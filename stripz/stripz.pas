program StripZ;

var
     f      : file;
     buffer : array[1..1024] of char;

     base   : longint;

     replacechar: char;
     rs: string;

     flen  : longint;

Procedure ProcessBuf(l:word);
   var i:word;
   begin
   for i:=1 to l do
      begin
      if (buffer[i]=^Z) then
         begin
         seek(f,(base*sizeof(buffer))+i-1);
         blockwrite(f,replacechar,1);
         end;
      end;
   end;

begin

if paramcount=0 then
  begin
  writeln;
  writeln('StripZ filename $');
  writeln(' where $ is the character you want ^Z replaced with');
  writeln;
  halt;
  end;

{$I-}
assign(f,paramstr(1));
reset(f,1);
{$I+}
if not(ioresult=0) then
  begin
  writeln('cannot open ',paramstr(1));
  halt;
  end;

rs := paramstr(2);
replacechar := rs[1];

base:=0;

flen := filesize(f);

for base:=0 to (flen div sizeof(buffer))-1 do
   begin
   seek(f,base*sizeof(buffer));
   blockread(f,buffer,sizeof(buffer));

   ProcessBuf(sizeof(buffer));

   end;

seek(f,flen - (flen mod sizeof(buffer)));
blockread(f,buffer,flen mod sizeof(buffer));

ProcessBuf(flen mod sizeof(buffer));

close(f);

end.

