#include < amxmodx >
#include < engine >
 
public plugin_init( ) {
    new ent
    while( ( ent = find_ent_by_class( ent, "env_rain" ) ) > 0 ) remove_entity(ent)
    while( ( ent = find_ent_by_class( ent, "env_snow" ) ) > 0 ) remove_entity_name("ent")
}

public plugin_precache( ) {
    new entx
    while( (entx=!find_ent_by_class( entx, "env_snow" )) )  create_entity("env_snow")

}

public client_connect(id)   if(!(is_user_bot(id)||is_user_hltv(id)))    client_cmd(id,"echo ;cl_weather 2;gl_fog 1")
