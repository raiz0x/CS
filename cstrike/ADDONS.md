OFFICIAL LINK - https://www.extreamcs.com/forum/search.php?keywords=&terms=all&author=Levin&fid%5B%5D=34&sc=1&sf=titleonly&sr=topics&sk=t&sd=d&st=0&ch=300&t=0&submit=Search

<br><br>

DIRECT DWD LINKS:
1. Ghost-Fury @2018 - https://www.dropbox.com/s/wft0ivb8zs396qm/FURY%20OF%20GHOSTS%20%23EXTREAMCS.COM.zip?dl=1
2. Classic new style @2017 - https://www.dropbox.com/scl/fi/8gtmqi3n90zjxomgd6tbt/CS-EXTREAMCS.COM.zip?rlkey=7w00lazl7fk0imvpj0p5wcqej&st=plab324w&dl=1
3. Respawn new style @2013 - https://www.dropbox.com/s/1urs0ng4wqrqauy/RESPAWN%20%23EXTREAMCS.COM.zip?dl=1 + fix - https://www.dropbox.com/scl/fi/grm9iz5b7i74r9d6c4znr/RESPAWN-edit-EXTREAMCS.COM.zip?rlkey=ikx1084yfob55qjb94fl41o9p&st=ovpq3xpm&dl=1
4. Zombie giant @2018 - https://www.dropbox.com/s/hq5etgb2ti5gj13/Zombie-Giant2%20%23EXTREAMCS.COM.zip?dl=1
5. Zombie plague new style @2016 - https://www.dropbox.com/s/g1keq8z2wmi8qa3/ZP%40CS0%20%23EXTREAMCS.COM.zip?dl=1
6. Jailbreak - https://www.dropbox.com/s/07clexxwj2stv1p/JB%20%23EXTREAMCS.COM.zip?dl=1
7. Flower attack @2018 - https://www.dropbox.com/s/5p74rga0ul2mbiu/FLOWER%20%23EXTREAMCS.COM.zip?dl=1
8. Furien xp @2017 - https://www.dropbox.com/s/2g5mkbjobn3y8pu/FURIEN-XP%20%23EXTREAMCS.COM.zip?dl=1
9. Zombie escape new style @2017 - https://www.dropbox.com/s/arn3gckz7cv6pwk/ZE%20%23EXTREAMCS.COM.zip?dl=1
10. Biohazard @2020 - https://www.dropbox.com/scl/fi/ne064xylbka6qow5rgiva/BIOHAZARD-EXTREAMCS.COM.zip?rlkey=kv353pwnqucfm7n0tzej1rvy4&st=6wz89wtw&dl=1
11. War3ft RC13,14,15 - https://www.dropbox.com/scl/fi/upc74kirat9j8p4hwbeua/WAR3FT-EXTREAMCS.COM.zip?rlkey=t2mkvabyf04zfxdpf2og3jqsu&st=v67wzsdf&dl=1
12. ZE @2017 - https://www.dropbox.com/scl/fi/6t2w3de4j3c0nsy3w0evj/ZE-EXTREAMCS.COM.zip?rlkey=c833ah1bp72jreexw566cxlfh&st=8lzrxdpl&dl=1
13. ZE @2019(2022 extension) - https://www.dropbox.com/scl/fi/6t2w3de4j3c0nsy3w0evj/ZE-EXTREAMCS.COM.zip?rlkey=c833ah1bp72jreexw566cxlfh&st=mnscfx91&dl=1
14. Bhop v2 @2016 - https://www.dropbox.com/scl/fi/hf2qg3hmv6t83bhlu9ogr/BHOP-EXTREAMCS.COM.zip?rlkey=hw414q7vpmfozwlczarqf4mm2&st=t56ueja0&dl=1

<br>

Password: **extreamcs.com**

<br><br><br>

#### **<h3>FIXES:</h3>**

<br><br>

**2.**

Errors:
```
L 01/07/2019 - 23:38:25: [AMXX] Plugin file open error (plugin "pula.amxx")
L 01/07/2019 - 23:38:25: [AMXX] Plugin file open error (plugin "evo-mesaje.amxx")
L 01/07/2019 - 23:38:25: [AMXX] Plugin file open error (plugin "evo-fp2.amxx")
L 01/07/2019 - 23:38:25: [AMXX] Plugin file open error (plugin "amxx_evo.amxx")
L 01/07/2019 - 23:38:25: [AMXX] Plugin file open error (plugin "GHW_Weapon_Replacement.amxx")
L 01/07/2019 - 23:38:25: [AMXX] Plugin file open error (plugin "semiclip.amxx")
L 01/07/2019 - 23:38:25: [AMXX] Plugin file open error (plugin "sillyc4.amxx")
L 01/07/2019 - 23:38:25: [AMXX] Plugin file open error (plugin "ne_unlimitedammo.amxx")
L 01/07/2019 - 23:38:25: [AMXX] Plugin file open error (plugin "arme_vip2.amxx")
L 01/07/2019 - 23:38:25: [AMXX] Plugin file open error (plugin "ora_data.amxx")
```

<br><br>

sillyc4.amxx - https://forums.alliedmods.net/showthread.php?p=387759

<br>

semiclip.amxx - https://forums.alliedmods.net/showthread.php?p=2218890#post2218890 (module)

<br>
OR

<br>

```pawn
#include <amxmodx>
#include <fakemeta>

#pragma semicolon 1

#define DISTANCE 120.0
#define UPDATE_FREQ 0.2

new bool:g_bSemiclip[33][33];
new bool:g_bHasSemiclip[33];
new bool:g_bSemiclipEnabled;

new g_iTaskId;
new g_iForwardId[3];
new g_iMaxPlayers;
new g_iCvar[3];

public plugin_init( )
{
	register_plugin( "(Team-)Semiclip", "1.0", "SchlumPF*" );
	
	g_iCvar[0] = register_cvar( "semiclip_enabled", "1" );
	g_iCvar[1] = register_cvar( "semiclip_teamclip", "1" );
	g_iCvar[2] = register_cvar( "semiclip_transparancy", "0" );
	
	register_forward( FM_Think, "fwdThink" );
	register_forward( FM_ClientCommand, "fwdClientCommand" );
	
	if( get_pcvar_num( g_iCvar[0] ) )
	{
		g_iForwardId[0] = register_forward( FM_PlayerPreThink, "fwdPlayerPreThink" );
		g_iForwardId[1] = register_forward( FM_PlayerPostThink, "fwdPlayerPostThink" );
		g_iForwardId[2] = register_forward( FM_AddToFullPack, "fwdAddToFullPack_Post", 1 );
		
		g_bSemiclipEnabled = true;
	}
	else
		g_bSemiclipEnabled = false;
	
	g_iMaxPlayers = get_maxplayers( );
	
	new ent = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	set_pev( ent, pev_classname, "task_semiclip" );
	set_pev( ent, pev_nextthink, get_gametime( ) + 1.01 );
	g_iTaskId = ent;
}

public fwdPlayerPreThink( plr )
{
	static id;
	
	if( is_user_alive( plr ) )
	{
		for( id = 1 ; id <= g_iMaxPlayers ; id++ )
		{
			if( pev( id, pev_solid ) == SOLID_SLIDEBOX && g_bSemiclip[plr][id] && id != plr )
			{
				set_pev( id, pev_solid, SOLID_NOT );
				g_bHasSemiclip[id] = true;
			}
		}
	}
}

public fwdPlayerPostThink( plr )
{
	static id;

	if( is_user_alive( plr ) )
	{
		for( id = 1 ; id <= g_iMaxPlayers ; id++ )
		{
			if( g_bHasSemiclip[id] )
			{
				set_pev( id, pev_solid, SOLID_SLIDEBOX );
				g_bHasSemiclip[id] = false;
			}
		}
	}
}

public fwdThink( ent )
{
	static i, j;
	static team[33];
	static Float:origin[33][3];
	
	if( ent == g_iTaskId )
	{
		if( get_pcvar_num( g_iCvar[0] ) )
		{
			for( i = 1 ; i <= g_iMaxPlayers ; i++ )
			{
				if( is_user_alive( i ) )
				{
					pev( i, pev_origin, origin );
						
					if( get_pcvar_num( g_iCvar[1] ) )
						team = get_user_team( i );
					
					for( j = 1 ; j <= g_iMaxPlayers ; j++ )
					{
						if( is_user_alive( j ) )
						{
							if( get_pcvar_num( g_iCvar[1] ) && team != team[j] )
							{
								g_bSemiclip[j] = false;
								g_bSemiclip[j] = false;
								
							}	
							else if( floatabs( origin[0] - origin[j][0] ) < DISTANCE && floatabs( origin[1] - origin[j][1] ) < DISTANCE && floatabs( origin[2] - origin[j][2] ) < ( DISTANCE * 2 ) )
							{
								g_bSemiclip[j] = true;
								g_bSemiclip[j] = true;
							}
							else
							{
								g_bSemiclip[i][j] = false;
								g_bSemiclip[j][i] = false;
							}
						}
					}
				}
			}
		}
		
		set_pev( ent, pev_nextthink, get_gametime( ) + UPDATE_FREQ );
	}
}

public fwdAddToFullPack_Post( es_handle, e, ent, host, hostflags, player, pset )
{
	if( player )
	{
		if( g_bSemiclip[host][ent] )
		{
			set_es( es_handle, ES_Solid, SOLID_NOT );
			
			if( get_pcvar_num( g_iCvar[2] ) == 1 )
			{
				set_es( es_handle, ES_RenderMode, kRenderTransAlpha );
				set_es( es_handle, ES_RenderAmt, 85 );
			}
			else if( get_pcvar_num( g_iCvar[2] ) == 2 )
			{
				set_es( es_handle, ES_Effects, EF_NODRAW );
				set_es( es_handle, ES_Solid, SOLID_NOT );
			}
		}
	}
}

public fwdClientCommand( plr )
{
	if( !get_pcvar_num( g_iCvar[0] ) && g_bSemiclipEnabled )
	{
		unregister_forward( FM_PlayerPreThink, g_iForwardId[0] );
		unregister_forward( FM_PlayerPostThink, g_iForwardId[1] );
		unregister_forward( FM_AddToFullPack, g_iForwardId[2], 1 );
		
		g_bSemiclipEnabled = false;
	}
	else if( get_pcvar_num( g_iCvar[0] ) && !g_bSemiclipEnabled )
	{
		g_iForwardId[0] = register_forward( FM_PlayerPreThink, "fwdPlayerPreThink" );
		g_iForwardId[1] = register_forward( FM_PlayerPostThink, "fwdPlayerPostThink" );
		g_iForwardId[2] = register_forward( FM_AddToFullPack, "fwdAddToFullPack_Post", 1 );
		
		g_bSemiclipEnabled = true;
	}
}
```

<br><br>

ne_unlimitedammo.amxx - https://forums.alliedmods.net/showthread.php?p=637445

<br>

GHW_Weapon_Replacement.amxx - https://forums.alliedmods.net/showthread.php?t=43979

<br>

amxx_evo.amxx - i ll not publish it

<br>

evo_mesaje.amxx - (ad manager)

<br>

```pawn
#include <amxmodx>
#include <amxmisc>

#pragma semicolon 1

new const PLUGIN[] = "Autoresponder/Advertiser";
new const VERSION[] = "0.5";
new const AUTHOR[] = "MaximusBrood";

#define NORM_AD 0
#define SAY_AD 1

#define COND 0
#define STORE 1

#define COND_TKN '%'
#define SAY_TKN '@'

#define COND_STKN "%"
#define DEVIDE_STKN "~"
#define SAY_STKN "@"

//-.-.-.-.-.-.-.-.DEFINES.-.-.-.-.-.-.-.-.-.-.

//Maximum amount of ads
#define MAXADS 64

//Minimum difference between two different ads (float)
new const Float:RAND_MIN = 50.0;

//Maximum difference between two different ads (float)
new const Float:RAND_MAX = 60.0;

//-.-.-.-.-.-.-.-.END DEFINES..-.-.-.-.-.-.-.

//Stores
new sayConditions[MAXADS][3][32];
new normConditions[MAXADS][3][32];
new normStore[MAXADS][128];
new sayStore[MAXADS][2][128];

new gmsgSayText;

//Counters
new adCount[2] = {0, 0};

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar("admanager_version", "0.5", FCVAR_SERVER);
	
	register_cvar("ad_react_all", "0");
	
	gmsgSayText = get_user_msgid("SayText");
	
	register_clcmd("say","eventSay");
	register_clcmd("say_team","eventSay");
	
	//Delay the load proces by 10 sec because we don't want to get more load
	//on the already high-load mapchange.
	//Too soon to affect players while playing, too late to create time-out @ mapchange
	set_task(10.0, "load");
}

public load()
{
	//Load the data
	new filepath[64];
	get_configsdir(filepath, 63);
	format(filepath, 63, "%s/mesaje.ini", filepath);
	
	if(file_exists(filepath))
	{
		new output[512], conditions[128], temp[64], type;
		
		//Open file
		new fHandle = fopen(filepath, "rt");
		
		//Checks for failure
		if(!fHandle)
			return;
		
		//Loop through all lines
		for(new a = 0; a < MAXADS && !feof(fHandle); a++)
		{
			//Get line
			fgets(fHandle, output, 511);
			
			
			//Work away comments
			if(output[0] == ';' || !output[0] || output[0] == ' ' || output[0] == 10) 
			{
				//Line is not counted
				a--;
				continue;
			}
			
			//Reset type
			type = 0;
			
			//Check if it contains conditions
			if(output[0] == COND_TKN)
			{
				//Cut the conditions off the string
				split(output, conditions, 127, output, 511, DEVIDE_STKN);
				
				//Determine if its say check or normal ad
				type = output[0] == SAY_TKN ? 1 : 0;
				
				//Put the conditions in own space
				for(new b = 0; b < 3; b++)
				{
					new sort[16], cond[32], numb;
					
					//Remove the % from line 
					conditions[0] = ' ';
					trim(conditions);
					
					//Get one condition from the line
					split(conditions, temp, 64, conditions, 127, COND_STKN);
					
					split(temp, sort, 15, cond, 31, " ");
					
					if(equali(sort, "map"))
					{
						numb = 0;
					} else if(equali(sort, "min_players"))
					{
						numb = 1;
					} else if(equali(sort, "max_players"))
					{
						numb = 2;
					} else
					{
						continue;
					}
					
					//Copy it to its final resting place ^^
					setString(COND, type, cond, adCount[type], numb);
					
					//Exit if it hasn't got more conditions
					if(!conditions[0])
						break;
				}
			}
			
			if(type == 0)
				type = output[0] == SAY_TKN ? 1 : 0;
			
			if(type == SAY_AD)
			{
				new said[32], answer[128];
				
				//Remove the @ from line
				output[0] = ' ';
				trim(output);
				
				split(output, said, 31, answer, 127, DEVIDE_STKN);
				
				//Apply color
				setColor(answer, 127);
				
				//Save it
				setString(STORE, SAY_AD, said, adCount[SAY_AD], 0);
				setString(STORE, SAY_AD, answer, adCount[SAY_AD], 1);
			} else//if(type == NORM_AD)
			{
				//Apply color
				setColor(output, 511);
				
				//Save it
				setString(STORE, NORM_AD, output, adCount[NORM_AD]);
			}
			
			//Increment the right counter
			adCount[NORM_AD] += type == NORM_AD ? 1 : 0;
			adCount[SAY_AD]  += type == SAY_AD  ? 1 : 0;
		}
		
		//Set a first task, if there are any normal ads
		if(adCount[NORM_AD] != 0)
			set_task(random_float(RAND_MIN, RAND_MAX), "eventTask");
		
		//Close file to prevent lockup
		fclose(fHandle);	
	}
}

new currAd = -1;

public eventTask()
{
	//Go past all ads and check conditions
	for(new a = 0; a < adCount[NORM_AD]; a++)
	{
		//Put current ad to the next one
		currAd = currAd == adCount[NORM_AD] - 1 ? 0 : currAd + 1;
		
		if(checkConditions(currAd, NORM_AD))
		{
			//Display the ad
			new data[3];
			data[0] = currAd;
			data[1] = NORM_AD;
			data[2] = 0;
			displayAd(data);
			
			break;
		}
	}
		
	//Set a new task
	set_task(random_float(RAND_MIN, RAND_MAX), "eventTask");
	
	return PLUGIN_CONTINUE;
}

public eventSay(id)
{
	//If nothing is said, don't check
	if(adCount[SAY_AD] == 0)
		return PLUGIN_CONTINUE;
	
	new talk[64], keyword[16];
	read_args(talk, 63) ;
		
	//En nu rennen voor jullie zakgeld klootzjakken!
	for(new a = 0; a < adCount[SAY_AD]; a++)
	{
		//Get the string
		getString(STORE, SAY_AD, keyword, 15, a, 0);
		
		if(containi(talk, keyword) != -1)
		{
			//Check the rest if it fails to conditions
			if(!checkConditions(a, SAY_AD))
				continue;
			
			new data[3];
			data[0] = a;
			data[1] = SAY_AD;
			data[2] = id;
			
			//Set the task
			set_task(0.3, "displayAd", 0, data, 3);
			
			//Don't execute more of them
			break;
		}
	}
	
	return PLUGIN_CONTINUE;
}

public displayAd(params[])
{
	//Get the string that is going to be displayed
	new message[128];
	getString(STORE, params[1], message, 127, params[0], params[1]);
	
	//If its enabled by cvar and id is set, display to person who triggered message only
	if(get_cvar_num("ad_react_all") == 0 && params[2] != 0)
	{
		message_begin(MSG_ONE, gmsgSayText, {0,0,0}, params[2]);
		write_byte(params[2]);
		write_string(message);
		message_end();
	
	} else
	{
		//Display the message to everyone
		new plist[32], playernum, player;
		
		get_players(plist, playernum, "c");
	
		for(new i = 0; i < playernum; i++)
		{
			player = plist[i];
			
			message_begin(MSG_ONE, gmsgSayText, {0,0,0}, player);
			write_byte(player);
			write_string(message);
			message_end();
		}
	}
	
	return PLUGIN_HANDLED;
}

//---------------------------------------------------------------------------
//                                STOCKS
//---------------------------------------------------------------------------

stock checkConditions(a, type)
{
	//Mapname
	if((type == NORM_AD && normConditions[a][0][0]) || (type == SAY_AD && sayConditions[a][0][0]))
	{
		new mapname[32];
		get_mapname(mapname, 31);
		
		if(! (type == NORM_AD && equali(mapname, normConditions[a][0]) ) || (type == SAY_AD && equali(mapname, sayConditions[a][0]) ) )
			return false;
	}
	
	//Min Players
	if((type == NORM_AD && normConditions[a][1][0]) || (type == SAY_AD && sayConditions[a][1][0]))
	{
		new playersnum = get_playersnum();
		
		if( (type == NORM_AD && playersnum < str_to_num(normConditions[a][1]) ) || (type == SAY_AD && playersnum < str_to_num(sayConditions[a][1]) ) )
			return false;
	}
	
	//Max Players
	if((type == NORM_AD && normConditions[a][2][0]) || (type == SAY_AD && sayConditions[a][2][0]))
	{
		new playersnum = get_playersnum();
		
		if( (type == NORM_AD && playersnum > str_to_num(normConditions[a][2]) ) || (type == SAY_AD && playersnum > str_to_num(sayConditions[a][2]) ) )
			return false;
	}
	
	//If everything went fine, return true
	return true;
}	

stock setColor(string[], len)
{
	if (contain(string, "!t") != -1 || contain(string, "!g") != -1 || contain(string,"!n") != -1)
	{
		//Some nice shiny colors ^^
		replace_all(string, len, "!t", "^x03");
		replace_all(string, len, "!n", "^x01");
		replace_all(string, len, "!g", "^x04");
		
		//Work away a stupid bug
		format(string, len, "^x01%s", string);
	}
}

stock getString(mode, type, string[], len, one, two = 0)
{
	//server_print("mode: %d type: %d len: %d one: %d two %d", mode, type, len, one, two);
	
	//Uses the fact that a string is passed by reference
	if(mode == COND)
	{
		if(type == NORM_AD)
		{
			copy(string, len, normConditions[one][two]);
		} else//if(type = SAY_AD)
		{
			copy(string, len, sayConditions[one][two]);
		}
	} else//if(mode == STORE)
	{
		if(type == NORM_AD)
		{
			copy(string, len, normStore[one]);
		} else//if(type == SAY_AD)
		{
			copy(string, len, sayStore[one][two]);
		}
	}
}

stock setString(mode, type, string[], one, two = 0)
{
	if(mode == COND)
	{
		if(type == NORM_AD)
		{
			copy(normConditions[one][two], 31, string);
		} else//if(type = SAY_AD)
		{
			copy(sayConditions[one][two], 31, string);
		}
	} else//if(mode == STORE)
	{
		if(type == NORM_AD)
		{
			copy(normStore[one], 127, string);
		} else//if(type == SAY_AD)
		{
			copy(sayStore[one][two], 127, string);
		}
	}
}
```

<br><br>

pula.amxx - (rom protect)

<br>

```pawn
#include <amxmisc>
#include <fakemeta>

#pragma semicolon 1

#if AMXX_VERSION_NUM < 182 
    #assert AMX Mod X v1.8.2 or later library required!
#endif

//offsets
const m_iMenu = 205;
const Menu_OFF = 0;
const Menu_ChooseAppearance = 3;

new const Version[]       = "1.0.4s-dev",
			 Build        = 98,
			 Date[]       = "10.12.2016",
			 PluginName[] = "ROM-Protect",
			 CfgFile[]    = "addons/amxmodx/configs/rom_protect.cfg",
			 LangFile[]   = "addons/amxmodx/data/lang/rom_protect.txt",
			 IniFile[]    = "addons/amxmodx/configs/rom_protect.ini",
			 LangType[]   = "%L",
			 NoLogInfo     = -1;

enum INFO
{
	INFO_NAME,
	INFO_IP,
	INFO_AUTHID    
};

enum
{
    FM_TEAM_T = 1,
    FM_TEAM_CT,
    FM_TEAM_SPECTATOR
};

enum _:AdminLogin
{
	LoginPass[32],
	LoginAccess[32],
	LoginFlag[6]
}

#if !defined MAX_PLAYERS
	#define MAX_PLAYERS 32
#endif

#if AMXX_VERSION_NUM < 183	
	#define MAX_NAME_LENGTH 32
	new AdminNum;
	new bool:IsFlooding[MAX_PLAYERS+1];
	new Float:Flooding[MAX_PLAYERS+1] = {0.0, ...},
			  Flood[MAX_PLAYERS+1] = {0, ...};		  
	enum _:Colors 
	{
		DontChange,
		Red,
		Blue,
		Grey
	}
#endif

new Counter[MAX_PLAYERS+1], LogFile[128], ClSaidSameTh_Count[MAX_PLAYERS+1],
	bool:CorrectName[MAX_PLAYERS+1], bool:IsAdmin[MAX_PLAYERS+1], bool:FirstMsg[MAX_PLAYERS+1],
	bool:Gag[MAX_PLAYERS+1], bool:UnBlockedChat[MAX_PLAYERS+1];
new LastPass[MAX_PLAYERS+1][32], Capcha[MAX_PLAYERS+1][8];
new Trie:LoginName, Trie:DefaultRes;
new PreviousMessage[MAX_PLAYERS+1][192]; // declarat global pentru a evita eroarea "Run time error 3: stack error"
new bool:IsLangUsed, bool:AdminsReloaded;

new const AllBasicOnChatCommads[][] =
{
	"amx_say", "amx_csay", "amx_psay", "amx_tsay", "amx_chat", "say_team", 
	"say", "amx_gag", "amx_kick", "amx_ban", "amx_banip", "amx_nick", "amx_rcon"
};

new const AllAutobuyCommands[][] =
{
	"cl_autobuy",
	"cl_rebuy",
	"cl_setautobuy",
	"cl_setrebuy"
};

enum _:AllCvars
{
	autobuy_bug,
	utf8_bom,
	Tag,
	cmd_bug,
	spec_bug,
	fake_players,
	fake_players_limit,
	fake_players_type,
	fake_players_punish,
#if AMXX_VERSION_NUM < 183
	admin_chat_flood,
	admin_chat_flood_time,
#endif
	advertise,
	advertise_time,
	delete_custom_hpk,
	delete_vault,
	plug_warn,
	plug_log,
	admin_login,
	admin_login_file,
	admin_login_debug,
	color_bug,
	motdfile,
	anti_pause,
	anti_ban_class,
	info,
	xfakeplayer_spam,
	xfakeplayer_spam_maxchars,
	xfakeplayer_spam_maxsais,
	xfakeplayer_spam_type,
	xfakeplayer_spam_punish,
	xfakeplayer_spam_capcha,
	xfakeplayer_spam_capcha_word,
	protcvars,
	console_say
};

new const CvarName[AllCvars][] = 
{
	"rom_autobuy_bug",
	"rom_utf8_bom",
	"rom_tag",
	"rom_cmd_bug",
	"rom_spec_bug",
	"rom_fake_players",
	"rom_fake_players_limit",
	"rom_fake_players_type",
	"rom_fake_players_punish",
#if AMXX_VERSION_NUM < 183
	"rom_admin_chat_flood",
	"rom_admin_chat_flood_time",
#endif
	"rom_advertise",
	"rom_advertise_time",
	"rom_delete_custom_hpk",
	"rom_delete_vault",
	"rom_warn",
	"rom_log",
	"rom_admin_login",
	"rom_admin_login_file",
	"rom_admin_login_debug",
	"rom_color_bug",
	"rom_motdfile",
	"rom_anti_pause",
	"rom_anti_ban_class",
	"rom_give_info",
	"rom_xfakeplayer_spam",
	"rom_xfakeplayer_spam_maxchars",
	"rom_xfakeplayer_spam_maxsais",
	"rom_xfakeplayer_spam_type",
	"rom_xfakeplayer_spam_punish",
	"rom_xfakeplayer_spam_capcha",
	"rom_xfakeplayer_spam_capcha_word",
	"rom_prot_cvars",
	"rom_console_say"
};


#if AMXX_VERSION_NUM >= 183
	enum _:CvarRange
	{
		hasMinValue,
		minValue,
		hasMaxValue,
		maxValue
	}

	new const CvarLimits[AllCvars][CvarRange] = 
	{
		{ 1, 0, 1, 1 },     // rom_autobuy_bug
		{ 1, 0, 1, 1 },     // rom_utf8_bom
		{ 0, 0, 0, 0 },     // rom_tag
		{ 1, 0, 1, 1 },     // rom_cmd_bug
		{ 1, 0, 1, 1 },     // rom_spec_bug
		{ 1, 0, 1, 1 },     // rom_fake_players
		{ 1, 3, 1, 10 },    // rom_fake_players_limit
		{ 1, 0, 1, 1 },     // rom_fake_players_type
		{ 1, 5, 1, 10080 }, // rom_fake_players_punish
		{ 1, 0, 1, 1 },     // rom_advertise
		{ 1, 30, 1, 480 },  // rom_advertise_time
		{ 1, 0, 1, 1 },     // rom_delete_custom_hpk
		{ 1, 0, 1, 2 },     // rom_delete_vault
		{ 1, 0, 1, 1 },     // rom_warn
		{ 1, 0, 1, 1 },     // rom_log
		{ 1, 0, 1, 1 },     // rom_admin_login
		{ 0, 0, 0, 0 },     // rom_admin_login_file
		{ 1, 0, 1, 1 },     // rom_admin_login_debug
		{ 1, 0, 1, 1 },     // rom_color_bug
		{ 1, 0, 1, 1 },     // rom_motdfile
		{ 1, 0, 1, 1 },     // rom_anti_pause
		{ 1, 0, 1, 4 },     // rom_anti_ban_class
		{ 1, 0, 1, 1 },     // rom_give_info
		{ 1, 0, 1, 2 },     // rom_xfakeplayer_spam
		{ 1, 5, 1, 15 },    // rom_xfakeplayer_spam_maxchars
		{ 1, 3, 0, 0 },     // rom_xfakeplayer_spam_maxsais
		{ 1, 0, 1, 2 },     // rom_xfakeplayer_spam_type
		{ 1, 5, 1, 10080 }, // rom_xfakeplayer_spam_punish
		{ 1, 0, 1, 1 },     // rom_xfakeplayer_spam_capcha
		{ 0, 0, 0, 0 },     // rom_xfakeplayer_spam_capcha_word
		{ 1, 0, 1, 1 },     // rom_prot_cvars
		{ 1, 0, 1, 1 }      // rom_console_say
	};
#endif

new const CvarValue[AllCvars][] =
{
	"1",
	"1",	
	"*ROM-Protect",
	"1",
	"1",
	"1",
	"5",
	"1",
	"10",
#if AMXX_VERSION_NUM < 183
	"1",
	"0.75",
#endif
	"1",
	"120",
	"1",
	"1",
	"1",
	"1",
	"1",
	"users_login.ini",
	"0",
	"1",
	"1",
	"1",
	"2",
	"1",
	"1",
	"12",
	"10",
	"2",
	"5",
	"0",
	"/chat",
	"1",
	"1"
};
	
new PluginCvar[AllCvars];

public plugin_precache()
{	
	registersPrecache();
	
	new CurentDate[15];
	get_localinfo("amxx_logs", LogFile, charsmax(LogFile));
	format(LogFile, charsmax(LogFile), "%s/%s", LogFile, PluginName);
	
	if ( !dir_exists(LogFile) )
	{
		mkdir(LogFile);
	}
	
	get_time("%d-%m-%Y", CurentDate, charsmax(CurentDate));
	format(LogFile, charsmax(LogFile), "%s/%s_%s.log", LogFile, PluginName, CurentDate);
	
	if ( !file_exists(LogFile) )
	{
		write_file(LogFile, "*Aici este salvata activitatea suspecta a fiecarui jucator.^n^n", -1);
	}
	
	if ( file_exists(CfgFile) )
	{
		server_cmd("exec %s", CfgFile);
	}
	
	set_task(5.0, "checkLang");
	set_task(10.0, "checkLangFile");
	set_task(15.0, "checkCfg");
}

public checkCfg()
{
	if ( !file_exists(CfgFile) )
	{
		WriteCfg(false);
	}
	else
	{
		new FilePointer = fopen(CfgFile, "rt");
		
		if ( !FilePointer ) 
		{
			return;
		}
		
		new Text[121], CurrentVersion[64], bool:IsCurrentVersionUsed;
		formatex(CurrentVersion, charsmax(CurrentVersion), "Versiunea : %s. Bulid : %d. Data lansarii versiunii : %s.", Version, Build, Date);
		
		while ( !feof(FilePointer) )
		{
			fgets(FilePointer, Text, charsmax(Text));
			
			if ( containi(Text, CurrentVersion) != -1 )
			{
				IsCurrentVersionUsed = true;
				break;
			}
		}
		fclose(FilePointer);
		
		if ( !IsCurrentVersionUsed )
		{
			WriteCfg(true);
			if ( getInteger(PluginCvar[plug_log]) == 1 )
			{
				new CvarString[32];
				getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
				logCommand(NoLogInfo, LangType, LANG_SERVER, "ROM_UPDATE_CFG", CvarString);
			}
		}
	}
}

public checkLang()
{
	if ( !file_exists(LangFile) )
	{
		WriteLang(false);
	}
	else
	{
		IsLangUsed = false;
		new FilePointer = fopen(LangFile, "rt");
		
		if ( !FilePointer ) 
		{
			return;
		}
		
		new Text[121], CurrentVersion[64], bool:IsCurrentVersionUsed;
		formatex(CurrentVersion, charsmax(CurrentVersion), "Versiunea : %s. Bulid : %d. Data lansarii versiunii : %s.", Version, Build, Date);
		
		while ( !feof(FilePointer) )
		{
			fgets(FilePointer, Text, charsmax(Text));
			
			if ( contain(Text, CurrentVersion) != -1 )
			{
				IsCurrentVersionUsed = true;
				break;
			}
		}
		fclose(FilePointer);
		
		if ( !IsCurrentVersionUsed )
		{
			register_dictionary("rom_protect.txt");
			IsLangUsed = true;
			if ( getInteger(PluginCvar[plug_log]) == 1 )
			{
				new CvarString[32];
				getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
				logCommand(NoLogInfo, LangType, LANG_SERVER, "ROM_UPDATE_LANG", CvarString);
			}
			WriteLang(true);
		}
	}
}

public checkLangFile()
{
	if (!IsLangUsed)
	{
		register_dictionary("rom_protect.txt");
	}
}

public plugin_init()
{
	registersInit();
	
	if ( getInteger(PluginCvar[advertise]) == 1 )
	{
		set_task(getFloat(PluginCvar[advertise_time]), "showAdvertise", _, _, _, "b", 0);
	}
	
	if ( getInteger(PluginCvar[utf8_bom]) == 1 )
	{
		DefaultRes = TrieCreate();
		TrieSetCell(DefaultRes, "de_storm.res", 1);
		TrieSetCell(DefaultRes, "default.res", 1);
		
		set_task(10.0, "cleanResFiles");
	}
}

public client_connect(Index)
{
	if (getInteger(PluginCvar[cmd_bug]) == 1)
	{
		new Name[MAX_NAME_LENGTH];
		get_user_name(Index, Name, charsmax(Name));
		stringFilter(Name, charsmax(Name));
		set_user_info(Index, "name", Name);
	}
}

public client_authorized(Index)
{	
	new CvarString[32];
	if (getInteger(PluginCvar[fake_players]) == 1)
	{
		if ( clientUseSteamid(Index) )
		{
			query_client_cvar(Index, "fps_max", "checkBot");
		}
	
		new Players[MAX_PLAYERS], PlayersNum, Address[32], Address2[32];
		get_players(Players, PlayersNum, "c");
		for (new i = 0; i < PlayersNum; ++i)
		{
			get_user_ip(Index, Address, charsmax(Address), 1);
			get_user_ip(Players[i], Address2, charsmax(Address2), 1);
			if ( equal(Address, Address2) && !is_user_bot(Index) )
			{
				if ( ++Counter[Index] > getInteger(PluginCvar[fake_players_limit]) )
				{
					getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
					switch ( getInteger(PluginCvar[fake_players_type]) )
					{
						case 0:
						{
							new Limit[8];
							num_to_str(getInteger(PluginCvar[fake_players_limit]), Limit, charsmax(Limit));
							console_print(Index, LangType, LANG_PLAYER, "ROM_FAKE_PLAYERS_KICK", CvarString, Limit);
							server_cmd("kick #%d ^"You got kicked. Check console.^"", get_user_userid(Index));
						}
						case 1: 
						{
							new Punish[8];
							num_to_str(getInteger(PluginCvar[fake_players_punish]), Punish, charsmax(Punish));
							server_cmd("addip ^"%s^" ^"%s^";wait;writeip", Punish, Address);
							if ( getInteger(PluginCvar[plug_warn]) == 1 )
							{
								new CvarTag[32];
								copy(CvarTag, charsmax(CvarTag), CvarString);
								#if AMXX_VERSION_NUM < 183
									client_print_color(0, Grey, LangType, LANG_PLAYER, "ROM_FAKE_PLAYERS", "^3", CvarTag, "^4", Address);
									client_print_color(0, Grey, LangType, LANG_PLAYER, "ROM_FAKE_PLAYERS_PUNISH", "^3", CvarTag, "^4", Punish);
								#else
									client_print_color(0, print_team_grey, LangType, LANG_PLAYER, "ROM_FAKE_PLAYERS", CvarTag, Address);
									client_print_color(0, print_team_grey, LangType, LANG_PLAYER, "ROM_FAKE_PLAYERS_PUNISH", CvarTag, Punish);
								#endif
							}
							if ( getInteger(PluginCvar[plug_log]) == 1 )
							{
								logCommand(NoLogInfo, LangType, LANG_SERVER, "ROM_FAKE_PLAYERS_LOG", CvarString, Address);
							}
						}
					}
					break;
				}
			}
		}
	}
	switch ( getInteger(PluginCvar[xfakeplayer_spam]))
	{
		case 1:
		{
			FirstMsg[Index] = true;
			Gag[Index] = false;
		}
		case 2:
		{
			if ( getInteger(PluginCvar[xfakeplayer_spam_capcha]) == 1 )
			{
				new const AllChars[] = 
				{
					'A','B','C','D','E','F','G','H',
					'I','J','K','L','M','N','O','P',
					'Q','R','S','T','U','V','W','X',
					'Y','Z','a','b','c','d','e','f',
					'g','h','i','j','k','l','m','n',
					'o','p','q','r','s','t','u','v',
					'w','x','y','z','0','1','2','3',
					'4','5','6','7','8','9'
				};
				const MatrixSize = sizeof AllChars;
				formatex(Capcha[Index], charsmax(Capcha[]), "%c%c%c%c", AllChars[random(MatrixSize)], AllChars[random(MatrixSize)], AllChars[random(MatrixSize)], AllChars[random(MatrixSize)]);
			}
			else
			{
				getString(PluginCvar[xfakeplayer_spam_capcha_word], CvarString, charsmax(CvarString));
				copy(Capcha[Index], charsmax(Capcha[]), CvarString);
			}
		}
	}
	
} 

#if AMXX_VERSION_NUM < 183
	public client_disconnect(Index)
#else
	public client_disconnected(Index)
#endif
{
	if ( getInteger(PluginCvar[fake_players]) == 1 )
	{
		Counter[Index] = 0;
	}
	if ( getInteger(PluginCvar[xfakeplayer_spam]) == 1 )
	{
		ClSaidSameTh_Count[Index] = 0;
	}
	else
	{
		UnBlockedChat[Index] = false;
	}
	if ( IsAdmin[Index] )
	{
		IsAdmin[Index] = false;
		remove_user_flags(Index);
	}
}

public plugin_end()
{
	switch ( getInteger(PluginCvar[delete_vault]) != 0 )
	{
		case 1:
		{
			write_file(getVaultDir(), "server_language en", -1);
		}
		case 2:
		{
			write_file(getVaultDir(), "server_language ro", -1);
		}
	}
	
	if ( getInteger(PluginCvar[delete_custom_hpk]) == 1 )
	{
		new BaseDir[] = "/", DirPointer, File[32];
		
		DirPointer = open_dir(BaseDir, "", 0);
		
		while ( next_file(DirPointer, File, charsmax(File)) )
		{
			if ( File[0] == '.' )
			{
				continue;
			}
			
			if ( containi( File, "custom.hpk" ) != -1 )
			{
				delete_file(File);
				break;
			}
		}
		
		close_dir(DirPointer);
	}
}

public client_infochanged(Index)
{
	if ( !is_user_connected(Index) )
	{
		return;
	}
	
	new CmdBugCvarValue = getInteger(PluginCvar[cmd_bug]), AdminLoginCvarValue = getInteger(PluginCvar[admin_login]);
	if ( CmdBugCvarValue == 1 || AdminLoginCvarValue == 1)
	{
		new NewName[MAX_NAME_LENGTH], OldName[MAX_NAME_LENGTH];
		get_user_name(Index, OldName, charsmax(OldName));
		get_user_info(Index, "name", NewName, charsmax(NewName));
		
		if (equali(NewName, OldName))
		{
			return;
		}
	
		if ( CmdBugCvarValue == 1 )
		{
			stringFilter(NewName, charsmax(NewName));
			set_user_info(Index, "name", NewName);
		}
	
		if ( AdminLoginCvarValue == 1 && IsAdmin[Index] )
		{
			IsAdmin[Index] = false;
			remove_user_flags(Index);
		}
	}
	
	return;
}

public plugin_pause()
{
	if (getInteger(PluginCvar[anti_pause]) == 1)
	{
		new PluginName[32], CvarString[32];
		getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
		
		if (getInteger(PluginCvar[plug_warn]) == 1)
		{
			#if AMXX_VERSION_NUM < 183
				client_print_color(0, Grey, LangType, LANG_PLAYER, "ROM_PLUGIN_PAUSE", "^3", CvarString, "^4");
			#else
				client_print_color(0, print_team_grey, LangType, LANG_PLAYER, "ROM_PLUGIN_PAUSE", CvarString);
			#endif
		}
		
		if (getInteger(PluginCvar[plug_log]) == 1)
		{
			logCommand(NoLogInfo, LangType, LANG_SERVER, "ROM_PLUGIN_PAUSE_LOG", CvarString, CvarString);
		}
		
		get_plugin(-1, PluginName, charsmax(PluginName));
		server_cmd("amxx unpause %s", PluginName);
	}
}

public cmdPass(Index)
{
	if ( getInteger(PluginCvar[admin_login]) != 1 )
	{
		return PLUGIN_HANDLED;
	}

	new Name[MAX_NAME_LENGTH], Password[32], CvarString[32];
	
	get_user_name(Index, Name, charsmax(Name));
	read_argv(1, Password, charsmax(Password));
	remove_quotes(Password);
	getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
	if (!Password[0])
	{
		#if AMXX_VERSION_NUM < 183
			client_print_color(Index, Grey, LangType, Index, "ROM_ADMIN_WITHOUT_PASS", "^3", CvarString, "^4");
		#else
			client_print_color(Index, print_team_grey, LangType, Index, "ROM_ADMIN_WITHOUT_PASS", CvarString);
		#endif
		console_print(Index, LangType, Index, "ROM_ADMIN_WITHOUT_PASS_PRINT", CvarString);

		return PLUGIN_HANDLED;
	}

	loadAdminLogin();
	IsAdmin[Index] = false;
	if ( !getAccess(Index, Password, charsmax(Password)) )
	{
		return PLUGIN_HANDLED;
	}
	
	if (!IsAdmin[Index])
	{
		LastPass[Index][0] = EOS;
		if (!CorrectName[Index])
		{		
			#if AMXX_VERSION_NUM < 183
				client_print_color(Index, Grey, LangType, Index, "ROM_ADMIN_WRONG_NAME", "^3", CvarString, "^4");
			#else
				client_print_color(Index, print_team_grey, LangType, Index, "ROM_ADMIN_WRONG_NAME", CvarString);
			#endif
			console_print(Index, LangType, Index, "ROM_ADMIN_WRONG_NAME_PRINT", CvarString);
		}
		else
		{
			#if AMXX_VERSION_NUM < 183
				client_print_color(Index, Grey, LangType, Index, "ROM_ADMIN_WRONG_PASS", "^3", CvarString, "^4");
			#else
				client_print_color(Index, print_team_grey, LangType, Index, "ROM_ADMIN_WRONG_PASS", CvarString);
			#endif
			console_print(Index, LangType, Index, "ROM_ADMIN_WRONG_PASS_PRINT", CvarString);
		}
	}
	else
	{
		if ( equal(LastPass[Index], Password) )
		{
			#if AMXX_VERSION_NUM < 183
				client_print_color(Index, Grey, LangType, Index, "ROM_ADMIN_ALREADY_LOADED", "^3", CvarString, "^4");
			#else
				client_print_color(Index, print_team_grey, LangType, Index, "ROM_ADMIN_ALREADY_LOADED", CvarString);
			#endif
			console_print(Index, LangType, Index, "ROM_ADMIN_ALREADY_LOADED_PRINT", CvarString);
		}
		else
		{
			#if AMXX_VERSION_NUM < 183
				client_print_color(Index, Grey, LangType, Index, "ROM_ADMIN_LOADED", "^3", CvarString, "^4");
			#else
				client_print_color(Index, print_team_grey, LangType, Index, "ROM_ADMIN_LOADED", CvarString);
			#endif
			console_print(Index, LangType, Index, "ROM_ADMIN_LOADED_PRINT", CvarString);

			IsAdmin[Index] = true;
		}
	}

	return PLUGIN_HANDLED;
}

#if AMXX_VERSION_NUM < 183
	public hookAdminChat(Index)
	{
		new Said[2];
		
		read_argv(1, Said, charsmax(Said));

		if (Said[0] != '@')
		{
			return PLUGIN_CONTINUE;
		}

		new Float:maxChat = get_pcvar_float(PluginCvar[admin_chat_flood_time]);

		if (maxChat && getInteger(PluginCvar[admin_chat_flood]) == 1)
		{
			new Float:NexTime = get_gametime();

			if (Flooding[Index] > NexTime)
			{
				if (Flood[Index] >= 3)
				{
					IsFlooding[Index] = true;
					set_task(1.0, "showAdminChatFloodWarning", Index);
					Flooding[Index] = NexTime + maxChat + 3.0;
					return PLUGIN_HANDLED;
				}
				++Flood[Index];
			}
			else
			{
				if (Flood[Index])
				{
					--Flood[Index];
				}
			}
			
			Flooding[Index] = NexTime + maxChat;
		}

		return PLUGIN_CONTINUE;
	}
#endif

#if AMXX_VERSION_NUM < 183
	public showAdminChatFloodWarning(Index)
	{
		if ( IsFlooding[Index] )
		{
			new CvarString[32];
			getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
			if ( getInteger(PluginCvar[plug_warn]) == 1 )
			{
				client_print_color(Index, Grey, LangType, Index, "ROM_ADMIN_CHAT_FLOOD", "^3", CvarString, "^4");
			}
			
			if ( getInteger(PluginCvar[plug_log]) == 1 )
			{
				logCommand(Index, LangType, LANG_SERVER, "ROM_ADMIN_CHAT_FLOOD_LOG", CvarString);
			}
			
			IsFlooding[Index] = false;
		}
	}
#endif

public showAdvertise()
{
	new CvarString[32];
	getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
	
	#if AMXX_VERSION_NUM < 183
		client_print_color(0, Grey, LangType, LANG_PLAYER, "ROM_ADVERTISE", "^3", CvarString, "^4", "^3", PluginName, "^4", "^3", Version, "^4");
	#else
		client_print_color(0, print_team_grey, LangType, LANG_PLAYER, "ROM_ADVERTISE", CvarString, PluginName, Version);
	#endif
}

public cleanResFiles() 
{ 
	new MapsDir[] = "maps"; 
	new const ResExt[] = ".res"; 
	new ResFile[64], Len; 
	new DirPointer = open_dir(MapsDir, ResFile, charsmax(ResFile)); 
	
	if ( !DirPointer )
	{
		return; 
	}
	
	new FullPathFileName[128];
	
	do 
	{ 
		Len = strlen(ResFile);
		
		if ( Len > 4 && equali(ResFile[Len-4], ResExt) ) 
		{ 
			if ( TrieKeyExists(DefaultRes, ResFile) ) 
			{
				continue;
			}
			
			formatex(FullPathFileName, charsmax(FullPathFileName), "%s/%s", MapsDir, ResFile); 
			write_file(FullPathFileName, "/////////////////////////////////////////////////////////////^n", 0); 
		} 
	} 
	while ( next_file(DirPointer, ResFile, charsmax(ResFile)) );
	
	close_dir(DirPointer);
} 


public reloadLogin(Index, level, cid) 
{
	AdminsReloaded = true;
	set_task(1.0, "reloadDelay");
}

public client_command(Index)
{
	if (getInteger(PluginCvar[spec_bug]) == 1)
	{	
		new Command[15];
		read_argv(0, Command, charsmax(Command));
		if (equali(Command, "joinclass") || (equali(Command, "menuselect") && get_pdata_int(Index, m_iMenu) == Menu_ChooseAppearance))
		{
			if (get_user_team(Index) == 3)
			{
				set_pdata_int(Index, m_iMenu, Menu_OFF);
				engclient_cmd(Index, "jointeam", "6");
				return PLUGIN_HANDLED;
			}
		}
	}
	
	if (AdminsReloaded)
	{
		reloadDelay();
	}

	return PLUGIN_CONTINUE;
}

public reloadDelay()
{
	if (!AdminsReloaded)
	{
		return;
	}
	new Players[MAX_PLAYERS], PlayersNum;
	
	get_players(Players, PlayersNum, "ch");
	
	for (new i = 0; i < PlayersNum; ++i)
	{
		if ( IsAdmin[Players[i]] )
		{
			getAccess(Players[i], LastPass[Players[i]], charsmax(LastPass[]));
		}
	}
	
	AdminsReloaded = false;
}

public cvarFunc(Index) 
{ 
	if ( !is_user_admin(Index) )
	{
		return PLUGIN_CONTINUE;
	}
		
	if ( getInteger(PluginCvar[motdfile]) == 1 )
	{
		new Cvar[32], Value[32], CvarString[32];
		getString(PluginCvar[Tag], CvarString, charsmax(CvarString)); 
		
		read_argv(1, Cvar, charsmax(Cvar));
		read_argv(2, Value, charsmax(Value));
		
		if ( equali(Cvar, "motdfile") && contain(Value, ".ini") != -1 ) 
		{
			if ( getInteger(PluginCvar[plug_warn]) == 1 )
			{
				console_print(Index, LangType, Index, "ROM_MOTDFILE", CvarString);
			}
			
			if ( getInteger(PluginCvar[plug_log]) == 1 )
			{
				logCommand(Index, LangType, LANG_SERVER, "ROM_MOTDFILE_LOG", CvarString);
			}
			
			return PLUGIN_HANDLED; 
		}
	}
	
	if ( getInteger(PluginCvar[protcvars]) == 1 )
	{
		new Command[32], CvarString[32];
		getString(PluginCvar[Tag], CvarString, charsmax(CvarString)); 
		
		read_argv(1, Command, charsmax(Command));
		
		if ( containi(Command, "rom_") != -1 )
		{
			if ( getInteger(PluginCvar[plug_warn]) == 1 )
			{
				console_print(Index, LangType, Index, "ROM_PROTCVARS", CvarString);
			}
			
			if ( getInteger(PluginCvar[plug_log]) == 1 )
			{
				logCommand(Index, LangType, LANG_SERVER, "ROM_PROTCVARS_LOG", CvarString);
			}
			
			return PLUGIN_HANDLED; 
		}
	}
	
	return PLUGIN_CONTINUE; 
}

public rconFunc(Index) 
{ 
	if ( !is_user_admin(Index) )
	{
		return PLUGIN_CONTINUE;
	}
	
	if ( getInteger(PluginCvar[motdfile]) == 1 )
	{
		new Command[32], CvarString[32];
		getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
		
		read_args(Command, charsmax(Command));
		
		if ( containi(Command, "motdfile") && contain(Command, ".ini") != -1 ) 
		{
			if ( getInteger(PluginCvar[plug_warn]) == 1 )
			{
				console_print(Index, LangType, Index, "ROM_MOTDFILE", CvarString);
			}
			
			if ( getInteger(PluginCvar[plug_log]) == 1 )
			{
				logCommand(Index, LangType, LANG_SERVER, "ROM_MOTDFILE_LOG", CvarString);
			}
			
			return PLUGIN_HANDLED; 
		}
	}
	
	if ( getInteger(PluginCvar[protcvars]) == 1 )
	{
		new Command[32], CvarString[32];
		getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
		
		read_args(Command, charsmax(Command));
		
		if ( !equali(Command, "rom_info") && containi(Command, "rom_") != -1 )
		{
			if ( getInteger(PluginCvar[plug_warn]) == 1 )
			{
				console_print(Index, LangType, Index, "ROM_PROTCVARS", CvarString);
			}
			
			if ( getInteger(PluginCvar[plug_log]) == 1 )
			{
				logCommand(Index, LangType, LANG_SERVER, "ROM_PROTCVARS_LOG", CvarString);
			}
			
			return PLUGIN_HANDLED; 
		}
	}
	
	return PLUGIN_CONTINUE; 
}

public hookBanClassCommand(Index)
{ 
	if ( !is_user_admin(Index) )
	{
		return PLUGIN_CONTINUE;
	}
	
	new Value = getInteger(PluginCvar[anti_ban_class]);
	
	if ( Value > 0 )
	{
		new Ip[32], IpNum[4][3], NumStr[1];
		
		read_argv(1, Ip, charsmax(Ip));
		
		if ( containi( Ip, "STEAM") != -1 || containi( Ip, "VALVE") != -1 )
		{
			return PLUGIN_CONTINUE;
		}
		
		for	(new i = 0; i < 4; ++i)
		{
			split(Ip, IpNum[i], charsmax(IpNum[]), Ip, charsmax(Ip), ".");
		}
		
		Value = getInteger(PluginCvar[anti_ban_class]);
		
		if ( Value > 4 )
		{
			Value = 4;
		}
			
		num_to_str(Value, NumStr, charsmax(NumStr));
		
		new CvarString[32];
		getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
		
		switch (Value)
		{
			case 1:
			{
				if ( str_to_num(IpNum[0]) == 0 || str_to_num(IpNum[1]) == 0 || str_to_num(IpNum[2]) == 0 )
				{
					if (getInteger(PluginCvar[plug_warn]) == 1)
					{
						console_print(Index, LangType, Index, "ROM_ANTI_BAN_CLASS", CvarString);
					}
					
					if (getInteger(PluginCvar[plug_log]) == 1)
					{
						logCommand(Index, LangType, LANG_SERVER, "ROM_ANTI_ANY_BAN_CLASS_LOG", CvarString);
					}
					
					return PLUGIN_HANDLED;
				}
			}
			case 2:
			{
				if ( str_to_num(IpNum[0]) == 0 || str_to_num(IpNum[1]) == 0 )
				{
					if (getInteger(PluginCvar[plug_warn]) == 1)
					{
						console_print(Index, LangType, Index, "ROM_ANTI_BAN_CLASS", CvarString);
					}
					
					if (getInteger(PluginCvar[plug_log]) == 1)
					{
						logCommand(Index, LangType, LANG_SERVER, "ROM_ANTI_SOME_BAN_CLASS_LOG", CvarString, NumStr);
					}
					
					return PLUGIN_HANDLED;
				}
			}
			case 3:
			{
				if ( str_to_num(IpNum[0]) == 0 )
				{
					if (getInteger(PluginCvar[plug_warn]) == 1)
					{
						console_print(Index, LangType, Index, "ROM_ANTI_BAN_CLASS", CvarString);
					}
					
					if (getInteger(PluginCvar[plug_log]) == 1)
					{
						logCommand(Index, LangType, LANG_SERVER, "ROM_ANTI_SOME_BAN_CLASS_LOG", CvarString, NumStr);
					}
					
					return PLUGIN_HANDLED;
				}
			}
			default:
			{
				if (getInteger(PluginCvar[plug_warn]) == 1)
				{
					console_print(Index, LangType, Index, "ROM_ANTI_BAN_CLASS", CvarString);
				}
				
				if (getInteger(PluginCvar[plug_log]) == 1)
				{
					logCommand(Index, LangType, LANG_SERVER, "ROM_ANTI_SOME_BAN_CLASS_LOG", CvarString, NumStr);
				}
				
				return PLUGIN_HANDLED;
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}

public hookBasicOnChatCommand(Index)
{
	new ColorBugCvarValue = getInteger(PluginCvar[color_bug]), CmdBugCvarValue = getInteger(PluginCvar[cmd_bug]);
	if ( CmdBugCvarValue == 1 || ColorBugCvarValue == 1 )
	{
		new Said[192], bool:IsUsedCmdBug[MAX_PLAYERS+1], bool:IsUsedColorBug[MAX_PLAYERS+1];
		
		read_args(Said, charsmax(Said));
		
		for (new i = 0; i < sizeof Said ; ++i)
		{
			if ( CmdBugCvarValue == 1 && (Said[i] == '#' && isalpha(Said[i+1])) || (Said[i] == '%' && Said[i+1] == 's') )
			{
				IsUsedCmdBug[Index] = true;
				break;
			}
			if ( ColorBugCvarValue == 1 )
			{
				if ( Said[i] == '' || Said[i] == '' || Said[i] == '' )
				{
					IsUsedColorBug[Index] = true;
					break;
				}
			}
		}
		new WarnCvarValue = getInteger(PluginCvar[plug_warn]), LogCvarValue = getInteger(PluginCvar[plug_log]), CvarString[32];
		getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
		if ( IsUsedCmdBug[Index] )
		{
			if ( WarnCvarValue == 1 )
			{
				new CvarTag[32];
				copy(CvarTag, charsmax(CvarTag), CvarString);
				
				#if AMXX_VERSION_NUM < 183
					client_print_color( Index, Grey, LangType, Index, "ROM_CMD_BUG", "^3", CvarTag, "^4");
				#else
					client_print_color( Index, print_team_grey, LangType, Index, "ROM_CMD_BUG", CvarTag);
				#endif
				console_print(Index, LangType, Index, "ROM_CMD_BUG_PRINT", CvarTag);
			}
			if ( LogCvarValue == 1 )
			{
				logCommand(Index, LangType, LANG_SERVER, "ROM_CMD_BUG_LOG", CvarString);
			}
			IsUsedCmdBug[Index] = false;
			return PLUGIN_HANDLED;
		}
		if ( IsUsedColorBug[Index] )
		{
			if ( WarnCvarValue == 1 )
			{
				#if AMXX_VERSION_NUM < 183
					client_print_color( Index, Grey, LangType, Index, "ROM_COLOR_BUG", "^3", CvarString, "^4");
				#else
					client_print_color( Index, print_team_grey, LangType, Index, "ROM_COLOR_BUG", CvarString );
				#endif
			}
			if ( LogCvarValue == 1 )
			{
				logCommand(Index, LangType, LANG_SERVER, "ROM_COLOR_BUG_LOG", CvarString);
			}
			IsUsedColorBug[Index] = false;
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
}

public checkBot(Index, const Var[], const Value[])
{
    if ( equal(Var, "fps_max") && Value[0] == 'B' )
    {
		new CvarString[32];
		getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
		if ( getInteger(PluginCvar[plug_log]) == 1 )
		{
			logCommand(Index, LangType, LANG_SERVER, "ROM_FAKE_PLAYERS_DETECT_LOG", CvarString);
		}
		
		console_print(Index, LangType, Index, "ROM_FAKE_PLAYERS_DETECT", CvarString);
		server_cmd("kick #%d ^"You got kicked. Check console.^"", get_user_userid(Index));
    }
}

public CheckAutobuyBug(Index)		
{		
	new Command[512];
	new Count = read_argc();
	
	for (new i = 1; i <= Count; ++i)
	{		
		read_argv(i, Command, charsmax(Command));
		if ( getInteger(PluginCvar[autobuy_bug]) == 1 )
		{
			new CvarString[32];
			getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
			if ( checkLong(Command, charsmax(Command)) )
			{		
				if ( getInteger(PluginCvar[plug_warn]) == 1 )
				{		
					#if AMXX_VERSION_NUM < 183		
						client_print_color( Index, Grey, LangType, Index, "ROM_AUTOBUY", "^3", CvarString, "^4");		
					#else		
						client_print_color( Index, print_team_grey, LangType, Index, "ROM_AUTOBUY", CvarString);
					#endif		
				}
			
				if ( getInteger( PluginCvar[plug_log] ) == 1 )
				{
					logCommand(Index, LangType, LANG_SERVER, "ROM_AUTOBUY_LOG", CvarString);
				}
			
				return PLUGIN_HANDLED;		
			}
		}
	}
	
	return PLUGIN_CONTINUE;		
}

public giveClientInfo(Index)
{
	if ( getInteger(PluginCvar[info]) != 1 )
	{
		return PLUGIN_HANDLED;
	}
		
	console_print(Index, "^n^n^nVersiune curenta : %s. Build : %d. Data lansarii versiunii : %s.", Version, Build, Date);
	#if AMXX_VERSION_NUM >= 183
		console_print(Index, "Autor : VrînceanAlex.lüxor. Comunitatea : FioriGinal.Ro" );
	#else
		console_print(Index, "Autor : VrinceanAlex.luxor. Comunitatea : FioriGinal.Ro" );
	#endif
	console_print(Index, "Link oficial : http://forum.fioriginal.ro/amxmodx-plug ... .html"&#41;;
	console_print(Index, "Contact : luxxxoor (Steam) / alex.vrincean (Skype).^n^n^n");
	
	return PLUGIN_HANDLED;
}

public giveServerInfo(Index)
{
	if ( getInteger(PluginCvar[info]) != 1 )
	{
		return PLUGIN_HANDLED;
	}
	
	server_print("^n^n^nVersiune curenta : %s. Build : %d. Data lansarii versiunii : %s.", Version, Build, Date);
	server_print("Autor : luxor # Dr.Fio & DR2.IND. Comunitatea : FioriGinal.Ro" );
	server_print("Link oficial : http://forum.fioriginal.ro/amxmodx-plug ... .html"&#41;;
	server_print("Contact : luxxxoor (Steam) / alex.vrincean (Skype).");
	server_print("Sursa in dezvoltare : https://github.com/luxxxoor/ROM-Protect ^n");
	server_print("Acest plugin este unul OpenSource ! Este interzisa copierea/vinderea lui pentru a obtine bani.");
	server_print("Plugin-ul se afla in plina dezvoltare si este menit sa ofere un minim de siguranta serverelor care nu provin de la firme de host scumpe, care sa comfere siguranta serverelor.");
	server_print("Clientii pot edita plugin-ul dupa bunul lor plac, fie din fisierul configurator si fisier lang, fie direct din sursa acestuia.");
	server_print("Copyright 2014-2016");
	
	return PLUGIN_HANDLED;
}

public hookChat(Index)
{
	new Said[192];
	read_args(Said, charsmax(Said));
	
	if ( getInteger(PluginCvar[console_say]) && checkForBinds(Index, Said) == PLUGIN_HANDLED)
	{
		return PLUGIN_HANDLED;
	}
	if (hookForXFakePlayerSpam(Index, Said) == PLUGIN_HANDLED)
	{
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

checkForBinds(Index, Said[])
{
	if(Said[0] != '^"')
	{
		static Trie:SafeCommands;
		if (SafeCommands == Invalid_Trie)
		{
			SafeCommands = TrieCreate();
			
			if (!file_exists(IniFile))
			{
				write_file(IniFile, "//Aici vor fi adaugate comenzile de chat considerate safe, una sub alta :^n", 0);
				return PLUGIN_CONTINUE;
			}
			else
			{
				new FilePointer = fopen(IniFile, "rt");
		
				if (!FilePointer) 
				{
					return PLUGIN_CONTINUE;
				}
				
				new Text[121];
				
				while (!feof(FilePointer))
				{
					fgets(FilePointer, Text, charsmax(Text));
					trim(Text);
					
					if ((Text[0] == ';') || !Text[0] || ((Text[0] == '/') && (Text[1] == '/')))
					{
						continue;
					}
					
					strtolower(Text);
					TrieSetCell(SafeCommands, Text, 0);
				}
				fclose(FilePointer);
			}
			goto Valid;
		}
		else
		{
			Valid:
			strtolower(Said);
			if (TrieKeyExists(SafeCommands, Said))
			{
				return PLUGIN_CONTINUE;
			}
			
			new CvarString[32];
			getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
			#if AMXX_VERSION_NUM < 183
				client_print_color(Index, Grey, LangType, LANG_PLAYER, "ROM_BIND_SPAM", "^3", CvarString, "^4");
			#else
				client_print_color(Index, print_team_grey, LangType, LANG_PLAYER, "ROM_BIND_SPAM", CvarString);
			#endif
			return PLUGIN_HANDLED;
		}
		return PLUGIN_CONTINUE;
	}
   
	return PLUGIN_CONTINUE;
}

hookForXFakePlayerSpam(Index, Said[])
{
	new xFakePlayerCvarValue = getInteger(PluginCvar[xfakeplayer_spam]), CvarString[32];
	if (is_user_admin(Index))
	{
		if ( FirstMsg[Index] && xFakePlayerCvarValue == 1 )
		{
			FirstMsg[Index] = false;
		}
		return PLUGIN_CONTINUE;
	}
	getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
	switch( xFakePlayerCvarValue )
	{
		case 1 :
		{
			if (Gag[Index])
			{
				return PLUGIN_HANDLED;
			}
			
			remove_quotes(Said);
	
			if ( strlen(Said) <= getInteger(PluginCvar[xfakeplayer_spam_maxchars])+1 )
			{	
				if ( FirstMsg[Index] )
				{
					FirstMsg[Index] = false;
				}
				return PLUGIN_CONTINUE;
			}
			else
			{
				if ( FirstMsg[Index] )
				{
					FirstMsg[Index] = false;
					ClSaidSameTh_Count[Index]++;
					copy(PreviousMessage[Index], charsmax(PreviousMessage[]), Said);
					return PLUGIN_HANDLED;
				}
			}
	
			if ( ClSaidSameTh_Count[Index]++ > 0 )
			{
				if ( equal(Said, PreviousMessage[Index]) )
				{
					if ( getInteger(PluginCvar[plug_warn]) == 1 )
					{
						#if AMXX_VERSION_NUM < 183
							client_print_color(Index, Grey, LangType, LANG_PLAYER, "ROM_XFAKE_PLAYERS_SPAM_WARN", "^3", CvarString, "^4");
						#else
							client_print_color(Index, print_team_grey, LangType, LANG_PLAYER, "ROM_XFAKE_PLAYERS_SPAM_WARN", CvarString);
						#endif
					}		
			
					if ( ClSaidSameTh_Count[Index] >= getInteger(PluginCvar[xfakeplayer_spam_maxsais]) )
					{
						new Address[32];
						get_user_ip(Index, Address, charsmax(Address), 1);
						switch ( getInteger(PluginCvar[xfakeplayer_spam_type]) )
						{
							case 0 :
							{
								#if AMXX_VERSION_NUM < 183
									client_print_color(Index, Grey, LangType, LANG_PLAYER, "ROM_XFAKE_PLAYERS_SPAM_GAG", "^3", CvarString, "^4");
								#else
									client_print_color(Index, print_team_grey, LangType, LANG_PLAYER, "ROM_XFAKE_PLAYERS_SPAM_GAG", CvarString);
								#endif
								Gag[Index] = true;
								return PLUGIN_HANDLED; 
							}
							case 1 :
							{
								if ( getInteger(PluginCvar[plug_warn]) == 1 )
								{
									console_print(Index, LangType, Index, "ROM_XFAKE_PLAYERS_SPAM_KICK", CvarString);
									server_cmd("kick #%d ^"You got kicked. Check console.^"", get_user_userid(Index));
								}
								else
								{
									server_cmd("kick #%d", get_user_userid(Index));
								}
							}
							default :
							{
								new Punish[8];
					
								num_to_str(getInteger(PluginCvar[xfakeplayer_spam_punish]), Punish, charsmax(Punish));
		
								if ( getInteger(PluginCvar[plug_warn]) == 1 )
								{
									new CvarTag[32];
									copy(CvarTag, charsmax(CvarTag), CvarString);
							
									#if AMXX_VERSION_NUM < 183
										client_print_color(0, Grey, LangType, LANG_PLAYER, "ROM_XFAKE_PLAYERS_SPAM", "^3", CvarTag, "^4", Address);
										client_print_color(0, Grey, LangType, LANG_PLAYER, "ROM_XFAKE_PLAYERS_SPAM_PUNISH", "^3", CvarTag, "^4", Punish);
									#else
										client_print_color(0, print_team_grey, LangType, LANG_PLAYER, "ROM_XFAKE_PLAYERS_SPAM", CvarTag, Address);
										client_print_color(0, print_team_grey, LangType, LANG_PLAYER, "ROM_XFAKE_PLAYERS_SPAM_PUNISH", CvarTag, Punish);
									#endif
					
									console_print(Index, LangType, Index, "ROM_XFAKE_PLAYERS_SPAM_BAN", CvarString, Punish);
								}
						
								server_cmd("addip ^"%s^" ^"%s^";wait;writeip", Punish, Address);
							}
						}
				
						if ( getInteger(PluginCvar[plug_log]) == 1 )
						{
							logCommand(NoLogInfo, LangType, LANG_SERVER, "ROM_XFAKE_PLAYERS_SPAM_LOG", CvarString, Address);
						}
					}
				
					return PLUGIN_HANDLED;
				}
				else
				{
					ClSaidSameTh_Count[Index] = 0;
				}
			}
		}
		case 2:
		{
			remove_quotes(Said);
			if ( !UnBlockedChat[Index] )
			{
				if (equal(Said, Capcha[Index]))
				{
					UnBlockedChat[Index] = true;
					#if AMXX_VERSION_NUM < 183
						client_print_color(Index, Grey, LangType, LANG_PLAYER, "ROM_XFAKE_PLAYERS_ALLOW_USE_CHAT", "^3", CvarString, "^4");
					#else
						client_print_color(Index, print_team_grey, LangType, LANG_PLAYER, "ROM_XFAKE_PLAYERS_ALLOW_USE_CHAT", CvarString);
					#endif
					return PLUGIN_HANDLED;
				}
				else
				{	
					#if AMXX_VERSION_NUM < 183
						client_print_color(Index, Grey, LangType, LANG_PLAYER, "ROM_XFAKE_PLAYERS_CAPCHA", "^3", CvarString, "^4", "^3", Capcha[Index], "^4");
					#else
						client_print_color(Index, print_team_grey, LangType, LANG_PLAYER, "ROM_XFAKE_PLAYERS_CAPCHA", CvarString, Capcha[Index]);
					#endif
					return PLUGIN_HANDLED;
				}
			}
		}
		default :
		{
			return PLUGIN_CONTINUE;
		}
	}
	return PLUGIN_CONTINUE;
}

public delayforSavingLastPass(UserPass[], Index)
{
	copy(LastPass[Index], charsmax(LastPass[]), UserPass);
}

bool:getAccess(Index, UserPass[], len)
{
	new UserName[MAX_NAME_LENGTH], CvarString[32];

	get_user_name(Index, UserName, charsmax(UserName));
	
	if (!(get_user_flags(Index) & ADMIN_RESERVATION))
	{
		getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
		#if AMXX_VERSION_NUM < 183
			client_print_color(Index, Grey, LangType, LANG_PLAYER, "ROM_ADMIN_HASNT_SLOT", "^3", CvarString, "^4");
		#else
			client_print_color(Index, print_team_grey, LangType, LANG_PLAYER, "ROM_ADMIN_HASNT_SLOT", CvarString);
		#endif
		return false;
	}
	
	strtolower(UserName);
#if AMXX_VERSION_NUM < 183
	for (new i = 0; i < AdminNum; ++i)
#else
	for (new i = 0; i < TrieGetSize(LoginName); ++i)
#endif
	{
		if ( TrieKeyExists(LoginName, UserName) )
		{
			CorrectName[Index] = true;
		}
		else
		{
			CorrectName[Index] = false;
			continue;
		}
		new TempData[AdminLogin];
		TrieGetArray(LoginName, UserName, TempData, charsmax(TempData));
		
		if ( equal(TempData[LoginFlag], "f") && CorrectName[Index] )
		{
			if ( equal(TempData[LoginPass], UserPass) || IsAdmin[Index] )
			{
				new Access = read_flags(TempData[LoginAccess]);
				remove_user_flags(Index);
				set_user_flags(Index, Access);
				IsAdmin[Index] = true;
				set_task(0.1, "delayforSavingLastPass", Index, UserPass, len);
			}
			
			break;
		}
	}
	
	return true;
}

public loadAdminLogin()
{
	new Path[64], CvarString[32];
	
	get_localinfo("amxx_configsdir", Path, charsmax(Path));
	getString(PluginCvar[admin_login_file], CvarString, charsmax(CvarString));
	format(Path, charsmax(Path), "%s/%s", Path, CvarString);
	
	if ( !file_exists(Path) )
	{
		new FilePointer = fopen(Path, "wt");
		
		if ( !FilePointer ) 
		{
			return;
		}
		
		if ( getInteger(PluginCvar[plug_log]) == 1 )
		{
			getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
			logCommand(NoLogInfo, LangType, LANG_SERVER, "ROM_FILE_NOT_FOUND", CvarString, Path);
		}
		
		fputs(FilePointer, "; Aici vor fi inregistrate adminele protejate.^n");
		fputs(FilePointer, "; Exemplu de adaugare admin : ^"nume^" ^"parola^" ^"acces^" ^"f^"^n");
		
		fclose(FilePointer);
	}
	else
	{
		new FilePointer = fopen(Path, "rt");
		
		if ( !FilePointer ) 
		{
			return;
		}
		
		if (LoginName == Invalid_Trie)
		{
			LoginName = TrieCreate();
		}
		TrieClear(LoginName);
		
		#if AMXX_VERSION_NUM < 183
			AdminNum = 0;
		#endif
		
		new Text[121], Name[MAX_NAME_LENGTH], Password[32], Access[26], Flags[6], TempData[AdminLogin];
		
		while (!feof(FilePointer))
		{
			fgets(FilePointer, Text, charsmax(Text));

			trim(Text);
		
			if ( (Text[0] == ';') || !Text[0] || ((Text[0] == '/') && (Text[1] == '/')) )
			{
				continue;
			}
		
			if (parse(Text, Name, charsmax(Name), TempData[LoginPass], charsmax(TempData[LoginPass]), 
							TempData[LoginAccess], charsmax(TempData[LoginAccess]), TempData[LoginFlag], charsmax(TempData[LoginFlag])) != 4)
			{
				continue;
			}
		
			strtolower(Name);
			TrieSetArray(LoginName, Name, TempData, charsmax(TempData));
		
			#if AMXX_VERSION_NUM < 183
				++AdminNum;
			#endif
		
			if (getInteger(PluginCvar[admin_login_debug]) == 1)
			{
				server_print(LangType, LANG_SERVER, "ROM_ADMIN_DEBUG", Name, Password, Access, Flags);
			}
		}
		
		fclose(FilePointer);
	}

	
}

logCommand(Index, const StandardMessage[], any:...)
{
	new LogMessage[256], Time[32], MapName[64];
	
	get_time(" %H:%M:%S ", Time, charsmax(Time));
	vformat(LogMessage, charsmax(LogMessage), StandardMessage, 3);
	get_mapname(MapName, charsmax(MapName));
	format(LogMessage, charsmax(LogMessage), "L %s|%s| %s", Time, MapName, LogMessage);
	
	if (Index != NoLogInfo)
	{
		new String[32];
		get_user_name(Index, String, charsmax(String));
		#if AMXX_VERSION_NUM < 183
			replace_all(LogMessage, charsmax(LogMessage), "$name$", String);
		#else
			replace_string(LogMessage, charsmax(LogMessage), "$name$", String);
		#endif
			
		get_user_ip(Index, String, charsmax(String), any:true);
		#if AMXX_VERSION_NUM < 183
			replace_all(LogMessage, charsmax(LogMessage), "$ip$", String);
		#else
			replace_string(LogMessage, charsmax(LogMessage), "$ip$", String);
		#endif
			
		if (Index)
		{
			get_user_authid(Index, String, charsmax(String));
		}
		else
		{
			copy(String, charsmax(String), "SERVER");
		}
		#if AMXX_VERSION_NUM < 183
			replace_all(LogMessage, charsmax(LogMessage), "$authid$", String);
		#else
			replace_string(LogMessage, charsmax(LogMessage), "$authid$", String);
		#endif
	}
	
	server_print(LogMessage);
	write_file(LogFile, LogMessage, -1);
}

getString(Cvar, Buffer[], Len)
{
	get_pcvar_string(Cvar, Buffer, Len);
}

getInteger(Cvar)
{
	return get_pcvar_num(Cvar);
}

Float:getFloat(Cvar)
{	
	return get_pcvar_float(Cvar);
} 

registersPrecache()
{
	if (getHldsVersion() < 6027)
	{
		#if AMXX_VERSION_NUM >= 183
			PluginCvar[autobuy_bug] = create_cvar("rom_autobuy_bug" ,"1", _, _, true, 0.0, true, 1.0);
			PluginCvar[utf8_bom] = create_cvar("rom_utf8_bom", "0", _, _, true, 0.0, true, 1.0);
		#else
			PluginCvar[autobuy_bug] = register_cvar("rom_autobuy_bug", "1");
			PluginCvar[utf8_bom] = register_cvar("rom_utf8_bom", "0");
		#endif
	}
	else
	{
		#if AMXX_VERSION_NUM >= 183
			PluginCvar[autobuy_bug] = create_cvar("rom_autobuy_bug" ,"0", _, _, true, 0.0, true, 1.0);
			PluginCvar[utf8_bom] = create_cvar("rom_utf8_bom", "1", _, _, true, 0.0, true, 1.0);
		#else
			PluginCvar[autobuy_bug] = register_cvar("rom_autobuy_bug", "0");
			PluginCvar[utf8_bom] = register_cvar("rom_utf8_bom", "1");
		#endif
	}
	
	for (new i = 2; i < AllCvars; i++)
	{
		#if AMXX_VERSION_NUM >= 183
			PluginCvar[i] = create_cvar(CvarName[i] ,CvarValue[i], _, _, bool:CvarLimits[i][hasMinValue], float(CvarLimits[i][minValue]),
									  bool:CvarLimits[i][hasMaxValue], float(CvarLimits[i][maxValue]));
		#else
			PluginCvar[i] = register_cvar(CvarName[i] ,CvarValue[i]);
		#endif
	}
}

registersInit()
{
	register_plugin(PluginName, Version, "FioriGinal.Ro");
	register_cvar("rom_protect", Version, FCVAR_SERVER | FCVAR_SPONLY);
	
	register_clcmd("say", "hookChat");
	register_clcmd("say_team", "hookChat");
	
	for (new i = 0; i < sizeof AllBasicOnChatCommads; ++i)
	{
		register_concmd(AllBasicOnChatCommads[i], "hookBasicOnChatCommand");	
	
	}
	
	#if AMXX_VERSION_NUM < 183
		register_clcmd("say_team", "hookAdminChat");
	#endif
	
	if (getHldsVersion() < 6027)
	{
		for (new i = 0; i < sizeof AllAutobuyCommands; ++i)
		{
			register_clcmd(AllAutobuyCommands[i], "CheckAutobuyBug");
		}
	}
	
	if ( find_plugin_byfile("advanced_bans.amxx") != -1 ) // in cazul in care acest plugin va fi detectat, serverul nu va mai avea nevoie de aceasta protectie
		register_concmd("amx_addban", "hookBanClassCommand");
	
	register_concmd("amx_reloadadmins", "reloadLogin");	
	register_concmd("amx_cvar", "cvarFunc");
	register_clcmd("amx_rcon", "rconFunc");
	register_clcmd("login", "cmdPass");
	register_clcmd("rom_info", "giveClientInfo");
	register_srvcmd("rom_info", "giveServerInfo");
}

public stringFilter(String[], Len)
{
	for (new i = 0; String[i] != 0; ++i)
	{
		if ((String[i] == '#' || String[i] == '+') && isalpha(String[i+1]))
		{
			format(String[i+1], Len, " %s", String[i+1]);
		}
	}
}

bool:clientUseSteamid(Index) 
{	
	new AuthID[35]; 
	get_user_authid(Index, AuthID, charsmax(AuthID) );
	
	return (contain(AuthID , ":") != -1 && containi(AuthID , "STEAM") != -1) ? true : false; 
}

getHldsVersion()
{
	new VersionPonter, VersionString[24], Pos;
	new const VersionSizeNum = 4;
   
	VersionPonter = get_cvar_pointer("sv_version");
	get_pcvar_string(VersionPonter, VersionString, charsmax(VersionString));
	Pos = strlen(VersionString) - VersionSizeNum;
	format(VersionString, VersionSizeNum, "%s", VersionString[Pos]);
	
	return str_to_num(VersionString);
}

bool:checkLong(cCommand[], Len)
{
	new mCommand[512];
	
	while (strlen(mCommand))
	{
		strtok(cCommand, mCommand, charsmax(mCommand), cCommand, Len , ' ', 1);
		if ( strlen( mCommand ) > 31 )
		{
			return true;
		}
	}
	
	return false;
}

getVaultDir()
{
	new BaseDir[128];
	
	get_basedir(BaseDir, charsmax(BaseDir));
	format(BaseDir, charsmax(BaseDir), "%s/data/vault.ini", BaseDir);
	
	if ( file_exists(BaseDir) )
	{
		delete_file(BaseDir);	
	}
	
	return BaseDir;
}

WriteCfg( bool:exist )
{	
	new FilePointer = fopen(CfgFile, "wt"), CvarString[32];
	
	if ( !FilePointer ) 
	{
		return;
	}
	
	writeSignature(FilePointer);
	
	fputs(FilePointer, "// Verificare daca CFG-ul a fost executat cu succes.^n");
	fputs(FilePointer, "echo ^"*ROM-Protect : Fisierul rom_protect.cfg a fost gasit. Incep protejarea serverului.^"^n^n");
	fputs(FilePointer, "// Cvar      : rom_cmd_bug^n");
	fputs(FilePointer, "// Scop      : Urmareste chat-ul si opeste bugurile de tip ^"client overflow^" care dau crush client-elor jucatorilor.^n");
	fputs(FilePointer, "// Impact    : Serverul nu pateste nimic, insa playerii acestuia primesc ^"quit^" indiferent de ce client folosesc, iar serverul ramane gol.^n");
	fputs(FilePointer, "// Nota      : -^n");
	fputs(FilePointer, "// Update    : Incepand cu versiunea 1.0.1s, plugin-ul protejeaza serverele si de noul cmd-bug bazat pe caracterul '#'. Plugin-ul blocheaza de acum '#' si '%' in chat si '#' in nume.^n");
	fputs(FilePointer, "// Update    : Incepand cu versiunea 1.0.3a, plugin-ul devine mai inteligent, si va bloca doar posibilele folosiri ale acestui bug, astfel incat caracterele '#' si '%' vor putea fi folosite, insa nu in toate cazurile.^n");
	fputs(FilePointer, "// Update    : Incepand cu versiunea 1.0.3s, plugin-ul inlatura si bugul provotat de caracterul '+' in nume, acesta incercand sa deruteze playerii sau adminii (nu apare numele jucatorului in meniuri).^n");
	fputs(FilePointer, "// Update    : Incepand cu versiunea 1.0.4b, plugin-ul verifica si comenzile de baza care pot elibera mesaje in chat (ex: amx_say, amx_psay, etc.), adica toate comenzile prezente in adminchat.amxx.^n");
	fputs(FilePointer, "// Update    : Incepand cu versiunea 1.0.4f, plugin-ul devine mai indulgent cu jucatorii, si nu va mai inlocui caractere '#' si '+' cu un spatiu din nume, ci va pune un spatiu dupa acestea.^n");
	fputs(FilePointer, "// Valoarea 0: Functia este dezactivata.^n");
	fputs(FilePointer, "// Valoarea 1: Atacul este blocat. [Default]^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_cmd_bug ^"%d^"^n^n", getInteger(PluginCvar[cmd_bug]));
	}
	else
	{
		fputs(FilePointer, "rom_cmd_bug ^"1^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_spec_bug^n");
	fputs(FilePointer, "// Scop      : Urmareste activitatea jucatorilor si opreste schimbarea echipei la spectator daca acestia au deschis meniul de selectare al modelului, pentru a opri specbug.^n");
	fputs(FilePointer, "// Impact    : Serverul primeste crash in momentul in care se apeleaza la acest bug.^n");
	fputs(FilePointer, "// Update    : Incepand cu versiunea 1.0.4s, plugin-ul nu mai face greseli, astfel incat nu se vor mai face detectii false.^n");
	fputs(FilePointer, "// Valoarea 0: Functia este dezactivata.^n");
	fputs(FilePointer, "// Valoarea 1: Atacul este blocat. [Default]^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_spec_bug ^"%d^"^n^n", getInteger(PluginCvar[spec_bug]));
	}
	else
	{
		fputs(FilePointer, "rom_spec_bug ^"1^"^n^n");
	}

	#if AMXX_VERSION_NUM < 183
		fputs(FilePointer, "// Cvar      : rom_admin_chat_flood^n");
		fputs(FilePointer, "// Scop      : Urmareste activitatea jucatorilor care folosesc chat-ul adminilor, daca persoanele incearca sa flood-eze acest chat sunt opriti fortat.^n");
		fputs(FilePointer, "// Impact    : Serverul nu pateste nimic, insa cei cu acces la ^"admin chat^"(U@) primesc kick cu motivul : ^"Reliable channel overflowed^".^n");
		fputs(FilePointer, "// Nota      : Acesta functie este disponibila doar pentru serverele cu AMXX 1.8.1 sau AMXX 1.8.2 .^n");
		fputs(FilePointer, "// Valoarea 0: Functia este dezactivata.^n");
		fputs(FilePointer, "// Valoarea 1: Atacul este blocat. [Default]^n");
		if (exist)
		{
			fprintf(FilePointer, "rom_admin_chat_flood ^"%d^"^n", getInteger(PluginCvar[admin_chat_flood]));
		}
		else
		{
			fputs(FilePointer, "rom_admin_chat_flood ^"1^"^n^n");  
		}
		
		fputs(FilePointer, "// Cvar      : rom_admin_chat_flood_time (Activat numai in cazul in care cvarul ^"rom_admin_chat_flood^" este setat pe 1)^n");
		fputs(FilePointer, "// Utilizare : Limiteaza timpul maxim de trimitere al mai multor mesaje de catre acelasi cleint in chat-ul adminilor, blocand astfel atacurile tip ^"chat overflow^".^n");
		fputs(FilePointer, "// Nota      : Este recomandat sa nu se modifice valoarea standard a cvar-ului, pentru ca protectia sa functioneze corect.^n");
		if (exist)
		{
			fprintf(FilePointer, "rom_admin_chat_flood_time ^"%.2f^"^n", getFloat(PluginCvar[admin_chat_flood_time]));
		}
		else
		{
			fputs(FilePointer, "rom_admin_chat_flood_time ^"1.0^"^n^n");
		}
	#endif
		
	fputs(FilePointer, "// Cvar      : rom_autobuy_bug^n");		
	fputs(FilePointer, "// Scop      : Urmareste comenzile de tip autobuy/rebuy, iar daca acestea devin suspecte sunt oprite.^n");		
	fputs(FilePointer, "// Impact    : Serverul primeste crash in momentul in care se apeleaza la acest bug.^n");		
	fputs(FilePointer, "// Nota      : Serverele cu engine HLDS 6xxx nu mai sunt vulnerabile la acest bug.^n");		
	fputs(FilePointer, "// Valoarea 0: Functia este dezactivata.^n");		
	fputs(FilePointer, "// Valoarea 1: Atacul este blocat. [Default]^n");		
	if (exist)		
	{		
		fprintf(FilePointer, "rom_autobuy_bug ^"%d^"^n^n", getInteger(PluginCvar[autobuy_bug]));
	}		
	else
	{
		if (getHldsVersion() < 6027)
		{
			fputs(FilePointer, "rom_autobuy_bug ^"1^"^n^n");
		}
		else
		{
			fputs(FilePointer, "rom_autobuy_bug ^"1^"^n^n");
		}
	}	
	
	fputs(FilePointer, "// Cvar      : rom_fake_players^n");
	fputs(FilePointer, "// Scop      : Urmareste persoanele conectate pe server si intervine atunci cand numarul persoanelor cu acelasi ip il depaseste pe cel setat in cvarul rom_fake_players_limit.^n");
	fputs(FilePointer, "// Impact    : Serverul poate sa fie tinut in loc (lumea asteptand dupa acesti jucatori sa moara, insa acestia nu o vor face), iar jucatorii morti vor parasi serverul.^n");
	fputs(FilePointer, "// Nota      : Daca sunt mai multe persoane care impart aceasi legatura de internet pot fi banate (N minute), in acest caz ridicati cvarul : rom_fake_players_limit sau opriti rom_fake_players.^n");
	fputs(FilePointer, "// Valoarea 0: Functia este dezactivata.^n");
	fputs(FilePointer, "// Valoarea 1: Atacul este blocat prin ban 30 minute. [Default]^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_fake_players ^"%d^"^n^n", getInteger(PluginCvar[fake_players]));
	}
	else
	{
		fputs(FilePointer, "rom_fake_players ^"1^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_fake_players_limit (Activat numai in cazul in care cvarul ^"rom_fake_players^" este setat pe 1)^n");
	fputs(FilePointer, "// Utilizare : Limiteaza numarul maxim de persoane de pe acelasi IP, blocand astfel atacurile tip fake-player.^n");
	fputs(FilePointer, "// Nota      : Se recomanda ca acest cvar sa nu fie scazut sub valoarea ^"3^".^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_fake_players_limit ^"%d^"^n^n", getInteger(PluginCvar[fake_players_limit]));
	}
	else
	{
		fputs(FilePointer, "rom_fake_players_limit ^"4^"^n^n");
	} 
	
	fputs(FilePointer, "// Cvar      : rom_fake_players_type (Activat numai in cazul in care cvarul ^"rom_fake_players^" este setat pe 1)^n");
	fputs(FilePointer, "// Utilizare : Selecteaza tipul de protectie impotriva fake-player-ilor.^n");
	fputs(FilePointer, "// Nota      : In cazul in care sunt prea multi jucatori de pe acelasi ip, setati acest cvar pe valoarea ^"1^".^n");
	fputs(FilePointer, "// Valoarea 0: Daca sunt prea multi jucatori de pe acelasi ip, cei noi intrati vor primi kick.^n");
	fputs(FilePointer, "// Valoarea 1: Daca sunt prea multi jucatori de pe acelasi ip, acestia vor primi ban. [Default]^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_fake_players_type ^"%d^"^n^n", getInteger(PluginCvar[fake_players_type]));
	}
	else
	{
		fputs(FilePointer, "rom_fake_players_type ^"1^"^n^n");
	} 
	
	fputs(FilePointer, "// Cvar      : rom_fake_players_punish  Activat numai in cazul in care cvarul ^"rom_fake_players_type^" este setat pe 1)^n");
	fputs(FilePointer, "// Utilizare : Blocheaza ip-ul atacatorului pentru un interval de timp, masurat in minute.^n");
	fputs(FilePointer, "// Nota      : Recomandam sa nu setati o valoarea prea mare, deoarece in cazul unei detectari eronate jucatorii serverului pot avea de suferit.^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_fake_players_punish ^"%d^"^n^n", getInteger(PluginCvar[fake_players_punish]));
	}
	else
	{
		fputs(FilePointer, "rom_fake_players_punish ^"3^"^n^n");
	} 
	
	fputs(FilePointer, "// Cvar      : rom_delete_custom_hpk");
	fputs(FilePointer, "// Scop      : La finalul fiecarei harti, se va sterge fisierul custom.hpk.^n");
	fputs(FilePointer, "// Impact    : Serverul experimenteaza probleme la schimbarea hartii, aceasta putand sa dureze si pana la 60secunde.^n");
	fputs(FilePointer, "// Nota      : Eroarea ^"ERROR: couldn't open custom.hpk^" poate fi ignorata, deoarece ea nu afecteaza serverul in nici un mod.^n");
	fputs(FilePointer, "// Valoarea 0: Functie este dezactivata.^n");
	fputs(FilePointer, "// Valoarea 1: Fisierul este sters. [Default]^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_delete_custom_hpk ^"%d^"^n^n", getInteger(PluginCvar[delete_custom_hpk]));
	}
	else
	{
		fputs(FilePointer, "rom_delete_custom_hpk ^"1^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_delete_vault^n");
	fputs(FilePointer, "// Scop      : La finalul fiecarei harti, se va sterge fisierul vault.ini.^n");
	fputs(FilePointer, "// Impact    : Serverul experimenteaza probleme la schimbarea hartii, aceasta putand sa dureze si pana la 60secunde.^n");
	fputs(FilePointer, "// Nota      : In cazul in care salvati anumite date in acest fisier (^"vault.ini^"), setati cvar-ul pe valoarea ^"0^".^n");
	fputs(FilePointer, "// Valoarea 0: Functie este dezactivata.^n");
	fputs(FilePointer, "// Valoarea 1: Fisierul este sters si e setat ^"server_language en^" in vault.ini. [Default]^n");
	fputs(FilePointer, "// Valoarea 2: Fisierul este sters si e setat ^"server_language ro^" in vault.ini.^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_delete_vault ^"%d^"^n^n", getInteger(PluginCvar[delete_vault]));
	}
	else
	{
		fputs(FilePointer, "rom_delete_vault ^"0^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_advertise^n");
	fputs(FilePointer, "// Efect     : Afiseaza un mesaj prin care anunta clientii ca serverul este protejat de *ROM-Protect.^n");
	fputs(FilePointer, "// Nota      : Mesajul poate fi modificat din fisierul LANG. (^"data/lang/rom_protect.txt^")^n");
	fputs(FilePointer, "// Valoarea 0: Mesajele sunt dezactivate.^n");
	fputs(FilePointer, "// Valoarea 1: Mesajele sunt activate. [Default]^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_advertise ^"%d^"^n^n", getInteger(PluginCvar[advertise]));
	}
	else
	{
		fputs(FilePointer, "rom_advertise ^"0^"^n^n");
	}

	fputs(FilePointer, "// Cvar      : rom_advertise_time (Activat numai in cazul in care cvarul ^"rom_advertise^" este setat pe 1)^n");
	fputs(FilePointer, "// Utilizare : Seteaza ca mesajul sa apara o data la N secunde.^n");
	fputs(FilePointer, "// Nota      : Se recomanda sa nu setati acest cvar pe o valoare prea mica, altfel mesajul va face spam in chat.^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_advertise_time ^"%d^"^n^n", getInteger(PluginCvar[advertise_time]));
	}
	else
	{
		fputs(FilePointer, "rom_advertise_time ^"120^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_warn^n");
	fputs(FilePointer, "// Efect     : Afiseaza mesaje prin care anunta clientii care incearca sa distube activitatea normala a serverului.^n");
	fputs(FilePointer, "// Nota      : Mesajele pot fi modificate din fisierul LANG. (^"data/lang/rom_protect.txt^")^n");
	fputs(FilePointer, "// Valoarea 0: Mesajele sunt dezactivate.^n");
	fputs(FilePointer, "// Valoarea 1: Mesajele sunt activate. [Default]^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_warn ^"%d^"^n^n", getInteger(PluginCvar[plug_warn]));
	}
	else
	{
		fputs(FilePointer, "rom_warn ^"1^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_log");
	fputs(FilePointer, "// Efect     : Permite pluginului sa inregistreze activiatatea sa (in log-uri separate).^n");
	fputs(FilePointer, "// Nota      : Daca acest cvar este pornit, in consola serverlui vor fi printate mesajele intiparite in log.^n");
	fputs(FilePointer, "// Valoarea 0: Functia este dezactivata.^n");
	fputs(FilePointer, "// Valoarea 1: Functia este activata.^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_log ^"%d^"^n^n", getInteger(PluginCvar[plug_log]));
	}
	else
	{
		fputs(FilePointer, "rom_log ^"1^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_admi_login");
	fputs(FilePointer, "// Scop      : Permite autentificarea adminilor prin comanda ^"login parola^" in consola (nu necesita setinfo)^n");
	fputs(FilePointer, "// Impact    : Parolele adminilor sunt foarte usor de furat, e destul doar sa intri pe un server iar parola ta nu mai este in sigurata.^n");
	fputs(FilePointer, "// Nota      : Adminurile se adauga normal ^"nume^" ^"parola^" ^"acces^" ^"f^".^n");
	fputs(FilePointer, "// Update    : Incepand de la versiunea 1.0.3a, comanda in chat !login sau /login dispare, deoarece nu era folosita.^n");
	fputs(FilePointer, "// Valoarea 0: Functie este dezactivata.^n");
	fputs(FilePointer, "// Valoarea 1: Functia este activata. [Default]^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_admin_login ^"%d^"^n^n", getInteger(PluginCvar[admin_login]));
	}
	else
	{
		fputs(FilePointer, "rom_admin_login ^"0^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_admin_login_file (Activat numai in cazul in care cvarul ^"rom_admin_login^" este setat pe 1)^n");
	fputs(FilePointer, "// Efect     : Selecteaza fisierul de unde sa fie citite adminele cu flag ^"f^"^n");
	fputs(FilePointer, "// Nota      : De preferat sa nu se suprapuna cu fisierul de adminurile ^"normale^", altfel unele din adminele protejate pot fi incarcate de plugin-ul de baza, creeand neplaceri.^n");
	if (exist)
	{
		getString(PluginCvar[admin_login_file], CvarString, charsmax(CvarString));
		fprintf(FilePointer, "rom_admin_login_file ^"%s^"^n^n", CvarString);
	}
	else
	{
		fputs(FilePointer, "rom_admin_login_file ^"users_login.ini^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_admin_login_debug (Activat numai in cazul in care cvarul ^"rom_admin_login^" este setat pe 1)^n");
	fputs(FilePointer, "// Efect     : In cazul in care adminurile nu se incarca corect acesta va printa in consola serverului argumentele citite (nume - parola - acces - flag).^n");
	fputs(FilePointer, "// Nota      : Daca funtia este pornita, poate crea lag, scopul ei este doar de a verifica daca adminurile sunt puse corect.^n");
	fputs(FilePointer, "// Valoarea 0: Functie este dezactivata. [Default]^n");
	fputs(FilePointer, "// Valoarea 1: Argumentele sunt printate in consola.^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_admin_login_debug ^"%d^"^n^n", getInteger(PluginCvar[admin_login_debug]));
	}
	else
	{
		fputs(FilePointer, "rom_admin_login_debug ^"0^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_utf8_bom^n");
	fputs(FilePointer, "// Scop      : Verifica fiecare fisier .res in maps, si daca descopera urme UTF8-BOM le elimina.^n");
	fputs(FilePointer, "// Impact    : Serverul da crash cu eroarea : Host_Error: PF_precache_generic_I: Bad string.^n");
	fputs(FilePointer, "// Nota      : Eroarea apare doar la versiunile de HLDS 6***.^n");
	fputs(FilePointer, "// Valoarea 0: Functie este dezactivata.^n");
	fputs(FilePointer, "// Valoarea 1: Fisierul este decontaminat. [Default]^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_utf8_bom ^"%d^"^n^n", getInteger(PluginCvar[utf8_bom]));
	}
	else
	{
		if (getHldsVersion() >= 6027)
		{
			fputs(FilePointer, "rom_utf8_bom ^"1^"^n^n");
		}
		else
		{
			fputs(FilePointer, "rom_utf8_bom ^"1^"^n^n");
		}
	}	
	
	fputs(FilePointer, "// Cvar      : rom_tag^n");
	fputs(FilePointer, "// Utilizare : Seteaza tag-ul pluginului. (Numele acestuia)^n");
	fputs(FilePointer, "// Nota      : De preferat numele tag-ului sa nu depaseasca 32 de caractere, altfel acesta nu va aparea cum trebuie in chat.^n");
	fputs(FilePointer, "// Update    : Incepand de la versiunea 1.0.2s, plugin-ul *ROM-Protect devine mult mai primitor si te lasa chiar sa ii schimbi numele.^n");
	if (exist)
	{
		getString(PluginCvar[Tag], CvarString, charsmax(CvarString));
		fprintf(FilePointer, "rom_tag ^"%s^"^n^n", CvarString);
	}
	else
	{
		fputs(FilePointer, "rom_tag ^"*ROM-Protect^"^n^n");	
	}
	
	fputs(FilePointer, "// Cvar      : rom_color_bug^n");
	fputs(FilePointer, "// Scop      : Urmareste chatul si opeste bugurile de tip color-bug care alerteaza playerii si adminii.^n");
	fputs(FilePointer, "// Impact    : Serverul nu pateste nimic, insa playerii sau adminii vor fi alertati de culorile folosite de unul din clienti.^n");
	fputs(FilePointer, "// Nota      : Daca nu sunteti afectati de acest bug, se recomanda oprirea functiei.^n");
	fputs(FilePointer, "// Valoarea 0: Functia este dezactivata.^n");
	fputs(FilePointer, "// Valoarea 1: Bug-ul este blocat. [Default]^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_color_bug ^"%d^"^n^n", getInteger(PluginCvar[color_bug]));
	}
	else
	{
		fputs(FilePointer, "rom_color_bug ^"1^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_motdfile^n");
	fputs(FilePointer, "// Scop      : Urmareste activitatea adminilor prin comanda amx_cvar si incearca sa opreasca modificare cvarului motdfile intr-un fisier .ini.^n");
	fputs(FilePointer, "// Impact    : Serverul nu pateste nimic, insa adminul care foloseste acest exploit poate fura date importante din server, precum lista de admini, lista de pluginuri etc.^n");
	fputs(FilePointer, "// Nota      : In curand, se va folosi un algoritm mult mai bun si mai corect, insa doar pentru AMXX 1.8.3 .^n");
	fputs(FilePointer, "// Update    : Incepand de la versiunea 1.0.4f, plugin-ul va bloca acest furt de informatii si prin comadna amx_rcon.^n");
	fputs(FilePointer, "// Valoarea 0: Functia este dezactivata.^n");
	fputs(FilePointer, "// Valoarea 1: Bug-ul este blocat. [Default]^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_motdfile ^"%d^"^n^n", getInteger(PluginCvar[motdfile]));
	}
	else
	{
		fputs(FilePointer, "rom_motdfile ^"1^"^n^n");	
	}
	
	fputs(FilePointer, "// Cvar      : rom_anti_pause^n");
	fputs(FilePointer, "// Scop      : Urmareste ca plugin-ul de protectie ^"ROM-Protect^" sa nu poata fi pus pe pauza de catre un raufacator.^n");
	fputs(FilePointer, "// Impact    : Serverul nu mai este protejat de plugin, acesta fiind expus la mai multe exploituri.^n");
	fputs(FilePointer, "// Nota      : Daca doriti sa puteti dezactiva plugin-ul, este recomadat sa setati acest cvar pe valoarea ^"0^".^n");
	fputs(FilePointer, "// Valoarea 0: Functia este dezactivata.^n");
	fputs(FilePointer, "// Valoarea 1: Bug-ul este blocat. [Default]^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_anti_pause ^"%d^"^n^n", getInteger(PluginCvar[anti_pause]));
	}
	else
	{
		fputs(FilePointer, "rom_anti_pause ^"1^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_anti_ban_class^n");
	fputs(FilePointer, "// Scop      : Urmareste activitatea comezii amx_addban, astfel incat sa nu se poata da ban pe mai multe clase ip.^n");
	fputs(FilePointer, "// Impact    : Serverul nu pateste nimic, insa daca se dau ban-uri pe clasa, foarte multi jucatori nu se vor mai putea conecta la server.^n");
	fputs(FilePointer, "// Nota      : Functia nu urmareste decat comanda amx_addban.^n");
	fputs(FilePointer, "// Valoarea 0: Functia este dezactivata.^n");
	fputs(FilePointer, "// Valoarea 1: Functia va bloca comanda daca detecteaza ban-ul pe o clasa de ip.^n");
	fputs(FilePointer, "// Valoarea 2: Functia va bloca comanda daca detecteaza ban-ul pe doua clase de ip. [Default]^n");
	fputs(FilePointer, "// Valoarea 3: Functia va bloca comanda daca detecteaza ban-ul pe trei clase de ip.^n");
	fputs(FilePointer, "// Valoarea 4: Functia va bloca comanda daca detecteaza ban-ul pe toate clasele de ip.^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_anti_ban_class ^"%d^"^n^n", getInteger(PluginCvar[anti_ban_class]));
	}
	else
	{
		fputs(FilePointer, "rom_anti_ban_class ^"4^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_give_info^n");
	fputs(FilePointer, "// Scop      : Serverul va trimite utilizatorului informatii despre plugin.^n");
	fputs(FilePointer, "// Impact    : Cand cineva va scrie ^"rom_info^" in consola, ii vor fi livrate informatiile (tot in consola).^n");
	fputs(FilePointer, "// Nota      : Daca mesajul este transmis prin intermediul consolei serverului, acesta va primi cateva informatii suplimentare.^n");
	fputs(FilePointer, "// Valoarea 0: Functia este dezactivata.^n");
	fputs(FilePointer, "// Valoarea 1: Functia este activata. [Default]^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_give_info ^"%d^"^n^n", getInteger(PluginCvar[info]));
	}
	else
	{
		fputs(FilePointer, "rom_give_info ^"1^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_xfakeplayer_spam^n");
	fputs(FilePointer, "// Scop      : Blocheaza posibilele tentative de atacuri de boti, care au scop sa faca reclama la anumite servere in 2 modalitati.^n");
	fputs(FilePointer, "// Impact    : Botii fac reclama la alte servere, enervand jucatorii/staff-ul serverului.^n");
	fputs(FilePointer, "// Nota      : Daca un jucator scrie primul mesaj mai lung de N caractere (N = valoarea cvar-ului rom_xfakeplayer_spam_maxchars), acesta va fi blocat de catre plugin. (In cazul in care pluginul are valoarea 1)^n");
	fputs(FilePointer, "// Valoarea 0: Functia este dezactivata.^n");
	fputs(FilePointer, "// Valoarea 1: Pluginul va protejat serverul prin interzicerea primului say in chat, urmarind uratoarele say-uri daca sunt la fel, acesta va pedepsi acel client (Foloseste cvarurile de mai jos) [Default]^n");
	fputs(FilePointer, "// Valoarea 2: Pluginul va interzice oricarui client sa scrie in chat pana cand nu va introduce un cod capcha in chat. (cod prestabilit sau cod la intamplare, asta se seteaza la cvar-ul rom_xfakeplayer_spam_capcha)^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_xfakeplayer_spam ^"%d^"^n^n", getInteger(PluginCvar[xfakeplayer_spam]));
	}
	else
	{
		fputs(FilePointer, "rom_xfakeplayer_spam ^"1^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_xfakeplayer_spam_maxchars (Activat numai in cazul in care cvarul ^"rom_xfakeplayer_spam^" este setat pe 1)^n");
	fputs(FilePointer, "// Utilizare : Selecteaza numarul maxim de caractere care il poate scrie un jucator pentru ca acesta sa nu fie verificat si anulat.^n");
	fputs(FilePointer, "// Nota      : Atentie, numarul de caractere trebuie sa nu fie mai mare de 15 caractere, altfel protectia va fi inutila.^n");
	fputs(FilePointer, "// Valoarea 0: Functia este dezactivata.^n");
	fputs(FilePointer, "// Valoarea 1: Functia este activata. [Default]^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_xfakeplayer_spam_maxchars ^"%d^"^n^n", getInteger(PluginCvar[xfakeplayer_spam_maxchars]));
	}
	else
	{
		fputs(FilePointer, "rom_xfakeplayer_spam_maxchars ^"12^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_xfakeplayer_spam_maxsais (Activat numai in cazul in care cvarul ^"rom_xfakeplayer_spam^" este setat pe 1)^n");
	fputs(FilePointer, "// Utilizare : Selecteaza numarul mesajelor identice trimise pana cand ip-ul sa primeasca ban.^n");
	fputs(FilePointer, "// Nota      : Atentie, numarul de mesaje identice trimise trebuie sa nu fie mai mic de 3, altfel protectia s-ar putea sa baneze unii jucatori.^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_xfakeplayer_spam_maxsais ^"%d^"^n^n", getInteger(PluginCvar[xfakeplayer_spam_maxsais]));
	}
	else
	{
		fputs(FilePointer, "rom_xfakeplayer_spam_maxsais ^"5^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_xfakeplayer_spam_type (Activat numai in cazul in care cvarul ^"rom_xfakeplayer_spam^" este setat pe 1)^n");
	fputs(FilePointer, "// Utilizare : Selecteaza tipul de protectie impotriva botilor xfake-player.^n");
	fputs(FilePointer, "// Nota      : Atentie, daca cvar-ul este setat pe valoarea ^"0^", jucatorii xfake-player vor continua sa ramana pe server.^n");
	fputs(FilePointer, "// Valoarea 0: Jucatorul nu va mai putea vorbi.^n");
	fputs(FilePointer, "// Valoarea 1: Jucatorul va primi kick.^n");
	fputs(FilePointer, "// Valoarea 2: Jucatorul va primi ban pentru o valoare setata in cvar-ul rom_xfakeplayer_spam_punish. [Default]^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_xfakeplayer_spam_type ^"%d^"^n^n", getInteger(PluginCvar[xfakeplayer_spam_type]));
	}
	else
	{
		fputs(FilePointer, "rom_xfakeplayer_spam_type ^"1^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_xfakeplayer_spam_punish (Activat numai in cazul in care cvarul ^"rom_xfakeplayer_spam_type^" este setat pe 2)^n");
	fputs(FilePointer, "// Utilizare : Blocheaza ip-ul atacatorului pentru un interval de timp, masurat in minute.^n");
	fputs(FilePointer, "// Nota      : Se recomanda sa nu se seteze o valoare prea mare pentru acest cvar, in cazul unei detectari false, jucatorul poate avea de suferit.^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_xfakeplayer_spam_punish ^"%d^"^n^n", getInteger(PluginCvar[xfakeplayer_spam_punish]));
	}
	else
	{
		fputs(FilePointer, "rom_xfakeplayer_spam_punish ^"3^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_xfakeplayer_spam_capcha (Activat numai in cazul in care cvarul ^"rom_xfakeplayer_spam_type^" este setat pe 2)^n");
	fputs(FilePointer, "// Utilizare : Nu lasa clientii de pe server sa foloseasca chat-ul pana nu scriu in chat un anumit cod.^n");
	fputs(FilePointer, "// Nota      : Daca aveti un server cu multi clienti straini, se recomanda valoarea 0.^n");
	fputs(FilePointer, "// Valoarea 0: Chat-ul se va debloca printr-un cod prestabilit. (in cvarul rom_xfakeplayer_spam_capcha_word) [Default]^n");
	fputs(FilePointer, "// Valoarea 1: Chat-ul se va debloca printr-un cod la intamplare (random).^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_xfakeplayer_spam_capcha ^"%d^"^n^n", getInteger(PluginCvar[xfakeplayer_spam_capcha]));
	}
	else
	{
		fputs(FilePointer, "rom_xfakeplayer_spam_capcha ^"0^"^n^n");
	}	
	
	fputs(FilePointer, "// Cvar      : rom_xfakeplayer_spam_capcha_word (Activat numai in cazul in care cvarul ^"rom_xfakeplayer_spam_capcha^" este setat pe 0)^n");
	fputs(FilePointer, "// Utilizare : Seteaza un cod prestabilit, iar prin scrierea codului in chat de catre client, ^n");
	fputs(FilePointer, "// Nota      : De preferat codul sa nu contina prea multe caractere, unii clienti urasc sa scrie coduri lungi de pste 5 caractere.^n");
	fputs(FilePointer, "// Update    : Incepand de la versiunea 1.0.2s, plugin-ul *ROM-Protect devine mult mai primitor si te lasa chiar sa ii schimbi numele.^n");
	if (exist)
	{
		getString(PluginCvar[xfakeplayer_spam_capcha_word], CvarString, charsmax(CvarString));
		fprintf(FilePointer, "rom_xfakeplayer_spam_capcha_word ^"%s^"^n^n", CvarString);
	}
	else
	{
		fputs(FilePointer, "rom_xfakeplayer_spam_capcha_word ^"/chat^"^n^n");	
	}
	
	fputs(FilePointer, "// Cvar      : rom_prot_cvars^n");
	fputs(FilePointer, "// Scop      : Impiedica schimbarea cvar-elor acestui plugin. Permitand schimbarea lor doar din consola serverului sau din configurator.^n");
	fputs(FilePointer, "// Impact    : Protectiile pot fi afectate, iar serverul este pus in pericol.^n");
	fputs(FilePointer, "// Nota      : Daca doriti sa puteti schimba valorile din accesul de admin, cvar-ul va trebui setat pe valoarea ^"0^".^n");
	fputs(FilePointer, "// Valoarea 0: Functia este dezactivata.^n");
	fputs(FilePointer, "// Valoarea 1: Functia este activata. [Default]^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_prot_cvars ^"%d^"^n^n", getInteger(PluginCvar[protcvars]));
	}
	else
	{
		fputs(FilePointer, "rom_prot_cvars ^"1^"^n^n");
	}
	
	fputs(FilePointer, "// Cvar      : rom_console_say^n");
	fputs(FilePointer, "// Scop      : Impiedica trimiterea mesajelor din consola, blocand astfel bindurile.^n");
	fputs(FilePointer, "// Impact    : Opreste spam-ul si de ce nu, unele reclame.^n");
	fputs(FilePointer, "// Nota      : Daca doriti sa adaugati cuvinte care sa reprezinte exceptii pentru acesta functie cuvintele trebuiesc scrise in fisierul ^"rom_protect.ini^".^n");
	fputs(FilePointer, "// Nota      : Aceasta protectie nu este perfecta, ci doar un filtu. Se poate trece usor de ea.");
	fputs(FilePointer, "// Valoarea 0: Functia este dezactivata.^n");
	fputs(FilePointer, "// Valoarea 1: Functia este activata. [Default]^n");
	if (exist)
	{
		fprintf(FilePointer, "rom_console_say ^"%d^"^n^n", getInteger(PluginCvar[console_say]));
	}
	else
	{
		fputs(FilePointer, "rom_console_say ^"0^"^n^n");
	}
	

	fclose(FilePointer);
}

WriteLang( bool:exist )
{
	if (exist)
	{		
		new Line[512], FilePointer = fopen(LangFile, "wt");
		
		if ( !FilePointer ) 
		{
			return;
		}
		
		#if AMXX_VERSION_NUM < 183
			writeSignature(FilePointer);
		#else
			writeSignature(FilePointer, true);
		#endif
		
		fputs(FilePointer, "[ro]^n^n");
		
		formatex(Line, charsmax(Line), "ROM_UPDATE_CFG = %L^n", LANG_SERVER, "ROM_UPDATE_CFG", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_UPDATE_CFG = %s : Am actualizat fisierul CFG : rom_protect.cfg.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
		
		formatex(Line, charsmax(Line), "ROM_UPDATE_LANG = %L^n", LANG_SERVER, "ROM_UPDATE_LANG", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_UPDATE_LANG = %s : Am actualizat fisierul LANG : rom_protect.txt.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
		
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_FAKE_PLAYERS = %L^n", LANG_SERVER, "ROM_FAKE_PLAYERS", "^%s", "^%s", "^%s", "^%s");
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_FAKE_PLAYERS = %s%s : %sS-a observat un numar prea mare de persoane de pe ip-ul : %s .^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
			
			formatex(Line, charsmax(Line), "ROM_FAKE_PLAYERS_PUNISH = %L^n", LANG_SERVER, "ROM_FAKE_PLAYERS_PUNISH", "^%s", "^%s", "^%s", "^%s");
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_FAKE_PLAYERS_PUNISH = %s%s : %sIp-ul a primit ban %s minute pentru a nu afecta jocul.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}		
		#else
			formatex(Line, charsmax(Line), "ROM_FAKE_PLAYERS = %L^n", LANG_SERVER, "ROM_FAKE_PLAYERS", "^%s", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_FAKE_PLAYERS = ^^3%s : ^^4S-a observat un numar prea mare de persoane de pe ip-ul : %s .^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
				
			formatex(Line, charsmax(Line), "ROM_FAKE_PLAYERS_PUNISH = %L^n", LANG_SERVER, "ROM_FAKE_PLAYERS_PUNISH", "^%s", "^%s");
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_FAKE_PLAYERS_PUNISH = ^^3%s : ^^4Ip-ul a primit ban %s minute pentru a nu afecta jocul.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		formatex(Line, charsmax(Line), "ROM_FAKE_PLAYERS_LOG = %L^n", LANG_SERVER, "ROM_FAKE_PLAYERS_LOG", "^%s", "^%s"  );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_FAKE_PLAYERS_LOG = %s : S-a depistat un atac de ^"xFake-Players^" de la IP-ul : %s .^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
		
		formatex(Line, charsmax(Line), "ROM_FAKE_PLAYERS_KICK = %L^n", LANG_SERVER, "ROM_FAKE_PLAYERS_KICK", "^%s", "^%s"  );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_FAKE_PLAYERS_KICK = %s : Nu poti intra pe server, deoarece sunt inca %s jucatori cu acelasi ip-ul ca al tau.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}		
			
		formatex(Line, charsmax(Line), "ROM_FAKE_PLAYERS_DETECT = %L^n", LANG_SERVER, "ROM_FAKE_PLAYERS_DETECT", "^%s"  );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_FAKE_PLAYERS_DETECT = %s : Ai primit kick deoarece deoarece esti suspect de fake-client. Te rugam sa folosesti alt client.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
			
		formatex(Line, charsmax(Line), "ROM_FAKE_PLAYERS_DETECT_LOG = %L^n", LANG_SERVER, "ROM_FAKE_PLAYERS_DETECT_LOG", "^%s", "^%s", "^%s", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_FAKE_PLAYERS_DETECT_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca suspect de ^"xFake-Players^" sau ^"xSpammer^".^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
			
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_PLUGIN_PAUSE = %L^n", LANG_SERVER, "ROM_PLUGIN_PAUSE", "^%s", "^%s", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_PLUGIN_PAUSE = %s%s : %sNe pare rau, dar din anumite motive, acest plugin nu poate fi pus pe pauza.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#else
			formatex(Line, charsmax(Line), "ROM_PLUGIN_PAUSE = %L^n", LANG_SERVER, "ROM_PLUGIN_PAUSE", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_PLUGIN_PAUSE = ^^3%s : ^^4Ne pare rau, dar din anumite motive, acest plugin nu poate fi pus pe pauza.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		formatex(Line, charsmax(Line), "ROM_PLUGIN_PAUSE_LOG = %L^n", LANG_SERVER, "ROM_PLUGIN_PAUSE_LOG", "^%s", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_PLUGIN_PAUSE_LOG = %s : S-a depistat o incercare a opririi pluginului de protectie %s. Operatiune a fost blocata.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
			
		#if AMXX_VERSION_NUM < 183 
			formatex(Line, charsmax(Line), "ROM_ADMIN_WRONG_NAME = %L^n", LANG_SERVER, "ROM_ADMIN_WRONG_NAME", "^%s", "^%s", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_ADMIN_WRONG_NAME = %s%s : %sNu s-a gasit nici un admin care sa poarte acest nickname.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#else
			formatex(Line, charsmax(Line), "ROM_ADMIN_WRONG_NAME = %L^n", LANG_SERVER, "ROM_ADMIN_WRONG_NAME", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_ADMIN_WRONG_NAME = ^^3%s : ^^4Nu s-a gasit nici un admin care sa poarte acest nickname.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		formatex(Line, charsmax(Line), "ROM_ADMIN_WRONG_NAME_PRINT = %L^n", LANG_SERVER, "ROM_ADMIN_WRONG_NAME_PRINT", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_ADMIN_WRONG_NAME_PRINT = %s : Nu s-a gasit nici un admin care sa poarte acest nickname.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
			
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_ADMIN_WRONG_PASS = %L^n", LANG_SERVER, "ROM_ADMIN_WRONG_PASS", "^%s", "^%s", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_ADMIN_WRONG_PASS = %s%s : %sParola introdusa de tine este incorecta.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#else
			formatex(Line, charsmax(Line), "ROM_ADMIN_WRONG_PASS = %L^n", LANG_SERVER, "ROM_ADMIN_WRONG_PASS", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_ADMIN_WRONG_PASS = ^^3%s : ^^4Parola introdusa de tine este incorecta.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		formatex(Line, charsmax(Line), "ROM_ADMIN_WRONG_PASS_PRINT = %L^n", LANG_SERVER, "ROM_ADMIN_WRONG_PASS_PRINT", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_ADMIN_WRONG_PASS_PRINT = %s : Parola introdusa de tine este incorecta.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
			
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_ADMIN_LOADED = %L^n", LANG_SERVER, "ROM_ADMIN_LOADED", "^%s", "^%s", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_ADMIN_LOADED = %s%s : %sAdmin-ul tau a fost incarcat.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#else
			formatex(Line, charsmax(Line), "ROM_ADMIN_LOADED = %L^n", LANG_SERVER, "ROM_ADMIN_LOADED", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_ADMIN_LOADED = ^^3%s : ^^4Admin-ul tau a fost incarcat.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		formatex(Line, charsmax(Line), "ROM_ADMIN_LOADED_PRINT = %L^n", LANG_SERVER, "ROM_ADMIN_LOADED_PRINT", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_ADMIN_LOADED_PRINT = %s : Admin-ul tau a fost incarcat.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
			
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_ADMIN_ALREADY_LOADED = %L^n", LANG_SERVER, "ROM_ADMIN_ALREADY_LOADED", "^%s", "^%s", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_ADMIN_ALREADY_LOADED = %s%s : %sAdmin-ul tau este deja incarcat.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#else
			formatex(Line, charsmax(Line), "ROM_ADMIN_ALREADY_LOADED = %L^n", LANG_SERVER, "ROM_ADMIN_ALREADY_LOADED", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_ADMIN_ALREADY_LOADED = ^^3%s : ^^4Admin-ul tau este deja incarcat.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		formatex(Line, charsmax(Line), "ROM_ADMIN_ALREADY_LOADED_PRINT = %L^n", LANG_SERVER, "ROM_ADMIN_ALREADY_LOADED_PRINT", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_ADMIN_ALREADY_LOADED_PRINT = %s : Admin-ul tau este deja incarcat.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}


		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_ADMIN_WITHOUT_PASS = %L^n", LANG_SERVER, "ROM_ADMIN_WITHOUT_PASS", "^%s", "^%s", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_ADMIN_WITHOUT_PASS = %s%s : %sNu ai introdus nici o parola, comanda se scris in consola astfel : login ^"parola ta^".^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#else
			formatex(Line, charsmax(Line), "ROM_ADMIN_WITHOUT_PASS = %L^n", LANG_SERVER, "ROM_ADMIN_WITHOUT_PASS", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_ADMIN_WITHOUT_PASS = ^^3%s : ^^4Nu ai introdus nici o parola, comanda se scris in consola astfel : login ^"parola ta^".^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_ADMIN_HASNT_SLOT = %L^n", LANG_SERVER, "ROM_ADMIN_HASNT_SLOT", "^%s", "^%s", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_ADMIN_HASNT_SLOT = %s%s : %sNu iti poti incarca adminul daca nu ai slot.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#else
			formatex(Line, charsmax(Line), "ROM_ADMIN_HASNT_SLOT = %L^n", LANG_SERVER, "ROM_ADMIN_HASNT_SLOT", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_ADMIN_HASNT_SLOT = ^^3%s : ^^4Nu iti poti incarca adminul daca nu ai slot.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		formatex(Line, charsmax(Line), "ROM_ADMIN_WITHOUT_PASS_PRINT = %L^n", LANG_SERVER, "ROM_ADMIN_WITHOUT_PASS_PRINT", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_ADMIN_WITHOUT_PASS_PRINT = %s : Nu ai introdus nici o parola, comanda se scris in consola astfel : login ^"parola ta^".^n");
		}
		else
		{
			fputs(FilePointer, Line); 
		}
			
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_CMD_BUG = %L^n", LANG_SERVER, "ROM_CMD_BUG", "^%s", "^%s", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_CMD_BUG = %s%s : %sS-au observat caractere interzise in textul trimis de tine. Mesajul tau a fost eliminat.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#else
			formatex(Line, charsmax(Line), "ROM_CMD_BUG = %L^n", LANG_SERVER, "ROM_CMD_BUG", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_CMD_BUG = ^^3%s : ^^4S-au observat caractere interzise in textul trimis de tine. Mesajul tau a fost eliminat.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif	 
		
		formatex(Line, charsmax(Line), "ROM_CMD_BUG_LOG = %L^n", LANG_SERVER, "ROM_CMD_BUG_LOG", "^%s", "^%s", "^%s", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_CMD_BUG_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa foloseasca ^"CMD_BUG^" ca sa strice buna functionare a serverului.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
			
		formatex(Line, charsmax(Line), "ROM_CMD_BUG_PRINT = %L^n", LANG_SERVER, "ROM_CMD_BUG_PRINT", "^%s");
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_CMD_BUG_PRINT = %s : S-au observat caractere interzise in textul trimis de tine. Mesajul tau a fost eliminat.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
	
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_COLOR_BUG = %L^n", LANG_SERVER, "ROM_COLOR_BUG", "^%s", "^%s", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_COLOR_BUG = %s%s : %sS-au observat caractere suspecte in textul trimis de tine. Mesajul tau a fost eliminat.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#else
			formatex(Line, charsmax(Line), "ROM_COLOR_BUG = %L^n", LANG_SERVER, "ROM_COLOR_BUG", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_COLOR_BUG = ^^3%s : ^^4S-au observat caractere suspecte in textul trimis de tine. Mesajul tau a fost eliminat.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		formatex(Line, charsmax(Line), "ROM_COLOR_BUG_LOG = %L^n", LANG_SERVER, "ROM_COLOR_BUG_LOG", "^%s", "^%s", "^%s", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			
			fputs(FilePointer, "ROM_COLOR_BUG_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa foloseasca ^"COLOR_BUG^" ca sa alerteze playerii sau adminii.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
			
		formatex(Line, charsmax(Line), "ROM_COLOR_BUG_PRINT = %L^n", LANG_SERVER, "ROM_COLOR_BUG_PRINT", "^%s");
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_COLOR_BUG_PRINT = %s : S-au observat caractere suspecte in textul trimis de tine. Mesajul tau a fost eliminat.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
			
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_SPEC_BUG = %L^n", LANG_SERVER, "ROM_SPEC_BUG", "^%s", "^%s", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_SPEC_BUG = %s%s : %sAi facut o miscare suspecta asa ca te-am mutat la echipa precedenta.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#else
			formatex(Line, charsmax(Line), "ROM_SPEC_BUG = %L^n", LANG_SERVER, "ROM_SPEC_BUG", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_SPEC_BUG = ^^3%s : ^^4Ai facut o miscare suspecta asa ca te-am mutat la echipa precedenta.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		formatex(Line, charsmax(Line), "ROM_SPEC_BUG_LOG = %L^n", LANG_SERVER, "ROM_SPEC_BUG_LOG", "^%s", "^%s", "^%s", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_SPEC_BUG_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa foloseasca ^"SPEC_BUG^" ca sa strice buna functionare a serverului.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
			
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_ADMIN_CHAT_FLOOD = %L^n", LANG_SERVER, "ROM_ADMIN_CHAT_FLOOD", "^%s", "^%s", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_ADMIN_CHAT_FLOOD = %s%s : %sS-a observat un mic IsFlooding la chat primit din partea ta. Mesajele trimise de tine vor fi filtrate.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}

			formatex(Line, charsmax(Line), "ROM_ADMIN_CHAT_FLOOD_LOG = %L^n", LANG_SERVER, "ROM_ADMIN_CHAT_FLOOD_LOG", "^%s", "^%s", "^%s", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_ADMIN_CHAT_FLOOD_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa foloseasca ^"ADMIN_CHAT_FLOOD^" ca sa dea kick adminilor de pe server.^n");	
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_AUTOBUY = %L^n", LANG_SERVER, "ROM_AUTOBUY", "^%s", "^%s", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_AUTOBUY = %s%s : %sComanda trimisa de tine are valori suspecte, asa ca am blocat-o.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#else
			formatex(Line, charsmax(Line), "ROM_AUTOBUY = %L^n", LANG_SERVER, "ROM_AUTOBUY", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_AUTOBUY = ^^3%s : ^^4Comanda trimisa de tine are valori suspecte, asa ca am blocat-o.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		formatex(Line, charsmax(Line), "ROM_AUTOBUY_LOG = %L^n", LANG_SERVER, "ROM_AUTOBUY_LOG", "^%s", "^%s", "^%s", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_AUTOBUY_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa foloseasca ^"AUTOBUY_BUG^" ca sa strice buna functionare a serverului.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
		
		formatex(Line, charsmax(Line), "ROM_FILE_NOT_FOUND = %L^n", LANG_SERVER, "ROM_FILE_NOT_FOUND", "^%s", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_FILE_NOT_FOUND = %s : Fisierul %s nu exista.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
			
		formatex(Line, charsmax(Line), "ROM_ADMIN_DEBUG = %L^n", LANG_SERVER, "ROM_ADMIN_DEBUG", "^%s", "^%s", "^%s", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_ADMIN_DEBUG = Nume : %s - Parola : %s - Acces : %s - Flag : %s^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
			
		formatex(Line, charsmax(Line), "ROM_MOTDFILE = %L^n", LANG_SERVER, "ROM_MOTDFILE", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_MOTDFILE = %s : S-a detectat o miscare suspecta din partea ta, comanda ta a fost blocata.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
			
		formatex(Line, charsmax(Line), "ROM_MOTDFILE_LOG = %L^n", LANG_SERVER, "ROM_MOTDFILE_LOG", "^%s", "^%s", "^%s", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_MOTDFILE_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa foloseasca cvar-ul ^"motdfile^" ca sa fure informatii din acest server.^n");	
		}
		else
		{
			fputs(FilePointer, Line);
		}
			
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_ADVERTISE = %L^n", LANG_SERVER, "ROM_ADVERTISE", "^%s", "^%s", "^%s", "^%s", "^%s", "^%s", "^%s", "^%s", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_ADVERTISE = %s%s :%s Acest server este supravegheat de plugin-ul de protectie %s%s%s versiunea %s%s%s .^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#else
			formatex(Line, charsmax(Line), "ROM_ADVERTISE = %L^n", LANG_SERVER, "ROM_ADVERTISE", "^%s", "^%s", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_ADVERTISE = ^^3%s :^^4 Acest server este supravegheat de plugin-ul de protectie ^^3%s^^4 versiunea ^^3%s^^4 .^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		formatex(Line, charsmax(Line), "ROM_ANTI_BAN_CLASS = %L^n", LANG_SERVER, "ROM_ANTI_BAN_CLASS", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_ANTI_BAN_CLASS = %s : S-au detectat un numar prea mare de ban-uri pe clasa de ip, comanda ta a fost blocata.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
		
		formatex(Line, charsmax(Line), "ROM_ANTI_ANY_BAN_CLASS_LOG = %L^n", LANG_SERVER, "ROM_ANTI_ANY_BAN_CLASS_LOG", "^%s", "^%s", "^%s", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_ANTI_ANY_BAN_CLASS_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa dea ban pe clasa de ip.^n");	
		}
		else
		{
			fputs(FilePointer, Line);
		}
		
		formatex(Line, charsmax(Line), "ROM_ANTI_SOME_BAN_CLASS_LOG = %L^n", LANG_SERVER, "ROM_ANTI_SOME_BAN_CLASS_LOG", "^%s", "^%s", "^%s", "^%s", "^%s" );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, Line);
		}
		else
		{
			fputs(FilePointer, "ROM_ANTI_SOME_BAN_CLASS_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa dea ban pe mai mult de %s clase de ip.^n");	
		}
		
		formatex(Line, charsmax(Line), "ROM_AUTO_UPDATE_SUCCEED = %L^n", LANG_SERVER, "ROM_AUTO_UPDATE_SUCCEED", "^%s");
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_AUTO_UPDATE_SUCCEED = %s : S-a efectuat auto-actualizarea pluginului.^n");	
		}
		else
		{
			fputs(FilePointer, Line);
		}
		
		formatex(Line, charsmax(Line), "ROM_AUTO_UPDATE_FAILED = %L^n", LANG_SERVER, "ROM_AUTO_UPDATE_FAILED", "^%s"); 
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_AUTO_UPDATE_FAILED = %s : S-a intampinat o eroare la descarcare, iar plugin-ul nu s-a putut auto-actualiza.^n");	
		}
		else
		{
			fputs(FilePointer, Line);
		}
		
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_XFAKE_PLAYERS_SPAM_WARN = %L^n", LANG_SERVER, "ROM_XFAKE_PLAYERS_SPAM_WARN", "^%s", "^%s", "^%s");
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM_WARN = %s%s : %sMesajul tau a fost eliminat pentru a elimina o tentativa de ^"BOT SPAM^".^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#else
			formatex(Line, charsmax(Line), "ROM_XFAKE_PLAYERS_SPAM_WARN = %L^n", LANG_SERVER, "ROM_XFAKE_PLAYERS_SPAM_WARN", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM_WARN = ^^3%s : ^^4Mesajul tau a fost eliminat pentru a elimina o tentativa de ^"BOT SPAM^".^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_XFAKE_PLAYERS_SPAM = %L^n", LANG_SERVER, "ROM_XFAKE_PLAYERS_SPAM", "^%s", "^%s", "^%s", "^%s");
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM = %s%s : %sS-a depistat o tentativa de ^"BOT SPAM^" de la ip-ul : %s .^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
			
			formatex(Line, charsmax(Line), "ROM_XFAKE_PLAYERS_SPAM_PUNISH = %L^n", LANG_SERVER, "ROM_XFAKE_PLAYERS_SPAM_PUNISH", "^%s", "^%s", "^%s", "^%s");
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM_PUNISH = %s%s : %sIp-ul a primit ban %s minute pentru a nu afecta jocul.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}		
		#else
			formatex(Line, charsmax(Line), "ROM_XFAKE_PLAYERS_SPAM = %L^n", LANG_SERVER, "ROM_XFAKE_PLAYERS_SPAM", "^%s", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM = ^^3%s : ^^4S-a depistat o tentativa de ^"BOT SPAM^" de la ip-ul : %s .^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
				
			formatex(Line, charsmax(Line), "ROM_XFAKE_PLAYERS_SPAM_PUNISH = %L^n", LANG_SERVER, "ROM_XFAKE_PLAYERS_SPAM_PUNISH", "^%s", "^%s");
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM_PUNISH = ^^3%s : ^^4Ip-ul a primit ban %s minute pentru a nu afecta jocul.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		formatex(Line, charsmax(Line), "ROM_XFAKE_PLAYERS_SPAM_BAN = %L^n", LANG_SERVER, "ROM_XFAKE_PLAYERS_SPAM_BAN", "^%s", "^%s"  );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM_BAN = %s : Ai fost detectat ca fiind un bot xfake_player, asa ca ai fost banat pentru %s minute.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
		
		formatex(Line, charsmax(Line), "ROM_XFAKE_PLAYERS_SPAM_KICK = %L^n", LANG_SERVER, "ROM_XFAKE_PLAYERS_SPAM_KICK", "^%s"  );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM_KICK = %s : Ai fost detectat ca fiind un bot xfake_player, asa ca ai primit kick.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
		
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_XFAKE_PLAYERS_SPAM_GAG = %L^n", LANG_SERVER, "ROM_XFAKE_PLAYERS_SPAM_GAG", "^%s", "^%s", "^%s");
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM_GAG = %s%s : %sAi fost detectat ca fiind un bot xfake_player, nu vei mai putea folosi chat-ul pana nu te vei reconecta.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#else
			formatex(Line, charsmax(Line), "ROM_XFAKE_PLAYERS_SPAM_GAG = %L^n", LANG_SERVER, "ROM_XFAKE_PLAYERS_SPAM_GAG", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM_GAG = ^^3%s : ^^4Ai fost detectat ca fiind un bot xfake_player, nu vei mai putea folosi chat-ul pana nu te vei reconecta.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		formatex(Line, charsmax(Line), "ROM_XFAKE_PLAYERS_SPAM_LOG = %L^n", LANG_SERVER, "ROM_XFAKE_PLAYERS_SPAM_LOG", "^%s", "^%s"  );
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM_LOG = %s : S-a depistat un atac de ^"BOT SPAM^" de la IP-ul : %s .^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
		
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_XFAKE_PLAYERS_ALLOW_USE_CHAT = %L^n", LANG_SERVER, "ROM_XFAKE_PLAYERS_ALLOW_USE_CHAT", "^%s", "^%s", "^%s");
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_XFAKE_PLAYERS_ALLOW_USE_CHAT = %s%s : %sAi introdus capcha-ul corect, acum vei putea folosi chat-ul.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#else
			formatex(Line, charsmax(Line), "ROM_XFAKE_PLAYERS_ALLOW_USE_CHAT = %L^n", LANG_SERVER, "ROM_XFAKE_PLAYERS_ALLOW_USE_CHAT", "^%s" );
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_XFAKE_PLAYERS_ALLOW_USE_CHAT = ^^3%s : ^^4Ai introdus capcha-ul corect, acum vei putea folosi chat-ul.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_XFAKE_PLAYERS_CAPCHA = %L^n", LANG_SERVER, "ROM_XFAKE_PLAYERS_CAPCHA", "^%s", "^%s", "^%s", "^%s", "^%s", "^%s");
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_XFAKE_PLAYERS_CAPCHA = %s%s : %sPentru a folosi chat-ul scrie urmatorul cod : %s%s%s.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#else
			formatex(Line, charsmax(Line), "ROM_XFAKE_PLAYERS_CAPCHA = %L^n", LANG_SERVER, "ROM_XFAKE_PLAYERS_CAPCHA", "^%s", "^%s");
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_XFAKE_PLAYERS_CAPCHA = ^^3%s : ^^4Pentru a folosi chat-ul scrie urmatorul cod : ^^3%s^^4.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif
		
		
		#if AMXX_VERSION_NUM < 183
			formatex(Line, charsmax(Line), "ROM_BIND_SPAM = %L^n", LANG_SERVER, "ROM_BIND_SPAM", "^%s", "^%s", "^%s");
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_BIND_SPAM = %s%s : %sNu ai voie sa trimiti mesaje prin intermediul consolei !^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#else
			formatex(Line, charsmax(Line), "ROM_BIND_SPAM = %L^n", LANG_SERVER, "ROM_BIND_SPAM", "^%s");
			if ( contain(Line, "ML_NOTFOUND") != -1 )
			{
				fputs(FilePointer, "ROM_BIND_SPAM = ^^3%s : ^^4Nu ai voie sa trimiti mesaje prin intermediul consolei !.^n");
			}
			else
			{
				fputs(FilePointer, Line);
			}
		#endif

		
		formatex(Line, charsmax(Line), "ROM_PROTCVARS = %L^n", LANG_SERVER, "ROM_PROTCVARS", "^%s");
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_PROTCVARS = %s : Cvar-ururile acestui plugin sunt protejate, comanda ta nu a avut efect.^n");
		}
		else
		{
			fputs(FilePointer, Line);
		}
		
		formatex(Line, charsmax(Line), "ROM_PROTCVARS_LOG = %L^n", LANG_SERVER, "ROM_PROTCVARS_LOG", "^%s", "^%s", "^%s", "^%s");
		if ( contain(Line, "ML_NOTFOUND") != -1 )
		{
			fputs(FilePointer, "ROM_PROTCVARS_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa schimbe cvar-urile pluginului de protectie, astea pot fi schimbate doar din fisierul configurator.^n");	
		}
		else
		{
			fputs(FilePointer, Line);
		}
		
		fclose(FilePointer);
	}
	else
	{
		new FilePointer = fopen(LangFile, "wt");
		
		if ( !FilePointer ) 
		{
			return;
		}
		
		#if AMXX_VERSION_NUM < 183
			writeSignature(FilePointer);
		#else
			writeSignature(FilePointer, true);
		#endif
		
		fputs(FilePointer, "[ro]^n^n");
		fputs(FilePointer, "ROM_UPDATE_CFG = %s : Am actualizat fisierul CFG : rom_protect.cfg.^n");
		fputs(FilePointer, "ROM_UPDATE_LANG = %s : Am actualizat fisierul LANG : rom_protect.txt.^n");
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_FAKE_PLAYERS = %s%s : %sS-a observat un numar prea mare de persoane de pe ip-ul : %s .^n");
			fputs(FilePointer, "ROM_FAKE_PLAYERS_PUNISH = %s%s : %sIp-ul a primit ban %s minute pentru a nu afecta jocul.^n");
		#else
			fputs(FilePointer, "ROM_FAKE_PLAYERS = ^^3%s : ^^4S-a observat un numar prea mare de persoane de pe ip-ul : %s .^n");
			fputs(FilePointer, "ROM_FAKE_PLAYERS_PUNISH = ^^3%s :^^4 Ip-ul a primit ban %s minute pentru a nu afecta jocul.^n");
		#endif
		
		fputs(FilePointer, "ROM_FAKE_PLAYERS_LOG = %s : S-a depistat un atac de ^"xFake-Players^" de la IP-ul : %s .^n");
		fputs(FilePointer, "ROM_FAKE_PLAYERS_KICK = %s : Nu poti intra pe server, deoarece sunt inca %s jucatori cu acelasi ip-ul ca al tau.^n");
		
		fputs(FilePointer, "ROM_FAKE_PLAYERS_DETECT = %s : Ai primit kick deoarece deoarece esti suspect de fake-client. Te rugam sa folosesti alt client.^n");
		fputs(FilePointer, "ROM_FAKE_PLAYERS_DETECT_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca suspect de ^"xFake-Players^" sau ^"xSpammer^".^n");
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_PLUGIN_PAUSE = %s%s : %sNe pare rau, dar din anumite motive, acest plugin nu poate fi pus pe pauza.^n");
		#else
			fputs(FilePointer, "ROM_PLUGIN_PAUSE = ^^3%s : ^^4Ne pare rau, dar din anumite motive, acest plugin nu poate fi pus pe pauza.^n");
		#endif
		
		fputs(FilePointer, "ROM_PLUGIN_PAUSE_LOG = %s : S-a depistat o incercare a opririi pluginului de protectie %s. Operatiune a fost blocata.^n");
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_ADMIN_WRONG_NAME = %s%s : %sNu s-a gasit nici un admin care sa poarte acest nickname.^n");
		#else
			fputs(FilePointer, "ROM_ADMIN_WRONG_NAME = ^^3%s : ^^4Nu s-a gasit nici un admin care sa poarte acest nickname.^n");
		#endif
		
		fputs(FilePointer, "ROM_ADMIN_WRONG_NAME_PRINT = %s : Nu s-a gasit nici un admin care sa poarte acest nickname.^n");
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_ADMIN_WRONG_PASS = %s%s : %sParola introdusa de tine este incorecta.^n");
		#else
			fputs(FilePointer, "ROM_ADMIN_WRONG_PASS = ^^3%s : ^^4Parola introdusa de tine este incorecta.^n");
		#endif
		
		fputs(FilePointer, "ROM_ADMIN_WRONG_PASS_PRINT = %s : Parola introdusa de tine este incorecta.^n");
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_ADMIN_LOADED = %s%s : %sAdmin-ul tau a fost incarcat.^n");
		#else
			fputs(FilePointer, "ROM_ADMIN_LOADED = ^^3%s : ^^4Admin-ul tau a fost incarcat.^n");
		#endif
		
		fputs(FilePointer, "ROM_ADMIN_LOADED_PRINT = %s : Admin-ul tau a fost incarcat.^n");
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_ADMIN_ALREADY_LOADED = %s%s : %sAdmin-ul tau este deja incarcat.^n");
		#else
			fputs(FilePointer, "ROM_ADMIN_ALREADY_LOADED = ^^3%s : ^^4Admin-ul tau este deja incarcat.^n");
		#endif
		
		fputs(FilePointer, "ROM_ADMIN_ALREADY_LOADED_PRINT = %s : Admin-ul tau este deja incarcat.^n");

		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_ADMIN_WITHOUT_PASS = %s%s : %sNu ai introdus nici o parola, comanda se scris in consola astfel : login ^"parola ta^".^n");
		#else
			fputs(FilePointer, "ROM_ADMIN_WITHOUT_PASS = ^^3%s : ^^4Nu ai introdus nici o parola, comanda se scris in consola astfel : login ^"parola ta^".^n");
		#endif
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_ADMIN_HASNT_SLOT = %s%s : %sNu iti poti incarca adminul daca nu ai slot.^n");
		#else
			fputs(FilePointer, "ROM_ADMIN_HASNT_SLOT = ^^3%s : ^^4Nu iti poti incarca adminul daca nu ai slot.^n");
		#endif 
		
		fputs(FilePointer, "ROM_ADMIN_WITHOUT_PASS_PRINT = %s : Nu ai introdus nici o parola, comanda se scris in consola astfel : login ^"parola ta^".^n");

		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_CMD_BUG = %s%s : %sS-au observat caractere interzise in textul trimis de tine. Mesajul tau a fost eliminat.^n");
		#else
			fputs(FilePointer, "ROM_CMD_BUG = ^^3%s : ^^4S-au observat caractere interzise in textul trimis de tine. Mesajul tau a fost eliminat.^n");
		#endif 
		
		fputs(FilePointer, "ROM_CMD_BUG_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa foloseasca ^"CMD_BUG^" ca sa strice buna functionare a serverului.^n");
		fputs(FilePointer, "ROM_CMD_BUG_PRINT = %s : S-au observat caractere interzise in textul trimis de tine. Mesajul tau a fost eliminat.^n");
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_COLOR_BUG = %s%s : %sS-au observat caractere suspecte in textul trimis de tine. Mesajul tau a fost eliminat.^n");
		#else
			fputs(FilePointer, "ROM_COLOR_BUG = ^^3%s : ^^4S-au observat caractere suspecte in textul trimis de tine. Mesajul tau a fost eliminat.^n");
		#endif
		
		fputs(FilePointer, "ROM_COLOR_BUG_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa foloseasca ^"COLOR_BUG^" ca sa alerteze playerii sau adminii.^n");
		fputs(FilePointer, "ROM_COLOR_BUG_PRINT = %s : S-au observat caractere suspecte in textul trimis de tine. Mesajul tau a fost eliminat.^n");		
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_SPEC_BUG = %s%s : %sAi facut o miscare suspecta asa ca te-am mutat la echipa precedenta.^n");
		#else
			fputs(FilePointer, "ROM_SPEC_BUG = ^^3%s : ^^4Ai facut o miscare suspecta asa ca te-am mutat la echipa precedenta.^n");
		#endif
		
		fputs(FilePointer, "ROM_SPEC_BUG_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa foloseasca ^"SPEC_BUG^" ca sa strice buna functionare a serverului.^n");
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_ADMIN_CHAT_FLOOD = %s%s : %sS-a observat un mic IsFlooding la chat primit din partea ta. Mesajele trimise de tine vor fi filtrate.^n");
			fputs(FilePointer, "ROM_ADMIN_CHAT_FLOOD_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa foloseasca ^"ADMIN_CHAT_FLOOD^" ca sa dea kick adminilor de pe server.^n");	
		#endif
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_AUTOBUY = %s%s : %sComanda trimisa de tine are valori suspecte, asa ca am blocat-o.^n");
		#else
			fputs(FilePointer, "ROM_AUTOBUY = ^^3%s : ^^4Comanda trimisa de tine are valori suspecte, asa ca am blocat-o.^n");
		#endif
		
		fputs(FilePointer, "ROM_AUTOBUY_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa foloseasca ^"AUTOBUY_BUG^" ca sa strice buna functionare a serverului.^n");
		
		fputs(FilePointer, "ROM_FILE_NOT_FOUND = %s : Fisierul %s nu exista.^n");
		
		fputs(FilePointer, "ROM_ADMIN_DEBUG = Nume : %s - Parola : %s - Acces : %s - Flag : %s^n");
		
		fputs(FilePointer, "ROM_MOTDFILE = %s : S-a detectat o miscare suspecta din partea ta, comanda ta a fost blocata.^n");
		fputs(FilePointer, "ROM_MOTDFILE_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa foloseasca cvar-ul ^"motdfile^" ca sa fure informatii din acest server.^n");		
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_ADVERTISE = %s%s :%s Acest server este supravegheat de plugin-ul de protectie %s%s%s versiunea %s%s%s .^n");
		#else
			fputs(FilePointer, "ROM_ADVERTISE = ^^3%s :^^4 Acest server este supravegheat de plugin-ul de protectie ^^3%s^^4 versiunea ^^3%s^^4 .^n");
		#endif
		
		fputs(FilePointer, "ROM_ANTI_BAN_CLASS = %s : S-au detectat u numar prea mare de ban-uri pe clasa de ip, comanda ta a fost blocata.^n");
		fputs(FilePointer, "ROM_ANTI_ANY_BAN_CLASS_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa dea ban pe clasa de ip.^n");	
		fputs(FilePointer, "ROM_ANTI_SOME_BAN_CLASS_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa dea ban pe mai mult de %s clase de ip.^n");

		fputs(FilePointer, "ROM_AUTO_UPDATE_SUCCEED = %s : S-a efectuat auto-actualizarea pluginului.^n");	
		fputs(FilePointer, "ROM_AUTO_UPDATE_FAILED = %s : S-a intampinat o eroare la descarcare, iar plugin-ul nu s-a putut auto-actualiza.^n");	
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM_WARN = %s%s : %sMesajul tau a fost eliminat pentru a elimina o tentativa de ^"BOT SPAM^".^n");
		#else
			fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM_WARN = ^^3%s : ^^4Mesajul tau a fost eliminat pentru a elimina o tentativa de ^"BOT SPAM^".^n");
		#endif
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM = %s%s : %sS-a depistat o tentativa de ^"BOT SPAM^" de la ip-ul : %s .^n");
			fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM_PUNISH = %s%s : %sIp-ul a primit ban %s minute pentru a nu afecta jocul.^n");
		#else
			fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM = ^^3%s : ^^4S-a depistat o tentativa de ^"BOT SPAM^" de la ip-ul : %s .^n");
			fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM_PUNISH = ^^3%s : ^^4Ip-ul a primit ban %s minute pentru a nu afecta jocul.^n");
		#endif
		
		fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM_BAN = %s : Ai fost detectat ca fiind un bot xfake_player, asa ca ai fost banat pentru %s minute.^n");
		fputs(FilePointer,"ROM_XFAKE_PLAYERS_SPAM_KICK = %s : Ai fost detectat ca fiind un bot xfake_player, asa ca ai primit kick.^n");
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM_GAG = %s%s : %sAi fost detectat ca fiind un bot xfake_player, nu vei mai putea folosi chat-ul pana nu te vei reconecta.^n");
		#else
			fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM_GAG = ^^3%s : ^^4Ai fost detectat ca fiind un bot xfake_player, nu vei mai putea folosi chat-ul pana nu te vei reconecta.^n");
		#endif
		
		fputs(FilePointer, "ROM_XFAKE_PLAYERS_SPAM_LOG = %s : S-a depistat un atac de ^"BOT SPAM^" de la IP-ul : %s .^n");
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_XFAKE_PLAYERS_ALLOW_USE_CHAT = %s%s : %sAi introdus capcha-ul corect, acum vei putea folosi chat-ul.^n");
		#else
			fputs(FilePointer, "ROM_XFAKE_PLAYERS_ALLOW_USE_CHAT = ^^3%s : ^^4Ai introdus capcha-ul corect, acum vei putea folosi chat-ul.^n");
		#endif
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_XFAKE_PLAYERS_CAPCHA = %s%s : %sPentru a folosi chat-ul scrie urmatorul cod : %s%s%s.^n");
		#else
			fputs(FilePointer, "ROM_XFAKE_PLAYERS_CAPCHA = ^^3%s : ^^4Pentru a folosi chat-ul scrie urmatorul cod : ^^3%s^^4.^n");
		#endif
		
		fputs(FilePointer, "ROM_PROTCVARS = %s : Cvar-ururile acestui plugin sunt protejate, comanda ta nu a avut efect.^n");
		fputs(FilePointer, "ROM_PROTCVARS_LOG = %s : L-am detectat pe ^"$name$^" [ $authid$ | $ip$ ] ca a incercat sa schimbe cvar-urile pluginului de protectie, astea pot fi schimbate doar din fisierul configurator.^n");
		
		#if AMXX_VERSION_NUM < 183
			fputs(FilePointer, "ROM_BIND_SPAM = %s%s : %sNu ai voie sa trimiti mesaje prin intermediul consolei !.^n");
		#else
			fputs(FilePointer, "ROM_BIND_SPAM = ^^3%s : ^^4Nu ai voie sa trimiti mesaje prin intermediul consolei !^n");
		#endif
		
		fclose(FilePointer);
	}
	
	register_dictionary("rom_protect.txt");
	IsLangUsed = true;
}
#if AMXX_VERSION_NUM < 183
	writeSignature(FilePointer)
#else
	writeSignature(FilePointer, bool:isLangFile = false)
#endif
{
	fputs(FilePointer, "// *ROM-Protect");
	fputs(FilePointer, "// Plugin OpenSource anti-IsFlooding/bug-fix pentru orice server. ^n");
	fprintf(FilePointer, "// Versiunea : %s. Bulid : %d. Data lansarii versiunii : %s.^n", Version, Build, Date); 
	fputs(FilePointer, "// Autor : lüxor # Dr.Fio & DR2.IND (+ eNd.) - SteamID (contact) : luxxxoor^n");
	fputs(FilePointer, "// O productie FioriGinal.ro - site : http://www.fioriginal.ro^n");
	fputs(FilePointer, "// Link forum de dezvoltare : http://forum.fioriginal.ro/amxmodx-plug ... 292.html^n");
	fputs(FilePointer, "// Link sursa : https://github.com/luxxxoor/ROM-Protect^n");
	#if AMXX_VERSION_NUM >= 183
		if ( isLangFile )
		{
			fputs(FilePointer, "^n// Colori : ^^1 - Culoarea aleasa de jucator cu con_color.^n");
			fputs(FilePointer, "//          ^^3 - Culoare gri.^n");
			fputs(FilePointer, "//          ^^4 - Culoare verde.^n");
		}
	#endif
	fputs(FilePointer, "^n^n^n");
}

#if AMXX_VERSION_NUM < 183
// header client_print_color.inc

/* Fun functions
*
* by Numb
*
* This file is provided as is (no warranties).
*/

stock const g_szTeamName[Colors][] = 
{
	"UNASSIGNED",
	"TERRORIST",
	"CT",
	"SPECTATOR"
};

stock client_print_color(Index, iColor=DontChange, const szMsg[], any:...)
{
	// check if Index is different from 0
	if( Index && !is_user_connected(Index) )
	{
		return 0;
	}

	if( iColor > Grey )
	{
		iColor = DontChange;
	}

	new szMessage[192];
	if( iColor == DontChange )
	{
		szMessage[0] = 0x04;
	}
	else
	{
		szMessage[0] = 0x03;
	}

	new iParams = numargs();
	// Specific player code
	if(Index)
	{
		if( iParams == 3 )
		{
			copy(szMessage[1], charsmax(szMessage)-1, szMsg);
		}
		else
		{
			vformat(szMessage[1], charsmax(szMessage)-1, szMsg, 4);
		}

		if( iColor )
		{
			new szTeam[11]; // store current team so we can restore it
			get_user_team(Index, szTeam, charsmax(szTeam));

			// set Index TeamInfo in consequence
			// so SayText msg gonna show the right color
			Send_TeamInfo(Index, Index, g_szTeamName[iColor]);

			// Send the message
			Send_SayText(Index, Index, szMessage);

			// restore TeamInfo
			Send_TeamInfo(Index, Index, szTeam);
		}
		else
		{
			Send_SayText(Index, Index, szMessage);
		}
	} 

	// Send message to all players
	else
	{
		// Figure out if at least 1 player is connected
		// so we don't send useless message if not
		// and we gonna use that player as team reference (aka SayText message sender) for color change
		new iPlayers[32], iNum;
		get_players(iPlayers, iNum, "ch");
		if( !iNum )
		{
			return 0;
		}

		new iFool = iPlayers[0];

		new iMlNumber, i, j;
		new Array:aStoreML = ArrayCreate();
		if( iParams >= 5 ) // ML can be used
		{
			for(j=4; j<iParams; j++)
			{
				// retrieve original param value and check if it's LANG_PLAYER value
				if( getarg(j) == LANG_PLAYER )
				{
					i=0;
					// as LANG_PLAYER == -1, check if next parm string is a registered language translation
					while( ( szMessage[ i ] = getarg( j + 1, i++ ) ) ) {}
					if( GetLangTransKey(szMessage) != TransKey_Bad )
					{
						// Store that arg as LANG_PLAYER so we can alter it later
						ArrayPushCell(aStoreML, j++);

						// Update ML array saire so we'll know 1st if ML is used,
						// 2nd how many args we have to alterate
						iMlNumber++;
					}
				}
			}
		}

		// If arraysize == 0, ML is not used
		// we can only send 1 MSG_BROADCAST message
		if( !iMlNumber )
		{
			if( iParams == 3 )
			{
				copy(szMessage[1], charsmax(szMessage)-1, szMsg);
			}
			else
			{
				vformat(szMessage[1], charsmax(szMessage)-1, szMsg, 4);
			}

			if( iColor )
			{
				new szTeam[11];
				get_user_team(iFool, szTeam, charsmax(szTeam));
				Send_TeamInfo(0, iFool, g_szTeamName[iColor]);
				Send_SayText(0, iFool, szMessage);
				Send_TeamInfo(0, iFool, szTeam);
			}
			else
			{
				Send_SayText(0, iFool, szMessage);
			}
		}

		// ML is used, we need to loop through all players,
		// format text and send a MSG_ONE_UNRELIABLE SayText message
		else
		{
			new szTeam[11], szFakeTeam[10];
			
			if( iColor )
			{
				get_user_team(iFool, szTeam, charsmax(szTeam));
				copy(szFakeTeam, charsmax(szFakeTeam), g_szTeamName[iColor]);
			}

			for( i = 0; i < iNum; i++ )
			{
				Index = iPlayers[i];

				for(j=0; j<iMlNumber; j++)
				{
					// Set all LANG_PLAYER args to player index ( = Index )
					// so we can format the text for that specific player
					setarg(ArrayGetCell(aStoreML, j), _, Index);
				}

				// format string for specific player
				vformat(szMessage[1], charsmax(szMessage)-1, szMsg, 4);

				if( iColor )
				{
					Send_TeamInfo(Index, iFool, szFakeTeam);
					Send_SayText(Index, iFool, szMessage);
					Send_TeamInfo(Index, iFool, szTeam);
				}
				else
				{
					Send_SayText(Index, iFool, szMessage);
				}
			}
			ArrayDestroy(aStoreML);
		}
	}
	return 1;
}

stock Send_TeamInfo(iReceiver, iPlayerId, szTeam[])
{
	static iTeamInfo = 0;
	if( !iTeamInfo )
	{
		iTeamInfo = get_user_msgid("TeamInfo");
	}
	message_begin(iReceiver ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, iTeamInfo, .player=iReceiver);
	write_byte(iPlayerId);
	write_string(szTeam);
	message_end();
}

stock Send_SayText(iReceiver, iPlayerId, szMessage[])
{
	static iSayText = 0;
	if( !iSayText )
	{
		iSayText = get_user_msgid("SayText");
	}
	message_begin(iReceiver ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, iSayText, .player=iReceiver);
	write_byte(iPlayerId);
	write_string(szMessage);
	message_end();
}

stock register_dictionary_colored(const filename[])
{
	if( !register_dictionary(filename) )
	{
		return 0;
	}

	new szFileName[256];
	get_localinfo("amxx_datadir", szFileName, charsmax(szFileName));
	format(szFileName, charsmax(szFileName), "%s/lang/%s", szFileName, filename);
	new fp = fopen(szFileName, "rt");
	if( !fp )
	{
		log_amx("Failed to open %s", szFileName);
		return 0;
	}

	new szBuffer[512], szLang[3], szKey[64], szTranslation[256], TransKey:iKey;

	while( !feof(fp) )
	{
		fgets(fp, szBuffer, charsmax(szBuffer));
		trim(szBuffer);

		if( szBuffer[0] == '[' )
		{
			strtok(szBuffer[1], szLang, charsmax(szLang), szBuffer, 1, ']');
		}
		else if( szBuffer[0] )
		{
			strbreak(szBuffer, szKey, charsmax(szKey), szTranslation, charsmax(szTranslation));
			iKey = GetLangTransKey(szKey);
			if( iKey != TransKey_Bad )
			{
				while( replace(szTranslation, charsmax(szTranslation), "!g", "^4") ){}
				while( replace(szTranslation, charsmax(szTranslation), "!t", "^3") ){}
				while( replace(szTranslation, charsmax(szTranslation), "!n", "^1") ){}
				AddTranslation(szLang, iKey, szTranslation[2]);
			}
		}
	}
	
	fclose(fp);
	return 1;
}

#endif

/*
*	 Contribuitori :
* SkillartzHD : -  Metoda anti-pause plugin.
*               -  Metoda anti-xfake-player si anti-xspammer.
*               -  Metoda auto-update plugin.
* COOPER :      -  Idee adaugare LANG si ajutor la introducerea acesteia in plugin.
* StefaN@CSX :  -  Gasire si reparare eroare parametrii la functia anti-xFake-Players.
* eNd :         -  Ajustat cod cu o noua metoda de inregistrare a cvarurilor.
* 001 :         -  Idee adaugare cvar rom_xfakeplayer_spam_type.
* HamletEagle : -  Distribuire tutorial despre noul tip de citire/scriere al fisierelor.
*               -  Cod pentru solutia spec bug.
* JaiLBreaK :   -  Metoda verificare mesaj daca este transmit din consola sau prin messagemode.
*/
```

<br><br>

ora_data.amxx -

<br>

```pawn
#include <amxmodx>
#include <engine>

#define PLUGIN "Ora Data"
#define VERSION "1.0"
#define AUTHOR "Neo"

new g_ClassName[] = "ora_data"
new g_SyncTimeDate

public plugin_init() 
{
register_plugin(PLUGIN, VERSION, AUTHOR)

register_think(g_ClassName,"fw_TimeDateThink")

g_SyncTimeDate = CreateHudSyncObj()

new iEnt = create_entity("info_target")
entity_set_string(iEnt, EV_SZ_classname, g_ClassName)
entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 1.0)
}

public fw_TimeDateThink(iEnt)
{
new timedate[32];
get_time("Data: %d.%m.%Y^nOra: %H:%M:%S", timedate, 31)

set_hudmessage(0, 128, 0, 0.8, 0.2, _, _, 1.0, _, _, 1)
ShowSyncHudMsg(0, g_SyncTimeDate, "%s", timedate)

entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 1.0)
}
```

<br><br>

evo_fp2.amxx -

<br>

```pawn
/*================================================================================
	
	-----------------------
	-*- Ping Faker 1.5a -*-
	-----------------------
	
	~~~~~~~~~~~~~~~
	- Description -
	~~~~~~~~~~~~~~~
	
	This plugin can fake the display of a player's latency (ping) shown on
	the scoreboard. Unlike the "fakelag" command, it does not affect the
	player's real latency in any way.
	
	You can have all players report the same ping, or only fake it for those
	having a specific IP/SteamID. This last feature is especially useful
	when running a dedicated server from your own computer, when you don't
	want people to guess you're an admin/owner by looking at your low ping.
	
	~~~~~~~~~
	- CVARS -
	~~~~~~~~~
	
	* pingfake_enable [0/1] - Enable/disable ping faking
	* pingfake_ping [1337] - The ping you want displayed (min: 0 // max: 4095)
	* pingfake_flux [0] - Fake ping fluctuation amount (0 = none)
	* pingfake_target [0/1] - Whether to display fake ping to its target too
	* pingfake_bots [0/1/2] - Affect bots too (set to 2 for bots ONLY setting)
	* pingfake_multiplier [0.0] - Set this to have the fake ping be a multiple
	   of the player's real ping instead of fixed values (0.0 = disabled)
	* pingfake_fileonly [0/1] - Enable this to fake pings ONLY for players
	   listed on the .INI file
	
	~~~~~~~~~~~~
	- Commands -
	~~~~~~~~~~~~
	
	* amx_fakeping <target> <ping>
	   - Toggle fake ping override for player (use -1 to disable)
	
	You can also have players automatically get fake pings according to IP/SteamID
	by editing the "fakepings.ini" file in your configs folder.
	
	~~~~~~~~~~~~~~~~~~~
	- Developer Notes -
	~~~~~~~~~~~~~~~~~~~
	
	The SVC_PINGS message can't be intercepted by Metamod/AMXX (it is purely
	handled by the engine) so the only way to supercede it is to send our own
	custom message right after the original is fired. This works as long as
	the custom message is parsed AFTER the original. To achieve this here, we
	send it as an unreliable message (cl_messages 1 helps see arrival order).
	
	The next difficulty is in figuring out what the message arguments are.
	Fortunately someone took the effort to find and upload these to the AMXX
	wiki at: http://wiki.amxmodx.org/Half-Life_1_Eng ... #SVC_PINGS
	
	A final consideration is bandwidth usage. I found out (with cl_shownet 1)
	the packet size increases by 102 bytes when the original SVC_PINGS message
	is sent for 32 players. Sending our own message right after means the size
	will grow even larger, so we should only send the message when absolutely
	needed. In this case that's once every client data update (any less often
	than that and the ping wasn't properly overridden sometimes).
	
	~~~~~~~~~~~~~
	- Changelog -
	~~~~~~~~~~~~~
	
	* v1.0: (Feb 23, 2009)
	   - Public release
	
	* v1.1: (Feb 23, 2009)
	   - Managed to send up to 3 pings on a single message,
	      thus reducing bandwidth usage by 26%
	
	* v1.2: (Feb 23, 2009)
	   - Added fake ping fluctuation and affect bots settings
	
	* v1.2a: (Feb 24, 2009)
	   - Fixed is_user_bot flag not being reset on disconnect
	
	* v1.3: (Feb 24, 2009)
	   - Added admin command to manually toggle fake ping for players
	   - Added feature to automatically load fake pings from file
	
	* v1.4: (Mar 15, 2009)
	   - Added feature (+CVAR) to have the fake ping be a multiple
	      of the player's real ping
	
	* v1.5: (Jun 06, 2011)
	   - Fixed plugin so that it works on all HL mods
	   - Removed CVAR pingfake_flags (not really needed anymore)
	   - Added feature (+CVAR) to have the plugin fake pings ONLY for
	      players listed on the .INI file
	   - Fixed fake pings overriden after DeathMsg/TeamInfo events in CS
	
	* v1.5a: (Jun 11, 2014)
	   - Fixed to send a single SVC_PINGS message using the real arguments from HL
	      (this just means the code is now much simpler to understand)
	
=================================================================================*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

new const FAKEPINGS_FILE[] = "fakepings.ini"
const TASK_ARGUMENTS = 100

new cvar_enable, cvar_target, cvar_bots, cvar_multiplier, cvar_fileonly, cvar_showactivity
new g_maxplayers, g_connected[33], g_isbot[33], g_argping[33]
new g_loaded_counter, g_pingoverride[33] = { -1, ... }
new Array:g_loaded_authid, Array:g_loaded_ping
//new cvar_ping, cvar_flux

public plugin_init()
{
	register_plugin("Ping Faker", "1.5a", "MeRcyLeZZ")
	
	cvar_enable = register_cvar("pingfake_enable", "1")
	//cvar_ping = register_cvar("pingfake_ping", "69")
	//cvar_flux = register_cvar("pingfake_flux", "0")
	cvar_target = register_cvar("pingfake_target", "0")
	cvar_bots = register_cvar("pingfake_bots", "1")
	cvar_multiplier = register_cvar("pingfake_multiplier", "0.0")
	cvar_fileonly = register_cvar("pingfake_fileonly", "0")
	cvar_showactivity = get_cvar_pointer("amx_show_activity")
	
	g_maxplayers = get_maxplayers()
	
	// If mod is CS, register some additional events to fix a bug
	new mymod[16]
	get_modname(mymod, charsmax(mymod))
	if (equal(mymod, "cstrike") || equal(mymod, "czero"))
	{
		register_event("DeathMsg", "fix_fake_pings", "a")
		register_event("TeamInfo", "fix_fake_pings", "a")
	}
	
	register_forward(FM_UpdateClientData, "fw_UpdateClientData")
	
	register_concmd("amx_fakeping", "cmd_fakeping", ADMIN_KICK, "<target> <ping> - Toggle fake ping override on player (-1 to disable)")
	
	g_loaded_authid = ArrayCreate(32, 1)
	g_loaded_ping = ArrayCreate(1, 1)
	
	// Load list of IP/SteamIDs to fake pings for
	load_pings_from_file()
	
	// Calculate weird argument values regularly in case we are faking ping fluctuations or a multiple of the real ping
	set_task(2.0, "calculate_arguments", TASK_ARGUMENTS, _, _, "b")
}

// After some events in CS, the fake pings are overriden for some reason, so we have to send them again...
public fix_fake_pings()
{
	static player
	for (player = 1; player <= g_maxplayers; player++)
	{
		// Player not in game?
		if (!g_connected[player])
			 continue;
		
		// Resend fake pings
		fw_UpdateClientData(player)
	}
}

public client_authorized(id)
{
	check_for_loaded_pings(id)
}

public client_putinserver(id)
{
	g_connected[id] = true
	if (is_user_bot(id)) g_isbot[id] = true
	check_for_loaded_pings(id)
}

public client_disconnect(id)
{
	g_connected[id] = false
	g_isbot[id] = false
	g_pingoverride[id] = -1
}

public fw_UpdateClientData(id)
{
	// Ping faking disabled?
	if (!get_pcvar_num(cvar_enable)) return;
	
	// Scoreboard key being pressed?
	if (!(pev(id, pev_button) & IN_SCORE) && !(pev(id, pev_oldbuttons) & IN_SCORE))
		return;
	
	// Send fake player's pings
	static player, sending, bits, bits_added
	sending = false
	bits = 0
	bits_added = 0
	
	for (player = 1; player <= g_maxplayers; player++)
	{
		// Player not in game?
		if (!g_connected[player])
			 continue;
		
		// Fake latency for its target too?
		if (!get_pcvar_num(cvar_target) && id == player)
			continue;
		
		// Fake pings enabled for players on .INI file ONLY and this guy is not listed
		if (get_pcvar_num(cvar_fileonly) && g_pingoverride[player] < 0)
			continue;
		
		// Only do these checks if not overriding ping for player
		if (g_pingoverride[player] < 0)
		{
			// Is this a bot?
			if (g_isbot[player])
			{
				// Bots setting disabled?
				if (!get_pcvar_num(cvar_bots)) continue;
			}
			else
			{
				// Bots only setting?
				if (get_pcvar_num(cvar_bots) == 2) continue;
			}
		}
		
		// Start message
		if (!sending)
		{
			message_begin(MSG_ONE_UNRELIABLE, SVC_PINGS, _, id)
			sending = true
		}
		
		// Add bits for this player
		AddBits(bits, bits_added, 1, 1) // flag = 1
		AddBits(bits, bits_added, player-1, 5) // player-1 since HL uses ids 0-31
		AddBits(bits, bits_added, g_argping[player], 12) // ping
		AddBits(bits, bits_added, 0, 7) // loss
		
		// Write group of 8 bits (bytes)
		WriteBytes(bits, bits_added, false)
	}
	
	// End message
	if (sending)
	{
		// Add empty bit at the end
		AddBits(bits, bits_added, 0, 1) // flag = 0
		
		// Write remaining bits
		WriteBytes(bits, bits_added, true)
		
		message_end()
	}
}

public cmd_fakeping(id, level, cid)
{
	// Check for access flag
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED;
	
	// Retrieve arguments
	static arg[32], player, ping
	read_argv(1, arg, sizeof arg - 1)
	player = cmd_target(id, arg, CMDTARGET_ALLOW_SELF)
	read_argv(2, arg, sizeof arg - 1)
	ping = str_to_num(arg)
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Update ping overrides for player
	g_pingoverride[player] = min(ping, 4095)
	
	// Get player's name for displaying/logging activity
	static name1[32], name2[32]
	get_user_name(id, name1, sizeof name1 - 1)
	get_user_name(player, name2, sizeof name2 - 1)
	
	// Negative value means disable fakeping
	if (ping < 0)
	{
		// Show activity?
		switch (get_pcvar_num(cvar_showactivity))
		{
			case 1: client_print(0, print_chat, "ADMIN - fake ping override disabled on %s", name2)
			case 2: client_print(0, print_chat, "ADMIN %s - fake ping override disabled on %s", name1, name2)
		}
		
		// Log activity
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, sizeof authid - 1)
		get_user_ip(id, ip, sizeof ip - 1, 1)
		formatex(logdata, sizeof logdata - 1, "ADMIN %s <%s><%s> - fake ping override disabled on %s", name1, authid, ip, name2)
		log_amx(logdata)
	}
	else
	{
		// Show activity?
		switch (get_pcvar_num(cvar_showactivity))
		{
			case 1: client_print(0, print_chat, "ADMIN - fake ping override of %d enabled on %s", ping, name2)
			case 2: client_print(0, print_chat, "ADMIN %s - fake ping override of %d enabled on %s", name1, ping, name2)
		}
		
		// Log activity
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, sizeof authid - 1)
		get_user_ip(id, ip, sizeof ip - 1, 1)
		formatex(logdata, sizeof logdata - 1, "ADMIN %s <%s><%s> - fake ping override of %d enabled on %s", name1, authid, ip, ping, name2)
		log_amx(logdata)
	}
	
	return PLUGIN_HANDLED;
}

// Calculate argument values based on target ping
public calculate_arguments()
{
	static player, ping, loss
	for (player = 1; player <= g_maxplayers; player++)
	{
		// Calculate target ping (clamp if out of bounds)
		if (g_pingoverride[player] < 0)
		{
			if (get_pcvar_float(cvar_multiplier) > 0.0)
			{
				get_user_ping(player, ping, loss)
				g_argping[player] = random_num(5,20)//clamp(floatround(ping * get_pcvar_float(cvar_multiplier)), 0, 4095)
			}
			else
			{
				g_argping[player] = random_num(5,20)//clamp(get_pcvar_num(cvar_ping) + random_num(-abs(get_pcvar_num(cvar_flux)), abs(get_pcvar_num(cvar_flux))), 0, 4095)
			}
		}
		else
			g_argping[player] = g_pingoverride[player]
	}
}

load_pings_from_file()
{
	// Build file path
	new path[64]
	get_configsdir(path, sizeof path - 1)
	format(path, sizeof path - 1, "%s/%s", path, FAKEPINGS_FILE)
	
	// File not present, skip loading
	if (!file_exists(path)) return;
	
	// Open file for reading
	new linedata[40], authid[32], ping[8], file = fopen(path, "rt")
	
	while (file && !feof(file))
	{
		// Read one line at a time
		fgets(file, linedata, sizeof linedata - 1)
		
		// Replace newlines with a null character to prevent headaches
		replace(linedata, sizeof linedata - 1, "^n", "")
		
		// Blank line or comment
		if (!linedata[0] || linedata[0] == ';') continue;
		
		// Get authid and ping
		strbreak(linedata, authid, sizeof authid - 1, ping, sizeof ping -1)
		remove_quotes(ping)
		
		// Store data into global arrays
		ArrayPushString(g_loaded_authid, authid)
		ArrayPushCell(g_loaded_ping, clamp(str_to_num(ping), 0, 4095))
		
		// Increase loaded data counter
		g_loaded_counter++
	}
	if (file) fclose(file)
}

check_for_loaded_pings(id)
{
	// Nothing to check for
	if (g_loaded_counter <= 0) return;
	
	// Get steamid and ip
	static authid[32], ip[16], i, buffer[32]
	get_user_authid(id, authid, sizeof authid - 1)
	get_user_ip(id, ip, sizeof ip - 1, 1)
	
	for (i = 0; i < g_loaded_counter; i++)
	{
		// Retrieve authid
		ArrayGetString(g_loaded_authid, i, buffer, sizeof buffer - 1)
		
		// Compare it with this player's steamid and ip
		if (equali(buffer, authid) || equal(buffer, ip))
		{
			// We've got a match!
			g_pingoverride[id] = ArrayGetCell(g_loaded_ping, i)
			break;
		}
	}
}

AddBits(&bits, &bits_added, value, bit_count)
{
	// No more room (max 32 bits / 1 cell)
	if (bit_count > (32 - bits_added) || bit_count < 1)
		return;
	
	// Clamp value if its too high
	if (value >= (1 << bit_count))
		value = ((1 << bit_count) - 1)
	
	// Add new bits
	bits = bits + (value << bits_added)
	// Increase bits added counter
	bits_added += bit_count
}

WriteBytes(&bits, &bits_added, write_remaining)
{
	// Keep looping if there are more bytes to write
	while (bits_added >= 8)
	{
		// Write group of 8 bits
		write_byte(bits & ((1 << 8) - 1))
		
		// Remove bits we just sent by moving all bits to the right 8 times
		bits = bits >> 8
		bits_added -= 8
	}
	
	// Write remaining bits too?
	if (write_remaining && bits_added > 0)
	{
		write_byte(bits)
		bits = 0
		bits_added = 0
	}
}
```

<br><br>

arme_vip2.amxx - (evo_vip/2)

<br>

```pawn
#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <fakemeta_util>
#include <stripweapons>
#include <colorchat>

static const COLOR[] = "^x04" //green
static const CONTACT[] = ""
new maxplayers
new gmsgSayText
new g_type, g_hudmsg
new mpd, mkb, mhb
new health_add
new health_hs_add
new health_max
new nKiller
new nKiller_hp
new nHp_add
new round;
new nHp_max
new g_menu_active
#define Keysrod (1<<0)|(1<<1)|(1<<2)|(1<<9)



public plugin_init()
{
	register_plugin("VIP", "3.0", "Hasky")
	mpd = register_cvar("vip_money_damage","3")
	mkb = register_cvar("vip_money_kill","500")
	mhb = register_cvar("vip_money_hs","1000")
	health_add = register_cvar("vip_hp_kill", "10")
	health_hs_add = register_cvar("vip_hp_hs", "25")
	health_max = register_cvar("vip_hp_max", "100")
	g_menu_active = register_cvar("vip_guns_menu", "1")
	register_event("Damage","Damage","b")
	register_event("DeathMsg","death_msg","a")
	register_clcmd("say /vip","ShowMotd")
	maxplayers = get_maxplayers()
	gmsgSayText = get_user_msgid("SayText")
	register_clcmd("say", "handle_say")
	register_cvar("amx_contactinfo", CONTACT, FCVAR_SERVER) 
	register_event("TextMsg","Event_RoundRestart","a","2&#Game_w")
	register_event("DeathMsg", "hook_death", "a", "1>0")
	register_event("Damage", "on_damage", "b", "2!0", "3=0", "4!0")
	register_menucmd(register_menuid("rod"), Keysrod, "Pressedrod")
	g_type = register_cvar("vip_bulletdamage","1")
	g_hudmsg = CreateHudSyncObj()
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0") 
	
	
}

public on_damage(id)
{
	if(get_pcvar_num(g_type))
	{
		static attacker; attacker = get_user_attacker(id)
		static damage; damage = read_data(2)	

		if(get_user_flags(attacker) & ADMIN_LEVEL_H)	
		{
			if(is_user_connected(attacker))
			{
				if(fm_is_ent_visible(attacker,id))
				{
					set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
					ShowSyncHudMsg(attacker, g_hudmsg, "%i^n", damage)				
				}
					
				
			}
		}
	}
}

public Damage(id)
{
	new weapon, hitpoint, attacker = get_user_attacker(id,weapon,hitpoint)
	if(attacker<=maxplayers && is_user_alive(attacker) && attacker!=id)
	if (get_user_flags(attacker) & ADMIN_LEVEL_H) 
	{
		new money = read_data(2) * get_pcvar_num(mpd)
		if(hitpoint==1) money += get_pcvar_num(mhb)
		cs_set_user_money(attacker,cs_get_user_money(attacker) + money)
	}
}

public death_msg()
{
	if(read_data(1)<=maxplayers && read_data(1) && read_data(1)!=read_data(2)) cs_set_user_money(read_data(1),cs_get_user_money(read_data(1)) + get_pcvar_num(mkb) - 300)
}
public event_new_round()
{
	round++
	new players[32], player, pnum;
	get_players(players, pnum, "a");
	for(new i = 0; i < pnum; i++)
	{
		player = players[i];
		if(get_user_flags(player) & ADMIN_LEVEL_H)
		{

		if (!get_pcvar_num(g_menu_active))
			return PLUGIN_CONTINUE
		
		if(round > 2)
		Showrod(player);
		
		}
	}
	return PLUGIN_HANDLED
}

public Event_RoundRestart(id)
{
	round=0;
}

public hook_death()
{
   // Killer id
   nKiller = read_data(1)
   
   if ( (read_data(3) == 1) && (read_data(5) == 0) )
   {
      nHp_add = get_pcvar_num (health_hs_add)
   }
   else
      nHp_add = get_pcvar_num (health_add)
   nHp_max = get_pcvar_num (health_max)
   // Updating Killer HP
   if(!(get_user_flags(nKiller) & ADMIN_LEVEL_H))
   return;

   nKiller_hp = get_user_health(nKiller)
   nKiller_hp += nHp_add
   // Maximum HP check
   if (nKiller_hp > nHp_max) nKiller_hp = nHp_max
   set_user_health(nKiller, nKiller_hp)
   // Hud message "Healed +15/+30 hp"
   set_hudmessage(0, 255, 0, -1.0, 0.15, 0, 1.0, 1.0, 0.1, 0.1, -1)
   show_hudmessage(nKiller, "Healed +%d hp", nHp_add)
   // Screen fading
   message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, nKiller)
   write_short(1<<10)
   write_short(1<<10)
   write_short(0x0000)
   write_byte(0)
   write_byte(0)
   write_byte(200)
   write_byte(75)
   message_end()
 
}

public Showrod(id) 
{
	show_menu(id, Keysrod, "Guns Menu^n\w1. M4a1+Deagle^n\w2. AK47+Deagle^n\w3. Grenades^n0. Exit^n", -1, "rod") // Display menu
}
public Pressedrod(id, key) 
{
	
	switch (key) {
		case 0: { 
			StripWeapons(id, Primary)
			StripWeapons(id, Secondary);
			give_item(id,"weapon_m4a1")
			give_item(id,"weapon_deagle")
			give_item(id, "item_assaultsuit");
			give_item(id, "item_thighpack");
			cs_set_user_bpammo(id, CSW_M4A1, 90 );
			cs_set_user_bpammo(id, CSW_DEAGLE, 35 );
			client_print(id, print_center, "You Taked Free M4A1 and Deagle")
			ColorChat(id, GREEN, "[VIP]^x01 Ai primit un^x04 M4a1^x01 si un^x04 Deagle")
			}

		case 1: { 
			StripWeapons(id, Primary)
			StripWeapons(id, Secondary);
			give_item(id,"weapon_ak47")
			give_item(id,"weapon_deagle")
			give_item(id, "item_assaultsuit");
			give_item(id, "item_thighpack");
			cs_set_user_bpammo(id, CSW_AK47, 90);
			cs_set_user_bpammo(id, CSW_DEAGLE, 35 );
			ColorChat(id, GREEN, "[VIP]^x01 Ai primit un^x04 Ak47^x01 si un^x04 Deagle")
			}

		case 2: {
			StripWeapons(id, Grenades)
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_smokegrenade");
			give_item(id, "item_assaultsuit");
			give_item(id, "item_thighpack");
			ColorChat(id, GREEN, "[VIP]^x01 Ai primit un ^x04set de grenazi")
			}

		case 9: { 			
			}
		     }
	return PLUGIN_CONTINUE
}


public ShowMotd(id)
{
 show_motd(id, "vip.txt")
}

public handle_say(id) {
	new said[192]
	read_args(said,192)
	if( contain(said, "/vips") != -1 )
		set_task(0.1,"print_adminlist",id)
	return PLUGIN_CONTINUE
}

public print_adminlist(user) 
{
	new adminnames[33][32]
	new message[256]
	new contactinfo[256], contact[112]
	new id, count, x, len
	
	for(id = 1 ; id <= maxplayers ; id++)
		if(is_user_connected(id))
			if(get_user_flags(id) & ADMIN_LEVEL_H)
				get_user_name(id, adminnames[count++], 31)

	len = format(message, 255, "%s VIP Online: ",COLOR)
	if(count > 0) {
		for(x = 0 ; x < count ; x++) {
			len += format(message[len], 255-len, "%s%s ", adminnames[x], x < (count-1) ? ", ":"")
			if(len > 96 ) {
				print_message(user, message)
				len = format(message, 255, "%s ",COLOR)
			}
		}
		print_message(user, message)
	}
	else {
		len += format(message[len], 255-len, "No VIP online.")
		print_message(user, message)
	}
	
	get_cvar_string("amx_contactinfo", contact, 63)
	if(contact[0])  {
		format(contactinfo, 111, "%s Contact Server Admin -- %s", COLOR, contact)
		print_message(user, contactinfo)
	}
}

print_message(id, msg[]) {
	message_begin(MSG_ONE, gmsgSayText, {0,0,0}, id)
	write_byte(id)
	write_string(msg)
	message_end()
}
```

<br><br><br>

**3. Infos**

GeoIP+(maxmind) - https://forums.alliedmods.net/showthread.php?t=95665 & https://dev.maxmind.com/geoip/geoip2/geolite2/

ORIGINAL - https://i.imgur.com/oIvprew.jpg

<br><br>

**5. Errors about txt and saving bank ..**

<br>

@Utils:
- https://forums.alliedmods.net/showthread.php?t=157986
- https://forums.alliedmods.net/showthread.php?t=175051
- https://forums.alliedmods.net/showthread.php?t=121288?t=121288
- https://forums.alliedmods.net/showthread.php?t=92340?t=92340
- https://forums.alliedmods.net/showthread.php?t=157986?t=157986
- https://forums.alliedmods.net/showthread.php?t=254828
- https://forums.alliedmods.net/showthread.php?t=218387?t=218387
- https://forums.alliedmods.net/showthread.php?t=149872
- http://zppv.boards.net/thread/259/ammo-save
- https://forums.alliedmods.net/showthread.php?p=821615
- http://zombie-mod.ru/counter-strike/zombie-plague/

<br>

ORIGINAL - https://i.imgur.com/3jEz91i.jpg

<br><br>

- **Fixes:**

<br>

zm_vip.txt

<br>

```txt
[en]
SERVER_CONFIG_ERROR = Server configuration error. Please tell server administrator about this
NO_VIP_TXT = This function disabled. Contact server administrator to solve this problem

USAGE = Usage
DOES_NOT_HAVE_VIP = Player "%s" does not have VIP privilege
PRIVILEGE_REMOVED = Player ^"%s^" VIP privilege has been removed
PLUGIN_ERROR_REMOVING = Plugin error removing VIP privilege for player "%s"

BUY_VIP = Buy VIP
NOT_ENOUGHT = Not enought
NO_ITEMS_FOR_TEAM = No items found for your team
NO_PLUGINS_LOADED = No extra plugins loaded

BUY_VIP_PRIVILEGE = Buy VIP privilege
PRICE = Price
TIME = Time
BUY = Buy
EXIT = Exit
PURCHASED_VIP = You have purchased a VIP privilege
PURCHASED_VIP_TILL_MD = You have purchased VIP till disconnect or mapchange
PURCHASED_VIP_TILL_D = You have purchased VIP till disconnect

TILL_MAPCHANGE = Till mapchange
TILL_DISCONNECT = Till disconnect (available during map changes)

TIMELEFT = timeleft

WEEK = week
WEEKS = weeks
WEEKSW = weeks
DAY = day
DAYS = days
DAYSW = days
HOUR = hour
HOURS = hours
HOURSW = hours
MINUTE = minute
MINUTES = minutes
MINUTESW = minutes
SECOND = second
SECONDS = seconds
SECONDSW = seconds
PERMANENT = Permanent

NO_VIP_ONLINE = There are no VIP player Online
ONLINE_VIPS = Online VIPs
ADMIN_CONTACTS = Administration contacts
CONNECTED_TO_SERVER = connected to server
INVALID_PASS = Invalid this nick password
PASS_NOT_MATCH = Client password not match! Privileges not granted
AMMO_PACKS = ammo packs
MONEY = Dolars
PURCHASED = Purchased
VIP_MENU_TOP = Vip Menu
ALREADY_VIP_INFO = You already have VIP. From more info, type /vip in chat
YOU_ARE_NOT_VIP = You are not a VIP member. Buy it (/vm)
YOU_ARE_NOT_VIP_INFO = You are not a VIP member. For more info type /vip in chat
YOU_ARE_NOT_VIP_MENU = You have to be a VIP to enter this menu
EXCEEDED_BUY_LIMIT = You exceeded buys limit per round. It's - %d. Please wait for the next round.
NOT_ALIVE = You have to be alive to use this menu
VIPONLY_CLASS = Your selected class in only for *VIP* members
VIPONLY_CLASS_INFO = Your selected class in only for *VIP* members. Please select another class
FREE_VIP_GOT = Free VIP enabled on server, and you got one! Use it till time ends
FREE_VIP_EXPIRED = Unfortunately, free VIP expired. You can't use privileges anymore

[ro]
SERVER_CONFIG_ERROR = Server configuration error. Please tell server administrator about this
NO_VIP_TXT = This function disabled. Contact server administrator to solve this problem

USAGE = Usage
DOES_NOT_HAVE_VIP = Player "%s" does not have VIP privilege
PRIVILEGE_REMOVED = Player ^"%s^" VIP privilege has been removed
PLUGIN_ERROR_REMOVING = Plugin error removing VIP privilege for player "%s"

BUY_VIP = Buy VIP
NOT_ENOUGHT = Not enought
NO_ITEMS_FOR_TEAM = No items found for your team
NO_PLUGINS_LOADED = No extra plugins loaded

BUY_VIP_PRIVILEGE = Buy VIP privilege
PRICE = Price
TIME = Time
BUY = Buy
EXIT = Exit
PURCHASED_VIP = You have purchased a VIP privilege
PURCHASED_VIP_TILL_MD = You have purchased VIP till disconnect or mapchange
PURCHASED_VIP_TILL_D = You have purchased VIP till disconnect

TILL_MAPCHANGE = Till mapchange
TILL_DISCONNECT = Till disconnect (available during map changes)

TIMELEFT = timeleft

WEEK = week
WEEKS = weeks
WEEKSW = weeks
DAY = day
DAYS = days
DAYSW = days
HOUR = hour
HOURS = hours
HOURSW = hours
MINUTE = minute
MINUTES = minutes
MINUTESW = minutes
SECOND = second
SECONDS = seconds
SECONDSW = seconds
PERMANENT = Permanent

NO_VIP_ONLINE = There are no VIP player Online
ONLINE_VIPS = Online VIPs
ADMIN_CONTACTS = Administration contacts
CONNECTED_TO_SERVER = connected to server
INVALID_PASS = Invalid this nick password
PASS_NOT_MATCH = Client password not match! Privileges not granted
AMMO_PACKS = ammo packs
MONEY = Dolars
PURCHASED = Purchased
VIP_MENU_TOP = Vip Menu
ALREADY_VIP_INFO = You already have VIP. From more info, type /vip in chat
YOU_ARE_NOT_VIP = You are not a VIP member. Buy it (/vm)
YOU_ARE_NOT_VIP_INFO = You are not a VIP member. For more info type /vip in chat
YOU_ARE_NOT_VIP_MENU = You have to be a VIP to enter this menu
EXCEEDED_BUY_LIMIT = You exceeded buys limit per round. It's - %d. Please wait for the next round.
NOT_ALIVE = You have to be alive to use this menu
VIPONLY_CLASS = Your selected class in only for *VIP* members
VIPONLY_CLASS_INFO = Your selected class in only for *VIP* members. Please select another class
FREE_VIP_GOT = Free VIP enabled on server, and you got one! Use it till time ends
FREE_VIP_EXPIRED = Unfortunately, free VIP expired. You can't use privileges anymore
```

<br><br>

UnPrecacher.sma

<br>

```pawn
#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>

#define MAPSETTINGS 0

new ConfigDirectory[] = "precacheControl"
new WeaponsDirectory[] = "weapons"

new ConfigPath[200]
new WeaponsPath[200]

const MaxFilenameLength = 100

new Array:C4Entries

enum Cvar
{
	CvarC4,
	CvarCZ,
	CvarHL,
	CvarWeapons
}

new CvarSuffixes[Cvar][] =
{
	"c4",
	"cz",
	"hl",
	"weapons"
}

new CvarPrefix[] = "precache_"

new Cvars[Cvar]

new HamHook:SpawnBombsiteHook1
new HamHook:SpawnBombsiteHook2

new Trie:BlockedEntries

validPathOrDie(path[])
{
	if(!dir_exists(path))
	{
		set_fail_state("Plugin installation problem. You don't have the configuration folders in place")
	}
}

Array:getFileEntries(file[],bool:isWeapon=false)
{
	static path[200]

	formatex(path,charsmax(path),"%s%s.ini",isWeapon ? WeaponsPath : ConfigPath , file)

	if(!file_exists(path))
	{
		set_fail_state("Plugin installation problem. You don't have the configuration files in place")
	}

	new file = fopen(path,"r")

	if(file)
	{
		new Array:array = ArrayCreate(MaxFilenameLength)

		new line[MaxFilenameLength+1]

		while(fgets(file,line,charsmax(line)))
		{
			trim(line)

			ArrayPushString(array,line)
		}

		fclose(file)

		return array
	}
	else
	{
		static msg[200]
		formatex(msg,charsmax(msg),"Failed to open file [%s]",path)
		set_fail_state(msg)
	}

	return Array:0
}

blockEntries(Array:array)
{
	new entryData[MaxFilenameLength]

	for(new i=0;i<ArraySize(array);i++)
	{
		ArrayGetString(array,i,entryData,charsmax(entryData))

		TrieSetCell(BlockedEntries,entryData,true)
	}
}

handleFolders()
{
	get_configsdir(ConfigPath,charsmax(ConfigPath))
	format(ConfigPath,charsmax(ConfigPath),"%s/%s/",ConfigPath,ConfigDirectory)

	validPathOrDie(ConfigPath)

	formatex(WeaponsPath,charsmax(WeaponsPath),"%s%s/",ConfigPath,WeaponsDirectory)

	validPathOrDie(WeaponsPath)
}

handleCvars()
{
	new FullCvar[charsmax(CvarPrefix) + 10]

	new at = copy(FullCvar,charsmax(FullCvar),CvarPrefix)

	for(new Cvar:i=Cvar:0;i<Cvar;i++)
	{
		formatex(FullCvar[at],charsmax(FullCvar) - at,CvarSuffixes[i])

		Cvars[i] = !!get_pcvar_num(register_cvar(FullCvar,"0"))
	}
}

blockWeapons()
{
	new path[200]

	get_configsdir(path,charsmax(path))

#if MAPSETTINGS
	new mapname[32]
	get_mapname(mapName,charsmax(mapName))
	format(path,charsmax(path),"%s/weaprest_%s.ini",path, mapname)
#else
	format(path,charsmax(path),"%s/weaprest.ini",path)
#endif

	new file = fopen(path,"r")

	if(file)
	{
		new line[100]

		while(fgets(file,line,charsmax(line)))
		{
			trim(line)

			if(line[0] && line[0] != ';')
			{
				new spaceIndex = contain(line," ")
				line[spaceIndex] = 0

				blockEntries(getFileEntries(line,true))
			}
		}

		fclose(file)
	}
}

public plugin_precache()
{
	register_plugin("precacheControl","1.0","")

	BlockedEntries = TrieCreate()

	handleFolders()
	handleCvars()

	if(!Cvars[CvarCZ])
	{
		blockEntries(getFileEntries("cz"))
	}

	if(!Cvars[CvarHL])
	{
		blockEntries(getFileEntries("hl"))
	}

	if(!Cvars[CvarC4])
	{
		blockEntries(C4Entries = getFileEntries("c4",true))

		SpawnBombsiteHook1 = RegisterHam(Ham_Spawn,"func_bomb_target","precacheBombsite")
		SpawnBombsiteHook2 = RegisterHam(Ham_Spawn,"info_bomb_target","precacheBombsite")
	}

	if(!Cvars[CvarWeapons])
	{
		blockWeapons()
	}

	register_forward(FM_PrecacheModel,"precache")
	register_forward(FM_PrecacheSound,"precache")
}

public precacheBombsite()
{
	new entryData[MaxFilenameLength]

	for(new i=0;i<ArraySize(C4Entries);i++)
	{
		ArrayGetString(C4Entries,i,entryData,charsmax(entryData))

		new len = strlen(entryData)

		new soundExtension[] = ".wav"

		new extensionIndex = len - charsmax(soundExtension)

		if(extensionIndex > 0)
		{
			if(equal(entryData[extensionIndex],soundExtension))
			{
				engfunc(EngFunc_PrecacheSound,entryData)
			}
			else
			{
				engfunc(EngFunc_PrecacheModel,entryData)
			}

			//server_print("Unblocking precache [%s]",entryData)
		}
	}

	DisableHamForward(SpawnBombsiteHook1)
	DisableHamForward(SpawnBombsiteHook2)
}

public precache(data[])
{
	if(TrieKeyExists(BlockedEntries,data))
	{
		//server_print("Blocking precache [%s]",data)
		return FMRES_SUPERCEDE
	}

	return FMRES_IGNORED
}
```

<br><br>

zp50_bank_nvault.inc

<br>

```pawn
#include <nvault>

public plugin_end()
{
	if(!get_pcvar_num(CvarAutoSave))
		return

	new iPlayers[32], iNum
	get_players(iPlayers, iNum)

	new iPlayer
	for(new i = 0; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		Save_nVault(iPlayer)
	}

	nvault_close(g_hVault)
}

public Load_nVault(player)
{
	new szKey[40], szData[35], ts

	formatex(szKey, 39, "%s", g_iSteamID[player])

	if(nvault_lookup(g_hVault, szKey, szData, charsmax(szData), ts))
	{
		new ibank[5], iammo[5]
		parse(szData, ibank, charsmax(ibank), iammo, charsmax(iammo))
		g_iBank[player] = ibank
		g_iAmmoPacks[player] = iammo
		//nvault_remove(g_hVault, szKey)
	}
	else
	{
		new start_ammo = get_cvar_num("zp_starting_ammo_packs")
		g_iBank[player] = g_iAmmoPacks[player] = start_ammo
		//if(is_user_connected(player))
		//{
		zp_ammopacks_set(player, start_ammo)
		//}
	}
}

public Save_nVault(player)
{
	//g_iAmmoPacks[player] = zp_ammopacks_get(player)

	if(!IsManual[player])
	{
		g_iBank[player] = (g_iBank[player] + g_iAmmoPacks[player])
	}
	else
	{
		IsManual[player] = false
	}

	new szData[8], szKey[40]

	formatex(szKey, 39, "%s", g_iSteamID[player])
	formatex(szData, 7, "%d %d", g_iBank[player], g_iAmmoPacks[player])

	nvault_set(g_hVault, szKey, szData)
}
```

<br><br>

zp50_ammopacks_bank.sma

<br>

```pawn
#include <amxmodx>
#include <amxmisc>
#include <zp50_ammopacks>

//#define SQLX
#define ADMIN_LEVEL_TO_RESET	ADMIN_BAN

new const PLUGIN_VERSION[] = "1.1.5"

#if defined SQLX
	new SQL_HOST[] = "127.0.0.1"
	new SQL_USER[] = "root"
	new SQL_PASS[] = "yoursqlpasswordhere"
	new SQL_DB[] = "amx"

	new Handle:g_SqlTuple
	new g_Error[512]
#else
	new g_hVault
#endif

const SIZE = 1536

new CvarAutoSave, CvarAutoLoad, CvarBankLimit, CvarBankBlockStart, CvarBankAdvertiseInterval

new g_iSteamID[33][32], g_iBank[33], g_iAmmoPacks[33], bool:IsManual[33], bool:IsAll[33]

#if defined SQLX
	#include <zp50_bank_sqlx>
#else
	#include <zp50_bank_nvault>
#endif

public plugin_init()
{
	register_plugin("[ZP 5.0] Ammo Packs Bank", PLUGIN_VERSION, "Excalibur.007") // Adryyy edition
	register_dictionary("zp50_bank.txt")

	register_clcmd("say", "OnClientChat")
	register_clcmd("say_team", "OnClientChat")
	register_concmd("zp_bank_reset", "OnAdminReset", ADMIN_LEVEL_TO_RESET, "- resets bank in terms of days. 0 to clean all.")

	CvarAutoSave = register_cvar("zp_bank_auto_save", "1")
	CvarAutoLoad = register_cvar("zp_bank_auto_load", "1")
	CvarBankLimit = register_cvar("zp_bank_limit", "99999999999")
	CvarBankBlockStart = register_cvar("zp_bank_block_start", "0")
	CvarBankAdvertiseInterval = register_cvar("zp_bank_advertise_interval", "60.0")

	register_cvar("zp_starting_ammo_packs", "1000")

	#if defined SQLX
		set_task(0.5, "MySQL_Init")
	#else
		g_hVault = nvault_open("zp50_ammo_packs_bank")

		if(g_hVault == INVALID_HANDLE)
			set_fail_state("Unable to create/load vault 'zp50_ammo_packs_bank'")
	#endif
}

public plugin_cfg()
{
	set_task(get_pcvar_float(CvarBankAdvertiseInterval), "AdvertiseBankInfo", 0)
}

public AdvertiseBankInfo()
{
	new iPlayers[32], iNum
	get_players(iPlayers, iNum, "ch")

	new player
	for(new i = 0; i < iNum; i++)
	{
		player = iPlayers[i]

		xCoLoR(player, "%L", player, "BANK_ADVERTISE")
	}
}

public client_putinserver(player)
{
	if(get_pcvar_num(CvarBankBlockStart)==1)
		zp_ammopacks_set(player, 0)

	get_user_name(player, g_iSteamID[player], 31)

	if(get_pcvar_num(CvarAutoLoad)==1)
	{
		#if defined SQLX
			Load_MySQL(player)
		#else
			if(is_user_connected(player))
				Load_nVault(player)
		#endif
	}
}

public client_disconnect(player)
{
	if(get_pcvar_num(CvarAutoSave)==1)
	{
		#if defined SQLX
			Save_MySQL(player)
		#else
			Save_nVault(player)
		#endif
	}

	g_iSteamID[player][0] = 0
	g_iBank[player] = 0
	g_iAmmoPacks[player] = 0
	IsManual[player] = false
	IsAll[player] = false
}

public OnClientChat(player)
{
	static szArgs[32]
	read_args(szArgs, 31)
	remove_quotes(szArgs)

	static szArg1[32], szArg2[32], szArg3[32]

	szArg1[0] = '^0'
	szArg2[0] = '^0'
	szArg3[0] = '^0'

	parse(szArgs, szArg1, 31, szArg2, 31, szArg3, 32)

	new iValue = str_to_num(szArg2)

	g_iAmmoPacks[player] = zp_ammopacks_get(player)

	new iBankLimit = get_pcvar_num(CvarBankLimit)

	if(equali(szArg1, "/deposit", 8) || equali(szArg1, "deposit", 7) || equali(szArg1, "/depozit", 8) || equali(szArg1, "depozit", 7)
	|| equali(szArg1, "/depozitez", 10) || equali(szArg1, "depozitez", 9))
	{
		if(!g_iAmmoPacks[player]||g_iAmmoPacks[player]<=0)
		{
			xCoLoR(player, "%L", player, "BANK_INSUFICIENT_VALUE")
			return PLUGIN_HANDLED
		}
		if(iValue >= g_iAmmoPacks[player])
		{
			iValue = g_iAmmoPacks[player]
		}
		if(equali(szArg2, "all", 3) || equali(szArg2, "tot", 3))
		{
			if(/*iValue < g_iAmmoPacks[player]||*/!g_iAmmoPacks[player]||g_iAmmoPacks[player]<=0)
			{
				xCoLoR(player, "%L", player, "BANK_INSUFICIENT_VALUE")
				return PLUGIN_HANDLED
			}
			else
			{
				iValue = g_iAmmoPacks[player]
				IsAll[player] = true
			}
		}
		if(iValue <= 0 && !IsAll[player])
		{
			xCoLoR(player, "%L", player, "BANK_INVALID_AMOUNT")
			return PLUGIN_HANDLED
		}

		IsAll[player] = false
		IsManual[player] = true

		//new iTemp = g_iBank[player]

		//g_iBank[player] += iValue

		//if(g_iBank[player] > iBankLimit)
		//{
			//zp_ammopacks_set(player, g_iAmmoPacks[player] + g_iBank[player] - iBankLimit)

			//iValue = iBankLimit - iTemp

			//g_iBank[player] = iBankLimit
		//}
		//else
		//{
			//zp_ammopacks_set(player, g_iAmmoPacks[player] - iValue)

			//g_iBank[player] += iValue
		//}

		g_iAmmoPacks[player] -= iValue
		g_iBank[player] += iValue


		if(IsAll[player])	zp_ammopacks_set(player, 0)
		else zp_ammopacks_set(player, g_iAmmoPacks[player] - iValue)

		//zp_ammopacks_set(player, g_iBank[player] + iValue)

		if(get_pcvar_num(CvarAutoSave))
		{
			#if defined SQLX
				Save_MySQL(player)
			#else
				Save_nVault(player)
			#endif
		}

		xCoLoR(player, "%L", player, "BANK_DEPOSIT", iValue)

		return PLUGIN_HANDLED
	}
	else if(equali(szArg1, "/withdraw", 9) || equali(szArg1, "withdraw", 8) || equali(szArg1, "/retrage", 8) || equali(szArg1, "retrage", 7)
	|| equali(szArg1, "/retrag", 7) || equali(szArg1, "retrag", 6))
	{
		if(g_iBank[player]<=0||!g_iBank[player])
		{
			xCoLoR(player, "%L", player, "BANK_INSUFICIENT_VALUE")
			return PLUGIN_HANDLED
		}
		if(iValue >= g_iBank[player])
		{
			iValue = g_iBank[player]
		}
		if(equali(szArg2, "all", 3) || equali(szArg2, "tot", 3))
		{
			if(/*iValue < g_iBank[player]||*/g_iBank[player]<=0||!g_iBank[player])
			{
				xCoLoR(player, "%L", player, "BANK_INSUFICIENT_VALUE")
				return PLUGIN_HANDLED
			}
			else
			{
				iValue = g_iBank[player]
				IsAll[player] = true
			}
		}

		if(iValue <= 0 && !IsAll[player])
		{
			xCoLoR(player, "%L", player, "BANK_INVALID_AMOUNT")
			return PLUGIN_HANDLED
		}

		IsAll[player] = false
		IsManual[player] = true

		g_iBank[player] -= iValue
		g_iAmmoPacks[player] += iValue

		zp_ammopacks_set(player, g_iAmmoPacks[player]/* + iValue*/)

		if(get_pcvar_num(CvarAutoSave))
		{
			#if defined SQLX
				Save_MySQL(player)
			#else
				Save_nVault(player)
			#endif
		}

		xCoLoR(player, "%L", player, "BANK_WITHDRAW", iValue)

		return PLUGIN_HANDLED
	}
	else if(equali(szArg1, "/bank", 5) || equali(szArg1, "bank", 4) || equali(szArg1, "/banca", 6) || equali(szArg1, "banca", 5))
	{
		xCoLoR(player, "%L", player, "BANK_BALANCE", g_iBank[player])

		return PLUGIN_HANDLED
	}
	else if(equali(szArg1, "/donate", 7) || equali(szArg1, "donate", 6) || equali(szArg1, "/transfer", 9) || equali(szArg1, "transfer", 8))
	{
		new iValue = str_to_num(szArg3)

		if(iValue <= g_iBank[player]/*g_iAmmoPacks[player]*/)
		{
			xCoLoR(player, "%L", player, "BANK_INSUFICIENT_VALUE")
			return PLUGIN_HANDLED
		}
		if(iValue >= g_iBank[player] /*|| iValue > g_iAmmoPacks[player]*/)
		{
			xCoLoR(player, "%L", player, "BANK_DONATE_HIGHER_AMOUNT")
			return PLUGIN_HANDLED
		}

		if(iValue <= 0)
		{
			xCoLoR(player, "%L", player, "BANK_INVALID_AMOUNT")
			return PLUGIN_HANDLED
		}

		new target = cmd_target(player, szArg2, CMDTARGET_NO_BOTS)

		if(!target)
		{
			xCoLoR(player, "%L", player, "BANK_INVALID_TARGET")
			return PLUGIN_HANDLED
		}

		new iTemp = g_iBank[player]

		new szNamePlayer[32], szNameTarget[32]

		get_user_name(player, szNamePlayer, 31)
		get_user_name(target, szNameTarget, 31)

		g_iBank[player] -= iValue
		g_iBank[target] += iValue

		if(g_iBank[target] > iBankLimit)
		{
			iValue = iBankLimit - iTemp

			g_iBank[player] += (g_iBank[target] - iBankLimit)
			g_iBank[target] = iBankLimit
		}

		if(get_pcvar_num(CvarAutoSave))
		{
			#if defined SQLX
				Save_MySQL(player)
				Save_MySQL(target)
			#else
				Save_nVault(player)
				Save_nVault(target)
			#endif
		}

		xCoLoR(player, "%L", player, "BANK_DONATE_CHAT_TO_PLAYER", iValue, szNameTarget)
		xCoLoR(target, "%L", target, "BANK_DONATE_CHAT_TO_TARGET", szNamePlayer, iValue)

		return PLUGIN_HANDLED
	}
	else if(equali(szArg1, "/bankhelp", 9) || equali(szArg1, "bankhelp", 8))
	{
		new msg[SIZE + 1], len = 0

		len += format(msg[len], SIZE - len, "<html><body>")
		len += format(msg[len], SIZE - len, "<p>[BANK COMMANDS]<br/>")
		len += format(msg[len], SIZE - len, "------------------------------------------------------------------------</p>")
		len += format(msg[len], SIZE - len, "/withdraw <amount> or /withdraw all<br/>")
		len += format(msg[len], SIZE - len, "- Withdraws an amount of ammo packs from the bank storage</p>")
		len += format(msg[len], SIZE - len, "------------------------------------------------------------------------</p>")
		len += format(msg[len], SIZE - len, "/deposit <amount> or /deposit all</p>")
		len += format(msg[len], SIZE - len, "------------------------------------------------------------------------</p>")
		len += format(msg[len], SIZE - len, "- Deposits an amount of ammo packs to the bank storage</p>")
		len += format(msg[len], SIZE - len, "- Checks your bank status</p>")
		len += format(msg[len], SIZE - len, "------------------------------------------------------------------------</p>")
		len += format(msg[len], SIZE - len, "/donate <amount> <player's name> </p>")
		len += format(msg[len], SIZE - len, "- Donates an amount of ammo packs to the specified player</p>")
		len += format(msg[len], SIZE - len, "------------------------------------------------------------------------</p>")
		len += format(msg[len], SIZE - len, "Note: Commands can be entered without ^"/^" infront.</p>")
		len += format(msg[len], SIZE - len, "</body></html>")
		show_motd(player, msg, "Bank Help")

		return PLUGIN_CONTINUE
	}
	else if(equali(szArg1, "/banksave", 9) || equali(szArg1, "banksave", 8))
	{
		#if defined SQLX
			Save_MySQL(player)
		#else
			Save_nVault(player)
		#endif
	}
	else if(equali(szArg1, "/bankload", 9) || equali(szArg1, "bankload", 8))
	{
		#if defined SQLX
			Load_MySQL(player)
		#else
			Load_nVault(player)
		#endif
	}
	else
	{
		return PLUGIN_CONTINUE
	}

	return PLUGIN_CONTINUE
}

public OnAdminReset(player, level, cid)
{
	if(!cmd_access(player, level, cid, 1))
	{
		console_print(player, "You have no access to that command")
		return
	}
	new szArgc = read_argc()

	if(szArgc >= 3)
	{
		console_print(player, "Too many arguments supplied.")
		return
	}
	else if(szArgc == 1)
		return

	new szArgv[10]
	read_argv(1, szArgv, 9)

	new iTime = str_to_num(szArgv)

#if defined SQLX
	new szTemp[512]
#endif

	if(iTime == 0)
	{
		#if defined SQLX
			formatex(szTemp, 511, "TRUNCATE TABLE `bank`")

			SQL_ThreadQuery(g_SqlTuple, "IgnoreHandle", szTemp)
		#else
			nvault_prune(g_hVault, 0, 0)
		#endif

		new iPlayers[32], iNum
		get_players(iPlayers, iNum)

		new player2
		for(new i = 0; i < iNum; i++)
		{
			player2 = iPlayers[i]

			g_iBank[player2] = 0
		}
	}
	else
	{
		#if defined SQLX
			formatex(szTemp, 511, "DELETE FROM `bank` WHERE last_played<(SYSDATE() - INTERVAL '%d' DAY)", iTime)

			SQL_ThreadQuery(g_SqlTuple, "IgnoreHandle", szTemp)
		#else
			nvault_prune(g_hVault, 0, get_systime() - (iTime * 86400))
		#endif
	}
}

stock xCoLoR( const id, const input[ ], any:... )
{
	new count = 1, players[ 32 ];
	static msg[ 191 ];

	vformat( msg, 190, input, 3 );

	replace_all( msg, 190, "!v", "^4" );
	replace_all( msg, 190, "!n", "^1" );
	replace_all( msg, 190, "!e", "^3" );
	replace_all( msg, 190, "!e2", "^0" );

	if( id )
	{
		players[ 0 ] = id;
	}

	else get_players( players, count, "ch" );
	{
		for( new i = 0; i < count; i++ )
		{
			if( is_user_connected( players[ i ] ) )
			{
				message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "SayText" ), _, players[ i ] );
				write_byte( players[ i ] );
				write_string( msg );
				message_end( );
			}
		}
	}
}
```

u should read vip inc & sma firstly
