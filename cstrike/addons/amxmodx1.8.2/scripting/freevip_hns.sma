//	LAST EDIT ON - 05.04.2019 & 20:27

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>
//#include <colorchat>

new bool:vip_free,bool:has_godmode[33],bool:has_gravity[33],bool:has_speed[33],Float:Gravity
const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0
//new scout[33]=0

public plugin_init()
{
	check_time( )
	set_task( 10.0, "check_time", _, _, _, "b" )
	register_menu("Game Menu", KEYSMENU, "radio")
	register_event("CurWeapon" , "CWeapon" , "be" , "1=1" );
	RegisterHam( Ham_Spawn, "player", "ham_SpawnPlayerPost", true );

	//register_logevent ( "round_start", 2, "1=Round_Start" );
}

public client_disconnected(id)
{
	//scout[id]=0
	has_speed[id]=false
	has_godmode[id]=false
	has_gravity[id]=false
}

public check_time( )
{
	new o, m, s;
	time(o, m, s)

	if( o >= 18 && o <= 24 )
	{
		if( !vip_free )
		{
			xCoLoR(0, "!v[!nFREE-VIP!v]!n Fiind trecut de ora!e 18:00!n, toti jucatorii conectati au primit acces!v *V.I.P*!n, pana la ora!e 00:00!n !");
		}
		vip_free = true;
		//server_cmd( "amx_default_access ^"bt^"" );
		//server_cmd( "amx_reloadadmins" );
	}
	else
	{
		if( vip_free )
		{
			xCoLoR(0, "!v[!nFREE-VIP!v]!n Fiind trecut de ora!e 00:00!n, eventul!v *V.I.P*!n, a luat!e Sfarsit!n, si va reincepe la ora!v 18:00!n !");
		}
		vip_free = false;
		//server_cmd( "amx_default_access ^"z^"" );
		//server_cmd( "amx_reloadadmins" );
	}
}

/*public round_start ( )
{
	new iPlayers [ 32 ], iNum, i;
	get_players ( iPlayers, iNum, "ch" );

	if ( !iNum )	return;

	for ( i = 0; i < iNum; i++ )
	{
		new id = iPlayers [ i ];

		if ( scout[ id ] > 0 )
		{
			scout [ id ]--;
		}
		else if ( scout[ id ] > 3 )
		{
			scout [ id ] = 0;
		}
	}
}*/

public ham_SpawnPlayerPost(id)
{
	if(vip_free&&is_user_alive(id))
	{
		has_godmode[id]=false
		has_gravity[id]=false
		has_speed[id]=false
		ShowMenu(id)
	}
}

public ShowMenu(id)
{
	static menu[512], len 
	len = 0
	
	//   new len = formatex( menu, 255, "\r[\yHNS.PLAY-ARENA.RO\r] \w- Invizibilitate \y[\rFPS\y]^n^n" );
	
	len += formatex(menu[len], charsmax(menu) - len, "\w[\r HNS.PLAY-ARENA.RO\w -\r FREE V.I.P \w]^n^n") 
	//len += formatex(menu[len], charsmax(menu) - len, "\w-\r[\w1\r]\w -\r Scout [\w3\r] [\wGL\r]^n") 
	len += formatex(menu[len], charsmax(menu) - len, "\w-\r[\w1\r]\w -\r GodMode [\w5\r] [\wSEC\r]^n") 
	len += formatex(menu[len], charsmax(menu) - len, "\w-\r[\w2\r]\w -\r Gravity [\w400\r] [\w30\r] [\wSEC\r]^n") 
	len += formatex(menu[len], charsmax(menu) - len, "\w-\r[\w3\r]\w -\r Speed [\w300\r] [\w30\r] [\wSEC\r]^n") 
	len += formatex(menu[len], charsmax(menu) - len, "\w-\r[\w4\r]\w -\r Medic [\w15$\r]^n^n") 
	
    /*len += formatex( menu[len], 255 - len, "^n\r0. \yIesire" );
    show_menu( id, ( 1<<0 | 1<<1 | 1<<9 ), menu, -1 );*/
	
	show_menu(id, KEYSMENU, menu, -1, "Game Menu") 

	return 1;
}
public radio ( id , key )
{
	switch ( key )
	{
		/*case 0:
		{
			if(!is_user_alive(id))
			{
				xCoLoR(id,"!v[HnS.Play-Arena.Ro]!n Trebuie sa fii in viata")
				return PLUGIN_HANDLED
			}

			if ( scout [ id ] > 0 )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Poti folosii^x03 SCOUT^x01-ul odata la^x04 2^x01 runde. Mai ai de asteptat^x03 %i^x01 rund%s", scout [ id ], scout [ id ] == 1 ? "a" : "e" );
				return PLUGIN_HANDLED;
			}
			else
			{
				give_item(id,"weapon_scout")
				new eNtry = find_ent_by_owner ( -1, "weapon_scout", id );

				if ( eNtry )
				{
					cs_set_weapon_ammo ( eNtry, 3 );
				}
				scout[id]=3
				xCoLoR(id,"!v[HnS.Play-Arena.Ro]!n Ai primit!e Scout!n cu!v 3GL")
			}
		}*/

		case 0:
		{
			if(!is_user_alive(id))
			{
				xCoLoR(id,"!v[HnS.Play-Arena.Ro]!n Trebuie sa fii in viata")
				return PLUGIN_HANDLED
			}

			if(has_godmode[id])
			{
				xCoLoR(id,"!v[HnS.Play-Arena.Ro]!n Ai deja!e GodMode")
				return PLUGIN_HANDLED
			}
			else
			{
				has_godmode[id]=true
				set_user_godmode(id,1)
				set_task(5.0,"REMOVE_GODMODE",id)
				xCoLoR(id,"!v[HnS.Play-Arena.Ro]!n Ai primit!g GodMode!n pentru!v 5 Secunde")
			}
		}
		
		case 1:
		{
			if(!is_user_alive(id))
			{
				xCoLoR(id,"!v[HnS.Play-Arena.Ro]!n Trebuie sa fii in viata")
				return PLUGIN_HANDLED
			}
		
			if(has_gravity[id])
			{
				xCoLoR(id,"!v[HnS.Play-Arena.Ro]!n Ai deja!e Gravitiatie")
				return PLUGIN_HANDLED
			}
			else
			{
				has_gravity[id]=true
				Gravity=400.0/500.0
				set_user_gravity(id,Gravity)
				set_task(30.0,"REMOVE_GRAVITY",id)
				xCoLoR(id,"!v[HnS.Play-Arena.Ro]!n Ai primit!e Gravitatie!n pentru!v 30 Secunde")
			}
		}
		
		case 2:
		{
			if(!is_user_alive(id))
			{
				xCoLoR(id,"!v[HnS.Play-Arena.Ro]!n Trebuie sa fii in viata")
				return PLUGIN_HANDLED
			}

			if(has_speed[id])
			{
				xCoLoR(id,"!v[HnS.Play-Arena.Ro]!n Ai deja!e Speed")
				return PLUGIN_HANDLED
			}
			else
			{
				has_speed[id]=true
				set_user_maxspeed(id,300.0)
				set_task(30.0,"REMOVE_SPEED",id)
				xCoLoR(id,"!v[HnS.Play-Arena.Ro]!n Ai primit!e Speed!n pentru!v 30 Secunde")
			}
		}
		
		case 3:
		{
			if(!is_user_alive(id))
			{
				xCoLoR(id,"!v[HnS.Play-Arena.Ro]!n Trebuie sa fii in viata")
				return PLUGIN_HANDLED
			}

			cs_set_user_money(id,cs_get_user_money(id)+15)
			xCoLoR(id,"!v[HnS.Play-Arena.Ro]!n Ai primit!e +15!v$!n pentru!e Medic!n !")
		}
	}
	return 1;
}

public CWeapon(id)
{
	if(is_user_alive(id))
	{
		Gravity=400.0/500.0
		if(get_user_weapon(id))
		{
			if(has_gravity[id])	set_user_gravity(id,Gravity)
			if(has_speed[id])	set_user_maxspeed(id,300.0)
		}
	}
}

public REMOVE_GRAVITY(id)
{
	if(is_user_connected(id)&&has_gravity[id])
	{
		has_gravity[id]=false
		remove_task(id)
		set_user_gravity(id,1.0)
		xCoLoR(id,"!v[HnS.Play-Arena.Ro]!n Tocmai ti-a expirat!e Gravitatia")
	}
}

public REMOVE_SPEED(id)
{
	if(is_user_connected(id)&&has_speed[id])
	{
		has_speed[id]=false
		remove_task(id)
		set_user_maxspeed(id,250.0)
		xCoLoR(id,"!v[HnS.Play-Arena.Ro]!n Tocmai ti-a expirat!e Viteza")
	}
}

public REMOVE_GODMODE(id)
{
	if(is_user_connected(id)&&has_godmode[id])
	{
		has_godmode[id]=false
		remove_task(id)
		set_user_godmode(id)
		xCoLoR(id,"!v[HnS.Play-Arena.Ro]!n Tocmai ti-a expirat!e GodMode-ul")
	}
}

stock xCoLoR( const id, const input[ ], any:... )
{
	new count = 1, players[ 32 ];
	static msg[ 191 ];
	
	vformat( msg, 190, input, 3 );
	
	replace_all( msg, 190, "!v", "^4" );
	replace_all( msg, 190, "!n", "^1" );
	replace_all( msg, 190, "!e", "^3" );
	replace_all( msg, 190, "!e2", "^0" );
	
	if( id )
	{
		players[ 0 ] = id;
	}
	
	else get_players( players, count, "c" );
	for( new i = 0; i < count; i++ )
	{
		if( is_user_connected( players[ i ] ) )
		{
			message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "SayText" ), _, players[ i ] );
			write_byte( players[ i ] );
			write_string( msg );
			message_end( );
		}
	}
}
