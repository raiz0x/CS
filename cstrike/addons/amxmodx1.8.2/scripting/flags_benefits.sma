#include <amxmodx>
#include <fun>
#include <cstrike>

#define PLUGIN "Furien VIP Benefits"
#define VERSION "0.1"

enum e_Data 
{
	MONEY,
	HP, 
	AP,
	FL[15]
}

new g_iBenefits[][e_Data] =
{
/**	MONEY		HEALTH		ARMOR		FLAG 	**/
	6000,		60,		60,		"a",
	5500,		50,		50,		"b",
	5000,		45,		45,		"c",
	4000,		35,		35,		"d",
	3000,		25,		25,		"e"
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, "FaTzZu" );
	
	register_event("DeathMsg", "evDeathMsg", "a");
}

public evDeathMsg( )
{
	new iKiller = read_data(1);
	new iVictim = read_data(2);
	
	if(iKiller == iVictim || !is_user_alive(iKiller))
		return;
	
	if(get_user_flags(iKiller) & read_flags(g_iBenefits[iKiller][FL]))
	{
		cs_set_user_money(iKiller, cs_get_user_money(iKiller) + g_iBenefits[iKiller][MONEY])
		set_user_health(iKiller, get_user_health(iKiller) + g_iBenefits[iKiller][HP])
		set_user_armor(iKiller, get_user_armor(iKiller) + g_iBenefits[iKiller][AP])
	}
}
