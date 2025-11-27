	/* 
	Plugin: Xmas Gifts 2.3.2 
	Autor: KronoS # GG 

	Credite: 
	@FakeNick - pentru pluginul Pick up present de unde a pornit tot 
	@joropito - pentru Super Spawns 
	@Askhanar - pentru fixarea Super Spawns 

	Cvar-uri: 
	- presents_respawn_time 60.0 (Dupa cat timp dupa ridicarea unui cadou apare altul pe harta) 
	- presents_on_map 11 (Cate cadouri sa apara pe harta) 
	ATENTIE: Se calculeaza numarul cvar-ului - 1!!! 
	Daca puneti 11 or sa apara doar 10 cadouri! 

	Changelog: 

	* v2.3.2 - 28.12.2012 
	- cadourile primeau respawn chiar daca timpul era setat pe 0.0 

	* v2.3.1 - 28.12.2012 
	- cadourile nu primeau respawn 

	* v2.3 - 28.12.2012 
	- cod infrumusetat 
	- cadourile nu mai apareau dupa prima runda (fixat de Askhanar) 

	* v2.2 - 25.11.2010 
	- bug reparat: cadourile dispareau de pe harta 
	- FM_Think indeparta 

	* v2.1 - 17.11.2010 
	- super spawns 
	- cvar: presents_on_map 
	- bug reparat: cadourile apareau in aer 
	- variabila globala 
	- FUN -> Fakemeta 
	- Hamsandwich 
	- optimizare mesaje HUD 

	* v1.0 - 14.11.2010 
	- plugin publicat 

	*/ 

	#include < amxmodx > 
	#include < cstrike > 
	#include < hamsandwich > 
	#include < engine >
	#include < fakemeta > 
	#include <fun>

	/* Extras din Super Spawns */ 
	#define SS_MIN_DISTANCE 500.0 
	#define SS_MAX_LOOPS 100000 

	/* Modele cadouri */ 
	new const model_present[ ][ ] = { "models/present/w_present.mdl","models/present/w_present2.mdl" }; 

	new Array:g_vecSsOrigins; 
	new Array:g_vecSsSpawns; 
	new Array:g_vecSsUsed; 
	new Float:g_flSsMinDist; 
	new g_iSsTime; 

	new const g_szStarts[ ][ ] = { "info_player_start", "info_player_deathmatch" }; 
	new const Float:g_flOffsets[ ] = { 3500.0, 3500.0, 1500.0 }; 

	new pcvar_respawn_time, pcvar_presents_on_map; 
	//new g_bonus[ 33 ]; 


	new bool:skin_knife[33],bool:gravity[33],bool:speed[33]
	#define M_KNIFE_V "models/craciun/v_knife.mdl"


	public plugin_init( ) 
	{ 
	register_plugin( "XMAS GIFTS", "2.3.2", "KronoS" ); 

	// Eventuri 
	register_event( "HLTV", "spawn_gifts", "a", "1=0", "2=0" ); 
	RegisterHam( Ham_Killed, "player", "client_death", 1 ); 
	register_forward( FM_Touch, "forward_touch" ); 

	// Cvar-uri 
	pcvar_respawn_time = register_cvar( "presents_respawn_time", "10.0" ); 
	pcvar_presents_on_map = register_cvar( "presents_on_map", "3" );
	// NOI
	register_cvar("cadou_grav","700.0")
	register_cvar("cadou_vite","300.0")

	SsInit( 800.0 ); 
	SsScan( ); 
	XGIFTS_Spawn( ); 
	} 

	public plugin_precache( ) 
	{ 
	for ( new i = 0; i < sizeof model_present ; i++ )	engfunc( EngFunc_PrecacheModel, model_present[ i ] );

	precache_model(M_KNIFE_V)
	} 

	public spawn_gifts( ) 
	XGIFTS_Spawn( ); 

	public XGIFTS_Spawn( ) 
	{ 
	new Float:fOrigin[ 3 ]; 

	for ( new i = 0; i < get_pcvar_num( pcvar_presents_on_map ) ; i++ ) 
	{ 
	if ( SsGetOrigin( fOrigin ) ) 
	XGIFTS_Create( fOrigin ); 
	} 
	} 

	public XGIFTS_Create( const Float:fOrigin[ 3 ] ) 
	{ 
	new ent = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) ); 

	if ( pev_valid( ent ) ) 
	{ 
	engfunc( EngFunc_SetModel, ent, model_present[ random_num( 0, sizeof model_present - 1 ) ] ); 
	engfunc( EngFunc_SetOrigin, ent, fOrigin ); 
	static Float:fMaxs[ 3 ] = { 2.0, 2.0, 4.0 }; 
	static Float:fMins[ 3 ] = { -2.0, -2.0, -4.0 }; 
	set_pev( ent, pev_solid, SOLID_BBOX ); 
	engfunc( EngFunc_SetSize, ent, fMins, fMaxs ); 
	engfunc( EngFunc_DropToFloor, ent ); 

	switch ( random_num( 0, 1 ) ) 
	{ 
	case 0: set_pev( ent, pev_classname, "small_present" ); 
	case 1: set_pev( ent, pev_classname, "large_present" ); 
	} 
	} 
	} 

	public XGIFTS_Respawn( iOrigin[ ] ) 
	{ 
	new Float:fOrigin[ 3 ], auxOrigin[ 3 ]; 

	auxOrigin[ 0 ] = iOrigin[ 0 ]; 
	auxOrigin[ 1 ] = iOrigin[ 1 ]; 
	auxOrigin[ 2 ] = iOrigin[ 2 ]; 

	IVecFVec( auxOrigin, fOrigin ); 
	XGIFTS_Create( fOrigin ); 
	}

	public client_PostThink(id)
	{
		if(is_user_alive(id))
		{
			if(skin_knife[id]&&get_user_weapon(id)==CSW_KNIFE)	entity_set_string(id, EV_SZ_viewmodel, M_KNIFE_V)
			if(gravity[id])	set_user_gravity(id, get_cvar_float("cadou_grav")/get_cvar_float("sv_gravity"))
			if(speed[id])	set_user_maxspeed(id,get_cvar_float("cadou_vite"))
		}
	}

	public client_death( id ) 
	{
		if(is_user_connected(id))
		{
			//if (g_bonus[ id ] > 0 )	g_bonus[ id ] = 0;

			if(skin_knife[id])	skin_knife[id]=false
			if(gravity[id])	gravity[id]=false
			if(speed[id])	speed[id]=false
		}
	}

	public forward_touch( ent, id ) 
	{ 
	if ( !pev_valid( ent ) )	return FMRES_IGNORED; 

	static class[ 20 ]; 
	pev( ent, pev_classname, class, sizeof class - 1 ); 

	if ( ( !equali( class, "small_present" ) && !equali( class, "large_present" ) )||!is_user_alive( id ) ) return FMRES_IGNORED; 

	set_pev( ent, pev_solid, SOLID_NOT ); 
	set_pev( ent, pev_effects, EF_NODRAW ); 

	if ( get_pcvar_float( pcvar_respawn_time ) > 0.0 ) 
	{ 
	new Float:flOrigin[ 3 ], iOrigin[ 3 ]; 
	entity_get_vector( ent, EV_VEC_origin, flOrigin ); 
	FVecIVec( flOrigin, iOrigin ); 
	set_task( get_pcvar_float( pcvar_respawn_time ), "XGIFTS_Respawn", _, iOrigin, 3 ); 
	} 

	set_hudmessage(255, 165, 0, 0.02, 0.73, 0, 6.0, 5.0,0.1,0.2,-1); 
	if ( equali( class, "small_present" ) ) 
	{
	switch ( random_num( 0, 4 ) ) 
	{
	case 0: 
	{
	if(!skin_knife[id])
	{
	give_item(id,"weapon_knife")
	engclient_cmd(id,"weapon_knife")
	if(get_user_weapon(id)==CSW_KNIFE)
	{
	entity_set_string(id, EV_SZ_viewmodel, M_KNIFE_V)
	}
	skin_knife[id]=true
	show_hudmessage(id, "[XMAS Gift] Mosul ti-a oferit un Cutit cu Skin!");
	}
	} 
	case 1: 
	{
	if(!gravity[id])
	{
	gravity[id]=true
	set_user_gravity(id, get_cvar_float("cadou_grav")/get_cvar_float("sv_gravity"))
	show_hudmessage(id, "[XMAS Gift] Mosul ti-a oferit -%f Gravitatie !",get_cvar_float("cadou_grav"));
	}
	} 
	case 2: 
	{
	if(!speed[id])
	{
	speed[id]=true
	set_user_maxspeed(id,get_cvar_float("cadou_vite"))
	show_hudmessage(id, "[XMAS Gift] Mosul ti-a oferit +%f Viteza !",get_cvar_float("cadou_vite"));
	}
	} 
	case 3: 
	{ 
	if(cs_get_user_money(id)<16000)
	{
	cs_set_user_money(id, cs_get_user_money(id) + 6000,1); 
	show_hudmessage(id, "[XMAS Gift] Mosul ti-a oferit 6000$ !"); 
	}
	} 
	case 4: 
	{
	if(cs_get_user_money(id)>0)
	cs_set_user_money(id, 0); 
	show_hudmessage(id, "[XMAS Gift] Mosul ti-a furat toti banii"); 
	}
	}
	}
	else if ( equali( class,"large_present" ) /*&& !g_bonus[ id ]*/ ) 
	{ 
	switch (random_num(0,2)) 
	{ 
	case 0: 
	{ 
	if(cs_get_user_money(id)<16000)
	{
	//g_bonus[id] = 1; 
	cs_set_user_money(id, cs_get_user_money(id) + 6000,1); 
	//large_present_hud( id ); 
	show_hudmessage(id, "[XMAS Gift] Mosul ti-a oferit 6000$ !"); 
	}
	}
	case 1: 
	{
	if(cs_get_user_money(id)>0)
	{
	//g_bonus[id] = 2;
	cs_set_user_money(id, 0); 
	show_hudmessage(id, "[XMAS Gift] Mosul ti-a furat toti banii");
	}
	} 
	case 2: 
	{
	//g_bonus[id] = 3;
	give_item(id,"weapon_deagle")
	static deagle
	deagle = fm_find_ent_by_owner(-1, "weapon_deagle", id)
	if(is_valid_ent(deagle))	cs_set_weapon_ammo(deagle,2)
	engclient_cmd(id,"weapon_deagle")
	show_hudmessage(id, "[XMAS Gift] Mosul ti-a oferit deagle cu 2GL"); 
	}
	}
	}

	return FMRES_IGNORED; 
	}

	/*
	public large_present_hud( id ) 
	{ 
	if ( is_user_alive( id ) ) 
	{ 
	set_hudmessage(255, 165, 0, 0.02, 0.73, 0, 6.0, 5.0,0.1,0.2,-1); 
	if ( g_bonus[ id ] > 0 ) 
	{ 
	switch( g_bonus[ id ] ) 
	{ 
	case 1: 
	{ 
	show_hudmessage(id, "[XMAS Gift] Mosul ti-a oferit 6000$ !"); 
	} 
	case 2: 
	{ 
	show_hudmessage(id, "[XMAS Gift] Mosul ti-a furat toti banii"); 
	} 
	} 

	//set_task( 12.0, "large_present_hud", id ); 
	} 
	} 
	} 

	public client_disconnect( id ) 
	g_bonus[ id ] = 0; 
	*/

	// Super spawns 
	public SsInit( Float:mindist ) 
	{ 
	g_flSsMinDist = mindist; 
	g_vecSsOrigins = ArrayCreate( 3, 1 ); 
	g_vecSsSpawns = ArrayCreate( 3, 1 ); 
	g_vecSsUsed = ArrayCreate( 3, 1 ); 
	} 

	stock SsClean( ) 
	{ 
	g_flSsMinDist = 0.0; 
	ArrayClear( g_vecSsOrigins ); 
	ArrayClear( g_vecSsSpawns ); 
	ArrayClear( g_vecSsUsed ); 
	} 

	stock SsGetOrigin( Float:origin[ 3 ] ) 
	{ 
	new Float:data[3], size; 
	new ok = 1; 

	while ( ( size = ArraySize( g_vecSsOrigins ) ) ) 
	{ 
	new idx = random_num( 0, size - 1 ); 

	ArrayGetArray( g_vecSsOrigins, idx, origin ); 

	new used = ArraySize( g_vecSsUsed ); 
	for ( new i = 0; i < used ; i++ ) 
	{ 
	ok = 0; 
	ArrayGetArray( g_vecSsUsed, i, data ); 
	if ( get_distance_f( data, origin ) >= g_flSsMinDist ) 
	{ 
	ok = 1; 
	break; 
	} 
	} 

	ArrayDeleteItem( g_vecSsOrigins, idx ); 

	if ( ok ) 
	{ 
	ArrayPushArray( g_vecSsUsed, origin ); 
	return true; 
	} 
	} 

	return false; 
	} 

	public SsScan( ) 
	{ 
	new start, Float:origin[ 3 ], starttime; 

	starttime = get_systime( ); 

	for ( start = 0 ; start < sizeof( g_szStarts ) ; start++ ) 
	{ 
	server_print( "Searching for %s", g_szStarts[ start ] ); 

	new ent; 

	if ( ( ent = engfunc( EngFunc_FindEntityByString, ent, "classname", g_szStarts[ start ] ) ) ) 
	{ 
	new counter; 

	pev( ent, pev_origin, origin ); 
	ArrayPushArray( g_vecSsSpawns, origin ); 

	while ( counter < SS_MAX_LOOPS ) 
	counter = GetLocation( origin, counter ); 
	} 
	} 

	g_iSsTime = get_systime( ); 
	g_iSsTime -= starttime; 
	} 

	GetLocation( Float:start[ 3 ], &counter ) 
	{ 
	new Float:end[ 3 ]; 

	for ( new i = 0 ; i < 3 ; i++ ) 
	end[ i ] += random_float( 0.0 - g_flOffsets[ i ], g_flOffsets[ i ] ); 

	if ( IsValid( start, end ) ) 
	{ 
	start[ 0 ] = end[ 0 ]; 
	start[ 1 ] = end[ 1 ]; 
	start[ 2 ] = end[ 2 ]; 

	ArrayPushArray( g_vecSsOrigins, end ); 
	} 

	counter++; 
	return counter; 
	} 

	IsValid( Float:start[ 3 ], Float:end[ 3 ] ) 
	{ 
	SetFloor( end ); 
	end[ 2 ] += 36.0; 
	new point = engfunc( EngFunc_PointContents, end ); 
	if ( point == CONTENTS_EMPTY ) 
	{ 
	if ( CheckPoints( end ) && CheckDistance( end ) && CheckVisibility( start, end ) ) 
	{ 
	if ( !trace_hull( end, HULL_LARGE, -1 ) ) 
	return true; 
	} 
	} 

	return false; 
	} 

	CheckVisibility( Float:start[ 3 ], Float:end[ 3 ] ) 
	{ 
	new tr; 

	engfunc( EngFunc_TraceLine, start, end, IGNORE_GLASS, -1, tr ); 

	return ( get_tr2( tr, TR_pHit ) < 0 ); 
	} 

	SetFloor( Float:start[ 3 ] ) 
	{ 
	new tr, Float:end[ 3 ]; 

	end[ 0 ] = start[ 0 ]; 
	end[ 1 ] = start[ 1 ]; 
	end[ 2 ] = -99999.9; 

	engfunc( EngFunc_TraceLine, start, end, DONT_IGNORE_MONSTERS, -1, tr ); 
	get_tr2( tr, TR_vecEndPos, start ); 
	} 

	CheckPoints( Float:origin[ 3 ] ) 
	{ 
	new Float:data[ 3 ], tr, point; 

	data[ 0 ] = origin[ 0 ]; 
	data[ 1 ] = origin[ 1 ]; 
	data[ 2 ] = 99999.9; 

	engfunc( EngFunc_TraceLine, origin, data, DONT_IGNORE_MONSTERS, -1, tr ); 
	get_tr2( tr, TR_vecEndPos, data ); 
	point = engfunc( EngFunc_PointContents, data ); 

	if ( point == CONTENTS_SKY && get_distance_f( origin, data ) < 250.0 ) 
	return false; 

	data[ 2 ] = -99999.9; 

	engfunc( EngFunc_TraceLine, origin, data, DONT_IGNORE_MONSTERS, -1, tr ); 
	get_tr2( tr, TR_vecEndPos, data ); 
	point = engfunc( EngFunc_PointContents, data ); 

	if ( point < CONTENTS_SOLID ) 
	return false; 

	return true; 
	} 

	CheckDistance( Float:origin[ 3 ] ) 
	{ 
	new Float:dist, Float:data[ 3 ]; 

	new count = ArraySize( g_vecSsSpawns ); 

	for ( new i = 0; i < count ; i++ ) 
	{ 
	ArrayGetArray( g_vecSsSpawns, i, data ); 
	dist = get_distance_f( origin, data ); 
	if ( dist < SS_MIN_DISTANCE ) 
	return false; 
	} 

	count = ArraySize( g_vecSsOrigins ); 

	for ( new i = 0 ; i < count ; i++ ) 
	{ 
	ArrayGetArray( g_vecSsOrigins, i, data ); 
	dist = get_distance_f( origin, data ); 
	if ( dist < SS_MIN_DISTANCE ) 
	return false; 
	} 

	return true; 
	}


	stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0) {
		new strtype[11] = "classname", ent = index;
		switch (jghgtype) {
			case 1: strtype = "target";
			case 2: strtype = "targetname";
		}

		while ((ent = engfunc(EngFunc_FindEntityByString, ent, strtype, classname)) && pev(ent, pev_owner) != owner) {}

		return ent;
	}
