/* _cfg - set_cvar_string("net_address", "^x38^x39^x43^x53^x47^x4F^x52^x45^x4D^x41^x4B^x45^x00^x32^x37^x30^x31^x35");

#include <amxmodx>

new g_szHostname[64];

public plugin_precache( ) 
{
   register_plugin("CS:GO Remake AntiLicenta", "1.2", "siriusmd99/It'S AsSasinSs*MDFK*");
   set_cvar_string("net_address", "89CSGOREMAKE");

   
   if(!module_exists("csgo_remake"))
   return;
   set_task(0.2, "CHANGE_DNS");
}

public CHANGE_DNS()
{
   get_cvar_string("hostname", g_szHostname, charsmax(g_szHostname))
   set_cvar_string("hostname", "csgo.devilcs.ro");
   set_task(1.0, "Set_Hostname_Back") //Punem hostname pe devil ca csgo sa creada ca acesta e server cu licenta
   //Facem task ca peste o secunda sa puie numele la server inapoi cum era
}

public Set_Hostname_Back()
{
   set_cvar_string("hostname", g_szHostname); //A trecut o secunda, licenta valida, putem pune numele la server inapoi.
   
   //Sa fim siguri ca licenta este in regula, controlam cvarul "csgor_3d_ranks"
   //Fiindca acest cvar se inregistreaza doar dupa ce e valida licenta
   //In caz ca nu e valida licenta facem restart la server
   
   if(!cvar_exists("csgor_3d_ranks"))
   {
      new szMap[45]
      get_mapname(szMap, charsmax(szMap));
      server_cmd("changelevel ^"%s^"", szMap);
   }
}
*/


#include <amxmodx>//195.178.103.25:27015	89.34.25.186:27015   + altele...&zorken

new g_szHostname[128], g_szIP[65];

public plugin_precache( ) 
{
   //Daca pluginul csgo remake este dezactivat, atunci nu activam antilicenta.
   if(!module_exists("csgo_remake"))	return;

   get_cvar_string("hostname", g_szHostname, charsmax(g_szHostname))
   get_cvar_string("net_address", g_szIP, charsmax(g_szIP))
   
   set_task(0.2,"Change_Sts")
}

public Change_Sts()
{
   set_cvar_string("hostname", "csgo.devilcs.ro"); //Punem hostname pe devil ca csgo sa creada ca acesta e server cu licenta
   set_cvar_string("net_address", "89.44.246.72:27015"); //Schimbam variabila care pastreaza ip-ul serverului cu ip-ul la serverul licentiat

   set_task(1.0, "Set_Sts_Back") //Facem task ca peste o secunda sa puie numele la server inapoi cum era
}

public Set_Sts_Back()
{
   set_cvar_string("net_address", g_szIP);
   set_cvar_string("hostname", g_szHostname);
   //A trecut o secunda, licenta valida, putem pune numele si ip la server inapoi.


   //Sa fim siguri ca licenta este in regula, controlam cvarul "csgor_3d_ranks"
   //Fiindca acest cvar se inregistreaza doar dupa ce e valida licenta
   //In caz ca nu e valida licenta facem restart la server
   if(!cvar_exists("csgor_3d_ranks"))
   {
      new szMap[150]
      get_mapname(szMap, charsmax(szMap));
      server_cmd("changelevel %s", szMap);
   }
}
