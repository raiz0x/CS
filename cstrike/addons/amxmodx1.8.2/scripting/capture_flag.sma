#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
//#include dm_chat

//native dm_set_user_money(id, set)
//native dm_get_user_money(id)
//native privilege_get(id)

#define Model_Flag "models/flag/flag.mdl"
#define TAG "!n[CSDM] "

new g_iAllocInfoTarget, g_iAllocInfoTarget2
new g_szConfigFile[128];

new g_CT_Flags, g_T_Flags
new g_iCvar[4],text[33]

public plugin_init()
{
	register_clcmd("amx_spawn_flag", "ClCMD_Spawn_FLAG",ADMIN_RCON,"<nume flag>")
	
	register_touch("Flag_Trigger", "player", "touch_flag")
	
	g_iCvar[0]=register_cvar("f_time_reward", "60")//reward dupa timp
	g_iCvar[1]=register_cvar("f_reward", "200")//suma de bani care o primeste dupa acel timp
	g_iCvar[2]=register_cvar("f_time_capture", "20")
	g_iCvar[3]=register_cvar("f_capture_reward", "300")//suma de bani care o primeste imediat dupa ce ia un flag
	
	set_task(float(g_iCvar[0]), "Task_Reward", .flags="b")
}

public plugin_precache()	precache_model(Model_Flag)

public plugin_cfg()
{
	g_iAllocInfoTarget = engfunc(EngFunc_AllocString, "cycler_sprite")
	g_iAllocInfoTarget2 = engfunc(EngFunc_AllocString, "trigger_multiple")
	
	new file[128]; get_localinfo("amxx_configsdir",file,63)
	format(file, 127, "%s/test_cvars/flags.cfg", file)
	if(file_exists(file)) server_cmd("exec %s", file), server_exec()
	
	load_flags()
}
public load_flags()
{
	new szMapName[32]
	get_mapname(szMapName, 31)
	strtolower(szMapName)//...
	
	formatex(g_szConfigFile, 127, "addons/amxmodx/configs/flags")
	
	if( !dir_exists(g_szConfigFile)) 
	{
		mkdir(g_szConfigFile)
		//format(g_szConfigFile, 127, "%s/%s.txt", g_szConfigFile, szMapName )
		//return
	}
	
	format(g_szConfigFile, 127, "%s/%s.txt", g_szConfigFile, szMapName)
	if(!file_exists(g_szConfigFile)) 
	{
		fopen(g_szConfigFile, "at")
		//return
	}
	
	new iFile = fopen( g_szConfigFile, "rt" )
	//if(!iFile) return
	
	new x[16], y[16], z[16], szDesc[32], szData[charsmax(x) + charsmax(y) + charsmax(z) + charsmax(szDesc)]
	new Float:vOrigin[3]
	
	while(!feof(iFile)) 
	{
		fgets(iFile, szData, charsmax(szData))
		trim(szData)
		
		if(!szData[0]) continue;
		
		parse(szData, x, 15, y, 15, z, 15, szDesc, 31)
		vOrigin[0] = str_to_float(x)
		vOrigin[1] = str_to_float(y)
		vOrigin[2] = str_to_float(z)
		
		spawn_flag(vOrigin, szDesc)
	}
	fclose( iFile )
}
public spawn_flag(const Float:vOrigin[3], const Desc[])
{
	new ent = engfunc(EngFunc_CreateNamedEntity, g_iAllocInfoTarget);
	if(!ent)	return 0
	
	engfunc(EngFunc_SetOrigin, ent, vOrigin)
	entity_set_string(ent, EV_SZ_classname, "Flag_Ent")
	engfunc(EngFunc_SetModel, ent, Model_Flag)
	entity_set_size(ent, Float: {0.0, 0.0, 0.0}, Float: {0.0, 0.0, 0.0})
	entity_set_float(ent, EV_FL_framerate, 1.0)
	entity_set_int(ent, EV_INT_sequence, 0)
	entity_set_float(ent, EV_FL_animtime, halflife_time())
	set_pev(ent, pev_body, 0)
	entity_set_string(ent, EV_SZ_targetname, Desc)
	
	
	new entity = engfunc(EngFunc_CreateNamedEntity, g_iAllocInfoTarget2)
	if(!entity)	return 0
	
	engfunc(EngFunc_SetOrigin, entity, vOrigin)
	entity_set_string(entity, EV_SZ_classname, "Flag_Trigger")
	entity_set_size(entity, Float: {-15.0, -15.0, 0.0}, Float: {15.0, 15.0, 64.0})
	entity_set_int(entity, EV_INT_solid, SOLID_TRIGGER)
	entity_set_int(entity, EV_INT_movetype, MOVETYPE_FLY)
	set_pev(entity, pev_euser1, ent)
	
	return ent
}
public ClCMD_Spawn_FLAG(id,level,cid)
{
	if(!cmd_access(id,level,cid,1))	return PLUGIN_HANDLED
	
	new arg1[32]
	read_argv(1,arg1,charsmax(arg1))
	
	if(equal(arg1,""))
	{
		console_print(id,"Folosire corecta: amx_spawn_flag NUME_FLAG")
		return PLUGIN_HANDLED
	}
	
	new Float:origin[3]
	pev(id, pev_origin, origin)
	origin[2]-=7.0
	
	formatex(text,charsmax(text),arg1)
	copy(text,charsmax(text),arg1)
	new ent=spawn_flag(origin,arg1)
	Save_Flags(ent)
	
	return PLUGIN_HANDLED
}
Save_Flags(ent)
{
	new iFile = fopen(g_szConfigFile, "at")
	if(!iFile) return
	
	new Float:vOrigin[3]
	pev(ent, pev_origin, vOrigin)

	fprintf(iFile, "%f %f %f ^"%s^"^n", vOrigin[0], vOrigin[1], vOrigin[2],text)
	fclose(iFile)
}

public Task_Reward()
{
	new id, reward=get_pcvar_num(g_iCvar[1])
	for (id = 0; id < get_maxplayers(); id++)
	{
		if(!is_user_connected(id)||is_user_bot(id)||is_user_hltv(id))	continue
		
		if(fm_cs_get_user_team(id)==2&&g_CT_Flags)
		{
			reward*=g_CT_Flags//suma de bani inmultita cu nru de flage
			cs_set_user_money(id,cs_get_user_money(id)+reward,1)//dm_set_user_money(id, dm_get_user_money(id)+reward)
		}
		else if(fm_cs_get_user_team(id)==1&&g_T_Flags)
		{
			reward*=g_T_Flags
			cs_set_user_money(id,cs_get_user_money(id)+reward,1)//dm_set_user_money(id, dm_get_user_money(id)+reward)
		}
	}
}

public touch_flag(entity, id)
{
	new ent=pev(entity, pev_euser1)
	
	if(pev(ent, pev_iuser1))	return
	if(fm_cs_get_user_team(id)==pev(ent, pev_body))	return
	
	message_begin(MSG_ONE,get_user_msgid("StatusIcon"),_,id)
	write_byte(2) 
	write_string("dmg_shock")
	write_byte(20)
	write_byte(20)
	write_byte(240)
	message_end()
	
	set_pev(ent, pev_iuser1, get_pcvar_num(g_iCvar[2]))
	
	message_begin(MSG_ONE, 108, _, id)
	write_byte(get_pcvar_num(g_iCvar[2]))
	write_byte(0)
	message_end()
	
	new info[2]
	info[0] = ent
	info[1] = id
	set_task(1.0, "flag_refresh", ent+636, info, 2, "b")
}
public flag_refresh(const info[])
{
	new ent=info[0],id=info[1]
	if(!is_user_connected(id)){
		remove_task(ent+636)//id..
		set_pev(ent, pev_iuser1, 0)
		return
	}
	
	new Float:flOrigin[3], Float:flOrigin2[3]
	pev(id, pev_origin, flOrigin)
	pev(ent, pev_origin, flOrigin2)
	new Float:flDistance = get_distance_f(flOrigin, flOrigin2) 
	
	if(flDistance>80.0||!is_user_alive(id)){
		message_begin(MSG_ONE, 108, _, id)
		write_byte(0)
		write_byte(0)
		message_end()
		
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),_,id)
		write_byte(0) 
		write_string("dmg_shock")
		write_byte(20)
		write_byte(20)
		write_byte(240)
		message_end()
		
		set_pev(ent, pev_iuser1, 0)
		remove_task(ent+636)
		return
	}
	
	set_pev(ent, pev_iuser1, pev(ent, pev_iuser1)-1)//crap
	if(!pev(ent, pev_iuser1))//daca pev==1
	{
		new szDesc[32]
		pev(ent, pev_targetname, szDesc, charsmax(szDesc))
		
		if(fm_cs_get_user_team(id)==2){
			if(pev(ent, pev_body))	g_T_Flags--
			g_CT_Flags++
		}else{
			g_T_Flags++
			if(pev(ent, pev_body))	g_CT_Flags--
		}
		
		set_pev(ent, pev_body, fm_cs_get_user_team(id))
		
		for(new i=0;i<get_maxplayers();i++)//^
		{
			if(!is_user_connected(i)||is_user_bot(i)||is_user_hltv(i)) continue
			if(i==id)	xCoLoR(id, "%s!gYou!t captured flag !g(%s)",TAG, szDesc)	
			else	xCoLoR(0, "%s!g%s!t Captured flags !g(%s)",TAG, fm_cs_get_user_team(id)==2?"Counter-Terrorists":"Terrorists", szDesc)//xd
			xCoLoR(id, "%s!gYou got +!t%d$",TAG,get_pcvar_num(g_iCvar[3]))
			cs_set_user_money(id,cs_get_user_money(id)+get_pcvar_num(g_iCvar[3]),1)
			return
		}
		remove_task(ent+636)
	}
	return
}

stock fm_cs_get_user_team(id)
{
	if (pev_valid(id) != 2) return 0
	return get_pdata_int(id, 114, 5)
}


stock xCoLoR(id, String[], any:...) 
{
	static szMesage[192];
	vformat(szMesage, charsmax(szMesage), String, 3);
	
	replace_all(szMesage, charsmax(szMesage), "!n", "^1");
	replace_all(szMesage, charsmax(szMesage), "!t", "^3");
	replace_all(szMesage, charsmax(szMesage), "!g", "^4");
	replace_all(szMesage, charsmax(szMesage), "!t2", "^0");
	
	static g_msg_SayText = 0;
	if(!g_msg_SayText)	g_msg_SayText = get_user_msgid("SayText");
	
	new Players[32], iNum = 1, i;

 	if(id) Players[0] = id;
	else get_players(Players, iNum, "c");
	
	for(--iNum; iNum >= 0; iNum--) 
	{
		i = Players[iNum];
		
		message_begin(MSG_ONE_UNRELIABLE, g_msg_SayText, _, i);
		write_byte(i);
		write_string(szMesage);
		message_end();
	}
}

#pragma tabsize 0
