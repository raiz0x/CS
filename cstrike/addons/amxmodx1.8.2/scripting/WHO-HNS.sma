#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Admini - HNS.PLAY-ARENA.RO"
#define VERSION "1.0"
#define AUTHOR ""

#define CharsMax(%1) sizeof %1 - 1//da..

#define MAX_GROUPS 32
new g_groupNames[MAX_GROUPS][] = {
	"-----  *  Fondator+Ftp  *  -----",
	"-----  *  Manager  *  -----",
	"-----  *  Manager+V.I.P G-1  *  -----",
	"-----  *  Manager+V.I.P G-2  *  -----",
	"-----  *  Manager+V.I.P G-3  *  -----",
	"-----  *  Owner  *  -----",
	"-----  *  Owner+V.I.P G-1  *  -----",
	"-----  *  Owner+V.I.P G-2  *  -----",
	"-----  *  Owner+V.I.P G-3  *  -----",
	"-----  *  GooD  *  -----",
	"-----  *  GooD+V.I.P G-1  *  -----",
	"-----  *  GooD+V.I.P G-2  *  -----",
	"-----  *  GooD+V.I.P G-3  *  -----",
	"-----  *  Moderator  *  -----",
	"-----  *  Moderator+V.I.P G-1  *  -----",
	"-----  *  Moderator+V.I.P G-2  *  -----",
	"-----  *  Moderator+V.I.P G-3  *  -----",
	"-----  *  Administrator  *  -----",
	"-----  *  Administrator+V.I.P G-1  *  -----",
	"-----  *  Administrator+V.I.P G-2  *  -----",
	"-----  *  Administrator+V.I.P G-3  *  -----",
	"-----  *  Helper  *  -----",
	"-----  *  Helper+V.I.P G-1  *  -----",
	"-----  *  Helper+V.I.P G-2  *  -----",
	"-----  *  Helper+V.I.P G-3  *  -----",
	"-----  *  Tester  *  -----",
	"-----  *  Tester+V.I.P G-1  *  -----",
	"-----  *  Tester+V.I.P G-2  *  -----",
	"-----  *  Tester+V.I.P G-3  *  -----",
	"-----  *  V.I.P G-1  *  -----",
	"-----  *  V.I.P G-2  *  -----",
	"-----  *  V.I.P G-3  *  -----"
}
new g_groupFlags[MAX_GROUPS][] = {
	"abcdefghijklmnoprstu",
	"abcdefijkmnoprs",
	"abcdefijkmnoprst",
	"abcdefijkmnotrsp",
	"adikmnoprstlbfjce",
	"abcdefijmnrs",
	"abcdefijmnrsp",
	"abcdefijmnrst",
	"adimnrstlbjce",
	"bcdefijmnr",
	"bcdefijmnrp",
	"bcdefijmnrt",
	"dimnrtlbfjce",
	"bfjcedijmngs",
	"bfjcedijmngsp",
	"bfjcedijmngst",
	"dijmngsplbfjce",
	"bfjcedijmn",
	"bfjcedijmnp",
	"bfjcedijmnt",
	"dimnlbfjce",
	"bfjceijm",
	"bfjceijmp",
	"bfjceijmt",
	"imlbfjce",
	"bceij",
	"bceijp",
	"bceijt",
	"ilbfjce",
	"p",
	"t",
	"lbfjce"
}
new g_ValueFlaguri[ MAX_GROUPS ];

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for( new i = 0 ; i < MAX_GROUPS ; i++ )	g_ValueFlaguri[ i ] = read_flags( g_groupFlags[ i ] );
	register_clcmd("say /who", "cmdWho");
	register_clcmd("say /admin", "cmdWho");
	
	
	register_concmd("amx_unlag","UNLAG_FC",ADMIN_LEVEL_A,"<valoare>")
	register_concmd("amx_restart","RESTART_FC",ADMIN_LEVEL_A,"<valoare>")
	register_concmd("amx_timelimit","TIMELIMIT_FC",ADMIN_LEVEL_A,"<valoare>")
}

public UNLAG_FC(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))	return PLUGIN_HANDLED
	
	new arg1[32],nume[32]
	read_argv(1,arg1,charsmax(arg1))
	get_user_name(id,nume,charsmax(nume))
	
	client_print(0,print_chat,"[PLAY-ARENA] Adminul %s , a setat sv_unlag pe %d",nume,str_to_num(arg1))
	server_cmd("sv_unlag %d",str_to_num(arg1))
	
	return PLUGIN_HANDLED
}
public RESTART_FC(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))	return PLUGIN_HANDLED
	
	new arg1[32],nume[32]
	read_argv(1,arg1,charsmax(arg1))
	get_user_name(id,nume,charsmax(nume))
	
	client_print(0,print_chat,"[PLAY-ARENA] Adminul %s , a setat sv_restart pe %d",nume,str_to_num(arg1))
	server_cmd("sv_restart %d",str_to_num(arg1))
	
	return PLUGIN_HANDLED
}
public TIMELIMIT_FC(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))	return PLUGIN_HANDLED
	
	new arg1[32],nume[32]
	read_argv(1,arg1,charsmax(arg1))
	get_user_name(id,nume,charsmax(nume))
	
	client_print(0,print_chat,"[PLAY-ARENA] Adminul %s , a setat mp_timelimit pe %d",nume,str_to_num(arg1))
	server_cmd("mp_timelimit %d",str_to_num(arg1))
	
	return PLUGIN_HANDLED
}


public cmdWho(id)
{
	static sPlayers[32], iNum,sBuffer[2368],iLen,sName[32],iPlayer,x,i
	get_players(sPlayers, iNum,"ch");
	
	iLen = formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen, "<html><head><meta charset=UTF-8></head><body bgcolor=black><center><h2><font color=^"00f5d0^"><B>hNs.PlayArena.Ro - Admini Online !</B></font></h2></center><br>");
	iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen,"<table align=center width=100%% cellpadding=2 cellspacing=0>");
	iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen,"<tr align=center bgcolor=#52697B><th width=5%%> NUME ADMIN</th><th width=6%%> ACCES ADMIN</th></tr>");
	
	for(x = 0; x < iNum; ++x)
	{
		iPlayer = sPlayers[x];
		for(i=0;i<=MAX_GROUPS;i++)
		{
			if(get_user_flags(iPlayer)==read_flags(g_groupFlags[i]/*g_ValueFlaguri[i]*/))
			{
				get_user_name(iPlayer, sName, charsmax(sName));
				iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen, "<tr align=center bgcolor=#2D2D2D><td><font color=red>%s</font> <td><font color=red>%s</font></tr>", sName,g_groupNames[i]);
			}
		}
	}
	iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen, "</table></body></html>");
	show_motd(id, sBuffer, "Adminii Online");
}
