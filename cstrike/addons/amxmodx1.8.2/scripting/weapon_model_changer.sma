#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >

new const g_szViewKnife[ ] = "models/Weapons/v_knife.mdl";

new const g_szWeaponKnife[ ] = "models/Weapons/p_knife.mdl";

public plugin_init( )
{
    RegisterHam( Ham_Item_Deploy, "weapon_knife", "FwdKnifeDeploy", 1 );
}

public plugin_precache( )
{
    precache_model( g_szWeaponKnife );
    
    precache_model( g_szViewKnife );
}

public FwdKnifeDeploy( iEntity )
{
    new client = get_pdata_cbase( iEntity, 41, 4 );
    
    if ( ! is_user_connected( client ) || ! is_user_alive( client ) ) return 1;
    
    if ( get_user_weapon( client ) == CSW_KNIFE )
    {
        set_pev( client, pev_viewmodel2, g_szViewKnife );
        
        set_pev( client, pev_weaponmodel2, g_szWeaponKnife );
    }
    
    return 1;
}  
