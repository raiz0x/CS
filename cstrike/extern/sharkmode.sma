/**
 * SHARKMOD
 * Version 0.3
 * By: Edgar De Loa
 * 
 * DESCRIPTION:
 * After enabling this plugin, all but one randomely chosen player will be moved to
 * the CT team. All players are locked to their team. The lone terrorist(the "shark")
 * will have increased speed, noclip, increased HP, but not be able to use anything
 * other than a knife.
 * 
 * The shark's objective is to kill the CTs.  If a CT manages to kill the shark,
 * that player will become the new shark next round.  If the shark manages to stay
 * alive for several consequtive rounds (admin-configurable), a new shark will be
 * randomely chosen.
 * 
 * An admin may also manually select the next shark through a menu.
 * 
 * 
 * REQUIREMENTS:
 * AMXX 1.70+
 * Fun module
 * Fakemeta module
 * 
 * CVARS:
 * sharkmod_maxhealth <#>
 *      The shark's initial health. (default: 255)
 * sharkmod_speed <#>
 *      Speed at which the shark travels (default: 640)
 *      Note: normal knife speed is 320, and is capped at 1000
 * sharkmod_maxrounds <#>
 *      Max number of consecutive rounds a player can be the shark (default: 3)
 * sharkmod_timer <#>
 *      Time after enabling that sharkmod begins (default: 10)
 * sharkmod_custommodel <0/1>
 *      1 to use your custom model, 0 otherwise (default: 0)
 * 
 * COMMANDS:
 * amx_shark <0/1>
 *      1 to enable sharkmod, 0 to disable
 * amx_sharkmenu
 *      Manually select the shark for the next round
 * 
 * CUSTOM MODELS:
 * The shark model should be: "models/player/shark/shark.mdl"
 * 
 * TO DO / IDEAS:
 * Make it work with other games
 * Emit shark sounds from shark when +use button is pressed.
 * Add more options to menu.
 * Allow multiple sharks.
 * Leave spectators out of the game.
 * Health changes according to number of opponents
 * Make shark's attacks stronger
 * 
 * NOTES:
 * Many of the things on the TO DO list are already in the works.
 * I figured I'd release what I have now so those that requested this mod
 * could have a working plugin immediately.
 */
 
#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
 
#pragma tabsize 0
 
#define PLUGIN  "SharkMod"
#define VERSION "0.3"
#define AUTHOR  "Edgar De Loa"
 
#define MENU_SIZE    256
#define MENU_PLAYERS 8
#define MIN_PL       2
#define TASKID       1997
 
#define SHARK_MODEL "shark"
#define SHARK_MODEL_DIR "models/player/shark/shark.mdl"
#define SHARK_SOUND "misc/shark.wav"
 
#define ADMIN_REQ ADMIN_RCON
 
new g_iMenuPosition
new g_iMenuPlayers[32]
 
new g_maxRounds
new g_timer
new g_speed
new g_grav
new g_maxhealth
new g_custommodel
new Float:SV_GRAV
new timer
 
new g_enabled = 0
new g_roundsPlayed = 0
new g_currentShark = 0
new g_nextShark = 0
new blockteams
 
public plugin_init(){
  register_plugin(PLUGIN, VERSION, AUTHOR)  
  
  register_clcmd("amx_sharkmenu", "ShowMenu", ADMIN_REQ, "- Select next shark")
  register_menucmd( register_menuid("\rPlayer Menu:"), 1023, "MenuAction" )
  
  register_clcmd("jointeam", "join_team")
  register_menucmd(register_menuid("Team_Select",1), (1<<0)|(1<<1)|(1<<4)|(1<<5), "team_select")
  
  //register_event("HLTV", "event_newRound", "a", "1=0", "2=0")
  register_logevent("event_newRound", 2, "1=Round_Start") 
  register_event("DeathMsg", "event_deathMsg", "a", "1>0")
  register_event("CurWeapon","event_curWeapon", "be", "1=1")
  register_forward(FM_Touch,"on_touch")
  //register_forward(FM_CmdStart, "event_cmdStart")
  register_event( "TextMsg", "RR", "a", "2=#Game_Commencing", "2=#Game_will_restart_in" )
  
  g_maxRounds = register_cvar("sharkmod_maxrounds", "3")
  g_speed = register_cvar("sharkmod_speed", "640.0")
  g_grav = register_cvar("sharkmod_grav", "500.0")
  g_timer = register_cvar("sharkmod_timer", "10")
  g_maxhealth = register_cvar("sharkmod_maxhealth", "255")
  
  //blockteams = g_enabled ? PLUGIN_HANDLED : PLUGIN_CONTINUE
 
  register_clcmd("say /a","A")
}
public A(id){
	client_print(id,print_chat,"%sESTI%s SHARK",g_currentShark==id?"":"NU ",g_nextShark==id?" NEXT":"")
	client_print(id,print_chat,"TIMER = %d",get_cvar_num(g_timer))
}
public plugin_cfg(){
    SV_GRAV=get_cvar_float("sv_gravity")
    timer=get_pcvar_num(g_timer)
}
public plugin_precache(){
  g_custommodel = register_cvar("sharkmod_custommodel", "0")
  if (get_pcvar_num(g_custommodel)) precache_model(SHARK_MODEL_DIR)
  
  //precache_sound(SHARK_SOUND)
}
public RR(){
  g_enabled = g_currentShark = g_nextShark = g_roundsPlayed = 0
 
  setServerSettings(0)
  unlockTeams()
 
  remove_task(TASKID)
}
public client_putinserver(id) if(!(is_user_bot(id)||is_user_hltv(id))&&get_playersnum()>=MIN_PL&&!g_enabled) startSharkMod()
public client_disconnect(id) if(get_playersnum()<MIN_PL) stopSharkMod()
public startSharkMod(){
  g_enabled = 1
  setServerSettings(1)
  lockTeams()
  
  //server_cmd("sv_restartround %f", get_pcvar_float(g_timer))
  //client_print(0, print_chat, "[SharkMod] SharkMod will start in %1.f second%s.", get_pcvar_float(g_timer), get_pcvar_float(g_timer)==1?"":"s")
 
  if(!task_exists(TASKID)||g_nextShark!=0||g_currentShark!=0) set_task(1.0, "Countdown", TASKID, _, _, "a", timer)
}
stock setServerSettings(const value=1){
  clamp(value,0,1)
  switch(value){
    case 1:{
        server_cmd("mp_limitteams 0")
        server_cmd("mp_autoteambalance 0")
        server_cmd("sv_maxspeed 1000")
    }
    case 0:{
        server_cmd("mp_limitteams 32")
        server_cmd("mp_autoteambalance 1")
        //server_cmd("sv_maxspeed 1000")
    }
  }
}
public lockTeams() blockteams = PLUGIN_HANDLED
public Countdown(){
    if(timer==1) createNewShark()
    else if (timer < 1) {//+ || , xdd
        set_hudmessage(0, 255, 0, 0.49, 0.11, 0, 1.0, 1.0, 0.1, 1.0, 2)
        show_hudmessage(0, "Time is up!")
        //timer=-1
        remove_task(TASKID)
        return
    }
 
    set_hudmessage(0, 255, 0, 0.49, 0.11, 0, 1.0, 1.0, 0.1, 1.0, 1)
    show_hudmessage(0, "%s%d Second%s until The Chosen will come", timer<9?"0":"", timer,timer==1?"":"s")

    timer--
}
 
public event_newRound(){
    timer=get_pcvar_num(g_timer)
    if((g_enabled||get_playersnum()>=MIN_PL)&&!task_exists(TASKID)){
	g_roundsPlayed++
        client_print(0, print_chat, "[SharkMod] Starting round %i/%i!", g_roundsPlayed, get_pcvar_num(g_maxRounds))
        if ((g_roundsPlayed == get_pcvar_num(g_maxRounds) || g_nextShark != 0|| !is_user_connected(g_currentShark) || get_user_team(g_currentShark) != 1 || g_currentShark == 0)) createNewShark()
    }
}
public createNewShark(){
  if (g_currentShark) cs_reset_user_model(g_currentShark)
 
  new players[32], num;get_players(players, num)
  for (new i = 0; i < num; i++){
    if(g_nextShark&&players[i]!=g_nextShark/*||g_currentShark&&players[i]!=g_currentShark&&(get_user_team(players[i])==1||get_user_team(players[i])==2)*/) cs_set_user_team(players[i], CS_TEAM_CT)
    else cs_set_user_team(players[i], CS_TEAM_CT)
  }
 
  if (g_nextShark == 0) g_nextShark = getRandPlayer()
 
  g_currentShark = g_nextShark;
 
  g_nextShark = g_roundsPlayed = 0
  
  if(get_user_team(g_currentShark)!=1){
    cs_set_user_team(g_currentShark, CS_TEAM_T)
    //ExecuteHamB(Ham_CS_RoundRespawn,g_currentShark)
  }
  if (g_custommodel) cs_set_user_model(g_currentShark, SHARK_MODEL)
  set_user_health(g_currentShark, get_pcvar_num(g_maxhealth))
  //set_user_noclip(g_currentShark, 1)
  set_user_maxspeed(g_currentShark, get_pcvar_float(g_speed))
  set_user_gravity(g_currentShark, get_pcvar_float(g_grav)/SV_GRAV)
  set_task(0.5, "event_curWeapon", g_currentShark)
  
  client_print(0, print_chat, "[SharkMod] The new Shark is: %s!", get_user_name_ex(g_currentShark))
}
public client_PreThink(id){
	if(is_user_alive(id)&&g_currentShark==id){
		set_user_maxspeed(g_currentShark, get_pcvar_float(g_speed))
		set_user_gravity(g_currentShark, get_pcvar_float(g_grav)/SV_GRAV)
	}
}
 
public stopSharkMod(){  
  if (g_currentShark&&is_user_connected(g_currentShark)) {
    cs_reset_user_model(g_currentShark)
    //set_user_noclip(g_currentShark)
    set_user_maxspeed(g_currentShark)
    set_user_gravity(g_currentShark)
  }

  g_enabled = g_currentShark = g_nextShark = g_roundsPlayed = 0
 
  setServerSettings(0)
  unlockTeams()
 
  remove_task(TASKID)
  
  client_print(0, print_chat, "[SharkMod] SharkMod is now off.")
}
public unlockTeams() blockteams = PLUGIN_CONTINUE
 
/*
public checkForValidPlayers(id)
{
  
  new players[32], num
  get_players(players, num)
  
  for(new i = 0; i < num; i++) {
    new csTeams:szTeam = cs_get_user_team(players[i])
    
    if (szTeam == CS_TEAM_CT || sz == CS_TEAM_T) {
      g_players++;
    }
  }
  
  
  if (get_playersnum() > 1) {
    client_print(id, print_chat, "[SharkMod] %i seconds until SharkMod begins!", g_timer)
    setServerSettings()
    return 1;
  }
  else {
    client_print(id, print_chat, "[SharkMod] Not enough players to start SharkMod.")
    return 0;
  }
}
*/
 
public ShowMenu(id, lvl, cid){
  if(cmd_access(id, lvl, cid, 0)) ShowPlayerMenu(id, g_iMenuPosition = 0)
  return PLUGIN_HANDLED
}
public ShowPlayerMenu(id, pos){
  if(pos < 0) return
 
  new i, j,szMenuBody[MENU_SIZE],iCurrKey = 0,szUserName[33],iStart = pos * MENU_PLAYERS,iNum,iEnd,iLen,iKeys
 
  get_players( g_iMenuPlayers, iNum )
 
  if( iStart >= iNum ) iStart = pos = g_iMenuPosition = 0
 
  iLen = format( szMenuBody, MENU_SIZE-1, "\rPlayer Menu:\R%d/%d^n\w^n", pos+1, (iNum / MENU_PLAYERS + ((iNum % MENU_PLAYERS) ? 1 : 0 )) )
  iEnd = iStart + MENU_PLAYERS
  iKeys = (1<<9|1<<7)
 
  if( iEnd > iNum ) iEnd = iNum
 
  for( i = iStart; i < iEnd; i++){
    j = g_iMenuPlayers[i]
    get_user_name( j, szUserName, charsmax(szUserName))
    if( (get_user_flags(j) & ADMIN_IMMUNITY) || !is_user_alive(j) ){
      iCurrKey++
      iLen += format( szMenuBody[iLen], (MENU_SIZE-1-iLen), "\d%d. %s^n\w", iCurrKey, szUserName )
    }else{
      iKeys |= (1<<iCurrKey++)
      iLen += format( szMenuBody[iLen], (MENU_SIZE-1-iLen), "%d. %s^n", iCurrKey, szUserName )
    }
  }
 
  if( iEnd != iNum ) {
    format( szMenuBody[iLen], (MENU_SIZE-1-iLen), "^n9. More...^n0. %s", pos ? "Back" : "Exit" )
    iKeys |= (1<<8)
  }else {
    format( szMenuBody[iLen], (MENU_SIZE-1-iLen), "^n0. %s", pos ? "Back" : "Exit" )
  }
 
  show_menu( id, iKeys, szMenuBody, -1 )
  return
}
public MenuAction(id, key){
  switch(key){
    case 8: ShowPlayerMenu( id, ++g_iMenuPosition )
    case 9: ShowPlayerMenu( id, --g_iMenuPosition )
    default:{
      new iPlayerID = g_iMenuPlayers[g_iMenuPosition * MENU_PLAYERS + key]
      client_print(0, print_chat, "[SharkMod] %s has been chosen to become the next Shark!", get_user_name_ex(iPlayerID))
      g_nextShark = iPlayerID;
    }
  }
  return PLUGIN_HANDLED
}
 
public event_deathMsg(){
  if (g_enabled) {
    new killer = read_data(1)
    new victim = read_data(2)
    
    if (victim == g_currentShark && killer != victim && killer <= 32) {
      g_currentShark=0
      g_nextShark = killer;
      client_print(0, print_chat, "[SharkMod] %s got the killing blow! The next Shark will be: %s!", get_user_name_ex(victim), get_user_name_ex(killer))
    }
  }
}
 
public event_curWeapon(id){
  if (g_enabled && id == g_currentShark) {
    new weapons[32], num;get_user_weapons(g_currentShark, weapons, num)
    if (num > 1) {
      strip_user_weapons(g_currentShark)
      give_item(g_currentShark, "weapon_knife")
    }
    set_user_maxspeed(g_currentShark, get_pcvar_float(g_speed))
    set_user_gravity(g_currentShark, get_pcvar_float(g_grav)/SV_GRAV)
  }
}
 
public on_touch(ent, id){
  if (id == g_currentShark) {
    if (!pev_valid(ent)) return FMRES_IGNORED
    static classname[35];pev(ent,pev_classname,classname,charsmax(classname))
    if ( (!equal(classname,"weapon",6)) && (!equal(classname,"armoury",7)) ) return FMRES_IGNORED
    return FMRES_SUPERCEDE
  }
  return FMRES_IGNORED
}
 
/*
public event_cmdStart(const id, const uc_handle, random_seed){
  if (id == g_currentShark) if ((pev(id, pev_button) & IN_JUMP) && !(pev(id, pev_oldbuttons) & IN_JUMP)) emit_sound(g_currentShark, CHAN_AUTO, SHARK_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
  return FMRES_IGNORED
}
*/
 
 
public team_select(id, key){
  if ( (key == 0 || key == 4) && blockteams == PLUGIN_HANDLED ) {
    engclient_cmd(id,"chooseteam")
    return PLUGIN_HANDLED
  }
  return PLUGIN_CONTINUE
}
public join_team(id){
  new arg[2],key;read_argv(1, arg, 1)
  key = str_to_num(arg)-1
  if ( (key == 0 || key == 4) && blockteams == PLUGIN_HANDLED ) {
    engclient_cmd(id,"chooseteam")
    return PLUGIN_HANDLED
  }
  return PLUGIN_CONTINUE
}
 
stock getRandPlayer(){
    new players[ 32 ], player, num, pList[ 33 ], count;
    get_players( players, num );
    for( new i ; i < num ; i ++ ){
        player = players[ i ];
        if( get_user_team( player ) == 1 || get_user_team( player ) == 2 ){
            pList[ count ] = player;
            count ++;
        }
    }
    return pList[ random( count ) ];
} 
stock get_user_name_ex(const id){
    new szName[33];get_user_name(id, szName, charsmax(szName));
    return szName;
}
