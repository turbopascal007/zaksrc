unit gMouse;
interface

{****************************************************************************
 * PROJECT:  Mouse routines with 'real' graphic cursor in text mode.
 *****************************************************************************
 * MODULE:  MOU.PAS
 *****************************************************************************
 * DESCRIPTION:
 *   Pascal source file for the mouse routines.  Combined near-literal
 *   translation of MOU.H and MOU.C
 *
 *****************************************************************************
 * MODIFICATION NOTES:
 *    Date     Author Comment
 * 26-Oct-1990   dk   Initial file.
 * 07-Jan-1991   dk   Fixed bugs and set up for release to Usenet.
 * 10-Jan-1991   djm  Translation to Turbo Pascal
 *****************************************************************************
 *
 * DISCLAIMER:
 *
 * Programmers may incorporate any or all code into their programs,
 * giving proper credit within the source. Publication of the
 * source routines is permitted so long as proper credit is given
 * to Dave Kirsch.
 *
 * Copyright (C) 1990, 1991 by Dave Kirsch.  You may use this program, or
 * code or tables extracted from it, as desired without restriction.
 * I can not and will not be held responsible for any damage caused from
 * the use of this software.
 *
 *****************************************************************************
 * This source works with Turbo Pascal 6.0.
 ****************************************************************************}

{*************************************************}
{ Mon 07-Jan-1991 - dk                            }
{                                                 }
{  Variables and defines for the mouse routines.  }
{                                                 }
{*************************************************}

{ Size of mouse "click" ahead buffer. }
const
  MOUSEBUFFERSIZE = 16;

{ Bit defines for mouse driver function 12 -- define handler. }
  MOUSEMOVE      =1;
  LEFTBPRESS     =2;
  LEFTBRELEASE   =4;
  RIGHTBPRESS    =8;
  RIGHTBRELEASE =16;
  MIDBPRESS     =32;
  MIDBRELEASE   =64;

  LEFTBDOWN  =1;
  RIGHTBDOWN =2;
  MIDBDOWN   =4;

{ Shift states for byte a 0:417h
   bit 7 =1 INSert active
   bit 6 =1 Caps Lock active
   bit 5 =1 Num Lock active
   bit 4 =1 Scroll Lock active
   bit 3 =1 either Alt pressed
   bit 2 =1 either Ctrl pressed
   bit 1 =1 Left Shift pressed
   bit 0 =1 Right Shift pressed
}

  SHIFT_RIGHTSHIFT =$01;
  SHIFT_LEFTSHIFT  =$02;
  SHIFT_SHIFT      =$03; { Either shift key. }
  SHIFT_CTRL       =$04;
  SHIFT_ALT        =$08;
  SHIFT_SCROLLLOCK =$10;
  SHIFT_NUMLOCK    =$20;
  SHIFT_CAPSLOCK   =$40;
  SHIFT_INS        =$80;

{ Mouse information record }
type
  minforectype = record
    buttonstat : word;
    cx, cy : integer;
    shiftstate : byte;
  end;

{  MOUINFOREC = minforectype; }

const
  mousehidden : word = 0;           { Is the mouse on? Additive flag }
  mouseinstalled : boolean = FALSE; { Is the mouse installed? }

var
  mousex, mousey : integer; { Mouse coordinates in characters. }
  mousepx, mousepy : word;  { Mouse pixel coordinates - not interfaced in C
                              version }

{ Initialize the mouse routines -- must be called. }
procedure MOUinit;

{ Deinitialize the mouse routines -- must be called on shutdown.
   Failure to call it will most likely result in a system crash if the mouse
   is moved. }
procedure MOUdeinit;

{ Hide the mouse cursor }
procedure MOUhide;

{ Hide the mouse cursor if it moves or is in a specific rectangular region
   of the screen. }
procedure MOUconditionalhide(x1, y1, x2, y2:integer);

{ Show the mouse cursor }
procedure MOUshow;

{ return TRUE if there are events waiting in the buffer. }
function MOUcheck:boolean;

{ look at the next event in the buffer, but don't pull it out. }
procedure MOUpreview(var mouinforec:minforectype);

{ get and remove next event from the buffer. }
procedure MOUget(var mouinforec:minforectype);

{ return the current status of the mouse buttons (see defines above). }
function MOUbuttonstatus:word;

implementation

uses
  Crt;

{ Routine to emulate w++ for words }
function postinc(var w:word):word;
begin
  postinc := w;
  inc(w);
end;

const
  HEIGHT =16;

const
  mbufin : integer = 0;
  mbufout: integer = 0; { Mouse buffer pointers }

  mousefreeze:integer = 0;           { Is mouse frozen in place? }

var
  mbuf : array [0..MOUSEBUFFERSIZE-1] of minforectype; { Mouse buffer }

{ Save information for non EGA/VGA }
  oldword : word;
  newword : word;
const
  saved : boolean = FALSE;
var
  oldmx, oldmy : word;

{ Save information for EGA/VGA displays }
const
  egavga : boolean = FALSE; { Do we have an EGA/VGA adapter? }
var
  savechars : array [0..3-1] of array[0..3-1] of byte;
              { The saved characters we overwrote }
const
  mousecursormask : array[0..HEIGHT-1] of longint =  (
  $00000000,  {0000000000000000}
  $40000000,  {0100000000000000}
  $60000000,  {0110000000000000}
  $70000000,  {0111000000000000}
  $78000000,  {0111100000000000}
  $7c000000,  {0111110000000000}
  $7e000000,  {0111111000000000}
  $7f000000,  {0111111100000000}
  $7f800000,  {0111111110000000}
  $7f000000,  {0111111100000000}
  $7c000000,  {0111110000000000}
  $46000000,  {0100011000000000}
  $06000000,  {0000011000000000}
  $03000000,  {0000001100000000}
  $03000000,  {0000001100000000}
  $00000000   {0000000000000000}
);

mousescreenmask : array[0..HEIGHT-1] of longint =  (
  $3fffffff,  {0011111111111111}
  $1fffffff,  {0001111111111111}
  $0fffffff,  {0000111111111111}
  $07ffffff,  {0000011111111111}
  $03ffffff,  {0000001111111111}
  $01ffffff,  {0000000111111111}
  $00ffffff,  {0000000011111111}
  $007fffff,  {0000000001111111}
  $003fffff,  {0000000000111111}
  $007fffff,  {0000000001111111}
  $01ffffff,  {0000000111111111}
  $10ffffff,  {0001000011111111}
  $b0ffffff,  {1011000011111111}
  $f87fffff,  {1111100001111111}
  $f87fffff,  {1111100001111111}
  $fcffffff   {1111110011111111}
);

var
  chardefs : array[0..(32 * 9-1)] of byte; { 9 character definitons. }
  points : word;           { change by djm! }

const
  conditionalhidemouse : boolean = FALSE;
var
  conx1, cony1, conx2, cony2 : word;

  vseg: word; { Segment of video ram. }
  mcols, mrows : word;
  savevmode : byte;

  maxx, maxy : integer;

const
  desqview : boolean = FALSE;

procedure POKEATTRIB(x, y : word; a: byte);
begin
  mem[vseg: (y) * (mcols * 2) + ((x) shl 1) + 1] := a;
end;

function PEEKATTRIB(x, y: word):byte;
begin
  PEEKATTRIB := mem[vseg: (y) * (mcols * 2) + ((x) shl 1) + 1]
end;

procedure pokeb(a, b:word;c : byte);
begin
  mem[a:b] := c
end;

function peekb(a,b:word):byte;
begin
  peekb := mem[a:b];
end;

var
  BIOS_POINTS : byte absolute $0000:$0485;
  COLS : byte absolute $0040:$004A;
  ROWS : byte absolute $0040:$0084;

const
  DEFCHAR = $d0;

{*******************************************************************}
{ Mon 07-Jan-1991 - dk                                              }
{                                                                   }
{  Plot the cursor on the screen, save background, draw grid, etc.  }
{                                                                   }
{*******************************************************************}
procedure plotegavgacursor(func:integer);
var
  off,
  width, height, i, j,
  disp,
  x, y : word;
const
  lsavex:integer = 0;
  lsavey:integer = 0;

begin
  case (func) of
    0 : begin{ erase grid, put back save info }
      x := lsavex;
      y := lsavey;
      end;
    1 : begin{ draw grid }
      x := mousex;
      y := mousey;
      end;
    2 : begin { save grid }
      x := mousex;
      lsavex := x;
      y := mousey;
      lsavey := y;
      end;
  end;

  width := mcols - x;
  if (width > 3) then
    width := 3;
  height := mrows - y;
  if (height > 3) then
    height := 3;

  off := y * (mcols * 2) + x * 2;
  disp := (mcols * 2) - width * 2;

  case (func) of
    0 : begin { erase grid, put back save info }
      for i := 0 to height-1 do
      begin
        for j := 0 to width-1 do
        begin
          mem[vseg:off] := savechars[i][j];
          inc(off,2);
        end;
        inc(off,disp);
      end;
    end;
    1 : begin{ draw grid. }
      for i := 0 to height-1 do
      begin
        for j := 0 to width-1 do
        begin
          mem[vseg:off] := DEFCHAR + i * 3 + j;
          inc(off,2);
        end;
        inc(off,disp);
      end;
    end;
    2 : begin{ save grid. }
      for i := 0 to height-1 do
      begin
        for j := 0 to width-1 do
        begin
          savechars[i][j] := mem[vseg:off];
          inc(off, 2);
        end;
        inc(off,disp);
      end;
    end;
  end
end;

procedure drawegavgacursor;
var
  off : word;
  i, j : integer;
  s1, s2, s3 : word;
  defs : ^longint;
  masks : ^longint;
  shift : word;
  addmask : longint;
label
  notmono;
begin

  plotegavgacursor(2); { Save current grid that is there. }

  { Time for some assembler.  Program the EGA/VGA Sequencer and Graphics
     Controller for direct access to the character definition tables.
     Then read in the definitions for the characters we are changing, AND
     the screen mask, then OR the cursor mask to them.  Then copy those
     defintions into the location of the mouse cursor defintions
     and set the Sequencer and Graphics Controller back to normal <whew!>.
  }

  { Program the Sequencer }

  asm
    pushf; { Disable interrupts }
    cli;
    mov dx, 3c4h; { Sequencer port address }
    mov ax, 0704h; { Sequential addressing }
    out dx, ax;

  { Program the Graphics Controller }
    mov dx, 3ceh; { Graphics Controller port address }
    mov ax, 0204h; { Select map 2 for CPU reads }
    out dx, ax;
    mov ax, 0005h; { Disable odd-even addressing }
    out dx, ax;
    mov ax, 0406h; { Map starts at A000:0000 (64K mode) }
    out dx, ax;
    popf;
  end;

  { Ok, now we have direct access to the character defintion tables, copy
     over the defintions for the characters we are changing }

  off := 0;
  for i := 0 to 3-1 do   { Note change in loop logic!  -djm }
  begin{ Grid is three characters high. }
    s1 := savechars[i    ,0] * 32;
    s2 := savechars[i    ,1] * 32;
    s3 := savechars[i    ,2] * 32;
    for j := 0 to points-1 do
    begin
      inc(off); { 4th byte, that we don't need. }
      chardefs[postinc(off)] := mem[$a000:postinc(s3)];
      chardefs[postinc(off)] := mem[$a000:postinc(s2)];
      chardefs[postinc(off)] := mem[$a000:postinc(s1)];
    end;
  end;

  { Ok, we've got the defintions for the characters that we are drawing the
     cursor on.  AND the screen mask and OR the cursor mask to them, thereby
     'drawing' the cursor.  Since the cursor is 16 pixels wide and 16 pixels
     high, we have to save a 3 by 3 character grid where the mouse cursor is
     going.  We use dwords (32 bits) to do the bit AND and OR.  This could
     be made alot faster on a 386 by using 32 bit registers. }

  shift := mousepx mod 8;
  addmask := $ff000000 shl (8 - shift);

  masks := @mousescreenmask;
  defs := @chardefs[(mousepy mod points)*sizeof(longint)];
  for i := 0 to HEIGHT-1 do
  begin
    defs^ := defs^ and ((masks^ shr shift) or addmask);
    inc(word(defs),sizeof(longint));
    inc(word(masks),sizeof(longint));
{   *defs++ &= (*masks++ >> shift) | addmask; }
  end;

  masks := @mousecursormask;
  defs := @chardefs[(mousepy mod points)*sizeof(longint)];
  for i := 0 to HEIGHT-1 do
  begin
    defs^ := defs^ or (masks^ shr shift);
    inc(word(defs),sizeof(longint));
    inc(word(masks),sizeof(longint));
{    *defs++ |= *masks++ >> shift;  }
  end;
  { Ok, Everything is setup, now copy the modifed character definitions
     to their new location. }

  asm
    mov dx, 3c4h; { Sequencer port address }
    mov ax, 0402h; { CPU writes only to map 2 }
    out dx, ax;
  end;

  off := 0;
  for i:=0 to 3-1 do   { Logic change here!  -djm }
  begin
  { Grid is three characters high. }
    s1 := (DEFCHAR + 3*i    ) * 32;
    s2 := (DEFCHAR + 3*i + 1) * 32;
    s3 := (DEFCHAR + 3*i + 2) * 32;
    for j := 0 to points-1 do
    begin
      inc(off); { 4th byte, that we don't need. }
      mem[$a000:postinc(s3)] := chardefs[postinc(off)];
      mem[$a000:postinc(s2)] := chardefs[postinc(off)];
      mem[$a000:postinc(s1)] := chardefs[postinc(off)];
    end;
  end;

  { Ok, put the Sequencer and Graphics Controller back to normal }

  { Program the Sequencer }
  asm
    pushf; { Disable interrupts }
    cli;
    mov dx, 3c4h; { Sequencer port address }
    mov ax, 0302h; { CPU writes to maps 0 and 1 }
    out dx, ax;
    mov ax, 0304h; { Odd-even addressing }
    out dx, ax;

  { Program the Graphics Controller }
    mov dx, 3ceh; { Graphics Controller port address }
    mov ax, 0004h; { Select map 0 for CPU reads }
    out dx, ax;
    mov ax, 1005h; { Enable odd-even addressing }
    out dx, ax;
    sub ax, ax;
    mov es, ax; { Segment 0 }
    mov ax, 0e06h; { Map starts at B800:0000 }
    mov bl, 7;
    cmp es:[49h], bl; { Get current video mode }
    jne notmono;
    mov ax, 0806h; { Map starts at B000:0000 }
notmono:
    out dx, ax;
    popf;
  end;
  { Ok, now put the bytes on the screen }

  plotegavgacursor(1); { Plot the new grid on the screen. }
end;

{*****************************************************}
{ 27-Oct-1990 - dk                                    }
{                                                     }
{  This function checks for the presense of EGA/VGA.  }
{                                                     }
{*****************************************************}
function isegavga:boolean;
label
  isvga,checkega;
begin
  asm
    mov ax, 1a00h; { ROM BIOS video function 1ah -- Read Display Code }
    int 10h;
    cmp ah, 1ah; { Is this call supported? }
    je checkega; { Not supported }
    cmp bl, 7; { VGA w/monochrome display? }
    je isvga; { Yup. }
    cmp bl, 8; { VGA w/color display? }
    jne checkega; { Nope }
  end;
isvga:
  isegavga := TRUE; { EGA/VGA is installed }
  exit;
checkega:
  asm
    mov ah, 12h; { EGA BIOS function }
    mov bl, 10h;
    int 10h;
    cmp bl, 10h; { Is EGA BIOS present? }
    jne isvga; { There is an EGA in the system. }
  end;
  isegavga := FALSE; { Not EGA or VGA in system. }
end;

{**********************************************}
{ 26-Oct-1990 - dk                             }
{                                              }
{  Mouse handler -- called from mouse driver.  }
{                                              }
{**********************************************}
{$S-} { Turn off stack checking }
procedure mousehandler; far;
{ This function is called whenever a button is pressed.  Do not call this
   function directly!!
}
var
  conditionmask:integer;
begin
  { Get our data segment }
  asm
    push ds
    push ax
    mov ax, seg @data
    mov ds, ax
    pop ax

    mov conditionmask,ax
  end;

  if (mousefreeze = 0) then
  begin
    { save mouse info passed to us from driver }
    asm
      mov mousepx, cx  { note change by djm }
      mov mousepy, dx
    end;
    mousex := mousepx div 8; { Characters are 8 pixels wide }
    mousey := mousepy div points; { Scale mousey down }

    { See if the mouse has moved. }
    if (conditionmask and MOUSEMOVE) <> 0 then
    begin
      if (saved) then
      begin
        if (egavga) then
          plotegavgacursor(0)
        else
          POKEATTRIB(oldmx, oldmy, oldword);
        saved := FALSE;
      end;

      if (mousehidden=0) and conditionalhidemouse then{ Check to see if we need to hide }
        if (mousex >= conx1) and (mousex <= conx2) and
           (mousey >= cony1) and (mousey <= cony2) then
        begin
          inc(mousehidden);
          conditionalhidemouse := FALSE;
        end;

      if (mousehidden=0) then
      begin
        if (egavga) then
          drawegavgacursor
        else
        begin
          oldword := PEEKATTRIB(mousex, mousey);
          asm
            mov ax,[oldword];  { Prepare to rotate attrib byte }
            and al, 0f7h; { Clear high bit }
            mov cl, 4   { We want to rotate 4 bits }
            rol al, cl  { Rotate it }
            mov newword,AX;
          end;

          POKEATTRIB(mousex, mousey, newword); { Write out new mouse cursor }
        end;

        oldmx := mousex;
        oldmy := mousey;
        saved := TRUE;

      end
    end
  end;

  { Now, see if a mouse button was whacked }
  if (conditionmask and (not MOUSEMOVE)) <> 0 then
    if (((mbufin + 1) mod MOUSEBUFFERSIZE) = mbufout) then
    begin { Buffer full? }
      sound(1760); { Make some noise. }
      delay(10);
      nosound;
    end else begin
      mbuf[mbufin].buttonstat := conditionmask and (not MOUSEMOVE);
      mbuf[mbufin].cx := mousex;
      mbuf[mbufin].cy := mousey;
      mbuf[mbufin].shiftstate := mem[0:$417]; { Get shift byte }
      mbufin := (mbufin + 1) mod MOUSEBUFFERSIZE;
    end;

  asm
    pop ds;
  end;
end;
{$S+} { Turn on stack checking }

{**********************************}
{ 26-Oct-1990 - dk                 }
{                                  }
{  Initialize the mouse routines.  }
{                                  }
{**********************************}
procedure MOUinit;
var
  v:byte;
label
  notdv;
begin

  asm
    sub ax,ax;    { Mouse driver function 0 -- reset and detect }
    int 33h
    mov mouseinstalled, AL;
  end;

  if (mouseinstalled) then
  begin { If a mouse is installed then activate driver }

    inc(mousefreeze); { Make sure handler doesn't do things, yet }

    asm
      mov ax,0F00h;
      int 10h;
      mov v,al;
    end;

    if (v = 7) then
    begin
      vseg := $b000;
    end else begin
      vseg := $b800;
      v := 3;
    end;

    if (ROWS = 0) then
    begin { No value, assume 80x25. }
      mrows := 25;
      mcols := 80;
      points := 8;
    end else begin
      mrows := ROWS + 1;
      mcols := COLS;
      points := BIOS_POINTS;
    end;

    { Check to see if we are running in DESQview.  If so, don't try to
       use the 'true' EGA/VGA cursor (DV doesn't like it at ALL). }

    asm
      mov ax, 2b01h;
      mov cx, 4445h;
      mov dx, 5351h;
      int 21h;

      cmp al, 0ffh;
      je notdv;
    end;

    desqview := TRUE;

notdv:

    { Do we have an EGA or VGA?  If so, and we are not in monochrome mode
       and we are not in DESQview then setup to draw a 'true' mouse cursor
       on an EGA/VGA }
    egavga := (vseg <> $b000) and (not desqview) and isegavga;

    if (egavga) then
    begin
      { We are going to use our 'true' mouse cursor and we need pixel
         resolution, not character resolution from the mouse driver
         (In text mode, the mouse driver only returns coordinates in multiples
         of 8, which we don't want.  We want multiples of 1, i.e. pixel
         resolution).  To get the mouse driver to return coordinates in pixel
         resolution, we 'trick' it into thinking it's in graphics mode by
         setting the low memory byte indicating mode to mode 6 (CGA 640x200x2).
         Then we reset the mouse driver.  The mouse driver will get the video
         mode then act as if it was in graphics mode, not text mode. }
      savevmode := mem[$40:$49];
      mem[$40:$49] := 6; { Does this work ?!?!?!?!? }

      { Reset driver for change in video mode to take effect. }
      asm
        sub ax,ax
        int 33h
      end;
      { Now that we've tricked the mouse driver into a grapics mode thereby
         causing it to give us pixel resolutions, put the old mode back. }
      mem[$40:$49] := savevmode;
    end;

    { Set up max x and y ranges. }

    maxx := mcols * 8 - 1; { Pixels horizontally }
    maxy := mrows * points - 1; { Pixels vertically }

    asm
      mov dx,[maxx]     { Pixels horizontally }
      mov ax,7        { mouse driver function 7 -- set max x range }
      sub cx,cx       { Minimum range }
      int 33h

      mov dx,[maxy]     { Pixels veritcally }
      mov ax,8        { mouse driver function 8 -- set max y range }
      sub cx,cx       { Minimum range }
      int 33h

    { Now install user routine }

      mov ax,cs
      mov es,ax
      mov dx, offset mousehandler
    { Setup up bits for calling routine }
      mov cx,LEFTBPRESS or LEFTBRELEASE or RIGHTBPRESS or RIGHTBRELEASE or MIDBPRESS or MIDBRELEASE or MOUSEMOVE;
      mov ax,12       { Function 12 -- set user routine }
      int 33h
    end;
    mousex := 0;
    mousey := 0;
    mousepx := 0;  { change by djm }
    mousepy := 0;  { change by djm }
    asm
      mov cx,[mousex]   { xcoord }
      mov dx,[mousey]   { ycoord }
      mov ax,4    { mouse driver function 4 -- set mouse position }
      int 33h
    end;
    MOUshow; { Call it twice just to make sure }

    dec(mousefreeze); { Handler can get into business, now }
  end
end;

{**************************}
{ 26-Oct-1990 - dk         }
{                          }
{  Hide the mouse cursor.  }
{                          }
{**************************}
procedure MOUhide;
{ This function turns off the mouse cursor, the mouse still responds
   to button presses }
begin
  if (not mouseinstalled) then
    exit;

  inc(mousefreeze); { don't have the handler doing weird things }

  inc(mousehidden); { indicate it's hidden now }

  if (saved) then
  begin
    if (egavga) then
      plotegavgacursor(0)
    else
      POKEATTRIB(oldmx, oldmy, oldword);
    saved := FALSE;
  end;

  dec(mousefreeze); { reactivate handler }
end;

{**************************}
{ 26-Oct-1990 - dk         }
{                          }
{  Show the mouse cursor.  }
{                          }
{**************************}
procedure MOUshow;
begin
  if (not mouseinstalled) then
    exit;

  inc(mousefreeze); { don't have the handler doing weird things }

  { Just in case we were in a conditionalhide }
  if (conditionalhidemouse) then
  begin
    { We were about to conditional hide, but we didn't, don't reactive
       mouse cursor. }
    conditionalhidemouse := FALSE;
    dec(mousefreeze); { Reactivate handler }
    exit;
  end;

  if (mousehidden <> 0) then
    dec(mousehidden)
  else begin
    dec(mousefreeze); { Reactivate handler }
    exit;  { It isn't hidden! }
  end;

  if (mousehidden <> 0) then
  begin
    dec(mousefreeze); { reactivate handler }
    exit; { still hidden! }
  end;

  { Draw mouse cursor }

  if (egavga) then
    drawegavgacursor
  else begin
    oldword := PEEKATTRIB(mousex, mousey);
    asm
      mov AX,[oldword];  { Prepare to rotate attrib byte }
      and al, 0f7h; { Clear high bit }
      mov cl, 4   { We want to rotate 4 bits }
      rol al, cl  { Rotate it }
      mov newword,AX;
    end;

    POKEATTRIB(mousex, mousey, newword); { Write out new mouse cursor }
  end;

  oldmx := mousex;
  oldmy := mousey;
  saved := TRUE;

  dec(mousefreeze); { Reactivate handler }
end;

{***********************************************************}
{ 27-Oct-1990 - dk                                          }
{                                                           }
{  Returns true if there is something in the mouse buffer.  }
{                                                           }
{***********************************************************}
function MOUcheck:boolean;
begin
  MOUcheck := mbufin <> mbufout;
end;

{************************************************************}
{ 26-Oct-1990 - dk                                           }
{                                                            }
{  Take a copy of the mouse event at the head of the queue.  }
{                                                            }
{************************************************************}
procedure MOUpreview(var mouinforec:minforectype);
begin
  if (not mouseinstalled) then
    exit;

  if (mbufin <> mbufout) then { if something is in buffer }
    mouinforec := mbuf[mbufout]
  else begin
    { Nothing to pull, just report mouse position }
    mouinforec.cx := mousex;
    mouinforec.cy := mousey;
    mouinforec.buttonstat := 0;
    mouinforec.shiftstate := mem[0:$417];
  end
end;

{**************************************************************}
{ 26-Oct-1990 - dk                                             }
{                                                              }
{  Get (and remove) the mouse event at the head of the queue.  }
{                                                              }
{**************************************************************}
procedure MOUget(var mouinforec:minforectype);
begin
  if (not mouseinstalled) then
    exit;

  if (mbufin <> mbufout) then
  begin { if something is in buffer }
    if (@mouinforec <> nil) then
      mouinforec := mbuf[mbufout];
    mbufout := (mbufout + 1) mod MOUSEBUFFERSIZE;
  end else begin
    { Nothing to pull, just report mouse position }
    mouinforec.cx := mousex;
    mouinforec.cy := mousey;
    mouinforec.buttonstat := 0;
    mouinforec.shiftstate := mem[0:$417];
  end
end;

{************************************}
{ 26-Oct-1990 - dk                   }
{                                    }
{  Deinitialize the mouse routines.  }
{                                    }
{************************************}
procedure MOUdeinit;
begin
  if (not mouseinstalled) then
    exit;

  MOUhide;

  asm
    sub ax,ax
    int 33h
  end;
end;

{************************************************}
{ 26-Oct-1990 - dk                               }
{                                                }
{  Returns the bits for the button status info.  }
{                                                }
{************************************************}
function MOUbuttonstatus:word;
var
  buts : word;
begin

  if (not mouseinstalled) then
  begin
    MOUbuttonstatus := 0;
    exit;
  end;

  asm
    mov ax,3
    int 33h
    mov buts,bx
  end;
  MOUbuttonstatus := buts;
end;

{**********************************************************************}
{ 26-Oct-1990 - dk                                                     }
{                                                                      }
{  Hide the mouse *if* it enters a certain screen area, automatically. }
{                                                                      }
{**********************************************************************}
procedure MOUconditionalhide(x1, y1, x2, y2:integer);
begin
  if (not mouseinstalled) then
    exit;

  inc(mousefreeze); { hold the handler }

  if (mousehidden <> 0) then
  begin
    dec(mousefreeze); { reactivate handler }
    exit; { already hidden! }
  end;

  conditionalhidemouse := TRUE;

  dec(x1,2);
  if (x1 < 0) then
    x1 := 0;
  dec(y1,2);
  if (y1 < 0) then
    y1 := 0;
  inc(x2,2);
  inc(y2,2);

  conx1 := x1;
  cony1 := y1;
  conx2 := x2;
  cony2 := y2;

  if (mousex >= conx1) and (mousex <= conx2) and
     (mousey >= cony1) and (mousey <= cony2) then
  begin
    conditionalhidemouse := FALSE; { We've already hidden it }
    MOUhide; { turn it off now if it's there. }
  end;

  dec(mousefreeze);
end;

{*******************************************************}
{ 15-Mar-1991 - dk					}
{							}
{  Set the mouse cursor to a specific screen position.	}
{							}
{*******************************************************}
procedure MOUsetpos(x, y:integer);
begin
  if (not mouseinstalled) then
    exit;

  inc(mousefreeze);

  MOUhide;

  mousex := x;
  mousey := y;
  mousepx := mousex * 8;
  mousepy := mousey * points;
  asm
    mov cx, mousepx   { xcoord }
    mov dx, mousepy   { ycoord }
    mov ax, 4	      { mouse driver function 4 -- set mouse position }
    int 33h
  end;

  MOUshow;

  dec(mousefreeze);
end;

end.
