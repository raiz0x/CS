	// LAST EDIT ON - 14.04.2019 & 23:08
	
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
		ATENTIE*: Se calculeaza numarul cvar-ului - 1!!! 
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
	#include <csgo_remake>

	#pragma tabsize 0

	new const g_szFmuGiftClassName[ ] = "csgo_supplybox";

	/* Model cadou */
	#define MODEL_CUTIE "models/cutie.mdl"

	/* Super-Spawns */ 
	#define SS_VERSION "1.0"
	#define SS_MIN_DISTANCE 500.0
	#define SS_MAX_LOOPS 100000

	new Array:g_vecSsOrigins;
	new Array:g_vecSsSpawns;
	new Array:g_vecSsUsed;
	new Float:g_flSsMinDist;
	new g_iSsTime;

	new const g_szStarts[ ][ ] = { "info_player_start", "info_player_deathmatch" };
	new const Float:g_flOffsets[ ] = { 3500.0, 3500.0, 1500.0 };


	new pcvar_respawn_time, pcvar_presents_on_map;

	public plugin_precache( )
	{
		// Cvar-uri
		pcvar_presents_on_map = register_cvar( "presents_on_map", "4" );
		pcvar_respawn_time = register_cvar( "presents_respawn_time", "90" );
	
		precache_model( MODEL_CUTIE );
	}

	public plugin_init( )
	{
		register_plugin( "XMAS GIFTS", "2.3.2", "KronoS" );


	// Eventuri
		//register_event( "HLTV", "spawn_gifts", "a", "1=0", "2=0" );
		register_logevent("spawn_gifts", 2, "0=World triggered", "1=Round_Start")
		register_forward( FM_Touch, "forward_touch" );


		//NOI
			register_cvar("box_chei","1");
			register_cvar("box_cutii","1");
			register_cvar("box_pulbere","1");
			register_cvar("box_bani","333");
			register_cvar("box_skin_max","80");


		SsInit( 800.0 );
		SsScan( );

		XGIFTS_Spawn( );
	}


	public spawn_gifts( )	XGIFTS_Spawn( );


	public XGIFTS_Spawn( )
	{
		new Float:fOrigin[ 3 ];
		for( new i = 0; i < get_pcvar_num( pcvar_presents_on_map ); i++ )	if( SsGetOrigin( fOrigin ) )	XGIFTS_Create( fOrigin );
	}

	public XGIFTS_Create( const Float:fOrigin[ 3 ] )
	{
		new ent = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) ); 

		if( pev_valid( ent ) )
		{
			engfunc( EngFunc_SetModel, ent, MODEL_CUTIE );
			engfunc( EngFunc_SetOrigin, ent, fOrigin );
			static Float:fMaxs[ 3 ] = { 2.0, 2.0, 4.0 };
			static Float:fMins[ 3 ] = { -2.0, -2.0, -4.0 };
			set_pev( ent, pev_solid, SOLID_BBOX );
			engfunc( EngFunc_SetSize, ent, fMins, fMaxs );
			engfunc( EngFunc_DropToFloor, ent );

			set_pev( ent, pev_classname, g_szFmuGiftClassName );
			
				set_rendering( ent,
			kRenderFxGlowShell,
			255,
			0,
			0,
			kRenderNormal,
			255 );
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

		client_print(0,print_chat,"Tocmai a fost aruncata o cutie pe mapa!Cautati-o pentru a afla ce ascunde.");

		return 0;
	}

	public forward_touch( ent, id )
	{
		if ( !pev_valid( ent )||!is_user_alive( id ) )	return FMRES_IGNORED;

		static class[ 35 ];
		pev( ent, pev_classname, class, sizeof class - 1 );
		if ( !equal( class, g_szFmuGiftClassName ) ) return FMRES_IGNORED;

		set_pev( ent, pev_solid, SOLID_NOT );
		set_pev( ent, pev_effects, EF_NODRAW );

		if ( get_pcvar_float( pcvar_respawn_time ) > 0.0 )
		{
			new Float:flOrigin[ 3 ], iOrigin[ 3 ];
			entity_get_vector( ent, EV_VEC_origin, flOrigin );
			FVecIVec( flOrigin, iOrigin );
			set_task( float(get_pcvar_num( pcvar_respawn_time )), "XGIFTS_Respawn", _, iOrigin, 3 );
		}

		switch( random_num( 0, 4 ) )
		{
			case 0:
			{
				if(csgor_is_user_logged(id))
				{
					csgor_set_user_keys(id,csgor_get_user_keys(id)+get_cvar_num("box_chei"));
					client_print(id,print_chat,"Super!Ai primit +%d chei%s",get_cvar_num("box_chei"),get_cvar_num("box_chei")==1?"e":"");
				}
				else
				{
					client_print(id,print_chat,"Inregistreaza-te prin /reg pentru a avea acces la Supply BOX");
					Bani(id);
				}
			}
			case 1:
			{
				if(csgor_is_user_logged(id))
				{
					csgor_set_user_cases(id,csgor_get_user_cases(id)+get_cvar_num("box_cutii"));
					client_print(id,print_chat,"Super!Ai primit +%d cuti%s",get_cvar_num("box_cutii"),get_cvar_num("box_cutii")==1?"e":"i");
				}
				else
				{
					client_print(id,print_chat,"Inregistreaza-te prin /reg pentru a avea acces la Supply BOX");
					Bani(id);
				}
			}
			case 2:
			{
				if(csgor_is_user_logged(id))
				{
					csgor_set_user_dusts(id,csgor_get_user_dusts(id)+get_cvar_num("box_pulbere"));
					client_print(id,print_chat,"Super!Ai primit +%d pulber%s",get_cvar_num("box_pulbere"),get_cvar_num("box_pulbere")==1?"e":"i");
				}
				else
				{
					client_print(id,print_chat,"Inregistreaza-te prin /reg pentru a avea acces la Supply BOX");
					Bani(id);
				}
			}
			case 3:
			{
				if(csgor_is_user_logged(id))
				{
					csgor_set_user_skins(id,random_num(0,get_cvar_num("box_skin_max")),1);
					client_print(id,print_chat,"Super!Ai primit +1 skin");
				}
				else
				{
					client_print(id,print_chat,"Inregistreaza-te prin /reg pentru a avea acces la Supply BOX");
					Bani(id);
				}
			}
			case 4: Bani(id);
		}
		return FMRES_IGNORED;
	}

	public Bani(id)
	{
		cs_set_user_money(id,cs_get_user_money(id)+get_cvar_num("box_bani"),1);
		client_print(id,print_chat,"Super!Ai primit +%d$",get_cvar_num("box_bani"));
		//return PLUGIN_HANDLED;
	}

	
	// Super spawns
	
	public SsDump( )
	{
		new Float:origin[ 3 ];
		new count = ArraySize( g_vecSsOrigins );
		server_print( "-------------------------------------------------------" );
		for( new i = 0; i < count; i++ )
		{
			ArrayGetArray( g_vecSsOrigins, i, origin );
			server_print( "Origin: %f %f %f", origin[ 0 ], origin[ 1 ], origin[ 2 ] );
		}
		server_print( "-------------------------------------------------------" );
		server_print( "Number of origins: %i", count );
		server_print( "Time: %i", g_iSsTime );
		server_print( "-------------------------------------------------------" );
	}
	
	public SsInit( Float:mindist )
	{
		register_cvar( "sv_superspawns", SS_VERSION, ( FCVAR_SERVER|FCVAR_SPONLY ) );
		register_concmd( "_ss_dump", "SsDump" );
	
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
		new Float:data[ 3 ], size;
		new ok = 1;

		while( ( size = ArraySize( g_vecSsOrigins ) ) )
		{
			new idx = random_num( 0, size - 1 );
			ArrayGetArray( g_vecSsOrigins, idx, origin );

			new used = ArraySize( g_vecSsUsed );
			for( new i = 0; i < used; i++ )
			{
				ok = 0;
				ArrayGetArray( g_vecSsUsed, i, data );
				if( get_distance_f( data, origin ) >= g_flSsMinDist )
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

		for( start = 0; start < sizeof( g_szStarts ); start++ )
		{
			server_print( "Searching for %s", g_szStarts[ start ] );

			new ent;
			if( ( ent = engfunc( EngFunc_FindEntityByString, ent, "classname", g_szStarts[ start ] ) ) )
			{
				new counter;

				pev( ent, pev_origin, origin );
				ArrayPushArray( g_vecSsSpawns, origin );

				while ( counter < SS_MAX_LOOPS ) counter = GetLocation( origin, counter );
			}
		}

		g_iSsTime = get_systime( );
		g_iSsTime -= starttime;
	}

	GetLocation( Float:start[ 3 ], &counter )
	{
		new Float:end[ 3 ];
		for( new i = 0; i < 3; i++ ) end[ i ] += random_float( 0.0 - g_flOffsets[ i ], g_flOffsets[ i ] );

		if( IsValid( start, end ) )
		{
			start[ 0 ] = end[ 0 ];
			start[ 1 ] = end[ 1 ];
			start[ 2 ] = end[ 2 ];

			ArrayPushArray( g_vecSsOrigins, end );
		}

		counter ++;

		return counter;
	}

	IsValid( Float:start[ 3 ], Float:end[ 3 ] )
	{
		SetFloor( end );
		end[ 2 ] += 36.0;
		new point = engfunc( EngFunc_PointContents, end );
		if( point == CONTENTS_EMPTY ) if ( CheckPoints( end ) && CheckDistance( end ) && CheckVisibility( start, end ) ) if ( !trace_hull( end, HULL_LARGE, -1 ) ) return true;

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

		if ( point == CONTENTS_SKY && get_distance_f( origin, data ) < 250.0 ) return false;

		data[ 2 ] = -99999.9;

		engfunc( EngFunc_TraceLine, origin, data, DONT_IGNORE_MONSTERS, -1, tr );
		get_tr2( tr, TR_vecEndPos, data );
		point = engfunc( EngFunc_PointContents, data );

		if ( point < CONTENTS_SOLID ) return false;

		return true;
	}

	CheckDistance( Float:origin[ 3 ] )
	{
		new Float:dist, Float:data[ 3 ];

		new count = ArraySize( g_vecSsSpawns );
		for( new i = 0; i < count; i++ ) 
		{
			ArrayGetArray( g_vecSsSpawns, i, data );
			dist = get_distance_f( origin, data );
			if( dist < SS_MIN_DISTANCE ) return false;
		}

		count = ArraySize( g_vecSsOrigins );
		for( new i = 0; i < count; i++ )
		{
			ArrayGetArray( g_vecSsOrigins, i, data );
			dist = get_distance_f( origin, data );
			if( dist < SS_MIN_DISTANCE ) return false;
		}

		return true;
	}
