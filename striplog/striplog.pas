Program StripLog;

{$B-}

Uses Dos,Crt;

Type BufType = array[1..65520] of byte;

Var inLog  : text;
    outLog : text;
    line   : string;
    lastl  : string;

    inBuf  : ^buftype;
    outBuf : ^buftype;
    lc     : longint;

    delline: boolean;

    procpos :byte;

    Grr    : boolean;

procedure procline;
 var tempstr:string;
 begin
 Grr := False;
 if pos('redialing.',line)>0 then exit;

 if (lc mod 50)=0 then begin gotoxy(18,wherey);write(lc) end;

 if (Pos('Calling',line)=0) and (pos('"BUSY"',line)=0) then
   begin

   if (pos('Z32-',line)>0) or (Pos('IZE-',line)>0) then
    begin
    tempstr:=copy(line,24,pos(',',copy(line,24,length(line)-24)));
    if pos('.',tempstr)>0 then
      begin
      write(outlog,copy(line,1,length(line)-5),' ');
      readln(inlog,line);
      procline;
      end
    else
      begin
      writeln(outlog,copy(line,24,length(line)-24+1));
      GRr := True;
      exit;
      end;
    end;

   procpos:=pos('Incoming call',line);
   if procpos>0 then
     begin
     delete(line,17,length('Incoming Call'));
     insert('Inbound',line,17)
     end;

   procpos:=pos('Modem reports',line);
   if procpos>0 then
      begin
      delete(line,17,length('Modem reports'));
      insert('Outbound',line,17)
      end;


   if not Grr then writeln(outLog,line);
   delline:=false;
   end
 else
   begin
   if not delline then writeln(outLog,copy(lastl,1,14),'  redialing...');
   delline:=true;
   end;

 lastl:=line;

 end;

begin
directvideo:=true;
lc:=0;

new(inBuf);
new(outBuf);

assign(inLog, 'DB.LOG');
assign(outLog,'DB.$$$');

reset(inLog);settextbuf(inLog,inBuf^,sizeof(inBuf^));

rewrite(outLog);settextbuf(outLog,outBuf^,sizeof(outBuf^));

write('Processing line: ');

lastl:='';

delline:=false;
while not eof(inLog) do
 begin
 readln(inLog,line);
 inc(lc);

 procline;

 end;

writeln;
close(inLog);
close(outLog);

erase(inLog);
rename(outLog,'DB.LOG');
end.