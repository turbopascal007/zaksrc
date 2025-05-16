Program Heil;
{$F+,X+,O-,R+,S+,G-,N-,E-,I+}
{$M $8000,$4000,$A0000}
Uses ExitErr,bTree,ModemCrt,EdlMgr,EditLine,IBSelect, Etc;

Const DataFileName = 'REGISTRY.DAT';
      SysStrSpec   = 'REGISTRY.SYS';
      NumOfMsgs    = 50;

Type MsgStrType = record
       t:string[80];
       end;

Type MsgType = Array[1..NumOfMsgs] of ^MsgStrType;

Const LengthOfStr = 1300;
Type MsgChckArray = array[1..lengthofstr] of byte;

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

Var M       : ^MsgType;
    ComPort : Byte; {1 or 2}
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

procedure CheckForHack(ag:longint);
    var
      a  :msgchckarray;
      i  :word;
      j:byte;
  begin
  i:=1;
  for j:=1 to numofmsgs do
      begin
      move( mem[seg(m^[j]^.t):ofs(m^[j]^.t)+1],a[i],length(m^[j]^.t));
      inc(i,length(m^[j]^.t));
      end;

  if not(CRC32Array(@a[1],i-1)=ag) then
    begin
    Writeln('Program Illegally Modified!');
    halt;
    end;

  end;


Procedure LoadSysStr;
  var f         :file;
      CurStrNum :word;
      NumOfStr  :word;
      CurLen    :byte;
      bffr      :array[0..255] of char;
      CRCVal    :longint;
  begin
  New(M);
  {$I-}
  Assign(f,SysStrSpec);
  reset(f,1);
  {$I+}

  if not (ioresult=0) then begin
           system.writeln('Cannot find REGISTRY.SYS');
           halt;
           end;

  blockread(f,crcval,sizeof(crcval));

  blockread(f,NumOfStr,sizeof(NumOfStr));
  for CurStrNum:=1 to NumOfStr do
     begin
     blockread(f,curlen,1);
     Seek(f,filepos(f)-1);
     blockread(f,bffr,curlen+1);
     GetMem(M^[CurStrNum],Curlen+1);
     Move(bffr,M^[CurStrNum]^.t,CurLen+1);
     end;
  close(f);
  CheckForHack(crcval);
  end;

Procedure Brag;
 begin
 if ansi then Io^.ClrScr;
 if ansi then io^.textbackground(black);
 if ansi then io^.textcolor(blue);
 io^.write (m^[1]^.t);
 if ansi then io^.textcolor(white);io^.write(m^[2]^.t);
 if ansi then io^.textcolor(cyan);
 io^.write(m^[3]^.t);
 if ansi then io^.textcolor(blue);
 io^.writeln(m^[4]^.t);
 io^.write (m^[5]^.t);
 if ansi then io^.textcolor(lightgray);
 io^.write(m^[6]^.t);
 if ansi then io^.textcolor(blue);
 io^.writeln(m^[7]^.t);
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

 {$I-}
 assign(f,'chain.txt');
 reset(f);
 {$I+}

 if not(ioresult=0) then begin
    system.writeln(m^[50]^.t);
    halt end;

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
  Writeln(m^[8]^.t);
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

 Io^.write(m^[9]^.t);
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

 editor^.add(1, 3,25,Rec^.Realname,[ins,caps],m^[10]^.t);
 editor^.add(1, 4, 5,Rec^.Age,[ins],m^[11]^.t);
 editor^.add(1, 5,50,rec^.hob,[ins],m^[12]^.t);
 editor^.add(1, 6,50,rec^.phys,[ins],m^[13]^.t);
 editor^.add(1, 7,50,rec^.movie,[ins],m^[14]^.t);
 editor^.add(1, 8,50,rec^.food,[ins],m^[15]^.t);
 editor^.add(1, 9,50,rec^.comp,[ins],m^[16]^.t);
 editor^.add(1,10,50,rec^.quest,[ins],m^[17]^.t);
 editor^.add(1,11,20,rec^.colour,[ins],m^[18]^.t);

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

if ansi then
    begin
    Io^.textcolor(cyan);
    Io^.textbackground(black);
    Io^.gotoxy(1,6)
    end;

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

  io^.writeln(m^[19]^.t+casestr(u));
  io^.writeln ('') ;

  with io^ do begin

  if ansi then textcolor(cyan); write(m^[20]^.t);
  if ansi then textcolor(white);writeln(d.realname);

  if ansi then textcolor(cyan);write(m^[21]^.t);
  if ansi then textcolor(white);writeln(d.age);

  if ansi then textcolor(cyan);write(m^[22]^.t);
  if ansi then textcolor(white);writeln(d.hob);

  if ansi then textcolor(cyan);write(m^[23]^.t);
  if ansi then textcolor(white);writeln(d.phys);

  if ansi then textcolor(cyan);write(m^[24]^.t);
  if ansi then textcolor(white);writeln(d.movie);

  if ansi then textcolor(cyan);write(m^[25]^.t);
  if ansi then textcolor(white);writeln(d.food);

  if ansi then textcolor(cyan);write(m^[26]^.t);
  if ansi then textcolor(white);writeln(d.comp);

  if ansi then textcolor(cyan);write(m^[27]^.t);
  if ansi then textcolor(white);writeln(d.quest);

  if ansi then textcolor(cyan);write(m^[28]^.t);
  if ansi then textcolor(white);writeln(d.colour);

  writeln ( '' );
   end;

  end
 else begin
   io^.writeln(m^[29]^.t+casestr(u));
   end;
 end;

Procedure NewRecord;
 begin
 Io^.Writeln('');
 Io^.Writeln(m^[30]^.t);

 FillChar(rec^,sizeof(rec^),0);

 Edit;

 end;

Procedure ViewElse;
 var le : lineeditobj;
     vun: string[25];
     var k,e:char;
 begin
 io^.writeln ( '' );
 io^.write(m^[31]^.t);
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

 io^.write(m^[32]^.t);

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

 ib:=new(pIBSelObj,Init(white,blue,cyan,M^[33]^.t,
       5,ansi,write,movex,textcolor,textbackground,readkey));

 d:=false;
 repeat begin
 if ansi then io^.clrscr;
 io^.writeln ( '' );
 brag;

 if ansi then io^.textcolor(cyan);
 io^.writeln ( '' );


 if ansi then io^.textcolor(red);
 io^.writeln (m^[34]^.t);

 if ansi then io^.textcolor(cyan);

 io^.writeln ( m^[35]^.t);
 io^.writeln ( m^[36]^.t);
 io^.writeln ( m^[37]^.t);
 io^.writeln ( m^[38]^.t);
 io^.writeln ( m^[39]^.t);
 if ansi then io^.textcolor(red);
 io^.writeln ( m^[40]^.t);
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
       io^.writeln ( m^[41]^.t );
       if ansi then io^.textcolor(white);
       Data^.ShowAll(ShowOneName);
       io^.writeln ( '' );

       if ansi then textcolor(red);

       io^.write(m^[42]^.t);

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

 io^.write(m^[43]^.t);

 if ansi then textcolor(cyan);

 io^.writeln(m^[44]^.t);

 if ansi then io^.textcolor(red);
 io^.writeln ( m^[45]^.t );
 if ansi then textcolor(cyan);
 io^.writeln ( m^[46]^.t);
 io^.writeln ( m^[47]^.t );
 if ansi then io^.textcolor(red);
 io^.writeln ( m^[48]^.t );

 if ansi then io^.textcolor(blue);
 io^.writeln ( m^[49]^.t );


 end;

begin

LoadSysStr;

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
