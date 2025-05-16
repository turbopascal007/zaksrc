Program SlCalls;
uses Crt,SlfLow;

var Log:logtype;
    a  :byte;

procedure process;
  begin



  end;

Begin
Init_Config('',closed);
Init_Log(log);
close_log;

a:= log.head;
repeat
 begin
 process;
 dec(a,1);
 if a=0 then a:=logsize;
 end
until i=log.head;

end.