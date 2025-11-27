#include amxmodx
#include amxmisc
#include fakemeta_util
#include hamsandwich
#include CC_Chat

#define PLUGIN_PREFIX "[DeathRun Race]"

//#define PLUGIN_KEY "89.44.44.44"

#define PORTAL_FLAG 0xAC

#define COLOR_GREEN (0x04)
#define COLOR_TEAM (0x03)
#define COLOR_NORMAL (0x01)

//native dr_set_user_lifes(Client, Lifes);
//native dr_get_user_lifes(Client);

enum Teams
{
	TEAM_UNASSIGNED,
	TEAM_TERRORIST,
	TEAM_CT,
	TEAM_SPECTATOR
};

const OFFSET_TEAM = 114;

new g_Invoker[33];
new g_Victim[33];

new bool:g_Precached = false;

new bool:g_Race[33];

new bool:g_Enabled = false;

new Float:g_PortalOrigin[3];

new g_Entity;

Teams:GetPureTeam(Client)
{
	return Teams:get_pdata_int(Client, OFFSET_TEAM);
}

CountAlivePlayers(Teams:Team)
{
	static Iterator, Count;

	Count = 0;

	for (Iterator = 1; Iterator <= get_maxplayers(); Iterator++)
	{
		if (is_user_alive(Iterator) && !is_user_bot(Iterator) && !is_user_hltv(Iterator) && GetPureTeam(Iterator) == Team)
		{
			Count++;
		}
	}

	return Count;
}

public plugin_init()
{
	register_plugin("DeathRun Race", "1.0", "Hattrick (Claudiu HKS)");

	register_logevent("RoundStart", 2, "1=Round_Start");
	register_logevent("RoundEnd", 2, "1=Round_End");

	RegisterHam(Ham_Think, "info_target", "OnThink");

	register_event("ResetHUD", "ResetHUD", "b");

	register_concmd("amx_set_portal", "CommandPortal", ADMIN_RCON, "- sets a map portal");

	set_task(0.7, "CheckLoop", .flags = "b");

#if defined PLUGIN_KEY
	new Address[32];

	get_user_ip(0, Address, sizeof(Address) - 1, 1);

	if (!equal(Address, PLUGIN_KEY))
	{
		set_fail_state("Cannot authorize the use!");
	}
#endif
}

public ResetHUD(Client)
{
	static Origin[3];

	if (g_Race[Client])
	{
		get_user_origin(Client, Origin);

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_TELEPORT);
		write_coord(Origin[0]);
		write_coord(Origin[1]);
		write_coord(Origin[2]);
		message_end();
	}
}

bool:IsSomeonesVictim(Client)
{
	static Iterator;

	for (Iterator = 1; Iterator <= get_maxplayers(); Iterator++)
	{
		if (g_Race[Iterator] && g_Race[Client] && g_Victim[Iterator] == Client)
		{
			return true;
		}
	}

	return false;
}

bool:IsSomeonesInvoker(Client)
{
	static Iterator;

	for (Iterator = 1; Iterator <= get_maxplayers(); Iterator++)
	{
		if (g_Race[Iterator] && g_Race[Client] && g_Invoker[Iterator] == Client)
		{
			return true;
		}
	}

	return false;
}

public CheckLoop()
{
	static Iterator, VictimName[32], InvokerName[32];

	if (g_Enabled && pev_valid(g_Entity))
	{
		for (Iterator = 1; Iterator <= get_maxplayers(); Iterator++)
		{
			if (is_user_alive(Iterator) && GetPureTeam(Iterator) == TEAM_CT && g_Race[Iterator] && g_Invoker[Iterator] && g_Race[g_Invoker[Iterator]] && IsSomeonesVictim(Iterator) && fm_entity_range(Iterator, g_Entity) < 240 && fm_is_visible(Iterator, g_PortalOrigin))
			{
				//dr_set_user_lifes(Iterator, dr_get_user_lifes(Iterator) + 1);

				get_user_name(Iterator, VictimName, sizeof(VictimName) - 1);

				get_user_name(g_Invoker[Iterator], InvokerName, sizeof(InvokerName) - 1);

				set_hudmessage(0, 200, 0, -1.0, 0.2, 2, 0.4, 6.0, 0.03, 0.03, 4);

				show_hudmessage(0, "%s a castigat cursa cu %s,^nsi a primit o viata!", VictimName, InvokerName);

				g_Race[Iterator] = false;

				g_Race[g_Invoker[Iterator]] = false;

				g_Victim[g_Invoker[Iterator]] = 0;

				g_Invoker[Iterator] = 0;

				g_Victim[Iterator] = 0;
			}

			if (is_user_alive(Iterator) && GetPureTeam(Iterator) == TEAM_CT && g_Race[Iterator] && g_Victim[Iterator] && g_Race[g_Victim[Iterator]] && IsSomeonesInvoker(Iterator) && fm_entity_range(Iterator, g_Entity) < 240 && fm_is_visible(Iterator, g_PortalOrigin))
			{
				//dr_set_user_lifes(Iterator, dr_get_user_lifes(Iterator) + 1);

				get_user_name(Iterator, InvokerName, sizeof(InvokerName) - 1);

				get_user_name(g_Victim[Iterator], VictimName, sizeof(VictimName) - 1);

				set_hudmessage(0, 200, 0, -1.0, 0.2, 2, 0.4, 6.0, 0.03, 0.03, 4);

				show_hudmessage(0, "%s a castigat cursa cu %s,^nsi a primit o viata!", InvokerName, VictimName);

				g_Race[Iterator] = false;

				g_Race[g_Victim[Iterator]] = false;

				g_Invoker[g_Victim[Iterator]] = 0;

				g_Victim[g_Invoker[Iterator]] = 0;

				g_Invoker[Iterator] = 0;

				g_Victim[Iterator] = 0;
			}
		}
	}
}

public CommandPortal(Admin, Level, Command)
{
	if (!cmd_access(Admin, Level, Command, 1))
	{
		return PLUGIN_HANDLED;
	}

	static File, Buffer[128], Map[32], Configurations[64], Float:Origin[3];

	get_localinfo("amxx_configsdir", Configurations, sizeof(Configurations) - 1);

	get_mapname(Map, sizeof(Map) - 1);

	formatex(Buffer, sizeof(Buffer) - 1, "%s/Portals/%s.Portal.ini", Configurations, Map);

	pev(Admin, pev_origin, Origin);

	File = fopen(Buffer, "w+");

	if (File)
	{
		fprintf(File, "%f %f %f", Origin[0], Origin[1], Origin[2]);

		fclose(File);
	}

	plugin_precache();

	console_print(Admin, "Done, portal has been set!");

	return PLUGIN_HANDLED;
}

public RoundStart()
{
	static Iterator;

	for (Iterator = 1; Iterator <= get_maxplayers(); Iterator++)
	{
		g_Race[Iterator] = false;

		g_Invoker[Iterator] = g_Victim[Iterator] = 0;
	}
}

public RoundEnd()
{
	static Iterator;

	for (Iterator = 1; Iterator <= get_maxplayers(); Iterator++)
	{
		g_Race[Iterator] = false;

		g_Invoker[Iterator] = g_Victim[Iterator] = 0;
	}
}

public plugin_precache()
{
	static Map[32], Buffer[128], Configurations[64], File, Origin[3][16], Iterator;

	get_mapname(Map, sizeof(Map) - 1);

	if (!g_Precached)
	{
		precache_model("models/gate2.mdl");
	}

	get_localinfo("amxx_configsdir", Configurations, sizeof(Configurations) - 1);

	formatex(Buffer, sizeof(Buffer) - 1, "%s/Portals", Configurations);

	if (!dir_exists(Buffer))
	{
		mkdir(Buffer);
	}

	formatex(Buffer, sizeof(Buffer) - 1, "%s/Portals/%s.Portal.ini", Configurations, Map);

	File = fopen(Buffer, "r");

	if (File)
	{
		while (!feof(File))
		{
			fgets(File, Buffer, sizeof(Buffer) - 1);

			trim(Buffer);

			if (strlen(Buffer))
			{
				parse(Buffer, Origin[0], sizeof(Origin[]) - 1, Origin[1], sizeof(Origin[]) - 1, Origin[2], sizeof(Origin[]) - 1);

				for (Iterator = 0; Iterator < sizeof(Origin); Iterator++)
				{
					g_PortalOrigin[Iterator] = str_to_float(Origin[Iterator]);

					if (Iterator == 2)
					{
						g_PortalOrigin[Iterator] += 75.0;
					}
				}
			}
		}

		fclose(File);

		if (pev_valid(g_Entity))
		{
			engfunc(EngFunc_RemoveEntity, g_Entity);
		}

		g_Entity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));

		if (pev_valid(g_Entity))
		{
			engfunc(EngFunc_SetOrigin, g_Entity, g_PortalOrigin);
			engfunc(EngFunc_SetModel, g_Entity, "models/gate2.mdl");

			set_pev(g_Entity, pev_iuser4, PORTAL_FLAG);
			set_pev(g_Entity, pev_nextthink, get_gametime() + 0.05);

			g_Enabled = true;
		}
	}
}

public OnThink(Entity)
{
	if (pev_valid(Entity) && pev(Entity, pev_iuser4) == PORTAL_FLAG)
	{
		static Float:Angles[3];

		pev(Entity, pev_angles, Angles);

		Angles[1] += 5.0;

		if (Angles[1] > 360.0)
		{
			Angles[1] = 0.0;
		}

		set_pev(Entity, pev_angles, Angles);
		set_pev(Entity, pev_nextthink, get_gametime() + 0.05);
	}
}

public client_command(Client)
{
	if (is_user_connected(Client))
	{
		static Command[16], String[32], Argument[16], Menu, Name[32], Index[4], Iterator;

		read_args(String, sizeof(String) - 1);

		read_argv(0, Command, sizeof(Command));

		remove_quotes(String);

		parse(String, Argument, sizeof(Argument) - 1);

		if ((equali(Command, "Say") || equali(Command, "Say_Team")) && (equali(Argument, "Race") || equali(Argument, "/Race")))
		{
			if (!g_Enabled)
			{
				ColorChatSpecial(Client, true, "Race is not enabled on this map!");
			}

			else if (g_Race[Client])
			{
				ColorChatSpecial(Client, true, "You are already into a race!");
			}

			else if (!is_user_alive(Client))
			{
				ColorChatSpecial(Client, true, "You should be alive!");
			}

			else if (GetPureTeam(Client) != TEAM_CT)
			{
				ColorChatSpecial(Client, true, "You should be Counter-Terrorist!");
			}

			else if (CountAlivePlayers(TEAM_CT) < 2)
			{
				ColorChatSpecial(Client, true, "There are not enough Counter-Terrorists!");
			}

			else
			{
				Menu = menu_create("Pick a target", "_MenuHandler");

				for (Iterator = 1; Iterator <= get_maxplayers(); Iterator++)
				{
					if (is_user_alive(Iterator) && Iterator != Client && !is_user_bot(Iterator) && !is_user_hltv(Iterator))
					{
						get_user_name(Iterator, Name, sizeof(Name) - 1);

						num_to_str(Iterator, Index, sizeof(Index) - 1);

						menu_additem(Menu, Name, Index);
					}
				}

				menu_display(Client, Menu);
			}
		}
	}
}

PureMessageOne(To, Message, Byte, String[])
{
	message_begin(MSG_ONE_UNRELIABLE, Message, _, To);
	write_byte(Byte);
	write_string(String);
	message_end();
}

ColorChatSpecial(To, bool:GrayOrTeamColor, What[], any:...)
{
	static TaggedBuffer[256], Buffer[256], Message, Iterator, MaximumClients;

	if (!Message)
	{
		Message = get_user_msgid("SayText");
	}

	if (!MaximumClients)
	{
		MaximumClients = get_maxplayers();
	}

	vformat(Buffer, sizeof(Buffer) - 1, What, 3);

	formatex(TaggedBuffer, sizeof(TaggedBuffer), "%c%s%c %s", COLOR_GREEN, PLUGIN_PREFIX, COLOR_NORMAL, Buffer);

	if (is_user_connected(To))
	{
		if (!is_user_bot(To) && !is_user_hltv(To))
		{
			PureMessageOne(To, Message, GrayOrTeamColor ? MaximumClients + 1 : To, TaggedBuffer);
		}
	}

	else
	{
		for (Iterator = 1; Iterator <= MaximumClients; Iterator++)
		{
			if (is_user_connected(Iterator) && !is_user_bot(Iterator) && !is_user_hltv(Iterator))
			{
				PureMessageOne(Iterator, Message, GrayOrTeamColor ? MaximumClients + 1 : Iterator, TaggedBuffer);
			}
		}
	}
}

public _MenuHandler(Client, Menu, Item)
{
	if (Item == MENU_EXIT)
	{
		menu_destroy(Menu);

		return PLUGIN_HANDLED;
	}

	static Data[4], Access, Name[32], Callback, Target, NewMenu, Buffer[128];

	menu_item_getinfo(Menu, Item, Access, Data, sizeof(Data) - 1, Name, sizeof(Name) - 1, Callback);

	Target = str_to_num(Data);

	if (!is_user_connected(Target))
	{
		ColorChatSpecial(Client, true, "Target is not connected!");
	}

	else if (!is_user_alive(Target))
	{
		ColorChatSpecial(Client, true, "Target is not alive!");
	}

	else if (g_Race[Target])
	{
		ColorChatSpecial(Client, true, "Target is already into a race!");
	}

	else if (GetPureTeam(Target) != TEAM_CT)
	{
		ColorChatSpecial(Client, true, "Target is not Counter-Terrorist!");
	}

	else
	{
		ColorChatSpecial(Client, true, "%s has been asked to accept!", Name);

		get_user_name(Client, Name, sizeof(Name) - 1);

		formatex(Buffer, sizeof(Buffer) - 1, "Do you want a race with %s?", Name);

		g_Invoker[Target] = Client;

		g_Victim[Client] = Target;

		NewMenu = menu_create(Buffer, "_AcceptMenuHandler");

		menu_additem(NewMenu, "Yes", "0");
		menu_additem(NewMenu, "No", "1");

		menu_display(Target, NewMenu);
	}

	menu_destroy(Menu);

	return PLUGIN_HANDLED;
}

public client_disconnect(Client)
{
	static Iterator, Name[32];

	for (Iterator = 1; Iterator <= get_maxplayers(); Iterator++)
	{
		if (Client == g_Invoker[Iterator])
		{
			get_user_name(Client, Name, sizeof(Name) - 1);

			ColorChatSpecial(Iterator, true, "Your invoker, %s, disconnected!", Name);

			g_Invoker[Iterator] = 0;

			break;
		}
	}

	g_Victim[Client] = 0;

	g_Race[Client] = false;
}

public _AcceptMenuHandler(Client, Menu, Item)
{
	if (Item == MENU_EXIT)
	{
		menu_destroy(Menu);

		return PLUGIN_HANDLED;
	}

	static Data[4], Access, Name[32], Callback, Option;

	menu_item_getinfo(Menu, Item, Access, Data, sizeof(Data) - 1, Name, sizeof(Name) - 1, Callback);

	Option = str_to_num(Data);

	get_user_name(Client, Name, sizeof(Name) - 1);

	if (!is_user_connected(g_Invoker[Client]))
	{
		ColorChatSpecial(Client, true, "Invoker has disconnected!");

		menu_destroy(Menu);

		return PLUGIN_HANDLED;
	}

	else if (!is_user_alive(g_Invoker[Client]))
	{
		ColorChatSpecial(Client, true, "Invoker is dead!");

		menu_destroy(Menu);

		return PLUGIN_HANDLED;
	}

	else if (GetPureTeam(g_Invoker[Client]) != TEAM_CT)
	{
		ColorChatSpecial(Client, true, "Invoker is not Counter-Terrorist!");

		menu_destroy(Menu);

		return PLUGIN_HANDLED;
	}

	else if (g_Race[g_Invoker[Client]])
	{
		ColorChatSpecial(Client, true, "Invoker is already into a race!");

		menu_destroy(Menu);

		return PLUGIN_HANDLED;
	}

	if (Option == 0)
	{
		ColorChatSpecial(g_Invoker[Client], true, "%s accepted to race!", Name);

		dllfunc(DLLFunc_Spawn, Client);
		dllfunc(DLLFunc_Spawn, g_Invoker[Client]);

		g_Race[Client] = g_Race[g_Invoker[Client]] = true;
	}

	else
	{
		ColorChatSpecial(g_Invoker[Client], true, "%s declined the race!", Name);

		g_Victim[g_Invoker[Client]] = 0;

		g_Invoker[Client] = 0;
	}

	menu_destroy(Menu);

	return PLUGIN_HANDLED;
}
