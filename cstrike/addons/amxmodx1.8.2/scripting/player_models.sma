#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#pragma semicolon						1

#define PLUGIN_NAME						"[CS] Models Manager"
#define PLUGIN_VERS						"0.42"
#define PLUGIN_AUTH						"81x08"

#define PLUGIN_INFO						PLUGIN_NAME, PLUGIN_VERS, PLUGIN_AUTH

#define MAX_PLAYERS						32

#define TASK_ID_PLAYER_MODEL_FIXED 		100

#define DEBUG_LOGS

const m_iPlayerTeam 					= 114;
const m_iModelIndexPlayer 				= 491;

const XO_PLAYER							= 5;

const MAX_SIZE_MDL_TYPE					= 6;
const MAX_SIZE_MDL_AUTH					= 35;
const MAX_SIZE_MDL_VARIOUS				= 20;
const MAX_SIZE_MDL_NAME					= MAX_SIZE_MDL_VARIOUS * 2;

const MAX_MODEL_LENGTH					= 64;
#define MAX_PARAMETERS	4

const MAX_SIZE_PL_MDL_DIR				= 20;
const MAX_SIZE_WP_MDL_DIR				= 30;

enum _: ENUM_DATA_TEAMS	{
	TEAM_NULL,
	
	TEAM_T,
	TEAM_CT
};

enum _: ENUM_DATA_MODELS_INFO	{
	MDL_TYPE[MAX_SIZE_MDL_TYPE],
	MDL_AUTH[MAX_SIZE_MDL_AUTH],
	MDL_VARIOUS[MAX_SIZE_MDL_VARIOUS],
	MDL_NAME[MAX_SIZE_MDL_NAME]
};

new g_iArrayPlayerModelSize /*, g_iArrayWeaponModelSize*/;

new bool: gp_bModel[MAX_PLAYERS + 1 char];

new gp_szModel[MAX_PLAYERS + 1 char][MAX_SIZE_MDL_NAME],
	gp_szPersonalModels[MAX_PLAYERS + 1 char][ENUM_DATA_TEAMS][MAX_SIZE_MDL_NAME];

new Array: g_aPlayerModel,
	Array: g_aWeaponModel;
	
new Trie:g_tViewModels;
new Trie:g_tWeaponModels;
new Trie:g_tWorldModels;

#define AllocString(%1) 		engfunc(EngFunc_AllocString,%1)

/*================================================================================
 [PLUGIN]
=================================================================================*/
public plugin_init()	{
	/* [PLUGIN] */
	register_plugin(PLUGIN_INFO);
}

public plugin_precache()	{
	g_aPlayerModel = ArrayCreate(ENUM_DATA_MODELS_INFO);
	g_aWeaponModel = ArrayCreate(ENUM_DATA_MODELS_INFO);
	
	new szFileModelsDir[128];
	get_localinfo("amxx_configsdir", szFileModelsDir, charsmax(szFileModelsDir));
	formatex(szFileModelsDir, charsmax(szFileModelsDir), "%s/ModelsManager", szFileModelsDir);

	new const szModelsDir[] 		= 	"models/ModelsManager";
	new const szModelsPlayersDir[] 	= 	"models/ModelsManager/players";
	new const szModelsWeaponsDir[] 	= 	"models/ModelsManager/weapons";
		
	if(!(dir_exists(szFileModelsDir))) {
		#if defined DEBUG_LOGS
		log_amx("[WARN] Directory '%s' not exist, will be created automatically." ,szFileModelsDir);
		#endif
		mkdir(szFileModelsDir);		
	}
	
	if(!(dir_exists(szModelsDir))) {
		#if defined DEBUG_LOGS
		log_amx("[WARN] Directory '%s' not exist, will be created automatically." ,szModelsDir);
		#endif
		mkdir(szModelsDir);
		mkdir(szModelsPlayersDir);
		mkdir(szModelsWeaponsDir);		
	}
		
	formatex(szFileModelsDir, charsmax(szFileModelsDir), "%s/players.ini", szFileModelsDir);
	
	new aData[ENUM_DATA_MODELS_INFO],
		szBuffer[MAX_SIZE_MDL_TYPE + MAX_SIZE_MDL_AUTH + MAX_SIZE_MDL_VARIOUS + MAX_SIZE_MDL_NAME];
	
	new iFile = fopen(szFileModelsDir, "rt");
	if(iFile)	{
		new szPrecache[MAX_SIZE_PL_MDL_DIR + MAX_SIZE_MDL_VARIOUS * 2];
		
		while(!(feof(iFile)))	{
			fgets(iFile, szBuffer, charsmax(szBuffer));
			trim(szBuffer);
			strtolower(szBuffer);

			if(!(szBuffer[0]) || szBuffer[0] == ';' || szBuffer[0] == '/' || szBuffer[0] == '#')
				continue;
			
			parse(szBuffer, 
				aData[MDL_TYPE],	charsmax(aData[MDL_TYPE]),
				aData[MDL_AUTH],	charsmax(aData[MDL_AUTH]),
				aData[MDL_VARIOUS],	charsmax(aData[MDL_VARIOUS]),
				aData[MDL_NAME],	charsmax(aData[MDL_NAME])
			);
			
			#if defined DEBUG_LOGS
			log_amx("PLRS, TYPE: [%s], AUTH: [%s], VAR: [%s], NAME: [%s]",aData[MDL_TYPE], aData[MDL_AUTH], aData[MDL_VARIOUS], aData[MDL_NAME]);
			#endif
			formatex(szPrecache, charsmax(szPrecache), "%s/players/%s.mdl", szModelsDir, aData[MDL_NAME]);
			strtolower(szPrecache);
			if(file_exists(szPrecache))	{
				precache_model(szPrecache);
				ArrayPushArray(g_aPlayerModel, aData);
			}
			else {
				#if defined DEBUG_LOGS
				log_amx("[WARN] Model '%s'not found", szPrecache);
				#endif
			}
		}
		
		fclose(iFile);
		
		if((g_iArrayPlayerModelSize = ArraySize(g_aPlayerModel)))	{
			/* [HAMSANDWICH] */
			RegisterHam(Ham_Spawn, "player", "HamHook_Player_Spawn", true);
			
			/* [FAKEMETA] */
			register_forward(FM_SetClientKeyValue, "FMHook_SetClientKeyValue", false);
		}
	} else {
		new const szInstructions[] = {
			"\
				; Instruction for use:^n\
				; [Types]^n\
				; 1 - ip^n\
				; 2 - name^n\
				; 3 - steam^n\
				; 4 - flag^n\
				; 5 - team^n^n\
				; [Syntax]^n\
				; ^"Type^" ^"IP | Name | SteamId | Flag | Team | *(for modes [team|steam])^" \
				^"Team: TT | CT | ANY^" ^"Model name (without .mdl)^"^n^n\
				; [Example]^n\
				; ^"ip^" ^"127.0.0.1^" ^"CT^" ^"vip^"^n\
				; ^"steam^" ^"*^" ^"TT^" ^"sas^"^n\
				; ^"steam^" ^"steamid:0:1:123456^" ^"ANY^" ^"chicken^"\
			"
		};
		
		write_file(szFileModelsDir, szInstructions, -1);
	}

	replace(szFileModelsDir, charsmax(szFileModelsDir), "players", "weapons");
	
	new Trie:tRegisterWeaponDeploy = TrieCreate();
	new szWeaponClass[32];
	new szViewModel[MAX_MODEL_LENGTH], szWeaponModel[MAX_MODEL_LENGTH], szWorldModel[MAX_MODEL_LENGTH];
	new szOldWorldModel[MAX_MODEL_LENGTH];
	
	iFile = fopen(szFileModelsDir, "rt");
	if(iFile)	{
		while(!(feof(iFile)))	{
			fgets(iFile, szBuffer, charsmax(szBuffer));
			trim(szBuffer);

			if(!(szBuffer[0]) || szBuffer[0] == ';' || szBuffer[0] == '/' || szBuffer[0] == '#')
				continue;
			
			/*
			parse(szBuffer, 
				aData[MDL_TYPE],	charsmax(aData[MDL_TYPE]),
				aData[MDL_AUTH],	charsmax(aData[MDL_AUTH]),
				aData[MDL_VARIOUS],	charsmax(aData[MDL_VARIOUS]),
				aData[MDL_NAME],	charsmax(aData[MDL_NAME])
			);
			*/
			
			parse(szBuffer, szWeaponClass, charsmax(szWeaponClass), 
			szViewModel, charsmax(szViewModel), szWeaponModel, charsmax(szWeaponModel), 
			szWorldModel, charsmax(szWorldModel));			
			
			if(!TrieKeyExists(tRegisterWeaponDeploy, szWeaponClass))
			{
				TrieSetCell
				(
					tRegisterWeaponDeploy,
					szWeaponClass,
					RegisterHam(Ham_Item_Deploy, szWeaponClass, "ItemDeploy_Post", true)
				);
			}
			
			format(szViewModel, charsmax(szViewModel), "%/weapons/%s.mdl", szModelsDir, szViewModel);
			if(file_exists(szViewModel))
			{
				if(!g_tViewModels)
				{
					g_tViewModels = TrieCreate();
				}
				TrieSetCell(g_tViewModels, szWeaponClass, AllocString(szViewModel));
				precache_model(szViewModel);
			}
			
			format(szWeaponModel, charsmax(szWeaponModel), "%/weapons/%s.mdl", szModelsDir, szWeaponModel);
			if(file_exists(szWeaponModel))
			{
				if(!g_tWeaponModels)
				{
					g_tWeaponModels = TrieCreate();
				}
				TrieSetCell(g_tWeaponModels, szWeaponClass, AllocString(szWeaponModel));
				precache_model(szWeaponModel);
			}
			
			format(szWorldModel, charsmax(szWorldModel), "%/weapons/%s.mdl", szModelsDir, szWorldModel);
			if(file_exists(szWorldModel))
			{
				if(!g_tWorldModels)
				{
					g_tWorldModels = TrieCreate();
				}
				if(szWeaponClass[10] == 'n') // weapon_mp5navy
				{
					// replace(szWeaponClass, charsmax(szWeaponClass), "navy", "")
					szWeaponClass[10] = EOS;
				}
				formatex(szOldWorldModel, charsmax(szOldWorldModel), "models/w_%s.mdl", szWeaponClass[7]);
				if(!TrieKeyExists(g_tWorldModels, szOldWorldModel))
				{
					TrieSetString(g_tWorldModels, szOldWorldModel, szWorldModel);
					precache_model(szWorldModel);
				}
			}
		}
		
		fclose(iFile);
		TrieDestroy(tRegisterWeaponDeploy);
		
		if((g_iArrayPlayerModelSize = ArraySize(g_aPlayerModel))){
				/* [HAMSANDWICH] */			
			RegisterHam(Ham_Item_Deploy, aData[MDL_VARIOUS], "HamHook_Item_Deploy", true);
		}
	} else {
		new const szInstructions[] = {
			"\
				; Instruction for use:^n\
				; [Types]^n\
				; 1 - ip^n\
				; 2 - name^n\
				; 3 - steam^n\
				; 4 - flag^n\
				; 5 - team^n^n\
				; [Syntax]^n\
				; ^"Type^" ^"IP | Name | SteamId | Flag | Team | *(for modes [team|steam])^" \
				^"Old name mdl (without .mdl)^" ^"New name mdl (without .mdl)^"^n^n\
				; [Example]^n\
				; ^"ip^" ^"127.0.0.1^" ^"w_awp^" ^"w_new2016_awp^"^n\
				; ^"steam^" ^"*^" ^"v_m4a1^" ^"v_newnew_m4a1^"^n\
				; ^"steam^" ^"steamid:0:1:123456^" ^"v_knife^" ^"v_boxes^"\
			"
		};
		
		write_file(szFileModelsDir, szInstructions, -1);
	}
}

public plugin_end()	{
	ArrayDestroy(g_aPlayerModel);
	ArrayDestroy(g_aWeaponModel);
	if(g_tViewModels)
		TrieDestroy(g_tViewModels);
	if(g_tWeaponModels)
		TrieDestroy(g_tWeaponModels);
	if(g_tWorldModels)
		TrieDestroy(g_tWorldModels);
}

/*================================================================================
 [CLIENT]
=================================================================================*/
public client_putinserver(pId)	{
	if(/*is_user_bot(pId) || */is_user_hltv(pId))
		return PLUGIN_HANDLED;

	new aPlayerModelData[ENUM_DATA_MODELS_INFO];
	for(new iCount = 0; iCount < g_iArrayPlayerModelSize; iCount++)	{
		if(ArrayGetArray(g_aPlayerModel, iCount, aPlayerModelData))	{
			funcSetModels(pId, 0, aPlayerModelData);
		}
	}

	return PLUGIN_CONTINUE;
}

public client_disconnect(pId)	{
	if(g_iArrayPlayerModelSize)	{
		gp_bModel[pId] = false;
		
		gp_szModel[pId] = "";
		gp_szPersonalModels[pId][TEAM_T] = "";
		gp_szPersonalModels[pId][TEAM_CT] = "";
		
		remove_task(pId + TASK_ID_PLAYER_MODEL_FIXED);
	}
}

/*================================================================================
 [HAMSANDWICH]
=================================================================================*/
public HamHook_Player_Spawn(const pId)	{
	if(is_user_alive(pId))	{
		new iTeam = get_pdata_int(pId, m_iPlayerTeam, XO_PLAYER);
		if(gp_szPersonalModels[pId][iTeam][0] != '^0') FM_SetPlayerModel(pId, gp_szPersonalModels[pId][iTeam]);
	}
}

/*================================================================================
 [FAKEMETA]
=================================================================================*/
public FMHook_SetClientKeyValue(const pId, const szBuffer[], const szKey[])	{
	if(gp_bModel[pId] && equal(szKey, "model", 5))	{
		new szModel[MAX_SIZE_MDL_NAME]; FM_GetPlayerModel(pId, szModel, charsmax(szModel));
		
		if(!(equal(szModel, gp_szModel[pId])))
			FM_SetPlayerModel(pId, gp_szModel[pId]);
		
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

FM_GetPlayerModel(const pId, const szModel[], const iLen) return engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, pId), "model", szModel, iLen);

FM_SetPlayerModel(const pId, const szModel[]){
	copy(gp_szModel[pId], charsmax(gp_szModel[]), szModel);
	static Float: fGameTime, Float: fChangeTime; fGameTime = get_gametime();

	if(fGameTime - fChangeTime > 0.1)	{
		taskSetPlayerModelFixed(pId + TASK_ID_PLAYER_MODEL_FIXED);
		fChangeTime = fGameTime;
	} else {
		set_task((fChangeTime + 0.1) - fGameTime, "taskSetPlayerModelFixed", pId + TASK_ID_PLAYER_MODEL_FIXED);
		fChangeTime += 0.1;
	}
}

public taskSetPlayerModelFixed(pId)	{
	pId -= TASK_ID_PLAYER_MODEL_FIXED;

	engfunc(EngFunc_SetClientKeyValue, pId, engfunc(EngFunc_GetInfoKeyBuffer, pId), "model", gp_szModel[pId]);
	new szBuffer[MAX_SIZE_PL_MDL_DIR + MAX_SIZE_MDL_NAME * 2]; formatex(szBuffer, charsmax(szBuffer), "models/player/%s/%s.mdl", gp_szModel[pId], gp_szModel[pId]);
	set_pdata_int(pId, m_iModelIndexPlayer, engfunc(EngFunc_ModelIndex, szBuffer), XO_PLAYER);
	
	gp_bModel[pId] = true;
}

/*================================================================================
 [STOCK]
=================================================================================*/
bool: funcIsUserSteam(const pId)	{
	static dp_pointer;

	if(dp_pointer || (dp_pointer = get_cvar_pointer("dp_r_id_provider")))	{
		server_cmd("dp_clientinfo %d", pId);
		server_exec();
		return bool: (get_pcvar_num(dp_pointer) == 2);
	}

	return false;
}

// Распределение по типу модели, и сбор информации о моделях. 
stock funcSetModels(const pId, const iType, const aData[ENUM_DATA_MODELS_INFO])	{
	if(aData[MDL_AUTH][0] == '*')	{
		if(equal(aData[MDL_TYPE], "team", 4) || (equal(aData[MDL_TYPE], "steam", 5) && funcIsUserSteam(pId)))	{
			switch(aData[MDL_VARIOUS][0])	{
				/* [PLAYER] */
				case 'a':	{		/* [ANY] */
					formatex(gp_szPersonalModels[pId][TEAM_T], charsmax(gp_szPersonalModels[][]), aData[MDL_NAME]);
					formatex(gp_szPersonalModels[pId][TEAM_CT], charsmax(gp_szPersonalModels[][]), aData[MDL_NAME]);
				}
				case 't', 'T':	{	/* [TT] */
					formatex(gp_szPersonalModels[pId][TEAM_T], charsmax(gp_szPersonalModels[][]), aData[MDL_NAME]);
				}
				case 'c', 'C':	{	/* [CT] */
					formatex(gp_szPersonalModels[pId][TEAM_CT], charsmax(gp_szPersonalModels[][]), aData[MDL_NAME]);
				}
				
				///* [WEAPON] */
				//case 'w':	{	/* [w_] */
				//}
			}
		}
		
		#if defined DEBUG_LOGS
		log_amx("pId:%d^n\
			===========^nMDL_TYPE:%s^n\
			AUTH:%s^n\
			VARIOUS:%s^n\
			NAME:%s^n\
			TEAM_T:%s^n\
			TEAM_CT:%s\
			", pId, aData[MDL_TYPE],aData[MDL_AUTH], aData[MDL_VARIOUS], aData[MDL_NAME], gp_szPersonalModels[pId][TEAM_T], gp_szPersonalModels[pId][TEAM_CT]);
		#endif
		
		return PLUGIN_HANDLED;
	}

	if(equal(aData[MDL_TYPE], "ip", 2))	{
		new szIP[16]; get_user_ip(pId, szIP, charsmax(szIP), .without_port = 1);
		#if defined DEBUG_LOGS
		log_amx("IP: %s", szIP);
		#endif
		if(equal(aData[MDL_AUTH], szIP))	{
			if(equal(aData[MDL_VARIOUS], "any", 3))	{
				formatex(gp_szPersonalModels[pId][TEAM_T], charsmax(gp_szPersonalModels[][]), aData[MDL_NAME]);
				formatex(gp_szPersonalModels[pId][TEAM_CT], charsmax(gp_szPersonalModels[][]), aData[MDL_NAME]);
			} else formatex(gp_szPersonalModels[pId][(aData[MDL_VARIOUS][0] == 't' || aData[MDL_VARIOUS][0] == 'T') ? TEAM_T : TEAM_CT], charsmax(gp_szPersonalModels[][]), aData[MDL_NAME]);
		}
		
		return PLUGIN_HANDLED;
	}

	if(equal(aData[MDL_TYPE], "name", 4))	{
		new szName[32]; get_user_name(pId, szName, charsmax(szName));
		
		if(equal(aData[MDL_AUTH], szName))	{
			if(equal(aData[MDL_VARIOUS], "any", 3))	{
				formatex(gp_szPersonalModels[pId][TEAM_T], charsmax(gp_szPersonalModels[][]), aData[MDL_NAME]);
				formatex(gp_szPersonalModels[pId][TEAM_CT], charsmax(gp_szPersonalModels[][]), aData[MDL_NAME]);
			} else formatex(gp_szPersonalModels[pId][(aData[MDL_VARIOUS][0] == 't' || aData[MDL_VARIOUS][0] == 'T') ? TEAM_T : TEAM_CT], charsmax(gp_szPersonalModels[][]), aData[MDL_NAME]);
		}
		
		return PLUGIN_HANDLED;
	}

	if(equal(aData[MDL_TYPE], "steam", 5))	{
		new szSteamId[35]; get_user_authid(pId, szSteamId, charsmax(szSteamId));
		strtolower(szSteamId);
		#if defined DEBUG_LOGS
		log_amx("STEAMID: %s", szSteamId);
		#endif
		if(equali(aData[MDL_AUTH], szSteamId))	{
			if(equal(aData[MDL_VARIOUS], "any", 3))	{
				formatex(gp_szPersonalModels[pId][TEAM_T], charsmax(gp_szPersonalModels[][]), aData[MDL_NAME]);
				formatex(gp_szPersonalModels[pId][TEAM_CT], charsmax(gp_szPersonalModels[][]), aData[MDL_NAME]);
			} else formatex(gp_szPersonalModels[pId][(aData[MDL_VARIOUS][0] == 't' || aData[MDL_VARIOUS][0] == 'T') ? TEAM_T : TEAM_CT], charsmax(gp_szPersonalModels[][]), aData[MDL_NAME]);
		}
		
		return PLUGIN_HANDLED;
	}
	
	if(equal(aData[MDL_TYPE], "flag", 4))	{
		if(get_user_flags(pId) & read_flags(aData[MDL_AUTH]))	{
			if(equal(aData[MDL_VARIOUS], "any", 3))	{
				formatex(gp_szPersonalModels[pId][TEAM_T], charsmax(gp_szPersonalModels[][]), aData[MDL_NAME]);
				formatex(gp_szPersonalModels[pId][TEAM_CT], charsmax(gp_szPersonalModels[][]), aData[MDL_NAME]);
			} else formatex(gp_szPersonalModels[pId][(aData[MDL_VARIOUS][0] == 't' || aData[MDL_VARIOUS][0] == 'T') ? TEAM_T : TEAM_CT], charsmax(gp_szPersonalModels[][]), aData[MDL_NAME]);
		}
	}
		
	return PLUGIN_CONTINUE;
}

// Я не знаю как на этом этапе проверять, соответствует ли по условию. или нет
public ItemDeploy_Post(wEnt)
{
	if(wEnt <= 0) return;

	const m_pPlayer = 41;

	new id = get_pdata_cbase(wEnt, m_pPlayer, .linuxdiff = 4);
	if(get_user_flags(id) & g_iAccess)
	{
		new iszNewModel, szWeaponClass[32];
		pev(wEnt, pev_classname, szWeaponClass, charsmax(szWeaponClass));
		if(g_tViewModels)
		{
			if(TrieGetCell(g_tViewModels, szWeaponClass, iszNewModel))
			{
				set_pev(id, pev_viewmodel, iszNewModel);
			}
		}
		if(g_tWeaponModels)
		{
			if(TrieGetCell(g_tWeaponModels, szWeaponClass, iszNewModel))
			{
				set_pev(id, pev_weaponmodel, iszNewModel);
			}
		}
	}
}
