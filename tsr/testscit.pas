{$M 8192,0,0}

{$R-,S+,I-,D+,F+,V-,B-,N-,L+}

Uses Dos,Crt;

Const
    TmrInt  = $08;
Var
    OldTmrVec  : pointer;
    t          : word;

procedure IntsOn;   InLine($FB);
procedure IntsOff;  Inline($FA);

Procedure CallOldInt(sub:pointer);
  begin
  Inline($9C/                { pushf                 }
             $ff/$5e/$06);   { call dword ptr [bp+6] }
  end;

procedure Tmr(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
  begin

  CalloldInt(OldTmrVec);

  IntsOff;

    inc(t);
    if (t mod )=0 then write('.');

  IntsOn;

  End;


BEGIN
  t:=0;
  clrscr;
  GetIntVec(TmrInt, OldTmrVec);
  SetIntVec(TmrInt, @Tmr);

  repeat

  until keypressed;

  SetIntVec(TmrInt, OldTmrVec);

END.


