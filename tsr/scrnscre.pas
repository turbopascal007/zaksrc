{$M 2000,0,0}
{$F+,W+}

Uses Crt,Dos;

var
  Clock_Ticks : longint absolute $0040:$006C; { BIOS timer ticks }

  KBDStatus   : byte absolute $0:$0417;

  InitialKBDStatus : byte;

Const
         KbdInt     = $09;
         KbdTrapInt = $15;
         TimerInt   = $08;

         MinIntensity = 0;
         MaxIntensity = 63;

         Num = $20;
         Scr = $10;
         Cap = $40;

type
         ColourRange  = MinIntensity..MaxIntensity;
         RGBType      = Record r, g, b   : ColourRange; end;

Var Critical: byte absolute $011c:0320;
    Dos_Busy: byte absolute $011c:0321;


Var      i:word;
         Regs         : registers;
         OldKbdTrapVec: pointer;
         OldKbdVec    : pointer;
         OldTimerVec  : pointer;

         RGB : RGBType;
         filetorun:string;

         tempval :longint;


Procedure SetRegister(register : Byte; colour : ColourRange); Assembler;
        ASM
        MOV     BH, colour
        MOV     BL, register
        MOV     AX, 1000h
        INT     10h
   end;  { SetRegister }

Procedure SetRGBValue(register : Byte; RGB : RGBType); Assembler;
     ASM
  {      PUSH    DS}
        LDS     SI, RGB
        XOR     BX, BX
        MOV     BL, register
        LODSB
        MOV     DH, AL
        LODSW
        XCHG    CX, AX
        XCHG    CH, CL
        MOV     AX, 1010h
        INT     10h
{        POP     DS}
end;  { SetRGBValue }

procedure clock(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
  var i:byte;
  var reg: registers;
  begin

  asm
   call OldTimerVec;
  end;

  Inline($FA); { intsoff }

  if ((Dos_busy=0) and (critical=0)) then
   begin
   if
    begin

    KbdStatus := KbdStatus XOR Num;
    KbdStatus := KbdStatus XOR Cap;
    KbdStatus := KbdStatus XOR Scr;
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