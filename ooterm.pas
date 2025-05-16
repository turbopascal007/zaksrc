uses Modem,Crt,Dos;

const Port = 2;
var Output:^ModemObj;
    c:char;

begin
New(output);
 if not output^.init(port) then
   begin
   Writeln;Writeln(^G,' * FOSSIL Driver Not Loaded, Aborting.');halt(1);
   end;
 Output^.SetParams  ( 2400 , 8 , 'N' , 1 );

 Output^.KillIn;
 Output^.KillOut;

 repeat
    begin
    if Crt.keypressed then
       begin
       c:=Crt.readkey;
       Output^.WriteChar(c)
       end;
    If Output^.Available then write(Output^.Readkey);
    end
 until c=^X;
dispose(output);
end.