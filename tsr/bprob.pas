{$M 2000,0,0}
{$F+,W+}

Uses Crt,Dos;

var
  Clock_Ticks : longint absolute $0040:$006C; { BIOS timer ticks }

Type  t = record
        c:char;
        a:byte;
        end;
      ScrnBuffer = Array[ 80*25 ] of t;

var       Screen: ScrnBuffer absolute $b800:0000 ;

Const
         TimerInt   = $08;

Var Critical: byte absolute $011c:0320;
    Dos_Busy: byte absolute $011c:0321;

Var      count        : longint;
         OldTimerVec  : pointer;

procedure clock(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
  begin

  asm
   call OldTimerVec;
  end;

  Inline($FA); { intsoff }

  if ((Dos_busy=0) and (critical=0)) then
   begin
   inc(count);
   if (count mod 5)=0 then
    begin

I have an other solution for you !
The top of the buffer is at address : $40:$1a
The end is at address $40:$1c
You can put the end of the buffer at the top of the buffer by the line :

    mem [$40:$1c] := mem [$40:$1a] ;

    end;

   end;
  inline($FB); { intson }
  end;


begin
  directvideo:=true;
  GetIntVec(TimerInt, OldTimerVec);
  SetIntVec(TimerInt, @clock);

  count:=0;

  exec(getenv('COMSPEC'),'');

  SetintVec(TimerInt, OldTimerVec);

end.