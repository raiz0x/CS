#if defined _nightcrawler
  #endinput
#endif
#define _nightcrawler 

#include <cstrike> 

enum _:ItemRestriction {
	Night,
	AntiNight
}  

new CsTeams:g_iNightTeam = CS_TEAM_T,
	CsTeams:g_iAntiNightTeam = CS_TEAM_CT,
	TeamCH = 0

public team_change2() {
	switch(TeamCH) {
		case 0: return false 
		case 1: return true
		default: return false
	}
	return false
} 

__get_user_team(playerid) {
	new CsTeams:iTeam = cs_get_user_team(playerid)  

	if(iTeam == g_iNightTeam) return Night 
	else if(iTeam == g_iAntiNightTeam) return AntiNight
	else return -1

	return -1
}   

native register_night_class(name[], desc[], hp, speed, Float:grav)
