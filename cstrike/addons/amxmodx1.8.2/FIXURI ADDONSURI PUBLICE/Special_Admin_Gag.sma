#include < amxmodx >
#include < amxmisc >
#include < fakemeta >
#include < engine >
#include < nvault >
#include < colorchat >

#pragma tabsize 0

#define PLUGIN "Special Admin Gag"
#define VERSION "1.7x"

#define COMMAND_ACCESS  	ADMIN_KICK
#define MAX_PLAYERS 		33

enum
{
	INFO_NAME,
	INFO_IP,
	INFO_AUTHID
};

new command[ ][ ] =
{
        "/gag", 
        "/ungag"
};

new Caccess[ ] = 
{
	COMMAND_ACCESS,
	COMMAND_ACCESS
};

new const gGagTag[ ] = "GAGED#";
new const gGagFileName[ ] = "gag_words.ini";
new const gLogFileName[ ] = "GagLog.log"; 

new const gGagThinkerClassname[ ] = "GagThinker_";
new const gGagVaultName[ ] = "GaggedPlayers";

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

new PlayerGagged[ MAX_PLAYERS ], PlayerGagTime[ MAX_PLAYERS ], JoinTime[ MAX_PLAYERS ];
new szName[ MAX_PLAYERS ], g_reason[ MAX_PLAYERS ][ 32 ], g_admin[ MAX_PLAYERS ][ 32 ], szOldName[ MAX_PLAYERS ][ 40 ];

new g_Words[ 562 ][ 64 ], g_Count;

new gCvarSwearGagTime, gCvarGagMinuteLimit, gCvarGagMinuteMinim, gCvarGagMinuteInSeconds, gCvarAdminGag, gCvarTagName, gCvarWords, gCvarTag,
gMaxPlayers, gVault;

public plugin_init( ) 
{
	register_plugin( PLUGIN, PLUGIN, "Cristi .C & eVoLuTiOn" );

	register_concmd( "amx_gag", "CommandGag" ); 
	register_concmd( "amx_ungag", "CommandUngag" );

	register_clcmd( "say", "CheckGag" );
	register_clcmd( "say_team", "CheckGag" );
	register_clcmd( "say_team @", "CheckGag" );

	register_clcmd( "say", "command_chat" );
	register_clcmd( "say_team", "command_chat" );
	register_clcmd( "say_team @", "command_chat" );

	GagThinker( );
	register_think( gGagThinkerClassname, "Forward_GagThinker" );

	gCvarSwearGagTime = register_cvar( "amx_autogag_time", "6" );
	gCvarGagMinuteLimit = register_cvar( "amx_gag_minute_limit", "30" );
	gCvarGagMinuteMinim = register_cvar( "amx_gag_minute_minim", "5" );
	gCvarGagMinuteInSeconds = register_cvar( "amx_gag_minute_in_seconds", "60" );
	gCvarTagName = register_cvar( "amx_gag_tagname", "0" );
	gCvarAdminGag = register_cvar( "amx_admingag", "0" );
	gCvarWords = register_cvar( "amx_maxwords", "200" );
	gCvarTag = register_cvar( "amx_gagtag", "| AMXX |" );

	gMaxPlayers = get_maxplayers( );

	gVault = nvault_open( gGagVaultName );
	if ( gVault == INVALID_HANDLE )	set_fail_state( "Error opening nVault" );
}

public plugin_cfg( ) 
{
	static szConfigDir[ 64 ], iFile[ 64 ];

	get_localinfo( "amxx_configsdir", szConfigDir, 63 );
	formatex( iFile, charsmax( iFile ), "%s/%s", szConfigDir, gGagFileName );

	if( !file_exists( iFile ) )
	{
		write_file( iFile, "# Pune aici cuvintele jignitoare sau reclamele", -1 );
		log_to_file( gLogFileName, "Fisierul < %s > nu exista ! Creez unul nou acum...", iFile );
	}

	new szBuffer[ 128 ];
        new szFile = fopen( iFile, "rt" );

        while( !feof( szFile ) )
        {
        	fgets( szFile, szBuffer, charsmax( szBuffer ) );

           	if( szBuffer[ 0 ] == '#' || szBuffer[ 0 ] == ';' || szBuffer[ 0 ] == '/' && szBuffer[ 1 ] == '/' )
           	{
                	continue;
            	}

		parse( szBuffer, g_Words[ g_Count ], sizeof g_Words[ ] - 1 );
		g_Count++;

		if( g_Count >= get_pcvar_num( gCvarWords ) )
		{
			break;
		}
	}

	fclose( szFile );
}

public plugin_precache( )
{
	for( new i = 0; i < sizeof( gHalfLifeGaggedSounds ); i++ )
	{
		precache_sound( gHalfLifeGaggedSounds[ i ] );
	}

	precache_sound( gGaggedSound );
	precache_sound( gUnGaggedSound );
}

public client_putinserver( id ) 
{ 
	if( /*is_user_connected( id ) &&*/ !is_user_bot( id ) || !is_user_hltv( id ) )
	{
		LoadGag( id );

		JoinTime[ id ] = get_systime( );

		if( PlayerGagged[ id ] == 1 || PlayerGagged[ id ] == 2 )
		{
			ColorChat( 0, NORMAL, "^4%s^1 Jucatorul cu gag^3 %s ^1(^4 %s^1 |^3 %s^1 ), s-a reconectat !", get_tag( ), GetInfo( id, INFO_NAME ), GetInfo( id, INFO_IP ), GetInfo( id, INFO_AUTHID ) );
			log_to_file( gLogFileName, "[ENTER] Jucatorul cu gag <%s><%s><%s>, s-a reconectat !", GetInfo( id, INFO_NAME ), GetInfo( id, INFO_IP ), GetInfo( id, INFO_AUTHID ) );
		}
	}
}

public client_disconnect( id )
{
	if(is_user_bot(id)||is_user_hltv(id))	return;
	if( PlayerGagged[ id ] == 1 || PlayerGagged[ id ] == 2 )
	{	
		ColorChat( 0, NORMAL, "^4%s^1 Jucatorul cu gag^3 %s ^1(^4 %s^1 |^3 %s^1 ), s-a deconectat !", get_tag( ), GetInfo( id, INFO_NAME ), GetInfo( id, INFO_IP ), GetInfo( id, INFO_AUTHID ) );
		log_to_file( gLogFileName, "[EXIT] Jucatorul cu gag <%s><%s><%s>, s-a deconectat !", GetInfo( id, INFO_NAME ), GetInfo( id, INFO_IP ), GetInfo( id, INFO_AUTHID ) );
	}
	//PlayerGagged[ id ] = 0;
	//PlayerGagTime[ id ] = 0;
	SaveGag( id );
	JoinTime[ id ] = 0;
}

public command_chat( index )
{
	static szArg[ 192 ], command2[ 192 ];
        read_args( szArg, charsmax( szArg ) );

        if( !szArg[ 0 ] )
        	return PLUGIN_CONTINUE;

        remove_quotes( szArg[ 0 ] );

        for( new x; x < sizeof( command ); x++ )
        {
        	if( equal( szArg, command[ x ], strlen( command[ x ] ) ) )
           	{
              		if( get_user_flags( index ) & Caccess[ x ] )
              		{
                 		formatex( command2, charsmax( command2 ), "amx_%s", szArg[1] );
				client_cmd( index, command2 );
              		}
              		break;
           	}
        }
        return PLUGIN_CONTINUE;
}

public CheckGag( id )
{
	new szSaid[ 300 ];
	read_args( szSaid, charsmax( szSaid ) );
	remove_quotes( szSaid );

	if( !UTIL_IsValidMessage( szSaid ) )
	{
		return PLUGIN_HANDLED;
	}

	if( strlen( g_reason[ id ] ) > 0 )
		copy( g_reason[ id ], charsmax( g_reason ), g_reason[ id ] );
	if( strlen( g_admin[ id ] ) > 0 )
		copy( g_admin[ id ], charsmax( g_admin ), g_admin[ id ] );

	if( PlayerGagged[ id ] != 0 )
	{
		if( PlayerGagged[ id ] == 2 )
		{
			PlayerGagged[ id ] = 2;
			ColorChat( id, NORMAL, "^4%s^1 Ai primit auto - gag pentru limbaj ^3vulgar^1, sau ^4reclama^1.", get_tag( ) );
			ColorChat( id, NORMAL, "^4%s^1 A(u) mai ramas <^3 %d^1 > minut%s", get_tag( ), PlayerGagTime[ id ], PlayerGagTime[ id ] == 1 ? "" : "e" );
		}
		else if( PlayerGagged[ id ] == 1 )
		{
			PlayerGagged[ id ] = 1;
			ColorChat( id, NORMAL, "^4%s^1 Ai primit gag de la adminul: ^3%s^1. A(u) mai ramas << ^4%d ^1>> minut%s !", get_tag( ), g_admin[ id ], PlayerGagTime[ id ], PlayerGagTime[ id ] == 1 ? "" : "e" );
			ColorChat( id, NORMAL, "^4%s^1 Motivul Gagului: ^3%s", get_tag( ), g_reason[ id ] );
		}

		client_cmd( id, "spk ^"%s^"", gHalfLifeGaggedSounds[ random_num( 0, charsmax( gHalfLifeGaggedSounds ) ) ] );

		return PLUGIN_HANDLED;
	}
	else
	{
		for( new i = 0; i < get_pcvar_num( gCvarWords ); i++ )
		{
			if( containi( szSaid, g_Words[ i ] ) != -1 )
			{
				if( get_pcvar_num( gCvarAdminGag ) == 1 )
				{
					if( is_user_admin( id ) )
					{	
						return PLUGIN_CONTINUE;
					}
				}

				PlayerGagged[ id ] = 2;

				if( get_pcvar_num( gCvarTagName ) == 1 )
				{
					get_user_name( id, szName, sizeof( szName ) -1 );
					client_cmd( id, "name ^"%s %s^"", gGagTag, szName );
					szOldName[ id ] = szName;
				}

				PlayerGagTime[ id ] = get_pcvar_num( gCvarSwearGagTime );

				SaveGag( id );

				set_speak( id, SPEAK_MUTED );

				ColorChat( 0, NORMAL, "^4%s^3 %s^1 (^4 %s^1 )^1 a primit^3 AutoGag^1 pentru^4 limbaj^1 sau^3 reclama^1 !", get_tag( ), GetInfo( id, INFO_NAME ), GetInfo( id, INFO_IP ) );

				ColorChat( id, NORMAL, "^4%s^1 Ai primit auto - gag pentru limbaj ^3vulgar^1, sau ^4reclama^1.", get_tag( ) );
				ColorChat( id, NORMAL, "^4%s^1 A(u) mai ramas <^3 %d^1 > minut%s", get_tag( ), PlayerGagTime[ id ], PlayerGagTime[ id ] == 1 ? "" : "e" );

				log_to_file( gLogFileName, "[AUTOGAG] <%s><%s><%s> a luat AutoGag pentru ca a injurat sau a facut reclama !", GetInfo( id, INFO_NAME ), GetInfo( id, INFO_IP ), GetInfo( id, INFO_AUTHID ) );

				client_cmd( id, "spk ^"%s^"", gGaggedSound );

				return PLUGIN_HANDLED;
			}
		}
	}

	return PLUGIN_CONTINUE;
}

public CommandGag( id )  
{  
	if( !HasUserAccess( id ) )
	{
		console_print( id, "%s Nu ai acces la aceasta comanda !", get_tag( ) );
		return 1;
	}

	new szArg[ 32 ], szMinutes[ 32 ], reason[ 32 ];
	read_argv( 1, szArg, charsmax( szArg ) );
	read_argv( 2, szMinutes, charsmax( szMinutes ) );
	read_argv( 3, reason, sizeof reason - 1 );

	new iMinutes = str_to_num( szMinutes );

	new iPlayer = cmd_target( id, szArg, ( CMDTARGET_NO_BOTS ) );

	if( equal( szArg, "" ) )
	{
		console_print( id, "amx_gag < nume / parte din nume / ip / #id / steamid > < minut(e) > < motiv >" );
		return 1;
	}

	if( equal( reason, "" ) )	format( reason, charsmax( reason ), "nespecificat" );

	if( !iPlayer || !is_user_connected( iPlayer ) )
	{
		console_print( id, "%s Jucatorul specificat nu a fost gasit !", get_tag( ) );
		return 1;
	}

	if( PlayerGagged[ iPlayer ] == 1 || PlayerGagged[ id ] == 2 ) 
	{
		console_print( id, "%s Jucatorul %s are deja Gag !", get_tag( ), GetInfo( iPlayer, INFO_NAME ) );
		return 1;
	} 

	if( get_pcvar_num( gCvarAdminGag ) == 1 )
	{
		if( is_user_admin( iPlayer ) )
		{
			console_print( id, "%s Nu poti da gag la Admini !", get_tag( ) );
			return 1;
		}
	}

	if( iMinutes > get_pcvar_num( gCvarGagMinuteLimit ) )
	{
		console_print( id, "%s Ai setat %d minute, iar limita maxima este de %d minute ! Setare automata pe %d.", get_tag( ), iMinutes, get_pcvar_num( gCvarGagMinuteLimit ), get_pcvar_num( gCvarGagMinuteLimit ) );

		iMinutes = get_pcvar_num( gCvarGagMinuteLimit );
	}
	else if( iMinutes < get_pcvar_num( gCvarGagMinuteMinim ) )
	{
		console_print( id, "%s Ai setat %d minute, iar limita minima este de %d minute ! Setare automata pe %d.", get_tag( ), iMinutes, get_pcvar_num( gCvarGagMinuteMinim ), get_pcvar_num( gCvarGagMinuteMinim ) );

		iMinutes = get_pcvar_num( gCvarGagMinuteMinim );
	}
	/*else if( !iMinutes )
	{
		console_print( id, "%s Nu ai setat minutele! Setam noi pe %d", get_tag( ),get_pcvar_num( gCvarGagMinuteMinim ) );

		iMinutes = get_pcvar_num( gCvarGagMinuteMinim );
	}*/

	if( get_pcvar_num( gCvarTagName ) == 1 )
	{
		get_user_name( iPlayer, szName, sizeof( szName ) -1 );
		szOldName[ iPlayer ] = szName;
		client_cmd( iPlayer, "name ^"%s %s^"", gGagTag, szName );
	}

	PlayerGagged[ iPlayer ] = 1;
	PlayerGagTime[ iPlayer ] = iMinutes;
	set_speak( iPlayer, SPEAK_MUTED );

	console_print( id, "%s %s tocmai a primit gag pt %d minut%s, pe motiv %s", get_tag( ), GetInfo( iPlayer, INFO_NAME ), iMinutes, iMinutes == 1 ? "" : "e", reason );

	ColorChat( 0, NORMAL, "^4%s^1 ^3%s^1: ii sparge tastatura lu'^4 %s^1 pentru^1 [ ^3%d ^1] minut%s. Motiv: ^1( ^4%s ^1)", get_tag( ), GetInfo( id, INFO_NAME ), GetInfo( iPlayer, INFO_NAME ), iMinutes, iMinutes == 1 ? "" : "e", reason );

	log_to_file( gLogFileName, "[GAG] %s i-a dat gag lui < %s >< %s >< %s > pt. < %d > minut%s motivul %s", GetInfo( id, INFO_NAME ), GetInfo( iPlayer, INFO_NAME ), GetInfo( iPlayer, INFO_IP ), GetInfo( iPlayer, INFO_AUTHID ), iMinutes, iMinutes == 1 ? "" : "e", reason );
	client_cmd( iPlayer, "spk ^"%s^"", gGaggedSound );

	if( strlen( reason ) > 0 )
	{
		copy( g_reason[ iPlayer ], charsmax( g_reason ), reason );
	}

	if( strlen( GetInfo( id, INFO_NAME ) ) > 0 )
	{
		copy( g_admin[ iPlayer ], charsmax( g_admin ), GetInfo( id, INFO_NAME ) );
	}

	SaveGag( iPlayer );

	return PLUGIN_HANDLED;
}

public CommandUngag( id )
{  
	if( !HasUserAccess( id ) )
	{
		console_print( id, "%s Nu ai acces la aceasta comanda !", get_tag( ) );
		return 1;
	}

	new szArg[ 32 ], reason[ 32 ];
	read_argv( 1, szArg, charsmax( szArg ) );
	read_argv( 2, reason, sizeof reason - 1 );

	new iPlayer = cmd_target( id, szArg, ( CMDTARGET_NO_BOTS ) );

	if( equal( szArg, "" ) )
	{
		console_print( id, "amx_gag < nume / parte din nume / ip / #id / steamid > < motiv >" );
		return 1;
	}

	if( equal( reason, "" ) )	format( reason, charsmax( reason ), "nespecificat" );

	if( !iPlayer || !is_user_connected( iPlayer ) )
	{
		console_print( id, "%s Jucatorul specificat nu a fost gasit !", get_tag( ) );
		return 1;
	}

	if( PlayerGagged[ iPlayer ] == 0 ) 
	{
		console_print( id, "%s Jucatorul %s nu are Gag !", get_tag( ), GetInfo( iPlayer, INFO_NAME ) );
		return 1;
	}

	if( get_pcvar_num( gCvarTagName ) == 1 )
	{
		set_user_info( iPlayer, "name", szOldName[ iPlayer ] );
	}

	PlayerGagged[ iPlayer ] = 0;
	PlayerGagTime[ iPlayer ] = 0;
	set_speak( iPlayer, SPEAK_NORMAL );

	if( strlen( g_reason[ iPlayer ] ) > 0 )
		copy( g_reason[ iPlayer ], charsmax( g_reason ), "" );// For what is here? No idea...
	if( strlen( g_admin[ iPlayer ] ) > 0 )
		copy( g_admin[ iPlayer ], charsmax( g_admin ), "" );

	console_print( id, "%s %s tocmai a primit un-gag, pe motiv %s", get_tag( ), GetInfo( iPlayer, INFO_NAME ), reason );

	ColorChat( 0, NORMAL, "^4%s ^3%s^1: ii reface tastatura lu'^4 %s^1. Motiv [ ^3%s ^1]", get_tag( ), GetInfo( id, INFO_NAME ), GetInfo( iPlayer, INFO_NAME ), reason );

	log_to_file( gLogFileName, "[UNGAG] < %s > i-a dat ungag lui < %s >< %s >< %s > motivul %s", GetInfo( id, INFO_NAME ), GetInfo( iPlayer, INFO_NAME ), GetInfo( iPlayer, INFO_IP ), GetInfo( iPlayer, INFO_AUTHID ), reason );
	client_cmd( iPlayer, "spk ^"%s^"", gUnGaggedSound );

	SaveGag( iPlayer );

	return PLUGIN_HANDLED;
}

stock GagThinker( )
{
	new iEntity = create_entity( "info_target" );

	if( !pev_valid( iEntity ) )
	{
		return PLUGIN_HANDLED;
	}

	set_pev( iEntity, pev_classname, gGagThinkerClassname );
	set_pev( iEntity, pev_nextthink, get_gametime( ) + 1.0 );

	return PLUGIN_HANDLED;
}

public Forward_GagThinker( iEntity )
{
	if( pev_valid( iEntity ) )
	{
		set_pev( iEntity, pev_nextthink, get_gametime( ) + 1.0 );

		new id;
		for( id = 1; id <= gMaxPlayers; id++ )
		{
			if( is_user_connected( id ) 	
			&& !is_user_bot( id )
			&& PlayerGagged[ id ]
			&& PlayerGagTime[ id ] > 0
			&& ( ( get_systime( ) - JoinTime[ id ] ) >= get_pcvar_num( gCvarGagMinuteInSeconds ) ) )
			{
				JoinTime[ id ] = get_systime( );
				PlayerGagTime[ id ] -= 1;

				if( PlayerGagTime[ id ] <= 0 )
				{
					PlayerGagTime[ id ] = 0;
					PlayerGagged[ id ] = 0;
					set_speak( id, SPEAK_NORMAL );

					ColorChat( id, NORMAL, "^4%s^1 Ai primit^3 Auto - UnGag^1 cu succes, ai grija la limbaj data viitoare !", get_tag( ) );
					ColorChat( 0, NORMAL, "^4%s^1 Jucatorul^3 %s^1 a primit^4 Auto - UnGag^1 cu succes !", get_tag( ), GetInfo( id, INFO_NAME ) );
					log_to_file( gLogFileName, "[AUTOUNGAG] < %s > a primit AutoUnGag !", GetInfo( id, INFO_NAME ) );

					client_cmd( id, "spk ^"%s^"", gUnGaggedSound );

					if( get_pcvar_num( gCvarTagName ) == 1 )
						set_user_info( id, "name", szOldName[ id ] );

					if( strlen( g_reason[ id ] ) > 0 )
						copy( g_reason[ id ], charsmax( g_reason ), "" );// Again...
					if( strlen( g_admin[ id ] ) > 0 )
						copy( g_admin[ id ], charsmax( g_admin ), "" );

					SaveGag( id );
				}
			}
		}
	}
}

stock SaveGag( id )
{
	if( !is_user_connected( id ) )	return;

	new name[ 32 ];
	get_user_name( id, name, 31 );

	new szIp[ 40 ], szVaultKey[ 64 ], szVaultData[ 64 ];
	get_user_ip( id, szIp, charsmax( szIp ) );

	formatex( szVaultKey, charsmax( szVaultKey ), "%s-%s-Gag", name, szIp );
	formatex( szVaultData, charsmax( szVaultData ), "%d %d %s %s", PlayerGagged[ id ], PlayerGagTime[ id ], g_admin[ id ], g_reason[ id ] );

	nvault_set( gVault, szVaultKey, szVaultData );
}

stock LoadGag( id )
{
	if( !is_user_connected( id ) )	return;

	new name[ 32 ];
	get_user_name( id, name, 31 );

	new szIp[ 40 ], szVaultKey[ 64 ], szVaultData[ 64 ];
	get_user_ip( id, szIp, charsmax( szIp ) );

	formatex( szVaultKey, charsmax( szVaultKey ), "%s-%s-Gag", name, szIp );
	formatex( szVaultData, charsmax( szVaultData ), "%d %d %s %s", PlayerGagged[ id ], PlayerGagTime[ id ], g_admin[ id ], g_reason[ id ] );
	nvault_get( gVault, szVaultKey, szVaultData, charsmax( szVaultData ) );

	new iGagOn[ 32 ], iGagTime[ 32 ], aN[33][32],aR[33][32];
	parse( szVaultData, iGagOn, charsmax( iGagOn ), iGagTime, charsmax( iGagTime ), aN[id],charsmax(aN[]),aR[id],charsmax(aR[]) );

	PlayerGagged[ id ] = str_to_num( iGagOn );
	PlayerGagTime[ id ] = str_to_num( iGagTime );

	copy(g_admin[id],charsmax(g_admin[]),aN[id]);
	copy(g_reason[id],charsmax(g_reason[]),aR[id]);
}

stock get_tag( )
{
	new szTag [ 32 ];
	get_pcvar_string( gCvarTag, szTag, sizeof( szTag ) -1 );

	return szTag;
}

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

stock bool:UTIL_IsValidMessage( const szSaid[ ] )
{
	new iLen = strlen( szSaid );

	if( !iLen )
	{
		return false;
	}

	for( new i = 0; i < iLen; i++ )
	{
		if( szSaid[ i ] != ' ' )
		{
			return true;
		}
	}

	return false;
}

stock bool:HasUserAccess( id )
{
	if( get_user_flags( id ) & COMMAND_ACCESS )
		return true;

	return false;
}

public plugin_end( )
{
//	if( 26 > 0 )
	//{
	//nvault_prune( gVault, 0, get_systime( ) - ( 26 * 86400 ) );
	//}

	nvault_close( gVault );
}
