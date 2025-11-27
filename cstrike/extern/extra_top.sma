// NVAULT FIX + UTILs - https://forums.alliedmods.net/showpost.php?p=2592019&postcount=1
// NEW GEOIP(AMXX<=182) - https://forums.alliedmods.net/showpost.php?p=857215&postcount=1

#include <amxmodx>
#include <nvault>
#include <nvault_util>
#include <nvault_array>
#include <geoip>

#pragma tabsize 0

//Allocate additional memory to plugin to prevent stack error
#pragma dynamic 16384

static const	Version[] = "0.1",

		VaultName[] = "Top_Example",

//This determines the max number of players that will be included in your top 15 calculation. It is best to keep this at a 
//value <= the max players that you expect to have data saved in the vault. If the number of player data saved exceeds this
//value then your top 15 will not be accurate since some players will be left out.
		Max_Player_Support = 3000,

		Top_Dsiplay_Num = 10

//#define COUNTRY_2CODE_TO_LOW

enum
{
    STATS_KILLS = 0,
    STATS_DEATHS,
    STATS_HEADSHOTS,
    STATS_TEAMKILLS,
    STATS_SHOTS,
    STATS_HITS,
    STATS_DAMAGE,
    STATS_RANK,
    STATS_MAX_STATS //=8
}

//Components of data that will be saved for each player.
enum _:PlayerData
{
    PlayerName[ 33 ],
    Country[3],
    IsSteamer,
    Kills,
    Deaths,
    Hs,
    Float:Acc,
    Float:Eff
}

new pdData[ MAX_PLAYERS + 1 ][ PlayerData ];
new g_AuthID[ MAX_PLAYERS + 1 ][ 33 ];
new bool:g_BotOrHLTV[ MAX_PLAYERS + 1 ];
new g_Vault;

//In your plugin, you set a players XP using the below:
//pdData[ id ][ XP ] = 12345;
    
public plugin_init() 
{
    register_plugin( "nVault Top" , Version , "bugsy" );
    
    register_clcmd( "say /top" , "ShowTop" );
    register_clcmd( "say_team /top" , "ShowTop" );
    
    if ( ( g_Vault = nvault_open( VaultName ) ) == INVALID_HANDLE )
    {
        set_fail_state( "Failed to open vault" );
    }
}

public plugin_end() 
{
    nvault_close( g_Vault );
}

public client_authorized( id )
{
    if ( !( g_BotOrHLTV[ id ] = bool:( is_user_bot( id ) || is_user_hltv( id ) ) ) )
    {
        //Get players' name so it can be used to retrieve their data from the vault.
        get_user_name( id , g_AuthID[ id ] , charsmax( g_AuthID[] ) );
        
        //Retrieve player data from vault. 
        nvault_get_array( g_Vault , g_AuthID[ id ] , pdData[ id ][ PlayerData:0 ] , sizeof( pdData[] ) );
    }
}

public client_disconnect( id )
{
    if ( !g_BotOrHLTV[ id ] )
    {
        //To avoid having to monitor for name changes in-game, the players name is retrieved and saved when disconnecting.
        get_user_name( id , pdData[ id ][ PlayerName ] , charsmax( pdData[][ PlayerName ] ) );
        
        //Save player data to vault.
	new ip[35];get_user_ip(id,ip,charsmax(ip),1)
	#if AMXX_VERSION_NUM < 183
	geoip_code2(ip,pdData[id][Country])
	#else
	geoip_code2_ex(ip,pdData[id][Country])
	#endif

	#if defined COUNTRY_2CODE_TO_LOW
	strtolower(pdData[id][Country])
	#endif

	pdData[id][IsSteamer]=str_to_num(is_user_steam(id))

	new izStats[8],izBody[8]
	get_user_stats( id, izStats, izBody )
	pdData[id][Kills]=get_user_frags(id)//izStats[STATS_KILLS]
	pdData[id][Deaths]=get_user_deaths(id)//izStats[STATS_DEATHS]
	pdData[id][Hs]=izStats[STATS_HEADSHOTS]
	pdData[id][Acc]=accuracy(izStats)
	pdData[id][Eff]=effect(izStats)

        nvault_set_array( g_Vault , g_AuthID[ id ] , pdData[ id ][ PlayerData:0 ] , sizeof( pdData[] ) );
    }
}

public ShowTop( id )
{
    enum _:TopInfo
    {
        nVault_Offset,
	nVault_Country[3],
	nVault_IsSteamer,
	nVault_Kills,
	nVault_Deaths,
	nVault_Hs,
	nVault_Float:Acc,
	nVault_Float:Eff
    }
    
    static iSortData[ Max_Player_Support ][ TopInfo ];
    
    new iVault , iRow , iCount , iNextOffset , iCurrentOffset , szKey[ 45 ] , iAvailablePlayers , pdVal[ PlayerData ];
    new szMOTD[ 2048 ] , iPos;
    
    //Close and re-open vault so the journal writes to the vault so nvault_util gets most up to date data.
    nvault_close( g_Vault );
    g_Vault = nvault_open( VaultName );
    
    //Open vault for nvault utility usage.
    iVault = nvault_util_open( VaultName );
    
    //Get count of total number of records in the vault.
    iCount = nvault_util_count( iVault );
    
    //Loop through all records in the vault.
    for ( iRow = 0 ; iRow < iCount && iRow < Max_Player_Support ; iRow++ )
    {
        //Read record from vault. iNextOffset will hold the position of the next record in the vault.
        iNextOffset = nvault_util_read_array( iVault , iNextOffset , szKey , charsmax( szKey ) , pdVal[ PlayerData:0 ] , sizeof( pdVal ) );
        
        //Set nVault_Offset to the byte offset for this players data. This will allow for retrieving any data for this player that needs to appear in the top 15 (name, steam id, etc.)
        //iPrevOffset is used since iOffset holds the position of the NEXT record, not current.
        iSortData[ iRow ][ nVault_Offset ] = iCurrentOffset;
        
        //Set value in array to his value. This will be used for sorting.
        copy(iSortData[ iRow ][ nVault_Country ],charsmax(iSortData[  ][ nVault_Country ]),pdVal[ Country ])
	iSortData[ iRow ][ nVault_IsSteamer ]=pdVal[ IsSteamer ]
	iSortData[ iRow ][ nVault_Kills ]=pdVal[ Kills ]
	iSortData[ iRow ][ nVault_Deaths ]=pdVal[ Deaths ]
	iSortData[ iRow ][ nVault_Hs ]=pdVal[ Hs ]
	iSortData[ iRow ][ nVault_Acc ]=pdVal[ Acc ]
	iSortData[ iRow ][ nVault_Eff ]=pdVal[ Eff ]
        
        //Since nvault_util_read_array() holds the position of the next record, we have to hold the current offset separately.
        iCurrentOffset = iNextOffset;
    }
    
    //Sort the array.
    SortCustom2D( iSortData , min( iCount , Max_Player_Support ) , "CompareXP" );

    //Prepare top MOTD.
    iPos = formatex( szMOTD , charsmax( szMOTD ) , "<meta charset=UTF-8><link href=^"http://home.omonas.lt/p/p.css^" rel=stylesheet><h2>Top players</h2>" );
    iPos += formatex( szMOTD[ iPos ] , charsmax( szMOTD ) - iPos , "<tr><th>#<th><th>Player<th><th>Kills<th>Deaths<th>Hs<th>acc.<th>eff.^n" );
    
    //This will account for if the vault has less than Top_Dsiplay_Num player data records stored.
    iAvailablePlayers = min( iCount , Top_Dsiplay_Num );
    
    //Build the top 15. iAvailablePlayers is set to the smaller of 15 or the total records in the vault.
    for ( iRow = 0 ; iRow < iAvailablePlayers ; iRow++ )
    {
        //Get nVault player data offset value which was set in the above loop.
        iCurrentOffset = iSortData[ iRow ][ nVault_Offset ];
        
        //Read data at the players offset so we can retrieve their name to be displayed in the top 15.
        nvault_util_read_array( iVault , iCurrentOffset , szKey , charsmax( szKey ) , pdVal[ PlayerData:0 ] , sizeof( pdVal ) );
        
        //Format line in MOTD.
        iPos += formatex( szMOTD[ iPos ] , charsmax( szMOTD ) - iPos ,"<td>%2d<td id=%s><td> %-22.22s<td id=%s><td> %3d<td> %d<td> %d<td> %.1f%%<td> %1.f%%^n", ( iRow + 1 ),pdVal[ Country ],
	pdVal[ PlayerName ],pdVal[ IsSteamer ]?"b":"a",pdVal[ Kills ],pdVal[ Deaths ],pdVal[ Hs ],pdVal[ Acc ],pdVal[ Eff ] );
    }
    
    //Close nvault utility file.
    nvault_util_close( iVault );
    
    //formatex( szMOTD[ iPos ], charsmax( szMOTD ) - iPos , "</body></font></pre>" );
    
    show_motd( id , szMOTD , "Top Players" );
    
    return PLUGIN_HANDLED;
}

public CompareXP( elem1[] , elem2[] ) 
{ 
    if ( elem1[ 1 ] > elem2[ 1 ] ) 
        return -1; 
    else if(elem1[ 1 ] < elem2[ 1 ] ) 
        return 1; 
    
    return 0; 
} 

stock bool:is_user_steam(id)
{
    static dp_pointer
    if(dp_pointer || (dp_pointer = get_cvar_pointer("dp_r_id_provider")))
    {
        server_cmd("dp_clientinfo %d", id)
        server_exec()
        return (get_pcvar_num(dp_pointer) == 2) ? true : false
    }
    return false
}

// Stats formulas
Float:accuracy(izStats[STATS_MAX_STATS])
{
	if (!izStats[STATS_SHOTS])
		return (0.0)
	
	return (100.0 * float(izStats[STATS_HITS]) / float(izStats[STATS_SHOTS]))
}

Float:effect(izStats[STATS_MAX_STATS])
{
	if (!izStats[STATS_KILLS])
		return (0.0)
	
	return (100.0 * float(izStats[STATS_KILLS]) / float(izStats[STATS_KILLS] + izStats[STATS_DEATHS]))
}
