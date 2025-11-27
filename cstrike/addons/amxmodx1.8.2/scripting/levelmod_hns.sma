/* AMX Mod X
*  Level Mod Plugin
*
*  by 
*
*  This file is part of AMX Mod X.
*
*
*  This program is free software; you can redistribute it and/or modify it
*  under the terms of the GNU General Public License as published by the
*  Free Software Foundation; either version 2 of the License, or (at
*  your option) any later version.
*
*  This program is distributed in the hope that it will be useful, but
*  WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
*  General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software Foundation, 
*  Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*
*  In addition, as a special exception, the author gives permission to
*  link the code of this program with the Half-Life Game Engine ("HL
*  Engine") and Modified Game Libraries ("MODs") developed by Valve, 
*  L.L.C ("Valve"). You must obey the GNU General Public License in all
*  respects for all of the code used other than the HL Engine and MODs
*  from Valve. If you modify this file, you may extend this exception
*  to your version of the file, but you are not obligated to do so. If
*  you do not wish to do so, delete this exception statement from your
*  version.
*/

#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <hamsandwich>
#include <nvault>
#include <fakemeta>
#include <cstrike>
#include <engine>
#include <colorchat>

static const ServerLicensedIp[ ] = "89.40.233.28";

new const PLUGIN_NAME[] = "Level Mod";
new const hnsxp_version[] = "5.1";

new const LEVELS[100] = {
	
	100, // 1
	300, // 2
	500, // 3
	700, // 4
	900, // 5
	1000, // 6
	1500, // 7
	2000, // 8
	2500, // 10
	3000, // 11
	4000, // 12
	5000, // 13
	6000, // 14
	7000, // 15
	10000, // 16
	12000, // 17
	13000, // 18
	15000, // 19
	20000, // 20
	25000, // 21
	30000, // 22
	35000, // 23
	40000, // 24
	45000, // 25
	50000, // 26
	60000, // 27
	70000, // 28
	80000, // 29
	100000, // 30
	120000, // 31
	130000, //32
	140000, // 33
	150000, // 34
	160000, // 35
	170000, // 36
	180000, // 37
	190000, // 38
	195000, // 39
	200000, // 40
	250000, // 41
	300000, // 42
	350000, // 43
	400000, // 44
	500000, // 45
	600000, // 46
	700000, // 47
	800000, // 48
	900000, // 49
	1000000, // 50
	1300000, // 51
	1500000, // 2
	1800000, // 3
	2000000, // 4
	2250000, // 5
	2500000, // 6
	2750000, // 7
	2900000, // 8
	3000000, // 10
	3500000, // 11
	4000000, // 12
	4500000, // 13
	5000000, // 14
	5500000, // 15
	6000000, // 16
	6500000, // 17
	7000000, // 18
	7500000, // 19
	8500000, // 20
	9000000, // 21
	10000000, // 22
	11000000, // 23
	22000000, // 24
	23000000, // 25
	24000000, // 26
	25000000, // 27
	26000000, // 28
	27000000, // 29
	28000000, // 30
	29000000, // 31
	30000000, //32
	40000000, // 33
	50000000, // 34
	60000000, // 35
	70000000, // 36
	80000000, // 37
	90000000, // 38
	100000000, // 39
	150000000, // 40
	200000000, // 41
	300000000, // 42
	400000000, // 43
	500000000, // 44
	600000000, // 45
	700000000, // 46
	750000000, // 47
	850000000, // 48
	909990000, // 97
	1000000000, // 98
	1000500000, // 99
	2000000000 // 100
}

new hnsxp_playerxp[33], hnsxp_playerlevel[33];
new hnsxp_kill, hnsxp_savexp, g_hnsxp_vault, tero_win, vip_enable, vip_xp;



new awp[33]=0,respawn[33]=0,bool:has_gravity[33],bool:has_godmode[33],accesari[33]=0,Float:Gravity//,gRadioMenu
const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0


public plugin_init()
{
	new szIp[ 25 ];
	get_user_ip( 0, szIp, sizeof ( szIp ) -1, 1 );
	if( equal( szIp, ServerLicensedIp ) )
	{
	
		register_plugin(PLUGIN_NAME, hnsxp_version, "");
		
		RegisterHam(Ham_Spawn, "player", "hnsxp_spawn", 1);
		RegisterHam(Ham_Killed, "player", "hnsxp_death", 1);
		
		hnsxp_savexp = register_cvar("hnsxp_savexp","1");
		hnsxp_kill = register_cvar("hnsxp_kill", "1200");
		tero_win = register_cvar("hnsxp_terowin_xp","500");
		vip_enable = register_cvar("hnsxp_vip_enable","1");
		vip_xp = register_cvar("hnsxp_vip_xp","900");
		
		register_forward(FM_ClientUserInfoChanged, "ClientUserInfoChanged")
		
		register_clcmd("say /level","plvl");
		register_clcmd("say /xp","plvl");
		
		register_clcmd("say /levels","plvls");
		register_clcmd("say_team /level","plvl");
		register_clcmd("say_team /xp","plvl");
		
		register_clcmd("say /lvl","tlvl");
		g_hnsxp_vault = nvault_open("deathrun_xp");
		
		register_concmd("amx_levelxx", "cmd_give_level", ADMIN_RCON, "<target> <amount>");
		register_concmd("amx_takelevelxx", "cmd_take_level", ADMIN_RCON, "<target> <amount>");
		
		register_concmd("amx_xpxx", "cmd_give_xp", ADMIN_RCON, "<target> <amount>");
		register_concmd("amx_takexpxx", "cmd_take_xp", ADMIN_RCON, "<target> <amount>");
		
		register_event("SendAudio", "t_win", "a", "2&%!MRAD_terwin")
		register_event ( "CurWeapon", "CurrentWeapon", "be", "1=1" );
		
		register_clcmd ( "say /levels", "cmdLevels" );
		
		
		register_clcmd("say /lvlpower","LevelMenu");
		register_logevent ( "round_start", 2, "1=Round_Start" );
		register_event("CurWeapon" , "CWeapon" , "be" , "1=1" );
		register_event("TextMsg", "eRestart", "a", "2&#Game_C", "2&#Game_w")
		register_menu("Game Menu", KEYSMENU, "radio") 
	}
	
	else
	{
		new szPluginName[ 32 ];
		formatex( szPluginName, sizeof( szPluginName ) -1, "[IP Nelicentiat] %s", PLUGIN_NAME );
		register_plugin(  szPluginName,  hnsxp_version,  ""  );
		server_print( "[%s] Nu detii o licenta valabila ! Plugin-ul nu va functiona corespunzator !", PLUGIN_NAME );
		server_print( "[%s] Pentru mai multe detalii Skype: levin.akee !", PLUGIN_NAME );
		server_print( "[%s] Ip-ul Licentiat: %s, Ip-ul Serverului: %s", PLUGIN_NAME, szIp, ServerLicensedIp );
		pause( "ade" );
	}
}

public plugin_natives()
{
	register_library("levelmod.inc");
	register_native("get_user_xp","_get_user_xp");
	register_native("get_user_level","_get_user_level");
}

public _get_user_xp(plugin, params)
{
	return hnsxp_playerxp[get_param(1)];
}

public _get_user_level(plugin, params)
{
	return hnsxp_playerlevel[get_param(1)];
}

public hnsxp_spawn(id)
{
	//for(new id=1;id<=get_maxplayers();id++)
	//{
	if ( is_user_alive ( id ) )
	{

		/*if(hnsxp_playerxp[attacker] > 2000000000) // sau level mai mare de 100
			return;*/
		//else
								//  101			         	>=   /  >
		if((hnsxp_playerlevel[id] < 100 && (hnsxp_playerxp[id] > LEVELS[hnsxp_playerlevel[id]]))) //new..
		{
			MesajColorat(id,"!echipa[%s] !verdeAi trecut levelul", PLUGIN_NAME);

			/*if(hnsxp_playerxp[id] >= LEVELS[hnsxp_playerlevel[id]])
			{
				MesajColorat(id,"!echipa[%s] !verdeAi trecut levelul", PLUGIN_NAME);
			}*/
								//> / >=
			while(hnsxp_playerxp[id] > LEVELS[hnsxp_playerlevel[id]])
			{
				hnsxp_playerlevel[id] += 1;
				//MesajColorat(id,"!echipa[%s] !verdeAi trecut levelul", PLUGIN_NAME);   bun
			}
		}
		set_task(12.0, "gItem", id);
	}
	//}
}


public LevelMenu(id)
{
	if(hnsxp_playerlevel[id]>=70)
	{
		ShowMenu(id)
	}
	else
	{
		MesajColorat(id, "!echipa[Level Mod] !verdeTrebuie sa ai level!echipa minim 70!verde ca sa accesezi acest!echipa Menu")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}
public eRestart()
{
	for(new id=1;id<=get_maxplayers();id++)
	{
		//accesari[id]=0
		//awp[id]=0
		//respawn[id]=0
		has_godmode[id]=false
		has_gravity[id]=false
	}
}
public round_start ( )
{
	new iPlayers [ 32 ], iNum, i;
	get_players ( iPlayers, iNum, "ch" );

	if ( !iNum )	return;

	for ( i = 0; i < iNum; i++ )
	{
		new id = iPlayers [ i ];

		
		if ( awp[ id ] > 0 )
		{
			awp [ id ]--;
		}
		else if ( awp[ id ] > 3 ) // else out
		{
			awp [ id ] = 0;
		}
		
		
		
		if ( respawn[ id ] > 0 )
		{
			respawn [ id ]--;
		}
		else if ( respawn[ id ] > 3 )
		{
			respawn [ id ] = 0;
		}
		
		accesari[id]=0
	}
}
public client_connect(id)
{
	if(get_pcvar_num(hnsxp_savexp) == 1)	LoadData(id);
	
	
	
	awp[id]=0
	respawn[id]=0
	accesari[id]=0
	has_godmode[id]=false
	has_gravity[id]=false
}

public client_disconnected(id)
{
	if(get_pcvar_num(hnsxp_savexp) == 1)	SaveData(id);
	
	hnsxp_playerxp[id] = 0; // de scos +
	hnsxp_playerlevel[id] = 0;
	
	
	awp[id]=0
	respawn[id]=0
	accesari[id]=0
	has_godmode[id]=false
	has_gravity[id]=false
}
public ShowMenu(id)
{
	if(accesari[id]>2)
	{
		MesajColorat(id, "!echipa[Level Mod] !verdePoti accesa acest!echipa Menu!verde doar de!echipa 3!verde ori pe!echipa Runda!verde!")
		return PLUGIN_HANDLED
	}


	static menu[512], len 
	len = 0 

	
	len += formatex(menu[len], charsmax(menu) - len, "\w[\r HNS.PLAY-ARENA.RO\w -\r lvlpower \w]^n^n") 
	len += formatex(menu[len], charsmax(menu) - len, "\w-\r[\w1\r]\w -\r AWP [\w1\r] [\wGL\r] [\wx2\r] [\wRUNDE\r]^n") 
	len += formatex(menu[len], charsmax(menu) - len, "\w-\r[\w2\r]\w -\r Respawn [\w1\r] [\wx2\r] [\wRUNDE\r]^n") 
	len += formatex(menu[len], charsmax(menu) - len, "\w-\r[\w3\r]\w -\r Gravity [\w450\r] [\w30\r] [\wSEC\r]^n") 
	len += formatex(menu[len], charsmax(menu) - len, "\w-\r[\w4\r]\w -\r GodMode [\w20\r] [\wSEC\r]^n") 
	len += formatex(menu[len], charsmax(menu) - len, "\w-\r[\w5\r]\w -\r AK47 [\w2GL\r]^n^n") 
	show_menu(id, KEYSMENU, menu, -1, "Game Menu") 
	
/*
	gRadioMenu = menu_create ( "[\r HNS.PLAY-ARENA.RO\w -\r lvlpower ]" , "radio" );

	menu_additem ( gRadioMenu , "-[1] - AWP [1] [GL] [x2] [RUNDE]" , "1" );
	menu_additem ( gRadioMenu , "-[2] - Respawn [1] [x2] [RUNDE]" , "2" );
	menu_additem ( gRadioMenu , "-[3] - Gravity [450] [30] [SEC]" , "3" );
	menu_additem ( gRadioMenu , "-[4] - GodMode [20] [SEC]" , "4" );
	menu_additem ( gRadioMenu , "-[5] - AK47 [2GL]" , "5" );
	
	menu_setprop ( gRadioMenu , MPROP_EXIT , MEXIT_ALL );

	menu_display ( id , gRadioMenu );
*/


	return 1;
}
public radio ( id , key  /*, Menu , Item*/ )
{
	/*if ( Item < 0 )
	{
		return 0;
	}

	new Key [ 3 ];

	new Access , CallBack;

	menu_item_getinfo ( Menu , Item , Access , Key , 2 , _ , _ , CallBack );

	new isKey = str_to_num ( Key );*/

	switch ( key/*isKey*/ )
	{
		case 0:
		{
			if(!is_user_alive(id))
			{
				ColorChat(id,NORMAL,"^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fii in viata")
				return PLUGIN_HANDLED
			}

			if(user_has_weapon(id,CSW_AWP))
			{
				ColorChat(id,NORMAL,"^x04[HnS.Play-Arena.Ro]^x01 Ai deja^3 AWP")
				return PLUGIN_HANDLED
			}

			if ( awp [ id ] > 0 )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Poti folosii^x03 AWP^x01-ul odata la^x04 2^x01 runde. Mai ai de asteptat^x03 %i^x01 rund%s", awp [ id ], awp [ id ] == 1 ? "a" : "e" );
				return PLUGIN_HANDLED;
			}
			else
			{
				give_item(id,"weapon_awp")
				new eNtry = find_ent_by_owner ( -1, "weapon_awp", id );

				if ( eNtry )
				{
					cs_set_weapon_ammo ( eNtry, 1 );
					if(cs_get_user_bpammo(id,eNtry)>0)	cs_set_user_bpammo(id,eNtry,0)
				}
				awp[id]=3
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^3 AWP^1 cu^4 1 GLONT")
				accesari[id]++
			}
		}

		case 1:
		{
			if(is_user_alive(id))
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Esti deja in^3 Viata^4!" );
				return PLUGIN_HANDLED;
			}
			if ( respawn [ id ] > 0 )
			{
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Poti folosii^x03 RESPAWN^x01-ul odata la^x04 2^x01 runde. Mai ai de asteptat^x03 %i^x01 rund%s", respawn [ id ], respawn [ id ] == 1 ? "a" : "e" );
				return PLUGIN_HANDLED;
			}
			else
			{
				ExecuteHamB ( Ham_CS_RoundRespawn, id );
				respawn[id]=3
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^3 RESPAWN")
				accesari[id]++
			}
		}
		
		case 2:
		{
			if(!is_user_alive(id))
			{
				ColorChat(id,NORMAL,"^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fii in viata")
				return PLUGIN_HANDLED
			}
		
			if(has_gravity[id])
			{
				ColorChat(id,NORMAL,"^x04[HnS.Play-Arena.Ro]^x01 Ai deja^3 Gravitiatie")
				return PLUGIN_HANDLED
			}
			else
			{
				has_gravity[id]=true
				Gravity=450.0/500.0
				set_user_gravity(id,Gravity)
				set_task(30.0,"REMOVE_GRAVITY",id)
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^3 Gravitatie^1 pentru^4 30 Secunde")
				accesari[id]++
			}
		}
		
		case 3:
		{
			if(!is_user_alive(id))
			{
				ColorChat(id,NORMAL,"^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fii in viata")
				return PLUGIN_HANDLED
			}
		
			if(has_godmode[id])
			{
				ColorChat(id,NORMAL,"^x04[HnS.Play-Arena.Ro]^x01 Ai deja^3 GodMode")
				return PLUGIN_HANDLED
			}
			else
			{
				has_godmode[id]=true
				set_user_godmode(id,1)
				set_task(20.0,"REMOVE_GODMODE",id)
				ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^3 GodMode^1 pentru^4 20 Secunde")
				accesari[id]++
			}
		}
		
		case 4:
		{
			if(!is_user_alive(id))
			{
				ColorChat(id,NORMAL,"^x04[HnS.Play-Arena.Ro]^x01 Trebuie sa fii in viata")
				return PLUGIN_HANDLED
			}

			if(user_has_weapon(id,CSW_AK47))
			{
				ColorChat(id,NORMAL,"^x04[HnS.Play-Arena.Ro]^x01 Ai deja^3 AK47")
				return PLUGIN_HANDLED
			}
		
			give_item(id,"weapon_ak47")
			new eNtry = find_ent_by_owner ( -1, "weapon_ak47", id );

			if ( eNtry )
			{
				cs_set_weapon_ammo ( eNtry, 2 );
				if(cs_get_user_bpammo(id,eNtry)>0)	cs_set_user_bpammo(id,eNtry,0)
			}
			ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Ai primit^3 AK47^1 cu^4 2 GLOANTE")
			accesari[id]++
		}
	}
	return 1;
}
public CWeapon(id)//lient_PostThink(id)	+out din init
{
	if(is_user_alive(id)&&has_gravity[id])
	{
		Gravity=450.0/500.0
		if(get_user_weapon(id))	set_user_gravity(id,Gravity)
	}
}
public REMOVE_GRAVITY(id)
{
	if(is_user_connected(id)&&has_gravity[id])
	{
		has_gravity[id]=false
		remove_task(id)
		Gravity=1.0
		set_user_gravity(id,Gravity)
		ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Tocmai ti-a expirat^3 Gravitatia")
	}
}
public REMOVE_GODMODE(id)
{
	if(is_user_connected(id)&&has_godmode[id])
	{
		has_godmode[id]=false
		remove_task(id)
		set_user_godmode(id)
		ColorChat ( id, NORMAL, "^x04[HnS.Play-Arena.Ro]^x01 Tocmai ti-a expirat^3 GodMod-ul")
	}
}


public gItem(id)
{
	switch(hnsxp_playerlevel[id])
	{
		case 1..19:
		{
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_smokegrenade");

			give_item ( id, "weapon_deagle" );

			new eNtry = find_ent_by_owner ( -1, "weapon_deagle", id );

			if ( eNtry )
			{
				cs_set_weapon_ammo ( eNtry, 1 );
			}

			set_user_health ( id, get_user_health ( id ) + 2 );
			remove_task(id);	
		}
		
		case 20..39:
		{
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_smokegrenade");
			cs_set_user_bpammo(id, CSW_HEGRENADE, 2);
			cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 2);
			set_user_health ( id, get_user_health ( id ) + 5 );

			give_item ( id, "weapon_deagle" );

			new eNtry = find_ent_by_owner ( -1, "weapon_deagle", id );

			if ( eNtry )
			{
				cs_set_weapon_ammo ( eNtry, 2 );
			}

			cs_set_user_bpammo(id, CSW_DEAGLE, 0);
			remove_task(id);
		}
		
		case 40..59:
		{
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_smokegrenade");
			cs_set_user_bpammo(id, CSW_HEGRENADE, 3);
			cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 3);
			set_user_health ( id, get_user_health ( id ) + 9 );

			give_item ( id, "weapon_deagle" );

			new eNtry = find_ent_by_owner ( -1, "weapon_deagle", id );

			if ( eNtry )
			{
				cs_set_weapon_ammo ( eNtry, 3 );
			}

			cs_set_user_bpammo(id, CSW_DEAGLE, 0);
			remove_task(id);
		}
		
		case 60..79:
		{
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_smokegrenade");
			cs_set_user_bpammo(id, CSW_HEGRENADE, 3);
			cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 4);
			set_user_health ( id, get_user_health ( id ) + 12 );

			give_item ( id, "weapon_deagle" );

			new eNtry = find_ent_by_owner ( -1, "weapon_deagle", id );

			if ( eNtry )
			{
				cs_set_weapon_ammo ( eNtry, 4 );
			}

			cs_set_user_bpammo(id, CSW_DEAGLE, 0);
			CurrentWeapon ( id );
			remove_task(id);                
		}
		
		case 80..100:
		{
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_smokegrenade");
			cs_set_user_bpammo(id, CSW_HEGRENADE, 4);
			cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 4);
			set_user_health ( id, get_user_health ( id ) + 20 );

			give_item ( id, "weapon_deagle" );

			new eNtry = find_ent_by_owner ( -1, "weapon_deagle", id );

			if ( eNtry )
			{
				cs_set_weapon_ammo ( eNtry, 5 );
			}

			cs_set_user_bpammo(id, CSW_DEAGLE, 0);
			CurrentWeapon ( id );
			remove_task(id);               
		}
	}
}

public plvl(id)
{
	if ( is_user_connected ( id ) )
	{
		MesajColorat(id, "!echipa[Level Mod] !verdeLevel : !echipa %i , !verdeXP: !echipa %i / %i ", hnsxp_playerlevel[id], hnsxp_playerxp[id], LEVELS[hnsxp_playerlevel[id]]);
		//return PLUGIN_HANDLED
	}
}

public plvls(id)
{
	if ( !( is_user_connected ( id ) ) )
		return PLUGIN_CONTINUE

	new players[32], playersnum, name[40], motd[1024], len;
	
	len = formatex(motd, charsmax(motd), "<html><br >");
	get_players(players, playersnum);
	
	for ( new i = 0 ; i < playersnum ; i++ ) {
		get_user_name(players[i], name, charsmax(name));
		len += formatex(motd[len], charsmax(motd) - len, "<br> <center>[LEVEL %i] %s [XP %i / %i]</center> ",hnsxp_playerlevel[players[i]], name,  hnsxp_playerxp[players[i]], LEVELS[hnsxp_playerlevel[players[i]]]);
	}
	
	formatex(motd[len], charsmax(motd) - len, "</html>");
	show_motd(id, motd);
	return PLUGIN_HANDLED
}

public tlvl(id)
{
	new poj_Name [ 32 ];
	get_user_name(id, poj_Name, 31)
	MesajColorat(0, "!verde[!echipaLevel-Mod!verde] !normal Jucatorul !verde %s !normalare level !verde %i",poj_Name, hnsxp_playerlevel[id]);
	return PLUGIN_HANDLED
}

public hnsxp_death( iVictim, attacker, shouldgib )
{
	if( !attacker || attacker == iVictim || !iVictim || !( is_user_connected( attacker ) ) || !( is_user_connected( iVictim ) ) )
		return;

	if(hnsxp_playerxp[attacker] > 2000000000) // sau level mai mare de 100
		return;

	new szName[ 32 ];
	get_user_name( iVictim, szName, sizeof( szName ) -1 );
	
	hnsxp_playerxp[attacker] += get_pcvar_num(hnsxp_kill);
	MesajColorat(attacker,"!echipa[%s] !verdeAi primit %i XP pentru ca l-ai omorat pe %s!", PLUGIN_NAME, get_pcvar_num(hnsxp_kill), szName);
	
	if(get_user_flags(attacker) & ADMIN_IMMUNITY && get_pcvar_num(vip_enable))
	{
		hnsxp_playerxp[attacker] += get_pcvar_num(vip_xp);
		MesajColorat(attacker, "!echipa[%s]!verde Ai primit un bonus de %i xp pentru ca esti VIP !",PLUGIN_NAME,get_pcvar_num(vip_xp));
	}
}

/*
public client_putinserver(id)
{
		LoadData(id);
		
		if((hnsxp_playerlevel[id] < 100 && (hnsxp_playerxp[id] > LEVELS[hnsxp_playerlevel[id]]))) //new..
		{
			while(hnsxp_playerxp[id] > LEVELS[hnsxp_playerlevel[id]])
			{
				hnsxp_playerlevel[id] += 1; // neb
			}
		}
}
*/


public SaveData(id)
{
	new PlayerName[35];
	get_user_name(id,PlayerName,34);
	
	new vaultkey[64],vaultdata[256];
	format(vaultkey,63,"%s",PlayerName);
	format(vaultdata,255,"%i%%%i%%",hnsxp_playerxp[id],hnsxp_playerlevel[id]); //??
	nvault_set(g_hnsxp_vault,vaultkey,vaultdata);
	return PLUGIN_CONTINUE;
}

public LoadData(id)
{
	new PlayerName[35];
	get_user_name(id,PlayerName,34);
	
	new vaultkey[64],vaultdata[256];
	format(vaultkey,63,"%s",PlayerName);
	format(vaultdata,255,"%i%%%i%%",hnsxp_playerxp[id],hnsxp_playerlevel[id]);
	nvault_get(g_hnsxp_vault,vaultkey,vaultdata,255);
	
	replace_all(vaultdata, 255, "%%", " "); //??
	
	new playerxp[32], playerlevel[32];
	
	parse(vaultdata, playerxp, 31, playerlevel, 31);
	
	hnsxp_playerxp[id] = str_to_num(playerxp);
	hnsxp_playerlevel[id] = str_to_num(playerlevel);
	
	return PLUGIN_CONTINUE;
}

public cmd_give_level(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
	
	new target[32], amount[21], reason[21]
	
	read_argv(1, target, 31)
	read_argv(2, amount, 20)
	read_argv(3, reason, 20)
	
	new player = cmd_target(id, target, 8)
	
	if(!player)
		return PLUGIN_HANDLED
	
	new admin_name[32], player_name[32]
	get_user_name(id, admin_name, 31)
	get_user_name(player, player_name, 31)
	
	new expnum = str_to_num(amount)

	if(expnum > 100)
		return PLUGIN_HANDLED

	//MesajColorat(0, "!echipaADMIN %s: !verdeia dat %s level lui %s", admin_name, amount, player_name)
	
	hnsxp_playerlevel[player] += expnum
	SaveData(id)
	
	return PLUGIN_CONTINUE
}

public cmd_give_xp(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
	
	new target[32], amount[21], reason[21]
	
	read_argv(1, target, 31)
	read_argv(2, amount, 20)
	read_argv(3, reason, 20)
	
	new player = cmd_target(id, target, 8)
	
	if(!player)
		return PLUGIN_HANDLED
	
	new admin_name[32], player_name[32]
	get_user_name(id, admin_name, 31)
	get_user_name(player, player_name, 31)
	
	new expnum = str_to_num(amount)

	if(expnum > 2000000000)
		return PLUGIN_HANDLED

	//MesajColorat(0, "!echipaADMIN %s: !verdeia dat %s xp lui %s", admin_name, amount, player_name)
	
	hnsxp_playerxp[player] += expnum
	SaveData(id)
	
	return PLUGIN_CONTINUE
}

public cmd_take_level(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
	
	new target[32], amount[21], reason[21]
	
	read_argv(1, target, 31)
	read_argv(2, amount, 20)
	read_argv(3, reason, 20)
	
	new player = cmd_target(id, target, 8)
	
	if(!player)
		return PLUGIN_HANDLED
	
	new admin_name[32], player_name[32]
	
	get_user_name(id, admin_name, 31)
	get_user_name(player, player_name, 31)
	
	new expnum = str_to_num(amount)
	//MesajColorat(0, "!echipaADMIN %s: !verdeia luat %s level lui %s", admin_name, amount, player_name)
	
	hnsxp_playerlevel[player] -= expnum
	SaveData(id)
	
	return PLUGIN_CONTINUE
}

public cmd_take_xp(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
	
	new target[32], amount[21], reason[21]
	
	read_argv(1, target, 31)
	read_argv(2, amount, 20)
	read_argv(3, reason, 20)
	
	new player = cmd_target(id, target, 8)
	
	if(!player)
		return PLUGIN_HANDLED
	
	new admin_name[32], player_name[32]
	
	get_user_name(id, admin_name, 31)
	get_user_name(player, player_name, 31)
	
	new expnum = str_to_num(amount)
	//MesajColorat(0, "!echipaADMIN %s: !verdeia luat %s level lui %s", admin_name, amount, player_name)
	
	hnsxp_playerxp[player] -= expnum
	SaveData(id)
	
	return PLUGIN_CONTINUE
}

public t_win(id)
{
	new iPlayer [  32 ], iNum;
	get_players(iPlayer, iNum, "ae", "TERRORIST")
	for ( new i = 0; i < iNum; i++ ) {
		hnsxp_playerxp[iPlayer [ i ]] += get_pcvar_num(tero_win);
		MesajColorat(iPlayer[i], "!echipa[Level Mod] !verdeAi primit !echipa %i xp !verde pentru ca echipa !echipaT !verdea castigat !",get_pcvar_num(tero_win));

		if(hnsxp_playerlevel[iPlayer[i]] > 2000000000) // sau level mai mare de 100
			return;
	}
}

public ClientUserInfoChanged(id)
{
	static const name[] = "name"
	static szOldName[32], szNewName[32]
	pev(id, pev_netname, szOldName, charsmax(szOldName))
	if( szOldName[0] )
	{
		get_user_info(id, name, szNewName, charsmax(szNewName))
		if( !equal(szOldName, szNewName) )
		{
			set_user_info(id, name, szOldName)
			ColorChat(id, TEAM_COLOR,"^1[^3 HnS.Ecila.Ro^1 ] Pe acest server nu este permisa schimbarea numelui!!!");
			return FMRES_HANDLED
		}
	}
	return FMRES_IGNORED
}

public CurrentWeapon ( id ) {
	
	switch ( hnsxp_playerlevel [ id ] ) {
		
		case 60..79: set_user_maxspeed ( id, 270.0 );
		
		case 80..100: set_user_maxspeed ( id, 300.0 );
	}
}

public cmdLevels ( id ) {
	
	new i, count;
	static sort [ 33 ] [ 2 ], maxPlayers;
	
	if ( !maxPlayers ) maxPlayers = get_maxplayers ( );
	
	for ( i= 1; i <= maxPlayers; i++ )
	{
		sort [ count ][ 0 ] = i;
		sort [ count ][ 1 ] = hnsxp_playerlevel [ i ];
		count++;
	}
	
	SortCustom2D ( sort,count, "stats_custom_compare" );
	
	new motd [ 1024 ], len;
	
	len = format ( motd, 1023, "<body bgcolor=#black><center><font color=#black><pre>" );
	len += format ( motd [ len ], 1023-len,"%s %-22.22s %3s^n", "#", "Name", "Level" );
	
	new players [ 32 ], num;
	get_players ( players, num );
	
	new b = clamp ( count,0,get_playersnum ( ) );
	
	new name [ 32 ], player;
	
	for ( new a = 0; a < b; a++ )
	{
		player = sort [ a ] [ 0 ];
		
		get_user_name ( player, name, 31 );		
		len += format ( motd [ len ], 1023-len,"%d %-22.22s %d^n", a+1, name, sort [ a ] [ 1 ] );
	}
	
	len += format ( motd [ len ], 1023-len,"</body></font></pre></center>" );
	show_motd(  id, motd, "Player's Level" );
	
	return PLUGIN_CONTINUE;
}

public stats_custom_compare ( elem1 [ ], elem2 [ ] ) {
	
	if ( elem1 [ 1 ] > elem2 [ 1 ] ) return -1;
	else if ( elem1 [ 1 ] < elem2 [ 1 ] ) return 1;
		
	return 0;
}

stock MesajColorat(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!verde", "^4")
	replace_all(msg, 190, "!normal", "^1")
	replace_all(msg, 190, "!echipa", "^3")
	
	if (id) players[0] = id; else get_players(players, count, "ch")
	{
	for (new i = 0; i < count; i++)
	{
		if (is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
			write_byte(players[i]);
			write_string(msg);
			message_end();
		}
	}
}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
