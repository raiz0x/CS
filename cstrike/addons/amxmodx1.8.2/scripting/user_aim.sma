register_event("StatusText", "status_display", "b")  // msg text/think

public status_display(id)
{
    new pi_target, p_body; 
    get_user_aiming(id, pi_target, p_body, 9999); 

    if(is_user_alive(pi_target) && get_pcvar_num(g_pcvar_toggle) == 1) 
    { 
        new sz_name[32], sz_message[64]; 
        get_user_name(pi_target, sz_name, 31);
        //new target = entity_get_int(id, EV_INT_iuser2);        

        if( cs_get_user_team(pi_target) == cs_get_user_team(id) ) 
            format(sz_message, 63, "Friend: %s | HP: %i | LVL: %i", sz_name, get_user_health(pi_target), PlayerLevel[pi_target]) 
        else  
            format(sz_message, 63, "Enemy: %s | LVL: %i", sz_name, PlayerLevel[pi_target]) 
        
        message_begin(MSG_ONE, get_user_msgid("StatusText"), {0, 0, 0}, id); 
        write_byte(0); 
        write_string(sz_message); 
        message_end();

        //set_hudmessage(200, 200, 200, 0.0, -1.0, 0, 3.2, 4.0, 0.3, 0.1, 1) // HUDMESSAGE_COLOR 
        //show_hudmessage(id, "%s", sz_message) 
    } 
    
    return PLUGIN_CONTINUE 
} 

register_message( get_user_msgid( "StatusValue" ), "msgStatusValue" );
public msgStatusValue( msgid, dest, id ) {
    new flag, value;
    flag = get_msg_arg_int( 1 );
    value = get_msg_arg_int( 2 );
    
    if( !value ) {
        return PLUGIN_CONTINUE;
    }
    
    if( flag == 2 ) {
        new text[ 128 ];
        
        if( get_user_team( value ) == get_user_team( id ) )
            formatex( text, charsmax( text ), "1 %%p2 HP: %d ( %s )", get_user_health( value ), g_mPlayerData[ g_iPlayerLevel[ value ] ][ m_szRankName ]  );
        else 
            formatex( text, charsmax( text ), "1 %%p2 ( %s )", g_mPlayerData[ g_iPlayerLevel[ value ] ][ m_szRankName ]  );
        
        message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "StatusText" ), _, id );
        write_byte( 0 );
        write_string( text );
        message_end( );
    }
    return PLUGIN_CONTINUE;
 }
