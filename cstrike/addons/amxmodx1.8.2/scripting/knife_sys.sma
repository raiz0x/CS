#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <fakemeta>
#include <fakemeta_util>
#include <colorchat>
#include <fvault>

#define MaxLevels 69
#define IsPlayer(%1) (1 <= %1 <= g_iMaxPlayers)

new MaxPlayers, syncObj, Lvl[33], XP[33], iPrefix
new ranks_hud, knife_xp, he_xp, hs_xp, kill_xp, suicide_xp, killer_msg
new UseAdminPrefixes, UseRankSystem, UseAllThree,UsePersonalTag
new HUDR,HUDG,HUDB,HUDX,HUDY, HUDEFFECT
new sayText, teamInfo, temp_flag[2]
new Vip, VipFlag

new const g_vault_name[] = "kniferanks";

new const Levels[MaxLevels] =
{
0,
50,
100,
150,
200,
250,
300,
350,
400,
450,
500, 
550, 
600,
650,
700,
750,
800,
850,
900,
950,
1000,
1050,
1100,
1150,
1200,
1250,
1300,
1350,
1400,
1450,
1500,
1550,
1600,
1650,
1700,
1750,
1800,
1850,
1900,
1950,
2000,
2050,
2100,
2150,
2200,
2250,
2300,
2350,
2400,
2450,
2500,
2550,
2600,
2650,
2700,
2750,
2800,
2850,
2900,
2950,
3000,
4000,
4150,
4270,
4320,
4410,
4460,
4500,
4580
}

new const Prefix[MaxLevels][] =
{
"Incepator",
"Incepator I",
"Incepator II",
"Incepator III",
"Jucator",
"Jucator I",
"Jucator II",
"Jucator III",
"Pro-Jucator",
"Pro-Jucator I",
"Pro-Jucator II",
"Pro-Jucator III",
"Ultra-Jucator",
"Ultra-Jucator I",
"Ultra-Jucator II",
"Ultra-Jucator III",
"Supernova",
"Supernova I",
"Supernova II",
"Supernova III",  
"Epic-Jucator",
"Epic-Jucator I",
"Epic-Jucator II",
"Epic-Jucator III",
"Specialist",
"Specialist I",
"Specialist II",
"Specialist III",
"Pro-Specialist",
"Pro-Specialist I",
"Pro-Specialist II",
"Pro-Specialist III",
"Ninja",
"Ninja I",
"Ninja II",
"Ninja III",
"Monster",
"Monster I",
"Monster II",
"Monster III",
"Jucator-Expert",
"Jucator-Expert I",
"Jucator-Expert II",
"Jucator-Expert III",
"Jucator-Global",
"Jucator-Global I",
"Jucator-Global II",
"Jucator-Global III",
"Recrut",
"Soldat",
"Fruntas",
"Caporal",
"Sergent",
"Plutonier",
"Assassin",
"Capitan",
"Ofiter",
"Locotenent",
"Plutonier",
"Sensei",
"Comandant",
"Amiral",
"Mos Craciun",
"Mos Nicolae",
"Ajutorul lui Mos Craciun",
"Spiridusi",
"Ren",
"Craciunita",
"Colindator"
}



#define MAX_GROUPS 11
new g_szGroups[ MAX_GROUPS ][ ] =
{
"FONDATOR",
"OWNER",
"CO-OWNER",
"GOD",
"SUPERVIZOR",
"SUPER MODERATOR",
"MODERATOR",
"ADMINISTRATOR",
"HELPER",
"SLOT",
"VIP"
};

new g_szGroupsFlags[ MAX_GROUPS ][ ] =
{
"abcdefghijklmnopqrstuvwxy",
"abcdefghijklmnopqrst",
"abcdefgijklmnopqrst",
"bcdefijklmnopqr",
"bcdefijmnopq",
"bcdefijmnop",
"bcdefijmno",
"bcdefij",
"bceij",
"b",
"ati"
};
new g_iGroupsFlagsValues[ MAX_GROUPS ];
static szChat[ 192 ],szName[ 32 ];

new szFile[ 128 ];
new PlayerTag[ 33 ][ 32 ];
new bool: PlayerHasTag[ 33 ];



public plugin_init()
{
    register_plugin("Admin Prefixes & Rank System", "1.0", "ajw1337");//edit by Adryyy
    
    Vip = register_cvar("enable_vip", "0")
    VipFlag = register_cvar("flag_vip", "c")
    
    register_event("DeathMsg","DeathMessage","a")
    
    register_clcmd("say /myrank", "cmdRank")
    register_clcmd("say_team /myrank", "cmdRank")
    register_clcmd("say /xp", "cmdRank")
    register_clcmd("say_team /xp", "cmdRank")


    UseAdminPrefixes = register_cvar("admin_prefixes", "0")
    UseRankSystem = register_cvar("rank_prefixes", "0")
    UsePersonalTag = register_cvar("personal_prefixes", "0")
    UseAllThree = register_cvar("rankadmintag_prefixes", "1")
    register_clcmd ("say", "hook_say")
    register_clcmd ("say_team", "hook_teamsay")

    
    ranks_hud = register_cvar("ranks_hud", "1")
    iPrefix = register_cvar("rank_prefix", "Knife");
    knife_xp = register_cvar("knife_xp", "4")
    he_xp = register_cvar("he_grenade_xp", "5")
    hs_xp = register_cvar("headshot_xp", "4")
    kill_xp = register_cvar("kill_xp", "2")
    suicide_xp = register_cvar("suicide_xp", "0")
    killer_msg = register_cvar("kill_message", "1")
    
    HUDR = register_cvar("hud_color_red", "139")
    HUDG = register_cvar("hud_color_green", "0")
    HUDB = register_cvar("hud_color_blue", "0")
    HUDX = register_cvar("hud_position_X", "-1.0")
    HUDY = register_cvar("hud_position_Y", "0.0")
    HUDEFFECT = register_cvar("hud_effects", "0")
    
    sayText = get_user_msgid("SayText")
    teamInfo = get_user_msgid("TeamInfo")
    register_message(sayText,"avoid_duplicated")
    
    register_concmd ("amx_give_xp", "CmdAddXP", ADMIN_LEVEL_A, "<nick | ct | t | @all> <xp>")
    register_concmd ("amx_take_xp", "CmdRemoveXP", ADMIN_LEVEL_A, "<nick | ct | t | @all> <xp>")
    
    register_forward( FM_ClientKill, "Fwd_Kill" );
    
    MaxPlayers = get_maxplayers()
    syncObj = CreateHudSyncObj()
    fvault_load(g_vault_name)


    for( new i = 0; i < MAX_GROUPS; i++ )	g_iGroupsFlagsValues[ i ] = read_flags( g_szGroupsFlags[ i ] );

	register_concmd( "amx_reloadtags", "ClCmdReloadTags", -1, "" );

	register_forward(FM_ClientUserInfoChanged, "ClientUserInfoChanged")
}


public plugin_precache( ) 
{
get_configsdir( szFile, sizeof ( szFile ) -1 );
formatex( szFile, sizeof ( szFile ) -1, "%s/PlayerTags.ini", szFile );

if( !file_exists( szFile ) ) 
{
	write_file( szFile, ";Aici treceti tag-urile jucatorilor !", -1 );
	write_file( szFile, ";ex: ^"Nume Player^" ^"Ip Player^" ^"SteamId Player^" ^"Tag Player^" ^"Flage^"", -1 );
	write_file( szFile, ";Numele sa fie exact( ex: Askhanar va fi Askhanar nu askhanar ! ) ", -1 );
}

}



public ClientUserInfoChanged(id) 
{ 
    static const name[] = "name" 
    static szOldName[32], szNewName[32] 
    pev(id, pev_netname, szOldName, charsmax(szOldName)) 
    if( szOldName[0] ) 
    { 
        get_user_info(id, name, szNewName, charsmax(szNewName)) 
        if( !equal(szOldName, szNewName) ) 
        { 
            set_user_info(id, name, szOldName) 
            return FMRES_HANDLED 
        } 
    } 
    return FMRES_IGNORED 
} 




public getPrefix()
{
    new Prefix[33]
    get_pcvar_string(iPrefix, Prefix, 32)

    return Prefix
}

public ShowHud(id)
{
set_hudmessage(get_pcvar_num(HUDR), get_pcvar_num(HUDG), get_pcvar_num(HUDB), get_pcvar_float(HUDX), get_pcvar_float(HUDY), get_pcvar_num(HUDEFFECT), 6.0, 1.0, 0.0, 0.0, -1)
if(MaxLevels == Lvl[id]+1)
ShowSyncHudMsg(id, syncObj,"Rank: %s^nXP: %d", Prefix[Lvl[id]], XP[id])
else
ShowSyncHudMsg(id, syncObj,"[ XP: %d/%d | LeveL %d: %s | Next Rank: %s ]", XP[id], Levels[Lvl[id]+1], Lvl[id]+1, Prefix[Lvl[id]], Prefix[Lvl[id]+1])
}

public cmdRank(id)
{
    if(MaxLevels == Lvl[id]+1)
        ColorChat(id, NORMAL, "^4[%s]^3 Rank^1:^4 %s^1 | ^3Level^1: ^4%d ^1| ^3XP^1: ^4%d^1.", getPrefix(), Prefix[Lvl[id]], Lvl[id]+1, XP[id])
    else
        ColorChat(id, NORMAL, "^4[%s]^3 Rank^1:^4 %s^1 | ^3Level^1: ^4%d ^1/ ^4%d ^1| ^3XP^1: ^4 %d ^1/ ^4%d ^3Next Rank: ^4%s^1.",getPrefix(), Prefix[Lvl[id]], Lvl[id]+1, MaxLevels, XP[id], Levels[Lvl[id]+1], Prefix[Lvl[id]+1])
}

public client_putinserver(id)
{
	if( is_user_bot( id ) || is_user_hltv( id ) ) return 1;

	if(get_pcvar_num(ranks_hud) == 1)	set_task(1.0, "ShowHud", id, _, _, "b")

	new currentPlayerRank = 0;
	while(currentPlayerRank < (MaxLevels - 1))
	{       
		if(XP[id] >= Levels[currentPlayerRank + 1])	++currentPlayerRank;     
		else	break;
	}
	Lvl[id] = currentPlayerRank;


	PlayerHasTag[ id ] = false;
	LoadPlayerTag( id );

	return 0;
}

public Fwd_Kill(id)
{
    if(is_user_alive(id)) {
        XP[id] -= get_pcvar_num(suicide_xp)
        CheckLevel(id)
        Save(id)
        if(get_pcvar_num(killer_msg) == 1)	ColorChat(id, RED, "^4[%s]^1 You committed ^3suicide ^1and ^3lost^4 %d XP^1.", getPrefix(),  get_pcvar_num(suicide_xp))
    }
    return PLUGIN_CONTINUE
}

public DeathMessage()
{       
    new killer = read_data(1);
    new victim = read_data(2);
    new headshot = read_data(3);
    new Weapon[ 32 ];
    read_data( 4, Weapon, charsmax( Weapon ) );
    format( Weapon, charsmax( Weapon ), "weapon_%s", Weapon );
    if( contain( Weapon, "nade" ) >= 0 )	Weapon = "weapon_hegrenade"
    new iWeapon = get_weaponid( Weapon );
    
    if(!killer || killer > MaxPlayers||killer == victim)	return PLUGIN_CONTINUE;
    
    new victim_name[32];
    get_user_name(victim, victim_name, 31);
    get_pcvar_string(VipFlag, temp_flag, charsmax(temp_flag));
    
    if(iWeapon == CSW_HEGRENADE)
    {
        if(get_pcvar_num(Vip) == 1 && get_user_flags(killer) & read_flags(temp_flag)) {
            XP[killer] += get_pcvar_num(he_xp)*2
            CheckLevel(killer)
            Save(killer)
            if(get_pcvar_num(killer_msg) == 1) {
                ColorChat(killer, RED, "^4[%s]^1 You killed ^4%s^1 with ^3HE Grenade^1 and get^4 %d XP^1.", getPrefix(),victim_name,  get_pcvar_num(he_xp)*2)
                return PLUGIN_CONTINUE
            }
        } else {
            XP[killer] += get_pcvar_num(he_xp)
            CheckLevel(killer)
            Save(killer)
            if(get_pcvar_num(killer_msg) == 1){
                ColorChat(killer, RED, "^4[%s]^1 You killed ^4%s^1 with ^3HE Grenade^1 and get^4 %d XP^1.", getPrefix(),victim_name,  get_pcvar_num(he_xp))
                return PLUGIN_CONTINUE
            }
        }
    }

    if(iWeapon == CSW_KNIFE)
    {
        if(get_pcvar_num(Vip) == 1 && get_user_flags(killer) & read_flags(temp_flag)) {
            XP[killer] += get_pcvar_num(knife_xp)*2
            CheckLevel(killer)
            Save(killer)
            if(get_pcvar_num(killer_msg) == 1) {
                ColorChat(killer, RED, "^4[%s]^1 You killed ^4%s^1 with ^3Knife^1 and get^4 %d XP^1.", getPrefix(),victim_name,  get_pcvar_num(knife_xp)*2)
                return PLUGIN_CONTINUE
            }
        } else {
            XP[killer] += get_pcvar_num(knife_xp)
            CheckLevel(killer)
            Save(killer)
            if(get_pcvar_num(killer_msg) == 1){
                ColorChat(killer, GREY, "^4[%s]^1 You killed ^4%s^1 with ^3Knife^1 and get^4 %d XP^1.", getPrefix(),victim_name, get_pcvar_num(knife_xp))
                return PLUGIN_CONTINUE
            }
        }
    }
    
    if(headshot)
    {
        if(get_pcvar_num(Vip) == 1 && get_user_flags(killer) & read_flags(temp_flag)) {
            XP[killer] += get_pcvar_num(hs_xp)*2
            CheckLevel(killer)
            Save(killer)
            if(get_pcvar_num(killer_msg) == 1){
                ColorChat(killer, BLUE, "^4[%s]^1 You killed ^4%s^1 with ^3Head^4Shot^1 and get^4 %d XP^1.", getPrefix(),victim_name, get_pcvar_num(hs_xp)*2)
                return PLUGIN_CONTINUE
            }
        } else {
            XP[killer] += get_pcvar_num(hs_xp)
            CheckLevel(killer)
            Save(killer)
            if(get_pcvar_num(killer_msg) == 1) {
                ColorChat(killer, BLUE, "^4[%s]^1 You killed ^4%s^1 with ^3Head^4Shot^1 and get^4 %d XP^1.", getPrefix(),victim_name, get_pcvar_num(hs_xp))
                return PLUGIN_CONTINUE
            }
        }
    }
    else
    {
        if(get_pcvar_num(Vip) == 1 && get_user_flags(killer) & read_flags(temp_flag)) {
            XP[killer] += get_pcvar_num(kill_xp)*2
            CheckLevel(killer)
            Save(killer)
            if(get_pcvar_num(killer_msg) == 1) {
                ColorChat(killer, NORMAL, "^4[%s]^1 You killed ^4%s^1 and get^4 %d XP^1.", getPrefix(),victim_name, get_pcvar_num(kill_xp)*2)
                return PLUGIN_CONTINUE
            }
        } else {
        XP[killer] += get_pcvar_num(kill_xp)
        CheckLevel(killer)
        Save(killer)
        if(get_pcvar_num(killer_msg) == 1){
            ColorChat(killer, RED, "^4[%s]^1 You killed ^4%s^1 and get^4 %d XP^1.", getPrefix(),victim_name, get_pcvar_num(kill_xp))
            return PLUGIN_CONTINUE
            }
        }
    }
    CheckLevel(killer)
    Save(killer)
    return PLUGIN_CONTINUE
}

public CheckLevel(id)
{        
    new currentPlayerRank = 0;
    while(currentPlayerRank < (MaxLevels - 1))
    {       
        if(XP[id] >= Levels[currentPlayerRank + 1])
            ++currentPlayerRank;     
        else         
            break;
    }
    Lvl[id] = currentPlayerRank;
}

public client_connect(id)	Load(id)

public client_disconnect(id)
{
    Save(id)
    XP[id] = 0
    Lvl[id] = 0
    remove_task(id)
}

public CmdAddXP (index, level, cid)
{
    if(!cmd_access(index, level, cid, 3)) return PLUGIN_HANDLED;
    
    new arg [32]
    read_argv (1, arg, 31)
    
    new AddXP [32]
    read_argv (2, AddXP, charsmax (AddXP))
    
    new XPtoGive = str_to_num (AddXP)
    
    new AdminName [32]
    new TargetName [32]
    get_user_name (index, AdminName, charsmax (AdminName))
    
    if(arg[0]=='@')
    {
        if(equali(arg[1],"All") || equali(arg[1],"ALL"))
        {
            new players[32], totalplayers, All
            get_players(players, totalplayers)
            
            for (new i = 0; i < totalplayers; i++)
            {
                All = players[i]
                
                XP[All] += XPtoGive
            }
            
            CheckLevel(All)
            ColorChat(0, NORMAL, "^4[%s] ^1ADMIN: ^3%s^1 gave^4 %i XP^1 to everyone!", getPrefix(), AdminName, XPtoGive)
        }
        else if(equali(arg[1],"T") || equali(arg[1],"t"))
        {
            new players[32], totalplayers, T
            get_players(players, totalplayers)
            
            for (new i = 0; i < totalplayers; i++)
            {
                if (get_user_team(players[i]) == 1)
                {
                    T = players[i]
                    
                    XP[T] += XPtoGive
                }
            }
            
            CheckLevel(T)
            ColorChat(0, RED, "^4[%s]^1 ADMIN: ^4%s ^1gave ^4%i XP ^1to all ^3Terrorists^1.", getPrefix(), AdminName, XPtoGive)
        }
        else if(equali(arg[1],"CT") || equali(arg[1],"ct"))
        {
            new players[32], totalplayers, CT
            get_players(players, totalplayers)
            
            for(new i = 0; i < totalplayers; i++)
            {
                if(get_user_team(players[i]) == 2)
                {
                    CT = players[i]
                    
                    XP[CT] += XPtoGive
                }
            }
            
            CheckLevel(CT)
            ColorChat(0, BLUE, "^4[%s]^1ADMIN: ^4%s^1 gave^4 %i XP^1to all ^3Counter-Terrorists^1.", getPrefix(), AdminName, XPtoGive)
        }
    }
    else
    {
        new iTarget = cmd_target(index, arg, 3)
        get_user_name (iTarget, TargetName, charsmax (TargetName))
        
        if(iTarget)
        {
            XP[iTarget] += XPtoGive
            
            CheckLevel(iTarget)
            ColorChat(0, NORMAL, "^4[%s]^1 ADMIN: ^3%s^1 gave^4 %i XP^1 to^4 %s^1.", getPrefix(), AdminName, XPtoGive, TargetName)
        }
    }
    return PLUGIN_HANDLED
}

public CmdRemoveXP (index, level, cid)
{
    if(!cmd_access(index, level, cid, 3)) return PLUGIN_HANDLED;
    
    new arg [32]
    read_argv (1, arg, 31)
    
    new RemoveXP [32]
    read_argv (2, RemoveXP, charsmax (RemoveXP))
    
    new XPtoTook = str_to_num (RemoveXP)
    
    new AdminName [32]
    new TargetName [32]
    get_user_name (index, AdminName, charsmax (AdminName))
    
    if(arg[0]=='@')
    {
        if(equali(arg[1],"All") || equali(arg[1],"ALL"))
        {
            new players[32], totalplayers, All
            get_players(players, totalplayers)
            
            for (new i = 0; i < totalplayers; i++)
            {
                All = players[i]
                
                XP[All] -= XPtoTook
            }
            
            CheckLevel(All)
            ColorChat(0, NORMAL, "^4[%s] ^1ADMIN: ^3%s^1 took^4 %i XP^1 from everyone!", getPrefix(), AdminName, XPtoTook)
        }
        else if(equali(arg[1],"T") || equali(arg[1],"t"))
        {
            new players[32], totalplayers, T
            get_players(players, totalplayers)
            
            for (new i = 0; i < totalplayers; i++)
            {
                if (get_user_team(players[i]) == 1)
                {
                    T = players[i]
                    
                    XP[T] -= XPtoTook
                }
            }
            
            CheckLevel(T)
            ColorChat(0, RED, "^4[%s]^1 ADMIN: ^4%s ^1took ^4%i XP ^1from all ^3Terrorists^1.", getPrefix(), AdminName, XPtoTook)
        }
        else if(equali(arg[1],"CT") || equali(arg[1],"ct"))
        {
            new players[32], totalplayers, CT
            get_players(players, totalplayers)
            
            for(new i = 0; i < totalplayers; i++)
            {
                if(get_user_team(players[i]) == 2)
                {
                    CT = players[i]
                    
                    XP[CT] -= XPtoTook
                }
            }
            
            CheckLevel(CT)
            ColorChat(0, BLUE, "^4[%s]^1ADMIN: ^4%s^1 took^4 %i XP^1from all ^3Counter-Terrorists^1.", getPrefix(), AdminName, XPtoTook)
        }
    }
    else
    {
        new iTarget = cmd_target(index, arg, 3)
        get_user_name (iTarget, TargetName, charsmax (TargetName))
        
        if(iTarget)
        {
            XP[iTarget] -= XPtoTook
            
            CheckLevel(iTarget)
            ColorChat(0, NORMAL, "^4[%s]^1 ADMIN: ^3%s^1 took^4 %i XP^1 from^4 %s^1.", getPrefix(), AdminName, XPtoTook, TargetName)
        }
    }
    return PLUGIN_HANDLED
}

public avoid_duplicated(msgId, msgDest, receiver)	return PLUGIN_HANDLED




public ClCmdReloadTags( id )
{
	if( !( get_user_flags( id ) & ADMIN_KICK ) )
	{
		client_cmd( id, "echo Nu ai acces la aceasta comanda !");
		return 1;
	}
	
	new iPlayers[ 32 ];
	new iPlayersNum;
	
	get_players( iPlayers, iPlayersNum, "c" );		
	for( new i = 0 ; i < iPlayersNum ; i++ )
	{
		PlayerHasTag[ iPlayers[ i ] ] = false;
		LoadPlayerTag( iPlayers[ i ] );
	}
	
	client_cmd( id, "echo Tag-urile jucatorilor au fost incarcate cu succes !");
	return 1;
}
public LoadPlayerTag( id )
{
	PlayerHasTag[ id ] = false;
	
	if( !file_exists( szFile ) ) 
	{
		write_file( szFile, ";Aici treceti tag-urile jucatorilor !", -1 );
		write_file( szFile, ";ex: ^"Nume Player^" ^"Ip Player^" ^"SteamId Player^" ^"Tag Player^" ^"Flage^"", -1 );
		write_file( szFile, ";Numele sa fie exact( ex: Askhanar va fi Askhanar nu askhanar ! ) ", -1 );
	}
	
	new f = fopen( szFile, "rt" );
	if( !f ) return 0;
	new data[ 512 ], buffer[ 5 ][ 32 ] ;
	while( !feof( f ) ) 
	{
		fgets( f, data, sizeof ( data ) -1 );
		if( !data[ 0 ] || data[ 0 ] == ';' || ( data[ 0 ] == '/' && data[ 1 ] == '/' ) ) 	continue;
		parse(data,\
			buffer[ 0 ], sizeof ( buffer[ ] ) - 1,\
			buffer[ 1 ], sizeof ( buffer[ ] ) - 1,\
			buffer[ 2 ], sizeof ( buffer[ ] ) - 1,\
			buffer[ 3 ], sizeof ( buffer[ ] ) - 1,\
			buffer[ 4 ], sizeof ( buffer[ ] ) - 1
		);
		
		new name[ 32 ], ip[ 32 ], authid[65];
		get_user_name( id, name, sizeof ( name ) -1 );
		get_user_ip( id, ip, sizeof ( ip ) -1, 1 );
		get_user_authid( id, authid, sizeof ( authid ) -1 );
		if( equal( name, buffer[ 0 ] ) || equal( ip, buffer[ 1 ] )|| equal( authid, buffer[ 2 ] )||get_user_flags(id)==read_flags(buffer[ 4 ]) )
		{
			PlayerHasTag[ id ] = true;
			copy( PlayerTag[ id ], sizeof ( PlayerTag[ ] ) -1, buffer[ 3 ] );
			break;
		}
	}
	
	return 0;
}
public hook_say(id)
{
	if( is_user_bot( id )||!is_user_connected(id) )	return PLUGIN_CONTINUE;
	read_args( szChat, sizeof( szChat ) - 1 );
	remove_quotes( szChat );
	if( equali( szChat,"" ) )	return PLUGIN_CONTINUE;
	get_user_name( id, szName, sizeof ( szName ) -1 );


	if(get_pcvar_num(UseAdminPrefixes) == 1){
		set_pcvar_num(UseRankSystem, 0)
		set_pcvar_num(UsePersonalTag,0)
		set_pcvar_num(UseAllThree, 0)
		
		if( is_user_admin( id ) )
		{
			for( new i = 0; i < MAX_GROUPS; i++ )
			{
				if( get_user_flags( id ) == g_iGroupsFlagsValues[ i ] )
				{
					switch( cs_get_user_team( id ) )
					{
						case CS_TEAM_T:		ColorChat( 0, RED,"^1%s^4|%s|^3 %s^1: %s",is_user_alive( id ) ? "" : "*DEAD* ", g_szGroups[ i ], szName, szChat );
						case CS_TEAM_CT:	ColorChat( 0, BLUE,"^1%s^4|%s|^3 %s^1: %s",is_user_alive( id ) ? "" : "*DEAD* ", g_szGroups[ i ], szName, szChat );
						case CS_TEAM_SPECTATOR:	ColorChat( 0, GREY,"^1*SPEC*^4|%s|^3 %s^1: %s", g_szGroups[ i ], szName, szChat );
					}
					break;
				}
			}
		}
		else
		{
			switch( cs_get_user_team( id ) )
			{
				case CS_TEAM_T:		ColorChat( 0, RED,"^1%s^3%s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ", szName, szChat );
				case CS_TEAM_CT:	ColorChat( 0, BLUE,"^1%s^3%s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ", szName, szChat );
				case CS_TEAM_SPECTATOR:	ColorChat( 0, GREY,"^1*SPEC*^3 %s^1: %s", szName, szChat );
			}
		}
	}
	
	
	if(get_pcvar_num(UseRankSystem) == 1){
		set_pcvar_num(UseAdminPrefixes, 0)
		set_pcvar_num(UsePersonalTag,0)
		set_pcvar_num(UseAllThree, 0)
		
		switch( cs_get_user_team( id ) )
		{
			case CS_TEAM_T:		ColorChat( 0, RED,"^1%s[^4%s^1]^3%s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]], szName, szChat );
			case CS_TEAM_CT:	ColorChat( 0, BLUE,"^1%s[^4%s^1]^3%s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]], szName, szChat );
			case CS_TEAM_SPECTATOR:	ColorChat( 0, GREY,"^1*SPEC* [^4%s^1]^3 %s^1: %s",Prefix[Lvl[id]], szName, szChat );
		}
	}
	
	
	if(get_pcvar_num(UseAllThree) == 1){
		set_pcvar_num(UseAdminPrefixes, 0)
		set_pcvar_num(UsePersonalTag,0)
		set_pcvar_num(UseRankSystem, 0)
		
		
		/*if( is_user_admin( id ) )
		{
			for( new i = 0; i < MAX_GROUPS; i++ )
			{
				if( get_user_flags( id ) == g_iGroupsFlagsValues[ i ] )
				{
					if( PlayerHasTag[ id ] )
					{
					switch( cs_get_user_team( id ) )
					{
						case CS_TEAM_T:		ColorChat( 0, RED,"^1%s[^4%s^1] ^4|%s|^3*^4%s^3* %s^1: %s",is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]], g_szGroups[ i ],PlayerTag[ id ], szName, szChat );
						case CS_TEAM_CT:	ColorChat( 0, BLUE,"^1%s[^4%s^1] ^4|%s|^3*^4%s^3* %s^1: %s",is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]], g_szGroups[ i ],PlayerTag[ id ], szName, szChat );
						case CS_TEAM_SPECTATOR:	ColorChat( 0, GREY,"^1*SPEC* [^4%s^1] ^4|%s|^3*^4%s^3* %s^1: %s",Prefix[Lvl[id]], g_szGroups[ i ],PlayerTag[ id ], szName, szChat );
					}
					}
					else if( !PlayerHasTag[ id ] )
					{
					switch( cs_get_user_team( id ) )
					{
						case CS_TEAM_T:		ColorChat( 0, RED,"^1%s[^4%s^1] ^4|%s|^3 %s^1: %s",is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]], g_szGroups[ i ], szName, szChat );
						case CS_TEAM_CT:	ColorChat( 0, BLUE,"^1%s[^4%s^1] ^4|%s|^3 %s^1: %s",is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]], g_szGroups[ i ], szName, szChat );
						case CS_TEAM_SPECTATOR:	ColorChat( 0, GREY,"^1*SPEC* [^4%s^1] ^4|%s|^3 %s^1: %s",Prefix[Lvl[id]], g_szGroups[ i ], szName, szChat );
					}
					}
					break;
				}
			}
		}
		else
		{*/
			if( PlayerHasTag[ id ] )
			{
			switch( cs_get_user_team( id ) )
			{
				case CS_TEAM_T:		ColorChat( 0, RED,"^1%s[^4%s^1]^3 *^4%s^3* %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]],PlayerTag[ id ], szName, szChat );
				case CS_TEAM_CT:	ColorChat( 0, BLUE,"^1%s[^4%s^1]^3 *^4%s^3* %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]],PlayerTag[ id ], szName, szChat );
				case CS_TEAM_SPECTATOR:	ColorChat( 0, GREY,"^1*SPEC* [^4%s^1]^3 *^4%s^3* %s^1: %s",Prefix[Lvl[id]],PlayerTag[ id ], szName, szChat );
			}
			}
			else if( !PlayerHasTag[ id ] )
			{
			switch( cs_get_user_team( id ) )
			{
				case CS_TEAM_T:		ColorChat( 0, RED,"^1%s[^4%s^1]^3 %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]], szName, szChat );
				case CS_TEAM_CT:	ColorChat( 0, BLUE,"^1%s[^4%s^1]^3 %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]], szName, szChat );
				case CS_TEAM_SPECTATOR:	ColorChat( 0, GREY,"^1*SPEC* [^4%s^1]^3 %s^1: %s",Prefix[Lvl[id]], szName, szChat );
			}
			}
		//}
	}
	
	
	if(get_pcvar_num(UseAdminPrefixes) == 0 && get_pcvar_num(UseRankSystem) == 0 && get_pcvar_num(UseAllThree) == 0&&get_pcvar_num(UsePersonalTag)==0)
	{
		switch( cs_get_user_team( id ) )
		{
			case CS_TEAM_T:		ColorChat( 0, RED,"^1%s^3%s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",szName, szChat );
			case CS_TEAM_CT:	ColorChat( 0, BLUE,"^1%s^3%s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",szName, szChat );
			case CS_TEAM_SPECTATOR:	ColorChat( 0, GREY,"^1*SPEC*^3 %s^1: %s",szName, szChat );
		}
	}




	if(get_pcvar_num(UsePersonalTag) == 1){
		set_pcvar_num(UseAdminPrefixes, 0)
		set_pcvar_num(UseRankSystem,0)
		set_pcvar_num(UseAllThree, 0)
		
		if( PlayerHasTag[ id ] )
		{
			switch( cs_get_user_team( id ) )
			{
				case CS_TEAM_T:		ColorChat( 0, RED,"^1%s^4 %s^3 %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",PlayerTag[ id ], szName, szChat );
				case CS_TEAM_CT:	ColorChat( 0, BLUE,"^1%s^4 %s^3 %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",PlayerTag[ id ], szName, szChat );
				case CS_TEAM_SPECTATOR:	ColorChat( 0, GREY,"^1*SPEC*^4 %s^3 %s^1: %s",PlayerTag[ id ], szName, szChat );
			}
		}
		else if( !PlayerHasTag[ id ] )
		{
			switch( cs_get_user_team( id ) )
			{
				case CS_TEAM_T:		ColorChat( 0, RED,"^1%s^3%s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",szName, szChat );
				case CS_TEAM_CT:	ColorChat( 0, BLUE,"^1%s^3%s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",szName, szChat );
				case CS_TEAM_SPECTATOR:	ColorChat( 0, GREY,"^1*SPEC*^3 %s^1: %s",szName, szChat );
			}
		}
	}


	
	return PLUGIN_HANDLED_MAIN
}
public hook_teamsay(id) {
	if( is_user_bot( id )||!is_user_connected(id) )	return PLUGIN_CONTINUE;
	read_args( szChat, sizeof( szChat ) - 1 );
	remove_quotes( szChat );
	if( equali( szChat,"" ) )	return PLUGIN_CONTINUE;
	
	static iPlayers[ 32 ], iPlayersNum;
	get_user_name( id, szName, sizeof ( szName ) -1 );
	get_players( iPlayers, iPlayersNum, "ch" );
	if( !iPlayersNum )	return PLUGIN_CONTINUE;
	static iPlayer, i;
	iPlayer = -1; i = 0;
	
	
	if(get_pcvar_num(UseAdminPrefixes) == 1){
		set_pcvar_num(UseRankSystem, 0)
		set_pcvar_num(UseAllThree, 0)
		set_pcvar_num(UsePersonalTag,0)
		
		
		if( is_user_admin( id ) )
		{
			static x; x = 0;
			
			for( x = 0; x < MAX_GROUPS; x++ )
			{
				if( get_user_flags( id ) == g_iGroupsFlagsValues[ x ] )
				{
					for( i = 0; i < iPlayersNum; i++ )
					{
						iPlayer = iPlayers[ i ];
						
						if( cs_get_user_team( id ) == cs_get_user_team( iPlayer ) )
						{
							switch( cs_get_user_team( id ) )
							{
								case CS_TEAM_T:		ColorChat( iPlayer, RED, "^1%s(Terrorist)^4|%s|^3 %s^1: %s",is_user_alive( id ) ? "" : "*DEAD* ", g_szGroups[ x ], szName, szChat );
								case CS_TEAM_CT:	ColorChat( iPlayer, BLUE, "^1%s(Counter-Terrorist)^4|%s|^3 %s^x01: %s",is_user_alive( id ) ? "" : "*DEAD* ", g_szGroups[ x ], szName, szChat );
								case CS_TEAM_SPECTATOR:	ColorChat( iPlayer, GREY, "^1%s(Spectator)^4|%s|^3 %s^1: %s", g_szGroups[ x ], szName, szChat );
							}
						}
					}
					break;
				}
			}
		}
		else
		{		
			for( i = 0; i < iPlayersNum; i++ )
			{
				iPlayer = iPlayers[ i ];
				
				if( cs_get_user_team( id ) == cs_get_user_team( iPlayer ) )
				{
					switch( cs_get_user_team( id ) )
					{
						case CS_TEAM_T:		ColorChat( iPlayer, RED, "^1%s(Terrorist)^3 %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ", szName, szChat );
						case CS_TEAM_CT:	ColorChat( iPlayer, BLUE, "^1%s(Counter-Terrorist)^3 %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ", szName, szChat );
						case CS_TEAM_SPECTATOR:	ColorChat( iPlayer, GREY, "^1(Spectator)^3 %s^1: %s", szName, szChat );
					}
				}
			}
		}
	}
	
	
	
	if(get_pcvar_num(UseRankSystem) == 1){
		set_pcvar_num(UseAdminPrefixes, 0)
		set_pcvar_num(UseAllThree, 0)
		set_pcvar_num(UsePersonalTag,0)
		
		
		for( i = 0; i < iPlayersNum; i++ )
		{
			iPlayer = iPlayers[ i ];
			
			if( cs_get_user_team( id ) == cs_get_user_team( iPlayer ) )
			{
				switch( cs_get_user_team( id ) )
				{
					case CS_TEAM_T:		ColorChat( iPlayer, RED, "^1%s(Terrorist) ^3[^4%s^3] %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]], szName, szChat );
					case CS_TEAM_CT:	ColorChat( iPlayer, BLUE, "^1%s(Counter-Terrorist) ^3[^4%s^3] %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]], szName, szChat );
					case CS_TEAM_SPECTATOR:	ColorChat( iPlayer, GREY, "^1(Spectator) ^3[^4%s^3] %s^1: %s",Prefix[Lvl[id]], szName, szChat );
				}
			}
		}
	}
	
	
	if(get_pcvar_num(UseAllThree) == 1){
		set_pcvar_num(UseAdminPrefixes, 0)
		set_pcvar_num(UseRankSystem, 0)
		set_pcvar_num(UsePersonalTag,0)
		
		
		/*if( is_user_admin( id ) )
		{
			static x; x = 0;
			
			for( x = 0; x < MAX_GROUPS; x++ )
			{
				if( get_user_flags( id ) == g_iGroupsFlagsValues[ x ] )
				{
					for( i = 0; i < iPlayersNum; i++ )
					{
						iPlayer = iPlayers[ i ];
						
						if( cs_get_user_team( id ) == cs_get_user_team( iPlayer )&&PlayerHasTag[ id ] )
						{
							switch( cs_get_user_team( id ) )
							{
								case CS_TEAM_T:		ColorChat( iPlayer, RED, "^1%s(Terrorist) ^3[^4%s^3]^4|%s|^3 *^4%s^3* %s^1: %s",is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]], g_szGroups[ x ],PlayerTag[ id ], szName, szChat );
								case CS_TEAM_CT:	ColorChat( iPlayer, BLUE, "^1%s(Counter-Terrorist) ^3[^4%s^3]^4|%s|^3 *^4%s^3* %s^x01: %s",is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]], g_szGroups[ x ],PlayerTag[ id ], szName, szChat );
								case CS_TEAM_SPECTATOR:	ColorChat( iPlayer, GREY, "^1%s(Spectator) ^3[^4%s^3]^4|%s|^3 *^4%s^3* %s^1: %s",Prefix[Lvl[id]], g_szGroups[ x ],PlayerTag[ id ], szName, szChat );
							}
						}
						else if( cs_get_user_team( id ) == cs_get_user_team( iPlayer )&&!PlayerHasTag[ id ] )
						{
							switch( cs_get_user_team( id ) )
							{
								case CS_TEAM_T:		ColorChat( iPlayer, RED, "^1%s(Terrorist) ^3[^4%s^3]^4|%s|^3 %s^1: %s",is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]], g_szGroups[ x ], szName, szChat );
								case CS_TEAM_CT:	ColorChat( iPlayer, BLUE, "^1%s(Counter-Terrorist) ^3[^4%s^3]^4|%s|^3 %s^x01: %s",is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]], g_szGroups[ x ], szName, szChat );
								case CS_TEAM_SPECTATOR:	ColorChat( iPlayer, GREY, "^1%s(Spectator) ^3[^4%s^3]^4|%s|^3 %s^1: %s",Prefix[Lvl[id]], g_szGroups[ x ], szName, szChat );
							}
						}
					}
					break;
				}
			}
		}
		else
		{*/
			for( i = 0; i < iPlayersNum; i++ )
			{
				iPlayer = iPlayers[ i ];
				
				if( cs_get_user_team( id ) == cs_get_user_team( iPlayer )&&PlayerHasTag[ id ] )
				{
					switch( cs_get_user_team( id ) )
					{
						case CS_TEAM_T:		ColorChat( iPlayer, RED, "^1%s(Terrorist) ^3[^4%s^3] *^4%s^3* %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]], PlayerTag[ id ],szName, szChat );
						case CS_TEAM_CT:	ColorChat( iPlayer, BLUE, "^1%s(Counter-Terrorist) ^3[^4%s^3] *^4%s^3* %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]],PlayerTag[ id ], szName, szChat );
						case CS_TEAM_SPECTATOR:	ColorChat( iPlayer, GREY, "^1(Spectator) ^3[^4%s^3] *^4%s^3* %s^1: %s",Prefix[Lvl[id]],PlayerTag[ id ], szName, szChat );
					}
				}
				else if( cs_get_user_team( id ) == cs_get_user_team( iPlayer )&&!PlayerHasTag[ id ] )
				{
					switch( cs_get_user_team( id ) )
					{
						case CS_TEAM_T:		ColorChat( iPlayer, RED, "^1%s(Terrorist) ^3[^4%s^3] %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]], szName, szChat );
						case CS_TEAM_CT:	ColorChat( iPlayer, BLUE, "^1%s(Counter-Terrorist) ^3[^4%s^3] %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",Prefix[Lvl[id]], szName, szChat );
						case CS_TEAM_SPECTATOR:	ColorChat( iPlayer, GREY, "^1(Spectator) ^3[^4%s^3] %s^1: %s",Prefix[Lvl[id]], szName, szChat );
					}
				}
			}
		//}
	}
	
	
	if(get_pcvar_num(UseAdminPrefixes) == 0 && get_pcvar_num(UseRankSystem) == 0 && get_pcvar_num(UseAllThree) == 0&&get_pcvar_num(UsePersonalTag)==0)
	{
		for( i = 0; i < iPlayersNum; i++ )
		{
			iPlayer = iPlayers[ i ];
			
			if( cs_get_user_team( id ) == cs_get_user_team( iPlayer ) )
			{
				switch( cs_get_user_team( id ) )
				{
					case CS_TEAM_T:		ColorChat( iPlayer, RED, "^1%s(Terrorist)^3 %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ", szName, szChat );
					case CS_TEAM_CT:	ColorChat( iPlayer, BLUE, "^1%s(Counter-Terrorist)^3 %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ", szName, szChat );
					case CS_TEAM_SPECTATOR:	ColorChat( iPlayer, GREY, "^1(Spectator)^3 %s^1: %s", szName, szChat );
				}
			}
		}
	}





	if(get_pcvar_num(UsePersonalTag) == 1){
		set_pcvar_num(UseAdminPrefixes, 0)
		set_pcvar_num(UseRankSystem,0)
		set_pcvar_num(UseAllThree, 0)


		for( i = 0; i < iPlayersNum; i++ )
		{
			iPlayer = iPlayers[ i ];

			if( cs_get_user_team( id ) == cs_get_user_team( iPlayer ) && PlayerHasTag[ id ] )
			{
				switch( cs_get_user_team( id ) )
				{
						case CS_TEAM_T:		ColorChat( iPlayer, RED, "^1%s(Terrorist)^3 %s %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",PlayerTag[ id ], szName, szChat );
						case CS_TEAM_CT:	ColorChat( iPlayer, BLUE, "^1%s(Counter-Terrorist)^3 %s %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",PlayerTag[ id ], szName, szChat );
						case CS_TEAM_SPECTATOR:	ColorChat( iPlayer, GREY, "^1(Spectator)^3 %s %s^1: %s",PlayerTag[ id ], szName, szChat );
				}
			}
			else if( cs_get_user_team( id ) == cs_get_user_team( iPlayer ) && !PlayerHasTag[ id ] )
			{
				switch( cs_get_user_team( id ) )
				{
						case CS_TEAM_T:		ColorChat( iPlayer, RED, "^1%s(Terrorist)^3 %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ", szName, szChat );
						case CS_TEAM_CT:	ColorChat( iPlayer, BLUE, "^1%s(Counter-Terrorist)^3 %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ", szName, szChat );
						case CS_TEAM_SPECTATOR:	ColorChat( iPlayer, GREY, "^1(Spectator)^3 %s^1: %s", szName, szChat );
				}
			}
		}
	}




	
	return PLUGIN_HANDLED_MAIN
}



public Save(id)
{
    new name[32];
    get_user_name(id,name,31);
    new vaultkey[64],vaultdata[256];
    
    format(vaultkey,63,"%s", name);
    format(vaultdata,255,"%i#%i#",XP[id],Lvl[id]);
    fvault_set_data(g_vault_name,vaultkey,vaultdata);
    
    return PLUGIN_CONTINUE;
}
public Load(id)
{
    new name[32];
    get_user_name(id,name,31);
    new vaultkey[64],vaultdata[256];
    
    format(vaultkey,63,"%s",name);
    format(vaultdata,255,"%i#%i#",XP[id],Lvl[id]);
    fvault_get_data(g_vault_name,vaultkey,vaultdata,charsmax(vaultdata));
    
    replace_all(vaultdata, 255, "#", " ");
    new playerxp[32], playerlevel[32];
    parse(vaultdata, playerxp, 31, playerlevel, 31);
    
    XP[id] = str_to_num(playerxp);
    Lvl[id] = str_to_num(playerlevel);
    
    return PLUGIN_CONTINUE;
}
public changeTeamInfo(player, team[])
{
    message_begin(MSG_ONE, teamInfo, _, player)    // Tells to to modify teamInfo(Which is responsable for which time player is)
    write_byte(player)                // Write byte needed
    write_string(team)                // Changes player's team
    message_end()                    // Also Needed
}

public writeMessage(player, szArgs[])
{
    message_begin(MSG_ONE, sayText, {0, 0, 0}, player)    // Tells to modify sayText(Which is responsable for writing colored messages)
    write_byte(player)                    // Write byte needed
    write_string(szArgs)                    // Effectively write the message, finally, afterall
    message_end()                        // Needed as always
}
 
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
