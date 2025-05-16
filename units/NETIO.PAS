Uses Dos;

Const Wait   = $00;
      NoWait = $80;

Type NCBtype = record
    Command         : byte;
    ReturnCode      : byte;
    LocalSessionNum : byte;
    Num             : byte;
    BufAdr          : pointer;
    Buflen          : word;
    CallName        : Array[1..16] of char;
    Name            : array[1..16] of char;
    ReceiveTimeOut  : byte;
    SendTimeOut     : byte;
    Post            : pointer;
    LANA_NUM        : byte;
    CMD_DONE        : byte; { $ff = not done }
    RES             : array[1..14] of byte;
    end;

type nametype = array[1..16] of byte;

Var Lana: byte;

procedure s2b(s:string;var a);
 begin
 move(s[1],a,ord(s[0]));
 fillchar(mem[seg(a):ofs(a)+length(s)],16-length(s),0);
 end;


Function Reset: boolean;
  var ncb:ncbtype;
      r  :registers;
  begin
  ncb.command := $32 or Wait;
  ncb.lana_num := lana;
  ncb.localsessionnum := 1;
  ncb.num := 1;

  r.es := seg(ncb);
  r.bx := ofs(ncb);
  Intr($5C,r);

  Reset:=ncb.returncode=0;
  end;

function AddName(addn:string;var namenum:byte): boolean;
  var ncb:ncbtype;
  r:registers;
  begin
  ncb.command := $30;
  ncb.lana_num := lana;
  s2b(addn,ncb.name);

  r.es := seg(ncb);
  r.bx := ofs(ncb);
  Intr($5C,r);

  namenum := ncb.num;
  addname := ncb.returncode=0;
  end;


function DeleteName(deln:string):boolean;
  var ncb:ncbtype;
  r:registers;
  begin

  ncb.command := $31;
  ncb.lana_num := lana;
  s2b(deln,ncb.name);

  r.es := seg(ncb);
  r.bx := ofs(ncb);
  Intr($5C,r);

  deletename := ncb.returncode=$17;
  end;

procedure DGSend(namenum:byte;callname:string;var d;l:word);
  var ncb:ncbtype;
      r:registers;

  begin
  ncb.command := $20;
  ncb.lana_num := lana;
  ncb.num := namenum;
  s2b(callname,ncb.callname);
  ncb.bufadr := @d;
  ncb.buflen := l;

  r.es := seg(ncb);
  r.bx := ofs(ncb);
  Intr($5C,r);

  end;

{procedure DGReceive}

var nn:byte;
    s:string;
begin
s:='Hi!';
Lana := 0;
writeln(reset);
writeln(AddName('ZAK',nn));

DGSEND(nn,'FRANKS_AT',s,length(s));

writeln(DeleteName('ZAK'));
end.