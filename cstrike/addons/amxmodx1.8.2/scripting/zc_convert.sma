#include <amxmodx>
#include <amxmisc>
#include <colorchat>
#include <zombiecrown>

#define ACCES_TO_CV ADMIN_RCON // FLAG - L	(users.ini)

new const szTag[]="Z.C System Convert"

new menu,title[2048],Key[3],Access,CallBack,isKey,szTemp[64],szTemp2[64]//,bm[512 char]

public plugin_init()
{
		register_clcmd("say /cv","ConvertMenu")
		register_clcmd("say /convert","ConvertMenu")

		register_cvar("develop_cv","0")//1-DOAR CU ACCES

		register_cvar("tokens_conv","1")
		register_cvar("points_conv","1")
		register_cvar("packs_conv","1")
		register_cvar("coins_conv","1")


//------------------------------------------------------------------------------;

		register_cvar("tokens_to_coins","")
		register_cvar("tokens_to_points","")
		register_cvar("tokens_to_packs","")

		register_clcmd("TOKENS_TO_COINS", "TokensCoins")
		register_clcmd("TOKENS_TO_POINTS", "TokensPoints")
		register_clcmd("TOKENS_TO_PACKS", "TokensPacks")

//------------------------------------------------------------------------------;

		register_cvar("points_to_coins","")
		register_cvar("points_to_tokens","")
		register_cvar("points_to_packs","")

		register_clcmd("POINTS_TO_COINS", "PointsCoins")
		register_clcmd("POINTS_TO_TOKENS", "PointsTokens")
		register_clcmd("POINTS_TO_PACKS", "PointsPacks")

//------------------------------------------------------------------------------;

		register_cvar("coins_to_points","")
		register_cvar("coins_to_tokens","")
		register_cvar("coins_to_packs","")

		register_clcmd("COINS_TO_POINTS", "CoinsPoints")
		register_clcmd("COINS_TO_TOKENS", "CoinsTokens")
		register_clcmd("COINS_TO_PACKS", "CoinsPacks")

//------------------------------------------------------------------------------;

		register_cvar("packs_to_points","")
		register_cvar("packs_to_tokens","")
		register_cvar("packs_to_coins","")

		register_clcmd("PACKS_TO_POINTS", "PacksPoints")
		register_clcmd("PACKS_TO_TOKENS", "PacksTokens")
		register_clcmd("PACKS_TO_COINS", "PacksCoins")

}

public ConvertMenu(id)
{
	if((get_cvar_num("develop_cv")==1)&&!(get_user_flags(id)&ACCES_TO_CV))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Momentan, Convertirea este dezactivata de catre^3 Developer^1!",szTag)
		return
	}

	formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nWhat Change^n",
	zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id))
	menu=menu_create(title,"ContentOne")


	if(get_cvar_num("tokens_conv")==1)
	{
		if(get_user_flags(id)&read_flags("q"))	menu_additem(menu,"\dTokens\y ->\r Ai nelimitat","")
		else
		{
		if(zp_get_user_tokens(id)>0)	menu_additem(menu,"\yTokens","1")
		else	menu_additem(menu,"\dTokens","")
		}
	}
	else	menu_additem(menu,"\yTokens\r [DISABLED]","")


	if(get_cvar_num("coins_conv")==1)
	{
		if(get_user_flags(id)&read_flags("r"))	menu_additem(menu,"\dCoins\y ->\r Ai nelimitat","")
		else
		{
		if(zp_get_user_coins(id)>0)	menu_additem(menu,"\yCoins","2")
		else	menu_additem(menu,"\dCoins","")
		}
	}
	else	menu_additem(menu,"\yCoins\r [DISABLED]","")


	if(get_cvar_num("packs_conv")==1)
	{
		if(get_user_flags(id)&read_flags("s"))	menu_additem(menu,"\dPacks\y ->\r Ai nelimitat","")
		else
		{
		if(zp_get_user_ammo_packs(id)>0)	menu_additem(menu,"\yPacks","3")
		else	menu_additem(menu,"\dPacks","")
		}
	}
	else	menu_additem(menu,"\yPacks\r [DISABLED]","")


	if(get_cvar_num("points_conv")==1)
	{
		if(get_user_flags(id)&read_flags("t"))	menu_additem(menu,"\dPoints\y ->\r Ai nelimitat","")
		else
		{
		if(zp_get_user_points(id)>0)	menu_additem(menu,"\yPoints","4")
		else	menu_additem(menu,"\dPoints","")
		}
	}
	else	menu_additem(menu,"\yPoints\r [DISABLED]","")


	menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
	menu_display(id,menu)
}
public ContentOne(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nSchimba Tokens in :^n",
			zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id))
			menu=menu_create(title,"ContentTwo")

			menu_additem(menu,"\yCoins","1")
			menu_additem(menu,"\yPacks","2")
			menu_additem(menu,"\yPoints","3")

			menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
			menu_display(id,menu)
		}

		case 2:
		{
			formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nSchimba Coins in :^n",
			zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id))
			menu=menu_create(title,"ContentSeven")

			menu_additem(menu,"\yTokens","1")
			menu_additem(menu,"\yPacks","2")
			menu_additem(menu,"\yPoints","3")

			menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
			menu_display(id,menu)
		}

		case 3:
		{
			formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nSchimba Packs in :^n",
			zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id))
			menu=menu_create(title,"ContentEleven")

			menu_additem(menu,"\yTokens","1")
			menu_additem(menu,"\yCoins","2")
			menu_additem(menu,"\yPoints","3")

			menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
			menu_display(id,menu)
		}

		case 4:
		{
			formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nSchimba Points in :^n",
			zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id))
			menu=menu_create(title,"ContentFifteen")

			menu_additem(menu,"\yTokens","1")
			menu_additem(menu,"\yCoins","2")
			menu_additem(menu,"\yPacks","3")

			menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
			menu_display(id,menu)
		}
	}

	return 1
}





public ContentFifteen(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nChange Points in Tokens^n",
			zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id))
			menu=menu_create(title,"ContentSixteen")

			menu_additem(menu,"\yIntrodu suma","1")

			menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
			menu_display(id,menu)
		}
		case 2:
		{
			formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nChange Points in Coins^n",
			zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id))
			menu=menu_create(title,"ContentSeventeen")

			menu_additem(menu,"\yIntrodu suma","1")

			menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
			menu_display(id,menu)
		}
		case 3:
		{
			formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nChange Points in Packs^n",
			zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id))
			menu=menu_create(title,"ContentEighteen")

			menu_additem(menu,"\yIntrodu suma","1")

			menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
			menu_display(id,menu)
		}
	}

	return 1
}



public ContentEighteen(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			if(zp_get_user_points(id)<0)
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Points^1 pentru convertirea in^4 Packs",szTag)
				return 1
			}
			else
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Introdu^3 SUMA^1 pentru^4 Convertie^1!(vezi sus)",szTag)

				client_cmd(id,"messagemode POINTS_TO_PACKS")

				//return 1
			}
		}
	}

	return 1
}
public PointsPacks(id)
{
	read_args(szTemp,charsmax(szTemp))
	remove_quotes(szTemp)

	if(zp_get_user_points(id)<0)
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Points^1 pentru convertirea in^4 Packs",szTag)
		return PLUGIN_HANDLED
	}

	if(str_to_num(szTemp)>zp_get_user_points(id))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu, nu, n-ai^3 sanse^1.",szTag)
		return PLUGIN_HANDLED
	}

	if(!str_to_num(szTemp))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Introducerea nu cuprinde doar^3 Cifre^1.",szTag)
		client_cmd(id,"messagemode POINTS_TO_PACKS")
	}
	else
	{
		szTemp2=szTemp

		formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nConfirm to change\y %d\w Points\r to\y %d\w Packs\r^nTi-a ramas\y %d\r rest.^n",
		zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id),str_to_num(szTemp),str_to_num(szTemp)*get_cvar_num("points_to_packs"),zp_get_user_points(id)-str_to_num(szTemp))
		menu=menu_create(title,"ContentNineteen")

		menu_additem(menu,"\yConfirm","1")
		menu_additem(menu,"\yClose","2")
		menu_additem(menu,"\yNew Convert","3")

		menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
		menu_display(id,menu)
	}

	return PLUGIN_HANDLED
}
public ContentNineteen(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			zp_set_user_points(id,zp_get_user_points(id)-str_to_num(szTemp2))
			zp_set_user_ammo_packs(id,zp_get_user_ammo_packs(id)+str_to_num(szTemp2)*get_cvar_num("points_to_packs"))

			SaveDate(id)
		}
		case 2:	show_menu(id,0,"",-1)
		case 3:	ConvertMenu(id)
	}

	return 1
}


public ContentSeventeen(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			if(zp_get_user_points(id)<0)
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Points^1 pentru convertirea in^4 Coins",szTag)
				return 1
			}
			else
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Introdu^3 SUMA^1 pentru^4 Convertie^1!(vezi sus)",szTag)

				client_cmd(id,"messagemode POINTS_TO_COINS")

				return 1
			}
		}
	}

	return 1
}
public PointsCoins(id)
{
	read_args(szTemp,charsmax(szTemp))
	remove_quotes(szTemp)

	if(zp_get_user_points(id)<0)
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Points^1 pentru convertirea in^4 Coins",szTag)
		return PLUGIN_HANDLED
	}

	if(str_to_num(szTemp)>zp_get_user_points(id))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu, nu, n-ai^3 sanse^1.",szTag)
		return PLUGIN_HANDLED
	}

	if(!str_to_num(szTemp))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Introducerea nu cuprinde doar^3 Cifre^1.",szTag)
		client_cmd(id,"messagemode POINTS_TO_COINS")
	}
	else
	{
		szTemp2=szTemp

		formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nAi schimbat\y %d\w Points\r in\y %d Coins\r^nTi-a ramas\y %d\r rest.^n",
		zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id),str_to_num(szTemp),str_to_num(szTemp)*get_cvar_num("points_to_coins"),zp_get_user_points(id))
		menu=menu_create(title,"ContentFourea")

		menu_additem(menu,"\yConfirm","1")
		menu_additem(menu,"\yClose","2")
		menu_additem(menu,"\yNew Convert","3")

		menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
		menu_display(id,menu)
	}

	return PLUGIN_HANDLED
}
public ContentFourea(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
		zp_set_user_points(id,zp_get_user_points(id)-str_to_num(szTemp2))
		zp_set_user_coins(id,zp_get_user_coins(id)+str_to_num(szTemp2)*get_cvar_num("points_to_coins"))

		SaveDate(id)
		}
		case 2:	show_menu(id,0,"",-1)
		case 3:	ConvertMenu(id)
	}

	return 1
}




public ContentSixteen(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			if(zp_get_user_points(id)<0)
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Points^1 pentru convertirea in^4 Tokens",szTag)
				return 1
			}
			else
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Introdu^3 SUMA^1 pentru^4 Convertie^1!(vezi sus)",szTag)

				client_cmd(id,"messagemode POINTS_TO_TOKENS")

				return 1
			}
		}
	}

	return 1
}
public PointsTokens(id)
{
	read_args(szTemp,charsmax(szTemp))
	remove_quotes(szTemp)

	if(zp_get_user_points(id)<0)
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Points^1 pentru convertirea in^4 Tokens",szTag)
		return PLUGIN_HANDLED
	}

	if(str_to_num(szTemp)>zp_get_user_points(id))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu, nu, n-ai^3 sanse^1.",szTag)
		return PLUGIN_HANDLED
	}

	if(!str_to_num(szTemp))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Introducerea nu cuprinde doar^3 Cifre^1.",szTag)
		client_cmd(id,"messagemode POINTS_TO_TOKENS")
	}
	else
	{
		szTemp2=szTemp

		formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nAi schimbat\y %d\w Points\r in\y %d\w Tokens\r^nTi-a ramas\y %d\w rest.^n",
		zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id),str_to_num(szTemp),str_to_num(szTemp)*get_cvar_num("points_to_tokens"),zp_get_user_points(id))
		menu=menu_create(title,"ContentFoureb")

		menu_additem(menu,"\yConfirm","1")
		menu_additem(menu,"\yClose","2")
		menu_additem(menu,"\yNew Convert","3")

		menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
		menu_display(id,menu)
	}

	return PLUGIN_HANDLED
}
public ContentFoureb(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
		zp_set_user_points(id,zp_get_user_points(id)-str_to_num(szTemp2))
		zp_set_user_tokens(id,zp_get_user_tokens(id)+str_to_num(szTemp2)*get_cvar_num("points_to_tokens"))

		SaveDate(id)
		}
		case 2:	show_menu(id,0,"",-1)
		case 3:	ConvertMenu(id)
	}

	return 1
}







public ContentEleven(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nChange Packs in Tokens^n",
			zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id))
			menu=menu_create(title,"ContentTwelf")

			menu_additem(menu,"\yIntrodu suma","1")

			menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
			menu_display(id,menu)
		}
		case 2:
		{
			formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nChange Packs in Coins^n",
			zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id))
			menu=menu_create(title,"ContentThirteen")

			menu_additem(menu,"\yIntrodu suma","1")

			menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
			menu_display(id,menu)
		}
		case 3:
		{
			formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nChange Packs in Points^n",
			zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id))
			menu=menu_create(title,"ContentFourteen")

			menu_additem(menu,"\yIntrodu suma","1")

			menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
			menu_display(id,menu)
		}
	}

	return 1
}


public ContentFourteen(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			if(zp_get_user_ammo_packs(id)<0)
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Packs^1 pentru convertirea in^4 Points",szTag)
				return 1
			}
			else
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Introdu^3 SUMA^1 pentru^4 Convertie^1!(vezi sus)",szTag)

				client_cmd(id,"messagemode PACKS_TO_POINTS")

				return 1
			}
		}
	}

	return 1
}
public PacksPoints(id)
{
	read_args(szTemp,charsmax(szTemp))
	remove_quotes(szTemp)

	if(zp_get_user_ammo_packs(id)<0)
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Packs^1 pentru convertirea in^4 Points",szTag)
		return PLUGIN_HANDLED
	}

	if(str_to_num(szTemp)>zp_get_user_ammo_packs(id))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu, nu, n-ai^3 sanse^1.",szTag)
		return PLUGIN_HANDLED
	}

	if(!str_to_num(szTemp))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Introducerea nu cuprinde doar^3 Cifre^1.",szTag)
		client_cmd(id,"messagemode PACKS_TO_TOKENS")
	}
	else
	{
		szTemp2=szTemp

		formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nAi schimbat\y %d\w Packs\r in\y %d\w Points\r^nTi-a ramas\y %d\r rest.^n",
		zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id),str_to_num(szTemp),str_to_num(szTemp)*get_cvar_num("packs_to_points"),zp_get_user_ammo_packs(id))
		menu=menu_create(title,"ContentFourec")

		menu_additem(menu,"\yConfirm","1")
		menu_additem(menu,"\yClose","2")
		menu_additem(menu,"\yNew Convert","3")

		menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
		menu_display(id,menu)
	}

	return PLUGIN_HANDLED
}
public ContentFourec(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
		zp_set_user_ammo_packs(id,zp_get_user_ammo_packs(id)-str_to_num(szTemp2))
		zp_set_user_points(id,zp_get_user_points(id)+str_to_num(szTemp2)*get_cvar_num("packs_to_points"))

		SaveDate(id)
		}
		case 2:	show_menu(id,0,"",-1)
		case 3:	ConvertMenu(id)
	}

	return 1
}






public ContentThirteen(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			if(zp_get_user_ammo_packs(id)<0)
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Packs^1 pentru convertirea in^4 Coins",szTag)
				return 1
			}
			else
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Introdu^3 SUMA^1 pentru^4 Convertie^1!(vezi sus)",szTag)

				client_cmd(id,"messagemode PACKS_TO_COINS")

				return 1
			}
		}
	}

	return 1
}
public PacksCoins(id)
{
	read_args(szTemp,charsmax(szTemp))
	remove_quotes(szTemp)

	if(zp_get_user_ammo_packs(id)<0)
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Packs^1 pentru convertirea in^4 Coins",szTag)
		return PLUGIN_HANDLED
	}

	if(str_to_num(szTemp)>zp_get_user_ammo_packs(id))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu, nu, n-ai^3 sanse^1.",szTag)
		return PLUGIN_HANDLED
	}

	if(!str_to_num(szTemp))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Introducerea nu cuprinde doar^3 Cifre^1.",szTag)
		client_cmd(id,"messagemode PACKS_TO_TOKENS")
	}
	else
	{
		szTemp2=szTemp

		formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nAi schimbat\y %d\w Packs\r in\y %d\w Coins\r^nTi-a ramas\y %d\w rest.^n",
		zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id),str_to_num(szTemp),str_to_num(szTemp)*get_cvar_num("packs_to_coins"),zp_get_user_ammo_packs(id))
		menu=menu_create(title,"ContentFourej")

		menu_additem(menu,"\yConfirm","1")
		menu_additem(menu,"\yClose","2")
		menu_additem(menu,"\yNew Convert","3")

		menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
		menu_display(id,menu)
	}

	return PLUGIN_HANDLED
}
public ContentFourej(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
		zp_set_user_ammo_packs(id,zp_get_user_ammo_packs(id)-str_to_num(szTemp2))
		zp_set_user_coins(id,zp_get_user_coins(id)+str_to_num(szTemp2)*get_cvar_num("packs_to_coins"))

		SaveDate(id)
		}
		case 2:	show_menu(id,0,"",-1)
		case 3:	ConvertMenu(id)
	}

	return 1
}








public ContentTwelf(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			if(zp_get_user_ammo_packs(id)<0)
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Packs^1 pentru convertirea in^4 Tokens",szTag)
				return 1
			}
			else
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Introdu^3 SUMA^1 pentru^4 Convertie^1!(vezi sus)",szTag)

				client_cmd(id,"messagemode PACKS_TO_TOKENS")

				return 1
			}
		}
	}

	return 1
}
public PacksTokens(id)
{
	read_args(szTemp,charsmax(szTemp))
	remove_quotes(szTemp)

	if(zp_get_user_ammo_packs(id)<0)
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Packs^1 pentru convertirea in^4 Tokens",szTag)
		return PLUGIN_HANDLED
	}

	if(str_to_num(szTemp)>zp_get_user_ammo_packs(id))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu, nu, n-ai^3 sanse^1.",szTag)
		return PLUGIN_HANDLED
	}

	if(!str_to_num(szTemp))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Introducerea nu cuprinde doar^3 Cifre^1.",szTag)
		client_cmd(id,"messagemode PACKS_TO_TOKENS")
	}
	else
	{
		szTemp2=szTemp

		formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nAi schimbat\y %d\w Packs\r in\y %d\w Tokens\r^nTi-a ramas\y %d\r rest.^n",
		zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id),str_to_num(szTemp),str_to_num(szTemp)*get_cvar_num("packs_to_tokens"),zp_get_user_ammo_packs(id))
		menu=menu_create(title,"ContentFoured")

		menu_additem(menu,"\yConfirm","1")
		menu_additem(menu,"\yClose","2")
		menu_additem(menu,"\yNew Convert","3")

		menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
		menu_display(id,menu)
	}

	return PLUGIN_HANDLED
}
public ContentFoured(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
		zp_set_user_ammo_packs(id,zp_get_user_ammo_packs(id)-str_to_num(szTemp2))
		zp_set_user_tokens(id,zp_get_user_tokens(id)+str_to_num(szTemp2)*get_cvar_num("packs_to_tokens"))

		SaveDate(id)
		}
		case 2:	show_menu(id,0,"",-1)
		case 3:	ConvertMenu(id)
	}

	return 1
}








public ContentSeven(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nChange Coins in Tokens^n",
			zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id))
			menu=menu_create(title,"ContentEight")

			menu_additem(menu,"\yIntrodu suma","1")

			menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
			menu_display(id,menu)
		}
		case 2:
		{
			formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nChange Coins in Packs^n",
			zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id))
			menu=menu_create(title,"ContentNine")

			menu_additem(menu,"\yIntrodu suma","1")

			menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
			menu_display(id,menu)
		}
		case 3:
		{
			formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nChange Coins in Points^n",
			zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id))
			menu=menu_create(title,"ContentTen")

			menu_additem(menu,"\yIntrodu suma","1")

			menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
			menu_display(id,menu)
		}
	}

	return 1
}


public ContentTen(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			if(zp_get_user_coins(id)<0)
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Coins^1 pentru convertirea in^4 Points",szTag)
				return 1
			}
			else
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Introdu^3 SUMA^1 pentru^4 Convertie^1!(vezi sus)",szTag)

				client_cmd(id,"messagemode COINS_TO_POINTS")

				return 1
			}
		}
	}

	return 1
}
public CoinsPoints(id)
{
	read_args(szTemp,charsmax(szTemp))
	remove_quotes(szTemp)

	if(zp_get_user_coins(id)<0)
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Coins^1 pentru convertirea in^4 Points",szTag)
		return PLUGIN_HANDLED
	}

	if(str_to_num(szTemp)>zp_get_user_coins(id))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu, nu, n-ai^3 sanse^1.",szTag)
		return PLUGIN_HANDLED
	}

	if(!str_to_num(szTemp))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Introducerea nu cuprinde doar^3 Cifre^1.",szTag)
		client_cmd(id,"messagemode COINS_TO_PACKS")
	}
	else
	{
		szTemp2=szTemp

		formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nAi schimbat\y %d\w Coins\r in\y %d\w Packs\r^nTi-a ramas\y %d\r rest.^n",
		zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id),str_to_num(szTemp),str_to_num(szTemp)*get_cvar_num("coins_to_points"),zp_get_user_coins(id))
		menu=menu_create(title,"ContentFourek")

		menu_additem(menu,"\yConfirm","1")
		menu_additem(menu,"\yClose","2")
		menu_additem(menu,"\yNew Convert","3")

		menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
		menu_display(id,menu)
	}

	return PLUGIN_HANDLED
}
public ContentFourek(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
		zp_set_user_coins(id,zp_get_user_coins(id)-str_to_num(szTemp2))
		zp_set_user_points(id,zp_get_user_points(id)+str_to_num(szTemp2)*get_cvar_num("coins_to_points"))

		SaveDate(id)
		}
		case 2:	show_menu(id,0,"",-1)
		case 3:	ConvertMenu(id)
	}

	return 1
}








public ContentNine(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			if(zp_get_user_coins(id)<0)
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Coins^1 pentru convertirea in^4 Packs",szTag)
				return 1
			}
			else
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Introdu^3 SUMA^1 pentru^4 Convertie^1!(vezi sus)",szTag)

				client_cmd(id,"messagemode COINS_TO_PACKS")

				return 1
			}
		}
	}

	return 1
}
public CoinsPacks(id)
{
	read_args(szTemp,charsmax(szTemp))
	remove_quotes(szTemp)

	if(zp_get_user_coins(id)<0)
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Coins^1 pentru convertirea in^4 Packs",szTag)
		return PLUGIN_HANDLED
	}

	if(str_to_num(szTemp)>zp_get_user_coins(id))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu, nu, n-ai^3 sanse^1.",szTag)
		return PLUGIN_HANDLED
	}

	if(!str_to_num(szTemp))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Introducerea nu cuprinde doar^3 Cifre^1.",szTag)
		client_cmd(id,"messagemode COINS_TO_PACKS")
	}
	else
	{
		szTemp2=szTemp

		formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nAi schimbat\y %d\w Coins\r in\y %d\w Packs\r^nTi-a ramas\y %d\r rest.^n",
		zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id),str_to_num(szTemp),str_to_num(szTemp)*get_cvar_num("coins_to_packs"),zp_get_user_coins(id))
		menu=menu_create(title,"ContentFouree")

		menu_additem(menu,"\yConfirm","1")
		menu_additem(menu,"\yClose","2")
		menu_additem(menu,"\yNew Convert","3")

		menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
		menu_display(id,menu)
	}

	return PLUGIN_HANDLED
}
public ContentFouree(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
		zp_set_user_coins(id,zp_get_user_coins(id)-str_to_num(szTemp2))
		zp_set_user_ammo_packs(id,zp_get_user_ammo_packs(id)+str_to_num(szTemp2)*get_cvar_num("coins_to_packs"))

		SaveDate(id)
		}
		case 2:	show_menu(id,0,"",-1)
		case 3:	ConvertMenu(id)
	}

	return 1
}











public ContentEight(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			if(zp_get_user_coins(id)<0)
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Coins^1 pentru convertirea in^4 Tokens",szTag)
				return 1
			}
			else
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Introdu^3 SUMA^1 pentru^4 Convertie^1!(vezi sus)",szTag)

				client_cmd(id,"messagemode COINS_TO_TOKENS")

				return 1
			}
		}
	}

	return 1
}
public CoinsTokens(id)
{
	read_args(szTemp,charsmax(szTemp))
	remove_quotes(szTemp)

	if(zp_get_user_coins(id)<0)
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Coins^1 pentru convertirea in^4 Tokens",szTag)
		return PLUGIN_HANDLED
	}

	if(str_to_num(szTemp)>zp_get_user_coins(id))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu, nu, n-ai^3 sanse^1.",szTag)
		return PLUGIN_HANDLED
	}

	if(!str_to_num(szTemp))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Introducerea nu cuprinde doar^3 Cifre^1.",szTag)
		client_cmd(id,"messagemode COINS_TO_TOKENS")
	}
	else
	{
		szTemp2=szTemp

		formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nAi schimbat\y %d\w Coins\r in\y %d\w Tokens\r^nTi-a ramas\y %d\w rest.^n",
		zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id),str_to_num(szTemp),str_to_num(szTemp)*10,zp_get_user_coins(id))
		menu=menu_create(title,"ContentFouref")

		menu_additem(menu,"\yConfirm","1")
		menu_additem(menu,"\yClose","2")
		menu_additem(menu,"\yNew Convert","3")

		menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
		menu_display(id,menu)
	}

	return PLUGIN_HANDLED
}
public ContentFouref(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
		zp_set_user_coins(id,zp_get_user_coins(id)-str_to_num(szTemp2))
		zp_set_user_tokens(id,zp_get_user_tokens(id)+str_to_num(szTemp2)*10)

		SaveDate(id)
		}
		case 2:	show_menu(id,0,"",-1)
		case 3:	ConvertMenu(id)
	}

	return 1
}









public ContentTwo(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nChange Tokens in Coins^n",
			zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id))
			menu=menu_create(title,"ContentThree")

			menu_additem(menu,"\yIntrodu suma","1")

			menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
			menu_display(id,menu)
		}
		case 2:
		{
			formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nChange Tokens in Packs^n",
			zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id))
			menu=menu_create(title,"ContentFive")

			menu_additem(menu,"\yIntrodu suma","1")

			menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
			menu_display(id,menu)
		}
		case 3:
		{
			formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nChange Tokens in Points^n",
			zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id))
			menu=menu_create(title,"ContentSix")

			menu_additem(menu,"\yIntrodu suma","1")

			menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
			menu_display(id,menu)
		}
	}

	return 1
}


public ContentSix(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			if(zp_get_user_tokens(id)<0)
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Tokens^1 pentru convertirea in^4 Points",szTag)
				return 1
			}
			else
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Introdu^3 SUMA^1 pentru^4 Convertie^1!(vezi sus)",szTag)

				client_cmd(id,"messagemode TOKENS_TO_POINTS")

				return 1
			}
		}
	}

	return 1
}
public TokensPoints(id)
{
	read_args(szTemp,charsmax(szTemp))
	remove_quotes(szTemp)

	if(zp_get_user_tokens(id)<0)
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Tokens^1 pentru convertirea in^4 Points",szTag)
		return PLUGIN_HANDLED
	}

	if(str_to_num(szTemp)>zp_get_user_tokens(id))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu, nu, n-ai^3 sanse^1.",szTag)
		return PLUGIN_HANDLED
	}

	if(!str_to_num(szTemp))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Introducerea nu cuprinde doar^3 Cifre^1.",szTag)
		client_cmd(id,"messagemode TOKENS_TO_POINTS")
	}
	else
	{
		szTemp2=szTemp

		formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nAi schimbat\y %d\w Tokens\r in\y %d\w Points\r^nTi-a ramas\y %d\r rest.^n",
		zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id),str_to_num(szTemp),str_to_num(szTemp)*get_cvar_num("tokens_to_points"),zp_get_user_tokens(id))
		menu=menu_create(title,"ContentFoureg")

		menu_additem(menu,"\yConfirm","1")
		menu_additem(menu,"\yClose","2")
		menu_additem(menu,"\yNew Convert","3")

		menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
		menu_display(id,menu)
	}

	return PLUGIN_HANDLED
}
public ContentFoureg(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
		zp_set_user_tokens(id,zp_get_user_tokens(id)-str_to_num(szTemp2))
		zp_set_user_points(id,zp_get_user_points(id)+str_to_num(szTemp2)*get_cvar_num("tokens_to_points"))

		SaveDate(id)
		}
		case 2:	show_menu(id,0,"",-1)
		case 3:	ConvertMenu(id)
	}

	return 1
}








public ContentFive(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			if(zp_get_user_tokens(id)<0)
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Tokens^1 pentru convertirea in^4 Packs",szTag)
				return 1
			}
			else
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Introdu^3 SUMA^1 pentru^4 Convertie^1!(vezi sus)",szTag)

				client_cmd(id,"messagemode TOKENS_TO_PACKS")

				return 1
			}
		}
	}

	return 1
}
public TokensPacks(id)
{
	read_args(szTemp,charsmax(szTemp))
	remove_quotes(szTemp)

	if(zp_get_user_tokens(id)<0)
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Tokens^1 pentru convertirea in^4 Packs",szTag)
		return PLUGIN_HANDLED
	}

	if(str_to_num(szTemp)>zp_get_user_tokens(id))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu, nu, n-ai^3 sanse^1.",szTag)
		return PLUGIN_HANDLED
	}

	if(!str_to_num(szTemp))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Introducerea nu cuprinde doar^3 Cifre^1.",szTag)
		client_cmd(id,"messagemode TOKENS_TO_PACKS")
	}
	else
	{
		szTemp2=szTemp

		formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nAi schimbat\y %d\w Tokens\r in\y %d\w Packs\r^nTi-a ramas\y %d\r rest.^n",
		zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id),str_to_num(szTemp),str_to_num(szTemp)*get_cvar_num("tokens_to_packs"),zp_get_user_tokens(id))
		menu=menu_create(title,"ContentFoureh")

		menu_additem(menu,"\yConfirm","1")
		menu_additem(menu,"\yClose","2")
		menu_additem(menu,"\yNew Convert","3")

		menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
		menu_display(id,menu)
	}

	return PLUGIN_HANDLED
}
public ContentFoureh(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
		zp_set_user_tokens(id,zp_get_user_tokens(id)-str_to_num(szTemp2))
		zp_set_user_ammo_packs(id,zp_get_user_ammo_packs(id)+str_to_num(szTemp2)*get_cvar_num("tokens_to_packs"))

		SaveDate(id)
		}
		case 2:	show_menu(id,0,"",-1)
		case 3:	ConvertMenu(id)
	}

	return 1
}








public ContentThree(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
			//new iPret=zp_get_user_coins(id)-15

			if(zp_get_user_tokens(id)/*iPret*/<0)
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Tokens^1 pentru convertirea in^4 Coins",szTag)
				return 1
			}
			else
			{
				ColorChat(id,NORMAL,"^1[^4%s^1] Introdu^3 SUMA^1 pentru^4 Convertie^1!(vezi sus)",szTag)

				//zp_set_user_tokens(id,zp_get_user_tokens(id)+1)
				//zp_set_user_coins(id,iPret)

				client_cmd(id,"messagemode TOKENS_TO_COINS")

				return 1
			}
		}
	}

	return 1
}
public TokensCoins(id)
{
	read_args(szTemp,charsmax(szTemp))
	remove_quotes(szTemp)

	if(zp_get_user_tokens(id)<0)
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu ai destule^3 Tokens^1 pentru convertirea in^4 Packs",szTag)
		return PLUGIN_HANDLED
	}

	if(str_to_num(szTemp)>zp_get_user_tokens(id))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Nu, nu, n-ai^3 sanse^1.",szTag)
		return PLUGIN_HANDLED
	}

	if(!str_to_num(szTemp))
	{
		ColorChat(id,NORMAL,"^1[^4%s^1] Introducerea nu cuprinde doar^3 Cifre^1.",szTag)
		client_cmd(id,"messagemode TOKENS_TO_COINS")
	}
	else
	{
		szTemp2=szTemp

		formatex(title,charsmax(title),"\ySystem convert Zombie Crown\w^nAi\r [\y %d\w Tokens\r ]\d |\r [\y %d\w Coins\r ]\d |\r [\y %d\w Points\r ]\d |\r [\y %d\w Packs\r ]\r^n^nAi schimbat\y %d\w Tokens\r in\y %d\w Coins\r^nTi-a ramas\y %d\r rest.^n",
		zp_get_user_tokens(id),zp_get_user_coins(id),zp_get_user_points(id),zp_get_user_ammo_packs(id),str_to_num(szTemp),str_to_num(szTemp)*get_cvar_num("tokens_to_coins"),zp_get_user_tokens(id))
		menu=menu_create(title,"ContentFourei")

		menu_additem(menu,"\yConfirm","1")
		menu_additem(menu,"\yClose","2")
		menu_additem(menu,"\yNew Convert","3")

		menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
		menu_display(id,menu)
	}

	return PLUGIN_HANDLED
}
public ContentFourei(id,Menu,Item)
{
	if(Item<0)	return 0

	menu_item_getinfo(Menu,Item,Access,Key,2,_,_,CallBack)
	isKey=str_to_num(Key)

	switch(isKey)
	{
		case 1:
		{
		zp_set_user_tokens(id,zp_get_user_tokens(id)-str_to_num(szTemp2))
		zp_set_user_coins(id,zp_get_user_coins(id)+str_to_num(szTemp2)*get_cvar_num("tokens_to_coins"))

		SaveDate(id)
		}
		case 2:	show_menu(id,0,"",-1)
		case 3:	ConvertMenu(id)
	}

	return 1
}
