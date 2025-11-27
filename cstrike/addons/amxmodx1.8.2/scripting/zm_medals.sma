#include <amxmodx> 
#include <amxmisc> 
#include <zombieplague> 
#include <nvault>

//native for inf bombs from base

#pragma tabsize 0

#define PLUGIN "[ZP] Addon: CSO Medal" 
#define VERSION "1.0" 
#define AUTHOR "Dias" 

// Medal: vanatorul de zombii 
#define ZH_MAX_KILL 750
new g_zh_kill[33]
#define REWARD1 4200

// Medal: maestrul in supravetuiri 
#define MS_MAX_ROUND 400
new g_ms_round[33]
#define REWARD2 4800

// Medal: zombii Terminator 
#define ZT_MAX_INFECT 320 
new g_zt_infect[33]
#define REWARD3 2500

// Medal: vanatorul de nemessis
#define NH_MAX_KILL 170 
new g_nh_kill[33]
#define REWARD4 1800

// Medal: vanatorul de eroii
#define HH_MAX_KILL 220 
new g_hh_kill[33]
#define REWARD5 3700

new g_nvault_zh, g_nvault_ms, g_nvault_zt, g_nvault_nh, g_nvault_hh



// Medal: TIMP JUCAT
#define MAX_TP 400
new g_max_tp[33],g_nvault_tp
#define TP_AMMO 1500

// Medal: DESTROY NEMESIS WITH HS
#define NEM_HS 300
new g_nem_hs[33],g_nvault_nhs
#define NHS_AMMO 3500

// Medal: RUNDE JUCATE
#define MAX_R 2500
new g_max_r[33],g_nvault_r
#define MR_AMMO 15000

// Medal: BOMBE PENTRU INFECTIE
#define MAX_B 300
native ch_in(id)
new g_max_bmbs[33],g_nvault_b
#define MB_AMMO 800

// Medal: KILL LAST HUMAN
#define MAX_LH 50
new g_lh[33],g_nvault_lh
#define ML_AMMO 1010



public plugin_init() 
{ 
	register_plugin(PLUGIN, VERSION, AUTHOR) 
	
	g_nvault_zh = nvault_open("cso_medal_zh") 
	g_nvault_ms = nvault_open("cso_medal_ms") 
	g_nvault_zt = nvault_open("cso_medal_zt") 
	g_nvault_nh = nvault_open("cso_medal_nh") 
	g_nvault_hh = nvault_open("cso_medal_hh") 
	
	register_event("HLTV", "event_newround", "a", "1=0", "2=0")
	register_event("DeathMsg", "event_death", "a")
	register_event("TextMsg","event_round_end","a","2=#Game_Commencing","2=#Game_will_restart_in")

	register_logevent("event_round_end", 2, "1=Round_End")
	
	register_clcmd("say /medalii", "show_medal")
	register_clcmd("say_team /medalii", "show_medal")



	g_nvault_tp = nvault_open("cso_medal_tp")
	g_nvault_nhs = nvault_open("cso_medal_nhs")
	g_nvault_r = nvault_open("cso_medal_r")
	g_nvault_b = nvault_open("cso_medal_b")
	g_nvault_lh = nvault_open("cso_medal_lh")
} 

public plugin_end() 
{ 
	nvault_close(g_nvault_zh)
	nvault_close(g_nvault_ms)
	nvault_close(g_nvault_zt)
	nvault_close(g_nvault_nh)
	nvault_close(g_nvault_hh)



	nvault_close(g_nvault_tp)
	nvault_close(g_nvault_nhs)
	nvault_close(g_nvault_r)
	nvault_close(g_nvault_b)
	nvault_close(g_nvault_lh)
} 

public client_putinserver(id) 
{ 
	load_medal_zh(id)
	load_medal_ms(id)
	load_medal_zt(id)
	load_medal_nh(id)
	load_medal_hh(id)



	load_medal_tp(id)
	load_medal_nhs(id)
	load_medal_r(id)
	load_medal_b(id)
	load_medal_lh(id)


}


public count(id) {
	if(g_max_tp[id] == MAX_TP)
	{
		/*if(task_exists(id))	remove_taks(id)
		if(task_exists(id+60))	remove_taks(id+60)
		if(task_exists(id+0x436))	remove_taks(id+0x436)*/
				new Name[32] 
				get_user_name(id, Name, sizeof(Name)) 
				
				client_printcolor(0, "!y[ZP MEDAL] !gFelicitari! !y%s !ga Terminat medalia !t[TIMP JUCAT] !gsi a primit !y%d !gde AMMO", Name, TP_AMMO) 
				zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + TP_AMMO) 

		return
	}

	if(g_max_tp[id] > MAX_TP)	return

	g_max_tp[id]++

			save_medal_tp(id)
}



public client_disconnect(id) 
{ 
	save_medal_zh(id)
	save_medal_ms(id)
	save_medal_zt(id)
	save_medal_nh(id)
	save_medal_hh(id)



	save_medal_tp(id)
	save_medal_nhs(id)
	save_medal_r(id)
	save_medal_b(id)
	save_medal_lh(id)
} 

public event_newround()
{
	for(new id=1;id<get_maxplayers();id++)
	{
		if(is_user_connected(id))
		{
if(g_max_r[id]==MAX_R)
{
				new Name[32]
				get_user_name(id, Name, sizeof(Name)) 
				
				client_printcolor(0, "!y[ZP MEDAL] !gFelicitari! !y%s !ga Terminat medalia !t[RUNDE JUCATE] !gsi a primit !y%d !gde AMMO", Name, MR_AMMO) 
				zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + MR_AMMO)

return
}

if(g_max_r[id]>=MAX_R)	return

			g_max_r[id]++

			save_medal_r(id)
		}
	}

	client_printcolor(0, "!y[!gzp.freakz.ro!y] !gScrie !t/medalii !gpentru a deschide meniul medalilor!")
}

public show_medal(id) 
{ 
	static menu 
	menu = menu_create("Medals\r", "medal_menu_handle1") 
	
	add_zombie_hunter(id, menu)
	add_master_survival(id, menu)
	add_zombie_terminator(id, menu)
	add_nemesis_hunter(id, menu)
	add_hero_hunter(id, menu)



	add_time_played(id, menu)
	add_nem_hs(id, menu)
	add_max_rounds(id, menu)
	add_inf_bmbs(id, menu)
	add_lh(id, menu)


	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL) 
	menu_display(id, menu, 0) 
} 

public load_medal_zh(id) 
{ 
	new vaultkey[40], vaultdata[13] 
	
	new Name[64]; 
	get_user_name(id, Name, 32) 
	
	formatex(vaultkey, sizeof(vaultkey), "__%s__", Name) 
	
	nvault_get(g_nvault_zh, vaultkey, vaultdata, 12); 
	
	g_zh_kill[id] = str_to_num(vaultdata) 
	
	/* 
	// Build customization file path 
	static path[64], medal_file[128] 
	get_configsdir(path, charsmax(path)) 
	
	// Set up some vars to hold parsing info 
	new linedata[1024], key[64], value[960] 
	
	// Open customization file for reading 
	new file, name2[32] 
	get_user_name(id, name2, sizeof(name2)) 
	
	formatex(medal_file, sizeof(medal_file), "%s/%s/%s.cfg", path, medal_folder, name2) 
	
	// File not present 
	if (!file_exists(path)) 
	{ 
		file = fopen(medal_file, "wt") 
	} 
	
	file = fopen(medal_file, "rt") 
	
	while (file && !feof(file)) 
	{ 
		// Read one line at a time 
		fgets(file, linedata, charsmax(linedata)) 
		
		// Blank line or comment 
		if (!linedata[0] || linedata[0] == ';') continue; 
		
		// Get key and value(s) 
		strtok(linedata, key, charsmax(key), value, charsmax(value), '=') 
		
		// Trim spaces 
		trim(key) 
		trim(value) 
		
		if (equal(key, "ZOMBIE_HUNTER")) 
			g_zh_kill[id] = str_to_num(value) 
		else if (equal(key, "MASTER_SURVIVAL")) 
			g_ms_round[id] = str_to_num(value) 
		else if (equal(key, "ZOMBIE_TERMINATOR")) 
			g_zt_infect[id] = str_to_num(value) 
		else if (equal(key, "NEMESIS_HUNTER")) 
			g_nh_kill[id] = str_to_num(value) 
		else if (equal(key, "HERO_HUNTER")) 
			g_hh_kill[id] = str_to_num(value) 
	}*/ 
} 

public load_medal_ms(id) 
{ 
	new vaultkey[40], vaultdata[13] 
	
	new Name[64]; 
	get_user_name(id, Name, 32) 
	
	formatex(vaultkey, sizeof(vaultkey), "__%s__", Name) 
	
	nvault_get(g_nvault_ms, vaultkey, vaultdata, 12); 
	
	g_ms_round[id] = str_to_num(vaultdata) 
} 

public load_medal_zt(id) 
{ 
	new vaultkey[40], vaultdata[13] 
	
	new Name[64]; 
	get_user_name(id, Name, 32) 
	
	formatex(vaultkey, sizeof(vaultkey), "__%s__", Name) 
	
	nvault_get(g_nvault_zt, vaultkey, vaultdata, 12); 
	
	g_zt_infect[id] = str_to_num(vaultdata) 
} 

public load_medal_nh(id) 
{ 
	new vaultkey[40], vaultdata[13] 
	
	new Name[64]; 
	get_user_name(id, Name, 32) 
	
	formatex(vaultkey, sizeof(vaultkey), "__%s__", Name) 
	
	nvault_get(g_nvault_nh, vaultkey, vaultdata, 12); 
	
	g_nh_kill[id] = str_to_num(vaultdata) 
} 

public load_medal_hh(id)
{
	new vaultkey[40], vaultdata[13]
	
	new Name[64];
	get_user_name(id, Name, 32)
	
	formatex(vaultkey, sizeof(vaultkey), "__%s__", Name)
	
	nvault_get(g_nvault_hh, vaultkey, vaultdata, 12);
	
	g_hh_kill[id] = str_to_num(vaultdata)
}




public load_medal_tp(id)
{
	new vaultkey[40], vaultdata[13],Name[32];
	get_user_name(id, Name, 31)
	
	formatex(vaultkey, sizeof(vaultkey), "__%s__", Name)
	nvault_get(g_nvault_tp, vaultkey, vaultdata, 12);
	
	g_max_tp[id] = str_to_num(vaultdata)

	if(g_max_tp[id]<MAX_TP)	set_task(60.0,"count",id,_,_,"b")
}

public load_medal_nhs(id)
{
	new vaultkey[40], vaultdata[13],Name[32];
	get_user_name(id, Name, 31)
	
	formatex(vaultkey, sizeof(vaultkey), "__%s__", Name)
	nvault_get(g_nvault_nhs, vaultkey, vaultdata, 12);
	
	g_nem_hs[id] = str_to_num(vaultdata)
}

public load_medal_r(id)
{
	new vaultkey[40], vaultdata[13],Name[32];
	get_user_name(id, Name, 31)
	
	formatex(vaultkey, sizeof(vaultkey), "__%s__", Name)
	nvault_get(g_nvault_r, vaultkey, vaultdata, 12);
	
	g_max_r[id] = str_to_num(vaultdata)
}

public load_medal_b(id)
{
	new vaultkey[40], vaultdata[13],Name[32];
	get_user_name(id, Name, 31)
	
	formatex(vaultkey, sizeof(vaultkey), "__%s__", Name)
	nvault_get(g_nvault_b, vaultkey, vaultdata, 12);
	
	g_max_bmbs[id] = str_to_num(vaultdata)
}

public load_medal_lh(id)
{
	new vaultkey[40], vaultdata[13],Name[32];
	get_user_name(id, Name, 31)
	
	formatex(vaultkey, sizeof(vaultkey), "__%s__", Name)
	nvault_get(g_nvault_lh, vaultkey, vaultdata, 12);
	
	g_lh[id] = str_to_num(vaultdata)
}






// Save Data 
public save_medal_zh(id) 
{ 
	new vaultkey[40], vaultdata[13]; 
	
	new Name[33]; 
	get_user_name(id, Name, 32); 
	
	formatex(vaultkey, 39, "__%s__", Name); 
	formatex(vaultdata, 12, "%i", g_zh_kill[id]); 
	
	nvault_set(g_nvault_zh, vaultkey, vaultdata); 
} 

public save_medal_ms(id) 
{ 
	new vaultkey[40], vaultdata[13]; 
	
	new Name[33]; 
	get_user_name(id, Name, 32); 
	
	formatex(vaultkey, 39, "__%s__", Name); 
	formatex(vaultdata, 12, "%i", g_ms_round[id]); 
	
	nvault_set(g_nvault_ms, vaultkey, vaultdata); 
} 

public save_medal_zt(id) 
{ 
	new vaultkey[40], vaultdata[13]; 
	
	new Name[33]; 
	get_user_name(id, Name, 32); 
	
	formatex(vaultkey, 39, "__%s__", Name); 
	formatex(vaultdata, 12, "%i", g_zt_infect[id]); 
	
	nvault_set(g_nvault_zt, vaultkey, vaultdata); 
} 

public save_medal_nh(id) 
{ 
	new vaultkey[40], vaultdata[13]; 
	
	new Name[33]; 
	get_user_name(id, Name, 32); 
	
	formatex(vaultkey, 39, "__%s__", Name); 
	formatex(vaultdata, 12, "%i", g_nh_kill[id]); 
	
	nvault_set(g_nvault_nh, vaultkey, vaultdata); 
} 

public save_medal_hh(id)
{
	new vaultkey[40], vaultdata[13];
	
	new Name[33];
	get_user_name(id, Name, 32);
	
	formatex(vaultkey, 39, "__%s__", Name);
	formatex(vaultdata, 12, "%i", g_hh_kill[id]);
	
	nvault_set(g_nvault_hh, vaultkey, vaultdata);
}




public save_medal_tp(id)
{
	new vaultkey[40], vaultdata[13],Name[32];
	get_user_name(id, Name, 31);
	
	formatex(vaultkey, 39, "__%s__", Name);
	formatex(vaultdata, 12, "%d", g_max_tp[id]);
	
	nvault_set(g_nvault_tp, vaultkey, vaultdata);

	if(task_exists(id))	remove_task(id)
		if(task_exists(id+0x436))
			remove_task(id+0x436)
}

public save_medal_nhs(id)
{
	new vaultkey[40], vaultdata[13],Name[32];
	get_user_name(id, Name, 31);
	
	formatex(vaultkey, 39, "__%s__", Name);
	formatex(vaultdata, 12, "%d", g_nem_hs[id]);
	
	nvault_set(g_nvault_nhs, vaultkey, vaultdata);
}

public save_medal_r(id)
{
	new vaultkey[40], vaultdata[13],Name[32];
	get_user_name(id, Name, 31);
	
	formatex(vaultkey, 39, "__%s__", Name);
	formatex(vaultdata, 12, "%d", g_max_r[id]);
	
	nvault_set(g_nvault_r, vaultkey, vaultdata);
}

public save_medal_b(id)
{
	new vaultkey[40], vaultdata[13],Name[32];
	get_user_name(id, Name, 31);
	
	formatex(vaultkey, 39, "__%s__", Name);
	formatex(vaultdata, 12, "%d", ch_in(id));
	
	nvault_set(g_nvault_b, vaultkey, vaultdata);
}

public save_medal_lh(id)
{
	new vaultkey[40], vaultdata[13],Name[32];
	get_user_name(id, Name, 31);
	
	formatex(vaultkey, 39, "__%s__", Name);
	formatex(vaultdata, 12, "%d", g_lh[id]);
	
	nvault_set(g_nvault_lh, vaultkey, vaultdata);
}






public zp_user_infected_post(victim, attacker) 
{ 
	if(is_user_alive(attacker) && zp_get_user_zombie(attacker)) 
	{ 
		if(g_zt_infect[attacker] < ZT_MAX_INFECT) 
		{ 
			g_zt_infect[attacker]++ 
			
			if(g_zt_infect[attacker] >= ZT_MAX_INFECT) 
			{ 
				static Name[64] 
				get_user_name(attacker, Name, sizeof(Name)) 
				
				client_printcolor(0, "!y[ZP MEDAL] !gFelicitari! !y%s !gai Terminat medalia !t[Zombii Infector] !gsi ai primit !y%d !gde Ammo.", Name, REWARD3) 
				zp_set_user_ammo_packs(attacker, zp_get_user_ammo_packs(attacker) + REWARD3) 
			} 
			
			save_medal_zt(attacker) 
		} 
	} 
} 

public event_death() 
{ 
	static attacker, victim,hs
	attacker = read_data(1) 
	victim = read_data(2)
	hs=read_data(3)
	
	if(zp_get_user_zombie(victim) && !zp_get_user_zombie(attacker)) 
	{ 
		if(g_zh_kill[attacker] < ZH_MAX_KILL) 
		{ 
			g_zh_kill[attacker]++ 
			
			if(g_zh_kill[attacker] >= ZH_MAX_KILL) 
			{ 
				static Name[64] 
				get_user_name(attacker, Name, sizeof(Name)) 
				
				client_printcolor(0, "!y[ZP MEDAL] !gFelicitari! !y%s !gai Terminat medalia !g[Vanatorul de Zombii] !gsi ai primit !y%d !gde Ammo.", Name, REWARD1) 
				zp_set_user_ammo_packs(attacker, zp_get_user_ammo_packs(attacker) + REWARD1) 
			} 
			
			save_medal_zh(attacker) 
		} 
	}
	else if(zp_get_user_nemesis(victim) && !zp_get_user_zombie(attacker) && !zp_get_user_nemesis(attacker))
	{ 
		if(g_nh_kill[attacker] < NH_MAX_KILL) 
		{ 
			g_nh_kill[attacker]++ 
			
			if(g_nh_kill[attacker] >= NH_MAX_KILL) 
			{ 
				static Name[64] 
				get_user_name(attacker, Name, sizeof(Name)) 
				
				client_printcolor(0, "!y[ZP MEDAL] !gFelicitari! !y%s !gai Terminat medalia !g[Vanatorul de Nemessis] !gsi ai primit !y%d !gde Ammo.", Name, REWARD4) 
				zp_set_user_ammo_packs(attacker, zp_get_user_ammo_packs(attacker) + REWARD4) 
			} 
			
			save_medal_nh(attacker) 
		} 
	}
	else if(zp_get_user_survivor(victim) && zp_get_user_zombie(attacker) || zp_get_user_nemesis(attacker))
	{ 
		if(g_hh_kill[attacker] < HH_MAX_KILL) 
		{ 
			g_hh_kill[attacker]++ 
			
			if(g_hh_kill[attacker] >= HH_MAX_KILL) 
			{ 
				static Name[64] 
				get_user_name(attacker, Name, sizeof(Name)) 
				
				client_printcolor(0, "!y[ZP MEDAL] !gFelicitari! !y%s !gai Terminat medalia !g[Vanatorul de Eroi] !gsi ai primit !y%d !gde Ammo.", Name, REWARD5) 
				zp_set_user_ammo_packs(attacker, zp_get_user_ammo_packs(attacker) + REWARD5) 
			} 
			save_medal_nh(attacker) 
		}
	}


if(!zp_get_user_zombie(attacker)&&zp_get_user_nemesis(victim)&&hs)
{
if(g_nem_hs[attacker]==NEM_HS)
{
				new Name[32] 
				get_user_name(attacker, Name, sizeof(Name)) 
				
				client_printcolor(0, "!y[ZP MEDAL] !gFelicitari! !y%s !ga Terminat medalia !t[NEMESIS HEADSHOTS] !gsi a primit !y%d !gde AMMO", Name, NHS_AMMO) 
				zp_set_user_ammo_packs(attacker, zp_get_user_ammo_packs(attacker) + NHS_AMMO) 

return
}
if(g_nem_hs[attacker]>NEM_HS)	return

g_nem_hs[attacker]++
save_medal_nhs(attacker)
}



if(zp_get_user_zombie(attacker)&&!zp_get_user_zombie(victim)&&zp_get_user_last_human(victim))
{
if(g_lh[attacker]==MAX_LH)
{
				new Name[32] 
				get_user_name(attacker, Name, sizeof(Name)) 
				
				client_printcolor(0, "!y[ZP MEDAL] !gFelicitari! !y%s !ga Terminat medalia !t[LAST HUMAN] !gsi a primit !y%d !gde AMMO", Name, ML_AMMO) 
				zp_set_user_ammo_packs(attacker, zp_get_user_ammo_packs(attacker) + ML_AMMO) 

return
}
if(g_lh[attacker]>MAX_LH)	return

g_lh[attacker]++
save_medal_lh(attacker)
}



} 

public event_round_end(id) 
{ 
	if(is_user_alive(id) && !zp_get_user_zombie(id)) 
	{ 
		if(g_ms_round[id] < MS_MAX_ROUND) 
		{ 
			g_ms_round[id]++ 
			
			if(g_ms_round[id] >= MS_MAX_ROUND) 
			{ 
				static Name[64] 
				get_user_name(id, Name, sizeof(Name)) 
				
				client_printcolor(0, "!y[ZP MEDAL] !gFelicitari! !y%s !gai Terminat medalia !g[Maestru in Supravetuiri] !gsi ai primit !y%d !gde Ammo.", Name, REWARD2) 
				zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + REWARD2) 
			} 
			
			save_medal_ms(id) 
		} 
	}


if(is_user_connected(id))
{
	if(g_max_bmbs[id] == MAX_B)
	{
				new Name[32] 
				get_user_name(id, Name, sizeof(Name)) 
				
				client_printcolor(0, "!y[ZP MEDAL] !gFelicitari! !y%s !ga Terminat medalia !t[INFECTION BOMB] !gsi a primit !y%d !gde AMMO", Name, MB_AMMO) 
				zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + MB_AMMO) 

		return
	}

	if(g_max_bmbs[id] > MAX_B)	return

	g_max_bmbs[id]++

			save_medal_b(id)
}

} 

// Medal: Vanatorul de Zombii
public add_zombie_hunter(id, menu)
{ 
	static temp_string[1024]
	
	if(g_zh_kill[id] < ZH_MAX_KILL) 
		formatex(temp_string, sizeof(temp_string), "\y--Vanatorul de Zombii--\w^nTrebuie sa omori %i zombi pentru a primi medalia Vanatorul de Zombii!\r %i/%i",ZH_MAX_KILL, g_zh_kill[id], ZH_MAX_KILL) 
	else 
		formatex(temp_string, sizeof(temp_string), "\y[Vanatorul de Zombii] \d[Complet]")

	menu_additem(menu, temp_string, "0") 
} 
// End Of Medal: Vanatorul de Zombii 

// Medal: Maestru in Supravetuiri
public add_master_survival(id, menu) 
{ 
	static temp_string[1024] 
	
	if(g_ms_round[id] < MS_MAX_ROUND) 
		formatex(temp_string, sizeof(temp_string), "\y--Maestru in Supravetuiri--\w^nTrebuie sa supravietuiesti %i runde pentru a primi medalia Maestru in Supravetuiri!\r %i/%i",MS_MAX_ROUND, g_ms_round[id], MS_MAX_ROUND) 
	else 
		formatex(temp_string, sizeof(temp_string), "\y[Maestru in Supravetuiri] \d[Complet]") 
	menu_additem(menu, temp_string, "1") 
} 
// End Of Medal: Maestru in Supravetuiri 

// Medal: Zombii Infector 
public add_zombie_terminator(id, menu) 
{ 
	static temp_string[1024] 
	
	if(g_zt_infect[id] < ZT_MAX_INFECT) 
		formatex(temp_string, sizeof(temp_string), "\y--Zombii Infector--\w^nTrebuie sa infectezi %i oameni pentru a primi medalia Zombii Infector!\r %i/%i",ZT_MAX_INFECT, g_zt_infect[id], ZT_MAX_INFECT) 
	else 
		formatex(temp_string, sizeof(temp_string), "\y[Zombii Infector] \d[Complet]") 
	menu_additem(menu, temp_string, "2") 
} 
// End Of Medal: Zombii Infector 

// Medal: Vanatorul de Nemessis 
public add_nemesis_hunter(id, menu) 
{ 
	static temp_string[1024] 
	
	if(g_nh_kill[id] < NH_MAX_KILL) 
		formatex(temp_string, sizeof(temp_string), "\y--Vanatorul de Nemessis--\w^nTrebuie sa omori %i nemesis pentru a primi medalia Vanatorul de Nemessis!\r %i/%i",NH_MAX_KILL, g_nh_kill[id], NH_MAX_KILL) 
	else 
		formatex(temp_string, sizeof(temp_string), "\y[Vanatorul de Nemessis] \d[Complet]") 
	menu_additem(menu, temp_string, "3") 
} 
// End Of Medal: Vanatorul de Nemessis

// Medal: Vanatorul de Eroi
public add_hero_hunter(id, menu) 
{ 
	static temp_string[1024] 
	
	if(g_hh_kill[id] < HH_MAX_KILL) 
		formatex(temp_string, sizeof(temp_string), "\y--Vanatorul de Eroi--\w^nTrebuie sa omori %i eroi pentru a primi medalia Vanatorul de Eroi!\r %i/%i",HH_MAX_KILL, g_hh_kill[id], HH_MAX_KILL) 
	else 
		formatex(temp_string, sizeof(temp_string), "\y[Vanatorul de Eroi] \d[Complet]") 
	menu_additem(menu, temp_string, "4") 
} 
// End Of Medal: Vanatorul de Eroi



public add_time_played(id, menu) 
{ 
	new temp_string[1024] 
	
	if(g_max_tp[id] < MAX_TP) 
		format(temp_string, sizeof(temp_string), "\y--Timp jucat--\w^nTrebuie sa joci %d minute pe server\r %d/%d",MAX_TP, g_max_tp[id], MAX_TP) 
	else 
		format(temp_string, sizeof(temp_string), "\y[Timp jucat] \d[Complet]")
		
	menu_additem(menu, temp_string, "5") 
}

public add_nem_hs(id, menu) 
{ 
	new temp_string[1024] 
	
	if(g_nem_hs[id] < NEM_HS) 
		format(temp_string, sizeof(temp_string), "\y--Nemesis Headshots--\w^nTrebuie sa omori %d nemesisi prin HS\r %d/%d",NEM_HS, g_nem_hs[id], NEM_HS) 
	else 
		format(temp_string, sizeof(temp_string), "\y[Nemesis Headshots] \d[Complet]")
		
	menu_additem(menu, temp_string, "6") 
}

public add_max_rounds(id, menu) 
{ 
	new temp_string[1024] 
	
	if(g_max_r[id] < MAX_R) 
		format(temp_string, sizeof(temp_string), "\y--Runde jucate--\w^nTrebuie sa joci %d runde pe server\r %d/%d",MAX_R, g_max_r[id], MAX_R) 
	else 
		format(temp_string, sizeof(temp_string), "\y[Runde jucate] \d[Complet]")
	
	menu_additem(menu, temp_string, "7") 
}

public add_inf_bmbs(id, menu) 
{ 
	new temp_string[1024] 
	
	if(g_max_bmbs[id] < MAX_B) 
		format(temp_string, sizeof(temp_string), "\y--Infection Bomb--\w^nTrebuie sa cumperi %d bombe de infectie\r %d/%d",MAX_B, g_max_bmbs[id], MAX_B) 
	else 
		format(temp_string, sizeof(temp_string), "\y[Infection Bomb] \d[Complet]")
	
	menu_additem(menu, temp_string, "8") 
}

public add_lh(id, menu) 
{ 
	new temp_string[1024] 
	
	if(g_lh[id] < MAX_LH)
		formatex(temp_string, sizeof(temp_string), "\y--Last Human--\w^nTrebuie sa omori de %d ori ultimul om\r %d/%d",MAX_LH, g_lh[id], MAX_LH) 
	else
		formatex(temp_string, sizeof(temp_string), "\y[Last Human] \d[Complet]")
	
	menu_additem(menu, temp_string, "9")
}



public medal_menu_handle1(id, menu, item) 
{ 
	if(item == MENU_EXIT) 
	{ 
		menu_destroy(menu) 
		return PLUGIN_HANDLED 
	} 
	
	static data[6], szName[64], access1, callback
	menu_item_getinfo(menu, item, access1, data,charsmax(data), szName,charsmax(szName), callback)
	
	static key_number 
	key_number = str_to_num(data) 
	
	switch(key_number)
	{
		case 0:	if(g_zh_kill[id] >= ZH_MAX_KILL)	client_printcolor(id, "!y[ZP MEDAL] Ai completat medalia !g[Vanatorul de Zombii]!")
		case 1:	if(g_ms_round[id] >= MS_MAX_ROUND)	client_printcolor(id, "!y[ZP MEDAL] Ai completat medalia !g[Maestru in Supravetuiri]!") 
		case 2:	if(g_zt_infect[id] >= ZT_MAX_INFECT)	client_printcolor(id, "!y[ZP MEDAL] Ai completat medalia !g[Zombii Infector]!")
		case 3:	if(g_nh_kill[id] >= NH_MAX_KILL)	client_printcolor(id, "!y[ZP MEDAL] Ai completat medalia !g[Vanatorul de Nemessis]!")
		case 4:	if(g_hh_kill[id] >= HH_MAX_KILL)	client_printcolor(id, "!y[ZP MEDAL] Ai completat medalia !g[Vanatorul de Eroi]!")

		case 5:	if(g_max_tp[id] >= MAX_TP)	client_printcolor(id, "!y[ZP MEDAL] Ai completat medalia !g[TIMP JUCAT]!")
		case 6:	if(g_nem_hs[id] >= NEM_HS)	client_printcolor(id, "!y[ZP MEDAL] Ai completat medalia !g[NEMESIS HEADSHOTS]!")
		case 7:	if(g_max_r[id] >= MAX_R)	client_printcolor(id, "!y[ZP MEDAL] Ai completat medalia !g[RUNDE JUCATE!")
		case 8:	if(g_max_bmbs[id] >= MAX_B)	client_printcolor(id, "!y[ZP MEDAL] Ai completat medalia !g[INFECTION BOMB]!")
		case 9:	if(g_lh[id] >= MAX_B)	client_printcolor(id, "!y[ZP MEDAL] Ai completat medalia !g[LAST HUMAN]!")
	} 
	
	return PLUGIN_HANDLED 
} 

stock client_printcolor(const id, const input[], any:...) 
{ 
	new iCount = 1, iPlayers[32] 
	static szMsg[191] 
	
	vformat(szMsg, charsmax(szMsg), input, 3) 
	replace_all(szMsg, 190, "!g", "^4") 
	replace_all(szMsg, 190, "!y", "^1") 
	replace_all(szMsg, 190, "!t", "^3") 
	
	if(id) iPlayers[0] = id 
	else get_players(iPlayers, iCount, "ch") 
	
	for (new i = 0; i < iCount; i++) 
	{ 
		if(is_user_connected(iPlayers[i])) 
		{ 
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, iPlayers[i]) 
			write_byte(iPlayers[i]) 
			write_string(szMsg) 
			message_end() 
		} 
	} 
}
