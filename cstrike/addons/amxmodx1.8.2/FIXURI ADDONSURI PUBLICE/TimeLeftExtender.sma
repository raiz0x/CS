/*
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
 *  All date formats are in european format (dd.mm.yyyy)
 *
 *                                  _
 *                                 | | _
 *              _ __  _ ______  ___| |(_) __ ___  __
 *             | '_ \| '_/  _ \/  _  || |/ _' | \/ /
 *             | |_) | | \ (_) \ (_| || | (_| |\  /
 *             | .__/|_|  \____/\____||_|\__. |/ /
 *             |_|                       |___//_/
 *      
 *  File:    TimeLeftExtender.sma
 *
 *  Title:   TimeLeft Extender
 *
 *  Version: 1.2
 *
 *  Feel free to redistribute and modify this file,
 *  But please give me some credits.
 *
 *  Author:  prodigy
 *           pro.digy@gmx.net
 *
 *  Last Changes:     17.07.2007 (dd.mm.yyyy)
 *
 *  Credits: - Johnny got his gun @ http://forums.alliedmods.net/showthread.php?p=67909
 *             For his code about detecting a round end.. and inspiring me to write this
 *           - The AMXX Team for some code from the timeleft.sma
 *           - MaximusBrood @ http://forums.alliedmods.net/showthread.php?p=236886
 *             For the color-code
 *           - neuromancer: Fixing the bug where the plugin "randomly" changed the map for some unknown reason
 *
 *  Purpose: This plugin removes the timelimit CATCH_MAPCHANGE_AT seconds before mapchange
 *           and makes the round end after the current round delaying the change for
 *           amx_tle_chattime seconds.
 *           When mapchange is blocked typing timeleft displays that the current round is the last.
 *
 *
 *  CVars:
 *           amx_tle_enabled [1]/0   - Controls wether the plugin is enabled or not. (default 1)
 *           amx_tle_usehud [1]/0    - Controls wether to use HUD message announcement or not. (default 1)
 *           amx_tle_chattime [7]    - Controls the time people have to chat before actual change occurs. (default 7)
 *           amx_tle_catchat [5]     - Controls at which second of timeleft the plugin should
 *                                       catch the mapchange and block it. (default 5)
 *           amx_tle_textcolor 0-[2] // Sets the color of the "This is the last round" message.
 *                                   //  0 = Normal chat color
 *                                   //  1 = Team color (CT: blue, T: red)
 *                                   //  2 = Green
 *
 *  Commands:
 *           amx_changenow          - Changes map immediatley to current amx_nextmap
 *           say changenow          - Changes map immediatley to current amx_nextmap
 *           say timeleft           - If the plugin blocked the mapchange, saying timeleft will
 *                                      display "This is the last round." in the users language.
 *
 *  Copyright (c) 2007 by Sebastian G. alias prodigy
 *
 *  Change-Log:
 *    1.2 (17.07.2007):
 *       Bug Fix:
 *         o Fixed the bug where the plugin "randomly" changed the map for some unknown reason
 *    1.1a (08.05.2007):
 *       o changed cvars to pcvars
 *
 *    1.1 (30.04.2007): 
 *       Features:
 *         o Added amx_tle_textcolor and functionality
 *    
 *    1.0 (29.04.2007):
 *       o initial release
 *
 *    0.1 Alpha (29.04.2007):
 *       o Added functionality for everything in 1.0,
 *         basically I just renamed the Version number.
 */

/*  amx_time_display "ab 1200" "ab 600" "ab 300" "ab 180" "ab 60"   ->  in amxx.cfg
[...]
; Map related
nextmap.amxx          ; displays next map in mapcycle
mapchooser.amxx       ; allows to vote for next map


TimeLeftExtender.amxx ; << needs to be in front of timeleft.amxx to
                      ; block it from displaying "No Time Limit"!!
timeleft.amxx         ; displays time left on map
[...]
*/

// de facut cu sync
// de facut sa reseteze mp_timelimit cand nu e in functiune faza

#include <amxmodx>

#pragma tabsize 0

#define DENUMIRE "DR.THEXFORCE.RO"

#define TLE_ENABLED "1"
#define DEFAULT_CHATTIME "0"
#define DEFAULT_USEHUD "0"
#define CATCH_MAPCHANGE_AT "5" // seconds left when mapchange should be catched and blocked
#define CHANGE_ACCESS ADMIN_MAP

new bool:g_mrset,g_timelimit,cvar_tle_enabled, cvar_tle_chattime, cvar_tle_catchat, cvar_tle_usehud,nextmap[65]

#include <dhudmessage>


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


public plugin_init() {
#if defined LICENTA_PRIN_IP_PORT
licenta()
#endif


#if defined LICENTA_PRIN_IP_PORTx
UTIL_CheckServerLicense(IP,SHUT_DOWN);
#endif


#if defined LICENTA_PRIN_EXPIRARE
licenta( );
#endif


  register_plugin("TimeLeft Extender", "0.1a", "prodigy")
  register_dictionary("TimeLeftExtender.txt")
  cvar_tle_enabled  = register_cvar("amx_tle_enabled", TLE_ENABLED)
  cvar_tle_chattime = register_cvar("amx_tle_chattime", DEFAULT_CHATTIME)
  cvar_tle_catchat  = register_cvar("amx_tle_catchat", CATCH_MAPCHANGE_AT) // changes are only registered after a map change
  cvar_tle_usehud   = register_cvar("amx_tle_usehud", DEFAULT_USEHUD) // use hud message?
  //register_event("SendAudio","event_roundEnd","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw")  new
  register_logevent("event_roundEnd", 2, "1=Round_End")  
  register_concmd("amx_changenow", "changeNow", CHANGE_ACCESS, "- changes map immediately to current amx_nextmap")
  register_clcmd("say /changenow", "changeNow", CHANGE_ACCESS, "- changes map immediately to current amx_nextmap")
  register_clcmd("say_team /changenow", "changeNow", CHANGE_ACCESS, "- changes map immediately to current amx_nextmap")
  register_clcmd("say timeleft", "timeleftInfo", 0, "- when timelimit is 0 displays last round")
  register_clcmd("say_team timeleft", "timeleftInfo", 0, "- when timelimit is 0 displays last round")

  g_mrset = false
  set_task(get_pcvar_float(cvar_tle_catchat), "initMapchangeEvent", 901337, "", 0, "d", 1) // Catch mapchange amx_tle_catchat seconds before change
}

public timeleftInfo(id) // de modificat prin cod.. ++ tot
{
  if(g_mrset == true)
  {
    xCoLoR(id, "%L",LANG_PLAYER, "LAST_ROUND_CHAT",DENUMIRE)
    return PLUGIN_HANDLED
  }
  return PLUGIN_CONTINUE
}

public changeNow(id) // de pus motiv??
{
  if(get_pcvar_num(cvar_tle_enabled))
  {
    if(get_user_flags(id)&ADMIN_MAP)
    {
      new name[64]
      get_user_name(id, name, charsmax(name))

		if (GetRandomMap("mapcycle.txt", nextmap,charsmax(nextmap)))	set_cvar_string("amx_nextmap",nextmap)
		else if (GetRandomMap("addons/amxmodx/configs/maps.ini",nextmap,charsmax(nextmap)))	set_cvar_string("amx_nextmap", nextmap)
		else
		{
			//get_cvar_string("amx_nextmap", nextmap, charsmax(nextmap))
			//if(ValidMap(nextmap))	get_cvar_string("amx_nextmap", nextmap, charsmax(nextmap))
			xCoLoR(id, "!v[!n %s!v ]!n Nu am gasit nici o mapa valida...",DENUMIRE)
			return PLUGIN_HANDLED
		}
      /*if(is_map_valid()))*/	get_cvar_string("amx_nextmap", nextmap, charsmax(nextmap))//hm...

      switch(get_cvar_num("amx_show_activity"))
      {
        case 2: xCoLoR(0, "%L", LANG_PLAYER, "ADMIN_CHANGENOW_2", name, nextmap)
        case 1: xCoLoR(0, "%L", LANG_PLAYER, "ADMIN_CHANGENOW_1", nextmap)
      }
      initMapChange()
      return PLUGIN_HANDLED
    }
    return PLUGIN_CONTINUE
  }
  return PLUGIN_CONTINUE
}

public event_roundEnd() // roundend hook
{
  if(g_mrset == true)
  {
    //g_mrset = false  de scos?
    resetTimeLimit()
    initMapChange()
  }
  return PLUGIN_CONTINUE
}

public initMapchangeEvent() // initiate the main event, setting timelimit to 0 etc..
{
  new players[32],num
  get_cvar_string("amx_nextmap", nextmap, charsmax(nextmap))
  get_players(players,num,"ch")

  if(get_pcvar_num(cvar_tle_enabled)&&num>2)
  {
    new m_timeleft = get_timeleft() // ??
    if(m_timeleft <= get_pcvar_num(cvar_tle_catchat) && g_mrset == false)
    {
      xCoLoR(0, "%L", LANG_PLAYER, "LAST_ROUND_CHAT",DENUMIRE)
      xCoLoR(0, "%L", LANG_PLAYER, "LAST_ROUND_NEXT_MAP",DENUMIRE, nextmap)

      remove_task(901337) // if task exisits

      if(get_pcvar_num(cvar_tle_usehud))
      {
        set_dhudmessage(0, 255, 0, -1.0, 0.24, 1, 0.0, 12.0)
        show_dhudmessage(0, "> %L <", LANG_PLAYER, "LAST_ROUND_HUD")
      }
      g_mrset = true
      g_timelimit = get_cvar_num("mp_timelimit")
      set_cvar_num("mp_timelimit", 0)
    }
  }
}

public resetTimeLimit() // reset timelimit to value used before setting it to 0
{
  set_cvar_num("mp_timelimit", g_timelimit)
}

public initMapChange() // initiate the change
{
  message_begin(MSG_ALL, SVC_INTERMISSION) /* Taken from timeleft.sma */ // initiates a mapchange viewing the scores screen
  message_end()                                /*                         */
  set_task(get_pcvar_float(cvar_tle_chattime), "doMapChange", 901338, "", 0, "")
}

public doMapChange() // do the actual change
{
  if(task_exists(901338, 0)) // fara 0
  {
    remove_task(901338);
  }
  get_cvar_string("amx_nextmap", nextmap, charsmax(nextmap))
  server_cmd("changelevel %s", nextmap)
}

GetRandomMap(const szMapFile[ ], szReturn[ ], const iLen)
{
	new iFile = fopen(szMapFile, "rt");
	
	if (!iFile)
	{
		return 0;
	}
	
	new Array:aMaps = ArrayCreate(64);
	new Trie:tArrayPos = TrieCreate( );
	new iTotal = 0;
	
	static szData[128], szMap[64];
	
	while (!feof(iFile))
	{
		fgets(iFile, szData, 127);
		parse(szData, szMap, 63);
		strtolower(szMap);
		
		if (is_map_valid(szMap) && !TrieKeyExists(tArrayPos, szMap))
		{
			ArrayPushString(aMaps, szMap);
			TrieSetCell(tArrayPos, szMap, iTotal);
			
			iTotal++;
		}
	}
	
	TrieDestroy(tArrayPos);
	
	if (!iTotal)
	{
		ArrayDestroy(aMaps);
		
		return 0;
	}
	
	ArrayGetString(aMaps, random(iTotal), szReturn, iLen);
	
	ArrayDestroy(aMaps);
	
	fclose(iFile);
	
	return 1;
}

stock bool:ValidMap(mapname[])
{
	if ( is_map_valid(mapname) )
	{
		return true;
	}
	// If the is_map_valid check failed, check the end of the string
	new len = strlen(mapname) - 4;
	
	// The mapname was too short to possibly house the .bsp extension
	if (len < 0)
	{
		return false;
	}
	if ( equali(mapname[len], ".bsp") )
	{
		// If the ending was .bsp, then cut it off.
		// the string is byref'ed, so this copies back to the loaded text.
		mapname[len] = '^0';
		
		// recheck
		if ( is_map_valid(mapname) )
		{
			return true;
		}
	}
	
	return false;
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
