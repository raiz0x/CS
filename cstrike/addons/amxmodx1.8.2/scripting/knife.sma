    #include						<amxmodx>
	#include						<amxmisc>
    #include						<cstrike>
    #include						<fakemeta>
	#include						<engine>
	#include						<fun>
    #include						<fvault>
	#include						<dhudmessage>

	#pragma tabsize					0

	native get_hh()

#if AMXX_VERSION_NUM < 183
    #include						<colorchat_lang>
	static const	m_iMenu = 205,
					MENU_OFF= 0;
#endif

	#define LAS_EDIT				"18/10/2020 | 12:52"
	#define CRITIC_EDIT				0

	//#define						NEW_HP_AP
	#if defined NEW_HP_AP
		#define	TYPE				1//1-think / 2-prethink / 3-task / 4-postthink
		#if TYPE == 1
			#define					DHUD_CLASS_ENT "env_hud"
		#endif
		#if TYPE == 1 || TYPE == 3
			#define UPDATE_DHUD		1.0//float!
		#endif
	#endif

	#define							HIDE

	static const					DEV_AUTHID[]="STEAM_0:1:51706930",
									DEV_XP=266400,
									PLUGIN[]="XP Knife",
									VERSION[]="1.1",
									AUTHOR[]="Fgh",				// ....mm edit by Lev.....
									VAULTNAME[]="XPVAULT",
									KILLXP=100,					//+XP PE KILL
									HSXP=200,					//+XP PE KILL CU HS
									LEVELUPXP=400,				//XP NECESAR PT LEVEL UP
									SKINHATSLEVELCHANGE=30,
									SKINKNIVESLEVELCHANGE=50,
									KNIFE_TAG[]="KNIFE:",		// mare parte din chat pt knife
									HATS_TAG[]="HAT:",			// mare parte din chat pt hats
									LEVEL_TAG[]="LEVEL:",		// mare parte din chat pt lvl
									XP_TAG[]="XP:",				// mare parte din chat pt xp
									CHAT_TAG[]="CT:",			// mare parte din chat
									VIP_FLAG[]="t",				// flag vip
									FOLDER_KV[]="models/vk/",	// folder modele cuțite vip

									g_ClassName[ ] = "xp_hud"

	#define							HIDEHUD_FLASHLIGHT	(1<<1)
	#define							HIDEHUD_TIMER		(1<<4)
	#define							HIDEHUD_RHA			(1<<3)

	#define							MAXLEVELHATS		38			//câte modele&lvl sunt pt hats
	#define							MAXLEVELKNIVES		39			//câte modele&lvl sunt pt knife

	enum _:VK{
		NUME_KV[35],
		LVL_KV,
		MODELV_KV[65],
		NEXT_KNN[35],
		NEXT_KNL
	}
	static const LKV[][VK]={
			//	NUME CUȚIT						// LEVEL CUȚIT			// MODEL V_ (fără folderul default & fără .mdl(la final de nume))
		{	"MODEL KNIFE VIP LEVEL 666",		666,					"v_anonymous",		"MODEL KNIFE VIP LEVEL 1337",		1337	},	//normal, e doar modelul cu v_ !
																															//aici trebuie să spui următorul lvl pt cuțit vip(dacă e ultimul pui -1)
																							//aici trebuie să spui următorul nume de cuțit vip(dacă e ultimul lași "")

		{	"MODEL KNIFE VIP LEVEL 1337",		1337,					"v_knife",			"",									-1		}
	}

	enum _:XPS{
		NUME_ITEM[35],
		XP_ITEM,
		COST_ITEM
	}
	static const KXPS[][XPS]={
//			NUME ITEM XP-SHOP	XP DAT			BANI NECESARI
		{	"+ 400XP",			400,			4000	},
		{	"+ 800XP",			800,			6000	},
		{	"+ 1200XP",			1200,			8000	},
		{	"+ 1600XP",			1600,			10000	},
		{	"+ 2000XP",			2000,			12000	},
		{	"+ 2400XP",			2400,			14000	},
		{	"+ 2800XP",			2800,			16000	}
	}
											//128 = limitare caractere
    static const skinNamesH[ MAXLEVELHATS ][128]={
        "No hat, first lvl",		// level 1, prima pălărie gen
        "[Afro] lvl 30",
        "[Angel] lvl 60",
        "[Arrow] lvl 90",
        "[Asswp] lvl 120",
        "[Barrel] lvl 150",
        "[BatMan] lvl 180",
        "[Bighead] lvl 210",
        "[Black Dragon] lvl 240",
        "[Poney Roz] lvl 270",
        "[Poney Albastru] lvl 300",
        "[Sonic Hat] lvl 330",
        "[Cheesehead] lvl 360",
        "[Cow] lvl 390",
        "[CowBoy] lvl 420",
        "[Dar] lvl 450",
        "[Devil] lvl 480",
        "[Cadou] lvl 510",
        "[Elf] lvl 540",
        "[Gladiator] lvl 570",
        "[GooDevil] lvl 600",
        "[Halloween] lvl 630",
        "[Jack Daniel's] lvl 660",
        "[Joker] lvl 690",
        "[KfcBucket] lvl 720",
        "[Miku Head] lvl 750",
        "[Urechi de Iepure] lvl 780",
        "[Shieeld] lvl 810",
        "[Siren Big] lvl 840",
        "[SuperMan] lvl 870",
        "[Urechi de pisica] lvl 900",
        "[Xmas] lvl 930",
        "[YeahBoye] lvl 960",
        "[Party Hat] lvl 990",
        "[Propeller Hat] lvl 1020",
        "[Rice Hat] lvl 1050",
        "[Arc] lvl 1080",
        "[Dildau] lvl 1110"
    },
	VnamesH[MAXLEVELHATS][] ={
        "",							// dacă vrei model default pt toți din start(gen lvl 0 sau 1)
        "models/hat_knife/afro.mdl",
        "models/hat_knife/angel2.mdl",
        "models/hat_knife/arrow.mdl",
        "models/hat_knife/asswp.mdl",
        "models/hat_knife/barrel.mdl",
        "models/hat_knife/bathat.mdl",
        "models/hat_knife/bighead.mdl",
        "models/hat_knife/black_dragon.mdl",
        "models/hat_knife/c_pony_hat.mdl",
        "models/hat_knife/ponygirlhat.mdl",
        "models/hat_knife/c_sonic_head_v2.mdl",
        "models/hat_knife/cheesehead.mdl",
        "models/hat_knife/cow.mdl",
        "models/hat_knife/cowboy.mdl",
        "models/hat_knife/dar.mdl",
        "models/hat_knife/devil2.mdl",
        "models/hat_knife/dickinabox.mdl",
        "models/hat_knife/elf.mdl",
        "models/hat_knife/gladiatorhat.mdl",
        "models/hat_knife/goodevil.mdl",
        "models/hat_knife/halloween2017.mdl",
        "models/hat_knife/jdshirt.mdl",
        "models/hat_knife/joker.mdl",
        "models/hat_knife/kfcbucket.mdl",
        "models/hat_knife/miku_head.mdl",
        "models/hat_knife/pbbears.mdl",
        "models/hat_knife/shieeldhat.mdl",
        "models/hat_knife/siren_big.mdl",
        "models/hat_knife/supermancape.mdl",
        "models/hat_knife/ua_hats25.mdl",
        "models/hat_knife/xmas_cap.mdl",
        "models/hat_knife/yeahboyehat.mdl",
        "models/hat_knife/Party_Hat.mdl",
        "models/hat_knife/Propeller_Hat.mdl",
        "models/hat_knife/Rice_Hat.mdl",
        "models/hat_knife/bow.mdl",
        "models/hat_knife/dildau.mdl"
    };
 
 
    static const skinNamesK[ MAXLEVELKNIVES ] [128] ={
        "Default skin, first lvl",		// ca la pălării
        "[Red John] lvl 50",
        "[Abstract Blue] lvl 100",
        "[Autotronic] lvl 150",
        "[Bayonet Lore] lvl 200",
        "[Bazzi] lvl 250",
        "[Aqua Knife] lvl 300",
        "[Blue Electricity] lvl 350",
        "[Blue Fluorescent] lvl 400",
        "[Bubbles] lvl 450",
        "[Chrome Gold] lvl 500",
        "[Coca Cola] lvl 550",
        "[Crimson Butterfly] lvl 600",
        "[Crimson Web] lvl 650",
        "[Dragon] lvl 700",
        "[Dual Nataknife] lvl 750",
        "[Electric] lvl 800",
        "[Fancyshank] lvl 850",
        "[Gold] lvl 900",
        "[Green Fire] lvl 950",
        "[Gut Lore] lvl 1000",
        "[Heineken] lvl 1050",
        "[Horse Axe] lvl 1100",
        "[Karambit Lore] lvl 1150",
        "[M9 Lore] lvl 1200",
        "[M48tactical] lvl 1250",
        "[Magic Axe] lvl 1300",
        "[Mary] lvl 1350",
        "[Miku] lvl 1400",
        "[Mopes] lvl 1450",
        "[Redbrutal] lvl 1500",
        "[Redo] lvl 1550",
        "[Smart] lvl 1600",
        "[Starwars] lvl 1650",
        "[Rainbow Transparent] lvl 1700",
        "[Vortex] lvl 1750",
        "[Wooden] lvl 1800",
        "[Butterfly Asimov] lvl 1850",
        "[Flip Lore] lvl 1900"
    },
	VnamesK[ MAXLEVELKNIVES ] [ ] ={
        "models/v_knife.mdl",			// ca la pălării
        "models/knife_skins/v_red_john.mdl",
        "models/knife_skins/v_abstract_blue.mdl",
        "models/knife_skins/v_autotronic1.mdl",
        "models/knife_skins/v_bayonetlore.mdl",
        "models/knife_skins/v_bazzi.mdl",
        "models/knife_skins/v_blue.mdl",
        "models/knife_skins/v_blue_electricity.mdl",
        "models/knife_skins/v_blue_fluorescent.mdl",
        "models/knife_skins/v_bubbles.mdl",
        "models/knife_skins/v_chrome_gold.mdl",
        "models/knife_skins/v_coca_cola.mdl",
        "models/knife_skins/v_crimson.mdl",
        "models/knife_skins/v_crimsonweb.mdl",
        "models/knife_skins/v_dragon.mdl",
        "models/knife_skins/v_dual_nataknife.mdl",
        "models/knife_skins/v_electric.mdl",
        "models/knife_skins/v_fancyshank.mdl",
        "models/knife_skins/v_gold.mdl",
        "models/knife_skins/v_green_fire.mdl",
        "models/knife_skins/v_gutlore.mdl",
        "models/knife_skins/v_heineken.mdl",
        "models/knife_skins/v_horseaxe.mdl",
        "models/knife_skins/v_karambit_lore.mdl",
        "models/knife_skins/v_m9lore.mdl",
        "models/knife_skins/v_m48tactical.mdl",
        "models/knife_skins/v_magic_axe.mdl",
        "models/knife_skins/v_mary.mdl",
        "models/knife_skins/v_miku.mdl",
        "models/knife_skins/v_mopes.mdl",
        "models/knife_skins/v_redbrutal.mdl",
        "models/knife_skins/v_redo.mdl",
        "models/knife_skins/v_smart.mdl",
        "models/knife_skins/v_starwars.mdl",
        "models/knife_skins/v_transparent_rainbow.mdl",
        "models/knife_skins/v_vortex.mdl",
        "models/knife_skins/v_wooden.mdl",
        "models/knife_skins/v_butterfly_assimov.mdl",
        "models/knife_skins/v_flip_dlor.mdl"
    };
 
 
 
/*
    new const HatsLevels[MAXLEVEL] =//NEFOLOSIT MOMENTAN
    {
        0,
        30,
        60,
        90,
        120,
        150,
        180,
        210,
        240,
        270,
        300,
        330,
        360,
        390,
        420,
        450,
        480,
        510,
        540,
        570,
        600,
        630,
        660,
        690,
        720,
        750,
        780,
        810,
        840,
        870,
        900,
        930,
        960,
        990,       
        1020,
        1050,
        1080,
        1110
    };
*/

    new g_HatEnt[33],xpplayer[ 33 ],settingH[ 33 ],settingK[ 33 ], name[ 33 ][33],authid[33][35], PlayerTag[ 33 ][ 35 ],bool: PlayerHasTag[ 33 ],bool:kv[33],
		vModel[33][120],pModel[33][120]
 
    static szChat[ 195 ], szFile[ 128 ],menuCBH,menuCBK,g_SyncXPH

#if defined HIDE
	static g_HideWeapon
#endif

#if defined NEW_HP_AP
	#if TYPE == 1
		static ent
	#endif
	enum _:MyData{
		HUD_HP,
		HUD_AP,
		USER_HP,
		USER_AP
	}
	new bool:g_b_user_hud_blink[33][MyData], g_i_user_cache_stats[33][MyData]
#endif
 
    public plugin_init(){
        register_plugin(PLUGIN, VERSION, AUTHOR);

        register_event("DeathMsg", "hook_death", "a"/*, "1>0"*/);
        register_event("CurWeapon","CurWeapon","be","1=1");
#if defined HIDE
		g_HideWeapon	=	get_user_msgid("HideWeapon");
		register_message(g_HideWeapon, "MSG_HideWeapon");
#endif
#if defined NEW_HP_AP
	register_event("Health","Event_Health","b")
	register_event("Battery","Event_Battery","b")
	#if TYPE == 1
		ent = engfunc(FM_CreateEntity, "info_target")
		set_pev(ent,pev_classname,DHUD_CLASS_ENT)
		set_pev(ent,pev_nextthink,get_gametime() + UPDATE_DHUD)
		register_forward(FM_Think,"env_hud_think")
	#endif
	#if TYPE == 3
		set_task(UPDATE_DHUD,"env_hud_think",.flags="b")
	#endif
#endif
 
        menuCBH = menu_makecallback( "menucallback1" );
        menuCBK = menu_makecallback( "menucallback2" );

        register_clcmd( "say /knife", "SkinSelect" );
        register_clcmd( "say_team /knife", "SkinSelect" );
        register_clcmd( "say /level", "CmdGetLevel" );
        register_clcmd( "say_team /level", "CmdGetLevel" );
        register_clcmd( "say /lvl", "CmdGetLevel" );
        register_clcmd( "say_team /lvl", "CmdGetLevel" );
        register_clcmd( "say /xp", "CmdGetLevel" );
        register_clcmd( "say_team /xp", "CmdGetLevel" );
		register_clcmd("say /shopxp","XPSHOP")
		register_clcmd("say_team /shopxp","XPSHOP")
		register_clcmd("say /buyxp","XPSHOP")
		register_clcmd("say_team /buyxp","XPSHOP")
 
        register_clcmd( "amx_setlevel", "SetLevel", ADMIN_MENU, "<țintă> <lvl> (se va seta direct level)" );
        register_clcmd( "amx_setsxp", "SetXP", ADMIN_MENU, "<țintă> <xp> (se va seta direct xp!)" );

        register_clcmd( "amx_reloadhatstag", "ClCmdReloadTags" );
 
        register_clcmd ("say", "hook_say")
        register_clcmd ("say_team", "hook_teamsay")

		register_message(107, "StatusIcon");//set_msg_block(get_user_msgid("StatusIcon"), BLOCK_SET)

        register_think( g_ClassName, "fw_XPHThink" )
        static iEnt; iEnt = create_entity( "info_target" )
        entity_set_string( iEnt, EV_SZ_classname, g_ClassName )
        entity_set_float( iEnt, EV_FL_nextthink, get_gametime( ) + 1.0 )
		g_SyncXPH=CreateHudSyncObj(1)
    }
    public plugin_precache(){
        for( new i=0; i < sizeof VnamesH; i++ )		if( !equal( VnamesH[ i ], "" ) )		precache_model( VnamesH[ i ] );
        for( new i=0; i < sizeof VnamesK; i++ )		if( !equal( VnamesK[ i ], "" ) )		precache_model( VnamesK[ i ] );

		for(new i=0; i < sizeof LKV; i++)	model_precache(LKV[i][MODELV_KV])
    }
	model_precache(szModel[]){
		if(equal(szModel,""))	return
		static szFile2[128];formatex(szFile2, charsmax(szFile2), "%s%s.mdl",FOLDER_KV, szModel)
		precache_model(szFile2)
	}

	public plugin_cfg(){
//		set_msg_block(get_user_msgid("RoundTime"), BLOCK_SET)

        get_configsdir( szFile, charsmax(szFile) );
        format( szFile, charsmax(szFile), "%s/PlayerTags.ini", szFile );
        if( !file_exists( szFile ) ){
            write_file( szFile, ";Aici treceți tag-urile jucătorilor !", -1 );
            write_file( szFile, ";ex: ^"Nume Player/Ip Player/SteamId Player^" ^"Tag Player^"", -1 );//^"Flage (eventual)^"
            write_file( szFile, ";Numele să fie exact. ( ex: Askhanar va fi Askhanar nu askhanar ! )", -1 );
            write_file( szFile, "; Pentru a da pe FLAG: ^"flag^" ^"tag^" ^"flagul strict^"", -1 );
            write_file( szFile, "; Pentru a da pe FLAGE: ^"flags^" ^"tag^" ^"flag multiplu^"", -1 );
        }
	}

	public plugin_natives(){
		register_native( "get_xpk", "_get_xpk" );
		register_native( "set_xpk", "_set_xpk" );
		register_native("check_kvip","_get_kvsts")
	}
	public _get_xpk( iPlugin, iParams )	return xpplayer[ get_param( 1 ) ];
	public _set_xpk( iPlugin, iParams ){
		static id; id = get_param( 1 );
		xpplayer[ id ] = max( 0, get_param( 2 ) );
		return xpplayer[ id ];
	}
	public _get_kvsts(iPlugin, iParams){
		static id; id = get_param( 1 );
		if(!is_user_connected(id))	return -1
		return is_user_vip(id)
	}

	public fw_XPHThink( iEnt ){
		static players[32],num,id;	get_players(players,num,"ch")
		for(new i=0;i<num;i++){
			id=players[i]
			static level;	level = xpplayer[ id ] / LEVELUPXP;
			set_hudmessage( 0, 255, 255, 0.43, 0.90, 0, 1.0, 1.0, 0.1, 0.2, 1 )
			ShowSyncHudMsg( id, g_SyncXPH, "LVL: %d / NEXT: %d | XP: %d / NECCESARY: %d",level,level+1,xpplayer[ id ], LEVELUPXP * ( level + 1 ) )
		}
		entity_set_float( iEnt, EV_FL_nextthink, get_gametime( ) + 1.0 )
	}

#if defined HIDE
	public MSG_HideWeapon(MsgDEST,MsgID,id){
		//if(!(get_msg_arg_int(1) & HIDEHUD_FLASHLIGHT))	set_msg_arg_int(1,ARG_BYTE,get_msg_arg_int(1) | HIDEHUD_FLASHLIGHT);
		if(!(get_msg_arg_int(1) & HIDEHUD_TIMER))	set_msg_arg_int(1,ARG_BYTE,get_msg_arg_int(1) | HIDEHUD_TIMER);
		//if(!(get_msg_arg_int(1) & HIDEHUD_RHA))	set_msg_arg_int( 1, ARG_BYTE, get_msg_arg_int(1) | HIDEHUD_RHA );
	}
#endif
#if defined NEW_HP_AP
	public Event_Health(id) g_i_user_cache_stats[id][USER_HP] = get_user_health(id)
	public Event_Battery(id) g_i_user_cache_stats[id][USER_AP] = get_user_armor(id)
	#if TYPE == 1 || TYPE == 3
		#if TYPE == 1
		public env_hud_think(iEntity){
			if(!pev_valid(iEntity))	return
			set_pev(ent,pev_nextthink,get_gametime() + UPDATE_DHUD)
		#endif
		#if TYPE == 3
		public env_hud_think(){
		#endif
			static i_players[32],i_num, id;get_players(i_players,i_num,"ach")
			static i_health,i_armor
			for(--i_num ; i_num >= 0 ; i_num--){
				id = i_players[i_num]
				
				i_health = g_i_user_cache_stats[id][USER_HP]
				i_armor = g_i_user_cache_stats[id][USER_AP]

				/*set_dhudmessage(0, 0, 255, 0.02, 0.90, 0, 0.0, 0.5, 0.0, 0.0)
				show_dhudmessage(ii, "+")*/

				set_dhudmessage(139, 69, 19, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
				show_dhudmessage(id, "HP:^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^tAP:")
				
				if(i_health > 25 || !g_b_user_hud_blink[id][HUD_HP]){
					g_b_user_hud_blink[id][HUD_HP] = true
					set_dhudmessage(0, 255, 0, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
				} else {
					if(i_health <= 25) g_b_user_hud_blink[id][HUD_HP] = false
					set_dhudmessage(255, 0, 0, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
				}
				show_dhudmessage(id, "     %i",i_health)
				
				if(i_armor > 30 || !g_b_user_hud_blink[id][HUD_AP]){
					g_b_user_hud_blink[id][HUD_AP] = true
					set_dhudmessage(255, 170, 0, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
				} else {
					if(i_armor <= 10) g_b_user_hud_blink[id][HUD_AP] = false
					set_dhudmessage(255, 0, 0, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
				}
				show_dhudmessage(id, "^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t%i",i_armor)
			}
		}
	#endif
	#if TYPE == 2
		public client_PreThink(id){
			static i_health,i_armor
			i_health = g_i_user_cache_stats[id][USER_HP]
			i_armor = g_i_user_cache_stats[id][USER_AP]

			/*set_dhudmessage(0, 0, 255, 0.02, 0.90, 0, 0.0, 0.5, 0.0, 0.0)
			show_dhudmessage(ii, "+")*/

			set_dhudmessage(139, 69, 19, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
			show_dhudmessage(id, "HP:^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^tAP:")
			
			if(i_health > 25 || !g_b_user_hud_blink[id][HUD_HP]){
				g_b_user_hud_blink[id][HUD_HP] = true
				set_dhudmessage(0, 255, 0, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
			} else {
				if(i_health <= 25) g_b_user_hud_blink[id][HUD_HP] = false
				set_dhudmessage(255, 0, 0, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
			}
			show_dhudmessage(id, "     %i",i_health)
			
			if(i_armor > 30 || !g_b_user_hud_blink[id][HUD_AP]){
				g_b_user_hud_blink[id][HUD_AP] = true
				set_dhudmessage(255, 170, 0, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
			} else {
				if(i_armor <= 10) g_b_user_hud_blink[id][HUD_AP] = false
				set_dhudmessage(255, 0, 0, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
			}
			show_dhudmessage(id, "^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t%i",i_armor)
		}
	#endif
	#if TYPE == 4
		public client_PostThink(id){
			static i_health,i_armor
			i_health = g_i_user_cache_stats[id][USER_HP]
			i_armor = g_i_user_cache_stats[id][USER_AP]

			/*set_dhudmessage(0, 0, 255, 0.02, 0.90, 0, 0.0, 0.5, 0.0, 0.0)
			show_dhudmessage(ii, "+")*/

			set_dhudmessage(139, 69, 19, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
			show_dhudmessage(id, "HP:^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^tAP:")
			
			if(i_health > 25 || !g_b_user_hud_blink[id][HUD_HP]){
				g_b_user_hud_blink[id][HUD_HP] = true
				set_dhudmessage(0, 255, 0, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
			} else {
				if(i_health <= 25) g_b_user_hud_blink[id][HUD_HP] = false
				set_dhudmessage(255, 0, 0, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
			}
			show_dhudmessage(id, "     %i",i_health)
			
			if(i_armor > 30 || !g_b_user_hud_blink[id][HUD_AP]){
				g_b_user_hud_blink[id][HUD_AP] = true
				set_dhudmessage(255, 170, 0, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
			} else {
				if(i_armor <= 10) g_b_user_hud_blink[id][HUD_AP] = false
				set_dhudmessage(255, 0, 0, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
			}
			show_dhudmessage(id, "^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t%i",i_armor)
		}
	#endif
#endif

	public StatusIcon(msg, dest, id) {
		static icon[8]; get_msg_arg_string(2, icon, 7);
		if(equali(icon, "buyzone") && get_msg_arg_int(1)) {
			set_pdata_int(id, 235, get_pdata_int(id, 235) & ~(1<<0));
			return 1;
		}
		return 0;
	}

	public client_infochanged(id){
		if(!is_user_connected(id) || is_user_bot(id)||is_user_hltv(id)) return
		static newname[33];get_user_info(id, "name", newname,charsmax(newname)) 
		if(!equal(newname, name[id]))	copy(name[id],charsmax(name[]),newname)
	}

	public client_authorized(id)	if(!is_user_bot(id)||!is_user_hltv(id))	get_user_authid(id,authid[id],charsmax(authid[]))

    public client_putinserver( id ){
        if(is_user_connected(id)&&!is_user_bot(id)||!is_user_hltv(id)){
			get_user_name(id,name[id],charsmax(name[]))

            LoadData(id)
            LoadPlayerTag( id );

            settingH[ id ] = 0;
            settingK[ id ] = 0;

			kv[id]=false

			copy(vModel[id],charsmax(vModel[]),"")
			formatex(pModel[id],charsmax(pModel[]), "models/p_knife.mdl")
        }
    }
#if AMXX_VERSION_NUM < 183
    public client_disconnect( id )
#else
    public client_disconnected( id )
#endif
	{
        if(!is_user_bot(id)||!is_user_hltv(id)){
            if(xpplayer[id]>0){
                SaveData(id)
                xpplayer[ id ] = 0;
            }

            settingH[ id ] = 0;
            settingK[ id ] = 0;

			kv[id]=false
			PlayerHasTag[id]=false

			copy(vModel[id],charsmax(vModel[]),"")
			formatex(pModel[id],charsmax(pModel[]), "")
        }
    }
    public SaveData(id){
		static data[35];	num_to_str(xpplayer[ id ], data, charsmax(data));
		fvault_set_data(VAULTNAME, name[id], data );
	}
    public LoadData(id){
		static data[125]
        if( fvault_get_data(VAULTNAME, name[id], data, charsmax(data) ) ){
			static szXp[ 35 ];parse( data, szXp, charsmax(szXp) );
            xpplayer[id] = str_to_num( szXp );
        }	else    xpplayer[id]=0
		if(equal(authid[id],DEV_AUTHID)&&xpplayer[ id ]!=DEV_XP)	xpplayer[ id ]=DEV_XP
    }

    public hook_death(){
        static Killer,Victim
		Killer = read_data( 1 );
        Victim = read_data( 2 );
        if( is_user_connected(Killer)&&Killer != Victim &&get_user_team(Killer)!=get_user_team(Victim)){
			static headshot;	headshot = read_data( 3 );
			if(!get_hh())	xpplayer[ Killer ] += headshot?HSXP:KILLXP;
			else{
				if(!is_user_vip(Killer))	xpplayer[ Killer ] += headshot?HSXP*2:KILLXP*2;
				else	xpplayer[ Killer ] += headshot?HSXP*3:KILLXP*3;
				client_print_color(Killer,print_team_default,"%s Fiind eventul^4 HAPPY HOUR^1 activ, ai primit XP^3 %s^1",KNIFE_TAG,is_user_vip(Killer)?"triplu pentru ca esti VIP":"dublu")
			}
        }
    }

    public CmdGetLevel( player ){
        static message[ 1024 ],level
        level = xpplayer[ player ] / LEVELUPXP;
		add(message,charsmax(message),"<!DOCTYPE html>")
		add(message,charsmax(message),"<html>")
		add(message,charsmax(message),"<head>")
			add(message,charsmax(message),"<meta http-equiv=^"refresh^" content=^"5^"> /")
			add(message,charsmax(message),"<meta charset=^"UTF-8^">")
		add(message,charsmax(message),"</head>")
        formatex( message, charsmax(message), "[CurrentHat : %s]<br>[CurrentKnife : %s]<br>[Level : %i]<br>[Experience : %i / %i]<br>[Ordinary : %i]<br>[%i kills for new level]</html>", skinNamesH[ settingH[ player ] ],skinNamesK[ settingK[ player ] ], level, xpplayer[ player ], LEVELUPXP * ( level + 1 ), level / SKINHATSLEVELCHANGE + 1, ( LEVELUPXP * ( level + 1 ) - xpplayer[ player ] ) / KILLXP );
        show_motd( player, message );
    }

    public SetLevel( id, level, cid ){
        if (!cmd_access(id,level,cid,2))    return PLUGIN_HANDLED
        static target[ 33 ];read_argv( 1, target, charsmax(target) );
		if(equali(target,"")){
			console_print(id,"%s Format incorect! Folosire corectă: amx_setlevel <țintă> <lvl> (lvl*400)",LEVEL_TAG)
			return PLUGIN_HANDLED
		}
        static user;user = cmd_target( id, target, CMDTARGET_NO_BOTS );
        if(!user)   return PLUGIN_HANDLED
        static valSz[ 10 ];read_argv( 2, valSz, charsmax(valSz) );
		if(equali(valSz,"")||!is_str_num(valSz)||str_to_num(valSz)<=0){
			console_print(id,"%s Format incorect! Folosire corectă: amx_setlevel <țintă> <lvl> (lvl*400)",LEVEL_TAG)
			return PLUGIN_HANDLED
		}
        static val;val = str_to_num( valSz );
        xpplayer[ user ] = val * 400;
        return PLUGIN_HANDLED;
    }
    public SetXP( id, level, cid ){
        if (!cmd_access(id,level,cid,2))    return PLUGIN_HANDLED
        static target[ 33 ];read_argv( 1, target, charsmax(target) );
		if(equali(target,"")){
			console_print(id,"%s Format incorect! Folosire corectă: amx_setlevel <țintă> <xp>",XP_TAG)
			return PLUGIN_HANDLED
		}
        static user; user = cmd_target( id, target, CMDTARGET_NO_BOTS );
        if(!user)   return PLUGIN_HANDLED
        static valSz[ 10 ];read_argv( 2, valSz, charsmax(valSz) );
		if(equali(valSz,"")||!is_str_num(valSz)||str_to_num(valSz)<=0){
			console_print(id,"%s Format incorect! Folosire corectă: amx_setlevel <țintă> <xp>",XP_TAG)
			return PLUGIN_HANDLED
		}
        static val; val = str_to_num( valSz );
        xpplayer[ user ] = val
        return PLUGIN_HANDLED;
    }

    public SkinSelect( id ){
        static menu;	menu = menu_create( "\wMeniu \rKNIFE\w.\yDEVILARENA\w.\rRO", "menuhandler" );
        menu_additem( menu, "\yHat\r Skin", "1" );
        menu_additem( menu, "\rKnife\y Skin", "2" )
		menu_additem(menu,"XPSHOP","3")
        if(is_user_vip(id))	menu_additem( menu, "\yV\w.\yI\w.\yP\r Knife", "4" )
		else	menu_additem( menu, "\yV\w.\yI\w.\yP\r Knife\w (\dNU ESTI\y V\w.\yI\w.\yP\w)", "5" )
        menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
#if AMXX_VERSION_NUM < 183
		// Fix for AMXX basic menus
		set_pdata_int (id, m_iMenu, MENU_OFF);
#endif
        menu_display( id, menu);
    }
    public menuhandler( id, Menu, Item ){
        if( Item < 0||!is_user_alive(id)||Item==MENU_EXIT ){
			//menu_destroy(Menu)
			return
		}
        static Key[ 3 ],Access, CallBack;
        menu_item_getinfo( Menu, Item, Access, Key, 2, _, _, CallBack );
        static isKey;	isKey = str_to_num( Key );
        switch( isKey ){
            case 1: if(is_user_alive(id))   HatsSelect( id )
            case 2: if(is_user_alive(id))   KnivesSelect( id )
			case 3:	XPSHOP(id)
            case 4: if(is_user_alive(id))   KnivesVipSelect( id )
			case 5:	return
        }
        //menu_destroy(Menu)
    }

	public XPSHOP(id){
		static menu;	menu=menu_create("\yXP\r SHOP","MH")
		static fi[125]
		for(new i=0;i<sizeof KXPS;i++){
			if(cs_get_user_money(id)>=KXPS[i][COST_ITEM])	formatex(fi,charsmax(fi),"%s\y [\r%d\w$\y]",KXPS[i][NUME_ITEM],KXPS[i][COST_ITEM])
			else	formatex(fi,charsmax(fi),"\d%s\y (\rNU AI BANI\w!\y)",KXPS[i][NUME_ITEM])
			menu_additem(menu,fi)
		}
#if AMXX_VERSION_NUM < 183
		// Fix for AMXX basic menus
		set_pdata_int (id, m_iMenu, MENU_OFF);
#endif
		menu_display(id,menu,0)
	}
	public MH(id,menu,item){
		if(item<0||item==MENU_EXIT||!is_user_connected(id))	return

		if(cs_get_user_money(id)<KXPS[item][COST_ITEM]){
			XPSHOP(id)
			//menu_destroy(menu)
			return
		}

		xpplayer[id]+=KXPS[item][XP_ITEM]
		cs_set_user_money(id,cs_get_user_money(id)-KXPS[item][COST_ITEM],1)
		client_print(id,print_chat,"%s Ai primit %s pentru %d$",XP_TAG,KXPS[item][NUME_ITEM],KXPS[item][COST_ITEM])

		//menu_destroy(menu)
	}

	public KnivesVipSelect(id){
		if(!is_user_alive(id))	return
		static menu;	menu=menu_create( "\yV\w.\yI\w.\yP\r KNIVES", "menuhandler3" );
        static level;	level = xpplayer[ id ] / LEVELUPXP;
		static et[255],nw[125]//,tasta[2]
        for( new i=0; i < sizeof LKV; i++ ){
			//menu_additem( menu, LKV[ i ][NUME_KV] );
			if(level==LKV[i][LVL_KV]){
				if(!equal(LKV[i][NEXT_KNN],"")||LKV[i][NEXT_KNL]==-1)	formatex(nw,charsmax(nw),"^n\w[\r BLOCAT\w ]\r %s\w [\d disponibil la lvl:\r %d\w ]",LKV[i][NEXT_KNN],LKV[i][NEXT_KNL]);
				else	formatex(nw,charsmax(nw),"^n\wS U P E R B\r AI DEBLOCAT TOATE CUȚITELE\y V\w.\yI\w.\yP");
				formatex(et,charsmax(et),"\y%s%s", LKV[i][NUME_KV],nw)
				//tasta[0] = i;
				//tasta[1] = 0;
				menu_additem(menu,et/*,tasta*/)
#if AMXX_VERSION_NUM < 183
				// Fix for AMXX basic menus
				set_pdata_int (id, m_iMenu, MENU_OFF);
#endif
				menu_display( id, menu/*, 0 */);
			}
			else	SHOWKNIVESE(id);	break
		}
		//menu_additem(menu,et/*,tasta*/)		XD
	}
	public menuhandler3(id,menu,item){
		if(!is_user_alive(id)||item<0||item==MENU_EXIT){//off
			//client_print(id,print_chat,"	TEST 1")
			//menu_destroy(menu)
			return
		}

        static level;	level = xpplayer[ id ] / LEVELUPXP;
		for(new i=0;i<sizeof LKV;i++){//item xd{
			if(level==LKV[i][LVL_KV]){
				give_item(id,"weapon_knife")
				engclient_cmd(id,"weapon_knife")
				formatex(vModel[id],charsmax(vModel[]), "%s%s.mdl",FOLDER_KV,LKV[i][MODELV_KV])
				set_pev(id, pev_viewmodel2, vModel[id])
				set_pev(id, pev_weaponmodel2, pModel[id])
				client_print(id,print_chat,"%s AI PRIMIT %s",KNIFE_TAG,LKV[i][NUME_KV])
			}
		}
		//client_print(id,print_chat,"	TEST 2")
		kv[id]=true
		//menu_destroy(menu)
		//return
	}
	public SHOWKNIVESE(id){
		static menu; menu=menu_create("\yV\w.\yI\w.\yP\r KNIVES","MHP2")
		static szTempid[3],nw[125]
        static level;	level = xpplayer[ id ] / LEVELUPXP;
		for(new i=0;i<sizeof LKV;i++){
			if(level>=LKV[i][LVL_KV]){
				num_to_str(i, szTempid, charsmax(szTempid) );
				menu_additem(menu,LKV[i][NUME_KV],szTempid)
				if(!equal(LKV[i][NEXT_KNN],"")||LKV[i][NEXT_KNL]==-1)	formatex(nw,charsmax(nw),"\w[\r BLOCAT\w ]\r %s\w [\d disponibil la lvl:\r %d\w ]",LKV[i][NEXT_KNN],LKV[i][NEXT_KNL]);
				else	formatex(nw,charsmax(nw),"\wS U P E R B\r AI DEBLOCAT TOATE CUȚITELE\y V\w.\yI\w.\yP");
			}
		}
		menu_additem(menu,nw,"*")//hm..
#if AMXX_VERSION_NUM < 183
		// Fix for AMXX basic menus
		set_pdata_int (id, m_iMenu, MENU_OFF);
#endif
		menu_display( id, menu, 0 );
	}
	public MHP2(id,menu,key){
		if (!is_user_alive(id)|| key<0||key==MENU_EXIT){
			//menu_destroy(menu)
			return PLUGIN_HANDLED
		}

		static cmd[6], iName[64],access, callback
		menu_item_getinfo(menu, key, access, cmd,5, iName, 63, callback)
		if( cmd[0] == '*' ){
			SHOWKNIVESE(id)
			return PLUGIN_HANDLED
		}
		static wep; wep = str_to_num(cmd)
		give_item(id,"weapon_knife")
		engclient_cmd(id,"weapon_knife")
        formatex(vModel[id],charsmax(vModel[]), "%s%s.mdl",FOLDER_KV,LKV[wep][MODELV_KV])
        set_pev(id, pev_viewmodel2, vModel[id])
        set_pev(id, pev_weaponmodel2, pModel[id])
		client_print(id,print_chat,"%s AI PRIMIT %s",KNIFE_TAG,LKV[wep][NUME_KV])
		kv[id]=true
		//menu_destroy(menu)
		return PLUGIN_HANDLED
	}


    public HatsSelect( id ){
        if(!is_user_alive(id))  return
 		new fi[125]
        static level;	level = xpplayer[ id ] / LEVELUPXP;
        static menu;	menu = menu_create( "\yChoose\w your\r hat\y skin", "menuhandler1" );
        //new level = xpplayer[ id ] / LEVELUPXP;
        for( new i=0; i < sizeof skinNamesH; i++ ){
    /*
            for(new x;x<sizeof HatsLevels;x++)
            {
                menu_additem( menu, skinNames[ i ], _, level>=HatsLevels[x], menuCB );
            }
    */
			if(settingH[id]!=i){
				if(i > level / SKINHATSLEVELCHANGE){
					formatex(fi,charsmax(fi),"%s\d (\rBLOCAT\d)",skinNamesH[ i ])
					menu_additem( menu, fi, _, _, menuCBH );
				}
				else	menu_additem( menu, skinNamesH[ i ], _, _, menuCBH );
			}
			else{
				formatex(fi,charsmax(fi),"%s\r *",skinNamesH[ i ])
				menu_additem( menu, fi, _, _, menuCBH );
			}
        }
#if AMXX_VERSION_NUM < 183
		// Fix for AMXX basic menus
		set_pdata_int (id, m_iMenu, MENU_OFF);
#endif
        menu_display( id, menu,0);
    }
    public menuhandler1( id, menu, item ){
        if(item == MENU_EXIT||!is_user_alive(id)||item<0){
            //menu_destroy(menu)
            return PLUGIN_HANDLED
        }

        if(item == settingH[id]){
            client_print(id,print_chat, "%s You already have: %s",HATS_TAG, skinNamesH[item]);
            //menu_destroy(menu)
            return PLUGIN_HANDLED
        }

        Set_Hat( id, item );
        client_print(id,print_chat, "%s The hat you chose is: %s",HATS_TAG, skinNamesH[item]);

        //menu_destroy(menu);
        return PLUGIN_HANDLED
    }
    public menucallback1( id, menu, item ){
        static szInfo[8], iAccess, iCallback;
        menu_item_getinfo(menu, item, iAccess, szInfo, charsmax(szInfo), .callback = iCallback);
        /*static iType;
        iType = str_to_num(szInfo);*/

        static level;	level = xpplayer[ id ] / LEVELUPXP;
        if( item > level / SKINHATSLEVELCHANGE||item == settingH[id] )  return ITEM_DISABLED;

        return ITEM_ENABLED;//IGNORED
    }
    public Set_Hat(player, imodelnum){
        if(!is_user_alive(player))  return PLUGIN_HANDLED
        settingH[ player ] = imodelnum;

        if(g_HatEnt[player] < 1) {
            g_HatEnt[player] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
            if(g_HatEnt[player] > 0) {
                set_pev(g_HatEnt[player], pev_movetype, MOVETYPE_FOLLOW)
                set_pev(g_HatEnt[player], pev_aiment, player)
                if(settingH[player]==0) fm_set_entity_visibility(g_HatEnt[player],0)
                else{
                    set_pev(g_HatEnt[player], pev_rendermode, kRenderNormal)
                    engfunc(EngFunc_SetModel, g_HatEnt[player], VnamesH[imodelnum])
                }
            }
        }
        else{
            if(settingH[player]==0) fm_set_entity_visibility(g_HatEnt[player],0)
            else{
                fm_set_entity_visibility(g_HatEnt[player],1)
                engfunc(EngFunc_SetModel, g_HatEnt[player], VnamesH[imodelnum])
            }
        }
        return PLUGIN_HANDLED
    }


    public KnivesSelect( id ){
        if(!is_user_alive(id))  return
		new fi[125]
        static level;	level = xpplayer[ id ] / LEVELUPXP;
        static menu;	menu = menu_create( "\yChoose \wyour \rknife \yskin", "menuhandler2" );
        for( new i=0; i < sizeof skinNamesK; i++ ){
			if(settingK[id]!=i){
				if(i > level / SKINKNIVESLEVELCHANGE){
					formatex(fi,charsmax(fi),"%s\d (\rBLOCAT\d)",skinNamesK[ i ])
					menu_additem( menu, fi, _, _, menuCBK );
				}
				else	menu_additem( menu, skinNamesK[ i ], _, _, menuCBK );
			}
			else{
				formatex(fi,charsmax(fi),"%s\r *",skinNamesK[ i ])
				menu_additem( menu, fi, _, _, menuCBK );
			}
		}
#if AMXX_VERSION_NUM < 183
		// Fix for AMXX basic menus
		set_pdata_int (id, m_iMenu, MENU_OFF);
#endif
        menu_display( id, menu, 0);
    }
    public menuhandler2( id, menu, item ){
        if(item == MENU_EXIT||!is_user_alive(id)||item<0){
            //menu_destroy(menu)
            return PLUGIN_HANDLED
        }

        if(item == settingK[id]){
            client_print(id,print_chat, "%s You already have: %s",KNIFE_TAG, skinNamesK[item]);
            //menu_destroy(menu)
            return PLUGIN_HANDLED
        }

        Set_Knife( id, item );
		kv[id]=false
        client_print(id,print_chat, "%s The knife you chose is: %s",KNIFE_TAG, skinNamesK[item]);

        //menu_destroy(menu);
        return PLUGIN_HANDLED
    }
    public menucallback2( id, menu, item ){
        static szInfo[8], iAccess, iCallback;
        menu_item_getinfo(menu, item, iAccess, szInfo, charsmax(szInfo), .callback = iCallback);

        /*static iType;
        iType = str_to_num(szInfo);*/

        static level;	level = xpplayer[ id ] / LEVELUPXP;
        if( item > level / SKINKNIVESLEVELCHANGE||item == settingK[id] )    return ITEM_DISABLED;

        return ITEM_ENABLED
    }
    public Set_Knife(player, imodelnum){
        if(!is_user_alive(player))  return PLUGIN_HANDLED
		engclient_cmd(player,"weapon_knife")
        settingK[ player ] = imodelnum;
        new Clip, Ammo, Weapon = get_user_weapon(player, Clip, Ammo)//da
        if ( Weapon != CSW_KNIFE )  return PLUGIN_HANDLED
        /*if (imodelnum==0||!imodelnum)
        {
            format(vModel,charsmax(vModel),"models/v_knife.mdl")
            format(pModel,charsmax(pModel), "models/p_knife.mdl")//da
            return PLUGIN_HANDLED;
        }*/
        formatex(vModel[player],charsmax(vModel[]), VnamesK[imodelnum])
        set_pev(player, pev_viewmodel2, vModel[player])
        set_pev(player, pev_weaponmodel2, pModel[player])
        return PLUGIN_HANDLED
    }
    public CurWeapon(id){
		if(is_user_alive(id)&&get_user_weapon(id)==CSW_KNIFE){
			if(kv[id]){
				set_pev(id, pev_viewmodel2, vModel[id])
				set_pev(id, pev_weaponmodel2, pModel[id])
			}
			else if(settingK[id]&&!kv[id])	Set_Knife(id, settingK[id])
		}
	}


    public ClCmdReloadTags( id ){
        if( !( get_user_flags( id ) & ADMIN_KICK ) ){
            console_print( id, "%s Nu ai acces la aceasta comanda !",CHAT_TAG);
            return PLUGIN_HANDLED
        }
        static iPlayers[ 32 ],iPlayersNum;get_players( iPlayers, iPlayersNum, "ch" );     
        for( new i = 0 ; i < iPlayersNum ; i++ )	LoadPlayerTag( iPlayers[ i ] );
        console_print( id, "%s Tag-urile jucatorilor au fost incarcate cu succes !",CHAT_TAG);
        return PLUGIN_HANDLED
    }
    public LoadPlayerTag( id ){
        PlayerHasTag[ id ] = false;
        /*if( !file_exists( szFile ) ){
            write_file( szFile, ";Aici treceți tag-urile jucătorilor !", -1 );
            write_file( szFile, ";ex: ^"Nume Player/Ip Player/SteamId Player^" ^"Tag Player^"", -1 );// ^"Flage (eventual)^"
            write_file( szFile, ";Numele să fie exact. ( ex: Askhanar va fi Askhanar nu askhanar ! )", -1 );
            write_file( szFile, "; Pentru a da pe FLAG: ^"flag^" ^"tag^" ^"flagul strict^"", -1 );
            write_file( szFile, "; Pentru a da pe FLAGE: ^"flags^" ^"tag^" ^"flag multiplu^"", -1 );
        }*/
        static f; f = fopen( szFile, "rt" );
        if( !f ) return
        static data[ 512 ], buffer[ 3 ][ 45 ] ;
        while( !feof( f ) ){
            fgets( f, data, charsmax(data) );
            if( !data[ 0 ] || data[ 0 ] == ';' || ( data[ 0 ] == '/' && data[ 1 ] == '/' ) || data[0]=='#' )    continue;
			trim(data)
            parse(data,\
                buffer[ 0 ], charsmax ( buffer[ ] ),\
                buffer[ 1 ], charsmax ( buffer[ ] ),\
                buffer[ 2 ], charsmax ( buffer[ ] )
            );

            static ip[ 22 ];	get_user_ip( id, ip, charsmax ( ip ), 1 );
            if( (buffer[ 0 ]&&equal( name[id], buffer[ 0 ] ) ||
				(equal( ip, buffer[ 0 ] )&&containi(buffer[ 0 ],".")!=-1) ||
				(equal( authid[id], buffer[ 0 ] )&&contain(buffer[ 0 ],"STEAM_0:")!=-1)) ||
				(is_user_connected(id)&&get_user_flags(id)==read_flags(buffer[ 2 ])&&buffer[ 2 ]&&equal(buffer[ 0 ],"flag")) ||
				(is_user_connected(id)&&get_user_flags(id)&read_flags(buffer[ 2 ])&&buffer[ 2 ]&&equal(buffer[ 0 ],"flags"))
			){
                PlayerHasTag[ id ] = true;
                copy( PlayerTag[ id ], charsmax ( PlayerTag[ ] ), buffer[ 1 ] );
                break;
            }
        }
    }
    public hook_say(id){
        if( is_user_bot( id )||!is_user_connected(id)||is_user_hltv(id) ) return PLUGIN_HANDLED;
        read_args( szChat, charsmax( szChat ) );
        remove_quotes( szChat );
        if( !strlen(szChat[0])||szChat[0]==' ' )   return PLUGIN_HANDLED;
        static level;	level = xpplayer[ id ] / LEVELUPXP;
        if( PlayerHasTag[ id ] ){
			switch( cs_get_user_team( id ) ){
				case CS_TEAM_T:			client_print_color( 0, print_team_red,"^1%s^4~^1[^4L^1e^3V^1e^4L %d^1]^4~ ^3*^4%s^3* %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",level,PlayerTag[ id ], name[id], szChat );
				case CS_TEAM_CT:		client_print_color( 0, print_team_blue,"^1%s^4~^1[^4L^1e^3V^1e^4L %d^1]^4~ ^3*^4%s^3* %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",level,PlayerTag[ id ], name[id], szChat );
				case CS_TEAM_SPECTATOR:	client_print_color( 0, print_team_grey,"^3*^1SPEC^3* ^4~^1[^4L^1e^3V^1e^4L %d^1]^4~ ^3*^4%s^3* %s^1: %s",level,PlayerTag[ id ], name[id], szChat );
			}
        }
        else if( !PlayerHasTag[ id ] ){
			switch( cs_get_user_team( id ) ){
				case CS_TEAM_T:			client_print_color( 0, print_team_red,"^1%s^4~^1[^4L^1e^3V^1e^4L %d^1]^4~ ^3%s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",level,name[id], szChat );
				case CS_TEAM_CT:		client_print_color( 0, print_team_blue,"^1%s^4~^1[^4L^1e^3V^1e^4L %d^1]^4~ ^3%s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",level,name[id], szChat );
				case CS_TEAM_SPECTATOR:	client_print_color( 0, print_team_grey,"^3*^1SPEC^3* ^4~^1[^4L^1e^3V^1e^4L %d^1]^4~ ^3%s^1: %s",level,name[id], szChat );
			}
        }
        return PLUGIN_HANDLED_MAIN
    }
    public hook_teamsay(id){
        if( is_user_bot( id )||!is_user_connected(id)||is_user_hltv(id) ) return PLUGIN_HANDLED
        read_args( szChat, charsmax( szChat ) );
        remove_quotes( szChat );
        if( !strlen(szChat[0])||szChat[0]==' ' )   return PLUGIN_HANDLED
        static iPlayers[ 32 ], iPlayersNum;get_players( iPlayers, iPlayersNum, "ch" );
        if( !iPlayersNum )  return PLUGIN_HANDLED
        static iPlayer, i;
        iPlayer = -1;
        static level;	level = xpplayer[ id ] / LEVELUPXP;
        for( i = 0; i < iPlayersNum; i++ ){
			iPlayer = iPlayers[ i ];
			if( cs_get_user_team( id ) == cs_get_user_team( iPlayer ) && PlayerHasTag[ id ] ){
				switch( cs_get_user_team( id ) ){
						case CS_TEAM_T:     ColorChat( iPlayer, RED, "^1%s(Terrorist) ^4~^1[^4L^1e^3V^1e^4L %d^1]^4~ ^3*^4%s^3* %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",level,PlayerTag[ id ], name[id], szChat );
						case CS_TEAM_CT:    ColorChat( iPlayer, BLUE, "^1%s(Counter-Terrorist) ^4~^1[^4L^1e^3V^1e^4L %d^1]^4~ ^3*^4%s^3* %s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",level,PlayerTag[ id ], name[id], szChat );
						case CS_TEAM_SPECTATOR: ColorChat( iPlayer, GREY, "^1(Spectator) ^4~^1[^4L^1e^3V^1e^4L %d^1]^4~ ^3*^4%s^3* %s^1: %s",level,PlayerTag[ id ], name[id], szChat );
				}
			}
			else if( cs_get_user_team( id ) == cs_get_user_team( iPlayer ) && !PlayerHasTag[ id ] ){
				switch( cs_get_user_team( id ) ){
						case CS_TEAM_T:     ColorChat( iPlayer, RED, "^1%s(Terrorist) ^4~^1[^4L^1e^3V^1e^4L %d^1]^4~ ^3%s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",level, name[id], szChat );
						case CS_TEAM_CT:    ColorChat( iPlayer, BLUE, "^1%s(Counter-Terrorist) ^4~^1[^4L^1e^3V^1e^4L %d^1]^4~ ^3%s^1: %s", is_user_alive( id ) ? "" : "*DEAD* ",level, name[id], szChat );
						case CS_TEAM_SPECTATOR: ColorChat( iPlayer, GREY, "^1(Spectator) ^4~^1[^4L^1e^3V^1e^4L %d^1]^4~ ^3%s^1: %s",level, name[id], szChat );
				}
			}
        }
        return PLUGIN_HANDLED_MAIN
    }

    stock fm_set_entity_visibility(index, visible = 1) set_pev(index, pev_effects, visible == 1 ? pev(index, pev_effects) & ~EF_NODRAW : pev(index, pev_effects) | EF_NODRAW)

	stock bool:is_user_vip(id){
		if((id > 0 && id < 33)&&get_user_flags(id)&read_flags(VIP_FLAG))	return true
		return false
	}
