//IDEAL PT TNI

#include amxmodx
#include fakemeta

#define BOTS_NUM	2

new const g_Names[BOTS_NUM][]=
{
   "IP - 89.44.246.71:27015",
   "DNS: SUD.EVILS.RO"
};

//#define HUD_AM

#if defined HUD_AM
new Array:g_Messages;
new g_Handler;
#endif

new g_Query[256];

public plugin_init()
{
#if defined HUD_AM
	new a = fopen("z_out_hud_advertisements.ini", "r");

	g_Handler = CreateHudSyncObj();

	g_Messages = ArrayCreate(512);
	if (a)
	{
		new Line[512];

		while (!feof(a))
		{
			fgets(a, Line, sizeof(Line) - 1);

			trim(Line);

			if (Line[0])
			{
				while(replace(Line, sizeof(Line)-1, "\n", "^n")){}

				ArrayPushString(g_Messages, Line);
			}
		}

		fclose(a);
	} else log_amx("Failed to open z_out_advertisements.ini file!");

	if (ArraySize(g_Messages))
	{
		set_task(30.0, "TaskAvertise", .flags = "b");
	}
#endif

	set_task( 15.0, "TaskManageBots", .flags="b" );
}
new g_Bot[33], g_BotsCount;
public TaskManageBots(){
	static PlayersNum; PlayersNum  = get_playersnum( 1 );
	if( PlayersNum < get_maxplayers() - 1 && g_BotsCount < BOTS_NUM ) {
		CreateBot();
	}
	if( PlayersNum > get_maxplayers() - 1 && g_BotsCount >= BOTS_NUM ) {
		RemoveBot();
	}}

public client_disconnect(i)
{
	if( g_Bot[ i ] ) {
		g_Bot[ i ] = 0, g_BotsCount -- ;
	}
}

RemoveBot(){
	static i;
	for( i = 1; i <= get_maxplayers(); i++ ) {
		if( g_Bot[ i ] ) {
			server_cmd( "kick #%d", get_user_userid( i ) );break;
		}}}

CreateBot(){
	static Bot;
	format( g_Query, 255, "%s",g_Names[g_BotsCount] );Bot = engfunc( EngFunc_CreateFakeClient, g_Query );
	if( Bot > 0 &&pev_valid(Bot)/*&&//!//Bot*/) {
		dllfunc(MetaFunc_CallGameEntity,"player",Bot);
		set_pev(Bot,pev_flags,FL_FAKECLIENT);
		set_pev(Bot, pev_model, "");
		set_pev(Bot, pev_viewmodel2, "");
		set_pev(Bot, pev_modelindex, 0);
		set_pev(Bot, pev_renderfx, kRenderFxNone);
		set_pev(Bot, pev_rendermode, kRenderTransAlpha);
		set_pev(Bot, pev_renderamt, 0.0);
		set_pdata_int(Bot,114,0);
		message_begin(MSG_ALL,get_user_msgid("TeamInfo"));
		write_byte(Bot);
		write_string("UNASSIGNED");
		message_end();
		g_Bot[Bot]=1;
		g_BotsCount++;
	}
}

#if defined HUD_AM
public TaskAvertise()
{
	static a,msg[512];

	for (a = 1; a <= get_maxplayers(); a++)
	{
		if (is_user_connected(a) && !is_user_bot(a) && !is_user_hltv(a))
		{
			set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), -1.0, 0.0777, random_num(0, 2), random_float(0.7, 0.9), 12.0, random_float(0.37, 0.4), random_float(0.37, 0.4), 4);
			ArrayGetString(g_Messages,random_num(0,ArraySize(g_Messages)-1),msg,511);
			ShowSyncHudMsg(a, g_Handler, msg);
		}
	}
}
#endif
