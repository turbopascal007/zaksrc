Program SearchlightCallBackVerifier;

{$F+}

Uses ExitErr,Crt,Dos,SlfHigh,SlfLow,ModemCrt,EdLMgr,EditLine,bTree,Etc;

Const PhDataFileName = 'SLCBV.DAT'; { bTree }
      RejectFileName = 'SLCBV.BAD'; { text }
      LogFileName    = 'SLCBV.LOG'; { text }

Type PhDataType = record
      UserName: String[25];
      end;

Var User      : UserType;
    Io        : pModemCrtObj;
    PhDat     : pbTreeObj;
    PhNum     : string[25];

procedure Write(s:string);far; begin Io^.write(s) end;
procedure MoveX(x:integer);far; begin Io^.MoveRelX(x) end;
Function  WhereX:byte; far; begin wherex:=Io^.Wherex end;
Procedure TextColor(c:byte);far; begin Io^.TextColor(c) end;
Procedure TextBackground(c:byte);far; begin Io^.TextBackground(c) end;
Function  ReadKey(var extend:char):char;far; begin readkey := Io^.Readkey(extend) end;
Procedure GotoXY(x,y:byte); far; begin Io^.gotoxy(x,y) end;
Procedure ClrEol;far; begin Io^.ClrEol end;

Procedure SetupObjects;
 begin
 Io := New (pModemCrtObj,Init(cfg.comport,Cfg.rsActive,[Local,Remote]));
 PhDat := New (pbTreeObj,Init(PhDataFileName,Sizeof(PhDataType)));
 with Io^ do
  begin
  setwrite([local]);
  textcolor(lightred);
  Writeln('Successfully Initialized FOSSIL Driver');
  textcolor(cyan);
  writeln(Io^.id);
  Setwrite([local,remote]);
  end;
 end;

Procedure GetPhoneNumber;
 var area:string[3];
    pre :string[3];
    ext :string[4];
    editor: plineeditmgrobj;

 Function Correct:boolean;
   var k,d:char;
   begin
   if cfg.ansi then io^.moverely(-11);

   io^.writeln ( '' );
   io^.writeln ( '(' + area + ') ' + pre + '-' + ext );
   io^.write ( ' Is this correct? ' );

   repeat k:=upcase(io^.readkey(d)) until k in ['Y','N'];

   write(k);

   Correct := k = 'Y';

   end;

 begin
 io^.writeln('Model: (aaa) ppp-eeee');
 Io^.writeln(' Enter your phone number');

 repeat begin
   Editor := New(pLineEditMgrObj,Init(White,Blue,cyan,30,green,
       Cfg.ansi,[esc,up,down,tab,enter],
       Write,MoveX,WhereX,TextColor,TextBackground,ReadKey,GotoXY,ClrEol,
       'Are All Fields Correct?',24,lightgray));

   editor^.add(1,10,3,'',[ins,caps],'Area Code (aaa part)');
   editor^.add(1,11,3,'',[ins],'Prefix (ppp part)');
   editor^.add(1,12,4,'',[ins],'Postfix (eeee part)');
   editor^.run;
   area := editor^.out;
   pre  := editor^.out;
   ext  := editor^.out;
   dispose(editor,done);Editor:=nil; end
 until Correct;

 end;



begin

Init_Config( '' , Closed );

User_Info ( Cfg.CurrUser , User );

SetupObjects;

Io^.killin;
Io^.ClrScr;

io^.writeln( 'Welcome to the Searchlight Call-Back Verifier!' );
io^.writeln( '' );
io^.writeln( '' );
io^.writeln( 'This program allows on-line validation.  It will call the user back' );
io^.writeln( 'and then the user will enter their BBS password.  It everything goes');
io^.writeln( 'ok, the user will be granted validated access');
io^.writeln( '' );

GetPhoneNumber;

{ add code here :-) }



Dispose(Io,Done(Cold,NoHang));
Dispose(PhDat,done);

end.
