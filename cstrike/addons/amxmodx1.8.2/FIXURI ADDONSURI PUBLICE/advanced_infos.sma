// de facut o caracteristica, sa zica si prima data de cand a inceput sa joace pe server...E AIUREA

#include <amxmodx>
#include <amxmisc>
#include <nvault>
#include < geoip >//nou

#pragma compress 1

#define EVO

enum
{
	MIN = 1,
	HOURS = 60,
	DAYS = 1440
}

const TIME_HANDLED = 97;

#define CONFIGURATION_FILE "advanced_account.ini"
#define LOG_FILE "account_register.log"
#define LOG_DEVELOPER "account_developer.log"

#define flag_get(%1,%2)	(%1 & (1 << (%2 & 31)))
#define flag_set(%1,%2)	%1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))

#define TASK_MINUTES 10101
#define ID_MINUTES (taskid - TASK_MINUTES)

new g_minutes[33], g_name[33][33], g_developeridt[33], g_loaded, g_isregistered, g_isdeveloper,
g_nvaultsave, g_msg_saytext, g_maxplayers, g_fw_load_pre, g_fw_load_post, bool:g_settings_loaded = false,
g_hours_need, tag_string[32], Array:g_developer, db_name[32], g_access_flag, field[10], ptime,content[192],ip[25], g_authid[33][65],
HostName[65];



new vault,chour[6],cmin[6],cday[6],cm[6],cyear[6],ctime[32] //  CURRENT TIME
new hrs,shour[6],smin[6],sday[6],sm[6],syear[6],value[128],sip[32] // STORED DATA



#define INFO_ZERO 0
#define NTOP 10
#define TIME 180.0
new topminutes[33],topnames[33][33],topauth[33][65],Data[64],Buffer[256],path[128],f



//#define LICENTA_PRIN_IP_PORT

#if defined LICENTA_PRIN_IP_PORT
#include <licenta>
#endif


//#define LICENTA_PRIN_MODEL

#if defined LICENTA_PRIN_MODEL
#include <licentax>
#define IP "89.34.25.64"

public plugin_precache()	CheckServer(IP);
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


	register_plugin("Advanced Infos", "2.2x", "cyby & S.Cosmin");//Adryyy force
	
	register_clcmd("say /slot", "slot_cmd");
	register_clcmd("say_team /slot", "slot_cmd");
	register_clcmd("say /res", "slot_cmd");
	register_clcmd("say_team /res", "slot_cmd");
	register_clcmd("say /reserv", "slot_cmd");
	register_clcmd("say_team /reserv", "slot_cmd");
	register_clcmd("say /reserve", "slot_cmd");
	register_clcmd("say_team /reserve", "slot_cmd");
	register_clcmd("say /reserved", "slot_cmd");
	register_clcmd("say_team /reserved", "slot_cmd");

	register_clcmd("say", "handleSay")
	register_clcmd("say_team", "handleSay")

	register_clcmd("PASSWORD_SLOT", "password_for_slot");
	register_clcmd("ADD_MINUTES", "add_developer_min");
	register_clcmd("REM_MINUTES", "rem_developer_min");

	register_clcmd("say /ored", "developer_menu");
	register_clcmd("say_team /ored", "developer_menu");
	register_clcmd("say /timpd", "developer_menu");
	register_clcmd("say_team /timpd", "developer_menu");
	register_clcmd("say /timed", "developer_menu");
	register_clcmd("say_team /timed", "developer_menu");
	
	g_maxplayers = get_maxplayers();
	g_msg_saytext = get_user_msgid("SayText");
	g_fw_load_pre = CreateMultiForward("get_loadtime_pre", ET_IGNORE, FP_CELL);
	g_fw_load_post = CreateMultiForward("get_loadtime_post", ET_IGNORE, FP_CELL);

	register_concmd( "amx_times", "FuncCommandTime", ADMIN_BAN, "- Vezi playerii depe server si timpul lor" );

	register_dictionary( "played_time.txt" );

	get_cvar_string("hostname",HostName,charsmax(HostName));


	register_clcmd("say /pttop", "show_top");
	register_clcmd("say /toptime", "show_top");
	register_clcmd("say /toptimes", "show_top");
	register_clcmd("say /tt", "show_top");
	register_clcmd("say /topore", "show_top");
	register_clcmd("say_team /pttop", "show_top");
	register_clcmd("say_team /toptime", "show_top");
	register_clcmd("say_team /toptimes", "show_top");
	register_clcmd("say_team /tt", "show_top");
	register_clcmd("say_team /topore", "show_top");


	register_concmd("amx_removetop", "remove_info", ADMIN_RCON);
	register_concmd("amx_topore", "show_top");


	register_cvar("msg_topup","0")
	register_cvar("msg_lastvisit","0")
	register_cvar("sounds_lastvisit","0")
	register_cvar("msgs_lastvisit","0")
	vault=nvault_open("last_visited")
	set_time()



	get_datadir(Data, 63);
	read_top();
}

public remove_info(id,level,cid)  {
	if(!cmd_access(id,level,cid,1)) {
       		return PLUGIN_HANDLED;
	}

	new target[32];
    	read_argv(1, target, 31);

	new poz = str_to_num(target);
	if( !poz|| poz > 10 || poz < 1) {
		console_print(id,"[AMXX]: Foloseste amx_removetop <pozitie>, de la 1 la 10 !");
       		return PLUGIN_HANDLED;
	}
	
	if(equal(topnames[poz-1],"")) {
		console_print(id,"[AMXX]: Nu se afla nimeni pe aceasta pozitie !");
		color(id, ".v%s.g Nu se afla nimeni pe aceasta pozitie !",tag_string);
		return PLUGIN_HANDLED;
	}

	color(0, ".v%s.g Adminul.e %s.g il sterge din top.v %d.g ore pe.e %s.g !",tag_string,g_name[id],NTOP,topnames[poz-1]);

	static i;
	for (i= poz-1;i<NTOP;i++) {
		formatex(topnames[i], 32, topnames[i+1]);
		formatex(topauth[i], 64, topauth[i+1]);
		topminutes[i] = topminutes[i+1];
		
		save_top();
	}
	
	return PLUGIN_HANDLED;
}

public plugin_cfg()
{
	g_developer = ArrayCreate(32, 32);
	load_conf_extern_files();
	set_task(1.0, "take_nvault");

}

public take_nvault()
{
	g_nvaultsave = nvault_open(db_name);
	
	if(g_nvaultsave == INVALID_HANDLE)	set_fail_state("[Advanced Infos] Eroare la deschiderea nVault...");
		
	for(new i = 0; i <= g_maxplayers; i++)
	{
		if(!is_user_connected(i)||is_user_bot(i)||is_user_hltv(i))	continue;
			
		takedata(i);
	}
}

public load_conf_extern_files()
{
	g_settings_loaded = false;
	new szFile[ 500 ], flags[32];
	get_localinfo( "amxx_configsdir", szFile, sizeof ( szFile ) -1 );
	format( szFile, sizeof ( szFile ) -1, "%s/%s", szFile, CONFIGURATION_FILE );
	if( !file_exists( szFile ) )
	{
		write_file( szFile, "[Setari Rezervare] (setari care sunt preluate la fiecare schimbare de harta fara a fi nevoita modificata sursa)", -1 );
		write_file( szFile, "HOURS = 10", -1 );
		write_file( szFile, "TAG = [AMXX]", -1 );
		write_file( szFile, "DEVELOPER = eVoLuTiOn", -1 );
		write_file( szFile, "NVAULT NAME = hours_played", -1 );
		write_file( szFile, "FLAG REGISTER = b", -1 );
		write_file( szFile, "FIELD = _pw", -1 );
		write_file( szFile, "", -1 );
		write_file( szFile, "// ca sa mai adaugi developeri, separi cu virgula, deci nu ai voie sa adaugi developeri cu virgula la nume", -1 );
		write_file( szFile, "// pentru a dezactiva /slot , modifica la  HOURS <= 0", -1 ); // sau off/dezactivat/etc..
	}
	g_hours_need = native_load_setting_int(CONFIGURATION_FILE, "Setari Rezervare", "HOURS");
	native_load_setting_string(CONFIGURATION_FILE, "Setari Rezervare", "TAG", tag_string, charsmax(tag_string));
	native_load_setting_string_arr(CONFIGURATION_FILE, "Setari Rezervare", "DEVELOPER", g_developer);
	native_load_setting_string(CONFIGURATION_FILE, "Setari Rezervare", "NVAULT NAME", db_name, charsmax(db_name));
	native_load_setting_string(CONFIGURATION_FILE, "Setari Rezervare", "FLAG REGISTER", flags, charsmax(flags));
	g_access_flag = read_flags(flags);
	native_load_setting_string(CONFIGURATION_FILE, "Setari Rezervare", "FIELD", field, charsmax(field));

	server_print("[Advanced Infos] Setarile au fost preluate cu succes.");
	g_settings_loaded = true;
}

public set_time(){
	get_time("%H",chour,charsmax(chour)) 	// Hours
	get_time("%M",cmin,charsmax(cmin)) 	// Minutes
	get_time("%d",cday,charsmax(cday))	// Day
	get_time("%m",cm,charsmax(cm))	// Mounth
	get_time("%Y",cyear,charsmax(cyear))	// Year
	get_time("%H:%M:%S - %m/%d/%Y",ctime,charsmax(ctime)) // the time
}

public plugin_natives()
{
	register_native("get_registered", "native_get_registered", 1);
	register_native("get_developer", "native_get_developer", 1);
	register_native("get_playedtime", "native_get_string_time", 1);
	register_native("get_loadedtime", "native_get_loadedtime", 1);
	register_native("get_inttime", "native_get_int_time", 1);

	register_native("get_pt", "native_get_pt", 1);
}

public native_get_pt(id)	return g_minutes[id]

public native_get_registered(id)
{
	if(!flag_get(g_loaded, id))	return false;
	
	if(flag_get(g_isregistered, id))	return true;
	
	return false;
}
public native_get_developer(id)
{
	if(!flag_get(g_loaded, id))	return false;
	
	if(flag_get(g_isdeveloper, id))	return true;
	
	return false;
}
public native_get_string_time(plugin_id, param_nums)
{
	if(param_nums != 3)	return -1;
	
	new id = get_param(1), time_played[32];
	if(!flag_get(g_loaded, id))	return -1;
	
	formatex(time_played, charsmax(time_played), "%s", convert_minutes(id));
	set_string(2, time_played, get_param(3));
	return 1;
}
public native_get_loadedtime(id)
{
	if(flag_get(g_loaded, id))	return true;
	
	return false;
}
public native_get_int_time(id, what)
{
	if(!flag_get(g_loaded, id))	return -1;
	
	if(what == MIN)	return g_minutes[id];
	
	new extract = 0, int_min = g_minutes[id];
	
	while(int_min >= what)
	{
		extract++;
		int_min -= what;
	}
	
	return extract;
}

public plugin_end()
{
	nvault_close(g_nvaultsave);

	nvault_close(vault)
}
	
public client_putinserver(id)
{
	if(is_user_bot(id)||is_user_hltv(id)/*||!is_user_connected(id)*/)	return

	get_user_name(id, g_name[id], charsmax(g_name[]));
	get_user_authid(id, g_authid[id], charsmax(g_authid[]));
	if( g_authid[id][ 7 ] != ':'||
		(g_authid[id][0]=='S'&&g_authid[id][1]=='T'&&g_authid[id][2]=='E'&&g_authid[id][3]=='A'&&g_authid[id][4]=='M'&&g_authid[id][5]=='_'&&g_authid[id][6]!='0') )
			formatex( g_authid[id], charsmax( g_authid[] ), "Non-Steam" )

	set_time()
	set_task(5.0,"check_data",id) // start it now!


	set_task(TIME,"RefreshTime",id,_,_,"b");


	if(!g_settings_loaded)	return;

	set_register(id);
	set_developer(id);
	g_developeridt[id] = 0;

	/*if(is_user_alive(id))
	{
		new dummy;
		ExecuteForward(g_fw_load_pre, dummy, id);
		if(dummy >= TIME_HANDLED)	return;

		ExecuteForward(g_fw_load_post, dummy, id);
	}*/

	flag_set(g_loaded, id);
	takedata(id);
	set_task(60.0, "increase_minutes", id+TASK_MINUTES, _, _, "b");
}

public RefreshTime(id) {
	checkandupdatetop(id,g_minutes[id]);
	return PLUGIN_HANDLED;
}

public client_disconnect(id)
{
	if(!g_settings_loaded||is_user_bot(id)||is_user_hltv(id))	return;

	g_developeridt[id] = 0;
	flag_unset(g_isregistered, id)
	flag_unset(g_isdeveloper, id)
	savedata(id);
}

public check_data(id){
	set_time()
	
	if(get_cvar_num("msgs_lastvisit")==1)	greet_messages(id)
	if(get_cvar_num("sounds_lastvisit")==1)	greet_sounds(id)
/*
	if(nvault_get(vault,g_name[id])==0)	color(id, ".v%s.g Deja te joci de 1 ora..nu uita sa mai iei o pauza",tag_string)
	else
	{
	nvault_get(vault,g_name[id],value,charsmax(value))
	parse(value,shour,charsmax(shour),smin,charsmax(smin),sday,charsmax(sday),sm,charsmax(sm),syear,charsmax(syear))
	color(id, ".v%s.g Ultima ta vizita >>.e %s.g:.e%s.g -.v %s.g/.e%s.g/.v%s",tag_string,shour,smin,sm,sday,syear)
	}
*/
	save_data(id)
}
public greet_messages(id){
	hrs=str_to_num(chour)
	set_time()
	
	if(hrs<12){
		color(id, ".v%s.g Neatza.e %s.g! Bun venit pe.v %s",tag_string,g_name[id],HostName)
	}else if(hrs<=16){
		color(id, ".v%s.g Amiaza placuta %s.g! Bun venit pe.v %s",tag_string,g_name[id],HostName)
	}else if(hrs<=23){
		color(id, ".v%s.g Buna seara %s.g! Bun venit pe.v %s",tag_string,g_name[id],HostName)
	}else if(hrs<=03){
		color(id, ".v%s.g Seara faina %s.g! Bun venit pe.v %s",tag_string,g_name[id],HostName)
	}else{
		color(id, ".v%s.g Salut %s.g! Bun venit pe.v %s",tag_string,g_name[id],HostName)
	}
	color(id, ".v%s.g TIMP CRUENT -.e %s",tag_string,HostName)
}
public greet_sounds(id){
	hrs=str_to_num(chour)
	
	new morningsounds[2][]={
		"^"scientist/c1a0_sci_gm(e55)^"",
		"^"scientist/c1a0_sci_gm1(e60)^""
	}
	new afternoonsounds[5][]={
		"scientist/goodtoseeyou",
		"scientist/greetings",
		"scientist/greetings2",
		"^"scientist/hellofreeman(e35)^"",
		"scientist/hellothere"
	}
	new evningsounds[3][]={
		"scientist/hellothere",
		"scientist/greetings",
		"scientist/c1a0_sci_itsyou"
	}

	if(hrs<=12)	client_cmd(id,"spk %s",morningsounds[random_num(0,1)])
	else if(hrs<=16)	client_cmd(id,"spk %s",afternoonsounds[random_num(0,4)])
	else if(hrs<=23)	client_cmd(id,"spk %s",evningsounds[random_num(0,2)])
}
public save_data(id){
	new cip[32]
	get_user_ip(id,cip,charsmax(cip))
	set_time()
	formatex(value,charsmax(value),"%s %s %s %s %s %s",chour,cmin,cday,cm,cyear,cip)
	nvault_set(vault,g_name[id],value) // store by NAME
}

public FuncCommandTime( iPlayer, iLevel, iCid )
{
	if( !cmd_access( iPlayer, iLevel, iCid, 1 ) )
	{
		return PLUGIN_HANDLED;
	}

	new iUser, szCountry[ 32 ],szCity[32], flags, sflags[ 32 ];

	console_print( iPlayer, "[  %L - %L - IP - STEAMID - TARA/ORAS - FLAGS  ]", iPlayer, "CON_NAME_X", iPlayer, "CON_TIME_X" );
	console_print( iPlayer, "" );
	
	for( iUser = 1; iUser <= 32; iUser++ )
	{
		if( is_user_connected( iUser ) && !is_user_bot( iUser ) && !is_user_hltv( iUser ) )
		{
			get_user_ip( iUser, ip, sizeof( ip ) -1, 1 );
			geoip_country( ip, szCountry, sizeof( szCountry ) -1 );
			geoip_city( ip, szCity, sizeof( szCity ) -1 );

			flags = get_user_flags( iUser );
			get_flags( flags, sflags, 31 );

			console_print( iPlayer, "[  %s - %s - %s - %s/%s - %s  ]", g_name[iUser], convert_minutes(iUser), g_authid[iUser], szCountry,szCity, sflags )
		}
	}
	
	return PLUGIN_HANDLED;
}

public slot_cmd(id)
{
	if(g_hours_need<=0/*||equali(g_hours_need,"off")!=-1||equali(g_hours_need,"dezactivat")!=-1*/)
	{
		color(id, ".v%s.g Functia.e /SLOT.g este.v DEZACTIVATA.g !", tag_string);
		return PLUGIN_HANDLED;
	}

	if(flag_get(g_isregistered, id)||is_user_admin(id))
	{
		color(id, ".v%s.g Deja ai.e CONT.g rezervat.", tag_string);
		return PLUGIN_HANDLED;
	}

	if(containi(g_name[id],HostName)!=-1)
	{
		color(id, ".v%s.g Nu poti luat slot pe acest.e NICK.g!", tag_string);
		return PLUGIN_HANDLED;
	}
	
	if((g_minutes[id] / 60) < g_hours_need)
	{
		color(id, ".v%s.g Ai nevoie de.e %d.g ore pentru.v cont.g! Timp acumulat pana acum:.e %s", tag_string, g_hours_need, convert_minutes(id));
		return PLUGIN_HANDLED;
	}
	else
	{
		client_cmd(id, "messagemode PASSWORD_SLOT");
		color(id, ".v%s.g Parola trebuie sa fie de.e MA.gxim 20 si.v MI.gnim 3 caractere!", tag_string);
		color(id, ".v%s.g Ti-a aparut.e SUS.g loc pentru a scrie.v P.garola!", tag_string);
		color(id, ".v%s.g In caz ca, gresesti, apasa tasta.e ESC.g!", tag_string);
	}
	return PLUGIN_HANDLED;
}

new const CMMDS[][]=
{
"/ore",
"/timp",
"/time",
"/played",
"/play"
}

public handleSay(id)
{
	new args[64]
	read_args(args, charsmax(args))
	remove_quotes(args)
	
	new arg1[16],arg2[32]
	strbreak(args, arg1, charsmax(arg1), arg2, charsmax(arg2))

	for(new i;i<sizeof CMMDS;i++)	if (equal(arg1,CMMDS[i]/*, strlen(CMMDS[i])*/)/*!=-1*/)	timeplayed_cmd(id, arg2)
}

public timeplayed_cmd(id,arg[])
{
	new to[32]
	parse(arg,to,charsmax(to))

	if( equal(to[0],"") )
	{
		ptime = get_user_time(id, 1) / 60;
		color(id, ".v%s.g Hey.e %s.g, ai jucat pana acum.v %d.g minut%s", tag_string,g_name[id], ptime, ptime == 1 ? "" : "e");
		if(!flag_get(g_loaded, id))
		{
			color(id, ".v%s.g Ne pare rau, dar inca nu am putut sa-ti preluam timpul jucat!", tag_string);
			return PLUGIN_HANDLED;
		}
		else
		{
		color(id, ".v%s.g Si ai un total de.e %s.g!", tag_string,convert_minutes(id));
		if(get_cvar_num("msg_lastvisit")==1)
		{
		if(nvault_get(vault,g_name[id])!=0)
		{
		nvault_get(vault,g_name[id],value,charsmax(value))
		parse(value,shour,charsmax(shour),smin,charsmax(smin),sday,charsmax(sday),sm,charsmax(sm),syear,charsmax(syear),sip,charsmax(sip))
		color(id, ".v%s.g Ultima vizita >>.e %s.g:.v%s.g -.e %s.g/.v%s.g/.e%s",tag_string,shour,smin,sday,sm,syear)
		color(id, ".v%s.g a fost de pe IP`ul:.e %s",tag_string,sip)
		}
		}
		}
	}
	else
	{
	new player = cmd_target( id, to, 8 );

	if( /*!is_user_connected( player ) ||*/ !player )
	{
		color( id, ".g[.v AMXX .g> .eTIMP .g] Nu am putut identifica cererea ta." );
		return 1;
	}

	ptime = get_user_time(player, 1) / 60;
	color(id, ".v%s.e %s.g a jucat pana acum.v %d.g minut%s!", tag_string,g_name[player], ptime, ptime == 1 ? "" : "e");

	if(!flag_get(g_loaded, player))
	{
		color(id, ".v%s.g Ne pare rau, dar inca nu am putut sa-i preluam timpul jucat lu'.e %s.g!", tag_string, g_name[player]);
		return PLUGIN_HANDLED;
	}
	else	color(id, ".v%s.e %s.g a jucat in total.v %s.g!", tag_string, g_name[player], convert_minutes(player));
	}
	return PLUGIN_HANDLED;
}


public read_top() {
	formatex(path, 127, "%s/TopOre.dat", Data);
	
	f = fopen(path, "rt");
	new i = INFO_ZERO;
	while( !feof(f) && i < NTOP+1)
	{
		fgets(f, Buffer, 255);
		new minutes[125];
		parse(Buffer, topnames[i], 32, topauth[i], 64, minutes, 124);
		topminutes[i]= str_to_num(minutes);
		
		i++;
	}
	fclose(f);
}
public save_top() {
	formatex(path, 127, "%s/TopOre.dat", Data);
	if( file_exists(path) ) {
		delete_file(path);
	}
	f = fopen(path, "at");
	for(new i = INFO_ZERO; i < NTOP; i++)
	{
		formatex(Buffer, 255, "^"%s^" ^"%s^" ^"%d^"^n",topnames[i],topauth[i], topminutes[i] );
		fputs(f, Buffer);
	}
	fclose(f);
}
public checkandupdatetop(id, minutes) {
	for (new i = INFO_ZERO; i < NTOP; i++)
	{
		if(minutes > topminutes[i])
		{
			new pos = i;	
			while( !equal(topnames[pos],g_name[id]) && pos < NTOP )	pos++;
			
			for (new j = pos; j > i; j--)
			{
				formatex(topnames[j], 32, topnames[j-1]);
				formatex(topauth[j], 64, topauth[j-1]);
				topminutes[j] = topminutes[j-1];
			}
			formatex(topnames[i], 32, g_name[id]);
			formatex(topauth[i], 64, g_authid[id]);
			
			topminutes[i] = minutes;
			if(get_cvar_num("msg_topup")==1)	color(0, ".v%s.g Topul de ore a fost actualizat!.e %s.g este pe locul.v %i.g in Top.e%d.gOre cu.v %s.g timp jucat.",tag_string, g_name[id],(i+1),NTOP,convert_minutes(minutes));	
			save_top();
			break;
		}
		else if( equal(topnames[i], g_name[id])) 
		break;	
	}
}
public show_top(id) {	
	static buffer[2368], name[131], len, i;
	len = format(buffer[len], 2367-len,"<STYLE>body{background:#232323;color:#cfcbc2;font-family:sans-serif}table{border-style:solid;border-width:1px;border-color:#FFFFFF;font-size:13px}</STYLE><table align=center width=100%% cellpadding=2 cellspacing=0");
	len += format(buffer[len], 2367-len, "<tr align=center bgcolor=#52697B><th width=4%% > # <th width=24%%> Nume Jucator <th width=24%%> SteamID <th width=24%%> Minute");	
	for( i = INFO_ZERO; i < NTOP; i++ ) {
			if( topminutes[i] == 0) {
				len += format(buffer[len], 2367-len, "<tr align=center bgcolor=#232323><td> %d <td> %s <td> %s <td> %s", (i+1), "-", "-", "-");
				//i = NTOP
			}
			else {
				name = topnames[i];
				while( containi(name, "<") != -1 )	replace(name, 129, "<", "&lt;");
				while( containi(name, ">") != -1 )	replace(name, 129, ">", "&gt;");

				if(equal(topnames[i],g_name[id]))	len += format(buffer[len], 2367-len, "<tr align=center bgcolor=#2D2D2D><td> %d <td> %s <td> %s <td> %d", (i+1), name,topauth[i], topminutes[i]);
				else	len += format(buffer[len], 2367-len, "<tr align=center bgcolor=#232323><td> %d <td> %s <td> %s <td> %d", (i+1), name,topauth[i], topminutes[i]);
			}
		}
	len += format(buffer[len], 2367-len, "</table>");
	len += formatex(buffer[len], 2367-len, "<tr align=bottom font-size:11px><Center><br><br>Primii %d Jucatori Cu Cele Mai Multe Ore Acumulate</Center></tr></body>",NTOP);
	static strin[125];
	format(strin,124, "Top %d ore jucate",NTOP);
	show_motd(id, buffer, strin);
}

public developer_menu(id)
{
	if(!flag_get(g_isdeveloper, id))
	{
		color(id, ".v%s.g Nu te afli printre.e Developeri.g !", tag_string);
		return PLUGIN_CONTINUE;
	}
	
	new menu = menu_create("\rDeveloper Menu", "developer_handler");
	menu_additem(menu, "\yAdd minutes", "");
	menu_additem(menu, "\yRemove Minutes", "");
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public developer_handler(id, menu, item)
{
	if(!flag_get(g_isdeveloper, id))
	{
		color(id, ".v%s.g Nu te afli printre.e Developeri.g !", tag_string);
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item)
	{
		case 0: open_addmin(id);
		case 1: open_remmin(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public open_addmin(id)
{
	if(!flag_get(g_isdeveloper, id))
	{
		color(id, ".v%s.g Nu te afli printre.e Developeri.g !", tag_string);
		return PLUGIN_HANDLED;
	}
		
	new menu = menu_create("\yAdauga minute la jucatori", "add_minutes"), menu_item[100], userid[32];
	for(new i = 1; i <= g_maxplayers; i++)
	{
		if(!is_user_connected(i) || !flag_get(g_loaded, i))	continue;
	
		formatex(menu_item, charsmax(menu_item), "\r%s - \y%s", g_name[i], convert_minutes(i));
		formatex(userid, charsmax(userid), "%d", get_user_userid(i));
		menu_additem(menu, menu_item, userid, 0);
	}
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public add_minutes(id, menu, item)
{
	if(!flag_get(g_isdeveloper, id))
	{
		color(id, ".v%s.g Nu te afli printre.e Developeri.g !", tag_string);
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new menu_data[6], menu_name[64], _access, item_callback;
	menu_item_getinfo(menu, item, _access, menu_data, charsmax(menu_data), menu_name, charsmax(menu_name), item_callback);
	new userid = str_to_num(menu_data);
	new player = find_player("k", userid);
	if(player)
	{
		client_cmd(id, "messagemode ADD_MINUTES");
		g_developeridt[id] = player;
		color(id, ".v%s.g L-ai selectat pe.e %s.g!", tag_string, g_name[player]);
	}
	else
	{
		color(id, ".v%s.g Jucatorul nu exista!", tag_string);
		g_developeridt[id] = 0;
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public open_remmin(id)
{
	if(!flag_get(g_isdeveloper, id))
	{
		color(id, ".v%s.g Nu te afli printre.e Developeri.g !", tag_string);
		return PLUGIN_HANDLED;
	}
		
	new menu = menu_create("\yAdauga minute la jucatori", "rem_minutes"), menu_item[100], userid[32];
	for(new i = 1; i <= g_maxplayers; i++)
	{
		if(!is_user_connected(i) || !flag_get(g_loaded, i))	continue;
	
		formatex(menu_item, charsmax(menu_item), "\r%s - \y%s", g_name[i], convert_minutes(i));
		formatex(userid, charsmax(userid), "%d", get_user_userid(i));
		menu_additem(menu, menu_item, userid, 0);
	}
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public rem_minutes(id, menu, item)
{
	if(!flag_get(g_isdeveloper, id))
	{
		color(id, ".v%s.g Nu te afli printre.e Developeri.g !", tag_string);
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new menu_data[6], menu_name[64], _access, item_callback;
	menu_item_getinfo(menu, item, _access, menu_data, charsmax(menu_data), menu_name, charsmax(menu_name), item_callback);
	new userid = str_to_num(menu_data);
	new player = find_player("k", userid);
	if(player)
	{
		client_cmd(id, "messagemode REM_MINUTES");
		g_developeridt[id] = player;
		color(id, ".v%s.g L-ai selectat pe.e %s.g!", tag_string, g_name[player]);
	}
	else
	{
		color(id, ".v%s.g Jucatorul nu exista!", tag_string);
		g_developeridt[id] = 0;
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public add_developer_min(id)
{
	if(!flag_get(g_isdeveloper, id))
	{
		color(id, ".v%s.g Nu te afli printre.e Developeri.g !", tag_string);
		g_developeridt[id] = 0;
		return PLUGIN_HANDLED;
	}
	
	if(!is_user_connected(g_developeridt[id]) || !flag_get(g_loaded, g_developeridt[id]))
	{
		color(id, ".v%s.g Jucatorul care l-ai selectat a parasit serverul!", tag_string);
		g_developeridt[id] = 0;
		return PLUGIN_HANDLED;
	}
	
	new amount[16];
	read_args(amount, charsmax(amount));
	remove_quotes(amount);
	new much = str_to_num(amount);
	if(much <= 0)
	{
		color(id, ".v%s.g Suma introdusa este mai mica sau egala cu 0!", tag_string);
		g_developeridt[id] = 0;
		return PLUGIN_HANDLED;
	}
	g_minutes[g_developeridt[id]] += much;
	color(0, ".v%s.g Developer.e %s.g ii adauga lu'.v %s.e %d minut%s.g!", tag_string, g_name[id], g_name[g_developeridt[id]], much, much == 1 ? "" : "e");
	color(g_developeridt[id], ".v%s.g Developer.e %s.g ti-a adaugat.v %d minut%s.g!", tag_string, g_name[id], much, much == 1 ? "" : "e");
	log_developer(id, g_developeridt[id], much, 1);
	g_developeridt[id] = 0;
	return PLUGIN_HANDLED;
}

public rem_developer_min(id)
{
	if(!flag_get(g_isdeveloper, id))
	{
		color(id, ".v%s.g Nu te afli printre.e Developeri.g !", tag_string);
		g_developeridt[id] = 0;
		return PLUGIN_HANDLED;
	}
	
	if(!is_user_connected(g_developeridt[id]) || !flag_get(g_loaded, g_developeridt[id]))
	{
		color(id, ".v%s.g Jucatorul care l-ai selectat a parasit serverul!", tag_string);
		g_developeridt[id] = 0;
		return PLUGIN_HANDLED;
	}
	
	new amount[16];
	read_args(amount, charsmax(amount));
	remove_quotes(amount);
	new much = str_to_num(amount);
	if(much <= 0)
	{
		color(id, ".v%s.g Suma introdusa este mai mica sau egala cu 0!", tag_string);
		g_developeridt[id] = 0;
		return PLUGIN_HANDLED;
	}
	if(much > g_minutes[g_developeridt[id]])
	{
		color(id, ".v%s.g Suma introdusa este mai mare decat cea pe care.e %s.g o are!", tag_string, g_name[g_developeridt[id]]);
		g_developeridt[id] = 0;
		return PLUGIN_HANDLED;
	}
	g_minutes[g_developeridt[id]] -= much;
	color(0, ".v%s.g Developer.e %s.g ii scade lu'.v %s.e %d minut%s.g!", tag_string, g_name[id], g_name[g_developeridt[id]], much, much == 1 ? "" : "e");
	color(g_developeridt[id], ".v%s.g Developer.e %s.g ti-a scazut.v %d minut%s.g!", tag_string, g_name[id], much, much == 1 ? "" : "e");
	log_developer(id, g_developeridt[id], much, 2);
	g_developeridt[id] = 0;
	return PLUGIN_HANDLED;
}

public client_infochanged(id)
{
	if(is_user_bot(id)||is_user_hltv(id)||!is_user_connected(id))	return

	new name[33]
	get_user_info(id, "name", name, charsmax(name));

	if(!(equali(name, g_name[id])))
	{
		savedata(id);
		formatex(g_name[id], charsmax(g_name[]), "%s", name); // fara astea next
		//copy( g_name[ id ], sizeof ( g_name[ ] ) -1, name );
		takedata( id );
		set_register(id);
		set_developer(id);

		if( equali( g_name[id], HostName ) )	show_menu( id, 0, "^n", 1 );
	}
}

public password_for_slot(id)
{
	new password[32];
	read_args(password, charsmax(password));
	//remove_quotes(password);
	if(!check_string(password))
	{
		color(id, ".v%s.g Parola nu respecta regulile!", tag_string);
		return PLUGIN_HANDLED;
	}

	if(equali(g_name[id],HostName))
	{
		color(id, ".v%s.g Nu poti inregistra acest.e NICK.g!", tag_string);
		return PLUGIN_HANDLED;
	}
	register_slot(id, password);
	return PLUGIN_HANDLED;
}

public increase_minutes(taskid)
{
	if( !is_user_connected(ID_MINUTES)/*||!flag_get(g_loaded, ID_MINUTES)*/||g_hours_need<=0||is_user_bot(ID_MINUTES)||
	is_user_hltv(ID_MINUTES))	return// PLUGIN_HANDLED;

	g_minutes[ID_MINUTES]++;

	if((g_minutes[ID_MINUTES] / 60) >= g_hours_need && !flag_get(g_isregistered, ID_MINUTES)&&!is_user_admin(ID_MINUTES) )
	{
		color(ID_MINUTES, ".v%s.g Salut! Se pare ca ai peste.e %d.g ore jucate, si iti poti activa.v CONTUL.g! Ore necesare pt. CONT(.e%d.g)!", tag_string, g_hours_need, g_hours_need);
		//return PLUGIN_CONTINUE;
		//return
	}

	//return PLUGIN_CONTINUE
}
	
public takedata(id) 
{
	if(/*!flag_get(g_loaded, id)||*/!is_user_connected(id)||is_user_bot(id)||is_user_hltv(id))	return;
	
	new vaultkey[32], vaultdata[256], minutes[32];
	formatex(vaultkey, charsmax(vaultkey), "%s", g_name[id]);
	formatex(vaultdata, charsmax(vaultdata), "^"%i^"", g_minutes[id]);
	nvault_get(g_nvaultsave, vaultkey, vaultdata, charsmax(vaultdata));
	parse(vaultdata, minutes, charsmax(minutes));
	g_minutes[id] = str_to_num(minutes);
}

public savedata(id)
{
	if(/*!flag_get(g_loaded, id)||*/is_user_bot(id)||is_user_hltv(id))	return;
	
	new vaultkey[32], vaultdata[256];
	formatex(vaultkey, charsmax(vaultkey), "%s", g_name[id]);
	formatex(vaultdata, charsmax(vaultdata), "^"%i^"", g_minutes[id]);
	nvault_set(g_nvaultsave, vaultkey, vaultdata);
	//g_minutes[id] = 0;
	//flag_unset(g_loaded, id)
	remove_task(id+TASK_MINUTES);
}

public register_slot(id, const password[])
{
	if(equali(g_name[id],HostName))
	{
		color(id, ".v%s.g Nu poti inregistra acest.e NICK.g!", tag_string);
		return;
	}
	if(flag_get(g_isregistered,id)||is_user_admin(id))
	{
		color(id, ".v%s.g Acest.e NICK.g este deja.v INREGISTRAT.n!", tag_string);
		return;
	}
	new line[192], configsdir[128], flag[32];
	get_flags(g_access_flag, flag, charsmax(flag));
	formatex(line, charsmax(line), "^"%s^" ^"%s^" ^"%s^" ^"a^" ; cont activat pt. %d ore", g_name[id], password, flag, g_hours_need); // ore%s??
	
	get_configsdir(configsdir, charsmax(configsdir));
	formatex(configsdir, charsmax(configsdir), "%s/users.ini", configsdir);
	write_file(configsdir, line);
	color(id, ".v%s.g Ti-ai activat.e Contul.g pentru.v %d.g ore de joc!", tag_string, g_hours_need);
	color(id, ".v%s.g Parola ta este:.e %s.g!", tag_string, password);
	color(id, ".v%s.g Foloseste.e setinfo %s %s.g!", tag_string, field, password);
	set_user_info(id, field, password);
	color(0, ".v%s.g Felicitari lui.e %s.g! Si-a activat Contul pentru.v %d ore jucate.g!", tag_string, g_name[id], g_hours_need);
	log_slot(id);
	flag_set(g_isregistered, id)
	server_cmd("amx_reloadadmins");
}

stock convert_minutes(id)
{
	new szminutes[32]
	//if(is_user_connected(id))
	//{
	new len = 0, days, hours, actual_minutes = g_minutes[id];

	while(actual_minutes >= 1440)
	{
		days++;
		actual_minutes -= 1440;
	}
	while(actual_minutes >= 60)
	{
		hours++;
		actual_minutes -= 60;
	}

	if(days > 0)	len += formatex(szminutes[len], charsmax(szminutes) - len, "%d zi%s ", days, days == 1 ? "" : "le");
	if(hours > 0)	len += formatex(szminutes[len], charsmax(szminutes) - len, "%d or%s ", hours, hours == 1 ? "a" : "e");
		
	if(actual_minutes > 0)	len += formatex(szminutes[len], charsmax(szminutes) - len, "%d minut%s", actual_minutes, actual_minutes == 1 ? "" : "e");
	if(!days && !hours && actual_minutes == 0)	len += formatex(szminutes[len], charsmax(szminutes) - len, "0 minute");
	//}
	return szminutes;
}

stock bool:check_string(const string[])
{
	new len = strlen(string);
	if(len < 3)	return false;
	if(len > 15)	return false;
		
	new bool:isntright = false;
	for(new i = 1; i <= len; i++)
	{
		if(!is_letter(string[i]))
		{
			isntright = true;
			break;
		}
	}

	if(isntright)	return false;

	return true;
}
stock bool:is_letter(u)
{
	if(u >= 65 || u <= 90)	return true;
	if(u >= 97 || u <= 122)	return true;
	
	return false;
}

stock color(const id, const input[], any:...)
{
	new count = 1, players[32];
	static msg[191]
	vformat(msg, charsmax(msg), input, 3)
	
	replace_all(msg, charsmax(msg), ".v", "^4")
	replace_all(msg, charsmax(msg), ".g", "^1")
	replace_all(msg, charsmax(msg), ".e", "^3")
	
	if(id) players[0] = id; else get_players(players, count, "ch")
	{
		for (new i = 0; i < count; i++)
		{
			if(is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, g_msg_saytext, _, players[i])
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}

stock set_developer(id)
{
	flag_unset(g_isdeveloper, id)

	new name[32]
	for(new i = 0; i < ArraySize(g_developer); i++)
	{
		ArrayGetString(g_developer, i, name, charsmax(name));
		if(equali(g_name[id], name))
		{
			flag_set(g_isdeveloper, id)
			break;
		}
	}
}

stock set_register(id)
{
	if(!is_user_connected(id))	flag_unset(g_isregistered, id)
	
	if(get_user_flags(id) & g_access_flag)	flag_set(g_isregistered, id)
	else	flag_unset(g_isregistered, id)
}

stock log_slot(id)
{
	get_user_ip(id, ip, charsmax(ip), 1);
	formatex(content, charsmax(content), "%s [IP: %s | STEAM: %s] si-a inregistrat numele. Timp acutal - %s", g_name[id], ip, g_authid[id], convert_minutes(id));
	log_to_file(LOG_FILE, content);
}

stock log_developer(admin, id, time, type)
{
	get_user_ip(admin, ip, charsmax(ip), 1);
	
	switch(type)
	{
		case 1: formatex(content, charsmax(content), "Developer: %s [IP: %s | STEAM: %s] ii ofera %d minut%s lui %s. [timp total: %s]", g_name[admin], ip, g_authid[admin], time, time == 1 ? "" : "e", g_name[id], convert_minutes(id));
		case 2: formatex(content, charsmax(content), "Developer: %s [IP: %s | STEAM: %s] ii scoate %d minut%s lui %s. [timp total: %s]", g_name[admin], ip, g_authid[admin], time, time == 1 ? "" : "e", g_name[id], convert_minutes(id));
	}
	log_to_file(LOG_DEVELOPER, content);
}

// Credite MeRcyLeZZ - pentru https://forums.alliedmods.net/showthread.php?t=243202
public native_load_setting_int(const filename[], const section[], const key[])
{
	// Open file for read
	new path[64], file, file_name[64];
	formatex(file_name, charsmax(file_name), "%s", filename);
	OpenCustomFileRead(path, charsmax(path), file_name, file);
	
	new section_str[64]
	formatex(section_str, charsmax(section_str), "%s", section);
	SectionExists(file, section_str)
	
	// Try to find key in section
	new keypos_start, keypos_end, key_str[64];
	formatex(key_str, charsmax(key_str), "%s", key);
	KeyExists(file, key_str, keypos_start, keypos_end);
	
	new value[16];
	SeekReturnValues(file, keypos_start, value, charsmax(value));
	new valoare = str_to_num(value);
	
	return valoare;
}

public native_load_setting_string(const filename[], const section[], const key[], setting_string[], len)
{
	// Open file for read
	new path[64], file, file_str[64];
	formatex(file_str, charsmax(file_str), "%s", filename);
	OpenCustomFileRead(path, charsmax(path), file_str, file)
	
	// Try to find section
	new section_str[64];
	formatex(section_str, charsmax(section_str), "%s", section);
	SectionExists(file, section_str)
	
	// Try to find key in section
	new keypos_start, keypos_end, key_str[64];
	formatex(key_str, charsmax(key_str), "%s", key);
	KeyExists(file, key_str, keypos_start, keypos_end);
	
	// Return string by reference
	new value[128]
	SeekReturnValues(file, keypos_start, value, charsmax(value))
	formatex(setting_string, len, "%s", value);
	
	// Value succesfully retrieved
	fclose(file);
	return true;
}

public native_load_setting_string_arr(const filename[], const section[], const key[], Array:array_handle)
{
	// Open file for read
	new path[64], file, file_str[64];
	formatex(file_str, charsmax(file_str), "%s", filename);
	if (!OpenCustomFileRead(path, charsmax(path), file_str, file))
		return false;
	
	// Try to find section
	new section_str[64];
	formatex(section_str, charsmax(section_str), "%s", section);
	if (!SectionExists(file, section_str))
	{
		fclose(file)
		return false;
	}
	
	// Try to find key in section
	new keypos_start, keypos_end, key_str[64];
	formatex(key_str, charsmax(key_str), "%s", key);
	if (!KeyExists(file, key_str, keypos_start, keypos_end))
	{
		fclose(file)
		return false;
	}
	
	// Return array
	new values[1024]
	SeekReturnValues(file, keypos_start, values, charsmax(values))
	ParseValuesArrayString(values, charsmax(values), array_handle)
	
	// Values succesfully retrieved
	fclose(file)
	return true;
}

OpenCustomFileRead(path[], len1, filename[], &file, create = false)
{	
	// Build customization file path
	get_configsdir(path, len1)
	format(path, len1, "%s/%s", path, filename)
	
	// File not present, create new file?
	if (!file_exists(path))
	{
		if (create)	write_file(path, "", -1)
		else	return false;
	}
	
	// Open customization file for reading
	file = fopen(path, "rt")
	if(!file)	return false;
	
	return true;
}

SectionExists(file, setting_section[])
{
	// Seek to setting's section
	new linedata[96], section[64]	
	while (!feof(file))
	{
		// Read one line at a time
		fgets(file, linedata, charsmax(linedata))
		
		// Replace newlines with a null character
		replace(linedata, charsmax(linedata), "^n", "")
		
		// New section starting
		if (linedata[0] == '[')
		{
			// Store section name without braces
			copyc(section, charsmax(section), linedata[1], ']')
			
			// Is this our setting's section?
			if (equal(section, setting_section))	return true;
		}
	}
	
	return false;
}

KeyExists(file, setting_key[], &keypos_start, &keypos_end)
{
	// Seek to setting's key
	new linedata[96], key[64]
	while (!feof(file))
	{
		// Read one line at a time
		keypos_start = ftell(file)
		fgets(file, linedata, charsmax(linedata))
		
		// Replace newlines with a null character
		replace(linedata, charsmax(linedata), "^n", "")
		
		// Blank line or comment
		if (!linedata[0] || linedata[0] == ';') continue;
		
		// Section ended?
		if (linedata[0] == '[')	break;
		
		// Get key
		keypos_end = ftell(file)
		copyc(key, charsmax(key), linedata, '=')
		trim(key)
		
		// Is this our setting's key?
		if (equal(key, setting_key))	return true;
	}
	
	return false;
}

SeekReturnValues(file, keypos_start, values[], len1)
{
	// Seek to key and parse it
	new linedata[1024], key[64]
	fseek(file, keypos_start, SEEK_SET)
	fgets(file, linedata, charsmax(linedata))
	
	// Replace newlines with a null character
	replace(linedata, charsmax(linedata), "^n", "")
	
	// Get values
	strtok(linedata, key, charsmax(key), values, len1, '=')
	trim(values)
}

ParseValuesArrayString(values[], len1, Array:array_handle)
{
	// Parse values
	new current_value[128]
	while (values[0] != 0 && strtok(values, current_value, charsmax(current_value), values, len1, ','))
	{
		// Trim spaces
		trim(current_value)
		trim(values)
		
		// Add to array
		ArrayPushString(array_handle, current_value)
	}
}
