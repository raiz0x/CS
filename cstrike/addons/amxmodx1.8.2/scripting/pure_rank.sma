#include <amxmodx>
#include <amxmisc>

//#define HTML_IN_MOTD
#define SAVE_RANKS_AFTER_SORT
#define SORT_INTERVAL 15.0

enum RankData
{
	Data_SteamID[32],
	Data_Name[32],
	Data_Kills,
	Data_Deaths
};

new g_File[64];
new Array:g_SteamID;
new Trie:g_Name, Trie:g_Kills, Trie:g_Deaths;
new g_Top15[2048];
new bool:g_Sort = true;
new g_Data[33][RankData], bool:g_Authorized[33];

public plugin_init()
{
	register_plugin("Rank", "3.0", "hleV");

	get_datadir(g_File, 63);
	add(g_File, 63, "/ranks.ini");

	g_SteamID = ArrayCreate(32, 1);
	g_Name = TrieCreate();
	g_Kills = TrieCreate();
	g_Deaths = TrieCreate();

	LoadRanks();
	ArraySort(g_SteamID, "SortRanks");
	WriteTop15();

	set_task(SORT_INTERVAL, "SortTask", _, _, _, "b");

	register_clcmd("say /rank", "SayRank");
	register_clcmd("say /top15", "SayTop15");

	register_event("DeathMsg", "DeathMsg", "a");
}

public plugin_end()
{
	ArraySort(g_SteamID, "SortRanks");
	SaveRanks();

	ArrayDestroy(g_SteamID);
}

public client_putinserver(Client)
{
	get_user_authid(Client, g_Data[Client][Data_SteamID], 31);

	if (!str_to_num(g_Data[Client][Data_SteamID][10]))
		return;

	get_user_name(Client, g_Data[Client][Data_Name], 31);

	if (!TrieKeyExists(g_Name, g_Data[Client][Data_SteamID]))
		AddRank(Client);
	else
		LoadData(Client);

	UpdateRank(Client, true);

	g_Authorized[Client] = true;
}

public client_disconnect(Client)
	g_Authorized[Client] = false;

public client_infochanged(Client)
{
	if (!g_Authorized[Client])
		return;

	static Name[32];
	get_user_info(Client, "name", Name, 31);

	if (equal(Name, g_Data[Client][Data_Name]))
		return;

	copy(g_Data[Client][Data_Name], 31, Name);
	UpdateRank(Client, true);
}

public SayRank(Client)
{
	new Position = GetPosition(Client);

	if (!g_Authorized[Client] || !Position)
	{
		client_print(Client, print_chat, "* You are not ranked.");

		return;
	}

	client_print
	(
		Client,
		print_chat,
		"* Your rank is %d of %d with %d kills and %d deaths.",
		Position,
		ArraySize(g_SteamID),
		g_Data[Client][Data_Kills],
		g_Data[Client][Data_Deaths]
	);
}

public SayTop15(Client)
	show_motd(Client, g_Top15, "Top 15");

public DeathMsg()
{
	new Killer = read_data(1);
	new Victim = read_data(2);

	if (g_Authorized[Victim])
	{
		g_Data[Victim][Data_Deaths]++;
		g_Sort = true;

		UpdateRank(Victim, false);
	}

	if (g_Authorized[Killer] && Killer != Victim)
	{
		g_Data[Killer][Data_Kills]++;
		g_Sort = true;

		UpdateRank(Killer, false);
	}
}

public SortTask()
{
	if (!g_Sort)
		return;

	ArraySort(g_SteamID, "SortRanks");
	WriteTop15();

#if defined SAVE_RANKS_AFTER_SORT
	SaveRanks();
#endif
}

public SortRanks(Array:SteamID, Position1, Position2)
{
	static SteamID1[32];
	ArrayGetString(SteamID, Position1, SteamID1, 31);

	static SteamID2[32];
	ArrayGetString(SteamID, Position2, SteamID2, 31);

	static Kills1;
	TrieGetCell(g_Kills, SteamID1, Kills1);

	static Kills2;
	TrieGetCell(g_Kills, SteamID2, Kills2);

	static Deaths1;
	TrieGetCell(g_Deaths, SteamID1, Deaths1);

	static Deaths2;
	TrieGetCell(g_Deaths, SteamID2, Deaths2);

	if (Kills1 - Deaths1 < Kills2 - Deaths2)
		return 1;
	else if (Kills1 - Deaths1 > Kills2 - Deaths2)
		return -1;

	return 0;
}

LoadRanks()
{
	new File = fopen(g_File, "r");

	if (!File)
		return;

	new Data[96], SteamID[32], Name[32], Kills[16], Deaths[16];

	while (!feof(File))
	{
		fgets(File, Data, 96);

		if (!strlen(Data))
			continue;

		parse(Data, SteamID, 31, Name, 31, Kills, 15, Deaths, 15);

		ArrayPushString(g_SteamID, SteamID);
		TrieSetString(g_Name, SteamID, Name);
		TrieSetCell(g_Kills, SteamID, str_to_num(Kills));
		TrieSetCell(g_Deaths, SteamID, str_to_num(Deaths));
	}

	fclose(File);
}

SaveRanks()
{
	new File = fopen(g_File, "w+");

	if (!File)
		return;

	for (new Position, Size = ArraySize(g_SteamID), SteamID[32], Name[32], Kills, Deaths; Position < Size; Position++)
	{
		ArrayGetString(g_SteamID, Position, SteamID, 31);
		TrieGetString(g_Name, SteamID, Name, 31);
		TrieGetCell(g_Kills, SteamID, Kills);
		TrieGetCell(g_Deaths, SteamID, Deaths);

		fprintf(File, "%s ^"%s^" %d %d^n", SteamID, Name, Kills, Deaths);
	}

	fclose(File);
}

AddRank(Client)
{
	g_Data[Client][Data_Kills] = 0;
	g_Data[Client][Data_Deaths] = 0;

	ArrayPushString(g_SteamID, g_Data[Client][Data_SteamID]);
	TrieSetString(g_Name, g_Data[Client][Data_SteamID], g_Data[Client][Data_Name]);
}

LoadData(Client)
{
	TrieGetCell(g_Kills, g_Data[Client][Data_SteamID], g_Data[Client][Data_Kills]);
	TrieGetCell(g_Deaths, g_Data[Client][Data_SteamID], g_Data[Client][Data_Deaths]);
}

UpdateRank(Client, bool:Name)
{
	if (Name)
		TrieSetString(g_Name, g_Data[Client][Data_SteamID], g_Data[Client][Data_Name]);

	TrieSetCell(g_Kills, g_Data[Client][Data_SteamID], g_Data[Client][Data_Kills]);
	TrieSetCell(g_Deaths, g_Data[Client][Data_SteamID], g_Data[Client][Data_Deaths]);
}

GetPosition(Client)
{
	static Position, Size, SteamID[32];

	for (Position = 0, Size = ArraySize(g_SteamID); Position < Size; Position++)
	{
		ArrayGetString(g_SteamID, Position, SteamID, 31);

		if (equal(SteamID, g_Data[Client][Data_SteamID]))
			return Position + 1;
	}

	return 0;
}	

WriteTop15()
{
#if defined HTML_IN_MOTD
	static const Header[] = "<body bgcolor=#000000><font color=#FFB000><pre>%5s  %22s  %5s  %5s^n^n";
	static const Buffer[] = "%4d   %22s  %5d  %6d^n";
#else
	static const Header[] = "%5s  %22s  %5s  %5s^n^n";
	static const Buffer[] = "%5d   %22s  %5d  %5d^n";
#endif

	static Length, Position, Size, SteamID[32], Name[32], Kills, Deaths;
	Length = formatex(g_Top15[Length], 2047 - Length, Header, "Rank", "Name", "Kills", "Deaths");

	for (Position = 0, Size = min(ArraySize(g_SteamID), 15); Position < Size; Position++)
	{
		ArrayGetString(g_SteamID, Position, SteamID, 31);
		TrieGetString(g_Name, SteamID, Name, 31);
		TrieGetCell(g_Kills, SteamID, Kills);
		TrieGetCell(g_Deaths, SteamID, Deaths);

		Length += formatex(g_Top15[Length], 2047 - Length, Buffer, Position + 1, Name, Kills, Deaths);
	}
}
