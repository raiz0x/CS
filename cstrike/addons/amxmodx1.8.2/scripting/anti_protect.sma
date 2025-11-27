#include <amxmodx>
#include <amxmisc>

#define cm(%0) ( sizeof (%0) - 1 )
#define g_BoolCheck(%0,%1) (%0 & (1<<%1))
#define g_BoolTrue(%0,%1) (%0 |= (1<<%1))
#define g_BoolFalse(%0,%1) (%0 &=  ~(1<<%1))

#define clientCommand(%0,%1,%2)     client_cmd(%0,%1,%2)
#define timeCheck    1.0
#define PUNISHTYPE     1


#define tripleExecute(%0,%1,%2)                                    \
        get_user_info(id,(%0),global_check[id],cm(global_check[]));    \
        clientCommand(id,(%1),Value_rate); \
        g_BoolTrue(Check_First,id); \
        set_task( timeCheck , (%2), id)

     
new Check_First;

const Value_rate = 0x5abf
const buffer1 = 0x20
const buffer2 = 0x21

new global_check[ buffer1 ][ buffer2 ]

public plugin_init()    register_plugin("Anti Protector", "1.0", "Freezo aka Spawner")

public client_connect(id)    set_task(timeCheck + 1.0 ,"checkProtector", id )

public checkProtector(id){
 
    if(g_BoolCheck(Check_First,id))
    {
        new FirstInfo[ buffer1 ]
        get_user_info(id,"rate",FirstInfo, charsmax(FirstInfo))
     
        if( equal(global_check[id]  ,FirstInfo) )
        { 
            switch(PUNISHTYPE)
            {
                case 1:  punish_type(id,1)
                case 2:  punish_type(id,2) 
            }
        }
        else
        {
            g_BoolFalse(Check_First,id)
            clientCommand(id,"rate %d",global_check[id])
        }
    }
    else
    {

        tripleExecute("rate", "rate %d", "checkProtector")
     
    } 
    return 0;
}


stock punish_type(index,value)
{
 
    new iClient = get_user_userid(index)
    switch(value)
    {
        case 1:  server_cmd("kick #%d ^"Protector Detected^"", iClient)
        case 2:  server_cmd("amx_ban 50.0 #%d ^"Protector Detected^"", iClient)
    }
    return 0;
} 
