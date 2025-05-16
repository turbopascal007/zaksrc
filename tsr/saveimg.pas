program SaveImg;

{$M 16384,0,65536}


Uses Dos,Crt;


Const
    KbdInt   = $09;

var
    filename     : string;
    Regs         : registers;

    OldKbdVec    : pointer;


procedure STI;  InLine($FB);
procedure CLI;  Inline($FA);


Procedure CallOldInt(sub:pointer);
  begin
  Inline($9C/                { pushf                 }
             $ff/$5e/$06)    { call dword ptr [bp+6] }
  end;

procedure keyboard(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
  begin
  CalloldInt(OldKbdVec);


  write('.');

  STI
  End;



procedure savescr;
  TYPE
     ScrData = Array[0..$4000] of Byte;
  VAR
     Data     : File of ScrData;
     Screen   : ^ScrData;

  BEGIN
     Screen := ptr($A000,0000);

     Assign(Data,filename);
     Rewrite(Data);
     Write(Data,Screen^);
     Close(Data);
   end;

var a,b:integer;

begin
   GetIntVec(KbdInt, OldKbdVec);
   SetIntVec(KbdInt, @keyboard);

  { Exec('C:\DOS\COMMAND.COM','');}

   for a:=1 to maxint do begin for b:=1 to maxint do end;

   SetIntVec(KbdInt, OldKbdVec);

end.