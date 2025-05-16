Uses bTree, ModemCrt, EdlMgr, EditLine, ooSlfLow, Etc;
{$B-}

Const usingmodem=false;

var
    Io        : pModemCrtObj;
    Editor    : pLineEditMgrObj;
    Cfg       : pSLConfigObj;

procedure Write(s:string);far; begin Io^.write(s) end;
procedure MoveX(x:integer);far; begin Io^.MoveRelX(x) end;
Function  WhereX:byte; far; begin wherex:=Io^.Wherex end;
Procedure TextColor(c:byte);far; begin Io^.TextColor(c) end;
Procedure TextBackground(c:byte);far; begin Io^.TextBackground(c) end;
Function  ReadKey(var extend:char):char;far; begin readkey := Io^.Readkey(extend) end;
Procedure GotoXY(x,y:byte); far; begin Io^.gotoxy(x,y) end;
Procedure ClrEol;far; begin Io^.ClrEol end;

var UName: string;
    PW   : string;


begin

Cfg:=New(pSLConfigObj,Init(''));

Io := New (pModemCrtObj,Init(Cfg^.Data.Comport,UsingModem,[Local,Remote]));

if Cfg^.Data.RsActive and not(Io^.DetectAnsi) then
  begin
  dispose(io,done(cold,nohang));
  dispose(cfg,done);
  halt(1);
  end;

with Io^ do
 begin
 setwrite([local]);
 textcolor(lightred);
 Writeln('Successfully Initialized FOSSIL Driver');
 textcolor(cyan);
 writeln(Io^.id);
 Setwrite([local,remote]);
 end;

Io^.flush;
Io^.killin;
Io^.ClrScr;

uname[0]:=#0;
pw[0]:=#0;

Editor := New(pLineEditMgrObj,Init(White,Blue,cyan,21,green,
       true,[Up,Down,Enter,tab,Esc],
       Write,MoveX,WhereX,TextColor,TextBackground,ReadKey,GotoXY,ClrEol,
       'Are All Fields Correct?',4,lightgray));

Io^.textbackground(0);
Io^.clrscr;
Io^.gotoxy(1,1);
textcolor(lightred);

Io^.write(' '+Cfg^.Data.SystemName+' Login Procedure ');
Io^.textcolor(magenta);

editor^.add(1,3,25,uname,[ins,caps],'Name/ID');
editor^.add(1,4,25,pw,[ins,echodots],'Password');
editor^.run;

uname:=editor^.out;
pw:=editor^.out;

Io^.textcolor(cyan);
Io^.textbackground(black);
Io^.gotoxy(1,7);

writeln('''',uname,'''');
writeln('''',pw,'''');

dispose(editor,done);

Dispose(Io,Done(cold,nohang));
Dispose(Cfg,done);

end.
