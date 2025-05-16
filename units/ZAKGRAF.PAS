unit ZakGraf;

interface
uses svgapal;

procedure InitGraf800x600;
procedure initgraf1024x768;
Procedure ZakCircleFill(radius:real;color:word);
procedure rotatepalette;
procedure setpalette;
procedure InitGraf320x200;

var palette    : dacpalette256;

const r=0;b=1;g=2;


implementation

uses graph;

var
     grDriver   : integer ;
     grMode     : integer ;
     ErrCode    : integer ;


{$F+}
function ad800x600: integer;
 begin
 ad800x600:=3;
 end;

function ad320x200:integer;
 begin
 ad320x200:=0;
 end;

function ad1024x768:integer;
 begin
 ad1024x768:=4;
 end;

{$F-}




procedure SetPalette;
 var i:byte;
  begin

  for i:=0 to 63 do { create the color wheel }
    begin
     Palette[i+1][r]  :=i   ;Palette[i+1][g]  :=63-i;Palette[i+1][b]  :=0;
     Palette[i+65][r] :=63-i;Palette[i+65][g] :=0   ;Palette[i+65][b] :=i;
     Palette[i+129][r]:=0   ;Palette[i+129][g]:=i   ;Palette[i+129][b]:=63-i;
    end;

   palette[0,r]:=0;
   palette[0,g]:=0;
   palette[0,b]:=0;
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

procedure InitGraf320x200;
  begin
  GrDriver := InstallUserDriver('svga256',@Ad320x200);

  GrDriver := Detect;

  InitGraph(GrDriver,grMode,'c:\tp\bgi');
  SetColor(15);
  ErrCode := GraphResult;
  if ErrCode <> GrOk then
     begin
     writeln('Graphics Error');
     Halt(1);
     end;

  SetGraphMode(GrMode);
  SetColor(15);
  end;


procedure InitGraf800x600;
  begin
  GrDriver := InstallUserDriver('svga256',@Ad800x600);

  GrDriver := Detect;

  InitGraph(GrDriver,grMode,'c:\tp\bgi');
  SetColor(15);
  ErrCode := GraphResult;
  if ErrCode <> GrOk then
     begin
     writeln('Graphics Error');
     Halt(1);
     end;

  SetGraphMode(GrMode);
  SetColor(15);
  end;

procedure InitGraf1024x768;
  begin
  GrDriver := InstallUserDriver('svga256',@Ad1024x768);

  GrDriver := Detect;

  InitGraph(GrDriver,grMode,'c:\tp\bgi');
  SetColor(15);
  ErrCode := GraphResult;
  if ErrCode <> GrOk then
     begin
     writeln('Graphics Error');
     Halt(1);
     end;

  SetGraphMode(GrMode);
  SetColor(15);
  end;

Procedure ZakCircleFill(radius:real;color:word);

  var a:real;
      i:word;
      x,y:longint;

      endpts: array[1..720,0..1] of longint;

  begin

  for i:=1 to 720 do
   begin
   A := (2 * PI / 360) * (I /2);

   Y := trunc(  (GetMaxY div 2) - (radius * SIN(A)));

   X := trunc(  (GetMaxX div 2) - (radius * COS(A)));

   endpts[i,0]:=x;
   endpts[i,1]:=y;

   PutPixel(x,y,color);
   end;

  setcolor(color);
  for i:=1 to 360 do
   begin
   line(endpts[720-i,0],endpts[720-i,1],endpts[i,0],endpts[i,1]);
   end;

  end;

end.