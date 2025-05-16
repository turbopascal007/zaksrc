Program AutoSearchlightAnsi;

Uses Crt, Dos, SlFiles, Modem, Etc;

const s1:string=' þ Client Terminal Has ANSI Emulation Capabilities';
      s2:string=' þ Client Terminal Has No ANSI Emulation Capabilities';
      s3:string=' þ Client Terminal Has Undeterminable ANSI Emulation Capabilities';

Var
    blah   : text;
    regs   : registers;
    inchar : char;
    Wait   : longint;
    out    : boolean;
    baudst : string;
    allwait: word;
    bpsr   : word;
    tv     : word;
    arq    :boolean;

    m      : ModemObj;

begin
 if paramcount>1 then baudst:=paramstr(2) else baudst:='';

 arq:=pos('ARQ',baudst)>0;

 if arq then allwait:=2000 else allwait:=500;

 val( copy(baudst,1,pos('/',baudst)-1) , bpsr , tv );

 crt.directvideo := false;
 slfiles.pathtoconfig:='';
 slfiles.Open_Config;
 slfiles.Read_Config;

 if not M.Init(Cfg.Comport) then halt;

 write('Checking for Ansi color... ');

 M.killin;
 m.write(#27+'[6n'+#8+#8+#8+#8);
 wait:=0;
 out:=false;
 inchar:=#0;
 repeat
   begin
   if m.available then
         begin
         inchar:=m.readkey;
         wait:=allwait
         end
   else
         begin
         delay(2);
         inc(wait,2)
         end
   end
 until wait>=allwait;

 if inchar = #27 then
          begin
          gotoxy(1,wherey);writeln(s1);
          m.writeln(^G+s1);
          ungetch(ord('C'));
          end
 else
        begin
        gotoxy(1,wherey);writeln(s2);
        m.writeln(^G+s2);
        ungetch(ord('N'));
        end;
     m.killin;

  close_Config;
end.
