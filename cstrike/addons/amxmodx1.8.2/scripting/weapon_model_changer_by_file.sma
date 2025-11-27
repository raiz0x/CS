/*    Formatright © 2012, ConnorMcLeod

    Weapons Models is free software;
    you can redistribute it and/or modify it under the terms of the
    GNU General Public License as published by the Free Software Foundation.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Weapons Models; if not, write to the
    Free Software Foundation, Inc., 59 Temple Place - Suite 330,
    Boston, MA 02111-1307, USA.
*/

#define VERSION "0.2.3"

/* ChangeLog
 *
 * v 0.2.3
 * - Added shield support
 * - Fixed missing p_ models support that were causing crashes
 * - Added pdata check on player on weapon deploy event
 * 
 * v0.2.2
 * - Fixed bad formating that was preventing default models from being detected
 * 
 * v0.2.1
 * - Fixed "Invalid trie handle provided" error
 * 
 * v0.2.0
 * - Check viewmodel and weaponmodel instead of weapon type, so it now supports shield models
 * 
 * v0.1.7
 * - Adjustments
 * 
 * v0.1.6
 * - Remove FreeEntPrivateData, was causing player from not being reconnected to server
 * 
 * v0.1.5
 * - Don't need to precache backpack model anymore
 * 
 * v0.1.4
 * - Store allocated view and weapon models in arrays instead of Trie
 * - Fixed w_backpack.mdl was not precached (bad string name was passed...)
 * 
 * v0.1.3
 * - Store precache returns values into a trie instead of checking trie and resend precache
 * - Only store world new models strings in a trie
 *
 * v0.1.2
 * - Moved  backpack model precache from precache hook to plugin_precache
 * 
 * v0.1.1
 * - Fixed first map where weapons were not registering
 * 
 * v0.1.0
 * - Hook Ham_Item_Deploy and set models there instead of hooking FM_ModelIndex that was intensive
 * 
 * v0.0.1 First Shot 
 */

// #define DONT_BLOCK_PRECACHE

#include <amxmodx>
#include <fakemeta_stocks>
#include <hamsandwich>

#pragma semicolon 1

const MAX_MODEL_LENGTH = 64;

new const m_rgpPlayerItems_CBasePlayer[6] = {367, 368, ...};
const m_pActiveItem = 373;

const XO_WEAPON = 4;
const m_pPlayer = 41;

new Trie:g_tszWorldModels; // handles new models strings (all excepted v_ and w_ models)
new Trie:g_tiPrecacheReturns; // handles all new models precache returns integers
new Trie:g_tiszViewModels;
new Trie:g_tiszWeaponModels;

public plugin_precache()
{
	new szModelsFile[128];
	get_localinfo("amxx_configsdir", szModelsFile, charsmax(szModelsFile));
	add(szModelsFile, charsmax(szModelsFile), "/weapons_models.ini");

	new iFile = fopen(szModelsFile, "rt");
	if(!iFile)
	{
		return;
	}

	new szDatas[192], szOldModel[MAX_MODEL_LENGTH], szNewModel[MAX_MODEL_LENGTH];
	new szWeaponClass[32], Trie:tRegisterWeaponDeploy = TrieCreate(), iId;

	new Trie:tWeaponsIds = TrieCreate();
	TrieSetCell(tWeaponsIds, "p228", CSW_P228);
	TrieSetCell(tWeaponsIds, "scout", CSW_SCOUT);
	TrieSetCell(tWeaponsIds, "hegrenade", CSW_HEGRENADE);
	TrieSetCell(tWeaponsIds, "xm1014", CSW_XM1014);
	TrieSetCell(tWeaponsIds, "c4", CSW_C4);
	TrieSetCell(tWeaponsIds, "mac10", CSW_MAC10);
	TrieSetCell(tWeaponsIds, "aug", CSW_AUG);
	TrieSetCell(tWeaponsIds, "smokegrenade", CSW_SMOKEGRENADE);
	TrieSetCell(tWeaponsIds, "elite", CSW_ELITE);
	TrieSetCell(tWeaponsIds, "fiveseven", CSW_FIVESEVEN);
	TrieSetCell(tWeaponsIds, "ump45", CSW_UMP45);
	TrieSetCell(tWeaponsIds, "sg550", CSW_SG550);
	TrieSetCell(tWeaponsIds, "galil", CSW_GALIL);
	TrieSetCell(tWeaponsIds, "famas", CSW_FAMAS);
	TrieSetCell(tWeaponsIds, "usp", CSW_USP);
	TrieSetCell(tWeaponsIds, "glock18", CSW_GLOCK18);
	TrieSetCell(tWeaponsIds, "awp", CSW_AWP);
	TrieSetCell(tWeaponsIds, "mp5navy", CSW_MP5NAVY);
	TrieSetCell(tWeaponsIds, "m249", CSW_M249);
	TrieSetCell(tWeaponsIds, "m3", CSW_M3);
	TrieSetCell(tWeaponsIds, "m4a1", CSW_M4A1);
	TrieSetCell(tWeaponsIds, "tmp", CSW_TMP);
	TrieSetCell(tWeaponsIds, "g3sg1", CSW_G3SG1);
	TrieSetCell(tWeaponsIds, "flashbang", CSW_FLASHBANG);
	TrieSetCell(tWeaponsIds, "deagle", CSW_DEAGLE);
	TrieSetCell(tWeaponsIds, "sg552", CSW_SG552);
	TrieSetCell(tWeaponsIds, "ak47", CSW_AK47);
	TrieSetCell(tWeaponsIds, "knife", CSW_KNIFE);
	TrieSetCell(tWeaponsIds, "p90", CSW_P90);

	new c, bool:bServerDeactivateRegistered, iExtPos, bShieldModel;
	while(!feof(iFile))
	{
		fgets(iFile, szDatas, charsmax(szDatas));
		trim(szDatas);
		if(!(c=szDatas[0]) || c == ';' || c == '#' || (c == '/' && szDatas[1] == '/'))
		{
			continue;
		}

		if(		parse(szDatas, szOldModel, charsmax(szOldModel), szNewModel, charsmax(szNewModel)) == 2
		&&	file_exists(szNewModel)	)
		{
			// models/[p/v]_
			// models/shield/[p/v]_shield_
			bShieldModel = equal(szOldModel, "models/shield/", 14);
			if( ( (c=szOldModel[bShieldModel ? 14 : 7]) == 'p' || c == 'v' ) && szOldModel[bShieldModel ? 15 : 8] == '_' )
			{
				if( equal(szOldModel[9], "mp5", 3 ) )
				{
					copy(szWeaponClass, charsmax(szWeaponClass), "weapon_mp5navy");
				}
				else
				{
					iExtPos = strlen(szOldModel) - 4;
					szOldModel[ iExtPos ] = EOS;
					formatex(szWeaponClass, charsmax(szWeaponClass), "weapon_%s", szOldModel[bShieldModel ? 23 : 9]);
					szOldModel[ iExtPos ] = '.';
				}
				
				if( !TrieGetCell(tWeaponsIds, szWeaponClass[7], iId) )
				{
					continue;
				}

				if( c == 'v' )
				{
					if( !g_tiszViewModels )
					{
						g_tiszViewModels = TrieCreate();
					}

					TrieSetCell(g_tiszViewModels, szOldModel, EF_AllocString( szNewModel ) );
				}
				else
				{
					if( !g_tiszWeaponModels )
					{
						g_tiszWeaponModels = TrieCreate();
					}
					
					TrieSetCell(g_tiszWeaponModels, szOldModel, EF_AllocString( szNewModel ) );
				}
				
				if( !TrieKeyExists(tRegisterWeaponDeploy, szWeaponClass) )
				{
					TrieSetCell
					(
						tRegisterWeaponDeploy,
						szWeaponClass,
						RegisterHam(Ham_Item_Deploy, szWeaponClass, "OnCBasePlayerWeapon_Deploy_P", true)
					);
				}
			}
			else
			{
				if( !bServerDeactivateRegistered && equal(szOldModel, "models/w_backpack.mdl") )
				{
					bServerDeactivateRegistered = true;
					register_forward(FM_ServerDeactivate, "OnServerDeactivate");
				}

				if( !g_tszWorldModels )
				{
					g_tszWorldModels = TrieCreate();
				}
				else if( TrieKeyExists(g_tszWorldModels, szOldModel) )
				{
					new szModel[MAX_MODEL_LENGTH];
					TrieGetString(g_tszWorldModels, szOldModel, szModel, charsmax(szModel));
					log_amx("%s world model is already set to %s, can't set it to %s !!", szWeaponClass, szModel, szNewModel);
					continue;
				}
				TrieSetString(g_tszWorldModels, szOldModel, szNewModel);
			}

			if( !g_tiPrecacheReturns )
			{
				g_tiPrecacheReturns = TrieCreate();
			}
			TrieSetCell(g_tiPrecacheReturns, szOldModel, EF_PrecacheModel(szNewModel));
#if defined DONT_BLOCK_PRECACHE
			EF_PrecacheModel(szOldModel);
#endif
		}
	}
	fclose(iFile);

	TrieDestroy(tRegisterWeaponDeploy);
	TrieDestroy(tWeaponsIds);

	if( g_tiPrecacheReturns )
	{
		register_forward(FM_PrecacheModel, "OnPrecacheModel");

		if( g_tszWorldModels )
		{
			register_forward(FM_SetModel, "OnSetModel");
		}
	}
}

public plugin_init()
{
	register_plugin("Weapons Models", VERSION, "ConnorMcLeod");
}

public OnServerDeactivate()
{
	static bool:bDontPassThisTwice = false;
	if( bDontPassThisTwice ) // unregister this would be waste of time
	{
		return;
	}
	bDontPassThisTwice = true;

	new id, c4 = FM_NULLENT;
	while( (c4 = EF_FindEntityByString(c4, "classname", "weapon_c4")) > 0 )
	{
		id = get_pdata_cbase(c4, m_pPlayer);
		if( id > 0 )
		{
			// can't use set_pdata_cbase on players at this point
			set_pdata_int(id, m_rgpPlayerItems_CBasePlayer[5], 0);
			set_pdata_int(id, m_pActiveItem, 0);
			// tried to remove c4 entity but server just stucks
		}
	}
}

public OnPrecacheModel(const szModel[])
{
	static iReturn;
	if( TrieGetCell(g_tiPrecacheReturns, szModel, iReturn) )
	{
		forward_return(FMV_CELL, iReturn);
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public OnCBasePlayerWeapon_Deploy_P( iWeapon )
{
	new id = get_pdata_cbase(iWeapon, m_pPlayer, XO_WEAPON);
	if( pev_valid(id) == 2 && get_pdata_cbase(id, m_pActiveItem) == iWeapon )
	{
		new iszNewModel, szOldModel[MAX_MODEL_LENGTH];
		if( g_tiszViewModels )
		{
			pev(id, pev_viewmodel2, szOldModel, charsmax(szOldModel));
			if( TrieGetCell(g_tiszViewModels, szOldModel, iszNewModel) )
			{
				set_pev(id, pev_viewmodel, iszNewModel);
			}
		}
		if( g_tiszWeaponModels )
		{
			pev(id, pev_weaponmodel2, szOldModel, charsmax(szOldModel));
			if( TrieGetCell(g_tiszWeaponModels, szOldModel, iszNewModel) )
			{
				set_pev(id, pev_weaponmodel, iszNewModel);
			}
		}
	}
}

public OnSetModel(const iEnt, const szModel[])
{
	new szNewModel[MAX_MODEL_LENGTH];
	if( TrieGetString(g_tszWorldModels, szModel, szNewModel, charsmax(szNewModel)) )
	{
		EF_SetModel(iEnt, szNewModel);
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}
