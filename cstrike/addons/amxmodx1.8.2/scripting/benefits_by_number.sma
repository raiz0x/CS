/*
			  _        ___    __   __    ___     _  _ 
			 | |      | __|   \ \ / /   |_ _|   | \| |
			 | |__    | _|     \ V /     | |    | .` |
			 |____|   |___|     \_/     |___|   |_|\_|
*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>

new const FILE_ACCESS[]="acces_beneficii.ini"
new const FILE_CVARS[]="beneficii.cfg"

new Trie: eData
//new numar_acces[33]
/*new const FlagsNR[][]=
{
	{ "1" },
	{ "2" },
	{ "3" },
	{ "4" },
	{ "5" },
	{ "6" },
	{ "7" },
	{ "8" }
}*/

enum _:CVARS
{
//	Fondator :
		fondator_hp/*[20]*/,
		fondator_ap,
		fondator_money,
//------------------------------------

//	Fondator fara ftp:
		fondatorfaraftp_hp,
		fondatorfaraftp_ap,
		fondatorfaraftp_money,
//------------------------------------

//	Daimond member:
		daimond_hp,
		daimond_ap,
		daimond_money,
//------------------------------------

//	Platinium member:
		platinium_hp,
		platinium_ap,
		platinium_money,
//------------------------------------

//	Gold member:
		gold_hp,
		gold_ap,
		gold_money,
//------------------------------------

//	Silver member :
		silver_hp,
		silver_ap,
		silver_money,
//------------------------------------

//	Bronze member :
		bronze_hp,
		bronze_ap,
		bronze_money,
//------------------------------------

//	VIP :
		vip_hp,
		vip_ap,
		vip_money
//------------------------------------
}

//Start of CVARs
new const Cvars[][][]=//CVARS xd +[]
{
//	Fondator :
	{"fondator_hp","50"},
	{"fondator_ap","50"},
	{"fondator_money","50"},
//------------------------------------
//	Fondator fara ftp:
	{"fondatorfaraftp_hp","45"},
	{"fondatorfaraftp_ap","45"},
	{"fondatorfaraftp_money","45"},
//------------------------------------
//	Daimond member:
	{"daimond_hp","40"},
	{"daimond_ap","40"},
	{"daimond_money","40"},
//------------------------------------
//	Platinium member:
	{"platinium_hp","35"},
	{"platinium_ap","35"},
	{"platinium_money","35"},
//------------------------------------
//	Gold member:
	{"gold_hp","30"},
	{"gold_ap","30"},
	{"gold_money","30"},
//------------------------------------
//	Silver member :
	{"silver_hp","25"},
	{"silver_ap","25"},
	{"silver_money","25"},
//------------------------------------
//	Bronze member :
	{"bronze_hp","20"},
	{"bronze_ap","20"},
	{"bronze_money","20"},
//------------------------------------
//	VIP :
	{"vip_hp","15"},
	{"vip_ap","15"},
	{"vip_money","15"}
//------------------------------------
};//End of CVARs


new cvars[CVARS]//formatex %s_hp/ap/money XD

public plugin_init()
{
	eData=TrieCreate()
	register_event("DeathMsg","evDeathMsg","a")
	//	Fondator :
	cvars[fondator_hp]=register_cvar(Cvars[0][0],Cvars[0][1])
	cvars[fondator_ap]=register_cvar(Cvars[1][0],Cvars[1][1])
	cvars[fondator_money]=register_cvar(Cvars[2][0],Cvars[2][1])
	//------------------------------------

	//	Fondator fara ftp:
	cvars[fondatorfaraftp_hp]=register_cvar(Cvars[3][0],Cvars[3][1])
	cvars[fondatorfaraftp_ap]=register_cvar(Cvars[4][0],Cvars[4][1])
	cvars[fondatorfaraftp_money]=register_cvar(Cvars[5][0],Cvars[5][1])
	//------------------------------------

	//	Daimond member:
	cvars[daimond_hp]=register_cvar(Cvars[6][0],Cvars[6][1])
	cvars[daimond_ap]=register_cvar(Cvars[7][0],Cvars[7][1])
	cvars[daimond_money]=register_cvar(Cvars[8][0],Cvars[8][1])
	//------------------------------------

	//	Platinium member:
	cvars[platinium_hp]=register_cvar(Cvars[9][0],Cvars[9][1])
	cvars[platinium_ap]=register_cvar(Cvars[10][0],Cvars[10][1])
	cvars[platinium_money]=register_cvar(Cvars[11][0],Cvars[11][1])
	//------------------------------------

	//	Gold member:
	cvars[gold_hp]=register_cvar(Cvars[12][0],Cvars[12][1])
	cvars[gold_ap]=register_cvar(Cvars[13][0],Cvars[13][1])
	cvars[gold_money]=register_cvar(Cvars[14][0],Cvars[14][1])
	//------------------------------------

	//	Silver member :
	cvars[silver_hp]=register_cvar(Cvars[15][0],Cvars[15][1])
	cvars[silver_ap]=register_cvar(Cvars[16][0],Cvars[16][1])
	cvars[silver_money]=register_cvar(Cvars[17][0],Cvars[17][1])
	//------------------------------------

	//	Bronze member :
	cvars[bronze_hp]=register_cvar(Cvars[18][0],Cvars[18][1])
	cvars[bronze_ap]=register_cvar(Cvars[19][0],Cvars[19][1])
	cvars[bronze_money]=register_cvar(Cvars[20][0],Cvars[20][1])
	//------------------------------------

	//	VIP :
	cvars[vip_hp]=register_cvar(Cvars[21][0],Cvars[21][1])
	cvars[vip_ap]=register_cvar(Cvars[22][0],Cvars[22][1])
	cvars[vip_money]=register_cvar(Cvars[23][0],Cvars[23][1])
	//------------------------------------
}

public plugin_cfg()
{
	new ConfigDIR[128],AccesFILE[50],CvarFILE[100],FilePointer,FilePointerX,FileData[256],name[32],access_number[1]
	get_configsdir(ConfigDIR,charsmax(ConfigDIR))
	formatex(AccesFILE,charsmax(AccesFILE),"%s/%s",ConfigDIR,FILE_ACCESS)
	if(!file_exists(AccesFILE))
	{
		FilePointer=fopen(AccesFILE,"w+")
		fputs(FilePointer,"// Aici faci configuratia acceselor, de forma ^"nume^" ^"numar^"^n")
		fputs(FilePointer,"//  Iar ^"numar^" reprezinta accesul acelui nume. Accese valide: 1->8^n")
		fputs(FilePointer,"//   Unde 1 este Fondator+Ftp iar 8 VIP^n")
		fputs(FilePointer,"// Pentru a bloca un acces, poti pune  ^";^" | ^"#^" | ^"//^"  in fata sa, sau poti sterge direct.^n^n")
		fclose(FilePointer)
	}
	FilePointer=fopen(AccesFILE,"rt")
	if(FilePointer)
	{
		while(!feof(FilePointer))
		{
			fgets(FilePointer,FileData,charsmax(FileData))
			if(!FileData[0]||FileData[0]==';'||FileData[0]=='#'||(FileData[0]=='/'&&FileData[1]=='/'))	continue
			//trim(FileData)
			parse(FileData,name,charsmax(name),access_number,charsmax(access_number))
			TrieSetString(eData,name,access_number)
			
			//copy(numar_acces,charsmax(numar_acces),access_number)
			
			/*new i
			for(i=0;i<sizeof FlagsNR;i++)
			{
				TrieSetString(eData,name,FlagsNR[i][0])
			}*/
		}
		fclose(FilePointer)
	}
	
	formatex(CvarFILE,charsmax(CvarFILE),"%s/%s",ConfigDIR,FILE_CVARS)
	if(!file_exists(CvarFILE))
	{
		FilePointerX=fopen(CvarFILE,"w+")
		fputs(FilePointerX,"// Aici faci configuratia cvar-urilor!^n")
		fputs(FilePointerX,"^n^n//Fondator+FTP SETTs^n")
		fprintf(FilePointerX,"%s ^"%d^"^n",Cvars[0][0],get_pcvar_num(cvars[fondator_hp]))
		fprintf(FilePointerX,"%s ^"%d^"^n",Cvars[1][0],get_pcvar_num(cvars[fondator_ap]))
		fprintf(FilePointerX,"%s ^"%d^"^n^n",Cvars[2][0],get_pcvar_num(cvars[fondator_money]))
		fputs(FilePointerX,"//Fondator-FTP SETTs^n")
		fprintf(FilePointerX,"%s ^"%d^"^n",Cvars[3][0],get_pcvar_num(cvars[fondatorfaraftp_hp]))
		fprintf(FilePointerX,"%s ^"%d^"^n",Cvars[4][0],get_pcvar_num(cvars[fondatorfaraftp_ap]))
		fprintf(FilePointerX,"%s ^"%d^"^n^n",Cvars[5][0],get_pcvar_num(cvars[fondatorfaraftp_money]))
		fputs(FilePointerX,"//Daimond SETTs^n")
		fprintf(FilePointerX,"%s ^"%d^"^n",Cvars[6][0],get_pcvar_num(cvars[daimond_hp]))
		fprintf(FilePointerX,"%s ^"%d^"^n",Cvars[7][0],get_pcvar_num(cvars[daimond_ap]))
		fprintf(FilePointerX,"%s ^"%d^"^n^n",Cvars[8][0],get_pcvar_num(cvars[daimond_money]))
		fputs(FilePointerX,"//Platinium SETTs^n")
		fprintf(FilePointerX,"%s ^"%d^"^n",Cvars[9][0],get_pcvar_num(cvars[platinium_hp]))
		fprintf(FilePointerX,"%s ^"%d^"^n",Cvars[10][0],get_pcvar_num(cvars[platinium_ap]))
		fprintf(FilePointerX,"%s ^"%d^"^n^n",Cvars[11][0],get_pcvar_num(cvars[platinium_money]))
		fputs(FilePointerX,"//Gold SETTs^n")
		fprintf(FilePointerX,"%s ^"%d^"^n",Cvars[12][0],get_pcvar_num(cvars[gold_hp]))
		fprintf(FilePointerX,"%s ^"%d^"^n",Cvars[13][0],get_pcvar_num(cvars[gold_ap]))
		fprintf(FilePointerX,"%s ^"%d^"^n^n",Cvars[14][0],get_pcvar_num(cvars[gold_money]))
		fputs(FilePointerX,"//Silver SETTs^n")
		fprintf(FilePointerX,"%s ^"%d^"^n",Cvars[15][0],get_pcvar_num(cvars[silver_hp]))
		fprintf(FilePointerX,"%s ^"%d^"^n",Cvars[16][0],get_pcvar_num(cvars[silver_ap]))
		fprintf(FilePointerX,"%s ^"%d^"^n^n",Cvars[17][0],get_pcvar_num(cvars[silver_money]))
		fputs(FilePointerX,"//Bronze SETTs^n")
		fprintf(FilePointerX,"%s ^"%d^"^n",Cvars[18][0],get_pcvar_num(cvars[bronze_hp]))
		fprintf(FilePointerX,"%s ^"%d^"^n",Cvars[19][0],get_pcvar_num(cvars[bronze_ap]))
		fprintf(FilePointerX,"%s ^"%d^"^n^n",Cvars[20][0],get_pcvar_num(cvars[bronze_money]))
		fputs(FilePointerX,"//V.I.P SETTs^n")
		fprintf(FilePointerX,"%s ^"%d^"^n",Cvars[21][0],get_pcvar_num(cvars[vip_hp]))
		fprintf(FilePointerX,"%s ^"%d^"^n",Cvars[22][0],get_pcvar_num(cvars[vip_ap]))
		fprintf(FilePointerX,"%s ^"%d^"^n",Cvars[23][0],get_pcvar_num(cvars[vip_money]))
		fclose(FilePointerX)
		server_print("* Am scris fisierul %s pentru ca nu exista, si l-am incarcat!",CvarFILE)
		server_cmd("exec %s",CvarFILE)
	}
	else
	{
		new TD[65],bool:error=false,line=0,length=0,count=0,text[512]
		get_time("%H:%M:%S | %d.%m.%Y",TD,charsmax(TD))

		while(read_file(CvarFILE,line++,text,charsmax(text),length))//shit 15% Xd
		{
			if(/*!text[0]||text[0]=='^n'||*/text[0]==';'||(text[0]=='/'&&text[1]=='/'))	continue
			new cvarX[32],param[32],bool:error_1=true,bool:error_2=true
			trim(text)
			parse(text,cvarX,charsmax(cvarX),param,charsmax(param))
			for(new i=0;i<=charsmax(Cvars);i++)	if(equal(cvarX,Cvars[i][0]))	error_1=false
			if(param[0]&&!(equali(param," ")))	error_2=false

			if(error_1)
			{
				server_print("[%s] [ERROR] > Cvar necunoscut: ^"%s^"",TD,cvarX)
				error=true
			}
			else
			{
				if(error_2)
				{
					server_print("[%s] [ERROR] > Valoare incorecta pentru: ^"%s^"",TD,cvarX)
					error=true
				}
				else
				{
					server_print("[%s] [OK] > Procesare cvar ^"%s^" valoare ^"%d^"",TD,cvarX,param)
					//server_cmd("%s %s",cvar,param)
					count++
				}
			}
		}

		if(!count)
		{
			server_print("[%s] [ERROR] > Se pare ca nu am gasit nimic de citit din %s",TD,FILE_CVARS)
			error=true
		}

		server_print("-----------------------------------------------------------------------------")

		if(error)
		{
			server_print("[%s] [AVERTISMENT] > S-au intampinat probleme la citira unor date din %s!",TD,FILE_CVARS)
			server_print("> Cauta dupa ^"[ERROR]^" in mesajele de mai sus, pentru a rezolva problema!")
		}
		else
		{
			server_print("* Am incarcat cu succes setarile din %s",CvarFILE)
			server_cmd("exec %s",CvarFILE)
		}
	}
}

public evDeathMsg()
{
	new iKiller=read_data(1),iVictim=read_data(2)
	
	if(iKiller==iVictim||!is_user_alive(iKiller))	return
	
	//if(TrieKeyExists(eData,get_name(iKiller)))
	//{
		//switch(numar_acces[iKiller])
	new number[2]
	//TrieGetString(eData,get_name(iKiller),number,charsmax(number))
	switch(TrieGetString(eData,get_name(iKiller),number,charsmax(number))/*number*/)
	{
			case 1:
			{
				cs_set_user_money(iKiller,cs_get_user_money(iKiller)+get_pcvar_num(cvars[fondator_money]),1)
				set_user_health(iKiller,get_user_health(iKiller)+get_pcvar_num(cvars[fondator_hp]))
				set_user_armor(iKiller,get_user_armor(iKiller)+get_pcvar_num(cvars[fondator_ap]))
			}

			case 2:
			{
				cs_set_user_money(iKiller,cs_get_user_money(iKiller)+get_pcvar_num(cvars[fondatorfaraftp_money]),1)
				set_user_health(iKiller,get_user_health(iKiller)+get_pcvar_num(cvars[fondatorfaraftp_hp]))
				set_user_armor(iKiller,get_user_armor(iKiller)+get_pcvar_num(cvars[fondatorfaraftp_ap]))
			}

			case 3:
			{
				cs_set_user_money(iKiller,cs_get_user_money(iKiller)+get_pcvar_num(cvars[daimond_money]),1)
				set_user_health(iKiller,get_user_health(iKiller)+get_pcvar_num(cvars[daimond_hp]))
				set_user_armor(iKiller,get_user_armor(iKiller)+get_pcvar_num(cvars[daimond_ap]))
			}

			case 4:
			{
				cs_set_user_money(iKiller,cs_get_user_money(iKiller)+get_pcvar_num(cvars[platinium_money]),1)
				set_user_health(iKiller,get_user_health(iKiller)+get_pcvar_num(cvars[platinium_hp]))
				set_user_armor(iKiller,get_user_armor(iKiller)+get_pcvar_num(cvars[platinium_ap]))
			}

			case 5:
			{
				cs_set_user_money(iKiller,cs_get_user_money(iKiller)+get_pcvar_num(cvars[gold_money]),1)
				set_user_health(iKiller,get_user_health(iKiller)+get_pcvar_num(cvars[gold_hp]))
				set_user_armor(iKiller,get_user_armor(iKiller)+get_pcvar_num(cvars[gold_ap]))
			}

			case 6:
			{
				cs_set_user_money(iKiller,cs_get_user_money(iKiller)+get_pcvar_num(cvars[silver_money]),1)
				set_user_health(iKiller,get_user_health(iKiller)+get_pcvar_num(cvars[silver_hp]))
				set_user_armor(iKiller,get_user_armor(iKiller)+get_pcvar_num(cvars[silver_ap]))
			}

			case 7:
			{
				cs_set_user_money(iKiller,cs_get_user_money(iKiller)+get_pcvar_num(cvars[bronze_money]),1)
				set_user_health(iKiller,get_user_health(iKiller)+get_pcvar_num(cvars[bronze_hp]))
				set_user_armor(iKiller,get_user_armor(iKiller)+get_pcvar_num(cvars[bronze_ap]))
			}

			case 8:
			{
				cs_set_user_money(iKiller,cs_get_user_money(iKiller)+get_pcvar_num(cvars[vip_money]),1)
				set_user_health(iKiller,get_user_health(iKiller)+get_pcvar_num(cvars[vip_hp]))
				set_user_armor(iKiller,get_user_armor(iKiller)+get_pcvar_num(cvars[vip_ap]))
			}
	}
	//}
}

stock get_name(id)
{
	new name[32]
	get_user_name(id,name,charsmax(name))
	return name
}

public plugin_end()	TrieDestroy(eData)

#pragma tabsize 0
