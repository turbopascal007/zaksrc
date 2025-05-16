Program Heil;
{$F+,X+,O-,R+,S+,G-,N-,E-}
{$M $8000,$4000,$A0000}
Uses ExitErr,bTree,ModemCrt,EdlMgr,EditLine,IBSelect, Etc;

Const DataFileName = 'REGISTRY.DAT';

Type DataRecType = record
        RealName : String[25];
        Age      : String[5];
        Hob      : string[70];
        Phys     : string[70];
        movie    : string[50];
        food     : string[50];
        Comp     : string[40];
        Quest    : string[50];
        Colour   : string[20];
        end;

Var ComPort : Byte; {1 or 2}
    UsingModem: boolean;

    UName : String[25];
    Io    : pModemCrtObj;
    Data  : pbTreeObj;
    Editor: pLineEditMgrObj;
    Rec   : ^DataRecType;
    ansi  : boolean;
    Found : Boolean;

procedure Write(s:string);far; begin Io^.write(s) end;
procedure MoveX(x:integer);far; begin Io^.MoveRelX(x) end;
Function  WhereX:byte; far; begin wherex:=Io^.Wherex end;
Procedure TextColor(c:byte);far; begin Io^.TextColor(c) end;
Procedure TextBackground(c:byte);far; begin Io^.TextBackground(c) end;
Function  ReadKey(var extend:char):char;far; begin readkey := Io^.Readkey(extend) end;
Procedure GotoXY(x,y:byte); far; begin Io^.gotoxy(x,y) end;
Procedure ClrEol;far; begin Io^.ClrEol end;

Procedure Brag;
 begin
 if ansi then Io^.ClrScr;
 if ansi then io^.textbackground(black);


 if ansi then io^.textcolor(blue);

 io^.write (' 靈컴컴');

 if ansi then io^.textcolor(white);io^.write(' Registry');
 if ansi then io^.textcolor(cyan);

 io^.write( ' (c) copyright 1992 by Zak Smith, All Rights Reserved');

 if ansi then io^.textcolor(blue);
 io^.writeln(' 컴컴캠');

 io^.write (' 聃컴컴');

 if ansi then io^.textcolor(lightgray);

 io^.write(' All Programming by Zak Smith  --  WWIV consulting by Jon Heil');

 if ansi then io^.textcolor(blue);

 io^.writeln(' 컴컴캭');

 end;

Procedure Parse;
 var s:string;
     w:integer;
     f:text;
 begin

 {
  user name .. 2
  com port = 1
  kb .. 20
 }
 assign(f,'chain.txt');
 reset(f);

 readln(f,s);
 readln(f,s);
 uname := rtrim(ltrim(upcasestr(s)));

 for w:=1 to 13 do readln(f,s);

 for w:=1 to 5 do readln(f,s);
 usingmodem := not( s='KB');

 if not usingmodem then ansi:=true;

 close(f);

 if paramcount=0 then begin
  system.writeln('REGISTRY CommPortNumber');
  halt end
 else comport:=toint(paramstr(1));

 end;

Procedure SetupObjects;
 begin
 Io := New (pModemCrtObj,Init(ComPort,UsingModem,[Local,Remote]));
 Data   := New (pbTreeObj,Init(DataFileName,Sizeof(DataRecType)));
 with Io^ do
  begin
  setwrite([local]);
  textcolor(lightred);
  Writeln('Successfully Initialized FOSSIL Driver');
  textcolor(cyan);
  writeln(Io^.id);
  Setwrite([local,remote]);
  end;
 New (Rec);
 fillchar(rec^,sizeof(rec^),#0);
 end;

Procedure Edit;
 begin
 if ansi then Io^.ClrScr;
 Editor := New(pLineEditMgrObj,Init(White,Blue,cyan,10,green,
       ansi,[esc,up,down,tab,enter],
       Write,MoveX,WhereX,TextColor,TextBackground,ReadKey,GotoXY,ClrEol,
       'Are All Fields Correct?',24,lightgray));

 if ansi then Io^.textbackground(0);

 Io^.write(' Updating fields: ');
 if ansi then Io^.textcolor(magenta);
 Io^.write(casestr(uname));

 {
        RealName : String[25];
        Age      : String[5]
        Hob      : string[50];
        Phys     : string[50];
        movie    : string[50];
        food     : string[50];
        Comp     : string[40];
        Quest    : string[50];
        Colour   : string[20];
 }

 editor^.add(1, 3,25,Rec^.Realname,[ins,caps],'Real Name');
 editor^.add(1, 4, 5,Rec^.Age,[ins],'Age');
 editor^.add(1, 5,50,rec^.hob,[ins],'Hobbies');
 editor^.add(1, 6,50,rec^.phys,[ins],'Physical');
 editor^.add(1, 7,50,rec^.movie,[ins],'Movie');
 editor^.add(1, 8,50,rec^.food,[ins],'Food');
 editor^.add(1, 9,50,rec^.comp,[ins],'Computer');
 editor^.add(1,10,50,rec^.quest,[ins],'Quest');
 editor^.add(1,11,20,rec^.colour,[ins],'Colour');

 editor^.run;

 with rec^ do begin
  realname:=editor^.out;
  age     :=editor^.out;
  hob     :=editor^.out;
  phys    :=editor^.out;
  movie   :=editor^.out;
  food    :=editor^.out;
  comp    :=editor^.out;
  quest   :=editor^.out;
  colour  :=editor^.out;
 end;

 dispose(editor,done);
 editor:=nil;

if ansi then begin
    Io^.textcolor(cyan);
    Io^.textbackground(black);
    Io^.gotoxy(1,6) end;

 if Found then Data^.Update(UName,Rec^) else Data^.Add(UName,Rec^);

 if ansi then io^.clrscr;

 end;

Procedure Show( u:string );
 var d:datarectype;
     k,e:char;
 begin
 if ansi then io^.textbackground(black);

 if data^.finddata( u , d ) then
  begin

  if ansi then io^.clrscr;
  if ansi then io^.textcolor(lightgray);
  if not ansi then begin io^.writeln(''); io^.writeln('') end;

  io^.writeln(' Info on: '+casestr(u));
  io^.writeln ('') ;

  with io^ do begin

  if ansi then textcolor(cyan); write('Real Name: ');
  if ansi then textcolor(white);writeln(d.realname);

  if ansi then textcolor(cyan);write('      Age: ');
  if ansi then textcolor(white);writeln(d.age);

  if ansi then textcolor(cyan);write('  Hobbies: ');
  if ansi then textcolor(white);writeln(d.hob);

  if ansi then textcolor(cyan);write(' Physical: ');
  if ansi then textcolor(white);writeln(d.phys);

  if ansi then textcolor(cyan);write('    Movie: ');
  if ansi then textcolor(white);writeln(d.movie);

  if ansi then textcolor(cyan);write('     Food: ');
  if ansi then textcolor(white);writeln(d.food);

  if ansi then textcolor(cyan);write('   `puter: ');
  if ansi then textcolor(white);writeln(d.comp);

  if ansi then textcolor(cyan);write('    Quest: ');
  if ansi then textcolor(white);writeln(d.quest);

  if ansi then textcolor(cyan);write('   Colour: ');
  if ansi then textcolor(white);writeln(d.colour);

  writeln ( '' );
   end;

  end
 else begin
   io^.writeln(' Could not locate '+casestr(u));
   end;
 end;

Procedure NewRecord;
 begin
 Io^.Writeln('');
 Io^.Writeln('Processing New Record');

 FillChar(rec^,sizeof(rec^),0);

 Edit;

 end;

Procedure ViewElse;
 var le : lineeditobj;
     vun: string[25];
     var k,e:char;
 begin
 io^.writeln ( '' );
 io^.write(' Who? ');
 le.init( 0, 0, 25, white, blue, cyan, ansi, '',
        [ins,caps],[enter],write,movex,wherex,textcolor,textbackground,readkey,
        gotoxy,clreol,'User Name: ',14,green);
 le.edit;
 io^.writeln( '' );
 io^.writeln( '' );

 vun:=rtrim(ltrim(upcasestr(le.answer)));
 le.done;

 Show ( vun );

 if ansi then io^.textcolor(red);

 io^.write('[hit a key]');

 k:=readkey(e);

 io^.writeln ( '' );

 end;

Function StepThrough(k:keytype;var data):boolean;far;
 var ib:pIBSelObj;
     t:byte;
 begin
 ib:=new(pIBSelObj,Init(white,blue,cyan,'Continue Quit',
    2,ansi,write,movex,textcolor,textbackground,readkey));


 Show ( upcasestr(ltrim(rtrim(k))) );

 io^.writeln ( '' );

 stepthrough := ib^.run=1;

 dispose(ib,done);

 end;

Function ShowOneName(k:keytype;var data):boolean;far;
 begin
 io^.writeln(casestr(k));
 ShowOneName := True;
 end;


procedure Menu;
 var k,e:char;
     d:boolean;
     ib:pIbSelObj;

 begin


 ib:=new(pIBSelObj,Init(white,blue,cyan,'View Step List Edit Quit',
       5,ansi,write,movex,textcolor,textbackground,readkey));

 d:=false;
 repeat begin
 if ansi then io^.clrscr;
 io^.writeln ( '' );
 brag;

 if ansi then io^.textcolor(cyan);
 io^.writeln ( '' );


 if ansi then io^.textcolor(red);
 io^.writeln ( '컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴' );

 if ansi then io^.textcolor(cyan);

 io^.writeln ( ' View Someone else''s registry' );
 io^.writeln ( ' Step through all registries');
 io^.writeln ( ' List all names with registries assigned' );
 io^.writeln ( ' Edit your own' );
 io^.writeln ( ' Quit this damned program ' );
 if ansi then io^.textcolor(red);
 io^.writeln ( '컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴' );
 io^.writeln ( '' );

 case ib^.run of

  1: ViewElse;
  2: begin
     io^.writeln ( '' );
     data^.showall(StepThrough);
     io^.writeln ( '' );
     end;
  4: Edit;
  3: begin
       io^.writeln ( '' );
       io^.writeln ( '' );
       if ansi then io^.textcolor(yellow);
       io^.writeln ( 'These names have registries assigned ...');
       if ansi then io^.textcolor(white);
       Data^.ShowAll(ShowOneName);
       io^.writeln ( '' );

       if ansi then textcolor(red);

       io^.write('[smash a key]');

       k:=readkey(e);

       io^.writeln ( '' );

       end;
  5: d:=true;
  end;

 end until d;

 dispose(ib,done);

 io^.writeln ( '' );
 io^.writeln ( '' );
 if ansi then io^.textcolor(white);
 io^.write('Registry');
 if ansi then textcolor(cyan);
 io^.writeln(' is a freeware product.');
 if ansi then io^.textcolor(red);
 io^.writeln ( '컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�' );
 if ansi then textcolor(cyan);
 io^.writeln ( ' Tired of that old interface?  This chunk of software has an interface much ');
 io^.writeln ( ' like that of the Searchlight BBS System written by Frank LaRosa. [end plug]');
 if ansi then io^.textcolor(red);
 io^.writeln ( '컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�' );

 if ansi then io^.textcolor(blue);
 io^.writeln ( ' Returning control to system .. ');


 end;


begin
Parse;

SetupObjects;

Io^.killin;

if usingmodem then ansi:=io^.detectansi else ansi:=true;

io^.killin;

Found := Data^.FindData (Uname, Rec^);

If Not Found then NewRecord;

Menu;

Dispose(Data);
Dispose(Io,Done(Hot,NoHang));
dispose(Rec);

end.
