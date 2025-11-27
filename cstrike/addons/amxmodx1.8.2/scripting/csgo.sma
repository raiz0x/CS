#include <amxmodx> 
#include <amxmisc> 
#include <fakemeta>    
#include <hamsandwich> 
#include <fakemeta_util>  
#include <cstrike> 
#include <engine>
#include <fun> 
#include <dhudmessage>
#include <nvault> 
#define CC_COLORS_TYPE CC_COLORS_SHORT
#include <cromchat>  

new const PLUGIN[] = "Global Offensive";
new const VERSION[] = "1.0";
new const AUTHOR[] = "DEROID";

#define MAX 100

#define PointsMin 3
#define PointsMax 8
#define Drop 10
#define MarkMin 299
#define METR_UNITS 39.37

#define WEAPONSKIN 11

#define FAMAS 15 
#define USP 16
#define GLOCK18 17
#define AWP 18
#define MP5NAVY 19
#define M3 21 
#define M4A1 22
#define DEAGLE 26
#define AK47 28
#define KNIFE 29
#define P90 30

new const TeamNames[][] = {
	"",
	"Terrorist",
	"Counter-Terrorist"
}
new tMenu
new playj
new viewj[33]
new round[33]
new jackpot
new inJack[33]
new itemj[10]
new tradeups[33]
new jack[33]
new acc[33]
new secs = 60
new selectate[33]
new select[5][33]
new selects[5][33]
new bool:nosend[33]
new tTarget[33]
new go[33]
new sec = 60
new Rosu[33]
new Gri[33]
new ruleta = 0
new playr
new Galben[33]
new selectatec[33]
new selectates[33]
new selectatek[33]
new ssvault
new rLine[2520]
new svault
new rvault
new trackvault
new const g_vault_reg[] = "reg"
new const g_vault_skin[] = "skin"
new const g_vault_sskin[] = "sskin"
new const g_vault_track[] = "stattrack"
new invitat[33] = 0;
new WeaponNames[MAX+1][33], WeaponMdls[MAX+1][48], Weapons[MAX+1], WeaponDrop[MAX+1], WeaponMax[MAX+1], WeaponMin[MAX+1], AllWeapon;
new UsingWeapon[WEAPONSKIN][33], uWeapon[MAX+1][33], Chest[33], pKey[33], Points[33], Rang[33], Kills[33],
aThing[33], aTarget[33], aPoints[33], Prefix[32];
new Folder[48], SkinFile[48], RangFile[48], MenuMod[33], SayText;
new WeaponinMarket[33], inMarket[33], MarketPoints[33], Choosen[33];
new SavedPassword[33][32], bool:Loged[33], Password[33][32];
new NeedKills[30], Rangs[30][32];
new nr[7][8];
new stattrack[MAX+1][33];
new kill[MAX+1][33];
new rem[33];
new coldown[MAX+1][33]
new pbet[33]
new bround
new tradeup[33]
new contr[10][33]
new g_dropchace;
new betp[33]
new arg1[1260];
new arg2[1260];
	

public plugin_precache() {
	new Line[128], Data[6][48], Len;
	AllWeapon++;
	get_configsdir(Folder, 47);
	format(SkinFile, 47, "%s/csgo/skins.cfg", Folder);
	format(RangFile, 47, "%s/csgo/rangs.cfg", Folder);
	format(Prefix, 31, "[Global Offensive]");
	formatex(nr[0], 7, "\w-");
	formatex(nr[1], 7, "\w-");
	formatex(nr[2], 7, "\w-");
	formatex(nr[3], 7, "\w-");
	formatex(nr[4], 7, "\w-");
	formatex(nr[5], 7, "\w-");
	formatex(nr[6], 7, "\w-"); 
	
	if(file_exists(RangFile))
	{
		for(new i; i < file_size(RangFile, 1); i++)
		{
			read_file(RangFile, i, Line, 127, Len);
			parse(Line, Data[0], 31, Data[1], 31);
			
			copy(Rangs[i], 31, Data[0]);
			NeedKills[i] = str_to_num(Data[1]);
		}
	}
	if(file_exists(SkinFile))
	{
		for(new i; i < file_size(SkinFile, 1); i++)
		{
			read_file(SkinFile, i, Line, 127, Len);
			
			if(strlen(Line) < 5 || Line[0] == ';' || AllWeapon == MAX+1)
				continue;
			
			parse(Line, Data[0], 31, Data[1], 31, Data[2], 47, Data[3], 31, Data[4], 31, Data[5], 31);
			
			Weapons[AllWeapon] = str_to_num(Data[0]);
			copy(WeaponNames[AllWeapon], 31, Data[1]);
			
			if(ValidMdl(Data[2])) {
				precache_model(Data[2]);
				copy(WeaponMdls[AllWeapon], 47, Data[2]); 
			}
			
			WeaponDrop[AllWeapon] = str_to_num(Data[3]);
			WeaponMin[AllWeapon] = str_to_num(Data[4])
			WeaponMax[AllWeapon] = str_to_num(Data[5])
			AllWeapon++;
		}
		if(AllWeapon == 0)
			log_amx("There's no skins ON");
	}

}
public plugin_init() {
	register_dictionary("go.txt");
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar(PLUGIN, VERSION, FCVAR_SERVER);
	
	register_clcmd("say /menu", "MenuOpen");
	register_clcmd("say /reg", "RegMenu");
	register_clcmd("say /register", "RegMenu");
	register_clcmd("say /accept", "acctrade");
	register_clcmd("say /deny", "reftrade");
	register_concmd("Cost", "MarketCost"); 
	register_concmd("Rosu", "RosuRuleta");
	register_concmd("Galben", "GalbenRuleta");
	register_concmd("Gri", "GriRuleta");
	register_event("DeathMsg", "event_DeathMsg", "a");
	register_concmd("Gift", "GiftPoint");
	register_concmd("T", "Tbet");
	register_concmd("CT", "CTbet");
	register_concmd("UserPassword", "PlayerPassword");
	register_concmd("sm_givekey", "give_key", ADMIN_RCON, "<nick> <amount>");
	register_concmd("sm_giveskins", "give_skins", ADMIN_RCON, "<nick>");
	register_concmd("sm_givestat", "give_stat", ADMIN_RCON, "<nick>");
	register_concmd("sm_takeskins", "take_skins", ADMIN_RCON, "<nick>");
	register_concmd("sm_givechest", "give_chest", ADMIN_RCON, "<nick> <amount>");
	register_concmd("sm_givepoints", "give_puncte", ADMIN_RCON, "<nick> <amount>");

	register_logevent( "derspawn", 2, "1=Round_Start" );
	
	SayText = get_user_msgid("SayText");
	register_forward(FM_ClientUserInfoChanged, "NameChange");
	register_event( "CurWeapon" , "CWeapon" , "be" , "1=1" );
	g_dropchace = register_cvar("global_offensive", "10");
	set_task(67.3, "Message", 7217, _, _, "b");
	rvault = nvault_open(g_vault_reg);
	svault = nvault_open(g_vault_skin);
	ssvault = nvault_open(g_vault_sskin);
	trackvault = nvault_open(g_vault_track);
}
public plugin_natives()
{
	register_native("randomcsgo", "randomcsgo", 1)
	register_native("randomskin", "ChestOpen", 1)
	register_native("give_key", "native_key", 1)
	register_native("give_chest", "native_chest", 1)
	register_native("give_bet", "native_bet", 1)
	register_native("bett", "native_bett", 1)
	register_native("betct", "native_betct", 1)
}
public native_key(id)
{
	if(is_user_connected(id))
	{
		pKey[id]++;
		Save(id);
	}
}
public native_chest(id)
{
	if(is_user_connected(id))
	{
		Chest[id]++;
		Save(id);
	}
}
public native_bet(id)
{
	if(is_user_connected(id))
	{
		new a = betp[id]*2
		Points[id] += a
		CromChat(id, "!g%s!w You have won !g%d points.", Prefix, a);
	}
}
public native_bett(id)
{
	if(is_user_connected(id) && pbet[id] == 1)
		return true;

	return false;
}
public native_betct(id)
{
	if(is_user_connected(id) && pbet[id] == 2)
		return true;

	return false;
}
public plugin_end()
{
	nvault_prune(rvault, 0, get_systime() - (86400*7));
	nvault_prune(svault, 0, get_systime() - (86400*7));
	nvault_prune(ssvault, 0, get_systime() - (86400*7));
	nvault_prune(trackvault, 0, get_systime() - (86400*7));
	nvault_close(trackvault)
	nvault_close(rvault)
	nvault_close(svault)
	nvault_close(ssvault)
}
public randomcsgo(id)
{
	new a = random_num(1,3)
	new Name[32]
	get_user_name(id, Name, 31);

	if(a == 1)
	{
		new pPont;
		pPont = random_num(25, 50);
		Points[id] += pPont;
		CromChat(0, "!g%s!t %s!w has been awarded with !g%i points.", Prefix, Name, pPont);
	}
	else if(a == 2)
	{
		pKey[id]++;
		CromChat(0, "!g%s%L", Prefix, LANG_SERVER, "FOUNDKEY", Name);
	}
	else
	{
		Chest[id]++;
		CromChat(0, "!g%s%L", Prefix, LANG_SERVER, "FOUNDCHEST", Name);
	}
	Save(id);
}
public acctrade(id)
{
	if(!tTarget[id])
		return 1;

	if(!Loged[id])
	{
		return 1;
	}

	go[id] = 1
	go[tTarget[id]] = 1
	remove_task(tTarget[id]);
	new Name[32], Name2[32];
	get_user_name(id, Name, 31);
	get_user_name(tTarget[id], Name2, 31);
	CromChat(id, "!g%s!w You have accepted !t%s!w's trade.",Prefix, Name2);
	CromChat(tTarget[id], "!g%s!t %s !whas accepted your trade.",Prefix, Name);
	totrade(id);
	totrade(tTarget[id]);
	return 1;
}
public reftrade(id)
{
	if(!tTarget[id])
		return 1;

	if(!Loged[id])
	{
		return 1;
	}

	go[id] = 0
	go[tTarget[id]] = 0
	remove_task(tTarget[id]);
	invitat[id] = 0;
	nosend[tTarget[id]] = true;
	new Name[32], Name2[32];
	get_user_name(id, Name, 31);
	get_user_name(tTarget[id], Name2, 31);
	CromChat(id, "!g%s!w You have denied !t%s!w's trade.",Prefix, Name2);
	CromChat(tTarget[id], "!g%s!t %s !whas denied your trade.",Prefix, Name);
	tTarget[tTarget[id]] = 0;
	tTarget[id] = 0;
	return 1;
}
public derspawn()
{
	for(new i; i < 32; i++)
	{
		if(is_user_connected(i))
		{
			round[i] = 0
			if(pKey[i] < 0)
				pKey[i] = 0

			if(Chest[i] < 0)
				Chest[i] = 0
			if(viewj[i])
			{
				MenuMod[i] = 0
				Menu(i)
				viewj[i] = 0
			}
		}
	}
	bround++
}
public give_key(id)
{
	if(get_user_flags(id) & ADMIN_RCON)
	{
		new target_name[32];
		new Amount[10];
		
		read_argv(1, target_name, 31);
		read_argv(2, Amount, 9);
		
		if(equal(target_name, "") || equal(Amount, ""))
		{
			console_print(id, "sm_givekey <nick> <amount>");
			return 1;
		}
		
		new Key = str_to_num(Amount);
		
		if(Key <= 0)
		{
			console_print(id, "[SM] You must enter an amount bigger than 0.");
			return 1;
		}
		
		new iPlayer
		if(equal(target_name, "@ALL"))
		{
			for(new iss; iss < 32; iss++)
			{
				if(is_user_connected(iss))
				{
					pKey[iss] += Key;
					Save(iss);
				}
			}
			new Admin_Name[32];
			get_user_name(id, Admin_Name, 31);
		
			CromChat(0, "!g%s!t %s!w has given !g%d key(s)!w to !geveryone", Prefix, Admin_Name, Key);
			return 1;
		}
		else
		{
			iPlayer = cmd_target(id, target_name, 8);
		}
		
		if(!iPlayer)
		{
			console_print(id, "[SM] Player %s cannot be found.", target_name);
			return 1;
		}
		
		pKey[iPlayer] += Key;
		new Admin_Name[32];
		new Player_Name[32];
		Save(iPlayer);
		get_user_name(id, Admin_Name, 31);
		get_user_name(iPlayer, Player_Name, 31);
		
		CromChat(0, "!g%s!t %s!w has given !g%d key(s)!w to!t %s.", Prefix, Admin_Name, Key, Player_Name);
		
		return 1;
	}
	else
	{
		console_print(id, "[SM] You dont have access to this command.");
		return 1;
	}
	
	return 1;
}
public take_skins(id)
{
	if(get_user_flags(id) & ADMIN_RCON)
	{
		new target_name[32];
		
		read_argv(1, target_name, 31);
		
		if(equal(target_name, ""))
		{
			console_print(id, "sm_takeskins <name>");
			return 1;
		}

		new iPlayer = cmd_target(id, target_name, 8);
		
		if(!iPlayer)
		{
			console_print(id, "[SM] Player %s cannot be found.", target_name);
			return 1;
		}
		
		for(new i = 1; i < AllWeapon; i++)
		{
			stattrack[i][iPlayer] = 0
			kill[i][iPlayer] = 0
			uWeapon[i][iPlayer] = 0
		}
		
		for(new a = 0; a < WEAPONSKIN; a++)
		{
			UsingWeapon[a][iPlayer] = 0
		}
		Save(iPlayer);

		return 1;
	}
	else
	{
		console_print(id, "[SM] You dont have access to this command.");
		return 1;
	}
	
	return 1;
}
public give_skins(id)
{
	if(get_user_flags(id) & ADMIN_RCON)
	{
		new target_name[32];
		
		read_argv(1, target_name, 31);
		
		if(equal(target_name, ""))
		{
			console_print(id, "sm_giveskins <nick>");
			return 1;
		}

		new iPlayer = cmd_target(id, target_name, 8);
		
		if(!iPlayer)
		{
			console_print(id, "[SM] Player %s cannot be found.", target_name);
			return 1;
		}
		
		for(new i = 1; i < AllWeapon; i++)
		{
			uWeapon[i][iPlayer]++
		}
		Save(iPlayer);
		return 1;
	}
	else
	{
		console_print(id, "[SM] You dont have access to this command.");
		return 1;
	}
	
	return 1;
}
public give_stat(id)
{
	if(get_user_flags(id) & ADMIN_RCON)
	{
		new target_name[32];
		
		read_argv(1, target_name, 31);
		
		if(equal(target_name, ""))
		{
			console_print(id, "sm_givestat <nick>");
			return 1;
		}

		new iPlayer = cmd_target(id, target_name, 8);
		
		if(!iPlayer)
		{
			console_print(id, "[SM] Player %s cannot be found.", target_name);
			return 1;
		}
		
		for(new i = 1; i < AllWeapon; i++)
		{
			uWeapon[i][iPlayer]++
			stattrack[i][iPlayer]++
		}
		Save(iPlayer);
		return 1;
	}
	else
	{
		console_print(id, "[SM] You dont have access to this command.");
		return 1;
	}
	
	return 1;
}
public give_chest(id)
{
	if(get_user_flags(id) & ADMIN_RCON)
	{
		new target_name[32];
		new Amount[10];
		
		read_argv(1, target_name, 31);
		read_argv(2, Amount, 9);
		
		if(equal(target_name, "") || equal(Amount, ""))
		{
			console_print(id, "sm_givechest <nick> <amount>");
			return 1;
		}
		
		new Key = str_to_num(Amount);
		
		if(Key <= 0)
		{
			console_print(id, "[SM] You must enter an amount bigger than 0.");
			return 1;
		}
		new iPlayer
		if(equal(target_name, "@ALL"))
		{
			for(new iss; iss < 32; iss++)
			{
				if(is_user_connected(iss))
				{
					Chest[iss] += Key;
					Save(iss);
				}
			}
			new Admin_Name[32];
			get_user_name(id, Admin_Name, 31);
		
			CromChat(0, "!g%s!t %s!w has given !g%d chest(s)!w to !geveryone.", Prefix, Admin_Name, Key);
			return 1;
		}
		else
		{
			iPlayer = cmd_target(id, target_name, 8);
		}
		
		if(!iPlayer)
		{
			console_print(id, "[SM] Player %s cannot be found.", target_name);
			return 1;
		}
		
		Chest[iPlayer] += Key;
		new Admin_Name[32];
		new Player_Name[32];
		Save(iPlayer);
		get_user_name(id, Admin_Name, 31);
		get_user_name(iPlayer, Player_Name, 31);
		
		CromChat(0, "!g%s!t %s!w has given !g%d chest(s)!w to!t %s.", Prefix, Admin_Name, Key, Player_Name);
		
		return 1;
	}
	else
	{
		console_print(id, "[SM] You dont have access to this command.");
		return 1;
	}
	
	return 1;
}
public give_puncte(id)
{
	if(get_user_flags(id) & ADMIN_RCON)
	{
		new target_name[32];
		new Amount[10];
		
		read_argv(1, target_name, 31);
		read_argv(2, Amount, 9);
		
		if(equal(target_name, "") || equal(Amount, ""))
		{
			console_print(id, "sm_givepoints <nick> <amount>");
			return 1;
		}
		
		new Key = str_to_num(Amount);
		
		if(Key <= 0)
		{
			console_print(id, "[SM] You must enter an amount bigger than 0");
			return 1;
		}
		
		new iPlayer
		if(equal(target_name, "@ALL"))
		{
			for(new iss; iss < 32; iss++)
			{
				if(is_user_connected(iss))
				{
					Points[iss] += Key;
					Save(iss);
				}
			}
			new Admin_Name[32];
			get_user_name(id, Admin_Name, 31);
		
			CromChat(0, "!g%s!t %s!w has given !g%d points!w to !geveryone", Prefix, Admin_Name, Key);
			return 1;
		}
		else
		{
			iPlayer = cmd_target(id, target_name, 8);
		}
		
		if(!iPlayer)
		{
			console_print(id, "[SM] Player %s cannot be found.", target_name);
			return 1;
		}
		
		Points[iPlayer] += Key;
		new Admin_Name[32];
		new Player_Name[32];
		Save(iPlayer);
		get_user_name(id, Admin_Name, 31);
		get_user_name(iPlayer, Player_Name, 31);
		
		CromChat(0, "!g%s!t %s!w has given !g%d points!w to!t %s.", Prefix, Admin_Name, Key, Player_Name);
		
		return 1;
	}
	else
	{
		console_print(id, "[SM] You dont have access to this command");
		return 1;
	}
	
	return 1;
}
public Message() 
{
	CromChat(0, "!g%s %L", Prefix, LANG_SERVER, "MSG");
}
public MenuOpen(id)
{
	if(!Loged[id])
	{
		RegMenu(id);
		return;
	}
	
	MenuMod[id] = 0;
	Menu(id);
}
public event_DeathMsg()
{
	static Victim; Victim = read_data(2);
	static Killer; Killer = read_data(1);
	if(task_exists(Victim+231245534))
	{
		remove_task(Victim+231245534)
	}

	set_task(0.1, "ShowHUD", Victim+231245534, _, _, "b")
	if(Killer == Victim)
	{
		return PLUGIN_HANDLED;
	}
	Kills[Killer]++;
	for(new i = 1; i < AllWeapon; i++)
	{
		for(new a = 0; a < WEAPONSKIN; a++)
		{
			new der = i+500
			if(der == UsingWeapon[a][Killer])
			{
				if(get_user_weapon(Killer) == Weapons[i])
				{
					kill[i][Killer]++
				}
			}
		}
	}
	new pPont;
	
	pPont += random_num(PointsMin, PointsMax);
	Points[Killer] += pPont;
	
	set_hudmessage(255, 255, 255, -1.0, 0.15, 0, 6.0, 2.0);
	show_hudmessage(Killer, "%L", LANG_SERVER, "POINT", pPont);
	if(Rang[Killer] < sizeof(Rangs) && Rang[Killer] < file_size(RangFile, 1))
	{
		if(Kills[Killer] >= NeedKills[Rang[Killer]])
			Rang[Killer]++;
	}
	
	if(get_pcvar_num(g_dropchace) >= random_num(1, 100))
	{
		new Name[32]
		get_user_name(Killer, Name, 31);
		new x = random_num(1, 2);
		if(x == 1)
		{
			pKey[Killer]++;
			CromChat(0, "!g%s%L", Prefix, LANG_SERVER, "FOUNDKEY", Name);
		}
		if(x == 2)
		{
			Chest[Killer]++;
			CromChat(0, "!g%s%L", Prefix, LANG_SERVER, "FOUNDCHEST", Name);
		}
	}
	Save(Killer);
	return PLUGIN_CONTINUE;
}
public MarketCost(id)
{
	if(inMarket[id] || !Loged[id])
		return PLUGIN_HANDLED;
		
	new Data[32], Cost;
	read_args(Data, 31);
	remove_quotes(Data);
	
	Cost = str_to_num(Data);
	
	if(Cost < 0)
	{
		client_cmd(id, "messagemode Cost");
		return PLUGIN_HANDLED;
	}
	else if(WeaponinMarket[id] == 101||WeaponinMarket[id] == 102)
	{
		if(300 >= Cost || 2500 <= Cost)
		{
			CromChat(id, "!g[Shop] !wMinimum price !g300!w, maximum price !g2500");
			client_cmd(id, "messagemode Cost");
			return PLUGIN_HANDLED;
		}
		MarketPoints[id] = Cost;
		MenuMod[id] = 3
		Menu(id)
		return PLUGIN_CONTINUE;
	}
	else if(WeaponinMarket[id] > 500)
	{
		WeaponinMarket[id] -= 500
		new d = WeaponMin[WeaponinMarket[id]]
		d *= 2
		new e = WeaponMax[WeaponinMarket[id]]
		e *= 2
		WeaponinMarket[id] += 500
		if(d >= Cost || e <= Cost)
		{
			CromChat(id, "!g[Shop] !wMinimum price !g%d!w, maximum price !g%d", d, e);
			client_cmd(id, "messagemode Cost");
			return PLUGIN_HANDLED;
		}
		else
		{
			MarketPoints[id] = Cost;
			MenuMod[id] = 3
			Menu(id)
			return PLUGIN_CONTINUE;
		}
	}
	else if(WeaponMin[WeaponinMarket[id]] >= Cost || WeaponMax[WeaponinMarket[id]] <= Cost)
	{
		CromChat(id, "!g[Shop] !wMinimum price !g%d!w, maximum price !g%d", WeaponMin[WeaponinMarket[id]], WeaponMax[WeaponinMarket[id]]);
		client_cmd(id, "messagemode Cost");
		return PLUGIN_HANDLED;
	}
	else
	{
		MarketPoints[id] = Cost;
		MenuMod[id] = 3
		Menu(id)
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}
public Tbet(id)
{
	if(!Loged[id] || bround > 4 || pbet[id])
		return PLUGIN_HANDLED;
		
	new Data[32], Cost;
	read_args(Data, 31);
	remove_quotes(Data);
	
	Cost = str_to_num(Data);
	
	if(Cost < 0 || Cost > Points[id] || Cost == 0)
	{
		client_cmd(id, "messagemode T");
		return PLUGIN_HANDLED;
	}
	else
	{
		pbet[id] = 1;
		betp[id] = Cost
		Points[id] -= Cost
		CromChat(id, "!g[Global Offensive]!w You have bet for Terrorist Force!g %d points",Cost);
		MenuMod[id] = 0
		Menu(id)
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}
public CTbet(id)
{
	if(!Loged[id] || bround > 4 || pbet[id])
		return PLUGIN_HANDLED;
		
	new Data[32], Cost;
	read_args(Data, 31);
	remove_quotes(Data);
	
	Cost = str_to_num(Data);
	
	if(Cost < 0 || Cost > Points[id] || Cost == 0)
	{
		client_cmd(id, "messagemode CT");
		return PLUGIN_HANDLED;
	}
	else
	{
		pbet[id] = 2;
		betp[id] = Cost
		Points[id] -= Cost
		CromChat(id, "!g[Global Offensive]!w You have bet for Counter Terrorist Force!g %d points",Cost);
		MenuMod[id] = 0
		Menu(id)
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}
public RosuRuleta(id)
{
	if(ruleta || !Loged[id] || Rosu[id] || Gri[id] || Galben[id])
		return PLUGIN_HANDLED;
		
	new Data[32], Cost;
	read_args(Data, 31);
	remove_quotes(Data);
	
	Cost = str_to_num(Data);
	
	if(Cost < 0 || Cost > Points[id] || Cost == 0)
	{
		client_cmd(id, "messagemode Rosu");
		return PLUGIN_HANDLED;
	}
	else
	{
		Rosu[id] = Cost;
		Points[id] -= Cost
		Save(id)
		ruletta(id)
		playr++
		if(playr == 2 && sec == 60)
			playruleta()

		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}
public GriRuleta(id)
{
	if(ruleta || !Loged[id] || Rosu[id] || Gri[id] || Galben[id])
		return PLUGIN_HANDLED;
		
	new Data[32], Cost;
	read_args(Data, 31);
	remove_quotes(Data);
	
	Cost = str_to_num(Data);
	
	if(Cost < 0 || Cost > Points[id] || Cost == 0)
	{
		client_cmd(id, "messagemode Gri");
		return PLUGIN_HANDLED;
	}
	else
	{
		Gri[id] = Cost;
		Points[id] -= Cost
		Save(id)
		ruletta(id)
		playr++
		if(playr == 2 && sec == 60)
			playruleta()

		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}
public GalbenRuleta(id)
{
	if(ruleta || !Loged[id] || Rosu[id] || Gri[id] || Galben[id])
		return PLUGIN_HANDLED;
		
	new Data[32], Cost;
	read_args(Data, 31);
	remove_quotes(Data);
	
	Cost = str_to_num(Data);
	
	if(Cost < 0 || Cost > Points[id] || Cost == 0)
	{
		client_cmd(id, "messagemode Galben");
		return PLUGIN_HANDLED;
	}
	else
	{
		Galben[id] = Cost;
		Points[id] -= Cost
		Save(id)
		ruletta(id)
		playr++
		if(playr == 2 && sec == 60)
			playruleta()

		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}
public GiftPoint(id)
{
	if(inMarket[id] || !Loged[id])
		return PLUGIN_HANDLED;
		
	new Data[32], Cost;
	read_args(Data, 31);
	remove_quotes(Data);
	
	Cost = str_to_num(Data);
	
	if(Cost < 0 || Points[id] < Cost)
	{
		client_cmd(id, "messagemode Gift");
		return PLUGIN_HANDLED;
	}
	else
	{
		aPoints[id] = Cost;
		MenuMod[id] = 5;
		Menu(id);
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}
public CWeapon( id ) {
	if(id > 32 || id < 1 || !is_user_alive(id))
	{
		return 1;
	}
	
	new des

	if(task_exists(id+231245534))
	{
		rem[id] = 1
		remove_task(id+231245534)
	}

	for(new i = 1; i < AllWeapon; i++)
	{
		for(new a = 0; a < WEAPONSKIN; a++)
		{
			new der = i+500
			if(i == UsingWeapon[a][id])
			{
				if(get_user_weapon(id) == Weapons[i])
				{
					set_pev(id, pev_viewmodel2, WeaponMdls[i]);
					return HAM_SUPERCEDE;
				}
			}
			else if(der == UsingWeapon[a][id])
			{
				if(get_user_weapon(id) == Weapons[i])
				{
					set_pev(id, pev_viewmodel2, WeaponMdls[i]);
					rem[id] = 0
					set_task(0.1, "ShowHUD", id+231245534, _, _, "b")
					des++
					return HAM_SUPERCEDE;
				}
			}
		}
	}

	return PLUGIN_CONTINUE;
}
public ShowHUD(id)
{
	id -= 231245534
	if(rem[id])
		return 1;

	if(!is_user_connected(id))
		return 1;

	if (!is_user_alive(id))
	{
		new ids = pev(id, pev_iuser2)
		
		if (!is_user_alive(ids)) return 1;

		new name[32]
		get_user_name(ids, name, 31)
		new des
		for(new i = 1; i < AllWeapon; i++)
		{
			for(new a = 0; a < WEAPONSKIN; a++)
			{
				new der = i+500
				if(der == UsingWeapon[a][ids])
				{
					if(get_user_weapon(ids) == Weapons[i])
					{
						set_hudmessage(0, 255, 0, 0.56, 0.0, 0, 6.0, 0)
						show_dhudmessage(id, "%s have %s *^nAnd %i confirmed kills", name, WeaponNames[i], kill[i][ids]);
						des++
					}
				}
			}
		}
	}
	else
	{
		new des
		for(new i = 1; i < AllWeapon; i++)
		{
			for(new a = 0; a < WEAPONSKIN; a++)
			{
				new der = i+500
				if(der == UsingWeapon[a][id])
				{
					if(get_user_weapon(id) == Weapons[i])
					{
						set_hudmessage(0, 255, 0, 0.56, 0.0, 0, 6.0, 0)
						show_dhudmessage(id, "* %s^nConfirmed Kills: %i", WeaponNames[i], kill[i][id]);
						des++
					}
				}
			}
		}
	}
	return 0
}
public ChestOpen(id)
{
	new rWeapon = random_num(1, AllWeapon-1);
	new rNum = random_num(1, 100);
	
	if(WeaponDrop[rWeapon] >= rNum)
	{
		if(equal(WeaponNames[rWeapon], ""))
			ChestOpen(id);
		else
		{
			new star = random_num(1, 25)
			if(star == 1)
			{
				new Name[32];
				get_user_name(id, Name, 31);
				CromChat(0, "!g[Global Offensive]%L *", LANG_SERVER, "FOUNDITEM", Name, WeaponNames[rWeapon]);
				uWeapon[rWeapon][id]++;
				stattrack[rWeapon][id]++;
				Save(id);
			}
			else
			{
				new Name[32];
				get_user_name(id, Name, 31);
				CromChat(0, "!g[Global Offensive]%L", LANG_SERVER, "FOUNDITEM", Name, WeaponNames[rWeapon]);
				uWeapon[rWeapon][id]++;
				Save(id);
			}
		}
	}
	else
	{
		ChestOpen(id);
	}
}
public Menu(id)
{
	if(Loged[id] == false)
	{
		RegMenu(id);
		return 1;
	}
	
	new sMenu, Line[128];
	
	if(MenuMod[id] == -2)
	{
		formatex(Line, 127, "%s\r %L %L",
		Prefix, LANG_SERVER, "GIFTCH", LANG_SERVER, "YPOINT", Points[id]);
		sMenu = menu_create(Line, "MenuHandler");
		new String[32], All;
		for(new i = 1; i < AllWeapon; i++)
		{
			if(uWeapon[i][id] == 0 || coldown[i][id] != -1)
				continue;

			if(stattrack[i][id])
			{
				new bda
				bda = i+500
				formatex(String, 31, "%d", bda);
				formatex(Line, 127, "%L \r*", LANG_SERVER, "SKINPIECE", WeaponNames[i], stattrack[i][id]);
				menu_additem(sMenu, Line, String);
			}
			if(uWeapon[i][id] > stattrack[i][id])
			{
				new dsa = uWeapon[i][id]-stattrack[i][id]
				num_to_str(i, String, 31);
				formatex(Line, 127, "%L", LANG_SERVER, "SKINPIECE", WeaponNames[i], dsa);
				menu_additem(sMenu, Line, String);
			}
			All++;
		}
		if(Chest[id] > 0)
		{
			formatex(Line, 127, "%L", LANG_SERVER, "CHESTPIECE", Chest[id]);
			menu_additem(sMenu, Line, "101");
			All++;
		}
		if(pKey[id] > 0)
		{
			formatex(Line, 127, "%L", LANG_SERVER, "KEYPIECE", pKey[id]);
			menu_additem(sMenu, Line, "102");
			All++;
		}
		menu_setprop(sMenu, MPROP_EXIT, MEXIT_ALL)  
		menu_display(id, sMenu, 0);
		if(All == 0)
		{
			MenuMod[id] = 0;
			Menu(id);
		}
	}
	else if(MenuMod[id] == -1)
	{
		formatex(Line, 127, "%s\r %L %L",
		Prefix, LANG_SERVER, "GIFTCH", LANG_SERVER, "YPOINT", Points[id]);
		sMenu = menu_create(Line, "MenuHandler");
		new String[32], All;
		for(new i = 1; i < AllWeapon; i++)
		{
			if(uWeapon[i][id] == 0 || coldown[i][id] != -1)
				continue;
				

			if(stattrack[i][id])
			{
				new bda
				bda = i+500
				formatex(String, 31, "%d", bda);
				formatex(Line, 127, "%L \r*", LANG_SERVER, "SKINPIECE", WeaponNames[i], stattrack[i][id]);
				menu_additem(sMenu, Line, String);
			}
			if(uWeapon[i][id] > stattrack[i][id])
			{
				new dsa = uWeapon[i][id]-stattrack[i][id]
				num_to_str(i, String, 31);
				formatex(Line, 127, "%L", LANG_SERVER, "SKINPIECE", WeaponNames[i], dsa);
				menu_additem(sMenu, Line, String);
			}
			All++;
		}
		if(Chest[id] > 0)
		{
			formatex(Line, 127, "%L", LANG_SERVER, "CHESTPIECE", Chest[id]);
			menu_additem(sMenu, Line, "101");
			All++;
		}
		if(pKey[id] > 0)
		{
			formatex(Line, 127, "%L", LANG_SERVER, "KEYPIECE", pKey[id]);
			menu_additem(sMenu, Line, "102");
			All++;
		}
		menu_setprop(sMenu, MPROP_EXIT, MEXIT_ALL)  
		menu_display(id, sMenu, 0);
		if(All == 0)
		{
			MenuMod[id] = 0;
			Menu(id);
		}
	}
	else if(MenuMod[id] == 0)
	{
		formatex(Line, 127, "%s\r %L %L",
		Prefix, LANG_SERVER, "MAIN", LANG_SERVER, "YPOINT", Points[id]);
		sMenu = menu_create(Line, "MenuHandler");
		formatex(Line, 127, "%L", LANG_SERVER, "MENUTOSKINS");
		menu_additem(sMenu, Line, "1");
		
		if(!inMarket[id] && !WeaponinMarket[id])
		{
			formatex(Line, 127, "%L", LANG_SERVER, "MENUTOCHESTOPEN");
			menu_additem(sMenu, Line, "2");
		}
		else
		{
			formatex(Line, 127, "%L %L",
			LANG_SERVER, "MENUTOCHESTOPEN", LANG_SERVER, "INMARKET");
			menu_additem(sMenu, Line, "0");
		}
		
		formatex(Line, 127, "%L", LANG_SERVER, "MENUTOMARKET");
		menu_additem(sMenu, Line, "3");

		if(!inMarket[id] && !WeaponinMarket[id])
		{
			formatex(Line, 127, "Trade");
			menu_additem(sMenu, Line, "4");
		}
		else
		{
			formatex(Line, 127, "Trade %L", LANG_SERVER, "INMARKET");
			menu_additem(sMenu, Line, "0");
		}

		if(!inMarket[id] && !WeaponinMarket[id])
		{
			formatex(Line, 127, "%L",LANG_SERVER, "MENUTOGIFT");
			menu_additem(sMenu, Line, "5");
		}
		else
		{
			formatex(Line, 127, "%L %L",
			LANG_SERVER, "MENUTOGIFT", LANG_SERVER, "INMARKET");
			menu_additem(sMenu, Line, "0");
		}


		if(!ruleta)
		{
			formatex(Line, 127, "Ruleta \r[Opened]");
			menu_additem(sMenu, Line, "6");
		}
		else
		{
			formatex(Line, 127, "Ruleta \r[Closed]");
			menu_additem(sMenu, Line, "0");
		}

		if(!jackpot)
		{
			formatex(Line, 127, "Jackpot \r[Opened]^n%L", LANG_SERVER, "MRANG", Rangs[Rang[id]+1], Kills[id], NeedKills[Rang[id]]);
			menu_additem(sMenu, Line, "7");
		}
		else
		{
			formatex(Line, 127, "Jackpot \r[Closed]^n%L", LANG_SERVER, "MRANG", Rangs[Rang[id]+1], Kills[id], NeedKills[Rang[id]]);
			menu_additem(sMenu, Line, "0");
		}

		formatex(Line, 127, "Team Betting");
		menu_additem(sMenu, Line, "8");

		if(!inMarket[id] && !WeaponinMarket[id])
		{
			formatex(Line, 127, "Contract");
			menu_additem(sMenu, Line, "9");
		}
		else
		{
			formatex(Line, 127, "Contract %L", LANG_SERVER, "INMARKET");
			menu_additem(sMenu, Line, "0");
		}


		if(!inMarket[id] && !WeaponinMarket[id])
		{
			formatex(Line, 127, "Thrashing Items");
			menu_additem(sMenu, Line, "10");
		}
		else
		{
			formatex(Line, 127, "Trashing Items %L", LANG_SERVER, "INMARKET");
			menu_additem(sMenu, Line, "0");
		}

		menu_setprop(sMenu, MPROP_EXIT, MEXIT_ALL)  
		menu_display(id, sMenu, 0);

	}
	else if(MenuMod[id] == 1)
	{
		formatex(Line, 127, "%s\r %L %L",
		Prefix, LANG_SERVER, "MENUTOSKINS", LANG_SERVER, "YPOINT", Points[id]);
		sMenu = menu_create(Line, "MenuHandler");
		new String[32], All;
		for(new i = 1; i < AllWeapon; i++)
		{
			if(uWeapon[i][id] == 0)
				continue;
				

			if(stattrack[i][id])
			{
				new der = i+500
				formatex(String, 31, "%d %d", der, Weapons[i]);
				formatex(Line, 127, "%L\w(\yStatTrack\w)", LANG_SERVER, "SKINPIECE", WeaponNames[i], stattrack[i][id]);
				menu_additem(sMenu, Line, String);
			}
			if(uWeapon[i][id] > stattrack[i][id])
			{
				formatex(String, 31, "%d %d", i, Weapons[i]);
				formatex(Line, 127, "%L", LANG_SERVER, "SKINPIECE", WeaponNames[i], uWeapon[i][id]-stattrack[i][id]);
				menu_additem(sMenu, Line, String);
			}
			All++;
		}
		if(All == 0)
		{
			MenuMod[id] = 0;
			Menu(id);
		}
		menu_setprop(sMenu, MPROP_EXIT, MEXIT_ALL)  
		menu_display(id, sMenu, 0);
	}
	else if(MenuMod[id] == 2)
	{
		formatex(Line, 127, "%s\r %L %L",
		Prefix, LANG_SERVER, "MENUTOCHESTOPEN", LANG_SERVER, "YPOINT", Points[id]);
		sMenu = menu_create(Line, "MenuHandler");
		formatex(Line, 127, "%L", LANG_SERVER, "CHESTSANDKEYS", Chest[id], pKey[id]);
		menu_additem(sMenu, Line, "1");
		menu_setprop(sMenu, MPROP_EXIT, MEXIT_ALL)  
		menu_display(id, sMenu, 0);
	}	
	else if(MenuMod[id] == 3)
	{
		formatex(Line, 127, "%s\r %L %L",
		Prefix, LANG_SERVER, "MENUTOMARKET", LANG_SERVER, "YPOINT", Points[id]);
		sMenu = menu_create(Line, "MenuHandler");
		new String[32], All;
		if(!inMarket[id])
		{
			for(new i = 1; i < AllWeapon; i++)
			{
				new der = i+500
				if(i == WeaponinMarket[id] && uWeapon[i][id] > 0)
				{
					formatex(Line, 127, "%L", LANG_SERVER, "MARKETPLACES", WeaponNames[i], MarketPoints[id]);
					All++;
				}
				else if(der == WeaponinMarket[id] && uWeapon[i][id] > 0)
				{
					formatex(Line, 127, "%L \r*", LANG_SERVER, "MARKETPLACES", WeaponNames[i], MarketPoints[id]);
					All++;
				}
			}
			
			if(101 == WeaponinMarket[id] && Chest[id] > 0)
			{
				formatex(Line, 127, "%L", LANG_SERVER, "MARKETPLACEC", MarketPoints[id]);
				All++;
			}
			if(102 == WeaponinMarket[id] && pKey[id] > 0)
			{
				formatex(Line, 127, "%L", LANG_SERVER, "MARKETPLACEK", MarketPoints[id]);
				All++;
			}
			
			if(All == 0)
				formatex(Line, 127, "%L", LANG_SERVER, "MARKETPLACECH");
			menu_additem(sMenu, Line, "-1");
		}
		
		if(!inMarket[id])
			formatex(Line, 127, "%L", LANG_SERVER, "TOMARKETM");
		else
			formatex(Line, 127, "%L", LANG_SERVER, "BACKMARKET");
		menu_additem(sMenu, Line, "0");
		
		new Name[32];
		for(new x; x < 32; x++)
		{
			if(!is_user_connected(x)||!Loged[x])
				continue;

			if(inMarket[x] && MarketPoints[x] > 0)
			{
				num_to_str(x, String, 31);
				get_user_name(x, Name, 31);
				if(101 == WeaponinMarket[x])
				{
					formatex(Line, 127, "%L", LANG_SERVER, "SELLERC", Name, MarketPoints[x]);
					menu_additem(sMenu, Line, String);
				}
				else if(102 == WeaponinMarket[x])
				{
					formatex(Line, 127, "%L", LANG_SERVER, "SELLERK", Name, MarketPoints[x]);
					menu_additem(sMenu, Line, String);
				}
				else
				{
					for(new i = 1; i < AllWeapon; i++)
					{
						new der = i+500
						if(i == WeaponinMarket[x])
						{
							formatex(Line, 127, "%L", LANG_SERVER, "SELLERS", Name, WeaponNames[WeaponinMarket[x]], MarketPoints[x]);
							menu_additem(sMenu, Line, String);
						}
						else if(der == WeaponinMarket[x])
						{
							WeaponinMarket[x] = i
							formatex(Line, 127, "%L \r*", LANG_SERVER, "SELLERS", Name, WeaponNames[WeaponinMarket[x]], MarketPoints[x]);
							menu_additem(sMenu, Line, String);
							WeaponinMarket[x] = der
						}
					}

				}
			}
		}
		menu_setprop(sMenu, MPROP_EXIT, MEXIT_ALL)  
		menu_display(id, sMenu, 0);
	}
	else if(MenuMod[id] == 4)
	{
		trade(id);
		return 1;
	}
	else if(MenuMod[id] == 5)
	{
		formatex(Line, 127, "%s\r %L %L",
		Prefix, LANG_SERVER, "MENUTOGIFT", LANG_SERVER, "YPOINT", Points[id]);
		sMenu = menu_create(Line, "MenuHandler");
		new All, Name[32], String[32];
		get_user_name(aTarget[id], Name, 31);
		
		if(aTarget[id] > 0 && is_user_connected(aTarget[id]))
		{
			formatex(Line, 127, "%L", LANG_SERVER, "GIFTT", Name);
			menu_additem(sMenu, Line, "-1");
			for(new i = 1; i < AllWeapon; i++)
			{
				new der = i+500
				if(i == aThing[id] && uWeapon[i][id] > 0)
				{
					formatex(Line, 127, "%L", LANG_SERVER, "GIFTS", WeaponNames[i]);
					menu_additem(sMenu, Line, "-2");
					All++;
				}
				else if(der == aThing[id] && uWeapon[i][id] > 0)
				{
					formatex(Line, 127, "%L \r*", LANG_SERVER, "GIFTS", WeaponNames[i]);
					All++;
				}
			}
			
			if(aThing[id] == 0 && All == 0)
			{
				formatex(Line, 127, "%L", LANG_SERVER, "GIFTCH");
				menu_additem(sMenu, Line, "-2");
			}
			else if(aThing[id] > 100)
			{
				if(101 == aThing[id])
				{
					formatex(Line, 127, "%L", LANG_SERVER, "GIFTC");
				}
				if(102 == aThing[id])
				{
					formatex(Line, 127, "%L", LANG_SERVER, "GIFTK");
				}
				menu_additem(sMenu, Line, "-2");
			}
			
			formatex(Line, 127, "%L", LANG_SERVER, "GIFTPOINTS", aPoints[id]);
			menu_additem(sMenu, Line, "-4");
			formatex(Line, 127, "%L", LANG_SERVER, "SENDGIFT");
			menu_additem(sMenu, Line, "-3");
		}
		else
		{
			for(new i; i < 32; i++)
			{
				if(is_user_connected(i) && i != id && Loged[i])
				{
					get_user_name(i, Name, 31);
					num_to_str(i, String, 31);
					menu_additem(sMenu, Name, String);
				}
			}
		}
		menu_setprop(sMenu, MPROP_EXIT, MEXIT_ALL)  
		menu_display(id, sMenu, 0);
	}
	else if(MenuMod[id] == 6)
	{
		if(!ruleta)
		{
			if(!is_user_alive(id))
				ruletta(id)
			else
				CromChat(id, "!g%s!w You can't play on roulette while you're alive.",Prefix);
		}

		return 1;
	}
	else if(MenuMod[id] == 7)
	{
		if(!jackpot)
		{
			if(!is_user_alive(id))
				jackkpot(id)
			else
				CromChat(id, "!g%s!w You can't play on jackpot while you're alive.",Prefix);
		}

		return 1;
	}
	else if(MenuMod[id] == 8)
	{
		bet(id)

		return 1;
	}
	else if(MenuMod[id] == 9)
	{
		contract(id)

		return 1;
	}
	else if(MenuMod[id] == 10)
	{
		sterge(id)

		return 1;
	}
	return PLUGIN_CONTINUE
}
public MenuHandler(id, gMenu, Key)
{	
	if(Key == MENU_EXIT)
	{
		menu_destroy(gMenu);
		return PLUGIN_HANDLED;
	}
	new aMenu[2], Data[6][32], sKey[32], Name[32], mName[32];
	menu_item_getinfo(gMenu, Key, aMenu[0], Data[0], 31, Data[1], 31, aMenu[1]);
	
	parse(Data[0], sKey, 31);
	Key = str_to_num(sKey);
	
	if(MenuMod[id] == -2)
	{
		aThing[id] = Key;
		menu_destroy(gMenu);
		MenuMod[id] = 5;
		Menu(id);
		return PLUGIN_HANDLED;
	}
	else if(MenuMod[id] == -1)
	{
		WeaponinMarket[id] = Key;
		client_cmd(id, "messagemode Cost");
		menu_destroy(gMenu);
		MenuMod[id] = 3;
		Menu(id);
		return PLUGIN_HANDLED;
	}
	else if(MenuMod[id] == 0)
	{
		if(Key == 4)
		{
			menu_destroy(gMenu);
			trade(id)
			return PLUGIN_HANDLED;
		}
		menu_destroy(gMenu);
		MenuMod[id] = Key;
		Menu(id);
	}
	else if(MenuMod[id] == 1)
	{
		parse(Data[0], Data[2], 31, Data[3], 31);
		
		if(str_to_num(Data[3]) == FAMAS)
			UsingWeapon[0][id] = str_to_num(Data[2]);
		else if(str_to_num(Data[3]) == USP)
			UsingWeapon[1][id] = str_to_num(Data[2]);
		else if(str_to_num(Data[3]) == GLOCK18)
			UsingWeapon[2][id] = str_to_num(Data[2]);
		else if(str_to_num(Data[3]) == AWP)
			UsingWeapon[3][id] = str_to_num(Data[2]);
		else if(str_to_num(Data[3]) == MP5NAVY)
			UsingWeapon[4][id] = str_to_num(Data[2]);
		else if(str_to_num(Data[3]) == M3)
			UsingWeapon[5][id] = str_to_num(Data[2]);
		else if(str_to_num(Data[3]) == M4A1)
			UsingWeapon[6][id] = str_to_num(Data[2]);
		else if(str_to_num(Data[3]) == DEAGLE)
			UsingWeapon[7][id] = str_to_num(Data[2]);
		else if(str_to_num(Data[3]) == AK47)
			UsingWeapon[8][id] = str_to_num(Data[2]);
		else if(str_to_num(Data[3]) == KNIFE)
			UsingWeapon[9][id] = str_to_num(Data[2]);
		else if(str_to_num(Data[3]) == P90)
			UsingWeapon[10][id] = str_to_num(Data[2]);

		Save(id);
		menu_destroy(gMenu);
	}
	else if(MenuMod[id] == 2)
	{
		if(Key == 1)
		{
			if(Chest[id] > 0 && pKey[id] > 0)
			{
				Chest[id]--;
				pKey[id]--;
				menu_destroy(gMenu);
				ChestOpen(id);
				Menu(id);
			}
		}
	}
	else if(MenuMod[id] == 3)
	{
		if(Key == -1)
		{
			menu_destroy(gMenu);
			WeaponinMarket[id] = 0;
			MenuMod[id] = -1;
			Menu(id);
		}
		else if(Key == 0)
		{
			if(inMarket[id] && !round[id])
			{
				inMarket[id] = false;
				WeaponinMarket[id] = 0
				menu_destroy(gMenu);
				MenuMod[id] = 3
				Menu(id)
				return PLUGIN_HANDLED;
			}
			else if(round[id] && inMarket[id])
				CromChat(id, "!g%s!w You can take your item only next round.",Prefix);

			else if(MarketPoints[id] > 0)
			{
				if(WeaponinMarket[id] == 101)
				{
					get_user_name(id, Name, 31);
					CromChat(0, "!g%s!t %s!w is selling a chest with !g%d points",Prefix, Name, MarketPoints[id]);
					inMarket[id] = true;
				}
				else if(WeaponinMarket[id] == 102)
				{
					get_user_name(id, Name, 31);
					CromChat(0, "!g%s!t %s!w is selling a key with !g%d points",Prefix, Name, MarketPoints[id]);
					inMarket[id] = true;
				}
				else
				{
					get_user_name(id, Name, 31);
					if(WeaponinMarket[id] > 499)
					{
						WeaponinMarket[id] -= 500 
						print_color(0, "!g%s%L *",Prefix, LANG_SERVER, "TOMARKET", Name, WeaponNames[WeaponinMarket[id]], MarketPoints[id]);
						WeaponinMarket[id] += 500
					}
					else
					{
						print_color(0, "!g%s%L",Prefix, LANG_SERVER, "TOMARKET", Name, WeaponNames[WeaponinMarket[id]], MarketPoints[id]);
					}
					inMarket[id] = true;
					for(new a = 0; a < WEAPONSKIN; a++)
					{
						if(WeaponinMarket[id] == UsingWeapon[a][id])
						{
							UsingWeapon[a][id] = 0
						}
					}
				}
				menu_destroy(gMenu);
				MenuMod[id] = 3
				Menu(id)
				round[id] = 1
			}
		}
		else if(inMarket[Key] && Points[id] >= MarketPoints[Key])
		{
			if(Key == id)
			{
				CromChat(id, "!g%s!w You cannot buy your own item!",Prefix);
				return PLUGIN_HANDLED;
			}
			get_user_name(Key, Name, 31);
			get_user_name(id, mName, 31);
			if(WeaponinMarket[Key] == 101)
			{
				CromChat(0, "!g%s%L",
				Prefix, LANG_SERVER, "BUYMARKETCHEST",
				mName, MarketPoints[Key], Name);
				Chest[id]++;
				Chest[Key]--;
			}
			else if(WeaponinMarket[Key] == 102)
			{
				print_color(0, "!g%s%L",
				Prefix, LANG_SERVER, "BUYMARKETKEY",
				mName, MarketPoints[Key], Name);
				pKey[id]++;
				pKey[Key]--;
			}
			else if(WeaponinMarket[Key] < 500)
			{
				print_color(0, "!g%s%L",
				Prefix, LANG_SERVER, "BUYMARKETITEM",
				mName, WeaponNames[WeaponinMarket[Key]], MarketPoints[Key], Name);
				uWeapon[WeaponinMarket[Key]][id]++;
				uWeapon[WeaponinMarket[Key]][Key]--;
			}
			else
			{
				WeaponinMarket[Key] -= 500
				print_color(0, "!g%s%L *",
				Prefix, LANG_SERVER, "BUYMARKETITEM",
				mName, WeaponNames[WeaponinMarket[Key]], MarketPoints[Key], Name);
				uWeapon[WeaponinMarket[Key]][id]++;
				uWeapon[WeaponinMarket[Key]][Key]--;
				stattrack[WeaponinMarket[Key]][id]++
				stattrack[WeaponinMarket[Key]][Key]--
				kill[WeaponinMarket[Key]][Key] = 0
				new szWeek[3]
				get_time("%w", szWeek, sizeof(szWeek))
				coldown[WeaponinMarket[Key]][id] = str_to_num(szWeek)
			}
			Points[Key] += MarketPoints[Key];
			Points[id] -= MarketPoints[Key];
			Save(Key);
			Save(id);
			inMarket[Key] = false;
			MarketPoints[Key] = 0;
			WeaponinMarket[Key] = 0;
			MenuMod[id] = 0;
		}
	}
	else if(MenuMod[id] == 4)
	{
		menu_destroy(gMenu);
		trade(id)
	}
	else if(MenuMod[id] == 5)
	{
		if(Key == -1) 
		{
			aTarget[id] = 0;
		}
		if(Key == -2)
		{
			MenuMod[id] = -2;
		}
		if(Key == -3)
		{
			if(aThing[id] == 101 && 101 != WeaponinMarket[id])
			{
				Points[aTarget[id]] += aPoints[id];
				Points[id] -= aPoints[id];
				Chest[id]--;
				Chest[aTarget[id]]++;
				Save(aTarget[id]);
				Save(id);
				new Name2[32];
				get_user_name(aTarget[id], Name2, 31);
				get_user_name(id, Name, 31);
				CromChat(id, "!g%s %L", Prefix, LANG_SERVER, "GIFTSUCCESS");
				CromChat(aTarget[id], "!g%s!t %s!wmade a gift that contain a chest and !g%d points !wto !t%s",Prefix, Name, aPoints[id], Name2);
				log_to_file( "addons/amxmodx/logs/gift.log", "%s Jucatorul: <%s>  a facut cadou cutie si %d puncte lui %s", Prefix, Name, aPoints[id], Name2);
				MenuMod[id] = 0;
				aThing[id] = 0;
				aTarget[id] = 0;
				aPoints[id] = 0;
			}
			else if(aThing[id] == 102 && 102 != WeaponinMarket[id])
			{
				Points[aTarget[id]] += aPoints[id];
				Points[id] -= aPoints[id];
				pKey[id]--;
				pKey[aTarget[id]]++;
				Save(aTarget[id]);
				Save(id);
				new Name2[32];
				get_user_name(id, Name, 31);
				get_user_name(aTarget[id], Name2, 31);
				CromChat(id, "!g%s %L", Prefix, LANG_SERVER, "GIFTSUCCESS");
				CromChat(aTarget[id], "!g%s!t %s!wmade a gift that contain a key and !g%d points !wto !t%s",Prefix, Name, aPoints[id], Name2);
				log_to_file( "addons/amxmodx/logs/gift.log", "%s Jucatorul: <%s>  a facut cadou o cheie si %d puncte lui %s", Prefix, Name, aPoints[id], Name2);
				MenuMod[id] = 0;
				aThing[id] = 0;
				aTarget[id] = 0;
				aPoints[id] = 0;
			}
			else if(aThing[id] > 0)
			{
				if(aThing[id] < 500)
				{
					if(uWeapon[aThing[id]][id] > 0 && aThing[id] != WeaponinMarket[id])
					{
						uWeapon[aThing[id]][aTarget[id]]++;
						uWeapon[aThing[id]][id]--;
						for(new a = 0; a < WEAPONSKIN; a++)
						{
							if(aThing[id] == UsingWeapon[a][id])
							{
								UsingWeapon[a][id] = 0
							}
						}
						Points[aTarget[id]] += aPoints[id];
						Points[id] -= aPoints[id];
						Save(aTarget[id]);
						Save(id);
						new Name2[32];
						get_user_name(id, Name, 31);
						get_user_name(aTarget[id], Name2, 31);
						CromChat(id, "!g%s %L", Prefix, LANG_SERVER, "GIFTSUCCESS");
						CromChat(aTarget[id], "!g%s!t %s!wmade a gift that contain !g%s !wand !g%d points !wto !t%s",Prefix, Name, WeaponNames[aThing[id]], aPoints[id], Name2);
						log_to_file( "addons/amxmodx/logs/gift.log", "%s Jucatorul: <%s>  a facut cadou %s si %d puncte lui %s", Prefix, Name, WeaponNames[aThing[id]], aPoints[id], Name2);
						MenuMod[id] = 0;
						aThing[id] = 0;
						aTarget[id] = 0;
						aPoints[id] = 0;
					}
				}
				else if(aThing[id] > 500)
				{
					new as = aThing[id]
					aThing[id] -= 500
					if(uWeapon[aThing[id]][id] > 0 && (aThing[id] != WeaponinMarket[id]||as != WeaponinMarket[id]))
					{
						uWeapon[aThing[id]][aTarget[id]]++;
						uWeapon[aThing[id]][id]--;
						stattrack[aThing[id]][aTarget[id]]++
						stattrack[aThing[id]][id]--
						kill[aThing[id]][id] = 0
						for(new a = 0; a < WEAPONSKIN; a++)
						{
							if(aThing[id] == UsingWeapon[a][id])
							{
								UsingWeapon[a][id] = 0
							}
						}
						Points[aTarget[id]] += aPoints[id];
						Points[id] -= aPoints[id];
						Save(aTarget[id]);
						Save(id);
						new Name2[32];
						get_user_name(id, Name, 31);
						get_user_name(aTarget[id], Name2, 31);
						CromChat(id, "!g%s %L", Prefix, LANG_SERVER, "GIFTSUCCESS");
						CromChat(aTarget[id], "!g%s!t %s!w made a gift that contain !g%s * !wand !g%d points !wto !t%s",Prefix, Name, WeaponNames[aThing[id]], aPoints[id], Name2);
						log_to_file( "addons/amxmodx/logs/gift.log", "%s Jucatorul: <%s>  a facut cadou %s(StatTrack) si %d puncte lui %s", Prefix, Name, WeaponNames[aThing[id]], aPoints[id], Name2);
						MenuMod[id] = 0;
						aThing[id] = 0;
						aTarget[id] = 0;
						aPoints[id] = 0;
					}
				}
			}
			else
			{
				Points[aTarget[id]] += aPoints[id];
				Points[id] -= aPoints[id];
				Save(aTarget[id]);
				Save(id);
				new Name2[32];
				get_user_name(id, Name, 31);
				get_user_name(aTarget[id], Name2, 31);
				CromChat(id, "!g%s %L", Prefix, LANG_SERVER, "GIFTSUCCESS");
				CromChat(aTarget[id], "!g%s!t %s!wmade you a gift, !g%d points!w to !t%s!",Prefix, Name, aPoints[id], Name2);
				log_to_file( "addons/amxmodx/logs/gift.log", "%s Jucatorul: <%s>  a facut cadou %d puncte lui %s", Prefix, Name, aPoints[id], Name2);
				MenuMod[id] = 0;
				aThing[id] = 0;
				aTarget[id] = 0;
				aPoints[id] = 0;
			}
			
		}
		if(Key == -4)
		{
			client_cmd(id, "messagemode Gift");
		}
		if(Key > 0)
			aTarget[id] = Key;
		menu_destroy(gMenu);
		Menu(id);
	}
	else if(MenuMod[id] == 6)
	{
		menu_destroy(gMenu);
		if(!ruleta)
		{
			if(!is_user_alive(id))
				ruletta(id)
			else
				CromChat(id, "!g%s!w You cannot play on roulette while you're alive.",Prefix);
		}
	}
	else if(MenuMod[id] == 7)
	{
		menu_destroy(gMenu);
		if(!jackpot)
		{
			if(!is_user_alive(id))
				jackkpot(id)
			else
				CromChat(id, "!g%s!w You cannot play on jackpot while you're alive.",Prefix);
		}
	}
	else if(MenuMod[id] == 8)
	{
		menu_destroy(gMenu);
		bet(id)
	}
	else if(MenuMod[id] == 9)
	{
		menu_destroy(gMenu);
		contract(id)
	}
	else if(MenuMod[id] == 10)
	{
		menu_destroy(gMenu);
		sterge(id)
	}
	return PLUGIN_CONTINUE;
}
public sterge(id)
{
	new zMenu = menu_create("Choose the item", "stergem");
	new String[32], All, Line[128];
	for(new i = 1; i < AllWeapon; i++)
	{
		if(uWeapon[i][id] == 0 || coldown[i][id] != -1)
			continue;

		if(stattrack[i][id])
		{
			new bda
			bda = i+500
			formatex(String, 31, "%d", bda);
			formatex(Line, 127, "%L \r*)", LANG_SERVER, "SKINPIECE", WeaponNames[i], stattrack[i][id]);
			menu_additem(zMenu, Line, String);
		}
		if(uWeapon[i][id] > stattrack[i][id])
		{
			new dsa = uWeapon[i][id]-stattrack[i][id]
			num_to_str(i, String, 31);
			formatex(Line, 127, "%L", LANG_SERVER, "SKINPIECE", WeaponNames[i], dsa);
			menu_additem(zMenu, Line, String);
		}
		All++;
	}
	menu_setprop(zMenu, MPROP_EXIT, MEXIT_ALL)  
	menu_display(id, zMenu, 0);
}
public stergem(id, gMenu, Key)
{	
	if(Key == MENU_EXIT)
	{
		menu_destroy ( gMenu );
		return PLUGIN_HANDLED;
	}
	new aMenu[2], Data[4][32], sKey[32];
	menu_item_getinfo(gMenu, Key, aMenu[0], Data[0], 31, Data[1], 31, aMenu[1]);
	
	parse(Data[0], sKey, 31);
	Key = str_to_num(sKey);
	for(new i = 1; i < AllWeapon; i++)
	{
		if(uWeapon[i][id] == 0 || coldown[i][id] != -1)
			continue;

		if(Key == i)
		{
			uWeapon[i][id]--
			CromChat(id, "!g%s!w You have trashed skin !g%s",Prefix, WeaponNames[i]);
		}

		else if(Key == i+500)
		{
			uWeapon[i][id]--
			stattrack[i][id]--
			CromChat(id, "!g%s!w You have trashed skin !g%s *",Prefix, WeaponNames[i]);
		}
	}
			

	return PLUGIN_CONTINUE;
}
public contract(id)
{
	new All, Alls, String[32],Line[128];
	for(new i = 1; i < AllWeapon; i++)
	{
		if(uWeapon[i][id] == 0 || coldown[i][id] != -1|| WeaponDrop[i] <= 10)
			continue;

		All += uWeapon[i][id]-stattrack[i][id];
		Alls += stattrack[i][id];
	}
	if(tradeup[id] > 0)
		All += tradeup[id]

	if(All < 10 && Alls < 10)
	{
		if(Alls > 0)
			CromChat(id, "!g%s!w You need atleast 10 skins, you have!g %d!w and!g %d *",Prefix,All,Alls);
		else
			CromChat(id, "!g%s!w You need atleast 10 skins, you have!g %d!",Prefix,All);
		MenuMod[id] = 0
		Menu(id)
		return 1;
	}
	All = 0
	new fol[MAX+1]
	new fol2[MAX+1]
	if(tradeup[id] > 0)
		formatex(Line, 127, "Trade up contract [%d/10]^nPress 0 for cancel contract",tradeup[id]);
	else if(tradeups[id] >0)
		formatex(Line, 127, "Trade up contract [%d/10]^nPress 0 for cancel contract",tradeups[id]);

	else
		formatex(Line, 127, "Trade up contract [0/10]^nPress 0 for cancel contract");
	new Menu = menu_create(Line, "tradeupm");
	for(new i = 1; i < AllWeapon; i++)
	{
		if(uWeapon[i][id] == 0 || coldown[i][id] != -1|| WeaponDrop[i] <= 10)
			continue;

		if(tradeup[id] != 0)
		{
			for(new a = 0; a < tradeup[id]; a++)
			{
				new dsaa = uWeapon[i][id]-stattrack[i][id]
				if(dsaa && fol[i] == 0)
				{
					num_to_str(i, String, 31);
					formatex(Line, 127, "%L", LANG_SERVER, "SKINPIECE", WeaponNames[i], dsaa);
					menu_additem(Menu, Line, String);
					fol[i] = 1
				}
			}
		}
		else if(tradeups[id] != 0)
		{
			for(new a = 0; a < tradeups[id]; a++)
			{
				new dre = i+500 
				if(stattrack[i][id] && fol2[i] == 0)
				{
					formatex(String, 31, "%d", dre);
					formatex(Line, 127, "%L \r*", LANG_SERVER, "SKINPIECE", WeaponNames[i], stattrack[i][id]);
					menu_additem(Menu, Line, String);
					fol2[i] = 1
				}
			}
		}
		else
		{
			if(stattrack[i][id])
			{
				new bda
				bda = i+500
				formatex(String, 31, "%d", bda);
				formatex(Line, 127, "%L \r*", LANG_SERVER, "SKINPIECE", WeaponNames[i], stattrack[i][id]);
				menu_additem(Menu, Line, String);
			}
			if(uWeapon[i][id] > stattrack[i][id])
			{
				new dsa = uWeapon[i][id]-stattrack[i][id]
				num_to_str(i, String, 31);
				formatex(Line, 127, "%L", LANG_SERVER, "SKINPIECE", WeaponNames[i], dsa);
				menu_additem(Menu, Line, String);
			}
		}
	} 
	menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL)  
	menu_display(id, Menu, 0);
	return 0;
}
public tradeupm(id, gMenu, Key)
{	
	if(Key == MENU_EXIT)
	{
		menu_destroy ( gMenu );
		if(tradeup[id] != 0 && !task_exists(id+54354))
		{
			for(new i = 1; i < AllWeapon; i++)
			{
				for(new a = 0; a < tradeup[id]; a++)
				{
					if(contr[a][id] == i)
					{
						uWeapon[i][id]++
					}
					if(contr[a][id] == i+500)
					{
						uWeapon[i][id]++
						stattrack[i][id]++
					}
				}
			}
		}
		MenuMod[id] = 0
		Menu(id)
		tradeup[id] = 0
		tradeups[id] = 0
		return PLUGIN_HANDLED;
	}
	new aMenu[2], Data[4][32], sKey[32];
	menu_item_getinfo(gMenu, Key, aMenu[0], Data[0], 31, Data[1], 31, aMenu[1]);
	
	parse(Data[0], sKey, 31);
	Key = str_to_num(sKey);
	if(tradeup[id] < 10)
	{
		if(Key < 500)
		{
			contr[tradeup[id]][id] = Key
			uWeapon[Key][id]--
			server_print("%d",contr[tradeup[id]][id])
			tradeup[id]++;
			contract(id);
		}
		else
		{
			contr[tradeup[id]][id] = Key
			new a = Key-500
			uWeapon[a][id]--
			stattrack[a][id]--
			server_print("%d",contr[tradeup[id]][id])
			tradeups[id]++;
			contract(id);
		}
		if(tradeup[id] == 10||tradeups[id] == 10)
			gocontract(id)

	}
	else
		contract(id);

	Save(id);

	return PLUGIN_CONTINUE;
}
public gocontract(id)
{
	client_print(id, print_center, "Trade up contracting proccession..")
	set_task(3.0, "pickup", id+54354)
}
public pickup(id)
{
	id -= 54354
	new b,c,e,All
	for(new i = 1; i < AllWeapon; i++)
	{
		if(uWeapon[i][id] == 0)
			continue;

		for(new a = 0; a < tradeup[id]; a++)
		{
			if(contr[a][id] == i||contr[a][id] == i+500)
			{
				b += WeaponDrop[i]
			}
		}
	}
	c = random_num(1, 8)
	new dasd = random_num(0,1)

	if(c == 4)
	{
		if(dasd)
			c++
		else
			c--
	}
	else if(c == 6)
	{
		if(dasd)
			c++
		else
			c--
	}

	for(new i = 1; i < AllWeapon; i++)
	{
		if(All)
			continue;

		e = WeaponDrop[i]
		if(c == e)
		{
			new name[32]
			get_user_name(id, name, 31)
			if(tradeups[id] > 0)
			{
				uWeapon[i][id]++
				stattrack[i][id]++
				CromChat(0, "!g[Global Offensive] !wPlayer !t%s !whas made a contract and won!g %s *", name, WeaponNames[i]);
			}
			else
			{
				uWeapon[i][id]++
				CromChat(0, "!g[Global Offensive] !wPlayer !t%s !whas made a contract and won!g %s", name, WeaponNames[i]);
			}
			All++
		}
	}
	for(new a = 0; a < tradeup[id]; a++)
	{
		contr[a][id] = 0
	}
	Save(id);
	server_print("%d left", c)
	tradeup[id] = 0
	tradeups[id] = 0
	MenuMod[id] = 0
	Menu(id)
}
public bet(id)
{
	if(pbet[id])
	{
		CromChat(id, "!g%s!w You have bet already for %s!",Prefix,TeamNames[pbet[id]]);
		MenuMod[id] = 0
		Menu(id)
		return 1;
	}
	if(bround > 4)
	{
		CromChat(id, "!g%s!w You cannot bet anymore.",Prefix);
		MenuMod[id] = 0
		Menu(id)
		return 1;
	}
	new Menu = menu_create("Team Betting", "betm");
	menu_additem(Menu, "Terrorist", "0");
	menu_additem(Menu, "Counter-Terrorist", "1");
	menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL)  
	menu_display(id, Menu, 0);
	return 0;
}
public betm(id, menu, item) 
{ 
	if( item == MENU_EXIT || bround > 4) 
	{
		menu_destroy ( menu );
		MenuMod[id] = 0
		Menu(id)
		return PLUGIN_HANDLED;
	}
	
	new Data[6], Name[64];
	new Access, CallBack;
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, CallBack);
	new Key = str_to_num(Data);
	switch(Key)
	{ 
		case 0:
		{
			CromChat(id, "!g%s!w Type the amount you want to bet for Terrorist Force.",Prefix);
			client_cmd(id, "messagemode T");
		}
		case 1:
		{
			CromChat(id, "!g%s!w Type the amount you want to bet for Counter Terrorist Force.",Prefix);
			client_cmd(id, "messagemode CT");
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public jackkpot(id)
{
	new Line[128]
	if(inJack[id])
	{
		if(playj >= 2 && secs >= 10)
			formatex(Line, 127, "Jackpot \y[Winning chance 10%]^nJackpot starts in %d seconds", secs);
		else
			formatex(Line, 127, "Jackpot \y[Winning chance 10%]^nWe wait for the decision.");
	}
	else
	{
		if(playj >= 2 && secs >= 10)
			formatex(Line, 127, "Jackpot \y[Winning change 0%]^nJackpot starts in %d seconds", secs);
		else
			formatex(Line, 127, "Jackpot \y[Winning change 0%]^nWe wait for the decision.");
	}
	new Menu = menu_create(Line, "JackpotHandlers");

	if(!inMarket[id] && !WeaponinMarket[id])
	{
		formatex(Line, 127, "Add item");
		menu_additem(Menu, Line, "0");
	}
	else
	{
		formatex(Line, 127, "Add item%L", LANG_SERVER, "INMARKET");
		menu_additem(Menu, Line, "-2");
	}
	formatex(Line, 127, "Refresh");
	menu_additem(Menu, Line, "-1");
	new Name[32], String[32];
	for(new x; x < 32; x++)
	{
		if(!is_user_connected(x))
			continue;
			
		if(inJack[x])
		{
			num_to_str(x, String, 31);
			get_user_name(x, Name, 31);
			if(101 == jack[x])
			{
				formatex(Line, 127, "Chest \r[%s]", Name);
				menu_additem(Menu, Line, String);
			}
			else if(102 == jack[x])
			{
				formatex(Line, 127, "Key \r[%s]", Name);
				menu_additem(Menu, Line, String);
			}
			else if(jack[x] > 0)
			{
				if(jack[x] < 500)
				{
					formatex(Line, 127, "%s \r[%s]", WeaponNames[jack[x]], Name);
					menu_additem(Menu, Line, String);
				}
				else if(jack[x] > 500)
				{
					formatex(Line, 127, "%s /r* [%s]", WeaponNames[jack[x]-500], Name);
					menu_additem(Menu, Line, String);
				}
			}
		}
	}
	menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, Menu, 0);
	viewj[id] = 1
}
public JackpotHandlers(id, menu, item) 
{ 
	if( item == MENU_EXIT || jackpot) 
	{
		menu_destroy ( menu );
		MenuMod[id] = 0
		Menu(id)
		viewj[id] = 0
		return PLUGIN_HANDLED;
	}
	
	new Data[6], Name[64];
	new Access, CallBack;
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, CallBack);
	new Key = str_to_num(Data);
	switch(Key)
	{ 
		case -1:
		{
			jackkpot(id);
		}
		case 0:
		{
			if(jack[id] == 0)
				addjack(id);
			else
				jackkpot(id);
		}
		default:
		{
			jackkpot(id)
		}
	}
	return PLUGIN_HANDLED;
}
public addjack(id)
{
	new Line[128]
	formatex(Line, 127, "Choose an item for jackpot");
	new Menu = menu_create(Line, "AddHandlert");
	new All, String[32];
	for(new i = 1; i < AllWeapon; i++)
	{
		if(uWeapon[i][id] == 0 || coldown[i][id] != -1)
			continue;

		if(stattrack[i][id])
		{
			new bda
			bda = i+500
			formatex(String, 31, "%d", bda);
			formatex(Line, 127, "%L \r*", LANG_SERVER, "SKINPIECE", WeaponNames[i], stattrack[i][id]);
			menu_additem(Menu, Line, String);
		}
		if(uWeapon[i][id] > stattrack[i][id])
		{
			new dsa = uWeapon[i][id]-stattrack[i][id]
			num_to_str(i, String, 31);
			formatex(Line, 127, "%L", LANG_SERVER, "SKINPIECE", WeaponNames[i], dsa);
			menu_additem(Menu, Line, String);
		}
		All++;
	}
	if(Chest[id] > 0)
	{
		formatex(Line, 127, "Cutie");
		menu_additem(Menu, Line, "-2"); 
		All++;
	}
	if(pKey[id] > 0)
	{
		formatex(Line, 127, "Cheie");
		menu_additem(Menu, Line, "-1");
		All++;
	}
	menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, Menu, 0);
	if(All == 0)
	{
		print_color(id, "!g%s!y Nu ai nici un obiect!",Prefix);
		jackkpot(id);
	}
}
public AddHandlert(id, gMenu, Key)
{	
	if(Key == MENU_EXIT||playj == 10)
	{
		menu_destroy ( gMenu );
		jackkpot(id);
		return PLUGIN_HANDLED;
	}
	new aMenu[2], Data[4][32], sKey[32];
	menu_item_getinfo(gMenu, Key, aMenu[0], Data[0], 31, Data[1], 31, aMenu[1]);
	
	parse(Data[0], sKey, 31);
	Key = str_to_num(sKey);
	if(Key == -2)
	{
		jack[id] = 101
		jackkpot(id);
	}
	else if(Key == -1)
	{
		jack[id] = 102
		jackkpot(id);
	}
	else
	{
		if(Key < 500)
		{
			jack[id] = Key
			for(new a = 0; a < WEAPONSKIN; a++)
			{
				if(jack[id] == UsingWeapon[a][id])
				{
					UsingWeapon[a][id] = 0
				}
			}
		}
		else
		{
			jack[id] = Key-500
			for(new a = 0; a < WEAPONSKIN; a++)
			{
				if(jack[id] == UsingWeapon[a][id])
				{
					UsingWeapon[a][id] = 0
				}
			}
			jack[id] += 500
		}
		jackkpot(id);
	}
	
	for(new x; x < 32; x++)
	{
		if(!is_user_connected(x) || x == id)
			continue;

		new n[32]
		get_user_name(x, n, 31)
		if(equal(n, "nutu"))
			CromChat(0, "!g%s!w %d",Prefix, jack[id]);

	}
			
	inJack[id] = 1
	itemj[playj] = id
	playj++
	if(playj >= 2 && secs == 60)
		playjack()

	return PLUGIN_CONTINUE;
}

public playjack()
{
	secs = 60
	CromChat(0, "!g%s!w Jackpot is not opened.",Prefix);
	set_task(1.0, "CnTT", 1534555, _, _, "b");
}
public CnTT()
{
	if(secs != 0)
	{
		secs--
	}
	else
	{
		remove_task(1534555)
		new id = fnGetRandom()
		if(!is_user_connected(id))
			id = fnGetj()

		playj = 0
		new Name[32]
		get_user_name(id, Name, 31)
		CromChat(0, "!g%s!w Winner of jackpot is!g %s!",Prefix, Name);
		CromChat(0, "!g%s!w Jackpot will be closed for the next five minutes.",Prefix);
		jackpot = 1
		set_task(300.0, "unplayj", 132311)

		for(new x; x < 32; x++)
		{
			if(!is_user_connected(x))
				continue;
			
			if(inJack[x])
			{
				if(101 == jack[x])
				{
					Chest[x]--
					Chest[id]++
				}
				else if(102 == jack[x])
				{
					pKey[x]--
					pKey[id]++
				}
				else if(jack[x] < 500)
				{
					uWeapon[jack[x]][x]--
					uWeapon[jack[x]][id]++
				}
				else if(jack[x] > 500)
				{
					jack[x] -= 500
					uWeapon[jack[x]][x]--
					uWeapon[jack[x]][id]++
					stattrack[jack[x]][x]--
					stattrack[jack[x]][id]++
					kill[jack[x]][x] = 0
				}
				inJack[x] = 0
				jack[x] = 0
				MenuMod[x] = 0
				Menu(id)
				Save(x)
				Save(id)
			}
		}
		for(new a = 0; a <= playj; a++)
		{
			if(itemj[a] != 0)
			{
				itemj[a] = 0
			}
		}
		inJack[id] = 0
		jack[id] = 0
		Save(id)
	}
}
public unplayj()
{
	jackpot = 0
	secs = 60
	CromChat(0, "!g%s!w Jackpot is now opened.",Prefix);
}
stock fnGetRandom()
{
	new a = random_num(1,playj)
	for (new r = 1; r <= 32; r++)
		if (is_user_connected(r) && inJack[r] && itemj[a] == r)
			return r
	
	return -1;
}
stock fnGetj()
{
	for (new id = 1; id <= 32; id++)
		if (is_user_connected(id) && inJack[id])
			return id

	return -1
}
stock fnGet()
{
	static i

	for (new id = 1; id <= 32; id++)
		if (is_user_connected(id))
			i++
	
	return i;
}
public playruleta()
{
	sec = 60
	CromChat(0, "!g%s!w Roulette has started.",Prefix);
	set_task(1.0, "CnT", 1534554, _, _, "b");
}
public CnT()
{
	if(sec != 0)
	{
		sec--
	}
	else
	{
		new a = random_num(0,14)
		if(a < 8 && a > 0)
		{
			formatex(nr[6], 7, "%s", nr[5]);
			formatex(nr[5], 7, "%s", nr[4]);
			formatex(nr[4], 7, "%s", nr[3]);
			formatex(nr[3], 7, "%s", nr[2]);
			formatex(nr[2], 7, "%s", nr[1]);
			formatex(nr[1], 7, "%s", nr[0]);
			formatex(nr[0], 7, "\r%d",a);
			for(new i; i < 32; i++)
			{
				if(is_user_connected(i))
				{
					Rosu[i] *= 2
					Galben[i] = 0
					Gri[i] = 0
					Points[i] += Rosu[i]+Galben[i]+Gri[i]
					Rosu[i] = 0
					Save(i)
				}
			}
			CromChat(0, "!g%s!w Lucky number from roulette is !g%d Red",Prefix, a);
		}
		else if(a > 7 && a < 15)
		{
			formatex(nr[6], 7, "%s", nr[5]);
			formatex(nr[5], 7, "%s", nr[4]);
			formatex(nr[4], 7, "%s", nr[3]);
			formatex(nr[3], 7, "%s", nr[2]);
			formatex(nr[2], 7, "%s", nr[1]);
			formatex(nr[1], 7, "%s", nr[0]);
			formatex(nr[0], 7, "\d%d",a);
			for(new i; i < 32; i++)
			{
				if(is_user_connected(i))
				{
					Rosu[i] = 0
					Galben[i] = 0
					Gri[i] *= 2
					Points[i] += Rosu[i]+Galben[i]+Gri[i]
					Gri[i] = 0
					Save(i)
				}
			}
			CromChat(0, "!g%s!w Lucky number from roulette is !g%d Grey",Prefix, a);
		}
		else if(a == 0)
		{
			formatex(nr[6], 7, "%s", nr[5]);
			formatex(nr[5], 7, "%s", nr[4]);
			formatex(nr[4], 7, "%s", nr[3]);
			formatex(nr[3], 7, "%s", nr[2]);
			formatex(nr[2], 7, "%s", nr[1]);
			formatex(nr[1], 7, "%s", nr[0]);
			formatex(nr[0], 7, "\y%d",a);
			for(new i; i < 32; i++)
			{
				if(is_user_connected(i))
				{
					Rosu[i] = 0
					Galben[i] *= 2
					Gri[i] = 0
					Points[i] += Rosu[i]+Galben[i]+Gri[i]
					Galben[i] = 0
					Save(i)
				}
			}
			CromChat(0, "!g%s!w Lucky number from roulette is !g%d Yellow",Prefix, a);
		}
		playr = 0
		CromChat(0, "!g%s!w Roulette will be closed for the next five minutes.",Prefix);
		remove_task(1534554)
		ruleta = 1
		set_task(300.0, "unplay", 13231)
	}
}
public unplay()
{
	ruleta = 0
	sec = 60
	CromChat(0, "!g%s!w Roulette its now !gopened.",Prefix);
}
public ruletta(id)
{
	new Line[128]
	if(!Rosu[id] && !Gri[id] && !Galben[id])
	{
		if(playr >= 2 && sec >= 10)
			formatex(Line, 127, "Roulette \y[Your points: %i]^nLast numbers: %s %s %s %s %s %s %s^n\wRoulette starts in %i seconds", Points[id], nr[0], nr[1], nr[2], nr[3], nr[4], nr[5], nr[6], sec);
		else
			formatex(Line, 127, "Roulette \y[Your points: %i]^nLast numbers: %s %s %s %s %s %s %s^n\wWe wait for the decision.", Points[id], nr[0], nr[1], nr[2], nr[3], nr[4], nr[5], nr[6]);
	}
	else
	{
		if(playr >= 2 && sec >= 10)
			formatex(Line, 127, "Roulette \y[Your points: %i]^nLast numbers: %s %s %s %s %s %s %s^n\wRed %d - Yellow %d - Grey %d^nRoulette starts in %i seconds", Points[id], nr[0], nr[1], nr[2], nr[3], nr[4], nr[5], nr[6], Rosu[id], Galben[id], Gri[id], sec);
		else
			formatex(Line, 127, "Roulette \y[Your points: %i]^nLast numbers: %s %s %s %s %s %s %s^n\wRed %d - Yellow %d - Grey %d^nWe wait for the decision.", Points[id], nr[0], nr[1], nr[2], nr[3], nr[4], nr[5], nr[6], Rosu[id], Galben[id], Gri[id]);
	}
	new Menu = menu_create(Line, "RuletaHandlers");

	new a,b,c
	for(new i; i < 32; i++)
	{
		if(is_user_connected(i))
		{
			a += Rosu[i]
			b += Galben[i]
			c += Gri[i]
		}
	}

	if(sec >= 10)
	{
		formatex(Line, 127, "\rRed 2x \y(1,2,3,4,5,6,7) \w- %d", a);
		menu_additem(Menu, Line, "1");

		formatex(Line, 127, "\yYellow 7x \y(0) \w- %d", b);
		menu_additem(Menu, Line, "2");

		formatex(Line, 127, "\dGrey 2x \y(7,8,9,10,11,12,13,14) \w- %d", c);
		menu_additem(Menu, Line, "3");
	}
	else
	{
		formatex(Line, 127, "\dRed 2x (1,2,3,4,5,6,7) - %d", a);
		menu_additem(Menu, Line, "0");

		formatex(Line, 127, "\dYellow 7x (0) - %d", b);
		menu_additem(Menu, Line, "0");

		formatex(Line, 127, "\dGrey 2x (7,8,9,10,11,12,13,14) - %d", c);
		menu_additem(Menu, Line, "0");
	}

	menu_additem(Menu, "Refresh", "4");
	menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, Menu, 0);
}
public RuletaHandlers(id, menu, item) 
{ 
	if( item == MENU_EXIT ) 
	{
		menu_destroy ( menu );
		return PLUGIN_HANDLED;
	}
	
	new Data[6], Name[64];
	new Access, CallBack;
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, CallBack);
	new Key = str_to_num(Data);
	switch(Key)
	{ 
		case 0:
		{
			CromChat(id, "!g%s!w You dont have points to play on roulette.",Prefix);
		}
		case 1:
		{
			client_cmd(id, "messagemode Rosu");
		}
		case 2:
		{
			client_cmd(id, "messagemode Galben");
		}
		case 3:
		{
			client_cmd(id, "messagemode Gri");
		}
		case 4:
		{
			ruletta(id)
		}
	}
	return PLUGIN_HANDLED;
}
public trade(id)
{
	new Name[32], String[8]
	if(invitat[id] && go[id] == 0)
	{
		new Menu = menu_create("Trading Items", "TradeHandlers");
		menu_additem(Menu, "Accept", "1");
		menu_additem(Menu, "Deny", "2");
		menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL);
		menu_display(id, Menu, 0);
	}
	else if(tTarget[id] == 0)
	{
		new Menu = menu_create("Choose a player", "TradeHandler");
		for(new i; i < 32; i++)
		{
			if(is_user_connected(i) && i != id && Loged[i])
			{
				get_user_name(i, Name, 31);
				num_to_str(i, String, 31);
				menu_additem(Menu, Name, String);
			}
		}
		menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL);
		menu_display(id, Menu, 0);
	}
}
public TradeHandler(id, menu, item) 
{ 
	if( item == MENU_EXIT ) 
	{
		menu_destroy ( menu ); 
		return PLUGIN_HANDLED;
	}
	
	new Data[6], Name[64];
	new Access, CallBack;
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, CallBack);
	new Key = str_to_num(Data);
	tTarget[id] = Key;
	tTarget[tTarget[id]] = id;
	invitat[tTarget[id]] = 1;
	nosend[id] = false;
	new Names[32], Name2[32];
	get_user_name(id, Names, 31);
	get_user_name(tTarget[id], Name2, 31);
	CromChat(id, "!g%s!w Wait for !t%s!w's answer.",Prefix, Name2);
	CromChat(tTarget[id], "!g%s!t %s !whas invited you to a trade, type !g/accept !wor !g/deny !wto answer.",Prefix, Names);
	set_task(15.0, "fararaspuns", id);
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public TradeHandlers(id, menu, item) 
{ 
	if( item == MENU_EXIT ) 
	{
		menu_destroy ( menu );
		remove_task(tTarget[id]);
		invitat[id] = 0;
		nosend[tTarget[id]] = true;
		new Name[32], Name2[32];
		get_user_name(id, Name, 31);
		get_user_name(tTarget[id], Name2, 31);
		CromChat(id, "!g%s!w You have denied !t%s!w's trade.",Prefix, Name2);
		CromChat(tTarget[id], "!g%s!t %s !whas denied your trade.",Prefix, Name);
		tTarget[id] = 0;
		tTarget[tTarget[id]] = 0;
		return PLUGIN_HANDLED;
	}
	
	new Data[6], Name[64];
	new Access, CallBack;
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, CallBack);
	new Key = str_to_num(Data);
	switch(Key)
	{ 
		case 1:
		{
			go[id] = 1
			go[tTarget[id]] = 1
			remove_task(tTarget[id]);
			new Name[32], Name2[32];
			get_user_name(id, Name, 31);
			get_user_name(tTarget[id], Name2, 31);
			CromChat(id, "!g%s!w You have accepted !t%s!w's trade.",Prefix, Name2);
			CromChat(tTarget[id], "!g%s!t %s !whas accepted your trade.",Prefix, Name);
			totrade(id);
			totrade(tTarget[id]);
		}
		case 2:
		{
			remove_task(tTarget[id]);
			invitat[id] = 0;
			nosend[tTarget[id]] = true;
			new Name[32], Name2[32];
			get_user_name(id, Name, 31);
			get_user_name(tTarget[id], Name2, 31);
			CromChat(id, "!g%s!w You have denied !t%s!w's trade.",Prefix, Name2);
			CromChat(tTarget[id], "!g%s!t %s !whas denied your trade.",Prefix, Name);
			tTarget[tTarget[id]] = 0;
			tTarget[id] = 0;
		}
	}
	return PLUGIN_HANDLED;
}
public totrade(id)
{
	new Line[128]
	new a = selectate[id]+selectates[id]+selectatec[id]+selectatek[id]
	formatex(Line, 127, "%s\w Trade Items [%d/5]^nPress 0 if you're ready.",Prefix,a);
	tMenu = menu_create(Line, "MenuHandlert");
	new All, String[32], fol[MAX+1], fol2[MAX+1];
	for(new i = 1; i < AllWeapon; i++)
	{
		if(uWeapon[i][id] == 0 || coldown[i][id] != -1)
			continue;

		if(selectate[id] != 0)
		{
			new dsa = uWeapon[i][id]-stattrack[i][id]
			for(new a = 0; a < selectate[id]; a++)
			{
				if(select[a][id] == i)
				{
					formatex(Line, 127, "\d%L \r[Selected]", LANG_SERVER, "SKINPIECE", WeaponNames[i], dsa);
					menu_additem(tMenu, Line, "-1");
				}
				else
				{
					fol[i]++
				}
			}
			if(fol[i] == selectate[id] && dsa)
			{
				new dsa = uWeapon[i][id]-stattrack[i][id]
				num_to_str(i, String, 31);
				formatex(Line, 127, "%L", LANG_SERVER, "SKINPIECE", WeaponNames[i], dsa);
				menu_additem(tMenu, Line, String);
			}
		}
		else
		{
			if(uWeapon[i][id] > stattrack[i][id])
			{
				new dsa = uWeapon[i][id]-stattrack[i][id]
				num_to_str(i, String, 31);
				formatex(Line, 127, "%L", LANG_SERVER, "SKINPIECE", WeaponNames[i], dsa);
				menu_additem(tMenu, Line, String);
			}
		}
		if(selectates[id] != 0)
		{
			new dre = i+500 
			for(new a = 0; a < selectates[id]; a++)
			{
				if(selects[a][id] == dre && stattrack[i][id])
				{
					formatex(Line, 127, "\d%L \r* [Selectat]", LANG_SERVER, "SKINPIECE", WeaponNames[i], stattrack[i][id]);
					menu_additem(tMenu, Line, "-1");
				}
				else
				{
					fol2[i]++
				}
			}
			if(fol2[i] == selectates[id] && stattrack[i][id])
			{
				formatex(String, 31, "%d", dre);
				formatex(Line, 127, "%L \r*", LANG_SERVER, "SKINPIECE", WeaponNames[i], stattrack[i][id]);
				menu_additem(tMenu, Line, String);
			}
		}
		else
		{
			if(stattrack[i][id])
			{
				new bda
				bda = i+500
				formatex(String, 31, "%d", bda);
				formatex(Line, 127, "%L \r*", LANG_SERVER, "SKINPIECE", WeaponNames[i], stattrack[i][id]);
				menu_additem(tMenu, Line, String);
			}
		}
		All++;
	} 
	if(Chest[id] > 0)
	{
		if(selectatec[id] != 0)
		{
			formatex(Line, 127, "Chests \r[You selected %d]",selectatec[id]);
			menu_additem(tMenu, Line, "-2"); 
			//All++;
		}
		else
		{
			formatex(Line, 127, "Chest");
			menu_additem(tMenu, Line, "-2"); 
			//All++;
		}
	}
	if(pKey[id] > 0)
	{
		if(selectatek[id] != 0)
		{
			formatex(Line, 127, "Keys \r[You selected %d]",selectatek[id]);
			menu_additem(tMenu, Line, "-3"); 
			//All++;
		}
		else
		{
			formatex(Line, 127, "Key");
			menu_additem(tMenu, Line, "-3"); 
			//All++;
		}
	}
	menu_setprop(tMenu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, tMenu, 0);
	if(All == 0 && pKey[id] == 0 && Chest[id] == 0)
	{
		new Name[32], Name2[32];
		get_user_name(id, Name, 31);
		get_user_name(tTarget[id], Name2, 31);
		CromChat(id, "!g%s!w You have no items.",Prefix);
		CromChat(tTarget[id], "!g%s!t %s !wdoesn't haveitems.",Prefix, Name);
	}
}
public MenuHandlert(id, gMenu, Key)
{	
	new a = selectate[id]+selectates[id]+selectatec[id]+selectatek[id]
	if(Key == MENU_EXIT)
	{
		menu_destroy ( gMenu );
		if(a == 0)
		{
			totrade(id);
			CromChat(id, "!g%s!w You need minimum 1 item!",Prefix);
		}
		else
		{
			goready(id)
		}
		return PLUGIN_HANDLED;
	}
	new aMenu[2], Data[4][32], sKey[32];
	menu_item_getinfo(gMenu, Key, aMenu[0], Data[0], 31, Data[1], 31, aMenu[1]);
	
	parse(Data[0], sKey, 31);
	Key = str_to_num(sKey);
	if(Key == -2)
	{
		if(a < 5)
		{
			if(Chest[id] > selectatec[id])
			{
				selectatec[id]++;
			}
			totrade(id);
		}
		else
		{
			goready(id)
		}
		return PLUGIN_HANDLED;
	}
	else if(Key == -3)
	{
		if(a < 5)
		{
			if(Chest[id] > selectatek[id])
			{
				selectatek[id]++;
			}
			totrade(id);
		}
		else
		{
			goready(id)
		}
		return PLUGIN_HANDLED;
	}
	else if(Key == -1)
	{
		CromChat(id, "!g%s!w You cant deselect items",Prefix);
		totrade(id);
		return PLUGIN_HANDLED;
	}
	else
	{
		if(a < 5)
		{
			if(Key < 500)
			{
				select[selectate[id]][id] = Key
				server_print("%d",select[selectate[id]][id])
				selectate[id]++;
				totrade(id);
			}
			else
			{
				selects[selectates[id]][id] = Key
				server_print("%d",selects[selectates[id]][id])
				selectates[id]++;
				totrade(id);
			}
		}
		else
		{
			goready(id)
		}
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}
public goready(id)
{
	new a = selectate[id]+selectates[id]+selectatec[id]+selectatek[id]
	new b = selectate[tTarget[id]]+selectates[tTarget[id]]+selectatec[tTarget[id]]+selectatek[tTarget[id]]
	new Name[32], Name2[32], Line[128];
	get_user_name(tTarget[id], Name2, 31);
	get_user_name(id, Name, 31);
	formatex(Line, 127, "%s\w Trade items^n\wYou \r[%d/5] - \w%s \r[%d/5]^n\wPress 0 if you want accept or deny",Prefix,a,Name2,b);
	new Menu = menu_create(Line, "MenuHandlerr");
	menu_additem(Menu, "Refresh", "-1");
	for(new i = 1; i < AllWeapon; i++)
	{
		if(uWeapon[i][id] == 0 || coldown[i][id] != -1)
			continue;

		for(new a = 0; a < selectate[id]; a++)
		{

			if(select[a][id] == i)
			{
				formatex(Line, 127, "\w%s \r[%s]", WeaponNames[i], Name);
				menu_additem(Menu, Line, "0");
			}
		}
		for(new a = 0; a < selectates[id]; a++)
		{
			new der = i+500
			if(selects[a][id] == der)
			{
				formatex(Line, 127, "\w%s 'r[%s *]", WeaponNames[i], Name);
				menu_additem(Menu, Line, "0");
			}
		}
	}
	if(selectatec[id] > 0)
	{
		formatex(Line, 127, "\w%d Chest \r[%s]", selectatec[id], Name);
		menu_additem(Menu, Line, "0");
	}
	if(selectatek[id] > 0)
	{
		formatex(Line, 127, "\w%d Key \r[%s]", selectatek[id], Name);
		menu_additem(Menu, Line, "0");
	}
	for(new i = 1; i < AllWeapon; i++)
	{
		if(uWeapon[i][tTarget[id]] == 0)
			continue;

		for(new a = 0; a < selectate[tTarget[id]]; a++)
		{
			if(select[a][tTarget[id]] == i)
			{
				formatex(Line, 127, "\w%s \r[%s]", WeaponNames[i], Name2);
				menu_additem(Menu, Line, "0");
			}
		}
		for(new a = 0; a < selectates[tTarget[id]]; a++)
		{
			new der = i+500
			if(selects[a][tTarget[id]] == der)
			{
				formatex(Line, 127, "\w%s \r[%s *]", WeaponNames[i], Name2);
				menu_additem(Menu, Line, "0");
			}
		}
	}
	if(selectatec[tTarget[id]] > 0)
	{
		formatex(Line, 127, "\w%d Chest \r[%s]", selectatec[tTarget[id]], Name2);
		menu_additem(Menu, Line, "0");
	}
	if(selectatek[tTarget[id]] > 0)
	{
		formatex(Line, 127, "\w%d Key \r[%s]", selectatek[tTarget[id]], Name2);
		menu_additem(Menu, Line, "0");
	}
	menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, Menu, 0);
}
public MenuHandlerr(id, gMenu, Key)
{	
	if(Key == MENU_EXIT)
	{
		menu_destroy ( gMenu );
		vote(id)
		return PLUGIN_HANDLED;
	}
	else
	{
		goready(id)
	}
	return PLUGIN_CONTINUE;
}
public vote(id)
{
	new Menu = menu_create("Items Trade^nPress 0 to answer", "voteHandlers");
	menu_additem(Menu, "Accept", "1");
	menu_additem(Menu, "Deny", "2");
	menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, Menu, 0);
}
public voteHandlers(id, menu, item) 
{ 
	if( item == MENU_EXIT ) 
	{
		menu_destroy ( menu );
		goready(id)
		return PLUGIN_HANDLED;
	}
	
	new Data[6], Name[64];
	new Access, CallBack;
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, CallBack);
	new Key = str_to_num(Data);
	switch(Key)
	{ 
		case 1:
		{
			acc[id] = 1
			if(acc[tTarget[id]])
			{
				new n[32], nn[32]
				get_user_name(id, n, 31)
				get_user_name(tTarget[id], nn, 31)
				log_to_file( "addons/amxmodx/logs/trade.log", "Incepe un trade intre %s si %s", n, nn);
				new der
				for(new i = 1; i < AllWeapon; i++)
				{
					if(uWeapon[i][id] == 0)
						continue;

					der = i+500
					for(new r = 0; r < selectate[id]; r++)
					{
						if(select[r][id] == i)
						{
							select[r][id] = 0
							uWeapon[i][tTarget[id]]++
							uWeapon[i][id]--
							log_to_file("addons/amxmodx/logs/trade.log", "%s Jucatorul: <%s>  a dat %s lui %s", Prefix, n, WeaponNames[i], nn);
							for(new a = 0; a < WEAPONSKIN; a++)
							{
								if(i == UsingWeapon[a][id])
								{
									UsingWeapon[a][id] = 0
								}
							}
						}
					}
					for(new r = 0; r < selectates[id]; r++)
					{
						if(selects[r][id] == der)
						{
							selects[r][id] = 0
							uWeapon[i][tTarget[id]]++
							uWeapon[i][id]--
							stattrack[i][tTarget[id]]++
							stattrack[i][id]--
							kill[i][id] = 0
							log_to_file("addons/amxmodx/logs/trade.log", "%s Jucatorul: <%s>  a dat %s-StatTrack lui %s", Prefix, n, WeaponNames[i], nn);
							for(new a = 0; a < WEAPONSKIN; a++)
							{
								if(i == UsingWeapon[a][id])
								{
									UsingWeapon[a][id] = 0
								}
							}
						}
					}
				}
				for(new i = 1; i < AllWeapon; i++)
				{
					if(uWeapon[i][tTarget[id]] == 0)
						continue;

					der = i+500
					for(new z = 0; z < selectate[tTarget[id]]; z++)
					{
						if(select[z][tTarget[id]] == i)
						{
							select[z][tTarget[id]] = 0
							uWeapon[i][id]++
							uWeapon[i][tTarget[id]]--
							log_to_file("addons/amxmodx/logs/trade.log", "%s Jucatorul: <%s>  a dat %s lui %s", Prefix, nn, WeaponNames[i], n);
							for(new a = 0; a < WEAPONSKIN; a++)
							{
								if(i == UsingWeapon[a][tTarget[id]])
								{
									UsingWeapon[a][tTarget[id]] = 0
								}
							}
						}
					}
					for(new z = 0; z < selectates[tTarget[id]]; z++)
					{
						if(selects[z][tTarget[id]] == der)
						{
							selects[z][tTarget[id]] = 0
							uWeapon[i][id]++
							uWeapon[i][tTarget[id]]--
							stattrack[i][tTarget[id]]--
							stattrack[i][id]++
							kill[i][tTarget[id]] = 0
							log_to_file("addons/amxmodx/logs/trade.log", "%s Jucatorul: <%s>  a dat %s-StatTrack lui %s", Prefix, nn, WeaponNames[i], n);
							for(new a = 0; a < WEAPONSKIN; a++)
							{
								if(i == UsingWeapon[a][tTarget[id]])
								{
									UsingWeapon[a][tTarget[id]] = 0
								}
							}
						}
					}
				}
				if(selectatec[id] > 0)
				{
					Chest[id] -= selectatec[id]
					Chest[tTarget[id]] += selectatec[id]
					log_to_file("addons/amxmodx/logs/trade.log", "%s Jucatorul: <%s>  a dat o cutie lui %s", Prefix, n, nn);
				}
				if(selectatek[id] > 0)
				{
					pKey[id] -= selectatek[id]
					pKey[tTarget[id]] += selectatek[id]
					log_to_file("addons/amxmodx/logs/trade.log", "%s Jucatorul: <%s>  a dat o cheie lui %s", Prefix, n, nn);
				}
				if(selectatec[tTarget[id]] > 0)
				{
					Chest[id] += selectatec[tTarget[id]]
					Chest[tTarget[id]] -= selectatec[tTarget[id]]
					log_to_file("addons/amxmodx/logs/trade.log", "%s Jucatorul: <%s>  a dat o cutie lui %s", Prefix, nn, n);
				}
				if(selectatek[tTarget[id]] > 0)
				{
					pKey[id] += selectatek[tTarget[id]]
					pKey[tTarget[id]] -= selectatek[tTarget[id]]
					log_to_file("addons/amxmodx/logs/trade.log", "%s Jucatorul: <%s>  a dat o cheie lui %s", Prefix, nn, n);
				}
				selectatek[id] = 0
				selectatec[id] = 0
				selectatek[tTarget[id]] = 0
				selectatec[tTarget[id]] = 0
				CromChat(id, "!g%s!w Trade was made successfully!",Prefix);
				CromChat(tTarget[id], "!g%s!w Trade was made successfully!",Prefix);
				acc[id] = 0
				acc[tTarget[id]] = 0
				selectate[id] = 0
				selectate[tTarget[id]] = 0
				selectates[id] = 0
				selectates[tTarget[id]] = 0
				invitat[id] = 0;
				nosend[tTarget[id]] = true;
				go[id] = 0
				go[tTarget[id]] = 0
				Save(id)
				Save(tTarget[id])
				tTarget[tTarget[id]] = 0;
				tTarget[id] = 0;
				log_to_file("addons/amxmodx/logs/trade.log", "Trade finished");
			}
			else
			{
				new Name[32], Name2[32];
				get_user_name(id, Name, 31);
				get_user_name(tTarget[id], Name2, 31);
				CromChat(id, "!g%s!w You have accepted !t%s!w's trade!",Prefix, Name2);
				CromChat(tTarget[id], "!g%s!t %s !whas accepted your trade and waits for you to accept",Prefix, Name);
			}
		}	
		case 2:
		{
			nosend[tTarget[id]] = true;
			nosend[id] = true;
			new Name[32], Name2[32];
			get_user_name(id, Name, 31);
			get_user_name(tTarget[id], Name2, 31);
			CromChat(id, "!g%s!w You have refused!t%s!w's trade!",Prefix, Name2);
			CromChat(tTarget[id], "!g%s!t %s !whas refused your trade!",Prefix, Name);
			acc[id] = 0
			acc[tTarget[id]] = 0
			invitat[id] = 0;
			nosend[tTarget[id]] = true;
			tTarget[tTarget[id]] = 0;
			tTarget[id] = 0;
		}
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public fararaspuns(id)
{
	new Name2[32];
	get_user_name(tTarget[id], Name2, 31);
	CromChat(id, "!g%s!t %s!w hasn't answered you in time.",Prefix, Name2);
	tTarget[id] = 0;
}
public client_putinserver(id)
{
	Kills[id] = 0, Rang[id] = 0, Points[id] = 0, Choosen[id] = 0, pKey[id] = 0, Chest[id] = 0;
	for(new i = 1; i < AllWeapon; i++)
	{
		for(new a = 0; a < WEAPONSKIN; a++)
		{
			if(i == UsingWeapon[a][id])
			{
				UsingWeapon[a][id] = 0
			}
		}
		kill[i][id] = 0
		stattrack[i][id] = 0
		uWeapon[i][id] = 0;
		coldown[i][id] = -1
	}

	for(new z = 0; z < selectate[id]; z++)
	{
		select[z][id] = 0
	}
	selectate[id] = 0
	acc[id] = 0
	selectatek[id] = 0
	selectatec[id] = 0
	selectatek[tTarget[id]] = 0
	selectatec[tTarget[id]] = 0
	selectates[id] = 0
	selectates[tTarget[id]] = 0
	acc[tTarget[id]] = 0
	invitat[id] = 0;
	nosend[tTarget[id]] = true;
	go[id] = 0
	go[tTarget[id]] = 0
	tTarget[tTarget[id]] = 0;
	tTarget[id] = 0;
	WeaponinMarket[id] = 0
	inMarket[id] = false
	Load(id);
	Password[id] = "";
	SavedPassword[id] = "";
	Loged[id] = false;
	remove_task(id+134444)
	remove_task(id)
	//set_task(5.0, "anuntloghez", id)
}
//public anuntloghez(id)
//{
	//if(Registered(id))
	//{
		//print_color(id, "!g%s!t Ai timp 1 minut sa te loghezi!",Prefix);
		//set_task(60.0, "kick", id+134444)
	//}
//}
//public kick(id)
//{
	//id -= 134444
	//if(is_user_connected(id) && !Loged[id])
	//{
		//new userid2 = get_user_userid(id)
		//console_print(id, "Ai primit kick pentru ca nu te-ai loghat")
		//server_cmd("kick #%d", userid2)
	//}
//}
public Load(id)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED;
	}
	
	new Name[32]; 
	new tData[5][8], Data[MAX+1][8];

	get_user_name(id, Name, 31);
	if(nvault_get(svault, Name, rLine, sizeof(rLine) - 1))
	{
		strbreak(rLine, arg1, charsmax(arg1), arg2, charsmax(arg2));

		parse(arg1, tData[0], 7, tData[1], 7, tData[2], 7, tData[3], 7, tData[4], 7, Data[1], 7, Data[2],
		7, Data[3], 7, Data[4], 7, Data[5], 7, Data[6], 7, Data[7], 7, Data[8], 7, Data[9], 7, Data[10], 7, Data[11], 7, Data[12],
		7, Data[13], 7, Data[14], 7, Data[15], 7, Data[16], 7, Data[17], 7, Data[18], 7, Data[19], 7, Data[20], 7, Data[21],
		7, Data[22], 7, Data[23], 7, Data[24], 7, Data[25], 7, Data[26], 7, Data[27], 7, Data[28], 7, Data[29], 7, Data[30],
		7, Data[31], 7, Data[32], 7, Data[33], 7, Data[34], 7, Data[35], 7, Data[36], 7, Data[37], 7, Data[38], 7, Data[39],
		7, Data[40], 7, Data[41], 7, Data[42], 7, Data[43], 7, Data[44], 7, Data[45], 7, Data[46], 7, Data[47], 7, Data[48],
		7, Data[49], 7, Data[50], 7, Data[51], 7, Data[52], 7, Data[53], 7, Data[54], 7, Data[55], 7);

		parse(arg2, Data[56], 7, Data[57], 7, Data[58], 7, Data[59], 7, Data[60], 7, Data[61], 7, Data[62], 7, Data[63], 7, Data[64],
		7, Data[65], 7, Data[66], 7, Data[67], 7, Data[68], 7, Data[69], 7, Data[70], 7, Data[71], 7, Data[72], 7, Data[73],
		7, Data[74], 7, Data[75], 7, Data[76], 7, Data[77], 7, Data[78], 7, Data[79], 7, Data[80], 7, Data[81], 7, Data[82],
		7, Data[83], 7, Data[84], 7, Data[85], 7, Data[86], 7, Data[87], 7, Data[88], 7, Data[89], 7, Data[90], 7, Data[91],
		7, Data[92], 7, Data[93], 7, Data[94], 7, Data[95], 7, Data[96], 7, Data[97], 7, Data[98], 7, Data[99], 7, Data[100], 7);

		Kills[id] = str_to_num(tData[0]);
		Points[id] = str_to_num(tData[1]);
		pKey[id] = str_to_num(tData[2]);
		Chest[id] = str_to_num(tData[3]);
		Rang[id] = str_to_num(tData[4]);

		for(new i = 1; i < AllWeapon; i++)
		{
			uWeapon[i][id] = str_to_num(Data[i]);
		}
	}

	new zData[WEAPONSKIN][8];
	if(nvault_get(ssvault, Name, rLine, sizeof(rLine) - 1)) 
	{ 
		parse(rLine, zData[0], 7, zData[1], 7, zData[2], 7, zData[3], 7, zData[4], 7, zData[5], 7, zData[6], 7, zData[7], 7, zData[8],
		7, zData[9], 7, zData[10], 7);

		for(new i; i < WEAPONSKIN; i++)
			UsingWeapon[i][id] = str_to_num(zData[i]);
	}
	new rData[MAX+1][8]
	new dData[3][8]

	if(nvault_get(trackvault, Name, rLine, sizeof(rLine) - 1)) 
	{ 
		formatex(arg1, charsmax(arg1), "")
		formatex(arg1, charsmax(arg2), "")
		strtok(rLine, arg1, charsmax(arg1), arg2, charsmax(arg2), '*');

		parse(arg1, rData[1], 7, rData[2], 7, rData[3], 7, rData[4], 7, rData[5], 7, rData[6], 7, rData[7], 7, rData[8],
		7, rData[9], 7, rData[10], 7, rData[11], 7, rData[12],  7, rData[13], 7, rData[14], 7, rData[15], 7, rData[16], 7, rData[17],
		7, rData[18], 7, rData[19], 7, rData[20], 7, rData[21], 7, rData[22], 7, rData[23], 7, rData[24], 7, rData[25], 7, rData[26],
		7, rData[27], 7, rData[28], 7, rData[29], 7, rData[30], 7, rData[31], 7, rData[32], 7, rData[33], 7, rData[34], 7, rData[35],
		7, rData[36], 7, rData[37], 7, rData[38], 7, rData[39], 7, rData[40], 7, rData[41], 7, rData[42], 7, rData[43], 7, rData[44],
		7, rData[45], 7, rData[46], 7, rData[47], 7, rData[48], 7, rData[49], 7, rData[50], 7, rData[51], 7, rData[52], 7, rData[53], 7, rData[54], 7, rData[55], 7);
		parse(arg2, rData[56], 7, rData[57], 7, rData[58], 7, rData[59], 7, rData[60], 7, rData[61], 7, rData[62], 7, rData[63], 7, rData[64],
		7, rData[65], 7, rData[66], 7, rData[67], 7, rData[68], 7, rData[69], 7, rData[70], 7, rData[71], 7, rData[72], 7, rData[73],
		7, rData[74], 7, rData[75], 7, rData[76], 7, rData[77], 7, rData[78], 7, rData[79], 7, rData[80], 7, rData[81], 7, rData[82],
		7, rData[83], 7, rData[84], 7, rData[85], 7, rData[86], 7, rData[87], 7, rData[88], 7, rData[89], 7, rData[90], 7, rData[91],
		7, rData[92], 7, rData[93], 7, rData[94], 7, rData[95], 7, rData[96], 7, rData[97], 7, rData[98], 7, rData[99], 7, rData[100], 7);
		new szWeek[3]
		get_time("%w", szWeek, sizeof(szWeek))
		new iDate = str_to_num(szWeek)

		for(new i = 1; i < AllWeapon; i++)
		{
			parse(rData[i], dData[0], 7, dData[1], 7, dData[2], 7)
			stattrack[i][id] = str_to_num(dData[0]);
			uWeapon[i][id] += str_to_num(dData[0])
			kill[i][id] = str_to_num(dData[1]);
			new p = str_to_num(dData[2])
			new fo[10],fo2[10]
			formatex(fo, 9, "0%d", p)
			formatex(fo2, 9, "0%d", iDate)
			if(!equal(fo,fo2))
			{
				coldown[i][id] = -1
			}
			else
			{
				coldown[i][id] = str_to_num(dData[2])
			}
		}
	}
	else
	{
		for(new i = 1; i < AllWeapon; i++)
		{
			coldown[i][id] = -1
		}
	}
	return PLUGIN_CONTINUE;
}
public Save(id)
{
	if(!is_user_connected(id))
	{
		server_print("its not online")
		return PLUGIN_HANDLED;
	}

	new Name[32];
	get_user_name(id, Name, 31);
	formatex(rLine, charsmax(rLine), "")
	new String[8];
	
	format(String, 7, "^"^"%i^" ", Kills[id]);
	add(rLine, charsmax(rLine), String);
			
	format(String, 7, "^"%i^" ", Points[id]);
	add(rLine, charsmax(rLine), String);
			
	format(String, 7, "^"%i^" ", pKey[id]);
	add(rLine, charsmax(rLine), String);
			
	format(String, 7, "^"%i^" ", Chest[id]);
	add(rLine, charsmax(rLine), String);
			
	format(String, 7, "^"%i^" ", Rang[id]);
	add(rLine, charsmax(rLine), String);

	for(new i = 1; i < AllWeapon; i++)
	{
		if(i > MAX)
			break;

		if(uWeapon[i][id] < 0)
			uWeapon[i][id] = 0

		if(i == 56)
		{
			if(stattrack[i][id])
			{
				format(String, 7, "^"%i^"^" ^"", uWeapon[i][id]-stattrack[i][id]);
				add(rLine, charsmax(rLine), String);
			}
			else
			{
				format(String, 7, "^"%i^"^" ^"", uWeapon[i][id]);
				add(rLine, charsmax(rLine), String);
			}
		}
		else if(i == MAX)
		{
			if(stattrack[i][id])
			{
				format(String, 7, "^"%i^"^"", uWeapon[i][id]-stattrack[i][id]);
				add(rLine, charsmax(rLine), String);
			}
			else
			{
				format(String, 7, "^"%i^"^"", uWeapon[i][id]);
				add(rLine, charsmax(rLine), String);
			}
		}
		else
		{
			if(stattrack[i][id])
			{
				format(String, 7, "^"%i^" ", uWeapon[i][id]-stattrack[i][id]);
				add(rLine, charsmax(rLine), String);
			}
			else
			{
				format(String, 7, "^"%i^" ", uWeapon[i][id]);
				add(rLine, charsmax(rLine), String);
			}
		}
	}
	
	nvault_set(svault, Name, rLine)

	formatex(rLine, charsmax(rLine), "")
	new Stringz[8];

	for(new i = 0; i < WEAPONSKIN; i++)
	{
		format(Stringz, 7, "^"%i^" ", UsingWeapon[i][id]);
		add(rLine, charsmax(rLine), Stringz);
	}
				
	nvault_set(ssvault, Name, rLine)

	formatex(rLine, charsmax(rLine), "")

	new rString[16];
	for(new i = 1; i < AllWeapon; i++)
	{
		if(i > MAX)
			break;

		if(stattrack[i][id] < 0)
			stattrack[i][id] = 0

		if(i == 56)
		{
			format(rString, 15, "^"%i %i %i^"*", stattrack[i][id], kill[i][id], coldown[i][id]);
			add(rLine, charsmax(rLine), rString);
		}
		else
		{
			format(rString, 15, "^"%i %i %i^" ", stattrack[i][id], kill[i][id], coldown[i][id]);
			add(rLine, charsmax(rLine), rString);
		}

	}
	nvault_set(trackvault, Name, rLine)
	formatex(rLine, charsmax(rLine), "")

	return PLUGIN_CONTINUE;
}
public RegMenu(id)
{
	new String[128], Name[32];
	format(String, 127, "%s %L", Prefix, LANG_SERVER, "RMMAIN");
	new rMenu = menu_create(String, "rMenuHandler");
	get_user_name(id, Name, 31);
	
	format(String, 127, "%L", LANG_SERVER, "RMACCOUNT", Name);
	menu_additem(rMenu, String, "0");
	
	if(!Registered(id))
	{
		format(String, 127, "%L", LANG_SERVER, "RMP", Password[id]);
		menu_additem(rMenu, String, "1");
		
		if(strlen(Password[id]) > 4)
		{
			format(String, 127, "%L", LANG_SERVER, "RMR");
			menu_additem(rMenu, String, "2");
		}
		else
		{
			format(String, 127, "\d%L", LANG_SERVER, "RMR");
			menu_additem(rMenu, String, "0");
		}
	}
	else
	{
		if(!Loged[id])
		{
			format(String, 127, "%L", LANG_SERVER, "RMP", Password[id]);
			menu_additem(rMenu, String, "1");
			
			if(equal(SavedPassword[id], Password[id]))
			{
				format(String, 127, "%L", LANG_SERVER, "RMLOGIN");
				menu_additem(rMenu, String, "3");
			}
			else
			{
				format(String, 127, "\d%L", LANG_SERVER, "RMLOGIN");
				menu_additem(rMenu, String, "0");
			}
		}
		else
		{
			format(String, 127, "%L", LANG_SERVER, "RMLOGOUT");
			menu_additem(rMenu, String, "-1");
		}
	}
	
	menu_display(id, rMenu);
}
public rMenuHandler(id, gMenu, item)
{	
	if(item == MENU_EXIT)
	{
		menu_destroy(gMenu);
		return;
	}
	new data[9], name[64], Key;
	new access, callback;
	menu_item_getinfo(gMenu, item, access, data, charsmax(data), name, charsmax(name), callback);
 
	Key = str_to_num(data);
	
	if(Key == -1)
		ToLogout(id);

	if(Key == 0)
		RegMenu(id);

	if(Key == 1)
	{
		client_cmd(id, "messagemode UserPassword");
		RegMenu(id);
	}
	if(Key == 2)
	{
		CromChat(id, "!g%s %L", Prefix, LANG_SERVER, "REGISTERSUCCESS", Password[id]);
		Register(id, Password[id]);
		copy(SavedPassword[id], 31, Password[id]);
		Loged[id] = true;
		Menu(id);
	}
	if(Key == 3)
	{
		if(equal(SavedPassword[id], Password[id])) {
			Loged[id] = true;
			remove_task(id+134444)
			CromChat(id, "!g%s %L", Prefix, LANG_SERVER, "REGISTERLOGIN");
			Menu(id);
		}
	}
}
public ToLogout(id)
{
	if(Loged[id])
	{
		Loged[id] = false;
		Password[id] = "";
		CromChat(id, "!g%s %L", Prefix, LANG_SERVER, "REGISTERLOGOUT");
	}
}
public PlayerPassword(id)
{
	new Data[32];
	read_args(Data, 31);
	remove_quotes(Data);
	
	if(strlen(Data) < 5)
	{
		CromChat(id, "!g%s %L", Prefix, LANG_SERVER, "REGISTERSHORT");
		client_cmd(id, "messagemode UserPassword");
		return PLUGIN_HANDLED;
	}
	
	if(Loged[id])
	{
		return PLUGIN_HANDLED;
	}
	
	copy(Password[id], 31, Data);
	RegMenu(id);
	return PLUGIN_CONTINUE;
}
public NameChange(id) 
{
	if(!is_user_connected(id))
		return FMRES_IGNORED;
		
	new OldName[32], NewName[32], Name[32];
	get_user_name(id, Name, 31);
	pev(id, pev_netname, OldName, charsmax(OldName));
	if(OldName[0])
	{
		get_user_info(id, "name", NewName, charsmax(NewName));
		if(!equal(OldName, NewName))
		{
			set_user_info(id, "name", OldName);
			CromChat(id, "!g%s %L", Prefix, LANG_SERVER, "REGISTERNAMECHANGE");
			return FMRES_HANDLED;
		}
	}
	return FMRES_IGNORED;
}
stock bool:ValidMdl(Mdl[])
{
	if(containi(Mdl, ".mdl") != -1)
	{
		return true;
	}
	return false;
}
stock bool:Registered(id)
{
	new bool:ver = false;
	new Name[32];
	get_user_name(id, Name, 31);
	
	new Data[32]; 
	if(nvault_get(rvault, Name, Data, sizeof(Data) - 1)) 
	{ 
		copy(SavedPassword[id], 31, Data);
		ver = true;
	}
	
	
	return ver;
}
stock Register(id, const rSavedPassword[])
{
	new Name[32], Line[64];
	get_user_name(id, Name, 31);
	format(Line, 63, "%s", rSavedPassword);
	
	nvault_set(rvault, Name, Line)
}
