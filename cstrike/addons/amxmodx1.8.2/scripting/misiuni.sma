/*
LICENTA


DETALII PLUGIN:

System Misiuni pentru Furien si Anti-Furieni. Sa fie cate o  misiune random activa la fiecare echipa pe toata durata mapei.
Cand scrii "/misiune" sa arate ce misiune se desfasoara in acel moment.
Cand scrii "misiune alege" sa pot alege eu o misiune
Cine termina primul aceste misiuni sa scrie in chat: 
(Anti-Furien) Jucatoru Ionica a indeplinit misiunea si a primit 120 dolari si hook.
(Furien) Jucatoru Ionica a indeplinit misiunea si a primit 120 dolari si teleport.
( acesti dolari sa fie salavati ca baza nu salveaza :)) )
premiile dureaza toata harta

#Anti-Furieni
Omoara 10 Furieni prin HeadShot.
Ucide 6 furieni cu lama
Dezamorseaza 8 bombe.
Omoara 30 furieni.

#Furieni
Foloseste 140$ intr-o runda.
Fa 35 kill-uri cu knife-ul.
Planteaza 10 bombe.
Omoara 30 anti-furieni.

Acestea sa se activeze cand sunt peste 3 playeri.

Meniu statisticile tale:
1. Misiune curenta: X
2. Killurile tale:  (+ procentaj) (x% completat)
3. Bombe plantate: (+ procentaj)
4. Bombe dezamorsate


CE TREBUIE SA MAI FAC:
- modt despre misiuni
- daca s-a incheiat o misiune iar castigatorul trece de la o echipa la cealalta ce se intampla?
- de afisat mesaj hud cu castigatorul imediat dupa ce a finalizat misiunea (o singura data)
- cand dam premiul la castigator sa verificam daca e conectat si in viata
- de adaugat invartire ecran la castigator
- cvar-uri
- progresul facut intr-o runda (de ex. tre sa fac 10 killuri, iar eu am facut 3 => arat procentaj)
- bug: misiune castigata dar am ales alta misiune => mesajele
DACA APAR ERORI:
- mutam maxim pe static si il trecem prin referinta
- restart la pc -> memorie volatila
- de verifcat tasku-ul task_anunta_castigator() cand misiunea la t este prima (de verificat de mai multe ori)

*/

#include <amxmodx>
#include <hamsandwich>
#include <cstrike>
#include <csx>

#pragma compress 1

#define PLUGIN_NAME "[AMXX] Misiuni"
#define PLUGIN_VERSION "1.0"
#define PLUGIN_AUTHOR "YONTU"


#define ULTIMA_MODIFICARE "10.02.2019"


// --------------------------------------------
//   ------------- DE EDITAT ---------------
// --------------------------------------------
#define TAG	"[AMXX]"
#define MIN_JUCATORI	2
#define ACCES_ADMIN	ADMIN_IMMUNITY
// --------------------------------------------
//   ------------- DE EDITAT ---------------
// --------------------------------------------

/*
	se_desfasoara:
	1 = misiunea se desfasoara
	0 = misiunea nu se desfasoara
*/

new misiune_ct, misiune_t, bool:se_desfasoara, bool:misiune_completa_t, bool:misiune_completa_ct, misiune_aleasa_ct, misiune_aleasa_t, castigator_t, castigator_ct, jucatori;
new max_players, g_sync_hudmessage, g_sync_hudmessage2;
new bmb_plant[33], bmb_def[33], nume_admin[33], kills_t[33], kills_ct[33], runde[33], text_potentiali[512], text_misiune[128],
nume_castigator_ct[32], nume_castigator_t[32];

enum datas_
{
	str[32],
	info
};

new const misiuni_t[][datas_] =
{
	{ "Rezista # de runde fara sa mori", 3 },
	{ "Ucide # anti-furieni cu cutitul", 4 },
	{ "Planteaza # bombe", 2 },
	{ "Omoara # anti-furieni", 10 }
};

new const misiuni_ct[][datas_] =
{
	{ "Omoara # furieni prin headshot", 4 },
	{ "Ucide # furieni cu lama", 2 },
	{ "Dezamorseaza # bombe", 8 },
	{ "Omoara # furieni", 3 }
};

// 93.114.82.92:27015

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_cvar("misiuni_", PLUGIN_VERSION, FCVAR_SPONLY|FCVAR_SERVER);
	set_cvar_string("misiuni_", PLUGIN_VERSION);

	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawnPre", 1);
	register_logevent("round_end", 2, "1=Round_End");
	register_event("TextMsg", "event_textmsg", "a", "2=#Game_will_restart_in");

	register_clcmd("say", "cmd_say");
	register_clcmd("say_team", "cmd_say");

	se_desfasoara = false;
	misiune_t = -1;
	misiune_ct = -1;
	misiune_aleasa_t = -1;
	misiune_aleasa_ct = -1;
	max_players = get_maxplayers();

	// alegem misiunea imediat dupa ce s-a dat restart la server/schimbat harta
	set_task(5.0, "task_alege_misiune");

	g_sync_hudmessage = CreateHudSyncObj();
	g_sync_hudmessage2 = CreateHudSyncObj();
}

public client_putinserver(id)
{
	jucatori++;
	set_task(3.0, "task_verifica_inceput");
}

public client_disconnect(id)
{
	jucatori--;
	set_task(3.0, "task_verifica_inceput");
}

public task_verifica_inceput()
{
	se_desfasoara = (jucatori >= MIN_JUCATORI) ? true : false;
	
	if(se_desfasoara)
        {
		/*
		Misiune in desfasurare...
		
		Fii primul care termina misiunea
		si vei fi rasplatit cu un premiu
		*/
		
		new jucatori2[32], numar = 0, id, i;
		if(!misiune_completa_ct)
		{
			if(0 <= misiune_ct <= sizeof(misiuni_ct))
			{
				get_players(jucatori2, numar, "e", "CT");
				for(i = 0; i < numar; i++)
				{
					id = jucatori2[i];
					if(!is_user_connected(id))	continue;
						
					set_hudmessage(255, 255, 255, 0.2, 0.40, 2, _, 2.0, _, _);
					ShowSyncHudMsg(id, g_sync_hudmessage2, "Misiune in desfasurare...^n^nFii primul care termina misiunea^nsi vei fi rasplatit cu un premiu", MIN_JUCATORI - jucatori);
				}
			}
			return;
		}
		if(!misiune_completa_t)
		{
			if(0 <= misiune_t <= sizeof(misiuni_t))
			{
				get_players(jucatori2, numar, "e", "TERRORIST");
				for(i = 0; i < numar; i++)
				{
					id = jucatori2[i];
					if(!is_user_connected(id))	continue;
						
					set_hudmessage(255, 255, 255, 0.2, 0.40, 2, _, 2.0, _, _);
					ShowSyncHudMsg(id, g_sync_hudmessage2, "Misiune in desfasurare...^n^nFii primul care termina misiunea^nsi vei fi rasplatit cu un premiu", MIN_JUCATORI - jucatori);
				}
			}
			return;
		}
	}				
}

// sa prevenim aparitia bugurilor la noile misiuni
public event_textmsg()
{
	if(misiune_aleasa_ct != -1)
	{
		arrayset(bmb_def, 0, charsmax(bmb_def));
		arrayset(kills_ct, 0, charsmax(kills_ct));
		castigator_ct = -1;
		misiune_completa_ct = false;
	}
	if(misiune_aleasa_t != -1)
	{
		arrayset(bmb_plant, 0, charsmax(bmb_plant));
		arrayset(kills_t, 0, charsmax(kills_t));
		arrayset(runde, 0, charsmax(runde));
		castigator_t = -1;
		misiune_completa_t = false;
	}
	//reseteaza_tot();
}

// s-ar putea sa apara bug aici
// neconcludent
public task_alege_misiune()
{
	if(misiune_aleasa_t == -1)	if(misiune_t == -1)	misiune_t = random_num(0, charsmax(misiuni_t));
	if(misiune_aleasa_t == -1)	if(misiune_ct == -1)	misiune_ct = random_num(0, charsmax(misiuni_ct));

	reseteaza_tot();
}

public fw_PlayerSpawnPre(id)
{
	if(!is_user_alive(id))	return HAM_HANDLED;
		
	if(misiune_aleasa_ct != -1)
	{
		misiune_ct = misiune_aleasa_ct;
		misiune_aleasa_ct = -1;
		
		task_alege_misiune();
		if(cs_get_user_team(id) == CS_TEAM_CT)
		{
			format_misiune_ct(misiune_ct, text_misiune);
			ColorChat(id, "!4%s!1 O NOUA MISIUNE A FOST ALEASA PENTRU VOI.", TAG);
			ColorChat(id, "!4%s!1 Adminul!3 %s!1 a ales misiunea!3 %s", TAG, nume_admin, text_misiune);
		}
		return HAM_HANDLED;
	}
	if(misiune_aleasa_t != -1)
	{
		misiune_t = misiune_aleasa_t;
		misiune_aleasa_t = -1;

		task_alege_misiune();
		if(cs_get_user_team(id) == CS_TEAM_T)
		{
			format_misiune_t(misiune_t, text_misiune);
			ColorChat(id, "!4%s!1 O NOUA MISIUNE A FOST ALEASA PENTRU VOI.", TAG);
			ColorChat(id, "!4%s!1 Adminul!3 %s!1 a ales misiunea!3 %s", TAG, nume_admin, text_misiune);
		}
		return HAM_HANDLED;
	}
	
	return HAM_IGNORED;
}

/*
Pot fi mai multi jucatori care au supravietuit x runde,
asadar, pentru a alege un castigator, alegem unul random
din toti cei care au supravietuit.
*/

public round_end()
{
	if(se_desfasoara && misiune_t == 0 && !misiune_completa_t)
	{
		new players[32], numar, i, id, total = 0, id_supravietuitori[32];
		cauta_id_jucatori(players, numar);
		for(i = 0; i < numar; i++)
		{
			id = players[i];
			if(!is_user_connected(id))	continue;

			if(cs_get_user_team(id) != CS_TEAM_T)	continue;

			if(is_user_alive(id))
			{
				if(++runde[id] == misiuni_t[misiune_t][info])
				{
					// numaram toti jucatorii care au supravietuti x runde si le retinem id-ul
					id_supravietuitori[total++] = id;
					misiune_completa_t = true;
				}
			}
			else runde[id] = 0;
		}

		if(misiune_completa_t)
		{
			// am gasit id-ul castigatorului, astfel putem sa ii dam un premiu pe restul rundelor
			castigator_t = id_supravietuitori[random_num(0, total-1)];
			get_user_name(castigator_t, nume_castigator_t, charsmax(nume_castigator_t));
			set_task(1.0, "task_anunta_castigator");
		}
	}
}

public task_anunta_castigator()
{
	new players[32], numar = 0, i, id, nume_castigator[32];
	if(misiune_completa_ct)
	{
		format_misiune_ct(misiune_ct, text_misiune);
		get_players(players, numar, "e", "CT");
		for(i = 0; i < numar; i++)
		{
			id = players[i];
			if(!is_user_connected(id))	continue;
				
			get_user_name(id, nume_castigator, charsmax(nume_castigator));
			
			if(id == castigator_ct && equal(nume_castigator_ct, nume_castigator))
			{
				ColorChat(id, "!4%s!1 FELICITARI!4 %s!1!!! Ai terminat primul misiunea!3 %s!1.", TAG, nume_castigator, text_misiune);
				set_task(0.25, "adauga_efecte", id, _, _, "a", 12);
			}
			else	ColorChat(id, "!4%s!1 Jucatorul!4 %s!1 a terminat primul misiunea!3 %s!1.", TAG, nume_castigator_ct, text_misiune);
		}
		return;
	}
	if(misiune_completa_t)
	{
		format_misiune_t(misiune_t, text_misiune);
		get_players(players, numar, "e", "TERRORIST");
		for(i = 0; i < numar; i++)
		{
			id = players[i];
			if(!is_user_connected(id))	continue;
				
			get_user_name(id, nume_castigator, charsmax(nume_castigator));
			
			if(id == castigator_t && equal(nume_castigator_t, nume_castigator))
			{
				ColorChat(id, "!4%s!1 FELICITARI!4 %s!1!!! Ai terminat primul misiunea!3 %s!1.", TAG, nume_castigator, text_misiune);
				set_task(0.25, "adauga_efecte", id, _, _, "a", 12);
			}
			else	ColorChat(id, "!4%s!1 Jucatorul!4 %s!1 a terminat primul misiunea!3 %s!1.", TAG, nume_castigator_t, text_misiune);
		}
	}
}

public adauga_efecte(castigator)
{
	if(!is_user_connected(castigator))	return;
		
	static g_msg_screenshake = 0;
	if(!g_msg_screenshake)	g_msg_screenshake = get_user_msgid("ScreenShake");
	
	message_begin(MSG_ONE, g_msg_screenshake, _, castigator);
	write_short(1<<14);
	write_short(1<<14);
	write_short(1<<14);
	message_end();

	static g_msg_screenfade = 0;
	if(!g_msg_screenfade)	g_msg_screenfade = get_user_msgid("ScreenFade");
		
	message_begin(MSG_ONE_UNRELIABLE, g_msg_screenfade, _, castigator);
	write_short(1<<10);
	write_short(1<<10);
	write_short(1<<12);
	write_byte(random_num(0, 255));
	write_byte(random_num(0, 255));
	write_byte(random_num(0, 255));
	write_byte(100);
	message_end();	
}

public cmd_say(id)
{
	static chat[192];
	read_args(chat, charsmax(chat));
	remove_quotes(chat);
    
	if(equali(chat, ""))	return PLUGIN_HANDLED_MAIN;

	new CsTeams:echipa = cs_get_user_team(id);
	
	if(echipa == CS_TEAM_CT)	if(misiune_ct != -1)	format_misiune_ct(misiune_aleasa_ct != -1 ? misiune_aleasa_ct : misiune_ct, text_misiune);
	else	if(misiune_t != -1)	format_misiune_t(misiune_aleasa_t != -1 ? misiune_aleasa_t : misiune_t, text_misiune);

	new comanda[32];
	strbreak(chat, comanda, charsmax(comanda), chat, charsmax(chat));

	if(equali(comanda, "misiune", 7) || equali(comanda, "/misiune", 7))
	{
		if(equali(chat[0], "help"))
		{
			meniu_statistici(id);
			return PLUGIN_CONTINUE;
		}
		if(equali(chat[0], "alege"))
		{
			if(!(get_user_flags(id) & ACCES_ADMIN))
			{
				ColorChat(id, "!4%s!1 Doar adminii au dreptul sa aleaga o misiune.", TAG);
				return PLUGIN_CONTINUE;
			}
			if(misiune_aleasa_ct != -1 || misiune_aleasa_t != -1)
			{
				ColorChat(id, "!4%s!3 A fost aleasa deja o misiune de catre adminul!1 %s!3. Te rugam sa astepti pana la urmatorul spawn.", TAG, nume_admin);
				ColorChat(id, "!4%s!1 Urmatoarea misiune:!3 %s", TAG, text_misiune);
			}
			else
			{
				static menu, text[128], tasta[2], i;
				if(echipa == CS_TEAM_CT)
				{
					formatex(text, charsmax(text), "\wAlege o misiune^nMisiunea curenta:\y %s", text_misiune);
					menu = menu_create(text, "alege_handler");
					
					for(i = 0; i < sizeof misiuni_ct; i++)
					{
						format_misiune_ct(i, text_misiune);
						formatex(text, charsmax(text), "%s%s", (i == misiune_ct) ? "\d" : "", text_misiune);
						tasta[0] = i;
						tasta[1] = 0;
						menu_additem(menu, text, tasta);
					}
				}
				else
				{
					formatex(text, charsmax(text), "\wAlege o misiune^nMisiunea curenta:\y %s", text_misiune);
					menu = menu_create(text, "alege_handler");
					
					for(i = 0; i < sizeof misiuni_t; i++)
					{
						format_misiune_t(i, text_misiune);
						formatex(text, charsmax(text), "%s%s", (i == misiune_t) ? "\d" : "", text_misiune);
						tasta[0] = i;
						tasta[1] = 0;
						menu_additem(menu, text, tasta);
					}
				}
				menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
				menu_display(id, menu, 0);
			}
			return PLUGIN_CONTINUE;
		}
		if(se_desfasoara)
		{
			if(echipa == CS_TEAM_CT)
			{
				// COMPLETA
				if(misiune_completa_ct)
				{
					ColorChat(id, "!4%s!1 Misiunea!3 %s!1 a fost castigata de!4 %s!1.", TAG, text_misiune, nume_castigator_ct);
					ColorChat(id, "!4%s!1 Harta urmatoare alegem o noua misiune. Fii alaturi de noi.", TAG);
				}
				else
				{
					// IN DESFASURARE
					ColorChat(id, "!4%s!1 In acest moment se desfasoara misiunea:!3 %s!1 (!4%d!1).", TAG, text_misiune, misiune_ct);
					if(calculeaza(id, CS_TEAM_CT, misiune_ct, 1, text_potentiali) == 1.0)	// 1.0 succes
						ColorChat(id, "!4%s!1 Potentiali castigatori:!3 %s", TAG, text_potentiali);
		
					set_hudmessage(42, 255, 42, 0.1, 0.6, 2, _, 2.0, _, _);
					ShowSyncHudMsg(id, g_sync_hudmessage, "Misiunea numarul %d^n^nDescriere: %s", misiune_ct, text_misiune);
				}
			}
			else
			{
				// COMPLETA
				if(misiune_completa_t)
				{
					ColorChat(id, "!4%s!1 Misiunea!3 %s!1 a fost castigata de!4 %s!1.", TAG, text_misiune, nume_castigator_t);
					ColorChat(id, "!4%s!1 Harta urmatoare alegem o noua misiune. Fii alaturi de noi.", TAG);
				}
				else
				{
					// IN DESFASURARE
					ColorChat(id, "!4%s!1 In acest moment se desfasoara misiunea:!3 %s!1 (!4%d!1).", TAG, text_misiune, misiune_t);
					if(calculeaza(id, CS_TEAM_T, misiune_t, 1, text_potentiali) == 1.0)	ColorChat(id, "!4%s!1 Potentiali castigatori:!3 %s", TAG, text_potentiali);
		
					set_hudmessage(42, 255, 42, 0.1, 0.6, 2, _, 2.0, _, _);
					ShowSyncHudMsg(id, g_sync_hudmessage, "Misiunea numarul %d^n^nDescriere: %s", misiune_t, text_misiune);
				}
			}
			meniu_statistici(id);
			return PLUGIN_CONTINUE;
		}
		else
		{
			if(echipa == CS_TEAM_CT)
			{
				// COMPLETA
				if(misiune_completa_ct)
				{
					ColorChat(id, "!4%s!1 Misiunea!3 %s!1 a fost castigata de!4 %s!1.", TAG, text_misiune, nume_castigator_ct);
					ColorChat(id, "!4%s!1 Harta urmatoare alegem o noua misiune. Fii alaturi de noi.", TAG);
				}
				else
				{
					// SUSPENDATA
					if(misiune_ct != -1)
					{
						ColorChat(id, "!4%s!1 Misiunea!3 '%s'!1 a fost suspendata.", TAG, text_misiune);
						if(MIN_JUCATORI - jucatori > 0)
						{
							ColorChat(id, "!4%s!1 Nu sunt suficienti jucatori pe server pentru a continua.", TAG);
						
							set_hudmessage(42, 255, 42, 0.1, 0.60, 0, _, 2.0, _, _);
							ShowSyncHudMsg(id, g_sync_hudmessage, "JUCATORI NECESARI: inca %d", MIN_JUCATORI - jucatori);
						}
					}
					else
					{
						// NU EXISTA MISIUNE
						ColorChat(id, "!4%s!1 Momentan nu ruleaza nicio misiune pe server.", TAG);
						return PLUGIN_CONTINUE;
					}
				}
			}
			else
			{
				// COMPLETA
				if(misiune_completa_t)
				{
					ColorChat(id, "!4%s!1 Misiunea!3 %s!1 a fost castigata de!4 %s!1.", TAG, text_misiune, nume_castigator_t);
					ColorChat(id, "!4%s!1 Harta urmatoare alegem o noua misiune. Fii alaturi de noi.", TAG);
				}
				else
				{
					// SUSPENDATA
					if(misiune_t != -1)
					{
						ColorChat(id, "!4%s!1 Misiunea!3 '%s'!1 a fost suspendata.", TAG, text_misiune);
						if(MIN_JUCATORI - jucatori > 0)
						{
							ColorChat(id, "!4%s!1 Nu sunt suficienti jucatori pe server pentru a continua. Necesari:!4 %d", TAG, MIN_JUCATORI - jucatori);
						
							set_hudmessage(42, 255, 42, 0.1, 0.60, 0, _, 2.0, _, _);
							ShowSyncHudMsg(id, g_sync_hudmessage, "JUCATORI NECESARI: inca %d", MIN_JUCATORI - jucatori);
						}
					}
					else
					{
						// NU EXISTA MISIUNE
						ColorChat(id, "!4%s!1 Momentan nu ruleaza nicio misiune pe server.", TAG);
						return PLUGIN_CONTINUE;
					}
				}
			}
			meniu_statistici(id);
			return PLUGIN_CONTINUE;
		}
	}
	return PLUGIN_CONTINUE;
}

/*
Status misiune:
COMPLETA
SUSPENDATA
IN DESFASURARE
*/

public meniu_statistici(id)
{
	new CsTeams:echipa = cs_get_user_team(id);
	static menu, text[128], Float:progres;
	menu = menu_create("\rStatisticile mele", "statistici_handler");
	
	progres = 0.0;
	if(echipa == CS_TEAM_CT)
	{
		format_misiune_ct(misiune_ct, text_misiune);
		formatex(text, charsmax(text), "Misiune curenta: %s", text_misiune);
		menu_additem(menu, text, "1");
	
		if(!misiune_completa_ct)
		{
			if(misiune_ct != -1 && se_desfasoara)	formatex(text, charsmax(text), "Status misiune: \yIN DESFASURARE");
			else	formatex(text, charsmax(text), "Status misiune: \dSUSPENDATA");
			menu_additem(menu, text, "2");
			
			switch(misiune_ct)
			{
				case 0:
				{
					progres = (kills_ct[id] * 100.0)/float(misiuni_ct[misiune_ct][info]);
					formatex(text, charsmax(text), "Progresul tau:\r %.1f%%", progres);
					menu_additem(menu, text, "3");
					
					formatex(text, charsmax(text), "Kill-uri facute:\r %d/%d", kills_ct[id], misiuni_ct[misiune_ct][info]);
					menu_additem(menu, text, "4");
				}
				case 1:
				{
					progres = (kills_ct[id] * 100.0)/float(misiuni_ct[misiune_ct][info]);
					formatex(text, charsmax(text), "Progresul tau:\r %.1f%%", progres);
					menu_additem(menu, text, "3");
					
					formatex(text, charsmax(text), "Kill-uri facute:\r %d/%d", kills_ct[id], misiuni_ct[misiune_ct][info]);
					menu_additem(menu, text, "4");
				}
				case 2:
				{
					progres = (bmb_def[id] * 100.0)/float(misiuni_ct[misiune_ct][info]);
					formatex(text, charsmax(text), "Progresul tau:\r %.1f%%", progres);
					menu_additem(menu, text, "3");
					
					formatex(text, charsmax(text), "Bombe dezamorsate:\r %d/%d", bmb_def[id], misiuni_ct[misiune_ct][info]);
					menu_additem(menu, text, "4");
				}
				case 3:
				{
					progres = (kills_ct[id] * 100.0)/float(misiuni_ct[misiune_ct][info]);
					formatex(text, charsmax(text), "Progresul tau:\r %.1f%%", progres);
					menu_additem(menu, text, "3");
					
					formatex(text, charsmax(text), "Kill-uri facute:\r %d/%d", kills_ct[id], misiuni_ct[misiune_ct][info]);
					menu_additem(menu, text, "4");
				}
			}

			formatex(text, charsmax(text), "Sansa de a castiga premiul:\r %.2f%%", calculeaza(id, CS_TEAM_CT, misiune_ct, 0, text_potentiali));
			menu_additem(menu, text, "5");
		}
		else
		{
			new bool:gasit = false, i, players[32], numar, player, nume_jucator[32];
			cauta_id_jucatori(players, numar);
			
			for(i = 0; i < numar; i++)
			{
				player = players[i];
				if(!is_user_connected(player))	continue;
					
				get_user_name(player, nume_jucator, charsmax(nume_jucator));
				if(equal(nume_castigator_ct, nume_jucator))
				{
					gasit = true;
					break;
				}
			}
			formatex(text, charsmax(text), "Castigator: \r%s%s (%sconectat)", nume_castigator_ct, gasit ? "\w" : "\d", gasit ? "" : "de");
			menu_additem(menu, text, "2");
		}
	}
	else
	{
		format_misiune_t(misiune_t, text_misiune);
		formatex(text, charsmax(text), "Misiune curenta: %s", text_misiune);
		menu_additem(menu, text, "1");
	
		if(!misiune_completa_t)
		{
			if(misiune_t != -1 && se_desfasoara)	formatex(text, charsmax(text), "Status misiune: \yIN DESFASURARE");
			else	formatex(text, charsmax(text), "Status misiune: \dSUSPENDATA");
			menu_additem(menu, text, "2");
			
			switch(misiune_t)
			{
				case 0:
				{
					progres = (runde[id] * 100.0)/float(misiuni_t[misiune_t][info]);
					formatex(text, charsmax(text), "Progresul tau:\r %.1f%%", progres);
					menu_additem(menu, text, "3");
					
					formatex(text, charsmax(text), "Runde supravietuite:\r %d/%d", runde[id], misiuni_t[misiune_t][info]);
					menu_additem(menu, text, "4");
				}
				case 1:
				{
					progres = (kills_t[id] * 100.0)/float(misiuni_t[misiune_t][info]);
					formatex(text, charsmax(text), "Progresul tau:\r %.1f%%", progres);
					menu_additem(menu, text, "3");
					
					formatex(text, charsmax(text), "Kill-uri facute:\r %d/%d", kills_t[id], misiuni_t[misiune_t][info]);
					menu_additem(menu, text, "4");
				}
				case 2:
				{
					progres = (bmb_plant[id] * 100.0)/float(misiuni_t[misiune_t][info]);
					formatex(text, charsmax(text), "Progresul tau:\r %.1f%%", progres);
					menu_additem(menu, text, "3");
					
					formatex(text, charsmax(text), "Bombe plantate:\r %d/%d", bmb_plant[id], misiuni_t[misiune_t][info]);
					menu_additem(menu, text, "4");
				}
				case 3:
				{
					progres = (kills_t[id] * 100.0)/float(misiuni_t[misiune_t][info]);
					formatex(text, charsmax(text), "Progresul tau:\r %.1f%%", progres);
					menu_additem(menu, text, "3");
					
					formatex(text, charsmax(text), "Kill-uri facute:\r %d/%d", kills_t[id], misiuni_t[misiune_t][info]);
					menu_additem(menu, text, "4");
				}
			}
			
			formatex(text, charsmax(text), "Sansa de a castiga premiul:\r %.2f%%", calculeaza(id, CS_TEAM_T, misiune_t, 0, text_potentiali));
			menu_additem(menu, text, "5");
		}
		else
		{
			new bool:gasit = false, i, players[32], numar, player, nume_jucator[32];
			cauta_id_jucatori(players, numar);
			
			for(i = 0; i < numar; i++)
			{
				player = players[i];
				if(!is_user_connected(player))	continue;
					
				get_user_name(player, nume_jucator, charsmax(nume_jucator));
				if(equal(nume_castigator_t, nume_jucator))
				{
					gasit = true;
					break;
				}
			}
			formatex(text, charsmax(text), "Castigator: \r%s%s (%sconectat)", nume_castigator_t, gasit ? "\w" : "\d", gasit ? "" : "de");
			menu_additem(menu, text, "2");
		}
	}

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public statistici_handler(id, menu, item)
{
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public alege_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new CsTeams:echipa = cs_get_user_team(id);
	if(echipa == CS_TEAM_CT)
	{
		if(item != misiune_ct)
		{
			misiune_aleasa_ct = item;
			//format_misiune_ct(misiune_aleasa_ct, text_misiune);
		}
		else
		{
			ColorChat(id, "!4%s!3 Nu poti alege misiunea curenta. Alege alta misiune.", TAG);
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
	}
	else
	{
		if(item != misiune_t)
		{
			misiune_aleasa_t = item;
			//format_misiune_t(misiune_aleasa_t, text_misiune);
		}
		else
		{	
			ColorChat(id, "!4%s!3 Nu poti alege misiunea curenta. Alege alta misiune.", TAG);
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
	}
	get_user_name(id, nume_admin, charsmax(nume_admin));
	ColorChat(id, "!4%s!1 Misiunea!3 %s!1 va fi activata la urmatorul spawn.", TAG, text_misiune);
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public client_death(killer, victim, wpnindex, hitplace, tk)
{
	if(!is_user_alive(killer))	return;

	if(killer == victim)	return;

	if(!se_desfasoara)	return;

	new CsTeams:echipa = cs_get_user_team(killer);
	if(echipa == CS_TEAM_CT)
	{
		if(misiune_completa_ct)	return;
			
		switch(misiune_ct)
		{
			case 0:
			{
				if(hitplace != HIT_HEAD)	return;

				if(++kills_ct[killer] == misiuni_ct[misiune_ct][info])
				{
					castigator_ct = killer;
					misiune_completa_ct = true;
					get_user_name(castigator_ct, nume_castigator_ct, charsmax(nume_castigator_ct));
					set_task(1.0, "task_anunta_castigator");
				}
			}
			case 1:
			{
				if(wpnindex != CSW_KNIFE)	return;

				if(++kills_ct[killer] == misiuni_ct[misiune_ct][info])
				{
					castigator_ct = killer;
					misiune_completa_ct = true;
					get_user_name(castigator_ct, nume_castigator_ct, charsmax(nume_castigator_ct));
					set_task(1.0, "task_anunta_castigator");
				}
			}
			case 3:
			{
				if(++kills_ct[killer] == misiuni_ct[misiune_ct][info])
				{
					castigator_ct = killer;
					misiune_completa_ct = true;
					get_user_name(castigator_ct, nume_castigator_ct, charsmax(nume_castigator_ct));
					set_task(1.0, "task_anunta_castigator");
				}
			}
			//default: {}
		}
	}
	else
	{
		if(misiune_completa_t)	return;
			
		switch(misiune_t)
		{
			case 0: runde[victim] = 0;
			case 1:
			{
				if(wpnindex != CSW_KNIFE)	return;

				if(++kills_t[killer] == misiuni_t[misiune_t][info])
				{
					castigator_t = killer;
					misiune_completa_t = true;
					get_user_name(castigator_t, nume_castigator_t, charsmax(nume_castigator_t));
					set_task(1.0, "task_anunta_castigator");
				}
			}
			case 3:
			{
				if(++kills_t[killer] == misiuni_t[misiune_t][info])
				{
					castigator_t = killer;
					misiune_completa_t = true;
					get_user_name(castigator_t, nume_castigator_t, charsmax(nume_castigator_t));
					set_task(1.0, "task_anunta_castigator");
				}
			}
			//default: {}
		}
	}
}

public bomb_planted(id)
{
	if(se_desfasoara && misiune_t == 2 && !misiune_completa_t)
	{
		ColorChat(id, "!4%s!1 Felicitari!!! Ai plantat o bomba. Planteaza in continuare bombe si termina primul misiunea.", TAG);
		ColorChat(id, "!4%s!1 Urmareste-ti progresul, tastand in chat!3 /misiune!1.", TAG);

		if(++bmb_plant[id] == misiuni_t[misiune_t][info])
		{
			castigator_t = id;
			misiune_completa_t = true;
			get_user_name(castigator_t, nume_castigator_t, charsmax(nume_castigator_t));
			set_task(1.0, "task_anunta_castigator");
		}
	}
}

public bomb_defused(id)
{
	if(se_desfasoara && misiune_ct == 2 && !misiune_completa_ct)
	{
		ColorChat(id, "!4%s!1 Felicitari!!! Ai dezamorsat o bomba. Dezamorseaza in continuare bombe si termina primul misiunea.", TAG);
		ColorChat(id, "!4%s!1 Urmareste-ti progresul, tastand in chat!3 /misiune!1.", TAG);

		if(++bmb_def[id] == misiuni_ct[misiune_ct][info])
		{
			castigator_ct = id;
			misiune_completa_ct = true;
			get_user_name(castigator_ct, nume_castigator_ct, charsmax(nume_castigator_ct));
			set_task(1.0, "task_anunta_castigator");
		}
	}
}

stock cauta_id_jucatori(players[32], &numar)
{
	numar = 0;
	new player;
	for(player = 1; player <= max_players; player++)
	{
		if(!is_user_connected(player))	continue;
			
		players[numar++] = player;
	}
}

/*
	Ce calculez?
	0 = sansa
	1 = potentiali castigatori
*/

stock Float:calculeaza(id, const CsTeams:echipa, const misiune, const ce_calculez, text[512])
{
	// retinem id-ul tuturor jucatorilor de pe server (numar = total de id-uri)
	new players[32], numar, i, player;
	cauta_id_jucatori(players, numar);
	
	new progres[33], maxim = 0;
	arrayset(progres, 0, charsmax(progres));
	
	for(i = 0; i < numar; i++)
	{
		player = players[i];
		if(!is_user_connected(player))	continue;
		
		if(cs_get_user_team(player) != echipa)	continue;

		if(echipa == CS_TEAM_CT)
		{
			switch(misiune)
			{
				case 0,1,3: progres[player] = kills_ct[player];
				case 2: progres[player] = bmb_def[player];
				default: progres[player] = 0;
			}
		}
		else
		{
			switch(misiune)
			{
				case 0: progres[player] = runde[player];
				case 1,3: progres[player] = kills_t[player];
				case 2: progres[player] = bmb_plant[player];
				default: progres[player] = 0;
			}
		}
		
		// calcularea maximului
		if(maxim <= progres[player])	maxim = progres[player];
	}

	if(ce_calculez == 0)
	{
		// algoritm: statisticile tale intr-o misiune raportate la numarul total maxim de statistici
		// nu se poate imparti la 0, deci daca maximul este 0, inseamna ca exista sanse de 100.0% ca un jucator sa castige premiul
		return (maxim == 0) ? 100.0 : (float(progres[id])/float(maxim))*100.0;
	}
	
	new len = 0, nume[32];
	if(!maxim)	len += format(text[len], charsmax(text)-len, "!3toti jucatorii!1.");
	else
	{
		for(i = 0; i < numar; i++)
		{
			player = players[i];
			if(!is_user_connected(player))	continue;
					
			if(progres[player] == maxim)
			{
				get_user_name(player, nume, charsmax(nume));
				len += format(text[len], charsmax(text)-len, "!3%s!1 | ", nume);
			}
		}
		// sa nu mai apara dupa ultimul nume caracterul '|'
		text[strlen(text)-2] = 0;
	}

	///*	debug
	console_print(id, "MAXIM jucatori: %d", maxim);
	for(i = 0; i < numar; i++)
	{
		player = players[i];
		if(!is_user_connected(player))	continue;

		if(cs_get_user_team(player) != echipa)	continue;

		get_user_name(player, nume, charsmax(nume));
		client_print(id, print_console, "--> %s	Progres: %d", nume, progres[player]);
	}
	//*/
	
	// p.l.m...
	return 1.0;
}

stock reseteaza_tot()
{
	// reset
	arrayset(bmb_plant, 0, charsmax(bmb_plant));
	arrayset(bmb_def, 0, charsmax(bmb_def));
	arrayset(kills_t, 0, charsmax(kills_t));
	arrayset(kills_ct, 0, charsmax(kills_ct));
	arrayset(runde, 0, charsmax(runde));
	
	castigator_t = -1;
	castigator_ct = -1;
	misiune_completa_t = false;
	misiune_completa_ct = false;
	nume_castigator_t[0] = EOS;
	nume_castigator_ct[0] = EOS;
}

stock format_misiune_ct(const misiune, string[128])
{
	string[0] = EOS;
	static str_to_rpl[3];
	num_to_str(misiuni_ct[misiune][info], str_to_rpl, charsmax(str_to_rpl));
	copy(string, charsmax(string), misiuni_ct[misiune][str]);
	replace(string, charsmax(string), "#", str_to_rpl);
	//client_print(id, print_chat, "%d. %s", misiune, string);
}

stock format_misiune_t(const misiune, string[128])
{
	string[0] = EOS;
	static str_to_rpl[3];
	num_to_str(misiuni_t[misiune][info], str_to_rpl, charsmax(str_to_rpl));
	copy(string, charsmax(string), misiuni_t[misiune][str]);
	replace(string, charsmax(string), "#", str_to_rpl);
	//client_print(id, print_chat, "%d. %s", misiune, string);
}

stock ColorChat(id, String[], any:...) 
{
	static szMesage[192];
	vformat(szMesage, charsmax(szMesage), String, 3);
	
	replace_all(szMesage, charsmax(szMesage), "!1", "^1");
	replace_all(szMesage, charsmax(szMesage), "!3", "^3");
	replace_all(szMesage, charsmax(szMesage), "!4", "^4");
	
	static g_msg_SayText = 0;
	if(!g_msg_SayText)	g_msg_SayText = get_user_msgid("SayText");
	
	new Players[32], iNum = 1, i;

 	if(id) Players[0] = id;
	else get_players(Players, iNum, "ch");
	
	for(--iNum; iNum >= 0; iNum--) 
	{
		i = Players[iNum];
		
		message_begin(MSG_ONE_UNRELIABLE, g_msg_SayText, _, i);
		write_byte(i);
		write_string(szMesage);
		message_end();
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
