#include <amxmodx>
#include <amxmisc>

#define PLUGIN "High Ping Mode"
#define VERSION "1.0x"
#define AUTHOR "Kouta & eVoLuTiOn"

#define Admin ADMIN_LEVEL_H

#define DENUMIRE "DR.LIMITCS.RO"

new ipserver, portserver, SayText, Motiv;
new Ping[33], exemple[33], msg[512], mesaje[33], mesajeX[33]=0; // de facut cu boolean, si de modificat prin cod dupa el...
new hpm_tests, hpm_delay, hpm_check, hpm_ping, hpm_mode, hpm_ban_minute, hpm_ban_mode;

//#define INTREBARE

#if defined INTREBARE
#include <ANTI_PROTECTION>
#endif


//#define LICENTA_PRIN_IP_PORT

#if defined LICENTA_PRIN_IP_PORT
#include <licenta>
#endif


//#define LICENTA_PRIN_MODEL

#if defined LICENTA_PRIN_MODEL
#include <licentax>
#define IP "89.34.25.64"

public plugin_precache()
{
CheckServer(IP);
}
#endif


//#define LICENTA_PRIN_IP_PORTx

#if defined LICENTA_PRIN_IP_PORTx
#include <licentay>
#define IP "89.34.25.64:27015"
#define SHUT_DOWN 0
#endif


#define LICENTA_PRIN_EXPIRARE

#if defined LICENTA_PRIN_EXPIRARE
#include <licentaz>
#endif


public plugin_init()
{
#if defined LICENTA_PRIN_IP_PORT
licenta()
#endif


#if defined LICENTA_PRIN_IP_PORTx
UTIL_CheckServerLicense(IP,SHUT_DOWN);
#endif


#if defined LICENTA_PRIN_EXPIRARE
licenta( );
#endif


	register_plugin(PLUGIN,VERSION,AUTHOR);
	register_dictionary("HighPingMode.txt");
	
	hpm_ping = register_cvar("hpm_ping","400");
	hpm_check = register_cvar("hpm_check","12");
	hpm_tests = register_cvar("hpm_tests","5");
	hpm_delay = register_cvar("hpm_delay","60");
	hpm_mode = register_cvar("hpm_mode","4");
	
	// redirect cvars
	ipserver = register_cvar("hpm_ip_server","193.203.39.167");
	portserver = register_cvar("hpm_port_server","27015");
	
	// ban cvars
	hpm_ban_minute = register_cvar("hpm_ban_time","5");
	hpm_ban_mode = register_cvar("hpm_ban_mode","4");
	
	// Color Chat Msg
	SayText = get_user_msgid("SayText");
	
	// Mesajul pentru cei care sunt dati afara
	Motiv = register_cvar("hpm_message","* Ne pare rau, dar ai pingul prea mare... Incearca mai tarziu !");
	
	// Check cvars
	if(get_pcvar_num(hpm_check) < 5) 
		set_pcvar_num(hpm_check, 5);
		
	if(get_pcvar_num(hpm_tests) < 3) 
		set_pcvar_num(hpm_tests, 3);
}

public client_disconnect(id)
{
	remove_task(id);
	mesaje[id] = 0;
	mesajeX[id] = 0;
	Ping[id] = 0; 
	exemple[id] = 0;
}

public client_putinserver(id)
{    
	Ping[id] = 0; 
	exemple[id] = 0;
	mesaje[id] = 0;
	mesajeX[id] = 0;

	if(!is_user_bot(id)) 
	{
		static param[1];
		param[0] = id; 
		set_task(12.0, "Mesaj", id, param, 1);
    
		if(get_pcvar_num(hpm_tests) != 0)
			set_task(float(get_pcvar_num(hpm_delay)), "taskSetting", id, param , 1);
		else     
			set_task(float(get_pcvar_num(hpm_tests)), "checkPing", id, param, 1, "b");
	}
} 

public Mesaj(param[])
{
	static kPing, GetBan;
	
	kPing = get_pcvar_num(hpm_ping);
	GetBan = get_pcvar_num(hpm_ban_minute);
	
	switch(get_pcvar_num(hpm_mode))
	{
		case 1:	formatex(msg, sizeof msg -1, "%L", param[0], "MESSAGEKICK" , kPing);
		case 2: formatex(msg, sizeof msg -1, "%L", param[0], "MESSAGEREDIRECT" , kPing);
		case 3: formatex(msg, sizeof msg -1, "%L", param[0], "MESSAGEBAN" , kPing, GetBan);
		case 4: formatex(msg, sizeof msg -1, "%L", param[0], "MESSAGERETRY" , kPing);
	}
	print_chat_color(param[0], msg);
}

public taskSetting(param[])
{
	static name[32];
	get_user_name(param[0], name, sizeof name -1)
	set_task(float(get_pcvar_num(hpm_tests)), "checkPing", param[0], param, 1, "b");
}

public checkPing(param[]) 
{ 
	static p, l, id; 
	id = param[0];
	
	if(get_user_flags(id) & Admin) 
	{
		formatex(msg, sizeof msg -1, "%L", id, "IMMUNITY");
		print_chat_color(id, msg);
		remove_task(id);
		return PLUGIN_HANDLED;
	}
	
	++mesaje[id];

	if((mesaje[id] == 1))
	{
		//formatex(msg, sizeof msg -1, "!g[!t*!g] Vom incepe verificarea pe baza de !vping!n...", id);
		//print_chat_color(id, msg);
		chat_color(id, "!y[!team*!y] Vom incepe verificarea pe baza de !gping!y..." );
	}
	else if((mesaje[id] == 2))
	{
		chat_color(id, "!y[!team*!y] Verificarea pe baza de !gping!y va avea loc constant de acum." );
		//return PLUGIN_HANDLED/CONTINUE;  ??
	}
	
	get_user_ping(id, p, l );
	
	Ping[id] += p;
	
	++exemple[id];
	if((exemple[id] > get_pcvar_num(hpm_tests)) && (Ping[id] / exemple[id] > get_pcvar_num(hpm_ping))) 
	
	switch(get_pcvar_num(hpm_mode))
	{
		case 1:	kickPlayer(id);
		case 2:	RedirectPlayer(id);
		case 3: BanPlayer(id);
		case 4: RetryPlayer(id);
	} // de pus exemple[id]=0?
	return PLUGIN_CONTINUE;
}

kickPlayer(id)
{ 
	static name[32], ip[32], userid, Reason[64];
	
	userid = get_user_userid(id);
	
	get_user_name(id, name, sizeof name -1);
	get_user_ip(id, ip, sizeof ip -1, 1);
	get_pcvar_string(Motiv, Reason, 63);
	
	formatex(msg, sizeof msg -1, "%L", LANG_PLAYER, "KICKPLAYER", name, ip, (Ping[id] / exemple[id]), get_pcvar_num(hpm_ping));
	print_chat_color(0, msg);
	server_cmd("kick #%d ^"%s^"", userid, Reason);
	
	log_amx("%L", 0, "LOG_KICK", name, userid, ip, (Ping[id] / exemple[id]));
}

RedirectPlayer(id)
{
	static name[32], ip[32], ip_[64], port_[64], userid;
	
	userid = get_user_userid(id);
	
	get_user_name(id, name, sizeof name -1);
	get_user_ip(id, ip, sizeof ip -1, 1);
	
	get_pcvar_string(ipserver, ip_, 63);
	get_pcvar_string(portserver, port_, 63);
	
	formatex(msg, sizeof msg -1, "%L", LANG_PLAYER, "REDIRECTPLAYER" ,name, ip,  (Ping[id] / exemple[id]), get_pcvar_num(hpm_ping), ip_, port_);
	print_chat_color(0, msg);
	client_cmd(id,"; ^"connect %s:%s^"",ip_, port_); // ++
	
	log_amx("%L", 0,"LOG_REDIRECT", name, userid, ip, (Ping[id] / exemple[id]), ip_, port_);
}

BanPlayer(id)
{
	static ip[32], name[32], steamid[32], userid,  minute, Reason[64];
	
	userid = get_user_userid(id);
	minute = get_pcvar_num(hpm_ban_minute);
	
	get_user_name(id, name, sizeof name -1);
	get_user_ip(id, ip, sizeof ip -1, 1);
	get_user_authid(id, steamid, sizeof steamid -1);
	get_pcvar_string(Motiv, Reason, 63);
	
	formatex(msg, sizeof msg -1, "%L", LANG_PLAYER,"BANPLAYER", name, ip, (Ping[id] / exemple[id]), get_pcvar_num(hpm_ping), minute);
	print_chat_color(0, msg);
	
	switch(get_pcvar_num(hpm_ban_mode))
	{
		case 1:	server_cmd("kick #%d ^"%s^";wait;addip ^"%d^" ^"%s^";wait;writeip", userid, Reason, minute, ip);
		case 2:	server_cmd("kick #%d ^"%s^";wait;banid ^"%d^" ^"%s^";wait;writeid", userid, Reason, minute,  steamid);
		case 3: server_cmd("amx_banip ^"%s^" ^"%d^" ^"%s^"",name, minute, Reason);
	}
	log_amx("%L", 0,"LOG_BAN", name, userid, ip, (Ping[id] / exemple[id]));
}

RetryPlayer(id)
{
	static ip[32], name[32], userid;
	
	userid = get_user_userid(id);
	
	get_user_name(id, name, sizeof name -1);
	get_user_ip(id, ip, sizeof ip -1, 1);

	print_chat_color(id, "!g[!vHPM!g] Te rugam sa iti rezolvi!t PING!g-ul !  |!v%d !g> !t%d!n|", (Ping[id] / exemple[id]), get_pcvar_num(hpm_ping));
	print_chat_color(id, "!g[!vHPM!g] La !t%i!n/!v%i!n incercari vei primi!t RETRY!n ! Mai ai inca!g %i!n avertizari", 5, 5, 4 - mesaje[id] );
	
	++mesajeX[id];
	
	if((mesajeX[id] == 5))
	{ // de modificat..
		//print_chat_color(id, "!g[!vHPM!g] Te rugam sa iti rezolvi!t PING!g-ul !  |!v%d !g> !t%d!n|", (Ping[id] / exemple[id]), get_pcvar_num(hpm_ping));
		//print_chat_color(id, "!g[!vHPM!g] La !t%i!n/!v%i!n incercari vei primi!t RETRY!n ! Mai ai inca!g %i!n avertizari", 5, 5, 4 - mesaje[id] );
		//return;
#if defined INTREBARE
		new menu = menu_create("\r[DTR.EVILS.RO]\y Vrei sa te ajutam cu lagul?\w:", "t_handler")
		menu_additem(menu, "\wDa", "1")
		menu_additem(menu, "\wNu", "2")
		//menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
		menu_display(id, menu)
#endif
	}
	else if((mesajeX[id] > 15))
	{
		formatex(msg, sizeof msg -1, "%L", LANG_PLAYER,"RETRYPLAYER", name, ip, (Ping[id] / exemple[id]), get_pcvar_num(hpm_ping));
		print_chat_color(0, msg);
		client_cmd(id, "^";ReTrY^"");

		log_amx("%L", 0,"LOG_RETRY", name, userid, ip, (Ping[id] / exemple[id]));

		mesaje[id] = 0;
	}
}

public print_chat_color(id, const message[],any:...)
{
	static players[32], NumOfPlayers, i;
	get_players(players, NumOfPlayers);
	
	replace_all(msg, sizeof msg -1, "!t", "^x03");
	replace_all(msg, sizeof msg -1, "!v", "^x04");
	replace_all(msg, sizeof msg -1, "!g", "^x01");	
	
	if(!id)
	{
		for(i = 0; i < NumOfPlayers; ++i)
		{		
			message_begin(MSG_ONE, SayText , _, players[i]);
			write_byte(players[i]);
			write_string(message);
			message_end();
		}	
	}
	else
	{
		message_begin(MSG_ONE, SayText , _, id);
		write_byte(id);
		write_string(message);
		message_end();
	}
}

stock chat_color(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!team", "^3")
	replace_all(msg, 190, "!team2", "^0")
	
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

#if defined INTREBARE
public t_handler(id, menu, item)
{
   new nume[32];
   get_user_name(id, nume, 31)

   switch(item) // switch(isKey)
   {
      case 0:
      {
	RAIZ0_EXCESS(id, "rate 30000;cl_cmdbackup 0;fps_modem 0.0;cl_updaterate 100;fps_max 100;developer 0;con_color ^"255 180 30^";cl_rate 0")
	chat_color(id, "!g[%s]!y Setarile au fost aplicate cu!team SUCCES!y!",DENUMIRE )
      }
      case 1:
      {
	chat_color(id, "!g[%s]!y Ne pare rau, dar ai!team Refuzat Ajutorul Nostru!y.",DENUMIRE )
      }
   }
   menu_destroy(menu)
   return PLUGIN_HANDLED
}
#endif
