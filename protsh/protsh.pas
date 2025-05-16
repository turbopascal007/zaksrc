{$M 10000,0,0}

{$R-,S-,I-,D+,F+,V-,B+,N-,L+}

Program ProtocolShell;

Uses Dos,{crt,Dos,SLfLow,SLfHigh,}FastWr;

Const
  {  KbdInt   = $09;}
    KbdInt = $16;
    TimerInt = $08;

Var Critical: byte absolute $011c:0320;
    Dos_Busy: byte absolute $011c:0321;

Var
    OldKbdVec    : pointer;
    OldTimerVec  : pointer;

{    user:usertype;}

procedure keyboard(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
  begin

  asm
   call OldKbdVec;
  end;

  Inline($FA);

{  if ((critical=0) and (dos_busy=0)) then}
    begin

    fastwrite(0,24,2,'User: ');
{    sound(2000);
    nosound;}

    end;

  Inline($FB);

  End;

  {
procedure clock(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
  begin
  asm
    Call OldTimerVec;
  end;

  inline($FA);

  inline($FB);

  end;
  }



BEGIN
  {Init_Config( '.\', closed  );

  user_info(cfg.curruser,user);}

  GetIntVec(KbdInt, OldKbdVec);

{  GetIntVec(TimerInt, OldTimerVec);}

  SetIntVec(KbdInt, @keyboard);

{  SetIntVec(TimerInt, @Clock);}

  exec(GetEnv('COMSPEC'),'');

  SetIntVec(KbdInt, OldKbdVec);
 { SetintVec(TimerInt, OldTimerVec);}

END.


