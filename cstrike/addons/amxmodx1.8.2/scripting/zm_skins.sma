#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>

#pragma tabsize 0

//#define STRICT
	#if defined STRICT
		new Float:g_models_targettime // target time for the last model change
	#endif

//#define ZM
	#if defined ZM
		#include <zombieplague>

		#define get_user_sum(%1)		zp_get_user_ammo_packs(%1)
		#define set_user_sum(%1,%2)		zp_set_user_ammo_packs(%1,%2)
	#else
		#define get_user_sum(%1)		cs_get_user_money(%1)
		#define set_user_sum(%1,%2)		cs_set_user_money(%1,%2,1)
	#endif

enum _:ES{
	NUME_SKIN[35],
	NUME_MODEL[35],
	COST,
	ACCESS_SKIN,
	TEAM
}
//modelele trebuie să le pui în /cstrike/models/NUME_MODEL/NUME_MODEL.mdl (dacă sunt și T nu e problemă!)
//ce e cu -1 va anula criteriul
//dacă vrei să fie accesibil la mai multe flage, delimitezi prin "|" dacă vrei să fie aces doar unor anumite flage delimitezi cu "&"	(pt a forța, introduci între "()")
static const	g_ES[][ES]={
					//	  NUME SKIN			NUME MODEL		PREȚ		FLAG ACCESS									ECHIPA(2=CT/OM)
					{	"NUME SKIN 1",		"model1",		100,		-1,											2		},
					{	"NUME SKIN 2",		"model2",		-1,			ADMIN_LEVEL_H,								2		},
					{	"NUME SKIN 3",		"model3",		1223,		ADMIN_LEVEL_H|ADMIN_SLAY,					2		},
					{	"NUME SKIN 4",		"model4",		13,			ADMIN_LEVEL_H&ADMIN_SLAY,					2		},
					{	"NUME SKIN 5",		"model5",		1,			(ADMIN_LEVEL_H&ADMIN_SLAY)|ADMIN_IMMUNITY,	2		},
					{	"NUME SKIN 6",		"model6",		1,			(ADMIN_LEVEL_H&ADMIN_BAN),					2		},
					{	"NUME SKIN 7",		"model7",		122,		(ADMIN_LEVEL_H|ADMIN_KICK),					2		}
				},
				comanda_chat_shop[]="/skins",
				titlu_meniu_shop[]="Diferite skin-uri^n^tAi\r %d\w %s\y",//sau\R \b
				chat_tag[]="[SKIN]",

				#if defined STRICT
					Float: MODELCHANGE_DELAY = 0.5, // delay between model changes
				#else
					Float:VERIFY_SMT=5.0,	//la cât timp după spawn, să verifice dacă este om & are model, ca să-l seteze(spawn! nu rundă nouă!)
				#endif

				#if defined ZM
					SUM[][] = { "ammo" },
				#else
					SUM[][] = { "money" },
				#endif

				PLAYERMODEL_CLASSNAME[] = "ent_playermodel"

static fmcc[120],g_MenuCallback
new pmff[33][125],g_ent_playermodel[33]

public plugin_init(){
    RegisterHam( Ham_Spawn, "player", "fw_PlayerSpawn", 1 )
    register_forward( FM_AddToFullPack, "fw_AddToFullPack" )
	#if defined STRICT
		register_forward( FM_SetClientKeyValue, "fw_SetClientKeyValue" )
		register_logevent("logevent_round_end", 2, "1=Round_End")
	#endif
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0")
    register_message( get_user_msgid( "ClCorpse" ), "message_clcorpse" )

	formatex(fmcc,charsmax(fmcc),"say %s",comanda_chat_shop)
		register_clcmd(fmcc,"SHOP")
	formatex(fmcc,charsmax(fmcc),"say_team %s",comanda_chat_shop)
		register_clcmd(fmcc,"SHOP")

	g_MenuCallback = menu_makecallback( "menuitem_callback" )
}
public plugin_precache()	for(new i=0; i < sizeof g_ES; i++)	precache_player_model(g_ES[i][NUME_MODEL])
precache_player_model(szModel[]){
	static szFile[128];formatex(szFile, charsmax(szFile), "models/player/%s/%s.mdl", szModel, szModel)
	precache_model(szFile)

	replace(szFile, charsmax(szFile), ".mdl", "T.mdl");if(file_exists(szFile))	precache_model(szFile)
}

public client_putinserver(id)	if(is_user_connected(id)&&!is_user_bot(id)||!is_user_hltv(id))	pmff[id]="",g_ent_playermodel[id]=0
public client_disconnect( id )	if ( fm_has_custom_model( id ) )	fm_remove_model_ents( id )

public event_new_round(){
	arrayset(pmff[EOS],0,charsmax(pmff[]))
	#if defined STRICT
		arrayset(g_ent_playermodel,0,charsmax(g_ent_playermodel))
	#endif
}
#if defined STRICT
	#if defined ZM
		/*public zp_round_started(gamemode, id)	arrayset(pmff[EOS],0,charsmax(pmff[]))
		public zp_round_ended(winteam)	arrayset(pmff[EOS],0,charsmax(pmff[]))*/
	#endif
	public logevent_round_end(){
		arrayset(pmff[EOS],0,charsmax(pmff[]))
		arrayset(g_ent_playermodel,0,charsmax(g_ent_playermodel))
	}
#endif

public SHOP(id){
	if(!is_user_alive(id)||!equali(pmff[id],""))	return
	#if defined ZM
		if(zp_get_user_zombie(id))	return
	#endif
	static menu,formtm[120],formim[255],RT[15];
	formatex(formtm,charsmax(formtm),titlu_meniu_shop,get_user_sum(id),SUM)	//%s - argument, am pus x2 %s pt că mai este unul sus în titlu meniu
	menu=menu_create(formtm,"MH")
	for(new i=0;i<sizeof g_ES;i++){
		if((get_user_sum(id)<g_ES[i][COST])&&g_ES[i][COST]!=-1){
			if(!(get_user_flags(id)&g_ES[i][ACCESS_SKIN])&&g_ES[i][ACCESS_SKIN]!=-1)	formatex(formim,charsmax(formim),"\d%s\r [\wNU AI ACCES\r]",g_ES[i][NUME_SKIN])
			else	if(get_user_team(id)!=g_ES[id][TEAM])	formatex(formim,charsmax(formim),"\d%s\w {\yECHIPA NECORESPUNZATOARE\w}",g_ES[i][NUME_SKIN])
			else	formatex(formim,charsmax(formim),"\d%s\y (\rNU AI %s SUFICIENTI\y)",g_ES[i][NUME_SKIN],strtoupper(SUM[0]))
		}
		else{
			if(!(get_user_flags(id)&g_ES[i][ACCESS_SKIN])&&g_ES[i][ACCESS_SKIN]!=-1)	formatex(formim,charsmax(formim),"\d%s\y [\rNU AI ACCES\y]",g_ES[i][NUME_SKIN])
			if(formim[0])	format(formim,charsmax(formim),"%s%s%s",formim,get_user_team(id)!=g_ES[id][TEAM]?" \w{\yECHIPA NECORESPUNZATOARE\w}":"",g_ES[i][COST]==-1?" \r*\wMOKA\r*":"")
			else	formatex(formim,charsmax(formim),"%s%s%s",g_ES[i][NUME_SKIN],get_user_team(id)!=g_ES[id][TEAM]?" \w{\yECHIPA NECORESPUNZATOARE\w}":"",g_ES[i][COST]==-1?" \r*\wMOKA\r*":"")
		}
		if(formim[0])	menu_additem(menu,formim,.callback=g_MenuCallback)
		else{
			formatex
			(
						formim,charsmax(formim),"%s%s%s",
							(!(get_user_flags(id)&g_ES[i][ACCESS_SKIN])&&g_ES[i][ACCESS_SKIN]!=-1)||
								(get_user_team(id)!=g_ES[id][TEAM])||
									((get_user_sum(id)<g_ES[i][COST])&&g_ES[i][COST]!=-1)?"\d":"",
										!(get_user_flags(id)&g_ES[i][ACCESS_SKIN])&&g_ES[i][ACCESS_SKIN]!=-1?"\r [\wNU AI ACCES\r]":g_ES[i][ACCESS_SKIN]==-1?" \r*\wMOKA\r*":"",
											get_user_team(id)!=g_ES[id][TEAM]?"\w {\yECHIPA NECORESPUNZATOARE\w}":"",
												(get_user_sum(id)<g_ES[i][COST])&&g_ES[i][COST]!=-1?"\y (\rNU AI $cost$ SUFICIENTI\y)":g_ES[i][COST]==-1?" \r*\wMOKA\r*":""
			)
			formatex(RT,charsmax(RT),"%s",strtoupper(SUM[0]))
			replace(formim,charsmax(formim),"$cost$",RT)
			menu_additem(menu,formim,.callback=g_MenuCallback)
		}
	}
	menu_display(id,menu,0)
}
public menuitem_callback( id, menu, item ){
	if ( !is_user_alive( id )||get_user_sum(id)<g_ES[item][COST]&&g_ES[item][COST]!=-1||!(get_user_flags(id)&g_ES[item][ACCESS_SKIN])&&g_ES[item][ACCESS_SKIN]!=-1||get_user_team(id)!=g_ES[item][TEAM] )	return ITEM_DISABLED;
	return ITEM_IGNORE;
}
public MH(id,menu,item){
	if(!is_user_alive(id)||!equali(pmff[id],""))	return
	#if defined ZM
		if(zp_get_user_zombie(id))	return
	#endif
	pmff[id]=""
	set_user_sum(id,get_user_sum(id)-item)
	client_print(0,print_chat,"%s ^"%s^" tocmai si-a achizitionat skin-ul ^"%s^" pentru %d %s%s",chat_tag,
		_get_user_name(id),g_ES[item][NUME_SKIN],g_ES[item][COST]==-1?0:g_ES[item][COST],SUM,
			g_ES[item][ACCESS_SKIN]!=-1?" (SPECIAL SKIN)":"")
	formatex(pmff[id],charsmax(pmff[]),"models/player/%s/%s.mdl",g_ES[item][NUME_MODEL],g_ES[item][NUME_MODEL])
	fm_set_player_model(id)
}

public fw_PlayerSpawn( const id ){
	if(is_user_alive(id)){
		#if defined STRICT
			if ( !equali(pmff[id],"")||fm_has_custom_model( id ) )	fm_remove_model_ents( id )
		#else
			set_task(VERIFY_SMT,"MSC",id)
		#endif
	}
}
public MSC(const id){
	if ( !equali(pmff[id],"")/*||fm_has_custom_model( id )*/ )	fm_set_player_model( id )
	else if ( fm_has_custom_model( id ) )	fm_remove_model_ents( id )
}

public fw_AddToFullPack( es, e, ent, host, hostflags, player ){
    if ( player ) return FMRES_IGNORED;
    if ( ent == g_ent_playermodel[host] )	return FMRES_SUPERCEDE;
    return FMRES_IGNORED;
}


public message_clcorpse(){
    static id;id = get_msg_arg_int( 12 )
    if ( fm_has_custom_model( id ) )	set_msg_arg_string( 1, pmff[id] )//or ent
}
	#if defined STRICT
		public fw_SetClientKeyValue( id, const infobuffer[], const key[] ){
			// Block CS model changes
			if ( fm_has_custom_model( id ) && equali( key, "model" ) && !equali(pmff[id],"") ){
				// Get current model
				static currentmodel[35];fm_cs_get_user_model( id, currentmodel, charsmax( currentmodel ) )
				
				// Check whether it matches the custom model - if not, set it again
				if ( !equal( currentmodel, pmff[id] ) )	fm_set_player_model( id )
				
				return FMRES_SUPERCEDE;
			}
			
			return FMRES_IGNORED;
		}
		public fm_cs_user_model_update( id ){
			static Float:current_time;current_time = get_gametime()
			
			// Delay needed?
			if ( current_time - g_models_targettime >= MODELCHANGE_DELAY ){
				fm_set_player_model( id )
				g_models_targettime = current_time
			}
			else{
				set_task( (g_models_targettime + MODELCHANGE_DELAY) - current_time, "fm_set_player_model", id )
				g_models_targettime = g_models_targettime + MODELCHANGE_DELAY
			}
		}
	#endif

stock fm_set_player_model(const id/*, const model[]*/){
	set_pev( id, pev_rendermode, kRenderTransTexture )
	set_pev( id, pev_renderamt, 1.0 )
	if ( !pev_valid( g_ent_playermodel[id] ) ){
		g_ent_playermodel[id] = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) )
		if ( !pev_valid( g_ent_playermodel[id] ) ) return;
		set_pev( g_ent_playermodel[id], pev_classname, PLAYERMODEL_CLASSNAME )
		set_pev( g_ent_playermodel[id], pev_movetype, MOVETYPE_FOLLOW )
		set_pev( g_ent_playermodel[id], pev_aiment, id )
		set_pev( g_ent_playermodel[id], pev_owner, id )
	}
	engfunc( EngFunc_SetModel, g_ent_playermodel[id], pmff[id] )
	engfunc( EngFunc_SetClientKeyValue, id, engfunc( EngFunc_GetInfoKeyBuffer, id ), "model", pmff[id] )
}
stock bool:fm_has_custom_model( const id )	return pev_valid( g_ent_playermodel[id] ) ? true : false;
stock fm_remove_model_ents( const id ){
    set_pev( id, pev_rendermode, kRenderNormal )
    if ( pev_valid( g_ent_playermodel[id] ) ){
        engfunc( EngFunc_RemoveEntity, g_ent_playermodel[id] )
        g_ent_playermodel[id] = 0
    }
	pmff[id]=""
}

stock fm_set_glow(const id, const type=1){
	/*new bool: hg[33] = false
	hg[id] = !( hg[id] )*/
	switch(type){//fm neccesary
		case 1:{
			//if(hv[id]){
			// Set a red glow on the "playermodel" entity
			set_pev( fm_has_custom_model(id)?g_ent_playermodel[id]:id, pev_renderfx, kRenderFxGlowShell )
			set_pev( fm_has_custom_model(id)?g_ent_playermodel[id]:id, pev_color, Float:{200.0, 0.0, 0.0} )
			set_pev( fm_has_custom_model(id)?g_ent_playermodel[id]:id, pev_renderamt, 50.0 )
			/*}
			else	fm_set_rendering( g_ent_playermodel[id] )*/
		}

		case 2:{
			//if(hv[id]){
			// Or, if you're using fakemeta_util's stock instead:
			fm_set_rendering( fm_has_custom_model(id)?g_ent_playermodel[id]:id, kRenderFxGlowShell, 200, 0, 0, kRenderNormal, 50 )
			/*}
			else	fm_set_rendering( g_ent_playermodel[id] )*/
		}
	}
}


stock fm_cs_get_user_model( const player, const model[], const len ){
    // Retrieve current model
    engfunc( EngFunc_InfoKeyValue, engfunc( EngFunc_GetInfoKeyBuffer, player ), "model", model, len )
}
stock fm_cs_reset_user_model( const id ){
    // Player doesn't have a custom model any longer
    set_pev( id, pev_rendermode, kRenderNormal )
    if ( pev_valid( g_ent_playermodel[id] ) ){
        engfunc( EngFunc_RemoveEntity, g_ent_playermodel[id] )
        g_ent_playermodel[id] = 0
    }
    pmff[id]=""
    
    dllfunc( DLLFunc_ClientUserInfoChanged, id, engfunc( EngFunc_GetInfoKeyBuffer, id ) )
}

stock _get_user_name(const id){
	static name[33];
	return is_user_connected(id)?get_user_info(id,"name",name,charsmax(name)):copy(name,charsmax(name),"NO NAME")
}
