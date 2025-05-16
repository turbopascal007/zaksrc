Program LoginInf;

Uses Crt, Dos, FosCom,etc;

var comport: word;
    s      : string;
    t      : word;
    d      : word;

begin

 val (paramstr(1),comport,t);

 val (paramstr(2),d,t);

 {directvideo := false;

 Fos_Init(Cfg.Comport);}

 s:=concat(' þ ',long2hex(memavail),'; ');

 for t:=3 to 2+d do

 s:=concat(s,long2hex(diskfree(t)),'/',long2hex(disksize(t)),'; ');

 s:=lowcasestr(s);

 writeln(s);

{ Fos_StringCRLF(cfg.comport,s);}

end.
