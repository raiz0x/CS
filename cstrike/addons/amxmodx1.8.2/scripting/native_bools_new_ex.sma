#include <amxmodx>

/*
#include <amxmodx>
#include <amxmisc>
//deci merg și fără bool:
native get_id_bool(id)
native get_id_new(id)
native get_bool_new()
native get_new()

public plugin_init() {
	register_clcmd("say /info_id_bool","a")
	register_clcmd("say /info_id_new","b")
	register_clcmd("say /info_bool_new","c")
	register_clcmd("say /info_new","d")
}
//deci ==true e defapt ==1..
public a(id)	client_print(id,print_chat,"VALOAREA PENTRU ID_BOOL: %s",get_id_bool(id)==1?"ADEVARATA":"FALSA")
public b(id)	client_print(id,print_chat,"VALOAREA PENTRU ID_NEW: %s",get_id_new(id)==1?"ADEVARATA":"FALSA")
public c(id)	client_print(id,print_chat,"VALOAREA PENTRU BOOL_NEW: %s",get_bool_new()==1?"ADEVARATA":"FALSA")
public d(id)	client_print(id,print_chat,"VALOAREA PENTRU NEW: %s",get_new()==1?"ADEVARATA":"FALSA")
*/


new asd
new bool:asdd
new bool:asddd[33]
new asdddd[33]

public plugin_init()
{
	register_clcmd("say /ac1","d")
	register_clcmd("say /ac2","a")
	register_clcmd("say /ac3","f")
	register_clcmd("say /ac4","q")
}

public plugin_natives()
{
	register_native("get_id_bool", "native_get_id_bool", 1)
	register_native("get_id_new", "native_get_id_new", 1)

	register_native("get_bool_new", "native_get_bool_new")
	register_native("get_new", "native_get_new")
}

public native_get_id_bool(id)
{
	if(!is_user_connected(id))
		return -1;
		
	return asddd[id];
}
public f(id)
{
	if(asddd[id]!=true)	asddd[id]=true
	else	asddd[id]=false
}


public native_get_id_new(id)
{
	if(!is_user_connected(id))
		return -1;
		
	return asdddd[id];
}
public q(id)
{
	if(asdddd[id]!=1)	asdddd[id]=1
	else	asdddd[id]=0
}


public native_get_bool_new()
{
	return asdd;
}
public a()
{
	if(asdd!=true)	asdd=true
	else	asdd=false
}


public native_get_new()
{
	return asd;
}
public d()
{
	if(asd!=1)	asd=1
	else	asd=0
}
