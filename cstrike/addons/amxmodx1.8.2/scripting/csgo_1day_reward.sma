#include < amxmodx >
#include < nvault >
#include < colorchat >
#include < csgo_remake >

#define MAXIM_POINTS 10
#define MAXIM_DUSTS 10
#define MAXIM_CASES 10
#define MAXIM_KEYS 10

new g_szAuthId[ 33 ][ 36 ], g_szDay[ 3 ], g_iVault, g_iDay;

public plugin_init( )
{
	register_plugin( "Daily Login Reward", "1.0", "OciXCrom" );
	get_time( "%d", g_szDay, charsmax( g_szDay ) );
	g_iDay = str_to_num( g_szDay );
	g_iVault = nvault_open( "DailyRewards" );
	if( g_iVault == INVALID_HANDLE )	set_fail_state( "I got some problems for ^"DailyRewards^" ." );
	register_clcmd( "say /reward", "PreDailyReward" );
}

public client_authorized( id )	if( !is_user_bot( id ) || !is_user_hltv( id ) )	get_user_authid( id, g_szAuthId[ id ], charsmax( g_szAuthId[ ] ) );

public PreDailyReward( id ) {
	if( !csgor_is_user_logged( id ) )	return;
	
	new iDay = nvault_get( g_iVault, g_szAuthId[ id ] ); 
	if( !iDay || iDay != g_iDay )	DailyReward( id );
	else	ColorChat( id, RED, "^1You have taken today's daily reward." );
}
public DailyReward( id ) {
	new menu = menu_create( "w- Daily Reward", "reward_handler" );
	
	menu_additem( menu, "Cases" );
	menu_additem( menu, "Keys" );
	menu_additem( menu, "Points" );
	menu_additem( menu, "Dusts" );
	
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}
public reward_handler( id, menu, item )
{
	new rand;
	switch( item )
	{
		case 0:
		{
			rand = random( MAXIM_CASES );
			csgor_set_user_cases( id, csgor_get_user_cases( id ) + rand );
			ColorChat( id, RED, "^1Rewarded -^4 %d^1 cas%s", rand, rand == 1 ? "" : "s" );
		}
		case 1:
		{
			rand = random( MAXIM_KEYS );
			csgor_set_user_keys( id, csgor_get_user_keys( id ) + rand );
			ColorChat( id, RED, "^1Rewarded -^4 %d^1 key%s", rand, rand == 1 ? "" : "s" );
		}
		case 2:
		{
			rand = random( MAXIM_POINTS );
			csgor_set_user_points( id, csgor_get_user_points( id ) + rand );
			ColorChat( id, RED, "^1Rewarded -^4 %d^1 point%s",rand, rand == 1 ? "" : "s" );
		}
		case 3:
		{
			rand = random( MAXIM_DUSTS );
			csgor_set_user_dusts( id, csgor_get_user_dusts( id ) + rand );
			ColorChat( id, RED, "^1Rewarded -^4 %d^1 dust%s", rand, rand == 1 ? "" : "s" );
		}
	}
	nvault_set( g_iVault, g_szAuthId[ id ], g_szDay );
}

public plugin_end( )	if( g_iVault != INVALID_HANDLE )	nvault_close( g_iVault );

#pragma tabsize 0
