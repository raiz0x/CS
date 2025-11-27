#include <amxmodx>
#include <amxmisc>

new const g_Char[ ] = "/"

new g_Commands[ ][ ] =
{
	"/kick",
	"/slay",
	"/ban",
	"/banip",
	"/slap",
	"/vote",
	"/votemap",
	"/map",
	"/addban",
	"/unban",
	"/cvar",
	"/nick",
	"/voteban",
	"/votekick",
	"/ct",
	"/t",
	"/spec",
	"/rcon",
	"/cancelvote",
	"/mapmenu",
	"/votemapmenu",
	"/ss",
	"/gag",
	"/ungag",
	"/bancfg",
	"/unbancfg",
	"/bancfg_pmenu",
	"/kickmenu",
	"/banmenu",
	"/blind",
	"/unblind",
	"/record",
	"/stoprecord"
}

public plugin_init()
{
	register_clcmd( "say", "hook_sayX" )
	register_clcmd( "say_team", "hook_sayX" )
	register_clcmd( "say_team @", "hook_sayX" )
}

public hook_sayX( e_Index )
{
	static s_Args[ 192 ], s_Command[ 192 ]
	read_args( s_Args, charsmax( s_Args ) )

	if( !s_Args[ 0 ] )	return 1

	remove_quotes( s_Args[ 0 ] )

	for( new i; i < sizeof g_Commands; i++ )
	{
		if( equal( s_Args, g_Commands[ i ], strlen( g_Commands[ i ] ) ) )
		{
			if( get_user_flags( e_Index ) )
			{
				replace( s_Args, charsmax( s_Args ), g_Char, "" )
				formatex( s_Command, charsmax ( s_Command ),"amx_%s", s_Args )
				client_cmd( e_Index, s_Command )

				return PLUGIN_HANDLED
			}
			/*else // if( !get_user_flags( e_Index ) )
			{
				chat_color( e_Index, "!g>!n AMXX|  Nu ai acces la aceasta!t Comanda!n." )
			}*/
			break
		}
	}

	return PLUGIN_CONTINUE
}
