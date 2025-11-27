// **** Be aware that I use '\' as a control char instead of '^'
#pragma ctrlchar '\'

// **** DO NOT EDIT THE QUERIES UNLESS YOU KNOW WHAT YOU'RE DOING!
// **** YOU HAVE BEEN WARNED

#include <amxmodx>
#include <amxmisc>
#include <sqlx>
#include <fakemeta>

// Do not touch unless you know.
#define MAX_DATA_ARRAY_SIZE 5

#if AMXX_VERSION_NUM < 183
	#include <colorchat>
	#define print_team_default Blue
	#define print_team_red Red
	#define print_team_grey Grey
	#define print_team_blue Blue
	
	#define MAX_NAME_LENGTH 32
	#define client_disconnected client_disconnect
#endif

#define SQLITE		0
#define MYSQL		1

/*****	Stuff that you can Edit	*****/ 
/* Explanation of stuff inside:
ADMIN_ACCESS_LETTER 	->	Access flag for the admin command that checks the time of a player
USE_NAME		->	Will make the plugin use the name of the player as the saving identifier. If a player changes his name, his time will reset.
				To disable: comment the line by adding // infront of #define
				making it //#define
				To Enable: Un comment the line by removing '//'
SAVE_TYPE		->	Decides which method should the plugin use to save data:
				Valid Values: 0 for SQLite (save locally in the server files), 1 for MySQL (must have an external server)
PREPARE_TOP_MOTD	->	If you're using an external MySQL server (or if you have a huge amount of players, you might actually want to use this
				This allows you to prepare the top motd as soon as the map starts instead of actually making it each time a player
				submits a command; however, it does not give up to date results. 
				(TLDR: Good for servers with a huge load or amount of players,
				does not give up to date results though, and will disable /top#_time command.)
				Enable/Disable: Same method as USE_NAME
PREFIX			->	The prefix of the chat messages. Should be easy to edit. Does not need any more explanation.
GET_TIME_INSTANT_QUERY	-> 	
TOP_DEFAULT_NUMBER	-> 	Number of entries in Top MOTD when using /toptime commands and if using PREPARE_TOP_MOTD
GET_TIME_INSTANT_QUERY	->	This will force the plugin to not use threaded queries, only enable if you know what you're doing.
				I do not recomment using this on distant servers (for example, your game server is in one end
				while your sql server is at the other end of the world)
DO_NOT_LOG		->	Do not let the plugin to log queries. 
				(Logging is useful for debuging, but if you don't want to, disable it by removing //)
				PS: Do not expect support from me if you have logging disabled.
*/

// Editables
#define SAVE_TYPE		1
#define ADMIN_ACCESS_LETTER	"e"
#define TOP_DEFAULT_NUMBER	15

// Enabled, Disabled
//#define USE_NAME
//#define PREPARE_TOP_MOTD
//#define GET_TIME_INSTANT_QUERY
//#define DO_NOT_LOG

new const PREFIX[] = "\x04[Played-Time]";

new const g_szTimeCheckChatCommands[][] = {
	"/mt",
	"mt",
	"/my_time",
	"my_time",
	"/mytime",
	"mytime"
};

new const g_szTopTimeChatCommands[][] = {
	"/timetop",
	"/time15",
	"/toptime",
	"/time10"
};

#if SAVE_TYPE == MYSQL
new const SQL_CONNECT_DATA[][] = {
	"127.0.0.1",
	"root",
	"",
	"played_time"
};
#endif

new const LOG_FILE_PLAYED_TIME[] = "addons/amxmodx/logs/played_time_log.txt";
/************************************/ 
/*****		End		*****/ 
/************************************/ 
#define IDENTIFIER_MAX_LENGTH	35
#define NOT_RETRIEVED		-1

new Handle:g_hSqlHandle, g_szQuery[512];
new g_iPlayedTime[33] = NOT_RETRIEVED;

#if defined PREPARE_TOP_MOTD
new bool:g_bTopMotdNoData = false;
#endif

new g_szTopMotd[1536];

new g_szOldName[33][MAX_NAME_LENGTH];
new g_iQueryNumber;
new g_iMaxPlayers;
new g_hGetTimeForward, g_hSaveTimeForward;

public plugin_natives()
{
	register_library("played_time");
	
	register_native("pt_get_user_played_time", "native_get_user_played_time", 0);
	register_native("pt_set_user_played_time", "native_set_user_played_time", 0);

	// Compatibility with other older plugins;
	register_native("get_user_playedtime", 	"native_get_user_played_time", 0);
	register_native("set_user_playedtime", 	"native_set_user_played_time", 0);
	register_native("get_user_played_time", 	"native_get_user_played_time", 0);
	register_native("set_user_played_time", 	"native_set_user_played_time", 0);
	
	register_native("pt_get_save_type", "native_get_save_type", 0)
	
	g_hGetTimeForward = CreateMultiForward("pt_client_get_time", ET_IGNORE, FP_CELL, FP_CELL);
	g_hSaveTimeForward = CreateMultiForward("pt_client_save_time", ET_IGNORE, FP_CELL, FP_CELL);
}

public plugin_end()
{
	SQL_FreeHandle(g_hSqlHandle);
	DestroyForward(g_hGetTimeForward);
	DestroyForward(g_hSaveTimeForward);
}

public plugin_init() 
{
	// Why? Because it looks cool.
	register_plugin(.plugin_name = "Played Time: Extended", .author = "Khalid", .version = "1.0b");
	
	new szMapName[32]; get_mapname(szMapName, charsmax(szMapName));
	log_to_file(LOG_FILE_PLAYED_TIME, "---- Map changed to: %s ----", szMapName);
	
	new ADMIN_ACCESS = read_flags(ADMIN_ACCESS_LETTER);
	
	// Filter chat to hook chat commands
	for(new i, szCommand[32]; i < sizeof g_szTimeCheckChatCommands; i++)
	{
		formatex(szCommand, charsmax(szCommand), "say %s", g_szTimeCheckChatCommands[i]);
		register_clcmd(szCommand, "ClCmdSay_CheckTime");
		formatex(szCommand, charsmax(szCommand), "say_team %s", g_szTimeCheckChatCommands[i]);
		register_clcmd(szCommand, "ClCmdSay_CheckTime");
	}
	
	for(new i, szCommand[32]; i < sizeof g_szTopTimeChatCommands; i++)
	{
		formatex(szCommand, charsmax(szCommand), "say %s", g_szTopTimeChatCommands[i]);
		register_clcmd(szCommand, "ClCmdSay_TopTime");
		formatex(szCommand, charsmax(szCommand), "say_team %s", g_szTopTimeChatCommands[i]);
		register_clcmd(szCommand, "ClCmdSay_TopTime");
	}
	
	register_clcmd("say", "ClCmdSay_TopNumberCommand");
	register_clcmd("say_team", "ClCmdSay_TopNumberCommand");
	
	// Command to allow admins to check other players played time
	register_concmd("amx_playedtime", "AdminCmd_ShowPlayerTime", ADMIN_ACCESS," <name - #userid - steamid> - Show total and current time played by a specific player.");
	register_concmd("amx_show_played_time", "AdminCmd_ShowPlayerTime", ADMIN_ACCESS," <name - #userid - steamid> - Show total and current time played by a specific player.");
	register_concmd("amx_played_time", "AdminCmd_ShowPlayerTime", ADMIN_ACCESS," <name - #userid - steamid> - Show total and current time played by a specific player.");
	
	register_forward(FM_ClientUserInfoChanged, "FMCallback_InfoChanged_Post", 1)
	
	CreateTableInDB();
	g_iMaxPlayers = get_maxplayers();
}

public AdminCmd_ShowPlayerTime(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
	
	new szName[32], iPlayer
	if(read_argc() == 1)
	{
		console_print(id, "Showing players times of all connected players")
		new iPlayers[32], iNum, iPlayer, szName[32]
		get_players(iPlayers, iNum, "h")
		
		console_print(id, "%d. %-32s %-22s", "#", "Name", "Time Played");
		for(new i; i < iNum; i++)
		{
			iPlayer = iPlayers[i]
			get_user_name(iPlayer, szName, 31)
			
			console_print(id, "%d. %-32s %-22d", i + 1, szName, (g_iPlayedTime[iPlayer] + get_user_time(iPlayer)) / 60)
		}
	}
	
	else
	{
		new szArg[32]
		read_argv(1, szArg, charsmax(szArg))
		
		iPlayer = cmd_target(id, szArg, CMDTARGET_OBEY_IMMUNITY)
		
		if(iPlayer)
		{
			get_user_name(iPlayer, szName, charsmax(szName))
			console_print(id, "%s total played time is %d minute(s)", szName, ( g_iPlayedTime[iPlayer] + get_user_time(iPlayer) ) / 60);
			return PLUGIN_HANDLED;
		}
		
		if(szArg[0] == '@')
		{
			new iPlayers[32], iNum
			if( equali(szArg, "@TERRORIST") || equali(szArg, "@T") || equal(szArg, "@TERR") )
			{
				console_print(id, "Showing players times for team Terrorist");
				get_players(iPlayers, iNum, "eh", "TERRORIST");
			}
			
			else if( equali(szArg, "@COUNTERTERRORIST") || equali(szArg, "@CT") || equali(szArg, "@COUNTER") )
			{
				console_print(id, "Showing players times for team Counter-Terrorist");
				get_players(iPlayers, iNum, "eh", "CT");
			}
			
			else
			{
				console_print(id, "That's not a correct team");
				return PLUGIN_HANDLED
			}
			
			for(new i; i < iNum; i++)
			{
				iPlayer = iPlayers[i]
				get_user_name(iPlayer, szName, 31)
				console_print(id, "%d. %s %22.22d", i + 1, szName, ( g_iPlayedTime[iPlayer] + get_user_time(iPlayer) ) / 60)
			}
		}
	}
	
	return PLUGIN_HANDLED
}

public ClCmdSay_CheckTime(id) 
{
	new iAdditionalTime = get_user_time(id);
	
	client_print_color(id, print_team_default, "\x04-------------------------------#Played Time#-----------------------------------")
	if(g_iPlayedTime[id] != NOT_RETRIEVED)
	{
		client_print_color(id, print_team_grey, "%s \x03You have been playing on this server for \x03%d minute%s", PREFIX, iAdditionalTime / 60, iAdditionalTime / 60 == 1?  "" : "s");
		client_print_color(id, print_team_grey, "%s \x03Your total played time on the server: \x03%d minute%s.", PREFIX, (iAdditionalTime + g_iPlayedTime[id]) / 60, ( (iAdditionalTime + g_iPlayedTime[id]) / 60 ) == 1 ? "" : "s");
	}
	
	else
	{
		client_print_color(id, print_team_grey, "%s \x03Your total time is not retrieved yet.");
	}
	
	client_print_color(id, print_team_default, "\x04-------------------------------------------------------------------------------")
	
	return PLUGIN_CONTINUE;
}

public ClCmdSay_TopTime(id)
{
	#if defined PREPARE_TOP_MOTD
	if(g_bTopMotdNoData)
	{
		client_print_color(id, print_team_default, "%s \x03No data to do the top list yet.");
		return;
	}
	
	show_motd(id, g_szTopMotd, "Time Top List");
	#else
	FormatTop(id, TOP_DEFAULT_NUMBER);
	#endif
}

public ClCmdSay_TopNumberCommand(id)
{
	#if defined PREPARE_TOP_MOTD
	ClCmdSay_TopTime(id)
	#else
	new szSaid[25]
	read_argv(1, szSaid, charsmax(szSaid))
	
	if( containi(szSaid, "/top") != -1 && ( containi(szSaid, "_time") != -1 || containi(szSaid, "time") != -1) )
	{
		replace(szSaid, charsmax(szSaid), "/top", ""); replace(szSaid, charsmax(szSaid), "_time", "");
		replace(szSaid, charsmax(szSaid), "time", "");
		
		if(!is_str_num(szSaid))		// If it has more other words than /top*_time
		{
			return PLUGIN_CONTINUE	// stop plugin and continue to show the words
		}
		
		new iNum = str_to_num(szSaid)
		FormatTop(id, iNum);
	}
	#endif
	
	return PLUGIN_CONTINUE;
}

stock FormatTop(id, iTopNumber)
{
	new iData[MAX_DATA_ARRAY_SIZE]; 
	iData[0] = id; iData[1] = iTopNumber;
	
	FormatQuery(g_szQuery, charsmax(g_szQuery), 
	"SELECT `_name_field_`, `_time_field_` FROM `_table_name_` ORDER BY `_time_field_` DESC LIMIT %d", iTopNumber);
	SQL_SendThreadedQuery("FormatTop", g_hSqlHandle,"QueryHandler_FormatTopList", g_szQuery, iData);
}

public QueryHandler_FormatTopList(FailState, Handle:hQuery, szError[], iError, Data[], iDataSize)
{
	if(FailState)
	{	
		PluginLog_SQLCallback("QueryHandler_FormatTopList", Data[iDataSize - 1], iError, FailState, szError);
		return;
	}
	
	if(iError)
	{
		PluginLog_SQLCallback("QueryHandler_FormatTopList", Data[iDataSize - 1], iError, FailState, szError);
		return;
	}
	
	#if !defined PREPARE_TOP_MOTD
	if(!is_user_connected(Data[0]))
	{
		return;
	}
	#endif
	
	new  iLen, szName[32], iPlace, iTime;
	iLen = formatex(g_szTopMotd, charsmax(g_szTopMotd), "<body bgcolor=#000000><font color=#FFB00><pre>");
	iLen += format(g_szTopMotd[iLen], charsmax(g_szTopMotd) - iLen,"%s %-22.22s %3s\n", "#", "Name", "Time in minutes");
	
	new iCount;
	
	if(!SQL_NumResults(hQuery))
	{
		#if defined PREPARE_TOP_MOTD
		g_bTopMotdNoData = true;
		#else
		client_print_color(Data[0], print_team_default, "%s \x03No top time motd as there is no data.");
		#endif
		
		return;
	}
	
	while(SQL_MoreResults(hQuery))
	{
		SQL_ReadResult(hQuery, 0, szName, charsmax(szName));
		iTime = SQL_ReadResult(hQuery, 1);
		
		replace_all(szName, charsmax(szName), "<", "&lt;");
		replace_all(szName, charsmax(szName), ">", "&gt;");
		
		iLen += formatex(g_szTopMotd[iLen], charsmax(g_szTopMotd) - iLen, "%d %-22.22s %d\n", ++iPlace, szName, iTime / 60);
		SQL_NextRow(hQuery)
		iCount++;
	}
	
	if(iCount)
	{
		iLen += formatex(g_szTopMotd[iLen], charsmax(g_szTopMotd) - iLen, "</pre></font></body>");
		
		new szTitle[25];
		formatex(szTitle, charsmax(szTitle), "Time Top%d", Data[1]);
		
		if(Data[0] > 0)
		{
			show_motd(Data[0], g_szTopMotd, szTitle);
		}
	}
	
	else
	{
		client_print_color(Data[0], print_team_default, "%s \x01No data in database yet..", PREFIX);
	}
}

public client_disconnected(id)
{
	if(is_user_bot(id))
	{
		return;
	}
	
	if(g_iPlayedTime[id] != NOT_RETRIEVED)
	{
		SavePlayedTime(id, true);
		g_iPlayedTime[id] = NOT_RETRIEVED;
	}
}

public client_authorized(id)
{
	if(is_user_bot(id))
	{
		return;
	}
	
	g_iPlayedTime[id] = NOT_RETRIEVED;
	#if !defined GET_TIME_INSTANT_QUERY
	GetClientPlayedTime(id, true);
	#else
	g_iPlayedTime[id] = GetClientPlayedTime(id, true);
	#endif
}

public client_infochanged(id)
{
	if(!is_user_connected(id))
	{
		return;
	}
	
	get_user_name(id, g_szOldName[id], charsmax(g_szOldName[]));
}

public FMCallback_InfoChanged_Post(id)
{
	if(!is_user_connected(id))
	{
		return;
	}
	
	new szNewName[32];
	get_user_name(id, szNewName, charsmax(szNewName));
	
	if(!equal(g_szOldName[id], szNewName))
	{
		#if defined USE_NAME;
		g_iPlayedTime[id] = NOT_RETRIEVED;
		GetClientPlayedTime(id, false);	// Get new played time for the new name.
		#else
		CleanString(szNewName, charsmax(szNewName))
		UpdateNameInDatabase(id, szNewName);
		#endif
	}
}

#if !defined USE_NAME
stock UpdateNameInDatabase(id, szNewName[])
{
	if(g_iPlayedTime[id] == NOT_RETRIEVED)
	{
		return;
	}
	
	new szAuthId[33]; get_user_authid(id, szAuthId, charsmax(szAuthId));
	FormatQuery(g_szQuery, charsmax(g_szQuery), "UPDATE `_table_name_` SET `_name_field_` = '%s' WHERE `_identifier_field_` = '%s'", szNewName, szAuthId);
	SQL_ThreadQuery(g_hSqlHandle, "QueryHandler_Dump", g_szQuery);
}
#endif

stock SavePlayedTime(id, bool:bIsDisconnect)
{
	new szIdentifier[IDENTIFIER_MAX_LENGTH];
	
	new iRet
	ExecuteForward(g_hSaveTimeForward, iRet, id, bIsDisconnect);
	
	#if defined USE_NAME
	get_user_name(id, szIdentifier, charsmax(szIdentifier));
	CleanString(szIdentifier, charsmax(szIdentifier));
	#else
	get_user_authid(id, szIdentifier, charsmax(szIdentifier));
	#endif
	
	#if defined USE_NAME
	FormatQuery(g_szQuery, charsmax(g_szQuery), "UPDATE _table_name_ SET `_time_field_` = '%d' WHERE `_name_field_` ='%s'", g_iPlayedTime[id] + get_user_time(id), szIdentifier);
	#else
	FormatQuery(g_szQuery, charsmax(g_szQuery), "UPDATE _table_name_ SET `_time_field_` = '%d' WHERE `_identifier_field_` ='%s'", g_iPlayedTime[id] + get_user_time(id), szIdentifier);
	#endif
	
	SQL_SendThreadedQuery("SavePlayedTime", g_hSqlHandle, "QueryHandler_Dump", g_szQuery);
}

#if !defined GET_TIME_INSTANT_QUERY
stock GetClientPlayedTime(id, bool:bConnect = true)
{	
	new szIdentifier[MAX_NAME_LENGTH + 3];
	#if defined USE_NAME
	get_user_name(id, szIdentifier, charsmax(szIdentifier));
	CleanString(szIdentifier, charsmax(szIdentifier));
	#else
	get_user_authid(id, szIdentifier, charsmax(szIdentifier));
	#endif
	
	#if defined USE_NAME
	FormatQuery(g_szQuery, charsmax(g_szQuery), "SELECT `_time_field_` FROM `_table_name_` WHERE `_name_field_` ='%s'", szIdentifier);
	#else
	new szName[MAX_NAME_LENGTH]; get_user_name(id, szName, charsmax(szName));
	FormatQuery(g_szQuery, charsmax(g_szQuery), "SELECT `_time_field_`, `_name_field_` FROM `_table_name_` WHERE `_identifier_field_` ='%s'", szIdentifier);
	#endif
	
	new Data[MAX_DATA_ARRAY_SIZE];
	Data[0] = id; Data[1] = _:bConnect;
	SQL_SendThreadedQuery("QueryHandler_GetPlayedTime", g_hSqlHandle, "QueryHandler_GetPlayedTime", g_szQuery, Data);
}

public QueryHandler_GetPlayedTime(FailState, Handle:hQuery, szError[], iError, Data[], iDataSize)
{
	PluginLog_SQLCallback("QueryHandler_GetPlayedTime", Data[iDataSize - 1], iError, FailState, szError);
	
	if(iError)
	{
		return;
	}
	
	new szName[MAX_NAME_LENGTH];
	
	#if !defined USE_NAME
	new szIdentifier[IDENTIFIER_MAX_LENGTH]; get_user_authid(Data[0], szIdentifier, charsmax(szIdentifier));
	#endif
	
	new id = Data[0];
	if(!SQL_MoreResults(hQuery))
	{
		get_user_name(id, szName, charsmax(szName));
		
		#if defined USE_NAME
		FormatQuery(g_szQuery, charsmax(g_szQuery), "INSERT INTO `_table_name_` (`_name_field_`, `_time_field_`) VALUES ('%s', '0')", szName);
		#else
		FormatQuery(g_szQuery, charsmax(g_szQuery), "INSERT INTO `_table_name_` (`_identifier_field_`, `_name_field_`, `_time_field_`) VALUES ('%s', '%s', '0')", szIdentifier, szName);
		#endif
		
		g_iPlayedTime[id] = 0;
		SQL_SendThreadedQuery("QueryHandler_GetPlayedTime", g_hSqlHandle, "QueryHandler_Dump", g_szQuery);
		return;
	}
	
	g_iPlayedTime[id] = SQL_ReadResult(hQuery, 0);
	
	new iRet;
	ExecuteForward(g_hGetTimeForward, iRet, id, Data[1]);
	
	get_user_name(id, szName, charsmax(szName));
	PluginLog("Got %d minutes (%d sec) for %s", g_iPlayedTime[id] / 60, g_iPlayedTime[id], szName);
	
	#if !defined USE_NAME
	new szOldSavedName[MAX_NAME_LENGTH];
	
	//get_user_name(id, szName, charsmax(szName));
	SQL_ReadResult(hQuery, 1, szOldSavedName, charsmax(szOldSavedName))
	
	CleanString(szName, charsmax(szName));
	
	if(!equal(szName, szOldSavedName))
	{
		FormatQuery(g_szQuery, charsmax(g_szQuery),
		"UPDATE `_table_name_` SET `_name_field_` = '%s' WHERE `_identifier_field_` = '%s'",
		szName, szIdentifier);
		SQL_SendThreadedQuery("QueryHandler_GetPlayedTime", g_hSqlHandle, "QueryHandler_Dump", g_szQuery);
	}
	#endif
}
#else

stock GetClientPlayedTime(id, bool:bConnect = true)
{	
	new szIdentifier[MAX_NAME_LENGTH + 3];
	new szName[MAX_NAME_LENGTH]; get_user_name(id, szName, charsmax(szName));
	
	#if defined USE_NAME
	get_user_name(id, szIdentifier, charsmax(szIdentifier));
	CleanString(szIdentifier, charsmax(szIdentifier));
	#else
	get_user_authid(id, szIdentifier, charsmax(szIdentifier));
	#endif
	
	#if defined USE_NAME
	FormatQuery(g_szQuery, charsmax(g_szQuery), "SELECT `_time_field_` FROM `_table_name_` WHERE `_name_field_` ='%s'", szIdentifier);
	#else
	FormatQuery(g_szQuery, charsmax(g_szQuery), "SELECT `_time_field_`, `_name_field_` FROM `_table_name_` WHERE `_identifier_field_` ='%s'", szIdentifier);
	#endif

	//SQL_SendThreadedQuery("QueryHandler_GetPlayedTime", g_hSqlHandle, "QueryHandler_GetPlayedTime", g_szQuery, Data);
	
	PluginLog_Query("GetClientPlayedTime", g_szQuery);
	
	new Handle:hQuery, Handle:hConnection;
	new iError, szError[256];
	hConnection = SQL_Connect(g_hSqlHandle, iError, szError, charsmax(szError));
	++g_iQueryNumber
	
	if(iError)
	{
		SQL_FreeHandle(hConnection);
		PluginLog_SQLCallback("GetClientPlayedTime #1", g_iQueryNumber, iError, 0, szError);
		
		return;
	}
	
	hQuery = SQL_PrepareQuery(g_hSqlHandle, g_szQuery);
	
	if(!SQL_Execute(hQuery))
	{
		SQL_QueryError(hQuery, szError, charsmax(szError));
		PluginLog_SQLCallback("GetClientPlayedTime #2", g_iQueryNumber, 0, 0, szError);
		
		SQL_FreeHandle(hQuery);
		SQL_FreeHandle(hConnection);
		return;
	}
	
	if(!SQL_MoreResults(hQuery))
	{
		SQL_FreeHandle(hQuery);
		SQL_FreeHandle(hConnection);
		
		get_user_name(id, szName, charsmax(szName));
		
		#if defined USE_NAME
		FormatQuery(g_szQuery, charsmax(g_szQuery), "INSERT INTO `_table_name_` (`_name_field_`, `_time_field_`) VALUES ('%s', '0')", szName);
		#else
		FormatQuery(g_szQuery, charsmax(g_szQuery), "INSERT INTO `_table_name_` (`_identifier_field_`, `_name_field_`, `_time_field_`) VALUES ('%s', '%s', '0')", szIdentifier, szName);
		#endif
		
		g_iPlayedTime[id] = 0;
		SQL_SendThreadedQuery("GetClientPlayedTime #3", g_hSqlHandle, "QueryHandler_Dump", g_szQuery);
		return;
	}
	
	new iRet;
	ExecuteForward(g_hGetTimeForward, iRet, id, bConnect);
	
	get_user_name(id, szName, charsmax(szName));
	PluginLog("Got %d minutes (%d sec) for %s", g_iPlayedTime[id] / 60, g_iPlayedTime[id], szName);
	
	#if !defined USE_NAME
	new szOldSavedName[MAX_NAME_LENGTH];
	
	//get_user_name(id, szName, charsmax(szName));
	SQL_ReadResult(hQuery, 1, szOldSavedName, charsmax(szOldSavedName))
	
	CleanString(szName, charsmax(szName));
	
	if(!equal(szName, szOldSavedName))
	{
		FormatQuery(g_szQuery, charsmax(g_szQuery),
		"UPDATE `_table_name_` SET `_name_field_` = '%s' WHERE `_identifier_field_` = '%s'",
		szName, szIdentifier);
		SQL_SendThreadedQuery("GetClientPlayedTime #3", g_hSqlHandle, "QueryHandler_Dump", g_szQuery);
	}
	#endif
	
	g_iPlayedTime[id] = SQL_ReadResult(hQuery, 0);
	
	SQL_FreeHandle(hQuery);
	SQL_FreeHandle(hConnection);
}
#endif


public QueryHandler_Dump(FailState, Handle:Query, szError[], iError, Data[], iDataSize)
{
	PluginLog_SQLCallback("QueryHandler_Dump", Data[iDataSize - 1], iError, FailState, szError);
}

CreateTableInDB()
{
	#if SAVE_TYPE == SQLITE
	SQL_SetAffinity("sqlite");
	g_hSqlHandle = SQL_MakeDbTuple("", "", "", "played_time_database");
	#endif
	
	#if SAVE_TYPE == MYSQL
	SQL_SetAffinity("mysql");
	g_hSqlHandle = SQL_MakeDbTuple(SQL_CONNECT_DATA[0], SQL_CONNECT_DATA[1], SQL_CONNECT_DATA[2], SQL_CONNECT_DATA[3]);
	#endif
	
	if(g_hSqlHandle == Empty_Handle)
	{
		set_fail_state("Could not connect to the SQL Database.");
	}
	
	#if SAVE_TYPE == SQLITE
		#if defined USE_NAME
		FormatQuery(g_szQuery, charsmax(g_szQuery),"CREATE TABLE IF NOT EXISTS `_table_name_` (`id` INTEGER PRIMARY KEY, `_name_field_` CHAR(32) UNIQUE, `_time_field_` INTEGER");
		#else
		FormatQuery(g_szQuery, charsmax(g_szQuery),"CREATE TABLE IF NOT EXISTS `_table_name_` (`id` INTEGER PRIMARY KEY, `_identifier_field_` CHAR(35) UNIQUE, `_name_field_` CHAR(32), _time_field_ INTEGER)");
		#endif
	#endif
	#if SAVE_TYPE == MYSQL
		#if defined USE_NAME
		FormatQuery(g_szQuery, charsmax(g_szQuery), "CREATE TABLE IF NOT EXISTS `_table_name_` (`_name_field_` VARCHAR(35) UNIQUE, `_time_field_` INT, `date_created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP)");
		#else
		FormatQuery(g_szQuery, charsmax(g_szQuery), "CREATE TABLE IF NOT EXISTS `_table_name_` (`_identifier_field_` VARCHAR(35) UNIQUE, `_name_field_` VARCHAR(32), `_time_field_` INT, `date_created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)");
		#endif
	#endif
	
	SQL_SendThreadedQuery("CreateTableInDB", g_hSqlHandle, "QueryHandler_Initialize", g_szQuery);
}

public QueryHandler_Initialize(FailState, Handle:Query, szError[], iError, Data[], iDataSize)
{
	if(FailState || iError)
	{
		PluginLog_SQLCallback("QueryHandler_Initialize", Data[iDataSize - 1], iError, FailState, szError);
		#if AMXX_VERSION_NUM < 183
		new szFailStateMessage[256];
		formatex(szFailStateMessage, charsmax(szFailStateMessage), "FailState %d %d: %s", FailState, iError, szError);
		set_fail_state(szFailStateMessage);
		#else
		set_fail_state("FailState %d %d: %s", FailState, iError, szError);
		#endif
	}
	
	else 
	{
		PluginLog("(QueryHandler_Initialize) [Query #: %d]: StartUp Query executed Successfully.", Data[iDataSize - 1]);
	}
	
	#if defined PREPARE_TOP_MOTD
	FormatTop(-1, TOP_DEFAULT_NUMBER);
	#endif
}

// NATIVES
public native_get_user_played_time(plugin_id, argc)
{
	new id = get_param(1);
	if(!IsValidPlayer_Native(id))
	{
		return -1
	}
	
	return g_iPlayedTime[id];
}

public native_set_user_played_time(plugin_id, argc)
{
	new id = get_param(1);
	new iNewTime = get_param(2);
	
	if(!IsValidPlayer_Native(id))
	{
		return 0
	}
	
	g_iPlayedTime[id] = iNewTime;
	return 1;
}

public native_get_save_type(plugin_id, argc)
{
	return SAVE_TYPE;
}

stock IsValidPlayer_Native(id)
{
	if(!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "Client %d is NOT connected", id);
		return 0;
	}
	
	if(is_user_bot(id))
	{
		log_error(AMX_ERR_NATIVE, "Client %d is a BOT", id);
		return 0;
	}
	
	if(is_user_hltv(id))
	{
		log_error(AMX_ERR_NATIVE, "HLTV client %d", id);
		return 0;
	}
	
	if( !( 1 <= id <= g_iMaxPlayers ) )
	{
		log_error(AMX_ERR_NATIVE, "Index out of bounds %d", id);
		return 0
	}
	
	return 1;
}

stock CleanString(szName[], iSize)
{
	replace_all(szName, iSize, "\"", "");
	replace_all(szName, iSize, "'", "");
}

stock FormatQuery(szQueryStorage[], iSize, szQuery[], any:...)
{
	vformat(szQueryStorage, iSize, szQuery, 4);
	
	replace_all(szQueryStorage, iSize, "_identifier_field_", "steamid");
	replace_all(szQueryStorage, iSize, "_name_field_", "name");
	replace_all(szQueryStorage, iSize, "_time_field_", "time_played");
	replace_all(szQueryStorage, iSize, "_table_name_", "played_time");
}

stock SQL_SendThreadedQuery(szPosition[], Handle:hSql, szQueryCallback[], szQuery[], Data[MAX_DATA_ARRAY_SIZE] = "")
{
	new ModifiedData[MAX_DATA_ARRAY_SIZE + 1];
	
	// Must be before, as this is where the increment happen.
	PluginLog_Query(szPosition, szQuery);
	for(new i; i < MAX_DATA_ARRAY_SIZE; i++)
	{
		ModifiedData[i] = Data[i];
	}
	
	ModifiedData[MAX_DATA_ARRAY_SIZE] = g_iQueryNumber;
	
	SQL_ThreadQuery(hSql, szQueryCallback, szQuery, ModifiedData, MAX_DATA_ARRAY_SIZE + 1);
}

stock PluginLog(szString[], any:...)
{
	#if !defined DO_NOT_LOG
	new szLog[1024]
	vformat(szLog, charsmax(szLog), szString, 2);
	
	log_to_file(LOG_FILE_PLAYED_TIME, szLog);
	//log_amx("[Played Time] %s", szLog);
	#endif
}

stock PluginLog_Query(szPosition[], szQuery[])
{
	#if !defined DO_NOT_LOG
	log_to_file(LOG_FILE_PLAYED_TIME, "(%s) Query Executed (#%d): \n\t\t\t\t%s", szPosition, ++g_iQueryNumber, szQuery);
	//log_amx("[Played Time] (%s) Query Executed (#%d): \n\t\t%s", szPosition, g_iQueryNumber, szQuery);
	#endif
}

stock PluginLog_SQLCallback(szPosition[], iQueryNumber, iError, FailState, szError[])
{
	#if !defined DO_NOT_LOG
	if(iError || FailState)
	{
		log_to_file(LOG_FILE_PLAYED_TIME, "(%s) [Query#: %d] [Error# :%d] [FailState: %d]: %s", szPosition, iQueryNumber, iError, FailState, szError);
	}
	
	else if(!iError && !FailState)
	{
		log_to_file(LOG_FILE_PLAYED_TIME, "(%s) [Query#: %d] executed successfully", szPosition, iQueryNumber);
	}
	#endif
}
