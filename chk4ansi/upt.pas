Program Upt;

{$define exhtra}

Uses Crt, Dos, SlFiles, SlDriv, FosCom, Etc, UpTime;

function Extra(var baud:word):string;
 var f:text;
     s,bs:string;

     e:string;

 begin
 {$I-}
 assign(f,'j:\db\thiscall.txt');
 reset(f);
 {$i+}
 if not ioresult=0 then
   begin
   writeln('error j:\db\thiscall.txt');
   exit;
   end;

 readln(f,s);
 close(f);

 bs:=copy(s,pos('CONNECT ',s)+8,length(s)-pos('CONNECT ',s)-8);

 baud := toint(copy(bs,1,pos('/',bs)-1));

   e:=' þ High Speed Protocols: ';
   if pos('HST'    ,bs)>0 then e:=concat(e,'HST ');
   if pos('V32'    ,bs)>0 then e:=concat(e,'v32 ');
   if pos('V42'    ,bs)>0 then e:=concat(e,'v42 ');
   if pos('V42BIS' ,bs)>0 then e:=concat(e,'v42á ');
   if pos('MNP4'   ,bs)>0 then e:=concat(e,'MNP4 ');
   if pos('MNP5'   ,bs)>0 then e:=concat(e,'MNP5 ');

 extra:=e;
 end;

var uts,e: string;
    baud:word;

begin
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

 {$ifdef extra}

 e:=Extra(baud);

 if baud>2400 then
  begin
  writeln(e);
  fos_stringcrlf(cfg.comport,e);
  end;

 {$endif}

 uts:=#13+#10+' þ System Has Been Up For '+uptimestr;

 writeln(uts);

 Fos_StringCRLF(cfg.comport,uts);

 close_config;

 if slactive then begin
  LocalAndRemote;
  ComInput;
  end;

end.
