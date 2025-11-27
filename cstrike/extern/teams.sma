#pragma tabsize 0

#include <amxmodx>
#include <cstrike>
#include <fun>

#if AMXX_VERSION_NUM < 183
	#include <api_colorchat>
#endif

enum
{
	EVO_TEAM_1 = 1,
	EVO_TEAM_2 = 2,
	EVO_TEAM_3 = 3,
	EVO_TEAM_1_2 = 4
}

enum
{
	EVO_IS_DEAD = 0,
	EVO_IS_ALIVE = 1
}

enum
{
	EVO_NON_BOT = 1
}

enum
{
	EVO_NON_HLTV = 1
}

#define EVO_GIVE_STEAM_BONUS_NEW_ROUND_TASK 1.5
#define EVO_ID_TASK 93715

new evo_cvarz[5], bool:evo_boolz[1], evo_maxpl, evo_stringz[1][35]

public plugin_init()
{
	evo_maxpl = get_maxplayers()

	register_event("HLTV", "evo_new_round", "a", "1=0", "2=0")
	register_event("DeathMsg", "evo_death_msg", "a")

	register_logevent("evo_end_round", 2, "1=Round_End")

	evo_cvarz[0] = register_cvar("evo_chat_tag", "^4[FURIEN.CSBLACKDEVIL.COM]^1")
	get_pcvar_string(evo_cvarz[0], evo_stringz[0], charsmax(evo_stringz[]))

	evo_cvarz[1] = register_cvar("evo_steam_hp", "25")
	evo_cvarz[2] = register_cvar("evo_steam_ap", "25")
	evo_cvarz[3] = register_cvar("evo_steam_cash", "2500")

	evo_cvarz[4] = register_cvar("evo_last_cash", "3000")
}

public evo_end_round()
{
	evo_boolz[0] = true
}
public evo_new_round()
{
	evo_boolz[0] = false

	for(new evo_id = 1; evo_id <= evo_maxpl; evo_id++)
	{
		if(is_user_bot(evo_id) || is_user_hltv(evo_id))
		{
			continue
		}

		if(!is_user_alive(evo_id))
		{
			continue
		}

		if(!evo_check_player_steam(evo_id))
		{
			continue
		}

		if(task_exists(evo_id + EVO_ID_TASK))
		{
			remove_task(evo_id + EVO_ID_TASK)
		}

		set_task(EVO_GIVE_STEAM_BONUS_NEW_ROUND_TASK, "EVO_STEAM_BONUS_TASK", evo_id + EVO_ID_TASK)

		break
	}
}
public EVO_STEAM_BONUS_TASK(evo_id)
{
	if(!task_exists(evo_id))
	{
		remove_task(evo_id)
		return
	}
	
	static evo_id2; evo_id2 = evo_id - EVO_ID_TASK
	if(!is_user_alive(evo_id2))
	{
		remove_task(evo_id2)
		return
	}

	client_print_color(evo_id, print_team_default, "%s - BECAUSE YOU ARE^4 STEAM ON^1 YOU GOT: [^4 %dHP^1 +^4 %dAP^1 +^4 %d$^1 ]",
		evo_get_chat_tag(), get_pcvar_num(evo_cvarz[1]), get_pcvar_num(evo_cvarz[2]), get_pcvar_num(evo_cvarz[3]))

	set_user_health(evo_id, get_user_health(evo_id) + get_pcvar_num(evo_cvarz[1]))
	set_user_armor(evo_id, get_user_armor(evo_id) + get_pcvar_num(evo_cvarz[2]))
	cs_set_user_money(evo_id, cs_get_user_money(evo_id) + get_pcvar_num(evo_cvarz[3]))
}
public evo_death_msg()
{
	if(evo_boolz[0])
	{
		return
	}

	if(evo_get_players(EVO_TEAM_1, EVO_IS_ALIVE) == 1)
	{
		static evo_last_furien; evo_last_furien = evo_get_last_id(EVO_TEAM_1, EVO_IS_ALIVE)

		client_print_color(0, evo_last_furien, "%s - ^"^3%s^1^" RECEIVED^4 %d$^1 BONUS BECAUSE IS THE^3 LAST FURIEN^1 !", evo_get_chat_tag(),
		 get_user_nick(evo_last_furien), get_pcvar_num(evo_cvarz[4]))

		cs_set_user_money(evo_last_furien, cs_get_user_money(evo_last_furien) + get_pcvar_num(evo_cvarz[4]))
	}

	if(evo_get_players(EVO_TEAM_2, EVO_IS_ALIVE) == 1)
	{
		static evo_last_anti_furien; evo_last_anti_furien = evo_get_last_id(EVO_TEAM_2, EVO_IS_ALIVE)

		client_print_color(0, evo_last_anti_furien, "%s - ^"^3%s^1^" RECEIVED^4 %d$^1 BONUS BECAUSE IS THE^3 LAST ANTI-FURIEN^1 !", evo_get_chat_tag(),
		 get_user_nick(evo_last_anti_furien), get_pcvar_num(evo_cvarz[4]))

		cs_set_user_money(evo_last_anti_furien, cs_get_user_money(evo_last_anti_furien) + get_pcvar_num(evo_cvarz[4]))
	}
}

stock evo_get_chat_tag()
{
	return evo_stringz[0]
}
stock get_user_nick(const evo_id)
{
	static evo_nick[33];get_user_name(evo_id, evo_nick, charsmax(evo_nick))
	return evo_nick
}
stock evo_get_last_id(const evo_team, const evo_alive, const evo_exclude_botz = EVO_NON_BOT, const evo_exclude_hltv = EVO_NON_HLTV)
{
	clamp(evo_team, 1, 3)
	clamp(evo_alive, 0, 1)
	clamp(evo_exclude_botz, 0, EVO_NON_BOT)
	clamp(evo_exclude_hltv, 0, EVO_NON_HLTV)

	static evo_playerID; evo_playerID = 0
	for(new evo_id = 1; evo_id <= evo_maxpl; evo_id++)
	{
		if(evo_exclude_botz == EVO_NON_BOT && is_user_bot(evo_id))
		{
			continue
		}

		if(evo_exclude_hltv == EVO_NON_HLTV && is_user_hltv(evo_id))
		{
			continue
		}

		switch(evo_alive)
		{
			case EVO_IS_ALIVE:
			{
				if(!is_user_alive(evo_id))
				{
					continue
				}
			}
			case EVO_IS_DEAD:
			{
				if(is_user_alive(evo_id))
				{
					continue
				}
			}
		}

		switch(evo_team)
		{
			case EVO_TEAM_1:
			{
				if(get_user_team(evo_id) == EVO_TEAM_1)
				{
					evo_playerID = evo_id
				}
			}
			case EVO_TEAM_2:
			{
				if(get_user_team(evo_id) == EVO_TEAM_2)
				{
					evo_playerID = evo_id
				}
			}
			case EVO_TEAM_3:
			{
				if(get_user_team(evo_id) == EVO_TEAM_3)
				{
					evo_playerID = evo_id
				}
			}
		}

		break
	}
	
	return evo_playerID
}
stock evo_get_players(const evo_team, const evo_alive, const evo_exclude_botz = EVO_NON_BOT, const evo_exclude_hltv = EVO_NON_HLTV)
{
	clamp(evo_team, 1, EVO_TEAM_1_2)
	clamp(evo_alive, 0, 1)
	clamp(evo_exclude_botz, 0, EVO_NON_BOT)
	clamp(evo_exclude_hltv, 0, EVO_NON_HLTV)

	static evo_count; evo_count = 0
	for(new evo_id = 1; evo_id <= evo_maxpl; evo_id++)
	{
		if(evo_exclude_botz == EVO_NON_BOT && is_user_bot(evo_id))
		{
			continue
		}

		if(evo_exclude_hltv == EVO_NON_HLTV && is_user_hltv(evo_id))
		{
			continue
		}

		switch(evo_alive)
		{
			case EVO_IS_ALIVE:
			{
				if(!is_user_alive(evo_id))
				{
					continue
				}
			}
			case EVO_IS_DEAD:
			{
				if(is_user_alive(evo_id))
				{
					continue
				}
			}
		}

		switch(evo_team)
		{
			case EVO_TEAM_1:
			{
				if(get_user_team(evo_id) == EVO_TEAM_1)
				{
					evo_count++
				}
			}
			case EVO_TEAM_2:
			{
				if(get_user_team(evo_id) == EVO_TEAM_2)
				{
					evo_count++
				}
			}
			case EVO_TEAM_3:
			{
				if(get_user_team(evo_id) == EVO_TEAM_3)
				{
					evo_count++
				}
			}
			case EVO_TEAM_1_2:
			{
				if(get_user_team(evo_id) == EVO_TEAM_1 || get_user_team(evo_id) == EVO_TEAM_2)
				{
					evo_count++
				}
			}
		}

		break
	}

	return evo_count
}
stock bool:evo_check_player_steam(const evo_id)
{
	if(!cvar_exists("dp_r_id_provider"))
	{
		server_print("[STOCK]: 'evo_check_player_steam' error")
		pause("a")
		return false
	}
    static dp_pointer
    if(dp_pointer || (dp_pointer = get_cvar_pointer("dp_r_id_provider")))
    {
        server_cmd("dp_clientinfo %d", evo_id)
        server_exec()
        return (get_pcvar_num(dp_pointer) == 2) ? true : false
    }
    return false
}
