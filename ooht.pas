Uses ooMdmcrt,crt;

const port =2;

var a,b,c,d,e,omc:ModemCrtType;
    f:boolean;



begin

writeln(memavail);

f:=false;

if f then begin
 omc.init ( port , True , [Local,Remote] );
 omc.SetParams  ( 2400 , 8 , 'N' , 1 );
 omc.KillIn;
 omc.KillOut;
 omc.SetWRite([local]);
 omc.Write('initializing modem... ');
 if omc.AtCommand('ATS0=1') then omc.writeln('ok') else
   begin
   write('failed');
   halt(2);
   end;
 with omc do
  begin
  setwrite([local,remote]);
  repeat until cd;
  crt.delay(2000);
  clrscr;
  textcolor(red);
  gotoxy(20,5);
  textcolor(blue);
  write('here!');
  moverelx(-10);
  textcolor(magenta);
  write('b');
  repeat until empty;
  if hangup then;
  end;
 end;

end.