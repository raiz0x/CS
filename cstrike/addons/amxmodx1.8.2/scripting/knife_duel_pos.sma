#include < amxmodx >
#include < amxmisc >
#include < xs >
#include < fun >
#include < fakemeta >
#include < engine >
#include < hamsandwich >

#define ADMIN_FLAG ADMIN_BAN

new const Float:VEC_BLANK[ 3 ] = { 9999.0, 9999.0, 9999.0 };

new Float:g_vecOrigin[ 2 ][ 3 ];
new g_szMapFile[ 128 ];

#define ValidOrigin(%1) !xs_vec_equal( g_vecOrigin[ %1 ], VEC_BLANK )
#define ValidOrigins() ( ValidOrigin( 0 ) && ValidOrigin( 1 ) )

new const g_szMenuTitleAdmin[ ] = "KnifeDuelAdminMenu";

new bool:g_bChallenging;
new g_iChallenger, g_iChallenged;

new pCvarSlashCount;
new pCvarCountDown;
new pCvarSetHealth;

public plugin_init( )
{
    register_plugin( "Knife Duel", "0.0.1", "Sneaky.amxx AKA HumboldtAnon" );
    
    register_clcmd( "knifeduel_menu", "CmdAdminMenu" );
    
    register_menu( g_szMenuTitleAdmin, ( MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_0 ), "MenuHandlerAdmin" );
    
    register_forward( FM_EmitSound, "FwdEmitSound" );
    register_forward( FM_ClientKill, "FwdClientKill" );

    RegisterHam(Ham_TakeDamage, "player", "Player_Hurt")
    
    register_event( "DeathMsg", "EventDeathMsg", "a" );
    register_event("HLTV", "event_new_round", "a", "1=0", "2=0") 
    
    pCvarSlashCount = register_cvar( "knifeduel_slash_count", "3" );
    pCvarCountDown = register_cvar( "knifeduel_countdown", "3" );
    pCvarSetHealth = register_cvar( "knifeduel_set_health", "0" );
}
public plugin_cfg()	    LoadOrigins( );

public event_new_round()
{
	g_bChallenging = false;
	g_iChallenger = 0;
	g_iChallenged = 0;
}

public client_disconnect( iPlayer )
{
    if( g_bChallenging )
    {
        if( iPlayer == g_iChallenged || iPlayer == g_iChallenger )
        {
            new iOtherPlayer = ( iPlayer == g_iChallenged ) ? g_iChallenger : g_iChallenged;
            
            ExecuteHamB( Ham_CS_RoundRespawn, iOtherPlayer );
            
            set_pev( iOtherPlayer, pev_flags, pev( iOtherPlayer, pev_flags ) & ~FL_FROZEN );
            
            g_bChallenging = false;
            g_iChallenger = 0;
            g_iChallenged = 0;
        }
    }
}

public CmdAdminMenu( iPlayer )
{
    if( access( iPlayer, ADMIN_FLAG ) )	ShowAdminMenu( iPlayer );
    else	console_print( iPlayer, "%L", iPlayer, "NO_ACC_COM" );
    
    return PLUGIN_HANDLED;
}
ShowAdminMenu( iPlayer )
{
    static szMenu[ 512 ];
    new iLen = copy( szMenu, charsmax( szMenu ), "\yKnife Duel^n\rAdmin Menu" );
    new iKeys = MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_0;
    new iValidCount;
    
    for( new i = 0; i < 2; i++ )
    {
        iLen += formatex( szMenu[ iLen ], charsmax( szMenu ), "^n^n\r%d. \wSet Position #%d^n   \yCurrent Position: ", ( i + 1 ), ( i + 1 ) );
        
        if( ValidOrigin( i ) )
        {
            iLen += formatex( szMenu[ iLen ], charsmax( szMenu ), "\w%.3f %.3f %.3f", g_vecOrigin[ i ][ 0 ], g_vecOrigin[ i ][ 1 ], g_vecOrigin[ i ][ 2 ] );
            iValidCount++;
        }
        else	iLen += copy( szMenu[ iLen ], charsmax( szMenu ), "\dNot Set" );
    }
    
    if( iValidCount == 2 )
    {
        iLen += copy( szMenu[ iLen ], charsmax( szMenu ), "^n^n\r3. \wSave Origins" );
        iKeys |= MENU_KEY_3;
    }
    else	iLen += copy( szMenu[ iLen ], charsmax( szMenu ), "^n^n\d3. Save Origins" );
    
    iLen += copy( szMenu[ iLen ], charsmax( szMenu ), "^n^n\r0. \wExit" );
    
    show_menu( iPlayer, iKeys, szMenu, _, g_szMenuTitleAdmin );
}
public MenuHandlerAdmin( iPlayer, iKey )
{
    switch( ++iKey % 10 )
    {
        case 1, 2:
        {
            pev( iPlayer, pev_origin, g_vecOrigin[ iKey - 1 ] );
            ShowAdminMenu( iPlayer );
        }
        case 3:
        {
            SaveOrigins( );
            client_print( iPlayer, print_chat, "* Saved origins" );
            ShowAdminMenu( iPlayer );
        }
    }
}

public FwdEmitSound( iPlayer, iChannel, const szSound[ ] )
{
    if( is_user_alive( iPlayer ) && equal( szSound, "weapons/knife_hitwall1.wav" ) )
    {
        static iHitCount[ 33 ], Float:flLastHit[ 33 ];
        new Float:flGameTime = get_gametime( );
        if( ( flGameTime - flLastHit[ iPlayer ] ) >= 1.0 )	iHitCount[ iPlayer ] = 0;
        else if( ++iHitCount[ iPlayer ] >= get_pcvar_num( pCvarSlashCount ) )
        {
            if( g_bChallenging )	client_print( iPlayer, print_chat, "* Someone is already starting a challenge." );
            else
            {
                g_bChallenging = true;
                g_iChallenger = iPlayer;
                ShowPlayerMenu( iPlayer );
            }
            iHitCount[ iPlayer ] = 0;
        }
        flLastHit[ iPlayer ] = flGameTime;
    }
}
public FwdClientKill( iPlayer )	return ( g_bChallenging && ( iPlayer == g_iChallenger || iPlayer == g_iChallenged ) ) ? FMRES_SUPERCEDE : FMRES_IGNORED;

public Player_Hurt(victim, inflictor, attacker, Float:dmg, dmgbits)
{
	if(g_bChallenging && ( attacker == g_iChallenger || attacker == g_iChallenged ) && get_user_team(attacker)==get_user_team(victim))
	{
		new km[120],name[32]
		get_user_name(attacker,name,charsmax(name))
		format(km,charsmax(km),"was killed by %s with knife, in duel",name)
		fakedamage(victim, km, dmg, dmgbits);
		set_user_frags(attacker,get_user_frags(attacker)+1)
	}
}
public EventDeathMsg( )
{
    if( g_bChallenging )
    {
        new iVictim = read_data( 1 );
        if( iVictim == g_iChallenger )	ShowWinner( g_iChallenged, g_iChallenger );
        else if( iVictim == g_iChallenged )	ShowWinner( g_iChallenger, g_iChallenged );
    }
}
ShowWinner( iWinner, iLoser )
{
    g_bChallenging = false;
    g_iChallenger = 0;
    g_iChallenged = 0;
    
    ExecuteHamB( Ham_CS_RoundRespawn, iWinner );
    
    client_print( 0, print_chat, "* %s has defeated %s in the knife duel!", GetUserNameReturned( iLoser ), GetUserNameReturned( iWinner ) );
}

ShowPlayerMenu( iPlayer )
{
    new iPlayers[ 32 ], iNum;
    get_players( iPlayers, iNum, "ach" );
    
    if( !iNum )
    {
        g_bChallenging = false;
        g_iChallenger = 0;
        client_print( iPlayer, print_chat, "* There are no players to challenge to a knife duel!" );
        return;
    }

    new iTarget, szName[ 32 ], szUserID[ 11 ]
    new hMenu = menu_create( "\yKnife Duel^nPlayer Menu", "MenuPlayer" );
    for( new i = 0; i < iNum; i++ )
    {
        iTarget = iPlayers[ i ];
        if(iTarget==iPlayer)	continue
        get_user_name( iTarget, szName, charsmax( szName ) );
        num_to_str( get_user_userid( iTarget ), szUserID, charsmax( szUserID ) );

        // Temporarily add userid to name item
        format( szName, charsmax( szName ), "#%s %s", szUserID, szName );
        
        menu_additem( hMenu, szName, szUserID );
    }
    
    menu_display( iPlayer, hMenu, 0 );
}

public MenuPlayer( iPlayer, hMenu, iItem )
{
    if( iItem == MENU_EXIT )
    {
        menu_destroy( hMenu );
        g_bChallenging = false;
        g_iChallenger = 0;
        return;
    }
    
    new iAccess, szUserID[ 11 ], hCallback;
    menu_item_getinfo( hMenu, iItem, iAccess, szUserID, charsmax( szUserID ), _, _, hCallback );
    new iTarget = GetPlayerByUserID( str_to_num( szUserID ) );
    
    client_print( g_iChallenger, print_chat, "Target userid: %s; Found target: %d; Connected: %s; Alive: %s", szUserID, iTarget, is_user_connected( iTarget ) ? "true" : "false", is_user_alive( iTarget ) ? "true" : "false" );
    
    if( is_user_alive( iTarget ) )
    {
        g_iChallenged = iTarget;
        client_print( 0, print_chat, "* %s has challenged %s to a knife duel!", GetUserNameReturned( iPlayer ), GetUserNameReturned( iTarget ) );
        ShowChallengeMenu( );
    }
    else
    {
        client_print( iPlayer, print_chat, "* That player is no longer %s", is_user_connected( iTarget ) ? "alive" : "connected" );
        ShowPlayerMenu( iPlayer );
    }
    menu_destroy( hMenu );
}

ShowChallengeMenu( )
{
    if( !is_user_alive( g_iChallenger ) || !is_user_alive( g_iChallenged ) )
    {
        g_bChallenging = false;
        g_iChallenger = 0;
        g_iChallenged = 0;
        return;
    }
    
    new szTitle[ 128 ];
    formatex( szTitle, charsmax( szTitle ), "\yKnife Duel^n\w%s has challeneged you^nDo you accept?", GetUserNameReturned( g_iChallenger ) );
    new hMenu = menu_create( szTitle, "MenuChallenge" );
    menu_additem( hMenu, "Yes", "1" );
    menu_additem( hMenu, "No", "0" );
    menu_setprop( hMenu, MPROP_EXIT, MEXIT_NEVER );
    menu_display( g_iChallenged, hMenu );
}
public MenuChallenge( iPlayer, hMenu, iItem )
{
    if( iItem == MENU_EXIT || !is_user_alive( g_iChallenger ) || !is_user_alive( g_iChallenged ) )
    {
        g_bChallenging = false;
        g_iChallenger = 0;
        g_iChallenged = 0;
        return;
    }
    
    if( iItem == 0 )
    {
	set_pev(g_iChallenger, pev_origin, g_vecOrigin[0])
	set_pev(g_iChallenged, pev_origin, g_vecOrigin[1])
        
        new iHealth = get_pcvar_num( pCvarSetHealth );
        if( iHealth > 0 )
        {
            set_user_health( g_iChallenger, iHealth );
            set_user_health( g_iChallenged, iHealth );
        }
        
        client_print( 0, print_chat, "* %s accepted the knife duel with %s", GetUserNameReturned( g_iChallenged ), GetUserNameReturned( g_iChallenger ) );
        
        new iParam[ 1 ];
        iParam[ 0 ] = get_pcvar_num( pCvarCountDown );
        set_task( 1.0, "TaskCountDown", 123, iParam, 1 );
    }
    else
    {
        client_print( 0, print_chat, "* %s declined to have a knife duel with %s", GetUserNameReturned( g_iChallenged ), GetUserNameReturned( g_iChallenger ) );
        
        g_bChallenging = false;
        g_iChallenger = 0;
        g_iChallenged = 0;
    }
    menu_destroy( hMenu );
}
public TaskCountDown( iParams[ ] )
{
    if( !is_user_alive( g_iChallenger ) )
    {
        g_bChallenging = false;
        g_iChallenger = 0;
        g_iChallenged = 0;
        
        if( is_user_alive( g_iChallenged ) )
        {
            ExecuteHamB( Ham_CS_RoundRespawn, g_iChallenged );
            set_pev( g_iChallenged, pev_flags, pev( g_iChallenged, pev_flags ) & ~FL_FROZEN );
        }
        return;
    }
    
    if( !is_user_alive( g_iChallenged ) )
    {
        g_bChallenging = false;
        g_iChallenger = 0;
        g_iChallenged = 0;
        return;
    }
    
    new iTimeLeft = iParams[ 0 ]--;
    if( iTimeLeft > 0 )
    {
        set_hudmessage( 0, 255, 0, .holdtime = 1.0, .channel = -1 );
        show_hudmessage( g_iChallenger, "Knife Duel^nCount Down: %d", iTimeLeft );
        show_hudmessage( g_iChallenged, "Knife Duel^nCount Down: %d", iTimeLeft );

        set_pev( g_iChallenger, pev_flags, pev( g_iChallenger, pev_flags ) | FL_FROZEN );
        set_pev( g_iChallenged, pev_flags, pev( g_iChallenged, pev_flags ) | FL_FROZEN );
        
        set_task( 1.0, "TaskCountDown", 123, iParams, 1 );
    }
    else
    {
        set_pev( g_iChallenger, pev_flags, pev( g_iChallenger, pev_flags ) & ~FL_FROZEN );
        set_pev( g_iChallenged, pev_flags, pev( g_iChallenged, pev_flags ) & ~FL_FROZEN );
        
        set_hudmessage( 0, 255, 0, .holdtime = 3.0, .channel = -1 );
        show_hudmessage( g_iChallenger, "Knife Duel^nFIGHT!" );
        show_hudmessage( g_iChallenged, "Knife Duel^nFIGHT!" );
    }
}

public LoadOrigins( )
{
    new strDir[101], strMapname[32]
    get_datadir(strDir, charsmax(strDir));
    add(strDir, charsmax(strDir), "/knife_duel" );
    if( !dir_exists( strDir ) )	mkdir( strDir );
    get_mapname(strMapname, charsmax(strMapname));
    formatex(g_szMapFile, charsmax(g_szMapFile), "%s/%s.txt", strDir, strMapname);
    
    new iFile = fopen( g_szMapFile, "r" );
    if( !iFile )	return
    
    new szData[ 125 ],szX[ 30 ], szY[ 30 ], szZ[ 30 ],iOriginCount=0;
    while( !feof( iFile ) && iOriginCount < 2 )
    {
	fgets( iFile, szData, charsmax( szData ) );
	trim( szData );
	parse( szData, szX, charsmax( szX ), szY, charsmax( szY ), szZ, charsmax( szZ ) );

	g_vecOrigin[ iOriginCount ][ 0 ] = str_to_float( szX );
	g_vecOrigin[ iOriginCount ][ 1 ] = str_to_float( szY );
	g_vecOrigin[ iOriginCount ][ 2 ] = str_to_float( szZ );
            
	iOriginCount++;
    }
    fclose( iFile );
}
public SaveOrigins( )
{
    new iFile = fopen(g_szMapFile, "w");
    if( !iFile )	return;
    
    fprintf( iFile, "%f %f %f^n", g_vecOrigin[ 0 ][ 0 ], g_vecOrigin[ 0 ][ 1 ], g_vecOrigin[ 0 ][ 2 ] );
    fprintf( iFile, "%f %f %f", g_vecOrigin[ 1 ][ 0 ], g_vecOrigin[ 1 ][ 1 ], g_vecOrigin[ 1 ][ 2 ] );
    
    fclose( iFile );
}

GetUserNameReturned( iPlayer )
{
    new szName[ 32 ];
    get_user_name( iPlayer, szName, charsmax( szName ) );
    return szName;
}

GetPlayerByUserID( iUserID )
{
    new iPlayers[ 32 ], iNum;
    get_players( iPlayers, iNum );

    for ( new i = 0, iTarget; i < iNum; i++ )
    {
        iTarget = iPlayers[ i ];
        if ( get_user_userid( iTarget ) == iUserID )	return iTarget;
    }
    return 0;
}
