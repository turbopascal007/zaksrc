uses dos,crt;

type regtype = record
        num: integer;
     end;

var
   exefile: file;
   offs   : longint;
   a      : longint;
   bffr   : array[1..512] of char;
   found  : boolean;
   code   : word;
   reg    : regtype;

begin
 found := false;

 assign(exefile, 'whatsnew.exe');
 reset(exefile, 1);

 offs := filesize(exefile);

 repeat
    begin
    dec(offs, sizeof(bffr));
    seek(exefile, offs);
    blockread(exefile, bffr, sizeof(bffr));
    a:=0;
    repeat
      begin
      inc(a,1);
      if (bffr[a]='(') and (bffr[a+1]='*') and
         (bffr[a+2]='*') and (bffr[a+3]=')')
          then found := true;
      end;
    until found or (a>sizeof(bffr)-4);
    end;
 until found;

 offs := offs+a+3;


 seek(exefile, offs);

 blockread(exefile,reg,2);

 write('Old Number: ',reg.num);

 val(paramstr(1), reg.num, code);

 seek(exefile, offs);

 blockwrite(exefile, reg, sizeof(reg));

 writeln(' Changed to ', reg.num);

 close(exefile);

end.
