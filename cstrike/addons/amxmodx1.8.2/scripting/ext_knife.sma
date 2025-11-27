#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <fvault>

new const g_vault_name[] = "Knives-Skins";

#pragma tabsize 0

#define SKINS 11

new g_knife[33];
    
new const g_knifemodels_v[SKINS][64] = {
    "models/v_knife.mdl", // The default model, don't touch
    
    "models/v_knife.mdl",
    "models/v_knife.mdl",
    "models/v_knife.mdl",
    "models/v_knife.mdl",
    "models/v_knife.mdl",
    "models/v_knife.mdl",
    "models/v_knife.mdl",
    "models/v_knife.mdl",
    "models/v_knife.mdl",
    "models/v_knife.mdl"
}
new const g_knifemodels_p[SKINS][64] = {
    "models/p_knife.mdl", // The default model, don't touch
    
    "models/p_knife.mdl",
    "models/p_knife.mdl",
    "models/p_knife.mdl",
    "models/p_knife.mdl",
    "models/p_knife.mdl",
    "models/p_knife.mdl",
    "models/p_knife.mdl",
    "models/p_knife.mdl",
    "models/p_knife.mdl",
    "models/p_knife.mdl"
}

new const g_knifenames [SKINS][32] = {
    "Default Knife",
    "Dorex Knife",
    "Lightning Knife",
    "Master Knife",
    "Traker Knife",
    "Ultimate Knife",
    "Ice Knife",
    "Bloody Knife",
    "Evolution Knife",
    "Simple Knife",
    "Crool Knife"
}

new g_knifecosts[SKINS][] = {
    "0",
    "5",
    "5",
    "5",
    "5",
    "5",
    "10",
    "10",
    "15",
    "15",
    "15"
}

new g_knifeflag[SKINS][] = {
    "0",
    "0",
    "0",
    "0",
    "0",
    "0",
    "1",
    "1",
    "1",
    "1",
    "1"
}  

static const PORTAL    [ ] = "^4[aNathrax-team.eu]^1 "
static const DIE    [ ] = "You can not open a shop, you must be alive !"
static const MONEY    [ ] = "You dont have money for this knife skin !"
static const BUY    [ ] = "You bought^3 "

#define PLUGIN "MultiShop - Knife server"
#define VERSION "1.0"
#define AUTHOR "SkillerkoS"

#define VIP_FLAG ADMIN_LEVEL_H

new count[33]
new k0[33],k1[33],k2[33],k3[33],k4[33],k5[33],k6[33],k7[33],k8[33],k9[33],k10[33]
new hk0[33],hk1[33],hk2[33],hk3[33],hk4[33],hk5[33],hk6[33],hk7[33],hk8[33],hk9[33],hk10[33]

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    register_clcmd("say /knifeshop", "cmd_knife")
    register_clcmd("say /knife", "cmd_knife")
    
    register_clcmd("say /inventory", "INFO")
    register_clcmd("say_team /invnetory", "INFO")
    
    register_event("CurWeapon","Event_CurWeapon","be","1=1");
}

public plugin_precache(){
    for (new i; i < sizeof g_knifemodels_v; i++)   precache_model(g_knifemodels_v[i]);
    for (new i; i < sizeof g_knifemodels_p; i++)   precache_model(g_knifemodels_p[i]);
}

public client_authorized(plr)   if( !is_user_hltv(plr) && !is_user_bot(plr) )   LoadExp(plr);
public client_disconnect(plr)
{
    if( g_knife[plr] > 0 )
    {
        SaveExp(plr);
        
        g_knife[plr] = 0;
    }
}
LoadExp(plr)
{
    new authid[35];
    get_user_authid(plr, authid, sizeof(authid) - 1);
    
    new data[125],szCount[8],szK[8],
    szK0[8],szK1[8],szK2[8],szK3[8],szK4[8],szK5[8],szK6[8],szK7[8],szK8[8],szK9[8],szK10[8],
    szhK0[8],szhK1[8],szhK2[8],szhK3[8],szhK4[8],szhK5[8],szhK6[8],szhK7[8],szhK8[8],szhK9[8],szhK10[8]
    	if( fvault_get_data(g_vault_name, authid, data, sizeof( data ) - 1 ) )
	{
		parse( data, szK, sizeof( szK ) - 1, szCount, sizeof( szCount ) - 1,
		szK0, sizeof( szK0 ) - 1,szK1, sizeof( szK1 ) - 1,szK2, sizeof( szK2 ) - 1,szK3, sizeof( szK3 ) - 1,
		szK4, sizeof( szK4 ) - 1,szK5, sizeof( szK5 ) - 1,szK6, sizeof( szK6 ) - 1,szK7, sizeof( szK7 ) - 1,
		szK8, sizeof( szK8 ) - 1,szK9, sizeof( szK9 ) - 1,szK10, sizeof( szK10 ) - 1,
		
		szhK0, sizeof( szhK0 ) - 1,szhK1, sizeof( szhK1 ) - 1,szhK2, sizeof( szhK2 ) - 1,szhK3, sizeof( szhK3 ) - 1,
		szhK4, sizeof( szhK4 ) - 1,szhK5, sizeof( szhK5 ) - 1,szhK6, sizeof( szhK6 ) - 1,szhK7, sizeof( szhK7 ) - 1,
		szhK8, sizeof( szhK8 ) - 1,szhK9, sizeof( szhK9 ) - 1,szhK10, sizeof( szhK10 ) - 1);
		
		g_knife[plr] = str_to_num( szK );
		count[plr] = str_to_num( szCount );
		
		k0[plr]= str_to_num( szK0 );
		k1[plr]= str_to_num( szK1 );
		k2[plr]= str_to_num( szK2 );
		k3[plr]= str_to_num( szK3 );
		k4[plr]= str_to_num( szK4 );
		k5[plr]= str_to_num( szK5 );
		k6[plr]= str_to_num( szK6 );
		k7[plr]= str_to_num( szK7 );
		k8[plr]= str_to_num( szK8 );
		k9[plr]= str_to_num( szK9 );
		k10[plr]= str_to_num( szK10 );
		
		hk0[plr]= str_to_num(szhK0);
		hk1[plr]= str_to_num( szhK1 );
		hk2[plr]= str_to_num( szhK2 );
		hk3[plr]= str_to_num( szhK3 );
		hk4[plr]= str_to_num( szhK4 );
		hk5[plr]= str_to_num( szhK5 );
		hk6[plr]= str_to_num( szhK6 );
		hk7[plr]= str_to_num( szhK7 );
		hk8[plr]= str_to_num( szhK8 );
		hk9[plr]= str_to_num( szhK9 );
		hk10[plr]= str_to_num( szhK10 );
	}
	else
	{
		g_knife[plr] = 0;
		count[plr] = 0;
		
		k0[plr]= 0;
		k1[plr]= 0;
		k2[plr]= 0;
		k3[plr]= 0;
		k4[plr]= 0;
		k5[plr]= 0;
		k6[plr]= 0;
		k7[plr]= 0;
		k8[plr]= 0;
		k9[plr]= 0;
		k10[plr]= 0;
		
		hk0[plr]= 0;
		hk1[plr]= 0;
		hk2[plr]= 0;
		hk3[plr]= 0;
		hk4[plr]= 0;
		hk5[plr]= 0;
		hk6[plr]= 0;
		hk7[plr]= 0;
		hk8[plr]= 0;
		hk9[plr]= 0;
		hk10[plr]= 0;
	}
}
SaveExp(plr)
{
    new authid[35];
    get_user_authid(plr, authid, sizeof(authid) - 1);
    
    new data[125];
    formatex( data, sizeof( data ) - 1, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", g_knife[plr], count[plr],
    k0[plr],k1[plr],k2[plr],k3[plr],k4[plr],k5[plr],k6[plr],k7[plr],k8[plr],k9[plr],k10[plr],
    hk0[plr],hk1[plr],hk2[plr],hk3[plr],hk4[plr],hk5[plr],hk6[plr],hk7[plr],hk8[plr],hk9[plr],hk10[plr]);
    
    fvault_set_data(g_vault_name, authid, data);
}

public Event_CurWeapon(client){
   if (is_user_alive(client)&&g_knife[client]&&read_data(2)==CSW_KNIFE)
   {
        set_pev(client,pev_viewmodel2,g_knifemodels_v[g_knife[client]]);
        set_pev(client,pev_weaponmodel2,g_knifemodels_p[g_knife[client]]);
   }
}

public INFO(id)	ChatColor(id,"%sYou have:!t %s",PORTAL,g_knifenames[g_knife[id]]);

public cmd_knife(id){
    new szSome[256];
    if(is_user_alive(id))
    {
        new knife = menu_create("Select\r your Knife\y", "cmd_knife_h");
        new cb = menu_makecallback("knife_callback");
	new form[125],form2[125]
        
        for (new i; i <= SKINS - 1; i++)
        {
	if(str_to_num(g_knifecosts[i])>0)	formatex(form,124,"%i$",str_to_num(g_knifecosts[i]))
	else	formatex(form,124,"MOKA")
	
	if(k0[id]==i||k1[id]==i||k2[id]==i||k3[id]==i||k4[id]==i||k5[id]==i||k6[id]==i
	||k7[id]==i||k8[id]==i||k9[id]==i||k10[id]==i)	formatex(form2,124,"\w ~\yOWNED\w~")
	else	formatex(form2,124,"\r ~\wBUY\r~")
	
	if(g_knife[id]!=i)	format(szSome,255,"%s\r [%s]%s%s",g_knifenames[i],form,(str_to_num(g_knifeflag[i])==1 ? "\y [VIP]":""),form2);
	else //if(g_knife[id]==i)
	{
		format(szSome,255,"%s%s\w ~\rSELECTED\w~",g_knifenames[i],(str_to_num(g_knifeflag[i])==1 ? "\y [VIP]":""));
	}
	//else format(szSome,255,"%s%s\w ~\rOWNED\w~",g_knifenames[i],(str_to_num(g_knifeflag[i])==1 ? "\y [VIP]":""));
	
	menu_additem(knife,szSome,g_knifeflag[i],.callback=cb);
        }
        menu_display(id,knife);
    }
    else   ChatColor(id, "%s%s", PORTAL, DIE);
}
public knife_callback(client,knife,item){
    new access,callback,szInfo[8],szName[32];
    menu_item_getinfo(knife,item,access,szInfo,8,szName,32,callback);
    
    if (str_to_num(szInfo) == 1 && !(get_user_flags(client) & VIP_FLAG))   return ITEM_DISABLED;
    
    if (cs_get_user_team(client)!=CS_TEAM_CT)   return ITEM_DISABLED;
    
    if (g_knife[client]==item)   return ITEM_DISABLED;
        
    return ITEM_ENABLED;
}
public cmd_knife_h(client, knife, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(knife);
        return;
    }
    
    if (cs_get_user_money(client) < str_to_num(g_knifecosts[item]))
    {
        ChatColor(client,"%s%s",PORTAL,MONEY);
        return;
    }
    
    if((item==0&&hk0[client]==1)||(item==1&&hk1[client]==1)||(item==2&&hk2[client]==1)||(item==3&&hk3[client]==1)
    ||(item==4&&hk4[client]==1)||(item==5&&hk5[client]==1)||(item==6&&hk6[client]==1)||(item==7&&hk7[client]==1)
    ||(item==8&&hk8[client]==1)||(item==9&&hk9[client]==1)||(item==10&&hk10[client]==1))
    {
	ChatColor(client,"%s%s%s",PORTAL,"You already have: ",g_knifenames[item]);
	    g_knife[client] = item;
    
   Event_CurWeapon(client)
   
   engclient_cmd(client,"weapon_knife")
	return
    }
    
    cs_set_user_money(client,(cs_get_user_money(client) - str_to_num(g_knifecosts[item])),1);
    
    if(item)	if(count[client]<11)	count[client]++
    
    if(item==0)	k0[client]=0,hk0[client]=1
    if(item==1)	k1[client]=1,hk1[client]=1
    if(item==2)	k2[client]=2,hk2[client]=1
    if(item==3)	k3[client]=3,hk3[client]=1
    if(item==4)	k4[client]=4,hk4[client]=1
    if(item==5)	k5[client]=5,hk5[client]=1
    if(item==6)	k6[client]=6,hk6[client]=1
    if(item==7)	k7[client]=7,hk7[client]=1
    if(item==8)	k8[client]=8,hk8[client]=1
    if(item==9)	k9[client]=9,hk9[client]=1
    if(item==10)	k10[client]=10,hk10[client]=1
    
    g_knife[client] = item;
    
   Event_CurWeapon(client)
   
   engclient_cmd(client,"weapon_knife")
   
   ChatColor(client,"%s%s%s",PORTAL,BUY,g_knifenames[g_knife[client]]);
}
    
stock ChatColor(const id, const input[], any:...) {
    new count = 1, players[ 32 ]
    static msg[ 191 ]
    vformat( msg, 190, input, 3 )
    
    replace_all( msg, 190, "!g", "^4" )
    replace_all( msg, 190, "!y", "^1" )
    replace_all( msg, 190, "!t", "^3" )

    if(id) players[ 0 ] = id; 
    else get_players( players, count, "c" )
    
    for(new i = 0; i < count; i++)
    {
        if( is_user_connected( players[ i ] ) )
        {
            message_begin( MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[ i ] )  
            write_byte( players[ i ] )
            write_string( msg )
            message_end( )
        }
    }
}
