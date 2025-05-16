{$M 5000,0,0}
Uses Dos,Crt,Etc;


var f :file;
    it:text;
    s,p :string;

Procedure KillFiles(p:string);
 var s:searchrec;
     f:file;
 begin
 FindFirst(p,anyfile XOR directory,s);
 While DosError=0 do
  begin

  if s.name<>'DUPEFILE.DAT' then
   begin
   assign(f,splitfilepath(p)+s.name);
   erase(f);
   end;

  FindNext(s);
  end;
 end;

Procedure Proc;
var op:string;
 begin

 p:=ltrim(copy(s,pos('-g',s)+2,length(s)-pos('-g',s)-1));
 p:=rtrim(copy(p,1,pos(' ',p)-1));

 if (p[ord(p[0])]<>'\') then p:=p+'\';

 op:=p;

 if (pos('-K',upcasestr(s))>0) then
   begin
   p:=p+'*.MSG';

   Write(p);

   KillFiles(op+'\*.*');

   writeln(' .. done')

   end;
 end;

begin

assign(it,'in.all');
reset(it);

readln(it,s);
if rtrim(ltrim(s))<>'' then proc;

while not eof(it) do
 begin
 readln(it,s);
 if rtrim(ltrim(s))<>'' then proc;
 end;

close(it);

end.

I AD&D     -g c:\msg\AD&D     -k
I ATHEIST  -g c:\msg\atheist  -k
