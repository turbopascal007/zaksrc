Uses Crt, NetBios;

var SessNum:byte;




begin

if Net_AddName('486') then
  begin
  if Net_Call('XANADU',sessnum) then
    begin



    if not Net_Hangup(sessnum) then writeln('HangUp Failed');
    end
  else
    begin
    writeln('Call Failed');
    end;
  if not Net_DelName then writeln('delname failed');
  end
else
  begin
  writeln('Addname Failed');

  end;
end.