{$M 16385,0,655360}

{$R-,S+,I-,D+,F+,V-,B-,N-,L+}

Program Generic;

Uses Dos,Crt;

Const
    KbdInt   = $09;
    TimerInt = $08;

Var Regs         : registers;

    OldKbdVec    : pointer;
    OldTimerVec  : pointer;


procedure IntsOn;   InLine($FB);
procedure IntsOff;  Inline($FA);


Procedure CallOldInt(sub:pointer);
  begin
  Inline($9C/                { pushf                 }
             $ff/$5e/$06)    { call dword ptr [bp+6] }
  end;

procedure keyboard(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
  begin

  CalloldInt(OldKbdVec);

  IntsOff;

  if keypressed then
   begin
        end;

    #0       : if readkey=#45 then done := true;
    end;
   ix:=wherex;
   iy:=wherey;

   textattr := $07;
   window(1,minline,80,maxline-3);

   gotoxy(tx,ty);
   end;

  IntsOn;

  End;


procedure clock(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
  var reg: registers;
      x,y: integer;
      wmin,wmax:integer;

  begin
  CallOldInt(OldTimerVec);

  reg.ah := $02;
  intr($1A, reg);

  if ((reg.dh mod 2) = 0) then
    begin
    x:=wherex;y:=wherey;
    wmax:=windmax;
    wmin:=windmin;

    window(1,1,80,25);

   gotoxy(1,1);
    clreol;
    write('[',outstr,'] ',pending, '  ',sptr:4);

    window(lo(wmin),hi(wmin),lo(wmax),hi(wmax));
    gotoxy(x,y);
    end;


  Inc(count);

  if ((count mod 5) = 0) then
   begin
   cursoroff;
   gotoxy(71,1);

   reg.ah := $02;
   intr($1A, reg);

   attr := textattr;
   textattr := $03;
   Write(hi(reg.cx):2, ':', lo(reg.cx):2, ':', hi(reg.dx):2);
   textattr := attr;
   gotoxy(tx,ty);
   cursoron;
   end;




  STI;
  end;

var temp: string;
    code: word;

BEGIN


  maxline := 25;
  minline := 1;


  if paramcount>0 then
    val(paramstr(1),maxline,code);

  clrscr;

  assigncrt(adev);
  rewrite(adev);
{
  assign(log, 'chatdterm.log');
  append(log);
}

  minline :=2;

  ix:=1;
  iy:=1;

  tx:=1;
  ty:=1;

  window(1,maxline-2,80,maxline);

  textattr := $1f;

  clrscr;
  textattr := $07;

  window(1,minline,80,maxline-3);
  clrscr;

  done := false;
  commport := 1;

  Baud := 2400;
  Wordsize := 8;
  Parity := 'N';
  Stopbits := 1;

  pending := false;
  outstr := '';

  ansi := true;
  Capson := false;

   GetIntVec(KbdInt, OldKbdVec);
{   GetIntVec(TimerInt, OldTimerVec);}


   SetIntVec(KbdInt, @keyboard);
{   SetIntVec(TimerInt, @Clock);}


  tx:=1;ty:=1;
  count := 0;

  Async_Init;

  if not Async_open_flag then
     if not Async_Open(Commport, Baud, Parity,WordSize, Stopbits) then
       begin
       write(adev, 'Error opening comm port');
       end;

  repeat
    begin
    if Async_Buffer_Check(inchar) then
      if inchar <> #0 then
       begin
       write(adev, inchar);
       {write(log, inchar);}
       tx:=wherex;
       ty:=wherey;
       end;
     if pending then
      begin
      Async_Send_String(outstr);
      pending := false;
      outstr := '';
      end;
    end;
  until done;
  close(log);
  Async_Open_Flag := true;
 { Async_Close; }


  SetIntVec(KbdInt, OldKbdVec);
{  SetintVec(TimerInt, OldTimerVec);}


END.


