Uses Crt, Dos, SlDriv, Etc;

begin
 LoadSlData;
 If SlActive then
  begin
  if upcasestr(Paramstr(1)) = 'ON'  then LocalAndRemote;
  if Upcasestr(paramstr(1)) = 'OFF' then localonly;
  end;
end.