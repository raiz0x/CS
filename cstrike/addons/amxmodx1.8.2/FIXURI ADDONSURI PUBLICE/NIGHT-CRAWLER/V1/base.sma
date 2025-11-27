	/* 
	-	Credits:
	-		Joropito - Team Menu
	-		Pastout - Suicide Bomb
	-		Exolent - Teleport
	*/

	#include < amxmodx >
	#include < cstrike >
	#include < hamsandwich >
	#include < fun >
	#include < fakemeta >
	#include < engine >
	#include < xs >
	
	#define PISTOL_WEAPONS_BIT    (1<<CSW_GLOCK18|1<<CSW_USP|1<<CSW_DEAGLE|1<<CSW_P228|1<<CSW_FIVESEVEN|1<<CSW_ELITE)
	#define SHOTGUN_WEAPONS_BIT    (1<<CSW_M3|1<<CSW_XM1014)
	#define SUBMACHINE_WEAPONS_BIT    (1<<CSW_TMP|1<<CSW_MAC10|1<<CSW_MP5NAVY|1<<CSW_UMP45|1<<CSW_P90)
	#define RIFLE_WEAPONS_BIT    (1<<CSW_FAMAS|1<<CSW_GALIL|1<<CSW_AK47|1<<CSW_SCOUT|1<<CSW_M4A1|1<<CSW_SG550|1<<CSW_SG552|1<<CSW_AUG|1<<CSW_AWP|1<<CSW_G3SG1)
	#define MACHINE_WEAPONS_BIT    (1<<CSW_M249)

	#define PRIMARY_WEAPONS_BIT    (SHOTGUN_WEAPONS_BIT|SUBMACHINE_WEAPONS_BIT|RIFLE_WEAPONS_BIT|MACHINE_WEAPONS_BIT)
	#define SECONDARY_WEAPONS_BIT    (PISTOL_WEAPONS_BIT)

	#define IsPrimaryWeapon(%1) ( (1<<%1) & PRIMARY_WEAPONS_BIT )
	#define IsSecondaryWeapon(%1) ( (1<<%1) & PISTOL_WEAPONS_BIT )

	#define m_iVGUI						510
	#define m_fGameHUDInitialized		349
	#define m_fNextHudTextArgsGameTime	198

	#define TEAM_MENU					"#Team_Select"
	#define TEAM_MENU2					"#Team_Select_Spect"

	#define MIN_WEAPON		CSW_P228
	#define MAX_WEAPON 		CSW_P90

	#define TEAM_NC 		CS_TEAM_T
	#define TEAM_HUMAN 		CS_TEAM_CT

	/* Constants */
	
		enum (+=1000)
		{
			TASK_ADRENALINE = 1000,
			TASK_SUICIDE,
			TASK_POISON,
			TASK_INVISIBLE,
			TASK_STARTGAME
		}
		
		new const g_iMaxBPAmmo[ MAX_WEAPON + 1 ] =
		{
			0, 52, 0, 90, 1, 32, 0, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120, 30,
			120, 200, 32, 90, 120, 90, 2, 35, 90, 90, 0, 100
		};

		new const g_iMaxClipAmmo[ MAX_WEAPON + 1 ] =
		{
			0, 13, 0, 10, 0, 7, 0, 30, 30, 0, 30, 20, 25, 30, 35, 25, 12, 20, 10, 30, 
			100, 8, 30, 30, 20, 0, 7, 30, 30, 0, 50
		};

		new const g_szWeaponClassnames[ MAX_WEAPON + 1 ][ ] =
		{
			"", "weapon_p228", "", "weapon_scout", "weapon_hegrenade",
			"weapon_xm1014", "weapon_c4", "weapon_mac10", "weapon_aug",
			"weapon_smokegrenade", "weapon_elite", "weapon_fiveseven",
			"weapon_ump45", "weapon_sg550", "weapon_galil", "weapon_famas",
			"weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy",
			"weapon_m249", "weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1",
			"weapon_flashbang", "weapon_deagle", "weapon_sg552", "weapon_ak47",
			"weapon_knife", "weapon_p90"
		};

		new const g_szWeaponNames[ MAX_WEAPON + 1 ][ ] =
		{
			"", "P228", "", "Schmidt Scout", "", "XM1014 (Auto-Shotgun)", "",
			"Mac-10", "AUG", "", "Dual Elites", "Five-Seven", "UMP-45", "SG-550",
			"Galil", "Famas", "USP", "Glock-18", "AWP", "MP5-Navy", "M249 (Para)",
			"M3 (Pump-Shotgun)", "M4A1", "TMP", "G3SG1", "", "Deagle", "SG-552",
			"AK-47", "", "P90"
		};

		enum _:ItemsInfo
		{
			ITEM_LASER, // Done
			ITEM_SUICIDE, // Done
			ITEM_POISON, // Done
			ITEM_ADRENALINE, // Done
			ITEM_MEDKIT // Done
		};

		new const g_szItemNames[ ItemsInfo ][ ] =
		{
			"Laser Sight",
			"Suicide Bomber \r(Bind Key Activated)",
			"Poison Scout Bullets",
			"Adrenaline \r(Bind Key Activated)",
			"Medic Kit \r(Bind Key Activated)"
		};
		
		new const g_szObjectives[ ][ ] = 
		{
			"func_bomb_target",
			"info_bomb_target",
			"hostage_entity",
			"monster_scientist",
			"func_hostage_rescue",
			"info_hostage_rescue",
			"info_vip_start",
			"func_vip_safetyzone",
			"func_escapezone"
		}
		
		new const g_szPrefix[ ] = "[NightCrawler]";

		new const g_szNCModel[ ] = "models/player/nightcrawler/nightcrawler.mdl";
		new const g_szNCKnife_V[ ] = "models/nightcrawler/v_nightcrawler.mdl";
		
		new const g_szLaserSprite[ ] = "sprites/zbeam4.spr";
		new const g_szExplosionSprite[ ] = "sprites/zerogxplode.spr";
		
		new const g_szSuicideBombSound[ ] = "weapons/c4_beep4.wav";
		new const g_szTeleportSound[ ] = "warcraft3/blinkarrival.wav";
		
	/* Booleans */
	
		new bool:g_bRememberGuns[ 33 ];
		new bool:g_bNCNextRound[ 33 ];
		new bool:g_bHasLaser[ 33 ];
		new bool:g_bAdrenalineActive[ 33 ];
		new bool:g_bVisible[ 33 ];
		
	/* Floats */
		
		new Float:g_flWallOrigin[ 33 ][ 3 ];
		new Float:g_flLastTeleportTime[ 33 ];
		
	/* Integers */
	
		new g_iPrimaryWeapon[ 33 ];
		new g_iSecondaryWeapon[ 33 ];
		new g_iChosenItem[ 33 ];
		
		new g_iAdrenalineUses[ 33 ];
		new g_iMedKitUses[ 33 ];
		new g_iSuicideTime[ 33 ];
		new g_iPoisonRemaining[ 33 ];
		new g_iTeleportsRemaining[ 33 ];
		
		new g_iTeamCount[ CsTeams ];		
		
		new g_iCurrentRound;
		
		new g_iMaxPlayers;
		
		new g_iLaserSprite;
		new g_iExplosionSprite;

	/* Menus */
		
		new g_hWeaponMenu;
		new g_hPrimaryWeaponMenu;
		new g_hSecondaryWeaponMenu;
		new g_hItemsMenu;

	/* Messages */
	
		new g_msgShowMenu;
		new g_msgVGUIMenu;
		new g_msgDeath;
		new g_msgScoreInfo;
		new g_msgStatusIcon;

	/* PCVARS */
	
		new g_pNightcrawlerRatio;
		new g_pNightcrawlerVisibleTime;
		new g_pNightcrawlerHealth;
		new g_pNightcrawlerGravity;
		new g_pNightcrawlerSpeed;
		new g_pNightcrawlerTeleDelay;
		new g_pNightcrawlerTeleCount;
		
		new g_pMapLighting;
		
		new g_pAdrenalineUses;
		new g_pAdrenalineTime;
		new g_pAdrenalineSpeed;
		
		new g_pMedKitUses;
		
		new g_pSuicideRadius;
		new g_pSuicideDamage;
		new g_pSuicideTime;
		
		new g_pPoisonAmount;
		new g_pPoisonInterval;
		new g_pPoisonDamage;
		
	public plugin_precache()
	{
		precache_model( g_szNCModel );
		precache_model( g_szNCKnife_V );
		
		precache_sound( g_szSuicideBombSound );
		precache_sound( g_szTeleportSound );
		
		g_iLaserSprite = precache_model( g_szLaserSprite );
		g_iExplosionSprite = precache_model( g_szExplosionSprite );
	}
	
	public plugin_init()
	{
		register_plugin( "Nightcrawler Mod", "1.0", "H3avY Ra1n" );
		
		register_clcmd( "jointeam", "CmdJoinTeam" );
		register_clcmd( "joinclass", "CmdJoinTeam" );
		register_clcmd( "say /guns", "CmdEnableGuns" );
		register_clcmd( "say_team /guns", "CmdEnableGuns" );
		register_clcmd( "item", "CmdUseItem" );
		
		RegisterHam( Ham_Spawn, "player", "Ham_PlayerSpawn_Post", 1 );
		RegisterHam( Ham_Killed, "player", "Ham_PlayerKilled_Post", 1 );
		RegisterHam( Ham_TakeDamage, "player", "Ham_PlayerTakeDamage_Post", 1 );
		
		register_forward( FM_Spawn, "Forward_Spawn_Post", 1 );
		register_forward( FM_Touch, "Forward_Touch_Pre", 0 );
		register_forward( FM_PlayerPreThink, "Forward_PlayerPreThink" );
		register_forward( FM_AddToFullPack, "Forward_AddToFullPack_Post", 1 );
		
		register_logevent( "LogEvent_BombSpawned", 3, "2=Spawned_With_The_Bomb" );
		register_logevent( "LogEvent_RoundEnd", 2, "1=Round_End" );
		
		register_event( "CurWeapon", "Event_CurWeapon", "be" );
		
		register_menucmd( register_menuid( "Team_Select", 1 ), ( 1 << 0 ) | ( 1 << 1 ) | ( 1 << 4 ) | ( 1 << 5 ), "TeamSelectMenu_Handler" );
			
		g_msgShowMenu 	= get_user_msgid( "ShowMenu" );
		g_msgVGUIMenu 	= get_user_msgid( "VGUIMenu" );
		g_msgScoreInfo 	= get_user_msgid( "ScoreInfo" );
		g_msgDeath		= get_user_msgid( "DeathMsg" );
		g_msgStatusIcon = get_user_msgid( "StatusIcon" );
		
		register_message( g_msgShowMenu, "Message_ShowMenu" );
		register_message( g_msgVGUIMenu, "Message_VGUIMenu" );
		register_message( g_msgStatusIcon, "Message_StatusIcon" );
		
		g_pNightcrawlerRatio		= register_cvar( "nc_ratio", "33" ); // Percentage
		g_pNightcrawlerVisibleTime	= register_cvar( "nc_visible_time", "2" );
		g_pNightcrawlerHealth		= register_cvar( "nc_health", "150" );
		g_pNightcrawlerGravity		= register_cvar( "nc_gravity", "600" );
		g_pNightcrawlerSpeed		= register_cvar( "nc_speed", "280.0" );
		g_pNightcrawlerTeleCount	= register_cvar( "nc_teleport_count", "2" );
		g_pNightcrawlerTeleDelay 	= register_cvar( "nc_teleport_delay", "2" );
		
		g_pMapLighting				= register_cvar( "nc_lighting", "g" );
		
		g_pAdrenalineUses			= register_cvar( "nc_adrenaline_uses", "2" );
		g_pAdrenalineTime			= register_cvar( "nc_adrenaline_time", "10" );
		g_pAdrenalineSpeed			= register_cvar( "nc_adrenaline_speed", "320" );
		
		g_pSuicideDamage 			= register_cvar( "nc_suicide_damage", "80" );
		g_pSuicideRadius			= register_cvar( "nc_suicide_radius", "50" );
		g_pSuicideTime				= register_cvar( "nc_suicide_time", "3" );
		
		g_pMedKitUses				= register_cvar( "nc_medkit_uses", "2" );
		
		g_pPoisonAmount				= register_cvar( "nc_poison_amount", "3" );
		g_pPoisonInterval			= register_cvar( "nc_poison_interval", "1" );
		g_pPoisonDamage				= register_cvar( "nc_poison_damage", "5" );
		
		g_iMaxPlayers 				= get_maxplayers();
		
		set_task( 30.0, "Task_StartGame", TASK_STARTGAME );
		
		CreateMenus();
	}

	public Message_StatusIcon( iMsgID, iMsgDest, id )
	{
		static szIcon[ 8 ];
		get_msg_arg_string( 2, szIcon, 7 );
		
		if( equal( szIcon, "buyzone" ) && get_msg_arg_int( 1 ) )
		{
			set_pdata_int( id, 235, get_pdata_int( id, 235 ) & ~(1<<0) );
			return PLUGIN_HANDLED;
		}
		
		return PLUGIN_CONTINUE;
	}
	
	public Forward_Spawn_Post( iEntity )
	{
		new szClassname[ 32 ];
		pev( iEntity, pev_classname, szClassname, charsmax( szClassname ) );
		
		for( new i = 0; i < sizeof g_szObjectives; i++ )
		{
			if( equali( szClassname, g_szObjectives[ i ] ) )
			{
				remove_entity( iEntity );
				break;
			}
		}
	}
	
			
	public Forward_Touch_Pre( iEnt, id )
	{
		if( !is_user_alive( id ) )
			return FMRES_IGNORED;
		
		new szClassname[ 32 ];
		pev( iEnt, pev_classname, szClassname, charsmax( szClassname ) );
		
		if( equali( szClassname, "worldspawn" ) || equali( szClassname, "func_wall" ) || equali( szClassname, "func_breakable" ) )
			pev( id, pev_origin, g_flWallOrigin[ id ] );
		
		else if( equali( szClassname, "weaponbox" ) || equali( szClassname, "armoury_entity" ) )
		{
			if( cs_get_user_team( id ) == TEAM_NC )
				return FMRES_SUPERCEDE;
		}
		
		return FMRES_IGNORED;
	}

	public client_putinserver( id )
	{
		g_bRememberGuns[ id ] = false;
		g_bNCNextRound[ id ] = false;
		g_bHasLaser[ id ] = false;
		g_bAdrenalineActive[ id ] = false;
		g_bVisible[ id ] = true;
		
		g_iAdrenalineUses[ id ] = 0;
		g_iMedKitUses[ id ] = 0;
		g_iSuicideTime[ id ] = 0;
		g_iPoisonRemaining[ id ] = 0;
		
		g_iPrimaryWeapon[ id ] = 0;
		g_iSecondaryWeapon[ id ] = 0;
		
		g_iTeleportsRemaining[ id ] = 0;
		
		g_iChosenItem[ id ] = -1;
		
		new szLighting[ 3 ];
		get_pcvar_string( g_pMapLighting, szLighting, 2 );
		
		engfunc( EngFunc_LightStyle, 0, szLighting );
	}

	public client_disconnect( id )
	{
		remove_task( TASK_SUICIDE + id );
	}
	
	public Forward_PlayerPreThink( id )
	{
		if( !is_user_alive( id ) )
			return;
		
		static CsTeams:iTeam;
		iTeam = cs_get_user_team( id );
		
		if( iTeam == TEAM_HUMAN )
		{
			if( !g_bHasLaser[ id ] )
			{
				static iPlayers[ 32 ], iNum;
				get_players( iPlayers, iNum, "ae", "CT" );
				
				if( iNum == 1 )
				{
					g_bHasLaser[ id ] = true;
				}
			}
			
			if( g_bHasLaser[ id ] )
			{

				static iTarget, iBody, iRed, iGreen, iBlue, iWeapon;
				
				get_user_aiming( id, iTarget, iBody );
			
				iWeapon = get_user_weapon( id );
			
				if( IsPrimaryWeapon( iWeapon ) || IsSecondaryWeapon( iWeapon ) )
				{
					if( is_user_alive( iTarget ) && cs_get_user_team( iTarget ) == TEAM_NC )
					{
						iRed = 255;
						iGreen = 0;
						iBlue = 0;
					}
					
					else
					{
						iRed = 0;
						iGreen = 255;
						iBlue = 0;
					}
					
					static iOrigin[ 3 ];
					get_user_origin( id, iOrigin, 3 );
					
					message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
					write_byte( TE_BEAMENTPOINT );
					write_short( id | 0x1000 );
					write_coord( iOrigin[ 0 ] );
					write_coord( iOrigin[ 1 ] );
					write_coord( iOrigin[ 2 ] );
					write_short( g_iLaserSprite );
					write_byte( 1 );
					write_byte( 10 );
					write_byte( 1 );
					write_byte( 5 );
					write_byte( 0 );
					write_byte( iRed );
					write_byte( iGreen );
					write_byte( iBlue );
					write_byte( 150 );
					write_byte( 25 );
					message_end( );
				}
			}
		}
		
		else if( iTeam == TEAM_NC )
		{
			static iButton;
			iButton = get_user_button( id );
			
			if( iButton & IN_USE )
			{
				static Float:fOrigin[ 3 ];
				pev( id, pev_origin, fOrigin );
				
				if( get_distance_f( fOrigin, g_flWallOrigin[ id ] ) > 10.0 )
					return;
				
				if( pev( id, pev_flags ) & FL_ONGROUND )
					return;
				
				if( iButton & IN_FORWARD )
				{
					static Float:fVelocity[ 3 ];
					velocity_by_aim( id, 240, fVelocity );
					
					set_pev( id, pev_velocity, fVelocity );
				}
				
				else if( iButton & IN_BACK )
				{
					static Float:fVelocity[ 3 ];
					velocity_by_aim( id, -240, fVelocity );
					
					set_pev( id, pev_velocity, fVelocity );
				}
			}
		}
		
		return;
	}

	public LogEvent_BombSpawned()
	{
		new szLogUser[ 80 ], szName[ 32 ];
		read_logargv( 0, szLogUser, 79 );
		parse_loguser( szLogUser, szName, 31 );
		
		new id = get_user_index( szName );
		
		engclient_cmd( id, "drop", "weapon_c4" );
		new iBomb = find_ent_by_class( -1, "weapon_c4" );
		
		if( iBomb )
		{
			remove_entity( iBomb );
		}
	}
	
	public LogEvent_RoundEnd()
	{
		g_iCurrentRound++;
	}

	////////////////////
	///*	Ratio	*///
	////////////////////

	public CmdJoinTeam( id )
		return PLUGIN_HANDLED;
		
	public TeamSelectMenu_Handler( id, iKey )
	{
		new CsTeams:iTeam = cs_get_user_team( id );
		
		CountTeams();

		switch( iKey )
		{
			case 0: // Join NC (Terrorists)
			{
				client_print( id, print_chat, "%s You cannot join the Night-Crawler team!", g_szPrefix );
				
				return PLUGIN_HANDLED;
			}
			
			case 1: // Join Humans (CTs)
			{
				if( iTeam == TEAM_HUMAN )
					return PLUGIN_HANDLED;
				
				if( task_exists( TASK_STARTGAME ) )
					ForceTeam( id, TEAM_HUMAN );
				
				else
				{
					CountTeams();
					
					// ( Percent * Total Players / 100 ) - Current Amount of NCs
					new iNeeded = get_pcvar_num( g_pNightcrawlerRatio ) * ( g_iTeamCount[ TEAM_NC ] + g_iTeamCount[ TEAM_HUMAN ] ) / 100 - g_iTeamCount[ TEAM_NC ];
					
					if( iNeeded == 0 && g_iTeamCount[ TEAM_HUMAN ] == 1 )
						iNeeded = 1;
						
					if( iNeeded >= 1 )
						ForceTeam( id, TEAM_NC );
					
					else ForceTeam( id, TEAM_HUMAN );
				
				}
				
				return PLUGIN_HANDLED;
			}
			
			case 5:
			{
				user_silentkill( id );
				ForceTeam( id, CS_TEAM_SPECTATOR );
				
				return PLUGIN_HANDLED;
			}
		}
		
		return PLUGIN_HANDLED;
	}

	public ForceTeam( id, CsTeams:iTeam )
	{
		static iRestore, iVGUI, iMSGBlock;

		iRestore = get_pdata_int( id, m_iVGUI );
		iVGUI = iRestore & ( 1 << 0 );
		if( iVGUI )
			set_pdata_int( id, m_iVGUI, iRestore & ~( 1 << 0 ) );

		switch( iTeam )
		{
			case CS_TEAM_SPECTATOR:
			{
				iMSGBlock = get_msg_block( g_msgShowMenu );
				set_msg_block( g_msgShowMenu, BLOCK_ONCE );
				dllfunc( DLLFunc_ClientPutInServer, id );
				set_msg_block( g_msgShowMenu, iMSGBlock );
				set_pdata_int( id, m_fGameHUDInitialized, 1 );
				engclient_cmd( id, "jointeam", "6" );
			}
			case CS_TEAM_T, CS_TEAM_CT:
			{
				iMSGBlock = get_msg_block( g_msgShowMenu );
				set_msg_block( g_msgShowMenu, BLOCK_ONCE );
				engclient_cmd( id, "jointeam", ( iTeam == CS_TEAM_CT ) ? "2" : "1" );
				engclient_cmd( id, "joinclass", "1" );
				set_msg_block( g_msgShowMenu, iMSGBlock );
			}
		}
		
		if( iVGUI )
			set_pdata_int( id, m_iVGUI, iRestore );
	}

	public Message_VGUIMenu( iMSGId, iDest, id )
	{
		static iMSGArg1;

		iMSGArg1 = get_msg_arg_int( 1 );
		
		if( iMSGArg1 == 2 )
		{
			show_menu( id, 51, TEAM_MENU2, -1 );
			return PLUGIN_HANDLED;
		}

		return PLUGIN_CONTINUE;
	}

	public Message_ShowMenu( iMSGId, iDest, id )
	{
		static iMSGArg1;
		iMSGArg1 = get_msg_arg_int( 1 );

		if( iMSGArg1 != 531 && iMSGArg1 != 563 )
			return PLUGIN_CONTINUE;

		show_menu( id, 51, TEAM_MENU2, -1 );
		return PLUGIN_HANDLED;
	}
		
	public Event_CurWeapon( id )
	{
		new iWeapon = read_data( 2 );
		switch( cs_get_user_team( id ) )
		{
			case TEAM_HUMAN:
			{
				if( IsPrimaryWeapon( iWeapon ) || IsSecondaryWeapon( iWeapon ) )
				{
					if( cs_get_user_bpammo( id, iWeapon ) != g_iMaxBPAmmo[ iWeapon ] )
					{
						cs_set_user_bpammo( id, iWeapon, g_iMaxBPAmmo[ iWeapon ] );
					}
					
					if( g_bAdrenalineActive[ id ] )
					{
						new iEnt = find_ent_by_owner( -1, g_szWeaponClassnames[ iWeapon ], id );
						
						if( !pev_valid( iEnt ) )
							return;
						
						cs_set_weapon_ammo( iEnt, g_iMaxClipAmmo[ iWeapon ] );
					}
				}
				
				if( g_bAdrenalineActive[ id ] )
				{
					set_user_maxspeed( id, get_pcvar_float( g_pAdrenalineSpeed ) );
				}
			}
			
			case TEAM_NC:
			{
				if( iWeapon == CSW_KNIFE )
				{
					set_pev( id, pev_viewmodel2, g_szNCKnife_V );
				}
			}
		}
	}

	public CreateMenus()
	{
		g_hWeaponMenu = menu_create( "Weapons Menu", "WeaponMenu_Handler" );
		menu_additem( g_hWeaponMenu, "New Weapons", "0" );
		menu_additem( g_hWeaponMenu, "Previous Weapons", "1" );
		menu_additem( g_hWeaponMenu, "2 + Don't Ask Again", "2" );
		
		g_hPrimaryWeaponMenu = menu_create( "Primary Weapons", "PrimaryMenu_Handler" );
		g_hSecondaryWeaponMenu = menu_create( "Secondary Weapons", "SecondaryMenu_Handler" );
		
		new szInfo[ 3 ];
		for( new i = MIN_WEAPON; i <= MAX_WEAPON; i++ )
		{
			if( IsPrimaryWeapon( i ) )
			{
				num_to_str( i, szInfo, charsmax( szInfo ) );
				menu_additem( g_hPrimaryWeaponMenu, g_szWeaponNames[ i ], szInfo );
			}
			
			else if( IsSecondaryWeapon( i ) )
			{
				num_to_str( i, szInfo, charsmax( szInfo ) );
				menu_additem( g_hSecondaryWeaponMenu, g_szWeaponNames[ i ], szInfo );
			}
			
			else continue;
		}
		
		g_hItemsMenu = menu_create( "Choose an Item:", "ItemsMenu_Handler" );
		
		for( new i = 0; i < ItemsInfo; i++ )
		{
			num_to_str( i, szInfo, charsmax( szInfo ) );
			
			if( i == ITEM_LASER )
			{
				menu_additem( g_hItemsMenu, g_szItemNames[ i ], szInfo, _, menu_makecallback( "LaserItem_Callback" ) );
			}
			
			else menu_additem( g_hItemsMenu, g_szItemNames[ i ], szInfo );
		}
	}	
	
	public LaserItem_Callback( id, hMenu, iItem )
	{
		if( g_iCurrentRound == 0 )
			return ITEM_DISABLED;
			
		new iFrags = get_user_frags( id );
		new iDeaths = get_user_deaths( id );

		new iPlayerFrags;
		
		new iPlayers[ 32 ], iNum;
		get_players( iPlayers, iNum, "ae", "CT" );
		
		for( new i = 0, iPlayer; i < iNum; i++ )
		{
			iPlayer = iPlayers[ i ];
			
			if( !is_user_alive( iPlayer ) || iPlayer == id )
				continue;
				
			iPlayerFrags = get_user_frags( iPlayer );
			
			if( iPlayerFrags > iFrags )
				return ITEM_DISABLED;
				
			else if( iPlayerFrags == iFrags )
			{
				if( get_user_deaths( iPlayer ) < iDeaths )
					return ITEM_DISABLED;
			}
		}
		
		return ITEM_ENABLED;
		
	}

	public Ham_PlayerSpawn_Post( id )
	{
		if( !is_user_alive( id ) )
			return HAM_IGNORED;
		
		strip_user_weapons( id );
		give_item( id, "weapon_knife" );
		
		new CsTeams:iTeam = cs_get_user_team( id );
		
		if( g_bNCNextRound[ id ] )
		{
			if( iTeam != TEAM_NC )
			{
				cs_set_user_team( id, TEAM_NC );
				ExecuteHamB( Ham_CS_RoundRespawn, id );
				g_bNCNextRound[ id ] = false;
				return HAM_IGNORED;
			}
			
			g_bNCNextRound[ id ] = false;
		}
		
		switch( iTeam )
		{
			case TEAM_NC:
			{
				cs_set_user_model( id, "nightcrawler" );
				
				if( get_user_weapon( id ) == CSW_KNIFE )
					set_pev( id, pev_viewmodel2, g_szNCKnife_V );
					
				client_print( id, print_chat, "%s You are now invisible.", g_szPrefix );
				
				set_user_health( id, get_pcvar_num( g_pNightcrawlerHealth ) );
				set_user_gravity( id, get_pcvar_float( g_pNightcrawlerGravity ) / 800 );
				set_user_maxspeed( id, get_pcvar_float( g_pNightcrawlerSpeed ) );
				
				set_user_footsteps( id, 1 );
				
				g_iTeleportsRemaining[ id ] = get_pcvar_num( g_pNightcrawlerTeleCount );
				
				g_bVisible[ id ] = false;
			}
			
			case TEAM_HUMAN:
			{
				if( g_bRememberGuns[ id ] )
					GiveWeapons( id );
				
				else if( g_iPrimaryWeapon[ id ] == 0 || g_iSecondaryWeapon[ id ] == 0 )
				{
					menu_display( id, g_hPrimaryWeaponMenu );
				}
				
				else menu_display( id, g_hWeaponMenu );
				
				set_user_footsteps( id, 0 );
				
				cs_set_user_model( id, "gign" );
				
				g_bVisible[ id ] = true;
			}
		}
		
		g_bNCNextRound[ id ] = false;
		
		return HAM_IGNORED;
	}

	public Ham_PlayerKilled_Post( iVictim, iKiller, iShouldGib )
	{
		if( !is_user_alive( iKiller ) )
			return HAM_IGNORED;
		
		switch( cs_get_user_team( iKiller ) )
		{
			case TEAM_HUMAN:
			{
				if( cs_get_user_team( iVictim ) == TEAM_NC )
				{
					client_print( iVictim, print_chat, "%s You were killed by a human and are now one also!", g_szPrefix );
					cs_set_user_team( iVictim, TEAM_HUMAN );
					
					if( !g_bNCNextRound[ iKiller ] )
					{
						client_print( iKiller, print_chat, "%s You killed a Night-Crawler and will be one next round!", g_szPrefix );
						g_bNCNextRound[ iKiller ] = true;
					}
				}
			}
			
			case TEAM_NC:
			{
				if( cs_get_user_team( iVictim ) == TEAM_HUMAN )
				{
					client_print( iKiller, print_chat, "%s You killed a human!", g_szPrefix );
					client_print( iVictim, print_chat, "%s You were killed by a Night-Crawler!", g_szPrefix );
				}
			}
		}
		
		return HAM_IGNORED;
	}

	public Ham_PlayerTakeDamage_Post( iVictim, iInflictor, iAttacker, Float:flDamage, iBits )
	{
		if( is_user_connected( iAttacker ) && cs_get_user_team( iVictim ) == TEAM_NC )
		{
			remove_task( TASK_INVISIBLE + iVictim );
			
			g_bVisible[ iVictim ] = true;
			
			set_task( get_pcvar_float( g_pNightcrawlerVisibleTime ), "Task_SetInvisible", iVictim + TASK_INVISIBLE );
			
			if( g_iChosenItem[ iAttacker ] == ITEM_POISON && iInflictor == CSW_SCOUT )
			{
				g_iPoisonRemaining[ iVictim ] = get_pcvar_num( g_pPoisonAmount );
				
				remove_task( TASK_POISON + iVictim );
				
				new szParams[ 2 ];
				szParams[ 0 ] = iAttacker;
				set_task( get_pcvar_float( g_pPoisonInterval ), "Task_Poison", TASK_POISON + iVictim, szParams, 2 );
			}
		}
	}
	
	public Task_Poison( szParams[ ], iTaskID )
	{
		new iAttacker = szParams[ 0 ];
		
		new id = iTaskID - TASK_POISON;
		
		ExecuteHam( Ham_TakeDamage, id, iAttacker, iAttacker, get_pcvar_float( g_pPoisonDamage ), DMG_GENERIC );
		
		if( --g_iPoisonRemaining[ id ] > 0 )
		{
			set_task( get_pcvar_float( g_pPoisonInterval ), "Task_PoisonHurt", iTaskID );
		}
	}
	
	public GiveWeapons( id )
	{
		new iPrimary = g_iPrimaryWeapon[ id ];
		new iSecondary = g_iSecondaryWeapon[ id ];
		
		give_item( id, g_szWeaponClassnames[ iPrimary ] );
		give_item( id, g_szWeaponClassnames[ iSecondary ] );
		
		cs_set_user_bpammo( id, iPrimary, g_iMaxBPAmmo[ iPrimary ] );
		cs_set_user_bpammo( id, iSecondary, g_iMaxBPAmmo[ iSecondary ] );
	}

	public WeaponMenu_Handler( id, hMenu, iItem )
	{
		switch( iItem )
		{
			case 0: menu_display( id, g_hPrimaryWeaponMenu, 0 );
			case 1: 
			{
				GiveWeapons( id );
				menu_display( id, g_hItemsMenu, 0 );
			}
			
			case 2: 
			{
				GiveWeapons( id );
				g_bRememberGuns[ id ] = true;
				
				menu_display( id, g_hItemsMenu, 0 );
			}
		}
	}

	public PrimaryMenu_Handler( id, hMenu, iItem )
	{
		if( iItem == MENU_EXIT )
		{
			menu_display( id, g_hItemsMenu, 0 );
			return PLUGIN_HANDLED;
		}
		
		new iAccess, hCallback;
		new szData[ 6 ];
		
		menu_item_getinfo( hMenu, iItem, iAccess, szData, charsmax( szData ), _, _, hCallback );
		
		g_iPrimaryWeapon[ id ] = str_to_num( szData );

		menu_display( id, g_hSecondaryWeaponMenu, 0 );
		
		return PLUGIN_HANDLED;
	}

	public SecondaryMenu_Handler( id, hMenu, iItem )
	{
		if( iItem == MENU_EXIT )
		{
			menu_display( id, g_hItemsMenu, 0 );
			return PLUGIN_HANDLED;
		}
		
		new iAccess, hCallback;
		new szData[ 6 ];
		
		menu_item_getinfo( hMenu, iItem, iAccess, szData, charsmax( szData ), _, _, hCallback );
		
		g_iSecondaryWeapon[ id ] = str_to_num( szData );

		GiveWeapons( id );
		
		menu_display( id, g_hItemsMenu, 0 );
		
		return PLUGIN_HANDLED;
	}

	public ItemsMenu_Handler( id, hMenu, iItem )
	{
		g_iChosenItem[ id ] = iItem;
		
		switch( iItem )
		{
			case ITEM_LASER:
			{
				g_bHasLaser[ id ] = true;
			}
			
			case ITEM_ADRENALINE:
			{
				client_print( id, print_chat, "%s Bind a key to 'item' to inject adrenaline.", g_szPrefix );
				
				g_iAdrenalineUses[ id ] = get_pcvar_num( g_pAdrenalineUses );
			}
			
			case ITEM_MEDKIT:
			{
				client_print( id, print_chat, "%s Bind a key to 'item' to use a medical kit.", g_szPrefix );
				
				g_iMedKitUses[ id ] = get_pcvar_num( g_pMedKitUses );
			}
			
			case ITEM_SUICIDE:
			{
				client_print( id, print_chat, "%s Bind a key to 'item' to start the countdown.", g_szPrefix );
			}
			
			case ITEM_POISON:
			{
				client_print( id, print_chat, "%s All bullets fired with a scout will be poisonous.", g_szPrefix );
			}
		}
		
		return PLUGIN_HANDLED;
	}
	
	public Task_StartGame()
	{
		new iPlayers[ 32 ], iNum;
		get_players( iPlayers, iNum );
		
		new iNCAmount = ( get_pcvar_num( g_pNightcrawlerRatio ) * iNum ) / 100 - g_iTeamCount[ TEAM_NC ];
		
		if( iNCAmount == 0 && iNum > 1 )
			iNCAmount = 1;
		
		new iRandom;
		
		for( new i = 0; i < iNCAmount; i++ )
		{
			iRandom = random( iNum );			
			cs_set_user_team( iPlayers[ iRandom ], TEAM_NC );
			iPlayers[ iRandom ] = iPlayers[ --iNum ];
		}
		
		server_cmd( "sv_restartround 1 " );
	}
	
	public CmdEnableGuns( id )
	{
		if( g_bRememberGuns[ id ] )
		{
			client_print( id, print_chat, "%s Your gun menu has been re-enabled.", g_szPrefix );
			g_bRememberGuns[ id ] = false;
		}
		
		else
			client_print( id, print_chat, "%s Your gun menu is already enabled!", g_szPrefix );
	}
	
	public CmdUseItem( id )
	{
		switch( cs_get_user_team( id ) )
		{
			case TEAM_NC:
			{
				if( g_iTeleportsRemaining[ id ] > 0 )
				{
					new Float:flGameTime = get_gametime();
					
					new iDelay = get_pcvar_num( g_pNightcrawlerTeleDelay );
					
					if( flGameTime - g_flLastTeleportTime[ id ] < iDelay )
					{
						client_print( id, print_chat, "%s You must wait %i seconds inbetween teleports.", g_szPrefix, iDelay );
						return;
					}
					
					else if( TeleportPlayer( id ) )
					{
						g_iTeleportsRemaining[ id ]--;
						g_flLastTeleportTime[ id ] = get_gametime();
					
					}
				}
			}
			
			case TEAM_HUMAN:
			{
				switch( g_iChosenItem[ id ] )
				{
					case ITEM_ADRENALINE:
					{
						if( g_bAdrenalineActive[ id ] )
						{
							client_print( id, print_chat, "%s Adrenaline is already active!", g_szPrefix );
						}
						
						else if( g_iAdrenalineUses[ id ] > 0 )
						{
							g_iAdrenalineUses[ id ]--;
							client_print( id, print_chat, "%s You have injected adrenaline!", g_szPrefix );
							
							g_bAdrenalineActive[ id ] = true;
							
							set_user_maxspeed( id, get_pcvar_float( g_pAdrenalineSpeed ) );
							
							set_task( get_pcvar_float( g_pAdrenalineTime ), "Task_RemoveAdrenaline", TASK_ADRENALINE + id );
						}
					}
					
					case ITEM_MEDKIT:
					{
						if( g_iMedKitUses[ id ] > 0 )
						{
							g_iMedKitUses[ id ]--;
							client_print( id, print_chat, "%s You have used one of your medical kits. You have %i more.", g_szPrefix, g_iMedKitUses[ id ] );
							
							set_user_health( id, 100 );
						}
					}
					
					case ITEM_SUICIDE:
					{
						if( task_exists( TASK_SUICIDE + id ) )
							return;
							
						g_iSuicideTime[ id ] = get_pcvar_num( g_pSuicideTime );
						
						Task_Suicide( TASK_SUICIDE + id );
						
						set_task( 1.0, "Task_Suicide", TASK_SUICIDE + id, .flags="a", .repeat=g_iSuicideTime[ id ] );
						
					}
				}
			}
		}
	}
	
	public Task_SetInvisible( iTaskID )
	{
		new id = iTaskID - TASK_INVISIBLE;
		
		g_bVisible[ id ] = false;
	}
	
	public Task_Suicide( iTaskID )
	{
		new id = iTaskID - TASK_SUICIDE;

		if( --g_iSuicideTime[ id ] == 0 )
		{
			new Float:flOrigin[ 3 ];
			pev( id, pev_origin, flOrigin );
		
			user_kill( id );
			
			message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
			write_byte( TE_EXPLOSION );
			write_coord( floatround( flOrigin[ 0 ] ) );
			write_coord( floatround( flOrigin[ 1 ] ) );
			write_coord( floatround( flOrigin[ 2 ] ) );
			write_short( g_iExplosionSprite );
			write_byte( 30 );
			write_byte( 30 );
			write_byte( 0 );
			message_end();
			
			fm_radius_damage( id, flOrigin, get_pcvar_float( g_pSuicideDamage ), get_pcvar_float( g_pSuicideRadius ) );
		}
		
		else emit_sound( id, CHAN_ITEM, g_szSuicideBombSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	}
	
	// Taken from Jailbreak Mod by Pastout.
	stock fm_radius_damage( id, Float:flOrigin[ 3 ], Float:flDamage, Float:flRadius )
	{
		new szClassname[ 33 ], CsTeams:iTeam;
		
		iTeam = cs_get_user_team( id );
		
		static iEnt;
		iEnt = -1;
		while( ( iEnt = engfunc( EngFunc_FindEntityInSphere, iEnt, flOrigin, flRadius ) ) )
		{
			pev( iEnt, pev_classname, szClassname, charsmax( szClassname ) );
			
			if( !equali( szClassname, "player" ) || !is_user_alive( iEnt ) || cs_get_user_team( iEnt ) == iTeam )
				continue;
			
			ExecuteHamB( Ham_TakeDamage, iEnt, 0, id, flDamage, DMG_GENERIC );
		}
	}
	
	// Taken from Jailbreak Mod by Pastout
	stock createKill(id, attacker, weaponDescription[]) 
	{
		new iFrags, iFrags2;
		
		if(id != attacker) 
		{
			iFrags = get_user_frags(attacker);
			set_user_frags(attacker, iFrags + 1);
			   
			//Kill the victim and block the messages
			set_msg_block(g_msgDeath,BLOCK_ONCE);
			set_msg_block(g_msgScoreInfo,BLOCK_ONCE);
			user_kill(id);
			  
			//user_kill removes a frag, this gives it back
			iFrags2 = get_user_frags(id);
			set_user_frags(id, iFrags2 + 1);
			  
			//Replaced HUD death message
			message_begin(MSG_ALL, g_msgDeath,{0,0,0},0);
			write_byte(attacker);
			write_byte(id);
			write_byte(0);
			write_string(weaponDescription);
			message_end();
			  
			//Update killers scorboard with new info
			message_begin(MSG_ALL, g_msgScoreInfo);
			write_byte(attacker);
			write_short(iFrags);
			write_short(get_user_deaths(attacker));
			write_short(0);
			write_short(get_user_team(attacker));
			message_end();
			  
			//Update victims scoreboard with correct info
			message_begin(MSG_ALL, g_msgScoreInfo);
			write_byte(id);
			write_short(iFrags2);
			write_short(get_user_deaths(id));
			write_short(0);
			write_short(get_user_team(id));
			message_end();
			
			new szName[32], szName1[32];
			get_user_name(id, szName, 31);
			get_user_name(attacker, szName1, 31);
		}
	}
			
	public Task_RemoveAdrenaline( iTaskID )
	{
		new id = iTaskID - TASK_ADRENALINE;
		
		g_bAdrenalineActive[ id ] = false;
		
		if( is_user_alive( id ) )
			set_user_maxspeed( id, 0.0 );
	}
	
	public Forward_AddToFullPack_Post( es, e, iEntity, iHost, iHostFlags, iPlayer, pSet )
	{
		if( is_user_alive( iEntity ) && is_user_alive( iHost ) && cs_get_user_team( iEntity ) == TEAM_NC && cs_get_user_team( iHost ) == TEAM_HUMAN )
		{
			set_es( es, ES_RenderMode, kRenderTransAdd );
			
			if( g_bVisible[ iEntity ] )
				set_es( es, ES_RenderAmt, 255 );
				
			else set_es( es, ES_RenderAmt, 0 );
		}
	}

	CountTeams()
	{
		for( new i = 1; i <= g_iMaxPlayers; i++ )
		{
			if( !is_user_connected( i ) )
				continue;
			
			g_iTeamCount[ cs_get_user_team( i ) ]++;
		}
	}
	
	// Credits to NiHiLaNTh
	TeleportPlayer( iPlayer )
	{
		new Float:vOrigin[ 3 ], Float:vViewOfs[ 3 ];
		pev( iPlayer, pev_origin, vOrigin );
		pev( iPlayer, pev_view_ofs, vViewOfs );
		
		xs_vec_add( vOrigin, vViewOfs, vOrigin );
		
		new Float:vViewAngle[ 3 ];
		pev( iPlayer, pev_v_angle, vViewAngle );
		
		new Float:vAimVector[ 3 ];
		angle_vector( vViewAngle, ANGLEVECTOR_FORWARD, vAimVector );
		xs_vec_normalize( vAimVector, vAimVector );
		xs_vec_mul_scalar( vAimVector, 9999.0, vAimVector );
		
		engfunc( EngFunc_TraceLine, vOrigin, vAimVector, 0, iPlayer, 0 );
		
		get_tr2( 0, TR_vecEndPos, vAimVector );
		get_tr2( 0, TR_vecPlaneNormal, vOrigin );
		
		xs_vec_normalize( vOrigin, vOrigin );
		xs_vec_mul_scalar( vOrigin, 36.0, vOrigin );
		xs_vec_add( vAimVector, vOrigin, vOrigin );
		
		new bool:bDucking = false;
		
		if( trace_hull( vOrigin, HULL_HUMAN, iPlayer ) )
		{
			if( !trace_hull( vOrigin, HULL_HEAD, iPlayer ) )
			{
				bDucking = true;
			}
			else
			{
				// player cannot duck or stand clearly, so try to move the origin so player can
				
				new iResetCount;
				
				test_new_origin:
				
				if( ++iResetCount > 4 )
				{
					// too many tries to find a good origin. just set to fail.
					
					client_print( iPlayer, print_center, "You cannot teleport there! You will be stuck!" );
					
					return 0;
				}
				
				for( new i = 0; i < 6; i++ )
				{
					switch( i )
					{
						case 0:
						{
							// check above x
							
							xs_vec_copy( vOrigin, vViewOfs );
							vViewOfs[ 0 ] += 16.0;
							
							engfunc( EngFunc_TraceLine, vOrigin, vViewOfs, 0, iPlayer, 0 );
							
							get_tr2( 0, TR_flFraction, vViewOfs[ 0 ] );
							
							if( vViewOfs[ 0 ] != 1.0 )
							{
								get_tr2( 0, TR_vecEndPos, vViewOfs );
								
								vOrigin[ 0 ] = vViewOfs[ 0 ] - 16.0;
								
								goto test_new_origin;
							}
						}
						case 1:
						{
							// check below x
							
							xs_vec_copy( vOrigin, vViewOfs );
							vViewOfs[ 0 ] -= 16.0;
							
							engfunc( EngFunc_TraceLine, vOrigin, vViewOfs, 0, iPlayer, 0 );
							
							get_tr2( 0, TR_flFraction, vViewOfs[ 0 ] );
							
							if( vViewOfs[ 0 ] != 1.0 )
							{
								get_tr2( 0, TR_vecEndPos, vViewOfs );
								
								vOrigin[ 0 ] = vViewOfs[ 0 ] + 16.0;
								
								goto test_new_origin;
							}
						}
						case 2:
						{
							// check above y
							
							xs_vec_copy( vOrigin, vViewOfs );
							vViewOfs[ 1 ] += 16.0;
							
							engfunc( EngFunc_TraceLine, vOrigin, vViewOfs, 0, iPlayer, 0 );
							
							get_tr2( 0, TR_flFraction, vViewOfs[ 0 ] );
							
							if( vViewOfs[ 0 ] != 1.0 )
							{
								get_tr2( 0, TR_vecEndPos, vViewOfs );
								
								vOrigin[ 1 ] = vViewOfs[ 1 ] - 16.0;
								
								goto test_new_origin;
							}
						}
						case 3:
						{
							// check below y
							
							xs_vec_copy( vOrigin, vViewOfs );
							vViewOfs[ 1 ] -= 16.0;
							
							engfunc( EngFunc_TraceLine, vOrigin, vViewOfs, 0, iPlayer, 0 );
							
							get_tr2( 0, TR_flFraction, vViewOfs[ 0 ] );
							
							if( vViewOfs[ 0 ] != 1.0 )
							{
								get_tr2( 0, TR_vecEndPos, vViewOfs );
								
								vOrigin[ 1 ] = vViewOfs[ 1 ] + 16.0;
								
								goto test_new_origin;
							}
						}
						case 4:
						{
							// check above z
							
							xs_vec_copy( vOrigin, vViewOfs );
							vViewOfs[ 2 ] += 36.0;
							
							engfunc( EngFunc_TraceLine, vOrigin, vViewOfs, 0, iPlayer, 0 );
							
							get_tr2( 0, TR_flFraction, vViewOfs[ 0 ] );
							
							if( vViewOfs[ 0 ] != 1.0 )
							{
								xs_vec_copy( vOrigin, vViewOfs );
								vViewOfs[ 2 ] += 18.0;
								
								engfunc( EngFunc_TraceLine, vOrigin, vViewOfs, 0, iPlayer, 0 );
								
								get_tr2( 0, TR_flFraction, vViewOfs[ 0 ] );
								
								if( vViewOfs[ 0 ] != 1.0 )
								{
									get_tr2( 0, TR_vecEndPos, vViewOfs );
									
									vOrigin[ 2 ] = vViewOfs[ 2 ] - 36.0;
									
									goto test_new_origin;
								}
								
								bDucking = true;
							}
						}
						case 5:
						{
							// check below z
							
							xs_vec_copy( vOrigin, vViewOfs );
							vViewOfs[ 2 ] -= 36.0;
							
							engfunc( EngFunc_TraceLine, vOrigin, vViewOfs, 0, iPlayer, 0 );
							
							get_tr2( 0, TR_flFraction, vViewOfs[ 0 ] );
							
							if( vViewOfs[ 0 ] != 1.0 )
							{
								xs_vec_copy( vOrigin, vViewOfs );
								vViewOfs[ 2 ] -= 18.0;
								
								engfunc( EngFunc_TraceLine, vOrigin, vViewOfs, 0, iPlayer, 0 );
								
								get_tr2( 0, TR_flFraction, vViewOfs[ 0 ] );
								
								if( vViewOfs[ 0 ] != 1.0 )
								{
									get_tr2( 0, TR_vecEndPos, vViewOfs );
									
									vOrigin[ 2 ] = vViewOfs[ 2 ] + 36.0;
									
									goto test_new_origin;
								}
								
								bDucking = true;
							}
						}
					}
				}
			}
		}
		
		if( engfunc( EngFunc_PointContents, vOrigin ) != CONTENTS_EMPTY )
		{
			client_print( iPlayer, print_center, "You can't teleport there!" );
			
			return 0;
		}
		
		if( bDucking )
		{
			set_pev( iPlayer, pev_flags, pev( iPlayer, pev_flags ) | FL_DUCKING );
			engfunc( EngFunc_SetSize, iPlayer, Float:{ -16.0, -16.0, -18.0 }, Float:{ 16.0, 16.0, 18.0 } );
		}
		
		engfunc( EngFunc_SetOrigin, iPlayer, vOrigin );
		
		return 1;
	}
