
#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

const MaxSlots = 32;

new g_bHasTimer[ MaxSlots+1 ];
new g_iMinutes[ MaxSlots+1 ];
new g_iSeconds[ MaxSlots+1 ];
new g_bStarted[ MaxSlots+1 ];

new Trie:g_tStartTargets;
new Trie:g_tFinishTargets;

new g_pCvarAutoEnable;

new g_iMaxPlayers;

new g_iTimerEnt;

public plugin_init( )
{
	register_plugin( "[KZ] Simple Timer", "0.1.1", "shupiro" );
	
	register_clcmd( "say /timer", "ClCmd_Timer" );
	register_clcmd( "say_team /timer", "ClCmd_Timer" );
	
	new szMapName[ 21 ];
	get_mapname( szMapName, charsmax( szMapName ) );
	
	if ( equali( szMapName, "kz_a2_bhop_corruo_ez" ) || equali( szMapName, "kz_a2_bhop_corruo_h" ) || equali( szMapName, "kz_a2_godspeed" ) )
	{
		RegisterHam( Ham_Touch, "func_button", "Fwd_TouchButton_Pre", 0 );
	}
	else if ( equali( szMapName, "kz_man_climbrace" ) )
	{
		RegisterHam( Ham_Think, "func_breakable", "Fwd_BreakableThink_Pre", 0 );
		RegisterHam( Ham_Touch, "trigger_multiple", "Fwd_MultipleTouch_Pre", 0 );
	}
	else
	{
		RegisterHam( Ham_Use, "func_button", "Fwd_UseButton_Pre", 0 );
	}
	
	g_tStartTargets = TrieCreate( );
	g_tFinishTargets = TrieCreate( );
	
	new i;
	
	new szStartTargets[ ][ ] =
	{
		"counter_start",
		"clockstartbutton",
		"firsttimerelay",
		"but_start",
		"counter_start_button",
		"multi_start",
		"timer_startbutton",
		"start_timer_emi",
		"gogogo" 
	}
	
	for ( i = 0; i < sizeof( szStartTargets ); i++ )
	{
		TrieSetCell( g_tStartTargets, szStartTargets[ i ], i );
	}
	
	new szFinishTargets[ ][ ] =
	{
		"counter_off",
		"clockstopbutton",
		"clockstop",
		"but_stop",
		"counter_stop_button",
		"multi_stop",
		"stop_counter",
		"m_counter_end_emi" 
	}
	
	for ( i = 0; i < sizeof( szFinishTargets ); i++ )
	{
		TrieSetCell( g_tFinishTargets, szFinishTargets[ i ], i );
	}
	
	g_pCvarAutoEnable = register_cvar( "kz_timer_autoenable", "1" );
	
	register_forward( FM_Think, "Fwd_Think_Pre", 0 );
	
	g_iTimerEnt = create_entity( "info_target" );
	set_pev( g_iTimerEnt, pev_classname, "timer_think" );
	set_pev( g_iTimerEnt, pev_nextthink, get_gametime() + 1.0 );
	
	g_iMaxPlayers = get_maxplayers( );
}

public client_disconnect( id )
{
	g_iMinutes[ id ] = 0;
	g_iSeconds[ id ] = -1;
	g_bHasTimer[ id ] = false;
	g_bStarted[ id ] = false;
}

public Fwd_TouchButton_Pre( iEnt, id )
{
	if ( is_user_alive( id ) )
	{
		new szTarget[ 32 ];
		pev( iEnt, pev_target, szTarget, charsmax( szTarget ) );
		
		if ( equal( szTarget, "gogogo" ) )
		{
			TimerStart( id );
		}
		else if ( equal( szTarget, "stop_counter" ) )
		{
			TimerStop( id );
		}
	}
}

public Fwd_BreakableThink_Pre( iEnt )
{
	new bAutoEnable = get_pcvar_num( g_pCvarAutoEnable );
	
	for ( new id = 1; id <= g_iMaxPlayers; id++ )
	{
		g_bStarted[ id ] = true;
		
		if ( bAutoEnable )
		{
			g_bHasTimer[ id ] = true;
		}
	}
}

public Fwd_MultipleTouch_Pre( iEnt, id )
{
	if ( is_user_alive( id ) )
	{
		TimerStop( id );
	}
}

public Fwd_UseButton_Pre( iEnt, id )
{
	if ( is_user_alive( id ) )
	{
		new szTarget[ 32 ];
		pev( iEnt, pev_target, szTarget, charsmax( szTarget ) );
		
		if ( TrieKeyExists( g_tStartTargets, szTarget ) )
		{
			TimerStart( id );
		}
		else if ( TrieKeyExists( g_tFinishTargets, szTarget ) )
		{
			TimerStop( id );
		}
	}
}

public ClCmd_Timer( id )
{
	g_bHasTimer[ id ] = g_bHasTimer[ id ] ? false : true;
	
	client_print( id, print_chat, "[AMXX] You have %sabled your timer.", g_bHasTimer[ id ] ? "en" : "dis" );
}

public Fwd_Think_Pre( iEnt )
{
	if ( iEnt == g_iTimerEnt )
	{
		static id;
		static iPlayer;
		for ( id = 1; id <= g_iMaxPlayers; id++ )
		{
			if ( g_bStarted[ id ] )
			{
				iPlayer = pev( id, pev_iuser1 ) == 4 ? pev( id, pev_iuser2 ) : id;
				
				if ( ++g_iSeconds[ iPlayer ] >= 60 )
				{
					g_iMinutes[ iPlayer ]++;
					g_iSeconds[ iPlayer ] = 0;
				}
				
				if ( g_bHasTimer[ iPlayer ] )
				{
					client_print( iPlayer, print_center, "%s%d:%s%d", g_iMinutes[ iPlayer ]<10?"0":"",g_iMinutes[ iPlayer ], g_iSeconds[ iPlayer ] < 10 ? "0" : "", g_iSeconds[ iPlayer ] );
				}
			}
		}
		
		set_pev( iEnt, pev_nextthink, get_gametime() + 1.0 );
	}
}

TimerStart( id )
{
	g_iMinutes[ id ] = 0;
	g_iSeconds[ id ] = -1;
				
	if ( get_pcvar_num( g_pCvarAutoEnable ) )
	{
		g_bHasTimer[ id ] = true;
	}
	
	g_bStarted[ id ] = true;
}

TimerStop( id )
{
	new name[32]
	get_user_name(id,name,charsmax(name))
	g_bStarted[ id ] = false;
	
	if ( g_bHasTimer[ id ] )
	{
		client_print( 0, print_chat, "Congratulations! %s finished the map in %s%d:%s%d",name, g_iMinutes[ id ]<10?"0":"",g_iMinutes[ id ], g_iSeconds[ id ] < 10 ? "0" : "", g_iSeconds[ id ] );
		g_bHasTimer[ id ] = false;
	}
}
				
public plugin_end( )
{
	TrieDestroy( g_tStartTargets );
	TrieDestroy( g_tFinishTargets );
}
