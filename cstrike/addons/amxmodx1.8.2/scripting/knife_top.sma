#include <amxmodx>
#include <colorchat>
#include <nvault>
#include <amxmisc>

#define MAXENTRIES 1000

new gKnifeKills[33], gKnifeDeaths[33], gKnifeHeadShots[33], gConnect[33], g_cvar, RecDir[64];

public plugin_init() {
    register_plugin( "KnifeTop", "1.0", "Tolsty" );
    register_event("DeathMsg", "eventDeathMsg", "a", "1>0");
    g_cvar = register_cvar("knifetop_topsave", "1");
    register_clcmd("say /knifereset","top_reset",ADMIN_BAN);
    register_clcmd("say /kniferank","kniferank");
    register_clcmd("say /knifetop","topten_show");
    register_clcmd("say /knife","info");
    new DataDir[64];
    get_datadir(DataDir, 63);
    format(RecDir, 63, "%s/vault", DataDir);

}

public client_connect(plr) {
    if(!get_pcvar_num(g_cvar) ) 
        return 
    gConnect[plr] = true;
    update(plr)
    set_task(15.0,"info", plr);
}
public client_disconnect(plr) {
    gConnect[plr] = false;
}
public update(plr) {
    if(!get_pcvar_num(g_cvar) ) 
        return PLUGIN_HANDLED
    static knifetop[128], szid[32];
    format(knifetop, 128, "%s/knifetop.vault",RecDir);
    if(get_pcvar_num(g_cvar) == 1)
        get_user_name(plr,szid,32);
    else if(get_pcvar_num(g_cvar) == 2 )
        get_user_ip(plr,szid,32);
    else if(get_pcvar_num(g_cvar) == 3 )
        get_user_authid(plr,szid,32);
    if( file_exists(knifetop)) {
        new szvault[64];
        format(szvault,64,"knifetop");
        
        new vault = nvault_open(szvault);
        if(vault != -1) {
            new szkey[4];
            for(new i=1;i<=MAXENTRIES;i++) {
                new szreturn[128];
                format(szkey,4,"%d",i);
                nvault_get(vault,szkey,szreturn,128);
                new arg1[16], arg2[16], arg3[8],  arg4[8],  arg5[8];
                if(parse(szreturn, arg1, 16, arg2, 16, arg3, 8, arg4, 8, arg5, 8) != 0 && equal(szid,arg1) ) {
                    gKnifeKills[plr] = str_to_num(arg3)
                    gKnifeDeaths[plr] = str_to_num(arg4)
                    gKnifeHeadShots[plr] = str_to_num(arg5)
                    if( !gConnect[plr] )
                        ColorChat(plr , RED, "[AMXX] You are %s in knifetop, with %d kills !", szkey, gKnifeKills[plr]);
                }
            }
            nvault_close(vault);
        }
    } 
    if(gConnect[plr])
        gConnect[plr] = false
    return PLUGIN_HANDLED

}
public info(plr) {
    ColorChat(plr , RED, "[AMXX] type /knifetop to see the knife top10, or /kniferank to see your rank");
    
}
public kniferank(plr) {
    update(plr)
}
public eventDeathMsg() {
    if(!get_pcvar_num(g_cvar) ) 
        return PLUGIN_HANDLED
    static killer; killer = read_data( 1 );
    static victim; victim = read_data( 2 ) ;      
    static szweapon[5];
    read_data( 4 , szweapon , 4 );
      
    if ( ( szweapon[ 0 ] == 'k' ) && ( szweapon[ 3 ] == 'f' ) ) {   
        gKnifeKills[killer]++ 
        gKnifeDeaths[victim]++ 
        if ( read_data( 3 ) ) {
            gKnifeHeadShots[killer]++
        }   
        topten_update(killer)
        topten_update(victim)        
    } 
    return PLUGIN_HANDLED
}

public topten_update( plr ) {
    new TopTenVault[64];
    format(TopTenVault, 64, "knifetop");
    
    new vault = nvault_open(TopTenVault);

    if(vault != -1) {

        new szkey[8];
        new szid[32];
        new szname[32];
        new cur_place;
        new new_place;

        if(get_pcvar_num(g_cvar) == 1)
            get_user_name(plr,szid,32);
        else if(get_pcvar_num(g_cvar) == 2 )
            get_user_ip(plr,szid,32);
        else if(get_pcvar_num(g_cvar) == 3 )
            get_user_authid(plr,szid,32);

        get_user_name(plr,szname,32);

        for(new i=1;i<=MAXENTRIES;i++) {
            new szreturn[128], arg1[32] ;
            format(szkey,8,"%d",i);
            nvault_get(vault,szkey,szreturn,128);
            if(parse(szreturn, arg1, 32) != 0 && equal(szid,arg1)) {
                cur_place = i;
                break;
            }
        }
        for(new i=1;i<=MAXENTRIES;i++) {
            new szreturn[256], arg1[32], arg3[32];
            format(szkey,8,"%d",i);
            nvault_get(vault,szkey,szreturn,256);
            if (cur_place == 1) {
                new_place = 1;
                break;
            }
            else if (cur_place != 0 && cur_place < i) {
                new_place = 0;
                break;
            }
            else if(parse(szreturn, arg1, 32) == 0) {
                new_place = i;
                break;
            }
            else if(gKnifeKills[plr]  > str_to_num(arg3) ) {
                new_place = i;
                break;
            }
        }
        if(cur_place == 0 && new_place <= 1000 && new_place > 0) {
            if(new_place < 1000) {
                new sztemp[128], sztempkey[8];
                
                for(new i=10;i>new_place;i--) {
                    format(sztempkey,8,"%d",i-1);
                    nvault_get(vault,sztempkey,sztemp,128);
                    if(!equal(sztemp,"")) {
                        format(sztempkey,8,"%d",i);
                        nvault_pset(vault,sztempkey,sztemp);
                    }
                }
            }
            client_print(0, print_chat, "[AMXX] %s now is %d knifetop with %d gKnifeKills!", szname, new_place, gKnifeKills[plr]);
            
            new sznew[512];
            format(szkey,8,"%d",new_place);
            format(sznew,512,"^"%s^" ^"%s^" ^"%d^" ^"%d^" ^"%d^" ", szid, szname, gKnifeKills[plr], gKnifeDeaths[plr], gKnifeHeadShots[plr]);    
            nvault_pset(vault,szkey,sznew);
        }
        else if(cur_place == new_place && cur_place > 0) {
                     
                new sznew[512], szkey[8];
                new szreturn[128], arg1[32], arg3[32], arg5[32];
                format(szkey,8,"%d",cur_place);
                nvault_get(vault,szkey,szreturn,128);
                    
                if(parse(szreturn, arg1, 32, arg3, 32) != 0) {
                    format(sznew,512,"^"%s^" ^"%s^" ^"%d^" ^"%d^" ^"%d^" ", szid, szname,  gKnifeKills[plr] > str_to_num(arg3) ? gKnifeKills[plr] : str_to_num(arg3), gKnifeDeaths[plr], gKnifeHeadShots[plr] > str_to_num(arg5) ? gKnifeHeadShots[plr] : str_to_num(arg5));    
                    nvault_pset(vault,szkey,sznew);
                }
        }
        else if (new_place < cur_place && new_place > 0) {
            new sznew[512];
            new szreturn[128], arg1[32], arg2[32];
            format(szkey,8,"%d",cur_place);
            nvault_get(vault,szkey,szreturn,128);
            if(parse(szreturn,arg1,32,arg2,32) != 0) {
                format(sznew,512,"^"%s^" ^"%s^" ^"%d^" ^"%d^" ^"%d^" ", szid, szname,  gKnifeKills[plr] , gKnifeDeaths[plr], gKnifeHeadShots[plr]);
                for(new i=cur_place;i>=new_place;i--) {
                    new szreturn[128], arg1[32], arg2[32];
                    format(szkey,8,"%d",i);
                    nvault_get(vault,szkey,szreturn,128);
                    
                    if(parse(szreturn,arg1,32,arg2,32) != 0){
                        new sztemp [128], sztempkey[8];
                        format(sztempkey,8,"%d",i-1);
                        nvault_get(vault,sztempkey,sztemp,128);
                        
                        if(!equal(sztemp,"")) {
                            format(sztempkey,8,"%d",i);
                            nvault_pset(vault,sztempkey,sztemp);
                        }
                    }
                    else break;
                }
                
                client_print(0, print_chat, "............" );
                nvault_pset(vault,szkey,sznew);
            }
        }
        nvault_close(vault);
    }
}





public topten_show( plr) {
    
    
    static knifetop[128];
    
    format(knifetop, 128, "%s/knifetop.vault",RecDir);
    
    if( file_exists(knifetop)) {
        
        new motd[2500];
        new szvault[64];

        format(szvault,64,"knifetop");
        
        new vault = nvault_open(szvault);
        if(vault != -1) {
        
            add(motd,2500,"<html><style>");
            add(motd,2500,"body { background-color:#000000; }");
            add(motd,2500,".tabel { color:#FFB000; }");
            add(motd,2500,".header { background-color:#3d3c23; color:#FFB000;}");
            add(motd,2500,"</style><body>");
            add(motd,2500,"<br><br><table align=center border=1 width=90% class=tabel>");
            add(motd,2500,"<tr><td class=header width=5% align=center>#</td><td class=header width=24%>Name</td><td class=header width=24%>KnifeKills</td><td class=header width=24%>KnifeDeaths</td><td class=header width=24%>KnifeHeadShots</td></tr>");
            new szkey[4];
            for(new i=1;i<=10;i++) {
                new szreturn[128];
                format(szkey,4,"%d",i);
                nvault_get(vault,szkey,szreturn,128);
                
                new arg1[16], arg2[16], arg3[8],  arg4[8],  arg5[8];
                if(parse(szreturn, arg1, 15, arg2, 15, arg3, 7, arg4, 7, arg5, 7) != 0) {
                    while (containi(arg2, "<") != -1) replace(arg2, 63, "<", "&lt")
                    while (containi(arg2, ">") != -1) replace(arg2, 63, ">", "&gt")
                    add(motd,2048,"<tr><td>");
                    add(motd,2048,szkey);
                    add(motd,2048,"</td><td>");
                    add(motd,2500,arg2);
                    add(motd,2500,"</td><td>");
                    add(motd,2500,arg3);
                    add(motd,2500,"</td><td>");
                    add(motd,2500,arg4);
                    add(motd,2500,"</td><td>");
                    add(motd,2500,arg5);
                    add(motd,2500,"</td><td>");
                    add(motd,2500,"</td></tr>");
                    
                    
                }
            }
            
            nvault_close(vault);
            
            add(motd,2500,"</table></body></html>");
            show_motd(plr ,motd,"KnifeTop");
        }
    } else {
        ColorChat(plr , RED, "No records in topfile");
    }
}

public top_reset(plr,level,cid) {
    if(!cmd_access(plr,level,cid,0)) {
        return PLUGIN_HANDLED;
    }
    
    new name[32];
    get_user_name(plr, name, 32);
    
    
    static knifetop[128];
    format(knifetop, 128, "%s/knifetop.vault",RecDir);
    if( file_exists(knifetop)) {
        delete_file(knifetop);
        ColorChat(0, GREEN, "[AMXX] ADMIN %s reseted the KnifeTop top", name);
        }
    return PLUGIN_HANDLED;
    
}  
