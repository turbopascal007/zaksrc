{$N+,E-}


Uses Dos, Crt, Etc;

Type Unt = longint;

Const MaxNum = 65536*2;

const fn = 'allprime.lst';

Type SinglePrimeArrayType = Array[0..65520 div SizeOf(Unt)-1] of Unt;
     pSPAT = ^SinglePrimeArrayType;
     PrimeArrayType = Array[0..MaxNum div (MaxNum div SizeOf(Unt))] of pSPAT;


Var p     : PrimeArrayType;
    NumOfP: longint;

procedure addprime(n:longint);
 begin
 inc(NumOfp);
 p[NumOfP div (65520 div Sizeof(unt))]^[NumOfP mod (65520 div Sizeof(unt))] := n;
 end;

function gp(i:longint):unt;
 begin
 gp:=p[i div (65520 div Sizeof(unt))]^[i mod (65520 div Sizeof(unt))]
 end;

function prime(n:longint):boolean;
var i:longint;
 begin
 for i:=1 to NumOfP do
     begin
     if (n mod gp(i))=0 then
       begin
       prime := false;
       exit;
       end
     else if gp(i) > (n div 2) then
       begin
       prime:=true;
       addprime(n);
       exit;
       end;
     end;
 prime := true;
 addprime(n)
 end;


var b     : byte;
    i     : longint;
    o     : text;

procedure loadprimes;
  var f:text;
      s:string;
      t:longint;
      c:longint;
  begin
  assign(f,fn);
  reset(f);
  c:=0;

  while not eof(f) do
    begin
    readln(f,s);
    t:=tolong( copy(s,pos(':',s)+1,length(s)-(pos(':',s)-1)));
    addprime(t);
    inc(c);
    end;

  i:=t+1;

  if not odd(i) then inc(i,1);

  numofp := c;

  close(f)
  end;

Begin

for b:=0 to maxnum div (maxnum div sizeof(unt))-1 do new(p[b]);

NumOfP := 0;

if existfile(fn,anyfile) then loadprimes else i := 2;

assign(o,fn);
if existfile(fn,anyfile) then append(o) else rewrite(o);

while (NumOfP < MaxNum) and not keypressed do
  begin
  if Prime(i) then
    begin
    writeln(o,'#',NumOfP:6,': ',i);
    writeln('#',NumOfP:6,': ',i);
    end;
  inc(i,2);
  end;


for b:=0 to maxnum div (maxnum div sizeof(unt))-1 do dispose(p[b]);

close(o);

end.
