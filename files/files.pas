{$M 2000,0,0}

Uses Dos,Crt,SlFiles,Etc;


var p:string;
    t:longint;
    u:usertype;

begin

directvideo:=false;
if paramcount>0 then p:=paramstr(1) else p:='';

pathtoconfig:='';

open_config;
read_config;
close_config;

 open_user;
 read_user_genhdr;
 read_user_hdr;
 read_user(cfg.curruser,u);
 close_user;


t:=nowsecondssincemidnight - secondssincemidnight(cfg.logtime.hour,
  cfg.logtime.minute,0);

if ((t >= 300) or (t<0)) or (u.access.msglevel>=100)  then
 begin

 exec(cfg.progpath+'sfiles.exe',p);

 end
else
 begin

writeln;
writeln;
writeln('You are experiencing the FileSystem_Delay <tm, damnit> which does not allow');
writeln('access to the file system of this BBS until you have been online 5 (five)');
writeln('minutes.  If you can figure this out, that''s nice. <mahahaha>');

writeln;
writeln('You have been online ',t,' seconds, and have to wait ',300-t,' more seconds.');
writeln;
writeln('..Returning to main BBS');
writeln;

open_config;
read_config;
cfg.command:=cfg.progpath+'bbs.exe';
write_config;
close_config;

 end;

end.
