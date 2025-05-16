Unit SLDRIV;
{$O+}

Interface

type SlData = record

      PROGID: string[6];                { Program ID }

      carrier: boolean;                 { carrier check enable }
      writeprotect: boolean;            { disk write protection }
      aborttype: byte;                  { 0=no abort, 1=terminate, 2=reboot }

      rsactive: boolean;                { set if rs232 active }
      ansi: boolean;                    { user ANSI mode }
      color: boolean;                   { user COLOR mode }
      directvid: boolean;               { system DirectVid mode }

      curratt: byte;                    { current video attribute }
      commtype: byte;                   { run parameter }
      idletime: word;                   { idle limit (seconds) }

      lastkey: boolean;                 { TRUE = last key from local kbd }

      OldVector: array[$00..$FF] of pointer;   { old user int vectors }

      end;


Var Data: ^SlData;

Procedure NoComInput;
Procedure ComInput;

Procedure LocalOnly;
Procedure LocalAndRemote;
Function  SlActive    : boolean;
Function  Carrier     : boolean;
Function  WriteProtect: boolean;
Function  Aborttype   : byte;
Function  RsActive    : boolean;
Function  AnsiMode    : boolean;
Function  ColorMode   : boolean;
Function  DirectVid   : boolean;
Function  Curratt     : byte;
Function  CommType    : byte;
Function  IdleTime    : word;
Function  Lastkey     : boolean;


Implementation

uses Dos;

var regs: registers;
    save: pointer;         { saved int $10 pointer }
    save16h: pointer;      { saved int $15 pointer }

Function SlActive;
  begin
  if data^.progid = 'SLBBS'
    then SlActive := True Else SlActive := False;
  end;

procedure LocalOnly;
  begin
  if (data^.rsactive and slactive) then
    begin
    GetIntVec($10,save);                  { read existing address }
    SetIntVec($10,Data^.OldVector[$10]);  { restore original BIOS address }
    end;
  end;

Procedure LocalAndRemote;
  begin
  if (Data^.rsactive and slactive)
      then SetIntVec($10,save); { put SLBBS address back }
  end;

procedure NoComInput;
  begin
  if (data^.rsactive and slactive) then
    begin
    GetIntVec($16,save16h);                  { read existing address }
    SetIntVec($16,Data^.OldVector[$16]);  { restore original BIOS address }
    end;
  end;

Procedure ComInput;
  begin
  if (Data^.rsactive and slactive) then SetIntVec($16,save16h); { put SLBBS address back }
  end;

Function Carrier: boolean;
  begin
  Carrier := data^.carrier;
  end;

function WriteProtect: boolean;
  begin
  WriteProtect := data^.writeprotect;
  end;

function AbortType: byte;
  begin
  AbortType := Data^.aborttype;
  end;

function RsActive: boolean;
  begin
  RsActive := data^.RsActive;
  end;

function AnsiMode: boolean;
  begin
  AnsiMode := data^.ansi;
  end;

function ColorMode: boolean;
  begin
  Colormode := data^.color;
  end;

function DirectVid: boolean;
  begin
  DirectVid := data^.directVid;
  end;

function Curratt: byte;
  begin
  Curratt := data^.curratt;
  end;

function Commtype: byte;
  begin
  Commtype := data^.commtype;
  end;

function IdleTime: word;
  begin
  IdleTime := data^.Idletime;
  end;

function Lastkey: boolean;
  begin
  lastkey := data^.lastkey;
  end;


var i:integer;
begin
  regs.ah:=$C7;
  MsDos(regs);                  { Load pointer to SLBBS data }
  data:=Ptr(regs.ax,regs.bx);
end.
