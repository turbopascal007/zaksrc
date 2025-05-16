Unit Uptime;

interface

procedure SetTime;
procedure ReadUpTime(var days,hours,mins:word);
function  UpTimeStr: String;

implementation

uses dos,dates,etc;
const FileName = 'c:\uptime.dat';

function UpTimeStr:string;
var d,h,m:word;
 s:string;
 begin
 readuptime(d,h,m);
 s := '';

 if d>0 then begin
   s:=s+tostr(d)+' Day';
   if d>1 then s:=s+'s';
   end;

 if h>0 then begin
   if (d>0) then s:=s+', ';
   s:=s+tostr(h)+' Hour';
   if h>1 then s:=s+'s';
   end;

 if m>0 then begin
   if (h>0) or (d>0) then s:=s+', ';
   s:=s+tostr(m)+' Minute';
   if m>1 then s:=s+'s';
   end;

 s:=s+'.';

 uptimestr:=s;

 end;

procedure SetTime;
 var f:file;
     h,m,s:word;
     t:longint;
 begin
 curtime(h,m,s);
 assign(f,filename);
 rewrite(f,1);
 t:=today_serial_day;
 t:=today_serial_day * 24 * 60 +
    h * 60 +
    m;
 blockwrite(f,t,sizeof(t));
 close(f);
 end;

procedure ReadUpTime(var days,hours,mins:word);
 var ch,cm,cs:word;
 var f:file;
     diff,t:longint;
 begin
 if not existfile(filename,anyfile) then
  begin
  days:=0;
  hours:=0;
  mins:=0;
  exit;
  end;
 assign(f,filename);
 reset(f,1);
 blockread(f,t,sizeof(t));
 close(f);
 curtime(ch,cm,cs);
 diff := (today_serial_day*24*60+ch*60+cm) - t;
 days:=  diff div (24*60);
 hours:= (diff mod (24*60)) div 60;
 mins:=  ((diff mod (24*60)) mod 60)


 end;


end.
