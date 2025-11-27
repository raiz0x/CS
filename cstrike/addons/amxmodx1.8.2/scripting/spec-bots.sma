#include <amxmodx>
#include <cstrike>
#include <fakemeta>

#define PLUGIN  "botespectador"
#define AUTHOR  "_|Polimpo4|_"
#define VERSION "1.0"

new szname_bot[] = "IP: 93.119.26.85:27015";                   ////////// NOME BOT 1
new szname_bot2[] = "SKYPE: th3_darkness";             ////////// NOME BOT 2
new szname_bot3[] = "SITE: www.evils.ro";            ////////// NOME BOT 3

new bool:bot_on, bot_id;
new bool:bot_on2, bot_id2;
new bool:bot_on3, bot_id3;

new g_Query[256],rj[128];

public plugin_init()
{
    register_plugin("botespectador", "1.0", "_|Polimpo4|_");

    bot_on=false;
    bot_on2=false;
    bot_on3=false;
    bot_id=0;
    bot_id2=0;
    bot_id3=0;
    set_task(1.3,"fake_make");
    set_task(1.6,"fake_make2");
    set_task(1.9,"fake_make3");
    //return PLUGIN_CONTINUE
}

public fake_make()
{
    if((!bot_on)&&(!bot_id))
    {
	formatex( g_Query, charsmax(g_Query),"%s",szname_bot )
        bot_id=engfunc(EngFunc_CreateFakeClient,g_Query);
        if(bot_id > 0)
        {
            engfunc(EngFunc_FreeEntPrivateData,bot_id);
            dllfunc(DLLFunc_ClientConnect,bot_id,g_Query,"20.05.45.45.2",rj);
            if(is_user_connected(bot_id))
            {
                dllfunc(DLLFunc_ClientPutInServer, bot_id);
                set_pev(bot_id,pev_spawnflags,pev(bot_id,pev_spawnflags)|FL_FAKECLIENT);
                set_pev(bot_id,pev_flags,pev(bot_id,pev_flags)|FL_FAKECLIENT);
                cs_set_user_team(bot_id, CS_TEAM_SPECTATOR);
                bot_on = true;
            }
        }
    }
    return PLUGIN_CONTINUE;
}

public fake_make2()
{
    if((!bot_on2)&&(!bot_id2))
    {
	formatex( g_Query, charsmax(g_Query),"%s",szname_bot2 )
        bot_id2=engfunc(EngFunc_CreateFakeClient,g_Query);
        if(bot_id2 > 0)
        {
            engfunc(EngFunc_FreeEntPrivateData,bot_id2);
            dllfunc(DLLFunc_ClientConnect,bot_id2,g_Query,"20.05.45.45.2",rj);
            if(is_user_connected(bot_id2))
            {
                dllfunc(DLLFunc_ClientPutInServer, bot_id2);
                set_pev(bot_id2,pev_spawnflags,pev(bot_id2,pev_spawnflags)|FL_FAKECLIENT);
                set_pev(bot_id2,pev_flags,pev(bot_id2,pev_flags)|FL_FAKECLIENT);
                cs_set_user_team(bot_id2, CS_TEAM_SPECTATOR);
                bot_on2 = true;
            }
        }
    }
    return PLUGIN_CONTINUE;
}

public fake_make3()
{
    if((!bot_on3)&&(!bot_id3))
    {
	formatex( g_Query, charsmax(g_Query), "%s",szname_bot3 )
        bot_id3=engfunc(EngFunc_CreateFakeClient,g_Query);
        if(bot_id3 > 0)
        {
            engfunc(EngFunc_FreeEntPrivateData,bot_id3);
            dllfunc(DLLFunc_ClientConnect,bot_id3,g_Query,"20.05.45.45.2",rj);
            if(is_user_connected(bot_id3))
            {
                dllfunc(DLLFunc_ClientPutInServer, bot_id3);
                set_pev(bot_id3,pev_spawnflags,pev(bot_id3,pev_spawnflags)|FL_FAKECLIENT);
                set_pev(bot_id3,pev_flags,pev(bot_id3,pev_flags)|FL_FAKECLIENT);
                cs_set_user_team(bot_id3, CS_TEAM_SPECTATOR);
                bot_on3 = true;
            }
        }
    }
    return PLUGIN_CONTINUE;
}
 
public client_disconnect(id)
{
    if(/*!bot_id&&*/get_playersnum(1) < get_maxplayers() && !bot_on)	fake_make()
    if(/*!bot_id2&&*/get_playersnum(2) < get_maxplayers() && !bot_on2)	fake_make2()
    if(/*!bot_id3&&*/get_playersnum(3) < get_maxplayers() && !bot_on3)	fake_make3()
}
 
public client_connect(id)
{
    if(get_playersnum(1) >= get_maxplayers() && bot_on)
    {
        bot_on = false
        bot_id=0
        server_cmd("kick ^"%s^"", szname_bot);
    }
    if(get_playersnum(2) >= get_maxplayers() && bot_on2)
    {
        bot_on2 = false
        bot_id2=0
        server_cmd("kick ^"%s^"", szname_bot2);
    }
    if(get_playersnum(3) >= get_maxplayers() && bot_on3)
    {
        bot_on3 = false
        bot_id3=0
        server_cmd("kick ^"%s^"", szname_bot3)
    }
}
