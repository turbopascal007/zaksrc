{$M 2000,0,0}
{$F+,W-,G-,R-,S-}

Uses Crt,Dos,FastWr;

var
  Clock_Ticks : longint absolute $0040:$006C; { BIOS timer ticks }

  KBDStatus   : byte absolute $0:$0417;

  InitialKBDStatus : byte;

Const
      CRay: array[1..3] of Char = 'Äáõ';        CC:byte=3;
      URay: array[1..6] of char = 'Åñóö£Ê';     UC:byte=6;
      ERay: array[1..7] of Char = 'Çàâäê‰Ó';    EC:byte=7;
      ARay: array[1..8] of char = 'ÉÑÖÜéè†‡';   AC:byte=8;
      IRay: array[1..4] of Char = 'ãåç°';       IC:byte=4;

      ORay: array[1..8] of char = 'ìîïô¢¯ÍÈ';   OC:byte=8;
      YRay: array[1..3] of char = 'òùÊ';        YC:byte=3;
      LRay: array[1..1] of char = 'ú';          LC:byte=1;
      FRay: array[1..1] of char = 'ü';          FC:byte=1;

      GRay: array[1..1] of char = '‚';          GC:byte=1;
      TRay: array[1..1] of char = 'Á';          TC:byte=1;
      DRay: array[1..1] of char = 'Î';          DC:byte=1;
      BRay: array[1..1] of char = '·';          BC:byte=1;
      NRay: array[1..4] of char = '§•„Ô';       NC:byte=4;
      JRay: array[1..1] of char = 'ı';          JC:byte=1;


type chartype = record
     c:char;
     a:byte;
     end;

Type ScrnBuffer = Array[1..80*25] of chartype;

var       S: ScrnBuffer absolute $b800:0000 ;

Const
         KbdInt     = $09;
         KbdTrapInt = $15;
         TimerInt   = $08;

         Num = $20;
         Scr = $10;
         Cap = $40;

Var Critical: byte absolute $011c:0320;
    Dos_Busy: byte absolute $011c:0321;


Var      i:word;
         Regs         : registers;
         OldKbdTrapVec: pointer;
         OldKbdVec    : pointer;
         OldTimerVec  : pointer;
         t            :word;

procedure clock(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
  var reg: registers;
  begin

  asm
   call OldTimerVec;
  end;

  Inline($FA); { intsoff }

  if ((Dos_busy=0) and (critical=0)) then
   begin
   if (clock_ticks mod 20)=0 then
    for t:=1 to 80*5 do
    begin

    case upcase(s[t].c) of
     'C': s[t].c:=Cray[random(CC-1)+1];
     'U': s[t].c:=Uray[random(UC-1)+1];
     'E': s[t].c:=Eray[random(EC-1)+1];
     'A': s[t].c:=Aray[random(AC-1)+1];
     'I': s[t].c:=Iray[random(IC-1)+1];

     'O': s[t].c:=Oray[random(OC-1)+1];
     'Y': s[t].c:=Yray[random(YC-1)+1];
     'L': s[t].c:=Lray[random(LC-1)+1];
     'F': s[t].c:=Fray[random(FC-1)+1];

     'G': s[t].c:=Gray[random(GC-1)+1];
     'T': s[t].c:=Tray[random(TC-1)+1];
     'D': s[t].c:=Dray[random(DC-1)+1];
     'B': s[t].c:=Bray[random(BC-1)+1];
     'N': s[t].c:=Nray[random(NC-1)+1];
     'J': s[t].c:=Jray[random(JC-1)+1];

    end;
    end;

   end;
  inline($FB); { intson }
  end;


begin
  initialkbdstatus:=kbdstatus;

  directvideo:=true;
  GetIntVec(TimerInt, OldTimerVec);
  SetIntVec(TimerInt, @clock);

  exec(getenv('COMSPEC'),'');

  SetintVec(TimerInt, OldTimerVec);

end.
