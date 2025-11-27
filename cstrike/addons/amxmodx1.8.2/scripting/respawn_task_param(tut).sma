/* AMXX Mod script.
*
* (c) Copyright 2004, developed by Geesu
* This file is provided as is (no warranties). 
*
* Changelog
* 1.1:
*   Added /respawn command to spawn a player if they're dead
*   Added a public cvar
* 1.0: 
*	Pistols are now given to players when they respawn
*	sv_checkpistols cvar added, if this is set to 0, then players will always spawn with a pistol, otherwise they will only spawn with a pistol when it is not scoutzknivez and not a ka map
*	sv_respawn cvar added, set this to 0 to disable the plugin
*/

new const VERSION[] =	"1.1"

#include <amxmodx>
#include <fun>
#include <cstrike>

#define DISABLE_CS 0

// team ids 
#define UNASSIGNED 0 
#define TS 1 
#define CTS 2 
#define AUTO_TEAM 5 

new bool:g_PistolsDisabled = false

public plugin_init(){

	register_plugin("Respawn Forever", VERSION, "Pimp Daddy (OoTOAoO)")

	register_event("DeathMsg","on_Death","a")
	
	register_cvar("sv_checkpistols", "1")
	register_cvar("sv_respawn", "1")
	register_cvar("respawn_forever_version", VERSION, FCVAR_SERVER)

	register_clcmd("say","on_Chat")
	register_clcmd("say_team","on_Chat")
}

public on_Chat(id)
{
	if ( !get_cvar_num("sv_respawn") )
	{
		client_print(id, print_chat, "* Respawn plugin disabled")
		return PLUGIN_CONTINUE
	}

	new szSaid[32]
	read_args(szSaid, 31) 

	if (equali(szSaid,"^"/respawn^"") || equali(szSaid,"^"respawn^""))
	{
		spawn_func(id)
	}
}

public check_pistols()
{
	/* Determine if we should give players a pistol or not */
	if ( get_cvar_num("sv_checkpistols") )
	{
		set_task(1.0, "check_pistols")
		new mapname[32]
		get_mapname(mapname,31) 
		if ( containi(mapname,"ka_")!=-1 || containi(mapname,"scoutzknivez")!=-1 )
				g_PistolsDisabled = true
	}
}

public spawn_func(id)
{
	new parm[1]
	parm[0]=id
	
	/* Spawn the player twice to avoid the HL engine bug */
	set_task(0.5,"player_spawn",72,parm,1)
	set_task(0.7,"player_spawn",72,parm,1)

	/* Then give them a suit and a knife */
	set_task(0.9,"player_giveitems",72,parm,1)
}

public on_Death()
{
	if ( !get_cvar_num("sv_respawn") )
		return PLUGIN_CONTINUE
	
	new victim_id = read_data(2)
	
	spawn_func( victim_id )

	return PLUGIN_CONTINUE
}

public player_giveitems(parm[1])
{
	new id = parm[0]

	give_item(id, "item_suit")
	give_item(id, "weapon_knife")

	/* Determines if a players should be given a pistol */
	if ( !g_PistolsDisabled )
	{
		new wpnList[32] = 0, number = 0, bool:foundGlock = false, bool:foundUSP = false 
		get_user_weapons(id,wpnList,number)
		
		/* Determine if the player already has a pistol */
		for (new i = 0;i < number;i++)
		{ 
			if (wpnList[i] == CSW_GLOCK18) 
				foundGlock = true 
			if (wpnList[i] == CSW_USP) 
				foundUSP = true 
		}
		
		/* Give a T his/her pistol */
		if ( get_user_team(id)==TS && !foundGlock )
		{
				give_item(id,"weapon_glock18")
				give_item(id,"ammo_9mm")
				give_item(id,"ammo_9mm")
		}
		/* Give a CT his/her pistol */
		else if ( get_user_team(id)==CTS && !foundUSP )
		{
				give_item(id,"weapon_usp")
				give_item(id,"ammo_45acp")
				give_item(id,"ammo_45acp")
		}
	}

	return PLUGIN_CONTINUE
}

public player_spawn(parm[1])
{
	spawn(parm[0])
}
