#include < amxmodx >
#include < cstrike >
#include < engine >
#include < fakemeta >
#include < hamsandwich>
#include < ColorChat >

#define PluginName       "KnifeBot Detector"
#define Version            "1.0"
#define Author        "Freezo aka Spawner"

#pragma semicolon 1
#define PRESSED(%0,%1) (((%1 & (%0)) == (%0)))

new bool:isDamaged[33];

public  plugin_init()
{
    register_plugin
    (
            .plugin_name    = PluginName,
            .version    = Version,
            .author  = Author
    );
    
    RegisterHam(Ham_TakeDamage, "player", "TakeDamage");

}

public client_disconnect(id)    isDamaged[id] = false;
public TakeDamage(iVictim, iInflictor, iAttacker, Float:flDamage, iDmgBits) isDamaged[iAttacker] = true;
  
public client_PreThink(id)
{
    if(!is_user_alive(id))  return;
    

    static  buttons;
    
    buttons         = pev(id, pev_button);
    
    new     iTarget , iBody;
    get_user_aiming( id , iTarget , iBody );
    
    if
    (
            ( id != iTarget )     &&    (1 <= iTarget <= 32)
            &&  get_user_weapon(id)   ==    CSW_KNIFE
            &&  cs_get_user_team(id)  !=   cs_get_user_team(iTarget)
    )   
    {
    if(isDamaged[id]){
        
            new iDistance    =   get_dist(id, iTarget);
            if(PRESSED(IN_ATTACK, buttons) && (70 <= iDistance <= 75))
            {
                new userName[32];get_user_name(id , userName, charsmax(userName));
                ColorChat(0, GREY, "^3[KnifeBot-Detector] ^4%s ^1has been detect using ^4knifebot ^1!! ^'=> ^3Distance ^1[^3%d^1]^4[SLASH]",  userName, iDistance);

            }
            if(PRESSED(IN_ATTACK2, buttons) && (60 <= iDistance <= 63))
            {
                // Declaring userName twice better than declaring it before the check ... because in if(isDamage[id]) will be called a lot ...
                new userName[32];get_user_name(id , userName, charsmax(userName));
                ColorChat(0, GREY, "^3[KnifeBot-Detector] ^4%s ^1has been detect using ^4knifebot ^1!! ^'=> ^3Distance ^1[^3%d^1]^4[STAB]",  userName, iDistance);

            }
            isDamaged[id] = false;
        }
    }
    
}

stock   get_dist(id,iPlayer)
{
    static          origin1[ 3 ] ,
    origin2[ 3 ];
    
    get_user_origin( id , origin1 );
    get_user_origin( iPlayer , origin2 );
    
    return  get_distance(origin1, origin2);
}
