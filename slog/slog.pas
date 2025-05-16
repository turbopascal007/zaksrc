Uses SlFGen,SlFiles,Dos,Etc;

const filename = 'SLBBS.LOG';
      TabStr   = ' LogOn ';
      TabLen   = Length(TabStr);

var logfile: text;
    u      : usertype;
    inf    : text;
    ms     : string;

Begin

FileMode := 66;

assign(inf,'d:\db\thiscall.txt');
reset(inf);

readln(inf,ms);

close(inf);

ms := copy(ms,pos('"',ms)+1,ord(ms[0]));

ms := copy(ms,1,pos('"',ms)-1);

ms := copy(ms,9,length(ms)-8);

ms := casestr(ms);

Init_Config ( Closed , '' );


Init_User;
read_user(cfg.curruser,u);
close_user;

if not cfg.remote then ms:='Local';

assign(logfile,filename);

if existfile (filename)
  then append (logfile)
 else
  rewrite (logfile);

writeln(logfile,DtTmStamp,' 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴');

writeln(logfile,DtTmStamp,TabStr,     '   User: ', casestr(U.name),', ',casestr(U.location));

Writeln(logfile,DtTmStamp,' ':tablen, '   Baud: ',ms);

Writeln(logfile,DtTmStamp,' ':tablen, ' Access: ',U.access.msglevel:3,'/',
                                          U.access.filelevel:3,'/',
                                          U.Access.Timelimit:4,'/',
                                          U.timeleft:4);
close(logfile);

end.
