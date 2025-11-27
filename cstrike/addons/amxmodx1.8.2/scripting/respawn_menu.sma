#include <amxmodx>
#include <amxmisc>

#define HAM

#if defined HAM
#include <hamsandwich>
#else
#include <cstrike>
#endif

#define PREFIX "[Knife.IrealCS.Ro]"
#define ACCESS ADMIN_SLAY
new bool:g_bStatus=true

// Ghostchat disabled by default
new ghostchat = 2; // Set to let HLTV see alive chat by default.
new gmsgSayText;
new logfilename[256];

public plugin_init()
{
	register_concmd( "amx_emenu", "evo_menu" , ACCESS);
	register_clcmd( "say /emenu", "evo_menu" , ACCESS );
	register_clcmd( "say_team /emenu", "evo_menu" , ACCESS );
#if defined HAM
	RegisterHam(Ham_Killed, "player", "Ham_PlayerKilled", 0);
#endif
	
	register_clcmd("say", "handle_say");
	register_concmd("amx_ghostchat", "handle_ghostchat",-1,"<mode>");
	gmsgSayText = get_user_msgid("SayText");
	server_cmd("sv_alltalk 1")
}

public evo_menu(id)
{
	if(!(get_user_flags(id)&ACCESS))	return PLUGIN_HANDLED
	
	new EMenu,text[192];
	EMenu = menu_create ( "\rEVO\y FCS" , "evo_fcs" );
	
	switch(g_bStatus)
	{
		case true: formatex(text, charsmax(text), "RESPAWN FULL -\y ON")
		case false: formatex(text, charsmax(text), "RESPAWN FULL -\d OFF")
	}
	menu_additem(EMenu, text, "1", ACCESS)
	
	menu_setprop ( EMenu , MPROP_EXIT , MEXIT_ALL );
	menu_display ( id , EMenu,0 );
	
	return 1;
}
public evo_fcs ( id , Menu , Item )
{
	if ( Item < 0 )	return 0;
	
	new Key [ 3 ],Access , CallBack;
	menu_item_getinfo ( Menu , Item , Access , Key , 2 , _ , _ , CallBack );
	new isKey = str_to_num ( Key );
	
	switch ( isKey )
	{
		case 1:
		{
			switch(g_bStatus)
			{
				case true: 
				{
					player_color(id, ".eRespawnul Full.g a fost.v Dezactivat.g !");
					g_bStatus = false;
				}
				case false: 
				{
					player_color(id, ".eRespawnul Full.g a fost.v Activat.g !");
					g_bStatus = true;
				}
			}
		}
	}
	return 1;
}
//public client_putinserver(id)	set_task(0.1,"Respawn_Player", id);
#if !defined HAM
public client_death(killer,victim,wpnindex,hitplace,TK)	set_task(1.0,"Respawn_Player", victim);
#else
public Ham_PlayerKilled(victim, attacker, shouldgib)	set_task(1.0,"Respawn_Player", victim);
#endif
public Respawn_Player(id)
{
	if(is_user_connected(id)&&!is_user_alive(id)&&get_user_team(id)!=3&&
		g_bStatus==true&&get_user_team(id)==2||get_user_team(id)==1)
	{
#if !defined HAM
		cs_user_spawn(id)
#else
		ExecuteHam/*B*/(Ham_CS_RoundRespawn, id);
#endif
	}
}



// Return current setting or set new value
public handle_ghostchat(id,level,cid) {
	
	// No switches given
	if (read_argc() < 2) {
		new status[55];
		if (ghostchat == 1) {
			copy(status, 55, "Dead can read alive");
		}
		else if (ghostchat == 2) {
			copy(status, 55, "Dead and alive can read eachother");
		}
		else if (ghostchat == 3) {
			copy(status, 55, "HLTV can read chat of the living");
		}
		else {
			copy(status, 55, "Disabled");
		}
		client_print(id,print_console,"[AMX] Ghostchat status: %s (NOT TEAMSAY)", status);
		if (cmd_access(id,ADMIN_LEVEL_B,cid,0)) 
			client_print(id,print_console,"[AMX] Ghostchat usage: amx_ghostchat 0(disabled), 1(Dead can read alive), 2(Dead and alive can chat), 3(Only HLTV can read alive)");
		return PLUGIN_HANDLED;
	}
	
	// If you don't have enough rights, you can't change anything
	if (!cmd_access(id,ADMIN_LEVEL_B,cid,0))
		return PLUGIN_HANDLED;
	
	new arg[2];
	read_argv(1,arg,2);
	
	if (equal(arg,"0",1)) {
		ghostchat = 0;
		client_print(0,print_chat,"[AMX] Ghostchat - Plugin has been disabled");
	}
	else if (equal(arg,"1",1)) {
		ghostchat = 1;
		client_print(0,print_chat,"[AMX] Ghostchat - Dead people can read the chat of the living (NOT TEAMSAY)!");
	}
	else if (equal(arg,"2",1)) {
		ghostchat = 2;
		client_print(0,print_chat,"[AMX] Ghostchat - Dead and living people can talk to eachother (NOT TEAMSAY)!");
	}
	else if (equal(arg,"3",1)) {
		ghostchat = 3;
		client_print(0,print_chat,"[AMX] Ghostchat - HLTV can read chat of the living (NOT TEAMSAY)!");
	}
	
	new authid[16],name[32];
	get_user_authid(id,authid,16);
	get_user_name(id,name,32);
	
	log_to_file(logfilename,"Ghostchat: ^"%s<%d><%s><>^" amx_ghostchat %s",name,get_user_userid(id),authid,arg);
	return PLUGIN_HANDLED;
}

public handle_say(id) {
	// If plugin is disabled, skip the code
	if (ghostchat <= 0)
		return PLUGIN_CONTINUE;
	
	// Gather information
	new is_alive = is_user_alive(id);
	new message[129];
	read_argv(1,message,128);
	new name[33];
	get_user_name(id,name,32);
	new player_count = get_playersnum();
	new players[32];
	get_players(players, player_count, "c");
	
	// Clients sometimes send empty messages, or a message containig a '[', ignore those.
	if (equal(message,"")) return PLUGIN_CONTINUE;
	if (equal(message,"[")) return PLUGIN_CONTINUE;
	
	// Response to a specific query
	if (containi(message,"[G]") != -1)
		client_print(id,print_chat,"[AMX] Ghostchat - Type amx_ghostchat in console for current status");
	
	// Format the messages, the %c (2) adds the color. The client decides what color
	// it gets by looking at team.
	if (is_alive) format(message, 127, "%c[G]*ALIVE*%s :    %s^n", 2, name, message);
	else format(message, 127, "%c[G]*DEAD*%s :    %s^n", 2, name, message);
	
	// Check all players wether they should receive the message or not
	for (new i = 0; i < player_count; i++) {
		
		if (is_alive && !is_user_alive(players[i])) {
			// Talking person alive, current receiver dead
			if ((ghostchat == 3 && is_user_hltv(players[i])) || ghostchat <= 2) {
				// Either HLTV mode is enabled and current player is HLTV
				// or one of the other modes is enabled...
				message_begin(MSG_ONE,gmsgSayText,{0,0,0},players[i]);
				write_byte(id);
				write_string(message);
				message_end();
			}
		}
		else if (!is_alive && is_user_alive(players[i]) && ghostchat == 2) {
			// Talking person is dead, current receiver alive
			message_begin(MSG_ONE,gmsgSayText,{0,0,0},players[i]);
			write_byte(id);
			write_string(message);
			message_end();
		}
	}
	return PLUGIN_CONTINUE;
}


stock player_color( const id, const input[ ], any:... )
{
	new count = 1, players[ 32 ]
	
	static msg[ 191 ]
	vformat( msg, 190, input, 3 )
	
	replace_all( msg, 190, ".v", "^4" ) /* verde */
	replace_all( msg, 190, ".g", "^1" ) /* galben */
	replace_all( msg, 190, ".e", "^3" ) /* ct=albastru | t=rosu */
	replace_all( msg, 190, ".x", "^0" ) /* normal-echipa */
	
	if( id ) players[ 0 ] = id; else get_players( players, count, "ch" )
	{
	for( new i = 0; i < count; i++ )
	{
		if( is_user_connected( players[ i ] ) )
		{
			message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "SayText" ), _, players[ i ] )
			write_byte( players[ i ] );
			write_string( msg );
			message_end( );
		}
	}
	}
}
