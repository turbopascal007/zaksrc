Program ooZdemo;

uses EditLine,EdlMgr,Crt;

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

procedure tb_(c:byte);far;
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

var IM:plineeditmgrtype;
begin
directvideo:=true;
IM:=new(plineEditMgrType,Init(white,blue,cyan,21,green,
       true,[esc,up,down,tab,enter],
       write_,movex,wherex_,textcolor,tb_,rk_,gxy_,clreol,
       'Are All Fields Correct?',24,lightgray));

textbackground(black);
crt.clrscr;

gotoxy(1,1);
textcolor(lightred);
write(' Updating fields');

im^.add(1,3,30,'Arthur, King of the Britons',[ins,caps],'Your Name');

im^.add(1,4,50,'To seek the Grail',[ins],'Your Quest');

im^.add(1,5,18,'Blue',[ins],'Your Favourite Colour');

im^.run;

gotoxy(1,10);

textcolor(green);
writeln('You entered');

textcolor(yellow);

writeln(im^.out);
writeln(im^.out);
writeln(im^.out);

dispose(im,done);
textcolor(cyan);

end.

