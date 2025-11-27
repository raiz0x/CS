#include <amxmodx> 
#include <nvault_util> 

new const Version[] = "0.1"; 

new const nVaultFile[] = "vault_name"; 
new const Delimiter = '    '; 
new const OutputFile[] = "nvault_export.txt"; 

new szFile[ 64 ]; 

public plugin_init()  
{ 
    register_plugin( "Export nVault to Text" , Version , "bugsy" ); 
     
    formatex( szFile[ get_datadir( szFile , charsmax( szFile ) ) ] , charsmax( szFile ) , "/vault/%s" , OutputFile ); 
     
    new iVaultHandle = nvault_util_open( nVaultFile ); 
    nvault_util_readall( iVaultHandle , "nvault_export_fwd" ); 
    nvault_util_close( iVaultHandle ); 
} 

public nvault_export_fwd( iCurrent , iTotal , const szKey[] , const szVal[] , iTimeStamp , const Data[] , iSize ) 
{ 
    static szData[ 1024 ]; 

    formatex( szData , charsmax( szData ) , "%s%c%s%c%d" , szKey , Delimiter , szVal , Delimiter , iTimeStamp );  
    write_file( szFile , szData ); 
}
