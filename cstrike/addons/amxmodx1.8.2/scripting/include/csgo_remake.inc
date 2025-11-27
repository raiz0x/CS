#if defined _csgo_remake_included
	#endinput
#endif

#define _csgo_remake_included

//#pragma reqlib csgo_remake

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib csgo_remake
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib csgo_remake
	#endif
#else
	#pragma library csgo_remake
#endif

/**
 * Returns a player's points.
 *
 * @param id		Player index.
 * @return			Amount of points. -1 on error.
 */
native csgor_get_user_points(id);

/**
 * Sets a player's points to the desired amount.
 *
 * @param id		Player index.
 * @param amount	A valid amount of points.
 * @return			True on success, false otherwise.
 */
native csgor_set_user_points(id, amount);

/**
 * Returns a player's dusts.
 *
 * @param id		Player index.
 * @return			Amount of dusts. -1 on error.
 */
native csgor_get_user_dusts(id);

/**
 * Sets a player's dusts to the desired amount.
 *
 * @param id		Player index.
 * @param amount	A valid amount of dusts.
 * @return			True on success, false otherwise.
 */
native csgor_set_user_dusts(id, amount);

/**
 * Returns a player's keys.
 *
 * @param id		Player index.
 * @return			Amount of keys. -1 on error.
 */
native csgor_get_user_keys(id);

/**
 * Sets a player's keys to the desired amount.
 *
 * @param id		Player index.
 * @param amount	A valid amount of keys.
 * @return			True on success, false otherwise.
 */
native csgor_set_user_keys(id, amount);

/**
 * Returns a player's cases.
 *
 * @param id		Player index.
 * @return			Amount of cases. -1 on error.
 */
native csgor_get_user_cases(id);

/**
 * Sets a player's cases to the desired amount.
 *
 * @param id		Player index.
 * @param amount	A valid amount of cases.
 * @return			True on success, false otherwise.
 */
native csgor_set_user_cases(id, amount);

/**
 * Returns a player's Rang ID. Set Rang name in output.
 *
 * @param id		Player index.
 * @param output	Output array for rang name.
 * @param len		Max length of a output array.
 * @return			Player Rang ID. -1 on error.
 */
native csgor_get_user_rang(id, output[], len);

/**
 * Sets a player's Rang ID. Set the appropriate amount of kills.
 *
 * @param id		Player index.
 * @param rangid	A valid Rang ID.
 * @return			True on success, false otherwise.
 */
native csgor_set_user_rang(id, rangid);

/**
 * Returns a player's amount of skins by specified Skin ID.
 *
 * @param id		Player index.
 * @param skinid	A valid Skin ID.
 * @return			Amount of skins. -1 on error.
 */
native csgor_get_user_skins(id, skinid);

/**
 * Sets a player's skins (by specific Skin ID) to desired amount.
 *
 * @param id		Player index.
 * @param skinid	A valid Skin ID.
 * @param amount	A valid amount of skins.
 * @return			True on success, false otherwise.
 */
native csgor_set_user_skins(id, skinid, amount);

/**
 * Returns whether a player is logged.
 *
 * @param id		Player index.
 * @return			True if it is, false otherwise.
 */
native csgor_is_user_logged(id);

/**
 * Called when a player log in account.
 *
 * @param id		Player index forwarding the event.
 */
forward csgor_user_log_in(id);

/**
 * Called when a player make assist.
 *
 * @param id			Assist index.
 * @param killer		Killer index.
 * @param victim		Victim index.
 * @param head			1 if HeadShot, 0 otherwise.
 */
forward csgor_user_assist(id, killer, victim, head);

/**
 * Called when a player is MVP.
 *
 * @param id			MVP index.
 * @param event			Event type. (0 - Top Killer, 1 - Planter, 2 - Defuser)
 * @param kills			Player's kills.
 */
forward csgor_user_mvp(id, event, kills);
