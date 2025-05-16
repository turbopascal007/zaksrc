Program SL_IEMSI;

Uses FosCom, Etc;

var
  Clock_Ticks : longint absolute $0040:$006C; { BIOS timer ticks }

Function NowTimer: longint; { Returns the timer value }
begin
  NowTimer := Clock_Ticks;
end;

Function ElapsedTime(start:longint): longint; { Returns elapsed ticks }
const                  { clock rate is 1,193,180/65536 times a second }
  dticks = 1573040;    { #-o-ticks per 24 hours }
begin
  if Clock_Ticks < start then
   ElapsedTime := dticks - (start - Clock_Ticks)
  else ElapsedTime := Clock_Ticks - start;
end;


Var Timer1,Timer2: longint;

begin









end.
