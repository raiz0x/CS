/*

* Bomba a fost stearsa.
* Acum tero pot fii invizibili atata timp cat nu isi iau dmg sau nu au knife in mana // credite ConnorMcLeod
* Am facut team swap
* Acum night au viteza de 1000
* Acum cand un night primeste dmg nu mai este inv, dupa 2 secunde daca nu isi primeste iar dmg atunci o sa fie iar inv
* Acum nu se mai poate cumpara nimic din buy
* Am sters viteza si gravitatia (cele default) pentru ca vor fi clase
*
*


*/
#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>
#include <fun>
#include <engine> 

#include <nightcrawler>

#define MAX_PLAYERS 32

new const   PLUGIN[ ] = "Nightcrawler Main",
			VERSION[ ] = "1.0.1",
			AUTHOR[ ] = "Diversity" 

new g_iPickUp = 2

public plugin_init() {
	
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Spawn, "player", "OnPlayerSpawn", 1)
	RegisterHam(Ham_Spawn, "hostage_entity", "Hostage_Spawn")
	RegisterHam(Ham_TakeDamage, "player", "OnPlayerTakeDamage", 1) 
	RegisterHam(Ham_Touch, "weaponbox", "GroundWeapon_Touch")
	RegisterHam(Ham_Touch, "armoury_entity", "GroundWeapon_Touch")
	RegisterHam(Ham_Touch, "weapon_shield", "GroundWeapon_Touch")

	register_event("CurWeapon", "CurWeapon", "be", "1=1") 
	register_event("HLTV", "NewRound", "a", "1=0", "2=0")

	register_message(get_user_msgid("ScoreAttrib"), "Message_ScoreAttrib")  
	register_message(get_user_msgid("SendAudio"), "Message_SendAudio")   

	new enT = create_entity("info_target")
	set_pev(enT, pev_classname, "check_speed")
	set_pev(enT, pev_nextthink, get_gametime() + 0.1)
	register_think("check_speed", "Set_Night_INV")  
}

public plugin_precache()  { 
    new Entity = create_entity("info_map_parameters")
    
    DispatchKeyValue(Entity, "buying", "3")
    DispatchSpawn(Entity)
} 

public pfn_keyvalue(Entity)   { 
    new ClassName[20], 
    	Anyf[2]
    copy_keyvalue(ClassName, charsmax(ClassName), Anyf, charsmax(Anyf), Anyf, charsmax(Anyf))
    
    if(equal(ClassName, "info_map_parameters")) { 
        remove_entity(Entity)
        return PLUGIN_HANDLED
    } 
    
    return PLUGIN_CONTINUE
} 

public OnPlayerSpawn(playerid) {
	if(!is_user_connected(playerid)) return 

	strip_user_weapons_ex(playerid)

	if(__get_user_team(playerid) == Night) {
		set_user_rendering(playerid, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0)
		set_user_footsteps(playerid, 1) 
	} else {
		set_user_rendering(playerid, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)	
		set_user_footsteps(playerid, 0)
		set_user_gravity(playerid, 1.0)
	} 
}

public OnPlayerTakeDamage(iVictim, iInflictor, iAttacker, Float:flDamage, iBits) {
	if(is_user_connected(iAttacker) && is_user_connected(iVictim) && __get_user_team(iVictim) == Night) {
		remove_task(10000 + iVictim)
		
		set_user_rendering(iVictim, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)	
		
		set_task(2.0, "SetInv", iVictim + 10000) 
	}
}

public SetInv(asdasd) {
	new playerid = asdasd-10000
	set_user_rendering(playerid, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0)
} 

public GroundWeapon_Touch(iWeapon, playerid) {
	if(!is_user_connected(playerid) || !is_user_alive(playerid)) return HAM_SUPERCEDE
	if(!g_iPickUp) {
		remove_entity(iWeapon)
		return HAM_SUPERCEDE
	} 

	new iTeam = __get_user_team(playerid)
	if((iTeam == -1) ||	(iTeam == Night && g_iPickUp != 1) || (iTeam == AntiNight && g_iPickUp != 2)) return HAM_SUPERCEDE
	
	return HAM_IGNORED
}   

public NewRound() {
	TeamCH = 0
}

public Message_ScoreAttrib() {
	new iFlags = get_msg_arg_int(2)
	if(iFlags & (1<<1)) {
		iFlags &= ~(1<<1)
		set_msg_arg_int(2, 0, iFlags)
	}
} 

public Message_SendAudio(iMsgId, iMsgDest, playerid) {
	if(playerid) return 

	new iPlayers[32], 
	 	iNum,  
	 	iPlayer 

	new szSound[14]
	get_msg_arg_string(2, szSound, charsmax(szSound))
	get_players(iPlayers, iNum) 

	if(equal(szSound, "%!MRAD_ctwin")) { 
		for(new i = 0; i < iNum; i++) {
			iPlayer = iPlayers[i]
			switch(__get_user_team(iPlayer)) {
				case AntiNight: cs_set_user_team(iPlayer, g_iNightTeam) 
				case Night: cs_set_user_team(iPlayer, g_iAntiNightTeam)
			}
			TeamCH = 1 
		} 
	}  
}  

public Hostage_Spawn(iHostage) {
	remove_entity(iHostage)
	return HAM_SUPERCEDE
} 

public CurWeapon(playerid) {

} 

public Set_Night_INV(iEnt) {
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1)

	new iPlayers[MAX_PLAYERS], 
		iNum, 
		playerid

	get_players(iPlayers, iNum, "ae", g_iNightTeam == CS_TEAM_T ? "TERRORIST" : "CT")

	for(new i; i<iNum; i++) {
		playerid = iPlayers[i]
		if(get_user_weapon(playerid) == CSW_KNIFE) set_user_rendering(playerid, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0) 
		else set_user_rendering(playerid, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
	}
}

strip_user_weapons_ex(playerid) {
	strip_user_weapons(playerid) 
	give_item(playerid, "weapon_knife")
}
