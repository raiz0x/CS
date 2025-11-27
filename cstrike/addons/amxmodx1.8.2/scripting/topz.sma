#include amxmodx
#include amxmisc
#include dhudmessage

new MP;

public plugin_init() 
{
    register_plugin( "Stats Hud", "1.0" , "kikizon" );
    
    set_task( 1.0 , "Hud" , .flags = "b" );
    MP = get_maxplayers();
}

public Hud( task_id )
{
    static Sort[33][2], i, t, count, Name[3][32], num[3];
    
    for( i = 1 ; i <=  MP ; ++i )
    {
        Sort[count][0] = i;
        Sort[count][1] = get_user_frags(i);
        ++count;
    }
    
    SortCustom2D(Sort, count, "Check" );
    
    t = clamp( count, 0, 3 );
    for( i = 0 ; i < t ; ++i )
    {        
        get_user_name( Sort[i][0] , Name[i], 31 );
        num[i] = Sort[i][1];
    }
        
    set_dhudmessage( 250, 250, 250, -1.0, 0.0, 1 );
    show_dhudmessage( 0 , "TOP FRAGS: %s (%d) | %s (%d) | %s (%d)",  Name[ 0 ], num[0], Name[ 1 ], num[ 1 ], Name[ 2 ], num[ 2 ]);
    
} 

public Check( e1[], e2[])
{
    if( e1[1] > e2[1]) 
        return -1;
    else if( e1[1] < e2[1]) 
        return 1;
  
    return 0;
} 
