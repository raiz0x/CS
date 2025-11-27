#include <amxmodx>
#include <nvault>
#include <zombieplague>

#pragma tabsize 0

#define NV_NAME "GET_AMMO"
#define TAG "[ZP]"

enum player_struct {
    mtime,bool:ftime,key[64]
}
new g_player[33][player_struct];

new cvar_save_type,cvar_time,cvar_ap;

public plugin_init() {

    register_plugin("Get Ammo Packs", "1.0", "Clauu");
    
    cvar_save_type = register_cvar("get_ammo_save_type","3"); // how to save data 1 by authid, 2 by ip or 3 by name
    cvar_time = register_cvar("get_ammo_minutes","60"); // time in minutes, 60minutes=1hour it will be auto calculated
    cvar_ap = register_cvar("get_ammo_packs","150"); // how many ammo packs to give
    
    register_clcmd("say /get", "cmd_ap");
    register_clcmd("say_team /get", "cmd_ap");
}
        
public cmd_ap(id) {
    new nv = nvault_open(NV_NAME);
    
    if(nv == INVALID_HANDLE) {
        client_print(id,print_chat,"%s For the moment getting ammo packs system is inactive..",TAG);
        return;
    }
    
    new txt_min[32],txt_ap[10];
    new ap = get_pcvar_num(cvar_ap),pminutes = get_pcvar_num(cvar_time);
    copy(txt_ap,charsmax(txt_ap),(ap==1)?"pack":"packs");
    build_time(pminutes,txt_min,charsmax(txt_min));
    
    if(g_player[id][ftime]) {
        client_print(id,print_chat,"%s You have just received %d ammo %s, get another in %s !",TAG,ap,txt_ap,txt_min);
        zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + ap);
        g_player[id][ftime]=false;
        nvault_touch(nv,g_player[id][key],g_player[id][mtime]=get_systime());
		nvault_close(nv);
        return;
    }
    
    new user_time=get_systime()-g_player[id][mtime];
    new diff_min=(user_time<(pminutes*60))?pminutes-(user_time/60):pminutes;
    build_time(diff_min,txt_min,charsmax(txt_min));
    
    if(user_time>=(pminutes*60)) {
        client_print(id,print_chat,"%s You have just received %d ammo %s since %s passed !",TAG,ap,txt_ap,txt_min);
        zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + ap);
        nvault_touch(nv,g_player[id][key],g_player[id][mtime]=get_systime());
    }
    else
        client_print(id,print_chat,"%s Retry again in %s for getting %d more ammo %s !",TAG,txt_min,ap,txt_ap);
    nvault_close(nv);
}

public client_putinserver(id) {
    new nv,data[32];
    get_auth(id,g_player[id][key],charsmax(g_player[][key]));
    g_player[id][mtime]=get_systime();
    g_player[id][ftime]=false;
    formatex(data,charsmax(data),"%d",g_player[id][mtime]);
    
    if((nv=nvault_open(NV_NAME))==INVALID_HANDLE)
        return;
    
    if(!nvault_lookup(nv,g_player[id][key],data,charsmax(data),g_player[id][mtime])) {
        nvault_set(nv,g_player[id][key],data);
        g_player[id][ftime]=true;
    }
    
    nvault_close(nv);
}    

public client_disconnect(id) {
    g_player[id][mtime]=0;
    g_player[id][ftime]=false;
}

stock get_auth(id,data[],len)
    switch(get_pcvar_num(cvar_save_type)) {
        case 1: get_user_authid(id,data,len);
        case 2: get_user_ip(id,data,len,1);
        case 3: get_user_name(id,data,len);
    }

stock build_time(pminutes,data[],len)
    if(pminutes==1)
        copy(data,len,"1 minute");
    else if(pminutes!=1&&pminutes<60)
        formatex(data,len,"%d minutes",pminutes);
    else if(pminutes==60)
        copy(data,len,"1 hour");
    else {
        new ptime=pminutes/60;
        if(ptime*60==pminutes)
            formatex(data,len,"%d %s",ptime,(ptime==1)?"hour":"hours");
        else {
            new diff=pminutes-ptime*60;
            formatex(data,len,"%d %s and %d %s",ptime,(ptime==1)?"hour":"hours",diff,(diff==1)?"minute":"minutes");
        }
    }
