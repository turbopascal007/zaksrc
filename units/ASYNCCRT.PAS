Unit AsyncCrt;

Interface
Uses FosCom;

const
  Black     = 0 ; DarkGray     =  8;
  Blue      = 1 ; LightBlue    =  9;
  Green     = 2 ; LightGreen   = 10;
  Cyan      = 3 ; LightCyan    = 11;
  Red       = 4 ; LightRed     = 12;
  Magenta   = 5 ; LightMagenta = 13;
  Brown     = 6 ; Yellow       = 14;
  LightGray = 7 ; White        = 15;


var UsingAsync :boolean;
    portnum    :byte;
    writelocal :boolean;
    writeremote:boolean;

const crlf=#13+#10;

function  localreadkey: char;
procedure delay(t:word);

procedure ClrLocalScr;

Procedure ClrAllScr;

Procedure InitAsync(PortNum:byte);
procedure AsyncClose(port:byte);
Procedure AWrite  (c:string);
Procedure AWriteln(s:string);
Procedure AGotoXY (x,y,ly:byte);
Procedure ASetTextColor(f,b:byte);
function  WhereY:byte;
Function  WhereX:byte;
Procedure ClrEol;


Implementation

Uses Crt,Gansi;

function localreadkey:char;
  begin
  localreadkey:=crt.readkey;

  end;


procedure clrallscr;
 begin
 if writelocal then crt.clrscr;
 if (usingasync and writeremote) then fos_string(portnum,cls);
 end;


procedure delay(t:word);
 begin
 crt.delay(t);
 end;

procedure clrlocalscr;
  begin
  crt.clrscr;
  end;

procedure ClrEol;
 begin
 if writelocal then Crt.ClrEol;
 if (usingasync and writeremote) then Fos_String(portnum,EraseEol);
 end;

function wherey:byte;
 begin
 wherey:=crt.wherey;
 end;

function wherex:byte;
 begin
 wherex:=crt.wherex;
 end;

procedure InitAsync(portnum:byte);
  begin
  if (usingasync and writeremote) then Fos_Init(portnum);
  end;

procedure AsyncClose(port:byte);
 begin
 if (usingasync and writeremote) then fos_close(port)
 end;

procedure Awrite(c:string);
 begin
 if writelocal then system.write(c);
 if (usingasync and writeremote) then Fos_string(portnum,c);
 end;

procedure Awriteln(s:string);
 begin
 if writelocal then system.writeln(s);
 if (usingasync and writeremote) then Fos_String(portnum,s+crlf);
 end;

Procedure AGotoXY(x,y,ly:byte);
 begin
 if writelocal then crt.gotoxy(x,ly);
 if (usingasync and writeremote) then Fos_String(portnum,Gansi.SetPos(x,y));
 end;

procedure ASetTextColor(f,b:byte);
 begin
 if writelocal then crt.textcolor(f);crt.textbackground(b);
 if (usingasync and writeremote) then Fos_String(portnum,Gansi.SetColor(f,b));
 end;


begin
   checkbreak:=false;
   UsingAsync:=False;
   portnum:=1;
   writelocal:=true;
   writeremote:=true;
END. AsyncCrt