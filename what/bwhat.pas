Program What;

uses Crt,SLfLow,SLfHigh,bTree,Etc;

Type Rectype = string[25];
Type DataRec = array[0..0] of byte;

Var          f       : file;
             user    : usertype;
             log     : text;

function allready: boolean;
 var a:longint;
 begin
 a:=0;

{ if (filesize(datafile)>1) then}

  begin
  for a:=0 to filesize(datafile)-1 do
   begin
   seek(datafile,a);
   blockread(datafile,datarec,1);
   if datarec=user.name then
     begin
     allready:=true;
     lastrec:=a;
     exit;
     end;
   end;
  end;
  lastrec:=a;
  allready:=false;
 end;

begin
filemode := 66;

directvideo:=false;
pathtoconfig:='';

open_config;
 read_config;
close_config;

open_user;
read_user_genhdr;
read_user_hdr;
read_user(cfg.curruser,user);
close_user;

if user.calls < 5 then halt;

assign(datafile,'WHAT.DAT');
if existfile('WHAT.DAT') then reset(datafile,sizeof(datarec)) else
  rewrite(datafile,sizeof(datarec));

if not allready then
 begin
 writeln;
 writeln('If Sirius Cybernetics was to be improved, what would you change/add?');
 write('> ');
 readln(instr);


 if rtrim(ltrim(instr))<>'' then
   begin
   inc(lastrec);
   seek(datafile,lastrec);
   blockwrite(datafile,user.name,1);

   assign(log,'WHAT.LOG');
   if existfile('WHAT.LOG') then append(log) else rewrite(log);
   writeln(log,dttmstamp,' ',user.name,' -> ',instr);
   close(log);
   end;

 close(datafile);

 end;

end.
