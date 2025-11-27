//pev_body + rendring 1/0

#include < amxmodx >
#include < fakemeta >
#include < engine >
#include < hamsandwich >
#include <ANTI_PROTECTION>

#define MODEL_HAT_T "models/santahat.mdl"
#define MODEL_HAT_CT "models/santahat_blue.mdl"

new g_iHats[ 33 ];

public plugin_init( ) {
	register_plugin( "Santa Hat + Snow", "1.3", "xPaw" );//edit by Adryyy
    
	//register_event( "TeamInfo", "EventTeamInfo", "a" );
    
	RegisterHam( Ham_Spawn, "player", "FwdHamPlayerSpawn", 1 );

	new ent
	while( ( ent = find_ent_by_class( ent, "env_rain" ) ) > 0 )	remove_entity(ent)
	while( ( ent = find_ent_by_class( ent, "env_snow" ) ) > 0 )	remove_entity_name("ent")
}

public plugin_precache( ) {
	new entx//if<0
	while( (entx=!find_ent_by_class( entx, "env_snow" )) )	create_entity("env_snow")

	precache_model( MODEL_HAT_CT );
	precache_model( MODEL_HAT_T );
}

public client_connect(id)	if(!(is_user_bot(id)||is_user_hltv(id)))	RAIZ0_EXCESS3(id,"cl_weather 2;gl_fog 1")
//public client_disconnect( id )	if( is_valid_ent( g_iHats[ id ] ) )	remove_entity( g_iHats[ id ] );

public FwdHamPlayerSpawn( id )	SetHat(id)

public SetHat(id)
{
	if( !(is_user_alive( id )&&is_user_bot(id)) )

	if(g_iHats[ id ]<1)
	{
		g_iHats[ id ]=engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if(g_iHats[ id ]>0)
		{
			switch(get_user_team(id))
			{
				case 1:	engfunc(EngFunc_SetModel, g_iHats[ id ], MODEL_HAT_T)
				case 2:	engfunc(EngFunc_SetModel, g_iHats[ id ], MODEL_HAT_CT)
			}
			set_pev(g_iHats[ id ], pev_movetype, MOVETYPE_FOLLOW)
			set_pev(g_iHats[ id ], pev_aiment, id)
			set_pev(g_iHats[ id ], pev_owner, id );
		}
	}
        else
	{
		switch(get_user_team(id))
		{
			case 1:	engfunc(EngFunc_SetModel, g_iHats[ id ], MODEL_HAT_T)
			case 2:	engfunc(EngFunc_SetModel, g_iHats[ id ], MODEL_HAT_CT)
		}
	}
}

//public client_death(killer,victim,wpnindex,hitplace,TK)	if(is_user_connected(victim)&&is_valid_ent( g_iHats[ id ] ))	remove_entity( g_iHats[ id ] );

public EventTeamInfo( ) {
    new id = read_data( 1 ),szTeam[ 3 ];
    read_data( 2, szTeam, 2 );
    switch(szTeam[0])
    {
	case 'C':	SetHat(id)
	case 'T':	SetHat(id)
    }
    return
}
