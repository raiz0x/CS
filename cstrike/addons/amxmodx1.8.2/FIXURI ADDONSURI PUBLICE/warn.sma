//de facut sa ii palpaie ecranu/tremure 5 secunde + 5 slapuri

#include < amxmodx >
#include < amxmisc >
#include < fakemeta >
#include < colorchat >
#include < nvault >

new g_Warn[ 33 ], name[ 32 ], namet[ 32 ], auth[ 32 ], address[ 32 ], warn_max,
p_max, warn_punish, warn_ban_lenght, p_lenght, g_dede;

new g_szName[ 33 ][ 32 ];


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


	register_plugin( "WARNINGS", "0.7x", "eVoLuTiOn" );

	register_concmd( "amx_warn", "addwarn_cmd" );
	register_concmd( "amx_unwarn", "removewarn_cmd" );

	warn_max = register_cvar( "max_warn", "3" );
	warn_punish = register_cvar( "warn_method", "1" );
	warn_ban_lenght = register_cvar( "warn_ban_duration", "120" );

	p_max = get_pcvar_num( warn_max );
	p_lenght = get_pcvar_num( warn_ban_lenght );

        g_dede = nvault_open( "warn_vaults" );

	register_forward( FM_ClientUserInfoChanged, "Fwd_ClientUserInfoChanged" );

	register_clcmd( "amx_warns", "ShowWrn" );

	register_clcmd( "say", "ClCmdSay" );
	register_clcmd( "say_team", "ClCmdSay" );
}

public SaveData( id )
{
        new PlayerName[ 33 ];
        get_user_name( id, PlayerName, 32 );

        new vaultkey[ 64 ], vaultdata[ 256 ];
        format( vaultkey, 63, "%s", PlayerName );
        format( vaultdata, 255, "%i", g_Warn[ id ] );
        nvault_set( g_dede, vaultkey, vaultdata );
        return PLUGIN_CONTINUE;
}

public LoadData( id )
{
        new PlayerName[ 33 ];
        get_user_name( id, PlayerName, 32 );

        new vaultkey[ 64 ], vaultdata[ 256 ];
        format( vaultkey, 63, "%s", PlayerName );
        format( vaultdata, 255, "%i", g_Warn[ id ] );
        nvault_get( g_dede, vaultkey, vaultdata, 255 );

        replace_all( vaultdata, 255, "`", " " );
        
        new playerw[ 32 ];

        parse( vaultdata, playerw, 31 );

        g_Warn[ id ] = str_to_num( playerw );

        return PLUGIN_CONTINUE;
}

public client_putinserver( id )
{
	if( is_user_bot( id ) )
		return PLUGIN_CONTINUE;

	get_user_name( id, g_szName[ id ], sizeof ( g_szName[ ] ) -1 );
	LoadData( id );
	return PLUGIN_CONTINUE;
}

public client_disconnect( id )
{
	SaveData( id );
}

public addwarn_cmd( id )
{
	if( !( get_user_flags( id ) & ADMIN_BAN ) )
	{
		client_cmd( id, "echo |I| Te inveti, nu vrei cam multe accese ?!" );
		return 1;
	}

	new arg[ 32 ], reason[ 32 ];
	read_argv( 1, arg, 31 );
	read_argv( 2, reason, 31 );
	remove_quotes( reason );
	get_user_name( id, name, 31 );

	if( equal( arg, "" ) || equal( reason, "" ) )
	{
		client_cmd( id, "echo |I| Valoare: amx_warn < player > < motiv >" );
		return 1;
	}

	new target = cmd_target( id, arg, CMDTARGET_NO_BOTS );

	if( !target )
        {
		client_cmd( id, "echo |I| Acest jucator nu este conectat pe server." );
		return 1;
        }

	get_user_name( target, namet, 31 );
	get_user_authid( target, auth, 31 );
	get_user_ip( target, address, 31 );

	g_Warn[ target ] += 1;

	SaveData( target );

	ColorChat( 0, NORMAL, "^x04[^x01 ADM!N^x04 ]^x03 %s^x01: i-a dat o avertizare jucatorului^x04 %s^x01 ! Motivul:^x03 %s", name, get_name( target ), reason );
	ColorChat( target, NORMAL, "Ai primit^x04 +1^x03 Avertizare^x01 de la adminul^x04 %s^x01 ! Motivul:^x03 %s^x01 ( ^x04%d^x01/^x03%d^x01 Avertizari )", name, reason, g_Warn[ target ], get_pcvar_num( warn_max ) );

	console_print( id, "Jucatorul respectiv a primit Avertizarea cu succes !" );

	if( g_Warn[ target ] == p_max )
	{
		switch( get_pcvar_num( warn_punish ) )
		{
			case 1:
			{
				server_cmd( "kick #%d ^"Ai primit kick deoarece ai acumulat %d Avertizari !^"", get_user_userid( target ), g_Warn[ target ] );
				ColorChat( 0, NORMAL, "^x01Jucatorul^x04 %s^x01 a primit kick deoarece a acumulat^x03 %d^x01 Avertizari !", get_name( target ), g_Warn[ target ] );
			}

			case 2:
			{
				set_task( 7.0, "quit", target );
				ColorChat( target, NORMAL, "^x01Pentru ca ai acumulat^x04 %d^x01 Avertizari, ti se va inchide^x03 Jocul^x01 !", g_Warn[ target ] ) ;
				ColorChat( 0, NORMAL, "^x01Jocul Jucatorului^x04 %s^x01 i se va inchide, deaorece a acumulat^x03 %d^x01 Avertizari !", get_name( target ), g_Warn[ target ] ) ;
			}

			case 3:
			{
				server_cmd( "kick #%d ^"Deoarece ai aculumat %d Avertismente ai primit BAN %s minut(e)^"; wait; addip ^"%s^" ^"%s^"; wait; writeid", get_user_userid( target ), g_Warn[ target ], p_lenght, p_lenght, address );
				ColorChat( 0, NORMAL, "^x01Jucatorul^x04 %s^x01 a primit Ban^x03 %s^x01 minute, deoarece a acumulat^x03 %d^x01 Avertismente !", get_name( target ), p_lenght, g_Warn[ target ] );
			}
		}
		g_Warn[ target ] = 0;
	}
	return PLUGIN_CONTINUE;
}

public removewarn_cmd( id )
{
	if( !( get_user_flags( id ) & ADMIN_BAN ) )
	{
		client_cmd( id, "echo |I| Te inveti, nu vrei cam multe accese ?!" );
		return 1;
	}

	new arg[ 32 ], reason[ 32 ];
	read_argv( 1, arg, 31 );
	read_argv( 2, reason, 31 );
	remove_quotes( reason );
	get_user_name( id, name, 31 );

	if( equal( arg, "" ) || equal( reason, "" ) )
	{
		client_cmd( id, "echo |I| Valoare: amx_unwarn < player > < motiv >" );
		return 1;
	}

	new target = cmd_target( id, arg, CMDTARGET_NO_BOTS );

	if( !target )
        {
		client_cmd( id, "echo |I| Acest jucator nu este conectat pe server." );
		return 1;
        }

	get_user_name( target, namet, 31 );

	if( g_Warn[ target ] == 0 )
	{
		console_print( id, "|I| Acel jucator nu are nici un Avertisment !" );
		return PLUGIN_HANDLED;
	}
	else
	{
		console_print( id, "|I| Jucatorul respectiv a scapat de Avertizare cu succes !" );

		g_Warn[ target ] -= 1;

		SaveData( target );

		ColorChat( target, NORMAL, "^x04[^x01 ADM!N^x04 ]^x03 %s^x01: ti-a sters 1 warn ! Motivul:^x04 %s", name, reason );
		ColorChat( 0, NORMAL, "^x04[^x01 ADM!N^x04 ]^x03 %s^x01: i-a sters 1 warn jucatorului^x04 %s^x01 ! Motivul:^x03 %s", name, get_name( target ), reason );
	}

	return PLUGIN_HANDLED;
}

public Fwd_ClientUserInfoChanged( id, szBuffer )
{
	if ( !is_user_connected( id ) ) 
		return FMRES_IGNORED;

	static szNewName[ 32 ];

	engfunc( EngFunc_InfoKeyValue, szBuffer, "name", szNewName, sizeof ( szNewName ) -1 );

	if ( equal( szNewName, g_szName[ id ] ) )
		return FMRES_IGNORED;

	SaveData( id );

	ColorChat( id, NORMAL, "^x04[^x01 WARN^x04 ]^x01 Tocmai ti-ai schimbat numele din^x03 %s^x01 in^x04 %s^x01 !", g_szName[ id ], szNewName );
	ColorChat( id, NORMAL, "^x04[^x01 WARN^x04 ]^x01 Am salvat^x03 %i^x01 warn(uri) pe numele^x04 %s^x01 !", g_Warn[ id ], g_szName[ id ] );

	copy( g_szName[ id ], sizeof ( g_szName[ ] ) -1, szNewName );
	LoadData( id );

	ColorChat( id, NORMAL, "^x04[^x01 WARN^x04 ]^x01 Am incarcat^x03 %i^x01 warn(uri) de pe noul nume (^x04 %s^x01 ) !", g_Warn[ id ], g_szName[ id ] );

	return FMRES_IGNORED;
}

public ClCmdSay( id )
{
	static szArgs[ 192 ];
	read_args( szArgs, sizeof ( szArgs ) -1 );

	if( !szArgs[ 0 ] )
		return 0;

	new szCommand[ 192 ];
	remove_quotes( szArgs/*[ 0 ]*/ );

	if( equali( szArgs, "/warns", strlen( "/warns" ) ) )
	{
		replace( szArgs, sizeof ( szArgs ) -1, "/", "" );
		formatex( szCommand, sizeof ( szCommand ) -1, "amx_%s", szArgs );
		client_cmd( id, szCommand );
		return 1;
	}
	if( equali( szArgs, "/warn", strlen( "/warn" ) ) )
	{
		replace( szArgs, sizeof ( szArgs ) -1, "/", "" );
		formatex( szCommand, sizeof ( szCommand ) -1, "amx_%s", szArgs );
		client_cmd( id, szCommand );
		return 1;
	}

	return 0;
}

public ShowWrn( id )
{
	if( !is_user_connected( id ) )
		return 1;

	new szArg[ 32 ];
    	read_argv( 1, szArg, sizeof ( szArg ) -1 );

	if( equal( szArg, "" ) ) 
	{
		ColorChat( id, NORMAL, "^x04[^x01 WARNS^x04 ]^x01 Ai ^x03%i^x01 warn-uri! La^x04 3^x01/^x03%i^x01 vei primi ban pentru ^x04%i^x01 minute !", g_Warn[ id ], p_max, p_lenght );
		return 1;
	}

    	new iPlayer = cmd_target( id, szArg, 8 );
    	if( !iPlayer )
	{
		ColorChat( id, NORMAL, "^x04[^x01 WARNS^x04 ]^x01 Jucatorul specificat nu a fost gasit !" );
		return 1;
	}

	new szName[ 32 ];
	get_user_name( iPlayer, szName, sizeof ( szName ) -1 );

	ColorChat( id, NORMAL, "^x04[^x01 WARNS^x04 ]^x03 %s^x01 are ^x04%i^x01 warn-uri! La^x03 3^x01/^x04%i^x01 va primi ban pentru ^x03%i^x01 minute !", szName, g_Warn[ iPlayer ], p_max, p_lenght );

	return 1;
}

public quit( target )
{
	client_cmd( target, "heartbeat" );
}

stock get_name( id )
{
	new name[ 32 ];
	get_user_name( id, name, sizeof( name ) -1 );

	return name;
}
