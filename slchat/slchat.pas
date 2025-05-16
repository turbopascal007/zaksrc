Program SlChat;

Uses Crt, ooSLfLow, ooSlDriv;

Var Config: pSLConfigObj;
    Driver: pSlDrivObj;


Procedure Page(s:boolean);
 procedure b(f:word;l:word);
  begin
  sound(f);
  delay(l);
  end;

 var i,c:word;

 begin
 Write('Paging ');
 c:=0;

 repeat begin
  for i:=1 to 25 do b(320*i,5);
  for i:=25 downto 1 do b(320*i,5);
  write('.');
  inc(c,1);
 end until (c>25) or KeyPressed {And (Driver^.LastKey or (not Driver^.SlActive))};

 nosound;
 end;



begin

Config := New(pSLConfigObj,Init(''));
Driver := New(pSlDrivObj,Init);

if NOT Config^.Data.SysAvail then Page(true);






dispose(Config,Done);
Dispose(Driver);

end.
