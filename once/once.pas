Program once;

uses crt,slfiles,etc;

Type Rectype = string[25];

Var          datafile: file;
             datarec : rectype;
             user    : usertype;
             lastrec : longint;
             instr   : string;

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
pathtoconfig:='d:\slbbs\';

open_config;
 read_config;
close_config;

open_user;
read_user_genhdr;
read_user_hdr;
read_user(cfg.curruser,user);
close_user;

assign(datafile,'once.DAT');
if existfile('once.DAT') then reset(datafile,sizeof(datarec)) else
  rewrite(datafile,sizeof(datarec));

if not allready then
 begin
   inc(lastrec);
   seek(datafile,lastrec);
   blockwrite(datafile,user.name,1);
   close(datafile);
   halt(1);
 end;

end.
