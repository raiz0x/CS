/* AMX Mod X
*   Anti Flood Plugin Edited
*
* by the AMX Mod X Development Team +
*  originally developed by OLO
*
* This file is part of AMX Mod X.
*
*
*  This program is free software; you can redistribute it and/or modify it
*  under the terms of the GNU General Public License as published by the
*  Free Software Foundation; either version 2 of the License, or (at
*  your option) any later version.
*
*  This program is distributed in the hope that it will be useful, but
*  WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
*  General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software Foundation,
*  Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*
*  In addition, as a special exception, the author gives permission to
*  link the code of this program with the Half-Life Game Engine ("HL
*  Engine") and Modified Game Libraries ("MODs") developed by Valve,
*  L.L.C ("Valve"). You must obey the GNU General Public License in all
*  respects for all of the code used other than the HL Engine and MODs
*  from Valve. If you modify this file, you may extend this exception
*  to your version of the file, but you are not obligated to do so. If
*  you do not wish to do so, delete this exception statement from your
*  version.
*/

#include <amxmodx>

new Float:g_Flooding[33] = {0.0, ...}
new g_Flood[33] = {0, ...}

new Float:g_nextNameChange[32],nc[32] = {0, ...}

public plugin_init() {
	register_plugin("Anti Flood",AMXX_VERSION_STR,"AMXX Dev Team+")
	
	register_dictionary("antiflood.txt")
	
	register_clcmd("say","chkFlood")
	register_clcmd("say_team","chkFlood")
	
	register_cvar("amx_flood_time","0.90")//secunde+
	register_cvar("amx_flood_time_resay","3.0")
	
	register_cvar("amx_namechange_time", "10.0")
	register_cvar("amx_namechenge_map", "3")//times-
	
	register_message(get_user_msgid("SayText"), "message_SayText")
}

public client_disconnect(id)	nc[id-1]=0

public message_SayText() {
	if (get_msg_args() != 4)	return PLUGIN_CONTINUE
	
	new buffer[32]
	get_msg_arg_string(2, buffer, 31)
	if (!equal(buffer, "#Cstrike_Name_Change"))	return PLUGIN_CONTINUE
	
	new id = get_msg_arg_int(1), oldName[32], newName[32]
	get_msg_arg_string(3, oldName, 31)
	get_msg_arg_string(4, newName, 31)
	
	if(!equal(oldName, newName))
	{
		if(++nc[id-1]>=get_cvar_num("amx_namechenge_map"))
		{
			client_print(id,print_chat, " [AMXX]: You can't change youre nickname anymore.")
			
			set_user_info(id, "name", oldName)
			
			return PLUGIN_HANDLED
		}
		else
		{
			if (get_gametime() < g_nextNameChange[id - 1]) {
				g_nextNameChange[id - 1] = get_gametime() + get_cvar_float("amx_namechange_time")
				
				client_print(id,print_chat, " [AMXX]: Too fast nick changes. Wait %.1f second%s, now is %.1f..", g_nextNameChange[id - 1]-get_gametime(),g_nextNameChange[id - 1]-get_gametime()==1?"":"s",get_gametime())
				
				set_user_info(id, "name", oldName)
				
				return PLUGIN_HANDLED
			}
			
			//client_print(id,print_chat, " [AMXX]: Next name change for you is %f second%s, now is %f second%s", g_nextNameChange[id - 1],g_nextNameChange[id - 1]==1?"":"s", get_gametime(), get_gametime()==1?"":"s")
			//client_print(id,print_chat, " [AMXX]: Nick change times left: %d", get_cvar_num("amx_namechenge_map")-nc[id])
		}
	}
	
	g_nextNameChange[id - 1] = get_gametime() + get_cvar_float("amx_namechange_time")
	
	return PLUGIN_CONTINUE
}

public chkFlood(id) {
	new Float:maxChat = get_cvar_float("amx_flood_time")
	
	if ( maxChat ) {
		static Float:nexTime
		nexTime = get_gametime()
		
		if ( g_Flooding[id] > nexTime ) {
			if (g_Flood[id] >= 4) {
				//								       %i
				client_print(id,print_chat, " [AMXX]: Next posibility to write is after %.1f second%s", g_Flooding[ id ]-nexTime,g_Flooding[ id ]-nexTime==1?"":"s")
				
				g_Flooding[ id ] = nexTime + maxChat + get_cvar_float("amx_flood_time_resay")
				
				return PLUGIN_HANDLED
			}
			g_Flood[id]++
		}
		else	if (g_Flood[id])	g_Flood[id]--
		
		g_Flooding[id] = nexTime + maxChat
	}
	
	return PLUGIN_CONTINUE
}
