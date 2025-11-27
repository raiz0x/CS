#include <amxmodx>
#include <cstrike>
#include <hamsandwich>

#define MAX_MODELS 32

enum _:Data
{
	Flags[32],
	TModel[32],
	CTModel[32]
}

new const g_szModels[][Data] = 
{
	{ "m", "tmodel1", "ctmodel1" },
	{ "n", "tmodel2", "ctmodel2" },
	{ "o", "tmodel3", "ctmodel3" },
	{ "p", "tmodel4", "ctmodel4" }
}

new g_iFlags[MAX_MODELS]

public plugin_init()
{
	register_plugin("Admin Models", "1.0", "OciXCrom")
	RegisterHam(Ham_Spawn, "player", "OnPlayerSpawn", 1)
}

public plugin_precache()
{
	for(new i; i < sizeof(g_szModels); i++)
	{
		precache_player_model(g_szModels[i][TModel])
		precache_player_model(g_szModels[i][CTModel])
		g_iFlags[i] = read_flags(g_szModels[i][Flags])
	}
}

public OnPlayerSpawn(id)
{
	if(!is_user_alive(id))
		return
	
	new bool:bMatch
		
	for(new i, iFlags = get_user_flags(id); i < sizeof(g_szModels); i++)
	{
		if((iFlags & g_iFlags[i]) == g_iFlags[i])
		{
			cs_set_user_model(id, g_szModels[i][cs_get_user_team(id) == CS_TEAM_CT ? CTModel : TModel])
			bMatch = true
			break
		}
	}
	
	if(!bMatch)
		cs_reset_user_model(id)
}	
	
precache_player_model(szModel[])
{
    static szFile[128]
    formatex(szFile, charsmax(szFile), "models/player/%s/%s.mdl", szModel, szModel)
    precache_model(szFile)
    replace(szFile, charsmax(szFile), ".mdl", "T.mdl")
    
    if(file_exists(szFile))
        precache_model(szFile)
}
