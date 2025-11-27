#pragma tabsize 0

#include <amxmodx>

#pragma ctrlchar '\'

/*
1 - caută pentru mai multe simboluri, precum: ^ / & / + / " (la sf. de nick)
orice valoare care nu este egală cu 1 reprezintă ocolirea simbolurilor precizate anterior
*/
#define EXTRA 0

public plugin_init()
{
   if(GetEngineVersion()<7000||GetEngineVersion()>4554&&AMXX_VERSION_NUM<str_to_num("182")&&!cvar_exists("reu_version"))
   {
      #define BLOCK 0
      register_clcmd("say","chat_handle")
      register_clcmd("say_team","chat_handle2")
   }
   else if(GetEngineVersion()<7000)
   {
      #if BLOCK!=0
         #define BLOCK 1
      #endif
      log_to_file("/addons/amxmodx/SYMBOLS.txt","Ai o versiune avansata a engine-ului, iar acest plugin nu mai este necesar")
   }
   else if(AMXX_VERSION_NUM>str_to_num("182"))
   {
      #if BLOCK!=0
         #define BLOCK 1
      #endif
      log_to_file("/addons/amxmodx/SYMBOLS.txt","Ai o versiune avansata a amxmodx-ului, iar acest plugin nu mai este necesar")
   }
   else if(cvar_exists("reu_version"))
   {
      #if BLOCK!=0
         #define BLOCK 1
      #endif
      log_to_file("/addons/amxmodx/SYMBOLS.txt","Acest plugin nu este necesar pe rehlds")
   }
}

#if BLOCK==0
new args[195],name[32],lenx

public client_connect(id)
{
   get_user_info(id,"name",name,charsmax(name))
   check_param(id,name,charsmax(name),1)
}

public client_infochanged(id)
{
   new newname[32],oldname[32]
   get_user_info(id,"name",newname,charsmax(newname))
   get_user_name(id,oldname,charsmax(oldname))
   if(!equal(oldname,newname))   check_param(id,newname,charsmax(newname),1)
}

public chat_handle(id)
{
   read_args(args,charsmax(args))
   remove_quotes(args)
   
   check_param(id,args,charsmax(args),2)
}
public chat_handle2(id)
{
   read_args(args,charsmax(args))
   remove_quotes(args)

   check_param(id,args,charsmax(args),3)
}

check_param(const id,fc[],fc_max,number)
{
   switch(number)
   {
      case 1:
      {
         if(containi(fc,"%")!=-1)
         {
            replace_all(fc,fc_max,"%","％")
            set_user_info(id,"name",fc)
         }
         if(containi(fc,"#")!=-1)
         {
            replace_all(fc,fc_max,"#","﹟")
            set_user_info(id,"name",fc)
         }


#if EXTRA==1
         if(containi(fc,"+")!=-1)
         {
            replace_all(fc,fc_max,"+"," + ")
            set_user_info(id,"name",fc)
         }
         if(containi(fc,"&")!=-1)
         {
            replace_all(fc,fc_max,"&","＆")
            set_user_info(id,"name",fc)
         }
         if(containi(fc,"\"")!=-1)
         {
            replace_all(fc,fc_max,"\"","＾")
            set_user_info(id,"name",fc)
         }

         lenx=strlen(fc)-1
         if(lenx>0)
         {
            if(equali(fc[lenx],"\""))
            {
               fc[lenx]='^'//s3x
               set_user_info(id,"name",fc)
            }
         }
#endif
      }
      case 2:
      {
         if(containi(fc,"%")!=-1)
         {
            replace_all(fc,fc_max,"%","％")
            engclient_cmd(id,"say",fc)
         }
         if(containi(fc,"#")!=-1)
         {
            replace_all(fc,fc_max,"#","﹟")
            engclient_cmd(id,"say",fc)
         }


#if EXTRA==1
         if(containi(fc,"+")!=-1)
         {
            replace_all(fc,fc_max,"+"," + ")
            engclient_cmd(id,"say",fc)
         }
         if(containi(fc,"&")!=-1)
         {
            replace_all(fc,fc_max,"&","＆")
            engclient_cmd(id,"say",fc)
         }
         if(containi(fc,"\"")!=-1)
         {
            replace_all(fc,fc_max,"\"","＾")
            engclient_cmd(id,"say",fc)
         }
#endif
      }
      case 3:
      {
         if(containi(fc,"%")!=-1)
         {
            replace_all(fc,fc_max,"%","％")
            engclient_cmd(id,"say_team",fc)
         }
         if(containi(fc,"#")!=-1)
         {
            replace_all(fc,fc_max,"#","﹟")
            engclient_cmd(id,"say_team",fc)
         }

#if EXTRA==1
         if(containi(fc,"+")!=-1)
         {
            replace_all(fc,fc_max,"+"," + ")
            engclient_cmd(id,"say_team",fc)
         }
         if(containi(fc,"&")!=-1)
         {
            replace_all(fc,fc_max,"&","＆")
            engclient_cmd(id,"say_team",fc)
         }
         if(containi(fc,"\"")!=-1)
         {
            replace_all(fc,fc_max,"\"","＾")
            engclient_cmd(id,"say_team",fc)
         }
      }
#endif
   }
}
#endif

GetEngineVersion()
{
   new VersionPonter,VersionString[24],Pos
   new const VersionSizeNum=4
   
   VersionPonter=get_cvar_pointer("sv_version")
   get_pcvar_string(VersionPonter,VersionString,charsmax(VersionString))
   Pos=strlen(VersionString)-VersionSizeNum
   format(VersionString,VersionSizeNum,VersionString[Pos])
   
   return str_to_num(VersionString)
}
