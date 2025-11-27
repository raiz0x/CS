/* 
	--| Nume: Girls Bonuses
	--| Autor: sPuf ?
	--| Versiune: 5.0
	
		--| Plugin cerut de catre RoCoFeLu 
			aici --|  cereri-cs/plugin-pentru-fete-t152446.html#p1222140
			
		--| Credite RoCoFeLu |-- ( toate ideile sunt provenite de la el )
			
		
		--| cvar-uri:
		
		--| activeaza daca sa primeasca sau nu bonus de hp la spawn ( default 1 ) |--
		girls_health 1/0 ( 1 activat sau 0 dezactivat )
		
		--| activeaza daca sa primeasca sau nu bonus de ap ( ap = armura ) la spawn ( default 1 ) |--
		girls_armour 1/0 ( 1 activat sau 0 dezactivat )
		
		--| urmatorul cvar este valabil in caz ca girls_health este 1 |--
		girls_hptoadd 15 ( cat hp sa primeasca la spawn )
		
		--| urmatorul cvar este valabil in caz ca girls_armour este 1 |--
		girls_aptoadd 35 ( cat ap ( armura ) sa primeasca la spawn )
		
		--| activeaza daca sa primeasca sau nu bonus de bani cand la spawn ( default 1 ) |--
		girls_spawnmoney 1/0 ( 1 activat sau 0 dezactivat )
		
		--| urmatorul cvar este valabil in caz ca girls_spawnmoney este 1 |--
		girls_spawnmoneytoadd 150 ( cati bani sa primeasca la spawn )
		
		--| activeaza daca sa primeasca sau nu bonus de bani cand omoara pe cineva ( default 1 ) |--
		girls_killmoney 1/0 ( 1 activat sau 0 dezactivat )
		
		--| urmatorul cvar este valabil in caz ca girls_killmoney este 1 |--
		girls_killmoneytoadd 500 ( cati bani sa primeasca la un kill )
		
		--| Numele modelelor pot fi schimbate de la urmatoarele linii:
		--| new const CT_GIRLS_MODELS[ ][ ] 
		--| new const T_GIRLS_MODELS[ ][ ]
		--| in loc de vip pui numele la model.
				ATENTIE !
				
		--| Numele modelului sa nu contina .mdl ( de ex: modelul e vip.mdl tu pui doar vip )
		--| Modelul .mdl sa fie pus in cstrike/models/player/NumeModel/NumeModel.mdl altfel pica serverul.
		--| In fisierul girls.ini veti trece numele / ip / steamd-ul fetei respective dupa cum urmeaza !
		--| 
		--| ;Exemplu de nume: "Andreea"
		--| ;Exemplu de ip: "123.123.123.123"
		--| ;Exemplu de steamid: "STEAM:0:1123123"
		--| ;Daca are ; sau // in fata nu este citit !
		--| ;Deasemenea ai grija ca numele sa fie scris corect,
				ceea ce vreau sa spun este ca orice litera sa fie identica numelui.
		--| ;Daca eu am sPuf ? si am trecut "spuf ?" nu va merge...si va trebui pus tot "sPuf ?"	(acum da)

*/

#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < hamsandwich >
#include < fun >

#define PLUGIN "Girls Bonuses"
#define VERSION "5.0"
#define AUTHOR "sPuf ?"

#pragma tabsize 0

new bool:UserIsGirl[ 33 ];

new const GIRLS_FILE[ ] = "girls.ini";

new szFile[ 128 ];

new const CT_GIRLS_MODELS[ ][ ] = {
	"fete_ct"
};

new const T_GIRLS_MODELS[ ][ ] = {
	"fete_t"
};

new cvar_health;
new cvar_armour;
new cvar_hptoadd;
new cvar_aptoadd;
new cvar_spawnmoney;
new cvar_spawnmoneytoadd;
new cvar_killmoney;
new cvar_killmoneytoadd;

//pentru cadavre.. cand mori / esti omorat, nu se va reseta modelul
new g_clcorpse;

new GirlModel[ 33 ];

public plugin_init( ) 
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	cvar_health = register_cvar( "girls_health", "1" );
	cvar_armour = register_cvar( "girls_armour", "1" );
	cvar_hptoadd = register_cvar( "girls_hptoadd", "15" );
	cvar_aptoadd = register_cvar( "girls_aptoadd", "35" );
	cvar_spawnmoney = register_cvar( "girls_spawnmoney", "1" );
	cvar_spawnmoneytoadd = register_cvar( "girls_spawnmoneytoadd", "150" );
	cvar_killmoney = register_cvar( "girls_killmoney", "1" );
	cvar_killmoneytoadd = register_cvar( "girls_killmoneytoadd", "500" );
	
	register_concmd( "amx_reloadgirls", "ConCmdReloadGirls", -1," Cauta nume de fete pe server ce corespund in girls.ini" );
	
	RegisterHam( Ham_Spawn, "player", "HamSpawnPostPlayer", 1 );
	register_event( "DeathMsg", "eventDeathMsg", "a" , "2!0" );//..oh
	
	g_clcorpse = get_user_msgid( "ClCorpse" );
	register_message( g_clcorpse, "HookClCorpse" );
}

public plugin_precache( ) 
{
	get_configsdir( szFile, charsmax(szFile) );
	formatex( szFile, charsmax(szFile), "%s/%s", szFile, GIRLS_FILE );
	
	if( !file_exists( szFile ) ) 
	{
		write_file( szFile, "; Aici treceti numele sau ip`ul ori steamid-ul fetelor !" );
		write_file( szFile, "; Exemplu de nume: ^"Andreea^"" );
		write_file( szFile, "; Exemplu de ip: ^"123.123.123.123^"" );
		write_file( szFile, "; Exemplu de steamid: ^"STEAM:0:1123123^"" );
	}
	
	new modelpath[ 65 ];
	for( new i = 0; i < sizeof ( CT_GIRLS_MODELS ); i++ )
	{
		formatex( modelpath, sizeof ( modelpath ) -1, "models/player/%s/%s.mdl", CT_GIRLS_MODELS[ i ], CT_GIRLS_MODELS[ i ] );
		precache_model( modelpath );
		
		replace(modelpath, charsmax(modelpath), ".mdl", "T.mdl")
		if(file_exists(modelpath))	precache_model(modelpath)
	}
	
	for( new i = 0; i < sizeof ( T_GIRLS_MODELS ); i++ )
	{
		formatex( modelpath, sizeof ( modelpath ) -1, "models/player/%s/%s.mdl", T_GIRLS_MODELS[ i ], T_GIRLS_MODELS[ i ] );
		precache_model( modelpath );
		
		replace(modelpath, charsmax(modelpath), ".mdl", "T.mdl")
		if(file_exists(modelpath))	precache_model(modelpath)
	}
}	

public client_authorized( id ) 
{
	GirlModel[ id ] = 0;
	UserIsGirl[ id ] = false;
	
	new Name[ 32 ], Ip[ 32 ], Steamid[ 35 ];
	get_user_name( id, Name, sizeof ( Name ) -1  );
	get_user_ip( id, Ip, sizeof ( Ip ) -1, 1 );
	get_user_authid( id, Steamid, sizeof ( Steamid ) -1 );
	
	CheckGirls( id, Name, Ip, Steamid );
}

public client_disconnect( id ) 
{
	GirlModel[ id ] = 0;
	UserIsGirl[ id ] = false;
}

public ConCmdReloadGirls( id )
{
	if( !( get_user_flags( id ) & read_flags( "d" ) ) )
	{
		client_cmd( id, "echo Nu ai acces la aceasta comanda !" );
		return 1;
	}
	
	new Players[ 32 ];
	new PlayersNum, player;
	get_players( Players, PlayersNum, "c" );	
	
	for( new i = 0 ; i < PlayersNum ; i++ ) 
	{
		player = Players[ i ];
		if( is_user_connected( player ) )
		{
			new Name[ 32 ], Ip[ 32 ], Steamid[ 35 ];
		
			get_user_name( player, Name, sizeof ( Name ) -1  );
			get_user_ip( player, Ip, sizeof ( Ip ) -1, 1 );
			get_user_authid( player, Steamid, sizeof ( Steamid ) -1 );
		
			CheckGirls( player, Name, Ip, Steamid );
		}
	}
	
	return 1;
}
public HamSpawnPostPlayer( id )
{
	if( !is_user_alive( id ) || UserIsGirl[ id ] == false ) return HAM_IGNORED;
	
	if( get_pcvar_num( cvar_spawnmoney) == 1 )
	{
		new money = cs_get_user_money( id );
		cs_set_user_money( id, money + get_pcvar_num( cvar_spawnmoneytoadd ) );
	}
		
	if( get_pcvar_num( cvar_health ) == 1 )
	{
		new health = get_user_health( id );
		set_user_health( id, health + get_pcvar_num( cvar_hptoadd ) );
	}
	
	if( get_pcvar_num( cvar_armour ) == 1 )
	{
		new armor = get_user_armor( id );
		set_user_armor( id, armor + get_pcvar_num( cvar_aptoadd ) );
	}
	
	new GirlTeam = get_user_team( id );
	SetGirlModel( id, GirlTeam );
	
	return HAM_IGNORED;
}
public SetGirlModel( id, const GirlTeam )
{
	switch( GirlTeam )
	{
		case 1:
		{
			GirlModel[ id ] = random( sizeof ( T_GIRLS_MODELS ) );//charsmax XD
			cs_set_user_model( id, T_GIRLS_MODELS[ GirlModel[ id ] ] );
		}
		case 2: 
		{
			GirlModel[ id ] = random( sizeof ( CT_GIRLS_MODELS ) );
			cs_set_user_model( id, CT_GIRLS_MODELS[ GirlModel[ id ] ] );
		}
	}
}

public HookClCorpse( )
{
	new id = get_msg_arg_int(12);
	
	if( UserIsGirl[ id ] == false )
		return;
    
	if( is_user_alive(id) )
	{
		switch( get_user_team( id ) )
		{
			case 1: set_msg_arg_string( 1, T_GIRLS_MODELS[ GirlModel[ id ] ] );//.............
			case 2: set_msg_arg_string( 1, CT_GIRLS_MODELS[ GirlModel[ id ] ] );
		}
	}
}

public eventDeathMsg( )
{
	if( get_pcvar_num( cvar_killmoney) != 1)
		return 0;
		
	new killer = read_data( 1 );
	new victim = read_data( 2 );
	//hs todo
	
	if( !killer || killer == victim || UserIsGirl[ killer ] == false )//connected xD
	{
		return 0;
	}
	
	new money = cs_get_user_money( killer );
	cs_set_user_money( killer, money + get_pcvar_num( cvar_killmoneytoadd ) );
	
	return 0;
}

public client_command( id )//2hard Xd
{
	new command[ 25 ];
	read_argv( 0, command , sizeof ( command ) -1 );
	
	if( equal( "model" , command, 0 ) )
	{
		if( UserIsGirl[ id ] == false )
		{
			return 1;
		}
	}
	
	return 0;
}

public CheckGirls( id, const Name[ ],  const Ip[ ], const Steamid[ ] ) 
{ 
	new File = fopen( szFile, "rt" );
	if( !File ) return 0;

	new data[ 512 ], Info[ 64 ];
	while( !feof( File ) ) 
	{
		fgets( File, data, charsmax(data) );
		if( !data[ 0 ] || data[ 0 ] == ';' || data[ 0 ] == '/' && data[ 1 ] == '/' ) 
			continue;
		parse( data, Info, charsmax(Info) );
		
		if( equal( Info, Name ) || equal( Info, Ip ) || equal( Info, Steamid )) 
		{
			UserIsGirl[ id ] = true;
			break;
		}
	}
	fclose( File );
	
	return 0;
}
