Uses SlfLow,SlfHigh,Crt,Etc;

Var Log : ^LogType;
    User: ^UserType;
    i   : longint;
    uF  : file;
    uFHDR:Fileheader;
    uHDR:UserHeader;

    MaxNum:word;
    NumShown:word;

procedure pause;
 var c:char;
     b:byte;
 begin
 if cfg.ansi then textcolor(cfg.colorchart[special]);
 Write('-- More --');
 c:=readkey;
 for b:=1 to length('-- More --') do write(#8+' '+#8);
 if cfg.ansi then TextColor(Cfg.Colorchart[normal]);
 end;

Function Abort:boolean;
 var c:char;
 begin
 if keypressed then
  begin
  c:=readkey;
  if c in [' ',^C] then abort:=true else abort:=false;
  end
 else abort:=false;
 end;

procedure Process;
  var tm:string[2];
      td:string[2];

  begin
  if (numshown>=MaxNum) or abort then exit;

  Read_Data(uf,UserF,Log^.Users[i].Id,User^);
  tm:=tostr2(Log^.Users[i].date.month,2);
  td:=tostr2(Log^.Users[i].date.day,2);

  if cfg.ansi and (cfg.curruser=Log^.users[i].id) then
      textcolor(cfg.colorchart[altcolor]);

  Writeln(tm,'/',td,'  ',User^.Name,' ',
     ltabc(length(user^.Name)+1,25,'.'),' ',User^.Location);

  if cfg.ansi and (cfg.curruser=Log^.users[i].id) then
      textcolor(cfg.colorchart[normal]);

  inc(numshown);

  if (numshown mod 23)=0 then pause;

  end;

var c:integer;
    t:word;
begin

directvideo := false;

MaxNum:=75;
if Paramcount>0 then
  begin
  val(paramstr(1),t,c);
  if c=0 then MaxNum:=t;
  end;

Init_Config( '' , Closed );
NumShown:=0;

New(Log);
New(User);

Init_Log(Log^);
Init_ConstData(uf,UserF,uFHDR,uHDR);

if cfg.ansi then TextColor(cfg.colorchart[headcolor]);
Writeln;
writeln('Date   Name                      Location');
if cfg.ansi then textcolor(cfg.colorchart[normal]);

i:= log^.head;
repeat
 begin
 process;
 dec(i,1);
 if i=0 then i:=logsize;
 end
until (numshown>=maxnum) or abort or (i=log^.head);

close_log;
close_data(uf);

Dispose(Log);
Dispose(User);

if not(Cfg.systemname='Sirius Cybernetics') then
 begin
 if cfg.ansi then textcolor(cfg.colorchart[altcolor]);
 Writeln;
 writeln('CallLog - Another FreeWare program by Zak Smith');
 if cfg.ansi then textcolor(cfg.colorchart[normal]);
 end;

end.
