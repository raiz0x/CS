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
	wiki at: http://wiki.amxmodx.org/Half-Life_1_Engine_Messages#SVC_PINGS
	
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
