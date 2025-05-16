Unit ModemCrt;
{$O+}
{$F+}

interface

uses Modem;

type ExitFosType = (Hot,Cold);
     ExitLineType = (Hang,NoHang);

const
  Black     = 0 ; DarkGray     =  8;
  Blue      = 1 ; LightBlue    =  9;
  Green     = 2 ; LightGreen   = 10;
  Cyan      = 3 ; LightCyan    = 11;
  Red       = 4 ; LightRed     = 12;
  Magenta   = 5 ; LightMagenta = 13;
  Brown     = 6 ; Yellow       = 14;
  LightGray = 7 ; White        = 15;


type
  WriteType = (Local,Remote);
  WriteTypeSet = Set of WriteType;

  pModemCrtObj = ^ModemCrtObj;
  ModemCrtObj = Object(ModemObj)
   Constructor Init(c:byte;UseModem:boolean;W:WriteTypeSet);
   Destructor  Done(Cl:ExitFosType;line:ExitLineType);

   Function   CD:boolean; virtual;

   Function  DetectANSI: boolean;

   Function  Spec:byte;virtual;
   Function  Rev :byte;virtual;
   Function  ID  :String;virtual;
   Function  InputBuf : word;virtual;
   Function  OutputBuf: word;virtual;
   Function  DTEBaud: word;virtual;
   Function  OutBufUsed: word;virtual;
   Function  InBufUsed: word;virtual;
   Function  HangUp:boolean;virtual;


   Procedure SetWrite(W:WriteTypeSet);

   Function  WhereX:byte;
   Procedure Write(s:string);virtual;

   Procedure WriteLn(s:string);virtual;
   Function  ReadKey(var extend:char):char;virtual;
   Function  KeyPressed:boolean;

   Procedure MoveRelX(x:integer);
   Procedure MoveRelY(y:integer);
   Procedure GotoXY(x,y:byte);

   Procedure ClrScr;
   Procedure ClrEol;
   Procedure Delay (l:word);

   Procedure TextColor(c:byte);
   Procedure TextBackground(c:byte);

   private
    UsingModem:boolean;
    Wr:WriteTypeSet;
   end;

implementation

Uses Gansi,Crt;

Destructor ModemCrtObj.Done(cl:exitfostype;line:exitlinetype);
 var d:boolean;
 begin
 if (line=hang) and UsingModem then d:=Hangup;
 if usingmodem and not d then
   begin
   case random(2) of
    0:System.Writeln(^G,' û Could NOT Hang Up Line!');
    1:System.Writeln(^G,' ð Das telephoneline ist nicht der hangedup');
    end
   end;
 if usingmodem and (cl=cold) then Close;
 end;

function ModemCrtObj.DetectANSI:boolean;
 var inchar:char;
     allwait,wait: word;
 begin
 if dtebaud>2400 then allwait := 1500 else allwait := 500;
 KillIn;
 ModemObj.Write(#27+'[6n'+#8+#8+#8+#8);
 inchar:=#0;
 wait := 0;
 repeat begin
  if Available then
     begin
     inchar:=ModemObj.ReadKey;
     wait:=allwait
     end
   else
     begin
     delay(2);
     inc(wait,2)
     end
  end
 until wait>=allwait;
 DetectAnsi:=inchar = #27;
 end;

function ModemCrtObj.cd:boolean;
 begin
 if usingmodem then cd:=modemobj.cd else cd:=true;
 end;

Constructor ModemCrtObj.Init(c:byte;UseModem:boolean;W:writetypeset);
 begin
 if UseModem then
  if not ModemObj.Init(c) then
    begin
    System.Writeln;
    Randomize;
    Case Random(3) of
     0:System.Writeln(^G,' û FOSSIL Driver Not Loaded! -- Aborting');
     1:System.Writeln(^G,' þ Il n''y a pas un FOSSIL conducteur -- J''ai avort‚.');
     2:System.Writeln(^G,' ð ­ACHTUNG!  Das computermachine ast nicht der FOSSILdriveur springenwverk.');
     end;
    Halt(1);
    end;
 UsingModem:=UseModem;
 SetWrite(w);
 end;

Function  ModemCrtObj.Spec:byte;
 begin
 if usingmodem then spec := ModemObj.Spec else Spec:=0
 end;

Function  ModemCrtObj.Rev :byte;
begin
 if usingmodem then Rev := ModemObj.Rev else Rev:=0
 end;


Function  ModemCrtObj.ID  :String;
begin
 if usingmodem then ID := ModemObj.ID else ID:='..but I''m not using a FOSSIL driver!';
 end;


Function  ModemCrtObj.InputBuf : word;
 begin
 if usingmodem then InputBuf := modemobj.inputbuf else inputbuf := 0;
 end;

Function  ModemCrtObj.OutputBuf: word;
 begin
 if usingmodem then outputbuf:=modemobj.outputbuf else outputbuf:=0;
 end;

Function  ModemCrtObj.DTEBaud: word;
 begin
 if usingmodem then DTEbaud := modemobj.dtebaud else dtebaud := 0;
 end;

Function  ModemCrtObj.OutBufUsed: word;
 begin
 if usingmodem then outbufused:=modemobj.outbufused else outbufused:=0;
 end;

Function  ModemCrtObj.InBufUsed: word;
 begin
 if usingmodem then inbufused:=modemobj.inbufused else inbufused:=0;
 end;

Function  ModemCrtObj.HangUp:boolean;
 begin
 if usingmodem then hangup:=modemobj.hangup else hangup:=true;
 end;


Function ModemCrtObj.WhereX:byte;
 begin
 WhereX:=Crt.Wherex;
 end;

Procedure ModemCrtObj.SetWrite(W:WriteTypeSet);
 begin
 Wr:=w
 end;

Procedure ModemCrtObj.Write(s:string);
 begin
 if (Local in Wr) then System.Write(s);
 if (UsingModem and (Remote in Wr)) then
   begin
   repeat until OkToSend;
   ModemObj.Write(s);
   end;
 end;

Procedure ModemCrtObj.WriteLn(s:string);
 begin
 if (Local in Wr) then System.WriteLn(s);
 if (UsingModem and (Remote in Wr)) then
   begin
   repeat until OkToSend;
   ModemObj.WriteLn(s);
   end;
 end;

Function  ModemCrtObj.ReadKey(var extend:char):char;
 const bf=3;
 var c:char;
     z:array[1..bf] of char;
     f:boolean;

 procedure pausekey;
   var timer:byte;
   begin
   timer:=0;

   While (timer<40) do
       begin
       if Available then exit;
       delay(1);
       inc(timer,1);
       end;
   end;

 begin
 if UsingModem then
   begin
   if not CD then RunError(300);
   repeat until (Crt.KeyPressed OR Available);
   if Crt.KeyPressed then
     begin
     c:=Crt.Readkey;
     ReadKey:=c;
     if c=#0 then extend:=Crt.Readkey;
     end
   else
     begin
     z[1]:=ModemObj.Readkey;

     pausekey;

     if not CD then RunError(300);

     z[2]:=PeekAhead;

     if (z[1]=^[) {ESC} and not(z[2]=#0) then
       begin
       if (z[2]='[') then
         begin
         Snarf(1); { make up for the '[' }
         ReadKey:=#0;

         repeat z[3] := PeekAhead until not(z[3]=#0);

         case z[3] of
           'A':Extend:=chr(72); { up }
           'B':extend:=chr(80); { down }
           'C':extend:=chr(77); { right }
           'D':extend:=chr(75); { left }
           'H':extend:=chr(71); { home }
           'K':extend:=chr(79); { end }
            end;

         Snarf(1); { make up for the (A,B,C,D) }
         end
       else
         begin
         readkey:=z[1];
         end
       end
     else
      readkey:=z[1];

     if z[1]=#127 then begin readkey:=#0; extend:=#83 end; { DEL }
     end;
   end
 else
  begin
   c:=Crt.Readkey;
   Readkey:=c;
   if c=#0 then extend:=crt.readkey;
  end
 end;

Function  ModemCrtObj.KeyPressed:boolean;
 begin
 KeyPressed := (Available and UsingModem) OR Crt.KeyPressed;
 end;

Procedure ModemCrtObj.MoveRelX(x:integer);
 begin
 If (Local in Wr) then Crt.gotoxy(wherex+x,wherey);
 if (UsingModem and (Remote in Wr)) then
   begin
   if x>0 then ModemObj.Write(Gansi.CursorRight(x))
   else if x<0 then ModemObj.Write(Gansi.CursorLeft(-x));
   end;
 end;

Procedure ModemCrtObj.MoveRelY(y:integer);
 begin
 If (Local in Wr) then Crt.gotoxy(wherex,wherey+y);
 if (UsingModem and (Remote in Wr)) then
   begin
   if y>0 then ModemObj.Write(Gansi.CursorDown(y))
   else if y<0 then ModemObj.Write(Gansi.CursorUp(-y));
   end;
 end;

Procedure ModemCrtObj.GotoXY(x,y:byte);
 begin
 If (Local in Wr) then Crt.gotoxy(x,y);
 if (UsingModem and (Remote in Wr)) then ModemObj.Write(Gansi.SetPos(x,y));
 end;

Procedure ModemCrtObj.ClrScr;
 begin
 if (local in Wr) then Crt.Clrscr;
 if (UsingModem and (Remote in Wr)) then ModemObj.Write(Gansi.Cls);
 end;

Procedure ModemCrtObj.ClrEol;
 begin
 if (local in Wr) then Crt.ClrEol;
 If (UsingModem and (Remote in Wr)) then ModemObj.Write(Gansi.DelLine);
 end;

Procedure ModemCrtObj.Delay (l:word);
 begin
 Crt.Delay(l);
 end;

Procedure ModemCrtObj.TextColor(c:byte);
 begin
 if (Local in Wr) then crt.textcolor(c);
 if (UsingModem and (Remote in Wr)) then
    ModemObj.Write(Gansi.SetFG(c));
 end;

Procedure ModemCrtObj.TextBackground(c:byte);
 begin
 if (Local in Wr) then crt.textbackground(c);
 if (UsingModem and (Remote in Wr)) then
    ModemObj.Write(Gansi.SetBG(c));
 end;

end.
