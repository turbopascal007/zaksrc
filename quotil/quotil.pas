Program Quotil;

Uses Crt, Dos, SlFiles, FileDef, SlDriv;


var User: usertype;


begin
  PathtoConfig := '';

  LoadSlData;
  If SlActive then LocalOnly;
  TextColor(LightCyan);Write('QUOTIL');
  TextColor(LightGray);Write(' - ');
  TextColor(Cyan);     Write('Quotes Toggle for Searchlight BBS');
  textcolor(lightgray);write(' - ');

  Open_Config;
  Read_Config;

  Open_UserFile;
  Read_UserFile_GenHdr;
  Read_UserFile_Hdr;

  ReadUser(Cfg.Curruser, User);
  Close_UserFile;

  If (User.Access.MsgLevel < Cfg.Mainlevels[16]) then
      begin
      TextColor(cyan);writeln('Quotes Turned OFF');
      Cfg.NoQuotes := True;
      Write_Config;
      end
  else
      begin
      TextColor(cyan);writeln('Quotes Turned ON');
      Cfg.NoQuotes := False;
      Write_Config;
      end;

  Close_Config;
  if SlActive then LocalAndRemote;
end.
