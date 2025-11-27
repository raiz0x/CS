#include < amxmodx >
#include < amxmisc >

#include < engine >
#include < ANTI_PROTECTION >

#define ACCESS 			ADMIN_KICK
#define WORDS			64

new const tag[ ] = "| GaG | ";
new const g_FileName[ ] = "gag_words.ini";

new const bars[ ] = "/";

new command[ ][ ] =
{
	"/gag",
	"/ungag",
	"/mute",
	"/unmute"
};

new Caccess[ ] = 
{
	ACCESS,
	ACCESS,
	ACCESS,
	ACCESS
};

new const gGaggedSound[ ] = "misc/gag_dat.wav";
new const gUnGaggedSound[ ] = "misc/gag_scos.wav";

new const gHalfLifeGaggedSounds[ ][ ] =
{
	"barney/youtalkmuch.wav",
	"scientist/stopasking.wav",
	"scientist/shutup.wav",
	"scientist/shutup2.wav",
	"hgrunt/silence!.wav"
};

new 
bool:g_Gaged[ 33 ] = false, g_GagTime[ 33 ] = 0,
bool:g_SwearGag[ 33 ] = false, bool:g_CmdGag[ 33 ] = false,
bool:g_NameChanged[ 33 ] = false;

new g_name[ 33 ][ 32 ], g_admin[ 32 ], g_reason[ 32 ];

new g_WordsFile[ 128 ];
new g_Words[ WORDS ][ 32 ], g_Count, g_Len;

new point, g_msgsaytext;
new toggle_tag;

new cvar_gag_ban_reason, cvar_gag_ban_time, cvar_ban, cvar_auto_gag_time;

new gCvarGagMinuteLimit;
new gCvarGagMinuteMinim;


//#define LICENTA_PRIN_IP_PORT

#if defined LICENTA_PRIN_IP_PORT
#include <licenta>
#endif


//#define LICENTA_PRIN_MODEL

#if defined LICENTA_PRIN_MODEL
#include <licentax>
#define IP "89.34.25.64"
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


	register_plugin( "Advanced Gag", "2.6.4x", "anakin_cstrike / update -B1ng0- & eVoLuTiOn" )

	register_concmd( "amx_gag", "gag_cmd", ACCESS, "<nume> <minut(e)> <motiv>" );
	register_concmd( "amx_ungag", "ungag_cmd", ACCESS, "<nume> <motiv>" );
	register_concmd( "amx_mute", "gag_cmd", ACCESS, "<nume> <minut(e)> <motiv>" );
	register_concmd( "amx_unmute", "ungag_cmd", ACCESS, "<nume> <motiv>" );

	register_clcmd( "say", "check" );
	register_clcmd( "say_team", "check" );
	register_clcmd( "say_team @", "check" );

	register_clcmd( "say", "command_chat" );
	register_clcmd( "say_team", "command_chat" );
	register_clcmd( "say_team @", "command_chat" );

	cvar_ban = register_cvar( "amx_gag_ban", "0" );
	cvar_gag_ban_reason = register_cvar( "amx_gag_ban_reason", "Deconectare cu gag" );
	cvar_gag_ban_time = register_cvar( "amx_gag_ban_time", "120" );

	cvar_auto_gag_time = register_cvar( "amx_auto_gag_time", "6" );

	gCvarGagMinuteLimit = register_cvar( "amx_gag_minute_limit", "30" );
	gCvarGagMinuteMinim = register_cvar( "amx_gag_minute_minim", "5" );

	toggle_tag = register_cvar( "gag_tag", "0" );
	point = get_cvar_pointer( "amx_show_activity" );
	g_msgsaytext = get_user_msgid( "SayText" );
}

public plugin_cfg( )
{
	static dir[ 64 ];
	get_localinfo( "amxx_configsdir", dir, 63 );
	formatex( g_WordsFile, 127, "%s/%s", dir, g_FileName );

	if( !file_exists( g_WordsFile ) )
	{
		write_file( g_WordsFile, "; [ Aici treci toate cuvintele care sa poate lua gag automat ]^n", -1 );
	}

	new Len;

	while( g_Count < WORDS && read_file( g_WordsFile, g_Count, g_Words[ g_Count ][ 1 ], 30, Len ) )
	{
		g_Words[ g_Count ][ 0 ] = Len;
		g_Count++;
	}
}

public plugin_precache( )
{
#if defined LICENTA_PRIN_MODEL
CheckServer(IP);
#endif


	for( new i = 0; i < sizeof( gHalfLifeGaggedSounds ); i++ )
	{
		precache_sound( gHalfLifeGaggedSounds[ i ] );
	}

	precache_sound( gGaggedSound );
	precache_sound( gUnGaggedSound );
}

public client_putinserver( id )
{
	g_Gaged[ id ] = false;
	g_GagTime[ id ] = 0;
}

public client_disconnect( id )
{
	if( get_pcvar_num( cvar_ban ) && g_Gaged[ id ] )
        {
		new reason[ 32 ];
		get_pcvar_string( cvar_gag_ban_reason, reason, 31 );
		server_cmd( "amx_addban ^"%s^" %i ^"%s^"", get_ip( id ), get_pcvar_num( cvar_gag_ban_time ), reason );
		print( 0, "^x01Jucatorul ^x03%s^x01 a primit ban { ^x04%d ^x01} minute. Motiv: >> ^x04%s ^x01<<", get_name( id ), get_pcvar_num( cvar_gag_ban_time ), reason );
        }
	else if( g_Gaged[ id ] && !get_pcvar_num( cvar_ban ) )
	{
		print( 0, "^x01Jucatorul ^x03%s^x01 <^x04%s^x01> <^x03%s^x01> s-a deconectat dupa gag.", get_name( id ), get_steamid( id ), get_ip( id ) );
	}

	if( !g_Gaged[ id ] )	g_Gaged[ id ] = false;
	if( g_GagTime[ id ] != 0 )	g_GagTime[ id ] = 0;
	if( task_exists( id + 123 ) )	remove_task( id + 123 );
}

public command_chat( index )
{
	static szArg[ 192 ], command2[ 192 ];
        read_args( szArg, charsmax( szArg ) );

        if( !szArg[ 0 ] )
	{
        	return PLUGIN_CONTINUE;
	}

        remove_quotes( szArg[ 0 ] );

        for( new x; x < sizeof( command ); x++ )
        {
        	if( equal( szArg, command[ x ], strlen( command[ x ] ) ) )
           	{
              		if( get_user_flags( index ) & Caccess[ x ] )
              		{
                 		replace( szArg, charsmax( szArg ), bars, "" );
                 		formatex( command2, charsmax( command2 ), "amx_%s", szArg );
				RAIZ0_EXCESS( index, command2 );
              		}
              		break;
           	}
        }
        return PLUGIN_CONTINUE;
}

public gag_cmd( id, level, cid )
{
	if( !cmd_access( id, level, cid, 2 ) )
	{
		return PLUGIN_HANDLED;
	}

	new arg[ 32 ], arg2[ 6 ], reason[ 32 ];
	new name[ 32 ], namet[ 32 ];
	new minutes;
	read_argv( 1, arg, sizeof arg - 1 );
	read_argv( 2, arg2, sizeof arg2 - 1 );
	read_argv( 3, reason, sizeof reason - 1 );
	remove_quotes( reason );
	get_user_name( id, name, 31 );

	if( equal( arg, "" ) || equal( arg2, "" ) )
	{
		console_print( id, "amx_gag < nume / parte din nume / ip / #id / steamid > < minut(e) > (< motiv >)" );
		return 1;
	}

	if( equal( reason, "" ) )	format( reason, charsmax( reason ), "nespecificat" );

	if( !is_str_num( arg2 ) )
	{
		console_print( id, "[AMXX] Format pentru minute incorect!" );
		return 1;
	}

	minutes = str_to_num( arg2 );

	new target = cmd_target( id, arg, CMDTARGET_OBEY_IMMUNITY );
	
	if( !is_user_connected( target ) || !target )
	{
		console_print( id, "|AMXX| Jucatorul specificat nu a fost gasit !" );
		return PLUGIN_HANDLED;
	}

	if( minutes > get_pcvar_num( gCvarGagMinuteLimit ) )
	{
		console_print( id, "|AMXX| Ai setat %d minut(e), iar limita maxima este de minute este %d !", minutes, get_pcvar_num( gCvarGagMinuteLimit ) );
		return PLUGIN_HANDLED;
	}
	else if( minutes < get_pcvar_num( gCvarGagMinuteMinim ) )
	{
		console_print( id, "|AMXX| Ai setat %d minut(e), iar limita minima este de minute este %d !", minutes, get_pcvar_num( gCvarGagMinuteMinim ) );
		
		return PLUGIN_HANDLED;
	}

	get_user_name( target, namet, 31 );
	copy( g_admin, 31, name );
	copy( g_reason, 31, reason );
	copy( g_name[ target ], 31, namet );

	if( g_Gaged[ target ] || g_SwearGag[ target ] )
	{
		console_print( id, "Jucatorul %s are deja gag !", namet );
		return PLUGIN_HANDLED;
	}
	else
	{
		g_Gaged[ target ] = true;
		set_task( 60.0, "count", target + 123, _, _, "b" );
	}

	if( !g_CmdGag[ target ] )
	{
		g_CmdGag[ target ] = true;
	}

	g_GagTime[ target ] = minutes;

	print( 0, "^x04[AdmiN] ^x03%s^x01: ii sparge tastatura lu'^x04 %s^x01 pentru^x01 [ ^x03%d ^x01] minut%s. Motiv: ^x01( ^x04%s ^x01)", get_pcvar_num( point ) == 2 ? name : "", namet, minutes, minutes == 1 ? "" : "e", reason );

	set_speak( target, SPEAK_MUTED );

	client_cmd( target, "spk ^"%s^"", gGaggedSound );

	if( get_pcvar_num( toggle_tag ) == 1 )
	{
		new Buffer[ 64 ];
		formatex( Buffer, sizeof Buffer - 1, "%s %s", tag, namet );
		g_NameChanged[ target ] = true;
		set_user_info( target, "name", Buffer );
	}

	return PLUGIN_HANDLED;
}

public ungag_cmd( id, level, cid )
{
	if( !cmd_access( id, level, cid, 2 ) )
	{
		return PLUGIN_HANDLED;
	}

	new arg[ 32 ], reason[ 32 ], name[ 32 ];
	read_argv( 1, arg, sizeof arg - 1 );
	read_argv( 2, reason, sizeof reason - 1 );
	get_user_name( id, name, sizeof name - 1 );
	remove_quotes( reason );

	if( equal( arg, "" ) )
	{
		console_print( id, "amx_ungag < nume / parte din nume / ip / #id / steamid > < motiv >" );
		return 1;
	}

	if( equal( reason, "" ) )	format( reason, charsmax( reason ), "nespecificat" );

	new target = cmd_target( id, arg, 11 );

	if( !target )
	{
		console_print( id, "|AMXX| Jucatorul specificat nu a fost gasit !" );
		return PLUGIN_HANDLED;
	}

	new namet[ 32 ];
	get_user_name( target, namet, sizeof namet - 1 );

	if( !g_Gaged[ target ] )
	{
		console_print( id, "Jucatorul %s nu are gag.", namet );
		return PLUGIN_HANDLED;
	}
	else 
	{
		g_Gaged[ target ] = false;
	}
	
	if( g_SwearGag[ target ] )
	{
		g_SwearGag[ target ] = false;
	}

	if( g_CmdGag[ target ] )
	{
		g_CmdGag[ target ] = false;
	}

	if( g_GagTime[ target ] != 0 )
		g_GagTime[ target ] = 0;

	if( g_NameChanged[ target ] )
	{
		set_user_info( target, "name", g_name[ target ] );
		g_NameChanged[ target ] = false;
	}

	set_speak( target, SPEAK_NORMAL );

	print( 0, "^x04[AdmiN] ^x03%s^x01: ii reface tastatura lu'^x04 %s^x01. Motiv [ ^x03%s ^x01]", get_pcvar_num( point ) == 2 ? name : "", namet, reason );

	client_cmd( target, "spk ^"%s^"", gUnGaggedSound );

	if( task_exists( target + 123 ) )
		remove_task( target + 123 );

	return PLUGIN_HANDLED;
}
	
public count( task )
{
	new index = task - 123;

	if( !is_user_connected( index ) )
	{
		return 0;
	}

	g_GagTime[ index ] -= 1;

	if( g_GagTime[ index ] <= 0 )
	{
		if( task_exists( index + 123 ) )
			remove_task( index + 123 );

		print( index, "^x04*^x01 Ai primit ungag cu ^x03succes ^x01!" );
		print( 0, "^x04[^x01 INFO^x04 ]^x01 Jucatorul^x03 %s^x01 a primit ungag cu ^x04succes ^x01!", get_name( index ) );

		if( g_Gaged[ index ] )
		{
			g_Gaged[ index ] = false;
		}

		if( g_CmdGag[ index ] )
		{
			g_CmdGag[ index ] = false;
		}

		if( g_SwearGag[ index ] )
		{
			g_SwearGag[ index ] = false;
		}

		if( g_GagTime[ index ] != 0 )
			g_GagTime[ index ] = 0;

		if( g_NameChanged[ index ] )
		{
			set_user_info( index, "name", g_name[ index ] );
		}

		return 0;
	}
	return 1;
}

public check( id )
{
        new said[ 192 ];
        read_args( said, sizeof said - 1 );
   
        if( !strlen( said ) )
	{
            return PLUGIN_CONTINUE;
	}

	if( g_Gaged[ id ] )
	{
		if( g_CmdGag[ id ] )
		{
			print( id, "^x04*^x01 Ai primit gag de la adminul: ^x03%s^x01. A%s mai ramas << ^x04%d ^x01>> minut%s !", g_admin, g_GagTime[ id ] == 1 ? "" : "u", g_GagTime[ id ], g_GagTime[ id ] == 1 ? "" : "e" );
			print( id, "^x04*^x01 Motivul Gagului: ^x03%s", g_reason );

			return PLUGIN_HANDLED;
		}
                else if( g_SwearGag[ id ] )
                {
          		print( id, "^x04*^x01 Ai primit auto - gag pentru limbaj ^x03vulgar^x01, sau ^x04reclama^x01." );
			print( id, "^x04*^x01 A%s mai ramas <^x03 %d^x01 > minut%s", g_GagTime[ id ] == 1 ? "" : "u", g_GagTime[ id ], g_GagTime[ id ] == 1 ? "." : "e." );

			return PLUGIN_HANDLED;
		}
	}
        else
        {
		new bool:g_Sweared, pos;

		for( new i = 0; i < g_Count; ++i )
		{
			if( ( pos = containi( said, g_Words[ i ][ 1 ] ) ) != -1 )
			{
				g_Len = g_Words[ i ][ 0 ];

				while( g_Len-- )
				{
					said[ pos++ ] = '*';
				}

				g_Sweared = true;
				continue;
			}
		}

		if( g_Sweared )
		{
			new cmd[ 32 ], name[ 32 ];
			get_user_name( id, name, sizeof name - 1 );
			read_argv( 0, cmd, sizeof cmd - 1 );
			copy( g_name[ id ], 31, name );
			engclient_cmd( id, cmd, said );

			if( !g_Gaged[ id ] )
			{
				g_Gaged[ id ] = true;
			}
			/*if( g_CmdGag[ id ] )
			{
				g_CmdGag[ id ] = false;
			}*/

			if( get_pcvar_num( toggle_tag ) == 1 )
			{
				new Buffer[ 64 ];
				formatex( Buffer, sizeof Buffer - 1, "%s %s", tag, name );
				g_NameChanged[ id ] = true;
				set_user_info( id, "name", Buffer );
			}

			if( !g_SwearGag[ id ] )
			{
				g_SwearGag[ id ] = true;
			}

			g_GagTime[ id ] = get_pcvar_num( cvar_auto_gag_time );

			print( id, "^x03*^x01 Ai primit auto - gag pentru limbaj ^x04vulgar ^x01sau ^x03reclama^x01." );
			print( id, "^x04*^x01 A%s mai ramas <^x03 %d^x01 > minut%s", g_GagTime[ id ] == 1 ? "" : "u", g_GagTime[ id ], g_GagTime[ id ] == 1 ? "." : "e." );

			print( 0, "^x04[^x01 INFO^x04 ]^x01 Jucatorul^x03 %s^x01 a primit auto-gag pentru^x04 %d ^x01minut%s!", get_name( id ), get_pcvar_num( cvar_auto_gag_time ), get_pcvar_num( cvar_auto_gag_time ) == 1 ? "" : "e" );

			set_task( 60.0, "count", id+123, _, _, "b" );

			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
}

print( id, const message[ ], { Float, Sql, Result, _ }:... )
{
	new Buffer[ 128 ], Buffer2[ 128 ];

	formatex( Buffer2, sizeof Buffer2 - 1, "%s", message );
	vformat( Buffer, sizeof Buffer - 1, Buffer2, 3 );

	if( id )
	{
		message_begin( MSG_ONE, g_msgsaytext, _, id );
		write_byte( id );
		write_string( Buffer );
		message_end( );
	}
        else
        {
		new players[ 32 ], index, num;
		get_players( players, num, "ch" );

		for( new i = 0; i < num; i++ )
		{
			index = players[ i ];
			if( !is_user_connected( index ) ) continue;

			message_begin( MSG_ONE, g_msgsaytext, _, index );
			write_byte( index );
			write_string( Buffer );
			message_end( );
		}
	}
}

stock get_name( id )
{
	new name[ 32 ];
	get_user_name( id, name, 31 );

	return name;
}

stock get_steamid( id )
{
	static steamid[ 32 ];
	get_user_authid( id, steamid, 31 );

	return steamid;
}

stock get_ip( id )
{
	static ip[ 32 ];
	get_user_ip( id, ip, 31, 1 );

	return ip;
}
