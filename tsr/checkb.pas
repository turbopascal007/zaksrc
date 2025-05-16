{$M 10000,0,0}
{$F+,W+}

Uses Crt,Dos;

var
  Clock_Ticks : longint absolute $0040:$006C; { BIOS timer ticks }

Const
         DiskInt   = $13;

Var Critical: byte absolute $011c:0320;
    Dos_Busy: byte absolute $011c:0321;

Var
         Regs         : registers;

         OldDiskVec   : pointer;

         f            : text;

procedure Disk(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
  var i:byte;
  var reg: registers;
  begin

  asm
   call OldDiskVec;
  end;

  Inline($FA); { intsoff }


  if (hi (ax) = 00) or
     (hi (ax) = 01) or
     (hi (ax) = 02) then

    if ((Dos_busy=0) and (critical=0)) then
     begin

     assign(f,'c:\checkb.bin');
     append(f);

     Writeln(f,'ax = ',ax,'; bx = ',bx,'; cx = ',cx);

     close(f);

     end;

  inline($FB); { intson }
  end;


begin

  directvideo:=true;
  GetIntVec(DiskInt, OldDiskVec);
  SetIntVec(DiskInt, @Disk);

  assign(f,'c:\checkb.bin');
  rewrite(f);
  writeln(f,' ... ');
  close(f);

  exec(getenv('COMSPEC'),'');

  SetintVec(DiskInt, OldDiskVec);

end.