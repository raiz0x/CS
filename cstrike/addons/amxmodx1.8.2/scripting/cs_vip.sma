#include <amxmodx>
#include <cstrike>
#include <fun>
#include <engine>
#include <fakemeta_util>
#include <hamsandwich>
#include <ANTI_PROTECTION>

#define VIP_FLAG ADMIN_LEVEL_H
#define VIP_BONUS_DMG 2.0
#define NR_RUNDA_MENIU 3		//(daca ai runda de live/rr, adauga +1 la nr initial)
#define TAG "!v[!nESTRIKE!v]!n"

new const VWM[][] =
{
"models/vip/v_m4a1_golden.mdl",
"models/vip/v_ak47_golden.mdl"
}
new const VPM[][] =
{
"vmp_ct",
"vmp_tx"
}
new const WEAPONENTNAMES[][] =
{
"weapon_m4a1",
"weapon_ak47"
}

#define is_valid_player(%1) (1 <= %1 <= g_MaxPlayers)

enum {
    SCOREATTRIB_ARG_PLAYERID = 1,
    SCOREATTRIB_ARG_FLAGS
}

enum ( <<= 1 ) {
    SCOREATTRIB_FLAG_NONE = 0,
    SCOREATTRIB_FLAG_DEAD = 1,
    SCOREATTRIB_FLAG_BOMB,
    SCOREATTRIB_FLAG_VIP
}

new round=0

new bool:choice_m4[33],bool:choice_ak[33]

new jumpznum[33] = 0,bool:dozjump[33] = false

const WEAPON_BITSUM = (1<<CSW_SCOUT) | (1<<CSW_XM1014) | (1<<CSW_MAC10) | (1<<CSW_AUG) | (1<<CSW_UMP45) | (1<<CSW_SG550) | (1<<CSW_P90) | 
(1<<CSW_FAMAS) | (1<<CSW_AWP) | (1<<CSW_MP5NAVY) | (1<<CSW_M249) | (1<<CSW_M3) | (1<<CSW_M4A1) | (1<<CSW_TMP) | (1<<CSW_G3SG1) | (1<<CSW_SG552) | 
(1<<CSW_AK47) | (1<<CSW_GALIL) | (1<<CSW_GLOCK18) | (1<<CSW_USP)

new g_MaxPlayers,bool:allow_weapons=true,mapname[125];

public plugin_init()
{
       register_clcmd ( "say /wantvip", "cmdShowMotd" );
       register_clcmd ( "say_team /wantvip", "cmdShowMotd" );

       register_message(get_user_msgid( "ScoreAttrib" ), "MessageScoreAttrib")

       register_event("HLTV", "event_new_round", "a", "1=0", "2=0")

       RegisterHam(Ham_Spawn, "player", "PlayerSpawn", 1 )
       for (new i; i < sizeof WEAPONENTNAMES; i++)//=)))
		/*if (WEAPONENTNAMES[i][0])*/ RegisterHam(Ham_Item_Deploy, WEAPONENTNAMES[i], "OnItemDeployPost", 1);
       RegisterHam(Ham_TakeDamage, "player", "player_damage",1)
       g_MaxPlayers = get_maxplayers();

       register_cvar("vip_jumps","1")


       register_forward( FM_SetClientKeyValue, "fw_SetClientKeyValue" )


       get_mapname(mapname,charsmax(mapname))
       if(contain(mapname,"hp")!=-1||contain(mapname,"awp")!=-1)	allow_weapons=false
}

public client_connect(id)   if(!(is_user_bot(id)||is_user_hltv(id)))    RAIZ0_EXCESS3(id,"cl_minmodels 0")

public cmdShowMotd (id)	show_motd (id,"addons/amxmodx/configs/vip.txt", "Informatii V.I.P")

public event_new_round()	round++

public plugin_precache()
{
	for (new i; i < sizeof VWM; i++)	precache_model(VWM[i]);

	new szBuffer[512];
	for(new i;i<sizeof(VPM);i++)
	{
/*
		formatex( szBuffer, charsmax( szBuffer ), "models/player/%s/%s.mdl", VPM[0], VPM[0] )
		precache_model( szBuffer )
		formatex( szBuffer, charsmax( szBuffer ), "models/player/%s/%s.mdl", VPM[1], VPM[1] )
		precache_model( szBuffer )
*/
		formatex( szBuffer, charsmax( szBuffer ), "models/player/%s/%s.mdl", VPM[i], VPM[i] )
		precache_model( szBuffer )
	}
}

public DisplayMenu( id ) {

	new menu = menu_create( "Equipment", "menu_handler" )

	menu_additem( menu, "50 HP", "1", VIP_FLAG )
	menu_additem( menu, "50 AP", "2", VIP_FLAG )
	if(allow_weapons==true)
	{
	menu_additem( menu, "M4A1 Gold + deagle +2he +2fb", "3", VIP_FLAG )
	menu_additem( menu, "AK Gold + deagle +2he +FB", "4", VIP_FLAG )
	menu_additem( menu, "AWP + deagle +2he", "5", VIP_FLAG )
	}

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL )
	menu_display( id, menu, 0 )
}

public menu_handler( id, Menu, Item )
{
	if( Item < 0 || !is_user_alive(id)||!is_client_vip(id) )	return 0;

	new Key[ 3 ],Access, CallBack;
	menu_item_getinfo( Menu, Item, Access, Key, 2, _, _, CallBack );
	new isKey = str_to_num( Key );

	switch( isKey )
	{
		case 1:
		{       
			set_user_health(id, get_user_health(id) + 50)
			xCoLoR(id,"%s Ai ales +!e50!nHP, spor la!v fraguri!n!",TAG)
		}
		case 2:
		{
			set_user_armor(id, get_user_armor(id) + 50)
			xCoLoR(id,"%s Ai ales +!e50!nAP, spor la!v fraguri!n!",TAG)
		}
		case 3:
		{
			if(cs_get_user_team(id)==CS_TEAM_T&&is_user_alive(id)&&user_has_weapon(id,CSW_C4))	engclient_cmd(id,"drop","weapon_c4")
			choice_m4[id] = true
			drop_wpn(id)
			give_item(id, "weapon_m4a1")     
			give_item(id, "weapon_deagle") 
			cs_set_user_bpammo(id, CSW_M4A1, 90)
			cs_set_user_bpammo(id, CSW_DEAGLE, 35)
			give_item(id, "weapon_hegrenade") 
			cs_set_user_bpammo(id, CSW_HEGRENADE, 2)
			give_item(id, "weapon_flashbang") 
			cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
			xCoLoR(id,"%s Ai ales!e M4A1!n+!vDEAGLE!n+!eHE!n+!vFL!n, spor la!e fraguri!n!",TAG)
		}  
		case 4:
		{
			if(cs_get_user_team(id)==CS_TEAM_T&&is_user_alive(id)&&user_has_weapon(id,CSW_C4))	engclient_cmd(id,"drop","weapon_c4")
			choice_ak[id] = true
			drop_wpn(id)
			give_item(id, "weapon_ak47")
			give_item(id, "weapon_deagle") 
			cs_set_user_bpammo(id, CSW_AK47, 90)
			cs_set_user_bpammo(id, CSW_DEAGLE, 35)
			give_item(id, "weapon_hegrenade") 
			cs_set_user_bpammo(id, CSW_HEGRENADE, 2)
			give_item(id, "weapon_flashbang") 
			cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
			xCoLoR(id,"%s Ai ales!e AK47!n+!vDEAGLE!n+!eHE!n+!vFL!n, spor la!e fraguri!n!",TAG)
		}
		case 5:
		{
			if(cs_get_user_team(id)==CS_TEAM_T&&is_user_alive(id)&&user_has_weapon(id,CSW_C4))	engclient_cmd(id,"drop","weapon_c4")
			drop_wpn(id)
			give_item(id, "weapon_awp")
			give_item(id, "weapon_deagle")
			cs_set_user_bpammo(id, CSW_AWP, 90)
			cs_set_user_bpammo(id, CSW_DEAGLE, 35)
			give_item(id, "weapon_hegrenade") 
			cs_set_user_bpammo(id, CSW_HEGRENADE, 2)

			xCoLoR(id,"%s Ai ales!e AWP!n+!vDEAGLE!n+!eHE!n, spor la!v fraguri!n!",TAG)
		}
	}
	menu_destroy(Menu) 
	return PLUGIN_HANDLED
}

public PlayerSpawn(id)
{
	if(is_user_connected(id)&&is_client_vip(id))
	{
		if(is_user_alive(id))
		{
		if( round>=NR_RUNDA_MENIU )	DisplayMenu(id)

		switch(cs_get_user_team(id))
		{
			case CS_TEAM_T:		cs_set_user_model(id,VPM[1])
			case CS_TEAM_CT:	cs_set_user_model(id,VPM[0])
		}

		if(choice_m4[id])	choice_m4[id]=false
		else if(choice_ak[id])	choice_ak[id]=false
		}
	}
}

public fw_SetClientKeyValue( const id, const infobuffer[ ], const key[ ], const value[] ) {
//!equal(value,VPM[0])
    if( equal( key, "model" )&&is_user_connected(id)&&is_client_vip(id) ) {
	switch(cs_get_user_team(id))
	{
		case CS_TEAM_T:		set_user_info( id, "model", VPM[1] )
		case CS_TEAM_CT:	set_user_info( id, "model", VPM[0] )
	}
	return FMRES_SUPERCEDE//+fiecare caz
    }
    return FMRES_IGNORED
}

public player_damage(victim, inflictor, attacker, Float:damage, bits)
{
	if(!is_user_alive(attacker))	return HAM_IGNORED;
        if(is_valid_player(attacker)&&is_client_vip(attacker)&&
		(/*user_has_weapon(attacker,CSW_M4A1)&&*/get_user_weapon(attacker) == CSW_M4A1&&choice_m4[attacker])||
			(/*user_has_weapon(attacker,CSW_AK47)&&*/get_user_weapon(attacker) == CSW_AK47&&choice_ak[attacker]))
				SetHamParamFloat(4, damage * VIP_BONUS_DMG)
				//return HAM_SUPERCEDE;

	return HAM_HANDLED;
}

public OnItemDeployPost(ent)
{
	if( pev_valid(ent) != 2 )	return
	static id; id = get_pdata_cbase(ent, 41, 4);

	if(pev_valid(id)&&is_user_alive(id)&&is_client_vip(id))
	{
	switch(cs_get_weapon_id(ent))
	{
		case CSW_M4A1:
		{
			if(choice_m4[id])	set_pev(id, pev_viewmodel2, VWM[0])
			//set_pev(id, pev_weaponmodel2, "models/p_custom.mdl")
		}
		case CSW_AK47:	if(choice_ak[id])	set_pev(id, pev_viewmodel2, VWM[1])
	}
	}
}

public client_putinserver(id)
{
	jumpznum[id] = 0
	dozjump[id] = false

	choice_m4[id] = false
	choice_ak[id] = false
}

public client_disconnect(id)
{
	jumpznum[id] = 0
	dozjump[id] = false
}

public MessageScoreAttrib(iMsgId, iDest, iReceiver)
{
	new iPlayer = get_msg_arg_int(SCOREATTRIB_ARG_PLAYERID)
	
	if(is_user_alive(iPlayer)&&is_client_vip(iPlayer))	set_msg_arg_int(SCOREATTRIB_ARG_FLAGS, ARG_BYTE, SCOREATTRIB_FLAG_VIP)
}

public client_PreThink(id)
{
	if(!is_user_alive(id) || !is_client_vip(id))	return PLUGIN_CONTINUE
	 
	new nzbut = get_user_button(id),ozbut = get_user_oldbutton(id)
	new Float:fallspeed = 100.0 * -1.0

	if((nzbut & IN_JUMP) && !(get_entity_flags(id) & FL_ONGROUND) && !(ozbut & IN_JUMP))
	{
		if (jumpznum[id] < get_cvar_num("vip_jumps"))
		{
			dozjump[id] = true
			jumpznum[id]++

			return PLUGIN_CONTINUE
		}
	}
	if((nzbut & IN_JUMP) && (get_entity_flags(id) & FL_ONGROUND))
	{
		jumpznum[id] = 0

		return PLUGIN_CONTINUE
	}    

	if(nzbut & IN_USE) 
	{
		new Float:velocity[3]
		entity_get_vector(id, EV_VEC_velocity, velocity)
		if (velocity[2] < 0.0) 
		{
			entity_set_int(id, EV_INT_sequence, 3)
			entity_set_int(id, EV_INT_gaitsequence, 1)
			entity_set_float(id, EV_FL_frame, 1.0)
			entity_set_float(id, EV_FL_framerate, 1.0)

			velocity[2] = (velocity[2] + 40.0 < fallspeed) ? velocity[2] + 40.0 : fallspeed
			entity_set_vector(id, EV_VEC_velocity, velocity)
		}
	}
	return PLUGIN_CONTINUE
}
public client_PostThink(id)
{
    if(!is_user_alive(id)||!is_client_vip(id))	return PLUGIN_CONTINUE

    if(dozjump[id] == true)
    {
        new Float:vezlocityz[3]    
        entity_get_vector(id,EV_VEC_velocity,vezlocityz)
        vezlocityz[2] = random_float(265.0,285.0)
        entity_set_vector(id,EV_VEC_velocity,vezlocityz)
        dozjump[id] = false
        return PLUGIN_CONTINUE
    }    
    return PLUGIN_CONTINUE
}  


drop_wpn( id )
{
	strip_user_weapons(id)
	give_item(id,"weapon_knife")
}

is_client_vip(id)
{
	if((get_user_flags(id) & VIP_FLAG))	return true

	return false
}

stock xCoLoR(id, String[], any:...) 
{
	static szMesage[192];
	vformat(szMesage, charsmax(szMesage), String, 3);
	
	replace_all(szMesage, charsmax(szMesage), "!n", "^1");
	replace_all(szMesage, charsmax(szMesage), "!e", "^3");
	replace_all(szMesage, charsmax(szMesage), "!v", "^4");
	replace_all(szMesage, charsmax(szMesage), "!e2", "^0");
	
	static g_msg_SayText = 0;
	if(!g_msg_SayText)	g_msg_SayText = get_user_msgid("SayText");
	
	new Players[32], iNum = 1, i;

 	if(id) Players[0] = id;
	else get_players(Players, iNum, "ch");
	
	for(--iNum; iNum >= 0; iNum--) 
	{
		i = Players[iNum];
		
		message_begin(MSG_ONE_UNRELIABLE, g_msg_SayText, _, i);
		write_byte(i);
		write_string(szMesage);
		message_end();
	}
}
