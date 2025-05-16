Program Heil;
{$F+,X+,O-,R+,S+,G-,N-,E-,I+}
{$M $8000,$4000,$A0000}
Uses ExitErr, bTree, ModemCrt, EdlMgr, EditLine, IBSelect, Etc;

Const DataFileName = 'REGISTRY.DAT';
  SysStrSpec   = 'REGISTRY.SYS';
  NumOfMsgs    = 50;
  
  NoHack : LongInt = 0;
  
Type MsgStrType = Record
                    t : String [80];
                  End;
  
Type MsgType = Array [1..NumOfMsgs] Of
  ^MsgStrType;
  
Const LengthOfStr = 1300;
Type MsgChckArray = Array [1..LengthOfStr] Of
  Byte;
  
Type DataRecType = Record
                     RealName : String [25];
                     Age      : String [5];
                     Hob      : String [70];
                     Phys     : String [70];
                     movie    : String [50];
                     food     : String [50];
                     Comp     : String [40];
                     Quest    : String [50];
                     Colour   : String [20];
                   End;
  
Var M       : ^MsgType;
  ComPort : Byte; {1 or 2}
  UsingModem : Boolean;
  
  UName : String [25];
  Io    : pModemCrtObj;
  Data  : pbTreeObj;
  Editor : pLineEditMgrObj;
  Rec   : ^DataRecType;
  ansi  : Boolean;
  Found : Boolean;
  
Procedure Write (s : String);
  far;
Begin
  Io^.Write (s) End;
Procedure MoveX (x : Integer);
  far;
Begin
  Io^.MoveRelX (x) End;
Function  WhereX : Byte;
far;
Begin
  WhereX := Io^.WhereX End;
Procedure TextColor (c : Byte);
  far;
Begin
  Io^.TextColor (c) End;
Procedure TextBackground (c : Byte);
  far;
Begin
  Io^.TextBackground (c) End;
Function  ReadKey (Var extend : Char) : Char;
  far;
Begin
  ReadKey := Io^.ReadKey (extend) End;
Procedure GotoXY (x, y : Byte);
  far;
Begin
  Io^.GotoXY (x, y) End;
Procedure ClrEOL;
  far;
Begin
  Io^.ClrEOL End;

Procedure CheckForHack (ag : LongInt);
Var
  a  : MsgChckArray;
  i  : Word;
  j : Byte;
Begin
  i := 1;
  For j := 1 To NumOfMsgs Do
      Begin
      Move ( mem [Seg (M^ [j]^.t) : Ofs (M^ [j]^.t) + 1], a [i], Length (M^ [j]^.t) );
      Inc (i, Length (M^ [j]^.t) );
      End;
  
  If Not (CRC32Array (@a [1], i - 1) = ag) Then
     Begin
     WriteLn ('Program Illegally Modified!');
     Halt;
     End;
  
End;


Procedure LoadSysStr;
Var f         : File;
  CurStrNum : Word;
  NumOfStr  : Word;
  CurLen    : Byte;
  bffr      : Array [0..255] Of
  Char;
  CRCVal    : LongInt;
Begin
  New (M);
  {$I-}
  Assign (f, SysStrSpec);
  Reset (f, 1);
  {$I+}
  
  If Not (IOResult = 0) Then
     Begin
     system.WriteLn ('Cannot find REGISTRY.SYS');
     Halt;
     End;
  
  BlockRead (f, CRCVal, SizeOf (CRCVal) );
  
  BlockRead (f, NumOfStr, SizeOf (NumOfStr) );
  For CurStrNum := 1 To NumOfStr Do
      Begin
      BlockRead (f, CurLen, 1);
      Seek (f, FilePos (f) - 1);
      BlockRead (f, bffr, CurLen + 1);
      GetMem (M^ [CurStrNum], CurLen + 1);
      Move (bffr, M^ [CurStrNum]^.t, CurLen + 1);
      End;
  Close (f);
  
  CheckForHack (CRCVal);
  
End;


Procedure Brag;
Begin
  If ansi Then
     Io^.ClrScr;
  If ansi Then
     Io^.TextBackground (black);
  
  
  If ansi Then
     Io^.TextColor (blue);
  
  Io^.Write (M^ [1]^.t);
  
  If ansi Then
     Io^.TextColor (white);
  Io^.Write (M^ [2]^.t);
  If ansi Then
     Io^.TextColor (cyan);
  
  Io^.Write (M^ [3]^.t);
  
  If ansi Then
     Io^.TextColor (blue);
  Io^.WriteLn (M^ [4]^.t);
  
  Io^.Write (M^ [5]^.t);
  
  If ansi Then
     Io^.TextColor (lightgray);
  
  Io^.Write (M^ [6]^.t);
  
  If ansi Then
     Io^.TextColor (blue);
  
  Io^.WriteLn (M^ [7]^.t);
  
End;

Procedure Parse;
Var s : String;
  w : Integer;
  f : Text;
Begin
  
  {
  user name .. 2
  com port = 1
  kb .. 20
 }
  
  {$I-}
  Assign (f, 'chain.txt');
  Reset (f);
  {$I+}
  
  If Not (IOResult = 0) Then
     Begin
     system.WriteLn (M^ [50]^.t);
     Halt End;
  
  ReadLn (f, s);
  ReadLn (f, s);
  UName := rtrim (ltrim (upcasestr (s) ) );
  
  For w := 1 To 13 Do
      ReadLn (f, s);
  
  For w := 1 To 5 Do
      ReadLn (f, s);
  UsingModem := Not ( s = 'KB');
  
  If Not UsingModem Then
     ansi := True;
  
  Close (f);
  
  If ParamCount = 0 Then
     Begin
     system.WriteLn ('REGISTRY CommPortNumber');
     Halt End
  Else
     ComPort := toint (ParamStr (1) );
  
End;

Procedure SetupObjects;
Begin
  Io := New (pModemCrtObj, Init (ComPort, UsingModem, [Local, Remote]) );
  Data   := New (pbTreeObj, Init (DataFileName, SizeOf (DataRecType) ) );
  With Io^ Do
       Begin
       setwrite ( [Local]);
       TextColor (lightred);
       WriteLn (M^ [8]^.t);
       TextColor (cyan);
       WriteLn (Io^.id);
       setwrite ( [Local, Remote]);
       End;
  New (Rec);
  FillChar (Rec^, SizeOf (Rec^), #0);
End;

Procedure Edit;
Begin
  If ansi Then
     Io^.ClrScr;
  Editor := New (pLineEditMgrObj, Init (white, blue, cyan, 10, green,
  ansi, [esc, up, down, tab, enter],
  Write, MoveX, WhereX, TextColor, TextBackground, ReadKey, GotoXY, ClrEOL,
  'Are All Fields Correct?', 24, lightgray) );
  
  If ansi Then
     Io^.TextBackground (0);
  
  Io^.Write (M^ [9]^.t);
  If ansi Then
     Io^.TextColor (magenta);
  Io^.Write (casestr (UName) );
  
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
  
  Editor^.add (1, 3, 25, Rec^.RealName, [ins, caps], M^ [10]^.t);
  Editor^.add (1, 4, 5, Rec^.Age, [ins], M^ [11]^.t);
  Editor^.add (1, 5, 50, Rec^.Hob, [ins], M^ [12]^.t);
  Editor^.add (1, 6, 50, Rec^.Phys, [ins], M^ [13]^.t);
  Editor^.add (1, 7, 50, Rec^.movie, [ins], M^ [14]^.t);
  Editor^.add (1, 8, 50, Rec^.food, [ins], M^ [15]^.t);
  Editor^.add (1, 9, 50, Rec^.Comp, [ins], M^ [16]^.t);
  Editor^.add (1, 10, 50, Rec^.Quest, [ins], M^ [17]^.t);
  Editor^.add (1, 11, 20, Rec^.Colour, [ins], M^ [18]^.t);
  
  Editor^.run;
  
  With Rec^ Do
       Begin
       RealName := Editor^.out;
       Age     := Editor^.out;
       Hob     := Editor^.out;
       Phys    := Editor^.out;
       movie   := Editor^.out;
       food    := Editor^.out;
       Comp    := Editor^.out;
       Quest   := Editor^.out;
       Colour  := Editor^.out;
       End;
  
  Dispose (Editor, done);
  Editor := Nil;
  
  If ansi Then
     Begin
     Io^.TextColor (cyan);
     Io^.TextBackground (black);
     Io^.GotoXY (1, 6)
     End;
  
  If Found Then
     Data^.Update (UName, Rec^) Else
     Data^.add (UName, Rec^);
  
  If ansi Then
     Io^.ClrScr;
  
End;

Procedure Show ( u : String );
Var d : DataRecType;
  k, e : Char;
Begin
  If ansi Then
     Io^.TextBackground (black);
  
  If Data^.finddata ( u , d ) Then
     Begin
     
     If ansi Then
        Io^.ClrScr;
     If ansi Then
        Io^.TextColor (lightgray);
     If Not ansi Then
        Begin
        Io^.WriteLn ('');
        Io^.WriteLn ('') End;
     
     Io^.WriteLn (M^ [19]^.t + casestr (u) );
     Io^.WriteLn ('') ;
     
     With Io^ Do
          Begin
          
          If ansi Then
             TextColor (cyan);
          Write (M^ [20]^.t);
          If ansi Then
             TextColor (white);
          WriteLn (d.RealName);
          
          If ansi Then
             TextColor (cyan);
          Write (M^ [21]^.t);
          If ansi Then
             TextColor (white);
          WriteLn (d.Age);
          
          If ansi Then
             TextColor (cyan);
          Write (M^ [22]^.t);
          If ansi Then
             TextColor (white);
          WriteLn (d.Hob);
          
          If ansi Then
             TextColor (cyan);
          Write (M^ [23]^.t);
          If ansi Then
             TextColor (white);
          WriteLn (d.Phys);
          
          If ansi Then
             TextColor (cyan);
          Write (M^ [24]^.t);
          If ansi Then
             TextColor (white);
          WriteLn (d.movie);
          
          If ansi Then
             TextColor (cyan);
          Write (M^ [25]^.t);
          If ansi Then
             TextColor (white);
          WriteLn (d.food);
          
          If ansi Then
             TextColor (cyan);
          Write (M^ [26]^.t);
          If ansi Then
             TextColor (white);
          WriteLn (d.Comp);
          
          If ansi Then
             TextColor (cyan);
          Write (M^ [27]^.t);
          If ansi Then
             TextColor (white);
          WriteLn (d.Quest);
          
          If ansi Then
             TextColor (cyan);
          Write (M^ [28]^.t);
          If ansi Then
             TextColor (white);
          WriteLn (d.Colour);
          
          WriteLn ( '' );
          End;
     
     End
  Else
     Begin
     Io^.WriteLn (M^ [29]^.t + casestr (u) );
     End;
End;

Procedure NewRecord;
Begin
  Io^.WriteLn ('');
  Io^.WriteLn (M^ [30]^.t);
  
  FillChar (Rec^, SizeOf (Rec^), 0);
  
  Edit;
  
End;

Procedure ViewElse;
Var le : lineeditobj;
  vun : String [25];
Var k, e : Char;
Begin
  Io^.WriteLn ( '' );
  Io^.Write (M^ [31]^.t);
  le.Init ( 0, 0, 25, white, blue, cyan, ansi, '',
  [ins, caps], [enter], Write, MoveX, WhereX, TextColor, TextBackground, ReadKey,
  GotoXY, ClrEOL, 'User Name: ', 14, green);
  le.Edit;
  Io^.WriteLn ( '' );
  Io^.WriteLn ( '' );
  
  vun := rtrim (ltrim (upcasestr (le.answer) ) );
  le.done;
  
  Show ( vun );
  
  If ansi Then
     Io^.TextColor (red);
  
  Io^.Write (M^ [32]^.t);
  
  k := ReadKey (e);
  
  Io^.WriteLn ( '' );
  
End;

Function StepThrough (k : keytype;
Var Data) : Boolean;
  far;
Var ib : pIBSelObj;
  t : Byte;
Begin
  ib := New (pIBSelObj, Init (white, blue, cyan, 'Continue Quit',
  2, ansi, Write, MoveX, TextColor, TextBackground, ReadKey) );
  
  
  Show ( upcasestr (ltrim (rtrim (k) ) ) );
  
  Io^.WriteLn ( '' );
  
  StepThrough := ib^.run = 1;
  
  Dispose (ib, done);
  
End;

Function ShowOneName (k : keytype;
Var Data) : Boolean;
  far;
Begin
  Io^.WriteLn (casestr (k) );
  ShowOneName := True;
End;

Procedure Menu;
Var k, e : Char;
  d : Boolean;
  ib : pIBSelObj;
  
Begin
  
  ib := New (pIBSelObj, Init (white, blue, cyan, M^ [33]^.t,
  5, ansi, Write, MoveX, TextColor, TextBackground, ReadKey) );
  
  d := False;
  Repeat
    Begin
    If ansi Then
       Io^.ClrScr;
    Io^.WriteLn ( '' );
    Brag;
    
    If ansi Then
       Io^.TextColor (cyan);
    Io^.WriteLn ( '' );
    
    
    If ansi Then
       Io^.TextColor (red);
    Io^.WriteLn (M^ [34]^.t);
    
    If ansi Then
       Io^.TextColor (cyan);
    
    Io^.WriteLn ( M^ [35]^.t);
    Io^.WriteLn ( M^ [36]^.t);
    Io^.WriteLn ( M^ [37]^.t);
    Io^.WriteLn ( M^ [38]^.t);
    Io^.WriteLn ( M^ [39]^.t);
    If ansi Then
       Io^.TextColor (red);
    Io^.WriteLn ( M^ [40]^.t);
    Io^.WriteLn ( '' );
    
    Case ib^.run Of
         
         1 : ViewElse;
         2 : Begin
         Io^.WriteLn ( '' );
         Data^.showall (StepThrough);
         Io^.WriteLn ( '' );
         End;
         4 : Edit;
         3 : Begin
         Io^.WriteLn ( '' );
         Io^.WriteLn ( '' );
         If ansi Then
            Io^.TextColor (yellow);
         Io^.WriteLn ( M^ [41]^.t );
         If ansi Then
            Io^.TextColor (white);
         Data^.showall (ShowOneName);
         Io^.WriteLn ( '' );
         
         If ansi Then
            TextColor (red);
         
         Io^.Write (M^ [42]^.t);
         
         k := ReadKey (e);
         
         Io^.WriteLn ( '' );
         
         End;
         5 : d := True;
    End;
    
    End Until d;
  
  Dispose (ib, done);
  
  Io^.WriteLn ( '' );
  Io^.WriteLn ( '' );
  If ansi Then
     Io^.TextColor (white);
  
  Io^.Write (M^ [43]^.t);
  
  If ansi Then
     TextColor (cyan);
  
  Io^.WriteLn (M^ [44]^.t);
  
  If ansi Then
     Io^.TextColor (red);
  Io^.WriteLn ( M^ [45]^.t );
  If ansi Then
     TextColor (cyan);
  Io^.WriteLn ( M^ [46]^.t);
  Io^.WriteLn ( M^ [47]^.t );
  If ansi Then
     Io^.TextColor (red);
  Io^.WriteLn ( M^ [48]^.t );
  
  If ansi Then
     Io^.TextColor (blue);
  Io^.WriteLn ( M^ [49]^.t );
  
  
End;

Begin
  
  LoadSysStr;
  
  Parse;
  
  SetupObjects;
  
  Io^.killin;
  
  If UsingModem Then
     ansi := Io^.detectansi Else
     ansi := True;
  
  Io^.killin;
  
  Found := Data^.finddata (UName, Rec^);
  
  If Not Found Then
     NewRecord;
  
  Menu;
  
  Dispose (Data);
  Dispose (Io, done (Hot, NoHang) );
  Dispose (Rec);
  
End.
