uses editline,edlmgr ,crt;

{$F+}

procedure movex(c:integer);far;
 begin
 gotoxy(wherex+c,wherey);
 end;

procedure write_(s:string);far;
 begin
 write(s);
 end;

function wherex_:byte;far;
 begin
 wherex_:=wherex;
 end;

procedure tc_(c:byte);far;
 begin
 textcolor(c);
 end;

procedure tb_(c:byte);
 begin
 textbackground(c);
 end;

function rk_:char;far;
 begin
 rk_:=readkey;
 end;

procedure gxy_(x,y:byte);far;
 begin
 gotoxy(x,y);
 end;

var m:plineeditmgrtype;
a:longint;
ansi:boolean;

begin

ansi:=true;

directvideo:=false;

a:=memavail;

m:=new(plineEditMgrType,Init(white,blue,cyan,ansi,[esc,up,down,tab,enter],
       write_,movex,wherex_,tc_,tb_,rk_,gxy_,
       'Are All Fields Correct?'));

textbackground(black);

crt.clrscr;

m^.add(10,1,25,'first line',[ins],'First line input?');

m^.add(10,2,25,'2nd line',[ins],'2nd line input?');

m^.NoMore;

m^.run;

writeln;
writeln;
writeln(m^.out);
writeln(m^.out);

dispose(m,done);

end.