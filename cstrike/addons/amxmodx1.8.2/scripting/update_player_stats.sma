#include <amxmodx>
#include <amxmisc>
#include <nvault>
#include <zp50_colorchat>

new Float:g_onlinetime[33]
new maxplayers

new Vault
static const VAULTNAME[] = "pinfo"

static const TITLE[] = "PInfo"
static const VERSION[] = "2.0"
static const AUTHOR[] = "OneEyed"
//---------------------------------------------------------------------------------------------------
public plugin_init() 
{
	register_plugin(TITLE, VERSION, AUTHOR)
	register_cvar(TITLE,VERSION,FCVAR_SERVER)	//plugin displays as cvar for HLSW or whatever
	
	maxplayers = get_maxplayers()
	register_clcmd("say","handle_say")
	register_clcmd("say_team","handle_say")
	
	new modname[32]
	get_modname(modname,31)
	/*if(equali("cstrike",modname))	register_event("SendAudio","EndofRound","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw")*/
	if(equali("ns",modname))
		register_event("GameStatus", "EndofRound", "ab", "1=2")
	else if(equali("dod",modname))
		register_event("RoundState","EndofRound","a","1=3","1=4")
}
//---------------------------------------------------------------------------------------------------
/*
public plugin_end() {	//update user on map change but not 2 times
	new Float:gametime = get_gametime()
	for(new id=1;id<=maxplayers;id++)	if( is_user_connected(id)&&!is_user_bot(id) )	updateUser(id, 0, 0, floatround(gametime - g_onlinetime[id]))
}*/
//---------------------------------------------------------------------------------------------------
public EndofRound() {
	new Float:gametime = get_gametime()
	for(new id=1;id<=maxplayers;id++)
		if( is_user_connected(id) && !is_user_bot(id)) {
			updateUser(id, 1, 0, floatround(gametime - g_onlinetime[id]))
			g_onlinetime[id] = gametime
		}
}
//---------------------------------------------------------------------------------------------------
public client_putinserver(id) {
	if(is_user_connected(id) && !is_user_bot(id)) {
		updateUser(id, 0, 1, 0)
		g_onlinetime[id] = get_gametime() - 3.0
	}
}
//---------------------------------------------------------------------------------------------------
public client_disconnect(id) {
	if(!is_user_bot(id))
	{
		updateUser(id, 0, 0, floatround(get_gametime()-g_onlinetime[id]))
		g_onlinetime[id] = 0.0
	}
}
//---------------------------------------------------------------------------------------------------
public handle_say(id) {
	new said[192]
	read_args(said,191)
	remove_quotes(said)
	if( (containi(said, "info") != -1) ) {
		new info[7]
		new name[34]
		new data[2]
		data[0] = id
		
		parse(said, info, 6, name, 33)
		if(equali(info, "info"))
		{
			if(equal(name[0],"")) {
				data[1] = id
				set_task(0.1, "printUserInfo", id, data, 2)
			}
			else
			{
				data[1] = cmd_target(id,name,2) // Don't block access...
				if(data[1]) 
					set_task(0.1, "printUserInfo", id, data, 2)
				else 
					zp_colored_print(id,"^1[^3ZC^1-^3Info^1] ^1- ^4There is no player with that name.")	
			}
		}
	}
	return PLUGIN_CONTINUE
}
//---------------------------------------------------------------------------------------------------
updateUser(id, rounds, connects, time) {
	Vault = nvault_open( VAULTNAME )
	if(Vault == INVALID_HANDLE)	server_print("Error opening nVault file: %s",VAULTNAME)
	else 
	{
		new steamid[32], playerinfo[4][32] // "FIRSTNICK"  "ROUNDS" "CONNECTIONS" "TOTALTIME"
		new key[32], val[511], TimeStamp

		get_user_authid(id,steamid,31)
		formatex(key,32,"%s",steamid)

		if( nvault_lookup(Vault, key, val, 510, TimeStamp) ) 
		{
			parse(val, playerinfo[0], 31, playerinfo[1], 31, playerinfo[2], 31, playerinfo[3], 31)
			new update[511]
			rounds += str_to_num( playerinfo[1] )
			connects += str_to_num( playerinfo[2] )
			time += str_to_num( playerinfo[3] )
			formatex(update,510,"^"%s^" %d %d %d",playerinfo[0], rounds, connects, time)
			nvault_set(Vault, key, update)
		}
		else
		{
			new update[511], name[32]
			get_user_name(id, name, 31)
			formatex(update,510,"^"%s^" 0 1 0",name)
			nvault_set(Vault, key, update)
		}
		nvault_close(Vault)
	}
}
//---------------------------------------------------------------------------------------------------
public printUserInfo(userids[]) 
{ 
	new id = userids[0]
	new playerid = userids[1]
	
	Vault = nvault_open( VAULTNAME )
	if(Vault == INVALID_HANDLE)	server_print("Error opening nVault file: %s",VAULTNAME)
	else 
	{
		new steamid[32], playerinfo[4][64] // "FIRSTNICK" "ROUNDS" "CONNECTIONS" "TOTALTIME"
		new key[32], val[511], TimeStamp//, text[512]
		
		get_user_authid(playerid,steamid,31)
		formatex(key,32,"%s",steamid)
		
		if( nvault_lookup(Vault, key, val, 510, TimeStamp) ) 
		{
			parse(val, playerinfo[0], 63, playerinfo[1], 63, playerinfo[2], 63, playerinfo[3], 63)

			new Float:gametime = get_gametime()
			new onlinetime = floatround( gametime - g_onlinetime[playerid] )
			new ptime = str_to_num(playerinfo[3]) + onlinetime
			new days = ptime / 86400
			new hours = (ptime / 3600) % 24
			new minutes = (ptime / 60) % 60
			new seconds = ptime % 60
			new totaltime[64]
			new sday[16], shr[16], smin[16], ssec[16]
			
			formatex(sday,15,"%d Day%s ",days, (days==1?"s":""))
			formatex(shr,15,"%d Hr%s ",hours, (hours==1?"s":""))
			formatex(smin,15,"%d Min%s ",minutes, (minutes==1?"s":""))
			formatex(ssec,15,"%d Sec%s ",seconds, (seconds==1?"s":""))
			formatex(totaltime, 63, "%s%s%s%s", (days >= 1 ? sday:""), (hours >= 1 ? shr:""), smin, (hours==0 ? ssec:""))
			//zp_colored_print( id, "^4 ^1================ ^3[ZC] CONNECT INFO ^4%s ^1================", playerinfo[0]);		
			zp_colored_print( id, "^1[^3ZC^1-^3Info^1] ^1[ ^1NAME: ^4%s ^1][ ^3CONNECTS^1: ^4%s ^1][ ^3ROUNDS^1: ^4%s ^1][ ^3TIME PLAYED^1: ^4%s ^1]",playerinfo[0],playerinfo[2],playerinfo[1],totaltime);
			//client_print(id,print_chat,text)
			
			nvault_close(Vault)
			
			updateUser(playerid, 0, 0, onlinetime)
			g_onlinetime[playerid] = gametime
		}
	}
	return PLUGIN_HANDLED
}
