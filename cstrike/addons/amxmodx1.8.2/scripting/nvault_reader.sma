#include <amxmodx>
#include <amxmisc>

// - From nvault.h -
#define VAULT_MAGIC   0x6E564C54     //nVLT
#define VAULT_VERSION 0x0200         //second version

/*  
    nVault File Format
 
    VAULT_MAGIC       (uint32)
    VAULT_VERSION     (uint16)
    ENTRIES           (int32)
    [
        TimeStamp     (int32)
        KeyLen        (uint8)
        ValLen        (uint16)
        KeyData       ([])
        ValData       ([])
    ]                                 
*/

new const Version[] = "0.1";

const MaxKeyLen  = 255;     //Max 255
const MaxValLen  = 512;     //Max 65535
const DataBuffer = 128;     //Make this the greater of (MaxKeyLen / 4) or (MaxValLen / 4)

public plugin_init() 
{
    register_plugin( "nVault File Reader" , Version , "bugsy" );
    
    ReadVault( "TheVaultFile" );
}

public ReadVault( const szVault[] )
{
    new szFile[ 64 ] , iFile;
    new iVaultMagic , iVaultVersion , iVaultEntries;
    new iKeyLen , iValLen , iTimeStamp;
    new szKey[ MaxKeyLen + 1 ] , szVal[ MaxValLen + 1 ] , RawData[ DataBuffer ];
    
    formatex( szFile[ get_datadir( szFile , charsmax( szFile ) ) ] , charsmax( szFile ) , "/vault/%s.vault" , szVault );
    
    iFile = fopen( szFile , "rb" );

    if ( !iFile )
        return 0;
    
    // Vault Magic
    fread_raw( iFile , RawData , 1 , BLOCK_INT );
    iVaultMagic = RawData[ 0 ];
    
    if ( iVaultMagic != VAULT_MAGIC )
        set_fail_state( "Error reading nVault: Vault Magic" );
    
    // Vault Version
    fread_raw( iFile , RawData , 1 , BLOCK_SHORT );
    iVaultVersion = RawData[ 0 ] & 0xFFFF;
    
    if ( iVaultVersion != VAULT_VERSION )
        set_fail_state( "Error reading nVault: Vault Version" );
        
    // Vault Entries
    fread_raw( iFile , RawData , 1 , BLOCK_INT );
    iVaultEntries = RawData[ 0 ];

    server_print( "nVault | Magic=%d Version=%d Entries=%d" , iVaultMagic , iVaultVersion , iVaultEntries );
    server_print( " " );

    for ( new iEntry = 0 ; iEntry < iVaultEntries ; iEntry++ )
    {
        // TimeStamp
        fread_raw( iFile , RawData , 1 , BLOCK_INT );
        iTimeStamp = RawData[ 0 ];
        
        // Key Length
        fread_raw( iFile , RawData , 1 , BLOCK_BYTE );
        iKeyLen = RawData[ 0 ] & 0xFF;
        
        // Val Length
        fread_raw( iFile , RawData , 1 , BLOCK_SHORT );
        iValLen = RawData[ 0 ] & 0xFFFF;
        
        // Key Data
        fread_raw( iFile , RawData , iKeyLen , BLOCK_CHAR );
        ReadString( szKey , iKeyLen , charsmax( szKey ) , RawData );
    
        // Val Data
        fread_raw( iFile , RawData , iValLen , BLOCK_CHAR );
        ReadString( szVal , iValLen , charsmax( szVal ) , RawData );

        server_print( "Entry=%d KeyLen=%d ValLen=%d TimeStamp=%d" , iEntry , iKeyLen , iValLen , iTimeStamp );
        server_print( "Key=^"%s^"" , szKey );
        server_print( "Val=^"%s^"" , szVal );
        server_print( " " );
    }
    
    fclose( iFile );
    
    return iVaultEntries;
}

ReadString( szDestString[] , iLen , iMaxLen , SourceData[] )
{
    new iStrPos = -1;
    new iRawPos = 0;
    
    while ( ( ++iStrPos < iLen ) && ( iStrPos < iMaxLen ) && ( iRawPos < DataBuffer ) )
    {
        szDestString[ iStrPos ] = ( SourceData[ iRawPos ] >> ( ( iStrPos % 4 ) * 8 ) ) & 0xFF;
        
        if ( iStrPos && ( ( iStrPos % 4 ) == 3 ) )
            iRawPos++
    }
    
    szDestString[ iStrPos ] = EOS;
}  
