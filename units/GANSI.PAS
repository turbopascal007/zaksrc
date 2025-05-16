unit gansi;
{$O+}

interface

uses
  Dos;

type
  ansicode   = string[15]; { Maximum size for most ANSI strings }

const
  hdr        = #27+'['; { ansi control sequence }
  clsd       = hdr+'0J'; { Clear Everything below cursor }
  clsu       = hdr+'1J'; { Clear Everything above cursor }
  cls        = hdr+'2J'; { Clear Screen }
  requestpos = hdr+'6n'; { request Cursor pos. StdIn rets Esc[x;yR }
  delline    = hdr+'K'; { delete from cursor to EOL }
  savepos    = hdr+'s'; { save cursor position }
  restpos    = hdr+'u'; { restore cursor position }
  cursorhome = hdr+'f'; { Home cursor }
  normcolor  = hdr+'0m'; { Normal white on black }
  highlight  = hdr+'1m'; { Highlight.  (Bold) }
  RevVideo   = hdr+'7m'; { Reverse the FG and BG }


function EraseEol: ansicode;

function SetPos(x,y:integer): ansicode;

function CursorUp(n:integer): ansicode;

function CursorDown(n:integer): ansicode;

function CursorRight(n:integer): ansicode;

function CursorLeft(n:integer): ansicode;


function InsertChar(n:integer): ansicode;

function DeleteChar(n:integer): ansicode;

function InsertLine(n:integer): ansicode;

function DeleteLine(n:integer): ansicode;


function SetAttr(C:integer): ansicode;

function SetFG(f:byte):ansicode;

function SetBG(b:byte):ansicode;

function SetColor(f,b:integer): ansicode;


function SetMode(mode:integer): ansicode;

function Resetmode(mode:integer): ansicode;


function SetChar(ch:char;st:string): string;

function SetExtendedKey(key:integer;st:string): string;


implementation

type  intstring = string[6];

{ Misc support functions }

function eraseeol: ansicode;
  begin
  eraseeol:=delline+'';
  end;

function bts(x:integer): intstring; { convert a integer to a string }
var z: intstring;
begin
  Str(x,z);
  bts := z;
end;

function HNum(n:integer): ansicode;
begin
  HNum := hdr+bts(n);
end;

{ Cursor Control functions }

function SetPos(x,y:integer): ansicode;
begin
  SetPos := hnum(y)+';'+bts(x)+'f';
end;

function CursorUp(n:integer): ansicode;
begin
  if n>1 then
  CursorUp := hnum(n)+'A'
  else Cursorup:=hdr+'A';
end;

function CursorDown(n:integer): ansicode;
begin
  if n>1 then
  CursorDown := hnum(n)+'B'
  else cursordown:=hdr+'B';
end;

function CursorRight(n:integer): ansicode;
begin
  if n>1 then
  CursorRight := hnum(n)+'C'
  else cursorright:=hdr+'C';
end;

function CursorLeft(n:integer): ansicode;
begin
  if n>1 then
  CursorLeft := hnum(n)+'D'
  else cursorleft:= hdr+'D';
end;


{ Editing Functions }

function InsertChar(n:integer): ansicode;
begin
  InsertChar := hnum(n)+'@';
end;

function DeleteChar(n:integer): ansicode;
begin
  DeleteChar := hnum(n)+'P';
end;

function InsertLine(n:integer): ansicode;
begin
  InsertLine := hnum(n)+'L';
end;

function DeleteLine(n:integer): ansicode;
begin
  DeleteLine := hnum(n)+'M';
end;


{ Color functions }

function SetAttr(C:integer): ansicode;
var
  x : integer;
  tmp : ansicode;
  h   : boolean;

  function AddHigh:ansicode;
    begin
    if (c and $08)=8 then AddHigh:=';1' else addhigh:='';
    end;

  procedure ColorIdentify;
  begin
    case x of
     0 :  tmp := tmp+'0';  { Black }
     1 :  tmp := tmp+'4';  { Blue }
     2 :  tmp := tmp+'2';  { Green }
     3 :  tmp := tmp+'6';  { Cyan }
     4 :  tmp := tmp+'1';  { Red }
     5 :  tmp := tmp+'5';  { Magenta }
     6 :  tmp := tmp+'3';  { Brown/Yellow }
     7 :  tmp := tmp+'7';  { White }
    end; { case }
  end; { ColorIdentify }

begin
  tmp := hdr;
  if (c and $08)=1 then tmp := tmp+'1' else tmp := tmp+'0';

  tmp := tmp+';3'; { common to all fgnds. }

  x := c and $07; { first three bits. }

  ColorIdentify; { Add Color Value digit }


  tmp := tmp+';4'; { common to all bkgnds. }
  x := (c and $70) shr 4;

  ColorIdentify; { Add color value digit }

  if (c and $80)=$80 then tmp := tmp+';5';

  Tmp := tmp+AddHigh+'m'; { complete ANSI code! }
  SetAttr:=tmp;
end; { setattr }

function SetColor(f,b:integer): ansicode;
begin
  b := (b shl 4); { move to high bits. }
  f := (f and $0f); { zero all high bits. }

  SetColor := SetAttr((b OR f)); {Create Attribute byte from values.}
end; { SetColor }
{
colors:  Black     0
         Red       1
         Green     2
         Yellow    3
         Blue      4
         Magneta   5
         Cyan      6
         White     7
}

function ansc(c:byte):byte;
 begin
 case c of
 0:ansc:=0;
 1:ansc:=4;
 2:ansc:=2;
 3:ansc:=6;
 4:ansc:=1;
 5:ansc:=5;
 6:ansc:=3;
 7:ansc:=7;
 end;
 end;

function SetFG(f:byte):ansicode;
 begin
 if (f and 8)=8 then { light }
   begin
   SetFG := Concat(hdr,'1;3',char(ansc(f and not 8)+48),'m');
   end
  else
   begin
   SetFG := Concat(hdr,'0;3',char(ansc(f)+48),'m');
   end;
 end;

function SetBG(b:byte):ansicode;
 var tmp:ansicode;
 begin
 tmp[0]:=chr(0);
 tmp:='4';
 SetBG := Concat(hdr,tmp,char(ansc(b)+48),'m');
 end;


{ Mode Setting Functions }

function SetMode(mode:integer): ansicode;
begin
  SetMode := hdr+'='+bts(mode)+'h';
  { Modes:
       0     40x25   Black and White
       1     40x25   Color
       2     80x25   Black and White
       3     80x25   Color
       4     320x200 color           (CGA)
       5     320x200 Black and White (CGA)
       6     640x200 Black and White (CGA)
       7     Wrap at end of line.
  }
end;

function Resetmode(mode:integer): ansicode;
begin
  Resetmode := hdr+'='+bts(mode)+'l';  { Same modes as above }
end;                                   { Wrap at EOL will turn off }

{ Keyboard Re-Defining functions }

function SetChar(ch:char;st:string): string;
begin
  SetChar := hdr+bts(ord(ch))+';"'+st+'"p'; { when ch is pressed st is }
end;                                        { sent instead of ch       }

function SetExtendedKey(key:integer;st:string): string;
begin
  SetExtendedKey := hdr+'0;'+bts(key)+';"'+st+'"p'; { Same as above. but the }
end;                                                { Key is an extended code }


end.

{**********************************************************************}

That's it...  Have fun.   TTYL

--- FD 1.99c
 * Origin: My programs don't have bugs. They have features. (1:163/127.12)

