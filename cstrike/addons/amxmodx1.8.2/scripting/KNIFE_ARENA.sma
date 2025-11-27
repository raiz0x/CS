//EDIT 2

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta_util>
#include <fun>
#include <engine>
#include <colorchat>
#include <dhudmessage>
#include <adv_vault>
 
#pragma tabsize 0
#pragma compress 1
 
 
//////////////////////////////////////////////////////////////////////////
 
new const COUNTRY[][] =
{
    "Serbia",
    "Croatia",
    "Bosnia and Herzegovina",
    "Macedonia",
    "Montenegro",
    "Norway",
    "Bulgaria",
    "Czech Republic",
    "Estonia",
    "Finland",
    "Romania",
    "Kosovo (Pokrajina)",
    "Albania",
    "Austria",
    "France",
    "Germany",
    "Switzerland",
    "Pakistan",
    "Poland",
    "Slovenia",
    "Sweden",
    "Argentina",
    "Brazil",
    "Peru",
    "Ukraine",
    "Greece",
    "India"
}
 
new const NUMBERS[][] =
{
    "1310",
    "866866",
    "091810700",
    "141551",
    "14741",
    "2201",
    "1916",
    "90309",
    "13013",
    "17163",
    "1235",
    "55050",
    "54345",
    "0900506506",
    "83355",
    "89000",
    "565",
    "5716",
    "7668",
    "3838",
    "72401",
    "22533",
    "49602",
    "35100",
    "3161",
    "54344",
    "9287090010"
}
 
new const CONTENTS[][] =
{
    "100",
    "TXT6",
    "TXT",
    "TAP",
    "FOR",
    "TXT",
    "TXT",
    "TXT3",
    "TXT",
    "TXT",
    "TXT",
    "TXT",
    "TXT",
    "TXT",
    "TXT",
    "FOR",
    "TAP",
    "FOR",
    "TXT",
    "TXT",
    "TXT",
    "FOR",
    "FOR",
    "TXT",
    "WLW",
    "TXT",
    "GMT"
}
 
new const PRICE_SMS[][] =
{
    "120,00 RSD",
    "6,20 KN",
    "2,00 BAM + PDV",
    "59,00 MKD",
    "1,00 EURO",
    "10,00 NOK",
    "2,40 BGN",
    "30,00 CZK",
    "1,60 EURO",
    "1,00 EURO",
    "1,00 EURO",
    "1,00 EURO",
    "120,00 ALL",
    "1,10 EURO",
    "1,00 EURO",
    "0,99 EURO",
    "2,00 CHF",
    "100,00 Rs",
    "7,38 PLN",
    "0,99 EURO",
    "15,00 SEK",
    "9,99 ARS",
    "R$ 4,00",
    "7.00 PEN",
    "15,00 UAH",
    "1.23 EURO",
    "99.00 INR"
}
 
new const COMMANDS[][]=
{
    "say /boost",
    "say_team /boost",
    "say /howtoboost",
    "say_team /howtoboost"
}
 
new const LANG_FILE[][] =
{
    "[en]",
    "BOOST_ADVERTISMENT = ^1Type ^3/boost^1 to open up the ^4Boost Menu^1!",
    "BOOST_COUNTRY = To boost from",
    "BOOST_SMS = Send SMS to",
    "BOOST_SMS_FORMAT = SMS Format (Content of Message - Message Body)",
    "BOOST_TEXT_FOR_SENDING = %s GTRS %s %s",
    "BOOST_PRICE_SMS = SMS Price",
    "BOOST_FORUM_INFO = For more info visit GameTracker.rs",
    "BOOST_MENU = \w[\rKnife Arena\w] \yCountry:",
    " ",
    "[sr]",
    "BOOST_ADVERTISMENT = ^1Ukucaj ^3/boost^1 da otvoris ^4Boost Meni^1!",
    "BOOST_COUNTRY = Da boostujes iz",
    "BOOST_SMS = Posalji SMS na broj",
    "BOOST_SMS_FORMAT = SMS Format (Sadrzaj SMS-a)",
    "BOOST_TEXT_FOR_SENDING = %s GTRS %s %s",
    "BOOST_PRICE_SMS = Cena SMS-a",
    "BOOST_FORUM_INFO = Vise informacija na GameTracker.rs",
    "BOOST_MENU = \w[\rGlobal Knife\w] \yIzaberi Zemlju:"
}
 
new Nick[32], TitleMenu[32], AdvTime;
 
//////////////////////////////////////////////////////////////////////////
 
 
 
enum
{
    WINNS=0,
    LOSS,
    KILLS,
    DEATHS,
    HEADSHOTS,
    NICK,
    MAX_RANKS
}
 
new RANKS[MAX_RANKS], g_winns[33], g_loss[33], g_kills[33], g_deaths[33], g_headshots[33], g_name[33][32], fvault, Sort
 
 
new MAXPLAYERS
 
#define CHAT_TAG "^3[^4KnifeDuels^3]^1 " // add a space right after if you want one between the tag and the messages
 

#define ARENA_ENT_NAME "entity_arena" // this is the arena's entity name
 
 
// here you can set the maximum number of arenas that can be used ingame
#define MAX_ARENAS 4

new const arena_names[][] = {
    "",
    "A",    // 1st arena
    "B",    // 2nd arena
    "C",     // 3rd arena
    "D"     // 4th arena
}
 
enum
{
    SCOREATTRIB_ARG_PLAYERID = 1,
    SCOREATTRIB_ARG_FLAGS
}
enum ( <<= 1 )
{
    SCOREATTRIB_FLAG_NONE = 0,
    SCOREATTRIB_FLAG_DEAD = 1,
    SCOREATTRIB_FLAG_BOMB,
    SCOREATTRIB_FLAG_VIP
}
 
// some arena codes...
#define ARENA_CODE 305924
#define FAKE_CODE 6969696969
#define CENTER_CODE 9696969696
#define EXTRA_CODE 911911911
 
// task code for advert
#define TASK_AD 34585029
#define TASK_DUEL 34585029
#define TASK_GIVEUP 34585029
#define TASK_OFFLINE 34585029
 
// some movement defines
#define MOVE_UP 0
#define MOVE_DOWN 1
#define MOVE_RIGHT 2
#define MOVE_LEFT 3
#define MOVE_FRONT 4
#define MOVE_BACK 5
 
// Arena ground size
#define ARENA_MINS Float:{-150.0,-62.0,-1.5}
#define ARENA_MAXS Float:{10.0,62.0,1.5}
 
// arena coords offcourse, this is used to build the arena.
new const Float:ARENA_COORDS[][2] = {
    {0.0,0.0},
    {100.0,0.0},
    {0.0,100.0},
    {100.0,100.0},
    {-100.0,0.0},
    {0.0,-100.0},
    {-100.0,-100.0},
    {-100.0,100.0},
    {100.0,-100.0},
    {200.0,0.0},
    {200.0,100.0},
    {200.0,-100.0}
}
 
enum {
    BLUE_SIDE = 0,
    RED_SIDE = 1,
    LEFT_SIDE = 2,
    RIGHT_SIDE = 3,
    TOP_SIDE = 4
}
 
new const ARENA_FILE[] = "%s/duel_arena/%s.cfg"
new user_can_spawn[33];

// if you want to disable a sound, rename it with "common/null.wav"|or delete??
new const DUEL_SOUNDS[][] = {
    "ambience/goal_1.wav",       // 0 round win
    "x/nih_die2.wav",       // 1 round lose
    "ambience/des_wind1.wav",   // 2 round draw
    "buttons/bell1.wav",         // 3 round start
    "buttons/blip1.wav" ,    // 4 accepted duel
    "weapons/headshot2.wav",  // 5 Countdown
    "events/tutor_msg.wav"   // 6 "Go!"
}
 
new const ARENA_MODELS[][] = {//wtf =))
    "models/KnifeArena.mdl", // Arena's ground
    "models/KnifeArena.mdl" // Arena's walls
}
 
new const MAP_FIX[][] = {
    "35hp_2",
    "ka_acer_2"
}
 
new Float:MAP_FIX_Z_COORD[] = {
    -864.253723
}
 
new const g_szKnifeSound[] = "weapons/knife_hitwall1.wav";
 
new Float:g_fHit[33];
new iHitCount[33]
 
 
new cvar_count = 0
 
new Head_shot[33][33]
new fakes;
new is_in_duel[33],his_countdown[33],is_frozen[33],his_challenger[33],his_asker[33],arena_number[33],his_wins[33],his_name[33][64];
new rounds[MAX_ARENAS+1],Float:arena_coord[MAX_ARENAS+1][3]; // using +1 just incase...
new Float:his_spawn[33][3],got_spawn[33],Float:his_angle[33][3],Float:his_original_spawn[33][3];
new next_empty_arena,total_arenas;
new map_name[32]
new cvar_z_fix,cvar_sounds,cvar_rounds,cvar_kills,cvar_cooldown,cvar_time
new Float:max_size[3],Float:min_size[3];
new selected = 1,Float:move_size[33],his_timer[33],his_offline[33],his_HS[33];
new map_default_hp;
new map_id = -1;
new his_previous_team[33];
// using these for less cpu usage.
new IS_BUGGED_MAP = 0,MAP_FIX_ENABLED,SOUNDS_ENABLED,MAX_ROUNDS,MAX_KILLS,MAX_COUNTDOWN,MAX_TIME;
new g_allocPmod, g_allocVmod
 
new motd[1536]
new cvar_teaminfo
new cvar_allinfo
new cvar_yourinfo
new HuDForEver
new g_motd[ 8000 ]
new Duel_logs[ 54 ];
new bool:gBackStabing[33];

static const szg_Pbk[] = "models/p_knife.mdl"
static const szg_Vbk[] = "models/v_knife.mdl"
 
const OFFSET_WEAPONOWNER = 41
const OFFSET_LINUX_WEAPONS = 4
 
#define P_NAME "Knife Duels"//edit by Adryyy
#define P_VERS "2.0.5"
#define P_AUTH "ALLIED"
#define P_REQ "- Global Knife Arena -"

new killed_forward;
new cvar_gamename;
 
#define ROUND_START_TASK 3215468
   
public plugin_init()
{
    register_plugin(P_NAME, P_VERS, P_AUTH)

    register_clcmd("say /origin","print_coords")
    register_clcmd("say /arena","editor_menu")
    register_clcmd("say /duel", "menu_principal");
    register_clcmd("say /reset","Duels_Reset",ADMIN_BAN);
    register_clcmd("say_team /origin","print_coords")
    register_clcmd("say_team /arena","editor_menu")
    register_clcmd("say_team /duel", "menu_principal");
    register_clcmd("say_team /reset","Duels_Reset",ADMIN_BAN);
 
    fvault = adv_vault_open("DuelsTop", false)
 
    RANKS[WINNS]         = adv_vault_register_field(fvault, "winns")
    RANKS[LOSS]          = adv_vault_register_field(fvault, "loss")
    RANKS[KILLS]         = adv_vault_register_field(fvault, "kills")
    RANKS[DEATHS]        = adv_vault_register_field(fvault, "deaths")
    RANKS[HEADSHOTS]     = adv_vault_register_field(fvault, "headshots")
    RANKS[NICK]          = adv_vault_register_field(fvault, "name", DATATYPE_STRING, 32)
 
    adv_vault_init(fvault)
    Sort = adv_vault_sort_create(fvault, ORDER_DESC, 20, 0, RANKS[WINNS], RANKS[LOSS], RANKS[KILLS], RANKS[DEATHS], RANKS[HEADSHOTS])
 
    cvar_z_fix      = register_cvar("duel_map_fix","1")
    cvar_sounds     = register_cvar("duel_sounds","1")
    cvar_rounds     = register_cvar("duel_rounds","20")
    cvar_kills      = register_cvar("duel_kills","10")
    cvar_cooldown   = register_cvar("duel_cooldown","1")
    cvar_time       = register_cvar("duel_max_nokill_time","120")
    cvar_count      = register_cvar("duel_knifecount", "5");
    cvar_gamename   = register_cvar( "duel_gamename", "Global Knife Arena" );
    cvar_teaminfo   = register_cvar("duel_teaminfo","1")
    cvar_allinfo    = register_cvar("duel_allinfo","1")
    cvar_yourinfo   = register_cvar("duel_yourinfo","1")
   
    //register_forward(FM_SetModel, "fw_SetModel")
    //RegisterHam(Ham_CS_RoundRespawn, "player", "Player_Respawn_pre", 0)
    RegisterHam(Ham_Spawn,"player","Player_spawn_post",1)
    RegisterHam(Ham_Killed, "player", "Player_Killed")
    RegisterHam(Ham_TakeDamage, "player", "Player_Take_Damage", 0)
    RegisterHam(Ham_Killed,"player","Duel_Rank")
    RegisterHam(Ham_TraceAttack, "player", "Ham_TraceAttack_player", 1)
    register_forward(FM_CmdStart, "Cmd_start" );
    register_forward(FM_EmitSound, "fwd_EmitSound", 1);
    register_forward(FM_GetGameDescription, "GameDesc" );
    register_forward(FM_PlayerPreThink,"FW_Prethink")
    register_event("HLTV", "round_start_event", "a", "1=0", "2=0")
    register_event("StatusValue","duel_status","be","1=2","2!0");
    register_event("StatusValue","duel_statusx","be","1=2","2!0");
    register_touch(ARENA_ENT_NAME, "player", "forward_touch");
 
    g_allocPmod = engfunc(EngFunc_AllocString, szg_Pbk)
    g_allocVmod = engfunc(EngFunc_AllocString, szg_Vbk)
 
    mkdir("addons/amxmodx/logs/KnifeDuels");
    format(Duel_logs, charsmax(Duel_logs), "addons/amxmodx/logs/KnifeDuels/Duel.log", Duel_logs)
 
    get_mapname(map_name,charsmax(map_name))
    new size = sizeof(MAP_FIX)
    for(new i; i <size;i++)
    {
        if(equal(map_name,MAP_FIX[i]))
        {
            map_id = i
            IS_BUGGED_MAP = 1
        }
    }
 
    MAXPLAYERS = get_maxplayers();
    if(containi(map_name,"1hp") != -1)	map_default_hp = 1
    else map_default_hp = 35

    load_arena_coords(-1)
   
    new cfgdir[32], urlfile[64]
    get_configsdir(cfgdir, charsmax(cfgdir))
    formatex(urlfile, charsmax(urlfile), "%s/duel_arena", cfgdir)
    if(!dir_exists(urlfile))
    {
        mkdir(urlfile)
        server_print("%sCreated new folder: %s",CHAT_TAG,urlfile)
    }

    killed_forward = CreateMultiForward("duel_player_killed", ET_IGNORE, FP_CELL,FP_CELL);
    set_task(25.0,"Advertise",TASK_AD)
    register_message( get_user_msgid( "ScoreAttrib" ), "MessageScoreAttrib" );
    update_cvars();
    HuDForEver = CreateHudSyncObj()
 
    for(new i=0;i< sizeof COMMANDS;i++)	register_clcmd(COMMANDS[i], "ChooseState");
   
    AdvTime = register_cvar("htbs_bym_vreme_reklame","120.0");     
    set_task(get_pcvar_float(AdvTime), "Advertisment");
    register_dictionary("boost_manager.txt")
}

public FW_Prethink(id)
{
    if (pev(id,pev_button) & IN_RELOAD && pev(id,pev_button) & IN_USE)	menu_principal(id)
    if (pev(id,pev_button) & IN_ATTACK && pev(id,pev_button) & IN_ATTACK2)	menu_principal(id)
}
 
public Duel_Rank(victim,attacker,shouldgib)
{
    new wid,bh
       
    if(!is_user_connected(victim)||is_in_duel[victim] != 2||!is_user_connected(attacker)||
	attacker == victim||is_in_duel[attacker] != 2 || is_in_duel[victim] != 2)	return HAM_IGNORED
       
    if(is_user_connected(his_challenger[victim]) && !is_user_connected(attacker))	if(!check_teams(victim,attacker))	return HAM_IGNORED
 
    static Float:FOrigin3[3]
    pev(victim, pev_origin, FOrigin3)
   
    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, FOrigin3, 0)
    write_byte(TE_IMPLOSION)
    engfunc(EngFunc_WriteCoord, FOrigin3[0])
    engfunc(EngFunc_WriteCoord, FOrigin3[1])
    engfunc(EngFunc_WriteCoord, FOrigin3[2])
    write_byte(200)
    write_byte(100)
    write_byte(5)  
    message_end()
       
    attacker = get_user_attacker(victim,wid,bh)
 
    g_kills[attacker]++
    g_deaths[victim]++
 
    new deaths;
    deaths = cs_get_user_deaths(victim)
    cs_set_user_deaths(victim, deaths + 1)  
    ExecuteHamB( Ham_AddPoints, attacker, 1, true );
     
    if(bh==HIT_HEAD)	g_headshots[attacker]++

    return PLUGIN_CONTINUE
}

public fwd_EmitSound(id, channel, const sound[])
{
    if(!equal(sound, g_szKnifeSound)||!is_user_alive(id))	return FMRES_IGNORED;
   
    static Float:fGmTime;
    fGmTime = get_gametime();
   
    if((fGmTime - g_fHit[id]) >= 1.0)
    {
        iHitCount[id] = 0;
        g_fHit[id] = fGmTime;
    }

    ++iHitCount[id];
    g_fHit[id] = fGmTime;
   
    if((iHitCount[id] >= get_pcvar_num(cvar_count)))
    {
        menu_principal(id)

        iHitCount[id] = 0;
    }
    return FMRES_IGNORED;
}

public menu_principal( id )
{
    new gMenu = menu_create("\y[\r Duel Menu\y ]", "menu_principal1")
   
    menu_additem(gMenu, "\wDuel", "1")  
    menu_additem(gMenu, "\wRank", "2")    
    menu_additem(gMenu, "\wTop", "3")    
    menu_additem(gMenu, "\wOffline", "4")
    menu_additem(gMenu, "\wGive Up", "5")
    menu_additem(gMenu, "\wBoost", "6")
    menu_additem(gMenu, "\wInfo", "7")
 
    menu_display(id, gMenu, 0)
}
public menu_principal1(id, menu, item)      
{
    if ( item == MENU_EXIT )    
    {
        menu_destroy(menu)      
        return PLUGIN_HANDLED;  
    }
    switch(item)  
    {
        case 0: duel_players_list(id)
        case 1: DuelRank(id)
        case 2: Menu_TOP(id)
        case 3: toggle_offline(id)
        case 4: give_up_player(id)
        case 5: ChooseState(id)
        case 6: player_rule(id)
    }
    return PLUGIN_HANDLED;  
}
 
/*public fw_SetModel(entity, model[])
{
    if(!is_valid_ent(entity))
        return FMRES_IGNORED
   
    static szClassName[33]
    entity_get_string(entity, EV_SZ_classname, szClassName, charsmax(szClassName))
       
    if(!equal(szClassName, "weaponbox"))
        return FMRES_IGNORED
   
    if(equal(model, "models/w_c4.mdl"))
    {
        remove_entity(entity)
    }
    return FMRES_IGNORED
}*/
 
public MessageScoreAttrib( iMsgId, iDest, iReceiver )
{
    new id= get_msg_arg_int( SCOREATTRIB_ARG_PLAYERID );

    if(!is_user_connected(id)||!is_user_alive(id))	return;

    set_msg_arg_int( SCOREATTRIB_ARG_FLAGS, ARG_BYTE, SCOREATTRIB_FLAG_NONE);
}
 
/*public CurrentWeapon(id)
{
    if(read_data(2) == CSW_C4)
    {
        if(is_user_alive(id))
        {
            strip_user_weapons(id)
            give_item(id,"weapon_knife")
           
        }
    }
}
stock get_weapon_owner(ent)
{
    return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)
}
public Player_Respawn_pre(id)
{
    if(is_user_connected(id))
    {
        if(!user_can_spawn[id])
        {
            return HAM_SUPERCEDE
        }
    }
    return HAM_IGNORED
}*/
 
public plugin_natives()
{
    register_library("knife_duels")

    register_native("is_user_in_duel","_is_user_in_duel")
    register_native("is_user_dueling_user","_is_user_dueling_user")
}
 
public get_non_duelers_alive()
{
    new count = 0

    for(new id; id < MAXPLAYERS;id++)	if(is_user_connected(id))	if(is_user_alive(id) && !is_in_duel[id])	count++

    return count
}
 
public respawn_everyone(taskid)	for(new id;id < MAXPLAYERS;id++)	if(is_user_connected(id))	if(is_in_duel[id] !=2 && !is_user_alive(id))	if(cs_get_user_team(id) == CS_TEAM_CT || cs_get_user_team(id) == CS_TEAM_T)	ExecuteHam(Ham_CS_RoundRespawn, id);
 
public get_non_duelers_alive_CT()
{
    new count = 0

    for(new id; id < MAXPLAYERS;id++)	if(is_user_connected(id))	if(is_user_alive(id) && !is_in_duel[id] && cs_get_user_team(id) == CS_TEAM_CT)	count++
    return count
}
 
public get_non_duelers_alive_T()
{
    new count = 0

    for(new id; id < MAXPLAYERS;id++)	if(is_user_connected(id))	if(is_user_alive(id) && !is_in_duel[id] && cs_get_user_team(id) == CS_TEAM_T)	count++
    return count
}
 
public _is_user_in_duel(plugin, iParams)
{
    new id = get_param(1)

    if(!is_user_connected(id))	return PLUGIN_CONTINUE

    if(is_in_duel[id] == 2)	return PLUGIN_HANDLED

    return PLUGIN_CONTINUE
}
 
public _is_user_dueling_user(plugin, iParams)
{
    new id = get_param(1)
    new enemy = get_param(2)

    if(!is_user_connected(id)||!is_user_connected(enemy))	return PLUGIN_CONTINUE

    if(is_in_duel[id] != 2 || is_in_duel[enemy] != 2)	return PLUGIN_CONTINUE

    if(id == his_challenger[enemy] && enemy == his_challenger[id])	return PLUGIN_HANDLED

    return PLUGIN_CONTINUE
}
 
public forward_touch(ent, id)
{
    if(!pev_valid(id)||!pev_valid(ent)||is_user_alive(id) && get_user_noclip(id))	return;
 
    static class[32]
    pev(ent,pev_classname,class,charsmax(class));
    if(equal(class,ARENA_ENT_NAME))
    {
        if(is_in_duel[id] && !gBackStabing[id])	gBackStabing[id] = true;
        if(is_user_alive(id) && !gBackStabing[id])
        {
                gBackStabing[id] = false;
                menu_principal(id)
                //back_to_the_spawn(id)
 
                user_slap(id,0)
                user_slap(id,0)
        }
    }
}

public Ham_TraceAttack_player(victim, attacker, Float:Damage, Float:Direction[3], ptr, Damagebits)	if(is_user_connected(attacker) && is_user_connected(victim))	Head_shot[attacker][victim] = bool:( get_tr2(ptr, TR_iHitgroup) == 1 )
 
public editor_menu(id)
{
    if(!is_user_connected(id))	return PLUGIN_HANDLED

    new flags = get_user_flags(id)
    if(!(flags & ADMIN_RCON))
    {
        client_print(id,print_chat,"You have no access to this command")
        return PLUGIN_HANDLED
    }

    new menu
    menu = menu_create( "\rArena spawner:", "Arenaspawner_handler" );
    new nameu[32];
   
    formatex(nameu,charsmax(nameu), "Add");
    menu_additem(menu, nameu, "", 0);
    formatex(nameu,charsmax(nameu), "Remove");
    menu_additem(menu, nameu, "", 0);
    formatex(nameu,charsmax(nameu), "Remove all");
    menu_additem(menu, nameu, "", 0);
    formatex(nameu,charsmax(nameu), "Select");
    menu_additem(menu, nameu, "", 0);
    formatex(nameu,charsmax(nameu), "Select all");
    menu_additem(menu, nameu, "", 0);
    formatex(nameu,charsmax(nameu), "Move");
    menu_additem(menu, nameu, "", 0);
    formatex(nameu,charsmax(nameu), "Save");
    menu_additem(menu, nameu, "", 0);
    formatex(nameu,charsmax(nameu), "Load");
    menu_additem(menu, nameu, "", 0);
    menu_display(id, menu, 0 );
    return PLUGIN_HANDLED
}
 
public Arenaspawner_handler( id, menu, item )
{
    if ( item == MENU_EXIT )
    {
        menu_destroy( menu );
        remove_the_fake_arena()
        return PLUGIN_HANDLED;
    }
   
    new szData[6], szName[64];
    new _access, item_callback;
    menu_item_getinfo( menu, item, _access, szData,charsmax( szData ), szName,charsmax( szName ), item_callback );
    new arenas_found;
    arenas_found = fakes_count()
    if(equali(szName,"Add"))
    {
        if(next_fake_arena() != -1)
        {
            start_fake_build(id,-1)
            if(fakes_count())
            {
                if(selected > MAX_ARENAS || selected == -1)
                {
                    selected = 1
                    select_the_fake_arena(EXTRA_CODE+selected)
                }
            }
        }
    else client_print_color(id,"%s ^3Maximum arenas reached.^1",CHAT_TAG)
    }
    else if(equali(szName,"Remove"))
    {
        if(fakes_count())
        {
            if(selected > MAX_ARENAS || selected == -1)
                selected = 1
            delete_the_fake_arena(EXTRA_CODE+selected)
            if(fakes_count())
                next_selection()
        } else client_print_color(id,"%s ^3No arenas found.",CHAT_TAG)
    }
    else if(equali(szName,"Remove all"))
    {
        //remove_menu(id)
        remove_the_fake_arena()
        client_print_color(id,"%s ^3All arenas removed.",CHAT_TAG)
    }
    else if(equali(szName,"Select"))
    {
        if(fakes_count())
        {
            next_selection()
        } else client_print_color(id,"%s ^3No arenas found.",CHAT_TAG)
    }
    else if(equali(szName,"Select all"))
    {
        if(fakes_count())
        {
            selected = -1
            select_the_fake_arena(EXTRA_CODE+selected)
        } else client_print_color(id,"%s ^3No arenas found.",CHAT_TAG)
    }
    else if(equali(szName,"Move"))
    {
        if(fakes_count())
        {
            if(selected > MAX_ARENAS)
                selected = 1
            select_the_fake_arena(EXTRA_CODE+selected)
            menu_destroy( menu );
            move_menu(id,EXTRA_CODE+selected)
            return PLUGIN_CONTINUE;
        }
        else client_print_color(id,"%s ^3No arenas found.",CHAT_TAG)
    }
    else if(equali(szName,"Load"))
    {
        remove_the_fake_arena()
        load_arena_coords(id)
        //client_print_color(id, DontChange,"%s ^3Arena coords loaded.",CHAT_TAG)
        set_task(0.1,"delay_build",id)
    }
    else if(equali(szName,"Save"))
    {
        if(fakes_count())
        {
            save_arena_coords(id)
            remove_the_fake_arena()
            load_arena_coords(id)
        }
        else	client_print_color(id,"%s ^3No arenas found.",CHAT_TAG)
    }
    if(!arenas_found && fakes_count())	next_selection()
    menu_destroy( menu );
    editor_menu(id)
    return PLUGIN_CONTINUE;
}
 
stock next_selection()
{
    if(selected == -1)	selected = 1

    new size = MAX_ARENAS*3
    for(new slct=0;slct < size;slct++)
    {
        selected++
        if(selected > MAX_ARENAS)	selected = 1
        if(fake_arena_exists(selected))
        {
            select_the_fake_arena(EXTRA_CODE+selected)
            return;
        }
    }
}
 
public fake_arena_exists(code)
{
    new arenas_ent = -1
    new code_ent
    while((arenas_ent=engfunc(EngFunc_FindEntityByString,arenas_ent,"classname",ARENA_ENT_NAME)))
    {
        if(entity_get_int(arenas_ent,EV_INT_iuser2) == CENTER_CODE && entity_get_int(arenas_ent,EV_INT_iuser1) == FAKE_CODE)
        {
            code_ent = entity_get_int(arenas_ent,EV_INT_iuser3)-EXTRA_CODE

            if(code_ent == code)	return PLUGIN_HANDLED
        }
    }
    return PLUGIN_CONTINUE
}
 
public fakes_count()
{
    new arenas_ent = -1
    new found = 0
    while((arenas_ent=engfunc(EngFunc_FindEntityByString,arenas_ent,"classname",ARENA_ENT_NAME)))	if(entity_get_int(arenas_ent,EV_INT_iuser2) == CENTER_CODE && entity_get_int(arenas_ent,EV_INT_iuser1) == FAKE_CODE)	found++

    return found
}
 
public arenas_count()
{
    new found = 0
    for(new id;id < MAXPLAYERS;id++)	if(is_user_connected(id))	if(is_in_duel[id] == 2)	found++

    return found/2
}
 
public delay_build(id)
{
    for(new i=1;i < total_arenas+1;i++)	start_fake_build(id,i)

    if(fakes_count())	next_selection()
}

public move_menu(id,code)
{
    new menu
    menu = menu_create( "\rMove arena:", "move_handler" );
   
    new nameu[32];
    new code_t[32];
    num_to_str(code,code_t,charsmax(code_t))
    formatex(nameu,charsmax(nameu), "Move up");
    menu_additem(menu, nameu, code_t, 0);
   
    formatex(nameu,charsmax(nameu), "Move down");
    menu_additem(menu, nameu, code_t, 0);
   
    formatex(nameu,charsmax(nameu), "Move front");
    menu_additem(menu, nameu, code_t, 0);
   
    formatex(nameu,charsmax(nameu), "Move back");
    menu_additem(menu, nameu, code_t, 0);
   
    formatex(nameu,charsmax(nameu), "Move right");
    menu_additem(menu, nameu, code_t, 0);
   
    formatex(nameu,charsmax(nameu), "Move left");
    menu_additem(menu, nameu, code_t, 0);
   
    formatex(nameu,charsmax(nameu), "Remove the arena");
    menu_additem(menu, nameu, code_t, 0);
   
    formatex(nameu,charsmax(nameu), "Move size: %.2f",move_size[id]);
    menu_additem(menu, nameu, code_t, 0);
    menu_display(id, menu, 0 );
    return PLUGIN_HANDLED
}
 
public move_handler( id, menu, item )
{
    if ( item == MENU_EXIT )
    {
        menu_destroy( menu );
        set_task(0.1,"editor_menu",id)
        return PLUGIN_HANDLED;
    }
   
    new szData[32], szName[64];
    new _access, item_callback;
    menu_item_getinfo( menu, item, _access, szData,charsmax( szData ), szName,charsmax( szName ), item_callback );
    new code = str_to_num(szData)
    if(equali(szName,"remove the arena"))
    {
        delete_the_fake_arena(code)
        menu_destroy( menu );
        editor_menu(id)
        unselect_the_fake_arena(0)
        return PLUGIN_CONTINUE;
    }
    else if(containi(szName,"move size:") != -1)
    {
        move_size[id]+= 10.0
        if(move_size[id] > 100.0)
        {
            move_size[id] = 10.0
        }
    }
    else if(equali(szName,"move up"))
    {
        move_the_fake_arena(id,code,MOVE_UP)
    }
    else if(equali(szName,"move down"))
    {
        move_the_fake_arena(id,code,MOVE_DOWN)
    }
    else if(equali(szName,"move right"))
    {
        move_the_fake_arena(id,code,MOVE_RIGHT)
    }
    else if(equali(szName,"move left"))
    {
        move_the_fake_arena(id,code,MOVE_LEFT)
    }
    else if(equali(szName,"move front"))
    {
        move_the_fake_arena(id,code,MOVE_FRONT)
    }
    else if(equali(szName,"move back"))
    {
        move_the_fake_arena(id,code,MOVE_BACK)
    }
    menu_destroy( menu );
    move_menu(id,code)
   
    return PLUGIN_CONTINUE;
}
 
public save_arena_coords(id)
{
    new found;
    new cfgdir[32], mapname[32], urlfile[64]
    get_configsdir(cfgdir, charsmax(cfgdir))
    get_mapname(mapname, charsmax(mapname))
    formatex(urlfile, charsmax(urlfile), ARENA_FILE, cfgdir, mapname)
 
    if (file_exists(urlfile))	delete_file(urlfile)
   
    new lineset[128]
    new Float:origin[3]
    new arenas_ent=-1;
    while((arenas_ent=engfunc(EngFunc_FindEntityByString,arenas_ent,"classname",ARENA_ENT_NAME)))
    {
        if(entity_get_int(arenas_ent,EV_INT_iuser2) == CENTER_CODE && entity_get_int(arenas_ent,EV_INT_iuser1) == FAKE_CODE)
        {
            found++
            pev(arenas_ent,pev_origin,origin);
            format(lineset, charsmax(lineset), "%.f %.f %.f", origin[0], origin[1], origin[2])
            write_file(urlfile, lineset,found)
           
        }
    }
    if(!found)	client_print_color(id, "%s Couldn't save:^3No arenas found.",CHAT_TAG)
    else client_print_color(id,"%s %d ^3Arena coords saved.",CHAT_TAG,found)
}
 
public print_coords(id)
{
    new Float:coord[3]
    pev(id,pev_origin,coord);
    client_print_color(id,"origin: ^3%.f %.f %.f",coord[0],coord[1],coord[2])
    return PLUGIN_HANDLED
}
 
public start_fake_build(id,zecode)
{
    if(!is_user_connected(id))	return PLUGIN_HANDLED

    new ext_code
    if(zecode == -1)
    {
        ext_code = next_fake_arena()

        if(ext_code == -1)	return PLUGIN_HANDLED
    }
    else ext_code = zecode

    ext_code+=EXTRA_CODE

    static Float:origin[3];
    if(zecode == -1)	get_user_hitpoint(id,origin)
    else
    {
        origin[0]=arena_coord[zecode][0]
        origin[1]=arena_coord[zecode][1]
        origin[2]=arena_coord[zecode][2]
    }
 
    /*origin[0] = 1002.911376
    origin[1] = -1561.421997
    origin[2] = 0.0*/
    new Float:fake_origin[3]
    static size
    size = sizeof(ARENA_COORDS)
    new ent_code = FAKE_CODE
    fakes++
    for(new coords;coords < size; coords++)
    {
        fake_origin[0] = origin[0]
        fake_origin[1] = origin[1]
        if(bugged_map())
            fake_origin[2]= MAP_FIX_Z_COORD[map_id]
        else fake_origin[2] = origin[2]
        //fake_origin[2]=-712.876892
       
        fake_origin[0]+=ARENA_COORDS[coords][0]*1.7
        fake_origin[1]+=ARENA_COORDS[coords][1]*1.53
       
        new ent=engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"func_wall"));
       
        set_pev(ent,pev_classname,ARENA_ENT_NAME);
        engfunc(EngFunc_SetModel,ent,ARENA_MODELS[0]);
        entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
        engfunc(EngFunc_SetSize,ent,ARENA_MINS,ARENA_MAXS);
        entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
        entity_set_int(ent,EV_INT_iuser1,ent_code)
        entity_set_int(ent,EV_INT_iuser3,ext_code)
        engfunc(EngFunc_SetOrigin,ent,fake_origin);
        stuck_check(fake_origin,120.0)
        static Float:rvec[3];
        pev(ent,pev_v_angle,rvec);
       
        rvec[0]=90.0;
        set_pev(ent,pev_angles,rvec);
       
        if(ARENA_COORDS[coords][0] == 0.0 && ARENA_COORDS[coords][1] == 100.0)
        {
            fake_origin[0] += max_size[0]
            fake_origin[1] += max_size[1]
            //create_wall(LEFT_SIDE,255,SOLID_BBOX,ent_code,0,ext_code,fake_origin)
        }
        if(ARENA_COORDS[coords][0] == 0.0 && ARENA_COORDS[coords][1] == -100.0)
        {
            fake_origin[0] += max_size[2]
            fake_origin[1] += min_size[0]
            //create_wall(RIGHT_SIDE,255,SOLID_BBOX,ent_code,0,ext_code,fake_origin)
        }
        if(ARENA_COORDS[coords][0] == 0.0 && ARENA_COORDS[coords][1] == 0.0)
        {
            create_wall(TOP_SIDE,255,SOLID_BBOX,ent_code,0,ext_code,fake_origin)
            entity_set_int(ent,EV_INT_iuser2,CENTER_CODE)
        }
        else if(ARENA_COORDS[coords][0] == 200.0 && ARENA_COORDS[coords][1] == 0.0)
        {
            fake_origin[0] += min_size[1]
           
            //create_wall(BLUE_SIDE,255,SOLID_BBOX,ent_code,0,ext_code,fake_origin)
        }
        else if(ARENA_COORDS[coords][0] == -100.0 && ARENA_COORDS[coords][1] == 0.0)
        {
            fake_origin[0] += min_size[2]
            //create_wall(RED_SIDE,255,SOLID_BBOX,ent_code,0,ext_code,fake_origin)
        }
        set_rendering(ent,kRenderFxGlowShell,0,50,0,kRenderNormal,10)
    }
    select_the_fake_arena(ext_code)
    return PLUGIN_HANDLED;
}
 
public move_the_fake_arena(id,code,moveto)
{
    new num;
    num = code-EXTRA_CODE
    new arenas_ent=-1;
    new Float:origin[3];
    while((arenas_ent=engfunc(EngFunc_FindEntityByString,arenas_ent,"classname",ARENA_ENT_NAME)))
    {
        if(entity_get_int(arenas_ent,EV_INT_iuser1) == FAKE_CODE)
        {
            if(entity_get_int(arenas_ent,EV_INT_iuser3) == code || num == -1)
            {
                pev(arenas_ent,pev_origin,origin);
                switch(moveto)
                {
                    case MOVE_UP:
                    {
                        origin[2]+=move_size[id]
                    }
                    case MOVE_DOWN:
                    {
                        origin[2]-=move_size[id]
                    }
                    case MOVE_RIGHT:
                    {
                        origin[1]+=move_size[id]
                    }
                    case MOVE_LEFT:
                    {
                        origin[1]-=move_size[id]
                    }
                    case MOVE_FRONT:
                    {
                        origin[0]+=move_size[id]
                    }
                    case MOVE_BACK:
                    {
                        origin[0]-=move_size[id]
                    }
                }
                engfunc(EngFunc_SetOrigin,arenas_ent,origin);
                stuck_check(origin,360.0)
            }
        }
    }
}
 
public select_the_fake_arena(code)
{
    new num;
    num = code-EXTRA_CODE

    new arenas_ent=-1;
    while((arenas_ent=engfunc(EngFunc_FindEntityByString,arenas_ent,"classname",ARENA_ENT_NAME)))
    {
        if(entity_get_int(arenas_ent,EV_INT_iuser1) == FAKE_CODE)
        {
            if(num == -1)	set_rendering(arenas_ent,kRenderFxGlowShell,250,0,0,kRenderNormal,10)
            else if(entity_get_int(arenas_ent,EV_INT_iuser3) == code)	set_rendering(arenas_ent,kRenderFxGlowShell,250,0,0,kRenderNormal,10)
        }
    }
    unselect_the_fake_arena(code)
}
 
public unselect_the_fake_arena(code)
{
    new num;
    num = code-EXTRA_CODE

    if(num == -1)	return;

    new arenas_ent=-1;
    while((arenas_ent=engfunc(EngFunc_FindEntityByString,arenas_ent,"classname",ARENA_ENT_NAME)))	if(entity_get_int(arenas_ent,EV_INT_iuser1) == FAKE_CODE && entity_get_int(arenas_ent,EV_INT_iuser3) != code)	set_rendering(arenas_ent,kRenderFxGlowShell,50,50,50,kRenderTransAdd,120)
}
 
public delete_the_fake_arena(code)
{
    new arenas_ent=-1;
    new found = 0

    while((arenas_ent=engfunc(EngFunc_FindEntityByString,arenas_ent,"classname",ARENA_ENT_NAME)))
    {
        if(entity_get_int(arenas_ent,EV_INT_iuser1) == FAKE_CODE && entity_get_int(arenas_ent,EV_INT_iuser3) == code)
        {
            engfunc(EngFunc_RemoveEntity,arenas_ent)
            found++
        }
    }

    if(found)	fakes--
}
 
public load_arena_coords(id)
{
    // Check for spawns points of the current map
    new cfgdir[32], mapname[32], filepath[100], linedata[64]
    get_configsdir(cfgdir, charsmax(cfgdir))
    get_mapname(mapname, charsmax(mapname))
    formatex(filepath, charsmax(filepath), ARENA_FILE, cfgdir, mapname)
    new arena = 0
    total_arenas = 0
    // Load spawns points
    if (file_exists(filepath))
    {
        new file = fopen(filepath,"rt"), row[4][6]
        while (file && !feof(file))
        {
            fgets(file, linedata, charsmax(linedata))
           
            // invalid spawn
            if(!linedata[0] || str_count(linedata,' ') < 2) continue;
           
            arena++
            if (arena > MAX_ARENAS)	break
           
            // get spawn point data
            parse(linedata,row[0],5,row[1],5,row[2],5)
           
            // origin
            arena_coord[arena][0] = floatstr(row[0])
            arena_coord[arena][1] = floatstr(row[1])
            if(bugged_map())	arena_coord[arena][2] = MAP_FIX_Z_COORD[map_id]
            else arena_coord[arena][2] = floatstr(row[2])
 
            total_arenas = arena
        }

        if (file) fclose(file)
    }

    if(id != -1)
    {
        if(!total_arenas)	client_print_color(id,"%sCouldn't load: ^3No arenas found.",CHAT_TAG)
        else	client_print_color(id,"%s%d ^3arena%s loaded.",CHAT_TAG,total_arenas, (total_arenas > 1 ? "s" : ""))
    }
}
 
stock bugged_map()
{
    if(!MAP_FIX_ENABLED)	return PLUGIN_CONTINUE
    if(IS_BUGGED_MAP)	return PLUGIN_HANDLED

    return PLUGIN_CONTINUE
}
 
stock str_count(const str[], searchchar)
{
    new count, i, len = strlen(str)
   
    for (i = 0; i <= len; i++)	if(str[i] == searchchar)	count++
   
    return count;
}
 
public Player_spawn_post(id)
{
    Set_Entity_Invisible(id, 0)
    if(is_user_alive(id))
    {
        if(is_in_duel[id] != 2)
        {
            set_task(1.0,"get_spawn_origin",id)
            return;
        }

        if(is_in_duel[id] == 2)	spawn_back(id)
    }
}
public spawn_back(id)
{
    entity_set_origin(id,his_spawn[id])
    set_user_health(id,map_default_hp)
    set_user_armor(id,0)
    set_user_godmode(id, 0)

    if(is_user_connected(his_challenger[id]))
    {
        check_teams(id,his_challenger[id])
        entity_set_origin(his_challenger[id],his_spawn[his_challenger[id]])
        set_user_health(his_challenger[id],map_default_hp)
        set_user_armor(his_challenger[id],0)
        entity_set_vector(id, EV_VEC_angles, his_angle[id])
        entity_set_int(id, EV_INT_fixangle, 1)
        entity_set_vector(his_challenger[id], EV_VEC_angles, his_angle[his_challenger[id]])
        entity_set_int(his_challenger[id], EV_INT_fixangle, 1)
    }
}
 
public update_cvars()
{
    MAP_FIX_ENABLED = get_pcvar_num(cvar_z_fix)
    SOUNDS_ENABLED = get_pcvar_num(cvar_sounds)
    MAX_ROUNDS = get_pcvar_num(cvar_rounds)
    MAX_KILLS = get_pcvar_num(cvar_kills)
    MAX_COUNTDOWN = get_pcvar_num(cvar_cooldown)
    MAX_TIME = get_pcvar_num(cvar_time)
}
 
stock remove_allarenas()
{
    new arenas_ent=-1;
    while((arenas_ent=engfunc(EngFunc_FindEntityByString,arenas_ent,"classname",ARENA_ENT_NAME)))	engfunc(EngFunc_RemoveEntity,arenas_ent)
    fakes = 0
}
 
public get_all_arena_coords(id)
{
    new Float:origin[3]
    new arenas_ent=-1;
    while((arenas_ent=engfunc(EngFunc_FindEntityByString,arenas_ent,"classname",ARENA_ENT_NAME)))
    {
        if(entity_get_int(arenas_ent,EV_INT_iuser2) == CENTER_CODE)
        {
            pev(arenas_ent,pev_origin,origin);
            client_print(id,print_console,"%.f %.f %.f",origin[0],origin[1],origin[2])
        }
    }
    client_print_color(id, "%s ^4Coords printed in console.",CHAT_TAG)
}
 
public remove_the_fake_arena()
{
    new arenas_ent=-1;
    while((arenas_ent=engfunc(EngFunc_FindEntityByString,arenas_ent,"classname",ARENA_ENT_NAME)))	if(entity_get_int(arenas_ent,EV_INT_iuser1) == FAKE_CODE)	engfunc(EngFunc_RemoveEntity,arenas_ent)

    fakes = 0
}
public next_fake_arena()
{
    if(fakes_count() >= MAX_ARENAS)	return -1

    for(new i=1;i < MAX_ARENAS+1;i++)	if(!fake_arena_exists(i))	return i

    return -1
    /*new num = fakes
    num++
    return num*/
}


public remove_the_arena(code)
{
    new arenas_ent=-1;
    while((arenas_ent=engfunc(EngFunc_FindEntityByString,arenas_ent,"classname",ARENA_ENT_NAME)))	if(entity_get_int(arenas_ent,EV_INT_iuser1) == code)	engfunc(EngFunc_RemoveEntity,arenas_ent)
}
public start_build(id)
{
    if(!is_user_connected(id)||is_in_duel[id] != 2||!his_challenger[id]||!total_arenas)	return PLUGIN_HANDLED

    static Float:origin[3];
    //get_user_hitpoint(id,origin)
    /*origin[0] = 1002.911376
    origin[1] = -1561.421997
    origin[2] = 0.0*/
    origin[0] = arena_coord[arena_number[id]][0]
    origin[1] = arena_coord[arena_number[id]][1]
    origin[2] = arena_coord[arena_number[id]][2]

    new Float:fake_origin[3]
    static size
    size = sizeof(ARENA_COORDS)
    new ent_code = arena_number[id]+ARENA_CODE

    for(new coords;coords < size; coords++)
    {
        fake_origin[0] = origin[0]
        fake_origin[1] = origin[1]
        fake_origin[2] = origin[2]
        //fake_origin[2]=-712.876892
        //fake_origin[2]=-864.253723
        fake_origin[0]+=ARENA_COORDS[coords][0]*1.7
        fake_origin[1]+=ARENA_COORDS[coords][1]*1.53
       
        new ent=engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"func_wall"));
       
        set_pev(ent,pev_classname,ARENA_ENT_NAME);
        engfunc(EngFunc_SetModel,ent,ARENA_MODELS[0]);
        entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
        engfunc(EngFunc_SetSize,ent,ARENA_MINS,ARENA_MAXS);
        entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
        entity_set_int(ent,EV_INT_iuser1,ent_code)
        engfunc(EngFunc_SetOrigin,ent,fake_origin);

        static Float:rvec[3];
        pev(ent,pev_v_angle,rvec);
       
        rvec[0]=90.0;
        set_pev(ent,pev_angles,rvec);
       
        if(ARENA_COORDS[coords][0] == 0.0 && ARENA_COORDS[coords][1] == 100.0)	create_wall(LEFT_SIDE,0,SOLID_BBOX,ent_code,0,0,fake_origin)
        if(ARENA_COORDS[coords][0] == 0.0 && ARENA_COORDS[coords][1] == -100.0)	create_wall(RIGHT_SIDE,0,SOLID_BBOX,ent_code,0,0,fake_origin)
        if(ARENA_COORDS[coords][0] == 0.0 && ARENA_COORDS[coords][1] == 0.0)
        {
            create_wall(TOP_SIDE,0,SOLID_BBOX,ent_code,0,0,fake_origin)
            entity_set_int(ent,EV_INT_iuser2,CENTER_CODE)
        }
        else if(ARENA_COORDS[coords][0] == 200.0 && ARENA_COORDS[coords][1] == 0.0)
        {
            create_wall(BLUE_SIDE,0,SOLID_BBOX,ent_code,0,0,fake_origin)

            if(cs_get_user_team(id) == CS_TEAM_CT)	set_spawn_positions(id,BLUE_SIDE,fake_origin,rvec)                                                                           
            else	if(his_challenger[id])	set_spawn_positions(his_challenger[id],BLUE_SIDE,fake_origin,rvec)
            //set_rendering(ent,kRenderFxGlowShell,0,0,200,kRenderNormal,10)
        }
        else if(ARENA_COORDS[coords][0] == -100.0 && ARENA_COORDS[coords][1] == 0.0)
        {
            create_wall(RED_SIDE,0,SOLID_BBOX,ent_code,0,0,fake_origin)

            if(cs_get_user_team(id) == CS_TEAM_T)	set_spawn_positions(id,RED_SIDE,fake_origin,rvec)                                                                           
            else	if(his_challenger[id])	set_spawn_positions(his_challenger[id],RED_SIDE,fake_origin,rvec)
            //set_rendering(ent,kRenderFxGlowShell,200,0,0,kRenderNormal,10)
        }
        spawn_back(id)
    }
   
    return PLUGIN_HANDLED;
}
 
public set_spawn_positions(id,side,Float:origin[3],Float:angle[3])
{
    if(side == BLUE_SIDE)	his_spawn[id][0] = origin[0]-20.0
    else his_spawn[id][0] = origin[0]-120.0

    his_spawn[id][1] = origin[1]
    his_spawn[id][2] = origin[2]+50.0
    entity_get_vector(id, EV_VEC_angles,his_angle[id])

    switch(side)
    {
        case RED_SIDE:
        {
            his_angle[id][1] = 0.0
            his_angle[id][0] = 0.0
        }
        case BLUE_SIDE:
        {
            his_angle[id][1] = 180.0
            his_angle[id][0] = 0.0
        }
    }
    got_spawn[id] = 1
}
 
public stuck_check(Float:origin[3],Float:radius)
{
    new player=-1;
    while((player = find_ent_in_sphere(player,origin,radius)) != 0)	if(is_user_alive(player))	if(is_player_stuck(player) && is_in_duel[player] != 2)	back_to_the_spawn(player)
}
 
stock is_player_stuck(id)
{
    static Float:originF[3]
    pev(id, pev_origin, originF)
   
    engfunc(EngFunc_TraceHull, originF, originF, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0)
   
    if (get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))	return true;
   
    return false;
}
 
public create_wall(type,alpha,solidity,code,code1,code2,Float:origin[3])
{
    new Float:wall_maxsize[3];
    new Float:wall_minsize[3];
    new Float:rvec[3];
    new ent=engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"func_wall"));
    pev(ent,pev_v_angle,rvec);

    switch(type)
    {
        case BLUE_SIDE:
        {
            wall_maxsize[0] = 2.0
            wall_minsize[0] = 0.0
            wall_maxsize[1] = 230.0
            wall_minsize[1] = -230.0
            wall_maxsize[2] = 150.0
            wall_minsize[2] = -1.0
            rvec[1]=180.0
        }
        case RED_SIDE:
        {
            wall_maxsize[0] = -150.0
            wall_minsize[0] = -152.0
            wall_maxsize[1] = 230.0
            wall_minsize[1] = -230.0
            wall_maxsize[2] = 150.0
            wall_minsize[2] = -1.0
            rvec[1]=180.0
        }
        case LEFT_SIDE:
        {
            wall_maxsize[0] = 360.0
            wall_minsize[0] = -300.0
            wall_maxsize[1] = 65.0
            wall_minsize[1] = 63.0
            wall_maxsize[2] = 150.0
            wall_minsize[2] = -1.0
            rvec[1]=90.0
        }
        case RIGHT_SIDE:
        {
            wall_maxsize[0] = 360.0
            wall_minsize[0] = -300.0
            wall_maxsize[1] = -63.0
            wall_minsize[1] = -65.0
            wall_maxsize[2] = 150.0
            rvec[1]=90.0
        }
        case TOP_SIDE:
        {
            wall_maxsize[0] = 360.0
            wall_minsize[0] = -300.0
            wall_maxsize[1] = 230.0
            wall_minsize[1] = -230.0
            wall_maxsize[2] = 150.0
            wall_minsize[2] = 148.0
            rvec[0]=90.0          
        }
    }
    set_pev(ent,pev_angles,rvec);
   
    set_pev(ent,pev_classname,ARENA_ENT_NAME);
    engfunc(EngFunc_SetModel,ent,ARENA_MODELS[0]);
    set_pev(ent, pev_effects, EF_NODRAW)
    entity_set_int(ent, EV_INT_solid, solidity);
    engfunc(EngFunc_SetSize,ent,wall_minsize,wall_maxsize);
    entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
    entity_set_int(ent,EV_INT_iuser1,code)
    entity_set_int(ent,EV_INT_iuser2,code1)
    entity_set_int(ent,EV_INT_iuser3,code2)
    engfunc(EngFunc_SetOrigin,ent,origin);
    //set_rendering(ent,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,alpha)
    //set_rendering(ent, kRenderFxGlowShell, 255, 100, 0, kRenderTransColor, 1);
}
 
public get_spawn_origin(id)	pev(id,pev_origin,his_original_spawn[id]);
 
stock get_user_hitpoint(id,Float:hOrigin[3])  {
    if(!is_user_alive(id))	return 0;
 
    new Float:fOrigin[3],Float:fvAngle[3],Float:fvOffset[3],Float:fvOrigin[3],Float:feOrigin[3];
    new Float:fTemp[3];
 
    pev(id,pev_origin,fOrigin);
    pev(id,pev_v_angle,fvAngle);
    pev(id,pev_view_ofs,fvOffset);
 
    xs_vec_add(fOrigin,fvOffset,fvOrigin);
 
    engfunc(EngFunc_AngleVectors,fvAngle,feOrigin,fTemp,fTemp);
 
    xs_vec_mul_scalar(feOrigin,9999.9,feOrigin);
    xs_vec_add(fvOrigin,feOrigin,feOrigin);
 
    engfunc(EngFunc_TraceLine,fvOrigin,feOrigin,0,id);
    global_get(glb_trace_endpos,hOrigin);
 
    return 1;
}
 
public plugin_precache()
{
    new size;
    size = sizeof(ARENA_MODELS)

    for(new i; i< size; i++)
    {
        engfunc(EngFunc_PrecacheModel,ARENA_MODELS[i]);
        precache_model("models/v_knife.mdl")
        precache_model("models/p_knife.mdl")
    }
 
    if(!file_exists("addons/amxmodx/data/lang/boost_manager.txt"))	for(new i=0;i< sizeof LANG_FILE;i++)	write_file("addons/amxmodx/data/lang/boost_manager.txt", LANG_FILE[i]);
}

public round_start_event()
{
    update_cvars();
    // using a variable to store player's names instead of regenerating it all the time...
    for(new id;id < MAXPLAYERS;id++)	if(is_user_connected(id))	get_user_name(id,his_name[id],charsmax(his_name))
}
 
public Advertise(task)
{
    client_print_color(0,"^3[^4Global Knife^3] ^1Bind ^3(E+R) ^1or ^3(mouse1 + mouse2) ^1to open ^4Duel Menu")

    set_task(100.0,"Advertise",TASK_AD)
}

public Cmd_start(id,hndle)
{
    if(!is_user_alive(id)||!is_frozen[id])	return FMRES_IGNORED

    new Buttons = get_uc(hndle,UC_Buttons)
    if(Buttons & IN_ATTACK)
    {
        Buttons &= ~IN_ATTACK
        set_uc( hndle , UC_Buttons , Buttons )
        return FMRES_SUPERCEDE
    }
    if(Buttons & IN_ATTACK2)
    {
        Buttons &= ~IN_ATTACK2
        set_uc( hndle , UC_Buttons , Buttons )
        return FMRES_SUPERCEDE
    }
    return FMRES_IGNORED
}
 
public Player_Take_Damage(victim, inflictor, attacker, Float:damage, damage_bits)
{    
    if(is_user_connected(attacker)) // we make sure the attacker is a player
    {
        if(is_in_duel[victim] == 2 || is_in_duel[attacker] == 2)
        {
            if(his_challenger[victim] != attacker || his_challenger[attacker] != victim)
            {
                // we protect the contenders from getting killed by other people or them killing others?
                return HAM_SUPERCEDE
            }
        }
    }
    return HAM_IGNORED
}
 
public client_putinserver(id)
{
    get_user_name(id,his_name[id],charsmax(his_name))
    reset_values(id)
    move_size[id] = 10.0
    his_offline[id] = 0
    his_previous_team[id] = 0
    set_task(1.0, "duel_showhud", id, _, _, "b")
}
 
public client_disconnect(id)
{
    end_his_duel(id)

    Vault(id, 1)
}
 
public end_his_duel(id)
{
    if(his_challenger[id])
    {
        client_print_color(0,"^3[^4Arena: %s^3] ^4%s^1's challenger ^4%s^1 has ^3left the game^1.",arena_names[arena_number[id]],his_name[his_challenger[id]],his_name[id])
        user_can_spawn[his_challenger[id]] = 1
        user_can_spawn[id] = 1
        if(arena_number[id] == arena_number[his_challenger[id]])	remove_the_arena(arena_number[id] +ARENA_CODE)
        back_to_the_spawn(id)
        back_to_the_spawn(his_challenger[id])
        reset_values(his_challenger[id])
    }
    reset_values(id)
}
 
public times_up_duel(id)
{
    client_print_color(0,"^3[^4Arena: %s^3] ^4%s^1 and ^4%s^1 has taken long to ^3finish the battle^1.",arena_names[arena_number[id]],his_name[his_challenger[id]],his_name[id])
       
    if(his_challenger[id])
    {
        if(arena_number[id] == arena_number[his_challenger[id]])	remove_the_arena(arena_number[id] +ARENA_CODE)

        user_kill(id,1)
        user_kill(his_challenger[id],1)
        //back_to_the_spawn(id)
        //back_to_the_spawn(his_challenger[id])
        reset_values(his_challenger[id])
    }

    reset_values(id)
}
 
public battle_timer(id)
{
    if(is_user_connected(id))
    {
        if(is_in_duel[id] == 2)
        {
            his_timer[id]++
            if(his_timer[id] > MAX_TIME)	times_up_duel(id)
            set_task(1.0,"battle_timer",id)
        }
    }
}
 
public toggle_offline(id)
{
    switch(his_offline[id])
    {
        case 0:
        {
            his_offline[id] = 1
            client_print_color(0,"%s^4%s^1 disconnected from the duel list.",CHAT_TAG,his_name[id])
        }
        default:
        {
            his_offline[id] = 0
            client_print_color(0,"%s^4%s^1 connected to the duel list.",CHAT_TAG,his_name[id])
        }
    }
}
 
public give_up_player(id)
{
    if(is_user_connected(his_challenger[id]))
    {
        client_print_color(0,"%s^4%s^3 got scared to face ^4%s^1 :)",CHAT_TAG,his_name[id],his_name[his_challenger[id]])
        if(arena_number[id] == arena_number[his_challenger[id]])	remove_the_arena(arena_number[id] +ARENA_CODE)
        back_to_the_spawn(id)
        back_to_the_spawn(his_challenger[id])
        reset_values(his_challenger[id])
    }
    reset_values(id)
}
 
public reward_winner(id)
{
if(is_user_connected(id))
{
g_winns[id]++
give_item(id, "weapon_hegrenade")
gBackStabing[id] = false;
cs_set_user_money(id,cs_get_user_money(id)+7000,1)
 
client_print_color(id,"%s^4Congratulations!!!^1, You have ^3won this battle^1!",CHAT_TAG)
if(SOUNDS_ENABLED)	client_cmd(id,"spk ^"%s^"",DUEL_SOUNDS[0])
/*if(cs_get_user_money(id)+15000 <= 16000)
{
cs_set_user_money(id,cs_get_user_money(id)+15000,1)
} else cs_set_user_money(id,16000,1)*/
}
}
 
 
public reward_loser(id)
{
if(is_user_connected(id))
{
g_loss[id]++
user_kill(id,1)
gBackStabing[id] = false;
client_print_color(id,"%sYou've ^3lost this battle^1!",CHAT_TAG)
if(SOUNDS_ENABLED)	client_cmd(id,"spk ^"%s^"",DUEL_SOUNDS[1])
/*if(cs_get_user_money(id)-15000 >= 0)
{
cs_set_user_money(id,cs_get_user_money(id)-15000,1)
} else cs_set_user_money(id,0,1)*/
}
}
 
public duel_players_list(id)
{
    if(!is_user_alive(id))
    {
        client_print_color(id,"%sYou can't challenge anyone when you're ^3dead1.",CHAT_TAG)
        return PLUGIN_HANDLED
    }
    if(his_offline[id])
    {
        client_print_color(id,"%sYou can't challenge people when you're ^3offline^1.",CHAT_TAG)
        return PLUGIN_HANDLED
    }
    if(is_user_connected(his_challenger[id]))
    {
        client_print_color(id,"%s^4%s ^1is still ^4fighting against you^1.",CHAT_TAG,his_name[his_challenger[id]])
        return PLUGIN_HANDLED
    }
    if(is_user_connected(his_asker[id]))
    {
        client_print_color(id,"%sYou can only ^3challenge one person^1 at the time, you've challenged ^4%s^1.",CHAT_TAG,his_name[his_asker[id]])
        return PLUGIN_HANDLED
    }
    if(!available_duelers(id))
    {
        client_print_color(id,"%sThere's ^4nobody^1 you can challenge.",CHAT_TAG)
        return PLUGIN_HANDLED
    }
    if(get_next_arena() == -1)
    {
        client_print_color(id,"%s^4Maximum arenas reached.",CHAT_TAG)
        return PLUGIN_HANDLED
    }

    new menu,menuformat[555];
    formatex(menuformat,charsmax(menuformat),"\w[\rGlobal Knife\w] \yKnifeDuels ^n\dArenas Free: %d/%d \w",arenas_count(),total_arenas)
    menu = menu_create( menuformat, "Duel_handler" );

    new szName[32], szUserId[32],nameu[92],CsTeams:team,tempid
    formatex(nameu,charsmax(nameu), "\yRefresh");
    menu_additem(menu, nameu,"rf_c", 0);
    menu_addblank(menu,0)

    //get_players( players, pnum, "c" );
    for ( new e; e<MAXPLAYERS; e++ )
    {
        if(!is_user_alive(e)||e==id&&!is_user_bot(e))	continue;

        tempid = e
        team = cs_get_user_team(tempid)
       
        if(tempid != id && team != CS_TEAM_SPECTATOR && team != CS_TEAM_UNASSIGNED)//  && !users_in_same_team(id,tempid))
        {
            get_user_name(tempid, szName, charsmax(szName));
            formatex(szUserId, charsmax(szUserId), "%d", get_user_userid(tempid));

            if(his_offline[tempid])
            {
                formatex(nameu,charsmax(nameu), "%s \w[\dOffline\w]", szName);
                menu_additem(menu, nameu, szUserId, 0);
            }
            else if(!is_user_alive(tempid))
            {
                formatex(nameu,charsmax(nameu), "\d%s [DEAD]", szName);
                menu_additem(menu, nameu, szUserId, 0);
            }
            else
            {
                if(is_in_duel[tempid] == 2)
                {
                    formatex(nameu,charsmax(nameu), "%s \w[\rIn Duel\w] \r[\yArena %s\r]", szName, arena_names[arena_number[id]]);
                    menu_additem(menu, nameu, szUserId);
                }
                else if(is_in_duel[tempid] == 1)
                {
                    formatex(nameu,charsmax(nameu), "%s \w[\yPending\w]", szName);
                    menu_additem(menu, nameu, szUserId, 0);
                }
                else
                {
                    formatex(nameu,charsmax(nameu), "%s", szName);
                    menu_additem(menu, nameu, szUserId, 0);
                }
            }
        }
    }
    menu_display(id, menu);

    return PLUGIN_HANDLED
}
public Duel_handler( id, menu, item )
{
    if ( item == MENU_EXIT )
    {
        menu_destroy( menu );
        return PLUGIN_HANDLED;
    }
   
    new szData[32], szName[64];
    new _access, item_callback;
    menu_item_getinfo( menu, item, _access, szData,charsmax( szData ), szName,charsmax( szName ), item_callback );

    if(equali(szData,"rf_c"))
    {
        menu_destroy( menu );
        duel_players_list(id)

        return PLUGIN_CONTINUE
    }

    new userid = str_to_num( szData );
    //spam_hud(id)
    new enem = find_player("k", userid); // flag "k" : find player from userid
    if (is_user_connected(enem))
    {
        if(get_next_arena() == -1)
        {
            client_print_color(id,"%sAl arena is busy right now! Try again later.",CHAT_TAG)
			return PLUGIN_HANDLED
        }
        if(!is_user_alive(enem))
        {
            client_print_color(id,"%sYou can't challenge dead players.",CHAT_TAG)
			return PLUGIN_HANDLED
        }
        if(his_offline[enem])
        {
            client_print_color(id,"%sYou can't challenge offline players.",CHAT_TAG)
			return PLUGIN_HANDLED
        }
        else
        {
            if(!is_in_duel[enem])
            {
                //spam_hud(enem)
                is_in_duel[enem] = 1
                is_in_duel[id] = 1
                his_asker[id] = enem
                his_asker[enem] = id
                ask_player(enem)
                client_print_color(0,"%s^4%s^1 has challenged ^4%s^1 for a ^3duel^1!",CHAT_TAG,his_name[id],his_name[enem])
               
                set_task(5.0,"taken_long",enem)

				return PLUGIN_HANDLED
            }
            else
            {
                client_print_color(id,"%s^4%s^1 seems ^3to be busy ^1with ^4another duel^1..",CHAT_TAG,his_name[enem])
				return PLUGIN_HANDLED
            }
        }
    }
    menu_destroy( menu );

    return PLUGIN_CONTINUE;
}
public taken_long(id)
{
    if(is_in_duel[id] == 1)
    {
		show_menu( id, 0, "^n", 1 );
        //client_print_color(0,"%s^4%s ^1has taken ^3too long to respond ^1to ^4%s^1's challenge.",CHAT_TAG,his_name[his_asker[id]],his_name[id])
        user_can_spawn[id] = 1
        user_can_spawn[his_asker[id]] = 1
        reset_values(his_asker[id])
        reset_values(id)
    }
}
 
stock available_duelers(asker)
{
    new num;
    num = 0 // just incase...

    for(new id;id < MAXPLAYERS;id++)	if(is_user_alive(id))	if(/*!is_in_duel[id] && */id != asker && !is_user_bot(id))	num++

    return num
}
 
public ask_player(id)
{
    if(!is_user_alive(id))	return PLUGIN_HANDLED

    new asker_name[32],menu_title[64];
    get_user_name(his_asker[id],asker_name,charsmax(asker_name))
    formatex(menu_title,charsmax(menu_title),"\rAccept Duel with \y%s\r ?",asker_name)

    new menu
    menu = menu_create( menu_title, "Ask_handler" );
   
    menu_additem(menu, "Yes!", "user_said_yes", 0);
    menu_additem(menu, "No!","user_said_no", 0);
   
    menu_display(id, menu);

    return PLUGIN_HANDLED
}
 
public Ask_handler( id, menu, item )
{
    if ( item == MENU_EXIT )
    {
        menu_destroy( menu );
        return PLUGIN_HANDLED;
    }
   
    new szData[65], szName[64];
    new _access, item_callback;
    menu_item_getinfo( menu, item, _access, szData,charsmax( szData ), szName,charsmax( szName ), item_callback );
   
    if(equal(szData,"user_said_yes"))
    {
		if(!is_user_alive(id))
		{
        client_print_color(id,"%sDuel challenge ^3canceled^1, ^4You're ^1dead..",CHAT_TAG)
        client_print_color(his_asker[id],"%sDuel challenge ^3canceled^1,^4 %s ^1is dead..",CHAT_TAG,his_name[his_asker[his_asker[id]]])
        reset_values(his_asker[id])
        reset_values(id)
		menu_destroy( menu );
		return PLUGIN_HANDLED
		}
        if(get_next_arena() == -1)
        {
            client_print_color(his_asker[id],"%sMaximum arenas reached.",CHAT_TAG)
            reset_values(his_asker[id])
            reset_values(id)
			menu_destroy( menu );
			return PLUGIN_HANDLED
        }
		if(is_in_duel[his_asker[id]] == 1)
        {
            manage_battle(id)
            check_teams(id,his_challenger[id])
            begin_the_battle(id,his_challenger[id])
			menu_destroy( menu );
			return PLUGIN_HANDLED
        }
		else
        {
            client_print_color(id,"%s%s either canceled the duel or chosen someone else to duel.",CHAT_TAG,his_name[his_asker[id]])
            reset_values(his_asker[id])
            reset_values(id)
			menu_destroy( menu );
			return PLUGIN_HANDLED
        }
		menu_destroy( menu );
    }
    if(equal(szData,"user_said_no"))
    {
        if(is_user_connected(his_asker[id]))
        {
            client_print_color(0,"%s^4%s ^1rejected ^4%s^1's challenge.",CHAT_TAG,his_name[id],his_name[his_asker[id]])
            reset_values(his_asker[id])
            reset_values(id)
			menu_destroy( menu );
			return PLUGIN_HANDLED
        }
		menu_destroy( menu );
    }
    //menu_destroy( menu );
    return PLUGIN_CONTINUE;
}
 
public Player_Killed(victim, attacker, shouldgib)
{
    if(!is_user_connected(victim)||is_in_duel[victim] != 2||!is_user_connected(attacker)||attacker == victim||is_in_duel[attacker] != 2
	|| is_in_duel[victim] != 2)	return HAM_IGNORED;

    if(is_user_connected(his_challenger[victim]) && !is_user_connected(attacker))	if(!check_teams(victim,attacker))	return HAM_IGNORED
   
    if(his_challenger[victim] == attacker || his_challenger[attacker] == victim )
    {
        fake_death(attacker,victim)
        his_wins[attacker]++
        rounds[arena_number[attacker]]++
        static ret;
        ExecuteForward(killed_forward, ret, attacker,victim)
        //ExecuteHamB( Ham_AddPoints, attacker, 1, true );
        //ExecuteHamB( Ham_AddPoints, victim, -1, true );
 
        new victim_name[64],attacker_name[64];
        get_user_name(victim,victim_name,charsmax(victim_name))
        get_user_name(attacker,attacker_name,charsmax(attacker_name))
 
        new distance,vorigin[3],aorigin[3]
 
        get_user_origin(victim,vorigin)
        get_user_origin(attacker,aorigin)
 
        distance = get_distance(vorigin,aorigin)
        new Float:iMeters = distance * 0.0254
 
        client_print_color(attacker,"^4[Global Knife Distance] ^1You Killed ^3%s ^1from a distance of ^3[%.2f] ^1meters !",victim_name,iMeters)
        client_print_color(victim,"^4[Global Knife Distance] ^3%s ^1Killed you from a distance of ^3[%.2f] ^1meters !",attacker_name,iMeters)
                       
        if(Head_shot[attacker][victim])
        {
            his_HS[attacker]++
            client_cmd(0,"spk ^"%s^"",DUEL_SOUNDS[5])
            Head_shot[attacker][victim] = false
        }
        //user_silentkill(victim)
        if(rounds[arena_number[attacker]] >= MAX_ROUNDS || his_wins[attacker] >= MAX_KILLS)
        {
            if(!get_non_duelers_alive())
            {
                ExecuteHamB(Ham_CS_RoundRespawn, victim)
                Check_Results(attacker,victim)
                return HAM_SUPERCEDE
            }
            else
            {
                ExecuteHamB(Ham_CS_RoundRespawn, victim)
                Check_Results(attacker,victim)
            }
        }
        else
        {
            wait_for_enemy_loop(attacker)
            //client_print_color(attacker,"%s^4Rounds^1:^3%d^4/^3%d^1 | ^4You^1:^3%d^4/^3%d^1 | ^4%s^1:^3%d^4/^3%d^1.",CHAT_TAG,rounds[arena_number[attacker]],MAX_ROUNDS,his_wins[attacker],MAX_KILLS,his_name[victim],his_wins[victim],MAX_KILLS)
            //client_print_color(victim,"%s^4Rounds^1:^3%d^4/^3%d^1 | ^4You^1:^3%d^4/^3%d^1 | ^4%s^1:^3%d^4/^3%d^1.",CHAT_TAG,rounds[arena_number[attacker]],MAX_ROUNDS,his_wins[victim],MAX_KILLS,his_name[attacker],his_wins[attacker],MAX_KILLS)
        }
        Set_Entity_Invisible(victim, 1)
        set_task(0.1,"delay_respawn",victim)
        return HAM_SUPERCEDE
    }
    return HAM_IGNORED
}
 
public fake_death(attacker,victim)
{
    message_begin( MSG_ALL, get_user_msgid("DeathMsg"),{0,0,0},0)
    write_byte(attacker)
    write_byte(victim)
    write_byte(0)
    write_string("knife")
    message_end()
}

public delay_respawn(id)
{
    if(is_user_connected(id))
    {
        if(!is_user_alive(id))
        {
            if(is_in_duel[id] == 2)
            {
                user_can_spawn[id] = 1
                ExecuteHamB(Ham_CS_RoundRespawn, id)
                user_can_spawn[id] = 0
            }else{
                user_can_spawn[id] = 1
                ExecuteHamB(Ham_CS_RoundRespawn, id)
            }
        }
        Set_Entity_Invisible(id, 0)
    }
    return PLUGIN_CONTINUE
}
 
public Check_Results(id,enemy)
{
    reset_teams(id)
    reset_teams(enemy)

    new id_name[64],enemy_name[64];
    get_user_name(id,id_name,charsmax(id_name))
    get_user_name(enemy,enemy_name,charsmax(enemy_name))

    new mapname[32]
    get_mapname(mapname,31)
 
    if(his_wins[id] > his_wins[enemy])
    {
        client_print_color(0,"^3[^4Arena: %s^3] ^4%s ^1won against ^4%s ^1with score ^3[%d/%d] ^1HS ^3[%d/%d] ^1Winns ^3[%d] ^1Loos ^3[%d]",arena_names[arena_number[id]],id_name,enemy_name,his_wins[id],his_wins[enemy],his_HS[id],his_HS[enemy],g_winns[id],g_loss[id])
        log_to_file(Duel_logs, "Arena: %s - [ [%s] vs [%s] with score [%d/%d] headshots [%d/%d] kills [%d] deaths [%d] ALL HS [%d] on map [%s]]",arena_names[arena_number[id]],id_name,enemy_name,his_wins[id],his_wins[enemy],his_HS[id],his_HS[enemy],g_kills[id],g_deaths[id],g_headshots[id],mapname)
        reward_winner(id)
        reward_loser(enemy)
    }
    else if(his_wins[enemy] > his_wins[id])
    {
        client_print_color(0,"^3[^4Arena: %s^3] ^4%s ^1won against ^4%s ^1with score ^3[%d/%d] ^1headshots ^3[%d/%d] ^1Winns ^3[%d] ^1Loos ^3[%d]",arena_names[arena_number[id]],enemy_name,id_name,his_wins[enemy],his_wins[id],his_HS[enemy],his_HS[id],g_winns[id],g_loss[id])
        reward_winner(enemy)
        reward_loser(id)
    }
    else
    {
        client_print_color(0,"^3[^4Arena: %s^3] ^4%s ^1and ^4%s ^1ended in a ^3draw match.",arena_names[arena_number[id]],id_name,enemy_name)

        if(SOUNDS_ENABLED)
        {
            client_cmd(id,"spk ^"%s^"",DUEL_SOUNDS[2])
            client_cmd(enemy,"spk ^"%s^"",DUEL_SOUNDS[2])
        }
        if(his_wins[id] == his_wins[enemy])
        {
            user_kill(id,1)
            user_kill(enemy,1)
        }
    }

    //client_print_color(0, DontChange,"%s^3Headshots: ^4%s^1:^3%d ^4%s^1:^3%d^1.",CHAT_TAG,id_name,his_HS[id],enemy_name,his_HS[enemy])
    if(arena_number[id] == arena_number[enemy])	remove_the_arena(arena_number[id] +ARENA_CODE)

    back_to_the_spawn(id)
    back_to_the_spawn(enemy)

    reset_values(enemy)
    reset_values(id)

	if(task_exists(id+360))	remove_task(id+360)
	if(task_exists(enemy+360))	remove_task(enemy+360)
}
 
public back_to_the_spawn(id)
{
    if(is_user_alive(id))
    {
        entity_set_origin(id,his_original_spawn[id])
        Set_Entity_Invisible(id, 0)
        set_user_health(id,map_default_hp)
    }
    set_user_armor(id,0)
    set_user_godmode(id, 0)
}
 

public manage_battle(id)
{
    is_in_duel[id] = 2
    is_in_duel[his_challenger[id]] = 2

    his_challenger[id] = his_asker[id]
    his_challenger[his_challenger[id]] = id

    his_asker[id] = 0
    his_asker[his_challenger[id]] = 0

    his_wins[id] = 0
    his_wins[his_challenger[id]] = 0

    user_can_spawn[id] = 0
    user_can_spawn[his_challenger[id]] = 0

    new aren_code = get_next_arena()
    arena_number[id] = aren_code
    arena_number[his_challenger[id]] = aren_code
    rounds[aren_code] = 0

    new CsTeams:teamid,CsTeams:teamenemy;
    teamid = cs_get_user_team(id)
    teamenemy = cs_get_user_team(his_challenger[id])

    if(teamid == CS_TEAM_T)	his_previous_team[id] = 2
    else if(teamid == CS_TEAM_CT)	his_previous_team[id] = 1
    else his_previous_team[id] = 0
   
    if(teamenemy == CS_TEAM_T)	his_previous_team[his_challenger[id]] = 2
    else if(teamenemy == CS_TEAM_CT)	his_previous_team[his_challenger[id]] = 1
    else his_previous_team[his_challenger[id]] = 0

    start_build(id)
    start_build(his_challenger[id])

    if(SOUNDS_ENABLED)
    {
        client_cmd(id,"spk ^"%s^"",DUEL_SOUNDS[4])
        client_cmd(his_challenger[id],"spk ^"%s^"",DUEL_SOUNDS[4])
    }

    battle_timer(id)
    battle_timer(his_challenger[id])

    hud_displayer(id)
    hud_displayer(his_challenger[id])

    strip_user_weapons(his_challenger[id])
    give_item(his_challenger[id],"weapon_knife")

    strip_user_weapons(id)
    give_item(id,"weapon_knife")

    set_pev(id, pev_viewmodel, g_allocVmod)
    set_pev(id, pev_weaponmodel, g_allocPmod)

    set_pev(his_challenger[id], pev_viewmodel, g_allocVmod)
    set_pev(his_challenger[id], pev_weaponmodel, g_allocPmod)

    client_print_color(0,"%s^4%s^1 accepted ^4%s^1's challenge!",CHAT_TAG,his_name[id],his_name[his_challenger[id]])
}
 
public begin_the_battle(id,enemy)	start_new_round(id,enemy)
public start_new_round(id,enemy)
{
    his_timer[id] = 0
    his_timer[enemy] = 0

    is_frozen[id] = 1
    is_frozen[enemy] = 1

    his_countdown[id] = MAX_COUNTDOWN
    his_countdown[enemy] = MAX_COUNTDOWN

    countdown(id)
    countdown(enemy)

    strip_user_weapons(his_challenger[id])
    give_item(his_challenger[id],"weapon_knife")

    strip_user_weapons(his_challenger[enemy])
    give_item(his_challenger[enemy],"weapon_knife")

    set_pev(his_challenger[id], pev_viewmodel, g_allocVmod)  
    set_pev(his_challenger[id], pev_weaponmodel, g_allocPmod)

    set_pev(his_challenger[enemy], pev_viewmodel, g_allocVmod)  
    set_pev(his_challenger[enemy], pev_weaponmodel, g_allocPmod)
}
public countdown(id)
{
    if(is_user_connected(id))
    {
        his_countdown[id]--

        if(0 >= his_countdown[id])
        {
            is_frozen[id] = 0

            unfreeze_player(id)

            if(SOUNDS_ENABLED)	client_cmd(id,"spk ^"%s^"",DUEL_SOUNDS[6])

            client_print(id,print_center,"Fight!")

            return PLUGIN_HANDLED
        }
        else
        {
            freeze_player(id)

            if(SOUNDS_ENABLED)	client_cmd(id,"spk ^"%s^"",DUEL_SOUNDS[5])

            client_print(id,print_center,"%d",his_countdown[id])

            if(!is_frozen[id]) // we prevent it from spamming
                is_frozen[id] = 1
        }
        set_task(1.0,"countdown",id)
    }
    return PLUGIN_CONTINUE
}
 
public reset_teams(id)
{
    if(his_previous_team[id] == 1)	cs_set_user_team(id,CS_TEAM_CT)
    else if(his_previous_team[id] == 2)	cs_set_user_team(id,CS_TEAM_T)

    return PLUGIN_CONTINUE
}
 
public check_teams(id,enemy)
{
    if(!is_user_connected(id) || !is_user_connected(enemy))	return PLUGIN_CONTINUE;

    new CsTeams:teamid,CsTeams:teamenemy;
    teamid = cs_get_user_team(id)
    teamenemy = cs_get_user_team(enemy)

    if(!users_in_same_team(id,enemy) && !is_in_false_team(id) && !is_in_false_team(enemy))	return PLUGIN_HANDLED

    if(teamid == CS_TEAM_CT && teamenemy == CS_TEAM_CT )	cs_set_user_team(id,CS_TEAM_T)
	else if(teamid == CS_TEAM_T && teamenemy == CS_TEAM_T)	cs_set_user_team(id,CS_TEAM_CT)
    else
    {
        Check_Results(id,enemy)

        return PLUGIN_CONTINUE
    }
    return PLUGIN_HANDLED
}
stock is_in_false_team(id)
{
    if(cs_get_user_team(id) == CS_TEAM_SPECTATOR || cs_get_user_team(id) == CS_TEAM_UNASSIGNED)	return PLUGIN_HANDLED
    return PLUGIN_CONTINUE
}
stock users_in_same_team(id,enemy)
{
    if(cs_get_user_team(id) == cs_get_user_team(enemy))	return PLUGIN_HANDLED
    return PLUGIN_CONTINUE
}
 
stock get_next_arena()
{
    next_empty_arena = 0
    for(new id=1;id <= MAXPLAYERS;id++)
    {
        if(is_user_connected(id))
        {
            if(arena_number[id] == next_empty_arena)
            {
                next_empty_arena++

                if(next_empty_arena > total_arenas)	return -1
            }
        }
    }

    if(next_empty_arena > total_arenas)	return -1

    return next_empty_arena
}
 
stock reset_values(id)
{
    his_HS[id] = 0
    rounds[arena_number[id]] = 0
    is_in_duel[id] = 0
    his_challenger[id] = 0
    his_asker[id] = 0
    arena_number[id] = 0
    his_wins[id] = 0
    got_spawn[id] = 0
    his_timer[id] = 0
    user_can_spawn[id] = 1

	if(task_exists(id+360))	remove_task(id+360)
}
 
public freeze_player(id)	set_user_maxspeed(id,1.0)
public unfreeze_player(id)	set_user_maxspeed(id,250.0)
 
public wait_for_enemy_loop(id)
{
    if(is_user_connected(id))
    {
        if(is_in_duel[id] == 2)
        {
            if(is_user_connected(his_challenger[id]))
            {
                if(is_in_duel[his_challenger[id]] == 2)
                {
                    if(is_user_alive(his_challenger[id]))
                    {
                        begin_the_battle(id,his_challenger[id])

                        return PLUGIN_HANDLED
                    }
                    set_task(0.1,"wait_for_enemy_loop",id)
                }
            }
        }
    }
    return PLUGIN_CONTINUE
}
 
public hud_displayer(id)
{
    if(is_user_connected(id)&& is_user_connected(his_challenger[id])&&is_in_duel[id] == 2&&is_in_duel[his_challenger[id]] == 2)
    {
            new name[64],his_name[64];
            get_user_name(id,name,charsmax(name))
            get_user_name(his_challenger[id],his_name,charsmax(his_name))

            set_dhudmessage(0, 255, 0, -1.0, 0.2, 0, 6.0, 12.0,0.1,0.2)

            show_dhudmessage(id, "Arena: %s | Rounds: %d/%d ^n%s -- %d/%d (HS:%d)^nVS^n%s -- %d/%d (HS:%d)"
				,arena_names[arena_number[id]]
				,rounds[arena_number[id]]
				,MAX_ROUNDS,name,his_wins[id]
				,MAX_KILLS,his_HS[id]
				,his_name,his_wins[his_challenger[id]]
				,MAX_KILLS,his_HS[his_challenger[id]]
			)

/*
           show_dhudmessage(his_challenger[id], "Arena: %s | Rounds: %d/%d ^n%s -- %d/%d (HS:%d)^nVS^n%s -- %d/%d (HS:%d)"
				,arena_names[arena_number[id]]
				,rounds[arena_number[id]]
				,MAX_ROUNDS,his_name,his_wins[his_challenger[id]]
				,MAX_KILLS,his_HS[his_challenger[id]]
				,name,his_wins[id]
				,MAX_KILLS,his_HS[id]
			)
*/
            set_task(0.1,"hud_displayer",id+360,_,_,"b")
    }
}

stock Set_Entity_Invisible(ent, Invisible = 1)
{
    if(!pev_valid(ent))	return
    set_pev(ent, pev_effects, Invisible == 0 ? pev(ent, pev_effects) & ~EF_NODRAW : pev(ent, pev_effects) | EF_NODRAW)
}

public DuelRank(id)
{  
        static host_name[32], motd[1501], len, authid[32], szName[32], szIP[32], Rank_position;
        get_user_name(id, szName, charsmax(szName))
        get_user_authid(id, authid, 31)
        get_user_ip(id, szIP, charsmax(szIP), 1)
		get_cvar_string("hostname", host_name, 31);
   
        Rank_position = adv_vault_sort_key(fvault, Sort, 0, g_name[id])
   
    len = format(motd, 1500,"<body bgcolor=#000000><font color=#87cefa><pre>");
    len += format(motd[len], 1500-len,"<center><font color=^"blue^">----------------------------------------------</color></left>^n");
        len += format(motd[len], 1500-len,"<center><h1><font color=^"yellow^"> KNIFE DUELS </font></h3></center>");
    len += format(motd[len], 1500-len,"<center><font color=^"blue^">----------------------------------------------</color></left>^n^n");
    len += format(motd[len], 1500-len,"<center><font color=^"red^"><B>Rank :</B> <font color=^"yellow^">%d / %d</color></left>^n", Rank_position, adv_vault_sort_numresult(fvault, Sort));
    len += format(motd[len], 1500-len,"<center><font color=^"red^"><B>Kills :</B> <font color=^"yellow^"> %d</color></left>^n", g_kills[id]);
    len += format(motd[len], 1500-len,"<center><font color=^"red^"><B>Deaths :</B> <font color=^"yellow^"> %d</color></left>^n", g_deaths[id]);
    len += format(motd[len], 1500-len,"<center><font color=^"red^"><B>Head Shots :</B> <font color=^"yellow^"> %d</color></left>^n", g_headshots[id]);
        len += format(motd[len], 1500-len,"<center><font color=^"red^"><B>Winns :</B> <font color=^"yellow^"> %d</color></left>^n", g_winns[id]);
        len += format(motd[len], 1500-len,"<center><font color=^"red^"><B>Loss :</B> <font color=^"yellow^"> %d</color></left>^n", g_loss[id]);
    len += format(motd[len], 1500-len,"<center><font color=^"green^">----------------------------------</color></left>^n");
    len += format(motd[len], 1500-len,"<center><font color=^"red^"><B>Your Name :</B> <font color=^"yellow^"> %s</color></left>^n", szName);
    len += format(motd[len], 1500-len,"<center><font color=^"red^"><B>Your Steam :</B> <font color=^"yellow^"> %s</color></left>^n", authid);
    len += format(motd[len], 1500-len,"<center><font color=^"red^"><B>Your Ip :</B> <font color=^"yellow^"> %s</color></left>^n", szIP);
    len += format(motd[len], 1500-len,"<center><font color=^"green^">----------------------------------</color></left>^n^n");
    len += format(motd[len], 1500-len,"<center><h2><font color=^"red^"> Welcome to : '%s' </font></h3></center>", host_name);
 
    show_motd(id, motd, "Knife Duels Rank");
   
    return 0;
}

public GameDesc( ) {
    static gamename[32];
    get_pcvar_string( cvar_gamename, gamename, 31 );

    forward_return( FMV_STRING, gamename );

    return FMRES_SUPERCEDE;
}

public duel_status(id)
{
    new name[32],pid = read_data(2)
    get_user_name(pid,name,31)

    new idAiming, iBodyPart
    get_user_aiming(id, idAiming, iBodyPart)
   
    if(is_user_alive(idAiming) && is_user_alive(id) && get_pcvar_num(cvar_teaminfo))
    {
        if(cs_get_user_team(id) == CS_TEAM_CT && cs_get_user_team(idAiming) == CS_TEAM_CT)
        {
            set_hudmessage(238,201,0,-1.0,0.70,1, 0.01, 3.0, 0.01, 0.01, -1)
            show_hudmessage(id, "%s ^n [ Kills: %d - Deaths %d ] ^n [ Winns: %d - Loss: %d ]", name,g_kills[pid],g_deaths[pid],g_winns[pid],g_loss[pid])
        }
        else if(cs_get_user_team(id) == CS_TEAM_T && cs_get_user_team(idAiming) == CS_TEAM_T)
        {
            set_hudmessage(238,201,0,-1.0,0.70,1, 0.01, 3.0, 0.01, 0.01, -1)
            show_hudmessage(id, "%s ^n [ Kills: %d - Deaths %d ] ^n [ Winns: %d - Loss: %d ]", name,g_kills[pid],g_deaths[pid],g_winns[pid],g_loss[pid])
        }
    }
}

public duel_statusx(id)
{
    new name[32],pid = read_data(2)
    get_user_name(pid,name,31)

    new idAiming, iBodyPart
    get_user_aiming(id, idAiming, iBodyPart)
   
    if(is_user_alive(idAiming) && is_user_alive(id) && get_pcvar_num(cvar_allinfo))
    {
        if(cs_get_user_team(id) == CS_TEAM_T && cs_get_user_team(idAiming) == CS_TEAM_CT)
        {
            set_hudmessage(238,201,0,-1.0,0.70,1, 0.01, 3.0, 0.01, 0.01, -1)
            show_hudmessage(id, "%s ^n [ Kills: %d - Deaths %d ] ^n [ Winns: %d - Loss: %d ]", name,g_kills[pid],g_deaths[pid],g_winns[pid],g_loss[pid])
        }
        else if(cs_get_user_team(id) == CS_TEAM_CT && cs_get_user_team(idAiming) == CS_TEAM_T)
        {
            set_hudmessage(238,201,0,-1.0,0.70,1, 0.01, 3.0, 0.01, 0.01, -1)
            show_hudmessage(id, "%s ^n [ Kills: %d - Deaths %d ] ^n [ Winns: %d - Loss: %d ]", name,g_kills[pid],g_deaths[pid],g_winns[pid],g_loss[pid])
        }
 
    }
}

public duel_showhud(id)
{
    if (is_user_connected(id) && is_user_alive(id) ,get_pcvar_num(cvar_yourinfo) )
    {
    set_hudmessage(238,201,0,-1.0,0.88,1, 0.01, 3.0, 0.01, 0.01, -1)
    ShowSyncHudMsg( id, HuDForEver,"[ Winns: %d - Loss: %d ]",g_winns[id], g_loss[id]);
   }
}

public client_authorized(Index)
{
    get_user_name(Index, g_name[Index], charsmax(g_name[]))
    g_winns[Index] = 0
        g_loss[Index] = 0
        g_kills[Index] = 0
        g_deaths[Index] = 0
        g_headshots[Index] = 0
    Vault(Index, 2)
}

public Menu_TOP(Index)
{
 
        new len
    static Kills, Nick[32], Keyindex //, Opciones[200], Posicion[6]
    //static Menu;Menu = menu_create("\wKNIFE DUELS TOP", "menu_top")
   
    new Toploop = (adv_vault_sort_numresult(fvault, Sort), 15)
 
                motd[0] = 0
 
        add(motd, charsmax(motd),
        "<html><style>\
        body{background:#040404;font-family:Verdana, Arial, Sans-Serif;font-size:7pt;}\
        .t{color:#808080;text-align:left; }\
        #h{background: #222 url('http://limmudny.org/wp-content/uploads/2014/09/PageTitleBackground2-900x100.jpg') repeat-x;color:#000;font-weight:bold;}\
        #p{color:#D41313;}\
        #n{color:#fff;}\
        </style><body>\
        <table cellspacing=0 width=100% class=t>")
 
        add(motd, charsmax(motd),
        "<tr><td id=h width=7%>Nr:</td>\
        <td id=h>Nick</td>\
        <td id=h>Winns</td></tr>")
       
        len = strlen(motd)
 
    for(new Position=1; Position <= Toploop; Position++)
    {
        Keyindex = adv_vault_sort_position(fvault, Sort, Position)
       
        if(!adv_vault_get_prepare(fvault, Keyindex)) continue
       
        Kills = adv_vault_get_field(fvault, RANKS[WINNS])
        adv_vault_get_field(fvault, RANKS[NICK], Nick, charsmax(Nick))
 
        len += formatex(motd[len], charsmax(motd)-len,"<tr><td id=p>%d:</td>\<td id=n>%s</td>\<td>%d</td>", Position, Nick, Kills)
 
        //formatex(Opciones, charsmax(Opciones), "\y%d\d. \w%s  \yWinns \r%d \yDeaths \r%d", Position, Nick, Kills)
        //num_to_str(Position, Posicion, charsmax(Posicion))
        //menu_additem(Menu, Opciones, Posicion)
 
    }
   
    //menu_setprop(Menu, MPROP_NEXTNAME, "Next")
    //menu_setprop(Menu, MPROP_BACKNAME, "Back")
    //menu_setprop(Menu, MPROP_EXITNAME, "Exit")
    //menu_display(Index, Menu, 0)
    add(motd, charsmax(motd), "</table></body></html>")
    show_motd(Index, motd, "Knife Duels Top")
 
}
 
public menu_top(Index, Menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(Menu)
        return PLUGIN_HANDLED
    }
   
    Menu_TOP(Index)
    return PLUGIN_HANDLED
}

public Vault(Index, Guardar_Cargar)
{
    static Nick[32]; get_user_name(Index, Nick, charsmax(Nick))
    if(Guardar_Cargar == 1)
    {
        adv_vault_set_start(fvault)
        adv_vault_set_field(fvault, RANKS[WINNS], g_winns[Index])
        adv_vault_set_field(fvault, RANKS[LOSS], g_loss[Index])
        adv_vault_set_field(fvault, RANKS[KILLS], g_kills[Index])
        adv_vault_set_field(fvault, RANKS[DEATHS], g_deaths[Index])
        adv_vault_set_field(fvault, RANKS[HEADSHOTS], g_headshots[Index])
        adv_vault_set_field(fvault, RANKS[NICK], Nick)
        adv_vault_set_end(fvault, 0, g_name[Index])
    }
    else if(Guardar_Cargar == 2)
    {
        if(!adv_vault_get_prepare(fvault, 0, g_name[Index]))	return
       
        g_winns[Index] = adv_vault_get_field(fvault, RANKS[WINNS])
        g_loss[Index] = adv_vault_get_field(fvault, RANKS[LOSS])
        g_kills[Index] = adv_vault_get_field(fvault, RANKS[KILLS])
        g_deaths[Index] = adv_vault_get_field(fvault, RANKS[DEATHS])
        g_headshots[Index] = adv_vault_get_field(fvault, RANKS[HEADSHOTS])
        adv_vault_get_field(fvault, RANKS[NICK], Nick, charsmax(Nick))
    }
}
 
 
public Duels_Reset(plr, level, cid) {
    if(!cmd_access(plr,level,cid,0)) {
        return PLUGIN_HANDLED;
    }
   
    new name[32];
    get_user_name(plr, name, 31);
   
    static DeleteTop[128], len;
 
    adv_vault_closed(fvault);
 
    if (!len)
    {
        get_localinfo("amxx_datadir", DeleteTop, charsmax(DeleteTop))
        add(DeleteTop, charsmax(DeleteTop), "/adv_vault/DuelsTop/");
        len = strlen(DeleteTop);
    }
 
    formatex(DeleteTop[len], charsmax(DeleteTop)-len, "data.dat");
    if( file_exists(DeleteTop))
        delete_file(DeleteTop);
 
    formatex(DeleteTop[len], charsmax(DeleteTop)-len, "simple.dat");
    if( file_exists(DeleteTop))
        delete_file(DeleteTop);
 
    formatex(DeleteTop[len], charsmax(DeleteTop)-len, "index.dat");
    if( file_exists(DeleteTop))
        delete_file(DeleteTop);
 
    formatex(DeleteTop[len], charsmax(DeleteTop)-len, "fields.dat");
    if( file_exists(DeleteTop))
        delete_file(DeleteTop);
 
    new i = 0;
    formatex(DeleteTop[len], charsmax(DeleteTop)-len, "sort_%d.dat", i);
    while (file_exists(DeleteTop))
    {
        delete_file(DeleteTop);
        formatex(DeleteTop[len], charsmax(DeleteTop)-len, "sort_%d.dat", ++i);
    }
    return PLUGIN_HANDLED;
}
 
player_rule( id )
{
    static len; len = 0
    len += formatex(g_motd[len], charsmax(g_motd) - len,"<body bgcolor=#000000><font color=#87cefa><pre>");    
    len += formatex(g_motd[len], charsmax(g_motd) - len, "<font color=^"red^">1.<font color=^"yellow^">[Duel]<font color=^"green^"> ---- This command challenge any player to Play 1v1 in the arena<br>")
    len += formatex(g_motd[len], charsmax(g_motd) - len, "<font color=^"red^">2.<font color=^"yellow^">[Rank]<font color=^"green^"> ---- This command can be show, your Statistics<br>")
    len += formatex(g_motd[len], charsmax(g_motd) - len, "<font color=^"red^">3.<font color=^"yellow^">[Top]<font color=^"green^"> ----- This Command can be show all the players Position and Statistics<br>")
    len += formatex(g_motd[len], charsmax(g_motd) - len, "<font color=^"red^">4.<font color=^"yellow^">[OFFLINE]<font color=^"green^"> -- This command connected you and disconected from Duel list<br>")
    len += formatex(g_motd[len], charsmax(g_motd) - len, "<font color=^"red^">5.<font color=^"yellow^">[Give Up]<font color=^"green^"> -- This Command finish the current duel battle<br>")
 
    show_motd( id, g_motd, "Duel Info" )
}
 
 
public ChooseState(id)
{
    formatex(TitleMenu, charsmax(TitleMenu), "%L", id, "BOOST_MENU")
    new meni = menu_create(TitleMenu, "ChooseStateMenu");
    for(new i=0;i<sizeof COUNTRY;i++)
        menu_additem(meni, COUNTRY[i]);
    menu_display(id, meni);
}
 
public ChooseStateMenu(id, meni, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(meni);
        return PLUGIN_CONTINUE;
    }
   
    HowToBoost(id, item);
    return PLUGIN_CONTINUE
}
 
public HowToBoost(id, item)
{
    static motd[2001], Linija, IpServera[32];
    get_user_ip(0, IpServera, charsmax(IpServera));
    get_user_name(id, Nick, 31);
    Linija = format(motd, 2000,"<!DOCTYPE html><html><head><title>- Global Knife Gaming -</title></head><body bgcolor='#FFFFFF'>")
    Linija += format(motd[Linija], 2000-Linija,"<font style='font-family:Arial, Helwetica, Sans-Serif;font-weight:Bold;font-size:15px;'>");
    Linija += format(motd[Linija], 2000-Linija,"<span style='color:black'>%L:</span><span style='color:#3399ff'> %s</span><br />", id, "BOOST_COUNTRY", COUNTRY[item]);
    Linija += format(motd[Linija], 2000-Linija,"<span style='color:black'>%L:</span><span style='color:#3399ff'> %s</span><br />", id, "BOOST_SMS", NUMBERS[item]);
    Linija += format(motd[Linija], 2000-Linija,"<span style='color:black'>%L:</span><br />", id, "BOOST_SMS_FORMAT");
    Linija += format(motd[Linija], 2000-Linija,"<span style='color:red'>%L</span><br />", id, "BOOST_TEXT_FOR_SENDING", CONTENTS[item], IpServera, Nick);
    Linija += format(motd[Linija], 2000-Linija,"<span style='color:black'>%L:</span><br /><span style='color:#3399ff'> %s</span><br />", id, "BOOST_PRICE_SMS", PRICE_SMS[item]);
    Linija += format(motd[Linija], 2000-Linija,"<span style='color:green'>%L</span><br />", id, "BOOST_FORUM_INFO");
    Linija += format(motd[Linija], 2000-Linija,"</font></body></html>")
    show_motd(id, motd, "[Global Knife] Boost Manager")
    return 0
}
 
public Advertisment() ColorChat(0, GREEN, "^3[^4Boost Manager^3]^1 %L", LANG_PLAYER, "BOOST_ADVERTISMENT"), set_task(get_pcvar_float(AdvTime), "Advertisment");

stock client_print_color(const id, const input[], any:...)
{
    new count = 1, players[32];

    static msg[191];
    vformat(msg, 190, input, 3);
    replace_all(msg, 190, "!g", "^x04"); // Green Color  
    replace_all(msg, 190, "!y", "^x01"); // Default Color  
    replace_all(msg, 190, "!t", "^x03"); // Team Color

    if (id) players[0] = id; else get_players(players, count, "ch");
    {
        for (new i = 0; i < count; i++)
        {
            if (is_user_connected(players[i]))
            {
                message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
                write_byte(players[i]);
                write_string(msg);
                message_end();
            }
        }
    }
}
