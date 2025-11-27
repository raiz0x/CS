#include <amxmodx>
#include <amxmisc>
#include <csx>
#include <nvault>

#pragma compress 1

#define EVO

new g_NvID, g_sBuffer[2048], toggle_sound;


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


	register_plugin("CFG Top15", "1.3 parca..", "x");

	register_clcmd("say /top15", "cmdTop15");
	register_clcmd("say_team /top15", "cmdTop15");

	toggle_sound = register_cvar("cfg_top15_sound", "1")

	g_NvID = nvault_open("playtimevault");
}

public client_disconnect(id)
{
	new szPlayTime[8], szAuthID[35], iPlayTime,ts;
	get_user_name(id, szAuthID, 34);

	if( !nvault_lookup( g_NvID, szAuthID , szPlayTime , 7 , ts ) )
	{
		format(szPlayTime, 7, "%d" , get_user_time(id, 1) );
		nvault_set( g_NvID , szAuthID , szPlayTime);
	}

	else
	{
		iPlayTime = str_to_num(szPlayTime) + get_user_time(id, 1);
		format(szPlayTime, 7, "%d" , iPlayTime );
		nvault_set( g_NvID , szAuthID , szPlayTime);
	}
}

Float:accuracy(izStats[8])
{
	if (!izStats[4])
	{
		return (0.0);
	}

	return (100.0 * float(izStats[5]) / float(izStats[4]));
}

Float:effec(izStats[8])
{
	if (!izStats[0])
	{
		return (0.0);
	}

	return (100.0 * float(izStats[0]) / float(izStats[0] + izStats[1]));
}

format_top15(sBuffer[2048])
{
	new loc1 = get_statsnum();
	new loc2 = get_statsnum();
	new loc3 = get_statsnum();

	new iMax = get_statsnum();
	new izStats[8], izBody[8], t_sName[32];
	new iLen = 0;

	if (iMax > 15)
	{
		iMax = 15;
	}

	loc1 = 1;
	loc2 = 2;
	loc3 = 3;
	new szTime[8];
      	new ts;

	iLen = format(sBuffer, 2047, "<body bgcolor=#000000><font color=#FFB000><pre>");
	iLen += format(sBuffer[iLen], 2047 - iLen, "%2s %-22.22s %6s %6s %4s %6s %4s %4s^n", "#", "Nick", " Kills", "Deaths", "  HS", " Eff", "Acc", "PlayTime");

	for (new i = 0; i < loc1 && 2047 - iLen > 0; i++)
	{
		get_stats(i, izStats, izBody, t_sName, 31);

		replace_all(t_sName, 31, "<", "[");
		replace_all(t_sName, 31, ">", "]");
   	
 
		new iCurTime = get_user_time( i , 1 );
		new iTotalTime = 0;

		if( nvault_lookup(g_NvID, t_sName , szTime, 7, ts) )
		{
          		iTotalTime = str_to_num(szTime);
		}

		iLen += format(sBuffer[iLen], 2047 - iLen, "%2d <font color=ff0bb7>%-22.22s</font> %6d %6d %4d %3.0f%% %3.0f%% %4d h <img src=http://icons.iconarchive.com/icons/3xhumed/mega-games-pack-05/16/Steam-icon.png>^n", i + 1, t_sName, izStats[0], izStats[1], izStats[2], effec(izStats), accuracy(izStats), ((iCurTime + iTotalTime) / 3600));
      
	}

	for (new i = 1; i < loc2 && loc2 != loc1 && 2047 - iLen > 0; i++/*; && loc2 != loc1*/)
	{
		get_stats(i, izStats, izBody, t_sName, 31);
		replace_all(t_sName, 31, "<", "[");
		replace_all(t_sName, 31, ">", "]");

		new iCurTime = get_user_time( i , 1 );
		new iTotalTime = 0;

		if( nvault_lookup(g_NvID, t_sName , szTime, 7, ts) )
		{
          		iTotalTime = str_to_num(szTime);
		}

		iLen += format(sBuffer[iLen], 2047 - iLen, "%2d <font color=#07fcff>%-22.22s</font> %6d %6d %4d %3.0f%% %3.0f%% %4d h <img src=http://img.informer.com/icons/png/16/24/24873.png>^n", i + 1, t_sName, izStats[0], izStats[1], izStats[2], effec(izStats), accuracy(izStats), ((iCurTime + iTotalTime) / 3600));
	}

	for (new i = 2; i < loc3 && loc3 != loc2 && 2047 - iLen > 0; i++/*; && loc3 != loc2*/)
	{
		get_stats(i, izStats, izBody, t_sName, 31);
		replace_all(t_sName, 31, "<", "[");
		replace_all(t_sName, 31, ">", "]");
  
		new iCurTime = get_user_time( i , 1 );
		new iTotalTime = 0;

		if( nvault_lookup(g_NvID, t_sName , szTime, 7, ts) )
		{
          		iTotalTime = str_to_num(szTime);
		}

		iLen += format(sBuffer[iLen], 2047 - iLen, "%2d <font color=#0BF402>%-22.22s</font> %6d %6d %4d %3.0f%% %3.0f%% %4d h <img src=http://t3.gstatic.com/images?q=tbn:ANd9GcQXa5ZqvYUrvmGP4WdvHScOjSkie7RBtjsC4AeXDoDMDWzgxcti>^n", i + 1, t_sName, izStats[0], izStats[1], izStats[2], effec(izStats), accuracy(izStats), ((iCurTime + iTotalTime) / 3600));
	}

	for (new i = 3; i < iMax && 2047 - iLen > 0; i++)
	{
		get_stats(i, izStats, izBody, t_sName, 31);
		replace_all(t_sName, 31, "<", "[");
		replace_all(t_sName, 31, ">", "]");

		new iCurTime = get_user_time( i , 1 );
		new iTotalTime = 0;

		if( nvault_lookup(g_NvID, t_sName , szTime, 7, ts) )
		{
          		iTotalTime = str_to_num(szTime);
		}

		iLen += format(sBuffer[iLen], 2047 - iLen, "%2d %-22.22s %6d %6d %4d %3.0f%% %3.0f%% %4d h^n", i + 1, t_sName, izStats[0], izStats[1], izStats[2], effec(izStats), accuracy(izStats), ((iCurTime + iTotalTime) / 3600));
	}

        iLen += format(sBuffer[iLen], 2047 - iLen, "<font color=#00FA9A>Cei mai buni Playeri se gasesc aici.</font>");
        iLen += format(sBuffer[iLen], 2047 - iLen, "<font color=#00FA9A> Ai onoarea de a fi in acest Top !</font>")
}

public cmdTop15( id )
{
	format_top15( g_sBuffer );
	show_motd( id, g_sBuffer, "Top 15" );

	if( get_pcvar_num( toggle_sound ) != 0 )
	{
		client_cmd( id, "spk ^"vox/top fifteen^"" )
	}

	return PLUGIN_HANDLED;
}

public plugin_end( )
{
    nvault_close( g_NvID );
}
