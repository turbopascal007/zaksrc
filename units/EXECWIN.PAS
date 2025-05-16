{
 This unit interfaces one procedure, ExecWindow, which uses the ExecDos
 routine from Turbo Professional's TPDOS unit to run a child process. In
 addition to what the ExecDos routine does, ExecWindow attempts to keep the
 video output of the child process within a specified window on the screen.
 This is useful for some programs, as exemplified by the INSTALL.EXE program
 used for installation of Turbo Professional files.

 The technique used is to grab interrupt 21h and thus control all writes to
 the standard output and error devices. These are rerouted to the screen,
 within the specified window. Note that the technique will not work for
 programs that write directly to video memory, through the BIOS, or through
 some other file handle assigned to the console. It does work with standard
 DOS commands, with the TPC.EXE compiler, and with other command line
 utilities like ARCX.COM.

 Written by Kim Kokkonen, TurboPower Software
 Released to the public domain
 Version 1.0 - 10/09/88
}

{$R-,S-,I-,B-,F-,V-,O+}

unit ExecWin;
  {-Exec a program in a window}

interface

uses
  Dos;
{  TpDos;}

type execproctype = procedure(c,p:string);

procedure ExecWindow(Command,p : string;
                    Xlo, Ylo, Xhi, Yhi : Byte;
                    Attr : Byte);


procedure FlexExecWindow(Command,p : string;
                    Xlo, Ylo, Xhi, Yhi : Byte;
                    Attr : Byte;
                    ep:execproctype);

  {-Exec a program in a window.
    Command and UseSecond are defined just as for ExecDos.
    Xlo, Ylo, Xhi, Yhi are the window boundaries, just as for a Window() call.
    Attr is the video attribute for all writes within the window.
    Returns error codes just like ExecDos.
  }

  {=======================================================================}

implementation

type
  ByteCast =
    record
      LoB, HiB : Byte;
    end;

var
  SaveInt21 : Pointer;
  WindPos : Word;
  WindLo : Word;
  WindHi : Word;
  WindAttr : Byte;

  {$L EXECWIN}
  procedure SetCsInts; external;
  procedure NewInt21; external;

 procedure FlexExecWindow(Command,p : string;
                    Xlo, Ylo, Xhi, Yhi : Byte;
                    Attr : Byte;
                    ep:execproctype);

  begin
    {Validate window}
    if (Xlo > Xhi) or (Ylo > Yhi) or (Xlo < 1) or (Ylo < 1) then begin
      Xlo:=1;
      Xhi:=80;
      Yhi:=25;
      Ylo:=1;
    end;

    {Store global copies of window data for interrupt handler}
    WindAttr := Attr;
    ByteCast(WindLo).LoB := Xlo-1;
    ByteCast(WindLo).HiB := Ylo-1;
    ByteCast(WindHi).LoB := Xhi-1;
    ByteCast(WindHi).HiB := Yhi-1;

    {Assure cursor is in window}
    inline
    (
     {;get cursor pos}
     $B4/$03/                     {  mov ah,3}
     $30/$FF/                     {  xor bh,bh}
     $CD/$10/                     {  int $10}
     {;assure it's within window}
     $8B/$0E/>WindLo/             {  mov cx,[>windlo]}
     $38/$EE/                     {  cmp dh,ch ;row above minimum?}
     $73/$02/                     {  jae okxlo ;jump if so}
     $88/$EE/                     {  mov dh,ch}
     {okxlo:}
     $38/$CA/                     {  cmp dl,cl ;col above minimum?}
     $73/$02/                     {  jae okylo ;jump if so}
     $88/$CA/                     {  mov dl,cl}
     {okylo:}
     $8B/$0E/>WindHi/             {  mov cx,[>windhi]}
     $38/$EE/                     {  cmp dh,ch ;row below maximum?}
     $76/$02/                     {  jbe okxhi ;jump if so}
     $88/$EE/                     {  mov dh,ch}
     {okxhi:}
     $38/$CA/                     {  cmp dl,cl ;col below maximum?}
     $76/$02/                     {  jbe okyhi ;jump if so}
     $88/$CA/                     {  mov dl,cl}
     {okyhi:}
     $89/$16/>WindPos/            {  mov [>windpos],dx ;save current position}
     {;position cursor}
     $B4/$02/                     {  mov ah,2}
     $30/$FF/                     {  xor bh,bh}
     $CD/$10);                    {  int $10}

    {Take over interrupt}
    GetIntVec($21, SaveInt21);
    SetCsInts;
    SetIntVec($21, @NewInt21);

    {Exec the program}

    Ep(Command,P);

    {Restore interrupt}
    SetIntVec($21, SaveInt21);
  end;


  procedure ExecWindow(Command,p : string;
                      Xlo, Ylo, Xhi, Yhi : Byte;
                      Attr : Byte);
    {-Exec a program in a window}
  begin
    {Validate window}
    if (Xlo > Xhi) or (Ylo > Yhi) or (Xlo < 1) or (Ylo < 1) then begin
      Xlo:=1;
      Xhi:=80;
      Yhi:=25;
      Ylo:=1;
    end;

    {Store global copies of window data for interrupt handler}
    WindAttr := Attr;
    ByteCast(WindLo).LoB := Xlo-1;
    ByteCast(WindLo).HiB := Ylo-1;
    ByteCast(WindHi).LoB := Xhi-1;
    ByteCast(WindHi).HiB := Yhi-1;

    {Assure cursor is in window}
    inline
    (
     {;get cursor pos}
     $B4/$03/                     {  mov ah,3}
     $30/$FF/                     {  xor bh,bh}
     $CD/$10/                     {  int $10}
     {;assure it's within window}
     $8B/$0E/>WindLo/             {  mov cx,[>windlo]}
     $38/$EE/                     {  cmp dh,ch ;row above minimum?}
     $73/$02/                     {  jae okxlo ;jump if so}
     $88/$EE/                     {  mov dh,ch}
     {okxlo:}
     $38/$CA/                     {  cmp dl,cl ;col above minimum?}
     $73/$02/                     {  jae okylo ;jump if so}
     $88/$CA/                     {  mov dl,cl}
     {okylo:}
     $8B/$0E/>WindHi/             {  mov cx,[>windhi]}
     $38/$EE/                     {  cmp dh,ch ;row below maximum?}
     $76/$02/                     {  jbe okxhi ;jump if so}
     $88/$EE/                     {  mov dh,ch}
     {okxhi:}
     $38/$CA/                     {  cmp dl,cl ;col below maximum?}
     $76/$02/                     {  jbe okyhi ;jump if so}
     $88/$CA/                     {  mov dl,cl}
     {okyhi:}
     $89/$16/>WindPos/            {  mov [>windpos],dx ;save current position}
     {;position cursor}
     $B4/$02/                     {  mov ah,2}
     $30/$FF/                     {  xor bh,bh}
     $CD/$10);                    {  int $10}

    {Take over interrupt}
    GetIntVec($21, SaveInt21);
    SetCsInts;
    SetIntVec($21, @NewInt21);

    {Exec the program}

    Exec(Command,P);

    {Restore interrupt}
    SetIntVec($21, SaveInt21);
  end;

end.
