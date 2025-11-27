#include <amxmodx>
#include <amxmisc>

new const Version[] = "0.1";

const MAX_LINE_LENGTH = 64;
const MENU_READY = -1;

enum _:IsComm
{
    CommentYes = 90,
    CommentNo
}

enum _:LineData
{
    LineIndex,
    IsLineCommented,
    LineText[ MAX_LINE_LENGTH ]
}

new g_MenuID = MENU_READY;
new g_szConfigFile[ 64 ] , g_LineData[ LineData ];
new g_pCvarFile , g_pCvarUseConfigsDir;

public plugin_init() 
{
    register_plugin( "Config Editor Menu 2" , Version , "bugsy" );
    
    register_clcmd( "configmenu" , "ShowConfigMenu" , ADMIN_RCON );
    
    g_pCvarFile = register_cvar( "cem_filename" , "maps.ini" );
    g_pCvarUseConfigsDir = register_cvar( "cem_useconfigsdir" , "1" );
}

public ShowConfigMenu( id , level , cid )
{
    if ( !cmd_access( id , level, cid , 0 ) )
        return PLUGIN_HANDLED;
        
    if ( g_MenuID != MENU_READY ) 
    {
        console_print( id , "* Another user is currently editing this file. Please try again later." );
        return PLUGIN_HANDLED;
    }
    
    new iFile , szFile[ 32 ] , iLine;
    
    if ( get_pcvar_num( g_pCvarUseConfigsDir ) )
    {
        szFile[ 0 ] = '/';
        get_pcvar_string( g_pCvarFile , szFile[ 1 ] , charsmax( szFile ) );
        copy( g_szConfigFile[ get_configsdir( g_szConfigFile , charsmax( g_szConfigFile ) ) ] , charsmax( g_szConfigFile ) , szFile );
    }
    else
    {
        get_pcvar_string( g_pCvarFile , g_szConfigFile , charsmax( g_szConfigFile ) );
    }
    
    if ( ( iFile = fopen( g_szConfigFile , "rt" ) ) )
    {
        g_MenuID = menu_create( "Edit Config" , "MenuItemSelected" );
        
        while ( ( fgets( iFile , g_LineData[ LineText ][ 1 ] , charsmax( g_LineData[ LineText ] ) - 1 ) ) )
        {
            iLine++;
            trim( g_LineData[ LineText ][ 1 ] );
            
            if ( g_LineData[ LineText ][ 1 ] && ( ( g_LineData[ LineText ][ 1 ] != '/' ) && ( g_LineData[ LineText ][ 2 ] != '/' ) ) )
            {    
                g_LineData[ LineIndex ] = iLine;
                g_LineData[ IsLineCommented ] = ( g_LineData[ LineText ][ 1 ] == ';') ? CommentYes : CommentNo;
                g_LineData[ LineText ][ 0 ] = ' ';
                
                menu_additem( g_MenuID , g_LineData[ LineText ][ 1 ] , g_LineData , ADMIN_KICK );
            }
        }
        
        fclose( iFile );
        
        if ( !menu_display( id , g_MenuID ) )
        {
            console_print( id , "* There are no items in this config file." );
            menu_destroy( g_MenuID );
            g_MenuID = MENU_READY;
        }
    }
    else
    {
        console_print( id , "* Error opening file: %s" , g_szConfigFile );
    }
    
    return PLUGIN_HANDLED;
}

public MenuItemSelected( id , iMenuID , iItem ) 
{
    new iAccess , iCB;
    
    if ( iItem >= 0 )
    {
        menu_item_getinfo( iMenuID , iItem , iAccess , g_LineData , sizeof( g_LineData ) , _ , _ , iCB );
        
        if ( g_LineData[ IsLineCommented ] == CommentYes )
        {
            g_LineData[ LineText ][ 1 ] = ' ';
            trim( g_LineData[ LineText ] );
        }
        else
        {
            g_LineData[ LineText ][ 0 ] = ';';
        }
        
        write_file( g_szConfigFile , g_LineData[ LineText ] , g_LineData[ LineIndex ] - 1 );
    }
    
    menu_destroy( g_MenuID );
    g_MenuID = MENU_READY;
} 
