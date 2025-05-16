{$M 16384,0,4192} { allow for exec's }

Program NMS;

uses Dos,Etc;

var f:text;
    l:string;

    num:string;
    d:boolean;


procedure Proc;
 begin
 l:=ltrim(rtrim(l));
 if copy(l,1,8)='Subject:' then
  if pos(upcasestr('National Midnight Star'),upcasestr(l))>0 then
   begin
   num:=copy(l,pos('#',l)+1,length(l)-pos('#',l));
   d:=true;
   end
  else
   begin
   close(f);
   writeln('Not a NMS!');
   halt;
   end;
 end;

begin
l:='';
num:='';
d:=false;

{Subject: 08/27/92 - The National Midnight Star #500}

assign(f,paramstr(1));
reset(f);

readln(f,l);
while not (eof(f) or d) do
  begin
  proc;
  readln(f,l);
  end;
close(f);

if num<>'' then
 begin
 writeln('renaming ',paramstr(1),' to ','RUSH'+num+'.TXT');
 assign(f,paramstr(1));
 rename(f,'RUSH'+num+'.TXT');
 end;

end.