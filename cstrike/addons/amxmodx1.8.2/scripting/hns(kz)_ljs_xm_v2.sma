#include <amxmodx>
#include <amxmisc>
#include <colorchat>
#include <fakemeta>
#include <engine>
#include <fakemeta_util>

#pragma semicolon 1

#define COMMAND_PROTECTION
#define JOKES

#define INFO_ONE 1
#define INFO_ZERO 0
#define NSTRAFES 14
#define NTOP 23
#define NSHOW 10
#define MAPSHOW 4 // show first 3

//enums
#define TYPE_NONE 0
#define TYPE_LJ 1
#define TYPE_CJ 2
#define TYPE_BJ 3
#define TYPE_HJ 4
#define TYPE_FEJ 5 //fireEscape jump
#define TYPE_LaJ 5 //ladder jump
#define TYPE_SBJ 6 //stand-up bhop
#define TYPE_WJ 7  //weird jump
#define TYPE_LCHJ 10 //Lj && Cj && Hj
#define TYPE_SBBJ 20 //Bj && SBJ

#define DIST_LEET 1
#define DIST_PRO 2
#define DIST_GOOD 3
#define DIST_GOD 4

#define TOP_MAP 0
#define TOP_LJ  1
#define TOP_CJ  2
#define TOP_BJ  3
#define TOP_SBJ 4
#define TOP_HJ  5
#define TOP_FEJ 6
#define TOP_LaJ 6
#define TOP_WJ 7

//Iterator
new jj;

//For PreThink
new Float:weapSpeed[33];
new Float:weapSpeedOld[33];
new strLen;
new strMess[40*NSTRAFES];
new strMessBuf[40*NSTRAFES];
new goodSyncTemp;
new badSyncTemp;
new Float:time_;
new Float:maxPreSpeedWeapon;
new Float:maxBhopPreSpeedWeap;
new Float:Fulltime;
new ljStatsRed;
new ljStatsGreen;
new ljStatsBlue;
new ljs_beam;
new sync_;


// Ints & strings
new server_settings[34][27][16];
new plugin_id;
new plugin_file_name[64];
new pluginstatus;
new gBeam;
new jumptype[33];
//new vJumpedAtEnt[33];
new strafes[33];
new ljsDir[64];
new pre_type[33][32];

new top_names[NTOP][129];
//new top_authid[NTOP][33];
new top_distance[NTOP];
new top_maxspeed[NTOP];
new top_prestrafe[NTOP];
new top_strafes[NTOP];
new top_sync[NTOP];
new top_type[NTOP][5];
new top_pretype[NTOP][32];

new map_names[NSHOW][129];
new map_authid[NSHOW][33];
new map_distance[NSHOW];
new map_maxspeed[NSHOW];
new map_prestrafe[NSHOW];
new map_strafes[NSHOW];
new map_sync[NSHOW];
new map_type[NSHOW][5];
new map_pretype[NSHOW][32];

new cj_names[NTOP][129];
new cj_authid[NTOP][33];
new cj_distance[NTOP];
new cj_maxspeed[NTOP];
new cj_prestrafe[NTOP];
new cj_strafes[NTOP];
new cj_sync[NTOP];
new cj_pretype[NTOP][32];

new bj_names[NTOP][129];
new bj_authid[NTOP][33];
new bj_distance[NTOP];
new bj_maxspeed[NTOP];
new bj_prestrafe[NTOP];
new bj_strafes[NTOP];
new bj_sync[NTOP];
new bj_pretype[NTOP][32];

new sbj_names[NTOP][129];
new sbj_authid[NTOP][33];
new sbj_distance[NTOP];
new sbj_maxspeed[NTOP];
new sbj_prestrafe[NTOP];
new sbj_strafes[NTOP];
new sbj_sync[NTOP];
new sbj_pretype[NTOP][32];

new wj_names[NTOP][129];
new wj_authid[NTOP][33];
new wj_distance[NTOP];
new wj_maxspeed[NTOP];
new wj_prestrafe[NTOP];
new wj_strafes[NTOP];
new wj_sync[NTOP];
new wj_pretype[NTOP][32];

new lj_names[NTOP][129];
new lj_authid[NTOP][33];
new lj_distance[NTOP];
new lj_maxspeed[NTOP];
new lj_prestrafe[NTOP];
new lj_strafes[NTOP];
new lj_sync[NTOP];
new lj_pretype[NTOP][32];

new view_names[33][NSHOW][129];
new view_distance[33][NSHOW];
new view_maxspeed[33][NSHOW];
new view_prestrafe[33][NSHOW];
new view_strafes[33][NSHOW];
new view_sync[33][NSHOW];
new view_type[33][NSHOW][5];
new view_pretype[33][NSHOW][32];
new full_top_stats_selected_type[33];
new full_top_stats_selected_page[33];
new strafe_stat_sync[33][NSTRAFES][2]; // 0=good 1=bad
new buttons;
new strafecounter_oldbuttons[33];

// Bools
new bool:bljhelp[33];
new bool:StrafeStat[33];
new bool:fallDown[33];
new bool:possible_lj_script[33][2];
new bool:tops_save;
new bool:gHasColorChat[33];
new bool:gHasSpeed[33];
new bool:gHasLjStats[33];
new bool:testBhop[33];
new bool:gInAir[33];
new bool:isBhop[33];
new bool:cjumped[33];
new bool:doubleducked[33];
new bool:cducked[33];
new bool:induck[33];
new bool:OnGround[33];
new bool:turning_right[33];
new bool:turning_left[33];
new bool:strafing_aw[33];
new bool:strafing_sd[33];
new bool:bljbeam[33];

// Floats
new Float:fMaxGroundBhopSpeed[33];
new Float:ljhel[33][3];
new Float:strafe_stat_time[33][NSTRAFES]; //[id][#of strafes for stat][goodStat/Badstat]  (of speed)
new Float:strafe_stat_speed[33][NSTRAFES][2]; //[id][#of strafes for stat][goodStat/Badstat]  (of speed)
new Float:TempSpeed[33]; 
new Float:vBeamPos[33][129][3];
new Float:vBeamPosStatus[33][129];
new Float:vBeamTime[33][129];
new Float:vBeamLastTime[33];
new Float:old_angle1[33];
new Float:angle[3];
new Float:vFramePos[33][2][3];
new Float:vFrameSpeed[33][2][3];
new Float:vDuckedAt[33][3];
new Float:vFallAt[33][3];
new Float:vJumpedAt[33][3];
new Float:vJumpedAt2[3];
new Float:xDistance;
new Float:yDistance;
new Float:fDistance;
new Float:fDistance1;
new Float:fDistance2;
new Float:rDistance[3];
new Float:rLandPos[3];
new Float:vOrigin[3];
new Float:vLastFrameOrigin[33][3];
//new Float:vLastFrameVelocity[33][3];
new Float:vOldOrigin[33][3];
//new Float:vOldOrigin2[33];
new Float:vTraceEnd[3];
new Float:fMaxAirSpeed[33];
new Float:fMaxGroundSpeed[33];
new Float:fCjPreSpeed[33];
new Float:vVelocity[3];
//new Float:realDist[33];
new Float:fSpeed;
new Float:gSpeed;
//new Float:OldOldSpeed[33];
//new Float:OldSpeed[33];
new Float:frame2time;
new Float:jumptime[33];
new Float:lasttime[33];
new Float:beam_jump_off_time[33];

// Plugin strings
new const gPLUGIN[] = "LjS - eXtreme Mod";
new const gVERSION[] = "2.2b7 Lt.RAT`s & .tv!X^^ edition v4 bl";
new const gVERSION_NUM[] = "22007";
new const gAUTHOR[] = "Lt.RAT & .tv!X^^ ";

// Cvars
new kz_ljs_enabled;
//new kz_good_lj;
//new kz_pro_lj;
//new kz_leet_lj;
new kz_min_lj;
new kz_min_lj_c;
new kz_max_lj;
new kz_cj_dif;
new kz_lj_sounds;
new kz_leet_lj_clr;
new kz_pro_lj_clr;
new kz_good_lj_clr;
new kz_leet_cj_clr;
new kz_pro_cj_clr;
new kz_good_cj_clr;
new kz_ljstats_red;
new kz_ljstats_green;
new kz_ljstats_blue;
new kz_ljs_beam;
new kz_legal_settings;
new kz_ljs_fastserver;
//new kz_ljs_autoserver;
new kz_ljs_speedtype;
new kz_ljs_connectenabler;
new kz_ljs_viscmds;
new kz_ljs_tops;
new kz_ljs_topsave;
new kz_ljs_rank_by;
new kz_ljs_maptop;
new kz_min_bhop;
new kz_min_bhop_c;
new edgefriction;
new mp_footsteps;
new sv_cheats;
new sv_gravity;
new sv_maxspeed;
new sv_stepsize;
new sv_maxvelocity;

//new sv_lan;

public plugin_init()
{
	if( tops_save )
		read_tops();
	
	new s_plugin_id[32], filename[255];
	
	format(s_plugin_id, 31, "%d", plugin_id);
	format(filename, 254, "%s/ljs_plugin_info.txt", ljsDir);
	
	if( file_exists(filename) )
		delete_file(filename);
	
	write_file(filename, gVERSION_NUM);
	write_file(filename, s_plugin_id);
	write_file(filename, plugin_file_name);
	write_file(filename, gPLUGIN);
	write_file(filename, gVERSION);
	write_file(filename, gAUTHOR);
}

public plugin_start()
{
	plugin_id = register_plugin(gPLUGIN, gVERSION, gAUTHOR);
	register_cvar("LongJumpStats", gVERSION, FCVAR_SERVER);
	register_dictionary("common.txt");
	
	register_forward(FM_ShouldCollide,   "fwdTouch",           1);
	register_forward(FM_Touch,           "fwdTouch",           1);
	register_forward(FM_PlayerPreThink,  "fwdPlayerPreThink",  0);
	register_forward(FM_PlayerPostThink, "fwdPlayerPostThink", 0);
	register_forward(FM_StartFrame,      "fwdStartFrame",      0);
	register_forward(FM_CmdStart,	     "fwdCmdStart");
	
	
	kz_ljs_enabled        = register_cvar("kz_ljs_enabled",        "1");		// enables/disables the plugin
	//kz_good_lj            = register_cvar("kz_good_lj",            "240.0");	// good longjumps
	//kz_pro_lj             = register_cvar("kz_pro_lj",             "245.0");	// professional longjumps
	//kz_leet_lj            = register_cvar("kz_leet_lj",            "250.0");	// leet longjump
	kz_min_lj             = register_cvar("kz_min_lj",             "215.0");	// minimal longjump
	kz_min_lj_c           = register_cvar("kz_min_lj_c",           "230.0");	// minimal longjump to see
	kz_min_bhop	      = register_cvar("kz_min_bhop", 	       "210.0");	// minimal bhop
	kz_min_bhop_c	      = register_cvar("kz_min_bhop_c", 	       "220.0");	// minimal bhop
	kz_max_lj             = register_cvar("kz_max_lj",             "260.0");	// maximal longjump
	kz_cj_dif             = register_cvar("kz_cj_dif",             "10.0");		// difrence between lj and cj
	kz_lj_sounds          = register_cvar("kz_lj_sounds",          "1");		// enables leet/pro/good lj/cj sounds
	kz_leet_lj_clr        = register_cvar("kz_leet_lj_clr",        "1");		// color of leet lj (1=red, 2=green, 3=blue, 4=gray, 5=team, 0=default)
	kz_pro_lj_clr         = register_cvar("kz_pro_lj_clr",         "2");		// color of pro lj
	kz_good_lj_clr        = register_cvar("kz_good_lj_clr",        "4");		// color of good lj
	kz_leet_cj_clr        = register_cvar("kz_leet_cj_clr",        "1");		// color of leet lj
	kz_pro_cj_clr         = register_cvar("kz_pro_cj_clr",         "2");		// color of pro lj
	kz_good_cj_clr        = register_cvar("kz_good_cj_clr",        "4");		// color of good lj
	kz_ljstats_red        = register_cvar("kz_ljstats_red",        "0");		// red color of /ljstats
	kz_ljstats_green      = register_cvar("kz_ljstats_green",      "180");		// green color of /ljstats
	kz_ljstats_blue       = register_cvar("kz_ljstats_blue",       "11");		// blue color of /ljstats
	kz_ljs_beam           = register_cvar("kz_ljs_beam",           "2");		// 0=beam off, 1=normal beam, 2=uber beam
	kz_legal_settings     = register_cvar("kz_legal_settings",     "1");		// enables protection 4 legal kreedz settings
	kz_ljs_fastserver     = register_cvar("kz_ljs_fastserver",     "1");            // Is your server fast? (0=slow, 1=normal, 2=good)
	//kz_ljs_autoserver     = register_cvar("kz_ljs_autoserver",     "1");		// Authomaticaly detect what cvar of kz_ljs_fastserver should be?
	kz_ljs_speedtype      = register_cvar("kz_ljs_speedtype",      "0");		// Speedometer type
	kz_ljs_connectenabler = register_cvar("kz_ljs_connectenabler", "ab");		// What is enabled at connect (0=nothing, a=colorchat, b=ljstats, c=speed)
	kz_ljs_viscmds        = register_cvar("kz_ljs_viscmds",        "1");		// Do you want say commands to be apeard on the chat?
	kz_ljs_tops           = register_cvar("kz_ljs_tops",           "3");		// LongJump top (0=Nothing, 1=ColorChat, 2=top, 3=top+ColorChat)
	kz_ljs_topsave        = register_cvar("kz_ljs_topsave",        "1");		// Do you want to save ljtop after mapchange?
	kz_ljs_rank_by        = register_cvar("kz_ljs_rank_by",        "2");		// How ranking will work? 0=name, 1=steam, 2=ip
	kz_ljs_maptop         = register_cvar("kz_ljs_maptop",         "1");		// Enable map top
	
	edgefriction          = get_cvar_pointer("edgefriction");
	mp_footsteps          = get_cvar_pointer("mp_footsteps");
	sv_cheats             = get_cvar_pointer("sv_cheats");
	sv_gravity            = get_cvar_pointer("sv_gravity");
	sv_maxspeed           = get_cvar_pointer("sv_maxspeed");
	sv_stepsize           = get_cvar_pointer("sv_stepsize");
	sv_maxvelocity        = get_cvar_pointer("sv_maxvelocity");
//	sv_lan                = get_cvar_pointer("sv_lan");
	
/*	
	server_settings[33][0] = "1";
	server_settings[33][1] = "260.0";
	server_settings[33][2] = "250.0";
	server_settings[33][3] = "245.0";
	server_settings[33][4] = "240.0";
	server_settings[33][5] = "215.0";
	server_settings[33][6] = "5.0";
	server_settings[33][7] = "1";
	server_settings[33][8] = "3";
	server_settings[33][9] = "1";
	server_settings[33][10] = "0";
	server_settings[33][11] = "1";
	server_settings[33][12] = "2";
	server_settings[33][13] = "4";
	server_settings[33][14] = "1";
	server_settings[33][15] = "2";
	server_settings[33][16] = "4";
	server_settings[33][17] = "0";
	server_settings[33][18] = "255";
	server_settings[33][19] = "159";
	server_settings[33][20] = "2";
	server_settings[33][21] = "1";
	server_settings[33][22] = "2";
	server_settings[33][23] = "1";
	server_settings[33][24] = "abc";
	server_settings[33][25] = "1";
	server_settings[33][26] = "0";
*/
	configurate_plugin();
	
	register_menucmd(register_menuid("LongJump Stats Menu"),  1023, "LjsMenu_Select");
	register_menucmd(register_menuid("Top 10 Menu"),          1023, "MainTopMenu_Select");
	register_menucmd(register_menuid("Full top stats"),       1023, "FullTopMenu_Select");
	register_menucmd(register_menuid("Show best longjumper"), 1023, "LeetJumpMenu_Select");
	
	
	tops_save = true;
	new LJS_ADMIN = ADMIN_MAP;
	if( get_pcvar_num(kz_ljs_topsave) )
		LJS_ADMIN = ADMIN_RCON;
	else
		tops_save = false;
	
	register_concmd("amx_resetljrec",  "topreset",         LJS_ADMIN, "- resets ljrec and ljtops");
	register_concmd("amx_resetljtops", "topreset",         LJS_ADMIN, "- resets ljrec and ljtops");
	
	register_clcmd("say /colorchat",  "cmdColorChat",      ADMIN_ALL, "- enables/disables colorchat");
	register_clcmd("say /ljstats",    "cmdLjStats",        ADMIN_ALL, "- enables/disables longjump stats");
	register_clcmd("say /ljsversion", "cmdVersion",        ADMIN_ALL, "- prints plugin version");
	register_clcmd("say /speed",      "cmdSpeed",          ADMIN_ALL, "- enabled/disables visible speed");
	register_clcmd("say /strafestat", "cmdStrafeStat",     ADMIN_ALL, "- enabled/disables strafe statistics");
	register_clcmd("say /ljlinear",   "cmdljhelp",         ADMIN_ALL, "- enabled/disables");
	register_clcmd("say /ljbeam",     "cmdljbeam",         ADMIN_ALL, "- enabled/disables");
	
	register_clcmd("say /ljsmenu",    "cmdLjsMenu",        ADMIN_ALL, "- display ljs menu");
	register_clcmd("say /cj15",       "cmdTopMenu",        -1,        "- display tops menu");
	register_clcmd("say /cjtop15",    "cmdTopMenu",        -1,        "- display tops menu");
	register_clcmd("say /cj10",       "cmdTopMenu",        -1,        "- display tops menu");
	register_clcmd("say /cjtop10",    "cmdTopMenu",        -1,        "- display tops menu");
	register_clcmd("say /cjtop",      "cmdTopMenu",        -1,        "- display tops menu");
	register_clcmd("say /bj15",       "cmdTopMenu",        -1,        "- display tops menu");
	register_clcmd("say /bjtop15",    "cmdTopMenu",        -1,        "- display tops menu");
	register_clcmd("say /bj10",       "cmdTopMenu",        -1,        "- display tops menu");
	register_clcmd("say /bjtop10",    "cmdTopMenu",        -1,        "- display tops menu");
	register_clcmd("say /bjtop",      "cmdTopMenu",        -1,        "- display tops menu");
	register_clcmd("say /bhop15",     "cmdTopMenu",        -1,        "- display tops menu");
	register_clcmd("say /bhop10",     "cmdTopMenu",        -1,        "- display tops menu");
	register_clcmd("say /bhop",       "cmdTopMenu",        -1,        "- display tops menu");
	register_clcmd("say /lj15",       "cmdTopMenu",        -1,        "- display tops menu");
	register_clcmd("say /ljtop15",    "cmdTopMenu",        -1,        "- display tops menu");
	register_clcmd("say /lj10",       "cmdTopMenu",        ADMIN_ALL, "- display tops menu");
	register_clcmd("say /ljtop10",    "cmdTopMenu",        -1,        "- display tops menu");
	register_clcmd("say /ljtop",      "cmdTopMenu",        -1,        "- display tops menu");
	register_clcmd("say /ljrec",      "show_leet_ljumper", ADMIN_ALL, "- display records menu");
	register_clcmd("say /cjrec",      "show_leet_ljumper", -1,        "- display records menu");
	register_clcmd("say /bjrec",      "show_leet_ljumper", -1,	  "- display records menu");
	register_clcmd("say /sbjrec",     "show_leet_ljumper", -1,        "- display records menu");
	register_clcmd("say /wjrec",      "show_leet_ljumper", -1,        "- display records menu");
	
	register_clcmd("say /tele",       "gocheckBoth",           -1,        " - teleported");
	register_clcmd("say /tp",         "gocheckBoth",           -1,        " - teleported");
	register_clcmd("say /gocheck",    "gocheckBoth",           -1,        " - teleported");
	register_clcmd("say /gc",         "gocheckBoth",           -1,        " - teleported");
	register_clcmd("say .tele",       "gocheckBoth",           -1,        " - teleported");
	register_clcmd("say .tp",         "gocheckBoth",           -1,        " - teleported");
	register_clcmd("say .gocheck",    "gocheckBoth",           -1,        " - teleported");
	register_clcmd("say .gc",         "gocheckBoth",           -1,        " - teleported");
	register_clcmd("/tele",           "gocheckBoth",           -1,        " - teleported");
	register_clcmd("/tp",             "gocheckBoth",           -1,        " - teleported");
	register_clcmd("/gocheck",        "gocheckBoth",           -1,        " - teleported");
	register_clcmd("/gc",             "gocheckBoth",           -1,        " - teleported");
	register_clcmd(".tele",           "gocheckBoth",           -1,        " - teleported");
	register_clcmd(".tp",             "gocheckBoth",           -1,        " - teleported");
	register_clcmd(".gocheck",        "gocheckBoth",           -1,        " - teleported");
	register_clcmd(".gc",             "gocheckBoth",           -1,        " - teleported");
	register_clcmd("say /stuck",      "gocheckBoth",           -1,        " - teleported");
	register_clcmd("say /unstuck",    "gocheckBoth",           -1,        " - teleported");
	register_clcmd("say .stuck",      "gocheckBoth",           -1,        " - teleported");
	register_clcmd("say .unstuck",    "gocheckBoth",           -1,        " - teleported");
	register_clcmd("/stuck",          "gocheckBoth",           -1,        " - teleported");
	register_clcmd("/unstuck",        "gocheckBoth",           -1,        " - teleported");
	register_clcmd(".stuck",          "gocheckBoth",           -1,        " - teleported");
	register_clcmd(".unstuck",        "gocheckBoth",           -1,        " - teleported");
	register_clcmd("say /start",      "gocheckBoth",           -1,        " - reseted");
	register_clcmd("say /reset",      "gocheckBoth",           -1,        " - reseted");
	register_clcmd("say /restart",    "gocheckBoth",           -1,        " - reseted");
	register_clcmd("say /spawn",      "gocheckBoth",           -1,        " - reseted");
	register_clcmd("say .start",      "gocheckBoth",           -1,        " - reseted");
	register_clcmd("say .reset",      "gocheckBoth",           -1,        " - reseted");
	register_clcmd("say .restart",    "gocheckBoth",           -1,        " - reseted");
	register_clcmd("say .spawn",      "gocheckBoth",           -1,        " - reseted");
	register_clcmd("/start",          "gocheckBoth",           -1,        " - reseted");
	register_clcmd("/reset",          "gocheckBoth",           -1,        " - reseted");
	register_clcmd("/restart",        "gocheckBoth",           -1,        " - reseted");
	register_clcmd("/spawn",          "gocheckBoth",           -1,        " - reseted");
	register_clcmd(".start",          "gocheckBoth",           -1,        " - reseted");
	register_clcmd(".reset",          "gocheckBoth",           -1,        " - reseted");
	register_clcmd(".restart",        "gocheckBoth",           -1,        " - reseted");
	register_clcmd(".spawn",          "gocheckBoth",           -1,        " - reseted");
	register_clcmd("+hook",           "gocheckBoth",           -1,        " - used hook");
	register_clcmd("-hook",           "gocheckBoth",           -1,        " - used hook");
		
	new dataDir[64];
	get_datadir(dataDir, 63);
	format(ljsDir, 63, "%s/ljs", dataDir);
	if( !dir_exists(ljsDir) )
		mkdir(ljsDir);
	
	get_plugin(plugin_id, plugin_file_name, 63, "", 0, "", 0, "", 0, "", 0);
}

public fwdCmdStart(plr, uc_handle, seed)
{
	if ( is_user_alive( plr ) )
	{
		static g_iPlayerFps;
		g_iPlayerFps = get_uc(uc_handle, UC_Msec);

		if ( (g_iPlayerFps > 0 && g_iPlayerFps < 10))
		{
			gocheckBoth(plr);
		}
	}
}

public configurate_plugin()
{
/*	if( !get_ljsconfig(0) )
	{
		for( new i; i < 27; i++ )
			format(server_settings[0][i], 15, "%s", server_settings[33][i]);
	}
	setconfig_now(0);
*/
}

public setconfig_now(player)
{
/*
	set_cvar_string("kz_ljs_enabled", server_settings[player][0]);
	set_cvar_string("kz_max_lj", server_settings[player][1]);
	set_cvar_string("kz_leet_lj", server_settings[player][2]);
	set_cvar_string("kz_pro_lj", server_settings[player][3]);
	set_cvar_string("kz_good_lj", server_settings[player][4]);
	set_cvar_string("kz_min_lj", server_settings[player][5]);
	set_cvar_string("kz_cj_dif", server_settings[player][6]);
	set_cvar_string("kz_lj_sounds", server_settings[player][7]);
	set_cvar_string("kz_lj_top", server_settings[player][8]);
	set_cvar_string("kz_ljs_topsave", server_settings[player][9]);
	set_cvar_string("kz_ljs_rank_by", server_settings[player][10]);
	set_cvar_string("kz_leet_lj_clr", server_settings[player][11]);
	set_cvar_string("kz_pro_lj_clr", server_settings[player][12]);
	set_cvar_string("kz_good_lj_clr", server_settings[player][13]);
	set_cvar_string("kz_leet_cj_clr", server_settings[player][14]);
	set_cvar_string("kz_pro_cj_clr", server_settings[player][15]);
	set_cvar_string("kz_good_cj_clr", server_settings[player][16]);
	set_cvar_string("kz_ljstats_red", server_settings[player][17]);
	set_cvar_string("kz_ljstats_green", server_settings[player][18]);
	set_cvar_string("kz_ljstats_blue", server_settings[player][19]);
	set_cvar_string("kz_ljs_beam", server_settings[player][20]);
	set_cvar_string("kz_legal_settings", server_settings[player][21]);
	if( str_to_num(server_settings[player][22]) == 2 && str_to_num(server_settings[player][23]) )
	{
		if( !is_dedicated_server() && get_pcvar_num(sv_lan) != 0 )
			set_cvar_string("kz_ljs_fastserver", "2");
		else
			set_cvar_string("kz_ljs_fastserver", "1");
	}
	else
		set_cvar_string("kz_ljs_fastserver", server_settings[player][22]);
	set_pcvar_num(kz_ljs_autoserver, str_to_num(server_settings[player][23]));
	set_cvar_string("kz_ljs_connectenabler", server_settings[player][24]);
	set_cvar_string("kz_ljs_viscmds", server_settings[player][25]);
	set_cvar_string("kz_ljs_speedtype", server_settings[player][26]);
*/
}

stock get_ljsconfig(player)
{
	static configsDir[64], filename[128];
	get_configsdir(configsDir, 63);
	format(filename, 127, "%s/ljstats.ini", configsDir);
	
	if( !dir_exists(configsDir) )
		mkdir(configsDir);
		
	if( !file_exists(filename) )
	{
		log_amx("LjS: Error: Configuration file <^"%s^"> not found!", filename);
		log_amx("LjS: Creating file...");
		write_file(filename, "; .-==========================================-.");
		write_file(filename, "; |~~ Long Jump Stats - eXtreme Modification ~~|");
		write_file(filename, "; .-==========================================-.");
		write_file(filename, "");
		write_file(filename, "");
		write_file(filename, "; Enabled/Disables the plugin");
		write_file(filename, "; 0 = disabled");
		write_file(filename, "; 1 = enabled");
		write_file(filename, "; Cvar kz_ljs_enabled (default ^"1^")");
		write_file(filename, "1");
		write_file(filename, "");
		write_file(filename, "; Maximum possible lj (not 4 cj)");
		write_file(filename, "; Cvar kz_max_lj (default ^"260.0^")");
		write_file(filename, "260.0");
		write_file(filename, "");
		write_file(filename, "; 1337 lj (prints to all players)");
		write_file(filename, "; To disable, set it to -1");
		write_file(filename, "; Cvar kz_leet_lj (default ^"250.0^")");
		write_file(filename, "250.0");
		write_file(filename, "");
		write_file(filename, "; Professional lj (prints to all players)");
		write_file(filename, "; To disable, set it to -1");
		write_file(filename, "; Cvar kz_pro_lj (default ^"245.0^")");
		write_file(filename, "245.0");
		write_file(filename, "");
		write_file(filename, "; Good lj (prints to all players)");
		write_file(filename, "; To disable, set it to -1");
		write_file(filename, "; Cvar kz_good_lj (default ^"240.0^")");
		write_file(filename, "240.0");
		write_file(filename, "");
		write_file(filename, "; Minimal lj distance");
		write_file(filename, "; Cvar kz_min_lj (default ^"215.0^")");
		write_file(filename, "215.0");
		write_file(filename, "");
		write_file(filename, "; Difrence between longjump and countjump for good/pro/leet/max jump");
		write_file(filename, "; Cvar kz_cj_dif (default ^"10.0^")");
		write_file(filename, "10.0");
		write_file(filename, "");
		write_file(filename, "; Enables lj sounds");
		write_file(filename, "; 0 = disabled");
		write_file(filename, "; 1 = ultimate sounds");
		write_file(filename, "; 2 = distance in voice");
		write_file(filename, "; Cvar kz_lj_sounds (default ^"1^")");
		write_file(filename, "1");
		write_file(filename, "");
		write_file(filename, "; How dose plugin works");
		write_file(filename, "; 0 = no top and no colorchat");
		write_file(filename, "; 1 = prints good/pro/leet jumps");
		write_file(filename, "; 2 = enables top10");
		write_file(filename, "; 3 = prints good/pro/leet jumps and enables top10");
		write_file(filename, "; Cvar kz_lj_top (default ^"3^")");
		write_file(filename, "3");
		write_file(filename, "");
		write_file(filename, "; Do you want to save ljtop after mapchange?");
		write_file(filename, "; Cvar kz_ljs_topsave (default ^"1^")");
		write_file(filename, "1");
		write_file(filename, "");
		write_file(filename, "; How ranking will work?");
		write_file(filename, "; 0 = names");
		write_file(filename, "; 1 = steam ids");
		write_file(filename, "; 2 = ips");
		write_file(filename, "; Cvar kz_ljs_rank_by (default ^"0^")");
		write_file(filename, "0");
		write_file(filename, "");
		write_file(filename, "; Kz jumping color chat:");
		write_file(filename, "; 0 = normal");
		write_file(filename, "; 1 = red");
		write_file(filename, "; 2 = green");
		write_file(filename, "; 3 = blue");
		write_file(filename, "; 4 = silver");
		write_file(filename, "; 5 = team color");
		write_file(filename, "");
		write_file(filename, "; Cvar kz_leet_lj_clr (default ^"1^")");
		write_file(filename, "1");
		write_file(filename, "; Cvar kz_pro_lj_clr (default ^"2^")");
		write_file(filename, "2");
		write_file(filename, "; Cvar kz_good_lj_clr (default ^"4^")");
		write_file(filename, "4");
		write_file(filename, "");
		write_file(filename, "; Cvar kz_leet_cj_clr (default ^"1^")");
		write_file(filename, "1");
		write_file(filename, "; Cvar kz_pro_cj_clr (default ^"2^")");
		write_file(filename, "2");
		write_file(filename, "; Cvar kz_good_cj_clr (default ^"4^")");
		write_file(filename, "4");
		write_file(filename, "");
		write_file(filename, "; Colors of /ljstats (rrr ggg bbb)");
		write_file(filename, "; Cvar kz_ljstats_red (default ^"0^")");
		write_file(filename, "0");
		write_file(filename, "; Cvar kz_ljstats_green (default ^"255^")");
		write_file(filename, "255");
		write_file(filename, "; Cvar kz_ljstats_blue (^"159^")");
		write_file(filename, "159");
		write_file(filename, "");
		write_file(filename, "; LongJump Stats Laser Beam");
		write_file(filename, "; 0 = off");
		write_file(filename, "; 1 = normal");
		write_file(filename, "; 2 = uber beam");
		write_file(filename, "; Cvar kz_ljs_beam (default ^"2^")");
		write_file(filename, "2");
		write_file(filename, "");
		write_file(filename, "; Enables protection 4 legal kreedz settings");
		write_file(filename, "; Cvar kz_legal_settings (default ^"1^")");
		write_file(filename, "1");
		write_file(filename, "");
		write_file(filename, "; Is your server fast?");
		write_file(filename, "; 0 = slow");
		write_file(filename, "; 1 = normal");
		write_file(filename, "; 2 = realy good ( >10mb/s or localhost/lan server )");
		write_file(filename, "; Cvar kz_ljs_fastserver (default ^"2^")");
		write_file(filename, "2");
		write_file(filename, "");
		write_file(filename, "; Enables auto-setting 4 kz_ljs_fastserver cvar if it is 2");
		write_file(filename, "; Cvar kz_ljs_autoserver (default ^"1^")");
		write_file(filename, "1");
		write_file(filename, "");
		write_file(filename, "; What is enabled on client when he connects to a server?");
		write_file(filename, "; 0 = nothing");
		write_file(filename, "; a = colorchat");
		write_file(filename, "; b = ljstats");
		write_file(filename, "; c = speed");
		write_file(filename, "; Cvar kz_ljs_connectenabler (default ^"abc^")");
		write_file(filename, "abc");
		write_file(filename, "");
		write_file(filename, "; Do you want cmds like /speed to be visible in the chat?");
		write_file(filename, "; Cvar kz_ljs_viscmds (default ^"1^")");
		write_file(filename, "1");
		write_file(filename, "");
		write_file(filename, "; Speedometer type");
		write_file(filename, "; 0 = show real speed and horizontal speed");
		write_file(filename, "; 1 = show real speed");
		write_file(filename, "; 2 = show horizontal speed");
		write_file(filename, "; Cvar kz_ljs_speedtype (default ^"0^")");
		write_file(filename, "0");
		if( file_exists(filename) )
		{
			log_amx("LjS: File <^"%s^"> successfully created.", filename);
			log_amx("LjS: All settings are setted by default.");
		}
		else
		{
			log_amx("LjS: Fatal-Error: Creation of <^"%s^"> file failed!", filename);
			log_amx("LjS: Disabeling plugin...");
			set_cvar_string("kz_ljs_enabled", "0");
			if( get_cvar_num("kz_ljs_enabled") )
			{
				if( !plugin_file_name[0] )
					return 0;
				
				log_amx("LjS: Fatal-Error: Omg, plugin cannot be disabled by cvar... Check your amxx!!!");
				log_amx("LjS: Disabeling plugin by turning off the code.");
				pause("ac", plugin_file_name);
			}
			return 0;
		}
	}
	
	new ljs_cvar_num;
	for( ljs_cvar_num = INFO_ZERO; ljs_cvar_num < 27; ljs_cvar_num++ )
		server_settings[player][ljs_cvar_num] = "";
	
	ljs_cvar_num = 0;
	new i, line, text[16], txtsize;
	for( i = INFO_ZERO; i < 255; i++ )
	{
		if( (line=read_file(filename, line, text, 15, txtsize)) != 0 )
		{
			if( text[0] == ';' || (text[0] == '/' && text[1] == '/') || !text[0] || text[0] == ' ' )
				continue;
			else
			{
				format(server_settings[player][ljs_cvar_num], 15, "%s", text);
				ljs_cvar_num += 1;
				if( ljs_cvar_num == 27 )
					break;
			}
		}
		else
			break;
	}
	
	delete_file(filename);
	write_file(filename, "; .-==========================================-.");
	write_file(filename, "; |~~ Long Jump Stats - eXtreme Modification ~~|");
	write_file(filename, "; .-==========================================-.");
	write_file(filename, "");
	write_file(filename, "");
	write_file(filename, "; Enabled/Disables the plugin");
	write_file(filename, "; 0 = disabled");
	write_file(filename, "; 1 = enabled");
	write_file(filename, "; Cvar kz_ljs_enabled (default ^"1^")");
	if( server_settings[player][0][0] )
		write_file(filename, server_settings[player][0]);
	else
	{
		fix_config(1, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; Maximum possible lj (not 4 cj)");
	write_file(filename, "; Cvar kz_max_lj (default ^"260.0^")");
	if( server_settings[player][1][0] )
		write_file(filename, server_settings[player][1]);
	else
	{
		fix_config(2, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; 1337 lj (prints to all players)");
	write_file(filename, "; To disable, set it to -1");
	write_file(filename, "; Cvar kz_leet_lj (default ^"250.0^")");
	if( server_settings[player][2][0] )
		write_file(filename, server_settings[player][2]);
	else
	{
		fix_config(3, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; Professional lj (prints to all players)");
	write_file(filename, "; To disable, set it to -1");
	write_file(filename, "; Cvar kz_pro_lj (default ^"245.0^")");
	if( server_settings[player][3][0] )
		write_file(filename, server_settings[player][3]);
	else
	{
		fix_config(4, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; Good lj (prints to all players)");
	write_file(filename, "; To disable, set it to -1");
	write_file(filename, "; Cvar kz_good_lj (default ^"240.0^")");
	if( server_settings[player][4][0] )
		write_file(filename, server_settings[player][4]);
	else
	{
		fix_config(5, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; Minimal lj distance");
	write_file(filename, "; Cvar kz_min_lj (default ^"215.0^")");
	if( server_settings[player][5][0] )
		write_file(filename, server_settings[player][5]);
	else
	{
		fix_config(6, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; Difrence between longjump and countjump for good/pro/leet/max jump");
	write_file(filename, "; Cvar kz_cj_dif (default ^"10.0^")");
	if( server_settings[player][6][0] )
		write_file(filename, server_settings[player][6]);
	else
	{
		fix_config(7, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; Enables lj sounds");
	write_file(filename, "; 0 = disabled");
	write_file(filename, "; 1 = ultimate sounds");
	write_file(filename, "; 2 = distance in voice");
	write_file(filename, "; Cvar kz_lj_sounds (default ^"1^")");
	if( server_settings[player][7][0] )
		write_file(filename, server_settings[player][7]);
	else
	{
		fix_config(8, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; How dose plugin works");
	write_file(filename, "; 0 = no top and no colorchat");
	write_file(filename, "; 1 = prints good/pro/leet jumps");
	write_file(filename, "; 2 = enables top10");
	write_file(filename, "; 3 = prints good/pro/leet jumps and enables top10");
	write_file(filename, "; Cvar kz_lj_top (default ^"3^")");
	if( server_settings[player][8][0] )
		write_file(filename, server_settings[player][8]);
	else
	{
		fix_config(9, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; Do you want to save ljtop after mapchange?");
	write_file(filename, "; Cvar kz_ljs_topsave (default ^"1^")");
	if( server_settings[player][9][0] )
		write_file(filename, server_settings[player][9]);
	else
	{
		fix_config(10, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; How ranking will work?");
	write_file(filename, "; 0 = names");
	write_file(filename, "; 1 = steam ids");
	write_file(filename, "; 2 = ips");
	write_file(filename, "; Cvar kz_ljs_rank_by (default ^"0^")");
	if( server_settings[player][10][0] )
		write_file(filename, server_settings[player][10]);
	else
	{
		fix_config(11, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; Kz jumping color chat:");
	write_file(filename, "; 0 = normal");
	write_file(filename, "; 1 = red");
	write_file(filename, "; 2 = green");
	write_file(filename, "; 3 = blue");
	write_file(filename, "; 4 = silver");
	write_file(filename, "; 5 = team color");
	write_file(filename, "");
	write_file(filename, "; Cvar kz_leet_lj_clr (default ^"1^")");
	if( server_settings[player][11][0] )
		write_file(filename, server_settings[player][11]);
	else
	{
		fix_config(12, player);
		return 1;
	}
	write_file(filename, "; Cvar kz_pro_lj_clr (default ^"2^")");
	if( server_settings[player][12][0] )
		write_file(filename, server_settings[player][12]);
	else
	{
		fix_config(13, player);
		return 1;
	}
	write_file(filename, "; Cvar kz_good_lj_clr (default ^"4^")");
	if( server_settings[player][13][0] )
		write_file(filename, server_settings[player][13]);
	else
	{
		fix_config(14, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; Cvar kz_leet_cj_clr (default ^"1^")");
	if( server_settings[player][14][0] )
		write_file(filename, server_settings[player][14]);
	else
	{
		fix_config(15, player);
		return 1;
	}
	write_file(filename, "; Cvar kz_pro_cj_clr (default ^"2^")");
	if( server_settings[player][15][0] )
		write_file(filename, server_settings[player][15]);
	else
	{
		fix_config(16, player);
		return 1;
	}
	write_file(filename, "; Cvar kz_good_cj_clr (default ^"4^")");
	if( server_settings[player][16][0] )
		write_file(filename, server_settings[player][16]);
	else
	{
		fix_config(17, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; Colors of /ljstats (rrr ggg bbb)");
	write_file(filename, "; Cvar kz_ljstats_red (default ^"0^")");
	if( server_settings[player][17][0] )
		write_file(filename, server_settings[player][17]);
	else
	{
		fix_config(18, player);
		return 1;
	}
	write_file(filename, "; Cvar kz_ljstats_green (default ^"255^")");
	if( server_settings[player][18][0] )
		write_file(filename, server_settings[player][18]);
	else
	{
		fix_config(19, player);
		return 1;
	}
	write_file(filename, "; Cvar kz_ljstats_blue (^"159^")");
	if( server_settings[player][19][0] )
		write_file(filename, server_settings[player][19]);
	else
	{
		fix_config(20, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; LongJump Stats Laser Beam");
	write_file(filename, "; 0 = off");
	write_file(filename, "; 1 = normal");
	write_file(filename, "; 2 = uber beam");
	write_file(filename, "; Cvar kz_ljs_beam (default ^"2^")");
	if( server_settings[player][20][0] )
		write_file(filename, server_settings[player][20]);
	else
	{
		fix_config(21, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; Enables protection 4 legal kreedz settings");
	write_file(filename, "; Cvar kz_legal_settings (default ^"1^")");
	if( server_settings[player][21][0] )
		write_file(filename, server_settings[player][21]);
	else
	{
		fix_config(22, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; Is your server fast?");
	write_file(filename, "; 0 = slow");
	write_file(filename, "; 1 = normal");
	write_file(filename, "; 2 = realy good ( >10mb/s or localhost/lan server )");
	write_file(filename, "; Cvar kz_ljs_fastserver (default ^"2^")");
	if( server_settings[player][22][0] )
		write_file(filename, server_settings[player][22]);
	else
	{
		fix_config(23, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; Enables auto-setting 4 kz_ljs_fastserver cvar if it is 2");
	write_file(filename, "; Cvar kz_ljs_autoserver (default ^"1^")");
	if( server_settings[player][23][0] )
		write_file(filename, server_settings[player][23]);
	else
	{
		fix_config(24, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; What is enabled on client when he connects to a server?");
	write_file(filename, "; 0 = nothing");
	write_file(filename, "; a = colorchat");
	write_file(filename, "; b = ljstats");
	write_file(filename, "; c = speed");
	write_file(filename, "; Cvar kz_ljs_connectenabler (default ^"abc^")");
	if( server_settings[player][24][0] )
		write_file(filename, server_settings[player][24]);
	else
	{
		fix_config(25, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; Do you want cmds like /speed to be visible in the chat?");
	write_file(filename, "; Cvar kz_ljs_viscmds (default ^"1^")");
	if( server_settings[player][25][0] )
		write_file(filename, server_settings[player][25][0]);
	else
	{
		fix_config(26, player);
		return 1;
	}
	write_file(filename, "");
	write_file(filename, "; Speedometer type");
	write_file(filename, "; 0 = show real speed and horizontal speed");
	write_file(filename, "; 1 = show real speed");
	write_file(filename, "; 2 = show horizontal speed");
	write_file(filename, "; Cvar kz_ljs_speedtype (default ^"0^")");
	if( server_settings[player][26][0] )
		write_file(filename, server_settings[player][26]);
	else
	{
		fix_config(27, player);
		return 1;
	}
	
	return 1;
}

public fix_config(fix_since, player)
{
	static configsDir[64], filename[128];
	get_configsdir(configsDir, 63);
	format(filename, 127, "%s/ljstats.ini", configsDir);
	
	if( !(fix_since < 2) )
	{
		log_amx("LjS: Error: Settings that gows before #%d in <^"%s^"> cold be incurrent!", (fix_since+1), filename);
		log_amx("LjS: All other settings are setted by default. Please check the config file!");
	}
	else
	{
		log_amx("LjS: Error: Configuration file <^"%s^"> is not currect!", filename);
		log_amx("LjS: All settings are setted by default.");
		
		server_settings[player][0] = "1";
		write_file(filename, "1");
		write_file(filename, "");
		write_file(filename, "; Maximum possible lj (not 4 cj)");
		write_file(filename, "; Cvar kz_max_lj (default ^"260.0^")");
	}
	if( fix_since < 3 )
	{
		server_settings[player][1] = "260.0";
		write_file(filename, "260.0");
		write_file(filename, "");
		write_file(filename, "; 1337 lj (prints to all players)");
		write_file(filename, "; To disable, set it to -1");
		write_file(filename, "; Cvar kz_leet_lj (default ^"250.0^")");
	}
	if( fix_since < 4 )
	{
		server_settings[player][2] = "250.0";
		write_file(filename, "250.0");
		write_file(filename, "");
		write_file(filename, "; Professional lj (prints to all players)");
		write_file(filename, "; To disable, set it to -1");
		write_file(filename, "; Cvar kz_pro_lj (default ^"245.0^")");
	}
	if( fix_since < 5 )
	{
		server_settings[player][3] = "245.0";
		write_file(filename, "245.0");
		write_file(filename, "");
		write_file(filename, "; Good lj (prints to all players)");
		write_file(filename, "; To disable, set it to -1");
		write_file(filename, "; Cvar kz_good_lj (default ^"240.0^")");
	}
	if( fix_since < 6 )
	{
		server_settings[player][4] = "240.0";
		write_file(filename, "240.0");
		write_file(filename, "");
		write_file(filename, "; Minimal lj distance");
		write_file(filename, "; Cvar kz_min_lj (default ^"215.0^")");
	}
	if( fix_since < 7 )
	{
		server_settings[player][5] = "215.0";
		write_file(filename, "215.0");
		write_file(filename, "");
		write_file(filename, "; Difrence between longjump and countjump for good/pro/leet/max jump");
		write_file(filename, "; Cvar kz_cj_dif (default ^"10.0^")");
	}
	if( fix_since < 8 )
	{
		server_settings[player][6] = "10.0";
		write_file(filename, "10.0");
		write_file(filename, "");
		write_file(filename, "; Enables lj sounds");
		write_file(filename, "; 0 = disabled");
		write_file(filename, "; 1 = ultimate sounds");
		write_file(filename, "; 2 = distance in voice");
		write_file(filename, "; Cvar kz_lj_sounds (default ^"1^")");
	}
	if( fix_since < 9 )
	{
		server_settings[player][7] = "1";
		write_file(filename, "1");
		write_file(filename, "");
		write_file(filename, "; How dose plugin works");
		write_file(filename, "; 0 = no top and no colorchat");
		write_file(filename, "; 1 = prints good/pro/leet jumps");
		write_file(filename, "; 2 = enables top10");
		write_file(filename, "; 3 = prints good/pro/leet jumps and enables top10");
		write_file(filename, "; Cvar kz_lj_top (default ^"3^")");
	}
	if( fix_since < 10 )
	{
		server_settings[player][8] = "3";
		write_file(filename, "3");
		write_file(filename, "");
		write_file(filename, "; Do you want to save ljtop after mapchange?");
		write_file(filename, "; Cvar kz_ljs_topsave (default ^"1^")");
	}
	if( fix_since < 11 )
	{
		server_settings[player][9] = "1";
		write_file(filename, "1");
		write_file(filename, "");
		write_file(filename, "; How ranking will work?");
		write_file(filename, "; 0 = names");
		write_file(filename, "; 1 = steam ids");
		write_file(filename, "; 2 = ips");
		write_file(filename, "; Cvar kz_ljs_rank_by (default ^"0^")");
	}
	if( fix_since < 12 )
	{
		server_settings[player][10] = "0";
		write_file(filename, "0");
		write_file(filename, "");
		write_file(filename, "; Kz jumping color chat:");
		write_file(filename, "; 0 = normal");
		write_file(filename, "; 1 = red");
		write_file(filename, "; 2 = green");
		write_file(filename, "; 3 = blue");
		write_file(filename, "; 4 = silver");
		write_file(filename, "; 5 = team color");
		write_file(filename, "");
		write_file(filename, "; Cvar kz_leet_lj_clr (default ^"1^")");
	}
	if( fix_since < 13 )
	{
		server_settings[player][11] = "1";
		write_file(filename, "1");
		write_file(filename, "; Cvar kz_pro_lj_clr (default ^"2^")");
	}
	if( fix_since < 14 )
	{
		server_settings[player][12] = "2";
		write_file(filename, "2");
		write_file(filename, "; Cvar kz_good_lj_clr (default ^"4^")");
	}
	if( fix_since < 15 )
	{
		server_settings[player][13] = "4";
		write_file(filename, "4");
		write_file(filename, "");
		write_file(filename, "; Cvar kz_leet_cj_clr (default ^"1^")");
	}
	if( fix_since < 16 )
	{
		server_settings[player][14] = "1";
		write_file(filename, "1");
		write_file(filename, "; Cvar kz_pro_cj_clr (default ^"2^")");
	}
	if( fix_since < 17 )
	{
		server_settings[player][15] = "2";
		write_file(filename, "2");
		write_file(filename, "; Cvar kz_good_cj_clr (default ^"4^")");
	}
	if( fix_since < 18 )
	{
		server_settings[player][16] = "4";
		write_file(filename, "4");
		write_file(filename, "");
		write_file(filename, "; Colors of /ljstats (rrr ggg bbb)");
		write_file(filename, "; Cvar kz_ljstats_red (default ^"0^")");
	}
	if( fix_since < 19 )
	{
		server_settings[player][17] = "0";
		write_file(filename, "0");
		write_file(filename, "; Cvar kz_ljstats_green (default ^"255^")");
	}
	if( fix_since < 20 )
	{
		server_settings[player][18] = "255";
		write_file(filename, "255");
		write_file(filename, "; Cvar kz_ljstats_blue (^"159^")");
	}
	if( fix_since < 21 )
	{
		server_settings[player][19] = "159";
		write_file(filename, "159");
		write_file(filename, "");
		write_file(filename, "; LongJump Stats Laser Beam");
		write_file(filename, "; 0 = off");
		write_file(filename, "; 1 = normal");
		write_file(filename, "; 2 = uber beam");
		write_file(filename, "; Cvar kz_ljs_beam (default ^"2^")");
	}
	if( fix_since < 22 )
	{
		server_settings[player][20] = "2";
		write_file(filename, "2");
		write_file(filename, "");
		write_file(filename, "; Enables protection 4 legal kreedz settings");
		write_file(filename, "; Cvar kz_legal_settings (default ^"1^")");
	}
	if( fix_since < 23 )
	{
		server_settings[player][21] = "1";
		write_file(filename, "1");
		write_file(filename, "");
		write_file(filename, "; Is your server fast?");
		write_file(filename, "; 0 = slow");
		write_file(filename, "; 1 = normal");
		write_file(filename, "; 2 = realy good ( >10mb/s or localhost/lan server )");
		write_file(filename, "; Cvar kz_ljs_fastserver (default ^"2^")");
	}
	if( fix_since < 24 )
	{
		server_settings[player][22] = "2";
		write_file(filename, "2");
		write_file(filename, "");
		write_file(filename, "; Enables auto-setting 4 kz_ljs_fastserver cvar if it is 2");
		write_file(filename, "; Cvar kz_ljs_autoserver (default ^"1^")");
	}
	if( fix_since < 25 )
	{
		server_settings[player][23] = "1";
		write_file(filename, "1");
		write_file(filename, "");
		write_file(filename, "; What is enabled on client when he connects to a server?");
		write_file(filename, "; 0 = nothing");
		write_file(filename, "; a = colorchat");
		write_file(filename, "; b = ljstats");
		write_file(filename, "; c = speed");
		write_file(filename, "; Cvar kz_ljs_connectenabler (default ^"abc^")");
	}
	if( fix_since < 26 )
	{
		server_settings[player][24] = "abc";
		write_file(filename, "abc");
		write_file(filename, "");
		write_file(filename, "; Do you want cmds like /speed to be visible in the chat?");
		write_file(filename, "; Cvar kz_ljs_viscmds (default ^"1^")");
	}
	if( fix_since < 27 )
	{
		server_settings[player][25] = "1";
		write_file(filename, "1");
		write_file(filename, "");
		write_file(filename, "; Speedometer type");
		write_file(filename, "; 0 = show real speed and horizontal speed");
		write_file(filename, "; 1 = show real speed");
		write_file(filename, "; 2 = show horizontal speed");
		write_file(filename, "; Cvar kz_ljs_speedtype (default ^"0^")");
	}
	if( fix_since < 28 )
	{
		server_settings[player][26] = "0";
		write_file(filename, "0");
	}
}

public plugin_cfg()
{
	if( get_pcvar_num(kz_legal_settings) )
	{
		set_cvar_string("edgefriction", "2");
		set_cvar_string("mp_footsteps", "1");
		set_cvar_string("sv_cheats", "0");
		set_cvar_string("sv_gravity", "800");
		set_cvar_string("sv_maxspeed", "320");
		set_cvar_string("sv_stepsize", "18");
		set_cvar_string("sv_maxvelocity", "2000");
	}
}

public plugin_precache()
{
	plugin_start();
	
	switch(random_num(1,6))
	{
		case 1: gBeam = precache_model("sprites/zbeam1.spr");
		case 2: gBeam = precache_model("sprites/zbeam2.spr");
		case 3: gBeam = precache_model("sprites/zbeam3.spr");
		case 4: gBeam = precache_model("sprites/zbeam4.spr");
		case 5: gBeam = precache_model("sprites/zbeam5.spr");
		case 6: gBeam = precache_model("sprites/zbeam6.spr");
	}
	
	if( get_pcvar_num(kz_lj_sounds) == 1 )
	{
		precache_sound("misc/impressive.wav");
		precache_sound("misc/mod_godlike.wav");
		precache_sound("misc/mod_wickedsick.wav");
		precache_sound("misc/perfect.wav");
	}
	
	if( get_pcvar_num(kz_ljs_enabled) )
		pluginstatus = INFO_ONE;
	else
		pluginstatus = INFO_ZERO;
}

public cmdTopMenu(id)
{
	new plugin_cvar = get_pcvar_num(kz_ljs_enabled);
	new ljtop_cvar = get_pcvar_num(kz_ljs_tops);
	
	if( plugin_cvar && (ljtop_cvar == 2 || ljtop_cvar == 3) )
	{
		new MenuBody[512], len, keys;
		len = format(MenuBody, 511, "\yLjStats by: LT.Rat & .tv!X^^ ^n");

		if( map_distance[0] )
		{		
			len += format(MenuBody[len], 511-len, "^n\r1. \wMap Top");
			keys = (1<<0);
		}
		else
			len += format(MenuBody[len], 511-len, "^n\r1. \dMap Top (no jumps)");

		if( lj_distance[0] )
		{
			len += format(MenuBody[len], 511-len, "^n\r2. \wLongJump Top");
			keys |= (1<<1);
		}
		else
			len += format(MenuBody[len], 511-len, "^n\r2. \dLongJump (no ljs)");

		if( cj_distance[0] )
		{
			len += format(MenuBody[len], 511-len, "^n\r3. \wCountJump Top");
			keys |= (1<<2);
		}
		else
			len += format(MenuBody[len], 511-len, "^n\r3. \dCountJump (no cjs)");

		if( bj_distance[0] )
		{
			len += format(MenuBody[len], 511-len, "^n\r4. \wBhopJump Top");
			keys |= (1<<3);
		}
		else
			len += format(MenuBody[len], 511-len, "^n\r4. \dBhopJump Top (no bjs)");

		if( sbj_distance[0] )
		{
			len += format(MenuBody[len], 511-len, "^n\r5. \wStand-UP BhopJump Top");
			keys |= (1<<4);
		}
		else
			len += format(MenuBody[len], 511-len, "^n\r5. \dStand-UP BhopJump Top (no sbjs)");
		
		if( wj_distance[0] )
		{
			len += format(MenuBody[len], 511-len, "^n\r6. \wWeirdJump Top");
			keys |= (1<<5);
		}
		else
			len += format(MenuBody[len], 511-len, "^n\r6. \dWeirdJump Top (no wjs)");
		
		len += format(MenuBody[len], 511-len, "^n^n\r0. \wExit");
		keys |= (1<<9);


	/*	len += format(MenuBody[len], 511-len, "^n^n^n\yTops full stats^n");
		len += format(MenuBody[len], 511-len, "^n\r5. \wTotal top stats");
		keys |= (1<<4);

		if( lj_distance[0] )
		{
			len += format(MenuBody[len], 511-len, "^n\r6. \wLj top stats");
			keys |= (1<<5);
		}
		else
			len += format(MenuBody[len], 511-len, "^n\r6. \dLj top stats (no ljs)");

		if( cj_distance[0] )
		{
			len += format(MenuBody[len], 511-len, "^n\r7. \wCj top stats");
			keys |= (1<<6);
		}
		else
			len += format(MenuBody[len], 511-len, "^n\r7. \dCj top stats (no cjs)");

		if( bj_distance[0] )
		{
			len += format(MenuBody[len], 511-len, "^n\r8. \wBj top stats");
			keys |= (1<<7);
		}
		else
			len += format(MenuBody[len], 511-len, "^n\r8. \dBj top stats (no bjs)");
			
		len += format(MenuBody[len], 511-len, "^n^n\r0. \wExit");
		keys |= (1<<9);
	*/
		show_menu(id, keys, MenuBody, -1, "Top 10 Menu");
	}
	else if( !plugin_cvar )
		client_print(id, print_chat, "[XJ] Tops are not valid. Plugin has been disabled.");
	else
		client_print(id, print_chat, "[XJ] Tops are not valid. Tops have been disabled.");
	
	return ( (get_pcvar_num(kz_ljs_viscmds))?PLUGIN_CONTINUE:PLUGIN_HANDLED );
}

public MainTopMenu_Select(id, key)
{
	new plugin_cvar = get_pcvar_num(kz_ljs_enabled);
	new ljtop_cvar = get_pcvar_num(kz_ljs_tops);
	
	if( plugin_cvar && (ljtop_cvar == 2 || ljtop_cvar == 3) )
	{
		switch((key+1))
		{
			case 1:
			{
				if( map_distance[0] )
				{
					show_top(id, TOP_MAP);
					cmdTopMenu(id);
				}
				else
					cmdTopMenu(id);
			}
			case 2:
			{
				if( lj_distance[0] )
				{
					show_top(id, TOP_LJ);
					cmdTopMenu(id);
				}
				else
					cmdTopMenu(id);
			}
			case 3:
			{
				if( cj_distance[0] )
				{
					show_top(id, TOP_CJ);
					cmdTopMenu(id);
				}
				else
					cmdTopMenu(id);
			}
			case 4:
			{
				if( bj_distance[0] )
				{
					show_top(id, TOP_BJ);
					cmdTopMenu(id);
				}
				else
					cmdTopMenu(id);
			}
			case 5:
			{
				if( sbj_distance[0] )
				{
					show_top(id, TOP_SBJ);
					cmdTopMenu(id);
				}
				else
					cmdTopMenu(id);
			}
			case 6:
			{
				if( wj_distance[0] )
				{
					show_top(id, TOP_WJ);
					cmdTopMenu(id);
				}
				else
					cmdTopMenu(id);
			}
#if defined JOKES
			case 7:
			{
				client_print(id, print_chat, "[XJ] It`s a joke :D ");
			}
			case 8:
			{
				client_print(id, print_chat, "[XJ] It`s a joke :D ");
			}
			case 9:
			{
				client_print(id, print_chat, "[XJ] It`s a joke :D ");
			}
#endif

/*
			case 5:
			{
				if( top_distance[0] )
					display_full_top_stats_menu(id, TOP_MAP, 0);
				else
					cmdTopMenu(id);
			}
			case 6:
			{
				if( lj_distance[0] )
					display_full_top_stats_menu(id, TOP_LJ, 0);
				else
					cmdTopMenu(id);
			}
			case 7:
			{
				if( cj_distance[0] )
					display_full_top_stats_menu(id, TOP_CJ, 0);
				else
					cmdTopMenu(id);
			}
			case 8:
			{
				if( bj_distance[0] )
					display_full_top_stats_menu(id, TOP_BJ, 0);
				else
					cmdTopMenu(id);
			}
*/
		}
	}
	else if( !plugin_cvar )
		client_print(id, print_chat, "[XJ] Tops are not valid. Plugin has been disabled.");
	else
		client_print(id, print_chat, "[XJ] Tops are not valid. Tops have been disabled.");
	
	return PLUGIN_HANDLED;
}

public display_full_top_stats_menu(id, toptype, page)
{
	full_top_stats_selected_type[id] = toptype;
	full_top_stats_selected_page[id] = page;

	new i, MenuBody[512], len, keys;
	
	if( toptype == 3 )
	{
		if( page == 2 )
		{
			len = format(MenuBody, 511, "\yFull bj top stats \r2/2^n");
			for( i = INFO_ZERO; i < NSHOW; i++ )
			{
				format( view_names[id][i], 32, bj_names[i] );
				view_distance[id][i] = bj_distance[i];
				view_maxspeed[id][i] = bj_maxspeed[i];
				view_prestrafe[id][i] = bj_prestrafe[i];
				view_strafes[id][i] = bj_strafes[i];
				view_sync[id][i] = bj_sync[i];
				view_type[id][i] = "";
				format( view_pretype[id][i], 31, bj_pretype[i] );
				if( i > 4 )
				{
					len += format(MenuBody[len], 511-len, "^n\r%d. \y%d. \w%s \r%d", (i-4), (i+1), view_names[id][i], (view_distance[id][i]/1000000));
					if( (i-5) )
						keys |= (1<<(i-5));
					else
						keys = (1<<0);
				}
			}
			len += format(MenuBody[len], 511-len, "^n^n\r9. \wBack");
			keys |= (1<<8);
		}
		else if( page )
		{
			len = format(MenuBody, 511, "\yFull bj top stats \r1/2^n");
			for( i = INFO_ZERO; i < 5; i++ )
			{
				format( view_names[id][i], 32, bj_names[i] );
				view_distance[id][i] = bj_distance[i];
				view_maxspeed[id][i] = bj_maxspeed[i];
				view_prestrafe[id][i] = bj_prestrafe[i];
				view_strafes[id][i] = bj_strafes[i];
				view_sync[id][i] = bj_sync[i];
				view_type[id][i] = "";
				format( view_pretype[id][i], 31, bj_pretype[i] );
				len += format(MenuBody[len], 511-len, "^n\r%d. \y%d. \w%s \r%d", (i+1), (i+1), view_names[id][i], (view_distance[id][i]/1000000));
				if( i )
					keys |= (1<<i);
				else
					keys = (1<<0);
			}
			len += format(MenuBody[len], 511-len, "^n^n\r9. \wNext");
			keys |= (1<<8);
		}
		else
		{
			len = format(MenuBody, 511, "\yFull bj top stats \r1/1^n");
			if( bj_distance[9] )
			{
				display_full_top_stats_menu(id, toptype, 1);
				return;
			}
			
			new limit;
			for( limit = INFO_ZERO; limit < NSHOW; limit++ )
			{
				if( !bj_distance[limit] )
					break;
			}
			
			if( limit == 1 )
			{
				format( view_names[id][0], 32, bj_names[0] );
				view_distance[id][0] = bj_distance[0];
				view_maxspeed[id][0] = bj_maxspeed[0];
				view_prestrafe[id][0] = bj_prestrafe[0];
				view_strafes[id][0] = bj_strafes[0];
				view_sync[id][0] = bj_sync[0];
				view_type[id][0] = "";
				format( view_pretype[id][0], 31, bj_pretype[0] );
				len += format(MenuBody[len], 511-len, "^n\r1. \y1. \w%s \r%d", view_names[id][0], (view_distance[id][0]/1000000));
				keys = (1<<0);
			}
			else
			{
				for( i = INFO_ZERO; i < limit; i++ )
				{
					format( view_names[id][i], 32, bj_names[i] );
					view_distance[id][i] = bj_distance[i];
					view_maxspeed[id][i] = bj_maxspeed[i];
					view_prestrafe[id][i] = bj_prestrafe[i];
					view_strafes[id][i] = bj_strafes[i];
					view_sync[id][i] = bj_sync[i];
					view_type[id][i] = "";
					format( view_pretype[id][i], 31, bj_pretype[i] );
					len += format(MenuBody[len], 511-len, "^n\r%d. \y%d. \w%s \r%d", (i+1), (i+1), view_names[id][i], (view_distance[id][i]/1000000));
					if( i )
						keys |= (1<<i);
					else
						keys = (1<<0);
				}
			}
		}
	}
	else if( toptype == 2 )
	{
		if( page == 2 )
		{
			len = format(MenuBody, 511, "\yFull cj top stats \r2/2^n");
			for( i = INFO_ZERO; i < NSHOW; i++ )
			{
				format( view_names[id][i], 32, cj_names[i] );
				view_distance[id][i] = cj_distance[i];
				view_maxspeed[id][i] = cj_maxspeed[i];
				view_prestrafe[id][i] = cj_prestrafe[i];
				view_strafes[id][i] = cj_strafes[i];
				view_sync[id][i] = cj_sync[i];
				view_type[id][i] = "";
				format( view_pretype[id][i], 31, cj_pretype[i] );
				if( i > 4 )
				{
					len += format(MenuBody[len], 511-len, "^n\r%d. \y%d. \w%s \r%d", (i-4), (i+1), view_names[id][i], (view_distance[id][i]/1000000));
					if( (i-5) )
						keys |= (1<<(i-5));
					else
						keys = (1<<0);
				}
			}
			len += format(MenuBody[len], 511-len, "^n^n\r9. \wBack");
			keys |= (1<<8);
		}
		else if( page )
		{
			len = format(MenuBody, 511, "\yFull cj top stats \r1/2^n");
			for( i = INFO_ZERO; i < 5; i++ )
			{
				format( view_names[id][i], 32, cj_names[i] );
				view_distance[id][i] = cj_distance[i];
				view_maxspeed[id][i] = cj_maxspeed[i];
				view_prestrafe[id][i] = cj_prestrafe[i];
				view_strafes[id][i] = cj_strafes[i];
				view_sync[id][i] = cj_sync[i];
				view_type[id][i] = "";
				format( view_pretype[id][i], 31, cj_pretype[i] );
				len += format(MenuBody[len], 511-len, "^n\r%d. \y%d. \w%s \r%d", (i+1), (i+1), view_names[id][i], (view_distance[id][i]/1000000));
				if( i )
					keys |= (1<<i);
				else
					keys = (1<<0);
			}
			len += format(MenuBody[len], 511-len, "^n^n\r9. \wNext");
			keys |= (1<<8);
		}
		else
		{
			len = format(MenuBody, 511, "\yFull cj top stats \r1/1^n");
			if( cj_distance[9] )
			{
				display_full_top_stats_menu(id, toptype, 1);
				return;
			}
			
			new limit;
			for( limit = INFO_ZERO; limit < NSHOW; limit++ )
			{
				if( !cj_distance[limit] )
					break;
			}
			
			if( limit == 1 )
			{
				format( view_names[id][0], 32, cj_names[0] );
				view_distance[id][0] = cj_distance[0];
				view_maxspeed[id][0] = cj_maxspeed[0];
				view_prestrafe[id][0] = cj_prestrafe[0];
				view_strafes[id][0] = cj_strafes[0];
				view_sync[id][0] = cj_sync[0];
				view_type[id][0] = "";
				format( view_pretype[id][0], 31, cj_pretype[0] );
				len += format(MenuBody[len], 511-len, "^n\r1. \y1. \w%s \r%d", view_names[id][0], (view_distance[id][0]/1000000));
				keys = (1<<0);
			}
			else
			{
				for( i = INFO_ZERO; i < limit; i++ )
				{
					format( view_names[id][i], 32, cj_names[i] );
					view_distance[id][i] = cj_distance[i];
					view_maxspeed[id][i] = cj_maxspeed[i];
					view_prestrafe[id][i] = cj_prestrafe[i];
					view_strafes[id][i] = cj_strafes[i];
					view_sync[id][i] = cj_sync[i];
					view_type[id][i] = "";
					format( view_pretype[id][i], 31, cj_pretype[i] );
					len += format(MenuBody[len], 511-len, "^n\r%d. \y%d. \w%s \r%d", (i+1), (i+1), view_names[id][i], (view_distance[id][i]/1000000));
					if( i )
						keys |= (1<<i);
					else
						keys = (1<<0);
				}
			}
		}
	}
	else if( toptype )
	{
		if( page == 2 )
		{
			len = format(MenuBody, 511, "\yFull lj top stats \r2/2^n");
			for( i = INFO_ZERO; i < NSHOW; i++ )
			{
				format( view_names[id][i], 32, lj_names[i] );
				view_distance[id][i] = lj_distance[i];
				view_maxspeed[id][i] = lj_maxspeed[i];
				view_prestrafe[id][i] = lj_prestrafe[i];
				view_strafes[id][i] = lj_strafes[i];
				view_sync[id][i] = lj_sync[i];
				view_type[id][i] = "";
				format( view_pretype[id][i], 31, lj_pretype[i] );
				if( i > 4 )
				{
					len += format(MenuBody[len], 511-len, "^n\r%d. \y%d. \w%s \r%d", (i-4), (i+1), view_names[id][i], (view_distance[id][i]/1000000));
					if( (i-5) )
						keys |= (1<<(i-5));
					else
						keys = (1<<0);
				}
			}
			len += format(MenuBody[len], 511-len, "^n^n\r9. \wBack");
			keys |= (1<<8);
		}
		else if( page )
		{
			len = format(MenuBody, 511, "\yFull lj top stats \r1/2^n");
			for( i = INFO_ZERO; i < 5; i++ )
			{
				format( view_names[id][i], 32, lj_names[i] );
				view_distance[id][i] = lj_distance[i];
				view_maxspeed[id][i] = lj_maxspeed[i];
				view_prestrafe[id][i] = lj_prestrafe[i];
				view_strafes[id][i] = lj_strafes[i];
				view_sync[id][i] = lj_sync[i];
				view_type[id][i] = "";
				format( view_pretype[id][i], 31, lj_pretype[i] );
				len += format(MenuBody[len], 511-len, "^n\r%d. \y%d. \w%s \r%d", (i+1), (i+1), view_names[id][i], (view_distance[id][i]/1000000));
				if( i )
					keys |= (1<<i);
				else
					keys = (1<<0);
			}
			len += format(MenuBody[len], 511-len, "^n^n\r9. \wNext");
			keys |= (1<<8);
		}
		else
		{
			len = format(MenuBody, 511, "\yFull lj top stats \r1/1^n");
			if( lj_distance[9] )
			{
				display_full_top_stats_menu(id, toptype, 1);
				return;
			}
			
			new limit;
			for( limit = INFO_ZERO; limit < NSHOW; limit++ )
			{
				if( !lj_distance[limit] )
					break;
			}
			
			if( limit == 1 )
			{
				format( view_names[id][0], 32, lj_names[0] );
				view_distance[id][0] = lj_distance[0];
				view_maxspeed[id][0] = lj_maxspeed[0];
				view_prestrafe[id][0] = lj_prestrafe[0];
				view_strafes[id][0] = lj_strafes[0];
				view_sync[id][0] = lj_sync[0];
				view_type[id][0] = "";
				format( view_pretype[id][0], 31, lj_pretype[0] );
				len += format(MenuBody[len], 511-len, "^n\r1. \y1. \w%s \r%d", view_names[id][0], (view_distance[id][0]/1000000));
				keys = (1<<0);
			}
			else
			{
				for( i = INFO_ZERO; i < limit; i++ )
				{
					format( view_names[id][i], 32, lj_names[i] );
					view_distance[id][i] = lj_distance[i];
					view_maxspeed[id][i] = lj_maxspeed[i];
					view_prestrafe[id][i] = lj_prestrafe[i];
					view_strafes[id][i] = lj_strafes[i];
					view_sync[id][i] = lj_sync[i];
					view_type[id][i] = "";
					format( view_pretype[id][i], 31, lj_pretype[i] );
					len += format(MenuBody[len], 511-len, "^n\r%d. \y%d. \w%s \r%d", (i+1), (i+1), view_names[id][i], (view_distance[id][i]/1000000));
					if( i )
						keys |= (1<<i);
					else
						keys = (1<<0);
				}
			}
		}
	}
	else
	{
		if( page == 2 )
		{
			len = format(MenuBody, 511, "\yFull total top stats \r2/2^n");
			for( i = INFO_ZERO; i < NSHOW; i++ )
			{
				format( view_names[id][i], 32, top_names[i] );
				view_distance[id][i] = top_distance[i];
				view_maxspeed[id][i] = top_maxspeed[i];
				view_prestrafe[id][i] = top_prestrafe[i];
				view_strafes[id][i] = top_strafes[i];
				view_sync[id][i] = top_sync[i];
				format( view_type[id][i], 4, top_type[i] );
				format( view_pretype[id][i], 31, top_pretype[i] );
				if( i > 4 )
				{
					len += format(MenuBody[len], 511-len, "^n\r%d. \y%d. \w%s \r%d \d%s", (i-4), (i+1), view_names[id][i], (view_distance[id][i]/1000000), view_type[id][i]);
					if( (i-5) )
						keys |= (1<<(i-5));
					else
						keys = (1<<0);
				}
			}
			len += format(MenuBody[len], 511-len, "^n^n\r9. \wBack");
			keys |= (1<<8);
		}
		else if( page )
		{
			len = format(MenuBody, 511, "\yFull total top stats \r1/2^n");
			for( i = INFO_ZERO; i < 5; i++ )
			{
				format( view_names[id][i], 32, top_names[i] );
				view_distance[id][i] = top_distance[i];
				view_maxspeed[id][i] = top_maxspeed[i];
				view_prestrafe[id][i] = top_prestrafe[i];
				view_strafes[id][i] = top_strafes[i];
				view_sync[id][i] = top_sync[i];
				format( view_type[id][i], 4, top_type[i] );
				format( view_pretype[id][i], 31, top_pretype[i] );
				len += format(MenuBody[len], 511-len, "^n\r%d. \y%d. \w%s \r%d \d%s", (i+1), (i+1), view_names[id][i], (view_distance[id][i]/1000000), view_type[id][i]);
				if( i )
					keys |= (1<<i);
				else
					keys = (1<<0);
			}
			len += format(MenuBody[len], 511-len, "^n^n\r9. \wNext");
			keys |= (1<<8);
		}
		else
		{
			len = format(MenuBody, 511, "\yFull total top stats \r1/1^n");
			if( top_distance[9] )
			{
				display_full_top_stats_menu(id, toptype, 1);
				return;
			}
			
			new limit;
			for( limit = INFO_ZERO; limit < NSHOW; limit++ )
			{
				if( !top_distance[limit] )
					break;
			}
			
			if( limit == 1 )
			{
				format( view_names[id][0], 32, top_names[0] );
				view_distance[id][0] = top_distance[0];
				view_maxspeed[id][0] = top_maxspeed[0];
				view_prestrafe[id][0] = top_prestrafe[0];
				view_strafes[id][0] = top_strafes[0];
				view_sync[id][0] = top_sync[0];
				format( view_type[id][0], 4, top_type[0] );
				format( view_pretype[id][0], 31, top_pretype[0] );
				len += format(MenuBody[len], 511-len, "^n\r1. \y1. \w%s \r%d \d%s", view_names[id][0], (view_distance[id][0]/1000000), view_type[id][0]);
				keys = (1<<0);
			}
			else
			{
				for( i = INFO_ZERO; i < limit; i++ )
				{
					format( view_names[id][i], 32, top_names[i] );
					view_distance[id][i] = top_distance[i];
					view_maxspeed[id][i] = top_maxspeed[i];
					view_prestrafe[id][i] = top_prestrafe[i];
					view_strafes[id][i] = top_strafes[i];
					view_sync[id][i] = top_sync[i];
					format( view_type[id][i], 4, top_type[i] );
					format( view_pretype[id][i], 31, top_pretype[i] );
					len += format(MenuBody[len], 511-len, "^n\r%d. \y%d. \w%s \r%d \d%s", (i+1), (i+1), view_names[id][i], (view_distance[id][i]/1000000), view_type[id][i]);
					if( i )
						keys |= (1<<i);
					else
						keys = (1<<0);
				}
			}
		}
	}
	len += format(MenuBody[len], 511-len, "^n^n\r0. \wExit");
	keys |= (1<<9);
	show_menu(id, keys, MenuBody, -1, "Full top stats");
}

public FullTopMenu_Select(id, key)
{
	new target = key, jumpschanged, nofirstjump, i, menu_continue = INFO_ONE, page = full_top_stats_selected_page[id], jumptype = full_top_stats_selected_type[id], ljtops = get_pcvar_num(kz_ljs_tops);
	key += 1;
	
	if( key == 10 )
		return PLUGIN_HANDLED;
	
	if( page == 2 )
		target += 5;
	
	if( !(get_pcvar_num(kz_ljs_enabled) && (ljtops == 2 || ljtops == 3)) )
	{
		if( !(ljtops == 2 || ljtops == 3) )
			client_print(id, print_chat, "[XJ] Tops are not valid. Tops have been disabled.");
		else
			client_print(id, print_chat, "[XJ] Tops are not valid. Plugin has been disabled.");
		return PLUGIN_HANDLED;
	}
	
	for( i = INFO_ZERO; i < 5; i++ )
	{
		if( jumptype == 3 )
		{
			if( !i && !bj_distance[i] )
			{
				nofirstjump = INFO_ONE;
				jumpschanged = INFO_ONE;
				break;
			}
			else if( !equal(view_names[id][i], bj_names[i]) 
			|| view_distance[id][i] != bj_distance[i]
			|| view_maxspeed[id][i] != bj_maxspeed[i]
			|| view_prestrafe[id][i] != bj_prestrafe[i]
			|| view_strafes[id][i] != bj_strafes[i]
			|| view_sync[id][i] != bj_sync[i]
			|| !equal(view_pretype[id][i], bj_pretype[i]) )
			{
				jumpschanged = INFO_ONE;
				break;
			}
		}
		else if( jumptype == 2 )
		{
			if( !i && !cj_distance[i] )
			{
				nofirstjump = INFO_ONE;
				jumpschanged = INFO_ONE;
				break;
			}
			else if( !equal(view_names[id][i], cj_names[i]) 
			|| view_distance[id][i] != cj_distance[i]
			|| view_maxspeed[id][i] != cj_maxspeed[i]
			|| view_prestrafe[id][i] != cj_prestrafe[i]
			|| view_strafes[id][i] != cj_strafes[i]
			|| view_sync[id][i] != cj_sync[i]
			|| !equal(view_pretype[id][i], cj_pretype[i]) )
			{
				jumpschanged = INFO_ONE;
				break;
			}
		}
		else if( jumptype )
		{
			if( !i && !lj_distance[i] )
			{
				nofirstjump = INFO_ONE;
				jumpschanged = INFO_ONE;
				break;
			}
			else if( !equal(view_names[id][i], lj_names[i]) 
			|| view_distance[id][i] != lj_distance[i]
			|| view_maxspeed[id][i] != lj_maxspeed[i]
			|| view_prestrafe[id][i] != lj_prestrafe[i]
			|| view_strafes[id][i] != lj_strafes[i]
			|| view_sync[id][i] != lj_sync[i]
			|| !equal(view_pretype[id][i], lj_pretype[i]) )
			{
				jumpschanged = INFO_ONE;
				break;
			}
		}
		else
		{
			if( !i && !top_distance[i] )
			{
				nofirstjump = INFO_ONE;
				jumpschanged = INFO_ONE;
				break;
			}
			else if( !equal(view_names[id][i], top_names[i]) 
			|| view_distance[id][i] != top_distance[i]
			|| view_maxspeed[id][i] != top_maxspeed[i]
			|| view_prestrafe[id][i] != top_prestrafe[i]
			|| view_strafes[id][i] != top_strafes[i]
			|| view_sync[id][i] != top_sync[i]
			|| !equal(view_type[id][i], top_type[i])
			|| !equal(view_pretype[id][i], top_pretype[i]) )
			{
				jumpschanged = INFO_ONE;
				break;
			}
		}
	}
	
	if( nofirstjump )
	{
		if( jumptype == 3 )
			client_print(id, print_chat, "[XJ] Bj top is not valid. Jumps have been reseted (no bjs).");
		else if( jumptype == 2 )
			client_print(id, print_chat, "[XJ] Cj top is not valid. Jumps have been reseted (no cjs).");
		else if( jumptype )
			client_print(id, print_chat, "[XJ] Lj top is not valid. Jumps have been reseted (no ljs).");
		else
			client_print(id, print_chat, "[XJ] Tops are not valid. Jumps have been reseted (no jumps).");
		menu_continue = INFO_ZERO;
	}
	else if( page && key == 9 )
	{
		if( page == 2 )
			full_top_stats_selected_page[id] = 0;
		else if( jumpschanged )
		{
			if( jumptype == 3 )
				client_print(id, print_chat, "[XJ] First 5 bjs have been changed. You are redirected to menu start.");
			else if( jumptype == 2 )
				client_print(id, print_chat, "[XJ] First 5 cjs have been changed. You are redirected to menu start.");
			else if( jumptype )
				client_print(id, print_chat, "[XJ] First 5 ljs have been changed. You are redirected to menu start.");
			else
				client_print(id, print_chat, "[XJ] First 5 jumps have been changed. You are redirected to menu start.");
			full_top_stats_selected_page[id] = 0;
		}
		else
		{
			if( jumptype == 3 && bj_distance[9] )
				full_top_stats_selected_page[id] = 2;
			else if( jumptype == 2 && cj_distance[9] )
				full_top_stats_selected_page[id] = 2;
			else if( jumptype && lj_distance[9] )
				full_top_stats_selected_page[id] = 2;
			else if( !jumptype && top_distance[9] )
				full_top_stats_selected_page[id] = 2;
			else
			{
				client_print(id, print_chat, "[XJ] All jumps have been changed. You are redirected to menu start.");
				full_top_stats_selected_page[id] = 0;
			}
		}
	}
	else
	{
		if( jumpschanged && page == 2 )
		{
			if( jumptype == 3 )
				client_print(id, print_chat, "[XJ] First 5 bjs have been changed. You are redirected to menu start.");
			else if( jumptype == 2 )
				client_print(id, print_chat, "[XJ] First 5 cjs have been changed. You are redirected to menu start.");
			else if( jumptype )
				client_print(id, print_chat, "[XJ] First 5 ljs have been changed. You are redirected to menu start.");
			else
				client_print(id, print_chat, "[XJ] First 5 jumps have been changed. You are redirected to menu start.");
			full_top_stats_selected_page[id] = 0;
		}
		else if( page == 2 )
		{
			if( jumptype == 3 && bj_distance[9] )
				full_top_stats_selected_page[id] = 2;
			else if( jumptype == 2 && cj_distance[9] )
				full_top_stats_selected_page[id] = 2;
			else if( jumptype && lj_distance[9] )
				full_top_stats_selected_page[id] = 2;
			else if( !jumptype && top_distance[9] )
				full_top_stats_selected_page[id] = 2;
			else
			{
				client_print(id, print_chat, "[XJ] All jumps have been changed. You are redirected to menu start.");
				full_top_stats_selected_page[id] = 0;
			}
		}
		else
			full_top_stats_selected_page[id] = 0;
	}
	
	if( !(page && key == 9) )
		show_player_stats(id, target, jumptype);
	
	if( menu_continue )
		display_full_top_stats_menu(id, jumptype, full_top_stats_selected_page[id]);
	
	return PLUGIN_HANDLED;
}

public show_player_stats(id, target, toptype)
{
	new buffer[2368], name[131], len, motdname[64];
	if( toptype == 3 )
		format(motdname, 63, "%s's bj", view_names[id][target]);
	else if( toptype == 2 )
		format(motdname, 63, "%s's cj", view_names[id][target]);
	else if( toptype )
		format(motdname, 63, "%s's lj", view_names[id][target]);
	else
		format(motdname, 63, "%s's jump", view_names[id][target]);
	
	len = format(buffer, 2367, "<body bgcolor=#94AEC6><table width=100%% cellpadding=2 cellspacing=0 border=0>");
	len += format(buffer[len], 2367-len, "<tr  align=left bgcolor=#52697B><th width=50%%> Info name <th width=50%% align=left> Value");
	
	format(name, 31, "%s", view_names[id][target]);
	while( containi(name, "<") != -1 )
		replace(name, 129, "<", "&lt;");
	while( containi(name, ">") != -1 )
		replace(name, 129, ">", "&gt;");
	
	if( toptype == 3 )
		len += format(buffer[len], 2367-len, "<tr align=left bgcolor=#A4BED6><td> Top type: <td align=left> BhopJump top");
	else if( toptype == 2 )
		len += format(buffer[len], 2367-len, "<tr align=left bgcolor=#A4BED6><td> Top type: <td align=left> CountJump top");
	else if( toptype == 1 )
		len += format(buffer[len], 2367-len, "<tr align=left bgcolor=#A4BED6><td> Top type: <td align=left> LongJump top");
	else
		len += format(buffer[len], 2367-len, "<tr align=left bgcolor=#A4BED6><td> Top type: <td align=left> Total top");
	
	len += format(buffer[len], 2367-len, "<tr align=left><td> Position: <td align=left> #%d", (target+1));
	len += format(buffer[len], 2367-len, "<tr align=left bgcolor=#A4BED6><td> Name: <td align=left> %s", name);
	len += format(buffer[len], 2367-len, "<tr align=left><td> Distance: <td align=left> %d.%06d", (view_distance[id][target]/1000000), (view_distance[id][target]%1000000));
	len += format(buffer[len], 2367-len, "<tr align=left bgcolor=#A4BED6><td> TopSpeed: <td align=left> %d.%06d", (view_maxspeed[id][target]/1000000), (view_maxspeed[id][target]%1000000));
	len += format(buffer[len], 2367-len, "<tr align=left><td> PreStrafe: <td align=left> %d.%06d", (view_prestrafe[id][target]/1000000), (view_prestrafe[id][target]%1000000));
	len += format(buffer[len], 2367-len, "<tr align=left bgcolor=#A4BED6><td> Strafes: <td align=left> %d", view_strafes[id][target]);
	len += format(buffer[len], 2367-len, "<tr align=left><td> Sync: <td align=left> %d", view_sync[id][target]);
	len += format(buffer[len], 2367-len, "<tr align=left bgcolor=#A4BED6><td> PreType: <td align=left> %s", view_pretype[id][target]);
	
	if( !toptype ) //TODO bhop?
		len += format(buffer[len], 2367-len, "<tr align=left><td> Jump Type: <td align=left> %s", (equal(view_type[id][target], "cj")) ? "CountJump" : "LongJump");
	
	len += format(buffer[len], 2367-len, "</table></body>");
	
	show_motd(id, buffer, motdname);
}

public cmdLjsMenu(id)
{
	new plugin_cvar = get_pcvar_num(kz_ljs_enabled);
	new ljtop_cvar = get_pcvar_num(kz_ljs_tops);
	new MenuBody[512], len, keys;
	len = format(MenuBody, 511, "\yLongJump Stats Menu^n");
	
	if( !plugin_cvar )
	{
		len += format(MenuBody[len], 511-len, "^n\r1. \dSwitch colorchat (plugin off)");
		len += format(MenuBody[len], 511-len, "^n\r2. \dSwitch ljstats (plugin off)");
		len += format(MenuBody[len], 511-len, "^n\r3. \dSwitch speed (plugin off)");
		len += format(MenuBody[len], 511-len, "^n\r4. \dView tops (plugin off)");
	}
	else
	{
		len += format(MenuBody[len], 511-len, "^n\r1. \wSwitch colorchat");
		len += format(MenuBody[len], 511-len, "^n\r2. \wSwitch ljstats");
		len += format(MenuBody[len], 511-len, "^n\r3. \wSwitch speed");
		if( (ljtop_cvar == 2 || ljtop_cvar == 3) && (map_distance[0] || lj_distance[0] || cj_distance[0] || bj_distance[0] || sbj_distance[0]) )
		{
			len += format(MenuBody[len], 511-len, "^n^n\r4. \wView tops");
			keys = (1<<0|1<<1|1<<2|1<<3);
		}
		else
		{
			if( !(map_distance[0] || lj_distance[0] || cj_distance[0] || bj_distance[0] || sbj_distance[0]) )
				len += format(MenuBody[len], 511-len, "^n\r4. \dView tops (no jumps)");
			else
				len += format(MenuBody[len], 511-len, "^n\r4. \dView tops (disabled)");
			keys = (1<<0|1<<1|1<<2);
		}
	}
	
	len += format(MenuBody[len], 511-len, "^n^n\r5. \wPrint plugin info");
	if( !plugin_cvar )
		keys = (1<<4);
	else
		keys |= (1<<4);
	
	new flags = get_user_flags(id);
	if( flags&ADMIN_MENU && (flags&ADMIN_CFG || flags&ADMIN_CVAR) )
		len += format(MenuBody[len], 511-len, "^n^n^n\rAdmin menu^n");
	
	if( flags&ADMIN_MENU )
	{
		if( flags&ADMIN_CFG )
		{
			len += format(MenuBody[len], 511-len, "^n\r6. \yServer configurations");
			keys |= (1<<5);
		}
		
		if( flags&ADMIN_CVAR )
		{
			len += format(MenuBody[len], 511-len, "^n\r7. \yOne map config");
			keys |= (1<<6);
		}
	}
	
	len += format(MenuBody[len], 511-len, "^n^n\r0. \wExit");
	keys |= (1<<9);
	
	show_menu(id, keys, MenuBody, -1, "LongJump Stats Menu");
	
	return ( (get_pcvar_num(kz_ljs_viscmds))?PLUGIN_CONTINUE:PLUGIN_HANDLED );
}

public LjsMenu_Select(id, key)
{
	switch((key+1))
	{
		case 1:
		{
			if( get_pcvar_num(kz_ljs_enabled) )
					cmdColorChat(id);
			cmdLjsMenu(id);
		}
		case 2:
		{
			if( get_pcvar_num(kz_ljs_enabled) )
				cmdLjStats(id);
			cmdLjsMenu(id);
		}
		case 3:
		{
			if( get_pcvar_num(kz_ljs_enabled) )
				cmdSpeed(id);
			cmdLjsMenu(id);
		}
		case 4:
		{
			if( get_pcvar_num(kz_ljs_enabled) )
				cmdTopMenu(id);
			else
				cmdLjsMenu(id);
		}
		case 5: cmdVersion(id);
		case 6:
		{
			if( get_user_flags(id)&ADMIN_CFG && get_user_flags(id)&ADMIN_MENU )
				ColorChat(id, RED, "[XJ] Comming soon!");
			else
				cmdLjsMenu(id);
		}
		case 7:
		{
			if( get_user_flags(id)&ADMIN_CVAR && get_user_flags(id)&ADMIN_MENU )
				ColorChat(id, BLUE, "[XJ] Comming soon!");
			else
				cmdLjsMenu(id);
		}
	}
	return PLUGIN_HANDLED;
}

public read_tops()
{
	static lj_filename[128], cj_filename[128], bj_filename[128], sbj_filename[128], wj_filename[128];
	format(lj_filename, 127, "%s/Top10_lj.dat", ljsDir);
	format(cj_filename, 127, "%s/Top10_cj.dat", ljsDir);
	format(bj_filename, 127, "%s/Top10_bj.dat", ljsDir);
	format(sbj_filename, 127, "%s/Top10_sbj.dat", ljsDir);
	format(wj_filename, 127, "%s/Top10_wj.dat", ljsDir);
	
	static distance[12], maxspeed[12], prestrafe[12], strafes[6], sync[6], line = 0, txtsize = 0, i;

	line = 0;
	if( file_exists(wj_filename) )
	{
		for( i = INFO_ZERO ; i < NTOP; i++ )
		{
			if( (line=read_file(wj_filename,line,wj_names[i],32,txtsize))!=0 )
			{
				if( (line=read_file(wj_filename,line,wj_authid[i],32,txtsize))!=0 )
				{
					if( (line=read_file(wj_filename,line,distance,11,txtsize))!=0 )
					{
						if( (line=read_file(wj_filename,line,maxspeed,11,txtsize))!=0 )
						{
							if( (line=read_file(wj_filename,line,prestrafe,11,txtsize))!=0 )
							{
								if( (line=read_file(wj_filename,line,strafes,5,txtsize))!=0 )
								{
									if( (line=read_file(wj_filename,line,sync,5,txtsize))!=0 )
									{
										if( (line=read_file(wj_filename,line,wj_pretype[i],31,txtsize))!=0 )
										{
											wj_distance[i] = str_to_num( distance );
											wj_maxspeed[i] = str_to_num( maxspeed );
											wj_prestrafe[i] = str_to_num( prestrafe );
											wj_strafes[i] = str_to_num( strafes );
											wj_sync[i] = str_to_num( sync );
										}
									}
								}
							}
						}
					}
				}
			}
			else
				break;
		}
	}

	line = 0;
	if( file_exists(lj_filename) )
	{
		for( i = INFO_ZERO ; i < NTOP; i++ )
		{
			if( (line=read_file(lj_filename,line,lj_names[i],32,txtsize))!=0 )
			{
				if( (line=read_file(lj_filename,line,lj_authid[i],32,txtsize))!=0 )
				{
					if( (line=read_file(lj_filename,line,distance,11,txtsize))!=0 )
					{
						if( (line=read_file(lj_filename,line,maxspeed,11,txtsize))!=0 )
						{
							if( (line=read_file(lj_filename,line,prestrafe,11,txtsize))!=0 )
							{
								if( (line=read_file(lj_filename,line,strafes,5,txtsize))!=0 )
								{
									if( (line=read_file(lj_filename,line,sync,5,txtsize))!=0 )
									{
										if( (line=read_file(lj_filename,line,lj_pretype[i],31,txtsize))!=0 )
										{
											lj_distance[i] = str_to_num( distance );
											lj_maxspeed[i] = str_to_num( maxspeed );
											lj_prestrafe[i] = str_to_num( prestrafe );
											lj_strafes[i] = str_to_num( strafes );
											lj_sync[i] = str_to_num( sync );
										}
									}
								}
							}
						}
					}
				}
			}
			else
				break;
		}
	}
	
	line = 0;
	if( file_exists(cj_filename) )
	{
		for( i = INFO_ZERO ; i < NTOP; i++ )
		{
			if( (line=read_file(cj_filename,line,cj_names[i],32,txtsize))!=0 )
			{
				if( (line=read_file(cj_filename,line,cj_authid[i],32,txtsize))!=0 )
				{
					if( (line=read_file(cj_filename,line,distance,11,txtsize))!=0 )
					{
						if( (line=read_file(cj_filename,line,maxspeed,11,txtsize))!=0 )
						{
							if( (line=read_file(cj_filename,line,prestrafe,11,txtsize))!=0 )
							{
								if( (line=read_file(cj_filename,line,strafes,5,txtsize))!=0 )
								{
									if( (line=read_file(cj_filename,line,sync,5,txtsize))!=0 )
									{
										if( (line=read_file(cj_filename,line,cj_pretype[i],31,txtsize))!=0 )
										{
											cj_distance[i] = str_to_num( distance );
											cj_maxspeed[i] = str_to_num( maxspeed );
											cj_prestrafe[i] = str_to_num( prestrafe );
											cj_strafes[i] = str_to_num( strafes );
											cj_sync[i] = str_to_num( sync );
										}
									}
								}
							}
						}
					}
				}
			}
			else
				break;
		}
	}
	line = 0;
	if( file_exists(bj_filename) )
	{
		for( i = INFO_ZERO ; i < NTOP; i++ )
		{
			if( (line=read_file(bj_filename,line,bj_names[i],32,txtsize))!=0 )
			{
				if( (line=read_file(bj_filename,line,bj_authid[i],32,txtsize))!=0 )
				{
					if( (line=read_file(bj_filename,line,distance,11,txtsize))!=0 )
					{
						if( (line=read_file(bj_filename,line,maxspeed,11,txtsize))!=0 )
						{
							if( (line=read_file(bj_filename,line,prestrafe,11,txtsize))!=0 )
							{
								if( (line=read_file(bj_filename,line,strafes,5,txtsize))!=0 )
								{
									if( (line=read_file(bj_filename,line,sync,5,txtsize))!=0 )
									{
										if( (line=read_file(bj_filename,line,bj_pretype[i],31,txtsize))!=0 )
										{
											bj_distance[i] = str_to_num( distance );
											bj_maxspeed[i] = str_to_num( maxspeed );
											bj_prestrafe[i] = str_to_num( prestrafe );
											bj_strafes[i] = str_to_num( strafes );
											bj_sync[i] = str_to_num( sync );
										}
									}
								}
							}
						}
					}
				}
			}
			else
				break;
		}
	}

	line = 0;
	if( file_exists(sbj_filename) )
	{
		for( i = INFO_ZERO ; i < NTOP; i++ )
		{
			if( (line=read_file(sbj_filename,line,sbj_names[i],32,txtsize))!=0 )
			{
				if( (line=read_file(sbj_filename,line,sbj_authid[i],32,txtsize))!=0 )
				{
					if( (line=read_file(sbj_filename,line,distance,11,txtsize))!=0 )
					{
						if( (line=read_file(sbj_filename,line,maxspeed,11,txtsize))!=0 )
						{
							if( (line=read_file(sbj_filename,line,prestrafe,11,txtsize))!=0 )
							{
								if( (line=read_file(sbj_filename,line,strafes,5,txtsize))!=0 )
								{
									if( (line=read_file(sbj_filename,line,sync,5,txtsize))!=0 )
									{
										if( (line=read_file(sbj_filename,line,sbj_pretype[i],31,txtsize))!=0 )
										{
											sbj_distance[i] = str_to_num( distance );
											sbj_maxspeed[i] = str_to_num( maxspeed );
											sbj_prestrafe[i] = str_to_num( prestrafe );
											sbj_strafes[i] = str_to_num( strafes );
											sbj_sync[i] = str_to_num( sync );
										}
									}
								}
							}
						}
					}
				}
			}
			else
				break;
		}
	}
	return PLUGIN_HANDLED;
}

public topreset(id)
{
	if( id == (is_dedicated_server()?0:1) || (get_user_flags(id)&ADMIN_RCON && tops_save) || (get_user_flags(id)&ADMIN_MAP && !tops_save) )
	{
		static lj_filename[128], cj_filename[128], bj_filename[128], sbj_filename[128], wj_filename[128];
		format(lj_filename, 127, "%s/Top10_lj.dat", ljsDir);
		format(cj_filename, 127, "%s/Top10_cj.dat", ljsDir);
		format(bj_filename, 127, "%s/Top10_bj.dat", ljsDir);
		format(sbj_filename, 127, "%s/Top10_sbj.dat", ljsDir);
		format(wj_filename, 127, "%s/Top10_wj.dat", ljsDir);
		
		if( file_exists(lj_filename) && tops_save )
			delete_file(lj_filename);
		if( file_exists(cj_filename) && tops_save )
			delete_file(cj_filename);
		if( file_exists(bj_filename) && tops_save )
			delete_file(bj_filename);
		if( file_exists(sbj_filename) && tops_save )
			delete_file(sbj_filename);
		if( file_exists(wj_filename) && tops_save )
			delete_file(wj_filename);
		
		static info_none[33], i;
		info_none = "";
		for( i = INFO_ZERO; i < NTOP; i++ )
		{
			format( map_names[i], 32, info_none );
			format( map_authid[i], 32, info_none );
			map_distance[i] = INFO_ZERO;
			map_maxspeed[i] = INFO_ZERO;
			map_prestrafe[i] = INFO_ZERO;
			map_strafes[i] = INFO_ZERO;
			map_sync[i] = INFO_ZERO;
			format( map_type[i], 32, info_none );
			
			format( lj_names[i], 32, info_none );
			format( lj_authid[i], 32, info_none );
			lj_distance[i] = INFO_ZERO;
			lj_maxspeed[i] = INFO_ZERO;
			lj_prestrafe[i] = INFO_ZERO;
			lj_strafes[i] = INFO_ZERO;
			lj_sync[i] = INFO_ZERO;
			
			format( cj_names[i], 32, info_none );
			format( cj_authid[i], 32, info_none );
			cj_distance[i] = INFO_ZERO;
			cj_maxspeed[i] = INFO_ZERO;
			cj_prestrafe[i] = INFO_ZERO;
			cj_strafes[i] = INFO_ZERO;
			cj_sync[i] = INFO_ZERO;

			format( bj_names[i], 32, info_none );
			format( bj_authid[i], 32, info_none );
			bj_distance[i] = INFO_ZERO;
			bj_maxspeed[i] = INFO_ZERO;
			bj_prestrafe[i] = INFO_ZERO;
			bj_strafes[i] = INFO_ZERO;
			bj_sync[i] = INFO_ZERO;

			format( sbj_names[i], 32, info_none );
			format( sbj_authid[i], 32, info_none );
			sbj_distance[i] = INFO_ZERO;
			sbj_maxspeed[i] = INFO_ZERO;
			sbj_prestrafe[i] = INFO_ZERO;
			sbj_strafes[i] = INFO_ZERO;
			sbj_sync[i] = INFO_ZERO;

			format( wj_names[i], 32, info_none );
			format( wj_authid[i], 32, info_none );
			wj_distance[i] = INFO_ZERO;
			wj_maxspeed[i] = INFO_ZERO;
			wj_prestrafe[i] = INFO_ZERO;
			wj_strafes[i] = INFO_ZERO;
			wj_sync[i] = INFO_ZERO;
		}

		static name[32], authid[32];
		name = "";
		authid = "";
		get_user_name( id, name, 31 );
		if( get_pcvar_num(kz_ljs_rank_by) == 1 )
			get_user_authid( id, authid ,31 );
		else
			get_user_ip( id, authid, 31, 1);
		
		log_amx("LjS: ^"%s<%d><%s>^" reseted ljtop", name, get_user_userid(id), authid);
		
		console_print(id, "[XJ] LongJump top and rec reseted!");
		client_print(0, print_chat, "[XJ] LongJump top and rec reseted!");
	}
	else
		console_print(id, "%L", id, "NO_ACC_COM");
	
	return PLUGIN_HANDLED;
}

public check_maintop(id, Distance, MaxAirSpeed, MaxGroundSpeed, strafes, sync, type)
{
	static jumptype[5], editional_top_n, rankby, top_num;
	rankby = get_pcvar_num(kz_ljs_rank_by);
	
	static name[33], authid[33];
	get_user_name( id, name, 32 );

	if( rankby == 1 )
		get_user_authid(id, authid ,32);
	else if( rankby == 2 )
		get_user_ip(id, authid, 32, 1);
	else
		get_user_name(id, authid, 32);

	editional_top_n = 0;
	top_num = 0;
	
	if( type == TYPE_WJ )
	{
		editional_top_n = check_wjtop(id, Distance, MaxAirSpeed, MaxGroundSpeed, strafes, sync, rankby);
		jumptype = "wj";
		if ( Distance > floatround(get_pcvar_float(kz_min_lj_c)*1000000) ) //TODO mb another cvar _c ?
		{
			top_num	= 255;
		}

		if( tops_save && editional_top_n)
		{
			save_tops(TOP_WJ);
		}
	}
	else if( type == TYPE_CJ )
	{
		editional_top_n = check_cjtop(id, Distance, MaxAirSpeed, MaxGroundSpeed, strafes, sync, rankby);
		jumptype = "cj";
		if ( Distance > floatround(get_pcvar_float(kz_min_lj_c)*1000000) )
		{
			top_num	= 255;
		}

		if( tops_save && editional_top_n)
		{
			save_tops(TOP_CJ);
		}
	}
	else if( type == TYPE_LJ || type == TYPE_HJ) //TODO: remove this after adding of hj top
	{
		editional_top_n = check_ljtop(id, Distance, MaxAirSpeed, MaxGroundSpeed, strafes, sync, rankby);
		jumptype = "lj";
		if ( Distance > floatround(get_pcvar_float(kz_min_lj_c)*1000000) )
		{
			top_num	= 255;
		}

		if( tops_save && editional_top_n)
		{
			save_tops(TOP_LJ);
		}
	}
	else if( type == TYPE_BJ )
	{
		editional_top_n = check_bjtop(id, Distance, MaxAirSpeed, MaxGroundSpeed, strafes, sync, rankby);
		jumptype = "bj";
		if ( Distance > floatround(get_pcvar_float(kz_min_bhop_c)*1000000) )
		{
			top_num	= 255;
		}

		if( tops_save && editional_top_n)
		{
			save_tops(TOP_BJ);
		}
	}
	else if( type == TYPE_SBJ )
	{
		editional_top_n = check_sbjtop(id, Distance, MaxAirSpeed, MaxGroundSpeed, strafes, sync, rankby);
		jumptype = "sbj";
		if ( Distance > floatround(get_pcvar_float(kz_min_bhop_c)*1000000) )
		{
			top_num	= 255;
		}

		if( tops_save && editional_top_n)
		{
			save_tops(TOP_SBJ);
		}
	}

	//TODO: can be deprectaed to "top_num" from "top_num == 255"
	if( top_num == 255 && Distance > map_distance[NSHOW-1] && get_pcvar_num(kz_ljs_maptop) )
	{
		top_num = 0;
		static i;
		for( i = INFO_ZERO; i < NSHOW; i++ )
		{
			if( Distance > map_distance[i] )
			{
				static pos, j;
				pos = i;
				j = 0;
				while( !equal( map_authid[pos], authid ) && pos < NSHOW-1 )
					pos++ ;
				for( j = pos; j > i; j-- )
				{
					format( map_names[j], 32, map_names[j-1] );
					format( map_authid[j], 32, map_authid[j-1] );
					map_distance[j] = map_distance[j-1];
					map_maxspeed[j] = map_maxspeed[j-1];
					map_prestrafe[j] = map_prestrafe[j-1];
					map_strafes[j] = map_strafes[j-1];
					map_sync[j] = map_sync[j-1];
					format( map_type[j], 4, map_type[j-1] );
					format( map_pretype[j], 31, map_pretype[j-1] );
				}
				
				format( map_names[i], 32, name );
				format( map_authid[i], 32, authid );
				map_distance[i] = Distance;
				map_maxspeed[i] = MaxAirSpeed;
				map_prestrafe[i] = MaxGroundSpeed;
				map_strafes[i] = strafes;
				map_sync[i] = sync;
				format( map_type[i], 4, jumptype );
				format( map_pretype[i], 31, pre_type[id] );
				top_num = i+1;
				
				break;
			}
			else if( equal( map_authid[i], authid ) )
			{
				top_num = 0;
				break;
			}
		}
	}
	else
	{
		top_num = 0;
	}

	if( (get_pcvar_num(kz_ljs_tops) == 2 || get_pcvar_num(kz_ljs_tops) == 3) )
	{
		if( top_num && editional_top_n )
		{
			if (top_num == editional_top_n)
			{
				ColorChat(0, NORMAL, "[XJ]^x04 %s^x01 now is^x04 %d^x01 in map^x04 & %s^x01 top with^x04 %d.%03d^x01 jump!", name, top_num, jumptype, (Distance/1000000), (Distance%1000000/1000));
			}
			else
			{
				ColorChat(0, NORMAL, "[XJ]^x04 %s^x01 now is^x04 %d^x01 in map top &^x04 %d^x01 in^x04 %s^x01 top with^x04 %d.%03d^x01 jump!", name, top_num, editional_top_n, jumptype, (Distance/1000000), (Distance%1000000/1000));				
			}
		}
		else if( top_num && top_num < MAPSHOW )
		{
			ColorChat(0, NORMAL, "[XJ]^x04 %s^x01 now is^x04 %d^x01 in map top with^x04 %d.%03d %s^x01 jump!", name, top_num, (Distance/1000000), (Distance%1000000), jumptype);
		}
		else if( editional_top_n && editional_top_n <= NSHOW )
		{
			ColorChat(0, NORMAL, "[XJ]^x04 %s^x01 now is^x04 %d^x01 in^x04 %s^x01 top with^x04 %d.%03d^x01 jump!", name, editional_top_n, jumptype, (Distance/1000000), (Distance%1000000));
		}
	}
}

public check_sbjtop(id, Distance, MaxAirSpeed, MaxGroundSpeed, strafes, sync, rankby)
{
	static name[32], authid[32];
	get_user_name( id, name, 31 );
	if( rankby == 1 )
		get_user_authid(id, authid ,31);
	else if( rankby == 2 )
		get_user_ip(id, authid, 31, 1);
	else
		get_user_name(id, authid, 31);
	
	if( Distance > sbj_distance[NTOP-1] )
	{
		static i;
		for( i = INFO_ZERO; i < NTOP; i++ )
		{
			if( Distance > sbj_distance[i] )
			{
				static pos, j;
				pos = i;
				j = 0;
				while( !equal( sbj_authid[pos], authid ) && pos < NTOP-1 )
					pos++ ;
				for( j = pos; j > i; j-- )
				{
					format( sbj_names[j], 32, sbj_names[j-1] );
					format( sbj_authid[j], 32, sbj_authid[j-1] );
					sbj_distance[j] = sbj_distance[j-1];
					sbj_maxspeed[j] = sbj_maxspeed[j-1];
					sbj_prestrafe[j] = sbj_prestrafe[j-1];
					sbj_strafes[j] = sbj_strafes[j-1];
					sbj_sync[j] = sbj_sync[j-1];
					format( sbj_pretype[j], 31, sbj_pretype[j-1] );
				}
				
				format( sbj_names[i], 32, name );
				format( sbj_authid[i], 32, authid );
				sbj_distance[i] = Distance;
				sbj_maxspeed[i] = MaxAirSpeed;
				sbj_prestrafe[i] = MaxGroundSpeed;
				sbj_strafes[i] = strafes;
				sbj_sync[i] = sync;
				format( sbj_pretype[i], 31, pre_type[id] );
				return (i+1);
				
			}
			else if( equal( sbj_authid[i], authid ) )
				return 0;
		}
	}
	return 0;
}

public check_wjtop(id, Distance, MaxAirSpeed, MaxGroundSpeed, strafes, sync, rankby)
{
	static name[32], authid[32];
	get_user_name( id, name, 31 );
	if( rankby == 1 )
		get_user_authid(id, authid ,31);
	else if( rankby == 2 )
		get_user_ip(id, authid, 31, 1);
	else
		get_user_name(id, authid, 31);
	
	if( Distance > wj_distance[NTOP-1] )
	{
		static i;
		for( i = INFO_ZERO; i < NTOP; i++ )
		{
			if( Distance > wj_distance[i] )
			{
				static pos, j;
				pos = i;
				j = 0;
				while( !equal( wj_authid[pos], authid ) && pos < NTOP-1 )
					pos++ ;
				for( j = pos; j > i; j-- )
				{
					format( wj_names[j], 32, wj_names[j-1] );
					format( wj_authid[j], 32, wj_authid[j-1] );
					wj_distance[j] = wj_distance[j-1];
					wj_maxspeed[j] = wj_maxspeed[j-1];
					wj_prestrafe[j] = wj_prestrafe[j-1];
					wj_strafes[j] = wj_strafes[j-1];
					wj_sync[j] = wj_sync[j-1];
					format( wj_pretype[j], 31, wj_pretype[j-1] );
				}
				
				format( wj_names[i], 32, name );
				format( wj_authid[i], 32, authid );
				wj_distance[i] = Distance;
				wj_maxspeed[i] = MaxAirSpeed;
				wj_prestrafe[i] = MaxGroundSpeed;
				wj_strafes[i] = strafes;
				wj_sync[i] = sync;
				format( wj_pretype[i], 31, pre_type[id] );
				return (i+1);
			}
			else if( equal( wj_authid[i], authid ) )
				return 0;
		}
	}
	return 0;
}

public check_bjtop(id, Distance, MaxAirSpeed, MaxGroundSpeed, strafes, sync, rankby)
{
	static name[32], authid[32];
	get_user_name( id, name, 31 );
	if( rankby == 1 )
		get_user_authid(id, authid ,31);
	else if( rankby == 2 )
		get_user_ip(id, authid, 31, 1);
	else
		get_user_name(id, authid, 31);
	
	if( Distance > bj_distance[NTOP-1] )
	{
		static i;
		for( i = INFO_ZERO; i < NTOP; i++ )
		{
			if( Distance > bj_distance[i] )
			{
				static pos, j;
				pos = i;
				j = 0;
				while( !equal( bj_authid[pos], authid ) && pos < NTOP-1 )
					pos++ ;
				for( j = pos; j > i; j-- )
				{
					format( bj_names[j], 32, bj_names[j-1] );
					format( bj_authid[j], 32, bj_authid[j-1] );
					bj_distance[j] = bj_distance[j-1];
					bj_maxspeed[j] = bj_maxspeed[j-1];
					bj_prestrafe[j] = bj_prestrafe[j-1];
					bj_strafes[j] = bj_strafes[j-1];
					bj_sync[j] = bj_sync[j-1];
					format( bj_pretype[j], 31, bj_pretype[j-1] );
				}
				
				format( bj_names[i], 32, name );
				format( bj_authid[i], 32, authid );
				bj_distance[i] = Distance;
				bj_maxspeed[i] = MaxAirSpeed;
				bj_prestrafe[i] = MaxGroundSpeed;
				bj_strafes[i] = strafes;
				bj_sync[i] = sync;
				format( bj_pretype[i], 31, pre_type[id] );
				return (i+1);
			}
			else if( equal( bj_authid[i], authid ) )
				return 0;
		}
	}
	return 0;
}

public check_cjtop(id, Distance, MaxAirSpeed, MaxGroundSpeed, strafes, sync, rankby)
{
	static name[32], authid[32];
	get_user_name( id, name, 31 );
	if( rankby == 1 )
		get_user_authid(id, authid ,31);
	else if( rankby == 2 )
		get_user_ip(id, authid, 31, 1);
	else
		get_user_name(id, authid, 31);
	
	if( Distance > cj_distance[NTOP-1] )
	{
		static i;
		for( i = INFO_ZERO; i < NTOP; i++ )
		{
			if( Distance > cj_distance[i] )
			{
				static pos, j;
				pos = i;
				j = 0;
				while( !equal( cj_authid[pos], authid ) && pos < NTOP-1 )
					pos++ ;
				for( j = pos; j > i; j-- )
				{
					format( cj_names[j], 32, cj_names[j-1] );
					format( cj_authid[j], 32, cj_authid[j-1] );
					cj_distance[j] = cj_distance[j-1];
					cj_maxspeed[j] = cj_maxspeed[j-1];
					cj_prestrafe[j] = cj_prestrafe[j-1];
					cj_strafes[j] = cj_strafes[j-1];
					cj_sync[j] = cj_sync[j-1];
					format( cj_pretype[j], 31, cj_pretype[j-1] );
				}
				
				format( cj_names[i], 32, name );
				format( cj_authid[i], 32, authid );
				cj_distance[i] = Distance;
				cj_maxspeed[i] = MaxAirSpeed;
				cj_prestrafe[i] = MaxGroundSpeed;
				cj_strafes[i] = strafes;
				cj_sync[i] = sync;
				format( cj_pretype[i], 31, pre_type[id] );
				return (i+1);
				
			}
			else if( equal( cj_authid[i], authid ) )
				return 0;
		}
	}
	return 0;
}

public check_ljtop(id, Distance, MaxAirSpeed, MaxGroundSpeed, strafes, sync, rankby)
{
	static name[32], authid[32];
	get_user_name( id, name, 31 );
	if( rankby == 1 )
		get_user_authid(id, authid ,31);
	else if( rankby == 2 )
		get_user_ip(id, authid, 31, 1);
	else
		get_user_name(id, authid, 31);
	
	if( Distance > lj_distance[NTOP-1] )
	{
		static i;
		for( i = INFO_ZERO; i < NTOP; i++ )
		{
			if( Distance > lj_distance[i] )
			{
				static pos, j;
				pos = i;
				j = 0;
				while( !equal( lj_authid[pos], authid ) && pos < NTOP-1 )
					pos++ ;
				for( j = pos; j > i; j-- )
				{
					format( lj_names[j], 32, lj_names[j-1] );
					format( lj_authid[j], 32, lj_authid[j-1] );
					lj_distance[j] = lj_distance[j-1];
					lj_maxspeed[j] = lj_maxspeed[j-1];
					lj_prestrafe[j] = lj_prestrafe[j-1];
					lj_strafes[j] = lj_strafes[j-1];
					lj_sync[j] = lj_sync[j-1];
					format( lj_pretype[j], 31, lj_pretype[j-1] );
				}
				
				format( lj_names[i], 32, name );
				format( lj_authid[i], 32, authid );
				lj_distance[i] = Distance;
				lj_maxspeed[i] = MaxAirSpeed;
				lj_prestrafe[i] = MaxGroundSpeed;
				lj_strafes[i] = strafes;
				lj_sync[i] = sync;
				format( lj_pretype[i], 31, pre_type[id] );
				return (i+1);
				
			}
			else if( equal( lj_authid[i], authid ) )
				return 0;
		}
	}
	return 0;
}

public save_tops(_top)
{
	static i, distance[12], maxspeed[12], prestrafe[12], strafes[6], sync[6];

	if (_top == TOP_LJ)
	{
		static lj_filename[128];

		format(lj_filename, 127, "%s/Top10_lj.dat", ljsDir);

		if( file_exists(lj_filename) )
			delete_file(lj_filename);

		for( i = INFO_ZERO; i < NTOP; i++ )
		{
			if( lj_distance[i] )
			{
				num_to_str(lj_distance[i], distance, 11);
				num_to_str(lj_maxspeed[i], maxspeed, 11);
				num_to_str(lj_prestrafe[i], prestrafe, 11);
				num_to_str(lj_strafes[i], strafes, 5);
				num_to_str(lj_sync[i], sync, 5);
				write_file(lj_filename, lj_names[i]);
				write_file(lj_filename, lj_authid[i]);
				write_file(lj_filename, distance);
				write_file(lj_filename, maxspeed);
				write_file(lj_filename, prestrafe);
				write_file(lj_filename, strafes);
				write_file(lj_filename, sync);
				write_file(lj_filename, lj_pretype[i]);
			}
		}
	}
	else if (_top == TOP_CJ)
	{
		static cj_filename[128];

		format(cj_filename, 127, "%s/Top10_cj.dat", ljsDir);

		if( file_exists(cj_filename) )
			delete_file(cj_filename);

		for( i = INFO_ZERO; i < NTOP; i++ )
		{
			if( cj_distance[i] )
			{
				num_to_str(cj_distance[i], distance, 11);
				num_to_str(cj_maxspeed[i], maxspeed, 11);
				num_to_str(cj_prestrafe[i], prestrafe, 11);
				num_to_str(cj_strafes[i], strafes, 5);
				num_to_str(cj_sync[i], sync, 5);
				write_file(cj_filename, cj_names[i]);
				write_file(cj_filename, cj_authid[i]);
				write_file(cj_filename, distance);
				write_file(cj_filename, maxspeed);
				write_file(cj_filename, prestrafe);
				write_file(cj_filename, strafes);
				write_file(cj_filename, sync);
				write_file(cj_filename, cj_pretype[i]);
			}
		}

	}
	else if (_top == TOP_WJ)
	{
		static wj_filename[128];

		format(wj_filename, 127, "%s/Top10_wj.dat", ljsDir);

		if( file_exists(wj_filename) )
			delete_file(wj_filename);

		for( i = INFO_ZERO; i < NTOP; i++ )
		{
			if( wj_distance[i] )
			{
				num_to_str(wj_distance[i], distance, 11);
				num_to_str(wj_maxspeed[i], maxspeed, 11);
				num_to_str(wj_prestrafe[i], prestrafe, 11);
				num_to_str(wj_strafes[i], strafes, 5);
				num_to_str(wj_sync[i], sync, 5);
				write_file(wj_filename, wj_names[i]);
				write_file(wj_filename, wj_authid[i]);
				write_file(wj_filename, distance);
				write_file(wj_filename, maxspeed);
				write_file(wj_filename, prestrafe);
				write_file(wj_filename, strafes);
				write_file(wj_filename, sync);
				write_file(wj_filename, wj_pretype[i]);
			}
		}

	}
	else if (_top == TOP_BJ)
	{
		static bj_filename[128];

		format(bj_filename, 127, "%s/Top10_bj.dat", ljsDir);

		if( file_exists(bj_filename) )
			delete_file(bj_filename);

		for( i = INFO_ZERO; i < NTOP; i++ )
		{
			if( bj_distance[i] )
			{
				num_to_str(bj_distance[i], distance, 11);
				num_to_str(bj_maxspeed[i], maxspeed, 11);
				num_to_str(bj_prestrafe[i], prestrafe, 11);
				num_to_str(bj_strafes[i], strafes, 5);
				num_to_str(bj_sync[i], sync, 5);
				write_file(bj_filename, bj_names[i]);
				write_file(bj_filename, bj_authid[i]);
				write_file(bj_filename, distance);
				write_file(bj_filename, maxspeed);
				write_file(bj_filename, prestrafe);
				write_file(bj_filename, strafes);
				write_file(bj_filename, sync);
				write_file(bj_filename, bj_pretype[i]);
			}
		}
	}
	else if (_top == TOP_SBJ)
	{
		static sbj_filename[128];

		format(sbj_filename, 127, "%s/Top10_sbj.dat", ljsDir);

		if( file_exists(sbj_filename) )  
			delete_file(sbj_filename);

		for( i = INFO_ZERO; i < NTOP; i++ )
		{
			if( sbj_distance[i] )
			{
				num_to_str(sbj_distance[i], distance, 11);
				num_to_str(sbj_maxspeed[i], maxspeed, 11);
				num_to_str(sbj_prestrafe[i], prestrafe, 11);
				num_to_str(sbj_strafes[i], strafes, 5);
				num_to_str(sbj_sync[i], sync, 5);
				write_file(sbj_filename, sbj_names[i]);
				write_file(sbj_filename, sbj_authid[i]);
				write_file(sbj_filename, distance);
				write_file(sbj_filename, maxspeed);
				write_file(sbj_filename, prestrafe);
				write_file(sbj_filename, strafes);
				write_file(sbj_filename, sync);
				write_file(sbj_filename, sbj_pretype[i]);
			}
		}
	}
}

public show_leet_ljumper(id)
{
	new plugin_cvar = get_pcvar_num(kz_ljs_enabled);
	new ljtop_cvar = get_pcvar_num(kz_ljs_tops);
	if( plugin_cvar && (ljtop_cvar == 2 || ljtop_cvar == 3) )
	{
		new MenuBody[512], len, keys;
		len = format(MenuBody, 511, "\yShow best longjumper^n");

		if( map_distance[0] )
		{
			len += format(MenuBody[len], 511-len, "^n\r1. \wMap record");
			keys = (1<<0);
		}
		else
			len += format(MenuBody[len], 511-len, "^n\r1. \dMap record (no jumps)");
			
		if( lj_distance[0] )
		{
			len += format(MenuBody[len], 511-len, "^n\r2. \wLongJump record");
			keys |= (1<<1);
		}
		else
			len += format(MenuBody[len], 511-len, "^n\r2. \dLongJump record (no ljs)");
			
		if( cj_distance[0] )
		{
			len += format(MenuBody[len], 511-len, "^n\r3. \wContJump record");
			keys |= (1<<2);
		}
		else
			len += format(MenuBody[len], 511-len, "^n\r3. \dContJump record (no cjs)");

		if( bj_distance[0] )
		{
			len += format(MenuBody[len], 511-len, "^n\r4. \wBhopJump record");
			keys |= (1<<3);
		}
		else
			len += format(MenuBody[len], 511-len, "^n\r4. \dBhopJump record (no bjs)");

		if( sbj_distance[0] )
		{
			len += format(MenuBody[len], 511-len, "^n\r5. \wStand-up BhopJump record");
			keys |= (1<<4);
		}
		else
			len += format(MenuBody[len], 511-len, "^n\r5. \dStand-up BhopJump record (no sbjs)");

		if( wj_distance[0] )
		{
			len += format(MenuBody[len], 511-len, "^n\r6. \wWeirdJump record");
			keys |= (1<<5);
		}
		else
			len += format(MenuBody[len], 511-len, "^n\r6. \dWeirdJump record (no wjs)");
			
		len += format(MenuBody[len], 511-len, "^n^n\r0. \wExit");
		keys |= (1<<9);
			
		show_menu(id, keys, MenuBody, -1, "Show best longjumper");
	}
	else if( !plugin_cvar )
		client_print(id, print_chat, "[XJ] Records are not valid. Plugin is disabled.");
	else
		client_print(id, print_chat, "[XJ] Records are not valid. Tops are disabled.");
	
	return ( (get_pcvar_num(kz_ljs_viscmds))?PLUGIN_CONTINUE:PLUGIN_HANDLED );
}

public LeetJumpMenu_Select(id, key)
{
	new plugin_cvar = get_pcvar_num(kz_ljs_enabled);
	new ljtops = get_pcvar_num(kz_ljs_tops);

	if( ljtops == 2 || ljtops == 3 )
		ljtops = 1;
	else
		ljtops = 0;

	switch((key+1))
	{
		case 1:
		{
			if( map_distance[0] && ljtops && plugin_cvar )
				client_print(id, print_chat, "[XJ] %s has the total %d.%06d %s record!", map_names[0], map_distance[0]/1000000, map_distance[0]%1000000, map_type[0]);
			else if( !plugin_cvar )
				client_print(id, print_chat, "[XJ] Records are not valid. Plugin has been disabled.");
			else if( !ljtops )
				client_print(id, print_chat, "[XJ] Records are not valid. Tops have been disabled.");
			else
				client_print(id, print_chat, "[XJ] Records are not valid. Tops have been reseted.");
		}
		case 2:
		{
			if( lj_distance[0] && ljtops && plugin_cvar )
				client_print(id, print_chat, "[XJ] %s has the %d.%06d lj record!", lj_names[0], lj_distance[0]/1000000, lj_distance[0]%1000000);
			else if( !plugin_cvar )
				client_print(id, print_chat, "[XJ] Records are not valid. Plugin has been disabled.");
			else if( !ljtops )
				client_print(id, print_chat, "[XJ] Records are not valid. Tops have been disabled.");
			else
				client_print(id, print_chat, "[XJ] Lj records are not valid. Tops have been reseted.");
		}
		case 3:
		{
			if( cj_distance[0] && ljtops && plugin_cvar )
				client_print(id, print_chat, "[XJ] %s has the %d.%06d cj record!", cj_names[0], cj_distance[0]/1000000, cj_distance[0]%1000000);
			else if( !plugin_cvar )
				client_print(id, print_chat, "[XJ] Records are not valid. Plugin has been disabled.");
			else if( !ljtops )
				client_print(id, print_chat, "[XJ] Records are not valid. Tops have been disabled.");
			else
				client_print(id, print_chat, "[XJ] Cj records are not valid. Tops have been reseted.");
		}
		case 4:
		{
			if( bj_distance[0] && ljtops && plugin_cvar )
				client_print(id, print_chat, "[XJ] %s has the %d.%06d bj record!", bj_names[0], bj_distance[0]/1000000, bj_distance[0]%1000000);
			else if( !plugin_cvar )
				client_print(id, print_chat, "[XJ] Records are not valid. Plugin has been disabled.");
			else if( !ljtops )
				client_print(id, print_chat, "[XJ] Records are not valid. Tops have been disabled.");
			else
				client_print(id, print_chat, "[XJ] Bj records are not valid. Tops have been reseted.");
		}
		case 5:
		{
			if( sbj_distance[0] && ljtops && plugin_cvar )
				client_print(id, print_chat, "[XJ] %s has the %d.%06d sbj record!", sbj_names[0], sbj_distance[0]/1000000, sbj_distance[0]%1000000);
			else if( !plugin_cvar )
				client_print(id, print_chat, "[XJ] Records are not valid. Plugin has been disabled.");
			else if( !ljtops )
				client_print(id, print_chat, "[XJ] Records are not valid. Tops have been disabled.");
			else
				client_print(id, print_chat, "[XJ] Sbj records are not valid. Tops have been reseted.");
		}
		case 6:
		{
			if( wj_distance[0] && ljtops && plugin_cvar )
				client_print(id, print_chat, "[XJ] %s has the %d.%06d wj record!", wj_names[0], wj_distance[0]/1000000, wj_distance[0]%1000000);
			else if( !plugin_cvar )
				client_print(id, print_chat, "[XJ] Records are not valid. Plugin has been disabled.");
			else if( !ljtops )
				client_print(id, print_chat, "[XJ] Records are not valid. Tops have been disabled.");
			else
				client_print(id, print_chat, "[XJ] Wj records are not valid. Tops have been reseted.");
		}
	}
	return PLUGIN_HANDLED;
}

public show_top(id, toptype)
{
	static buffer[2368], name[131], len, i;
	
	len = format(buffer, 2367, "<body bgcolor=#94AEC6><table width=100%% cellpadding=2 cellspacing=0 border=0>");
	if( !toptype )
		len += format(buffer[len], 2367-len, "<tr  align=center bgcolor=#52697B><th width=5%%> # <th width=34%% align=left> Name <th width=10%%> Distance <th  width=10%%> MaxSpeed <th  width=11%%> PreStrafe <th  width=9%%> Strafes <th  width=6%%> Sync <th  width=10%%> Type");
	else
		len += format(buffer[len], 2367-len, "<tr  align=center bgcolor=#52697B><th width=5%%> # <th width=34%% align=left> Name <th width=10%%> Distance <th  width=10%%> MaxSpeed <th  width=11%%> PreStrafe <th  width=9%%> Strafes <th  width=6%%> Sync");
	
	if( toptype == TOP_WJ)
	{
		for( i = INFO_ZERO; i < NSHOW; i++ )
		{		
			if( wj_distance[i] == 0 )
			{
				len += format(buffer[len], 2367-len, "<tr align=center%s><td> %d <td align=left> %s <td> %s <td> %s <td> %s <td> %s <td> %s", ((i%2)==0) ? "" : " bgcolor=#A4BED6", (i+1), "-", "-", "-", "-", "-", "-");
				i=NSHOW;
			}
			else
			{
				name = wj_names[i];
				while( containi(name, "<") != -1 )
					replace(name, 129, "<", "&lt;");
				while( containi(name, ">") != -1 )
					replace(name, 129, ">", "&gt;");
				len += format(buffer[len], 2367-len, "<tr align=center%s><td> %d <td align=left> %s <td> %d.%01d <td> %d.%01d <td> %d.%01d <td> %d <td> %d", ((i%2)==0) ? "" : " bgcolor=#A4BED6", (i+1), name, (wj_distance[i]/1000000), (wj_distance[i]%1000000/100000), (wj_maxspeed[i]/1000000), (wj_maxspeed[i]%1000000/100000), (wj_prestrafe[i]/1000000), (wj_prestrafe[i]%1000000/100000), wj_strafes[i], wj_sync[i]);
			}
		}
	}
	else if( toptype == TOP_SBJ)
	{
		for( i = INFO_ZERO; i < NSHOW; i++ )
		{		
			if( sbj_distance[i] == 0 )
			{
				len += format(buffer[len], 2367-len, "<tr align=center%s><td> %d <td align=left> %s <td> %s <td> %s <td> %s <td> %s <td> %s", ((i%2)==0) ? "" : " bgcolor=#A4BED6", (i+1), "-", "-", "-", "-", "-", "-");
				i=NSHOW;
			}
			else
			{
				name = sbj_names[i];
				while( containi(name, "<") != -1 )
					replace(name, 129, "<", "&lt;");
				while( containi(name, ">") != -1 )
					replace(name, 129, ">", "&gt;");
				len += format(buffer[len], 2367-len, "<tr align=center%s><td> %d <td align=left> %s <td> %d.%01d <td> %d.%01d <td> %d.%01d <td> %d <td> %d", ((i%2)==0) ? "" : " bgcolor=#A4BED6", (i+1), name, (sbj_distance[i]/1000000), (sbj_distance[i]%1000000/100000), (sbj_maxspeed[i]/1000000), (sbj_maxspeed[i]%1000000/100000), (sbj_prestrafe[i]/1000000), (sbj_prestrafe[i]%1000000/100000), sbj_strafes[i], sbj_sync[i]);
			}
		}
	}
	else if( toptype == TOP_BJ)
	{
		for( i = INFO_ZERO; i < NSHOW; i++ )
		{		
			if( bj_distance[i] == 0 )
			{
				len += format(buffer[len], 2367-len, "<tr align=center%s><td> %d <td align=left> %s <td> %s <td> %s <td> %s <td> %s <td> %s", ((i%2)==0) ? "" : " bgcolor=#A4BED6", (i+1), "-", "-", "-", "-", "-", "-");
				i=NSHOW;
			}
			else
			{
				name = bj_names[i];
				while( containi(name, "<") != -1 )
					replace(name, 129, "<", "&lt;");
				while( containi(name, ">") != -1 )
					replace(name, 129, ">", "&gt;");
				len += format(buffer[len], 2367-len, "<tr align=center%s><td> %d <td align=left> %s <td> %d.%01d <td> %d.%01d <td> %d.%01d <td> %d <td> %d", ((i%2)==0) ? "" : " bgcolor=#A4BED6", (i+1), name, (bj_distance[i]/1000000), (bj_distance[i]%1000000/100000), (bj_maxspeed[i]/1000000), (bj_maxspeed[i]%1000000/100000), (bj_prestrafe[i]/1000000), (bj_prestrafe[i]%1000000/100000), bj_strafes[i], bj_sync[i]);
			}
		}
	}
	else if( toptype == TOP_CJ)
	{
		for( i = INFO_ZERO; i < NSHOW; i++ )
		{		
			if( cj_distance[i] == 0 )
			{
				len += format(buffer[len], 2367-len, "<tr align=center%s><td> %d <td align=left> %s <td> %s <td> %s <td> %s <td> %s <td> %s", ((i%2)==0) ? "" : " bgcolor=#A4BED6", (i+1), "-", "-", "-", "-", "-", "-");
				i=NSHOW;
			}
			else
			{
				name = cj_names[i];
				while( containi(name, "<") != -1 )
					replace(name, 129, "<", "&lt;");
				while( containi(name, ">") != -1 )
					replace(name, 129, ">", "&gt;");
				len += format(buffer[len], 2367-len, "<tr align=center%s><td> %d <td align=left> %s <td> %d.%01d <td> %d.%01d <td> %d.%01d <td> %d <td> %d", ((i%2)==0) ? "" : " bgcolor=#A4BED6", (i+1), name, (cj_distance[i]/1000000), (cj_distance[i]%1000000/100000), (cj_maxspeed[i]/1000000), (cj_maxspeed[i]%1000000/100000), (cj_prestrafe[i]/1000000), (cj_prestrafe[i]%1000000/100000), cj_strafes[i], cj_sync[i]);
			}
		}
	}
	else if( toptype == TOP_LJ)
	{
		for( i = INFO_ZERO; i < NSHOW; i++ )
		{		
			if( lj_distance[i] == 0 )
			{
				len += format(buffer[len], 2367-len, "<tr align=center%s><td> %d <td align=left> %s <td> %s <td> %s <td> %s <td> %s <td> %s", ((i%2)==0) ? "" : " bgcolor=#A4BED6", (i+1), "-", "-", "-", "-", "-", "-");
				i=NSHOW;
			}
			else
			{
				name = lj_names[i];
				while( containi(name, "<") != -1 )
					replace(name, 129, "<", "&lt;");
				while( containi(name, ">") != -1 )
					replace(name, 129, ">", "&gt;");
				len += format(buffer[len], 2367-len, "<tr align=center%s><td> %d <td align=left> %s <td> %d.%01d <td> %d.%01d <td> %d.%01d <td> %d <td> %d", ((i%2)==0) ? "" : " bgcolor=#A4BED6", (i+1), name, (lj_distance[i]/1000000), (lj_distance[i]%1000000/100000), (lj_maxspeed[i]/1000000), (lj_maxspeed[i]%1000000/100000), (lj_prestrafe[i]/1000000), (lj_prestrafe[i]%1000000/100000), lj_strafes[i], lj_sync[i]);
			}
		}
	}
	else if( toptype == TOP_MAP)
	{
		for( i = INFO_ZERO; i < NSHOW; i++ )
		{		
			if( map_distance[i] == 0 )
			{
				len += format(buffer[len], 2367-len, "<tr align=center%s><td> %d <td align=left> %s <td> %s <td> %s <td> %s <td> %s <td> %s <td> %s", ((i%2)==0) ? "" : " bgcolor=#A4BED6", (i+1), "-", "-", "-", "-", "-", "-", "-");
				i=NSHOW;
			}
			else
			{
				name = map_names[i];
				while( containi(name, "<") != -1 )
					replace(name, 129, "<", "&lt;");
				while( containi(name, ">") != -1 )
					replace(name, 129, ">", "&gt;");
				len += format(buffer[len], 2367-len, "<tr align=center%s><td> %d <td align=left> %s <td> %d <td> %d <td> %d <td> %d <td> %d <td> %s", ((i%2)==0) ? "" : " bgcolor=#A4BED6", (i+1), name, (map_distance[i]/1000000), (map_maxspeed[i]/1000000), (map_prestrafe[i]/1000000), map_strafes[i], map_sync[i], map_type[i]);
			}
		}
	}
		
	len += format(buffer[len], 2367-len, "</table></body>");
	static strin[20];

        if( toptype == TOP_WJ)
		format(strin,19, "Top %d WeirdJumps", NSHOW); //TODO: remove bug or todo better message
	else if( toptype == TOP_SBJ)
		format(strin,19, "Top %d S-BhopJumps", NSHOW); //TODO: remove bug or todo better message
	else if( toptype == TOP_BJ)
		format(strin,19, "Top %d BhopJumps", NSHOW);
	else if( toptype == TOP_CJ)
		format(strin,19, "Top %d CountJumps", NSHOW);
	else if( toptype == TOP_LJ)
		format(strin,19, "Top %d LongJumps", NSHOW);
	else if( toptype == TOP_MAP)
		format(strin,19, "Top %d Map Jumps", NSHOW);
        show_motd(id, buffer, strin);
}
public gocheckBoth(id)
{
	gocheck(id);
	gocheckbhop(id);
}
public gocheck(id)
{
	gInAir[id] = false;
	cjumped[id] = false;
	doubleducked[id] = false;
	jumptype[id] = TYPE_NONE;
}

public gocheckbhop(id)
{
	isBhop[id] = false;
	testBhop[id] = false;
	fMaxAirSpeed[id] = 0.0; //prevent 1 bug
	fMaxGroundSpeed[id] = 250.0;
	jumptype[id] = TYPE_NONE;
}

public ddend(id)
	doubleducked[id] = false;

public testcjstart(id)
	cducked[id] = false;

public client_putinserver(id)
{
	if( task_exists(id+234490, 0) )
		remove_task(id+234490, 0);
	
	set_task(0.1, "check_prestrafe_type", id+234490, "", 0, "b", 0);
	
	static connectenabler[6], fastserver;
	fastserver = get_pcvar_num(kz_ljs_fastserver);
	get_pcvar_string(kz_ljs_connectenabler, connectenabler, 5);
	format(connectenabler, 5, "_%s", connectenabler);

	if( contain(connectenabler, "a") > 0 )
		gHasColorChat[id] = true;
	else
		gHasColorChat[id] = false;
	if( contain(connectenabler, "b") > 0 )
		gHasLjStats[id] = true;
	else
		gHasLjStats[id] = false;
	if( contain(connectenabler, "c") > 0 )
	{
		gHasSpeed[id] = true;
		if( fastserver == 1 )
			set_task(0.1, "tskSpeed", id+334490, "", 0, "b", 0);
		else if( fastserver != 2 )
			set_task(0.5, "tskSpeed", id+334490, "", 0, "b", 0);
	}
	else
		gHasSpeed[id] = false;
//	if (get_pcvar_num(kz_ljs_beam) > 0)
//		bljbeam[id] = true;
//	else

	bljbeam[id] = false;

#if defined COMMAND_PROTECTION
	if( fastserver == 2 )
		set_task(0.5, "tskFps", id+434490, "", 0, "b", 0);
	else
		set_task(1.0, "tskFps", id+434490, "", 0, "b", 0);
#endif	
	StrafeStat[id] = true;
	bljhelp[id] = false;
	turning_right[id] = false;
	turning_left[id] = false;
	strafing_aw[id] = false;
	strafing_sd[id] = false;
	cducked[id] = false;
	cjumped[id] = false;
	doubleducked[id]=false;
	induck[id] = false;
	OnGround[id] = false;
	possible_lj_script[id][0] = false;
	possible_lj_script[id][1] = false;
	isBhop[id] = false;
	testBhop[id] = false;
	vFallAt[id][0] = 0.0;
	vFallAt[id][1] = 0.0;
	vFallAt[id][2] = 0.0;
}

public client_disconnect(id)
{
	if( task_exists(id+234490, 0) )
		remove_task(id+234490, 0);
	
	StrafeStat[id] = true;
	bljhelp[id] = false;
	gHasColorChat[id] = false;
	gHasLjStats[id] = false;
	gHasSpeed[id] = false;
	turning_right[id] = false;
	turning_left[id] = false;
	strafing_aw[id] = false;
	strafing_sd[id] = false;
	OnGround[id] = false;
	cducked[id] = false;
	doubleducked[id] = false;
	cjumped[id] = false;
	induck[id] = false;
	possible_lj_script[id][0] = false;
	possible_lj_script[id][1] = false;
	isBhop[id] = false;
	testBhop[id] = false;

	
	if( task_exists(id+334490, 0) )
		remove_task(id+334490, 0);
	
	if( task_exists(id+434490, 0) )
		remove_task(id+434490, 0);
}

public check_prestrafe_type(id)
{
	id -= 234490;
	if( is_user_alive(id) )
	{
		static flags, buttons, moving;
		flags = pev(id, pev_flags);
		buttons = pev(id, pev_button);
		
		/*if( flags&FL_ONGROUND && gInAir[id] && get_gametime() > (jumptime[id]+0.1) )
		{	
			new Float:vvvOrigin[3];
			pev(id, pev_origin, vvvOrigin);

			client_print(id, print_console, "prizemlils v check_prestrafe_type, %f %f %f", vvvOrigin[0],vvvOrigin[1],vvvOrigin[2]);			
			fwdPlayerPreThink(id);
		}*/
		
		if( (buttons&IN_FORWARD || buttons&IN_BACK || buttons&IN_MOVERIGHT || buttons&IN_MOVELEFT) && !(buttons&IN_DUCK) )
			moving = INFO_ONE;
		else
			moving = INFO_ZERO;
		
		if( moving && !(doubleducked[id]) && !(cjumped[id]) && flags&FL_ONGROUND && (turning_right[id] || turning_left[id]) )
		{
			if( buttons&IN_FORWARD && buttons&IN_BACK )
				moving = INFO_ZERO;
			
			if( buttons&IN_MOVELEFT && buttons&IN_MOVERIGHT )
				moving = INFO_ZERO;
			
			if( !(moving) )
				pre_type[id] = "key error";
		}
		else
		{
			moving = 0;
		}
		
		if( moving )
		{
			if( buttons&IN_FORWARD )
			{
				if( buttons&IN_MOVERIGHT )
				{
					if( turning_right[id] )
						pre_type[id] = "right";
					else
						pre_type[id] = "right sw";
				}
				else if( buttons&IN_MOVELEFT )
				{
					if( turning_left[id] )
						pre_type[id] = "left";
					else
						pre_type[id] = "left sw";
				}
				else
				{
					if( turning_right[id] )
						pre_type[id] = "right (1 key)";
					else
						pre_type[id] = "left (1 key)";
				}
			}
			else if( buttons&IN_BACK )
			{
				if( buttons&IN_MOVERIGHT )
				{
					if( turning_left[id] )
						pre_type[id] = "bw right";
					else
						pre_type[id] = "bw right sw";
				}
				else if( buttons&IN_MOVELEFT )
				{
					if( turning_right[id] )
						pre_type[id] = "bw left";
					else
						pre_type[id] = "bw left sw";
				}
				else
				{
					if( turning_left[id] )
						pre_type[id] = "bw right (1 key)";
					else
						pre_type[id] = "bw left (1 key)";
				}
			}
			else if( buttons&IN_MOVERIGHT )
			{
				if( turning_right[id] )
					pre_type[id] = "bw right sw (1 key)";
				else
					pre_type[id] = "left sw (1 key)";
			}
			else if( buttons&IN_MOVELEFT )
			{
				if( turning_left[id] )
					pre_type[id] = "bw left sw (1 key)";
				else
					pre_type[id] = "right sw (1 key)";
			}
			else
				pre_type[id] = "unknown error";
		}
	}				
}

#if defined COMMAND_PROTECTION
public tskFps(id)
{
	if( get_pcvar_num(kz_legal_settings) && get_pcvar_num(kz_ljs_enabled) )
	{
		id-=434490;
		client_cmd(id, "developer 0;fps_max 101;cl_forwardspeed 400;cl_sidespeed 400;cl_backspeed 400");
	}
}
#endif	

public cmdColorChat(id)
{
	if( get_pcvar_num(kz_ljs_enabled) && !gHasColorChat[id] )
	{
		gHasColorChat[id] = true;
		client_print(id, print_chat, "[XJ] ColorChat enabled. To disable, type /colorchat.");
	}
	else if( get_pcvar_num(kz_ljs_enabled) )
	{
		gHasColorChat[id] = false;
		client_print(id, print_chat, "[XJ] ColorChat disabled. To enable, type /colorchat.");
	}
	
	return ( (get_pcvar_num(kz_ljs_viscmds))?PLUGIN_CONTINUE:PLUGIN_HANDLED );
}

public cmdLjStats(id)
{
	if( get_pcvar_num(kz_ljs_enabled) && !gHasLjStats[id] )
	{
		gHasLjStats[id] = true;
		
		client_print(id, print_chat, "[XJ] LongJump Stats enabled. To disable, type /ljstats.");
	}
	else if( get_pcvar_num(kz_ljs_enabled) )
	{
		gHasLjStats[id] = false;
		
		client_print(id, print_chat, "[XJ] LongJump Stats disabled. To enable, type /ljstats.");
	}
	
	return ( (get_pcvar_num(kz_ljs_viscmds))?PLUGIN_CONTINUE:PLUGIN_HANDLED );
}

public cmdSpeed(id)
{
	if( get_pcvar_num(kz_ljs_enabled) && !gHasSpeed[id] )
	{
		gHasSpeed[id] = true;
		if( get_pcvar_num(kz_ljs_fastserver) == 1 )
			set_task(0.1, "tskSpeed", id+334490, "", 0, "b", 0);
		else if( get_pcvar_num(kz_ljs_fastserver) != 2 )
			set_task(0.5, "tskSpeed", id+334490, "", 0, "b", 0);
		client_print(id, print_chat, "[XJ] Speedometer enabled. To disable, type /speed.");
	}
	else if( get_pcvar_num(kz_ljs_enabled) )
	{
		gHasSpeed[id] = false;
		if( task_exists(id+334490, 0) )
			remove_task(id+334490, 0);
		client_print(id, print_chat, "[XJ] Speedometer disabled. To enable, type /speed.");
	}
	
	return ( (get_pcvar_num(kz_ljs_viscmds))?PLUGIN_CONTINUE:PLUGIN_HANDLED );
}

public cmdStrafeStat(id)
{
	if( get_pcvar_num(kz_ljs_enabled) && !(StrafeStat[id]) )
	{
		StrafeStat[id] = true;
		client_print(id, print_chat, "[XJ] Strafe stat enabled. To disable, type /strafestat.");
	}
	else if( get_pcvar_num(kz_ljs_enabled) )
	{
		StrafeStat[id] = false;
		client_print(id, print_chat, "[XJ] Strafe stat disabled. To enable, type /strafestat.");
	}
	
	return ( (get_pcvar_num(kz_ljs_viscmds))?PLUGIN_CONTINUE:PLUGIN_HANDLED );
}

public cmdljhelp(id)
{
	if( get_pcvar_num(kz_ljs_enabled) && !(bljhelp[id]) )
	{
		bljhelp[id] = true;
		client_print(id, print_chat, "enabled");
	}
	else if( get_pcvar_num(kz_ljs_enabled) )
	{
		bljhelp[id] = false;
		client_print(id, print_chat, "disabled");
	}
	
	return ( (get_pcvar_num(kz_ljs_viscmds))?PLUGIN_CONTINUE:PLUGIN_HANDLED );
}
public cmdljbeam(id)
{
	if( get_pcvar_num(kz_ljs_enabled) && !(bljbeam[id]) && get_pcvar_num(kz_ljs_beam) > 0)
	{
		bljbeam[id] = true;
		client_print(id, print_chat, "[XJ] Lj beam enabled. To disable, type /ljbeam.");
	}
	else if( get_pcvar_num(kz_ljs_enabled) )
	{
		bljbeam[id] = false;
		if (get_pcvar_num(kz_ljs_beam) > 0)
			client_print(id, print_chat, "[XJ] Lj beam disabled. To enable, type /ljbeam.");
		else
			client_print(id, print_chat, "[XJ] Lj beam disabled in plugin configuration.");
	}
	
	return ( (get_pcvar_num(kz_ljs_viscmds))?PLUGIN_CONTINUE:PLUGIN_HANDLED );
}

public tskSpeed(taskid)
{
	taskid-=334490;
	static alive, aliveflags, spectatedplayer, specflags;
	alive = is_user_alive(taskid);
	aliveflags = pev(taskid, pev_flags);
	spectatedplayer = get_spectated_player(taskid);
	if( spectatedplayer )
		specflags = pev(spectatedplayer, pev_flags);
	else
		specflags = INFO_ZERO;
	
	if( (alive || spectatedplayer > 0) && get_pcvar_num(kz_ljs_enabled) )
	{
		if( alive )
		{
			pev(taskid, pev_velocity, vVelocity);
			if( aliveflags&FL_ONGROUND && aliveflags&FL_INWATER )
				vVelocity[2]-=vVelocity[2];
		}
		else
		{
			pev(spectatedplayer, pev_velocity, vVelocity);
			if( specflags&FL_ONGROUND && specflags&FL_INWATER )
				vVelocity[2]-=vVelocity[2];
		}
				
		if( get_pcvar_num(kz_ljs_fastserver) == 1 )
			set_hudmessage(255, 255, 255, -1.0, 0.65, 0, 0.0, 0.2, 0.0, 0.0, 2);
		else if( !(get_pcvar_num(kz_ljs_fastserver) == 1 || get_pcvar_num(kz_ljs_fastserver) == 2) )
			set_hudmessage(255, 255, 255, -1.0, 0.65, 0, 0.0, 0.6, 0.0, 0.0, 2);
		
		if( get_pcvar_num(kz_ljs_speedtype) == 1 )
			show_hudmessage(taskid, "%d units/second", floatround(vector_length(vVelocity), floatround_floor));
		else if( get_pcvar_num(kz_ljs_speedtype) == 2 )
		{
			if( vVelocity[2] != 0 )
				vVelocity[2]-=vVelocity[2];
			gSpeed = vector_length(vVelocity);
			show_hudmessage(taskid, "%d velocity", floatround(gSpeed, floatround_floor));
		}
		else
		{
			if( vVelocity[2] != 0 )
				vVelocity[2]-=vVelocity[2];
			gSpeed = vector_length(vVelocity);
			if( alive )
			{
				pev(taskid, pev_velocity, vVelocity);
				if( aliveflags&FL_ONGROUND && aliveflags&FL_INWATER )
					vVelocity[2]-=vVelocity[2];
			}
			else
			{
				pev(spectatedplayer, pev_velocity, vVelocity);
				if( specflags&FL_ONGROUND && specflags&FL_INWATER )
					vVelocity[2]-=vVelocity[2];
			}
			show_hudmessage(taskid, "%d units/second^n%d velocity", floatround(vector_length(vVelocity), floatround_floor), floatround(gSpeed, floatround_floor));
		}
	}
}

public cmdVersion(id)
{
	ColorChat(id, GREY, "^x04[XJ] Plugin: ^x01%s^x04 by: ^x03%s", gPLUGIN, gAUTHOR);
	if( get_pcvar_num(kz_ljs_enabled) )
		ColorChat(id, BLUE, "^x04[XJ] Version: ^x01%s^x04, Status:^x03 enabled", gVERSION);
	else
		ColorChat(id, RED, "^x04[XJ] Version: ^x01%s^x04, Status:^x03 disabled", gVERSION);
	
	return ( (get_pcvar_num(kz_ljs_viscmds))?PLUGIN_CONTINUE:PLUGIN_HANDLED );
}

public fwdStartFrame()
{
	if( get_pcvar_num(kz_legal_settings) && get_pcvar_num(kz_ljs_enabled) )
	{
		if( get_pcvar_num(edgefriction) != 2 )
			set_pcvar_num(edgefriction, 2);
		
		if( get_pcvar_num(mp_footsteps) != 1 )
			set_pcvar_num(mp_footsteps, 1);
		
		if( get_pcvar_num(sv_cheats) != 0 )
			set_pcvar_num(sv_cheats, 0);
		
		if( get_pcvar_num(sv_gravity) != 800 )
			set_pcvar_num(sv_gravity, 800);
		
		if( get_pcvar_num(sv_maxspeed) != 320 )
			set_pcvar_num(sv_maxspeed, 320);
		
		if( get_pcvar_num(sv_stepsize) != 18 )
			set_pcvar_num(sv_stepsize, 18);
		
		if( get_pcvar_num(sv_maxvelocity) != 2000 )
			set_pcvar_num(sv_maxvelocity, 2000);
	}
	
	if( FindPlayer() > -1)
	{
		if( get_pcvar_num(kz_ljs_enabled) )
		{
			set_hudmessage(255, 255, 255, -1.0, 0.65, 0, 0.0, 0.1, 0.0, 0.0, 2);
			if( !pluginstatus )
			{
				ColorChat(0, BLUE, "^x04[XJ] ^x01%s ^x04plugin^x03 enabled ^x04!", gPLUGIN);
				pluginstatus = INFO_ONE;
			}
		}
		else
		{
			if( pluginstatus )
			{
				ColorChat(0, RED, "^x04[XJ] ^x01%s ^x04plugin^x03 disabled ^x04!", gPLUGIN);
				pluginstatus = INFO_ZERO;
			}
		}
	}
	static id, fastserver, speedtype, spectatedplayer, alive, aliveflags, specflags;
	fastserver = get_pcvar_num(kz_ljs_fastserver);
	speedtype = get_pcvar_num(kz_ljs_speedtype);
	for( id = INFO_ONE; id < 33; id++ )
	{
		if( pev_valid(id) && pluginstatus )
		{
			alive = is_user_alive(id);
			aliveflags = pev(id, pev_flags);
			spectatedplayer = get_spectated_player(id);
			if( spectatedplayer )
				specflags = pev(spectatedplayer, pev_flags);
			else
				specflags = INFO_ZERO;
			if( alive || spectatedplayer )
			{
				if( alive )
				{
					pev(id, pev_velocity, vVelocity);
					if( aliveflags&FL_ONGROUND && aliveflags&FL_INWATER )
						vVelocity[2]-=vVelocity[2];
				}
				else
				{
					pev(spectatedplayer, pev_velocity, vVelocity);
					if( specflags&FL_ONGROUND && specflags&FL_INWATER )
						vVelocity[2]-=vVelocity[2];
				}
				
				if( fastserver == 2 && gHasSpeed[id] )
				{
					if( task_exists(id+334490, 0) )
						remove_task(id+334490, 0);
					
					if( speedtype == 1 )
						show_hudmessage(id, "%d units/second", floatround(vector_length(vVelocity), floatround_floor));
					else if( speedtype == 2 )
					{
						if( vVelocity[2] != 0 )
							vVelocity[2]-=vVelocity[2];
						gSpeed = vector_length(vVelocity);
						show_hudmessage(id, "%d velocity", floatround(gSpeed, floatround_floor));
					}
					else
					{
						if( vVelocity[2] != 0 )
							vVelocity[2]-=vVelocity[2];
						gSpeed = vector_length(vVelocity);
						if( alive )
						{
							pev(id, pev_velocity, vVelocity);
							if( aliveflags&FL_ONGROUND && aliveflags&FL_INWATER )
								vVelocity[2]-=vVelocity[2];
						}
						else
						{
							pev(spectatedplayer, pev_velocity, vVelocity);
							if( specflags&FL_ONGROUND && specflags&FL_INWATER )
								vVelocity[2]-=vVelocity[2];
						}
						show_hudmessage(id, "%d units/second^n%d velocity", floatround(vector_length(vVelocity), floatround_floor), floatround(gSpeed, floatround_floor));
					}			
				}
				else if( gHasSpeed[id]
				&& fastserver != 2
				&& !task_exists(id+334490, 0) )
				{
					if( fastserver )
						set_task(0.1, "tskSpeed", id+334490, "", 0, "b", 0);
					else
						set_task(0.5, "tskSpeed", id+334490, "", 0, "b", 0);
				}
			}
		}
	}
	
	return FMRES_IGNORED;
}

public fwdPlayerPreThink(id)
{
	if( is_user_alive(id) && get_pcvar_num(kz_ljs_enabled) )
	{		
		static Float:fGravity;
		pev(id, pev_gravity, fGravity);
		
		pev(id, pev_origin, vOrigin);
		fDistance = get_distance_f(vOldOrigin[id], vOrigin);

		weapSpeedOld[id] = weapSpeed[id];

		pev(id, pev_origin, vOldOrigin[id]);

		pev(id, pev_velocity, vVelocity);
		if( vVelocity[2] != 0 )
			vVelocity[2]-=vVelocity[2];

		pev(id, pev_maxspeed, weapSpeed[id]);
//1111
//		static flags, buttons, oldbuttons;
//		if (weapSpeed > 250)
//		{
//			static Float:baseveloc[3];
//			pev(id, pev_basevelocity, baseveloc);
//			client_print(id, print_chat,"baseveloc[0] %f baseveloc[1] %f baseveloc[2] %f",baseveloc[0],baseveloc[1],baseveloc[2]);
//		}
		
		if( vector_length(vVelocity) > (fMaxGroundSpeed[id] + 105.0) 
		|| pev(id, pev_movetype) != MOVETYPE_WALK
		|| fGravity != 1.0
		|| get_pcvar_num(edgefriction) != 2
		|| get_pcvar_num(mp_footsteps) != 1
		|| get_pcvar_num(sv_cheats) != 0
		|| get_pcvar_num(sv_gravity) != 800
		|| get_pcvar_num(sv_maxspeed) != 320
		|| get_pcvar_num(sv_stepsize) != 18
		|| get_pcvar_num(sv_maxvelocity) != 2000
		|| pev(id, pev_waterlevel) >= 2 
		|| fDistance > 22 
		|| weapSpeedOld[id] != weapSpeed[id])
		{
			gocheckBoth(id);

			return FMRES_IGNORED;
		}

		static flags, oldbuttons;
		flags = pev(id, pev_flags);
		buttons = pev(id, pev_button);
		oldbuttons = pev(id, pev_oldbuttons);

		if( (gInAir[id] == true || isBhop[id] == true) && !(flags&FL_ONGROUND) )
		{
			static i;
			for( i = INFO_ZERO; i < 2; i++ )
			{
				if( (i == 1) 
				|| (vFramePos[id][i][0] == 0
				&& vFramePos[id][i][1] == 0
				&& vFramePos[id][i][2] == 0 
				&& vFrameSpeed[id][i][0] == 0
				&& vFrameSpeed[id][i][1] == 0
				&& vFrameSpeed[id][i][2] == 0 )) //or amxx platform very intellectual :D
				{
					//pev(id, pev_origin, vOrigin);
					vFramePos[id][i][0] = vOrigin[0];
					vFramePos[id][i][1] = vOrigin[1];
					vFramePos[id][i][2] = vOrigin[2];
					
					pev(id, pev_velocity, vVelocity);
					vFrameSpeed[id][i][0] = vVelocity[0];
					vFrameSpeed[id][i][1] = vVelocity[1];
					vFrameSpeed[id][i][2] = vVelocity[2];
					i=2;
					//client_print(id, print_console,"Numb Origin %f %f %f", vOrigin[0],vOrigin[1],vOrigin[2]);
				}
			}
		}

		pev(id, pev_velocity, vVelocity);
		//if (weapSpeed == 260)
		//	client_print(id, print_console,"Pre %f	%f	%f	%f	%f	%f", vOrigin[0],vOrigin[1],vOrigin[2],vVelocity[0],vVelocity[1],vVelocity[2]);

		pev(id, pev_velocity, vVelocity);
		if( flags&FL_ONGROUND && flags&FL_INWATER )  //??
			vVelocity[2] = 0.0;
		fSpeed = vector_length(vVelocity);

		if( vVelocity[2] != 0 )
			vVelocity[2]-=vVelocity[2];

		gSpeed = vector_length(vVelocity);

		if( !(flags&FL_ONGROUND) )
			lasttime[id] = get_gametime();	

		if( gInAir[id] || isBhop[id])
		{
			if (((vOrigin[2] + 18.0 - vJumpedAt[id][2]) < 0)
			    && !(flags&FL_ONGROUND) )
			{
				fallDown[id] = true;
				static Float:fJAt2;
				fJAt2 = vJumpedAt[id][2];

				if( is_in_duck(id) )
				{
					vOrigin[2]-=18.0;
					fJAt2-=18.0;
				}

				static Float:koeff1;
				koeff1 = (fJAt2-vLastFrameOrigin[id][2])/(vOrigin[2]-vLastFrameOrigin[id][2]);

				vLastFrameOrigin[id][2] = fJAt2;
				vLastFrameOrigin[id][0] = koeff1*(vOrigin[0]-vLastFrameOrigin[id][0])+vLastFrameOrigin[id][0];
				vLastFrameOrigin[id][1] = koeff1*(vOrigin[1]-vLastFrameOrigin[id][1])+vLastFrameOrigin[id][1];

				//TODO make it better
			}
			else
			{
				fallDown[id] = false;
				vLastFrameOrigin[id] = vOrigin;
				vOrigin[2] = vJumpedAt[id][2];
			}
		
/*			if( flags&FL_ONGROUND )
			{
				fallDown[id] = false;
				
				//vOrigin[2] = vJumpedAt[id][2];	
			}
			//vLastFrameOrigin[id] = vOrigin;*/

			if( gSpeed > fMaxAirSpeed[id] )
			{
				if (strafes[id] < NSTRAFES)
				{
					strafe_stat_speed[id][strafes[id]][0] += gSpeed - fMaxAirSpeed[id];
				}
				fMaxAirSpeed[id] = gSpeed;
			}
			if ((gSpeed < TempSpeed[id]) && (strafes[id] < NSTRAFES))
			{
				strafe_stat_speed[id][strafes[id]][1] += TempSpeed[id] - gSpeed;
			}
			TempSpeed[id] = gSpeed;
		}

		maxPreSpeedWeapon = weapSpeed[id]*1.115;
		maxBhopPreSpeedWeap = weapSpeed[id]*1.2;

		if( isBhop[id] )
		{	
			if (flags&FL_ONGROUND || fallDown[id])
			{
				func69(id, TYPE_BJ);	

				//is it good, mb better to do it with pev_flDuckTime ?
				if (vFrameSpeed[id][0][2] > 229)
					jumptype[id] = TYPE_SBJ;
				else
					jumptype[id] = TYPE_BJ;

				if( ((vJumpedAt[id][2] == vOrigin[2]) || fallDown[id] )
				&& fDistance > get_pcvar_float(kz_min_bhop)
				&& !(fDistance > get_pcvar_float(kz_max_lj)) )			
				{
					sync_ = INFO_ZERO;
					strMess[0] = '^0'; //unnecessary?
					strMessBuf[0] = '^0'; //unnecessary?
					strLen = INFO_ZERO;
					badSyncTemp = INFO_ZERO;
					goodSyncTemp = INFO_ZERO;

					Fulltime = lasttime[id]-jumptime[id];
					
					if(strafes[id] < NSTRAFES)
					{
						strafe_stat_time[id][0] = jumptime[id];
						strafe_stat_time[id][strafes[id]] = lasttime[id];
 						
						for(jj = INFO_ONE;jj <= strafes[id]; jj++)
						{
							time_ = ((strafe_stat_time[id][jj] - strafe_stat_time[id][jj-1])*100) / (Fulltime);
							if ((strafe_stat_sync[id][jj][0]+strafe_stat_sync[id][jj][1]) > 0)
							{
								sync_ = (strafe_stat_sync[id][jj][0] * 100)/(strafe_stat_sync[id][jj][0]+strafe_stat_sync[id][jj][1]); //using like a buffer		
							}				
							else
							{
								sync_ = 0;
							}
							strLen += format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^t%2d^t%4.3f^t%4.3f^t%3.1f%%^t%3d%%^n", jj, strafe_stat_speed[id][jj][0], strafe_stat_speed[id][jj][1], time_, sync_);

							goodSyncTemp += strafe_stat_sync[id][jj][0];
							badSyncTemp += strafe_stat_sync[id][jj][1];
						}
						if (jumptype[id] == TYPE_SBJ)
						{
							strLen += format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^tType: StandUp Bhop");
						}
					}
	
					//Standart Sync
					if( goodSyncTemp > 0 )
						sync_ = (goodSyncTemp*100/(goodSyncTemp+badSyncTemp));
					else
						sync_ = INFO_ZERO;
					
					if( !(possible_lj_script[id][0] || possible_lj_script[id][1] || fallDown[id] || weapSpeed[id] != 250.0 || pev(id, pev_fuser2) == 0.0))
					{
						check_maintop(id, floatround((fDistance*1000000), floatround_floor), floatround((fMaxAirSpeed[id]*1000000), floatround_floor), floatround((fMaxGroundSpeed[id]*1000000), floatround_floor), strafes[id], sync_, jumptype[id]);
					}

					ljStatsRed = get_pcvar_num(kz_ljstats_red);
					ljStatsGreen = get_pcvar_num(kz_ljstats_green);
					ljStatsBlue = get_pcvar_num(kz_ljstats_blue);
					ljs_beam = get_pcvar_num(kz_ljs_beam);
					static i;
					
					if( gHasLjStats[id] && bljbeam[id] )
					{
						i = DrawBeam(id, ljs_beam, 1);
					}

					static strdist[128];
					num_to_word(floatround(fDistance, floatround_floor), strdist, 127);

					for( i = INFO_ONE; i < 33; i++ )
					{
						if( (i == id || is_user_spectating_player(i, id)) && gHasLjStats[i] )
						{
							copy(strMessBuf,strLen,strMess);

							if ( fallDown[id] || weapSpeed[id] != 250.0 || pev(id, pev_fuser2) == 0.0)
							{
								set_hudmessage(255, 0, 109, -1.0, 0.70, 0, 0.0, (vBeamLastTime[id]*0.1), 0.1, 0.1, 3);
							}
							else
							{
								set_hudmessage(ljStatsRed, ljStatsGreen, ljStatsBlue, -1.0, 0.70, 0, 0.0, (vBeamLastTime[id]*0.1), 0.1, 0.1, 3);
							}

							show_hudmessage(i, "Bhop Distance: %f^nMaxSpeed: %f (%.3f)^nPreStrafe: %f (%.3f)^nStrafes: %d^nSync: %d%%^n^n^nBhop Longjump'd", fDistance, fMaxAirSpeed[id], fMaxAirSpeed[id] - fMaxGroundSpeed[id], fMaxGroundSpeed[id],fMaxGroundBhopSpeed[id], strafes[id], sync_ );
							client_print(i, print_console, "Bhop Distance: %f MaxSpeed: %f (%.3f) PreStrafe: %f (%.3f) Strafes: %d Sync: %d", fDistance, fMaxAirSpeed[id], fMaxAirSpeed[id] - fMaxGroundSpeed[id], fMaxGroundSpeed[id],fMaxGroundBhopSpeed[id], strafes[id], sync_ );
							if ( StrafeStat[i] && strLen != 0 )
							{
								if ( fallDown[id] || weapSpeed[id] != 250.0 || pev(id, pev_fuser2) == 0.0)
								{
									set_hudmessage(255, 0, 109, 0.70, 0.35, 0, 0.0, (vBeamLastTime[id]*0.1), 0.1, 0.1, 4);
								}
								else
								{
									set_hudmessage(ljStatsRed, ljStatsGreen, ljStatsBlue, 0.70, 0.35, 0, 0.0, (vBeamLastTime[id]*0.1), 0.1, 0.1, 4);
								}
								show_hudmessage(i,"%s",strMessBuf);
								static strMessHalf[40];

								for(jj=INFO_ONE; (jj <= strafes[id]) && (jj < NSTRAFES);jj++)
								{
									strtok(strMessBuf,strMessHalf,40,strMessBuf,40*NSTRAFES,'^n');
									replace(strMessHalf,40,"^n","");
									client_print(i, print_console, "%s", strMessHalf);	
								}
							}

							if( possible_lj_script[id][0] || possible_lj_script[id][1] )
							{
								if( possible_lj_script[id][0] && possible_lj_script[id][1] )
									client_print(i, print_center, "No ljtop access (possible lj script)");
								else
									client_print(i, print_center, "No ljtop access (possible %s script)", (possible_lj_script[id][0])?"prestrafe":"strafe");
							}
								
							if( get_pcvar_num(kz_lj_sounds) == 2 && gHasColorChat[i] && !(fallDown[id]) && weapSpeed[id] == 250.0 && pev(id, pev_fuser2) > 0.0)
								client_cmd(i, "speak ^"vox/%s uniform(e30) it south(e15)^"", strdist);

							if( i != id && (ljs_beam == 1 || ljs_beam == 2) && bljbeam[i] )
							{
								DrawSpecBeam(i);
							}
						}
					}
					if (!(fallDown[id]) && weapSpeed[id] == 250.0 && pev(id, pev_fuser2) > 0.0)
					{
						static Float:max_lj, Float:leet_lj, Float:pro_lj, Float:good_lj, ljtop, Float:god_lj;
						ljtop = get_pcvar_num(kz_ljs_tops);

						if( (!(possible_lj_script[id][0] || possible_lj_script[id][1] )) && (ljtop == 1	|| ljtop == 3) )
						{

							max_lj = get_pcvar_float(kz_max_lj);
						/*	leet_lj = get_pcvar_float(kz_leet_lj) - 10;
							pro_lj = get_pcvar_float(kz_pro_lj) - 10;
							good_lj = get_pcvar_float(kz_good_lj) - 10;
							ljtop = get_pcvar_num(kz_ljs_tops);
						*/
							leet_lj = 240.0;
							pro_lj = 235.0;
							good_lj = 230.0;
							god_lj = 245.0;

							if( fDistance < max_lj
							&& !(fDistance < god_lj)
							&& !(0 > god_lj))
							{
								PrintChatMess(id, 3, DIST_GOD, jumptype[id]);
							}
							else if( fDistance < max_lj
							&& !(fDistance < leet_lj)
							&& !(0 > leet_lj))
							{
								PrintChatMess(id, get_pcvar_num(kz_leet_lj_clr), DIST_LEET, jumptype[id]);
							}				
							else if( fDistance < max_lj
							&& !(fDistance < pro_lj)
							&& !(0 > pro_lj))
							{
								PrintChatMess(id, get_pcvar_num(kz_pro_lj_clr), DIST_PRO, jumptype[id]);
							}						
							else if( fDistance < max_lj
							&& !(fDistance < good_lj)
							&& !(0 > good_lj))
							{
								PrintChatMess(id, get_pcvar_num(kz_good_lj_clr), DIST_GOOD, jumptype[id]);
							}
						}
					}
				}
				jumptype[id] = TYPE_NONE;
			}
		}
		else
		{ 
			if( testBhop[id] && buttons&IN_JUMP && !(oldbuttons&IN_JUMP) && flags&FL_ONGROUND)
			{
				set_task(0.71,"gocheckbhop", id);
				
				//client_print(id, print_console, "fMaxGroundBhopSpeed %f gSpeed %f fMaxGroundSpeed %f fMaxAirSpeed[id] %f OldSpeed[id] %f",fMaxGroundBhopSpeed[id], gSpeed, fMaxGroundSpeed[id], fMaxAirSpeed[id],OldSpeed[id]);
				fMaxGroundBhopSpeed[id] = gSpeed - fMaxAirSpeed[id];
				fMaxGroundSpeed[id] = gSpeed;
				fMaxAirSpeed[id] = gSpeed;

				//client_print(id, print_console, "fMaxGroundBhopSpeed %f gSpeed %f fMaxGroundSpeed %f fMaxAirSpeed[id] %f OldSpeed[id] %f",fMaxGroundBhopSpeed[id], gSpeed, fMaxGroundSpeed[id], fMaxAirSpeed[id],OldSpeed[id]);
				set_hudmessage(255, 255, 255, -1.0, 0.70, 0, 0.0, 0.7, 0.1, 0.1, 3);
				static i;

/*
				if (fMaxGroundSpeed[id] > maxBhopPreSpeedWeap)
				{
					for( i = INFO_ONE; i < 33; i++ )
					{
						if( (i == id || is_user_spectating_player(i, id)) && gHasLjStats[i])
						{
							show_hudmessage(i, "Prestrafe: %f (%.3f)^nYour Maxspeed was too high^nMaxspeed have to be under %.3f", fMaxGroundSpeed[id], fMaxGroundBhopSpeed[id], maxBhopPreSpeedWeap);
							//client_print(i, print_console, "Prestrafe: %f (%.3f) Your Maxspeed was too high, Maxspeed have to be under %.3f", fMaxGroundSpeed[id], fMaxGroundBhopSpeed[id], maxBhopPreSpeedWeap);
						}
					}
				}
				else
				{
					for( i = INFO_ONE; i < 33; i++ )
					{
						if( (i == id || is_user_spectating_player(i, id)) && gHasLjStats[i])
						{
							show_hudmessage(i, "Prestrafe: %f (%.3f)", fMaxGroundSpeed[id], fMaxGroundBhopSpeed[id]);
							//client_print(i, print_console, "Prestrafe: %f (%.3f)", fMaxGroundSpeed[id], fMaxGroundBhopSpeed[id]);
						}
					}
				}
*/
				if (fMaxGroundSpeed[id] < maxBhopPreSpeedWeap)
				{
					for( i = INFO_ONE; i < 33; i++ )
					{
						if( (i == id || is_user_spectating_player(i, id)) && gHasLjStats[i])
						{
							show_hudmessage(i, "Prestrafe: %f (%.3f)", fMaxGroundSpeed[id], fMaxGroundBhopSpeed[id]);
							client_print(i, print_console, "OLDPrestrafe: %f (%.3f)", fMaxGroundSpeed[id], fMaxGroundBhopSpeed[id]);
						}
					}
				}
				isBhop[id] = true;
				testBhop[id] = false;
				jumptype[id] = TYPE_NONE; // ???

			}
			else
			{ //TODO pravilnie yslovi9??
				if( testBhop[id] && (isBhop[id] == false))
				{
					if (!(buttons&IN_JUMP) && oldbuttons&IN_JUMP)
					{
						//client_print(id, print_console, "slishkom rano");
						set_hudmessage(255, 0, 109, -1.0, 0.70, 0, 0.0, 0.5, 0.1, 0.1, 3);
						static i;
						for( i = INFO_ONE; i < 33; i++ )
						{
							if( (i == id || is_user_spectating_player(i, id)) && gHasLjStats[i])
							{
								show_hudmessage(id,"You pressed jump too early!");
								//client_print(id, print_console, "You pressed jump too early");
							}
						}
					}
					jumptype[id] = TYPE_NONE;
				}
				testBhop[id] = false;
			}

			if( buttons&IN_JUMP
			&& !(oldbuttons&IN_JUMP)
			&& flags&FL_ONGROUND
			&& gInAir[id] == false )
			{
				pev(id, pev_origin, vOrigin);

				static Float:temp[3],Float:temp2[3];
				temp[0] = vFallAt[id][0];
				temp[1] = vFallAt[id][1];
				temp[2] = 0.0;

				temp2[0] = vOrigin[0];
				temp2[1] = vOrigin[1];
				temp2[2] = 0.0;

				//client_print(id, print_console,"wj %f",get_distance_f(vFallAt[id], vOrigin) );
				//client_print(id, print_console,"wj %f",get_distance_f(temp, temp2) );

				if (jumptype[id] == TYPE_WJ && get_distance_f(temp, temp2) > 5.2)
				{
					jumptype[id] = TYPE_NONE;

					if ( get_distance_f(temp, temp2) < 12.0 )
					{
						gocheck(id);

						//BUGBUGBUG it possible to do CJ with good prestrafe after unsucessfull Wj

						//client_print(id, print_chat,"obnylili wj %f",get_distance_f(vFallAt[id], vOrigin) );	
						return FMRES_IGNORED;
					}
				}
				set_task(0.8,"gocheck", id);
			
				jumptime[id] = get_gametime();
				static i;
				gInAir[id] = true;	

				//strafecounter_oldbuttons[id] = 0;
				//TODO is such IF is right? i think that isBhop[id] is useless
				if (!isBhop[id] && !testBhop[id])
				{
					//vOldOrigin2[id] = vOrigin[2];
					fMaxGroundSpeed[id] = fSpeed;
					fMaxAirSpeed[id] = fSpeed;
					vJumpedAt[id][2] = vOrigin[2];

					//strafecounter_oldbuttons[id] = buttons;
				}
				strafecounter_oldbuttons[id] = INFO_ZERO;
					
				fallDown[id] = false;
	
				vJumpedAt[id][0] = vOrigin[0];
				vJumpedAt[id][1] = vOrigin[1];
				
				//client_print(id, print_console,"Numb JAT %f %f %f",vOrigin[0], vOrigin[1],vOrigin[2]);
			
				if( doubleducked[id] && vOrigin[2] == vDuckedAt[id][2] )
					cjumped[id] = true;
				else
					cjumped[id] = false;
			
				doubleducked[id] = false;
			
				strafes[id] = INFO_ZERO;
	
				TempSpeed[id] = 0.0;
				//vOrigin[2] -= 70;
				//engfunc( EngFunc_TraceHull, vJumpedAt[id], vOrigin, DONT_IGNORE_MONSTERS, HULL_HUMAN, id, 0 );
				//vJumpedAtEnt[id] = get_tr2( 0, TR_pHit );

				for( i = INFO_ZERO; i < NSTRAFES; i++ )
				{
					strafe_stat_speed[id][i][0] = 0.0;
					strafe_stat_speed[id][i][1] = 0.0;
					strafe_stat_sync[id][i][0] = INFO_ZERO;
					strafe_stat_sync[id][i][1] = INFO_ZERO;
					strafe_stat_time[id][i] = 0.0;
				}
			
				turning_right[id] = false;
				turning_left[id] = false;
				strafing_aw[id] = false;
				strafing_sd[id] = false;

				ljhel[id][0] = 0.0;
				ljhel[id][1] = 0.0;
				ljhel[id][2] = 0.0;

				if( cjumped[id] == false )
				{
					vBeamLastTime[id] = 0.0;
					beam_jump_off_time[id] = jumptime[id];
					for( i = INFO_ZERO; i < 127; i++ )
					{
						vBeamPos[id][i][0] = 0.0;
						vBeamPos[id][i][1] = 0.0;
						vBeamPos[id][i][2] = 0.0;
						vBeamTime[id][i] = 0.0;
					}
					if (jumptype[id] != TYPE_WJ)
						jumptype[id] = TYPE_LJ;
				}
				/*else if (isBhop[id] == true)
				{
					//TODO: we really need this here??
					jumptype[id] = TYPE_BJ;
				}*/
				else 
				{
				 	jumptype[id] = TYPE_CJ;
				}

				for( i = INFO_ZERO; i < 2; i++ )
				{
					vFramePos[id][i][0] = 0.0;
					vFramePos[id][i][1] = 0.0;
					vFramePos[id][i][2] = 0.0;
			
					vFrameSpeed[id][i][0] = 0.0;
					vFrameSpeed[id][i][1] = 0.0;
					vFrameSpeed[id][i][2] = 0.0;
				}

				if( jumptype[id] == TYPE_WJ && !(is_in_duck(id)) )
				{
					set_hudmessage(255, 155, 100, -1.0, 0.70, 0, 0.0, 0.7, 0.1, 0.1, 3);
					if (fSpeed > maxBhopPreSpeedWeap)
					{
						//TODO redone it in PostThink with better msg
						for( i = INFO_ONE; i < 33; i++ )
						{
							if( (i == id || is_user_spectating_player(i, id)) && gHasLjStats[i])
							{
								show_hudmessage(i, "Prestrafe: %f ^nYour Maxspeed was too high^nMaxspeed have to be under %.3f", fMaxGroundSpeed[id], maxBhopPreSpeedWeap);
								client_print(i, print_console, "OLDPrestrafe: %f ^nYour Maxspeed was too high^nMaxspeed have to be under %.3f", fMaxGroundSpeed[id], maxBhopPreSpeedWeap);
							}
						}
					}
					else
					{
						for( i = INFO_ONE; i < 33; i++ )
						{
							if( (i == id || is_user_spectating_player(i, id)) && gHasLjStats[i])
							{
								show_hudmessage(i, "Prestrafe: %f", fMaxGroundSpeed[id]);
								client_print(i, print_console, "OLDPrestrafe: %f", fMaxGroundSpeed[id]);
							}
						}
					}
				}

				vFallAt[id][0] = 0.0;
				vFallAt[id][1] = 0.0;
				vFallAt[id][2] = 0.0;

				//client_print(id, print_console,"wj jumptype[id] %d",jumptype[id] );

			//	if (weapSpeed[id] > 250)
		//		{
	//				client_print(id, print_chat,"vot i prignyli %d flag1 %d ",jumptype[id],flags&FL_ONGROUND);
//				}

			}
			else if( ( fallDown[id] || flags&FL_ONGROUND ) && gInAir[id])
			{		
//				if (weapSpeed[id] > 250)
//				{
//					client_print(id, print_chat,"vot i prizemlilis %d",jumptype[id]);
//				}
				func69(id, TYPE_LCHJ);
//				if (weapSpeed[id] > 250)
//				{
//					client_print(id, print_chat,"vot i prizemlilis2 %d",jumptype[id]);
//				}

				vJumpedAt[id][0] = vFramePos[id][1][0];        //for bhop
				vJumpedAt[id][1] = vFramePos[id][1][1];        //for bhop

				if (!fallDown[id] 
				&& vJumpedAt[id][2] == vOrigin[2]
				&& fm_get_user_longjump(id) == false)
					testBhop[id] = true;
					


				if ((vJumpedAt[id][2] == vOrigin[2]) || fallDown[id] )
				{
					strMess[0] = '^0'; //unnecessary?
					strLen = INFO_ZERO;
					sync_ = INFO_ZERO;
					badSyncTemp = INFO_ZERO;
					goodSyncTemp = INFO_ZERO;
	
					Fulltime = lasttime[id]-jumptime[id];
	
					if(strafes[id] < NSTRAFES)
					{
						strafe_stat_time[id][0] = jumptime[id];
						strafe_stat_time[id][strafes[id]] = lasttime[id];
	
						for(jj = 1;jj <= strafes[id]; jj++)
						{
							time_ = ((strafe_stat_time[id][jj] - strafe_stat_time[id][jj-1])*100) / (Fulltime);
							if ((strafe_stat_sync[id][jj][0]+strafe_stat_sync[id][jj][1]) > 0)
							{
								sync_ = (strafe_stat_sync[id][jj][0] * 100)/(strafe_stat_sync[id][jj][0]+strafe_stat_sync[id][jj][1]); //using like a buffer		
							}				
							else
							{
								sync_ = 0;
							}
							strLen += format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^t%2d^t%4.3f^t%4.3f^t%3.1f%%^t%3d%%^n", jj, strafe_stat_speed[id][jj][0], strafe_stat_speed[id][jj][1], time_, sync_);
	
							goodSyncTemp += strafe_stat_sync[id][jj][0];
							badSyncTemp += strafe_stat_sync[id][jj][1];
						}
						if (jumptype[id] == TYPE_HJ)
						{
							strLen += format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^t^tHJ");
						}
						//if (BlockDist > 210.0 && BlockDist < get_pcvar_float(kz_max_lj))
						//	strLen += format(strMess[strLen],(40*NSTRAFES)-strLen-1, "Block %3.3f", BlockDist);
						//strLen += format(strMess[strLen],(40*NSTRAFES)-strLen-1, "		WeirdJump");
					}

					//Standart Sync
					if( goodSyncTemp > 0 )
						sync_ = (goodSyncTemp*100/(goodSyncTemp+badSyncTemp));
					else
						sync_ = INFO_ZERO;

					//weird jump
					if(fDistance > get_pcvar_float(kz_min_lj) //TODO mb another cvar
					&& jumptype[id] == TYPE_WJ
					&& !(fDistance > get_pcvar_float(kz_max_lj) + 23.0) )
					{
						if( !(possible_lj_script[id][0] || possible_lj_script[id][1] || fallDown[id] || weapSpeed[id] != 250.0 || pev(id, pev_fuser2) == 0.0))
						{
							check_maintop(id, floatround((fDistance*1000000), floatround_floor), floatround((fMaxAirSpeed[id]*1000000), floatround_floor), floatround((fMaxGroundSpeed[id]*1000000), floatround_floor), strafes[id], sync_, TYPE_WJ);
						}
						
						ljStatsRed = get_pcvar_num(kz_ljstats_red);
						ljStatsGreen = get_pcvar_num(kz_ljstats_green);
						ljStatsBlue = get_pcvar_num(kz_ljstats_blue);
						ljs_beam = get_pcvar_num(kz_ljs_beam);
						static i;
	
						if( gHasLjStats[id] && bljbeam[id] )
						{
							DrawBeam(id, ljs_beam, 1);
						}

						static strdist[128];
						num_to_word(floatround(fDistance, floatround_floor), strdist, 127);
						
						for( i = INFO_ONE; i < 33; i++ )
						{
							if( (i == id || is_user_spectating_player(i, id)) && gHasLjStats[i] )
							{
								copy(strMessBuf,strLen,strMess);

								if ( fallDown[id] || weapSpeed[id] != 250.0 || pev(id, pev_fuser2) == 0.0)
								{
									set_hudmessage(255, 0, 109, -1.0, 0.70, 0, 0.0, (vBeamLastTime[id]*0.1), 0.1, 0.1, 3);
								}
								else
								{
									set_hudmessage(ljStatsRed, ljStatsGreen, ljStatsBlue, -1.0, 0.70, 0, 0.0, (vBeamLastTime[id]*0.1), 0.1, 0.1, 3);
								}

								show_hudmessage(i, "WJ Distance: %f^nMaxSpeed: %f (%.3f)^nPreStrafe: %f^nStrafes: %d^nSync: %d%%^n^n^nWeirdJump'd", fDistance, fMaxAirSpeed[id], fMaxAirSpeed[id] - fMaxGroundSpeed[id], fMaxGroundSpeed[id], strafes[id], sync_ );
								client_print(i, print_console, "WJ Distance: %f MaxSpeed: %f (%.3f) PreStrafe: %f Strafes: %d Sync: %d", fDistance, fMaxAirSpeed[id], fMaxAirSpeed[id] - fMaxGroundSpeed[id], fMaxGroundSpeed[id], strafes[id], sync_ );
								
								if ( StrafeStat[i] && strLen != 0 )
								{
									if ( fallDown[id] || weapSpeed[id] != 250.0)
									{
										set_hudmessage(255, 0, 109, 0.70, 0.35, 0, 0.0, ((vBeamLastTime[id]*0.1)), 0.1, 0.1, 4);
									}
									else
									{
										set_hudmessage(ljStatsRed, ljStatsGreen, ljStatsBlue, 0.70, 0.35, 0, 0.0, ((vBeamLastTime[id]*0.1)), 0.1, 0.1, 4);
									}
									show_hudmessage(i,"%s",strMessBuf);
									static strMessHalf[40];
									//if (jumptype[id] == TYPE_HJ || (BlockDist > 210.0 && BlockDist < get_pcvar_float(kz_max_lj)))
									//	strafes[id] += 1;
									for(jj=INFO_ONE; (jj <= strafes[id]) && (jj < NSTRAFES);jj++)
									{
										strtok(strMessBuf,strMessHalf,40,strMessBuf,40*NSTRAFES,'^n');
										replace(strMessHalf,40,"^n","");
										client_print(i, print_console, "%s", strMessHalf);	
									}
								}
	
								if( possible_lj_script[id][0] || possible_lj_script[id][1] )
								{
									if( possible_lj_script[id][0] && possible_lj_script[id][1] )
										client_print(i, print_center, "No ljtop access (possible lj script)");
									else
										client_print(i, print_center, "No ljtop access (possible %s script)", (possible_lj_script[id][0])?"prestrafe":"strafe");
								}
							
								if( get_pcvar_num(kz_lj_sounds) == 2 && gHasColorChat[i] && !(fallDown[id]) && weapSpeed[id] == 250.0 && pev(id, pev_fuser2) > 0.0)
									client_cmd(i, "speak ^"vox/%s uniform(e30) it south(e15)^"", strdist);
								
								if( i != id && (ljs_beam == 1 || ljs_beam == 2) && bljbeam[i] )
								{
									DrawSpecBeam(i);
								}
							}
						}
						//still weird jump
						if (!(fallDown[id]) && weapSpeed[id] == 250.0 && pev(id, pev_fuser2) > 0.0)
						{
							if( !(possible_lj_script[id][0] || possible_lj_script[id][1] ))
							{
								static Float:cj_dif, Float:max_cj, Float:leet_cj, Float:pro_cj, Float:good_cj, Float:god_cj, ljtop;
								cj_dif = get_pcvar_float(kz_cj_dif);
								cj_dif += 5;
								max_cj = get_pcvar_float(kz_max_lj) + 23; 

							/*	leet_cj = get_pcvar_float(kz_leet_lj) + cj_dif; 
								pro_cj = get_pcvar_float(kz_pro_lj) + cj_dif; 
								good_cj = get_pcvar_float(kz_good_lj) + cj_dif; 
							*/

								leet_cj = 265.0; 
								pro_cj = 260.0; 
								good_cj = 255.0; 
								god_cj = 270.0; 
							
								ljtop = get_pcvar_num(kz_ljs_tops);

								if( ljtop == 1 || ljtop == 3 ) 
								{
									if( fDistance < max_cj
									&& !(fDistance < god_cj)
									&& !(0 > god_cj))
									{
										PrintChatMess(id, 3, DIST_GOD, TYPE_WJ);
									}
									else if( fDistance < max_cj
									&& !(fDistance < leet_cj)
									&& !(0 > leet_cj))
									{
										PrintChatMess(id, get_pcvar_num(kz_leet_lj_clr), DIST_LEET, TYPE_WJ);
									}
									else if( fDistance < max_cj
									&& !(fDistance < pro_cj)
									&& !(0 > pro_cj))
									{
										PrintChatMess(id, get_pcvar_num(kz_pro_lj_clr), DIST_PRO, TYPE_WJ);
									}						
									else if( fDistance < max_cj
									&& !(fDistance < good_cj)
									&& !(0 > good_cj))
									{
										PrintChatMess(id, get_pcvar_num(kz_good_lj_clr), DIST_GOOD, TYPE_WJ);
									}
								}
							}
						}
						//jumptype[id] = TYPE_NONE;
					} //long jump
					else if( fDistance > get_pcvar_float(kz_min_lj)
					&& fMaxGroundSpeed[id] < maxPreSpeedWeapon
					&& cjumped[id] == false
					&& !(fDistance > get_pcvar_float(kz_max_lj)) )
					{
						if( !(possible_lj_script[id][0] || possible_lj_script[id][1] || fallDown[id] || weapSpeed[id] != 250.0))
						{
							check_maintop(id, floatround((fDistance*1000000), floatround_floor), floatround((fMaxAirSpeed[id]*1000000), floatround_floor), floatround((fMaxGroundSpeed[id]*1000000), floatround_floor), strafes[id], sync_, TYPE_LJ);
						}
						
						ljStatsRed = get_pcvar_num(kz_ljstats_red);
						ljStatsGreen = get_pcvar_num(kz_ljstats_green);
						ljStatsBlue = get_pcvar_num(kz_ljstats_blue);
						ljs_beam = get_pcvar_num(kz_ljs_beam);
						static i;
	
						if( gHasLjStats[id] && bljbeam[id] )
						{
							DrawBeam(id, ljs_beam, 1);
						}

						static strdist[128];
						num_to_word(floatround(fDistance, floatround_floor), strdist, 127);
						
						for( i = INFO_ONE; i < 33; i++ )
						{
							if( (i == id || is_user_spectating_player(i, id)) && gHasLjStats[i] )
							{
								copy(strMessBuf,strLen,strMess);
	
								if ( fallDown[id] || weapSpeed[id] != 250.0)
								{
									set_hudmessage(255, 0, 109, -1.0, 0.70, 0, 0.0, ((vBeamLastTime[id]*0.1)), 0.1, 0.1, 3);
								}
								else
								{
									set_hudmessage(ljStatsRed, ljStatsGreen, ljStatsBlue, -1.0, 0.70, 0, 0.0, ((vBeamLastTime[id]*0.1)), 0.1, 0.1, 3);
								}
	
								show_hudmessage(i, "Distance: %f^nMaxSpeed: %f (%.3f)^nPreStrafe: %f^nStrafes: %d^nSync: %d%%^n^n^nLongJump'd", fDistance, fMaxAirSpeed[id], fMaxAirSpeed[id] - fMaxGroundSpeed[id], fMaxGroundSpeed[id], strafes[id], sync_ );
								client_print(i, print_console, "Distance: %f MaxSpeed: %f (%.3f) PreStrafe: %f Strafes: %d Sync: %d", fDistance, fMaxAirSpeed[id], fMaxAirSpeed[id] - fMaxGroundSpeed[id], fMaxGroundSpeed[id], strafes[id], sync_ );
								
								if ( StrafeStat[i] && strLen != 0 )
								{
									if ( fallDown[id] || weapSpeed[id] != 250.0)
									{
										set_hudmessage(255, 0, 109, 0.70, 0.35, 0, 0.0, ((vBeamLastTime[id]*0.1)), 0.1, 0.1, 4);
									}
									else
									{
										set_hudmessage(ljStatsRed, ljStatsGreen, ljStatsBlue, 0.70, 0.35, 0, 0.0, ((vBeamLastTime[id]*0.1)), 0.1, 0.1, 4);
									}
									show_hudmessage(i,"%s",strMessBuf);
									static strMessHalf[40];
									//if (jumptype[id] == TYPE_HJ || (BlockDist > 210.0 && BlockDist < get_pcvar_float(kz_max_lj)))
									//	strafes[id] += 1;
									for(jj=INFO_ONE; (jj <= strafes[id]) && (jj < NSTRAFES);jj++)
									{
										strtok(strMessBuf,strMessHalf,40,strMessBuf,40*NSTRAFES,'^n');
										replace(strMessHalf,40,"^n","");
										client_print(i, print_console, "%s", strMessHalf);	
									}
								}

								if( possible_lj_script[id][0] || possible_lj_script[id][1] )
								{
									if( possible_lj_script[id][0] && possible_lj_script[id][1] )
										client_print(i, print_center, "No ljtop access (possible lj script)");
									else
										client_print(i, print_center, "No ljtop access (possible %s script)", (possible_lj_script[id][0])?"prestrafe":"strafe");
								}
								
								if( get_pcvar_num(kz_lj_sounds) == 2 && gHasColorChat[i] && !(fallDown[id]) && weapSpeed[id] == 250.0)
									client_cmd(i, "speak ^"vox/%s uniform(e30) it south(e15)^"", strdist);
								
								if( i != id && (ljs_beam == 1 || ljs_beam == 2) && bljbeam[i] )
								{
									DrawSpecBeam(i);
								}
							}
						}
	
						if (!(fallDown[id]) && weapSpeed[id] == 250.0)
						{
							if( !(possible_lj_script[id][0] || possible_lj_script[id][1] ))
							{
								static Float:max_lj, Float:leet_lj, Float:pro_lj, Float:good_lj, Float:god_lj, ljtop;
								max_lj = get_pcvar_float(kz_max_lj);
/*								leet_lj = get_pcvar_float(kz_leet_lj);
								pro_lj = get_pcvar_float(kz_pro_lj);
								good_lj = get_pcvar_float(kz_good_lj);
*/
								leet_lj = 250.0;
								pro_lj = 245.0;
								good_lj = 240.0;
								god_lj = 255.0;

								ljtop = get_pcvar_num(kz_ljs_tops);
	
								if( ljtop == 1 || ljtop == 3 ) 
								{
									if( fDistance < max_lj
									&& !(fDistance < god_lj)
									&& !(0 > god_lj))
									{
										PrintChatMess(id, 3, DIST_GOD, TYPE_LJ);
									}
									else if( fDistance < max_lj
									&& !(fDistance < leet_lj)
									&& !(0 > leet_lj))
									{
										PrintChatMess(id, get_pcvar_num(kz_leet_lj_clr), DIST_LEET, TYPE_LJ);
									}
									else if( fDistance < max_lj
									&& !(fDistance < pro_lj)
									&& !(0 > pro_lj))
									{
										PrintChatMess(id, get_pcvar_num(kz_pro_lj_clr), DIST_PRO, TYPE_LJ);
									}						
									else if( fDistance < max_lj
									&& !(fDistance < good_lj)
									&& !(0 > good_lj))
									{
										PrintChatMess(id, get_pcvar_num(kz_good_lj_clr), DIST_GOOD, TYPE_LJ);
									}
								}
							}
						}
						//jumptype[id] = TYPE_NONE;
					} //CountJump
					else if( fDistance > get_pcvar_float(kz_min_lj)
					&& fMaxGroundSpeed[id] < maxBhopPreSpeedWeap       //TODO: is it right?
					&& cjumped[id] == true
					&& !(fDistance > (get_pcvar_float(kz_max_lj) + 18)) ) 
					{
						if( !(possible_lj_script[id][0] || possible_lj_script[id][1] || fallDown[id] || weapSpeed[id] != 250.0))
						{
							check_maintop(id, floatround((fDistance*1000000), floatround_floor), floatround((fMaxAirSpeed[id]*1000000), floatround_floor), floatround((fMaxGroundSpeed[id]*1000000), floatround_floor), strafes[id], sync_, TYPE_CJ);
						}
	
						ljStatsRed = get_pcvar_num(kz_ljstats_red);
						ljStatsGreen = get_pcvar_num(kz_ljstats_green);
						ljStatsBlue = get_pcvar_num(kz_ljstats_blue);
						ljs_beam = get_pcvar_num(kz_ljs_beam);
						static i;
	
						if( gHasLjStats[id] && bljbeam[id])
						{
							i = DrawBeam(id, ljs_beam, 2);
						}
		
						static strdist[128];
						num_to_word(floatround(fDistance, floatround_floor), strdist, 127);
	
						for( i = INFO_ONE; i < 33; i++ )
						{
							if( (i == id || is_user_spectating_player(i, id)) && gHasLjStats[i] )
							{
								copy(strMessBuf,strLen,strMess);

								if ( fallDown[id] || weapSpeed[id] != 250.0)
								{
									set_hudmessage(255, 0, 109, -1.0, 0.70, 0, 0.0, ((vBeamLastTime[id]*0.1)), 0.1, 0.1, 3);
								}
								else
								{
									set_hudmessage(ljStatsRed, ljStatsGreen, ljStatsBlue, -1.0, 0.70, 0, 0.0, ((vBeamLastTime[id]*0.1)), 0.1, 0.1, 3);
								}

								show_hudmessage(i, "CJ Distance: %f^nMaxSpeed: %f (%.3f)^nPreStrafe: (%.3f) %f^nStrafes: %d^nSync: %d%%^n^n^nCountJump'd", fDistance, fMaxAirSpeed[id], fMaxAirSpeed[id] - fMaxGroundSpeed[id], fCjPreSpeed[id],fMaxGroundSpeed[id], strafes[id], sync_ );
								client_print(i, print_console, "CJ Distance: %f MaxSpeed: %f (%.3f) PreStrafe: (%.3f) %f Strafes: %d Sync: %d", fDistance, fMaxAirSpeed[id], fMaxAirSpeed[id] - fMaxGroundSpeed[id], fCjPreSpeed[id], fMaxGroundSpeed[id], strafes[id], sync_ );
								
								if ( StrafeStat[i] && strLen != 0 )
								{
									if ( fallDown[id] || weapSpeed[id] != 250.0)
									{
										set_hudmessage(255, 0, 109, 0.70, 0.35, 0, 0.0, ((vBeamLastTime[id]*0.1)), 0.1, 0.1, 4);
									}
									else
									{
										set_hudmessage(ljStatsRed, ljStatsGreen, ljStatsBlue, 0.70, 0.35, 0, 0.0, ((vBeamLastTime[id]*0.1)), 0.1, 0.1, 4);
									}
									show_hudmessage(i,"%s",strMessBuf);
									static strMessHalf[40];
									for(jj=INFO_ONE; (jj <= strafes[id]) && (jj < NSTRAFES);jj++)
									{
										strtok(strMessBuf,strMessHalf,40,strMessBuf,40*NSTRAFES,'^n');
										replace(strMessHalf,40,"^n","");
										client_print(i, print_console, "%s", strMessHalf);	
									}
								}	
		
								if( possible_lj_script[id][0] || possible_lj_script[id][1] )
								{
									if( possible_lj_script[id][0] && possible_lj_script[id][1] )
										client_print(i, print_center, "No ljtop access (possible cj script)");
									else
										client_print(i, print_center, "No ljtop access (possible %s script)", (possible_lj_script[id][0])?"prestrafe":"strafe");
								}
								
								if( get_pcvar_num(kz_lj_sounds) == 2 && gHasColorChat[i] && !(fallDown[id]) && weapSpeed[id] == 250.0)
									client_cmd(i, "speak ^"vox/%s uniform(e30) it south(e15)^"", strdist);
								
								if( i != id && (ljs_beam == 1 || ljs_beam == 2) && bljbeam[i])
								{
									DrawSpecBeam(i);
								}
							}
						}
						
						if (!(fallDown[id]) && weapSpeed[id] == 250.0)
						{
							if( !(possible_lj_script[id][0] || possible_lj_script[id][1] ))
							{
								static Float:cj_dif, Float:max_cj, Float:leet_cj, Float:pro_cj, Float:good_cj, Float:god_cj, ljtop;
								cj_dif = get_pcvar_float(kz_cj_dif);
								max_cj = get_pcvar_float(kz_max_lj) + 18; 

/*								leet_cj = get_pcvar_float(kz_leet_lj) + cj_dif; 
								pro_cj = get_pcvar_float(kz_pro_lj) + cj_dif; 
								good_cj = get_pcvar_float(kz_good_lj) + cj_dif; */

								leet_cj = 260.0; 
								pro_cj = 255.0; 
								good_cj = 250.0; 
								god_cj = 265.0; 

								ljtop = get_pcvar_num(kz_ljs_tops);
	
								if( ljtop == 1 || ljtop == 3 )
								{
									if( fDistance < max_cj
									&& !(fDistance < god_cj)
									&& !(cj_dif > god_cj) )
									{
										PrintChatMess(id, 3, DIST_GOD, TYPE_CJ);
									}					
									else if( fDistance < max_cj
									&& !(fDistance < leet_cj)
									&& !(cj_dif > leet_cj) )
									{
										PrintChatMess(id, get_pcvar_num(kz_leet_cj_clr), DIST_LEET, TYPE_CJ);
									}					
									else if( fDistance < max_cj
									&& !(fDistance < pro_cj)
									&& !(cj_dif > pro_cj) )
									{
										PrintChatMess(id, get_pcvar_num(kz_pro_cj_clr), DIST_PRO, TYPE_CJ);
									}					
									else if( fDistance < max_cj
									&& !(fDistance < good_cj)
									&& !(cj_dif > good_cj) )
									{
										PrintChatMess(id, get_pcvar_num(kz_good_cj_clr), DIST_GOOD, TYPE_CJ);
									}
								}
							}
						}
					}
					//jumptype[id] = TYPE_NONE;
				}
				if (testBhop[id] == false)
				{
					fMaxAirSpeed[id] = 0.0;
					fMaxGroundSpeed[id] = 250.0;
				}
				cjumped[id] = false;

				jumptype[id] = TYPE_NONE;

				//gInAir[id] = false; //why??
			}
			else if( flags&FL_ONGROUND
			&& gInAir[id] == false )
			{
/*
				//TODO: Vashe strannaia zashita; very strange protection, why we need it
				pev(id, pev_velocity, vVelocity);
				vVelocity[2]-=vVelocity[2];

				if( vector_length(vVelocity) > maxPreSpeedWeapon
				&& doubleducked[id] == false)
				{
					set_task(0.5,"gocheck", id);				
				}
*/
				//gInAir[id] = false; //why?
				fMaxAirSpeed[id] = 0.0;
				fMaxGroundSpeed[id] = 250.0; 
				cjumped[id] = false;
			}
		} 

		if (gInAir[id] || isBhop[id] || doubleducked[id])
		{
			static i, j;
			j = 0;
			for( i = INFO_ZERO; i < 127; i++ )
			{
				if( i == 126 || (vBeamPos[id][i][0] == 0
				&& vBeamPos[id][i][1] == 0
				&& vBeamPos[id][i][2] == 0
				&& vBeamTime[id][i] == 0) )
				{
					pev(id, pev_origin, vBeamPos[id][i]);
					//client_print(id, print_console,"%d	%f	%f",i, vBeamPos[id][i][0],vBeamPos[id][i][1]);
					if( i == 0 )
						vBeamTime[id][i] = 15.0;
					else
						vBeamTime[id][i] = (get_gametime()-beam_jump_off_time[id])*10+15;
					
					if( doubleducked[id] == true || induck[id] == true )
						vBeamPosStatus[id][i] = -1.0;
					else if( is_in_duck(id) )
						vBeamPosStatus[id][i] = 1.0;
					else
						vBeamPosStatus[id][i] = 0.0;

					vBeamLastTime[id] = vBeamTime[id][i];

					j=i;
					
					{
						ljhel[id][0] += vBeamPos[id][i][0];
						ljhel[id][1] += vBeamPos[id][i][1];
					}
					if (i < 13 && i > 2 && (i%3)==0 && jumptype[id] != TYPE_HJ && jumptype[id] != TYPE_WJ)
					{
						pev(id, pev_origin, vOrigin);
						vOrigin[2] = vJumpedAt[id][2] - 38.0;
						if (HJdetect(id, vOrigin))
						      jumptype[id] = TYPE_HJ;
					}
					i=127;
				}
			}

			if ( j > 3 && (j%4)==0 && (gInAir[id] == true || isBhop[id] == true) && bljhelp[id])
			{
				message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0, 0, 0}, id);
				write_byte (0);
				write_coord(floatround(vJumpedAt[id][0]));
				write_coord(floatround(vJumpedAt[id][1]));
				//write_coord(floatround(vOldOrigin2[id]-34));
				write_coord(floatround(vJumpedAt[id][2]-34));
				write_coord(floatround((220/j)*((ljhel[id][0]/(j+1))-vJumpedAt[id][0])+vJumpedAt[id][0]));
				write_coord(floatround((220/j)*((ljhel[id][1]/(j+1))-vJumpedAt[id][1])+vJumpedAt[id][1]));
				//write_coord(floatround(vOldOrigin2[id]-34));
				write_coord(floatround(vJumpedAt[id][2]-34));
				write_short(gBeam);
				write_byte(0);			
				write_byte(0);
				if (j < 70)
				{
					write_byte(2);
				}
				else
				{
					write_byte(17);
				}
				write_byte(20);
				write_byte(0);
				write_byte(random_num(32, 255));
				write_byte(random_num(32, 255));
				write_byte(random_num(32, 255));
				write_byte(200);
				write_byte(0);
				message_end();
			}
		}

		if( flags&FL_ONGROUND )
		{
			if (!pev( id, pev_solid ))
			{
				static ClassName[32];
				pev(pev(id, pev_groundentity), pev_classname, ClassName, 32);
	
				if( equal(ClassName, "func_train")
					|| equal(ClassName, "func_conveyor") 
					|| equal(ClassName, "trigger_push") || equal(ClassName, "trigger_gravity"))
				{
					gocheck(id);
					set_task(0.4,"gocheck", id);
					gocheckbhop(id);
					set_task(0.4,"gocheckbhop", id);
				}
				else if(equal(ClassName, "func_door") || equal(ClassName, "func_door_rotating") )
				{
					gocheck(id);
					set_task(0.4,"gocheck", id);			
				}
			}

		/*	if (jumptype[id] == TYPE_WJ && OnGround[id] && !(gInAir[id])) //2nd frame
			{
				set_hudmessage(255, 0, 109, -1.0, 0.70, 0, 0.0, 0.5, 0.1, 0.1, 3);
				static i;
				for( i = INFO_ONE; i < 33; i++ )
				{
					if( (i == id || is_user_spectating_player(i, id)) && gHasLjStats[i])
					{
						show_hudmessage(id,"Too late for weird jump");
						//client_print(id, print_console, "You pressed jump too early");
					}
				}
				gocheck(id);
				set_task(0.2,"gocheck", id);
				//jumptype[id] = TYPE_NONE;
			}		*/
	/*		
			//TODO: hates this detection of CJ, need to redone it with better detection type
			if( OnGround[id] == false && !(jumptype[id] == TYPE_WJ) )
			{
				//pev(id, pev_origin, vOrigin); //why we need it?
				if( doubleducked[id] == false
				&& !(cjumped[id] == true
				&& buttons&IN_JUMP
				&& !(oldbuttons&IN_JUMP)) )
				{
					set_task(0.4,"gocheck", id);
				}
				else if( doubleducked[id] == true
				&& vOrigin[2] != vDuckedAt[id][2] )
				{
					set_task(0.5,"gocheck", id);
				}
				OnGround[id] = true;
			}
			else if (OnGround[id] == false && jumptype[id] == TYPE_WJ )
			{
				if( !(buttons&IN_JUMP && !(oldbuttons&IN_JUMP)) )
				OnGround[id] = true;
			}			
*/
			//TODO: hates this detection of CJ, need to redone it with better detection type
			if( OnGround[id] == false )
			{
				//pev(id, pev_origin, vOrigin); //why we need it?
				if( doubleducked[id] == false
				&& !(cjumped[id] == true
				&& buttons&IN_JUMP
				&& !(oldbuttons&IN_JUMP)) 
				&& jumptype[id] != TYPE_WJ) //mb better jumptype[id] == TYPE_NONE
				{
					set_task(0.4,"gocheck", id);
				//	client_print(id, print_console,"popali v 1");//1111
				}
				else if( doubleducked[id] == true
				&& vOrigin[2] != vDuckedAt[id][2] )
				{
					set_task(0.5,"gocheck", id);
					//client_print(id, print_console,"popali v 2");//1111
				}

				if (jumptype[id] == TYPE_WJ && !(cjumped[id]))
				{
					pev(id, pev_origin, vFallAt[id]);
					//client_print(id, print_console,"da etoje WJ");//1111
				}
				OnGround[id] = true;
			}
		}

		if( buttons&IN_DUCK
		&& flags&FL_ONGROUND
		&& gInAir[id] == false
		&& isBhop[id] == false
		&& (fSpeed < maxPreSpeedWeapon && jumptype[id] != TYPE_WJ ) )
		{
			if( induck[id] == false )
			{
				cducked[id] = true;
				induck[id] = true;
				set_task(0.1,"testcjstart", id);
				
				pev(id, pev_origin, vOrigin);
				vDuckedAt[id][0] = vOrigin[0];
				vDuckedAt[id][1] = vOrigin[1];
				vDuckedAt[id][2] = vOrigin[2];
				beam_jump_off_time[id] = get_gametime();
				fCjPreSpeed[id] = fSpeed;
				
				static i;
				for( i = INFO_ZERO; i < 127; i++ )
				{
					vBeamPos[id][i][0] = 0.0;
					vBeamPos[id][i][1] = 0.0;
					vBeamPos[id][i][2] = 0.0;
					vBeamTime[id][i] = 0.0;
				}
				vBeamLastTime[id] = 0.0;
			}
		}
		else if( oldbuttons&IN_DUCK )
		{
			induck[id] = false;
			if( cducked[id] == true && !is_in_duck(id) )
			{
				set_task(0.3,"ddend", id);
				doubleducked[id] = true;
				cducked[id] = false;
			}
		}

		if( !(flags&FL_ONGROUND) )
		{
			OnGround[id] = false;
			//client_print(id, print_console,"WJ Prestrafe %f",vVelocity[2]);
			pev(id, pev_velocity, vVelocity);
			if (vVelocity[2] == -4.0 || 
				vVelocity[2] == -4.4 || 
				vVelocity[2] == -4.8 || 
				vVelocity[2] == -3.599999 || 
				vVelocity[2] == -3.2) // -4.  -12.  -20.  -28.  -36.  -44.  -52.  -60.  -68.  -76.  -84.  -92.  -100.  -108.  -116.
			{
				if(!(cjumped[id]))
					jumptype[id] = TYPE_WJ;				
			}
			//if (weapSpeed[id] > 250)
			//{//11111
			//	client_print(id, print_chat,"vot i vzleteli %f",vVelocity[2]);
			//}
		}
	}
	return FMRES_IGNORED;
}

public fwdPlayerPostThink(id)
{
	if( is_user_alive(id) && get_pcvar_num(kz_ljs_enabled) )
	{
		static buttonsNew, flags, i;
		buttonsNew = pev(id, pev_button);
		flags = pev(id, pev_flags);

		static Float:ori[3];
		
		pev(id, pev_origin, ori);
		pev(id, pev_velocity, vVelocity);

		vVelocity[2] = 0.0;
		fSpeed = vector_length(vVelocity);

		if( (flags&FL_ONGROUND)
		&& (gInAir[id] == true || OnGround[id] == false || isBhop[id])) //dont need @OnGround[id] == false@ here i think
		{
			fwdPlayerPreThink(id);
		}

		//maxBhopPreSpeedWeap = weapSpeed[id]*1.2;

		//Linear loss of speed can be calcilated like speed = (WeaponSpeed*1.2)*0.8
		if ( isBhop[id] && (gSpeed > maxBhopPreSpeedWeap) && (fSpeed < gSpeed - 30.0) && gInAir[id] ) ///w00t that gInAir here rulezz
		{
			fMaxAirSpeed[id] = fSpeed;
			fMaxGroundBhopSpeed[id] += (fSpeed - gSpeed);//(gSpeed - fMaxGroundSpeed[id]); //is it right?
			fMaxGroundSpeed[id] = fSpeed;
			//client_print(id, print_console, "gSpeed %f fSpeed %f",gSpeed, fSpeed);
			set_hudmessage(255,255, 200, -1.0, 0.70, 0, 0.0, 0.7, 0.1, 0.1, 3);
			for( i = INFO_ONE; i < 33; i++ )
			{
				if( (i == id || is_user_spectating_player(i, id)) && gHasLjStats[i])
				{
					show_hudmessage(i, "Prestrafe: %f (%.3f)^nYour Maxspeed was too high %.3f^nMaxspeed have to be under %.3f", fMaxGroundSpeed[id], fMaxGroundBhopSpeed[id], gSpeed, maxBhopPreSpeedWeap);
					//client_print(i, print_console, "Prestrafe: %f (%.3f)^nYour Maxspeed was too high %.3f^nMaxspeed have to be under %.3f", fMaxGroundSpeed[id], fMaxGroundBhopSpeed[id], gSpeed, maxBhopPreSpeedWeap);
				}
			}
		}
		
		pev(id, pev_angles, angle);
		if( old_angle1[id] > angle[1] )
		{
			turning_left[id] = false;
			turning_right[id] = true;
		}
		else if( old_angle1[id] < angle[1] )
		{
			turning_left[id] = true;
			turning_right[id] = false;
		}
		else
		{
			turning_left[id] = false;
			turning_right[id] = false;
		}
	
	/*	if( strafing_aw[id] == false
		&& (buttonsNew&IN_MOVELEFT)
		&& (turning_left[id] == true || turning_right[id] == true )
		&& !(buttonsNew&IN_MOVERIGHT || buttonsNew&IN_BACK) )
		{
			strafing_aw[id] = true;
			strafing_sd[id] = false;
			if(strafes[id] < NSTRAFES)
				strafe_stat_time[id][strafes[id]] = get_gametime();
			strafes[id] += INFO_ONE;
		}
		else if( strafing_sd[id] == false
		&& (buttonsNew&IN_MOVERIGHT)
		&& (turning_left[id] == true || turning_right[id] == true )
		&& !(buttonsNew&IN_MOVELEFT || buttonsNew&IN_FORWARD) )
		{
			strafing_aw[id] = false;
			strafing_sd[id] = true;
			if(strafes[id] < NSTRAFES)
				strafe_stat_time[id][strafes[id]] = get_gametime();
			strafes[id] += INFO_ONE;
		}
		*/

		if( !(strafecounter_oldbuttons[id]&IN_MOVELEFT) && buttonsNew&IN_MOVELEFT
		&& !(buttonsNew&IN_MOVERIGHT) && !(buttonsNew&IN_BACK) && !(buttonsNew&IN_FORWARD)
		&& (turning_left[id] || turning_right[id]) )
		{
			if(strafes[id] < NSTRAFES)
				strafe_stat_time[id][strafes[id]] = get_gametime();
			strafes[id] += INFO_ONE;
		}
		else if( !(strafecounter_oldbuttons[id]&IN_MOVERIGHT) && buttonsNew&IN_MOVERIGHT
		&& !(buttonsNew&IN_MOVELEFT) && !(buttonsNew&IN_BACK) && !(buttonsNew&IN_FORWARD)
		&& (turning_left[id] || turning_right[id]) )
		{
			if(strafes[id] < NSTRAFES)
				strafe_stat_time[id][strafes[id]] = get_gametime();
			strafes[id] += INFO_ONE;
		}
		else if( !(strafecounter_oldbuttons[id]&IN_BACK) && buttonsNew&IN_BACK
		&& !(buttonsNew&IN_MOVELEFT) && !(buttonsNew&IN_MOVERIGHT) && !(buttonsNew&IN_FORWARD)
		&& (turning_left[id] || turning_right[id]) )
		{
			if(strafes[id] < NSTRAFES)
				strafe_stat_time[id][strafes[id]] = get_gametime();
			strafes[id] += INFO_ONE;
		}
		else if( !(strafecounter_oldbuttons[id]&IN_FORWARD) && buttonsNew&IN_FORWARD
		&& !(buttonsNew&IN_MOVELEFT) && !(buttonsNew&IN_MOVERIGHT) && !(buttonsNew&IN_BACK)
		&& (turning_left[id] || turning_right[id]) )
		{
			if(strafes[id] < NSTRAFES)
				strafe_stat_time[id][strafes[id]] = get_gametime();
			strafes[id] += INFO_ONE;
		}

		//add ginAir check here
		if( buttonsNew&IN_MOVERIGHT
		|| buttonsNew&IN_MOVELEFT
		|| buttonsNew&IN_FORWARD
		|| buttonsNew&IN_BACK )
		{
			if(strafes[id] < NSTRAFES)
			{
				if( fSpeed > gSpeed)
					strafe_stat_sync[id][strafes[id]][0] += INFO_ONE;
				else
					strafe_stat_sync[id][strafes[id]][1] += INFO_ONE;

				//client_print(id, print_console,"OldSpeed[id] %f gSpeed %f", OldSpeed[id], gSpeed);
			}
			//else
			//{//TODO: ! if player made more than NSTRAFES}
		}
		
		//OldSpeed[id] = fSpeed;
		
		if( buttonsNew&IN_RIGHT
		|| buttonsNew&IN_LEFT )
		{
			if( flags&FL_ONGROUND )
			{
				possible_lj_script[id][1] = false;
				
				if( fSpeed > 250 ) //change ro weap speed, if we need it
				{
					if( task_exists(id+534490) )
						remove_task(id+534490);
					
					possible_lj_script[id][0] = true;
				}
			}
			else if( gInAir[id] || isBhop[id] )
				possible_lj_script[id][1] = true;
		}
		else if( flags&FL_ONGROUND )
		{
			possible_lj_script[id][1] = false;
			
			if( !task_exists(id+534490) && possible_lj_script[id][0] )
				set_task(1.5, "isnt_prestrafe_cheating", id+534490);
		}

		if( buttons&IN_MOVERIGHT && (buttons&IN_MOVELEFT || buttons&IN_FORWARD || buttons&IN_BACK) )
			strafecounter_oldbuttons[id] = INFO_ZERO;
		else if( buttons&IN_MOVELEFT && (buttons&IN_FORWARD || buttons&IN_BACK || buttons&IN_MOVERIGHT) )
			strafecounter_oldbuttons[id] = INFO_ZERO;
		else if( buttons&IN_FORWARD && (buttons&IN_BACK || buttons&IN_MOVERIGHT || buttons&IN_MOVELEFT) )
			strafecounter_oldbuttons[id] = INFO_ZERO;
		else if( buttons&IN_BACK && (buttons&IN_MOVERIGHT || buttons&IN_MOVELEFT || buttons&IN_FORWARD) )
			strafecounter_oldbuttons[id] = INFO_ZERO;
		else if( turning_left[id] || turning_right[id] )
			strafecounter_oldbuttons[id] = buttons;
	}
}

public isnt_prestrafe_cheating(id)
	possible_lj_script[id-534490][0] = false;

public fwdTouch(ent, id)
{ 
	static ClassName[32];
	if( pev_valid(ent) )
	{
		pev(ent, pev_classname, ClassName, 31);
	}
	static ClassName2[32];
	if( pev_valid(id) )
	{
		pev(id, pev_classname, ClassName2, 31);
	}
	if( equal(ClassName2, "player") )
	{
		//IF we need protection from func_door and func_door_rotating uncomment lines
		//if( pev(id, pev_groundentity) == ent && (gInAir[id] || !OnGround[id] || testBhop[id]) ) //TODO remove BUG from here
		//{
		//	if( pev(id, pev_flags)&FL_ONGROUND && get_gametime() > (jumptime[id]+0.1))
		//	{
		//		fwdPlayerPreThink(id);
		//	}
		//}

	//	static Float:ori[3];
//		static Float:velo[3];
		
//		pev(id, pev_origin, ori);
	//	pev(id, pev_velocity, velo);

	//	if (weapSpeed[id] == 260)
	//		client_print(id, print_console,"Tou %f	%f	%f	%f	%f	%f", ori[0],ori[1],ori[2],velo[0],velo[1],velo[2]);

		//BUG?? plr can touch smth illegal on last frame... 
		//There is No bug, because: PreThink - Engine - Touch - PostThink, but if u uncomment upper lines we will get that bug
		if( equal(ClassName, "func_train")
			|| equal(ClassName, "func_conveyor") 
			|| equal(ClassName, "trigger_push") || equal(ClassName, "trigger_gravity"))
		{
			gocheck(id);
			set_task(0.4,"gocheck", id);
			gocheckbhop(id);
			set_task(0.4,"gocheckbhop", id);
		}
		//IF we need protection from func_door and func_door_rotating uncomment lines
		//else if(equal(ClassName, "func_door") || equal(ClassName, "func_door_rotating") )
		//{
		//	gocheck(id);
		//	set_task(0.4,"gocheck", id);			
		//}
	}	
}

stock get_spectated_player(spectator)
{
	if( !pev_valid(spectator) )
		return 0;
	if( !is_user_connected(spectator) )
		return 0;
	if( is_user_alive(spectator) )
		return 0;
	if( pev(spectator, pev_deadflag) != 2 )
		return 0;
	
	static player, specmode;
	specmode = pev(spectator, pev_iuser1);
	if( !(specmode == 1 || specmode == 2 || specmode == 4) )
		return 0;
	
	player = pev(spectator, pev_iuser2);
	
	if( !pev_valid(player) )
		return 0;
	if( !is_user_connected(player) )
		return 0;
	if( !is_user_alive(player) )
		return 0;
	
	return player;
}

stock is_user_spectating_player(spectator, player)
{
	if( !pev_valid(spectator) || !pev_valid(player) )
		return 0;
	if( !is_user_connected(spectator) || !is_user_connected(player) )
		return 0;
	if( is_user_alive(spectator) || !is_user_alive(player) )
		return 0;
	if( pev(spectator, pev_deadflag) != 2 )
		return 0;
	
	static specmode;
	specmode = pev(spectator, pev_iuser1);
	if( !(specmode == 1 || specmode == 2 || specmode == 4) )
		return 0;
	
	if( pev(spectator, pev_iuser2) == player )
		return 1;
	
	return 0;
}

stock is_in_duck(player)
{
	// supplied with invalid entities
	if( !pev_valid(player)  )
		return 0;
	
	// retrieve absolutes
	static Float:absmin[3], Float:absmax[3];
	
	pev(player, pev_absmin, absmin);
	pev(player, pev_absmax, absmax);
	
	absmin[2]+=64.0;
	
	if( absmin[2] < absmax[2] )
		return 0;
	
	return 1;
}
/*stock bool:fm_get_user_longjump(index) 
{
	new value[2];
	engfunc(EngFunc_GetPhysicsKeyValue, index, "slj", value, 1);
	switch (value[0]) 
	{
		case '1': return true;
	}

	return false;
}*/
stock Float:fm_distance_to_floor2(index,const Float:start[3], ignoremonsters = 1) 
{
	// nerekomendyy ispolzovat tk probivaet raznie i neskolko textyr za raz v opredelennih sly4aiah 
	//(dont use it if u dont know how it works)
	
	new Float:dest[3], Float:end[3];
	dest[0] = start[0];
	dest[1] = start[1];
	dest[2] = -8191.0;

	engfunc(EngFunc_TraceLine, start, dest, ignoremonsters, index);
	global_get(glb_trace_endpos, end);
	if (end[2] == -8191.0)
		return 0.0;
	
	new Float:ret = start[2] - end[2];
	return ret > 0 ? ret : 0.0;
}

stock bool:HJdetect(index,const Float:vOrigin[3])
{
	//TODO better HJ detect...  not buged like this
	static Float:vStop[3], Float:vStart[3];
	
	static Float:vVel[3];
	static Float:speed;
	static Float:fraction;
	
	pev(index, pev_velocity, vVel);
	speed = vector_length(vVel);
	
	if( speed < 0.1 )
	{
		return false;
	}
	
	vStart[0] = vStop[0] = vOrigin[0] + vVel[0]/speed*16.03125;
	vStart[1] = vStop[1] = vOrigin[1] + vVel[1]/speed*16.03125;
	vStart[2] = vOrigin[2];// + vMins[2]; // get origin of player's feet
	vStop[2] = vStart[2] - 69.0; // Changed from 34 to 70 for CS? Or am i doing something wrong..?

	if( engfunc(EngFunc_PointContents, vStart) == CONTENTS_SOLID ) // make sure start origin isn't in void space, this happens on hills. not sure if it really applies edgefriction here
	{
		return false;
	}

	engfunc(EngFunc_TraceLine, vStart, vStop, 1, index); // trace a line from player feet to 70 units below that
	//beam(index, vStart, vStop);
	global_get(glb_trace_fraction, fraction);
	if( fraction == 1.0 ) 
		return true;
	return false;
}

stock DrawBeam(id, _ljs_beam, type)
{
	//predvaritelno nado podgotovit vJumpedAt2 vTraceEnd vBeamPos vOrigin gBeam vBeamTime dl9 type == 1 = lj = bj 
	// CJ - type ==2 
	static i;

	if( _ljs_beam == 1)
	{
		message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0, 0, 0}, id);
		write_byte (0);
		write_coord(floatround(vJumpedAt2[0]));
		write_coord(floatround(vJumpedAt2[1]));
		write_coord(floatround(vJumpedAt2[2]));
		write_coord(floatround(vTraceEnd[0]));
		write_coord(floatround(vTraceEnd[1]));
		write_coord(floatround(vTraceEnd[2]));
		write_short(gBeam);
		write_byte(1);
		write_byte(5);
		write_byte(30);
		write_byte(20);
		write_byte(0);
		write_byte(random_num(32, 255));
		write_byte(random_num(32, 255));
		write_byte(random_num(32, 255));
		write_byte(200);
		write_byte(200);
		message_end();
	}
	else if( _ljs_beam == 2)
	{
		set_task(0.4, "gocheck", id);
		set_task(0.8, "gocheck", id);
		set_task(1.2, "gocheck", id);
		for( i = INFO_ZERO; i < 127; i++ )
		{
			if( i == 0 )
			{
				message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0, 0, 0}, id);
				write_byte (0);
				if (type == 1)
				{
					write_coord(floatround(vJumpedAt2[0]));
					write_coord(floatround(vJumpedAt2[1]));
				}
				else if (type == 2)
				{
					write_coord(floatround(vDuckedAt[id][0]));
					write_coord(floatround(vDuckedAt[id][1]));
				}
				write_coord(floatround(vTraceEnd[2]));
				write_coord(floatround(vBeamPos[id][0][0]));
				write_coord(floatround(vBeamPos[id][0][1]));
				write_coord(floatround(vTraceEnd[2]));
				write_short(gBeam);
				write_byte(1);
				write_byte(5);
				write_byte(15);
				write_byte(20);
				write_byte(0);
				if (type == 1)
					write_byte(255);
				else if (type == 2)
					write_byte(0);
				write_byte(255);
				write_byte(0);
				write_byte(200);
				write_byte(200);
				message_end();
									
				message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0, 0, 0}, id);
				write_byte (0);
				write_coord(floatround(vBeamPos[id][0][0]));
				write_coord(floatround(vBeamPos[id][0][1]));
				write_coord(floatround(vTraceEnd[2]));
				write_coord(floatround(vBeamPos[id][1][0]));
				write_coord(floatround(vBeamPos[id][1][1]));
				write_coord(floatround(vTraceEnd[2]));
				write_short(gBeam);
				write_byte(1);
				write_byte(5);
				write_byte(15);
				write_byte(20);
				write_byte(0);
				if (type == 1)
					write_byte(255);
				else if (type == 2)
					write_byte(0);
				write_byte(255);
				write_byte(0);
				write_byte(200);
				write_byte(200);
				message_end();
			}
			else if( i == 126 || (vBeamPos[id][i+1][0] == 0
			&& vBeamPos[id][i+1][1] == 0
			&& vBeamPos[id][i+1][2] == 0) )
			{
				message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0, 0, 0}, id);
				write_byte (0);
				write_coord(floatround(vBeamPos[id][i][0]));
				write_coord(floatround(vBeamPos[id][i][1]));
				write_coord(floatround(vTraceEnd[2]));
				write_coord(floatround(vOrigin[0]));
				write_coord(floatround(vOrigin[1]));
				write_coord(floatround(vTraceEnd[2]));
				write_short(gBeam);
				write_byte(1);
				write_byte(5);
				write_byte(floatround(vBeamTime[id][i]));
				write_byte(20);
				write_byte(0);
				if( vBeamPosStatus[id][i] == 1 )
				{
					write_byte(255);
					write_byte(0);
					write_byte(0);
				}
				else
				{
					write_byte(255);
					write_byte(255);
					write_byte(0);
				}
				write_byte(200);
				write_byte(200);
				message_end();
				
				message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0, 0, 0}, id);
				write_byte (0);
				write_coord(floatround(vOrigin[0]));
				write_coord(floatround(vOrigin[1]));
				write_coord(floatround(vTraceEnd[2]));
				write_coord(floatround(vTraceEnd[0]));
				write_coord(floatround(vTraceEnd[1]));
				write_coord(floatround(vTraceEnd[2]));
				write_short(gBeam);
				write_byte(1);
				write_byte(5);
				write_byte(floatround(vBeamTime[id][i]));
				write_byte(20);
				write_byte(0);
				if( vBeamPosStatus[id][i] == 1 )
				{
					write_byte(255);
					write_byte(0);
					write_byte(0);
				}
				else
				{
					write_byte(255);
					write_byte(255);
					write_byte(0);
				}
				write_byte(200);
				write_byte(200);
				message_end();
				break;
			}
			else
			{
				message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0, 0, 0}, id);
				write_byte (0);
				write_coord(floatround(vBeamPos[id][i][0]));
				write_coord(floatround(vBeamPos[id][i][1]));
				write_coord(floatround(vTraceEnd[2]));
				write_coord(floatround(vBeamPos[id][i+1][0]));
				write_coord(floatround(vBeamPos[id][i+1][1]));
				write_coord(floatround(vTraceEnd[2]));
				write_short(gBeam);
				write_byte(1);
				write_byte(5);
				write_byte(floatround(vBeamTime[id][i]));
				write_byte(20);
				write_byte(0);
				if( vBeamPosStatus[id][i] == 1)
				{
					write_byte(255);
					write_byte(0);
					write_byte(0);
				}
				else if( vBeamPosStatus[id][i] == -1 && type == 2)
				{
					write_byte(0);
					write_byte(255);
					write_byte(0);
				}
				else
				{	
					write_byte(255);
					write_byte(255);
					write_byte(0);
				}
				write_byte(200);
				write_byte(200);
				message_end();
			}
		}
	}
	return i;	
}

stock DrawSpecBeam(i)
{
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0, 0, 0}, i);
	write_byte (0);
	write_coord(floatround(vJumpedAt2[0]));
	write_coord(floatround(vJumpedAt2[1]));
	write_coord(floatround(vJumpedAt2[2]));
	write_coord(floatround(vTraceEnd[0]));
	write_coord(floatround(vTraceEnd[1]));
	write_coord(floatround(vTraceEnd[2]));
	write_short(gBeam);
	write_byte(1);
	write_byte(5);
	write_byte(30);
	write_byte(20);
	write_byte(0);
	write_byte(random_num(32, 255));
	write_byte(random_num(32, 255));
	write_byte(random_num(32, 255));
	write_byte(200);
	write_byte(200);
	message_end();
}

stock PrintChatMess(id, color, _DistType, _JumpType)
{
	static name[33], i;
	get_user_name(id, name, 31);

		//TODO za4em takie yslovi9 ???? //why we need such if //pohorowemy (i == id || is_user_spectating_player(i, id)) nenado
		// pohorowemy voobshe bgo a ne yslovi9

	if( _JumpType == TYPE_LJ )
	{
		for( i = INFO_ONE; i < 33; i++ )
		{	
			if( i == id || is_user_spectating_player(i, id) || (pev_valid(i) && is_user_connected(i) && gHasColorChat[i]) )
			{
				if( color < 6 && color > 0 )
				{
					switch(color)
					{
						case 1: ColorChat(i, RED, "[XJ] %s jumped %.3f units with lj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 2: ColorChat(i, GREEN, "[XJ] %s jumped %.3f units with lj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 3: ColorChat(i, RED, "[XJ] %s jumped %.3f units with lj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 4: ColorChat(i, GREY, "[XJ] %s jumped %.3f units with lj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 5: ColorChat(i, TEAM_COLOR, "[XJ] %s jumped %.3f units with lj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
					}
				}
				else
					client_print(i, print_chat, "[XJ] %s jumped %.3f units with lj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);

				if( get_pcvar_num(kz_lj_sounds) == 1 )
				{
					if (_DistType == DIST_PRO)
					{
						if( (i == id || is_user_spectating_player(i, id)))
							client_cmd(i, "speak misc/perfect");
					}
					else if (_DistType == DIST_LEET)
					{
						if( i == id || is_user_spectating_player(i, id) )
							client_cmd(i, "speak misc/mod_wickedsick");
					}
					else if (_DistType == DIST_GOOD)
					{
						if( i == id || is_user_spectating_player(i, id) )
							client_cmd(i, "speak misc/impressive");
					}
					else if (_DistType == DIST_GOD)
					{
							client_cmd(i, "speak misc/mod_godlike");
					}
				}
			}
		}
	}
	else if ( _JumpType == TYPE_CJ )
	{
		for( i = INFO_ONE; i < 33; i++ )
		{	
			if( i == id || is_user_spectating_player(i, id) || (pev_valid(i) && is_user_connected(i) && gHasColorChat[i]) )
			{
				if( color < 6 && color > 0 )
				{
					switch(color)
					{
						case 1: ColorChat(i, RED, "[XJ] %s jumped %.3f units with cj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 2: ColorChat(i, GREEN, "[XJ] %s jumped %.3f units with cj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 3: ColorChat(i, RED, "[XJ] %s jumped %.3f units with cj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 4: ColorChat(i, GREY, "[XJ] %s jumped %.3f units with cj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 5: ColorChat(i, TEAM_COLOR, "[XJ] %s jumped %.3f units with cj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
					}
				}
				else
					client_print(i, print_chat, "[XJ] %s jumped %.3f units with cj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);

				if( get_pcvar_num(kz_lj_sounds) == 1 )
				{
					if (_DistType == DIST_PRO)
					{
						if( (i == id || is_user_spectating_player(i, id)))
							client_cmd(i, "speak misc/perfect");
					}
					else if (_DistType == DIST_LEET)
					{
						if( i == id || is_user_spectating_player(i, id) )
							client_cmd(i, "speak misc/mod_wickedsick");
					}
					else if (_DistType == DIST_GOOD)
					{
						if( i == id || is_user_spectating_player(i, id) )
							client_cmd(i, "speak misc/impressive");
					}
					else if (_DistType == DIST_GOD)
					{
							client_cmd(i, "speak misc/mod_godlike");
					}
				}
			}
		}
	}
	else if ( _JumpType == TYPE_WJ )
	{
		for( i = INFO_ONE; i < 33; i++ )
		{	
			if( i == id || is_user_spectating_player(i, id) || (pev_valid(i) && is_user_connected(i) && gHasColorChat[i]) )
			{
				if( color < 6 && color > 0 )
				{
					switch(color)
					{
						case 1: ColorChat(i, BLUE, "[XJ] %s jumped %.3f units with wj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 2: ColorChat(i, GREEN, "[XJ] %s jumped %.3f units with wj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 3: ColorChat(i, RED, "[XJ] %s jumped %.3f units with wj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 4: ColorChat(i, GREY, "[XJ] %s jumped %.3f units with wj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 5: ColorChat(i, TEAM_COLOR, "[XJ] %s jumped %.3f units with wj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
					}
				}
				else
					client_print(i, print_chat, "[XJ] %s jumped %.3f units with wj!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);

				if( get_pcvar_num(kz_lj_sounds) == 1 )
				{
					if (_DistType == DIST_PRO)
					{
						if( (i == id || is_user_spectating_player(i, id)))
							client_cmd(i, "speak misc/perfect");
					}
					else if (_DistType == DIST_LEET)
					{
						if( i == id || is_user_spectating_player(i, id) )
							client_cmd(i, "speak misc/mod_wickedsick");
					}
					else if (_DistType == DIST_GOOD)
					{
						if( i == id || is_user_spectating_player(i, id) )
							client_cmd(i, "speak misc/impressive");
					}
					else if (_DistType == DIST_GOD)
					{
							client_cmd(i, "speak misc/mod_godlike");
					}
				}
			}
		}
	}
	else if ( _JumpType == TYPE_BJ )
	{
		for( i = INFO_ONE; i < 33; i++ )
		{	
			if( i == id || is_user_spectating_player(i, id) || (pev_valid(i) && is_user_connected(i) && gHasColorChat[i]) )
			{
				if( color < 6 && color > 0 )
				{
					switch(color)
					{
						case 1: ColorChat(i, BLUE, "[XJ] %s jumped %.3f units with bhop!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 2: ColorChat(i, GREEN, "[XJ] %s jumped %.3f units with bhop!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 3: ColorChat(i, RED, "[XJ] %s jumped %.3f units with bhop!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 4: ColorChat(i, GREY, "[XJ] %s jumped %.3f units with bhop!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 5: ColorChat(i, TEAM_COLOR, "[XJ] %s jumped %.3f units with bhop!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
					}
				}
				else
					client_print(i, print_chat, "[XJ] %s jumped %.3f units with bhop!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);

				if( get_pcvar_num(kz_lj_sounds) == 1 )
				{
					if (_DistType == DIST_PRO)
					{
						if( (i == id || is_user_spectating_player(i, id)))
							client_cmd(i, "speak misc/perfect");
					}
					else if (_DistType == DIST_LEET)
					{
						if( i == id || is_user_spectating_player(i, id) )
							client_cmd(i, "speak misc/mod_wickedsick");
					}
					else if (_DistType == DIST_GOOD)
					{
						if( i == id || is_user_spectating_player(i, id) )
							client_cmd(i, "speak misc/impressive");
					}
					else if (_DistType == DIST_GOD)
					{
							client_cmd(i, "speak misc/mod_godlike");
					}
				}
			}
		}
	}
	else if ( _JumpType == TYPE_SBJ )
	{
		for( i = INFO_ONE; i < 33; i++ )
		{	
			if( i == id || is_user_spectating_player(i, id) || (pev_valid(i) && is_user_connected(i) && gHasColorChat[i]) )
			{
				if( color < 6 && color > 0 )
				{
					switch(color)
					{
						case 1: ColorChat(i, BLUE, "[XJ] %s jumped %.3f units with stand-up bhop!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 2: ColorChat(i, GREEN, "[XJ] %s jumped %.3f units with stand-up bhop!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 3: ColorChat(i, RED, "[XJ] %s jumped %.3f units with stand-up bhop!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 4: ColorChat(i, GREY, "[XJ] %s jumped %.3f units with stand-up bhop!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
						case 5: ColorChat(i, TEAM_COLOR, "[XJ] %s jumped %.3f units with stand-up bhop!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);
					}
				}
				else
					client_print(i, print_chat, "[XJ] %s jumped %.3f units with stand-up bhop!^x01 (Strafe: %d / Sync: %d%%)", name, fDistance,strafes[id], sync_);

				if( get_pcvar_num(kz_lj_sounds) == 1 )
				{
					if (_DistType == DIST_PRO)
					{
						if( (i == id || is_user_spectating_player(i, id)))
							client_cmd(i, "speak misc/perfect");
					}
					else if (_DistType == DIST_LEET)
					{
						if( i == id || is_user_spectating_player(i, id) )
							client_cmd(i, "speak misc/mod_wickedsick");
					}
					else if (_DistType == DIST_GOOD)
					{
						if( i == id || is_user_spectating_player(i, id) )
							client_cmd(i, "speak misc/impressive");
					}
					else if (_DistType == DIST_GOD)
					{
							client_cmd(i, "speak misc/mod_godlike");
					}
				}
			}
		}
	}
}

stock func69(id, type)
{
	if( type == TYPE_BJ)
	{
		isBhop[id] = false;
	}
	else
	{
		set_task(0.5,"gocheck", id); //why we need it ?
		gInAir[id] = false;
	}

	//static Float:BlockDist;
	//BlockDist = 0.0;

	if (fallDown[id] == true)
	{
		vOrigin[0]= vLastFrameOrigin[id][0];
		vOrigin[1]= vLastFrameOrigin[id][1];
		vOrigin[2]= vLastFrameOrigin[id][2];
	}
	else
	{
		pev(id, pev_origin, vOrigin);
	}

	//client_print(id, print_console, "vOrigin %f %f %f Speed %f %f %f",vOrigin[0],vOrigin[1],vOrigin[2],vFrameSpeed[id][1][0],vFrameSpeed[id][1][1],vFrameSpeed[id][1][2]);

	fDistance1 = get_distance_f(vJumpedAt[id], vOrigin)+32.0;
	//client_print(id, print_console, "fDistance1 %f vor %f %f %f", fDistance1, vOrigin[0],vOrigin[1],vOrigin[2]);
	//client_print(id, print_console, "fDistance1 %f", fDistance1);

	rLandPos[2] = vFrameSpeed[id][0][2] * vFrameSpeed[id][0][2] + (2 * get_pcvar_float(sv_gravity) * (vFramePos[id][0][2] - vOrigin[2]));
	//client_print(id, print_console, "111 %f %f %f",vFrameSpeed[id][0][2],vFramePos[id][0][2],vOrigin[2]);
	rDistance[0] = (floatsqroot(rLandPos[2]) * -1) - vFrameSpeed[id][1][2];

	//client_print(id, print_console, "RaZ diff %f  notSqrtZvel %f",(vFramePos[id][0][2] - vOrigin[2]),rLandPos[2]);
	rDistance[1] = get_pcvar_float(sv_gravity)*-1;
	//client_print(id, print_console, "rLandPos[2] %f ^n", rLandPos[2]);
				
	frame2time = floatdiv(rDistance[0], rDistance[1]);
	client_print(id, print_console, "frame2time	%f %f",frame2time, fDistance1);
	if( vFrameSpeed[id][1][0] < 0 )
		vFrameSpeed[id][1][0] = vFrameSpeed[id][1][0]*-1;
	rDistance[0] = frame2time*vFrameSpeed[id][1][0];
			
	if( vFrameSpeed[id][1][1] < 0 )
		vFrameSpeed[id][1][1] = vFrameSpeed[id][1][1]*-1;
	rDistance[1] = frame2time*vFrameSpeed[id][1][1];

	if( vFrameSpeed[id][1][2] < 0 )
		vFrameSpeed[id][1][2] = vFrameSpeed[id][1][2]*-1;
	rDistance[2] = frame2time*vFrameSpeed[id][1][2];

	//client_print(id, print_console, "frame2time %f rD0 %f rD1 %f %f",frame2time,rDistance[0],rDistance[1],rDistance[2]);

	//client_print(id, print_console, "vFramePos[id][1][0] %f %f vFramePos[id][1][1] %f %f", vFramePos[id][1][0],vOrigin[0], vFramePos[id][1][1],vOrigin[1]);
	if( vFramePos[id][1][0] < vOrigin[0] )
		rLandPos[0] = vFramePos[id][1][0] + rDistance[0];
	else
		rLandPos[0] = vFramePos[id][1][0] - rDistance[0];
	if( vFramePos[id][1][1] < vOrigin[1] )
		rLandPos[1] = vFramePos[id][1][1] + rDistance[1];
	else
		rLandPos[1] = vFramePos[id][1][1] - rDistance[1];

	if( is_in_duck(id) )
		vOrigin[2]+=18.0;

	rLandPos[2] = vOrigin[2];

	//client_print(id, print_console, "rLandPos %f %f %f", rLandPos[0],rLandPos[1],rLandPos[2]);

	frame2time += (lasttime[id]-jumptime[id]);

	//client_print(id, print_console, "vJumpedAt[id][2] %f rLandPos[2] %f vFramePos[id][0][2] %f vOrigin[2]modif %f",vJumpedAt[id][2],rLandPos[2],vFramePos[id][0][2], vOrigin[2]);

	//client_print(id, print_console, "vFrameSpeed[id][0][2] %f", vFrameSpeed[id][0][2]);

	if( vOrigin[2] == vJumpedAt[id][2] )
	{
		if ( type == TYPE_BJ )
		{
			if(!(frame2time > 0.48 && frame2time < 0.7) && pev(id, pev_fuser2) > 0.0) //why we use pev_fuser2) > 0.0 here ???
			{
				vOrigin[2] = vOrigin[2]*-1;
			}
		}
		else
		{
			if( is_in_duck(id) && !(frame2time > 0.71 && frame2time < 0.77) )
			{
				vOrigin[2] = vOrigin[2]*-1;
			}
			else if( !(is_in_duck(id)) && !(frame2time > 0.65 && frame2time < 0.70) )
			{
				vOrigin[2] = vOrigin[2]*-1;
			}
		}
	}
	fDistance2 = get_distance_f(vJumpedAt[id], rLandPos)+32.00;

	//client_print(id, print_console, "fDistance2 %f vFrameSpeed[id][0][2] %f vFrameSpeed[id][1][2] %f", fDistance2, vFrameSpeed[id][0][2],vFrameSpeed[id][1][2]);
				
		//if( (fDistance1+0.25 > fDistance2) && type == TYPE_BJ ) //TODO good calculation
	if( fDistance1 > fDistance2 )
	{
		fDistance = fDistance2;
		vOrigin[0] = rLandPos[0];
		vOrigin[1] = rLandPos[1];
	}
	else
		fDistance = fDistance1;

	vJumpedAt2[2] = vJumpedAt[id][2]-34.0;
	vTraceEnd[2] = vOrigin[2]-34.0;
				
	vJumpedAt2[0] = vJumpedAt[id][0];
	vTraceEnd[0] = vOrigin[0];

	vJumpedAt2[1] = vJumpedAt[id][1]-vJumpedAt[id][1];
	vTraceEnd[1] = vOrigin[1]-vOrigin[1];

	xDistance = get_distance_f(vJumpedAt2, vTraceEnd);

	vJumpedAt2[0] = vJumpedAt[id][0]-vJumpedAt[id][0];
	vTraceEnd[0] = vOrigin[0]-vOrigin[0];

	vJumpedAt2[1] = vJumpedAt[id][1];
	vTraceEnd[1] = vOrigin[1];

	yDistance = get_distance_f(vJumpedAt2, vTraceEnd);

	if( vJumpedAt[id][0] > vOrigin[0] )
	{
		vJumpedAt2[0] = vJumpedAt[id][0]+(xDistance*16.03125/fDistance);
		vTraceEnd[0] = vOrigin[0]-(xDistance*16.03125/fDistance);
	}
	else if( vJumpedAt[id][0] < vOrigin[0] )
	{
		vJumpedAt2[0] = vJumpedAt[id][0]-(xDistance*16.03125/fDistance);
		vTraceEnd[0] = vOrigin[0]+(xDistance*16.03125/fDistance);
	}
	else
	{
		vJumpedAt2[0] = vJumpedAt[id][0];
		vTraceEnd[0] = vOrigin[0];
	}

	if( vJumpedAt[id][1] > vOrigin[1] )
	{
		vJumpedAt2[1] = vJumpedAt[id][1]+(yDistance*16.03125/fDistance);
		vTraceEnd[1] = vOrigin[1]-(yDistance*16.03125/fDistance);
	}
	else if( vJumpedAt[id][1] < vOrigin[1] )
	{
		vJumpedAt2[1] = vJumpedAt[id][1]-(yDistance*16.03125/fDistance);
		vTraceEnd[1] = vOrigin[1]+(yDistance*16.03125/fDistance);
	}
	else
	{
		vJumpedAt2[1] = vJumpedAt[id][1];
		vTraceEnd[1] = vOrigin[1];
	}
}	


stock func77(id, type)	
{	
	static ent2; 
	new Float:orig[3];
	static classname3[33];
	pev(id, pev_origin, orig);
	if (is_in_duck(id))
	{
		while((ent2 = engfunc(EngFunc_FindEntityInSphere, 33, orig, 19.0)) != 0) 
		{ 
			pev(ent2, pev_classname, classname3, 32); 
			if( equal(classname3, "func_train")
				|| equal(classname3, "func_conveyor") 
				|| equal(classname3, "trigger_push") 
				|| equal(classname3, "trigger_gravity")
				|| equal(classname3, "func_door")
				|| equal(classname3, "func_door_rotating") )
			{
				return 1;
			}
		}
	}
	else 
	{
		while((ent2 = engfunc(EngFunc_FindEntityInSphere, 33, orig, 37.0)) != 0) 
		{ 
			pev(ent2, pev_classname, classname3, 32); 
			if( equal(classname3, "func_train")
				|| equal(classname3, "func_conveyor") 
				|| equal(classname3, "trigger_push") 
				|| equal(classname3, "trigger_gravity")
				|| equal(classname3, "func_door")
				|| equal(classname3, "func_door_rotating") )
			{
				return 1;
			}
		}
	}
	return 0;
}
