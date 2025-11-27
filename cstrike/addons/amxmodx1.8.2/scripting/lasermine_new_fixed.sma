#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <cstrike>
#include <zombieplague>


#pragma tabsize 0


#define PLUGIN "[ZP] LaserMine" //kkt1
#define VERSION "2.8.1" //fake
#define AUTHOR "SandStriker / Shidla / QuZ/DJ_WEST" //lev fix


#define MODE_LASERMINE 0 // 0? dmg pe hit
#define ACCESS ADMIN_IMMUNITY
#define CHAT_TAG "^4[ZOMBIE.THEXFORCE.RO]^1"
//#define LOCK_SPEED

static const	LMName[] = "LASER-MINE",
		LMCost = 2, //ammo
		LMTeam = ZP_TEAM_ANY, //0-all

		Red_Hum      = 0,
		Green_Hum    = 0,
		Blue_Hum   = 255,

		Red_Zomb   = 255,
		Green_Zomb    = 0,
		Blue_Zomb   = 0,

	   ENT_MODELS[]   = "models/v_tripmine.mdl",

	   ENT_SOUND1[]   = "weapons/mine_deploy.wav", 
	   ENT_SOUND2[]   = "weapons/mine_charge.wav",
	   ENT_SOUND3[]   = "weapons/mine_activate.wav",

	   ENT_SOUND6[]   = "debris/bustglass1.wav",
	   ENT_SOUND7[]   = "debris/bustglass2.wav",
	   ENT_SOUND4[]   = "debris/beamstart9.wav",
	   
	   ENT_SOUND5[]   = "items/gunpickup2.wav",

	   ENT_SPRITE1[]   = "sprites/laserbeam.spr",
	   ENT_SPRITE2[]   = "sprites/lm_explode.spr",

	   ENT_CLASS_NAME[]   =   "lasermine", 
	   ENT_CLASS_NAME3[]   =   "func_breakable", 
	   gSnarkClassName[]   =   "wpn_snark",  
	   barnacle_class[]   =   "barnacle",      
	   weapon_box[]      =   "weaponbox";

#define RemoveEntity(%1) engfunc(EngFunc_RemoveEntity,%1)

#define TASK_PLANT 15100 
#define TASK_RESET 15500 
#define TASK_RELEASE 15900 

#define LASERMINE_TEAM pev_iuser1
#define LASERMINE_COUNT pev_fuser1
#define LASERMINE_OWNER pev_iuser2
#define LASERMINE_BEAMENDPOINT pev_vuser1
#define LASERMINE_POWERUP pev_fuser2
#define LASERMINE_STEP pev_iuser3
#define LASERMINE_BEAMTHINK pev_fuser3
#define LASERMINE_HITING pev_iuser4

enum tripmine_e { 
   TRIPMINE_IDLE1 = 0, 
   TRIPMINE_IDLE2, 
   TRIPMINE_ARM1, 
   TRIPMINE_ARM2, 
   TRIPMINE_FIDGET, 
   TRIPMINE_HOLSTER, 
   TRIPMINE_DRAW, 
   TRIPMINE_WORLD, 
   TRIPMINE_GROUND, 
}; 
enum 
{ 
   POWERUP_THINK, 
   BEAMBREAK_THINK, 
   EXPLOSE_THINK,

   POWERUP_SOUND, 
   ACTIVATE_SOUND, 
   STOP_SOUND
}; 

new g_EntMine, beam, boom 
new g_LENABLE, g_LFMONEY, g_LAMMO, g_LDMGh,g_LDMGz, g_LBEO, g_LTMAX, g_LHEALTH, g_LMODE, g_LRADIUS, g_NOROUND 
new g_LRDMGz,g_LRDMGh,g_LFF,g_LDELAY, g_LVISIBLE, g_LSTAMMO, g_LACCESS, g_LGLOW, g_LDMGMODE, g_LCLMODE 
new g_LCBRIGHT, g_LDSEC, g_LCMDMODE, g_LBUYMODE, g_LME, g_LDETAIL; 
new g_msgDeathMsg,g_msgScoreInfo,g_msgDamage,g_msgStatusText; 
new g_dcount[33],g_nowtime,g_MaxPL 
new bool:g_settinglaser[33] 
new ID_BLOOD; 
//new g_LCOST

new g_havemine[33], g_deployed[33]; 

	#if defined LOCK_SPEED
		new Float:plspeed[33]
	#endif

public plugin_init() 
{ 
   register_plugin(PLUGIN, VERSION, AUTHOR);

   g_LME=zp_register_extra_item(LMName,LMCost,LMTeam)
  
   register_clcmd("+setlaser","CreateLaserMine_Progress_b"); 
   register_clcmd("-setlaser","StopCreateLaserMine"); 

   register_clcmd("+dellaser","ReturnLaserMine_Progress"); 
   register_clcmd("-dellaser","StopReturnLaserMine");

   register_clcmd("say","say_lasermine");
   register_clcmd("say_team","say_lasermine");
   //register_clcmd("buy_lasermine","BuyLasermine");

   register_concmd("lm_take", "luatlaser", ACCESS, " - <nume>"); 
   register_concmd("lm_give", "puslaser", ACCESS, " - <nume>"); 

   g_LENABLE   = register_cvar("lm","1"); //e activ?
   g_LACCESS   = register_cvar("lm_acc","0"); //0-all / 1-admin
   g_LMODE      = register_cvar("lm_mode","0"); //0-kill / 1-tripmine
   g_LAMMO      = register_cvar("lm_ammo","1"); //limita de lm
   g_LSTAMMO   = register_cvar("lm_startammo","1"); //cu cate lm incepe runda

   g_LDMGz      = register_cvar("lm_dmg_zm","2000"); //dmg la zm
   g_LDMGh      = register_cvar("lm_dmg_hm","75"); //dmg la hm

   g_LFMONEY   = register_cvar("lm_fragammo","5"); //ammo pe frag
   g_LHEALTH   = register_cvar("lm_health","500"); //hp lm
   g_LTMAX      = register_cvar("lm_teammax","10"); // lm intr-o echipa
   g_LRADIUS   = register_cvar("lm_radius","320.0") //zona din jurul laser-ului

   g_LRDMGz      = register_cvar("lm_rdmg_zm","500.0") // dmg la explozie pt zm
   g_LRDMGh      = register_cvar("lm_rdmg_hm","50.0") // dmg la explozie pt hm

   g_LFF      = register_cvar("lm_ff","0"); //friendly-fire focus
   g_NOROUND   = register_cvar("lm_noround","1"); //doar cand incepe infectia se poate crea lm
   g_LDELAY   = register_cvar("lm_delay","10"); //dupa cat timp de la infectie poti planta
   g_LVISIBLE   = register_cvar("lm_line","1"); //linia este vizibila?
   g_LGLOW      = register_cvar("lm_glow","1"); //stralucire specifica lm
   g_LCBRIGHT   = register_cvar("lm_bright","255"); //lumina emisa de linie (255-maxim)
   g_LCLMODE   = register_cvar("lm_color","0"); //0-team color/1-green

   g_LDMGMODE   = register_cvar("lm_ldmgmode","0"); //laser hit damage mode. (0 is frame dmg, 1 is once dmg, 2 is seconds dmg)
   g_LDSEC      = register_cvar("lm_ldmgseconds","1"); //pe cate secunde sa ia dmg

   g_LBUYMODE   = register_cvar("lm_buymode","1"); //1-lm moka/2-pe ammo
   g_LCMDMODE   = register_cvar("lm_cmdmode","1"); //command mode. (0 is +USE key, 1 is bind, 2 is each)
   g_LBEO      = register_cvar("lm_brokeenemy","1"); //ia dmg la owner/coechipieri?
   g_LDETAIL  = register_cvar("lm_realistic_detail", "1"); //efecte lm

   register_event("DeathMsg", "DeathEvent", "a"); 
   //register_event("CurWeapon", "standing", "be", "1=1"); 
   register_event("ResetHUD", "delaycount", "a");
   register_event("HLTV", "newround", "a", "1=0", "2=0")
   register_event("Damage","CutDeploy_onDamage","b");

   register_logevent("endround", 2, "1=Round_End")

   g_msgDeathMsg = get_user_msgid("DeathMsg");
   g_msgScoreInfo = get_user_msgid("ScoreInfo");
   g_msgDamage = get_user_msgid("Damage");
   g_msgStatusText = get_user_msgid("StatusText");
  
   register_forward(FM_Think, "ltm_Think");
   //register_forward(FM_PlayerPostThink, "ltm_PostThink");
   register_forward(FM_PlayerPreThink, "ltm_PreThink");
	register_forward(FM_TraceLine,		"MinesShowInfo", 1);

   RegisterHam(Ham_TakeDamage, ENT_CLASS_NAME3, "Laser_TakeDamage",0);
	#if defined LOCK_SPEED
	   RegisterHam(Ham_Spawn,"player","SPCMD",1)
	#endif

   register_dictionary("lasermines.txt") 
} 

public plugin_precache() 
{ 
   precache_sound(ENT_SOUND1); 
   precache_sound(ENT_SOUND2); 
   precache_sound(ENT_SOUND3); 
   precache_sound(ENT_SOUND4); 
   precache_sound(ENT_SOUND5); 
   precache_sound(ENT_SOUND6); 
   precache_sound(ENT_SOUND7); 
   precache_model(ENT_MODELS);

   beam = precache_model(ENT_SPRITE1); 
   boom = precache_model(ENT_SPRITE2); 
} 

public plugin_modules()
{
   require_module("fakemeta");
   require_module("cstrike");
}

public plugin_cfg() 
{ 
   g_EntMine = engfunc(EngFunc_AllocString,ENT_CLASS_NAME3); 
   //arrayset(g_havemine,0,sizeof(g_havemine)); 
   //arrayset(g_deployed,0,sizeof(g_deployed)); 
   g_MaxPL = get_maxplayers(); 

   new file[64]; get_localinfo("amxx_configsdir",file,63); 
   format(file, 63, "%s/lm_cvars.cfg", file); 
   if(file_exists(file)) server_cmd("exec %s", file), server_exec(); 
} 

public luatlaser(id, level, cid) 
{ 
   if (!cmd_access(id, level, cid, 2)) 
   { 
      return PLUGIN_HANDLED 
   } 

   new arg[32] 
    
   read_argv(1, arg, 31) 
   new player = cmd_target(id, arg, CMDTARGET_ALLOW_SELF) 
    
   if (!player) 
      return PLUGIN_HANDLED 

   DeleteTask(player); 
   RemoveAllTripmines(player); 

   new namea[32],namep[32]; 
   get_user_name(id,namea,charsmax(namea)); 
   get_user_name(player,namep,charsmax(namep)); 
   client_printcolor(0, "!g[LM]!y Adminul!g %s!y i-a dezactivat laserele lui g %s", namea, namep);
   return PLUGIN_HANDLED; 
} 
public puslaser(id, level, cid) 
{ 
   if (!cmd_access(id, level, cid, 2)) 
   { 
      return PLUGIN_HANDLED 
   } 

   new arg[32] 
    
   read_argv(1, arg, 31) 
   new player = cmd_target(id, arg, CMDTARGET_ALLOW_SELF) 
    
   if (!player) 
      return PLUGIN_HANDLED 

   DeleteTask(player); 
   SetStartAmmo(player); 

   new namea[32],namep[32]; 
   get_user_name(id,namea,charsmax(namea)); 
   get_user_name(player,namep,charsmax(namep)); 
   client_printcolor(0, "!g[LM]!y Adminul!g %s!y i-a reactivat laserele lui!g %s", namea, namep);

   return PLUGIN_HANDLED; 
} 

public Laser_TakeDamage(victim, inflictor, attacker, Float:f_Damage, bit_Damage) {
	if(get_pcvar_num(g_LBEO)<0||get_pcvar_num(g_LBEO)>4)	return HAM_IGNORED
	static entityName[35]; pev(victim, pev_classname, entityName, charsmax(entityName));
	if (!equali(entityName, ENT_CLASS_NAME))	return HAM_IGNORED;
	static i_Owner ;i_Owner = pev(victim, LASERMINE_OWNER)
	switch(get_pcvar_num(g_LBEO)) {
		case 0:	{
			if(i_Owner != attacker) return HAM_SUPERCEDE;
		}
		case 1:	{
			if(CsTeams:pev(victim, LASERMINE_TEAM) != cs_get_user_team(attacker)) return HAM_SUPERCEDE;
		}
		case 2:{
			return HAM_IGNORED;
		}
		case 3:{
			if(i_Owner == attacker || CsTeams:pev(victim, LASERMINE_TEAM) == cs_get_user_team(attacker))	return HAM_SUPERCEDE;
		}
		case 4:{
			if(cs_get_user_team(i_Owner)==cs_get_user_team(attacker))	return HAM_SUPERCEDE;
		}
		default:{
			return HAM_IGNORED;
		}
	}
	return HAM_SUPERCEDE
}

public delaycount(id)	g_dcount[id] = floatround(get_gametime());

public CreateLaserMine_Progress_b(id) 
{ 
   if(get_pcvar_num(g_LCMDMODE) != 0)	CreateLaserMine_Progress(id);

   return PLUGIN_HANDLED; 
} 
public CreateLaserMine_Progress(id) 
{ 
   if(!CreateCheck(id))	return PLUGIN_HANDLED;

   g_settinglaser[id] = true;
	#if defined LOCK_SPEED
	   set_pev(id, pev_maxspeed, 1.0)
	#endif

   message_begin(MSG_ONE, 108, {0,0,0}, id); 
   write_byte(1); 
   write_byte(0); 
   message_end(); 

   set_task(1.2, "Spawn", (TASK_PLANT + id)); 

   return PLUGIN_HANDLED;
}
public Spawn(id) 
{ 
   id -= TASK_PLANT 
  
   new i_Ent = engfunc(EngFunc_CreateNamedEntity,g_EntMine); 
   if(!i_Ent) 
   { 
      client_printcolor(id,"[Laesrmine Debug] Can't Create Entity"); 
      return
   }

   /*new iEntx = g_MaxPL + 1; 
   new clsname[32]; 
   while((iEntx = engfunc(EngFunc_FindEntityByString, iEntx, "classname", ENT_CLASS_NAME))) 
   {
         clsname[0] = '^0' 
         pev(iEntx, pev_classname, clsname, sizeof(clsname)-1); 
         if(equali(clsname, ENT_CLASS_NAME)	//||equali(clsname, ENT_CLASS_NAME3)//	) 
         { 
		PlaySound(iEntx, STOP_SOUND); 
		RemoveEntity(iEntx);
		StopCreateLaserMine(id)
		return
         }
	 //else	set_pev(iEnt, pev_flags, FL_KILLME); 
   }*/

   set_pev(i_Ent,pev_classname,ENT_CLASS_NAME); 

   engfunc(EngFunc_SetModel,i_Ent,ENT_MODELS); 

   set_pev(i_Ent,pev_solid,SOLID_NOT); 
   set_pev(i_Ent,pev_movetype,MOVETYPE_FLY);
   set_pev(i_Ent,pev_frame,0); 
   set_pev(i_Ent,pev_body,3); 
   set_pev(i_Ent,pev_sequence,TRIPMINE_WORLD); 
   set_pev(i_Ent,pev_framerate,0); 
   set_pev(i_Ent,pev_takedamage,DAMAGE_YES); 
   set_pev(i_Ent,pev_dmg,100.0);

   set_user_health(i_Ent,get_pcvar_num(g_LHEALTH));

   new Float:vOrigin[3],Float:vNewOrigin[3],Float:vNormal[3],Float:vTraceDirection[3], Float:vTraceEnd[3],Float:vEntAngles[3]; 
   pev(id, pev_origin, vOrigin);
   velocity_by_aim(id, 128, vTraceDirection); 
   xs_vec_add(vTraceDirection, vOrigin, vTraceEnd); 
   engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, 0);

   new Float:fFraction; 
   get_tr2(0, TR_flFraction, fFraction); 

   if(fFraction < 1.0) 
   { 
      get_tr2(0, TR_vecEndPos, vTraceEnd); 
      get_tr2(0, TR_vecPlaneNormal, vNormal); 
   } 

   xs_vec_mul_scalar(vNormal, 8.0, vNormal); 
   xs_vec_add(vTraceEnd, vNormal, vNewOrigin); 

   engfunc(EngFunc_SetSize, i_Ent, Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 4.0 }); 
   engfunc(EngFunc_SetOrigin, i_Ent, vNewOrigin); 

   vector_to_angle(vNormal,vEntAngles); 
   set_pev(i_Ent,pev_angles,vEntAngles); 

   new Float:vBeamEnd[3], Float:vTracedBeamEnd[3]; 
        
   xs_vec_mul_scalar(vNormal, 8192.0, vNormal); 
   xs_vec_add(vNewOrigin, vNormal, vBeamEnd); 

   engfunc(EngFunc_TraceLine, vNewOrigin, vBeamEnd, IGNORE_MONSTERS, -1, 0); 

   get_tr2(0, TR_vecPlaneNormal, vNormal); 
   get_tr2(0, TR_vecEndPos, vTracedBeamEnd); 
  
   set_pev(i_Ent, LASERMINE_OWNER, id); 
   set_pev(i_Ent,LASERMINE_BEAMENDPOINT,vTracedBeamEnd); 
   set_pev(i_Ent,LASERMINE_TEAM,int:cs_get_user_team(id)); 
   new Float:fCurrTime = get_gametime(); 

   set_pev(i_Ent,LASERMINE_POWERUP, fCurrTime + 2.5); 
   set_pev(i_Ent,LASERMINE_STEP,POWERUP_THINK); 
   set_pev(i_Ent,pev_nextthink, fCurrTime + 0.2); 

   PlaySound(i_Ent,POWERUP_SOUND); 
   g_deployed[id]++; 
   g_havemine[id]--; 
   DeleteTask(id); 
   ShowAmmo(id);

	#if defined LOCK_SPEED
	   resetspeed(id)
	#endif
}

public ReturnLaserMine_Progress(id) 
{ 
   if(!ReturnCheck(id))	return PLUGIN_HANDLED;

   g_settinglaser[id] = true; 

   message_begin(MSG_ONE, 108, {0,0,0}, id); 
   write_byte(1); 
   write_byte(0); 
   message_end(); 

   set_task(1.2, "ReturnMine", (TASK_RELEASE + id)); 

   return PLUGIN_HANDLED; 
}
public ReturnMine(id) 
{ 
   id -= TASK_RELEASE;

   new tgt,body,Float:vo[3],Float:to[3]; 
   get_user_aiming(id,tgt,body);

   if(!pev_valid(tgt)) return;

   pev(id,pev_origin,vo); 
   pev(tgt,pev_origin,to);

   if(get_distance_f(vo,to) > 70.0) return;

   new EntityName[32]; 
   pev(tgt, pev_classname, EntityName, 31);

   if(!equal(EntityName, ENT_CLASS_NAME)) return;

   if(pev(tgt,LASERMINE_OWNER) != id) return;

   RemoveEntity(tgt); 

   g_havemine[id] ++; 
   g_deployed[id] --; 
   emit_sound(id, CHAN_ITEM, ENT_SOUND5, VOL_NORM, ATTN_NORM, 0, PITCH_NORM) 
   ShowAmmo(id) 

   return; 
}

public StopCreateLaserMine(id) 
{ 
   DeleteTask(id);

   message_begin(MSG_ONE, 108, {0,0,0}, id); 
   write_byte(0); 
   write_byte(0); 
   message_end(); 

   return PLUGIN_HANDLED; 
}
public StopReturnLaserMine(id) 
{ 
   DeleteTask(id);

   message_begin(MSG_ONE, 108, {0,0,0}, id);
   write_byte(0); 
   write_byte(0); 
   message_end(); 

   return PLUGIN_HANDLED; 
}

public ltm_Think(i_Ent) 
{ 
   if(!pev_valid(i_Ent)) 
      return FMRES_IGNORED;

   new EntityName[32];
   pev(i_Ent, pev_classname, EntityName, 31);

   if(!get_pcvar_num(g_LENABLE)) return FMRES_IGNORED;
  
   if(!equal(EntityName, ENT_CLASS_NAME))	return FMRES_IGNORED; 

   static Float:fCurrTime; 
   fCurrTime = get_gametime(); 

   switch(pev(i_Ent, LASERMINE_STEP)) 
   { 
      case POWERUP_THINK: 
      { 
         new Float:fPowerupTime; 
         pev(i_Ent, LASERMINE_POWERUP, fPowerupTime); 

         if(fCurrTime > fPowerupTime) 
         { 
            set_pev(i_Ent, pev_solid, SOLID_BBOX); 
            set_pev(i_Ent, LASERMINE_STEP, BEAMBREAK_THINK); 

            PlaySound(i_Ent, ACTIVATE_SOUND); 
         }

         if(get_pcvar_num(g_LGLOW)!=0) 
         { 
            if(get_pcvar_num(g_LCLMODE)==0) 
            { 
               switch (pev(i_Ent,LASERMINE_TEAM)) 
               {
                  case CS_TEAM_T:	set_rendering(i_Ent,kRenderFxGlowShell,Red_Zomb,Green_Zomb,Blue_Zomb,kRenderNormal,5);
                  case CS_TEAM_CT:	set_rendering(i_Ent,kRenderFxGlowShell,Red_Hum,Green_Hum,Blue_Hum,kRenderNormal,5);
               }
            }
            else	set_rendering(i_Ent,kRenderFxGlowShell,random_num(50 , 200),random_num(50 , 200),random_num(50 , 200),kRenderNormal,5);
         } 
         set_pev(i_Ent, pev_nextthink, fCurrTime + 0.1); 
      }
      case BEAMBREAK_THINK: 
      { 
         static Float:vEnd[3],Float:vOrigin[3]; 
         pev(i_Ent, pev_origin, vOrigin); 
         pev(i_Ent, LASERMINE_BEAMENDPOINT, vEnd); 

         static iHit, Float:fFraction; 
         engfunc(EngFunc_TraceLine, vOrigin, vEnd, DONT_IGNORE_MONSTERS, i_Ent, 0); 

         get_tr2(0, TR_flFraction, fFraction); 
         iHit = get_tr2(0, TR_pHit); 

         if(fFraction < 1.0) 
         {
            if(pev_valid(iHit)) 
            { 
               pev(iHit, pev_classname, EntityName, 31); 
              
               if(!equal(EntityName, ENT_CLASS_NAME) && !equal(EntityName, gSnarkClassName) && !equal(EntityName, barnacle_class) && !equal(EntityName, weapon_box)) 
               { 
			set_pev(i_Ent, pev_enemy, iHit); 

			if(get_pcvar_num(g_LMODE) == MODE_LASERMINE)	CreateLaserDamage(i_Ent,iHit); 
			else 
			if(get_pcvar_num(g_LFF) || CsTeams:pev(i_Ent,LASERMINE_TEAM) != cs_get_user_team(iHit))	set_pev(i_Ent, LASERMINE_STEP, EXPLOSE_THINK); 

			if (!pev_valid(i_Ent))	return FMRES_IGNORED; 

			set_pev(i_Ent, pev_nextthink, fCurrTime + random_float(0.1, 0.3)); 
               } 
            } 
         }

         if(get_pcvar_num(g_LDMGMODE)!=0)	if(pev(i_Ent,LASERMINE_HITING) != iHit)	set_pev(i_Ent,LASERMINE_HITING,iHit); 

         if(pev_valid(i_Ent)) 
         { 
            static Float:fHealth; 
            pev(i_Ent, pev_health, fHealth); 

            if(fHealth <= 0.0 || (pev(i_Ent,pev_flags) & FL_KILLME)) 
            { 
			set_pev(i_Ent, LASERMINE_STEP, EXPLOSE_THINK); 
			set_pev(i_Ent, pev_nextthink, fCurrTime + random_float(0.1, 0.3)); 
            } 
                                
            static Float:fBeamthink; 
            pev(i_Ent, LASERMINE_BEAMTHINK, fBeamthink); 
                    
            if(fBeamthink < fCurrTime && get_pcvar_num(g_LVISIBLE)) 
            { 
               DrawLaser(i_Ent, vOrigin, vEnd); 
               set_pev(i_Ent, LASERMINE_BEAMTHINK, fCurrTime + 0.1); 
            } 
            set_pev(i_Ent, pev_nextthink, fCurrTime + 0.01); 
         } 
      } 
      case EXPLOSE_THINK: 
      { 
         set_pev(i_Ent, pev_nextthink, 0.0); 
         PlaySound(i_Ent, STOP_SOUND); 
         g_deployed[pev(i_Ent,LASERMINE_OWNER)]--; 
         CreateExplosion(i_Ent); 
         switch (pev(i_Ent,LASERMINE_TEAM)) //crap
         {
                  case CS_TEAM_T:	CreateDamage(i_Ent,get_pcvar_float(g_LRDMGz),get_pcvar_float(g_LRADIUS))
                  case CS_TEAM_CT:	CreateDamage(i_Ent,get_pcvar_float(g_LRDMGh),get_pcvar_float(g_LRADIUS))
         }
         RemoveEntity(i_Ent); 
      } 
   } 

   return FMRES_IGNORED; 
}
PlaySound(i_Ent, i_SoundType) 
{ 
   switch (i_SoundType) 
   { 
      case POWERUP_SOUND: 
      { 
         emit_sound(i_Ent, CHAN_VOICE, ENT_SOUND1, VOL_NORM, ATTN_NORM, 0, PITCH_NORM); 
         emit_sound(i_Ent, CHAN_BODY , ENT_SOUND2, 0.2, ATTN_NORM, 0, PITCH_NORM); 
      } 
      case ACTIVATE_SOUND: 
      { 
         emit_sound(i_Ent, CHAN_VOICE, ENT_SOUND3, 0.5, ATTN_NORM, 1, 75); 
      } 
      case STOP_SOUND: 
      { 
         emit_sound(i_Ent, CHAN_BODY , ENT_SOUND2, 0.2, ATTN_NORM, SND_STOP, PITCH_NORM); 
         emit_sound(i_Ent, CHAN_VOICE, ENT_SOUND3, 0.5, ATTN_NORM, SND_STOP, 75); 
      } 
   } 
} 

DrawLaser(i_Ent, const Float:v_Origin[3], const Float:v_EndOrigin[3]) 
{
   new tcolor[3]; 
   new teamid = pev(i_Ent, LASERMINE_TEAM);

   if(get_pcvar_num(g_LCLMODE) == 0) 
   { 
      switch(teamid)
       { 
         case 1:
	 {
            tcolor[0] = Red_Zomb; 
            tcolor[1] = Green_Zomb; 
            tcolor[2] = Blue_Zomb; 
         } 
         case 2:
	 {
            tcolor[0] = Red_Hum; 
            tcolor[1] = Green_Hum; 
            tcolor[2] = Blue_Hum; 
         } 
      } 
   }
   else 
   { 
      
      tcolor[0] = random_num(50 , 200); 
      tcolor[1] = random_num(50 , 200); 
      tcolor[2] = random_num(50 , 200); 
   }

   message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
   write_byte(TE_BEAMPOINTS); 
   engfunc(EngFunc_WriteCoord,v_Origin[0]); 
   engfunc(EngFunc_WriteCoord,v_Origin[1]); 
   engfunc(EngFunc_WriteCoord,v_Origin[2]); 
   engfunc(EngFunc_WriteCoord,v_EndOrigin[0]); 
   engfunc(EngFunc_WriteCoord,v_EndOrigin[1]); 
   engfunc(EngFunc_WriteCoord,v_EndOrigin[2]); 
   write_short(beam); 
   write_byte(0); 
   write_byte(0); 
   write_byte(1);  
   write_byte(5);  
   write_byte(0);  
   write_byte(tcolor[0]); 
   write_byte(tcolor[1]); 
   write_byte(tcolor[2]); 
   write_byte(get_pcvar_num(g_LCBRIGHT)); 
   write_byte(255); 
   message_end(); 
   
   	// Get user origin
	static Float:originF[3]
	pev(ID_BLOOD, pev_origin, originF)
   
   	// Sparks
	if(get_pcvar_num(g_LDETAIL)) {
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, v_EndOrigin, 0)
	write_byte(TE_SPARKS) // TE id
	engfunc(EngFunc_WriteCoord, v_EndOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, v_EndOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, v_EndOrigin[2]) // z
	message_end();
      
   	// Effects when cut
		message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
		write_byte(TE_EXPLOSION)
		engfunc(EngFunc_WriteCoord, v_EndOrigin[0])
		engfunc(EngFunc_WriteCoord, v_EndOrigin[1])
		engfunc(EngFunc_WriteCoord, v_EndOrigin[2]-10.0)
		write_short(TE_SPARKS)	// sprite index
		write_byte(1)	// scale in 0.1's
		write_byte(30)	// framerate
		write_byte(TE_EXPLFLAG_NODLIGHTS | TE_EXPLFLAG_NOPARTICLES | TE_EXPLFLAG_NOSOUND)	// flags
		message_end()
	}
} 

CreateDamage(iCurrent,Float:DmgMAX,Float:Radius) 
{
   new Float:vecSrc[3]; 
   pev(iCurrent, pev_origin, vecSrc); 

   new AtkID =pev(iCurrent,LASERMINE_OWNER); 
   new TeamID=pev(iCurrent,LASERMINE_TEAM); 

   new ent = -1; 
   new Float:tmpdmg = DmgMAX; 

   new Float:kickback = 0.0; 
  
   new Float:Tabsmin[3], Float:Tabsmax[3]; 
   new Float:vecSpot[3]; 
   new Float:Aabsmin[3], Float:Aabsmax[3]; 
   new Float:vecSee[3]; 
   new trRes; 
   new Float:flFraction; 
   new Float:vecEndPos[3]; 
   new Float:distance; 
   new Float:origin[3], Float:vecPush[3]; 
   new Float:invlen; 
   new Float:velocity[3]; 
   new iHitHP,iHitTeam; 
  
   new Float:falloff; 
   if(Radius > 0.0) 
   { 
      falloff = DmgMAX / Radius; 
   }
   else
   { 
      falloff = 1.0; 
   } 
  
   while((ent = engfunc(EngFunc_FindEntityInSphere, ent, vecSrc, Radius)) != 0) 
   { 
      if(!pev_valid(ent)) continue; 
      if(!(pev(ent, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER))) 
      {
         continue; 
      } 
      if(!pev_user_alive(ent)) continue; 
      
      kickback = 1.0; 
      tmpdmg = DmgMAX; 
      
      pev(ent, pev_absmin, Tabsmin); 
      pev(ent, pev_absmax, Tabsmax); 
      xs_vec_add(Tabsmin,Tabsmax,Tabsmin); 
      xs_vec_mul_scalar(Tabsmin,0.5,vecSpot); 
      pev(iCurrent, pev_absmin, Aabsmin); 
      pev(iCurrent, pev_absmax, Aabsmax); 
      xs_vec_add(Aabsmin,Aabsmax,Aabsmin); 
      xs_vec_mul_scalar(Aabsmin,0.5,vecSee); 
      engfunc(EngFunc_TraceLine, vecSee, vecSpot, 0, iCurrent, trRes); 
      get_tr2(trRes, TR_flFraction, flFraction); 
      
      if(flFraction >= 0.9 || get_tr2(trRes, TR_pHit) == ent) 
      {
         get_tr2(trRes, TR_vecEndPos, vecEndPos); 
         distance = get_distance_f(vecSrc, vecEndPos) * falloff; 
         tmpdmg -= distance; 
         if(tmpdmg < 0.0)	tmpdmg = 0.0; 
        
         if(kickback != 0.0) 
         { 
            xs_vec_sub(vecSpot,vecSee,origin); 
            invlen = 1.0/get_distance_f(vecSpot, vecSee); 

            xs_vec_mul_scalar(origin,invlen,vecPush); 
            pev(ent, pev_velocity, velocity) 
            xs_vec_mul_scalar(vecPush,tmpdmg,vecPush); 
            xs_vec_mul_scalar(vecPush,kickback,vecPush); 
            xs_vec_add(velocity,vecPush,velocity);

            if(tmpdmg < 60.0)	xs_vec_mul_scalar(velocity,12.0,velocity); 
	    else	xs_vec_mul_scalar(velocity,4.0,velocity);

            if(velocity[0] != 0.0 || velocity[1] != 0.0 || velocity[2] != 0.0)	set_pev(ent, pev_velocity, velocity)
         } 

         iHitHP = pev_user_health(ent) - floatround(tmpdmg) 
         iHitTeam = int:cs_get_user_team(ent) 
         if(iHitHP <= 0) 
         { 
            if(iHitTeam != TeamID) 
            { 
               zp_set_user_ammo_packs(AtkID,zp_get_user_ammo_packs(AtkID) + get_pcvar_num(g_LFMONEY)) 
               set_score(AtkID,ent,1,iHitHP) 
            }
	    else 
            { 
               if(get_pcvar_num(g_LFF)) 
               { 
                  zp_set_user_ammo_packs(AtkID,zp_get_user_ammo_packs(AtkID) - get_pcvar_num(g_LFMONEY)) 
                  set_score(AtkID,ent,-1,iHitHP) 
               } 
            } 
         }
	 else 
         { 
            if(iHitTeam != TeamID || get_pcvar_num(g_LFF)) 
            {
               set_user_health(ent, iHitHP) 
               engfunc(EngFunc_MessageBegin,MSG_ONE_UNRELIABLE,g_msgDamage,{0.0,0.0,0.0},ent); 
               write_byte(floatround(tmpdmg)) 
               write_byte(floatround(tmpdmg)) 
               write_long(DMG_BULLET) 
               engfunc(EngFunc_WriteCoord,vecSrc[0]) 
               engfunc(EngFunc_WriteCoord,vecSrc[1]) 
               engfunc(EngFunc_WriteCoord,vecSrc[2]) 
               message_end() 
            } 
         } 
      } 
   }
} 

bool:pev_user_alive(ent) 
{ 
   new deadflag = pev(ent,pev_deadflag); 
   if(deadflag != DEAD_NO)	return false;

   return true; 
} 

CreateExplosion(iCurrent) 
{ 
   new Float:vOrigin[3]; 
   pev(iCurrent,pev_origin,vOrigin); 

   message_begin(MSG_BROADCAST, SVC_TEMPENTITY); 
   write_byte(99); 
   write_short(iCurrent); 
   message_end(); 

   engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vOrigin, 0); 
   write_byte(TE_EXPLOSION); 
   engfunc(EngFunc_WriteCoord,vOrigin[0]); 
   engfunc(EngFunc_WriteCoord,vOrigin[1]); 
   engfunc(EngFunc_WriteCoord,vOrigin[2]); 
   write_short(boom); 
   write_byte(30); 
   write_byte(15); 
   write_byte(0); 
   message_end(); 
} 

CreateLaserDamage(iCurrent,isHit) 
{ 
   if(isHit < 0) return PLUGIN_CONTINUE

   switch(get_pcvar_num(g_LDMGMODE)) 
   { 
      case 1: 
      { 
         if(pev(iCurrent,LASERMINE_HITING) == isHit)	return PLUGIN_CONTINUE 
      } 
      case 2: 
      { 
         if(pev(iCurrent,LASERMINE_HITING) == isHit) 
         { 
            static Float:cnt 
            static now,htime;now = floatround(get_gametime()) 

            pev(iCurrent,LASERMINE_COUNT,cnt) 
            htime = floatround(cnt) 
            if(now - htime < get_pcvar_num(g_LDSEC))	return PLUGIN_CONTINUE
	    else	set_pev(iCurrent,LASERMINE_COUNT,get_gametime())
         }
	 else	set_pev(iCurrent,LASERMINE_COUNT,get_gametime())
      } 
   } 

   new Float:vOrigin[3],Float:vEnd[3] 
   pev(iCurrent,pev_origin,vOrigin) 
   pev(iCurrent,pev_vuser1,vEnd) 

   new teamid = pev(iCurrent, LASERMINE_TEAM),szClassName[32],Alive,God,iHitTeam,iHitHP,id,hitscore 

   szClassName[0] = '^0' 
   pev(isHit,pev_classname,szClassName,32) 
   if((pev(isHit, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER))) 
   { 
      Alive = pev_user_alive(isHit)
      God = get_user_godmode(isHit)

      if(!Alive || God) return PLUGIN_CONTINUE

      iHitTeam = int:cs_get_user_team(isHit)

      if(zp_get_user_zombie(isHit))	iHitHP = pev_user_health(isHit) - get_pcvar_num(g_LDMGz)
      else	iHitHP = pev_user_health(isHit) - get_pcvar_num(g_LDMGh)

      id = pev(iCurrent,LASERMINE_OWNER)

      if(iHitHP <= 0) 
      { 
         if(iHitTeam != teamid) 
         { 
            emit_sound(isHit, CHAN_WEAPON, ENT_SOUND4, 1.0, ATTN_NORM, 0, PITCH_NORM) 
            hitscore = 1 
            zp_set_user_ammo_packs(id,zp_get_user_ammo_packs(id) + get_pcvar_num(g_LFMONEY)) 
            set_score(id,isHit,hitscore,iHitHP) 
         } 
         else 
         { 
            if(get_pcvar_num(g_LFF)) 
            { 
               emit_sound(isHit, CHAN_WEAPON, ENT_SOUND4, 1.0, ATTN_NORM, 0, PITCH_NORM) 
               hitscore = -1 
               zp_set_user_ammo_packs(id,zp_get_user_ammo_packs(id) - get_pcvar_num(g_LFMONEY)) 
               set_score(id,isHit,hitscore,iHitHP) 
            } 
         } 
      } 
      else if(iHitTeam != teamid || get_pcvar_num(g_LFF)) 
      { 
         emit_sound(isHit, CHAN_WEAPON, ENT_SOUND4, 1.0, ATTN_NORM, 0, PITCH_NORM) 
         set_user_health(isHit,iHitHP) 
         set_pev(iCurrent,LASERMINE_HITING,isHit); 
         engfunc(EngFunc_MessageBegin,MSG_ONE_UNRELIABLE,g_msgDamage,{0.0,0.0,0.0},isHit);
	 if(zp_get_user_zombie(isHit))
         {
		write_byte(get_pcvar_num(g_LDMGz)) 
		write_byte(get_pcvar_num(g_LDMGz))
         }
         else
         {
		write_byte(get_pcvar_num(g_LDMGh)) 
		write_byte(get_pcvar_num(g_LDMGh))
         }
         write_long(DMG_BULLET) 
         engfunc(EngFunc_WriteCoord,vOrigin[0]) 
         engfunc(EngFunc_WriteCoord,vOrigin[1]) 
         engfunc(EngFunc_WriteCoord,vOrigin[2]) 
         message_end() 
      } 
   } 
   else if(equal(szClassName, ENT_CLASS_NAME3)) 
   { 
      new hl; 
      hl = pev_user_health(isHit); 
      if(zp_get_user_zombie(isHit))	set_user_health(isHit,hl-get_pcvar_num(g_LDMGz));
      else set_user_health(isHit,hl-get_pcvar_num(g_LDMGh));
   } 
   return PLUGIN_CONTINUE 
} 

stock pev_user_health(id) 
{ 
   new Float:health 
   pev(id,pev_health,health)

   return floatround(health) 
} 

stock set_user_health(id,health)	health > 0 ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id); 

stock get_user_godmode(index) { 
   new Float:val 
   pev(index, pev_takedamage, val) 

   return (val == DAMAGE_NO) 
} 

stock set_user_frags(index, frags) 
{ 
   set_pev(index, pev_frags, float(frags)) 
   return 1 
} 

stock pev_user_frags(index) 
{ 
   new Float:frags; 
   pev(index,pev_frags,frags);

   return floatround(frags); 
} 

set_score(id,target,hitscore,HP) 
{ 
   new idfrags = pev_user_frags(id) + hitscore
   set_user_frags(id,idfrags)

   new tarfrags = pev_user_frags(target) + 1
   set_user_frags(target,tarfrags)

   new idteam = int:cs_get_user_team(id) 
   new iddeaths = cs_get_user_deaths(id) 

   message_begin(MSG_ALL, g_msgDeathMsg, {0, 0, 0} ,0) 
   write_byte(id) 
   write_byte(target) 
   write_byte(0) 
   write_string(ENT_CLASS_NAME) 
   message_end() 

   message_begin(MSG_ALL, g_msgScoreInfo) 
   write_byte(id) 
   write_short(idfrags) 
   write_short(iddeaths) 
   write_short(0) 
   write_short(idteam) 
   message_end() 

   set_msg_block(g_msgDeathMsg, BLOCK_ONCE) 

   set_user_health(target, HP) 
}

public say_lasermine(id) 
{ 
   new said[32] 
   read_argv(1,said,31); 
   if(!get_pcvar_num(g_LENABLE))	return PLUGIN_CONTINUE
   //if(equali(said,"/buy lasermine")||equali(said,"/lm")||equali(said,"buy_lasermine"))	BuyLasermine(id)
   if(equali(said, "/lasermine")) 
   { 
      const SIZE = 1024 
      new msg[SIZE+1],len = 0; 
      len += formatex(msg[len], SIZE - len, "<html><body>") 
      len += formatex(msg[len], SIZE - len, "<p><b>LaserMine</b></p><br/>") 
      len += formatex(msg[len], SIZE - len, "<p>Poti planta lasere numai pe un perete.</p><br/>") 
      len += formatex(msg[len], SIZE - len, "<p>Cu laserele plantate puteti omora zombi sau invers</p><br/>") 
      len += formatex(msg[len], SIZE - len, "<p><b>Introduce aceste comenzi in consola :<br/>") 
      len += formatex(msg[len], SIZE - len, "<b>bind v +setlaser</p>") 
      len += formatex(msg[len], SIZE - len, "<b>bind c +dellaser</p>") 
      len += formatex(msg[len], SIZE - len, "</body></html>") 
      show_motd(id, msg, "Lasermine Entity help")
   } 
   if(equali(said, "/lm")||equali(said, "/laser"))	showInfo(id)
   return PLUGIN_CONTINUE 
}
public zp_extra_item_selected(id, itemid)	if(itemid == g_LME)	BuyLasermine(id)
public BuyLasermine(id)
{
   if(!CanCheck(id,1)) return

   g_havemine[id]++;

   client_printcolor(id, "%L %L", id, "CHATTAG",id, "STR_BOUGHT")

   emit_sound(id, CHAN_ITEM, ENT_SOUND5, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
   ShowAmmo(id)
}
ShowAmmo(id) 
{ 
   new ammo[51]
   new PlugStat[ 555 char ];
   formatex(PlugStat, charsmax(PlugStat), "%L", LANG_PLAYER, "STR_STATE")
   formatex(ammo, 50, "%s %i/%i",PlugStat, g_havemine[id],get_pcvar_num(g_LAMMO))

   message_begin(MSG_ONE, g_msgStatusText, {0,0,0}, id) 
   write_byte(0) 
   write_string(ammo) 
   message_end() 
}
public showInfo(id)	client_printcolor(id, "%L", id, "STR_REF")

	#if defined LOCK_SPEED
		public SPCMD(id){
			if(!is_user_alive(id)||is_user_bot(id)||is_user_hltv(id))	return

			pev(id, pev_maxspeed,plspeed[id])
		}
		/*public standing(id) 
		{ 
		   if(!g_settinglaser[id])	return

		   set_pev(id, pev_maxspeed, 1.0)
		}
		public ltm_PostThink(id) 
		{ 
		   if(!g_settinglaser[id])	resetspeed(id)
		   else
		   { 
			  pev(id, pev_maxspeed,plspeed[id]) 
			  set_pev(id, pev_maxspeed, 1.0) 
		   }

		   return FMRES_IGNORED 
		}*/
		resetspeed(id)	set_pev(id, pev_maxspeed, plspeed[id]) 
	#endif
public ltm_PreThink(id) 
{ 
   if(!pev_user_alive(id) || g_settinglaser[id] == true || is_user_bot(id) || get_pcvar_num(g_LCMDMODE) == 1)	return FMRES_IGNORED; 

   if(pev(id, pev_button) & IN_USE && !(pev(id, pev_oldbuttons) & IN_USE))	CreateLaserMine_Progress(id)

   return FMRES_IGNORED;
}

public client_putinserver(id) 
{
   if(!get_pcvar_num(g_LENABLE))	return
   g_deployed[id] = 0; 
   g_havemine[id] = 0; 
   DeleteTask(id); 
   //set_task( 1.1, "checkIfspec",id,.flags="b") 
} 
public client_disconnect(id){ 
   if(!get_pcvar_num(g_LENABLE))	return

   DeleteTask(id);
   RemoveAllTripmines(id);
} 

public newround(id) 
{ 
	if(!get_pcvar_num(g_LENABLE))	return

	for(new id=1;id<=get_maxplayers();id++)
	{
		DeleteTask(id); 
		RemoveAllTripmines(id); 

		delaycount(id); 
		SetStartAmmo(id);
	}
}
public endround(id) 
{ 
	if(!get_pcvar_num(g_LENABLE))	return
	for(new id=1;id<=get_maxplayers();id++)
	{
		DeleteTask(id); 
		RemoveAllTripmines(id); 
	}
}

public zp_user_infected_post( id, infector, nemesis )
{
	if ( !infector || nemesis )	return;
	if(g_deployed[id]>0)
	{
		RemoveAllTripmines(id);
		g_havemine[id]=get_pcvar_num(g_LSTAMMO)
	}
}

public DeathEvent()
{ 
	if(!get_pcvar_num(g_LENABLE))	return

	new id = read_data(2) 
	if(is_user_connected(id))
	{
		DeleteTask(id);
		set_task( 1.0, "checkIfspec",id)
	}
}

public checkIfspec(id)
{
    if( g_deployed[id] > 0 )
    {
          if(cs_get_user_team(id) == CS_TEAM_SPECTATOR)
          {
               DeleteTask(id);
               RemoveAllTripmines(id);

               /*new namep[32];
               get_user_name(id,namep,charsmax(namep));
               client_printcolor(0,"!g[LM]!y Laserele lui!g %s!y au fost!g dezactivate!y deoarece s-a mutat la!g spectatori!y !",namep);*/
          }
     }
}
public RemoveAllTripmines(i_Owner){ 
	new iEnt = -1//g_MaxPL + 1;
	static clsname[35];
	while((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", ENT_CLASS_NAME))){
		if (!pev_valid(iEnt))	continue;
		if(i_Owner){
			if(pev(iEnt, LASERMINE_OWNER) != i_Owner)	continue;
			//clsname[0] = '^0'
			pev(iEnt, pev_classname, clsname, charsmax(clsname));
			if(equali(clsname, ENT_CLASS_NAME)){
				PlaySound(iEnt, STOP_SOUND);
				RemoveEntity(iEnt);
			}
		}
		else	set_pev(iEnt, pev_flags, FL_KILLME);
	}
	g_deployed[i_Owner]=0;
}

public CutDeploy_onDamage(id)	if(get_user_health(id) < 1)	DeleteTask(id);

SetStartAmmo(id){
   static stammo; stammo = get_pcvar_num(g_LSTAMMO);
   if(stammo <= 0) return
   g_havemine[id] = (g_havemine[id] <= stammo) ? stammo : g_havemine[id];
}
DeleteTask(id){
   if(task_exists((TASK_PLANT + id)))	remove_task((TASK_PLANT + id))
   if(task_exists((TASK_RELEASE + id)))	remove_task((TASK_RELEASE + id))
   g_settinglaser[id] = false
}

stock set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16){
   static Float:RenderColor[3];
   RenderColor[0] = float(r);
   RenderColor[1] = float(g);
   RenderColor[2] = float(b);

   set_pev(entity, pev_renderfx, fx);
   set_pev(entity, pev_rendercolor, RenderColor);
   set_pev(entity, pev_rendermode, render);
   set_pev(entity, pev_renderamt, float(amount));

   return 1
}

public MinesShowInfo(Float:vStart[3], Float:vEnd[3], Conditions, id, iTrace){
	static iHit;iHit = get_tr2(iTrace, TR_pHit);
    if( pev_valid( iHit ) ){
        if( pev(iHit, pev_deadflag) == DEAD_NO ){//sau id
			static cClassname[35];pev( iHit, pev_classname, cClassname, charsmax(cClassname) );
            if( equali( cClassname, ENT_CLASS_NAME ) ){
                static aim; aim = pev( iHit, LASERMINE_OWNER );
                static name[ 120 ];get_user_name( aim, name, charsmax( name ) )
				format(name,charsmax(name),"[%s] %s",zp_get_user_zombie(aim)?"ZM":"HM",name)
                set_hudmessage( 50, 100, 150, -1.0, 0.60, 0, 6.0, 1.1, 0.0, 0.0, -1 )
                show_hudmessage( id, "Owner: %s^nHealth: %d/700", name, floatround(Float:pev(iHit,pev_health )))
            }
        }
    }
}

bool:ReturnCheck(id){ 
   if(!CanCheck(id,-1)) return false;
   if(g_havemine[id] + 1 > get_pcvar_num(g_LAMMO)) return false;
   static tgt,body,Float:vo[3],Float:to[3]; 
   get_user_aiming(id,tgt,body);

   if(!pev_valid(tgt)) return false;
   pev(id,pev_origin,vo);
   pev(tgt,pev_origin,to);
   if(get_distance_f(vo,to) > 70.0) return false;

   static EntityName[35];pev(tgt, pev_classname, EntityName, charsmax(EntityName));
   if(!equal(EntityName, ENT_CLASS_NAME)) return false;
   if(pev(tgt,LASERMINE_OWNER) != id) return false;

   return true;
}
bool:CreateCheck(id){
   if(!CanCheck(id,0)) return false;
   if(!zp_has_round_started() && get_pcvar_num(g_NOROUND)){
      client_printcolor(id, "%L %L", id, "CHATTAG",id, "STR_NOROUND")
      return false;
   }

   if(g_deployed[id] >= get_pcvar_num(g_LAMMO)) 
   { 
      client_printcolor(id, "%L %L", id, "CHATTAG",id, "STR_MAXDEPLOY") 
      return false; 
   } 

   if(TeamDeployedCount(id) >= get_pcvar_num(g_LTMAX)) 
   { 
      client_printcolor(id, "%L %L", id, "CHATTAG",id, "STR_MANYPPL") 
      return false; 
   }

   new Float:vTraceDirection[3], Float:vTraceEnd[3],Float:vOrigin[3]; 
   pev(id, pev_origin, vOrigin); 
   velocity_by_aim(id, 128, vTraceDirection); 
   xs_vec_add(vTraceDirection, vOrigin, vTraceEnd); 
   engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, 0); 
   new Float:fFraction,Float:vTraceNormal[3]; 
   get_tr2(0, TR_flFraction, fFraction); 
  
   if(fFraction < 1.0) 
   { 
      get_tr2(0, TR_vecEndPos, vTraceEnd); 
      get_tr2(0, TR_vecPlaneNormal, vTraceNormal); 

      return true; 
   } 

   client_printcolor(id, "%L %L", id, "CHATTAG",id, "STR_PLANTWALL") 
   DeleteTask(id); 
  
   return false; 
}
stock TeamDeployedCount(id) 
{ 
   static i,CsTeams:t,cnt
   t = cs_get_user_team(id)
   cnt=0;

   for(i = 1;i <= g_MaxPL;i++)	if(is_user_connected(i))	if(t == cs_get_user_team(i))	cnt += g_deployed[i];

   return cnt; 
}
bool:CanCheck(id,mode)  
{ 
   if(!get_pcvar_num(g_LENABLE)) 
   { 
      client_printcolor(id, "%L %L", id, "CHATTAG",id, "STR_NOTACTIVE") 
      return false; 
   }

   if(get_pcvar_num(g_LACCESS) != 0)
   {
      if(!(get_user_flags(id) & ADMIN_IMMUNITY)) 
      { 
         client_printcolor(id, "%L %L", id, "CHATTAG",id, "STR_NOACCESS") 
         return false; 
      }
   }

   if(!pev_user_alive(id)) return false;

   if(mode == 0) 
   { 
      if(g_havemine[id] <= 0) 
      { 
         client_printcolor(id, "%L %L", id, "CHATTAG",id, "STR_DONTHAVEMINE") 
         return false; 
      } 
   }
   else if(mode == 1) 
   { 
      if(get_pcvar_num(g_LBUYMODE) == 0) 
      { 
         client_printcolor(id, "%L %L", id, "CHATTAG",id, "STR_CANTBUY") 
         return false; 
      }

      if(g_havemine[id] >= get_pcvar_num(g_LAMMO)) 
      { 
         client_printcolor(id, "%L %L", id, "CHATTAG",id, "STR_HAVEMAX") 
         return false; 
      }

      /*if(zp_get_user_ammo_packs(id) < LMCost) MANUAL BUY..
      { 
         client_printcolor(id, "%L %L%d %L", id, "CHATTAG",id, "STR_NOMONEY",get_pcvar_num(g_LCOST),id, "STR_NEEDED") 
         return false; 
      }*/
   }
   //else == -1

   if(!CheckTime(id)) 
   { 
      client_printcolor(id, "%L %L %d %L", id, "CHATTAG",id, "STR_DELAY",get_pcvar_num(g_LDELAY)-g_nowtime,id, "STR_SECONDS") 
      return false; 
   } 

   return true;
}
bool:CheckTime(id) 
{ 
   g_nowtime = floatround(get_gametime()) - g_dcount[id];

   if(g_nowtime >= get_pcvar_num(g_LDELAY)&&zp_has_round_started())	return true;

   return false; 
}

stock client_printcolor(const id, const input[], any:...) 
{ 
   new iCount = 1, iPlayers[32] 
   static szMsg[191] 

   vformat(szMsg, charsmax(szMsg), input, 3) 
   replace_all(szMsg, 190, "!g", "^4") 
   replace_all(szMsg, 190, "!y", "^1") 
   replace_all(szMsg, 190, "!t", "^3") 
   replace_all(szMsg, 190, "!w", "^0")
   replace_all(szMsg, charsmax(szMsg), "[ZP]", CHAT_TAG);

   if(id) iPlayers[0] = id
   else get_players(iPlayers, iCount, "ch")

   for(new i = 0; i < iCount; i++) 
   { 
      if(is_user_connected(iPlayers[i]))
      { 
         message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, iPlayers[i]) 
         write_byte(iPlayers[i]) 
         write_string(szMsg) 
         message_end() 
      } 
   } 
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
