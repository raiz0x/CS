#include <amxmodx>
#include <hamsandwich>
#include <engine>

#define CHECK_FREQ 10

new g_oldangles[33][3],g_afktime[33],bool:g_spawned[33] = {true, ...}

public plugin_init()
{
	register_cvar("mp_afktime", "45")	// Dupa cat timp va da slay jucatorilor
	set_task(float(CHECK_FREQ),"checkPlayers",_,_,_,"b")
	RegisterHam(Ham_Spawn, "player", "e_Spawn", 1);
}

public checkPlayers() {
	for (new i = 0; i <= get_maxplayers(); i++) {
		if (is_user_alive(i) && !is_user_bot(i)) {
			new newangle[3]
			get_user_origin(i, newangle)

			if ( (newangle[0] == g_oldangles[i][0] && newangle[1] == g_oldangles[i][1] && newangle[2] == g_oldangles[i][2])) {
				g_afktime[i] += CHECK_FREQ
				check_afktime(i)
				} else {
				g_oldangles[i][0] = newangle[0]
				g_oldangles[i][1] = newangle[1]
				g_oldangles[i][2] = newangle[2]
				g_afktime[i] = 0
			}
		}
	}
	return PLUGIN_HANDLED
}

check_afktime(id) {
	if(!is_user_alive(id))	return
	if (g_afktime[id] >= get_cvar_num("mp_afktime"))	user_kill(id,1);
}

public client_disconnect(id) {
	if(!is_user_bot(id))
	{
	g_afktime[id] = 0
	g_spawned[id]=false
	}
}

public client_putinserver(id) {
	if(is_user_connected(id)&&!is_user_bot(id))
	{
	g_afktime[id] = 0
	g_spawned[id]=false
	}
}

public e_Spawn(id) {
	if(is_user_alive(id)&&!is_user_bot(id)&&get_user_team(id)!=3)
	{
	g_spawned[id] = true
	get_user_origin(id, g_oldangles[id])
	}
}
