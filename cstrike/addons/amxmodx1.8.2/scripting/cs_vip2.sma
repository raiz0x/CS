#include <amxmodx> 
#include <cstrike> 
#include <fakemeta>
#include <fun> 
#include <hamsandwich> 

#pragma tabsize 0

#define PLUGIN    "Weapons"  
#define AUTHOR    "Author"  
#define VERSION    "1.0"  

#define VIP_GOLD_ACCESS "bi"
#define is_gold_vip(%1) (get_user_flags(%1)&read_flags(VIP_GOLD_ACCESS))

new g_MaxPlayers
#define is_valid_player(%1) (1 <= %1 <= g_MaxPlayers)

new bool:sp_w[33][3]

enum _:VIP_WEAPONS{
	V_MODEL[35],
	ENG_WEAPON[15],
	CSW_WEAPON,
	Float:WEAPON_DMG
}
static const VWS[][VIP_WEAPONS] ={
	{ "models/vip/v_m4a1_gold.mdl", "weapon_m4a1", CSW_M4A1, 2.0 },
	{ "models/vip/v_ak47_gold.mdl", "weapon_ak47", CSW_AK47, 2.0 },
	{ "models/vip/v_xm1014_gold.mdl", "weapon_xm1014", CSW_XM1014, 2.0 }
}

public plugin_precache() for (new i; i < sizeof VWS; i++) precache_model(VWS[i][V_MODEL])

public plugin_init() 
{ 
    register_plugin("CT Weapons", "1.0", "WTFCS")
    //Hamsandwich 
    RegisterHam(Ham_Spawn, "player", "Player_Spawn", 1) 
	for (new i; i < sizeof VWS; i++) RegisterHam(Ham_Item_Deploy, VWS[i][ENG_WEAPON], "OnItemDeployPost", 1);
	RegisterHam(Ham_TakeDamage, "player", "player_damage",1)

	g_MaxPlayers = get_maxplayers();
} 

public Player_Spawn(id) 
{ 
    if(is_user_alive(id)) 
    {
	sp_w[id][0]=sp_w[id][1]=sp_w[id][2]=false
	strip_user_weapons(id) 
	give_item(id, "weapon_knife") 
	give_item(id, "weapon_hegrenade") //<---- 1 He grenade 
	give_item(id, "weapon_smokegrenade") //<---- 1. smoke grenade
	if(get_user_team(id)==2){
		give_item(id, "weapon_deagle")
                give_item(id,"ammo_50ae")
	        give_item(id,"ammo_50ae")
	        give_item(id,"ammo_50ae")
	        give_item(id,"ammo_50ae")
	        give_item(id,"ammo_50ae")
	        give_item(id,"ammo_50ae")
	        give_item(id,"ammo_50ae")
		Player_Weapons(id)
        }
    }  
}

public OnItemDeployPost(ent){
	if( pev_valid(ent) != 2 )	return
	static id; id = get_pdata_cbase(ent, 41, 4);
	if(pev_valid(id)&&is_user_alive(id)&&is_gold_vip(id)&&(sp_w[id][0]||sp_w[id][1]||sp_w[id][2])) for (new i; i < sizeof VWS; i++) if(cs_get_weapon_id(ent)==VWS[i][CSW_WEAPON]) set_pev(id, pev_viewmodel2, VWS[i][V_MODEL])
}

public Player_Weapons(id){
	new menu = menu_create("\r[\yAnti-Furien\r] \wWeapons Menu Player", "menu_handler");  
	menu_additem(menu, "\r[\yPICK\r] \wAK47", "1", 0);  
	menu_additem(menu, "\r[\yPICK\r] \wM4A1", "2", 0);  
	menu_additem(menu, "\r[\yPICK\r] \wAUG", "3", 0);  
	menu_additem(menu, "\r[\yPICK\r] \wGALIL", "4", 0);   
	menu_additem(menu, "\r[\yPICK\r] \wFAMAS", "5", 0);  
	if(!is_gold_vip(id)) menu_additem(menu, "\r[\yPICK\r] \wXM1014", "6", 0);  
	else {
		static fmt[250];formatex(fmt,charsmax(fmt),"\r[\yPICK\r] \wXM1014^n\r[\yVIP\r]\w GOLD Weapons^n")
		menu_additem(menu, fmt, "6", 0);
		menu_additem(menu, "\r[\yPICK\r]\w M4a1 gold","7");
		menu_additem(menu, "\r[\yPICK\r]\w AK47 gold","8");
		menu_additem(menu, "\r[\yPICK\r]\w XM1014 gold","9");
	}
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);  
	menu_display(id, menu, 0);  
}
public menu_handler(id, menu, item)  
{  
    if( item == MENU_EXIT||get_user_team(id)!=2||!is_user_alive(id) )  
    {  
        menu_destroy(menu);  
        return PLUGIN_HANDLED;  
    }  
    new data[6], iName[64];  
    new access, callback;  
    menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);  
    new key = str_to_num(data);  
    
    switch(key)  
    {  
        case 1:  
        {  
			give_item(id, "weapon_ak47")  

			cs_set_user_bpammo(id,CSW_AK47,250)
        }  
        case 2:  
        {  
			give_item(id, "weapon_m4a1")  
            
			cs_set_user_bpammo(id,CSW_M4A1,250)    
        }  
        case 3:   
        {  
			give_item(id, "weapon_aug")  
            
			cs_set_user_bpammo(id,CSW_AUG,250)    
        }  
        case 4:   
        {  
            give_item(id, "weapon_galil")  
            
            cs_set_user_bpammo(id,CSW_GALIL,250)    
            
        }  
        case 5:   
        {  
            
            give_item(id, "weapon_famas")  
            
            cs_set_user_bpammo(id,CSW_FAMAS,250)    
            
        }  
        case 6:   
        {  
            give_item(id, "weapon_xm1014")  
            
            
            cs_set_user_bpammo(id,CSW_XM1014,250)   
        }  

	case 7:{
		if(is_gold_vip(id)){
			sp_w[id][0]=true
			give_item(id,"weapon_m4a1")
			cs_set_user_bpammo(id,CSW_M4A1,250)
			engclient_cmd(id,"weapon_knife")
			engclient_cmd(id,"weapon_m4a1")
		}
	}
	case 8:{
		if(is_gold_vip(id)){
			sp_w[id][1]=true
			give_item(id,"weapon_ak47")
			cs_set_user_bpammo(id,CSW_AK47,250)
			engclient_cmd(id,"weapon_knife")
			engclient_cmd(id,"weapon_ak47")
		}
	}
	case 9:{
		if(is_gold_vip(id)){
			sp_w[id][2]=true
			give_item(id,"weapon_xm1014")
			cs_set_user_bpammo(id,CSW_XM1014,250)
			engclient_cmd(id,"weapon_knife")
			engclient_cmd(id,"weapon_xm1014")
		}
	}
       }  
    
    menu_destroy(menu);  
    return PLUGIN_HANDLED;  
}

public player_damage(victim, inflictor, attacker, Float:damage, bits){
	if(!is_user_alive(attacker))	return HAM_IGNORED;
        if(is_valid_player(attacker)&&is_gold_vip(attacker)&&(sp_w[attacker][0]||sp_w[attacker][1]||sp_w[attacker][2])) for (new i; i < sizeof VWS; i++) if(get_user_weapon(attacker)==VWS[i][CSW_WEAPON]) SetHamParamFloat(4, damage * VWS[i][WEAPON_DMG])
	return HAM_SUPERCEDE;
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
