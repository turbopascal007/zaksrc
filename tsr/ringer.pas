{$M 8192,0,0}

{$R-,S+,I-,D+,F+,V-,B-,N-,L+}

Program Keytodisk;

Uses Dos,Crt,CrtCapt,etc;

Const
    TimerInt   = $08;
    Uart_MSR   = $06;
    Port_Offs  = $3f8; { com1 }

Const Port_MSR_RI = Port_Offs+Uart_Msr;

Var
    x,y          : byte;

    c            : longint;
    S            : ScreenArrayType;

    Regs         : registers;

    OldTimerVec  : pointer;

    Ringing      : boolean;

procedure IntsOn;   InLine($FB);
procedure IntsOff;  Inline($FA);

Procedure CallOldInt(sub:pointer);
  begin
  Inline($9C/                { pushf                 }
             $ff/$5e/$06);   { call dword ptr [bp+6] }
  end;

procedure clock(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
  var reg: registers;
  begin
  CallOldInt(OldTimerVec);

  IntsOff;

  inc(c);

  if (c mod 2)=0 then
    if odd(Port[Port_MSR_Ri] shr 6) then
     if not ringing then
      begin
      ringing:=true;
      x:=wherex;
      y:=wherey;
      SaveScreen(s);
      directvideo:=true;
      Gotoxy(60,1);

      write('  Ringing  ');

      gotoxy(x,y);
      end;

  if ringing then begin
        ringing:=not(ringing);
        restorescreen(s);
        end;

  IntsOn;

  end;


var temp:string;
BEGIN

  c:=0;

  ringing:=false;

  GetIntVec(TimerInt, OldTimerVec);

  SetIntVec(TimerInt, @Clock);

  writeln('Ringer Loaded');

  Editor(50,temp,'',white,blue);

  SetintVec(TimerInt, OldTimerVec);

{  keep(0);}

END.


