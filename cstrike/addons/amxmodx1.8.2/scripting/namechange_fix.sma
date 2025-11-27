#include <amxmodx>
#include <cromchat>
#include <fakemeta>

#define PLUGIN_VERSION "1.1"

new g_pAdminFlag, g_pMaxChanges
new g_iAdminFlag, g_iMaxChanges
new g_iChanges[33]

public plugin_init()
{
	register_plugin("No Name Change", PLUGIN_VERSION, "OciXCrom")
	register_cvar("CRXNoNameChange", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	register_forward(FM_ClientUserInfoChanged, "OnUserInfoChanged")
	register_dictionary("NoNameChange.txt")
	g_pAdminFlag = register_cvar("nnc_admin_flag", "")
	g_pMaxChanges = register_cvar("nnc_max_changes", "0")
	CC_SetPrefix("&x04[NNC]")
}

public plugin_cfg()
{
	new szFlag[2]
	get_pcvar_string(g_pAdminFlag, szFlag, charsmax(szFlag))
	g_iAdminFlag = read_flags(szFlag)
	g_iMaxChanges = get_pcvar_num(g_pMaxChanges)
}

public client_putinserver(id)
{
	if(g_iMaxChanges)
		g_iChanges[id] = 0
}

public OnUserInfoChanged(id)
{
	if(g_iAdminFlag && get_user_flags(id) & g_iAdminFlag)
		return FMRES_IGNORED
	
	static const szName[] = "name"
	static szOldName[32], szNewName[32]
	pev(id, pev_netname, szOldName, charsmax(szOldName))
	
	if(szOldName[0])
	{
		get_user_info(id, szName, szNewName, charsmax(szNewName))
		
		if(!equal(szOldName, szNewName))
		{
			if(g_iChanges[id] < g_iMaxChanges)
			{
				g_iChanges[id]++
				
				new g_iChangesLeft = g_iMaxChanges - g_iChanges[id]
				CC_SendMessage(id, "%L", id, !g_iChangesLeft ? "NNC_CHANGE_ZERO" : g_iChangesLeft == 1 ? "NNC_CHANGE_ONE" : "NNC_CHANGE_MORE", g_iChangesLeft)
				return FMRES_IGNORED
			}
			
			set_user_info(id, szName, szOldName)
			CC_SendMessage(id, "%L", id, "NNC_MESSAGE")
			return FMRES_HANDLED
		}
	}
	
	return FMRES_IGNORED
}
