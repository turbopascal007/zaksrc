Program CheckDb;
{$X+}
Uses Crt, Dos, Etc;

const lookfor   = 'ECHOMAIL';
      bragline  = 'CheckDb - Check for new Echomail/DB.LOG : ';

{type bffrtype = array[1..32768] of byte;}
Type BffrType = array[1..64000] of byte;

var
  dblog       : text;
  templine    : string;
  oldtempline : string;
  linecounter : longint;

  bffr        : ^bffrtype;

  start       : longint;

procedure status;
 var x,y:byte;
 begin
  if (linecounter mod 100)=0  then
    begin

    gotoxy(length(bragline)+1,wherey);

    if (nowsecondssincemidnight-start)>0 then
     write(linecounter:6,' (',
       (linecounter div (nowsecondssincemidnight-start)):4,')');

    clreol;

    end;
 end;

begin
  new(bffr);

  assign(dblog, 'db.log');
  reset(dblog);
  settextbuf(dblog,bffr^,sizeof(bffr^));

  directvideo := true;

  linecounter := 0;
  templine:='';
  oldtempline:='';

  clrscr;
  gotoxy(1,1);

  write(Bragline);

  start:=nowsecondssincemidnight;

  repeat
     begin
     oldtempline:=templine;
     readln(dblog, templine);
     inc(linecounter);

     status;
     if keypressed then
       begin
       readkey;
       writeln;
       Writeln('Aborted by Operator');
       halt(0);
       end;

     end;
  until eof(dblog);
  writeln;

  if (pos(lookfor,concat(upcasestr(oldtempline),upcasestr(templine))) > 0)
     then
       begin
       Writeln('Echomail found');
       halt(1)
       end

     else
       begin
       Writeln('Echomail not found');
       halt(0);
       end;

end.
