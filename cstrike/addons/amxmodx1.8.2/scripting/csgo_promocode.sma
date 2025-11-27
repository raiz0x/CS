#include <amxmodx>
#include <amxmisc>
#include <cstrike>

#include <fvault>
// Pruning player agree/decline after 15 days of not being updated
//	15 days * 24 hours * 60 minutes * 60 seconds = 15 days in seconds(24x8600ms)
//		15 * 24 * 60 * 60
#define ZILE_CURATARE	15	//dupa 15 zile ii sterge pe cei care au folosit un cod din promo, ca sa poata folosii altul dinou

//#include <csgo_remake>

new const FVN[] = "PCodes";
//enum data [35]
new Array: g_PromoCodes/*=Invalid_Array*/;
new Array: g_PromoCodesPoints;

new cod_folosit[33];
new name[33] [32];

new const pCMD [] = "/promocode";

public plugin_cfg()
{
	new ConfigsDir[128], File
	get_configsdir(ConfigsDir, charsmax(ConfigsDir));
	add(ConfigsDir, charsmax(ConfigsDir), "/promocode.ini");

	if(!file_exists(ConfigsDir))
	{
		new form[100];
		formatex(form, charsmax(form), "Couldn't find ^"%s^". I will write a new one...", ConfigsDir);
		log_amx(form);
		server_print(form);
		//set_fail_state(form);

		File = fopen(ConfigsDir, "w");
		fputs(File, ";Aici treci codurile si premiul lor.^n");
		fputs(File, "; EX: ^"COD^" ^"SUMA^"^n");
		fputs(File, ";Suma reprezinta cifrele care se adauga ca si puncte...^n^n");
		fclose(File);
		//return;
	}

	g_PromoCodes = ArrayCreate(15);
	g_PromoCodesPoints = ArrayCreate(1);//1,32

	File = fopen(ConfigsDir, "r");//csf
	if(!File)	return;//...
	if(File)
	{
		new Buffer[120], CodeName[10], CodePoints[10];
		while(!feof(File))
		{
			fgets(File, Buffer, charsmax(Buffer))
			if(!Buffer[0] || Buffer[0] == ';' || Buffer[0] == '#' || Buffer[0] == '/' && Buffer[1] == '/')	continue;
			trim(Buffer); //xd
			parse(Buffer, CodeName, charsmax(CodeName), CodePoints, charsmax(CodePoints));
			//if(parse(Buffer) != 3 || !strlen(Buffer))	continue;

			for(new x; x < sizeof(CodeName); x++)	ArrayPushString(g_PromoCodes, CodeName[x]);
			for(new a; a < sizeof(CodePoints); a++)	ArrayPushCell(g_PromoCodesPoints, str_to_num(CodePoints[a]));//generare random xd
		}
		fclose(File);
	}
}

public plugin_init()	register_clcmd("say", "handle_say"),register_clcmd("say_team", "handle_say");

public client_authorized(id)	get_user_name(id, name[id], charsmax(name [])),LoadData(id);

public handle_say(Player)
{
	new Args[125];
	read_args(Args, charsmax(Args));
	if(!Args[0])	return PLUGIN_CONTINUE;//xD
	remove_quotes(Args);//[0]

	new szCmd[32], szCode[10], szTemp[10];
	parse(Args, szCmd, charsmax(szCmd), szCode, charsmax(szCode));

	if(equal(szCmd, pCMD))
	{
		/*if(!ArraySize(g_PromoCodes))
		{
			client_print(Player, print_chat, "Probleme in citirea codurilor.");
			return PLUGIN_HANDLED
		}*/

		/*if(!csgor_is_user_logged(Player))
		{
			client_print(Player, print_chat, "Se pare ca nu esti logat.");
			return PLUGIN_HANDLED;
		}*/

		if(cod_folosit[Player] == 1)
		{
				client_print(Player, print_chat, "Se pare ca ai activat recent un cod. Asteapta sa expire.");
				return PLUGIN_HANDLED;
		}

		for(new b; b < ArraySize(g_PromoCodes); b++)
		{
			if(equal(szCode, ""))
			{
				client_print(Player, print_chat, "Folosire corecta: %s COD", pCMD);
				return PLUGIN_HANDLED;
			}

			ArrayGetString(g_PromoCodes, b, szTemp, charsmax(szTemp));

			if(equal(szCode, szTemp))
			{
				for(new c; c < ArraySize(g_PromoCodesPoints); c++)
				{
					client_print(Player, print_chat, "Felicitari! Ai activat cu succes codul ^"%s^" fiind unul valid, si ai primit +%d punct%s", szTemp, ArrayGetCell(g_PromoCodesPoints, c), ArrayGetCell(g_PromoCodesPoints, c) == 1 ? "" : "e");
					//csgor_set_user_points(Player, csgor_get_user_points(Player) + ArrayGetCell(g_PromoCodesPoints, c));
					cs_set_user_money(Player, cs_get_user_money(Player) + ArrayGetCell(g_PromoCodesPoints, c), 1);
					cod_folosit[Player] = 1;
					fvault_set_data(FVN, name[Player], cod_folosit[Player]);
					//ArrayClear(g_PromoCodes);
					break;
				}
				return PLUGIN_HANDLED;
			}
			else
			{
				client_print(Player, print_chat, "OOOOPS ! COD INVALID.");
				return PLUGIN_HANDLED;
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public LoadData(id)
{
	new data[120];
	if(fvault_get_data(FVN, name[id], data, charsmax(data)))	cod_folosit[id] = str_to_num(data);
	else	cod_folosit[id] = 0;
}

public plugin_end()
{
	fvault_prune(FVN, _, get_systime() - (ZILE_CURATARE * 24 * 60 * 60));//0	road2cfg

	ArrayDestroy(g_PromoCodes);
	ArrayDestroy(g_PromoCodesPoints);
}
