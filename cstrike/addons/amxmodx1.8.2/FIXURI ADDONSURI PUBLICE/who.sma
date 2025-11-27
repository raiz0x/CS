#include < amxmodx >

#define DENUMIRE "DR.LIMITCS.RO"

#define PLUGIN "HUD MOD"
#define VERSION "0.4x"
#define AUTHOR "eVoLuTiOn +"

#define MAX_GROUPS 		10
#define MAX_FLAGS 		10

new g_szGradeSiPreturi[ ][ ] =
{
	"\dOwner\w <-> \y8E",
	"\dCo Owner\w <-> \y7E",
	"\dAdministrator\w <-> \y5E",
	"\dCo Administrator\w <-> \y4E",
	"\dSuper Moderator\w <-> \y3E",
	"\dModerator\w <-> \y2E",
	"\dHelper\w <-> \yCERERE",
	"\y*V.I.P*\w <=> \r6E^n",
	"\wPentru cumparare ADD:",
	"\ySKYPE: \rlevin.akee",
	"\dTOATE GRADELE SUNT PERMANENTE !"
}

new const g_szWhoGroups[ MAX_GROUPS ][ ] =
{
        "Fondator",
        "Owner",
        "Co - Owner",
        "Administrator",
        "Co - Administrator",
        "Super - Moderator",
        "Moderator",
        "HeL|PeR",
        "*V.I.P*",
        "LoYaL"//sLoT
};

new const g_szWhoFlags[ MAX_FLAGS ][ ] =
{
        "abcdefghijklmnopqrstu",
        "abcdefghijklnopqrstu",
        "abcdefhijnopqrst",
        "bcdefijnopqrs",
        "cdefijnopqr",
        "cdefijopq",
        "cdefpij",
        "cdefri",
        "abdceifjt",
        "b"
};


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


	register_plugin( PLUGIN, VERSION, AUTHOR );

	register_clcmd( "say", "hookSay" );
	register_clcmd( "say_team", "hookSay" );
}

public hookSay( id )
{
	new szSaid[ 192 ];
	read_args( szSaid, sizeof( szSaid ) -1 );
	remove_quotes( szSaid );

	if( contain( szSaid, "/who" )!=-1 || contain( szSaid, "/admin" )!=-1 )	CreateWho( id );
	if( contain( szSaid, "/pret" ) != -1 )	CreatePret( id );

	return PLUGIN_CONTINUE;
}

public CreatePret( id )
{
	new iLen, szMotd[ 2048 ]

	iLen = format( szMotd[ iLen ], charsmax(szMotd) - iLen, "\r*\y Preturiile\w serverului \d%s\r:^n^n",DENUMIRE );

	for( new i = 0; i < sizeof( g_szGradeSiPreturi ); i++ )	iLen += format( szMotd[ iLen ], charsmax(szMotd) - iLen, "%s^n", g_szGradeSiPreturi[ i ] );
	show_menu( id, ( 1 << 1 || 1 << 2 || 1 << 3 || 1 << 4 || 1 << 5 ), szMotd, -1 );
}

public CreateWho( id )
{
	new iPlayers[ 32 ], iCount, iLen, szMotd[ 2048 ]
	get_players( iPlayers, iCount, "ch" );

	iLen = format( szMotd[ iLen ], charsmax(szMotd) - iLen, "\yADMINI \r[ \dONLINE \r]\w:^n^n" );

	for( new p = 0; p < iCount; p++ )
	{
		static player;
		player = iPlayers[ p ];

		for( new i = 0; i < MAX_FLAGS; i++ )
		{
			if( get_user_flags( player ) == read_flags( g_szWhoFlags[ i ] ) )
			{
				static szName[ 32 ];
				get_user_name( player, szName, sizeof( szName ) -1 );

				iLen += format( szMotd[ iLen ], charsmax(szMotd) - iLen, "\y[ \wNICK: \d%s\y ] [ \rGRAD: \d%s\y ]^n", szName, g_szWhoGroups[ i ] );
			}
		}
		show_menu( id, ( 1 << 1 || 1 << 2 || 1 << 3 || 1 << 4 || 1 << 5 || 1 << 6 || 1 << 7 || 1 << 8 || 1 << 9 || 1 << 0 ), szMotd, -1 );
	}
}
