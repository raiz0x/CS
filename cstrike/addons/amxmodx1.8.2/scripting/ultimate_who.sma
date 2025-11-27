#include <amxmodx>
#include <amxmisc>

#include <colorchat>

#pragma semicolon 1

#define INSERT_COLOR_TAGS(%1) \
{ \
    replace_all( %1, charsmax( %1 ), "!g", "^x04" ); \
    replace_all( %1, charsmax( %1 ), "!t", "^x03" ); \
    replace_all( %1, charsmax( %1 ), "!n", "^x01" ); \
    replace_all( %1, charsmax( %1 ), "!y", "^x01" ); \
}

#define checkvipflags(%1) format(vipflags, sizeof(vipflags)-1, "%s%s", GroupFlags[%1], vip_flag)

// ============= Aici se modifica ===============

#define GROUPS 8 // Aici modificati in functie de cate graduri aveti pe server
#define vip_flag "t" // flag-ul pentru vip
#define allvipflags "bit" // toate flagurile vipului in caz in care aveti free vip pe server sa apara doar vipii adevarati in /vips

new GroupNames[GROUPS][ ] = {
	"Founder",
	"Owner",
	"Co-Owner",
	"GoD",
	"Moderator",
	"Administrator",
	"Helper",
	"V.I.P"
};

new GroupFlags[GROUPS][ ] = {
	"abcdefghijklmnopqrstu",
	"abcdefghijlmnopqrstu",
	"bcdefghijlmnopqrstu",
	"bcdefghijmnopq",
	"cdefijmnopq",
	"cdefijmno",
	"cdefijm",
	"bit"
};

// ========= De aici nu mai modificati daca nu va pricepeti ============

new const Dictionary[19][] = {
	"ONLINE_ADMIN",
	"CONSOLE_END",
	"MOTD_TITLE",
	"ADMINS_ONLINE",
	"VIPS_ONLINE",
	"NOADMIN_ONLINE",
	"NOVIP_ONLINE",
	"MENU_TITLE",
	"SIMPLE_PLAYER",
	"DEAD_PLAYER",
	"T_TEAM",
	"CT_TEAM",
	"SPEC_TEAM",
	"CONSOLE_MID",
	"WHO_MENU_TITLE",
	"WHO_DISABLED",
	"WHO_CHAT_DISABLED",
	"CONSOLE_NO_ADMIN_ONLINE",
	"MENU_NO_ADMIN_ONLINE"
};

new who_type, console_active, chat_active, chat_show_admins, chat_show_vips, motd_bg_color,
motd_font_color_groups, motd_font_color_names, colorchat_active, colorchat_tags, colorchat_tags_adm_only;
new bool:whomotd=false, bool:whomenu=false, bool:whoconsole=false;
new vipflags[32];

public plugin_init( )  {
	register_plugin("Ultimate Who (Imbunatatit)", "1.0", "Marcelinho"); // P.Of.Pw original
	register_cvar("Whoisthere", "Marcelinho", FCVAR_SERVER | FCVAR_SPONLY);
	
	register_clcmd("say", "handle_say");
	register_clcmd("say_team", "handle_teamsay");
	
	register_concmd("amx_who", "whoConsole");
	register_concmd("admin_who", "whoConsole");
	register_concmd("who", "whoConsole");
	
	register_message(get_user_msgid ("SayText"), "noDuplicate");
	
	register_dictionary_colored("who.txt");
	
	who_type		= register_cvar("who_type", "3"); // Apartententa [/who] - 1=MOTD | 2=Meniu | 3=Amandoua
	console_active		= register_cvar("console_active_en", "1"); // Comanda amx_who (1=Activata|0=Dezactivata) + apartenenta la [/who]
	chat_active		= register_cvar("who_chat_en", "1"); // Comanda [/who] (1=Activata|0=Dezactivata)
	chat_show_admins	= register_cvar("who_chat_show_admins", "1"); // Comanda [/admins] (1=Activata|0=Dezactivata)
	chat_show_vips		= register_cvar("who_chat_show_vips", "1"); // Comanda [/vips] (1=Activata|0=Dezactivata)
	motd_bg_color		= register_cvar("who_motd_bgcolor", "black"); // Culoarea de background la MOTD (nume culoare sau cod HEX)
	motd_font_color_groups	= register_cvar("who_motd_fontcolor_groups", "red"); // Culoarea fontului la MOTD pentru gruparile de admini (nume culoare sau cod HEX)
	motd_font_color_names	= register_cvar("who_motd_fontcolor_names", "yellow"); // Culoarea fontului la MOTD pentru numele adminilor (nume culoare sau cod HEX)
	colorchat_active	= register_cvar("colorsay_en", "1"); // Chat-ul va fi colorat (1=ON|0=OFF)
	colorchat_tags		= register_cvar("colorsay_tags_en", "1"); // In chat apare un TAG in fata numelui in functie de gradul persoanei care scrie (1=ON|0=OFF)
	colorchat_tags_adm_only = register_cvar("colorsay_tags_only_adm", "0"); // Cei care vor avea tag-uri in chat sunt doar adminii (1=ON|0=OFF)
}
public handle_say(id) {
	new txt[128];
	read_args(txt, sizeof(txt)-1);
	
	if(containi(txt, "who") != -1 || contain(txt, "/who") != -1)
		if(get_pcvar_num(chat_active))
			set_task(0.1, "cmdWho", id);
		
	if(containi(txt, "admins") != -1 || contain(txt, "/admins") != -1)
		if(get_pcvar_num(chat_show_admins))
			set_task(0.1, "showAdmins", id);
		
	if(containi(txt, "vips") != -1 || contain(txt, "/vips") != -1)
		if(get_pcvar_num(chat_show_vips))
			set_task(0.1, "showVips", id);
			
	if(!get_pcvar_num(colorchat_active))
		return 0;
	
	new msg[192], dead[16], bool:admin[32];
	format(dead, sizeof(dead)-1, "%L", LANG_SERVER, Dictionary[9]);
	remove_quotes(txt);
	
	if (txt[0] == '@' || txt[0] == '/' || txt[0] == '!' || equal (txt, ""))
		return 1;
		
	new tName[32];
	get_user_name (id, tName, sizeof(tName)-1);
	
	for(new k=0; k<GROUPS; k++) {
		checkvipflags(k);
		if(get_pcvar_num(colorchat_tags)) {
			if(get_user_flags(id) == read_flags(GroupFlags[k]) || get_user_flags(id) == read_flags(vipflags)) {
				admin[id]=true;
				format(msg, sizeof(msg)-1, "^x01%s^x04 [%s] ^x03 %s:^x04 %s", is_user_alive(id) ? "" : dead, GroupNames[k], tName, txt);
			}
			else if(!admin[id]) {
				if(get_pcvar_num(colorchat_tags_adm_only)) format(msg, sizeof(msg)-1, "^x01%s^x03 %s:^x01 %s", is_user_alive(id) ? "" : dead, tName, txt);
				else format(msg, sizeof(msg)-1, "^x01%s ^x04[%L] ^x03 %s:^x01 %s", is_user_alive(id) ? "" : dead, LANG_SERVER, Dictionary[8], tName, txt);
			}
		}
		else {
			if(get_user_flags(id) == read_flags(GroupFlags[k]) || get_user_flags(id) == read_flags(vipflags))
				admin[id] = true;
				
			format(msg, sizeof(msg)-1, "^x01%s^x03 %s:%s %s", is_user_alive(id) ? "" : dead, tName, admin[id] ? "^x04" : "^x01", txt);
		}
	}
	
	for(new i=0; i<get_maxplayers( ); i++) {
		if(!is_user_connected(i))
			continue;
			
		message_begin(MSG_ONE, get_user_msgid("SayText"), {0, 0, 0}, i);
		write_byte(id);
		write_string(msg);
		message_end( );
	}
	
	return 1;
}

public handle_teamsay(id) {
	new txt[128], team[25], dead[16];
	format(dead, sizeof(dead)-1, "%L", LANG_SERVER, Dictionary[9]);
	read_args(txt, sizeof(txt)-1);
			
	if(!get_pcvar_num(colorchat_active))
		return 0;
	
	switch(get_user_team(id)) {
		case 1: format(team, sizeof(team)-1, "%L", LANG_SERVER, Dictionary[10]);
		case 2: format(team, sizeof(team)-1, "%L", LANG_SERVER, Dictionary[11]);
		default: format(team, sizeof(team)-1, "%L", LANG_SERVER, Dictionary[12]);
	}
	
	new msg[192];
	remove_quotes(txt);
	
	if (txt[0] == '@' || txt[0] == '/' || txt[0] == '!' || equal (txt, ""))
		return 1;
		
	new tName[32], bool:admin[32];
	get_user_name (id, tName, sizeof(tName)-1);
	
	for(new k=0; k<GROUPS; k++) {
		checkvipflags(k);
		if(get_pcvar_num(colorchat_tags)) {
			if(get_user_flags(id) == read_flags(GroupFlags[k]) || get_user_flags(id) == read_flags(vipflags)) {
				admin[id] = true;
				format(msg, sizeof(msg)-1, "^x01%s ^x04[%s] ^x03 %s (%s):^x04 %s", is_user_alive(id) ? "" : dead, GroupNames[k], tName, team, txt);
			}
			else if(!admin[id]) {
				if(get_pcvar_num(colorchat_tags_adm_only)) format(msg, sizeof(msg)-1, "^x01%s^x03 %s (%s):^x01 %s", is_user_alive(id) ? "" : dead, tName, team, txt);
				else format(msg, sizeof(msg)-1, "^x01%s ^x04[%L] ^x03 %s (%s):^x01 %s", is_user_alive(id) ? "" : dead, LANG_SERVER, Dictionary[8], tName, team, txt);
			}
		}
		else {
			if(get_user_flags(id) == read_flags(GroupFlags[k]) || get_user_flags(id) == read_flags(vipflags))
				admin[id]=true;
			
			format(msg, sizeof(msg)-1, "^x01%s^x03 %s (%s):%s %s", is_user_alive(id) ? "" : dead, tName, team, admin[id] ? "^x04" : "^x01", txt);
		}
	}
	
	for(new i=0; i<get_maxplayers( ); i++) {
		if(!is_user_connected(i))
			continue;
		
		if(get_user_team(id) == get_user_team(i)) {	
			message_begin(MSG_ONE, get_user_msgid("SayText"), {0, 0, 0}, i);
			write_byte(id);
			write_string(msg);
			message_end( );
		}
	}
	
	return 1;
}

public cmdWho(id) {
	if(get_pcvar_num(who_type)==1 || get_pcvar_num(who_type)==3)  whomotd=true;
	if(get_pcvar_num(who_type)==2 || get_pcvar_num(who_type)==3) whomenu=true;
	if(get_pcvar_num(console_active)) whoconsole=true;
	
	new title[64], disabled[64], item1[64], item2[64], item3[64];
	
	format(title, sizeof(title)-1, "%L", LANG_SERVER, Dictionary[14]);
	format(disabled, sizeof(disabled)-1, "%L", LANG_SERVER, Dictionary[15]);
	
	format(item1, sizeof(item1)-1, "%sMOTD %s", whomotd ? "\r" : "\d", whomotd ?  "" : disabled);
	format(item2, sizeof(item2)-1, "%sMenu %s", whomenu ? "\r" : "\d", whomenu ? "" : disabled);
	format(item3, sizeof(item3)-1, "%sConsole %s", whoconsole ? "\r" : "\d", whoconsole ? "" : disabled);
	
	new menu = menu_create(title, "whoHandler");
	
	menu_additem(menu, item1);
	menu_additem(menu, item2);
	menu_additem(menu, item3);
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu);
}

public whoHandler(id, menu, item) {
	if (!(item == MENU_EXIT)) {
		switch (item) {
			case 0: {
				if(!whomotd) {
					ColorChat(id, BLUE, "%L", LANG_SERVER, Dictionary[16]);
					return 1;
				}
					
				set_task(0.1, "whoMotd", id);
			}
			case 1: {
				if(!whomenu) {
					ColorChat(id, BLUE, "%L", LANG_SERVER, Dictionary[16]);
					return 1;
				}
				
				set_task(0.1, "whoMenu", id);
			}
			case 2: {
				if(!whoconsole) {
					ColorChat(id, BLUE, "%L", LANG_SERVER, Dictionary[16]);
					return 1;
				}
				
				client_cmd(id, "toggleconsole");
				set_task(0.1, "whoConsole", id);
			}
		}
	}
	
	menu_destroy(menu );
	return 1;
}
public whoMenu(id) {
	new iPlayers[32], admName[32], iNum;
	new Menu[256], iLen, count;
	
	iLen = format(Menu[iLen], sizeof(Menu)-1, "%L^n^n", LANG_SERVER, Dictionary[7]);
	get_players(iPlayers, iNum);
   
	for(new k=0; k<GROUPS; k++) {
		checkvipflags(k);
		for(new i=0; i<iNum; i++) {
			if(get_user_flags(iPlayers[i]) == read_flags(GroupFlags[k]) || get_user_flags(iPlayers[i]) == read_flags(vipflags)) {
				get_user_name(iPlayers[i], admName, sizeof(admName)-1);
				iLen += format(Menu[iLen], sizeof(Menu)-iLen-1, "\w%s : \r%s%s^n", GroupNames[k], admName, get_user_flags(iPlayers[i]) & read_flags(vip_flag) ? "[VIP]" : "");
				count++;
			}
		}
	}
	if(!count) iLen += format(Menu[iLen], sizeof(Menu)-iLen-1, "^n %L^n", LANG_SERVER, Dictionary[18]);
	show_menu(id, (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9), Menu);
	return 0;
}
public whoMenuHandler(id, menu, item) {
	if (item == MENU_EXIT)     {
		menu_destroy(menu);
		return 1;
	}
	return 1;
}

public whoMotd(id) {
	new iPlayers[32], admName[32], iNum, iLen;
	new sBuffer[1024], bg_color[32], font_color_g[32], font_color_n[32];
	
	get_pcvar_string(motd_bg_color, bg_color, sizeof(bg_color)-1);
	get_pcvar_string(motd_font_color_groups, font_color_g, sizeof(font_color_g)-1);
	get_pcvar_string(motd_font_color_names, font_color_n, sizeof(font_color_n)-1);
	
	iLen = formatex(sBuffer, sizeof(sBuffer)-1, "<body bgcolor=^"%s^"><pre>", bg_color);
	get_players(iPlayers, iNum);
	
	for(new k=0; k<GROUPS; k++) {
		iLen += formatex(sBuffer[iLen], sizeof(sBuffer)-iLen-1, "<center><h5><font color=^"%s^">%s</font></h5></center>", font_color_g, GroupNames[k]);
		checkvipflags(k);
		for(new i=0; i<iNum ; i++) {
			if(get_user_flags(iPlayers[i]) == read_flags(GroupFlags[k]) || get_user_flags(iPlayers[i]) == read_flags(vipflags)) {
				get_user_name(iPlayers[i], admName, sizeof(admName)-1);
				iLen += formatex(sBuffer[iLen], sizeof(sBuffer)-iLen-1, "<center><font color=^"%s^">%s %s</font></center>", font_color_n, admName, get_user_flags(iPlayers[i]) & read_flags(vip_flag) ? "<b>[VIP]</b>" : "");
			}
		}
	}
	formatex(bg_color, sizeof(bg_color), "%L", LANG_SERVER, Dictionary[2]);
	show_motd(id, sBuffer, bg_color);
	return 0;
}

public showAdmins(id) {
	new aNames[32];
	new msg[128];
	new count, iLen;
	
	iLen = format(msg, sizeof(msg)-1, "%L", LANG_SERVER, Dictionary[3]);
	for(new i=0 ; i<get_maxplayers( ); i++) {
		if(get_user_flags(i) & ADMIN_KICK && is_user_connected(i)) {
			get_user_name(i, aNames, sizeof(aNames)-1);
			iLen += format(msg[iLen], sizeof(msg)-iLen-1, "%s, ", aNames);
			if(iLen > 96) {
				ColorChat(id, BLUE, msg);
				iLen = format(msg, sizeof(msg)-1, "^x04%s, ");
			}
			count++;
		}
	}
	iLen = format(msg, iLen-2, msg);
	//strtok(msg, finalmsg, sizeof(finalmsg), array, sizeof(array), ', ,');
	if(!count) {
		ColorChat(id, BLUE, "%L", id, Dictionary[5]);
		return 1;
	}
	ColorChat(id, BLUE, "%s.", msg);
	return 0;
}
public showVips(id) {
	new vNames[32];
	new msg[128];
	new count, iLen;
	
	iLen = format(msg, sizeof(msg)-1, "%L", LANG_SERVER, Dictionary[4]);
	for(new i=0 ; i<get_maxplayers( ); i++) {
		for(new k=0; k<GROUPS; k++) {	
			checkvipflags(k);
			if(get_user_flags(i) == read_flags(vipflags) && is_user_connected(i)) {
				get_user_name(i, vNames, sizeof(vNames)-1);
				iLen += format(msg[iLen], sizeof(msg)-iLen-1, "%s, ", vNames);
				if(iLen > 96) {
					ColorChat(id, BLUE, msg);
					iLen = format(msg, sizeof(msg)-1, "^x04%s, ");
				}
				count++;
			}
		}
	}
	iLen = format(msg, iLen-2, msg);
	if(!count) {
		ColorChat(id, BLUE, "%L", id, Dictionary[6]);
		return 1;
	}
	ColorChat(id, BLUE, "%s.", msg);
	return 0;
}

public whoConsole(id) {
	if(!get_pcvar_num(console_active))
		return 1;
	
	new iPlayers[32],admName[32], iNum, count;
	get_players(iPlayers, iNum);
	console_print(id, "^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n%L", id, Dictionary[0]);
	
	for(new k=0; k<GROUPS; k++) {
		checkvipflags(k);
		for(new i=0; i<iNum; i++) {
			if(get_user_flags(iPlayers[i]) == read_flags(GroupFlags[k]) || get_user_flags(iPlayers[i]) == read_flags(vipflags)) {
				get_user_name(iPlayers[i], admName, sizeof(admName)-1);
				console_print(id, "%L %s %s : %s", LANG_SERVER, Dictionary[13], get_user_flags(iPlayers[i]) & read_flags(vip_flag) ? "[VIP]" : "", admName, GroupNames[k]);
				count++;
			}
		}
	}
	if(!count) console_print(id, "%L %L", LANG_SERVER, Dictionary[13], LANG_SERVER, Dictionary[17]);
	console_print(id, "%L^n^n^n^n", id, Dictionary[1]);
	return 1;
}
public noDuplicate(msgId, msgDest, receiver) {
	if(get_pcvar_num(colorchat_active))
		return 0;
	
	return 1;
}
public client_connect(id)
	if(is_user_connected(id))
		client_cmd(id, "con_color ^"255 255 255^"");

// ==========================================================================================

stock register_dictionary_colored( const filename[] )
{
    if( !register_dictionary( filename ) )
    {
        return 0;
    }

    new szFileName[ 256 ];
    get_localinfo( "amxx_datadir", szFileName, charsmax( szFileName ) );
    format( szFileName, charsmax( szFileName ), "%s/lang/%s", szFileName, filename );
    new fp = fopen( szFileName, "rt" );

    if( !fp )
    {
        log_amx( "Failed to open %s", szFileName );
        return 0;
    }

    new szBuffer[ 512 ], szLang[ 3 ], szKey[ 64 ], szTranslation[ 256 ], TransKey:iKey;

    while( !feof( fp ) )
    {
        fgets( fp, szBuffer, charsmax( szBuffer ) );
        trim( szBuffer );

        if( szBuffer[ 0 ] == '[' )
        {
            strtok( szBuffer[ 1 ], szLang, charsmax( szLang ), szBuffer, 1, ']' );
        }
        else if( szBuffer[ 0 ] )
        {
        #if AMXX_VERSION_NUM < 183
            strbreak( szBuffer, szKey, charsmax( szKey ), szTranslation, charsmax( szTranslation ) );
        #else
            argbreak( szBuffer, szKey, charsmax( szKey ), szTranslation, charsmax( szTranslation ) );
        #endif

            iKey = GetLangTransKey( szKey );

            if( iKey != TransKey_Bad )
            {
                INSERT_COLOR_TAGS( szTranslation )
                AddTranslation( szLang, iKey, szTranslation[ 2 ] );
            }
        }
    }

    fclose( fp );
    return 1;
}
