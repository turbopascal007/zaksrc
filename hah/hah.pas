Uses bTree, ModemCrt, EdlMgr, EditLine, Etc;
{$F+}

Const ComPort=2;
      usingmodem=false;

Type DataRecType = record
        Quest  : String[50];
        FColour: String[15]
        end;

Var UName : String[25];
    Io    : pModemCrtObj;
    Data  : pbTreeObj;
    Editor: pLineEditMgrObj;
    Rec   : ^DataRecType;
    Found : boolean;

procedure Write(s:string);far; begin Io^.write(s) end;
procedure MoveX(x:integer);far; begin Io^.MoveRelX(x) end;
Function  WhereX:byte; far; begin wherex:=Io^.Wherex end;
Procedure TextColor(c:byte);far; begin Io^.TextColor(c) end;
Procedure TextBackground(c:byte);far; begin Io^.TextBackground(c) end;
Function  ReadKey(var extend:char):char;far; begin readkey := Io^.Readkey(extend) end;
Procedure GotoXY(x,y:byte); far; begin Io^.gotoxy(x,y) end;
Procedure ClrEol;far; begin Io^.ClrEol end;

var a:longint;

begin
a:=memavail;

UName := rtrim(UpCaseStr (Paramstr(1) + ' ' + Paramstr(2)));

Io := New (pModemCrtObj,Init(ComPort,UsingModem,[Local,Remote]));

Data   := New (pbTreeObj,Init('HAH.DAT',Sizeof(DataRecType)));

with Io^ do
 begin
 setwrite([local]);
 textcolor(lightred);
 Writeln('Successfully Initialized FOSSIL Driver');
 textcolor(cyan);
 writeln(Io^.id);
 Setwrite([local,remote]);
 end;

{
repeat until Io^.atcommand('ATS0=1');}

system.write('ok');

repeat until Io^.cd;

Io^.delay(3000);

Io^.write('.....');
Io^.flush;

Io^.setparams(2400,8,'N',1);

Io^.killin;

Io^.ClrScr;

New (Rec);
fillchar(rec^,sizeof(rec^),#0);

Found := Data^.FindData (UName, Rec^);

If Not Found then
  begin
  Io^.Writeln('');
  Io^.Writeln('Processing New Record');
  Rec^.Quest := '';
  Rec^.FColour := '';
  end;

Editor := New(pLineEditMgrObj,Init(White,Blue,cyan,21,green,
       true,[esc,up,down,tab,enter],
       Write,MoveX,WhereX,TextColor,TextBackground,ReadKey,GotoXY,ClrEol,
       'Are All Fields Correct?',24,lightgray));

Io^.textbackground(0);
Io^.clrscr;
Io^.gotoxy(1,1);
textcolor(lightred);

Io^.write(' Updating fields: ');
Io^.textcolor(magenta);
Io^.write(casestr(uname));

editor^.add(1,3,50,Rec^.Quest,[ins],'Your Quest');
editor^.add(1,4,15,Rec^.FColour,[ins],'Your Favourite Colour');
editor^.run;

rec^.quest:=editor^.out;
rec^.FColour:=editor^.out;

Io^.textcolor(cyan);
Io^.textbackground(black);
Io^.gotoxy(1,6);

if Found then
  begin
  if Data^.Update(UName,Rec^) then
    Io^.writeln('ok')
  else
    Io^.writeln('damn!')
  end
else
  begin
  if Data^.Add(UName,Rec^) then
    Io^.writeln('ok')
  else
    Io^.writeln('damn!')
  end;

dispose(editor,done);



Dispose(Data);
Dispose(Io,Done(cold,hang));
{dispose(rec);}

end.
