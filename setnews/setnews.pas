Program Setnews;

Uses Dos, Crt, Filedef, SlDriv;

Var
    Configfile: file of configtype;
    cfg       : configtype;

    Userfile  : file;
    User      : UserType;
    UserGenHdr: fileheader;
    UserHdr   : UserHeader;

    subfile   : text;

procedure Read_config;                       { set configtype to dir in   }
  begin                                      { command line for           }
  assign(configfile, configspec);            {  config.sl2                }
  reset(configfile);                         { open and set to first      }
  read(configfile, cfg);                     { record (0) and read to     }
  end;                                       { cfg                        }

procedure close_config;                      { closes config file         }
  begin
  close(configfile);
  end;

procedure Open_userfile;
  begin
  Assign(userfile, Cfg.Datapath+userspec);
  reset(userfile, 1);
  end;

procedure Read_user_hdrs;
  begin

  seek(userfile, 0);
  blockread(userfile, usergenhdr, sizeof(usergenhdr));

  seek(userfile, sizeof(usergenhdr));
  blockread(userfile, userhdr, sizeof(userhdr));

  end;

procedure Readuser(n: longint);
  begin
  Seek(Userfile, (UserGenHdr.RecSize*(n-1))+UserGenHdr.Offset);
  Blockread(UserFile, User, UserGenHdr.Recsize);
  end;

procedure Close_userfile;
  begin
  close(userfile);
  end;

begin

   LoadSlData;
   If SlActive then LocalOnly;

   TextColor(lightcyan);write('SetNews');
   textcolor(cyan);writeln(' - Set text file for last subboard util.');



   Read_config;
   Close_Config;

   Open_userFile;
   Read_User_Hdrs;
   ReadUser(cfg.Curruser);
   Close_Userfile;

   Assign(subfile, cfg.textpath + paramstr(1));
   rename(subfile, cfg.textpath + user.subboard + '.TXT');

   if SlActive then LocalAndRemote;

end.
