#include <amxmodx>
#include <hamsandwich>
#include <cstrike>
#include <nvault>
#include <fun>
#include <colorchat>

#pragma tabsize 0

static const
   PLUGIN[] = "Simple Level Mod",
   VERSION[] = "2.0",
   AUTHOR[] = "scosmyn";

#define MAX_LEVELS   16

new const Levels[MAX_LEVELS] =
{
   0,
   1,
   2,
   3,
   4,
   5,
   6,
   7,
   8,
   9,
   10,
   11,
   12,
   13,
   14
}
new const Kills[MAX_LEVELS] =
{
   0,
   50,
   100,
   150,
   250,
   350,
   500,
   650,
   750,
   850,
   1250,
   1500,
   2000,
   2500,
   5000
}

new const szTag[MAX_LEVELS][] =
{
   "",
   "Soldat",
   "Fruntas",
   "Caporal",
   "Sergent",
   "Plutonier",
   "Maistru",
   "Sublocotenent",
   "Locotenent",
   "Capitan",
   "Maior",
   "Colonel",
   "General de Brigada",
   "General-Maior",
   "General-Locotenent",
   "GENERAL"
}

new Level[33],Kill[33],szName[32],g_vault,g_sync
new pcvar_hs,pcvar_kill,pcvar_knife,pcvar_he,pcvar_efect,pcvar_r,pcvar_g,pcvar_b,pcvar_hp_lvl,pcvar_ap_lvl

static szChat[ 192 ]

public plugin_init() {
   register_plugin(PLUGIN,VERSION,AUTHOR)
   register_event("DeathMsg","ev_msg","a")
   RegisterHam(Ham_Spawn,"player","player_spawn",1)
   
   pcvar_hs = register_cvar("cvar_hs_bonus","1")
   pcvar_kill = register_cvar("cvar_normal_bonus","1")
   pcvar_knife = register_cvar("cvar_knife_bonus","1")
   pcvar_he = register_cvar("cvar_he_bonus","1")
   pcvar_efect = register_cvar("cvar_effect_lvl","1")
   pcvar_r = register_cvar("cvar_red","255")
   pcvar_g = register_cvar("cvar_green","0")
   pcvar_b = register_cvar("cvar_blue","0")
   pcvar_hp_lvl = register_cvar("cvar_hp_lvl","5")
   pcvar_ap_lvl = register_cvar("cvar_ap_lvl","10")
   
   g_vault = nvault_open("simple_lvl_mod")
   g_sync = CreateHudSyncObj()
   
   if(g_vault == INVALID_HANDLE)
      set_fail_state("Eroare la deschiderea bazei de date din vault.")


	register_clcmd( "say", "HookClCmdSay" );
	register_clcmd( "say_team", "HookClCmdSayTeam" );
}


public HookClCmdSay( id )
{
	if( is_user_bot( id )||!is_user_connected(id) )
		return PLUGIN_CONTINUE;
	read_args( szChat, sizeof( szChat ) - 1 );
	remove_quotes( szChat );
	if( equali( szChat,"" ) )
		return PLUGIN_CONTINUE;
	
	get_user_name( id, szName, sizeof ( szName ) -1 );
		
		for( new i = 0; i < MAX_LEVELS; i++ )
		{
				switch( cs_get_user_team( id ) )
				{
					case CS_TEAM_T:		ColorChat( 0, RED,"^1%s~^3[^4 Level %d^3 ]^1~^3 %s^4:^1 %s",is_user_alive( id ) ? "" : "*DEAD* ", Level[id], szName, szChat );
					case CS_TEAM_CT:	ColorChat( 0, BLUE,"^1%s~^3[^4 Level %d^3 ]^1~^3 %s^4:^1 %s",is_user_alive( id ) ? "" : "*DEAD* ", Level[id], szName, szChat );
					case CS_TEAM_SPECTATOR:	ColorChat( 0, GREY,"^1*SPEC*~^3[^4 Level %d^3 ]^1~^3 %s^4:^1 %s", Level[id], szName, szChat );
				}
				
				break;
		}
	
	return PLUGIN_HANDLED_MAIN;
}
public HookClCmdSayTeam( id )
{
	if( is_user_bot( id )||!is_user_connected(id) )
		return PLUGIN_CONTINUE;
	
	read_args( szChat, sizeof( szChat ) - 1 );
	remove_quotes( szChat );
	
	if( equali( szChat,"" ) )
		return PLUGIN_CONTINUE;
	
	static iPlayers[ 32 ], iPlayersNum;
	get_user_name( id, szName, sizeof ( szName ) -1 );
	
	get_players( iPlayers, iPlayersNum, "ch" );
	if( !iPlayersNum )
		return PLUGIN_CONTINUE;
	
	static iPlayer, i;
	iPlayer = -1; i = 0;
		static x; x = 0;
		
		for( x = 0; x < MAX_LEVELS; x++ )
		{
				for( i = 0; i < iPlayersNum; i++ )
				{
					iPlayer = iPlayers[ i ];
		
					if( cs_get_user_team( id ) == cs_get_user_team( iPlayer ) )
					{
						switch( cs_get_user_team( id ) )
						{
							case CS_TEAM_T:		ColorChat( iPlayer, RED, "^1%s(Terrorist)~^3[^4 Level %d^3 ]^1~^3 %s^4:^1 %s",is_user_alive( id ) ? "" : "*DEAD*", Level[id], szName, szChat );
							case CS_TEAM_CT:	ColorChat( iPlayer, BLUE, "^1%s(Counter-Terrorist)~^3[^4 Level %d^3 ]^1~^3 %s^4:^1 %s",is_user_alive( id ) ? "" : "*DEAD*", Level[id], szName, szChat );
							case CS_TEAM_SPECTATOR:	ColorChat( iPlayer, GREY, "^1%s(Spectator)~^3[^4 Level %d^3 ]^1~^3 %s^4:^1 %s", Level[id], szName, szChat );
						}
					}
				}
				break;
		}
	
	return PLUGIN_HANDLED_MAIN;
}


public player_spawn(id) {
   if(!is_user_alive(id) || is_user_bot(id))
      return HAM_HANDLED
   
   if(Level[id] < 1)
      Level[id] = 1

   set_user_health(id,get_user_health(id) + get_pcvar_num(pcvar_hp_lvl) * Level[id])
   set_user_armor(id,get_user_armor(id) + get_pcvar_num(pcvar_ap_lvl) * Level[id])
   return HAM_HANDLED
}

public ev_msg( ) {
   static kiler;    kiler = read_data(1)
   static hs;       hs = read_data(3)
   
   if(kiler == read_data(2) || !is_user_alive(kiler))
      return

   if(hs)
      Kill[kiler]+= get_pcvar_num(pcvar_hs)
   else
      Kill[kiler]+= get_pcvar_num(pcvar_kill)
   
   if(get_user_weapon(kiler) == CSW_KNIFE && !hs)
      Kill[kiler]+= get_pcvar_num(pcvar_knife)
   if(get_user_weapon(kiler) == CSW_HEGRENADE && !hs)
      Kill[kiler]+= get_pcvar_num(pcvar_he)

   if(Level[kiler] < MAX_LEVELS)
   {
      while(Kill[kiler] >= Kills[Level[kiler]])
      {
         Level[kiler]++
         color(kiler,"!teamFelicitari,ai ajuns la level %i (!g%s!team).",Level[kiler],szTag[Level[kiler]])
         screen_fade(kiler, get_pcvar_num(pcvar_efect), get_pcvar_num(pcvar_r), get_pcvar_num(pcvar_g), get_pcvar_num(pcvar_b), 115)
         return
      }
   }
   SaveData(kiler)
}

public client_putinserver(id) {
   if(!is_user_bot(id))
   {
      LoadData(id)
      set_task(1.0,"show_hud",id+0x4332,_,_,"b")
   }
}

public client_disconnect(id) {
   remove_task(id+0x4332)
   SaveData(id)
}

public show_hud(id) {
   id-=0x4332
   get_user_name(id,szName,charsmax(szName))

	new x[10]
	if(Level[id]<MAX_LEVELS)
	{
		format(x,charsmax(x),"%d",Levels[Level[id]+1])
	}
	else	formatex(x,charsmax(x),"MAXIM")

   if(is_user_alive(id))
   {
      set_hudmessage(85, 255, 42, -1.0, 0.78, 0, 6.0, 1.1)
      ShowSyncHudMsg(id,g_sync,"Level: [ %i --> %s ]^nRank: ~~ %s ~~^nXP: [ %i --> %i ]",Level[id],x,szTag[Level[id]],Kill[id],Kills[Level[id]])
   }
}

public SaveData(id)
{
   new name[32],vaultkey[64],vaultdata[256]
   get_user_name(id,name,charsmax(name))
   formatex(vaultkey,63,"%s-Mod",name)
   formatex(vaultdata,255,"%i#%i#",Kill[id],Level[id])
   nvault_set(g_vault,vaultkey,vaultdata)
}

public LoadData(id)
{
   new name[32],vaultkey[64],vaultdata[256]
   get_user_name(id,name,charsmax(name))
   formatex(vaultkey,63,"%s-Mod",name)
   formatex(vaultdata,255,"%i#%i#",Kill[id],Level[id])
   nvault_get(g_vault,vaultkey,vaultdata,255)
   replace_all(vaultdata, 255, "#", " ")

   new kill[32],level[32]
   parse(vaultdata, kill, 31, level, 31)
   Kill[id] = str_to_num(kill)
   Level[id] = str_to_num(level)
}
public plugin_end() nvault_close(g_vault)
stock screen_fade(id,holdtime,r,g,b,a)
{
   message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("ScreenFade"),{ 0, 0, 0 },id);
   write_short(seconds_to_units(holdtime));
   write_short(seconds_to_units(holdtime));
   write_short(0);
   write_byte(r);
   write_byte(g);
   write_byte(b);
   write_byte(a);
   message_end();
}

stock seconds_to_units(time)
{
   return((1 << 12) * (time))
}

stock color( const id, const input[ ], any:... )
{
   new count = 1, players[ 32 ]

   static msg[ 191 ]
   vformat( msg, 190, input, 3 )

   replace_all( msg, 190, "!g", "^4" ) //- verde
   replace_all( msg, 190, "!y", "^1" ) //- galben
   replace_all( msg, 190, "!team", "^3" ) //- echipa
   replace_all( msg, 190, "!n", "^0" ) //- normal

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
