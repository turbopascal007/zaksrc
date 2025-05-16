Unit ooSLDRIV;
{$O+,F+}

Interface

Type IOType = (Local,Both);

type pSlData = ^SlData;
     SlData = record
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

Type
  pSlDrivObj = ^sldrivobj;
  SlDrivObj = object
  Constructor Init;

  Procedure SetRead(Re:IOtype);

  Procedure SetWrite(Wr:IOtype);

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

  Private
  data:pSlData;
  end;




Implementation

uses Dos;

var regs: registers;
    save: pointer;         { saved int $10 pointer }
    save16h: pointer;      { saved int $15 pointer }

Function SlDrivObj.SlActive;
  begin
  if data^.progid = 'SLBBS'
    then SlActive := True Else SlActive := False;
  end;

Procedure SlDrivObj.SetWrite(WR:IOtype);
  begin
  if (data^.rsactive and slactive) then
   if WR=Local then
    begin
    GetIntVec($10,save);                  { read existing address }
    SetIntVec($10,Data^.OldVector[$10]);  { restore original BIOS address }
    end
   else if WR=Both then
     SetIntVec($10,save); { put SLBBS address back }
  end;

Procedure SlDrivObj.SetRead(re:iotype);
  begin
  if (data^.rsactive and slactive) then
   if Re=Local then
    begin
    GetIntVec($16,save16h);                  { read existing address }
    SetIntVec($16,Data^.OldVector[$16]);  { restore original BIOS address }
    end
   else if RE=Both then
    SetIntVec($16,save16h); { put SLBBS address back }

  end;

Function SlDrivObj.Carrier: boolean;
  begin
  Carrier := data^.carrier;
  end;

Function SlDrivObj.WriteProtect: boolean;
  begin
  WriteProtect := data^.writeprotect;
  end;

Function SlDrivObj.AbortType: byte;
  begin
  AbortType := Data^.aborttype;
  end;

Function SlDrivObj.RsActive: boolean;
  begin
  RsActive := data^.RsActive;
  end;

Function SlDrivObj.AnsiMode: boolean;
  begin
  AnsiMode := data^.ansi;
  end;

Function SlDrivObj.ColorMode: boolean;
  begin
  Colormode := data^.color;
  end;

Function SlDrivObj.DirectVid: boolean;
  begin
  DirectVid := data^.directVid;
  end;

Function SlDrivObj.Curratt: byte;
  begin
  Curratt := data^.curratt;
  end;

Function SlDrivObj.Commtype: byte;
  begin
  Commtype := data^.commtype;
  end;

Function SlDrivObj.IdleTime: word;
  begin
  IdleTime := data^.Idletime;
  end;

Function SlDrivObj.Lastkey: boolean;
  begin
  lastkey := data^.lastkey;
  end;

Constructor SlDrivObj.Init;
begin
  regs.ah:=$C7;
  MsDos(regs);                  { Load pointer to SLBBS data }
  data:=Ptr(regs.ax,regs.bx);
end;
end.
