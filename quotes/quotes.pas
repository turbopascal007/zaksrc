uses SLfLow,Crt,Dos;

var i:longint;
    f:file;
    fh:fileheader;
    qh:quotehead;
    q :quotetype;
    m : boolean;
    c : word;

begin

c:=0;

m:= true;

filemode:=66;

directvideo := false;

init_config ( '' , closed );

init_constdata(f,quotesF,fh,qh);

i:=qh.head;

if cfg.ansi then clrscr;


while not(i=qh.tail) and m do
  begin
  read_data(f,quotesf,i,q);
{  if q.status=active then}
    begin
    inc(c);
    if cfg.ansi then textcolor(lightgray);
    write('``');
    if cfg.ansi then textcolor(cfg.colorchart[normal]);
    write(q.quote);
    if cfg.ansi then textcolor(lightgray);
    writeln('''''');
    write('   --- ');
    if cfg.ansi then textcolor(cfg.colorchart[special]);
    write(q.name);
    write('    ');
    if cfg.ansi then textcolor(cfg.colorchart[altcolor]);
    writeln(q.date.month,'/',q.date.day,'/',q.date.year);
    writeln;
    end;

  dec(i);
  if i=0 then i:=96;

  if (c mod 6)=0 then
   begin
   if cfg.ansi then textcolor(cfg.colorchart[promptcolor]);
   write('View more quotes? ');
   m:=not (upcase(readkey)='N');
   if cfg.ansi then clrscr;
   end;

  end;

close_data(f)

end.