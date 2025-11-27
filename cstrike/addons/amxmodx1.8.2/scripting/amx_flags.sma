#include <amxmodx>
#include <amxmisc>

public plugin_init()
{
	register_plugin("Flags Adder/Remover", "1.0", "AlliedModders")
	register_concmd("amx_flags", "cmdflags", ADMIN_RCON, "<name or #userid> [flags] [+|-] - adds/removes flags to the specific user")
}

public cmdflags(caller, level, cid)
{
	if(!cmd_access(caller, level, cid, 2))
		return PLUGIN_HANDLED

	static arg[32], id
	read_argv(1, arg, sizeof arg - 1)
	id = cmd_target(caller, arg, 0)
	if(!id)
		return PLUGIN_HANDLED

	if(read_argc() == 2)
	{
		get_flags(get_user_flags(id), arg, sizeof arg - 1)
		console_print(caller, "Flag-urile jucatorului:   %s", arg)
		return PLUGIN_HANDLED
	}
	static flags
	read_argv(2, arg, sizeof arg - 1)
	flags = read_flags(arg)
	read_argv(3, arg, 1)
	switch(arg[0])
	{
		case '+': set_user_flags(id, flags)
		case '-': remove_user_flags(id, flags)
		default :
		{
			remove_user_flags(id, -1)
			set_user_flags(id, flags)
		}
	}
	return PLUGIN_HANDLED
}
