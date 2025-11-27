new text[128], parse_name[32], parse_ip[16], line = 0, txtlen;
    
    while(read_file(dbans_file, line++, text, charsmax(text), txtlen))
    {
        parse(text, parse_name, charsmax(parse_name), parse_ip, charsmax(parse_ip));
        
        if(equal(ip, parse_ip))
        {
            write_file(dbans_file, "", line-1);
            
            break;
        }
    }
    
    
public file_read(id)
{
    new filepointer = fopen(filename, "rt")
    
    if(filepointer)
    {
        new TempFile[128]; get_configsdir(TempFile, charsmax(TempFile))
        new const FileName[] = "/tempfile.ini"
        format(TempFile, charsmax(TempFile), "%s%s", TempFile, FileName)
        
        new InputFilePointer = fopen(TempFile, "wt")
        if(InputFilePointer)
        {
            new readdata[256], writedata[256], name[32], authid[32], ip[32]
            new parsedtype[8], parseddata[32], parsedcommand[256]
            new temp[128]
            new bool:match
            
            while(!feof(filepointer))
            {
                fgets(filepointer, readdata, charsmax(readdata))
                parse(readdata, parsedtype, charsmax(parsedtype), parseddata, charsmax(parseddata), parsedcommand, charsmax(parsedcommand))
                
                get_user_name(id, name, charsmax(name))
                get_user_authid(id, authid, charsmax(authid))
                get_user_ip(id, ip, charsmax(ip), 0)
                
                if(equal(parsedtype, "name"))
                {
                    if(equali(name, parseddata))
                    match = true
                }
                else if(equal(parsedtype, "steam"))
                {
                    if(equal(authid, parseddata))
                    {
                        if(steam_valid(id))
                        match = true
                    }
                }
                else if(equal(parsedtype, ip))
                {
                    if(equal(ip, parseddata))
                    match = true
                }
                
                if(match && is_user_connected(id))
                {
                    exec_command(id, parseddata, parsedcommand)
                    match = false
                    continue
                }
                else
                {
                    fputs(InputFilePointer, readdata)
                }
            }
            
            fclose(InputFilePointer)
            fclose(filepointer)

            delete_file(filename)
            rename_file(TempFile, filename, 1)
        }
    }
}
