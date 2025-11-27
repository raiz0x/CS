#include <amxmodx>
#include <amxmisc>

#define DENUMIRE "DR.LIMITCS.RO"

new const g_Chars[ ][ ] = // + numbers
{
	"%",
	"#",
	"`",
	"~",
	"?",
	"!",
	"(",
	")",
	"-",
	"+",
	".",
	",",
	"<",
	">",
	"@",
	"$",
	//"^",
	"&",
	"*",
	"=",
	"/",
	"'",
	//""",
	";",
	":",
	"\",
	"|",
	"]",
	"}",
	"[",
	"{"
};

new Array:g_Things = Invalid_Array;
new g_NamesCount = 0;
new g_Default = 0;
new g_New = 0;

new cvar_nick_checker, cvar_min_lenght, cvar_max_lenght, cvar_symbols; // ++ sa nu afecteze adminii..??


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


	register_plugin("Restricted Names", "1.4X", "(Hattrick JM3Ch3Rul & Fantasy) + eVoLuTiOn");

	g_Default = register_cvar("amx_default_name", "LIMITCS.RO", FCVAR_SERVER | FCVAR_SPONLY | FCVAR_UNLOGGED | FCVAR_EXTDLL);
	g_New = register_cvar("amx_new_name", "DR.LIMITCS.RO", FCVAR_SERVER | FCVAR_SPONLY | FCVAR_UNLOGGED | FCVAR_EXTDLL);
	
	if (g_Default == 0 || g_New == 0)
	{
		set_fail_state("Plugin-ul nu a fost configurat corect.");
		
		return;
	}
	
	static File, Location[256], ConfigurationFilesDirectory[128], Line[64];

	get_localinfo("amxx_configsdir", ConfigurationFilesDirectory, charsmax(ConfigurationFilesDirectory));

	formatex(Location, charsmax(Location), "%s/restricted_things.ini", ConfigurationFilesDirectory);
	
	if (!file_exists(Location))
	{
		File = fopen(Location, "w+");
		
		switch (File)
		{
			case 0://????
			{
				
			}
			
			default:
			{
				fclose(File);
			}
		}
	}

	File = fopen(Location, "r");

	if (!File)
	{
		log_amx("Nu am putut deschide ^"%s/restricted_things.ini^"", ConfigurationFilesDirectory);

		return;
	}
	
	g_Things = ArrayCreate(64);
	
	if (g_Things == Invalid_Array)
	{
		set_fail_state("Nu am putut porni plugin-ul..");
		
		return;
	}

	while (!feof(File))
	{
		fgets(File, Line, charsmax(Line));

		trim(Line);
		
		if (strlen(Line) && Line[0] != ';')
		{
			ArrayPushString(g_Things, Line);
		}
	}
	
	fclose(File);
	
	if (g_Things == Invalid_Array || !ArraySize(g_Things))
	{
		log_amx("Nu am gasit niciun nick interzis din ^"%s/restricted_things.ini^".", ConfigurationFilesDirectory);
	}

	cvar_nick_checker = register_cvar( "nick_checker", "0" );
	cvar_min_lenght = register_cvar( "min_lenght_name", "3" );
	cvar_max_lenght = register_cvar( "max_lenght_name", "25" );
	cvar_symbols = register_cvar( "symbols_block", "0" );
}

public client_authorized(Client)
{
	if (g_Things == Invalid_Array || !ArraySize(g_Things))
	{
		return;
	}

	static Name[32], Default[32], Iterator, Thing[32], New[32], Ip[32], IpP[32];

	get_user_name(Client, Name, charsmax(Name));
	get_pcvar_string(g_Default, Default, charsmax(Default));
	get_pcvar_string(g_New, New, charsmax(New));
	get_user_ip(0, Ip, charsmax(Ip));
	get_user_ip(0, IpP, charsmax(IpP), 1);
	
	if (containi(Name, Default) != -1 || containi(Name, Ip)!= -1 || containi(Name, IpP)!= -1)
	{
		return;
	}
	
	for (Iterator = 0; Iterator < ArraySize(g_Things); Iterator++)
	{
		ArrayGetString(g_Things, Iterator, Thing, charsmax(Thing));
		
		if (containi(Name, Thing) != -1 && !is_user_admin(Client) && !is_user_bot(Client) && !is_user_hltv(Client))
		{
			//xCoLoR( 0, "!v|!nFURIEN.REGEDIT.RO!v|!n Nick-ul lu'!e %s!n a fost schimbat in!v %s", Name, New );

			formatex(Name, charsmax(Name), "%s |%d|", New, ++g_NamesCount); // de facut cu for
			set_user_info(Client, "name", Name);

			client_print(Client, print_console, "Ne cerem scuze dar nick-ul tau a fost schimbat in %s, deoarece continea %s, acesta fiind cuvant restrictionat", New, Thing)

			break;
		}
	}

	if( get_pcvar_num( cvar_nick_checker ) )
	{
		if( strlen( Name ) < get_pcvar_num( cvar_min_lenght ) && !is_user_admin(Client) && !is_user_bot(Client) && !is_user_hltv(Client) )
		{
			server_cmd( "kick #%i ^">%s< Nick-ul tau este prea Mic. Minim %i Caractere^"", DENUMIRE, get_user_userid( Client ), get_pcvar_num( cvar_min_lenght ) );
		}

		if( strlen( Name ) > get_pcvar_num( cvar_max_lenght ) && !is_user_admin(Client) && !is_user_bot(Client) && !is_user_hltv(Client) )
		{
			server_cmd( "kick #%i ^">%s< Nick-ul tau este prea Mare. Minim %i Caractere^"", DENUMIRE, get_user_userid( Client ), get_pcvar_num( cvar_min_lenght ) );
		}

		if( get_pcvar_num( cvar_symbols ) == 1 )
		{
			for( new g = 0; g < sizeof( g_Chars ); g++ )
			{
				if( containi( Name, g_Chars[ g ] ) != -1 && !is_user_admin(Client) && !is_user_bot(Client) && !is_user_hltv(Client) )
				{
					server_cmd( "kick #%i ^">%s< Nick-ul tau Contine Simboluri Interzise !^"", DENUMIRE, get_user_userid( Client ) );
				}
			}
		}
	}
}

public client_infochanged(Client)
{
	if (g_Things == Invalid_Array || !ArraySize(g_Things))
	{
		return;
	}

	static OldName[32], Name[32], Default[32], Iterator, Thing[32], New[32], Ip[32], IpP[32];

	get_user_name(Client, OldName, charsmax(OldName));
	get_pcvar_string(g_Default, Default, charsmax(Default));
	get_user_info(Client, "name", Name, charsmax(Name));
	get_pcvar_string(g_New, New, charsmax(New));
	get_user_ip(0, Ip, charsmax(Ip));
	get_user_ip(0, IpP, charsmax(IpP), 1);

	if (containi(Name, Default)!= -1 || containi(Name, Ip)!= -1 || containi(Name, IpP)!= -1||equali(Name, OldName))
	{
		return;
	}

	for (Iterator = 0; Iterator < ArraySize(g_Things); Iterator++)
	{
		ArrayGetString(g_Things, Iterator, Thing, charsmax(Thing));
		
		if (containi(Name, Thing) != -1 && !is_user_admin(Client) && !is_user_bot(Client) && !is_user_hltv(Client))
		{
			//xCoLoR( 0, "!v|!nFURIEN.REGEDIT.RO!v|!n Nick-ul lu'!e %s!n a fost schimbat in!v %s", Name, New );

			formatex(Name, charsmax(Name), "%s |%d|", New, ++g_NamesCount);
			set_user_info(Client, "name", Name);

			client_print(Client, print_console, "Ne cerem scuze dar nick-ul tau a fost schimbat in %s, deoarece continea %s, acesta fiind cuvant restrictionat", Name, Thing)

			break;
		}
	}

	if( get_pcvar_num( cvar_nick_checker ) )
	{
		if( strlen( Name ) < get_pcvar_num( cvar_min_lenght ) && !is_user_admin(Client) && !is_user_bot(Client) && !is_user_hltv(Client) )
		{
			xCoLoR( Client, "!v|!n%s!v|!n Nick-ul tau este prea!e Mic!n. Minim!v %i!n Caractere.", DENUMIRE, get_pcvar_num( cvar_min_lenght ) );

			return;
		}

		if( strlen( Name ) > get_pcvar_num( cvar_max_lenght ) && !is_user_admin(Client) && !is_user_bot(Client) && !is_user_hltv(Client) )
		{
			xCoLoR( Client, "!v|!n%s!v|!n Nick-ul tau este prea!e Mare!n. Minim!v %i!n Caractere.", DENUMIRE, get_pcvar_num( cvar_max_lenght ) );

			return;
		}

		if( get_pcvar_num( cvar_symbols ) == 1 )
		{
			for( new g = 0; g < sizeof( g_Chars ); g++ )
			{
				if( containi( Name, g_Chars[ g ] ) != -1 && !is_user_admin(Client) && !is_user_bot(Client) && !is_user_hltv(Client) )
				{
					xCoLoR( Client, "!v|!n%s!v|!n Nick-ul tau contine!e Simboluri!v Interzise!n !", DENUMIRE );

					return;
				}
			}
		}
	}
}

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
