#include <amxmodx>
#include <amxmisc>
#include <cstrike>

enum
{
	
	INFO_NAME,
	INFO_IP,
	INFO_AUTHID
	
};

#define ACCESS ADMIN_SLAY	

//====================================================================
//      Variables
//====================================================================

// Thanks to Xellath
new g_szSpecialChars[ ][ ] =
{
    "/",
    "\",
    ">", 
    "<",
    "+",
    "%s",
    "#cstr",
    "#spec",
    "#title"
};

new cvar_log,cvar_amxx,cvar_save_name,text[192];

public plugin_init()
{
	register_plugin("AdminLogs", "1.2X", "pirvu")

//====================================================================
//      Cvars
//====================================================================

	cvar_log = register_cvar("log_method","1") // era 3 pt switch
	cvar_amxx=register_cvar("log_amxx_mod","1"); // all _ ...
	cvar_save_name=register_cvar("log_symbols","0");
}

public plugin_precache()
{
	new timedate[ 32 ],filename[200]
	get_configsdir(filename, sizeof filename - 1)
	format ( filename , sizeof filename-1 , "%s" , filename ) 
	if(!dir_exists(filename))	mkdir(filename)
	get_time( "%d.%m.%Y", timedate, 31 )
	format ( filename , sizeof filename-1 , "%s/adminlogs" , filename ) 
	if(!dir_exists(filename))	mkdir(filename)
	format ( filename , sizeof filename-1 , "%s/%s" , filename,timedate )
	if(!dir_exists(filename))	mkdir(filename)
}

public client_putinserver( id )
{
	if( !(get_user_flags(id) & ACCESS) || !is_user_connected(id) )
		return 0;

	new name[32]
	get_user_name(id,name,31)

	new timedate[ 32 ]
	get_time( "%d.%m.%Y", timedate, 31 )

	new flags, sflags[ 32 ]
	flags = get_user_flags( id )
	get_flags( flags, sflags, 31 )

	new filename[200]
	if (get_pcvar_num(cvar_save_name)) 
	{
		for( new i = 0; i < sizeof( g_szSpecialChars ); i++ )
        		if( containi( name, g_szSpecialChars[ i ] ) )
           			replace_all( name, charsmax( name ), g_szSpecialChars[ i ], " " );
		//thanks to Xellath
	}
	format ( filename , 199 , "addons/amxmodx/configs/adminlogs/%s/%s.txt" , timedate, name )

	if(! file_exists ( filename )) 
	{
		formatex(text, sizeof ( text ) -1, "-| Aici este salvata activitatea adminului %s in data de %s |-", GetInfo( id, INFO_NAME ),  _get_date( ) );
		write_file( filename, text );
		write_file( filename, " ", -1 );
		write_file( filename, " ", -1 );
		write_file( filename, "^n-------------------------------------------------------------------------------------------------------------------------------", -1 );
		formatex(text, sizeof ( text ) -1, "- Harta: %s| - Data: %s| - Timpul: %s|  %s [ %s | %s | `%s` ] s-a conectat pe server.", 
			_get_mapname( ), _get_date( ), _get_time( ), GetInfo( id, INFO_NAME ), GetInfo( id, INFO_AUTHID ), GetInfo( id, INFO_IP ),sflags );
		write_file( filename, text)
		write_file( filename, "-------------------------------------------------------------------------------------------------------------------------------", -1 );
	}
	else
	{
		write_file( filename, "^n-------------------------------------------------------------------------------------------------------------------------------", -1 );
		formatex(text,sizeof(text)-1, "- Harta: %s| - Data: %s| - Timpul: %s|  %s [ %s | %s | `%s` ] s-a conectat pe server.", 
			_get_mapname( ), _get_date( ), _get_time( ), GetInfo( id, INFO_NAME ), GetInfo( id, INFO_AUTHID ), GetInfo( id, INFO_IP ),sflags );
		write_file(filename, text)
		write_file( filename, "-------------------------------------------------------------------------------------------------------------------------------", -1 );
	}
	return 0;
}

public client_disconnect( id )
{
	if( !(get_user_flags(id) & ACCESS) )
		return 0;

	new name[32]
	get_user_name(id,name,31)

	new timedate[ 32 ]
	get_time( "%d.%m.%Y", timedate, 31 )

	new flags, sflags[ 32 ]
	flags = get_user_flags( id )
	get_flags( flags, sflags, 31 )

	new filename[200]
	if (get_pcvar_num(cvar_save_name)) 
	{
		for( new i = 0; i < sizeof( g_szSpecialChars ); i++ )
        		if( containi( name, g_szSpecialChars[ i ] ) )
           			replace_all( name, charsmax( name ), g_szSpecialChars[ i ], " " );
		//thanks to Xellath
	}
	format ( filename , 199 , "addons/amxmodx/configs/adminlogs/%s/%s.txt" , timedate, name )

	if(! file_exists ( filename )) 
	{
	formatex(text, sizeof ( text ) -1, "-| Aici este salvata activitatea adminului %s in data de %s |-", GetInfo( id, INFO_NAME ),  _get_date( ) );
	write_file( filename, text );
	write_file( filename, " ", -1 );
	write_file( filename, " ", -1 );
	write_file( filename, "-------------------------------------------------------------------------------------------------------------------------------", -1 );
	formatex(text, sizeof ( text ) -1, "- Harta: %s| - Data: %s| - Timpul: %s|  %s [ %s | %s | `%s` ] s-a deconectat de pe server. [ %i min jucat%s ]",
			_get_mapname( ), _get_date( ), _get_time( ), GetInfo( id, INFO_NAME ), GetInfo( id, INFO_AUTHID ), GetInfo( id, INFO_IP ),sflags, get_user_time( id, 1 ) / 60, get_user_time( id, 1 ) / 60 == 1 ? "" : "e" ); // fara 60 ?
	write_file(filename, text)
	write_file( filename, "-------------------------------------------------------------------------------------------------------------------------------^n", -1 );
	}
	else
	{
	write_file( filename, "-------------------------------------------------------------------------------------------------------------------------------", -1 );
	formatex(text, sizeof ( text ) -1, "- Harta: %s| - Data: %s| - Timpul: %s|  %s [ %s | %s | `%s` ] s-a deconectat de pe server. [ %i min jucate ]",
			_get_mapname( ), _get_date( ), _get_time( ), GetInfo( id, INFO_NAME ), GetInfo( id, INFO_AUTHID ), GetInfo( id, INFO_IP ),sflags, get_user_time( id, 1 ) / 60 ); // fara 60 ?
	write_file(filename, text)
	write_file( filename, "-------------------------------------------------------------------------------------------------------------------------------^n", -1 );
	}
	return 0;
	
}

//====================================================================
//     Hook player command
//====================================================================

public client_command(id)
{
	if (get_user_flags(id) & ACCESS) 
	{

//====================================================================
//	FORMAT FILE
//====================================================================

		new name[32]
		get_user_name(id,name,31)

		new timedate[ 32 ]
		get_time( "%d.%m.%Y", timedate, 31 )

		new flags, sflags[ 32 ]
		flags = get_user_flags( id )
		get_flags( flags, sflags, 31 )

		new filename[200]
		if (get_pcvar_num(cvar_save_name)) 
		{
			for( new i = 0; i < sizeof( g_szSpecialChars ); i++ )
        			if( containi( name, g_szSpecialChars[ i ] ) )
           				replace_all( name, charsmax( name ), g_szSpecialChars[ i ], " " );
			//thanks to Xellath
		}
		format ( filename , 199 , "addons/amxmodx/configs/adminlogs/%s/%s.txt" , timedate, name )

		if(! file_exists ( filename )) 
		{ 
			formatex(text, sizeof ( text ) -1, "-| Aici este salvata activitatea adminului %s in data de %s |-", GetInfo( id, INFO_NAME ),  _get_date( ) );
			write_file( filename, text );
			write_file( filename, " ", -1 );
			write_file( filename, " ", -1 );
		} 
		
//====================================================================
//	Read arguments
//====================================================================

		static szCommand[ 36 ];
		read_argv( 0, szCommand, sizeof ( szCommand ) -1 );
	
//====================================================================
//      If the command contains amx_
//====================================================================

		if( ( equali( szCommand, "amx_", 4 )  && get_pcvar_num(cvar_amxx) ) )
		{
//====================================================================
//	Get player name , steam , ip
//====================================================================

			new ip[32],steam[32];

			get_user_ip(id,ip,31,1)
			get_user_authid(id,steam,31)

//====================================================================
//	Get current date & time
//====================================================================

			static s_Time[ 16 ], s_Date[ 16 ];

			get_time ( "%d/%m/%Y", s_Date, charsmax ( s_Date ) );
   			get_time ( "%H:%M:%S", s_Time, charsmax ( s_Time ) );	

//====================================================================
// 	MARK COMMAND & READ FIRST ARGUMENT
//====================================================================

			static szArgs[ 101 ];
			read_args( szArgs, sizeof ( szArgs ) -1 );
		
			remove_quotes( szArgs );

//====================================================================
//	Log the command 
//====================================================================
	
			if (get_pcvar_num(cvar_log)==1)
			{
				formatex( text, sizeof ( text ) -1, "[%s|%s]: Ip [%s] / SteamID [%s] / Flags [%s] / Name [%s] -> typed the command '%s %s' in console",s_Date,s_Time,ip,steam,name,sflags,szCommand, szArgs );
				write_file(filename,text)
			}
		}
	}
	return PLUGIN_CONTINUE
}

stock _get_time( )
{
	new szTime[ 32 ];
	get_time( " %H:%M:%S ", szTime ,sizeof ( szTime ) -1 );
	
	return szTime;
}

stock _get_date( )
{
	new szDate[ 32 ];
	get_time( " %d/%m/%Y ", szDate ,sizeof ( szDate ) -1 );
	
	return szDate;
}

stock _get_mapname( )
{
	new szMapName[ 32 ];
	get_mapname( szMapName, sizeof ( szMapName ) -1 );
	
	return szMapName;
}

stock GetInfo( id, const iInfo )
{
	new szInfoToReturn[ 64 ];
	
	switch( iInfo )
	{
		case INFO_NAME:
		{
			static szName[ 32 ];
			get_user_name( id, szName, sizeof ( szName ) -1 );
			
			copy( szInfoToReturn, sizeof ( szInfoToReturn ) -1, szName );
		}
		case INFO_IP:
		{
			static szIp[ 32 ];
			get_user_ip( id, szIp, sizeof ( szIp ) -1, 1 );
			
			copy( szInfoToReturn, sizeof ( szInfoToReturn ) -1, szIp );
		}
		case INFO_AUTHID:
		{
			static szAuthId[ 35 ];
			get_user_authid( id, szAuthId, sizeof ( szAuthId ) -1 );
			
			copy( szInfoToReturn, sizeof ( szInfoToReturn ) -1, szAuthId );
		}
	}

	return szInfoToReturn;
}
