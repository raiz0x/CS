#include <amxmodx>
#include <amxmisc>
#include <nvault>

new const
	PLUGIN[] = "",
	VERSION[] = "2.0",
	AUTHOR[] = "S.Cosmin";

new iTime[33],Password[33][32],bool:HaveSlot[33] = false
new pcvar_hours,PasswordFieldCvarPointer,g_vault

new Trie:eData

#define TIMP	250.0

public plugin_init() {
	register_plugin(PLUGIN,VERSION,AUTHOR)
	
	register_clcmd("say","cmdSay")
	register_clcmd("say /ore","cmdOre")
	register_clcmd("amx_slot","cmdSlot")
	
	PasswordFieldCvarPointer = get_cvar_pointer("amx_password_field")
	pcvar_hours = register_cvar("cvar_hours_slot","10")
	eData = TrieCreate()
	refresh()
	
	set_task(TIMP,"mesaje",_,_,_,"b")
}
public refresh()
{
	new File[128],FilePointer,FileData[256],szName[32],szPassword[32]
	get_configsdir(File,charsmax(File))
	format(File,charsmax(File),"%s/%s",File,"slot.ini")
	if(!file_exists(File))
	{
		FilePointer = fopen(File,"w+")
		fclose(FilePointer)
	}
	FilePointer = fopen(File,"rt")
	if(FilePointer)
	{
		while(!feof(FilePointer))
		{
			fgets(FilePointer,FileData,charsmax(FileData))
			parse(FileData,szName,charsmax(szName),szPassword,charsmax(szPassword))
			TrieSetString(eData,szName,szPassword)
		}
		fclose(FilePointer)
	}
}
public cmdSay(id) {
	new szArgs[192],name[32],bool:bSlot = false
	read_args(szArgs,charsmax(szArgs))
	get_user_name(id,name,charsmax(name))
	remove_quotes(szArgs)

	if(HaveSlot[id])
	{
		if(TrieKeyExists(eData,name))
		{
			color(id,"!team[AMXX]!yAi deja slot pe acest nick.")
			HaveSlot[id] = false
			bSlot = true
			return 1
		}
		if(strlen(szArgs) < 6 || strlen(szArgs) > 20 || equal(szArgs,"") || !szArgs[0])
		{
			color(id,"!team[AMXX]!yParola invalida,minim 6 caractere,maxim 20.")
			client_cmd(id,"messagemode")
			return 1
		}
		copy(Password[id],charsmax(Password[]),szArgs)
		give_slot(id)
		return 1
	}
	if(equali(szArgs,"/slot") && !is_user_admin(id))
	{
		if(bSlot)
		{
			color(id,"!team[AMXX]!yAi deja slot pe acest nick.")
			return 1
		}
		replace_all(szArgs,charsmax(szArgs),"/","")
		client_cmd(id,"amx_%s",szArgs)
	}
	return 0
}

public cmdSlot(id) {
	new szName[32]
	get_user_name(id,szName,charsmax(szName))
	
	if(TrieKeyExists(eData,szName) || is_user_admin(id))
	{
		color(id,"!team[AMXX]!yAi deja slot pe acest nick.")
		HaveSlot[id] = false
		return 1
	}
	new player_seconds,player_minutes,player_hours
	player_seconds = (iTime[id] * 60) + get_user_time(id)
	player_minutes = iTime[id] + (get_user_time(id) / 60)
	player_hours = player_seconds / 3600

	if(player_hours >= get_pcvar_num(pcvar_hours))
	{
		HaveSlot[id] = true
		color(id,"!team[AMXX]!yAdauga parola,dupa care scrii in consola !gsetinfo _pw !teamparola.")
		client_cmd(id,"messagemode")
	}
	else
	{
		color(id,"!team[AMXX]!yPana in acest moment aveti doar !g%i !yor%s (!g%i !yminut%s),mai aveti nevoie de !g%i !yor%s.",player_hours,player_hours == 1 ? "a": "e",player_minutes,player_minutes == 1 ? "" : "e",get_pcvar_num(pcvar_hours) - player_hours,get_pcvar_num(pcvar_hours) - player_hours == 1 ? "a" : "e")
		return 1
	}
	return 0
}
public cmdOre(id)
{
	new player_minutes
	player_minutes = iTime[id] + (get_user_time(id) / 60)
	
	if(player_minutes < 60)
	{
		color(id,"!team[AMXX]!yPana in acest moment aveti !g%i !yminut%s pe server.",player_minutes,player_minutes == 1 ? "" : "e")
		return
	}
	new player_seconds,player_hours
	player_seconds = (iTime[id] * 60) + get_user_time(id)
	player_hours = player_seconds / 3600
	color(id,"!team[AMXX]!yPana in acest moment aveti !g%i !yminute pe server (!g%d !yor%s).",player_minutes,player_hours,player_hours == 1? "a" : "e")
}
public client_connect(id)
{
	LoadData(id)
	set_task(0.3,"verify_player",id)
}
public client_disconnect(id)
{
	iTime[id] = iTime[id] + (get_user_time(id) / 60)
	SaveData(id)
	HaveSlot[id] = false
}
public client_infochanged(id) {
	SaveData(id)
	new oldname[32],newname[32]
	get_user_name(id,oldname,charsmax(oldname))
	get_user_info(id,"name",newname,charsmax(newname))

	if(!equal(newname,oldname))
	{
		set_task(0.1,"LoadData",id)
		set_task(0.1,"verify_player",id)
	}
}
public verify_player(id) {
	new PlayerPassword[32],PasswordField[5],szName[32],szPassword[32]
	get_pcvar_string(PasswordFieldCvarPointer,PasswordField,charsmax(PasswordField))
	get_user_info(id,PasswordField,PlayerPassword,charsmax(PlayerPassword))
	get_user_name(id,szName,charsmax(szName))

	if(TrieKeyExists(eData,szName))
	{
		TrieGetString(eData,szName,szPassword,charsmax(szPassword))
		if(!equal(PlayerPassword,szPassword))
		{
			server_cmd("kick #%i ^"Acest nume este rezervat pe server!^"",get_user_userid(id))
			return 1
		}
	}
	return 0
}
public give_slot(id)
{
	new File[128],name[32],FilePointer
	get_user_name(id,name,charsmax(name))
	get_configsdir(File,charsmax(File))
	format(File,charsmax(File),"%s/%s",File,"slot.ini")
	
	if(!file_exists(File))
	{
		FilePointer = fopen(File,"w+")
		fclose(FilePointer)
	}

	FilePointer = fopen(File,"a")
	if(FilePointer)
	{
		fprintf(FilePointer,"%s %s^n",name,Password[id])
		color(id,"!team[AMXX]!yAi fost adaugat cu succes in baza noastra de date,Nume: !g%s !yParola: !g%s",name,Password[id])
		fclose(FilePointer)
	}
	refresh()
}
public mesaje()
{
	color(0,"!team[AMXX]!yPentru a primii slot gratis, tasteaza comanda !g/slot!y.")
	color(0,"!team[AMXX]!yPentru a putea folosii comanda !g/slot !yaveti nevoie de minim !g%i !yor%s.",get_pcvar_num(pcvar_hours),get_pcvar_num(pcvar_hours) == 1 ? "a" : "e")
}
public SaveData(id)
{
	g_vault = nvault_open("PlayedTime")
	new name[32],vaultkey[64],vaultdata[256]
	get_user_name(id,name,charsmax(name))
	formatex(vaultkey,charsmax(vaultkey),"%s-OreJucate",name)
	formatex(vaultdata,charsmax(vaultdata),"%i ",iTime[id])
	nvault_set(g_vault,vaultkey,vaultdata)
	nvault_close(g_vault)
}
public LoadData(id)
{
	g_vault = nvault_open("PlayedTime")
	new name[32],vaultkey[64],vaultdata[256],time[32]
	get_user_info(id,"name",name,charsmax(name))
	formatex(vaultkey,charsmax(vaultkey),"%s-OreJucate",name)
	formatex(vaultdata,charsmax(vaultdata),"%i ",iTime[id])
	nvault_get(g_vault,vaultkey,vaultdata,charsmax(vaultdata)) 	
	parse(vaultdata,time,charsmax(time))
	iTime[id] = str_to_num(time)
	nvault_close(g_vault)
}
public plugin_end()
{
	TrieDestroy(eData)
}
stock color(const id,const input[ ],any:...)
{
	new count = 1,players[32]
	static msg[191]
	vformat(msg,190,input,3)
	replace_all(msg,190,"!g","^4")	//verde
	replace_all(msg,190,"!y","^1") //- galben
	replace_all(msg,190,"!team","^3") //- echipa
	replace_all(msg,190,"!n","^0") //- normal

	if(id) players[0] = id; else get_players(players,count,"ch")
	{
		for(new i = 0; i < count; i++)
		{
			if(is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("SayText"),_,players[i])
				write_byte(players[i])
				write_string(msg)
				message_end()
			}
		}
	}
}
