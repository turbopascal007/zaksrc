{$M 10000,0,0}
{$F+,W+,R-,S-}

Uses Crt,Dos;

Const
         TimerInt   = $08;

Var Critical: byte absolute $011c:0320;
    Dos_Busy: byte absolute $011c:0321;

Var
         OldTimerVec  : pointer;

procedure clock(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
  begin

  asm
   call OldTimerVec;
  end;

  Inline($FA); { intsoff }

{  if ((Dos_busy=0) and (critical=0)) then}
   begin
   write('.');
   end;
  inline($FB); { intson }
  end;


begin
  directvideo:=true;
  GetIntVec(TimerInt, OldTimerVec);
  SetIntVec(TimerInt, @clock);

  exec(getenv('COMSPEC'),'');

  SetintVec(TimerInt, OldTimerVec);

end.