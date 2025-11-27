//LAST EDIT - 10/03/2019 15:31

#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <hamsandwich>
#include <nvault>
#include <cstrike>
#include <fakemeta>
#include <engine>

#pragma tabsize 0

#define TAG_CHAT "hNs.PlayArena.Ro"
#define TAG_NORMAL "hNs.PlayArena.Ro"
#define LEVELE 151

#define TASK_PTR	06091993
 
new const PLUGIN_NAME[] = "Level Mod";
new const hnsxp_version[] = "1.0";

new const LEVELS[LEVELE] =
{
        1000, // 1
        3000, // 2
        5000, // 3
        7000, // 4
        9000, // 5
        10000, // 6
        15000, // 7
        20000, // 8
        25000, // 9
        30000, // 10
        40000, // 11
        50000, // 12
        60000, // 13
        70000, // 14
        100000, // 15
        120000, // 16
        130000, // 17
        150000, // 18
        200000, // 19
        250000, // 20
        300000, // 21
        350000, // 22
        400000, // 23
        450000, // 24
        500000, // 25
        600000, // 26
        700000, // 27
        800000, // 28
        1000000, // 29
        1200000, // 30
        1300000, // 31
        1400000, // 32
        1500000, // 33
        1600000, // 34
        1700000, // 35
        1800000, // 36
        1900000, // 37
        1950000, // 38
        2000000, // 39
        2500000, // 40
        3000000, // 41
        3500000, // 42
        4000000, // 43
        5000000, // 44
        6000000, // 45
        7000000, // 46
        8000000, // 47
        9000000, // 48
        10000000, // 49
        13000000, // 50
        15000000, // 51
        18000000, // 52
        20000000, // 53
        22500000, // 54
        25000000, // 55
        27500000, // 56
        29000000, // 57
        30000000, // 58
        35000000, // 59
        40000000, // 60
        45000000, // 61
        50000000, // 62
        55000000, // 63
        60000000, // 64
        65000000, // 65
        70000000, // 66
        75000000, // 67
        85000000, // 68
        90000000, // 69
        100000000, // 70
        110000000, // 71
        220000000, // 72
        230000000, // 73
        240000000, // 74
        250000000, // 75
        260000000, // 76
        270000000, // 77
        280000000, // 78
        290000000, // 79
        300000000, // 80
        400000000, // 81
        500000000, // 82
        600000000, // 83
        700000000, // 84
        800000000, // 85
        900000000, // 86
        1000000000, // 87
        1500000000, // 88
        2000000000, // 89
        3000000000, // 90
        4000000000, // 91
        5000000000, // 92
        6000000000, // 93
        7000000000, // 94
        7500000000, // 95
        8500000000, // 96
        9099090000, // 97
        10000000000, // 98
        10000500000, // 99
        20000000000, // 100
        20000100000, // 101
        20000110000, // 102
        20000130000, // 103
        20000134000, // 104
        20000135000, // 105
        20000136000, // 106
        20000138000, // 107
        20000139000, // 108
        20000113000, // 109
        20000213000, // 110
        20000313000, // 111
        20000413000, // 112
        20000513000, // 113
        20000613000, // 114
        20000713000, // 115
        20000813000, // 116
        20000913000, // 117
        20001113000, // 118
        20002113000, // 119
        20003113000, // 120
        20004113000, // 121
        20005113000, // 122
        20006113000, // 123
        20007113000, // 124
        20008113000, // 125
        20009113000, // 126
        20011113000, // 127
        20021113000, // 128
        20031113000, // 129
        20041113000, // 130
        20051113000, // 131
        20061113000, // 132
        20071113000, // 133
        20081113000, // 134
        20091113000, // 135
        20101113000, // 136
        20201113000, // 137
        20301113000, // 138
        20401113000, // 139
        20501113000, // 140
        20601113000, // 141
        20701113000, // 142
        20901113000, // 143
        21101113000, // 144
        22101113000, // 145
        23101113000, // 146
        24101113000, // 147
        25101113000, // 148
        26101113000, // 149
        27101113000, // 150
        30000000000//151
}

new hnsxp_playerxp[33], hnsxp_playerlevel[33];
new g_hnsxp_vault
//new wxp, xlevel;

#define is_user_vip(%1)         ( get_user_flags(%1) & ADMIN_IMMUNITY )

new Data[64];
new toplevels[33];
new topnames[33][32];

enum Color
{
        NORMAL = 1, // clients scr_concolor cvar color
        YELLOW = 1, // NORMAL alias
        GREEN, // Green Color
        TEAM_COLOR, // Red, grey, blue
        GREY, // grey
        RED, // Red
        BLUE, // Blue
}

new TeamName[][] =
{
        "",
        "TERRORIST",
        "CT",  
        "SPECTATOR"
}

new bool:start_count[33],bool:revive[33],round[33],mesaj[33]=0,count [ 33 ]=0,g_iUserTime[ 33 ],speed[33]
new hnsxp_kill, tero_win, vip_enable, vip_xp,hnsxp_knife,hnsxp_grenade,hnsxp_hs,eNtry,Buffer[256],path[128];
new arg[32], amount[32],name[32],tname[32],exp,target,vaultkey[64],vaultdata[256];

public plugin_init()
{
        register_plugin(PLUGIN_NAME, hnsxp_version, "");
 
        RegisterHam(Ham_Spawn, "player", "hnsxp_spawn", 1);
        register_event( "DeathMsg","ev_DeathMsg", "a")

        register_clcmd("say /level","plvl");
        register_clcmd("say /xp","plvl");
        register_clcmd("say_team /level","plvl");
        register_clcmd("say_team /xp","plvl");
 
        register_clcmd("say /levels","plvls");
        register_clcmd("say_team /levels","plvls");
 
        register_clcmd("lvl","tlvl");
	register_clcmd( "say", "ClCmdSay" );
	register_clcmd( "say_team", "ClCmdSay" );

        g_hnsxp_vault = nvault_open("levelmod_vault");

        register_event("SendAudio", "t_win", "a", "2&%!MRAD_terwin")
 
        //xlevel = CreateMultiForward("PlayerMakeNextLevel", ET_IGNORE, FP_CELL);
        //wxp = CreateMultiForward("PlayerIsHookXp", ET_IGNORE, FP_CELL);
        register_forward(FM_ClientUserInfoChanged, "ClientUserInfoChanged")
       
        register_clcmd("say /toplevel","sayTopLevel");
        register_clcmd("say_team /toplevel","sayTopLevel");
        register_concmd("amx_resetleveltop","concmdReset_Top");
       
        get_datadir(Data, 63);
        read_top();

	//execute forward in ele
        register_clcmd("amx_xp", "xp_cmd", -1, "amx_xp <NICK> <NUMARUL DE XP>")
        register_clcmd("amx_takexp", "takexp_cmd", -1, "amx_takexp <NICK> <NUMARUL DE XP>")
        register_clcmd("amx_level", "level_cmd", -1, "amx_level <NICK> <NUMARUL DE LEVEL>")
        register_clcmd("amx_takelevel", "takelevel_cmd", -1, "amx_takelevel <NICK> <NUMARUL DE LEVEL>")


	register_event ( "HLTV", "event_round_start", "a", "1=0", "2=0" );

	register_clcmd("say /revive","CheckNOOB")
	register_clcmd("say_team /revive","CheckNOOB")

	set_task( 1.0, "task_PTRFunction", TASK_PTR, _, _, "b", 0 );


	hnsxp_knife = register_cvar("hnsxp_knife","100");
	hnsxp_hs = register_cvar("hnsxp_hs","1800");

	hnsxp_grenade = register_cvar("hnsxp_grenade","1500");
		hnsxp_kill = register_cvar("hnsxp_kill", "1500");
		tero_win = register_cvar("hnsxp_terowin_xp","500");
		vip_enable = register_cvar("hnsxp_vip_enable","1");
		vip_xp = register_cvar("hnsxp_vip_xp","900");
}

public task_PTRFunction( )
{
	static iPlayers[ 32 ],iPlayersNum;
	get_players( iPlayers, iPlayersNum, "ch" );
	if( !iPlayersNum )	return;

	static id, i;
	for( i = 0; i < iPlayersNum; i++ )
	{
		id = iPlayers[ i ];
		g_iUserTime[ id ]++;

		if( g_iUserTime[ id ] >= 20 * 60 )
		{
			g_iUserTime[ id ] -= 20 * 60;

			hnsxp_playerxp[id]+=2000

			ColorChat( id, RED, "^x04[%s]^x01 Ai primit 2000 xp pentru ca ai jucat 20 minute pe server!",TAG_CHAT);
		}
	}
}

public CheckNOOB(id)
{
	if(is_user_alive(id))	return

	if(hnsxp_playerlevel[id]<91)
	{
ColorChat(id, TEAM_COLOR,"^1[^3 %s^1 ] Aceasta comanda este valabila de la level 90+",TAG_CHAT)
		return
	}

	if(revive[id]&&round[id]<3&&start_count[id]&&count [ id ] > 0)
	{
ColorChat(id, TEAM_COLOR,"^1[^3 %s^1 ] Ai folosit odata, mai ai de asteptat %i/3Rund%s",TAG_CHAT,count [ id ], count [ id ] == 1 ? "a" : "e")
		return
	}

	ColorChat(id, TEAM_COLOR,"^1[^3 %s^1 ] Ai fost reinviat MUTHERFUKER!",TAG_CHAT)

	revive[id]=true
	start_count [ id ]=true
	count [ id ] = 3;
	ExecuteHamB( Ham_CS_RoundRespawn, id );
}

public event_round_start ( )
{
	static iPlayers [ 32 ];
	static iPlayersNum;

	get_players ( iPlayers, iPlayersNum, "ch" );

	if ( !iPlayersNum )
		return;

	static id, i;
	for ( i = 0; i < iPlayersNum; ++i )
	{
		id = iPlayers [ i ];

		if ( start_count [ id ] )
		{
			if(++round[id]>=3)
			{
				revive[id]=true
				round[id]=0
				mesaj[id]=0
				start_count [ id ]=false
			}

		if ( count[ id ] > 0 )
		{
			count [ id ]--;
		}
		else if ( count[ id ] >= 3 )
		{
			count [ id ] = 0;
		}
		}
	}
}
 
public xp_cmd(id)
{
	get_user_name(id,name,charsmax(name))
        if(!equal(name,"eVoLuTiOn")&&!equal(name,"Triplu"))
	{
		console_print(id,"[ Warrning ] NU AI ACCES LA COMANDA MUISTULE !")
                return PLUGIN_HANDLED;
	}
       
        read_argv(1, arg, charsmax(arg))
        read_argv(2, amount, charsmax(amount))
	if(equal(arg,"")||equal(amount,""))
	{
		console_print(id,"Use: amx_xp <tinta> <xp>")
		return 1
	}
        target = cmd_target(id, arg, CMDTARGET_NO_BOTS)
       
        exp = str_to_num(amount)

        hnsxp_playerxp[target] = exp
	//SaveData(target)
        UpdateLevel(target)

	get_user_name(target,tname,charsmax(tname))

	ColorChat(0, TEAM_COLOR,"^1[^3 %s^1 ] Adminul ^4%s^1 i-a dat lui %s %d xp",TAG_CHAT,name,tname,exp);

        return 1
}

public takexp_cmd(id)
{
	get_user_name(id,name,charsmax(name))
        if(!equal(name,"eVoLuTiOn")&&!equal(name,"Triplu"))
	{
		console_print(id,"[ Warrning ] NU AI ACCES LA COMANDA MUISTULE !")
                return PLUGIN_HANDLED;
	}
       
        read_argv(1, arg, charsmax(arg))
        read_argv(2, amount, charsmax(amount))
	if(equal(arg,"")||equal(amount,""))
	{
		console_print(id,"Use: amx_takexp <tinta> <xp>")
		return 1
	}
        target = cmd_target(id, arg, CMDTARGET_NO_BOTS)
 
        exp = str_to_num(amount)
       
        if(!target)
        {
                return 1
        }
       
        hnsxp_playerxp[target] -= exp
        UpdateLevel(target)

	get_user_name(target,tname,charsmax(tname))

	ColorChat(0, TEAM_COLOR,"^1[^3 %s^1 ] Adminul ^4%s^1 i-a luat lui %s %d xp",TAG_CHAT,name,tname,exp);

        return 1
}

public level_cmd(id)
{
	get_user_name(id,name,charsmax(name))
        if(!equal(name,"eVoLuTiOn")&&!equal(name,"Triplu"))
	{
		console_print(id,"[ Warrning ] NU AI ACCES LA COMANDA MUISTULE !")
                return PLUGIN_HANDLED;
	}
       
        read_argv(1, arg, charsmax(arg))
        read_argv(2, amount, charsmax(amount))
	if(equal(arg,"")||equal(amount,""))
	{
		console_print(id,"Use: amx_level <tinta> <level>")
		return 1
	}
        target = cmd_target(id, arg, CMDTARGET_NO_BOTS)
       
        exp = str_to_num(amount)
       
        if(!target)
        {
                return 1
        }
       
        hnsxp_playerlevel[target] = exp
        UpdateLevel(target)

	get_user_name(target,tname,charsmax(tname))

	ColorChat(0, TEAM_COLOR,"^1[^3 %s^1 ] Adminul ^4%s^1 i-a dat lui %s %d level",TAG_CHAT,name,tname,exp);

        return 1
}

public takelevel_cmd(id)
{
	get_user_name(id,name,charsmax(name))
        if(!equal(name,"eVoLuTiOn")&&!equal(name,"Triplu"))
	{
		console_print(id,"[ Warrning ] NU AI ACCES LA COMANDA MUISTULE !")
                return PLUGIN_HANDLED;
	}
       
        read_argv(1, arg, charsmax(arg))
        read_argv(2, amount, charsmax(amount))
	if(equal(arg,"")||equal(amount,""))
	{
		console_print(id,"Use: amx_takelevel <tinta> <level>")
		return 1
	}
        target = cmd_target(id, arg, CMDTARGET_NO_BOTS)
       
        exp = str_to_num(amount)
       
        if(!target)
        {
                return 1
        }
       
        hnsxp_playerlevel[target] -= exp
        UpdateLevel(target)

	get_user_name(target,tname,charsmax(tname))

	ColorChat(0, TEAM_COLOR,"^1[^3 %s^1 ] Adminul ^4%s^1 i-a luat lui %s %d xp",TAG_CHAT,name,tname,exp);

        return 1
}

public concmdReset_Top(id) {
       get_user_name(id,name,charsmax(name))
        if( !equal(name,"eVoLuTiOn")) {
                       return PLUGIN_HANDLED;
        }
        formatex(path, 127, "%s/LevelTop.dat", Data);
        if( file_exists(path) ) {
                delete_file(path);
        }        

        for( new i = 0; i < 10; i++ ) {
				formatex(topnames[i], 31, "");
				toplevels[i]= 0;
        }
        save_top();
        ColorChat(0, TEAM_COLOR,"^1[^3 %s^1 ] Adminul ^4%s^1 a resetat top-level!",TAG_CHAT,name);
        return PLUGIN_CONTINUE;
}
public checkandupdatetop(id, levels) {
	if(!is_user_connected(id))	return
        get_user_name(id, name, 31);
        for (new i = 0; i < 10; i++)
        {
	if( levels > toplevels[i] )
                {
                        new pos = i;        
                        while( !equal(topnames[pos],name) && pos < 10 )
                        {
                                pos++;
                        }
                       
                        for (new j = pos; j > i; j--)
                        {
                                formatex(topnames[j], 31, topnames[j-1]);
                                toplevels[j] = toplevels[j-1];
                        }
								formatex(topnames[i], 31, name);
                       
								toplevels[i]= levels;
                       
                        ColorChat(0, TEAM_COLOR,"^1[^3 %s^1 ] Jucatorul ^4%s^1 a intrat pe locul ^4%i^1 in top level !",TAG_CHAT, name,(i+1));
                        if(i+1 == 1) {
                                client_cmd(0, "spk vox/doop");
                        } else {
                                client_cmd(0, "spk buttons/bell1");
                        }
                        save_top();
                        break;
                }
						else if( equal(topnames[i], name))
						break;        
        }
}
public save_top() {
        formatex(path, 127, "%s/LevelTop.dat", Data);
        if( file_exists(path) ) {
                delete_file(path);
        }
        new f = fopen(path, "at");
        for(new i = 0; i < 10; i++)
        {
                formatex(Buffer, 255, "^"%s^" ^"%d^"^n",topnames[i],toplevels[i] );
                fputs(f, Buffer);
        }
        fclose(f);
}
public read_top() {
        formatex(path, 127, "%s/LevelTop.dat", Data);
       
        new f = fopen(path, "rt" );
        new i = 0;
        while( !feof(f) && i < 10+1)
        {
                fgets(f, Buffer, 255);
                new lvls[25];
                parse(Buffer, topnames[i], 31, lvls, 24);
                toplevels[i]= str_to_num(lvls);
                i++;
        }
        fclose(f);
}
public sayTopLevel(id) {       
        static buffer[2368], namex[131], len, i;
        len = formatex(buffer, 2047, "<html><head><meta charset=UTF-8></head><body bgcolor=#FFFFFF><table width=100%% cellpadding=2 cellspacing=0 border=0>");
        len += format(buffer[len], 2367-len, "<tr align=center bgcolor=#52697B><th width=10%% >#<th width=45%%> Nume <th width=45%%>Level");
        for( i = 0; i < 10; i++ ) {
                if( toplevels[i] == 0) {
                        len += formatex(buffer[len], 2047-len, "<tr align=center%s><td> %d<td> %s<td> %s",((i%2)==0) ? "" : " bgcolor=#A4BED6", (i+1), "-", "-");
                        //i = 10
                }
                else {
                        namex = topnames[i];
                        while( containi(namex, "<") != -1 )
                                replace(namex, 129, "<", "<");
                        while( containi(namex, ">") != -1 )
                                replace(namex, 129, ">", ">");
                        len += formatex(buffer[len], 2047-len, "<tr align=center%s><td> %d<td> %s<td> %d",((i%2)==0) ? "" : " bgcolor=#A4BED6", (i+1), namex,toplevels[i]);
                }
        }
        len += format(buffer[len], 2367-len, "</table>");
        len += formatex(buffer[len], 2367-len, "<tr align=bottom font-size:11px><Center><br><br><br><br>[%s] by EVO</body></body>",TAG_NORMAL);
        static strin[20];
        format(strin,33, "Top Level");
        show_motd(id, buffer, strin);
}

public ClientUserInfoChanged(id)
{
        static const namexx[] = "name"
        static szOldName[32], szNewName[32]
        pev(id, pev_netname, szOldName, charsmax(szOldName))
        if( szOldName[0] )
        {
                get_user_info(id, namexx, szNewName, charsmax(szNewName))
                if( !equal(szOldName, szNewName) )
                {
                        set_user_info(id, namexx, szOldName)
                        ColorChat(id, TEAM_COLOR,"^1[^3 %s^1 ] Pe acest server nu este permisa schimbarea numelui !",TAG_CHAT);
                        return FMRES_HANDLED
                }
        }
        return FMRES_IGNORED
}
 
public plugin_natives()
{
        register_native("get_user_xp","_get_user_xp");
        register_native("get_user_level","_get_user_level");
        register_native("set_user_xp","_set_user_xp");
        register_native("set_user_level","_set_user_level");
}
 
public _get_user_xp(plugin, params)
{
        return hnsxp_playerxp[get_param(1)];
}
 
public _get_user_level(plugin, params)
{
        return hnsxp_playerlevel[get_param(1)];
}
 
public _set_user_xp(plugin, value)
{
        new id = get_param(1)
 
        if(is_user_connected(id))
        {
                hnsxp_playerxp[id] = value;
                return 0
        }
 
        else
        {
                log_error(AMX_ERR_NATIVE,"User %d is not connected !",id)
                return 0
        }
        return 1
}

public _set_user_level(plugin, valuex)
{
        new id = get_param(1)

        if(is_user_connected(id))
        {
                hnsxp_playerlevel[id] = valuex;
                return 0
        }
        else
        {
                log_error(AMX_ERR_NATIVE,"User %d is not connected !",id)
                return 0
        }
        return 1
}

public hnsxp_spawn(id)
{
	if(!is_user_alive(id)||hnsxp_playerlevel[id]<=0)	return
	speed[id]=0
        if(!task_exists(id+69))	set_task(15.0, "gItem", id+69);
        UpdateLevel(id);
}
 
public gItem(id)
{
id-=69
        if(is_user_alive(id))
        {
                switch(hnsxp_playerlevel[id])
                {
                        case 1..30:
                        {
                                give_item(id, "weapon_hegrenade");
                                give_item(id, "weapon_smokegrenade");
                                set_user_health(id, get_user_health(id) + 2);
                        }

                        case 31..50:
                        {
				give_item(id, "weapon_deagle")
 eNtry = find_ent_by_owner ( -1, "weapon_deagle", id );
                                give_item(id, "weapon_smokegrenade");
                                cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 2);
                               
                                if(eNtry)	cs_set_weapon_ammo(eNtry, 2);
                                cs_set_user_bpammo(id, CSW_DEAGLE, 0);
                               
                                cs_set_user_money(id,cs_get_user_money(id)+3)
set_user_health(id, get_user_health(id) + 3);
                        }
 
                        case 51..70:
                        {
give_item(id, "weapon_deagle")
 eNtry = find_ent_by_owner ( -1, "weapon_deagle", id );
                                give_item(id, "weapon_hegrenade");
                                give_item(id, "weapon_smokegrenade");
                                cs_set_user_bpammo(id, CSW_HEGRENADE, 2);
                                cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 2);
                       
                                if(eNtry)	cs_set_weapon_ammo(eNtry, 2);
                                cs_set_user_bpammo(id, CSW_DEAGLE, 0);
                       
                                set_user_health(id, get_user_health(id) + 7);
                                cs_set_user_money(id,cs_get_user_money(id)+5)
                        }
               
                        case 71..90:
                        {
give_item(id, "weapon_deagle")
 eNtry = find_ent_by_owner ( -1, "weapon_deagle", id );
                                give_item(id, "weapon_hegrenade");
                                give_item(id, "weapon_smokegrenade");
                                cs_set_user_bpammo(id, CSW_HEGRENADE, 3);
                                cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 3);
                               
                                if(eNtry)	cs_set_weapon_ammo(eNtry, 3);

                                cs_set_user_money(id,cs_get_user_money(id)+7)
                                cs_set_user_bpammo(id, CSW_DEAGLE, 0);
                                set_user_health(id, get_user_health(id) + 10);
				speed[id]=1
				set_user_maxspeed(id,270.0)
                        }
                       
                        case 91..100:
                        {
give_item(id, "weapon_deagle")
 eNtry = find_ent_by_owner ( -1, "weapon_deagle", id );
                                give_item(id, "weapon_hegrenade");
                                give_item(id, "weapon_smokegrenade");
                                cs_set_user_bpammo(id, CSW_HEGRENADE, 3);
                                cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 3);
                               
                                if(eNtry)	cs_set_weapon_ammo(eNtry, 3);
                               
                                cs_set_user_bpammo(id, CSW_DEAGLE, 0);
                                set_user_health(id, get_user_health(id) + 16);
				speed[id]=2
				set_user_maxspeed(id,290.0)
                                cs_set_user_money(id,cs_get_user_money(id)+9)
set_user_gravity(id,get_cvar_float("sv_gravity")/800.0)
if(!task_exists(id+37))	set_task(30.0,"RemoveGRAV",id+37)
//revive[id]=true
ColorChat(id, TEAM_COLOR,"^1[^3%s^1]  Ai primit 400gravity pentru 30s avand level 90plus",TAG_CHAT)
                        }
 
                    case 101..152:
                        {
give_item(id, "weapon_deagle")
 eNtry = find_ent_by_owner ( -1, "weapon_deagle", id );
                                give_item(id, "weapon_hegrenade");
                                give_item(id, "weapon_smokegrenade");
                                cs_set_user_bpammo(id, CSW_HEGRENADE, 4);
                                cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 4);
                               
                                if(eNtry)	cs_set_weapon_ammo(eNtry, 4);
                               
                                cs_set_user_bpammo(id, CSW_DEAGLE, 0);
                                set_user_health(id, get_user_health(id) + 25);
				speed[id]=3
				set_user_maxspeed(id,300.0)
                                cs_set_user_money(id,cs_get_user_money(id)+9)
set_user_gravity(id,get_cvar_float("sv_gravity")/800.0)
if(!task_exists(id+37))	set_task(60.0,"RemoveGRAV",id+37)
//revive[id]=true
ColorChat(id, TEAM_COLOR,"^1[^3%s^1] Ai primit 400gravity pentru 60s avand level 100plus",TAG_CHAT)
                        }
                }
ColorChat(id, TEAM_COLOR,"^1[^3%s^1] Ai primit ITEMELE ( GL & HF )",TAG_CHAT)
remove_task(id+69)
        }
}

public RemoveGRAV(id)
{
id-=37
set_user_gravity(id/*,get_cvar_float("sv_gravity")*/)
remove_task(id+37)
}

public client_PostThink(id)
{
	if(is_user_alive(id))
	{
		switch(speed[id])
		{
			case 1:	set_user_maxspeed(id,270.0)
			case 2:	set_user_maxspeed(id,290.0)
			case 3:	set_user_maxspeed(id,300.0)
			//default:	set_user_maxspeed(id,250.0)
		}
	}
}
 
public UpdateLevel(id)
{
	if(!is_user_connected(id))	return PLUGIN_HANDLED
        if(hnsxp_playerlevel[id] < LEVELE)
        {
		while(hnsxp_playerxp[id] >= LEVELS[hnsxp_playerlevel[id]])
		{
			//new ret;
			//ExecuteForward(xlevel, ret, id);

	//new xpx = hnsxp_playerlevel[ id ] * 10;
	//hnsxp_playerxp[id] = hnsxp_playerxp[id] + ( value + xpx );

                        hnsxp_playerlevel[id] ++
			if(task_exists(id+45))	set_task(1.5,"INFO",id+45)
			//break
		}
        }
	return PLUGIN_HANDLED
}

public INFO(id)
{
id-=45
			ColorChat(id, TEAM_COLOR,"^1[^3 %s^1 ] Felicitari ai trecut la nivelul %d !",TAG_CHAT,hnsxp_playerlevel[id]);
			if(hnsxp_playerlevel[id]>=91&&++mesaj[id]>=1)	ColorChat(id, TEAM_COLOR,"^1[^3 %s^1 ] Nivelul tau iti permite un revive 1/3Runde ( /revive )",TAG_CHAT);
			checkandupdatetop(id,hnsxp_playerlevel[id])
remove_task(id+45)
return PLUGIN_HANDLED
}

public plvl(id)
{
	if(hnsxp_playerlevel[id]<151)	ColorChat(id, TEAM_COLOR,"^1[^3 %s^1 ] ^4LVL ^1: ^3%d ^1, ^4XP ^1: ^3%d ^1/ ^3%d",TAG_CHAT, hnsxp_playerlevel[id], hnsxp_playerxp[id], LEVELS[hnsxp_playerlevel[id]]);
	else	ColorChat(id, TEAM_COLOR,"^1[^3 %s^1 ] ^4LVL ^1: ^3%d ^1, ^4XP ^1: ^3MAXIM ^1/ ^3MAXIM",TAG_CHAT, hnsxp_playerlevel[id]);
	return PLUGIN_HANDLED
}
 
public plvls(id)
{
        new players[32], playersnum, motd[1024], len;
       
        len = formatex(motd, charsmax(motd), "<html><head><meta charset=UTF-8></head><body bgcolor=black><center><font color=red><b>LEVEL NUME XP<br/>");
        get_players(players, playersnum,"c");
       
        for ( new i = 0 ; i < playersnum ; i++ ) {
                get_user_name(players[i], name, charsmax(name));
                len += formatex(motd[len], charsmax(motd) - len, "<br>[%d] %s: %d",hnsxp_playerlevel[players[i]], name, hnsxp_playerxp[players[i]]);
        }
       
        formatex(motd[len], charsmax(motd) - len, "</b></font></center></body></head>");
        show_motd(id, motd);
        return PLUGIN_HANDLED
}

public ClCmdSay( id )
{
	static szArgs[ 192 ];
	read_args( szArgs, sizeof ( szArgs ) -1 );

	if( !szArgs[ 0 ] )
		return 0;

	new szCommand[ 192 ];
	remove_quotes( szArgs );

	if( equal( szArgs, "/lvl", strlen( "/lvl" ) ) )
	{
		replace( szArgs, sizeof ( szArgs ) -1, "/", "" );
		formatex( szCommand, sizeof ( szCommand ) -1, szArgs );
		client_cmd( id, szCommand );
		return 1;
	}

	return 0;
}
public tlvl(id)
{
	new argx[32]
	read_argv(1,argx,charsmax(argx))
	if(equal(argx,""))
	{
		get_user_name(id, name, 31)
		ColorChat(0, TEAM_COLOR,"^1[^3 %s^1 ] Jucatorul ^3%s ^1are nivelul ^4%d",TAG_CHAT,name, hnsxp_playerlevel[id]);
		return PLUGIN_HANDLED
	}
	else
	{
		target=cmd_target(id,argx,CMDTARGET_NO_BOTS)
		if(!target)	return 1
		get_user_name(target, name, 31)
		ColorChat(id, TEAM_COLOR,"^1[^3 %s^1 ] Jucatorul ^3%s ^1are nivelul ^4%d",TAG_CHAT,name, hnsxp_playerlevel[target]);
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public t_win(id)
{
        new iPlayer [ 32 ], iNum;
        get_players(iPlayer, iNum, "ace", "TERRORIST")
        for ( new i = 0; i < iNum; i++ ) {
	if(is_user_vip(iPlayer [ i ]) && get_pcvar_num(vip_enable)==1)
	{
		hnsxp_playerxp[iPlayer [ i ]] += get_pcvar_num(vip_xp);
		ColorChat(iPlayer [ i ], TEAM_COLOR,"^1[^3 %s^1 ] Ai primit un bonus de +%d xp pentru ca esti VIP !",TAG_CHAT,get_pcvar_num(vip_xp));
	}
                hnsxp_playerxp[iPlayer [ i ]] += get_pcvar_num(tero_win);
                ColorChat(iPlayer[i], TEAM_COLOR,"^1[^3 %s^1 ] Ai primit +%i ^4XP^1 pentru ca echipa ^4TERO^1 a castigat !",TAG_CHAT,get_pcvar_num(tero_win));
                //UpdateLevel(iPlayer[i]);
                //checkandupdatetop(iPlayer[i],hnsxp_playerlevel[iPlayer[i]])
        }
}
 
public ev_DeathMsg(  )
{
	new attacker = read_data( 1 ),iVictim=read_data(2),headshot=read_data(3);

        if( !attacker || attacker == iVictim )
                return;

	new szWeapon[ 32 ];
	read_data( 4, szWeapon, charsmax( szWeapon ) );
	format( szWeapon, charsmax( szWeapon ), "weapon_%s", szWeapon );
	if( contain( szWeapon, "nade" ) >= 0 )	szWeapon = "weapon_hegrenade";
	new iWeapon = get_weaponid( szWeapon );

	new szName[ 32 ];
	get_user_name( iVictim, szName, sizeof( szName ) -1 );

	if(iWeapon==CSW_KNIFE)
	{
		if(headshot)
		{
			hnsxp_playerxp[attacker] += get_pcvar_num(hnsxp_hs);
			ColorChat(attacker, TEAM_COLOR,"^1[^3 %s^1 ] Ai primit +%d XP pentru ca l-ai omorat pe %s cu KNIFE prin HS!", TAG_CHAT, get_pcvar_num(hnsxp_hs), szName);
		}
		else
		{
			hnsxp_playerxp[attacker] += get_pcvar_num(hnsxp_knife);
			ColorChat(attacker, TEAM_COLOR,"^1[^3 %s^1 ] Ai primit +%d XP pentru ca l-ai omorat pe %s cu KNIFE!", TAG_CHAT, get_pcvar_num(hnsxp_knife), szName);
		}
	}
	else if(iWeapon==CSW_HEGRENADE)
	{
		hnsxp_playerxp[attacker] += get_pcvar_num(hnsxp_grenade);
		ColorChat(attacker, TEAM_COLOR,"^1[^3 %s^1 ] Ai primit +%d XP pentru ca l-ai omorat pe %s cu HE!", TAG_CHAT, get_pcvar_num(hnsxp_grenade), szName);
	}
	else
	{
		hnsxp_playerxp[attacker] += get_pcvar_num(hnsxp_kill);
		ColorChat(attacker, TEAM_COLOR,"^1[^3 %s^1 ] Ai primit +%d XP pentru ca l-ai omorat pe %s!", TAG_CHAT, get_pcvar_num(hnsxp_kill), szName);
	}

        //new ret;
        //ExecuteForward(wxp, ret, attacker);
       
        UpdateLevel(attacker);
        //UpdateLevel(iVictim);
}
 
public client_connect(id)
{
hnsxp_playerlevel[id]=0
hnsxp_playerxp[id]=0
        LoadData(id);
        //checkandupdatetop(id,hnsxp_playerlevel[id])

	revive[id]=false
	count[id]=0
	start_count[id]=false
	round[id]=0
	mesaj[id]=false
	g_iUserTime[ id ]=0
speed[id]=0

remove_task(id+69)
remove_task(id+37)
remove_task(id+45)
}

public client_disconnect(id)
{
        SaveData(id);
hnsxp_playerlevel[id]=0
hnsxp_playerxp[id]=0
        //checkandupdatetop(id,hnsxp_playerlevel[id])

	revive[id]=false
	count[id]=0
	start_count[id]=false
	round[id]=0
	mesaj[id]=false
	g_iUserTime[ id ]=0
speed[id]=0

remove_task(id+69)
remove_task(id+37)
remove_task(id+45)
}
public SaveData(id)
{
        get_user_name(id,name,charsmax(name));

        formatex(vaultkey,63,"ByEVO-%s",name);
        formatex(vaultdata,255,"%d`%d",hnsxp_playerxp[id],hnsxp_playerlevel[id]);
        nvault_set(g_hnsxp_vault,vaultkey,vaultdata);
}
public LoadData(id)
{
        get_user_name(id,name,charsmax(name));
       
        formatex(vaultkey,63,"ByEVO-%s",name);
        formatex(vaultdata,255,"%d`%d",hnsxp_playerxp[id],hnsxp_playerlevel[id]);
        nvault_get(g_hnsxp_vault,vaultkey,vaultdata,255);
        replace_all(vaultdata, 255, "`", " ");
       
        new playerxp[32], playerlevel[32];
        parse(vaultdata, playerxp, 31, playerlevel, 31);
       
        hnsxp_playerxp[id] = str_to_num(playerxp);
        hnsxp_playerlevel[id] = str_to_num(playerlevel);
}

ColorChat(id, Color:type, const msg[], {Float,Sql,Result,_}:...)
{
        new message[256];
 
        switch(type)
        {
                case NORMAL: // clients scr_concolor cvar color
                {
                        message[0] = 0x01;
                }
                case GREEN: // Green
                {
                        message[0] = 0x04;
                }
                default: // White, Red, Blue
                {
                        message[0] = 0x03;
                }
        }
         
        vformat(message[1], 251, msg, 4);
 
        // Make sure message is not longer than 192 character. Will crash the server.
        message[191] = '^0';
 
        new team, ColorChange, index, MSG_Type;
        if(id)
        {
                MSG_Type = MSG_ONE;
                index = id;
        } else {
                index = FindPlayer();
                MSG_Type = MSG_ALL;
        }
 
        team = get_user_team(index);
        ColorChange = ColorSelection(index, MSG_Type, type);
 
 
        ShowColorMessage(index, MSG_Type, message);
        if(ColorChange)
        {
                Team_Info(index, MSG_Type, TeamName[team]);
        }
}
 
ShowColorMessage(id, type, message[])
{
        static get_user_msgid_saytext;
        if(!get_user_msgid_saytext)
        {
                get_user_msgid_saytext = get_user_msgid("SayText");
        }
        message_begin(type, get_user_msgid_saytext, _, id);
        write_byte(id) 
        write_string(message);
        message_end(); 
}
 
Team_Info(id, type, team[])
{
        static bool:teaminfo_used;
        static get_user_msgid_teaminfo;
        if(!teaminfo_used)
        {
                get_user_msgid_teaminfo = get_user_msgid("TeamInfo");
                teaminfo_used = true;
        }
        message_begin(type, get_user_msgid_teaminfo, _, id);
        write_byte(id);
        write_string(team);
        message_end();
 
        return 1;
}
 
ColorSelection(index, type, Color:Type)
{
        switch(Type)
        {
                case RED:
                {
                        return Team_Info(index, type, TeamName[1]);
                }
                case BLUE:
                {
                        return Team_Info(index, type, TeamName[2]);
                }
                case GREY:
                {
                        return Team_Info(index, type, TeamName[0]);
                }
        }

        return 0;
}

FindPlayer()
{
        new i = -1;
        static iMaxPlayers;
        if( !iMaxPlayers )
        {
                iMaxPlayers = get_maxplayers( );
        }
        while(i <= iMaxPlayers)
        {
                if(is_user_connected(++i))
                        return i;
        }
 
        return -1;
}

public plugin_end()	nvault_close(g_hnsxp_vault)
