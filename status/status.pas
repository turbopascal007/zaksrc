uses crt,dos,etc,slfiles,dates;

Var
    numofd :integer;
    user   :usertype;

procedure Disks(var totalfree,total,used: longint);
    var
    d:byte;
    curfree:longint;
    cursize:longint;
    numofd :integer;

    begin

    Total:=0;
    TotalFree:=0;

    numofd:=24;

for d:=3 to numofd do
 begin
 if not (disksize(d)=-1) then
    begin
    curfree:=diskfree(d);
    cursize:=disksize(d);

    inc(total,cursize);
    inc(totalfree,curfree);

    end;

 end;

  used := total - totalfree;

  end;
{
function TotalFree: longint;
var cur:longint;
    d:byte;
    tv:longint;
 begin
 tv:=0;
 for d:=3 to numofd do
 if not (disksize(d)=-1) then
  begin
  cur:=diskfree(d);
  inc(tv,cur);
  end;
 TotalFree:=tv;
 end;

Function Total: longint;
var cur:longint;
    d:byte;
    tv:longint;
 begin
 tv:=0;
 for d:=3 to numofd do
 if not (disksize(d)=-1) then
  begin
  cur:=disksize(d);
  inc(tv,cur);
  end;
 total:=tv;
 end;}

function Time_Logged_On: longint;
  begin
  Time_Logged_On:=SecondsSinceMidnight(
        Cfg.LogTime.Hour,
        Cfg.LogTime.Minute,
        0);
  end;

Function Time_Online:longint;
  begin
  Time_Online:=((NowSecondsSinceMidnight-Time_Logged_On) div 60)
  end;

function datetime:string;
 begin

 datetime:= copy(days[today_day_of_week],1,3) +
        ', '+
        tostr(today_month)+
        '-'+
        tostr(today_day)+
        '-'+
        tostr(today_year)+
        ', '+
        curtimestr;
 end;

procedure tc(c:byte);
 begin
 if cfg.ansi then textcolor(c);
 end;

var tf,t,u:longint;

begin
 FileMode:=66;

 {$ifdef debug}
 clrscr;
 {$endif}

 directvideo:=false;

 pathtoconfig:='.\';
 open_config;
 read_config;
 close_config;

 open_user;
 read_user_genhdr;
 read_user_hdr;
 read_user(cfg.curruser,user);
 close_user;

 if paramcount<2 then numofd:=24 else numofd:=toint(paramstr(2))+2;

 writeln;
 tc(cyan);
 write('Current System Status for ');
 tc(white);
 write(casestr(user.name),' ':(25-(length(user.name))));

 tc(green);
 writeln(datetime:24);

 tc(cyan);
 write('Elapsed Time Online : ');

 tc(white);
 write(time_online:4);

 tc(cyan);
 write(' min            Time Left this Session : ');

 tc(white);
 write( (Cfg.TimeLimit - Time_Online):4);

 tc(cyan);
 writeln(' min');

 tc(cyan);
 write('  Uploaded ');

 tc(white);
 write(int2comma(user.uploads,6));

 tc(cyan);
 writeln('k');

 write('Downloaded ');

 tc(white);
 write(int2comma(user.downloads,6));

 tc(cyan);
 write('k                       Ratio: d/u = ');

 tc(white);
 if user.uploads>0 then
   write((user.downloads / user.uploads):4:2)
 else write('0.00');
 writeln;

 disks(tf,t,u);

 tc(cyan);
 write('Total Space = ');
 tc(white);

 write(int2comma(t,11));

 tc(cyan);

 write('b             Free = ');


 tc(white);
 write(int2comma(tf,11));

 tc(cyan);
 writeln('b');

end.