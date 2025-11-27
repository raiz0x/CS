#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <cstrike>
#include <fun>

#define PLUGIN	"Unlimited Ammo"
#define VERSION "0.3.1"
#define AUTHOR	"v3x"

#define HE_GRENADE	(1<<0)
#define SMOKE_GRENADE	(1<<1)
#define FLASH_GRENADE	(1<<2)

new const USAGE[] = ": amx_ammo <nick,#userid> <0|1>";

new gCvar_flags;

public plugin_init()
{
	register_plugin(PLUGIN , VERSION , AUTHOR);
	register_concmd("amx_ammo" , "concmd_Ammo" , ADMIN_LEVEL_A , USAGE);
	register_event("CurWeapon" , "event_CurWeapon" , "be" , "1=1");
	gCvar_flags = register_cvar("ammo_nade_flags" , "ac");
}

new bool:has_ammo[33];

public concmd_Ammo(id , lvl , cid)
{
	if(!cmd_access(id , lvl , cid , 3))
		return PLUGIN_HANDLED;

	static arg1[33] , arg2[8];
	read_argv(1 , arg1 , 32);
	read_argv(2 , arg2 , 7);

	remove_quotes(arg2);

	static pid;
	pid = cmd_target(id , arg1 , 0);

	if(!pid)
		return PLUGIN_HANDLED;

	if(equali(arg2 , "ON" , 2) || str_to_num(arg2) == 1)
	{
		if(!task_exists(id))
			set_task(0.3 , "check_for_nades" , id , _ , _ , "b");
		has_ammo[pid] = true;
	}
	else if(equali(arg2 , "OFF" , 2) || !str_to_num(arg2))
	{
		if(task_exists(id))
			remove_task(id);
		has_ammo[pid] = false;
	}
	else
	{
		console_print(id , "[AMXX] Usage%s" , USAGE);
		return PLUGIN_HANDLED;
	}

	static pname1[33] , pname2[33];
	get_user_name(id  , pname1 , 32);
	get_user_name(pid , pname2 , 32);

	static s;
	s = has_ammo[pid];

	switch(get_cvar_num("amx_show_activity"))
	{
		case 1: client_print(0 , print_chat , "ADMIN: %s unlimited ammo on %s" , s ? "Set" : "Unset" , pname2);
		case 2: client_print(0 , print_chat , "ADMIN %s: %s unlimited ammo on %s" , pname1 , s ? "Set" : "Unset" , pname2);
	}

	return PLUGIN_HANDLED;
}

public event_CurWeapon(id)
{
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE;

	if(has_ammo[id])
	{
		static wpnid, clip;
		wpnid = read_data(2);
		clip = read_data(3);

		give_ammo(id , wpnid , clip);
	}

	return PLUGIN_CONTINUE;
}

public client_connect(id)
{
	has_ammo[id] = false;
	if(task_exists(id))
		remove_task(id);
}

public client_disconnect(id)
{
	has_ammo[id] = false;
	if(task_exists(id))
		remove_task(id);
}

public give_ammo(id , wpnid , clip)
{
	if(!is_user_alive(id))
		return;

	if(	wpnid==CSW_C4		||
		wpnid==CSW_KNIFE	||
		wpnid==CSW_HEGRENADE	||
		wpnid==CSW_SMOKEGRENADE	||
		wpnid==CSW_FLASHBANG	) 
			return;

	if(!clip)
	{
		static weapname[33];
		get_weaponname(wpnid , weapname , 32);

		static wpn
		wpn = -1;
		while((wpn = find_ent_by_class(wpn , weapname)) != 0)
		{
			if(id == entity_get_edict(wpn , EV_ENT_owner))
			{
				cs_set_weapon_ammo(wpn , maxclip(wpnid))
				break;
			}
		}
	}
}

public check_for_nades(id)
{
	if(!is_user_alive(id))
		return;

	if(nade_flags() & HE_GRENADE)
	{
		if(!user_has_weapon(id , CSW_HEGRENADE))
			give_item(id , "weapon_hegrenade");
	}
	if(nade_flags() & SMOKE_GRENADE)
	{
		if(!user_has_weapon(id , CSW_SMOKEGRENADE))
			give_item(id , "weapon_smokegrenade");
	}
	if(nade_flags() & FLASH_GRENADE)
	{
		if(!user_has_weapon(id , CSW_FLASHBANG))
			give_item(id , "weapon_flashbang");
	}
}

// Taken from a superhero found on Google. Sorry, I don't know which one!
stock maxclip(wpnid) 
{
	static ca;
	ca = 0;

	switch (wpnid) 
	{
		case CSW_P228 : ca = 13;
		case CSW_SCOUT : ca = 10;
		case CSW_HEGRENADE : ca = 0;
		case CSW_XM1014 : ca = 7;
		case CSW_C4 : ca = 0;
		case CSW_MAC10 : ca = 30;
		case CSW_AUG : ca = 30;
		case CSW_SMOKEGRENADE : ca = 0;
		case CSW_ELITE : ca = 15;
		case CSW_FIVESEVEN : ca = 20;
		case CSW_UMP45 : ca = 25;
		case CSW_SG550 : ca = 30;
		case CSW_GALI : ca = 35;
		case CSW_FAMAS : ca = 25;
		case CSW_USP : ca = 12;
		case CSW_GLOCK18 : ca = 20;
		case CSW_AWP : ca = 10;
		case CSW_MP5NAVY : ca = 30;
		case CSW_M249 : ca = 100;
		case CSW_M3 : ca = 8;
		case CSW_M4A1 : ca = 30;
		case CSW_TMP : ca = 30;
		case CSW_G3SG1 : ca = 20;
		case CSW_FLASHBANG : ca = 0;
		case CSW_DEAGLE	: ca = 7;
		case CSW_SG552 : ca = 30;
		case CSW_AK47 : ca = 30;
		case CSW_P90 : ca = 50;
	}
	return ca;
}

stock nade_flags()
{
	static buffer[8];
	get_pcvar_string(gCvar_flags , buffer , 7);

	return read_flags(buffer);
}
