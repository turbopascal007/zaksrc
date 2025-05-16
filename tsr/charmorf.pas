{$M 2000,0,0}
{$F+,W+}

Uses Crt,Dos;

var
  Clock_Ticks : longint absolute $0040:$006C; { BIOS timer ticks }

  KBDStatus   : byte absolute $0:$0417;

  InitialKBDStatus : byte;

Type ScrnBuffer = Array[1..2048] of byte;
var       Screen: ScrnBuffer absolute $b800:0000 ;

Const
         KbdInt     = $09;
         KbdTrapInt = $15;
         TimerInt   = $08;

         Num = $20;
         Scr = $10;
         Cap = $40;

Var Critical: byte absolute $011c:0320;
    Dos_Busy: byte absolute $011c:0321;


Var      i:word;
         Regs         : registers;
         OldKbdTrapVec: pointer;
         OldKbdVec    : pointer;
         OldTimerVec  : pointer;
         t            :word;

procedure clock(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
  var reg: registers;
  begin

  asm
   call OldTimerVec;
  end;

  Inline($FA); { intsoff }

  if ((Dos_busy=0) and (critical=0)) then
   begin
   if true then
    begin
  {
    i:=1;
    repeat
      begin

      screen[i] := screen[i] and random(32);

      inc(i,2);
      end;
    until i>=2048;
  }

    KbdStatus := KbdStatus XOR Num;
 {   KbdStatus := KbdStatus XOR Cap;
    KbdStatus := KbdStatus XOR Scr; }

    end;

   end;
  inline($FB); { intson }
  end;


begin
  initialkbdstatus:=kbdstatus;

  directvideo:=true;
  GetIntVec(TimerInt, OldTimerVec);
  SetIntVec(TimerInt, @clock);

  exec(getenv('COMSPEC'),'');

  SetintVec(TimerInt, OldTimerVec);

end.