#include < amxmodx >

new const TehOpenGL[ ] = "../opengl32.dll";

public plugin_init( )
    register_plugin( "Anti OpenGL", "1.0", "CSF" );

public plugin_precache( )
    force_unmodified( force_exactfile, "", "", TehOpenGL );

public inconsistent_file( id, const szFileName[ ], szReason[ 64 ] ) {
    if( equal( szFileName, TehOpenGL ) ) {
        copy( szReason, 63, "Your reason here." );
        log_amx( "Client: %i - File: %s - Reason: %s", id, szFileName, szReason );
    }
    /*if (file_exists("..\opengl32.dll"))
    {
        delete_file("..\opengl32.dll")
    }*/
}
