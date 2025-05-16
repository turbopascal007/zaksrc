{ Copyright (c) 1990, Borland International }
program Prime0PA;

uses dos,crt;


const
  MaxPrimes = 64000;

type
  PrimeArray = array[1..32000] of word;

var
  Primes              : array[1..2] of ^PrimeArray;
  CurPrime, LastPrime : longint;
  J                   : longint;

  jlow                : longint;
  t                   : integer; {either 1 or 2, dude}

  GetOut              : Boolean;
  logfile             : text;
  ts                  : string[80];
  bffr                : array[1..16384] of byte;


procedure barf;
 begin
 close(logfile);
 halt;
 end;

function prime


begin
  new(primes[1]);
  new(primes[2]);

  assign(logfile, 'c:\tp\alprimes.lst');
  rewrite(logfile);
  settextbuf(logfile, bffr, 16483);

  Primes[1]^[1] := 2;
  Primes[1]^[2] := 3;
  LastPrime := 2;
  CurPrime  := 3;

  Writeln('Prime 1 = ', Primes[1]^[1]);
  Writeln('Prime 2 = ', Primes[1]^[2]);

  while CurPrime < MaxPrimes do
    begin
    GetOut := False;
    J := 1;
    if j>32000 then begin jlow:=j-32000; t:=2 end else t:=1;if t=1 then jlow:=j;
    while (J <= LastPrime) and (not GetOut) do
       begin
       if (CurPrime mod Primes[t]^[Jlow])=0 then
         begin
         CurPrime := CurPrime + 2;
         GetOut := True;
         end
       else
         begin
         Inc(J);
         if j>32000 then begin jlow:=j-32000; t:=2 end else t:=1;if t=1 then jlow:=j;
         end
       end { while };
    end;

    if J > LastPrime then
    begin
      Inc(LastPrime);

      if keypressed then barf;
      Writeln(logfile,'Prime ', LastPrime, ' = ', CurPrime);

      writeln(lastprime,curprime:8);

      Primes[t]^[jlow] := CurPrime;
      CurPrime := CurPrime + 2;

  end; { while }
end. { Prime0 }
