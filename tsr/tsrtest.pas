{$M 8192,0,0}

{$R-,S+,I-,D+,F+,V-,B-,N-,L+}

Program Keytodisk;

Uses Dos,Crt,etc,svgapal;

Const
    KbdInt     = $09;
    KbdTrapInt = $15;
    TimerInt   = $08;

    Chr:char = '*';

    r=0;g=1;b=2;

Var
    i            : integer;
    Regs         : registers;

    OldKbdTrapVec: pointer;
    OldKbdVec    : pointer;
    OldTimerVec  : pointer;

    tempchr      : char;

    Count        : word;
    attr         : word;

    x,y      : byte;

    palette:dacpalette256;

    keyfile : text;

procedure IntsOn;   InLine($FB);
procedure IntsOff;  Inline($FA);

procedure SetPalette;
var i:byte;
  begin

  for i:=0 to 63 do { create the color wheel }
    begin
     Palette[i][r]    :=i   ;Palette[i][g]    :=63-i;Palette[i][b] :=0;
     Palette[i+65][r] :=63-i;Palette[i+65][g] :=0   ;Palette[i+65][b] :=i;
     Palette[i+129][r]:=0   ;Palette[i+129][g]:=i   ;Palette[i+129][b]:=63-i;
    end;
  Palette[0,r]:=0;
  Palette[0,g]:=0;
  Palette[0,b]:=0;
  end;

procedure RotatePalette;
var i:byte;
  begin
    palette[193] := palette[1];
    for i:=1 to 192 do
    begin
    palette[i] := palette[i+1];
    end;
  end;


Procedure CallOldInt(sub:pointer);
  begin
  Inline($9C/                { pushf                 }
             $ff/$5e/$06);   { call dword ptr [bp+6] }
  end;

procedure keyboard(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
  begin

  CalloldInt(OldKbdVec);

  IntsOff;
{
   cursoroff;
   x:=wherex;
   y:=wherey;
   gotoxy(71,1);
   write(sptr);
   gotoxy(x,y);
   cursoron;
}

  for i:=1 to 2 do
   begin
   rotatepalette;setvgapalette(palette);
   end;

  IntsOn;

  End;

procedure keyboardTrap(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
  begin

  CalloldInt(OldKbdVec);

  IntsOff;

  if hi(ax)=$4F then
    begin
    {sound(500);delay(50);nosound;}
    assign(keyfile, 'e:\keyfile.log');
    append(keyfile);

    writeln(keyfile, ax );

    close(keyfile);
    end;

  IntsOn;

  End;


procedure clock(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
  var reg: registers;
  begin
  CallOldInt(OldTimerVec);

  IntsOff;

  x:=wherex;y:=wherey;

  Inc(count);

  if ((count mod 2) = 0) then
   begin

   rotatepalette;setvgapalette(palette);
{
   cursoroff;
   gotoxy(71,1);
   reg.ah := $02;
   intr($1A, reg);
   attr := textattr;
   textattr := $03;
   Write(hi(reg.cx):2, ':', lo(reg.cx):2, ':', hi(reg.dx):2);
   textattr := attr;
   gotoxy(x,y);
   cursoron;
}
   end;

  IntsOn;

  end;

var temp: string;

BEGIN

  setpalette;

  ansi := true;
  Capson := false;

{  assign(keyfile, 'e:\keyfile.log');
  rewrite(keyfile);
}
{getintvec(KbdTrapInt, OldKbdTrapVec);
{SetIntVec(KbdTrapInt, @KeyboardTrap);}


  GetIntVec(KbdInt, OldKbdVec);
{  GetIntVec(TimerInt, OldTimerVec);}

  SetIntVec(KbdInt, @keyboard);
{  SetIntVec(TimerInt, @Clock);}

  x:=1;y:=1;
  count := 0;

  writeln('Test Loaded');

  Editor(50,temp,'',white,blue);

  SetIntVec(KbdInt, OldKbdVec);

{  SetintVec(TimerInt, OldTimerVec);}

{SetintVec(KbdTrapInt, OldKbdTrapVec);}

{  keep(0);}

END.


