#include <amxmodx>
#include <fakemeta>

#define PLUGIN "No bomb Damage"
#define VERSION "1.0"
#define AUTHOR "ConnorMcLeod"

public plugin_precache() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_map_parameters"))
	SetKeyValue(iEnt, "bombradius", "1", "info_map_parameters")
	dllfunc(DLLFunc_Spawn, iEnt)
}

SetKeyValue(iEnt, const szKey[], const szValue[], const szClassName[])
{
	set_kvd(0, KV_ClassName, szClassName)
	set_kvd(0, KV_KeyName, szKey)
	set_kvd(0, KV_Value, szValue)
	set_kvd(0, KV_fHandled, 0)
	dllfunc(DLLFunc_KeyValue, iEnt, 0)
}
