#include <amxmodx>
#include <fake_queries>

//new const iPlayers = 25;
//new const iMaxPlayers = 32;
new const iBotsNum = 0;

public plugin_init()
{
	fq_set_players(random_num(1,5))
	fq_set_maxplayers(get_maxplayers())
	fq_set_botsnum(iBotsNum)

	set_task(1.0,"TASK",.flags="b")
	set_task(random_float(180.0,300.0),"TASK2",.flags="b")
}

public TASK()	fq_set_players(random_num(2,6))
public TASK2()	fq_set_players(random_num(1,18))
