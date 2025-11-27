#pragma tabsize 0

#include <amxmodx>
#include <amxmisc>
 
#define TAG "BlackOut"
 
#define SELECTMAPS  5
#define OBEY_MAPCYCLE
#define charsof(%1) (sizeof(%1)-1)
 
new Array:g_mapName;
new g_mapNums;
 
new g_nextName[SELECTMAPS]
new g_voteCount[SELECTMAPS + 2]
new g_mapVoteNum
new g_teamScore[2]
new g_lastMap[32]
 
new g_coloredMenus
new bool:g_selected = false
 
new g_nextMap[32]
new g_mapCycle[32]
new g_pos
 
new g_TimeSet[32][2]
new g_LastTime
new g_CountDown
new g_Switch
 
 
public plugin_init()
{
    register_plugin("Nextmap Chooser", AMXX_VERSION_STR, "AMXX Dev Team")
    register_dictionary("mapchooser.txt")
    register_dictionary("common.txt")
   
    g_mapName=ArrayCreate(32);
   
    new MenuName[64]
   
    format(MenuName, 63, "%L", "en", "CHOOSE_NEXTM")
    register_menucmd(register_menuid(MenuName), (-1^(-1<<(SELECTMAPS+2))), "countVote")
    register_cvar("amx_extendmap_max", "90")
    register_cvar("amx_extendmap_step", "15")
 
    if (cstrike_running())
        register_event("TeamScore", "team_score", "a")
 
    get_localinfo("lastMap", g_lastMap, 31)
    set_localinfo("lastMap", "")
 
    new maps_ini_file[64]
    get_configsdir(maps_ini_file, 63);
    format(maps_ini_file, 63, "%s/maps.ini", maps_ini_file);
   
    if (!file_exists(maps_ini_file))
        get_cvar_string("mapcyclefile", maps_ini_file, 63)
    if (loadSettings(maps_ini_file))
        set_task(15.0, "voteNextmap", 987456, "", 0, "b")
 
    g_coloredMenus = colored_menus()
   
    register_dictionary("nextmap.txt")
    register_event("30", "changeMap", "a")
    register_clcmd("say nextmap", "sayNextMap", 0, "- displays nextmap")
    register_clcmd("say currentmap", "sayCurrentMap", 0, "- display current map")
    register_clcmd("say ff", "sayFFStatus", 0, "- display friendly fire status")
    register_cvar("amx_nextmap", "", FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_SPONLY)
 
    new szString[32], szString2[32], szString3[8]
   
    get_localinfo("lastmapcycle", szString, 31)
    parse(szString, szString2, 31, szString3, 7)
    g_pos = str_to_num(szString3)
    get_cvar_string("mapcyclefile", g_mapCycle, 31)
 
    if (!equal(g_mapCycle, szString2))
        g_pos = 0   // mapcyclefile has been changed - go from first
 
    readMapCycle(g_mapCycle, g_nextMap, 31)
    set_cvar_string("amx_nextmap", g_nextMap)
    format(szString3, 31, "%s %d", g_mapCycle, g_pos)   // save lastmapcycle settings
    set_localinfo("lastmapcycle", szString3)
   
   
    register_dictionary("timeleft.txt")
    register_cvar("amx_time_voice", "1")
    register_srvcmd("amx_time_display", "setDisplaying")
    register_cvar("amx_timeleft", "00:00", FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)
    register_clcmd("say timeleft", "sayTimeLeft", 0, "- displays timeleft")
    register_clcmd("say thetime", "sayTheTime", 0, "- displays current time")
   
    set_task(0.8, "timeRemain", 8648458, "", 0, "b")
}
 
public sayTheTime(id)
{
    if (get_cvar_num("amx_time_voice"))
    {
        new mhours[6], mmins[6], whours[32], wmins[32], wpm[6]
       
        get_time("%H", mhours, 5)
        get_time("%M", mmins, 5)
       
        new mins = str_to_num(mmins)
        new hrs = str_to_num(mhours)
       
        if (mins)
            num_to_word(mins, wmins, 31)
        else
            wmins[0] = 0
       
        if (hrs < 12)
            wpm = "am "
        else
        {
            if (hrs > 12) hrs -= 12
            wpm = "pm "
        }
 
        if (hrs)
            num_to_word(hrs, whours, 31)
        else
            whours = "twelve "
       
        client_cmd(id, "spk ^"fvox/time_is_now %s_period %s%s^"", whours, wmins, wpm)
    }
   
    new ctime[64]
   
    get_time("%d.%m.%Y  %H:%M:%S", ctime, 63)
    xColor(0, "Data:!g %s", ctime)
   
    return PLUGIN_CONTINUE
}
 
public sayTimeLeft(id)
{
    if (get_cvar_float("mp_timelimit"))
    {
        new a = get_timeleft()
       
        if (get_cvar_num("amx_time_voice"))
        {
            new svoice[128]
            setTimeVoice(svoice, 127, 0, a)
            client_cmd(id, "%s", svoice)
        }
        xColor(0, "Timp Ramas:!g %d:%02d", (a / 60), (a % 60))
    }
    else
        xColor(0, "!tFara limita de timp.")
   
    return PLUGIN_CONTINUE
}
 
setTimeText(text[], len, tmlf)
{
    new secs = tmlf % 60
    new mins = tmlf / 60
   
    if (secs == 0)
        format(text, len, "%d %s", mins, (mins == 1) ? "minut" : "minute")
    else if (mins == 0)
        format(text, len, "%d %s", secs, (secs == 1) ? "secunda" : "secunde")
    else
        format(text, len, "%d %s %d %s", mins, (mins == 1) ? "minut" : "minute", secs, (secs == 1) ? "secunda" : "secunde")
}
 
setTimeVoice(text[], len, flags, tmlf)
{
    new temp[7][32]
    new secs = tmlf % 60
    new mins = tmlf / 60
   
    for (new a = 0;a < 7;++a)
        temp[a][0] = 0
 
    if (secs > 0)
    {
        num_to_word(secs, temp[4], 31)
       
        if (!(flags & 8))
            temp[5] = "seconds "    /* there is no "second" in default hl */
    }
   
    if (mins > 59)
    {
        new hours = mins / 60
       
        num_to_word(hours, temp[0], 31)
       
        if (!(flags & 8))
            temp[1] = "hours "
       
        mins = mins % 60
    }
   
    if (mins > 0)
    {
        num_to_word(mins, temp[2], 31)
       
        if (!(flags & 8))
            temp[3] = "minutes "
    }
   
    if (!(flags & 4))
        temp[6] = "remaining "
   
    return format(text, len, "spk ^"vox/%s%s%s%s%s%s%s^"", temp[0], temp[1], temp[2], temp[3], temp[4], temp[5], temp[6])
}
 
findDispFormat(time)
{
    for (new i = 0; g_TimeSet[i][0]; ++i)
    {
        if (g_TimeSet[i][1] & 16)
        {
            if (g_TimeSet[i][0] > time)
            {
                if (!g_Switch)
                {
                    g_CountDown = g_Switch = time
                    remove_task(8648458)
                    set_task(1.0, "timeRemain", 34543, "", 0, "b")
                }
               
                return i
            }
        }
        else if (g_TimeSet[i][0] == time)
        {
            return i
        }
    }
   
    return -1
}
 
public setDisplaying()
{
    new arg[32], flags[32], num[32]
    new argc = read_argc() - 1
    new i = 0
 
    while (i < argc && i < 32)
    {
        read_argv(i + 1, arg, 31)
        parse(arg, flags, 31, num, 31)
       
        g_TimeSet[i][0] = str_to_num(num)
        g_TimeSet[i][1] = read_flags(flags)
       
        i++
    }
    g_TimeSet[i][0] = 0
   
    return PLUGIN_HANDLED
}
 
public timeRemain(param[])
{
    new gmtm = get_timeleft()
    new tmlf = g_Switch ? --g_CountDown : gmtm
    new stimel[12]
   
    format(stimel, 11, "%02d:%02d", gmtm / 60, gmtm % 60)
    set_cvar_string("amx_timeleft", stimel)
   
    if (g_Switch && gmtm > g_Switch)
    {
        remove_task(34543)
        g_Switch = 0
        set_task(0.8, "timeRemain", 8648458, "", 0, "b")
       
        return
    }
 
    if (tmlf > 0 && g_LastTime != tmlf)
    {
        g_LastTime = tmlf
        new tm_set = findDispFormat(tmlf)
       
        if (tm_set != -1)
        {
            new flags = g_TimeSet[tm_set][1]
            new arg[128]
           
            if (flags & 1)
            {
                setTimeText(arg, 127, tmlf)
                if (flags & 16)
                    set_hudmessage(random_num(50, 255), random_num(50, 255), random_num(50, 255), -1.0, 0.85, 0, 0.0, 1.1, 0.1, 0.5, -1)
                else
                    set_hudmessage(random_num(50, 255), random_num(50, 255), random_num(50, 255), -1.0, 0.85, 0, 0.0, 3.0, 0.0, 0.5, -1)
                       
                show_hudmessage(0, "%s", arg)
            }
 
            if (flags & 2)
            {
                setTimeVoice(arg, 127, flags, tmlf)
                client_cmd(0, "%s", arg)
            }
        }
    }
}
 
 
public checkVotes()
{
    new b = 0
   
    for (new a = 0; a < g_mapVoteNum; ++a)
        if (g_voteCount[b] < g_voteCount[a])
            b = a
 
   
    if (g_voteCount[SELECTMAPS] > g_voteCount[b]
        && g_voteCount[SELECTMAPS] > g_voteCount[SELECTMAPS+1])
    {
        new mapname[32]
       
        get_mapname(mapname, 31)
        new Float:steptime = get_cvar_float("amx_extendmap_step")
        set_cvar_float("mp_timelimit", get_cvar_float("mp_timelimit") + steptime)
        xColor(0, "Votarea a luat sfarsit. Harta actuala va fi extinsa cu!g %.0f!n minute", steptime)
        log_amx("Vote: Voting for the nextmap finished. Map %s will be extended to next %.0f minutes", mapname, steptime)
       
        return
    }
   
    new smap[32]
    if (g_voteCount[b] && g_voteCount[SELECTMAPS + 1] <= g_voteCount[b])
    {
        ArrayGetString(g_mapName, g_nextName[b], smap, charsof(smap));
        set_cvar_string("amx_nextmap", smap);
    }
 
   
    get_cvar_string("amx_nextmap", smap, 31)
    xColor(0, "Votarea a luat sfarsit. Harta urmatoare va fi:!g %s", smap)
    log_amx("Vote: Voting for the nextmap finished. The nextmap will be %s", smap)
}
 
public countVote(id, key)
{
    if (get_cvar_float("amx_vote_answers"))
    {
        new name[32]
        get_user_name(id, name, 31)
       
        if (key == SELECTMAPS)
            xColor(0, "!g%s!n alege extinderea hartii", name)
        else if (key < SELECTMAPS)
        {
            new map[32];
            ArrayGetString(g_mapName, g_nextName[key], map, charsof(map));
            xColor(0, "!g%s!n alege!t %s", name, map)
        }
    }
    ++g_voteCount[key]
   
    return PLUGIN_HANDLED
}
 
bool:isInMenu(id)
{
    for (new a = 0; a < g_mapVoteNum; ++a)
        if (id == g_nextName[a])
            return true
    return false
}


new bool:allowed=false,countdown=7

public vote_countdownPendingVote()
{
   countdown--;

   if (countdown <= 0)
   {
      allowed=true
voteNextmap()
countdown=7
   }
   else
   {
      new word[6];
      num_to_word(countdown, word, 5);
      
      client_cmd(0, "spk ^"fvox/%s^"", word);

   set_hudmessage(0, 222, 50, -1.0, 0.13, 0, 1.0, 0.94, 0.0, 0.0, -1);
   show_hudmessage(0, "Auto-Vot peste %d secund%s", countdown,countdown==1?"a":"e");
   }

}
public voteNextmap()
{
    new winlimit = get_cvar_num("mp_winlimit")
    new maxrounds = get_cvar_num("mp_maxrounds")
   
    if (winlimit)
    {
        new c = winlimit - 2
       
        if ((c > g_teamScore[0]) && (c > g_teamScore[1]))
        {
            g_selected = false
            return
        }
    }
    else if (maxrounds)
    {
        if ((maxrounds - 2) > (g_teamScore[0] + g_teamScore[1]))
        {
            g_selected = false
            return
        }
    } else {
        new timeleft = get_timeleft()
       
        if (timeleft < 1 || timeleft > 129)
        {
            g_selected = false
            return
        }
    }
 

   if(!allowed)
   {
set_task(1.0, "vote_countdownPendingVote", _, _, _, "a", 7);
return
   }

    if (g_selected)
        return
 
    g_selected = true
   
    new menu[512], a, mkeys = (1<<SELECTMAPS + 1)
 
    new pos = format(menu, 511, g_coloredMenus ? "\y%s:\w^n^n" : "%s:^n^n", "E timpu` sa alegem urmatoarea harta.")
    new dmax = (g_mapNums > SELECTMAPS) ? SELECTMAPS : g_mapNums
   
    for (g_mapVoteNum = 0; g_mapVoteNum < dmax; ++g_mapVoteNum)
    {
        a = random_num(0, g_mapNums - 1)
       
        while (isInMenu(a))
            if (++a >= g_mapNums) a = 0
       
        g_nextName[g_mapVoteNum] = a
        pos += format(menu[pos], 511, "%d. %a^n", g_mapVoteNum + 1, ArrayGetStringHandle(g_mapName, a));
        mkeys |= (1<<g_mapVoteNum)
        g_voteCount[g_mapVoteNum] = 0
    }
   
    menu[pos++] = '^n'
    g_voteCount[SELECTMAPS] = 0
    g_voteCount[SELECTMAPS + 1] = 0
   
    new mapname[32]
    get_mapname(mapname, 31)
 
    if ((winlimit + maxrounds) == 0 && (get_cvar_float("mp_timelimit") < get_cvar_float("amx_extendmap_max")))
    {
        pos += format(menu[pos], 511, "\r%d\w. Extinde harta\r %s\w^n", SELECTMAPS + 1, mapname)
        mkeys |= (1<<SELECTMAPS)
    }
 
    format(menu[pos], 511, "\r%d\w. %s", SELECTMAPS+2, "Nu votez")
    new MenuName[64]
   
    format(MenuName, 63, "%L", "en", "CHOOSE_NEXTM")
    show_menu(0, mkeys, menu, 15, MenuName)
    set_task(15.0, "checkVotes")
    xColor(0, "E timpul sa alegem urmatoarea harta.")
    client_cmd(0, "spk Gman/Gman_Choose2")
    log_amx("Vote: Voting for the nextmap started")
}


stock bool:ValidMap(mapname[])
{
    if ( is_map_valid(mapname) )
    {
        return true;
    }
    // If the is_map_valid check failed, check the end of the string
    new len = strlen(mapname) - 4;
   
    // The mapname was too short to possibly house the .bsp extension
    if (len < 0)
    {
        return false;
    }
    if ( equali(mapname[len], ".bsp") )
    {
        // If the ending was .bsp, then cut it off.
        // the string is byref'ed, so this copies back to the loaded text.
        mapname[len] = '^0';
       
        // recheck
        if ( is_map_valid(mapname) )
        {
            return true;
        }
    }
   
    return false;
}
 
loadSettings(filename[])
{
    if (!file_exists(filename))
        return 0
 
    new szText[32]
    new currentMap[32]
   
    new buff[256];
   
    get_mapname(currentMap, 31)
 
    new fp=fopen(filename,"r");
   
    while (!feof(fp))
    {
        buff[0]='^0';
       
        fgets(fp, buff, charsof(buff));
       
        parse(buff, szText, charsof(szText));
       
       
        if (szText[0] != ';' &&
            ValidMap(szText) &&
            !equali(szText, g_lastMap) &&
            !equali(szText, currentMap))
        {
            ArrayPushString(g_mapName, szText);
            ++g_mapNums;
        }
       
    }
   
    fclose(fp);
 
    return g_mapNums
}
 
public team_score()
{
    new team[2]
   
    read_data(1, team, 1)
    g_teamScore[(team[0]=='C') ? 0 : 1] = read_data(2)
}
 
public plugin_end()
{
    new current_map[32]
 
    get_mapname(current_map, 31)
    set_localinfo("lastMap", current_map)
}
 
 
 
 
getNextMapName(szArg[], iMax)
{
    new len = get_cvar_string("amx_nextmap", szArg, iMax)
   
    if (ValidMap(szArg)) return len
    len = copy(szArg, iMax, g_nextMap)
    set_cvar_string("amx_nextmap", g_nextMap)
   
    return len
}
 
public sayNextMap()
{
    new name[32]
   
    getNextMapName(name, 31)
    xColor(0, "Harta urmatoare este:!g %s", name)
}
 
public sayCurrentMap()
{
    new mapname[32]
 
    get_mapname(mapname, 31)
    xColor(0, "Harta actuala este:!g %s", mapname)
}
 
public sayFFStatus()
{
    xColor(0, "Friendlyfile:!g %s", get_cvar_num("mp_friendlyfire") ? "ON" : "OFF")
}
 
public delayedChange(param[])
{
    set_cvar_float("mp_chattime", get_cvar_float("mp_chattime") - 2.0)
    server_cmd("changelevel %s", param)
}
 
public changeMap()
{
    new string[32]
    new Float:chattime = get_cvar_float("mp_chattime")
   
    set_cvar_float("mp_chattime", chattime + 2.0)       // make sure mp_chattime is long
    new len = getNextMapName(string, 31) + 1
    set_task(chattime, "delayedChange", 0, string, len) // change with 1.5 sec. delay
}
 
new g_warning[] = "WARNING: Couldn't find a valid map or the file doesn't exist (file ^"%s^")"
 
#if defined OBEY_MAPCYCLE
readMapCycle(szFileName[], szNext[], iNext)
{
    new b, i = 0, iMaps = 0
    new szBuffer[32], szFirst[32]
 
    if (file_exists(szFileName))
    {
        while (read_file(szFileName, i++, szBuffer, 31, b))
        {
            if (!isalnum(szBuffer[0]) || !ValidMap(szBuffer)) continue
           
            if (!iMaps)
                copy(szFirst, 31, szBuffer)
           
            if (++iMaps > g_pos)
            {
                copy(szNext, iNext, szBuffer)
                g_pos = iMaps
                return
            }
        }
    }
 
    if (!iMaps)
    {
        log_amx(g_warning, szFileName)
        get_mapname(szFirst, 31)
    }
 
    copy(szNext, iNext, szFirst)
    g_pos = 1
}
 
#else
 
readMapCycle(szFileName[], szNext[], iNext)
{
    new b, i = 0, iMaps = 0
    new szBuffer[32], szFirst[32], szCurrent[32]
   
    get_mapname(szCurrent, 31)
   
    new a = g_pos
 
    if (file_exists(szFileName))
    {
        while (read_file(szFileName, i++, szBuffer, 31, b))
        {
            if (!isalnum(szBuffer[0]) || !ValidMap(szBuffer)) continue
           
            if (!iMaps)
            {
                iMaps = 1
                copy(szFirst, 31, szBuffer)
            }
           
            if (iMaps == 1)
            {
                if (equali(szCurrent, szBuffer))
                {
                    if (a-- == 0)
                        iMaps = 2
                }
            } else {
                if (equali(szCurrent, szBuffer))
                    ++g_pos
                else
                    g_pos = 0
               
                copy(szNext, iNext, szBuffer)
                return
            }
        }
    }
   
    if (!iMaps)
    {
        log_amx(g_warning, szFileName)
        copy(szNext, iNext, szCurrent)
    }
    else
        copy(szNext, iNext, szFirst)
   
    g_pos = 0
}
#endif
 
 
stock xColor(const id, const input[], any:...)
    {
       new count = 1, players[32]
       static msg[320], msg2[320]
       vformat(msg, 190, input, 3)
       format(msg2, 190, "!n[!g%s!n] %s", TAG, msg)
       replace_all(msg2, 190, "!g", "^4")
       replace_all(msg2, 190, "!n", "^1")
       replace_all(msg2, 190, "!t", "^3")
       replace_all(msg2, 190, "!t2", "^0")
       if (id) players[0] = id; else get_players(players, count, "ch")
       {
          for (new i = 0; i < count; i++)
          {
             if (is_user_connected(players[i]))
             {
                message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
                write_byte(players[i])
                write_string(msg2)
                message_end()
             }
          }
       }
    }
