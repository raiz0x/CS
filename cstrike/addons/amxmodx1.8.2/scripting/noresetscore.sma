#include <amxmodx>
#include <fun>
#include <cstrike>
#include <hamsandwich>

new const Version[] = "1.2"

new Frags[33], Deaths[33], RestartGame
new Float:RestartTime
new HamHook:PlayerSpawn

public plugin_init() {
	register_plugin("No Reset Score", Version, "GlaDiuS")
	
	register_event("TextMsg", "RoundRestart", "a", "2&#Game_w") 
	register_event("HLTV", "NewRound", "a", "1=0", "2=0")
	
	PlayerSpawn = RegisterHam(Ham_Spawn, "player", "FwPlayerSpawn", 1)
}

public NewRound() {
	if(RestartGame) {		
		new Players[32], num, user
		get_players(Players, num, "h")
		for(new i = 0; i < num; i++) {
			user = Players[i] 
			if(is_user_connected(user)) {
				Frags[user] = get_user_frags(user)
				Deaths[user] = cs_get_user_deaths(user)
				if(Frags[user] || Deaths[user])
					RestartTime = get_gametime()
			}
		}
		EnableHamForward(PlayerSpawn)
		RestartGame = false
	}
}	

public FwPlayerSpawn(user) {
	new Float:GameTime = get_gametime()
	
	if(GameTime != RestartTime)
		DisableHamForward(PlayerSpawn)
	
	else {
		if(is_user_alive(user)) {
			set_user_frags(user, Frags[user])
			cs_set_user_deaths(user, Deaths[user])
		}
	}
}

public RoundRestart() {
	RestartGame = true
	client_print(0, print_chat, "the game will restart, but you dont lose your score")
}
