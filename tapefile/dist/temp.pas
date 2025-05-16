{ Procedures/Functions from ETC }

procedure CurTime(var h:word; var m: word;var s:word);
 Var Hour,Min,Sec,Sec100:word;
 begin
 GetTime(Hour,Min,Sec,Sec100);
 h:=hour;
 m:=min;
 s:=sec;
 end;

function SecondsSinceMidnight(h,m,s:word):longint;
  begin
  SecondsSinceMidnight := (h*3600)+(m*60)+s
  end;

function ExistFile(s:string):boolean;
  var re:searchrec;
  begin
  FindFirst(s,$3F,re);
  ExistFile := not(DosError=18)
  end;

Procedure CursorOff;
  var regs:registers;
  Begin
  Regs.Ax := $0100;
  Regs.Cx := $2807;
  Intr($10,Regs);
  End;

Procedure CursorOn;
  var regs:registers;
  Begin
  Regs.Ax := $0100;
  If LastMode = Mono Then
    Regs.Cx := $090A
  Else
    Regs.Cx := $0607;
  Intr($10,Regs);
  End;

function lowcase(ch: char): char;
  begin
  ch := upcase(Ch);
  case ord(ch) of
  65..90: Lowcase := chr(ord(ch)+32);
  else Lowcase := Ch;
  end;
  end;

function CaseStr(s: string): string;
   var i: byte;
   begin
   s[1] := upcase(s[1]);
   for i := 2 to ord(s[0]) do
       begin
       case ord(s[i-1]) of
        32..46,58..64,91..96,132..126
          :  s[i] := upcase(s[i]);
        else s[i] := lowcase(s[i]);
        end;
       end;
   CaseStr := s;
   end;

function UpcaseStr(s:string):string;
  var a:byte;
  begin
  for a:=1 to ord(s[0]) do s[a] := upcase(s[a]);
  UpCaseStr := s;
  end;

function CurTimeStr: string;
 Var Hour,Min,Sec,Sec100:word;
     HourS,MinS,SecS,Sec100s:string[2];
     i:byte;
     t:string;
 begin
 GetTime(Hour,Min,Sec,Sec100);
 Str(Hour:2,HourS);
 Str(Min:2,MinS);
 Str(Sec:2,Secs);
 t:=concat(HourS,':',MinS,':',SecS);
 for i:=1 to ord(t[0]) do
  if t[i]=' ' then t[i]:='0';
 CurTimeStr:=t;
 end;

function DtTmStamp: string;
 var m,d,y,dw: word;
     sm,sd: string[2];
     sy:string[4];
     ts:string;
     i:byte;
 begin
 getdate(y,m,d,dw);
 str(m:2,sm);
 str(d:2,sd);
 str(y:4,sy);
 sy:=copy(sy,3,2);
 ts:=concat(sy,'-',sm,'-',sd);
 for i:=1 to ord(ts[0]) do if ts[i]=' ' then ts[i]:='0';
 ts:=ts+' '+curtimestr;
 DtTmStamp:=ts;
 end;


{ WARNING - I have not tested this with anything other than port 1 ! }
Function Carrier_On:boolean;          {TRUE if carrier present}
     var a:word;
     begin
     case PortNum of
       1: A := $3F8;
       2: A := $2F8;
       3: A := $3E8;
       4: A := $2E8;
       end;
     Carrier_On:=odd ( Port[ A + $06 ] shr 7 )
     end;

function compare(s1,s2:string):byte;
 begin
 s1:=upcasestr(s1);
 s2:=upcasestr(s2);
 if s1 = s2 then compare:=0;
 if s1 < s2 then compare:=2;
 if s1 > s2 then compare:=1;
 end;

Function LTab(n: integer;m:integer):string;
  var a: string;
      b: integer;
  begin
  a := '';
  for b := n+1 to m do a:=a+' ';
  Ltab := a;
  end;

function ltrim(s:string):string;
  begin
  if s='' then begin ltrim:=''; exit end;
  repeat
    begin
    if s[1]=' ' then delete(s,1,1);
    end;
  until s[1]<>' ';
  ltrim:=s;
  end;

function rtrim(s:string):string;
  var a: byte;d:boolean;
  begin
  if s='' then begin rtrim:=''; exit end;
  d:=false;
  a:= ord(s[0]);
  repeat
   if s[a]=#32 then
    begin
    s[0] := chr(ord(s[0])-1);
    dec(a);
    end
  else d:=true;
  until d;
  rtrim:=s;
  end;

function ToStrb(var s: byte): string;
  var a: string;
  begin
  str(S,A);
  ToStrb:=A;
  end;

{ end }
