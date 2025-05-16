unit PrlDev;

interface

Type pPrlDevObj = ^PrlDevObj;
     PrlDevObj = object
     Constructor Init(c:byte);
     Procedure   Put(c:byte);
     Procedure   Clear;
     Procedure   ShiL(n:byte);
     Procedure   ShiR(n:byte);
     Procedure   SetDelay(n:word);
     Procedure   PutDelay(c:byte);
     Procedure   PutArray(var a;l:word);
     Procedure   PutArrayDelay(var a;l:word);
     Destructor  Done(clr:boolean);
     private
      portnum,lastbyte:byte;
      tdelay:word;
     end;

implementation

uses crt;

type addrtype = array[1..2] of word;
const portaddr: addrtype = ($378, $278);

Constructor PrlDevObj.Init(c:byte);
 begin
 lastbyte:=0;
 portnum:=c;
 tdelay:=0;
 Put(LastByte)
 end;

procedure PrlDevObj.PutArray(var a;l:word);
 var c:word;
 begin
 for c:=0 to l-1 do put(mem[seg(a):ofs(a)+c]);
 end;

procedure PrlDevObj.PutArrayDelay(var a;l:word);
 var c:word;
 begin
 for c:=0 to l-1 do putdelay(mem[seg(a):ofs(a)+c]);
 end;


Procedure PrlDevObj.Put(c:byte);
 begin
 port[portaddr[portnum]]:=integer(c);
{ lastbyte := c;}
 end;

procedure PrlDevObj.SetDelay(n:word);
 begin
 tdelay:=n;
 end;

procedure PrlDevObj.PutDelay(c:byte);
 begin
 Put(c);
 delay(tdelay);
 end;

procedure PrlDevObj.Clear;
 var cl:byte;
 begin
 cl:=0;
 Put(cl);
 end;

procedure PrlDevObj.ShiR(n:byte);
 var tv:byte;
 begin
 tv:=lastbyte shr n;
 Put(tv)
 end;

procedure PrlDevObj.ShiL(n:byte);
 var tv:byte;
 begin
 tv:=lastbyte shl n;
 Put(tv)
 end;

destructor PrlDevObj.Done(clr:boolean);
 begin
 if clr then Clear;
 end;

end.