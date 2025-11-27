#include <amxmodx>
#include <hamsandwich>

#define DMG_FALL (1<<5)

public plugin_init()
{
    register_plugin("No Fall Damage", "1.0", "OciXCrom")
    RegisterHam(Ham_TakeDamage, "player", "OnTakeDamagePre", 0)
}

public OnTakeDamagePre(iVictim, iInflictor, iAttacker, Float:fDamage, iBits)
    return iBits & DMG_FALL ? HAM_SUPERCEDE : HAM_IGNORED 


/*
    //    SetHamParamFloat(4, 0.0)
        SetHamReturnInteger(0)
        */
