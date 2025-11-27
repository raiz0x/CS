/*
	Template by Exolent from http://forums.alliedmods.net/showpost.p ... stcount=15
	Requires small modification (if not already done in the post):
	
	while( ( cChar = szMessage[ iPos ] ) == '@' )  
	{  
		i++; 
		iPos++; 
	}  
*/

#include < amxmodx >
#include < amxmisc >
#include < cstrike >

new g_iMsgID_SayText;

new g_iAdminChatFlag = ADMIN_ALL;

new g_szTags[5][10];
new Trie:g_tSteamTagIndex;
new g_iPlayerTag[33]

public plugin_init( )
{
	register_plugin("pepe_thugs Chat Tags", "0.2", "Fysiks")
	register_clcmd( "say", "CmdSay" );
	register_clcmd( "say_team", "CmdSayTeam" );
	
	g_iMsgID_SayText = get_user_msgid( "SayText" );
	
	new szCommand[ 32 ], iFlags;
	for( new i = 0; get_concmd( i, szCommand, charsmax( szCommand ), iFlags, "", 0, 0, -1 ); i++ )
	{
		if( equal( szCommand, "amx_chat" ) )
		{
			g_iAdminChatFlag = iFlags;
			break;
		}
	}
	
	g_tSteamTagIndex = TrieCreate();
	loadTags();
}

public client_connect(id)
{
	g_iPlayerTag[id] = 0;
}

public client_authorized(id)
{
	new szSteamID[32];
	get_user_authid(id, szSteamID, charsmax(szSteamID));
	TrieGetCell(g_tSteamTagIndex, szSteamID, g_iPlayerTag[id] )
}

public CmdSay( iPlayer )
{
	if( !g_iPlayerTag[iPlayer] )
	{
		return PLUGIN_CONTINUE;
	}

	if( !is_user_connected( iPlayer ) )
	{
		return PLUGIN_HANDLED_MAIN;
	}
	
	new szArgs[ 194 ];
	
	if( !IsValidMessage( iPlayer, false, szArgs, charsmax( szArgs ) ) )
	{
		return PLUGIN_HANDLED_MAIN;
	}
	
	new iAlive = is_user_alive( iPlayer );
	new CsTeams:iTeam = cs_get_user_team( iPlayer );
	
	new iPlayers[ 32 ], iNum;
	get_players( iPlayers, iNum );
	
	new szName[ 32 ];
	get_user_name( iPlayer, szName, charsmax( szName ) );
	
	new const szPrefixes[ 2 ][ CsTeams ][ ] =
	{
		{
			"^1*DEAD* ",
			"^1*DEAD* ",
			"^1*DEAD* ",
			"^1*SPEC* "
		},
		{
			"",
			"",
			"",
			""
		}
	};
	
	new szMessage[ 192 ];
	formatex( szMessage, charsmax( szMessage ), "^4%s ^1%s^3%s^1 :  %s", g_szTags[g_iPlayerTag[iPlayer]], szPrefixes[ iAlive ][ iTeam ], szName, szArgs );
	
	new iTarget;
	for( new i = 0; i < iNum; i++ )
	{
		iTarget = iPlayers[ i ];
		
		if( iTarget == iPlayer || ( iAlive || is_user_connected( iTarget ) ) && is_user_alive( iTarget ) == iAlive )
		{
			message_begin( MSG_ONE_UNRELIABLE, g_iMsgID_SayText, _, iTarget );
			write_byte( iPlayer );
			write_string( szMessage );
			message_end( );
		}
	}
	
	return PLUGIN_HANDLED_MAIN;
}

public CmdSayTeam( iPlayer )
{
	if( !g_iPlayerTag[iPlayer] )
	{
		return PLUGIN_CONTINUE;
	}

	if( !is_user_connected( iPlayer ) )
	{
		return PLUGIN_HANDLED_MAIN;
	}
	
	new szArgs[ 194 ];
	
	if( !IsValidMessage( iPlayer, true, szArgs, charsmax( szArgs ) ) )
	{
		return PLUGIN_HANDLED_MAIN;
	}
	
	new iAlive = is_user_alive( iPlayer );
	new CsTeams:iTeam = CsTeams:( ( _:cs_get_user_team( iPlayer ) ) % 3 );
	
	new iPlayers[ 32 ], iNum;
	get_players( iPlayers, iNum );
	
	new szName[ 32 ];
	get_user_name( iPlayer, szName, charsmax( szName ) );
	
	new const szPrefixes[ 2 ][ CsTeams ][ ] =
	{
		{
			"(Spectator)",
			"*DEAD*(Terrorist)",
			"*DEAD*(Counter-Terrorist)",
			""
		},
		{
			"(Spectator)",
			"(Terrorist)",
			"(Counter-Terrorist)",
			""
		}
	};
	
	new szMessage[ 192 ];
	formatex( szMessage, charsmax( szMessage ), "^4%s ^1%s^3 %s^1 :  %s", g_szTags[g_iPlayerTag[iPlayer]], szPrefixes[ iAlive ][ iTeam ], szName, szArgs );
	
	for( new i = 0, iTeammate; i < iNum; i++ )
	{
		iTeammate = iPlayers[ i ];
		
		if( iTeammate == iPlayer || ( iAlive || is_user_connected( iTeammate ) ) && is_user_alive( iTeammate ) == iAlive && CsTeams:( ( _:cs_get_user_team( iTeammate ) ) % 3 ) == iTeam )
		{
			message_begin( MSG_ONE_UNRELIABLE, g_iMsgID_SayText, _, iTeammate );
			write_byte( iPlayer );
			write_string( szMessage );
			message_end( );
		}
	}
	
	return PLUGIN_HANDLED_MAIN;
}

bool:IsValidMessage( iPlayer, bool:bTeamSay, szMessage[ ], iLen )
{
	read_args( szMessage, iLen );
	remove_quotes( szMessage );

	if( !szMessage[ 0 ] )
	{
		return false;
	}
	
	new iPos, cChar, i;
	while( ( cChar = szMessage[ iPos ] ) == '@' )
	{
		i++;
		iPos++;
	}

	if( i > 0 )
	{
		return ( !( bTeamSay ? ( i == 1 ) : ( 1 <= i <= 3 ) ) || !access( iPlayer, g_iAdminChatFlag ) );
	}

	while( 0 < ( cChar = szMessage[ iPos++ ] ) <= 255 )
	{
		if( cChar != ' ' && cChar != '%' )
		{
			return true;
		}
	}

	return false;
}

loadTags()
{
	// load tags from file
	new szFilePath[128];
	get_configsdir(szFilePath, charsmax(szFilePath));
	add(szFilePath, charsmax(szFilePath), "/tags.ini");
	
	new f = fopen(szFilePath, "rt");
	
	if( !f )
	{
		new szMessage[128];
		formatex(szMessage, charsmax(szMessage), "Unable to open %s", szFilePath);
		set_fail_state(szMessage);
	}
	
	new data[32], iTagCount;
	while( !feof(f) )
	{
		fgets(f, data, charsmax(data))
		
		trim(data);
		if( !data[0] || data[0] == ';' || data[0] == '/' && data[1] == '/' ) continue;
		
		if( data[0] == '[' )
		{
			iTagCount++
			copy(g_szTags[iTagCount], charsmax(g_szTags[]), data)
		}
		else
		{
			TrieSetCell(g_tSteamTagIndex, data, iTagCount)
		}
	}
	fclose(f)
}
