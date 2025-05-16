{$M 2000,0,0}

Uses Dos,Crt,SlFiles,Etc,SlFGen;

var p:string;
    t:longint;
    u:usertype;

begin

directvideo:=false;

Init_Config ( Closed , '' );

Init_User;
read_user(cfg.curruser,u);
close_user;

t:=nowsecondssincemidnight - secondssincemidnight(cfg.logtime.hour,
  cfg.logtime.minute,0);

t:=5;
if ((t >= 300) or (t<0)) or (u.access.msglevel>=100)  then
 begin

 { do nothing, with great vigor }

 end
else
 begin

writeln;
writeln;
writeln('You are experiencing the FileSystem_Delay <tm, damnit> which gives you this');
writeln('funky message, which says .. ');
writeln;
writeln('You have been on less than 5 minutes, and you are allready going off to the');
writeln('Files section.  Please take time to take a look at the other aspects of this');
writeln('BBS and what BBSing, in general, has to offer.');

writeln('If you can figure this out, that''s nice. <mahahaha>');

writeln;
write('You have been online ',t,' seconds .');
for t := 1 to 5 do
  begin
  delay(500);
  write(' ');
  delay(500);
  write('.');
  end;

writeln;



 end;

end.
