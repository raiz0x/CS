// timeunit_minutes - timeunit_seconds(ca sa arate si secundele) , timeunit_seconds = 0

#include < amxmodx >
#include < amxmisc >
#include < nvault >
#include < time >
#include < geoip >//special..

#include "colorchat.inl"

#pragma semicolon 1

new const g_sVaultName[ ] = "PlayedTime";

new g_hVault;


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


	register_plugin( "Played Time", "1.7x", "Hattrick & eVoLuTiOn" );

	register_dictionary( "played_time.txt" );
	register_dictionary( "time.txt" );

	register_concmd( "amx_time", "FuncCommandTime", ADMIN_BAN, "- Vezi playerii depe server si timpul lor" );
	register_clcmd( "amxx_time", "FuncCommandSay" );
	register_clcmd( "amxx_ore", "FuncCommandSay" );
	register_clcmd( "amxx_timp", "FuncCommandSay" );

	register_clcmd( "say", "hook_say" );
	register_clcmd( "say_team", "hook_say" );

	g_hVault = nvault_open( g_sVaultName );

	set_task( 60.0, "FuncUpgradePlayedTime", 237567, _, _, "b" );

	color_chat_init( );
}
/*
public plugin_cfg( )
{
	nvault_prune( g_hVault, 0, get_systime( ) - 604800 );
}
*/
public plugin_end( )
{
	nvault_close( g_hVault );
}

public FuncUpgradePlayedTime( )
{
	new sName[ 32 ];
	new sData[ 32 ];
	new iMinutes;

	for( new iPlayer = 1; iPlayer <= 32; iPlayer++ )
	{
		if( is_user_connected( iPlayer ) )
		{
			get_user_name( iPlayer, sName, charsmax( sName ) );

			nvault_get( g_hVault, sName, sData, charsmax( sData ) );

			iMinutes = str_to_num( sData );

			iMinutes++;

			num_to_str( iMinutes, sData, charsmax( sData ) );

			nvault_set( g_hVault, sName, sData );
		}
	}
}

public FuncCommandTime( iPlayer, iLevel, iCid )
{
	if( !cmd_access( iPlayer, iLevel, iCid, 1 ) )
	{
		return PLUGIN_HANDLED;
	}

	new iUser;
	new sName[ 32 ];
	new sData[ 32 ];
	new sText[ 128 ];
	new iMinutes;
	new address[ 32 ], authid[ 35 ], szCountry[ 20 ], flags, sflags[ 32 ];

	console_print( iPlayer, "[  %L - %L - IP - STEAMID - TARA - ACCES  ]", iPlayer, "CON_NAME_X", iPlayer, "CON_TIME_X" );
	console_print( iPlayer, "" );
	
	for( iUser = 1; iUser <= 32; iUser++ )
	{
		if( is_user_connected( iUser ) && !is_user_bot( iUser ) && !is_user_hltv( iUser ) )
		{
			get_user_name( iUser, sName, charsmax( sName ) );

			geoip_country( address, szCountry, 19 );
			get_user_ip( iUser, address, sizeof( address ) -1, 1 );
			get_user_authid( iUser, authid, sizeof( authid ) -1 );

			flags = get_user_flags( iUser );
			get_flags( flags, sflags, 31 );

			nvault_get( g_hVault, sName, sData, charsmax( sData ) );

			iMinutes = str_to_num( sData );

			if( iMinutes )
			{
				get_time_length( iUser, iMinutes, timeunit_minutes, sText, charsmax( sText ) );
				
				//console_print( iPlayer, "[  %32s - %32s  ]", sName, sText );

				console_print( iPlayer, "[  %s - %s - %s - %s - %s - %s  ]", sName, sText, address, authid, szCountry, sflags );

				//if( !iMinutes/* == 0*/ )
					//console_print( iPlayer, "[  %s - %s - %s - %s - %s - %s - %L  ]", sName, sText, address, authid, szCountry, sflags, iPlayer, "NOT_YET_CON" );
			}
			else
			{
				console_print( iPlayer, "[  %32s - %L  ]", sName, iPlayer, "NOT_YET_CON" );
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public FuncCommandSay( iPlayer )
{
	if( !is_user_connected( iPlayer ) ) // fara asta
		return 1;

	new arg[ 32 ];
	read_argv( 1, arg, sizeof ( arg ) -1 );

	if( equal( arg, "" ) )
	{
		new sName[ 32 ];
		new sData[ 32 ];
		new sText[ 128 ];
		new iMinutes;

		get_user_name( iPlayer, sName, charsmax( sName ) );

		nvault_get( g_hVault, sName, sData, charsmax( sData ) );

		iMinutes = str_to_num( sData );

		if( iMinutes )
		{
			get_time_length( iPlayer, iMinutes, timeunit_minutes, sText, charsmax( sText ) );

			ColorChat( iPlayer, YELLOW, "^x01[^x04 AMXX ^x01> ^x04TIMP ^x01] %L", iPlayer, "PLAYED_TIME", sText );
		}
		else
		{
			ColorChat( iPlayer, YELLOW, "^x01[^x04 AMXX ^x01> ^x04TIMP ^x01] %L", iPlayer, "PLAYED_TIME_NULL" );
		}

		return 1;
	}

	new player = cmd_target( iPlayer, arg, 8 );

	if( !is_user_connected( player ) || !player )
	{
		ColorChat( iPlayer, YELLOW, "^x01[^x04 AMXX ^x01> ^x04TIMP ^x01] Acest jucator nu este^x03 Conectat^x01 !" );
		return 1;
	}

	new sName[ 32 ];
	new sData[ 32 ];
	new sText[ 128 ];
	new iMinutes;

	get_user_name( player, sName, charsmax( sName ) );

	nvault_get( g_hVault, sName, sData, charsmax( sData ) );

	iMinutes = str_to_num( sData );

	if( iMinutes )
	{
		get_time_length( player, iMinutes, timeunit_minutes, sText, charsmax( sText ) );

		ColorChat( iPlayer, YELLOW, "^x01[^x04 AMXX ^x01> ^x04TIMP ^x01] %L", iPlayer, "PLAYED_TIMET", sName, sText );
	}
	else
	{
		ColorChat( iPlayer, YELLOW, "^x01[^x04 AMXX ^x01> ^x04TIMP ^x01] %L", iPlayer, "PLAYED_TIME_NULLT" );
	}

	return PLUGIN_HANDLED;
}

public hook_say( id )
{
	static s_Args[ 192 ];
	read_args( s_Args, sizeof( s_Args ) - 1 );

	if( !s_Args[ 0 ] )
		return 0;

	remove_quotes( s_Args[ 0 ] );

	if( equal( s_Args, "/time", strlen( "/time" ) ) )
	{
		replace( s_Args, sizeof( s_Args ) - 1, "/", "" );
		client_cmd( id, "amxx_%s", s_Args );
		return 1;
	}
	else if( equal( s_Args, "/ore", strlen( "/ore" ) ) )
	{
		replace( s_Args, sizeof( s_Args ) - 1, "/", "" );
		client_cmd( id, "amxx_%s", s_Args );
		return 1;
	}
	else if( equal( s_Args, "/timp", strlen( "/timp" ) ) )
	{
		replace( s_Args, sizeof( s_Args ) - 1, "/", "" );
		client_cmd( id, "amxx_%s", s_Args );
		return 1;
	}

	return 0;
}
