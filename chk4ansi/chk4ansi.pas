Program Chk4Ansi;

Uses Crt, Dos, SlFiles, SlDriv, FosCom, Etc, UpTime;

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
    arq    :boolean;

    douptime : boolean;
    uts:string;

begin
 {$IFDEF debug}
 writeln(uptimestr);
 halt;
 {$endif}


 if paramcount>1 then baudst:=paramstr(1) else baudst:='';

 douptime := paramcount>=2;

 arq:=pos('ARQ',baudst)>0;

 if arq then allwait:=1500 else allwait:=500;

 crt.directvideo := false;

 slfiles.pathtoconfig:='';
 slfiles.Open_Config;
 slfiles.Read_Config;

 if slactive then
   begin
   LocalOnly;
   NoComInput;
   end;

 Fos_Init(Cfg.Comport);

 write('Checking for Ansi color... ');

 if pos('HST',baudst)=0 then
     begin
     Fos_Kill_In (cfg.comport);
     Fos_String(Cfg.Comport,#27+'[6n'+#8+#8+#8+#8);
     wait:=0;
     out:=false;
     inchar:=#0;
     repeat
      begin
      if Fos_Avail(Cfg.ComPort) then
         begin
         inchar:=Fos_Receive(Cfg.Comport);
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
        if slactive then
          begin
          cfg.ansi := true;
          cfg.color := true;
          Data^.Ansi := true;
          write_config;
          end
        else
          begin
          gotoxy(1,wherey);writeln(s1);
          Fos_StringCRLF(cfg.comport,^G+s1);
          {UnGetCh('C');}
          end
     else
       if not slactive then
        begin
        gotoxy(1,wherey);writeln(s2);
        Fos_StringCRLF(cfg.comport,^G+s2);
        {UnGetCh('N');}
        end
       else
        begin
        cfg.ansi:=true;
        cfg.color:=true;
        data^.ansi:=true;
        write_config;
        end;
     if not slactive then Fos_Kill_in (cfg.comport);
     end
 else
   begin
   gotoxy(1,wherey);writeln(s3);
   Fos_StringCRLF(cfg.comport,^G+s3);
   end;


 if douptime then
   begin
   uts:=#13+#10+' þ System Has Been Up For '+uptimestr;

   writeln(uts);

   Fos_StringCRLF(cfg.comport,uts);

   end;

 close_config;

 if slactive then begin
  LocalAndRemote;
  ComInput;
  end;

end.
