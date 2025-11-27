#include <amxmodx>

// Arrays, Then we add the Dimensions.
new Array:g_steamid
new Array:g_password
new Array:g_flags
new Array:g_mode

// Array of player flags
new Array:g_playerflags

// We need to create a cvar por setinfo & for default flag.
new cvar_setinfo
new cvar_defaultflag

// Here are the flags for loggins types.
enum
{
    KZ_JOIN_PASS = (1<<0),
    KZ_JOIN_TAGS = (1<<1),
    KZ_JOIN_STEAM = (1<<2),
    KZ_JOIN_IP = (1<<3),
    KZ_JOIN_NOPASS = (1<<4)
}

public plugin_precache() 
{
    register_plugin("Admins Loggin", "1.0", "ReymonARG")
    
    // Now create the 2 cvars for custom somethings.
    cvar_setinfo = register_cvar("fakeadmin_setinfo", "_pw")
    cvar_defaultflag = register_cvar("fakeadmin_defaultflag", "z")
    
    register_concmd("fakeadmin_reload", "fakereload", ADMIN_RCON)
    
    // We need to create the dimensions for the Arrays
    g_steamid = ArrayCreate(32, 1)
    g_password = ArrayCreate(32, 1)
    g_flags = ArrayCreate(1, 1)
    g_mode = ArrayCreate(1, 1)
    g_playerflags = ArrayCreate(1, 1)
    
    for( new i = 0; i <= 32; i++)
        ArrayPushCell(g_playerflags, 0)
    
    // Well now we need to get the list of admins
    fake_get_admins("addons/amxmodx/configs/newusers.ini")
}

public fakereload(id, level)
{
    if( get_user_flags(id) & level )
    {
        fake_get_admins("addons/amxmodx/configs/newusers.ini")
        
        for( new i = 1; i <= 32; i++)
        {
            if( !is_user_connected(i) ) continue
            fakeadmin_authplayer(i)
        }
    }
    
    return PLUGIN_HANDLED
}

public fake_get_admins(const filename[])
{
    // First we have to create some static collet the info.
    static data[192], steamid[32], password[32], flags[32], mode[10]
    
    // For reload admins. We need to clean all information and get again.
    ArrayClear(g_steamid)
    ArrayClear(g_password)
    ArrayClear(g_flags)
    ArrayClear(g_mode)
    
    // Now we need to open the file and read, line per line.
    new f = fopen(filename, "rt" )
    while( !feof(f) )
    {
        fgets( f, data, 191)
        // With continue if dont is the data that we want.
        if( data[0] == '/' && data[1] == '/' || data[0] == ';' || data[0] == ' ' || data[0] == '^n') continue
        
        // If dont are all param go to next line.
        if( parse( data, steamid, 31, password, 31, flags, 31, mode, 9) != 4 ) continue
        
        // Push the information into Arrays items.
        ArrayPushString(g_steamid, steamid)
        ArrayPushString(g_password, password)
        ArrayPushCell(g_flags, read_flags(flags))
        ArrayPushCell(g_mode, read_flags(flags))
    }
    // This is very important. We need to close the file.
    fclose(f)
    
    // We print the num of items that SteamId Array have.
    // Why dont is -1, Because array have item 0 to.
    server_print("%i Admin from %s", ArraySize(g_steamid), filename)
    
    return 1
}

public client_connect(id)
{
    static defaultflags[32]
    get_pcvar_string(cvar_defaultflag, defaultflags, 31)
    
    // First of all. We set player the defaults flags. Then if is admin we edit.
    ArraySetCell(g_playerflags, id, read_flags(defaultflags) )
}

public client_authorized(id)
{
    fakeadmin_authplayer(id)
}

// Player change name?
public client_infochanged(id)
{
    static oldname[32], newname[32]
    get_user_name(id, oldname, 31)
    get_user_info(id, "name", newname, 31)
    
    if( !equal(oldname, newname) )
        fakeadmin_authplayer(id, newname)
}

// Auth Player
stock fakeadmin_authplayer(id, const newname[] = "")
{
    static name[32], authid[32], ip[32]
    
    // If is seted name copy to new array, ifnot get the name.
    if( equal(newname, "") )
        get_user_name(id, name, 31)
    else
        copy(name, 31, newname)
    
    static plr_steamid[32], plr_password[32], plr_flags, plr_mode
    static setinfo[32], setinfo_tag[32] // If needed password
    get_pcvar_string(cvar_setinfo, setinfo_tag, 31)
    
    // Now we get player steamid & ip
    get_user_authid(id, authid, 31)
    get_user_ip(id, ip, 31, 1) // Very important this. Without ip port.
    get_user_info(id, setinfo_tag, setinfo, 31)
    
    for( new i = 0; i < sizeof(g_steamid); i++)
    {    
        // First of all, we need to get the information.
        ArrayGetString(g_steamid, i, plr_steamid, 31)
        ArrayGetString(g_password, i, plr_password, 31)
        plr_flags = ArrayGetCell(g_flags, i)
        plr_mode = ArrayGetCell(g_mode, i)
        
        // Now. select the login mode.
        if( plr_mode & KZ_JOIN_STEAM )
        {
            // If equal the steamid of the list cotinue.
            if( equal(plr_steamid, authid) )
            {
                // Now we need to check if password required or not.
                if( plr_mode & KZ_JOIN_NOPASS )
                {
                    return ArraySetCell(g_playerflags, id, plr_flags)
                }
                else
                {
                    // If equal the password, Set flags
                    if( equal(plr_password, setinfo) )
                    {
                        return ArraySetCell(g_playerflags, id, plr_flags)
                    }
                    else
                    {
                        // If is seted kick player con bad password. Kick with reason..
                        if( plr_mode & KZ_JOIN_PASS )
                        {
                            return server_cmd("kick #%d  You dont have Access to this Server", get_user_userid(id))
                        }
                    }
                }
            }
        }
        else if( plr_mode & KZ_JOIN_IP )
        {            
            if( equal(plr_steamid, ip) )
            {
                if( plr_mode & KZ_JOIN_NOPASS )
                {
                    return ArraySetCell(g_playerflags, id, plr_flags)
                }
                else
                {
                    if( equal(plr_password, setinfo) )
                    {
                        return ArraySetCell(g_playerflags, id, plr_flags)
                    }
                    else
                    {
                        if( plr_mode & KZ_JOIN_PASS )
                        {
                            return server_cmd("kick #%d  You dont have Access to this Server", get_user_userid(id))
                        }
                    }
                }
            }
        }
        else
        {
            static is_tag_flag = -1
            if( plr_mode & KZ_JOIN_TAGS )
            {
                is_tag_flag = containi(name, plr_steamid)
            }
            
            if( is_tag_flag != -1 ||  equal(plr_steamid, name) )
            {
                if( plr_mode & KZ_JOIN_NOPASS )
                {
                    return ArraySetCell(g_playerflags, id, plr_flags)
                }
                else
                {
                    if( equal(plr_password, setinfo) )
                    {
                        return ArraySetCell(g_playerflags, id, plr_flags)
                    }
                    else
                    {
                        if( plr_mode & KZ_JOIN_PASS )
                        {
                            return server_cmd("kick #%d  You dont have Access to this Server", get_user_userid(id))
                        }
                    }
                }
            }            
        }    
    }
    
    return 1
}  
