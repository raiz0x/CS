#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <hamsandwich>
#include <cstrike>
#include <dhudmessage>
#include <fakemeta>
#include <nvault>
 
#define PLUGIN_VERSION  "1.0"
 
#define MAX_PLAYERS 32
#define TASK_GM     2199
 
// --------------------------------------------
//   ------------- DE EDITAT ---------------
// --------------------------------------------
#define HP      100
#define VITEZA      500
#define CREDITE_KILL    10
#define TAG     "[~ S H O P ~]"
// --------------------------------------------
//   ------------- DE EDITAT ---------------
// --------------------------------------------
 
new meniu;
new callback;
new bar;
new credite[MAX_PLAYERS+1];
new bool:viteza[MAX_PLAYERS+1];
new bool:invizibilitate[MAX_PLAYERS+1];
new bool:godmode[MAX_PLAYERS+1];
new bool:am_ales[MAX_PLAYERS+1];
new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame;
new vault;
 
enum datas_
{
    str[32],
    info,
    cost
};
 
/*
prima coloana: numele itemului
a doua coloana: cantitatea din item
ultima coloana: costul itemului
 
sa zicem ca X este un numar. Daca in numele itemului se afla X, pe acesta trebuie sa il inlocuiesti cu simbolul '#'. X reprezinta cantitatea din acel item. Mai jos ai exemplu.
pluginul creaza automat meniul si itemele, numele itemelor si cantitatatea itemelor se inlocuiesc automat, tu trebuie sa modifici mai jos matricea dupa bunul plac
 
daca in item nu se afla nicio cantitate, la a doua coloana scrii -1
*/
new const data_meniu[][datas_] =
{  
    // nume     // cantitate    // cost
    { "+#HP",       HP,         20},
    { "AK47",       -1,         20},
    { "M4A1",       -1,         20},
    { "Pachet AK47-HP-HE",       -1,         40},
    { "Arma random",    -1,         15},
    { "Surpriza",   -1,         30},
    { "Loterie",   -1,         100}
};
 
public plugin_init()
{
    register_plugin("Shop", PLUGIN_VERSION, "YONTU");
   
    register_event("HLTV", "event_newround", "a", "1=0", "2=0");
    RegisterHam(Ham_Player_ResetMaxSpeed, "player", "fw_ResetMaxSpeedPost", true);
    register_clcmd("say /shop", "cmd_shop");
    register_clcmd("say_team /shop", "cmd_shop");
    register_clcmd("drop", "cmd_use_power");
 
    register_concmd("amx_credite", "cmd_credite", ADMIN_IMMUNITY, "<nume> <credite>");
 
    bar = get_user_msgid("BarTime");
 
    vault = nvault_open("credite");
    if(vault == INVALID_HANDLE)
        set_fail_state("Eroare la deschiderea bazei de date din foldeurul data/vault.");
}
 
public plugin_end()
{
    nvault_close(vault);
}
 
public salveaza_credite(id)
{
    new vaultdata[64];
    format(vaultdata, charsmax(vaultdata), "%i#", credite[id]);
 
    new nume[32];
    get_user_name(id, nume, charsmax(nume));
    nvault_set(vault, nume, vaultdata);
}
 
public incarca_credite(id)
{
    new vaultdata[64], temp[MAX_PLAYERS+1];
    format(vaultdata, charsmax(vaultdata), "%i#", credite[id]);
 
    new nume[32];
    get_user_name(id, nume, charsmax(nume));
    nvault_get(vault, nume, vaultdata, charsmax(vaultdata));
    replace_all(vaultdata, charsmax(vaultdata), "#", " ");
 
    parse(vaultdata, temp, charsmax(temp));
    credite[id] = str_to_num(temp);
}
 
public cmd_use_power(id)
{      
    if(is_user_alive(id) && godmode[id])
    {
        set_dhudmessage(255, 255, 0, -1.0, 0.78, 0, _, 2.0);
        show_dhudmessage(id, "ESTI   I N V I N C I B I L!");
 
        set_user_godmode(id, true);
        godmode[id] = false;   
        ShakeScreen(id, 2.0);
 
        message_begin(MSG_ONE_UNRELIABLE, bar, .player=id)
        write_short(5);
        message_end();
 
        set_task(30.0, "opreste_godmode", id + TASK_GM);
    }
 
    return PLUGIN_CONTINUE;
}
 
public opreste_godmode(id)
{
    id -= TASK_GM;
    set_dhudmessage(20, 255, 0, -1.0, 0.78, 0, _, 2.0);
    ColorChat(id, "!4%s!1 Nu mai esti invincibil.", TAG);
    set_user_godmode(id, false);
    ShakeScreen(id, 2.0);
}
 
public event_newround()
{
    arrayset(am_ales, false, charsmax(am_ales));
    arrayset(viteza, false, charsmax(viteza));
    arrayset(godmode, false, charsmax(godmode));
   
    new i, players[MAX_PLAYERS], num, id;
    get_players(players, num);
    for(i = 0; i < num; i++)
    {
        id = players[i];
        if(!is_user_alive(id))
            continue;
 
        if(invizibilitate[id])
        {
            invizibilitate[id] = false;
            set_user_rendering(id);
        }
 
        if(task_exists(id + TASK_GM))
            remove_task(id + TASK_GM);
    }
}
 
public fw_ResetMaxSpeedPost(id)
{
    if(is_user_alive(id) && viteza[id])
    {
        engfunc(EngFunc_SetClientMaxspeed, id, VITEZA);
        set_pev(id, pev_maxspeed, VITEZA);
    }
    return HAM_IGNORED;
}
 
public client_death(killer, victim, wpnindex, hitplace, tk)
{
    if(!is_user_alive(killer))
        return;
 
    if(killer == victim)
        return;
 
    credite[killer] += CREDITE_KILL;
    salveaza_credite(killer);
 
    if(viteza[killer]) viteza[killer] = false;
    if(godmode[killer]) godmode[killer] = false;
    if(invizibilitate[killer])
    {
        invizibilitate[killer] = false;
        set_user_rendering(killer);
    }
}
 
public client_putinserver(id)
{
    am_ales[id] = false;
    viteza[id] = false;
    invizibilitate[id] = false;
    godmode[id] = false;
    incarca_credite(id);
}
 
public client_disconnected(id)
{
    if(task_exists(id + TASK_GM))
        remove_task(id + TASK_GM);
 
    salveaza_credite(id);
}
 
public hook_shop(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
 
    if(!is_user_alive(id))
        return ITEM_DISABLED;
       
    if(am_ales[id])
        return ITEM_DISABLED;
           
    if(credite[id] < data_meniu[item][cost])
        return ITEM_DISABLED;
   
    return ITEM_ENABLED;
}
 
public shop_handler(id, menu, item)
{
        if(cs_get_user_team( id ) == CS_TEAM_T) {
     ColorChat(id, "!4%s!1 Doar!3 CT !1au acces!", TAG);
                            
       return true
           }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
   
    switch(item)
    {
        case 0:
        {
            set_user_health(id, get_user_health(id) + HP);
            am_ales[id] = true;
            ColorChat(id, "!4%s!1 Acum ai cu!3 100HP !1mai mult!", TAG);
            am_ales[id] = true;
        }
        case 1:
                {
                    give_item(id, "weapon_ak47");
                    cs_set_user_bpammo(id, CSW_AK47, 90);
                    ColorChat(id, "!4%s!1 Ai primit!3 AK-47!", TAG);
                    am_ales[id] = true;
                }
        case 2:
                {
                    give_item(id, "weapon_m4a1");
                    cs_set_user_bpammo(id, CSW_M4A1, 90);
                    ColorChat(id, "!4%s!1 Ai primit!3 M4A1!", TAG);
                    am_ales[id] = true;
                }
        case 3:
                {
                    give_item(id, "weapon_ak47");
                    cs_set_user_bpammo(id, CSW_AK47, 90);
                    set_user_health(id, get_user_health(id) + HP); 

                    if(!user_has_weapon(id, CSW_HEGRENADE))
                    {
                        give_item(id, "weapon_hegrenade");
                    }
                    cs_set_user_bpammo(id, CSW_HEGRENADE, 2);
                    ColorChat(id, "!4%s!1 Ai primit!3 M4A1 + 100HP + 2HE!", TAG);
                    am_ales[id] = true;
                }
        case 4:
        {
            switch(random_num(0, 12))
            {
                case 0:
                {
                    give_item(id, "weapon_ak47");
                    cs_set_user_bpammo(id, CSW_AK47, 90);
                    ColorChat(id, "!4%s!1 Ai primit!3 AK-47!", TAG);
                   
                }
                case 1:
                {
                    give_item(id, "weapon_p90");
                    cs_set_user_bpammo(id, CSW_P90, 90);
                    ColorChat(id, "!4%s!1 Ai primit!3 P90!", TAG);
                }
                case 2:
                {
                    give_item(id, "weapon_scout");
                    cs_set_user_bpammo(id, CSW_SCOUT, 30);
                    ColorChat(id, "!4%s!1 Ai primit!3 SCOUT!", TAG);
                }
                case 3:
                {
                    give_item(id, "weapon_famas");
                    cs_set_user_bpammo(id, CSW_FAMAS, 90);
                    ColorChat(id, "!4%s!1 Ai primit!3 FAMAS!", TAG);
                   
                }
                case 4:
                {
                    give_item(id, "weapon_m4a1");
                    cs_set_user_bpammo(id, CSW_M4A1, 90);
                    ColorChat(id, "!4%s!1 Ai primit!3 M4A1!", TAG);
                   
                }
                case 5:
                {
                    give_item(id, "weapon_awp");
                    cs_set_user_bpammo(id, CSW_AWP, 30);
                    ColorChat(id, "!4%s!1 Ai primit!3 AWP!", TAG);
                   
                }
                case 6:
                {
                    give_item(id, "weapon_elite");
                    cs_set_user_bpammo(id, CSW_ELITE, 90);
                    ColorChat(id, "!4%s!1 Ai primit!3 ELITE!", TAG);
                   
                }
                case 7:
                {
                    give_item(id, "weapon_mac10");
                    cs_set_user_bpammo(id, CSW_MAC10, 90);
                    ColorChat(id, "!4%s!1 Ai primit!3 MAC10!", TAG);
                   
                }
                case 8:
                {
                    give_item(id, "weapon_xm1014");
                    cs_set_user_bpammo(id, CSW_XM1014, 21);
                    ColorChat(id, "!4%s!1 Ai primit!3 XM1014!", TAG);
                   
                }
                case 9:
                {
                    give_item(id, "weapon_m249");
                    cs_set_user_bpammo(id, CSW_M249, 200);
                    ColorChat(id, "!4%s!1 Ai primit!3 M249!", TAG);
                   
                }
                case 10:
                {
                    give_item(id, "weapon_aug");
                    cs_set_user_bpammo(id, CSW_AUG, 90);
                    ColorChat(id, "!4%s!1 Ai primit!3 AUG!", TAG);
                   
                }
                case 11:
                {
                    give_item(id, "weapon_ump45");
                    cs_set_user_bpammo(id, CSW_UMP45, 90);
                    ColorChat(id, "!4%s!1 Ai primit!3 UMP45!", TAG);
                   
                }
                case 12:
                {
                    give_item(id, "weapon_tmp");
                    cs_set_user_bpammo(id, CSW_TMP, 90);
                    ColorChat(id, "!4%s!1 Ai primit!3 TMP!", TAG);
                   
                }
            }
            am_ales[id] = true;
        }
        case 5: // (100% invizibilitate, +2credite, AWP, speed 1000, 5HE, GOD MODE 5sec)
        {
            switch(random_num(0, 8))
            {
                case 0:
                {
                    invizibilitate[id] = true;
                    set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 25);
                    ColorChat(id, "!4%s!1 Acum esti!3 I N V I Z I B I L!1.", TAG);
 
                    ShakeScreen(id, 2.0);
                }
                case 1:
                {
                    credite[id] += 30;
                    ColorChat(id, "!4%s!1 Ai castigat in plus!3 30 credite!1.", TAG);
                }
                case 2:
                {
                    give_item(id, "weapon_awp");
                    cs_set_user_bpammo(id, CSW_AWP, 30);
                    ColorChat(id, "!4%s!1 Ai castigat un!3 AWP!", TAG);
                }
                case 3:
                {
                    viteza[id] = true;
                    ColorChat(id, "!4%s!1 Acum esti mult mai!3 rapid.", TAG);
 
                    ShakeScreen(id, 2.0);
                }
                case 4:
                {
                    if(!user_has_weapon(id, CSW_HEGRENADE))
                    {
                        give_item(id, "weapon_hegrenade");
                    }
                    cs_set_user_bpammo(id, CSW_HEGRENADE, 5);
                    ColorChat(id, "!4%s!1 Ai castigat!3 5 HE.", TAG);
                }
                case 5:
                {
                    godmode[id] = true;
                   
                    new nume[32];
                    get_user_name(id, nume, charsmax(nume));
                    ColorChat(0, "!4%s!3 %s!1 a avut norocul sa devina !3invincibil!1 30sec.", TAG, nume);
                    ColorChat(id, "!4%s!1 Apasta tasta!4 V!1 sa iti activezi puterea.", TAG);
 
                    set_dhudmessage(20, 255, 0, -1.0, 0.78, 0, _, 2.0);
                    show_dhudmessage(id, "Fa-te invincibil prin apasarea tastei V.");
                }
                case 6:
                {
                    credite[id] += 50;
                    ColorChat(id, "!4%s!1 Ai castigat in plus!3 50 credite!1.", TAG);
                }
                case 7:
                {
                    give_item(id, "weapon_ak47");
                    cs_set_user_bpammo(id, CSW_AK47, 30);
                    ColorChat(id, "!4%s!1 Ai castigat un!3 AK47!", TAG);
                }
                case 8:
                {
	  set_user_noclip(id,1);
	  set_task(8.0,"removeClip",id);
                    ColorChat(id, "!4%s!1 NoClip pentru!3 8 sec!", TAG);
                }
            }
            am_ales[id] = true;
        }


        case 6:
         {   
             new nume[32];
             get_user_name(id, nume, charsmax(nume));
             switch(random_num(0, 17))
            {
                case 0:
                {
                    credite[id] += 50;
                    ColorChat(0, "!4%s!3 %s!1 a castigat!3 50 credite !1la loterie.", TAG, nume);
                }
                case 1:
                {
                    credite[id] += 99;
                    ColorChat(0, "!4%s!3 %s!1 a castigat!3 99 credite !1la loterie.", TAG, nume);
                }
                case 2:
                {
                    credite[id] += 1;
                    ColorChat(0, "!4%s!3 %s!1 a castigat!3 1 credit !1la loterie.", TAG, nume);
                }
                case 3:
                {
                    credite[id] += 150;
                    ColorChat(0, "!4%s!3 %s!1 a castigat!3 150 credite !1la loterie.", TAG, nume);
                }
                case 4:
                {
                    credite[id] += 20;
                    ColorChat(0, "!4%s!3 %s!1 a castigat!3 20 credite !1la loterie.", TAG, nume);
                }
                case 5:
                {
                    credite[id] += 120;
                    ColorChat(0, "!4%s!3 %s!1 a castigat!3 120 credite !1la loterie.", TAG, nume);
                }
                case 6:
                {
                    credite[id] += 100;
                    ColorChat(0, "!4%s!3 %s!1 a castigat!3 100 credite !1la loterie.", TAG, nume);
                }
                case 7:
                {
                    credite[id] += 222;
                    ColorChat(0, "!4%s!3 %s!1 a castigat!3 222 credite !1la loterie.", TAG, nume);
                }
                case 8:
                {
                    ColorChat(0, "!4%s!1 GHINION! !3%s!1 a pierdut!3 100 credite !1la loterie.", TAG, nume);
                }
                case 9:
                {
                    credite[id] += 80;
                    ColorChat(0, "!4%s!3 %s!1 a castigat!3 80 credite !1la loterie.", TAG, nume);
                }
                case 10:
                {
                    credite[id] += 130;
                    ColorChat(0, "!4%s!3 %s!1 a castigat!3 130 credite !1la loterie.", TAG, nume);
                }
                case 11:
                {
                    credite[id] += 69;
                    ColorChat(0, "!4%s!3 %s!1 a castigat!3 69 credite !1la loterie.", TAG, nume);
                }
                case 12:
                {
                    credite[id] += 20;
                    ColorChat(0, "!4%s!3 %s!1 a castigat!3 20 credite !1la loterie.", TAG, nume);
                }
                case 13:
                {
                    credite[id] += 77;
                    ColorChat(0, "!4%s!3 %s!1 a castigat!3 77 credite !1la loterie.", TAG, nume);
                }
                case 14:
                {
                    credite[id] += 444;
                    ColorChat(0, "!4%s!1 BINGO! !3%s!1 a castigat marele premiu la loterie,!3 444 credite.", TAG, nume);
                }
                case 15:
                {
                    credite[id] += 11;
                    ColorChat(0, "!4%s!3 %s!1 a castigat!3 11 credite !1la loterie.", TAG, nume);
                }
                case 16:
                {
                    credite[id] += 90;
                    ColorChat(0, "!4%s!3 %s!1 a castigat!3 90 credite !1la loterie.", TAG, nume);
                }
                case 17:
                {
                    credite[id] += 180;
                    ColorChat(0, "!4%s!3 %s!1 a castigat!3 180 credite !1la loterie.", TAG, nume);
                }
             }
          am_ales[id] = true;
          }
}
    credite[id] -= data_meniu[item][cost];
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}
 
public removeClip(id) {
	set_user_noclip(id,0);
                  ColorChat(id, "!4%s!1 NoClip !3 OFF!", TAG);
}

public cmd_shop(id)
{
    static text[128], tasta[2], str_to_rpl[5], i;
    formatex(text, charsmax(text), "Meniu Shop | Creditele tale:\r %d\w", credite[id]);
    meniu = menu_create(text, "shop_handler");
    callback = menu_makecallback("hook_shop");
   
    for(i = 0; i < sizeof data_meniu; i++)
    {
        if(data_meniu[i][info] != -1)
        {
            num_to_str(data_meniu[i][info], str_to_rpl, charsmax(str_to_rpl));
            copy(text, charsmax(text), data_meniu[i][str]);
            replace(text, charsmax(text), "#", str_to_rpl);
            formatex(text, charsmax(text), "%s -\r %d\w credit%s", text, data_meniu[i][cost], data_meniu[i][cost] == 1 ? "" : "e");
        }
        else
        {
            formatex(text, charsmax(text), "%s -\r %d\w credit%s", data_meniu[i][str], data_meniu[i][cost], data_meniu[i][cost] == 1 ? "" : "e");
        }
       
        tasta[0] = i;
        tasta[1] = 0;
        menu_additem(meniu, text, tasta, _, callback);
    }
    menu_setprop(meniu, MPROP_EXIT, MEXIT_ALL);
    menu_display(id, meniu);
    return PLUGIN_CONTINUE;
}

public cmd_credite(id, level, cid)
{
    if(!cmd_access(id, level, cid, 3))
        return PLUGIN_HANDLED;
   
    new nume[32],  cantitate[13];
    read_argv(1, nume,  charsmax(nume));
    read_argv(2, cantitate,  charsmax(cantitate));
   
    new player = cmd_target(id, nume, 8);
    if(!player || !is_user_connected(id))
    {
        client_cmd(id,  "echo Jucatorul %s nu a fost gasit sau nu este conectat!", nume);
        return PLUGIN_HANDLED;
    }
   
    new credite_  =  str_to_num(cantitate);
    if(credite_  <=  0)
    {
        client_cmd(id,  "echo Numarul de credite trebuie sa fie mai mare decat 0.");
        return PLUGIN_HANDLED;
    }
   
    credite[player] += credite_;
    salveaza_credite(player);
   
    new nume_admin[32];
    get_user_name(id,  nume_admin, charsmax(nume_admin));
   
    new nume_jucator[32];
    get_user_name(player,  nume_jucator,  charsmax(nume_jucator));
   
    ColorChat(0, "!4%s!1 Adminul!4 %s!1 i-a dat!3 %d!1 credit%s lui!3 %s!1.", TAG, nume_admin, credite_, credite_ == 1 ? "" : "e", nume_jucator);
 
    return PLUGIN_HANDLED;
}
 
public ShakeScreen(id, const Float:iSeconds)
{
    static g_msg_SS = 0;
    if(!g_msg_SS)
        g_msg_SS = get_user_msgid("ScreenShake");
   
    message_begin(MSG_ONE, g_msg_SS, _, id);
    write_short(floatround(4096.0 * iSeconds, floatround_round));
    write_short(floatround(4096.0 * iSeconds, floatround_round));
    write_short(1<<13);
    message_end();
}
 
stock ColorChat(id, String[], any:...)
{
    static szMesage[192];
    vformat(szMesage, charsmax(szMesage), String, 3);
   
    replace_all(szMesage, charsmax(szMesage), "!1", "^1");
    replace_all(szMesage, charsmax(szMesage), "!3", "^3");
    replace_all(szMesage, charsmax(szMesage), "!4", "^4");
   
    static g_msg_SayText = 0;
    if(!g_msg_SayText)
        g_msg_SayText = get_user_msgid("SayText");
   
    new Players[32], iNum = 1, i;
 
    if(id) Players[0] = id;
    else get_players(Players, iNum, "ch");
   
    for(--iNum; iNum >= 0; iNum--)
    {
        i = Players[iNum];
       
        message_begin(MSG_ONE_UNRELIABLE, g_msg_SayText, _, i);
        write_byte(i);
        write_string(szMesage);
        message_end();
    }
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
