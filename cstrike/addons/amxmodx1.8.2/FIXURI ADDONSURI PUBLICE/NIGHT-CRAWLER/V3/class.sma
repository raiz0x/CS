#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
 
#include <nightcrawler>

enum _:NightClassData {
	ClassName[32],
	ClassDesc[32],
	ClassHP,
	ClassSpeed,
	ClassGrav
}

new Array:g_NightClasses, 
	g_iTotalNightClasses, 
	g_NightSelectClassFwd

new g_FirstSpawn[33], 
	g_CurNightClass[33], 
	g_NextNightClass[33]

public plugin_precache() {

	register_plugin("NightCrawler Rase", "1.0", "Filip. & KronoS # GG") 

	g_NightClasses = ArrayCreate(NightClassData)
}  

public plugin_init() {

	if(!g_iTotalNightClasses)
		set_fail_state("This plugin can't run because no nightcrawler classes were found!")
	
	RegisterHam(Ham_Spawn, "player", "Event_PlayerSpawn", 1)
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	
	register_clcmd("say /class", "Func_CmdChangeClass")
	register_clcmd("say_team /class", "Func_CmdChangeClass")
	
	g_NightSelectClassFwd = CreateMultiForward("night_class_selected", ET_IGNORE, FP_CELL, FP_CELL)
	
	set_task(120.0, "Func_DisplayInfo", _, _, _, "b")
}

public plugin_natives() {
	register_native("register_night_class", "native_register_night_class")
	register_native("get_user_night_class", "native_get_user_night_class")
	register_native("set_user_night_class", "native_set_user_night_class")
}

public client_putinserver(playerid) {

	g_CurNightClass[playerid] = 1
	g_NextNightClass[playerid] = 1
	g_FirstSpawn[playerid] = 1
}

public Event_PlayerSpawn(playerid) {
	
	if(!is_user_alive(playerid) || __get_user_team(playerid) != Night) return true

	if(g_FirstSpawn[playerid]) {	
		g_FirstSpawn[playerid] = 0
		Func_ShowNightClasses(playerid, .page = 0)
	}
	
	g_CurNightClass[playerid] = g_NextNightClass[playerid]
	
	new eItemData[NightClassData]
	new iClassIndex = g_CurNightClass[playerid] - 1
	ArrayGetArray(g_NightClasses, iClassIndex, eItemData)
	
	set_user_health(playerid, eItemData[ClassHP])
	set_user_gravity(playerid, Float:eItemData[ClassGrav])

	return true
}

public Event_CurWeapon(playerid) {
	
	if(!is_user_alive(playerid) || __get_user_team(playerid) != Night) return true
	
	new eItemData[NightClassData]
	new iClassIndex = g_CurNightClass[playerid] - 1
	ArrayGetArray(g_NightClasses, iClassIndex, eItemData)
	
	set_pev(playerid, pev_maxspeed, float(eItemData[ClassSpeed]))

	return true
}

public Func_CmdChangeClass(playerid) Func_ShowNightClasses(playerid, .page = 0 ) 
public Func_DisplayInfo() client_print(0, print_chat, "Type /class to change your nightcrawler class")

Func_ShowNightClasses(playerid, page) {
	
	if(!g_iTotalNightClasses) return true
	
	page = clamp(page, 0, (g_iTotalNightClasses - 1) / 7)
	
	new iMenu = menu_create("\rChoose a Nightcrawler class:", "Handler_ClassesMenu")
	
	new eItemData[NightClassData], szItem[64], szNum[3]
	
	for(new class = 0; class < g_iTotalNightClasses; class++) {
		
		ArrayGetArray(g_NightClasses, class, eItemData)
		
		if(class == (g_NextNightClass[playerid] - 1)) formatex(szItem, charsmax(szItem), "\d%s [%s]", eItemData[ClassName], eItemData[ClassDesc])
		else formatex(szItem, charsmax(szItem), "%s \y[%s]", eItemData[ClassName], eItemData[ClassDesc])
		
		num_to_str(class, szNum, charsmax(szNum))
		
		menu_additem(iMenu, szItem, szNum)
	}
	
	menu_display(playerid, iMenu, page)

	return true
}

public Handler_ClassesMenu(playerid, menu, item) {
	
	if(item == MENU_EXIT) {
		menu_destroy(menu)
		return
	}
	
	new iAccess, szNum[3], hCallback
	menu_item_getinfo(menu, item, iAccess, szNum, charsmax(szNum), _, _, hCallback)
	
	new iClassIndex = str_to_num(szNum)
	
	new eItemData[NightClassData]
	ArrayGetArray(g_NightClasses, iClassIndex, eItemData)
	
	g_NextNightClass[playerid] = str_to_num(szNum) + 1
	
	client_print(playerid, print_chat, "Your nightcrawler class after the next spawn will be %", eItemData[ClassName])
	client_print(playerid, print_chat, "HP: %i | Speed: %i | Gravity: %i", eItemData[ClassHP], eItemData[ClassSpeed], floatround(eItemData[ClassGrav] * 800.0))
	
	menu_destroy(menu)
	
	new iReturn
	ExecuteForward(g_NightSelectClassFwd, iReturn, playerid, iClassIndex)
}

public native_register_night_class(Plugin, iParams) {
	
	new eClassData[NightClassData]
	
	get_string(1, eClassData[ClassName], charsmax(eClassData[ClassName]))
	get_string(2, eClassData[ClassDesc], charsmax(eClassData[ClassDesc]))
	
	eClassData[ClassHP] = get_param(3)
	eClassData[ClassSpeed] = get_param(4)
	eClassData[ClassGrav] = get_param(5)
	
	ArrayPushArray(g_NightClasses, eClassData)
	
	g_iTotalNightClasses++
	
	return (g_iTotalNightClasses - 1)
}

public native_get_user_night_class(playerid) return g_CurNightClass[playerid]

public native_set_user_night_class(playerid, class) {
	
	if(class < 0 || class >= g_iTotalNightClasses) return 0
	
	g_NextNightClass[playerid] = class
	return 1
}
