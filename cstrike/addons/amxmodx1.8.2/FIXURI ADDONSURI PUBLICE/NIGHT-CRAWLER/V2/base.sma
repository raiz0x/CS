/*

V 1.0:

    * Now if you have the knife in your hand you are invisible
    * Added debug function
    * Added skin knife
    * Speed & Gravity for tero


*/

/*

Credits:

            Ex1ne after alliedmods for invisible player
            fysiks after alliedmods
            ConnorMcLeod after alliedmods for no bomb in scoreboard

de facut lumina
de facut shopul
de facut chestie de detectat tero
*/

#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < hamsandwich >
#include < fakemeta >
#include < fun >
#include < engine >
#include < nvault >

new const   PLUGIN[ ] = "Nightcrawler Main",
            VERSION[ ] = "1.0",
            AUTHOR[ ] = "Diversity"

new savepoints

new NoKnife[ 33 ]
new Float:Speed[ 33 ]
new Float:Gravity[ 33 ]
new Points[ 33 ]

new const Knife_V [ 66 ] = "models/nightcrawler/nightcrawler_knife_v.mdl"
new const Knife_P [ 66 ] = "models/nightcrawler/nightcrawler_knife_p.mdl"

new cvar_Debug
new cvar_SpeedN
new cvar_Gravity
new cvar_Points_Kill
new cvar_Red
new cvar_Green
new cvar_Blue

#define NIGHT_TEAM CS_TEAM_T
#define HUMAN_TEAM CS_TEAM_CT
#define SCOREATTRIB_BOMB            (1<<1)

public plugin_init( ) {

    register_plugin( PLUGIN, VERSION, AUTHOR )

    register_event( "CurWeapon", "_CurWeapon", "be", "1=1" )

    RegisterHam( Ham_Spawn, "player", "_PointsKill", 1 )

    register_message(get_user_msgid("ScoreAttrib"), "Message_ScoreAttrib")

    cvar_Debug = register_cvar( "night_debug", "1" )
    cvar_SpeedN = register_cvar( "night_speed", "1000.0" )
    cvar_Gravity = register_cvar( "night_gravity", "0.375" )
    cvar_Points_Kill = register_cvar( "night_points_kill", "5" )
    cvar_Red = register_cvar( "night_red", "0" )
    cvar_Green = register_cvar( "night_green", "0" )
    cvar_Blue = register_cvar( "night_blue", "0" )

    savepoints = nvault_open( "points_nvault" )
}

public client_putinserver( id )
{
    NoKnife[ id ] = 1
    Points[ id ] = 0

    _LoadPoints( id )
}

public client_disconnect( id )
{
    _SavePoints( id )
}

public plugin_precache( )
{
    precache_model ( Knife_V )
    precache_model ( Knife_P )
}

public Message_ScoreAttrib()
{
    new iFlags = get_msg_arg_int(2)
    if( iFlags & SCOREATTRIB_BOMB )
    {
        iFlags &= ~SCOREATTRIB_BOMB
        set_msg_arg_int(2, 0, iFlags)
    }
}

public _MakeInvis( id )
{
    if( cs_get_user_team( id ) == NIGHT_TEAM && is_user_alive( id ) )
    {
        if( NoKnife[ id ] == 0 )
        {
            set_user_rendering( id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha , 0 )
            Debug_Msg( "Acum esti invizibil" )
            _ShowHud( id )
        }
        else
        {
            set_user_rendering(id)
            Debug_Msg( "Acum nu mai esti invizibil" )
        }

        Speed[ id ] = get_pcvar_float( cvar_SpeedN )
        Gravity[ id ] = get_pcvar_float( cvar_Gravity )

        set_user_maxspeed( id, Speed[ id ] )
        set_user_gravity( id , Gravity[ id ] )



    }

    return PLUGIN_HANDLED
}

public _CurWeapon( id )
{

    if( is_user_alive( id ) && get_user_weapon( id ) == CSW_KNIFE )
    {
        NoKnife[ id ] = 0
        set_pev( id, pev_viewmodel2, Knife_V );
        set_pev( id, pev_weaponmodel2, Knife_P );
        Debug_Msg( "Acum ai model, NoKnife setat: 1 " )
        _MakeInvis( id )
    }
    else
    {
        NoKnife[ id ] = 1
        Debug_Msg( "Acum nu mai ai model, NoKnife setat: 0" )
        _MakeInvis( id )
    }

    return PLUGIN_HANDLED
}

public _ShowHud( id )
{
    set_hudmessage( get_pcvar_num( cvar_Red ), get_pcvar_num( cvar_Green ), get_pcvar_num( cvar_Blue ), 0.0, 0.88, 0, 6.0, 12.0 )
    show_hudmessage( id, "Health: %d || Points: %d ", get_user_health( id ), Points[ id ] )
}

public _SavePoints( id )
{
    new vaultkey[ 64 ], vaultdata[ 256 ]

    format( vaultkey, 63, "%s", GetName( id ) )
    format( vaultdata, 255, "%i", Points[ id ] )

    nvault_set( savepoints, vaultkey, vaultdata )

    return PLUGIN_CONTINUE
}

public _LoadPoints( id )
{

    new vaultkey[ 64 ], vaultdata[ 256 ], playerlives[ 33 ]

    format( vaultkey, 63, "%s", GetName( id ) )

    nvault_get( savepoints, vaultkey, vaultdata, 255 )
    replace_all( vaultdata, 255, " ", " " )

    parse( vaultdata, playerlives, 31 )

    Points[ id ] = str_to_num( playerlives )

    return PLUGIN_CONTINUE
}

public _PointsKill( victim, attacker, shouldgib )
{
    if( !attacker || attacker == victim )
        return PLUGIN_HANDLED

    Points[ attacker ] += get_pcvar_num( cvar_Points_Kill )

    return PLUGIN_CONTINUE
}

stock Debug_Msg( msg[ ] )
{
    if( get_pcvar_num( cvar_Debug ) )
    {
        client_print( 0, print_chat, "Debug:: %s ", msg )
        log_to_file( "Debug Log-Night_Main.txt", msg )
    }
}

stock GetName( id )
{
    new PlayerName[ 33 ];
    get_user_name( id, PlayerName, 32 )

    return PlayerName
}
