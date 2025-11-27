#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>

#define UPDATE_INTERVAL 0.3
#define TID_TIMER 26642

new g_timer_entid
new Float:g_t_time
new g_HSO

new g_target[33]

public plugin_init()
{
	register_plugin("Target Info on HUD", "1.2", "Sylwester")
	
	register_message(get_user_msgid("StatusValue"), "update_target")
	register_dictionary("furien_gamesites.txt")
	
	g_HSO = CreateHudSyncObj()
	create_timer()
}

public update_target(msg_id, msg_dest, id)
{
	if(get_msg_arg_int(1) == 2)
		g_target[id] = get_msg_arg_int(2)
}

public create_timer()
{
	set_task(0.3, "timer_cycle", TID_TIMER, "", 0, "b")
}

public fwd_Think(Ent)
{
	if(Ent != g_timer_entid)
		return FMRES_IGNORED
		
	g_t_time += UPDATE_INTERVAL
	set_pev(Ent, pev_nextthink, g_t_time)
	timer_cycle()
	return FMRES_IGNORED
}

public timer_cycle()
{
	new iPlayers[32], iNum, id, tar
	get_players(iPlayers, iNum, "ach")
	for(new i, szName[32];i < iNum;i++)
	{
		id = iPlayers[i]
		
		tar = g_target[id]  

		if(pev(id, pev_iuser2) == g_target[id])
			tar = g_target[tar]
			
		if(!tar)
			continue
		
		if(get_user_team(id) == get_user_team(tar))
		{
			get_user_name(tar, szName, charsmax(szName))
			
			set_hudmessage(85,85,85, -1.0, 0.70, 0,0.1,0.2)
			ShowSyncHudMsg(id, g_HSO, "%s^n%L: %d^n%L: %d", szName, id, "HEALTH_HUD_MSG", get_user_health(tar), id, "MONEY_HUD_MSG", cs_get_user_money(tar))
		}
	}
}
