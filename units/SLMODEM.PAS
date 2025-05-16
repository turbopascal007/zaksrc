{$F-} {$S-} {$A-}

Unit SLModem;
  { Searchlight BBS Modem Interface Unit }

  { Procedures and functions in this unit can be used by DOOR programs
    to access Searchlight's serial port drivers directly. I/O, carrier
    detect, disconnect, and buffer controls are included.         }

  { These procedures work only in conjunction with Searchlight 2.15C
    and later versions. See MODEM.DOC for more information.       }

Interface
  Uses DOS;

Type RSbaud = (B110,B150,B300,B600,B1200,B2400,B4800,B9600,B19200,B38400);
     AnsiType = (GENERIC,PROCOMM,STANDARD);

     SLDataType = record         { Public Data Area }
      PROGID: string[6];                { Program ID }
      carrier: boolean;                 { carrier check enabled? }
      writeprotect: boolean;            { disk write protection? }
      aborttype: byte;                  { 0=no abort, 1=terminate, 2=reboot }

      rsactive: boolean;                   { set if rs232 active }
      ansi: boolean;                    { is user in ANSI mode? }
      color: boolean;                   { does user have a color crt? }
      directvid: boolean;               { system DirectVideo mode }

      curratt: byte;                    { current video attribute }
      commtype: byte;                   { run parameter }
      idletime: word;                   { idle limit (seconds) }
      lastkey: boolean;                 { TRUE = last key from local kbd }

      OldVector: array[$00..$7F] of pointer;   { old user int vectors }
      AnsiMode: AnsiType;               { user's ANSI mode }
     end;


Var DriverLoaded: boolean;             { Set if SLBBS drivers available }
    SLData: ^SLDataType;               { Pointer to public data area }
    AUXIn: text;                       { RS232 Input File }
    AUXOut: text;                      { RS232 Output File }

 Function CarrierDetect: boolean;      { Check carrier status }
Procedure Hangup;                      { Disconnect (hangup) }
 Function RS232Avail: boolean;         { Check RS232 char available }
 Function RS232In: char;               { Read RS232 char }
Procedure RS232Out (c: char);          { Write RS232 char }
Procedure PauseOutput;                 { Pause buffered output }
Procedure RestartOutput;               { Restart output after pause }
Procedure ClearInputBuffer;            { Clear input buffer }
Procedure ClearOutputBuffer;           { Clear output buffer }
 Function BufferEmpty: boolean;        { Check buffer empty condition }

Procedure WaitOut;                     { Wait for output buffer to clear }

Procedure RSinit (com: integer; speed: RSbaud; buffactor: integer; flow: boolean);
  { Initialize RS232 port }

Procedure RSCleanup;
  { Reset RS232 port }

Procedure ComToggle;
  { Toggle BIOS I/O support on and off }



Implementation

Const RSInt = $7E;             { interrupt for modem functions }
      SLBBSID = $736C;         { code for identifying SL interrupts }

Var regs: registers;           { registers for most operations }
    rscom: integer;            { set to active com port via RSinit }
    p,exitsave: pointer;


{ ----- Hardware Modem Controls ----- }

Function CarrierDetect: boolean;
  { read carrier detect pin; true=carrier detected }
Begin
  if DriverLoaded then begin
    regs.ax:=2;
    Intr(RSInt,regs);
    CarrierDetect:=(regs.bx=1);
  end else CarrierDetect:=true;
end;


Procedure Hangup;
  { disconnect from remote user (hang up) }
Begin
  if DriverLoaded then begin
    SLData^.Aborttype:=0;   { Set abort type to 'none'. This is important. }
    regs.ax:=3;
    Intr(RSInt,regs);
  end;
end;



{ ----- Modem I/O Functions ----- }

Function RS232Avail: boolean;
  { test whether a character is available in the input buffer }
Begin
  if DriverLoaded then begin
    regs.ax:=4;
    Intr(RSInt,regs);
    RS232Avail:=(regs.bx=1);
  end else RS232Avail:=false;
end;


Function RS232In: char;
  { read next character from input buffer }
Begin
  regs.ax:=5;
  Intr(RSInt,regs);
  RS232In:=char(lo(regs.bx));
end;


Procedure RS232Out (c: char);
  { write character to output buffer }
Begin
  regs.ax:=6;
  regs.bx:=byte(c);
  Intr(RSInt,regs);
end;


Procedure PauseOutput;
  { if output buffering is on, pauses buffered output }
Begin
  if DriverLoaded then begin
    regs.ax:=7;
    Intr(RSInt,regs);
  end;
end;


Procedure RestartOutput;
  { resume buffered output after pausing }
Begin
  if DriverLoaded then begin
    regs.ax:=8;
    Intr(RSInt,regs);
  end;
end;


Procedure ClearInputBuffer;
  { clears the input buffer }
Begin
  if DriverLoaded then begin
    regs.ax:=9;
    Intr(RSInt,regs);
  end;
end;


Procedure ClearOutputBuffer;
  { clears the output buffer }
Begin
  if DriverLoaded then begin
    regs.ax:=10;
    Intr(RSInt,regs);
  end;
end;


Function BufferEmpty: boolean;
  { check if output buffer is empty }
Begin
  if DriverLoaded then begin
    regs.ax:=11;
    Intr(RSInt,regs);
    BufferEmpty:=(regs.bx=1);
  end else BufferEmpty:=true;
end;


Procedure WaitOut;
  { wait until output buffer is empty }
Begin
  if DriverLoaded then begin
    regs.ax:=12;
    Intr(RSInt,regs);
  end;
end;



{ ----- File Handlers ----- }

{$F+}
Function RsFlush (var f: textrec): integer;
Begin
  RsFlush:=0;
end;

Function RsClose (var f: textrec): integer;
Begin
  f.mode:=fmClosed;
  RsClose:=0;
end;

Function RsInput (var f: textrec): integer;
Begin
  with f do begin
    bufptr^[0]:=RS232In;
    bufend:=1;
    bufpos:=0;
  end;
  RsInput:=0;
end;


Function RsOutput (var f: textrec): integer;
Begin
  with f do begin
    RS232Out(bufptr^[0]);
    bufpos:=0;
  end;
  RsOutput:=0;
end;


Function RsOpen (var f: textrec): integer;
Begin
  if (f.mode=fmInput)
    then f.InOutFunc:=@RsInput
    else f.InOutFunc:=@RsOutput;
  f.FlushFunc:=@RsFlush;
  f.CloseFunc:=@RsClose;
  RsOpen:=0;
end;


Procedure AssignAUX (var f: text);
Begin
  with Textrec(f) do
  begin
    mode:=fmClosed;
    bufsize:=1;
    bufptr:=@Buffer;
    OpenFunc:=@RsOpen;
    name[0]:=#0;
  end;
end;



{ ----- RS232 Initialization & Cleanup Code ----- }

Procedure RSinit (com: integer; speed: RSbaud; buffactor: integer; flow: boolean);
  { initialize port; required only if port not already active }
Begin
  if driverloaded then begin
    RSCom:=com;        { save port number }
    if (rscom<>0) then begin
      regs.ax:=0;
      regs.bx:=com;
      regs.cx:=ord(speed);
      regs.dx:=buffactor;
      regs.si:=word(flow);
      Intr(RSInt,regs);
    end;
  end else RSCom:=0;
end;


Procedure RSCleanup;
  { un-initialize port. should be used only if RSinit was used. }
Begin
  if (rscom<>0) then begin
    regs.ax:=1;
    Intr(RSInt,regs);
  end;
  rscom:=0;
end;


{ ----- Searchlight Control Functions ----- }

Function GetPublicPtr: Pointer;
  { get pointer to the SLBBS public data area. Returns NIL if not available }
var p: pointer;
Begin
  if driverloaded then begin
    regs.ax:=$C7;
    regs.cx:=$00;
    Intr(RSInt,regs);
    if (regs.cx=SLBBSID)
      then GetPublicPtr:=Ptr(regs.ax,regs.bx)
      else GetPublicPtr:=Nil;
  end else GetPublicPtr:=Nil;
end;


Procedure ComToggle;
  { toggle BIOS COM support on/off }
var save: pointer;
Begin
  if SLData<>nil then        { make sure Searchlight is loaded }
    if SLData^.rsactive then begin
      GetIntVec($10,save);                       { read address of INT $10 }
      SetIntVec($10,SLData^.OldVector[$10]);     { restore saved address }
      SLData^.OldVector[$10]:=save;              { store retrieved address }
      GetIntVec($16,save);
      SetIntVec($16,SLData^.OldVector[$16]);     { repeat for INT $16 }
      SLData^.OldVector[$16]:=save;
    end;
end;


{$F+}
Procedure ModemExit;
  { cleanup procedure }
Begin
  System.ExitProc:=SLModem.ExitSave;
  RSCleanup;
end;
{$F-}



Begin   { ----- Unit Initialization ----- }

  GetIntVec($79,p);                     { check if slbbs driver available }
  DriverLoaded:=(longint(p)=SLBBSID);
  SLData:=GetPublicPtr;                 { get public data area pointer }

  rscom:=0;
  AssignAux(AUXIn);    { prepare file oriented i/o functions }
  AssignAux(AUXOut);
  reset(AUXIn);
  rewrite(AUXOut);

  SLModem.Exitsave:=System.Exitproc;     { install cleanup procedure }
  System.Exitproc:=@ModemExit;

end.