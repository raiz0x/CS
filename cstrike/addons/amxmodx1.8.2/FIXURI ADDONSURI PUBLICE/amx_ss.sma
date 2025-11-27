// 199 hp, sau 255 -> 256 %
// de pus amx_ssban ??

#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < fun >
#include < geoip >
#include < colorchat >
#include < ANTI_PROTECTION >

//#pragma semicolon 1

#define PLUGIN "New Model ScreenShot"
#define VERSION "1.7x"//YEAAAAAAAAA 2018

#define SS_ACCESS	ADMIN_SLAY
#define SignTask	112233
#define UnSignTask	332211

enum
{
	INFO_NAME,
	INFO_IP,
	INFO_AUTHID
};

new const szTag[ ] = "AMXX >> SS";
new const szSite[ ] = "extreamcs.com/forum";

new g_iUserHP[ 33 ];
new g_iUserAP[ 33 ];

new PlayerName[ 32 ];
new PlayerIp[ 32 ];
new AdminName[ 32 ];

new iPlayer;

new gCvarMoveSpec;
new gCvarMinutesToGive;
new admin_spec, admin_message;

new TextForScreenShot[ 168 ];

new bool:choosed[33]

#include < dhudmessage >

#define CONTOR_SS

#if defined CONTOR_SS
new max_ss, pozes, poze, gmsgFade;
new param, idx;
//new finish;
#endif


//#define LICENTA_PRIN_IP_PORT

#if defined LICENTA_PRIN_IP_PORT
#include <licenta>
#endif


//#define LICENTA_PRIN_MODEL

#if defined LICENTA_PRIN_MODEL
#include <licentax>
#define IP "89.34.25.64"

public plugin_precache()
{
CheckServer(IP);
}
#endif


//#define LICENTA_PRIN_IP_PORTx

#if defined LICENTA_PRIN_IP_PORTx
#include <licentay>
#define IP "89.34.25.64:27015"
#define SHUT_DOWN 0
#endif


#define LICENTA_PRIN_EXPIRARE

#if defined LICENTA_PRIN_EXPIRARE
#include <licentaz>
#endif


public plugin_init( )
{
#if defined LICENTA_PRIN_IP_PORT
licenta()
#endif


#if defined LICENTA_PRIN_IP_PORTx
UTIL_CheckServerLicense(IP,SHUT_DOWN);
#endif


#if defined LICENTA_PRIN_EXPIRARE
licenta( );
#endif


	register_plugin( PLUGIN, VERSION, "Askhanar & eVoLuTiOn" );

	register_dictionary( "screen_message.txt" );

	gCvarMoveSpec = register_cvar( "ss_move_spec", "1" );
	gCvarMinutesToGive = register_cvar( "ss_time_to_give_ss", "5" );
	admin_spec = register_cvar( "ss_admin_must_be_spec", "1" );
	admin_message = register_cvar( "ss_admin_like_target", "0" );

#if defined CONTOR_SS
	max_ss = register_cvar( "ss_maximized", "5" );

	register_concmd( "amx_ss", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin > < nr. poze >" ); // + motiv?
	register_concmd( "amx_poza", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin > < nr. poze >" ); // + motiv?
	register_concmd( "amx_poze", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin > < nr. poze >" ); // + motiv?
	register_concmd( "amx_screenshot", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin > < nr. poze >" ); // + motiv?
	register_concmd( "amx_screenshots", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin > < nr. poze >" ); // + motiv?
	register_concmd( "amx_snapshot", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin > < nr. poze >" ); // + motiv?
	register_concmd( "amx_snapshots", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin > < nr. poze >" ); // + motiv?
	register_concmd( "amx_snap", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin > < nr. poze >" ); // + motiv?
	register_concmd( "amx_snaps", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin > < nr. poze >" ); // + motiv?

	gmsgFade = get_user_msgid( "ScreenFade" );
#else
	register_concmd( "amx_ss", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin >" ); // + motiv?
	register_concmd( "amx_poza", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin >" ); // + motiv?
	register_concmd( "amx_poze", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin >" ); // + motiv?
	register_concmd( "amx_screenshot", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin >" ); // + motiv?
	register_concmd( "amx_screenshots", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin >" ); // + motiv?
	register_concmd( "amx_snapshot", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin >" ); // + motiv?
	register_concmd( "amx_snapshots", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin >" ); // + motiv?
	register_concmd( "amx_snap", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin >" ); // + motiv?
	register_concmd( "amx_snaps", "ClCmdSS", SS_ACCESS, "< tinta > < contact admin >" ); // + motiv?
#endif
}

#if defined CONTOR_SS
public plugin_cfg( )
{
	clamp( get_pcvar_num( max_ss ), 5, 10 );
}
#endif

public client_putinserver( id )
{
	g_iUserHP[ id ] = 0;
	g_iUserAP[ id ] = 0;
}

public client_disconnect( id )
{
	g_iUserHP[ id ] = 0;
	g_iUserAP[ id ] = 0;

	if( task_exists( id + UnSignTask ) || task_exists( id + SignTask ) )
	{
		ColorChat( 0, NORMAL, "^x01[ ^x04%s ^x01] Jucatorul^x03 %s^x01 s-a deconectat in timp ce i se faceau 'x04poze^x01' !", szTag, GetInfo( id, INFO_NAME ) );
		remove_task( id + UnSignTask );
		remove_task( id + SignTask );
	}
}

public ClCmdSS( id )
{
	if( !( get_user_flags( id ) & SS_ACCESS ) )
	{
		client_cmd( id, "echo * Nu ai acces la aceasta comanda !" );
		return 1;
	}

	new szFirstArg[ 32 ], szSecondArgument[ 32 ];
	read_argv( 1, szFirstArg, sizeof ( szFirstArg ) -1 );
	read_argv( 2, szSecondArgument, sizeof ( szSecondArgument ) );

#if defined CONTOR_SS
	new arg3[ 32 ];
	read_argv( 3, arg3, sizeof ( arg3 ) -1 );

	if( equal( szFirstArg, "" ) || equal( szSecondArgument, "" ) || equal( arg3, "" ) )
	{
		client_cmd( id, "echo amx_ss < tinta > < contact admin > < nr. poze >" );
		return 1;
	}
#else
	if( equal( szFirstArg, "" ) || equal( szSecondArgument, "" ) )
	{
		client_cmd( id, "echo amx_ss < tinta > < contact admin >" );
		return 1;
	}
#endif

#if defined CONTOR_SS
	if( str_to_num( arg3 ) > get_pcvar_num( max_ss ) )
	{
		client_cmd( id, "echo * Poti face maxim %d poz%s. Asa ca setam noi valoarea adecvata( %d ).", get_pcvar_num( max_ss ), get_pcvar_num( max_ss ) == 1 ? "a" : "e", get_pcvar_num( max_ss ) );
		pozes = get_pcvar_num( max_ss );
		return 1;
	}
	else if( str_to_num( arg3 ) < get_pcvar_num( max_ss ) )
	{
		client_cmd( id, "echo * Poti face minim %d poz%s. Asa ca setam noi valoarea adecvata( %d ).", get_pcvar_num( max_ss ), get_pcvar_num( max_ss ) == 1 ? "a" : "e", get_pcvar_num( max_ss ) );
		pozes = get_pcvar_num( max_ss );
		return 1;
	}
#endif
//de facut task pt ss 1 ss2 ss3(+blindu) ss4, in care sa fie print center ss 1 etc..
	iPlayer = cmd_target( id, szFirstArg, 8 );

	if( !iPlayer )
	{
		client_cmd( id, "echo * Jucatorul specificat nu a fost gasit !" );
		return 1;
	}

	if( !is_user_alive( iPlayer ) )
	{
		client_cmd( id, "echo [ AMXX > SS ] Jucatorul %s nu este in viata !", GetInfo( iPlayer, INFO_NAME ) );
		return 1;
	}

	if( task_exists( SignTask ) || task_exists( UnSignTask ) )
	{
		client_cmd( id, "echo * Deja este activ un proces de verificare. Ai putina rabdare, sa se clarifice situatia." );
		return 1;
	}

	if( task_exists( iPlayer + SignTask ) || task_exists( iPlayer + UnSignTask ) )
	{
		client_cmd( id, "echo * Jucatorul %s este in curs de 'pozare' !", GetInfo( iPlayer, INFO_NAME ) );
		return 1;
	}

	if( cs_get_user_team( id ) != CS_TEAM_SPECTATOR && get_pcvar_num( admin_spec ) == 1 )
	{
		client_cmd( id, "echo [ AMXX > SS ] Trebuie sa fii Spectator ca sa poti face o poza !" );
		return 1;
	}

	g_iUserHP[ iPlayer ] = get_user_health( iPlayer );
	g_iUserAP[ iPlayer ] = get_user_armor( iPlayer );

	set_user_godmode( iPlayer, 1 );
	set_user_health( iPlayer, 255 );
	set_user_armor( iPlayer, 255 );

	new Float:Minutes = get_pcvar_float( gCvarMinutesToGive ) * 60.0;

	get_user_name( iPlayer, PlayerName, sizeof( PlayerName ) -1 );
	get_user_ip( iPlayer, PlayerIp, sizeof( PlayerIp ) -1 );

	get_user_name( id, AdminName, sizeof( AdminName ) -1 );

	//new country[ 33 ];
	new szHostName[ 64 ];
	get_cvar_string( "hostname", szHostName, sizeof ( szHostName ) -1 );
        //geoip_country( GetInfo( iPlayer, INFO_IP ), country );

	set_task( 3.0, "Messages", iPlayer );
	set_task( Minutes / 3.0, "BanThis", id );

	#if defined CONTOR_SS
	//pozes = get_pcvar_num( max_ss );
	poze = 1; // += 1

	client_print( iPlayer, print_center, "[SS # %d ]", poze+1 );

	/*if( str_to_num( arg3 ) >= 1 )  FIRST SS IS GREEN
	{
		set_task( 0.15, "Blind", iPlayer );
	}*/

	//set_task( 0.15, "GreenShot", 3322, _, _, "b" );

	ColorChat( 0, NORMAL, "^x01[^x04 AMXX ^x01>> ^x04SS ^x01] ^x03%s^x01: i'a facut^x04 %d p^x01oze jucatorului^x03 %s^x01 !", GetInfo( id, INFO_NAME ), str_to_num( arg3 ), GetInfo( iPlayer, INFO_NAME ) );

	if( get_pcvar_num( admin_message ) == 1 )
	{
		ColorChat( id, NORMAL, "^x01[^x04 AMXX ^x01>> ^x04SS ^x01] ^x03%s^x01 trebuie sa iti dea^x03 %d p^x01oze cu^x04 f^x01ormat^x03 .BMP^x01 si^x04 1^x01 cu^x03 f^x01ormat^x04 .TGA^x01 !", GetInfo( iPlayer, INFO_NAME ), str_to_num( arg3 ) );
		client_print( id, print_console, "[ AMXX >> SS ] %s trebuie sa iti dea %d poze cu format .BMP si 1 cu format .TGA !", GetInfo( iPlayer, INFO_NAME ) );
		client_print( id, print_console, "[ AMXX >> SS ] %s te va contacta pe %s , ales de catre tine !", GetInfo( iPlayer, INFO_NAME ), szSecondArgument );
	}

	RAIZ0_EXCESS( iPlayer, "screenshot" );

	//finish = str_to_num( arg3 );  cvaru max_ss ..

	//new array[ 2 ];
	//array[ 0 ] = id; //save usefull data in a vector so it can be reused
	//array[ 1 ] = iPlayer;
	//set_task( 0.1, "ss_propriuzis", 0, array, 2, "a", str_to_num( arg3 ) );  array[ 1 ] + cvaru'

	RAIZ0_EXCESS( iPlayer, "snapshot" );

	poze++;
	param = iPlayer;
	idx = id;
	set_task( 1.0, "GreenShot", 3322, _, _, "b" );


	ColorChat( iPlayer, NORMAL, "^x01[^x04 AMXX ^x01> ^x04SS ^x01] Nume Jucator:^x03 %s^x04 |^x01 Nume Admin:^x03 %s", GetInfo( iPlayer, INFO_NAME ), GetInfo( id, INFO_NAME ) );
	ColorChat( iPlayer, NORMAL, "^x01[^x04 AMXX ^x01> ^x04SS ^x01] IP Jucator:^x03 %s^x04 |^x01 IP Admin:^x03 %s", GetInfo( iPlayer, INFO_IP ), GetInfo( id, INFO_IP ) );
	ColorChat( iPlayer, NORMAL, "^x01[^x04 AMXX ^x01> ^x04SS ^x01] SteamId Jucator:^x03 %s^x04 |^x01 SteamId Admin:^x03 %s", GetInfo( iPlayer, INFO_AUTHID ), GetInfo( id, INFO_AUTHID ) );
	ColorChat( iPlayer, NORMAL, "^x01[^x04 AMXX ^x01> ^x04SS ^x01] Data si Ora:^x03 %s^x04 |^x01 Forum: ^x03%s", _get_time( ), szSite );
	//client_print( iPlayer, print_center, "Screenshot facut..." );

	client_print( iPlayer, print_console, "%s Nume Jucator: %s | Nume Admin: %s", szTag, GetInfo( iPlayer, INFO_NAME ), GetInfo( id, INFO_NAME ) );
	client_print( iPlayer, print_console, "%s IP Jucator: %s | IP Admin: %s", szTag, GetInfo( iPlayer, INFO_IP ), GetInfo( id, INFO_IP ) );
	client_print( iPlayer, print_console, "%s SteamId Jucator: %s | SteamId Admin: %s", szTag, GetInfo( iPlayer, INFO_AUTHID ), GetInfo( id, INFO_AUTHID ) );
	client_print( iPlayer, print_console, "%s Data si Ora: %s | Forum: %s", szTag, _get_time( ), szSite );
	#else
	set_task( 0.2, "Blind", iPlayer );

	ColorChat( 0, NORMAL, "^x01[^x04 AMXX ^x01>> ^x04SS ^x01] ^x03%s^x01: i'a facut poze jucatorului^x04 %s^x01 !", GetInfo( id, INFO_NAME ), GetInfo( iPlayer, INFO_NAME ) );

	if( get_pcvar_num( admin_message ) == 1 )
	{
		ColorChat( id, NORMAL, "^x01[^x04 AMXX ^x01>> ^x04SS ^x01] ^x03%s^x01 trebuie sa iti dea^x03 3^x01 poze cu^x04 f^x01ormat^x03 .BMP^x01 si^x04 1^x01 cu^x03 f^x01ormat^x04 .TGA^x01 !", GetInfo( iPlayer, INFO_NAME ) );
		client_print( id, print_console, "[ AMXX >> SS ] %s trebuie sa iti dea 3 poze cu format .BMP si 1 cu format .TGA !", GetInfo( iPlayer, INFO_NAME ) );
		client_print( id, print_console, "[ AMXX >> SS ] %s te va contacta pe %s , ales de catre tine !", GetInfo( iPlayer, INFO_NAME ), szSecondArgument );
	}

	ColorChat( iPlayer, NORMAL, "^x01[^x04 AMXX ^x01> ^x04SS ^x01] Nume Jucator:^x03 %s^x04 |^x01 Nume Admin:^x03 %s", GetInfo( iPlayer, INFO_NAME ), GetInfo( id, INFO_NAME ) );
	ColorChat( iPlayer, NORMAL, "^x01[^x04 AMXX ^x01> ^x04SS ^x01] IP Jucator:^x03 %s^x04 |^x01 IP Admin:^x03 %s", GetInfo( iPlayer, INFO_IP ), GetInfo( id, INFO_IP ) );
	ColorChat( iPlayer, NORMAL, "^x01[^x04 AMXX ^x01> ^x04SS ^x01] SteamId Jucator:^x03 %s^x04 |^x01 SteamId Admin:^x03 %s", GetInfo( iPlayer, INFO_AUTHID ), GetInfo( id, INFO_AUTHID ) );
	ColorChat( iPlayer, NORMAL, "^x01[^x04 AMXX ^x01> ^x04SS ^x01] Data si Ora:^x03 %s^x04 |^x01 Forum: ^x03%s", _get_time( ), szSite );
	client_print( iPlayer, print_center, "Screenshot facut..." );

	client_print( iPlayer, print_console, "%s Nume Jucator: %s | Nume Admin: %s", szTag, GetInfo( iPlayer, INFO_NAME ), GetInfo( id, INFO_NAME ) );
	client_print( iPlayer, print_console, "%s IP Jucator: %s | IP Admin: %s", szTag, GetInfo( iPlayer, INFO_IP ), GetInfo( id, INFO_IP ) );
	client_print( iPlayer, print_console, "%s SteamId Jucator: %s | SteamId Admin: %s", szTag, GetInfo( iPlayer, INFO_AUTHID ), GetInfo( id, INFO_AUTHID ) );
	client_print( iPlayer, print_console, "%s Data si Ora: %s | Forum: %s", szTag, _get_time( ), szSite );
	#endif

	client_cmd( iPlayer, "spk misc/antend" ); // vox/bizwarn.screen

	format( TextForScreenShot, sizeof( TextForScreenShot ), "%s", szSecondArgument );

	if( get_pcvar_num( admin_message ) == 1 )
	{
		ColorChat( id, NORMAL, "^x01[^x04 AMXX ^x01> ^x04SS ^x01] Nume Jucator:^x03 %s^x04 |^x01 Nume Admin:^x03 %s", GetInfo( iPlayer, INFO_NAME ), GetInfo( id, INFO_NAME ) );
		ColorChat( id, NORMAL, "^x01[^x04 AMXX ^x01> ^x04SS ^x01] IP Jucator:^x03 %s^x04 |^x01 IP Admin:^x03 %s", GetInfo( iPlayer, INFO_IP ), GetInfo( id, INFO_IP ) );
		ColorChat( id, NORMAL, "^x01[^x04 AMXX ^x01> ^x04SS ^x01] SteamId Jucator:^x03 %s^x04 |^x01 SteamId Admin:^x03 %s", GetInfo( iPlayer, INFO_AUTHID ), GetInfo( id, INFO_AUTHID ) );
		ColorChat( id, NORMAL, "^x01[^x04 AMXX ^x01> ^x04SS ^x01] Data si Ora:^x03 %s^x04 |^x01 Forum: ^x03%s", _get_time( ), szSite );
		client_print( id, print_center, "Screenshot facut pe %s...", GetInfo( iPlayer, INFO_NAME ) );

		client_print( id, print_console, "%s Nume Jucator: %s | Nume Admin: %s", szTag, GetInfo( iPlayer, INFO_NAME ), GetInfo( id, INFO_NAME ) );
		client_print( id, print_console, "%s IP Jucator: %s | IP Admin: %s", szTag, GetInfo( iPlayer, INFO_IP ), GetInfo( id, INFO_IP ) );
		client_print( id, print_console, "%s SteamId Jucator: %s | SteamId Admin: %s", szTag, GetInfo( iPlayer, INFO_AUTHID ), GetInfo( id, INFO_AUTHID ) );
		client_print( id, print_console, "%s Data si Ora: %s | Forum: %s", szTag, _get_time( ), szSite );

		RAIZ0_EXCESS( id, "wait;toggleconsole;wait;wait;snapshot;wait;wait;wait;wait;toggleconsole" );
	}

	for( new i = 1; i <= 3; i++ ) // de modificat
	{
		DisplayMessages( iPlayer, i );
	}

#if !defined CONTOR_SS
	set_task( 0.1, "SignScreen", iPlayer + SignTask );
#endif
	ColorChat( id, NORMAL, "^x01[^x04 AMXX ^x01>> ^x04SS ^x01] ^x03%s^x01 te va contacta la^x04 %s^x01 , id contact ales de tine!", GetInfo( iPlayer, INFO_NAME ), szSecondArgument );

	return 1;
}

public SignScreen( iPlayer )
{
	if( !is_user_connected( iPlayer ) )	return 1;
	iPlayer -= SignTask;

	RAIZ0_EXCESS( iPlayer, "wait;toggleconsole;wait;wait;snapshot;wait;wait;wait;wait;toggleconsole" );

	if( get_pcvar_num( gCvarMoveSpec ) )
	{
		user_kill( iPlayer, 1 );
		cs_set_user_team( iPlayer, CS_TEAM_SPECTATOR );
	}

	set_task( 0.7, "UnSignPlayer", iPlayer + UnSignTask );

	return 0;
}
	
public UnSignPlayer( iPlayer )
{
	if( !is_user_connected( iPlayer ) )	return 0;
	iPlayer -= UnSignTask;

	ColorChat( iPlayer, NORMAL, "^x01[ ^x04%s ^x01] Screenshot ^x03semnat^x01...", szTag );
	client_cmd( iPlayer, "echo * Screenshot semnat..." );
	client_print( iPlayer, print_center, "Screenshot semnat..." );

	if( is_user_alive( iPlayer ) && get_pcvar_num( gCvarMoveSpec ) != 1 )
	{
		set_user_godmode( iPlayer, 0 );
		set_user_health( iPlayer, g_iUserHP[ iPlayer ] );
		set_user_armor( iPlayer, g_iUserAP[ iPlayer ] );
	}

	g_iUserHP[ iPlayer ] = 0;
	g_iUserAP[ iPlayer ] = 0;

	return 0;
}

public DisplayMessages( iPlayer, const iMessage )
{
	new country[ 45 ];
	new szHostName[ 64 ];
	get_cvar_string( "hostname", szHostName, sizeof ( szHostName ) -1 );
	geoip_country( GetInfo( iPlayer, INFO_IP ), country );

	set_dhudmessage( 150, 0, 255, -1.0, 0.00, 0, 0.25, 1.0, 0.0, 0.0 );
	//ShowSyncHudMsg( iPlayer, SyncHudMessage, "%L", LANG_PLAYER, "SS_MSG_HUD", _get_time( ), szHostName, GetInfo( iPlayer, INFO_NAME ), GetInfo( iPlayer, INFO_IP ), GetInfo( iPlayer, INFO_AUTHID ), country, szSite );
	show_dhudmessage( iPlayer, "%L", LANG_PLAYER, "SS_MSG_HUD", _get_time( ), szHostName, GetInfo( iPlayer, INFO_NAME ), GetInfo( iPlayer, INFO_IP ), GetInfo( iPlayer, INFO_AUTHID ), country, szSite );
/*
	switch( iMessage )
	{
		case 1:
		{
			set_hudmessage( 255, 0, 0, 0.10, 0.25, 0, 0.0, 0.2, 0.0, 0.1, 1 );
			ShowSyncHudMsg( iPlayer, SyncHudMessage, "%s", szHostName );
		}
		case 2:
		{
			set_hudmessage( 235,  255, 45, -1.0, -1.0, 0, 0.0, 0.2, 0.0, 0.1, 2 );
			ShowSyncHudMsg( iPlayer, SyncHudMessage2, "%s", szHostName );
		}
		case 3:
		{
			set_hudmessage( 0, 0, 255, 0.75, 0.75, 0, 0.0, 0.2, 0.0, 0.1, 3 );
			ShowSyncHudMsg( iPlayer, SyncHudMessage3, "%s", szHostName );
		}
	}
*/
}

public Messages( iPlayer/* id*/ )
{
	//new iPlayer = cmd_target( id, szFirstArg, 8 );

	ColorChat( iPlayer, NORMAL, "^x01[^x04 AMXX ^x01>> ^x04SS ^x01] Trebuie sa prezinti^x03 3 p^x01oze cu^x04 f^x01ormat^x03 .BMP^x01 si^x04 1^x01 cu^x03 f^x01ormat^x04 .TGA^x01 la^x03 admin^x01-ul^x04 %s^x01 !", AdminName );

	ColorChat( iPlayer, NORMAL, "^x01(^x04 SS-ADMIN^x01 )^x03 %s^x01: CONTACT^x04 %s^x01 ! Ai^x03 %d minut%s + BUZZ^x04 !", AdminName, TextForScreenShot, get_pcvar_num( gCvarMinutesToGive ), get_pcvar_num( gCvarMinutesToGive ) == 1 ? "" : "e" );
	ColorChat( iPlayer, NORMAL, "^x01(^x04 SS-ADMIN^x01 )^x03 %s^x01: CONTACT^x04 %s^x01 ! Ai^x03 %d minut%s + BUZZ^x04 !", AdminName, TextForScreenShot, get_pcvar_num( gCvarMinutesToGive ), get_pcvar_num( gCvarMinutesToGive ) == 1 ? "" : "e" );
	ColorChat( iPlayer, NORMAL, "^x01(^x04 SS-ADMIN^x01 )^x03 %s^x01: CONTACT^x04 %s^x01 ! Ai^x03 %d minut%s + BUZZ^x04 !", AdminName, TextForScreenShot, get_pcvar_num( gCvarMinutesToGive ), get_pcvar_num( gCvarMinutesToGive ) == 1 ? "" : "e" );
	ColorChat( iPlayer, NORMAL, "^x01(^x04 SS-ADMIN^x01 )^x03 %s^x01: CONTACT^x04 %s^x01 ! Ai^x03 %d minut%s + BUZZ^x04 !", AdminName, TextForScreenShot, get_pcvar_num( gCvarMinutesToGive ), get_pcvar_num( gCvarMinutesToGive ) == 1 ? "" : "e" );
	ColorChat( iPlayer, NORMAL, "^x01(^x04 SS-ADMIN^x01 )^x03 %s^x01: CONTACT^x04 %s^x01 ! Ai^x03 %d minut%s + BUZZ^x04 !", AdminName, TextForScreenShot, get_pcvar_num( gCvarMinutesToGive ), get_pcvar_num( gCvarMinutesToGive ) == 1 ? "" : "e" );
}

public Blind( id )
{
	message_begin( MSG_ONE, get_user_msgid( "ScreenFade" ), _, id );
	write_short( floatround( 4096.0 * 1.0, floatround_round ) );
	write_short( floatround( 4096.0 * 1.0, floatround_round ) );
	write_short( 0x0000 );
	write_byte( 0 );
	write_byte( 255 );
	write_byte( 20 );
	write_byte( 250 );
	message_end( );
}

public BanThis( id )
{
	new MenuTitle[ 168 ];
	formatex( MenuTitle, sizeof( MenuTitle ), "\d|\r Screen Shot\d |\y Mertia\r %s\y ban?", PlayerName );

	new BanMenu = menu_create( MenuTitle, "BanHandler", 0 );

	menu_additem( BanMenu, "\yDa", "1", 0, -1 );
	menu_additem( BanMenu, "\yNu", "2", 0, -1 );
	menu_additem( BanMenu, "\wIntreaba-ma mai incolo", "3", 0, -1 );
	menu_additem( BanMenu, "\wMa descurc singur", "4", 0, -1 );

	menu_setprop( BanMenu, MPROP_EXIT, MEXIT_NEVER );
	menu_display( id, BanMenu );
}

public BanHandler( id, BanMenu, item )
{
	if( item == MENU_EXIT )
		return PLUGIN_HANDLED;

	new data[ 6 ], szName[ 64 ];
	new accesss, callback;

	menu_item_getinfo( BanMenu, item, accesss, data, sizeof( data ), szName, sizeof( szName ), callback );

	switch( str_to_num( data ) )
	{
		case 1:
		{
			if( !is_user_connected( find_player( "c", PlayerIp ) ) )
			{
				if( is_user_connected( id ) )
				{
					client_cmd( id, "amx_addban %s 3200 ^"Neprezentare Screen Shot^"", PlayerIp );
				}
				else
				{
					server_cmd( "addip ^"3200^" ^"%s^"; wait; writeip", PlayerIp );
				}
			}

			set_dhudmessage( 0, 255, 0, -1.0, -1.0, 0, 5.0, 10.0 );
			//ShowSyncHudMsg( 0, SyncHudMessage, "[ADMIN] %s: l-a Banat pe %s (IP: %s)^n Motiv : Problema cu Pozele facute !", AdminName, PlayerName, PlayerIp );
			show_dhudmessage( 0, "[ADMIN] %s: l-a Banat pe %s (IP: %s)^n Motiv : Problema la Pozele facute !", AdminName, PlayerName, PlayerIp );

			choosed[id]=true;
		}

		case 2:
		{
			set_dhudmessage( 0, 255, 0, -1.0, -1.0, 0, 5.0, 10.0 );
			//ShowSyncHudMsg( 0, SyncHudMessage, "[ADMIN] %s: l-a Crutat pe %s (IP: %s)^nMotiv : Pozele facute sunt Adecvate !", AdminName, PlayerName, PlayerIp );
			show_dhudmessage( 0, "[ADMIN] %s: l-a Crutat pe %s (IP: %s)^nMotiv : Pozele facute sunt Adecvate !", AdminName, PlayerName, PlayerIp );

			choosed[id]=true;
		}

		case 3:	if(!choosed[id]&&is_user_connected(id)&&is_user_admin(id)&&is_user_connected(iPlayer))	set_task(1.0,"BanThis",id);

		case 4:
		{
			choosed[id]=true;
			remove_task(UnSignTask);
			remove_task(SignTask);
			menu_destroy( BanMenu );
		}
	}
	menu_destroy( BanMenu );
	return PLUGIN_HANDLED;
}

#if defined CONTOR_SS
public GreenShot( id, level, cid )
{
	if( poze < pozes /*poze == pozes && get_pcvar_num( max_ss ) >= 3*/ )
	{
		if( poze == 3 )
		{
			//console_print( id, "[ AMXX >> SS ] Pozele pot fi cerute!" );

			message_begin( MSG_ONE, gmsgFade, { 0, 0, 0 }, param );
			write_short( 14 << 7 );
			write_short( 58 << 6 );
			write_short( 1 << 0 );
			write_byte( 5 );
			write_byte( 255 );
			write_byte( 0 );
			write_byte( 255 );
			message_end( );
		}

		client_print( param, print_center, "[SS # %d ]", poze+1 );

		RAIZ0_EXCESS( param, "snapshot" );

		poze++;
	}
	else
	{
		if( is_user_connected( param ) )
		{
				RAIZ0_EXCESS( param, "snapshot" );

			//finish = finish - 1;

			//if( finish == 0 )
			//{
				//RAIZ0_EXCESS( player, "kill" );

				if( is_user_alive( param ) && get_pcvar_num( gCvarMoveSpec ) != 1 )
				{
					set_user_godmode( param, 1 );
					set_user_health( param, g_iUserHP[ iPlayer ] );
					set_user_armor( param, g_iUserAP[ iPlayer ] );
				}

				g_iUserHP[ param ] = 0;
				g_iUserAP[ param ] = 0;

				if( is_user_alive( param ) )
				{
					user_kill( param, 1 );
					if( get_pcvar_num( gCvarMoveSpec ) == 1 )
					{
						cs_set_user_team( param, CS_TEAM_SPECTATOR );
					}
				}

				console_print( idx, "[ AMXX >> SS ] Pozele pot fi cerute!" );
			//}
		}
		remove_task( 3322 );
	}
	/*else remove_task( 3322 );*/

	return PLUGIN_HANDLED; // era continue
}





/*
public ss_propriuzis( array[ 2 ] )
{
	//take data and set them accordingly
	new player = array[ 1 ];
	new id = array[ 0 ];

	if( poze == pozes && get_pcvar_num( max_ss ) >= 3 )
	{
		if( poze == 3 )
		{
			console_print( id, "[ AMXX >> SS ] Pozele pot fi cerute!" );

			message_begin( MSG_ONE, gmsgFade, { 0, 0, 0 }, player );
			write_short( 14 << 7 );
			write_short( 58 << 6 );
			write_short( 1 << 0 );
			write_byte( 5 );
			write_byte( 255 );
			write_byte( 0 );
			write_byte( 255 );
			message_end( );
		}

		client_print( player, print_center, "[SS # %d ]", poze+1 ); // doar poze...

		RAIZ0_EXCESS( player, "snapshot" ); //ss

		poze++;
		//remove_task( 3322 );  if task exists
	}
	else
	{
		if( is_user_connected( player ) )
		{
				RAIZ0_EXCESS( player, "snapshot" ); //ss

			//finish = finish - 1;

			//if( finish == 0 )
			//{
				//RAIZ0_EXCESS( player, "kill" );

				if( is_user_alive( player ) && get_pcvar_num( gCvarMoveSpec ) != 1 )
				{
					set_user_godmode( player, 1 );
					set_user_health( player, g_iUserHP[ iPlayer ] );
					set_user_armor( player, g_iUserAP[ iPlayer ] );
				}

				g_iUserHP[ player ] = 0;
				g_iUserAP[ player ] = 0;

				if( is_user_alive( player ) )
				{
					user_kill( player, 1 );
					if( get_pcvar_num( gCvarMoveSpec ) == 1 )
					{
						cs_set_user_team( player, CS_TEAM_SPECTATOR );
					}
				}

			//	console_print( id, "[ AMXX >> SS ] Pozele pot fi cerute!" );
			//}
		}
		remove_task( 3322 );
	}
//	else remove_task( 3322 );

	return PLUGIN_HANDLED; // era continue
}
*/





#endif

stock GetInfo( id, const iInfo )
{
	new szInfoToReturn[ 64 ];

	switch( iInfo )
	{
		case INFO_NAME:
		{
			new szName[ 32 ];
			get_user_name( id, szName, sizeof( szName ) -1 );

			copy( szInfoToReturn, sizeof( szInfoToReturn ) -1, szName );
		}

		case INFO_IP:
		{
			new szIp[ 32 ];
			get_user_ip( id, szIp, sizeof( szIp ) -1, 1 );

			copy( szInfoToReturn, sizeof( szInfoToReturn ) -1, szIp );
		}

		case INFO_AUTHID:
		{
			new szAuthId[ 35 ];
			get_user_authid( id, szAuthId, sizeof( szAuthId ) -1 );

			copy( szInfoToReturn, sizeof( szInfoToReturn ) -1, szAuthId );
		}
	}

	return szInfoToReturn;
}

stock _get_time( )
{
	new logtime[ 32 ];
	get_time( "%d.%m.%Y - %H:%M:%S", logtime, sizeof( logtime ) -1 );

	return logtime;
}
