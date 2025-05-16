Program SysChat;

Uses Crt,Dos,Etc,Pauses,Modem;

procedure p;
 begin
 if lo(dosversion)=20 then os2pause;
 end;

var io:pmodemobj;

begin
io:=new(pmodemobj);

io^.init(toparamstr(



end.