#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fun>


#define PLUGIN "Stealth Mod"
#define VERSION "0.0.1"
#define AUTHOR "ONEMDX"


public plugin_init() {

register_plugin(PLUGIN, VERSION, AUTHOR);
register_forward(FM_PlayerPreThink, "FWD_PlayerPreThink");
}


public FWD_PlayerPreThink(id) {	
			if(is_user_alive(id))
			{		
					if(IsHoldingKnife(id)) {
					set_user_rendering( id, kRenderFxNone, 0, 0, 0, kRenderTransTexture, 50 );
					set_pev(id, pev_maxspeed, 500.0);	
                                        set_user_gravity( id, 0.3 );
 		                        set_user_footsteps( id, 0 );
	
					}
					else {
                                        set_user_rendering( id ); 
                                        set_pev(id, pev_maxspeed, 250.0);
                                        set_user_gravity( id, 1.0 );
		                        set_user_footsteps( id, 1 );
                                         }
			}
	
}


public IsHoldingKnife( id )
{
	new iClip, iAmmo, iWeapon;
	iWeapon = get_user_weapon( id, iClip, iAmmo );
	
	
	if ( iWeapon == CSW_KNIFE )
	{
		return true;
	}
	
	return false;
}
