/* AMX Mod script.
*
* (c) Copyright 2004, kaboomkazoom
* This file is provided as is (no warranties)
*
* Simple Swear Replacement filter 1.5
* Replaces the chat message containing any
* swear word with a replacement line from
* replacements.ini
*
* So anyone who swears will himself be insulted.
*
* Whenever any message is replaced, then the original
* message containing Swears will be shown to all the
* Admins (So the Admins know what was said).
*
* Admin messages are not replaced. So they can Swear ;)
*
* Uses swearwords.ini and replacements.ini files.
* Put these files in the AMX Config Directory.
* Other swear files can also be used.
*
* You can also add Swear Words and Replacement
* Lines to the files in between the game whenever
* you want.
*
*
*
* Console Commands
* ~~~~~~~~~~~~~~~~
*
* amx_addswear < swear word >			-	Use this Command in game to add the
*							swear word in swearwords.ini and start
*							blocking that word from that moment on.
*
* amx_addreplacement < replacement line >	-	Use this command in game to add a new
*							replacement line in replacements.ini
*
*
*
*
* P.S. If the number of swear words or replacement
* lines exceeds 150 or 50 respectively then change
* the values of MAX_WORDS and MAX_REPLACE
*
*
*/

// sa le pun sa le schimbe si nick-ul la aia de fac reclame..(+nick_adds method)

#include <amxmodx>
#include <amxmisc> 

#include "BCKD2x.INC"

// max number of words in swear list and max number of lines in replace list
#define MAX_WORDS 666
#define MAX_REPLACE 666

// global variables for storing the swear list and replace list and their respective number of lines
new g_swearWords[MAX_WORDS][20]
new g_replaceLines[MAX_REPLACE][192]
new g_swearNum
new g_replaceNum


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


public plugin_init()
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


	register_plugin ( "Swear Replacement", "1.5", "kaboomkazoom")
	register_clcmd ( "say", "swearcheck" )
	register_clcmd ( "say_team", "swearcheck" )
	register_clcmd ( "say_team @", "swearcheck" )
	register_concmd ( "amx_addswear", "add_swear", ADMIN_LEVEL_A , "< swear word to add >" )
	register_concmd ( "amx_addreplacement", "add_replacement", ADMIN_LEVEL_A , "< replacement line to add >" )
	register_concmd ( "amx_swearsreload", "reload_swears_replacement", ADMIN_LEVEL_A , "< reload swears & replacement >" )
	readList()
}

public reload_swears_replacement(id)
{
	if ( ( !(get_user_flags(id)&ADMIN_LEVEL_A) && id ) )
	{
		client_print ( id, print_console, "[ANTI-RECLAMA] ACCES INTERZIS !" )
	 	return PLUGIN_HANDLED
	}

	readList()

	return PLUGIN_HANDLED
}

readList()
{
	new Configsdir[64]
	new swear_file[64], replace_file[64]
	get_configsdir( Configsdir, 63 )
	format(swear_file, 63, "%s/swearwords.ini", Configsdir )
	format(replace_file, 63, "%s/replacements.ini", Configsdir )

	if ( !file_exists(swear_file) )
	{
		server_print ( "==========================================================" )
		server_print ( "[Swear Replacement] Fisierul %s nu a fost gasit..", swear_file )
		server_print ( "==========================================================" )
		return
	}
	
	if ( !file_exists(replace_file) )
	{
		server_print ( "==========================================================" )
		server_print ( "[Swear Replacement] Fisierul %s nu a fost gasit..", replace_file )
		server_print ( "==========================================================" )
		return
	}
	
	new len, i=0
	while( i < MAX_WORDS && read_file( swear_file, i , g_swearWords[g_swearNum], 19, len ) )
	{
		i++
		if( g_swearWords[g_swearNum][0] == ';' || len == 0 )
			continue
		g_swearNum++
	}

	i=0
	while( i < MAX_REPLACE && read_file( replace_file, i , g_replaceLines[g_replaceNum], 191, len ) )
	{
		i++
		if( g_replaceLines[g_replaceNum][0] == ';' || len == 0 )
			continue
		g_replaceNum++
	}

	server_print ( "======================================================" )
	server_print ( "[Swear Replacement] Am incarcat %d Cuvinte Interzise", g_swearNum )
	server_print ( "[Swear Replacement] Am incarcat %d Inlocuri Cuvinte Interzise", g_replaceNum )
	server_print ( "======================================================" )

}

/*public client_connect(id)
{
	new new_name[32]
	get_user_name ( id, new_name, 31 )

	string_cleaner ( new_name )

	new i = 0
	while ( i < g_swearNum )
	{
		if ( containi ( new_name, g_swearWords[i++] ) != -1 )
		{
			set_user_info(Client, "name", "FAN FURIEN.REGEDIT.RO");

			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}*/

public swearcheck(id)
{
	if ( (get_user_flags(id)&ADMIN_LEVEL_A) || !id )
	 	return PLUGIN_CONTINUE

	new said[192], ip[32], ipp[32]
	read_args ( said, 191 )
	get_user_ip ( 0, ip, charsmax(ip) )
	get_user_ip ( 0, ipp, charsmax(ipp), 1 )

	if ( containi ( said, ip ) != -1 || containi ( said, ipp ) != -1 )	return PLUGIN_CONTINUE

	//string_cleaner ( said )

	new i = 0
	while ( i < g_swearNum )
	{
		if ( containi ( said, g_swearWords[i++] ) != -1 )
		{
			xCoLoR( id, "!v[!nANTI-RECLAMA!v]!n Cuvantul!e %s!n este!v BLOCAT",said )

			new j, playercount, players[32], user_name[32], random_replace = random ( g_replaceNum )
			get_user_name ( id, user_name, 31 )
			get_players ( players, playercount, "c" )

			for ( j = 0 ; j < playercount ; j++)
			{
				if ( get_user_flags(players[j])&ADMIN_LEVEL_B )
					xCoLoR( players[j], "!v[!nANTI-RECLAMA!v]!e %s!v :!n %s",user_name, said )
			}

			//xCoLoR( 0, "!v|!nFURIEN.REGEDIT.RO!v|!n Jucatorul!e %s!n, a incercat sa faca!v Reclama!n (!e %s!n ), si i-am!v BLOCAT!e ACTIUNEA!n !", user_name, said );

			copy ( said, 191, g_replaceLines[random_replace] )
			new cmd[10]
			read_argv ( 0, cmd, 9)
			engclient_cmd ( id ,cmd ,said )

			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}

public add_swear(id)
{
	if ( ( !(get_user_flags(id)&ADMIN_LEVEL_A) && id ) )
	{
		client_print ( id, print_console, "[ANTI-RECLAMA] ACCES INTERZIS !" )
	 	return PLUGIN_HANDLED
	}

	if ( read_argc() == 1 )
	{
		client_print ( id, print_console, "[ANTI-RECLAMA] ARGUMENTELE NU SE POTRIVESC !" )
	 	return PLUGIN_HANDLED
	}

	new Configsdir[64]
	new swear_file[64]
	get_configsdir( Configsdir, 63 )
	format ( swear_file, 63, "%s/swearwords.ini", Configsdir )

	read_args ( g_swearWords[g_swearNum], 19 )
	write_file( swear_file, "" )
	write_file( swear_file, g_swearWords[g_swearNum] )
	g_swearNum++

	id ? client_print ( id, print_console, "[ANTI-RECLAMA] TEXT ADAUGAT CU SUCCES IN LISTA !" ) : server_print ( "[ANTI-RECLAMA] TEXT ADAUGAT CU SUCCES IN FISIER !" )

	return PLUGIN_HANDLED
}

public add_replacement(id)
{
	if ( ( !(get_user_flags(id)&ADMIN_LEVEL_A) && id ) )
	{
		client_print ( id, print_console, "[ANTI-RECLAMA] ACCES INTERZIS !" )
	 	return PLUGIN_HANDLED
	}

	if ( read_argc() == 1 )
	{
		client_print ( id, print_console, "[ANTI-RECLAMA] ARGUMENTELE NU SE POTRIVESC !" )
	 	return PLUGIN_HANDLED
	}

	new Configsdir[64]
	new replace_file[64]
	get_configsdir( Configsdir, 63 )
	format ( replace_file, 63, "%s/replacements.ini", Configsdir )

	read_args ( g_replaceLines[g_replaceNum], 191 )
	write_file( replace_file, "" )
	write_file( replace_file, g_replaceLines[g_replaceNum] )
	g_replaceNum++

	id ? client_print ( id, print_console, "[ANTI-RECLAMA] INLOCUIRE CUVANT ADAUGAT IN LISTA CU SUCCES !" ) : server_print ( "[ANTI-RECLAMA] INLOCUIRE CUVANT ADAUGAT IN FISIER CU SUCCES !" )

	return PLUGIN_HANDLED
}

/*public string_cleaner( str[] ) // de modificat..
{
	new i, len = strlen ( str )
	while ( contain ( str, " " ) != -1 )
		replace ( str, len, " ", "" )

	len = strlen ( str )
	while ( contain ( str, "|<" ) != -1 )
		replace ( str, len, "|<", "k" )

	len = strlen ( str )
	while ( contain ( str, "|>" ) != -1 )
		replace ( str, len, "|>", "p" )

	len = strlen ( str )
	while ( contain ( str, "()" ) != -1 )
		replace ( str, len, "()", "o" )

	len = strlen ( str )
	while ( contain ( str, "[]" ) != -1 )
		replace ( str, len, "[]", "o" )

	len = strlen ( str )
	while ( contain ( str, "{}" ) != -1 )
		replace ( str, len, "{}", "o" )

	len = strlen ( str )
	for ( i = 0 ; i < len ; i++ )
	{
		if ( str[i] == '@' )
			str[i] = 'a'

		if ( str[i] == '$' )
			str[i] = 's'

		if ( str[i] == '0' )
			str[i] = 'o'

		if ( str[i] == '7' )
			str[i] = 't'

		if ( str[i] == '3' )
			str[i] = 'e'

		if ( str[i] == '5' )
			str[i] = 's'

		if ( str[i] == '<' )
			str[i] = 'c'

		if ( str[i] == '3' )
			str[i] = 'e'

	}
}*/

stock xCoLoR( const id, const input[ ], any:... )
{
	new count = 1, players[ 32 ];
	static msg[ 191 ];
	vformat( msg, 190, input, 3 );

	replace_all( msg, 190, "!v", "^4" );
	replace_all( msg, 190, "!n", "^1" );
	replace_all( msg, 190, "!e", "^3" );
	replace_all( msg, 190, "!e2", "^0" );

	if( id )
	{
		players[ 0 ] = id;
	}

	else get_players( players, count, "ch" );
	{
		for( new i = 0; i < count; i++ )
		{
			if( is_user_connected( players[ i ] ) )
			{
				message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "SayText" ), _, players[ i ] );
				write_byte( players[ i ] );
				write_string( msg );
				message_end( );
			}
		}
	}
}
