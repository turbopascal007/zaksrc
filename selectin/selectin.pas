{
I like a organized-looking area text file.. and MailSeek didn't take off
the trailing spaces..
c:\msg\btech   ;I BTECH    -g c:\msg\btech    -k
c:\msg\sf-lit  ;I SF-LIT   -g c:\msg\sf-lit   -k
}

Program SelectIn;
Uses Dos,Etc,Crt;
var inf,outf: text;
    l     : string;
procedure proc;
  var p:string;

  begin
  l:=ltrim(l);
  if length(l)<1 then exit;
  if l[1]='*' then write(l)
  else
   begin
   p:=rtrim(ltrim(copy(l,1,pos(';',l)-1)));
   if p[length(p)]<>'\' then p:=p+'\';
   p:=p+'*.MSG';

   write(p+ltab(length(p),30));

   if EXISTFILE(p) then
     begin
     write('Found');
     writeln(outf,rtrim(ltrim(copy(l,pos(';',l)+1,length(l)-pos(';',l)))));
     end
    else write('unfound');
   end;

  writeln;
  end;

begin
assign(inf,paramstr(1));
reset(inf);

assign(outf,paramstr(2));
rewrite(outf);

repeat
 begin
 readln(inf,l);
 proc;
 end
until eof(inf);

close(inf);
close(outf);
end.

