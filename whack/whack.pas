Program Whack;

Uses Dos;

Const 
      CRay: array[1..3] of Char = '€‡›';        CC:byte=3;
      URay: array[1..6] of char = '–—š£æ';     UC:byte=6;
      ERay: array[1..7] of Char = '‚ˆ‰Šäî';    EC:byte=7;
      ARay: array[1..8] of char = 'ƒ„…† à';   AC:byte=8;
      IRay: array[1..4] of Char = '‹Œ¡';       IC:byte=4;

      ORay: array[1..8] of char = '“”•™¢øêé';   OC:byte=8;
      YRay: array[1..3] of char = '˜æ';        YC:byte=3;
      LRay: array[1..1] of char = 'œ';          LC:byte=1;
      FRay: array[1..1] of char = 'Ÿ';          FC:byte=1;

      GRay: array[1..1] of char = 'â';          GC:byte=1;
      TRay: array[1..1] of char = 'ç';          TC:byte=1;
      DRay: array[1..1] of char = 'ë';          DC:byte=1;
      BRay: array[1..1] of char = 'á';          BC:byte=1;
      NRay: array[1..4] of char = '¤¥ãï';       NC:byte=4;
      JRay: array[1..1] of char = 'õ';          JC:byte=1;

var
    s:string;
    i:byte;

begin

randomize;

reset(input);
rewrite(output);

repeat
 begin
 readln(input,s);
 for i:=1 to length(s) do
    begin
    case upcase(s[i]) of
     'C': s[i]:=Cray[random(CC-1)+1];
     'U': s[i]:=Uray[random(UC-1)+1];
     'E': s[i]:=Eray[random(EC-1)+1];
     'A': s[i]:=Aray[random(AC-1)+1];
     'I': s[i]:=Iray[random(IC-1)+1];

     'O': s[i]:=Oray[random(OC-1)+1];
     'Y': s[i]:=Yray[random(YC-1)+1];
     'L': s[i]:=Lray[random(LC-1)+1];
     'F': s[i]:=Fray[random(FC-1)+1];

     'G': s[i]:=Gray[random(GC-1)+1];
     'T': s[i]:=Tray[random(TC-1)+1];
     'D': s[i]:=Dray[random(DC-1)+1];
     'B': s[i]:=Bray[random(BC-1)+1];
     'N': s[i]:=Nray[random(NC-1)+1];
     'J': s[i]:=Jray[random(JC-1)+1];

     end;
    end;
 writeln(output,s);
 end;
until eof(input);

close(input);
close(output);

end.
