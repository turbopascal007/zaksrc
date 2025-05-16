Program TapeFile; { (C) copyright 1992 by Zak Smith, All Rights Reserved }

{
 NOTE -- This code may be used in your programs AS LONG AS the product
         is freely available.  (That means freeware, for instance)

Setup Notes --

  Uses SLBBS's com support, but ABORT should be set to NONE

Program Notes --

  This program retrieves files from the tape drive and then sends them
  to the user via the DSZ protocol driver.

  first it builds a linked list in the heap of the names of all the files
  in the `DirFileName' directory.  it does this by:
      1)  scanning the quick-index TAPEFILE.IDX  -- if it exists
      2) otherwise it scans the *.SL2 file.

  if the *.SL2 file is updated (more files put on tape), just delete
  tapefile.IDX and it will create a new one.  it exists merely for speed.

  then it lets the user enter a partial filename, a wildcard, or a special
  command.  it parses this line, and then executes the appropriate function.
  when it does any of the scanning for filenames, it just goes right through
  the linked list in ram.

  once the filename is entered, it asks the user if they want to continue,
  then it checks to see if the file exists in the `GenPath' directory,
  meaning it has recently been retrieved by another user.

  if if doesn't exist on disk, it scans the 'VOLUME.x' files to see
  on which tape volume the file exists.

  Then it executes TAPE.  If it was succesful. and TAPE returned an
  errorcode of 0, it then Sends the file. otherwise, it doesn't send the
  file.

Author Notes --

  Originally written by Zak Smith because I had this tape drive and not
  enough hard disk space..

  If you have questions (I wouldn't be surprised) or comments, I am
  reachable the following ways..

  Sysop - Sirius Cybernetics 414-966-3552
  Zak Smith - 1:154/736 @ fido-land
   "    "   - 250:200/736 @ sl_net
  zak.smith@mixcom.com
}

{$X+} { - eXtended Syntax - Allow for functions to act like procedures,
          not returning anything. }

{$B+} { - Complete Boolean Evaluation - Allow functions that aren't just
          functions to be executed. }

{$M 16384,0,81920} { Allow 384k for DSZ.COM and TAPE.EXE }

Uses Dos,Crt,        { standard }
     SlDriv,
     Dates,
     SlFiles, {
                SLFiles is not included, but it contains the low-level
                file routines for SLBBS.  These were `derived' directly
                from the original FILE211.ZIP archive.  It includes the
                latest FILEDEF.REF as well.

                if you have any questions, ask..
              }
     WildChck,
     Ed,
     SwpExec;

Const NumOfVolumes: byte = 2;
      DirFileName = 'OFFLINE';  { NAME of the SLBBS file subboard used for
                                  the offline files.. }
    {$IFNDEF DEBUG}
      GenPath     = 'D:\SLBBS\TAPE\TEMP\';   { change to your liking.. }
      ProgPath    = 'D:\SLBBS\TAPE\';
    {$ELSE}
      GenPath     = 'D:\SLTEST\';            { used for debugging.. }
      ProgPath    = 'D:\SLTEST\';
    {$ENDIF}
Type
    PartialType = (None,OnlyOne,OneOfMany);

    FileListPtr = ^FileListType;
    FileListType = record
     FileName: string[12];
     RecNum  : longint;
     next    : FileListPtr;
     end;

    QuickIndexType = Record
     FileName: string[12];
     RecNum  : longint;{ Record number in the *.SL2 file for QUICK referece }
     end;

Var
    TimeUserEntered: longint;

    logfile : text;

    ExecStr : string;
    MustAsk : boolean;
    another : boolean;
    good    : boolean;
    DlFile  : string;
    Dir     : DirType;
    Setup   : SetupData;
    EnterN  : String;
    User    : UserType;

    ListRoot: FileListPtr;
    PrevFile: FileListPtr;
    CurFile : FileListPtr;
    NextFile: FileListPtr;

   QuickFile: File;

Procedure InitVars;
var h,m,s:word;
  begin
  CurTime(h,m,s);
  TimeUserEntered := SecondsSinceMidnight(h,m,s);

  If ExistFile(Progpath+'TAPEFILE.LOG') then
   begin
   assign(logfile, progpath+'TAPEFILE.LOG');
   append(logfile);
   end
  else
   begin
   assign(logfile, progpath+'TAPEFILE.LOG');
   rewrite(logfile);
   end;

  another:=true;
  DirectVideo:=false;

  UseInsert:=false;  { for line editor routine }
  CapsOn:=false;     { for line editor routine }

  {$IFNDEF DEBUG}
   PathToConfig:='D:\SLBBS\'; { from slfiles.. }
  {$ELSE}
   PathToConfig:='D:\SLTEST\';
  {$ENDIF}

  ListRoot := nil;
  PrevFile:=nil;
  CurFile:=nil;
  nextfile:=nil;

  filemode := 66;
  end;

procedure KillStatusLine;
  var x,y:byte;
  begin
  x:=wherex;y:=wherey;
  if slactive then localonly;
  directvideo := cfg.directvid;
  Window(1,1,80,25);
  gotoxy(1,25);
  textbackground(black);
  clreol;
  gotoxy(x,y);
  directvideo := false;
  if slactive then localandremote;
  end;

procedure InitStatus;
  var x,y: byte;
  begin
  if SlActive then LocalOnly;
  directvideo := cfg.directvid;
  cursoroff;
  x:=wherex;y:=wherey;
  window(1,1,80,25);
  gotoxy(1,25);
  textcolor(white);
  textbackground(blue);
  Write(' User: ',CaseStr(User.Name));
  clreol;
  Gotoxy(34,25);
  Write('TapeFile');
  textbackground(black);
  window(1,1,80,24);
  if y=25 then y:=24;
  gotoxy(x,y);
  clreol;
  CursorOn;
  directvideo := false;
  if SlActive then LocalandRemote;
  end;

function abort:boolean;
   var t:byte;
       a:boolean;
   begin
   a:=false;
   if keypressed then
    begin
    case readkey of
     ' ': a:=true;
     ^C : a:=true;
    end
    end;

   if a then
    begin
    t:=textattr;
    textattr:=$0C;
    write('^C');
    textattr:=t;
    end;

   abort:=a;
   end;

Procedure InitConfig;
  begin
  Open_Config;
  Read_Config;
  end;

Procedure InitSetup;
  Begin
  Open_Setup(SetupDIR);
  Read_Setup_GenHdr;
  Read_Setup_Hdr;
  end;

Procedure FindSetup;
 procedure ClimbSetup(cur:longint); { this is recursive .. this is .. }
  begin
  Read_Setup_Data(cur,Setup);
   case compare(DirFileName, Setup.Name) of
    0: begin
       exit;
       end;
    1: ClimbSetup(setup.leaf.right);
    2: ClimbSetup(setup.leaf.left);
    end;
  end;
  begin
  ClimbSetup(SetupHdr.Root.TreeRoot);
  end;

Procedure OpenDir;
  begin
  Open_Dir(Setup.Path,Setup.Name);
  Read_Dir_GenHdr;
  Read_Dir_Hdr;
  end;

procedure close_log;
 begin
 Close(logfile);
 end;

Procedure Closefiles;
 begin
 Writeln(LogFile, DtTmStamp, ' ',casestr(User.Name),' exited door.');
 writeln;

 Close_User;
 Close_Config;
 Close_Setup;
 Close_Dir;
 Close_Strings;
 Close_log;
 end;

procedure SetupLinkedList;
  var d   :dirtype;
      cnt :longint;

  Procedure Status;
   begin
   if not ANSI then write('.') else
     begin
     gotoxy(24,wherey);
     write(cnt:5, ' files read');
     end;
   end;


  procedure SaveQuick;
    Var QuickIdxRec: QuickIndexType;

    begin
    writeln;
    Write('Please Wait: Quick Index Being Written');

    assign(QuickFile,ProgPath+'TAPEFILE.IDX');
    rewrite(QuickFile,17);

    Seek(QuickFile,0);
    CurFile := ListRoot;
    While CurFile <> Nil do
     begin
     QuickIdxRec.FileName:=CurFile^.Filename;
     QuickIdxRec.RecNum:=CurFile^.RecNum;
     BlockWrite(QuickFile,QuickIdxRec,1);
     CurFile := CurFile^.Next
     end;
    close(QuickFile);
    Writeln(LogFile, DtTmStamp, ' Quick Index Written');
    end;

  Procedure LoadFromQuick;
    var           n:longint;
        QuickIdxRec: QuickIndexType;
    begin
    assign(QuickFile,ProgPath+'TAPEFILE.IDX');
    reset(QuickFile,17);

    for n:= 1 to filesize(QuickFile) do
      begin
      BlockRead(QuickFile,QuickIdxRec,1);

      if ListRoot=Nil then
       begin
       new(CurFile);
       ListRoot := CurFile;
       CurFile^.Next := Nil;
       end
      else
       begin
       PrevFile := CurFile;
       New(CurFile);
       PrevFile^.Next := CurFile;
       CurFile^.Next := Nil;
       end;

     With CurFile^ do
      begin
      FileName := QuickIdxRec.FileName;
      RecNum := QuickIdxRec.RecNum;
      end;

     inc(cnt);
     if (cnt mod 85)=0 then status;
     end;

    if not ANSI then writeln else gotoxy(24,wherey);
     write(cnt:5, ' files read');

    end;

  Procedure ClimbDir(cur:longint);
   var l,r:longint;
   begin
   Read_Dir(cur,d);

   r:=d.leaf.right;
   l:=d.leaf.left;

   if d.leaf.left<>0 then ClimbDir(d.leaf.left);

   if l<>0 then Read_Dir(cur,d);

   if ListRoot=Nil then
     begin
     new(CurFile);
     ListRoot := CurFile;
     CurFile^.Next := Nil;
     end
   else
     begin
     PrevFile := CurFile;
     New(CurFile);
     PrevFile^.Next := CurFile;
     CurFile^.Next := Nil;
     end;

   With CurFile^ do
     begin
     FileName := D.Name;
     RecNum := Cur;
     end;

   inc(cnt);
   if (cnt mod 85)=0 then status;
   if r<>0 then ClimbDir(r);
   end;

  begin
  cnt:=0;
  TextColor(cfg.colorchart[normal]);
  Write('Initializing File List');

  If ExistFile(ProgPath+'TAPEFILE.IDX') then
    LoadFromQuick
  else
   begin
   ClimbDir(DirHdr.Root.TreeRoot);
   if not ANSI then writeln else gotoxy(24,wherey);
     write(cnt:5, ' files read');
   SaveQuick;
   end;

  writeln;
  end;

Procedure GetUserData;
  Begin
  Open_User;
  Read_User_GenHdr;
  Read_User_Hdr;
  Read_User(Cfg.CurrUser,User);
  End;

Procedure BarfExit;
  begin
  CloseFiles;
  LocalOnly;
  writeln;
  writeln(' Carrier Lost');
  writeln;
  localandremote;
  KillStatusLine;
  Halt(1);
  end;

Procedure Pause;
   begin
   TextColor(cfg.colorchart[Special]);
   write('-- more -- ');
      repeat
       if portcheck then
        If Not Carrier_On then
         begin
         Carrier:=false;
         Exit;
         end;
      until keypressed;
   Readkey;
   if not carrier then BarfExit;
   if ansi then begin gotoxy(1,wherey);clreol end
   else writeln;
   end;


Procedure GetFileName(var N:string);
  begin
  TextBackGround(black);
  TextColor(Cfg.ColorChart[HEADCOLOR]);
  writeln;
  writeln;
  Write('You may enter ');
  TextColor(Cfg.ColorChart[SPECIAL]);
  Write('1 ');
  TextColor(Cfg.ColorChart[HEADCOLOR]);
  Write('File name.');Writeln;

  TextColor(Cfg.ColorChart[NORMAL]);
  Write('Press ');
  TextColor(Cfg.ColorChart[ALTCOLOR]);
  Write('F ');

  TextColor(Cfg.ColorChart[NORMAL]);
  Write('for File List, ');
  TextColor(Cfg.ColorChart[ALTCOLOR]);
  Write('? ');
  TextColor(Cfg.ColorChart[NORMAL]);
  write('for Help, ');
  TextColor(Cfg.ColorChart[ALTCOLOR]);
  Write('ENTER ');
  TextColor(Cfg.ColorChart[NORMAL]);
  writeln('when done.');

  writeln;

  TextColor(Cfg.ColorChart[NORMAL]);
  Write('[');
  TextColor(Cfg.ColorChart[SUBCOLOR]);
  Write(DirFileName);
  TextColor(Cfg.ColorChart[NORMAL]);
  Write(']');
  Write(lTab(Length(DirFileName),8));
  Write('  (');
  TextColor(Cfg.ColorChart[SPECIAL]);
  Write(' 0');
  TextColor(Cfg.ColorChart[NORMAL]);
  Write(' Selected) :');

    { Editor Again!  Not included, but should be easy to make ..
          maxlen = 12, etc.. result in `n' }

  Editor(12,n,'',cfg.colorchart[CHATCOLOR],black);

  if not carrier then BarfExit;

  end;

Procedure ProcessFileName(N:string;var DownlFile:String;var g:boolean;var m:boolean);
 function show_file:byte;
  var
      m,d,y: string[2];
      t    : string[4];
      fs   : string[1];
      sf   :byte;


  begin
  sf:=1;
     if (dir.passwd[1]<>0) AND (dir.passwd[2]<>0) AND (dir.passwd[3]<>0) then
     fs := '+' else fs := '';
   str(dir.date.month:2,m);
   str(dir.date.day  :2,d); if d[1]=' 'then d[1] := '0';
   str(dir.date.year :2,y); if y[1]=' 'then y[1] := '0';
   TextColor(Cfg.ColorChart[HeadColor]);

   localonly;
   if (not ansi) and (not(wherex=1)) then
     begin
     localandremote;
     writeln;
     end
   else localandremote;

   if ansi and (not(wherex=1)) then begin
     gotoxy(1,wherey);
     clreol;
     end;

   Write(Dir.Name,lTab(ord(dir.name[0]),12));
   TextColor(cfg.Colorchart[AltColor]);
   Write(' ',dir.length*128/1024:7:1,'k');
   TextColor(Cfg.ColorChart[Normal]);
   Write(dir.times:4,' ',m,'-',d,'-',y,' ');
   textcolor(Cfg.ColorChart[SubColor]);
   writeln(dir.descrip);
   if Dir.EDescrip[1][0] <> #0 then
      begin
      write('         ');writeln(dir.edescrip[1]);
      write('         ');writeln(dir.edescrip[2]);
      writeln;
      inc(sf,3);
      end;
  Show_File:=sf;
  end;


 Function MatchFound: boolean;
   begin
   CurFile := ListRoot;
   While CurFile <> Nil do
    begin
    if N=CurFile^.FileName then
      begin
      MatchFound:=True;
      exit;
      end;
    CurFile := CurFile^.Next
    end;
   MatchFound := False
   end;

 Function PartialName: PartialType;
   var count: word;
   begin
   count:=0;
   CurFile := ListRoot;
   While CurFile <> Nil do
    begin
    if N=Copy(CurFile^.FileName,1,length(N)) then
       Inc(Count);
    CurFile := CurFile^.Next
    end;
   case Count of
     1:  begin
         PartialName:=OnlyOne;
         CurFile := ListRoot;
         While CurFile <> Nil do
          begin
          if N=Copy(CurFile^.FileName,1,length(n)) then exit;
          CurFile := CurFile^.Next
          end;
         end;
     0:  PartialName:=none;
     Else PartialName:=OneOfMany;
     End;
   end;

 Procedure ShowAllPartialMatches;
   var t,l:byte;
   begin
   l:=0;
   CurFile := ListRoot;
   While CurFile <> Nil do
    begin
    if N=Copy(CurFile^.FileName,1,length(N)) then
      begin
      Read_Dir(CurFile^.RecNum,Dir);
      if l+4>=User.scrnsize then begin Pause; l:=0 end;
      t:=Show_File;
      if abort then exit;
      inc(l,t);
      end;
    CurFile := CurFile^.Next
    end;
   end;

  Function WildCard: boolean;
   var i:byte;
   begin
   wildcard := false;
   for i:=1 to length(n) do
    begin
    if (n[i]='?') or (n[i]='*') then begin Wildcard:=true; exit end;
    end;
   end;

  procedure ShowAllWildCardMatches;
   var t,l:byte;

   begin
   l:=0;
   CurFile := ListRoot;
   While CurFile <> Nil do
    begin
    if MatchWC(n,CurFile^.FileName) then
      begin
      read_dir(CurFile^.Recnum,dir);
      if l+4>=User.scrnsize then begin Pause; l:=0 end;
      t:=Show_File;
      if abort then exit;
      inc(l,t);
      end;
    CurFile := CurFile^.Next
    end;

   end;


  Function WildMatch: partialtype;
   var
       i:word;
   begin
   i:=0;
   CurFile := ListRoot;
   While CurFile <> Nil do
    begin
    if MatchWC(n,CurFile^.FileName) then inc(i);
    CurFile := CurFile^.Next
    end;

   case i of
    0: begin
       wildmatch:=none;
       exit
       end;
    1: begin
       wildmatch:=onlyone;
       CurFile := ListRoot;
       While CurFile <> Nil do
         begin
         if MatchWC(n,CurFile^.FileName) then exit;
         CurFile := CurFile^.Next
         end;
       end;
    else wildmatch:=oneofmany;
    end
   end;

  Procedure ShowAllFiles;
   var t,l:byte;
   begin
   l:=0;
   CurFile := ListRoot;
   While CurFile <> Nil do
    begin
      begin
      Read_Dir(CurFile^.RecNum,Dir);
      if l+4>=User.scrnsize then begin Pause; l:=0 end;
      t:=Show_File;
      if abort then exit;
      inc(l,t);
      end;
    CurFile := CurFile^.Next
    end;
   end;

 Procedure ZippyScan;
  var s:string;
  function checkin: boolean;
  begin
  checkin := (pos(s,upcasestr(concat(dir.name,dir.descrip,
         dir.edescrip[1],dir.edescrip[2])))>0);
  end;
   var t,l:byte;
       c: word;
       b: boolean;
   begin
   writeln;
   textcolor(cfg.colorchart[normal]);
   writeln;
   Writeln('Enter Pattern to search for..');
   write('>');

      { Calls a generic line editor routine..
         maximum input length is 50,
         put into `s', no data already in buffer.. }

   Editor(50,s,'',cfg.colorchart[CHATCOLOR],black);

   if ltrim(rtrim(s))='' then exit;
   if not carrier then BarfExit;

   s:=upcasestr(s);
   textcolor(cfg.colorchart[special]);
   writeln;
   writeln('Searching...');

   l:=0;
   c:=0;
   CurFile := ListRoot;
   While CurFile <> Nil do
    begin
      begin
      Read_Dir(CurFile^.RecNum,Dir);
      inc(c);
      if ((c mod 50)=0) or (c=DirHdr.Root.Entries) then
        begin
        if ansi then begin gotoxy(1,wherey);clreol end
        else writeln;
        textcolor(cfg.colorchart[special]);
        Write(c:4,' files searched');
        end;
      if CheckIn then
        begin
        if l+4>=User.scrnsize then begin Pause; l:=0 end;
        t:=Show_File;
        if abort then exit;
        inc(l,t);
        end;
      end;
    CurFile := CurFile^.Next
    end;

   writeln;
   end;

 procedure WideDir;
   var c,l:byte;
   begin
   l:=0;
   c:=0;
   CurFile := ListRoot;
   writeln;
   textcolor(cfg.colorchart[normal]);
   While CurFile <> Nil do
    begin
    Write(CurFile^.filename,lTab(length(CurFile^.filename),13));
    if abort then exit;
    inc(c);
    if c=6 then begin
                writeln;
                c:=0;
                inc(l);
                if l+3>=User.scrnsize then
                  begin
                  Pause;
                  textcolor(cfg.colorchart[normal]);
                  l:=0
                  end;
                end;

    CurFile := CurFile^.Next
    end;
   writeln;
   end;

 Procedure ShowDiskBuffer;
  var fs:searchrec;
      t,l:byte;
      found:boolean;
      rn:longint;

  procedure RecNumOf(var r:longint;var f:boolean);
   begin
   CurFile := ListRoot;
   While CurFile <> Nil do
    begin
    if upcasestr(fs.name)=CurFile^.FileName then
      begin
      f:=True;
      r:=curfile^.recnum;
      exit;
      end;
    CurFile := CurFile^.Next
    end;
   f := False
   end;

  procedure dofile;
   begin
    RecNumOf(rn,found);
    if found then
      begin
      read_dir(rn,dir);
      if l+4>=User.scrnsize then begin Pause; l:=0 end;
      t:=Show_File;
      if abort then exit;
      inc(l,t);
      end;
   end;

  begin
  textcolor(cfg.colorchart[normal]);
  writeln('These files won''t have to be pulled from the tape.');
  writeln;

  t:=0;l:=0;

  findfirst(GenPath+'*.*',AnyFile,fs);
  if doserror=0 then
    begin
    repeat
     begin
     dofile;
     findnext(fs);
     end
    until not (doserror=0);
    end;

  end;


 Procedure ShowHelp;
  begin
  writeln;
  textcolor(cfg.colorchart[normal]);
  writeln('You may enter...');
  writeln('      ...A full length filename');
  writeln('      ...A partial filename (just the first few letters)');
  writeln('      ...A wildcard filespec');
  writeln;
  writeln('In addition, there are several commands you can use..');

  textcolor(cfg.colorchart[headcolor]);write(' F');
  textcolor(cfg.colorchart[normal]);
  writeln(' - Display all files in alphabetical order');

  textcolor(cfg.colorchart[headcolor]);write(' Z');
  textcolor(cfg.colorchart[normal]);
  writeln(' - Perform a Zippy directory scan');

  textcolor(cfg.colorchart[headcolor]);write(' W');
  textcolor(cfg.colorchart[normal]);
  writeln(' - Display a wide directory of files');

  textcolor(cfg.colorchart[headcolor]);write(' S');
  textcolor(cfg.colorchart[normal]);
  writeln(' - Show Files in Disk Buffer');

  end;

  begin
  m:=false;
  g:=true;
  if N='' then
      begin
      g:=false;
      m:=true;
      exit;
      end;
  if N='F' then
      begin
      writeln;
      writeln;
      textbackground(cfg.colorchart[background]);
      textcolor(cfg.colorchart[inverse]);

      { Note SlStr() is a function that returns the string from STRINGS.SYS
        of that index number .. }

      write(SlStr(882));
      textbackground(black);
      writeln;
      ShowAllFiles;
      g:=false;
      m:=false;
      exit;
      end;
  if N='?' then
      begin
      g:=false;
      m:=false;
      ShowHelp;
      exit;
      end;
  if N='Z' then
      begin
      g:=false;
      m:=false;
      ZippyScan;
      Exit;
      end;
  if N='W' then
      begin
      g:=false;
      m:=false;
      writeln;
      WideDir;
      exit;
      end;
  if N='S' then
      begin
      g:=false;
      m:=false;
      writeln;
      ShowDiskBuffer;
      exit;
      end;

  If WildCard then
   begin
   case WildMatch of
    onlyone:
     begin
     Read_Dir(CurFile^.RecNum,Dir);
     If Cfg.Ansi then
      begin
      Gotoxy(22+length(DirFileName),Wherey);
      TextColor(Cfg.ColorChart[HEADCOLOR]);
      Write(CurFile^.FileName,lTab(Length(CurFile^.FileName),12));
      TextColor(Cfg.ColorChart[NORMAL]);
      Write(' - ');
      TextColor(Cfg.ColorChart[SUBCOLOR]);
      if length(Dir.Descrip)>(80-Wherex) then
       writeln(copy(dir.descrip,1,80-wherex))
      else
       writeln(Dir.Descrip);
      end;
     DownlFile:=CurFile^.FileName;
     exit;
     end;
    OneOfMany:
     begin
     TextColor(Cfg.ColorChart[Normal]);
     writeln;
     writeln('There are more than one matches for that wildcard.');
     writeln;
     textbackground(cfg.colorchart[background]);
     textcolor(cfg.colorchart[inverse]);
     write(SlStr(882));
     textbackground(black);write(#0);
     writeln;
     ShowAllWildCardMatches;
     writeln;
     textcolor(cfg.colorchart[normal]);
     DownlFile:='';
     g:=false;
     exit;
     end;
    none: begin
          writeln;
          textcolor(cfg.colorchart[errcolor]);
          writeln(SlStr(876));
          g:=false;
          m:=true;
          exit;
          end;
    end; { case .. }
   end; { if wildcard }

  If MatchFound then
    begin
    Read_Dir(CurFile^.RecNum,Dir);
    If Cfg.Ansi then
     begin
     Gotoxy(22+length(DirFileName),Wherey);
     TextColor(Cfg.ColorChart[HEADCOLOR]);
     Write(CurFile^.FileName,lTab(Length(CurFile^.FileName),12));
     TextColor(Cfg.ColorChart[NORMAL]);
     Write(' - ');
     TextColor(Cfg.ColorChart[SUBCOLOR]);
     if length(Dir.Descrip)>(80-Wherex) then
      writeln(copy(dir.descrip,1,80-wherex))
     else
      writeln(Dir.Descrip);
     end
    else
     begin
     writeln;
     show_File;
     writeln;
     end;
    DownlFile:=CurFile^.FileName;
    exit;
    end;
  case PartialName of
   OnlyOne:
    begin
    Read_Dir(CurFile^.RecNum,Dir);
    If Cfg.Ansi then
     begin
     Gotoxy(22+length(DirFileName),Wherey);
     TextColor(Cfg.ColorChart[HEADCOLOR]);
     Write(CurFile^.FileName,lTab(Length(CurFile^.FileName),12));
     TextColor(Cfg.ColorChart[NORMAL]);
     Write(' - ');
     TextColor(Cfg.ColorChart[SUBCOLOR]);
     if length(Dir.Descrip)>(80-Wherex) then
      writeln(copy(dir.descrip,1,80-wherex))
     else
      writeln(Dir.Descrip);
     end
    else
     begin
     writeln;
     Show_File;
     writeln;
     end;
    DownlFile:=CurFile^.FileName;
    exit;
    end;
   OneOfMany:
    begin
    TextColor(Cfg.ColorChart[Normal]);
    writeln;
    writeln('There are more than one matches for that partial filename');
    writeln;
     textbackground(cfg.colorchart[background]);
     textcolor(cfg.colorchart[inverse]);
     write(SlStr(882));
     textbackground(black);write(#0);writeln;
    ShowAllPartialMatches;
    writeln;
    textcolor(cfg.colorchart[normal]);
    DownlFile:='';
    g:=false;
    exit;
    end;
   none:
    begin
    writeln;
    textcolor(cfg.colorchart[errcolor]);
    writeln('No files found matching that partial name.');
    g:=false;
    m:=true;
    exit;
    end;
   end; { case partialname of }

 end;

function AskIfEnterAnother: boolean;
  var r:byte;
  begin
  TextColor(Cfg.colorchart[normal]);
  writeln;
  write('Pick another file? ');

   { GetChoice is a light-bar selector like SLBBS uses -- not included
     because a case READKEY of could be used just as well }

{  GetChoice(2, 'Yes No',Cfg.ColorChart[InVerse],Cfg.ColorChart[BackGround],
            Cfg.ColorChart[Normal],r);
 }
  if not carrier then barfexit;

  if r=1 then AskIfEnterAnother:=true else AskIfEnterAnother:=False;
  end;

function AskifSure:boolean;
  var r:byte;
  begin
  TextColor(Cfg.colorchart[normal]);
  writeln;
  writeln('It will take approximately 2 minutes to get the file from the');
  writeln('tape drive.  Then you will be able to download it using Zmodem.');
  writeln;
  write('Continue? ');

 { GetChoice is a light-bar selector like SLBBS uses -- not included
     because a case READKEY of could be used just as well }

{  GetChoice(2, 'Yes No',Cfg.ColorChart[InVerse],Cfg.ColorChart[BackGround],
            Cfg.ColorChart[Normal],r);}

  if not carrier then barfexit;

  if r=1 then AskIfSure:=true else AskIfSure:=False;
  end;


procedure WhichVolume(f:string;var v:byte);
  var z:byte;

  function InText:boolean;
    type bffrtype = array[1..20480] of char;
    var tfile: text;
        ts   : string;
        bffr : ^bffrtype;

    begin
    new(bffr);
    intext:=false;
    assign(tfile,ProgPath+'VOLUME.'+Tostrb(z));
    reset(tfile);
    SetTextBuf(tfile, bffr^,sizeof(bffr^));
    readln(tfile,ts);

    repeat
     begin
     ts:=copy(upcasestr(Rtrim(ts)),1,20);
     if pos(f,ts)<>0 then
      begin
      intext:=true;
      dispose(bffr);
      exit;
      end;

     readln(tfile,ts);
     end
    until eof(tfile);
    dispose(bffr);
    end;

  begin
  v:=0;
  for z:=1 to NumOfVolumes do
    begin
    If InText then
       begin
       v:=z;
       exit;
       end;
    end;
  end;

function GrabFromTape:integer;
  var volume: byte;

      ssm1  : longint;
      ssm2  : longint;

      h,m,s : word;
      err   : integer;
  begin

  writeln;
  textcolor(cfg.colorchart[altcolor]);
  write('Please wait, determining volume... ');

  WhichVolume(DlFile,volume);

  if volume=0 then
    begin
    writeln;
    writeln;
    textcolor(cfg.colorchart[errcolor]);
    writeln('Ack!  File ', DlFile,' not found on any tape volumes!');
    writeln('Please report to Sysop! ');
    BarfExit;
    end;

  writeln('File Found, Volume ',volume);

  writeln;
  TextColor(cfg.colorchart[headcolor]);
  writeln('Swapping to disk...');

  textcolor(lightgray);
  ExecStr:='RESTORE \FILES\OFFLINE\'+DlFile+' '+GenPath+' /V='+Tostrb(volume)+'/P/-O';
  KillStatusLine;

  release(listroot);
  NoComInput;

  curtime(h,m,s);
  ssm1:=secondssincemidnight(h,m,s);
  {$IFNDEF DEBUG}
  err:=do_Exec('D:\SLBBS\TAPE\TAPE.EXE',ExecStr,USE_FILE,$ffff,FALSE);
  {$ENDIF}

  localonly;
  writeln;
  localandremote;

  grabfromtape:=err;
  curtime(h,m,s);
  ssm2:=secondssincemidnight(h,m,s)-ssm1;

  if err=0 then
    Writeln(LogFile, DtTmStamp, ' ',DlFile,' restored from tape, took ',ssm2:4, ' seconds.')
  else
    Writeln(LogFile, DtTmStamp, ' ',DlFile,' NOT Restored tape, Error : ',Err:3);

  ComInput;

  InitStatus;
  end;

Procedure SendZmodem(var SomeThingSent:boolean);
  var doserr:byte;
  begin

  TextColor(cfg.colorchart[headcolor]);
  writeln;
  writeln(SlStr(815),'Zmodem');

  ExecStr:='sz '+GenPath+DlFile;

    KillStatusLine;
    {$IFDEF DEBUG} ClrScr; {$ENDIF}
    {$IFNDEF DEBUG}
    LocalOnly;
    NoComInput;
    ClrScr;
    writeln;

    Writeln(User.name,' downloading ', Dlfile);
    Exec('D:\DSZ.COM',ExecStr);
    doserr:=lo(dosexitcode);

    if doserr=0 then
      begin
      Writeln(LogFile, DtTmStamp, ' ',DlFile,' sent.');
      SomeThingSent:=true;
      end
    else
      begin
      Writeln(LogFile, DtTmStamp, ' ',DlFile,' NOT sent: DSZ error code: ',doserr);
      SomeThingSent:=false;
      end;

    writeln;
    ComInput;
    LocalAndRemote;
    {$ENDIF}
  end;

procedure GetFileEntry;   { value returned in EnterN }
  begin
   repeat
    begin
    GetFileName(EnterN);
    EnterN := UpCaseStr(EnterN);

    ProcessFileName(EnterN,DlFile,good,mustask);
    if ((not good) and mustask) then another:=AskIfEnterAnother;

    end
   until (not another) or good;
  end;

Procedure ProcessFile;
    var err    :integer;
        exists : boolean;
        sent   :boolean;
    begin

    exists:=existfile(genpath+dlfile);
    err:=0;

    If exists then
     begin
     writeln;
     writeln('The file was in the disk buffer, so it won''t have to be retrieved.');
     writeln;
     if Cfg.RsActive then SendZmodem(sent);
     writeln;
     writeln;
     textcolor(cfg.colorchart[special]);
     if Sent then writeln(SlStr(921)) else writeln(slstr(920));
     writeln;
     end

    else if AskIfSure then
     begin
     err:=GrabFromTape;
     exists:=existfile(genpath+dlfile);

     if (err=0) and exists then
         begin
         if Cfg.RsActive then SendZmodem(sent);
         writeln;
         writeln;
         textcolor(cfg.colorchart[special]);
         if Sent then writeln(SlStr(921)) else writeln(slstr(920));
         writeln;
         end
     else
         begin
         writeln;
         textcolor(cfg.colorchart[ERRColor]);
         writeln('File Does Not Exist on Disk - Aborting');
         end;

     end
     else
      begin
      textcolor(cfg.colorchart[ErrColor]);
      writeln;
      writeln;
      writeln('Operation Cancelled!');
      writeln;
      end;
end;

Function TimeLeft: longint;
var h,m,s:word;
  begin
  curtime(h,m,s);

  TimeLeft := ( Cfg.TimeLimit*60 ) -
             (  SecondsSinceMidnight(h,m,s)
              - SecondsSinceMidnight(Cfg.Logtime.Hour,Cfg.Logtime.minute,0)
             )
  end;


Function CheckLimits: boolean;
  var i:longint;
      t:boolean;
      br:word;
  begin
  CurFile := ListRoot;
  While CurFile <> Nil do
    begin
    if CurFile^.FileName=DlFile then
      begin
      i:=CurFile^.RecNum;
      end;
    CurFile := CurFile^.Next
    end;

  Read_Dir(i,dir);

  CheckLimits := true;
  if (data^.rsactive or cfg.rsactive) then
   begin

 { this don't work !!!
   if
      (((((Setup.Value*10*Dir.Length*128) div 1024)+User.Downloads) div
       User.Uploads)>User.Access.Ratio)
    then begin
         CheckLimits:=false;
         writeln;
         Textcolor(cfg.colorchart[special]);
         writeln('Picking that file would overrun your ratio');
         end;
 }

   case cfg.baudrate of
 { (B110,B150,B300,B600,B1200,B2400,B4800,B9600,B19200,B38400);}
     b110  : br:=110;
     b150  : br:=150;
     b300  : br:=300;
     b600  : br:=600;
     b1200 : br:=1200;
     b2400 : br:=2400;
     b4800 : br:=4800;
     b9600 : br:=9600;
     b19200: br:=19200;
     b38400: br:=38400;
    end;

   if
      ( (Dir.Length*128) div br ) > Timeleft
    then begin
         CheckLimits:=False;
         Writeln;
         Textcolor(cfg.colorchart[special]);
         writeln(SlStr(814));
         end;

   end;
  end;

begin
   InitVars;
   clrscr;
   textbackground(black);
   textcolor(cyan);
   writeln('Please Wait... Will Take 4 seconds...');
   writeln;
   InitConfig;
   Open_Strings;
   PortCheck := Cfg.RsActive;
   Portnum := Cfg.ComPort;
   InitSetup;
   Ansi:=Cfg.Ansi;
   FindSetup;
   GetUserData;
   Writeln(LogFile, DtTmStamp, ' ',CaseStr(User.Name),' entered door.');
   InitStatus;
   OpenDir;
   SetupLinkedList;
   textcolor(cfg.colorchart[normal]);
   writeln;
   writeln('This door  allows you to access files which  are stored on the');
   writeln('tape drive.   The list of these files is the OFFLINE directory');
   writeln('in the Files section. You can use the Zippy command from there');
   writeln('to scan for a word or phrase.');
   writeln;
   writeln('It will take about 2 minutes to get the file off the tape,  so');
   writeln('please be patient, and don''t hang up.');
   writeln;
   write('At the file prompt, enter ');
   textcolor(cfg.colorchart[headcolor]);
   write('?');
   textcolor(cfg.colorchart[normal]);
   writeln(' to see a list of special commands.');
   writeln;
   GetFileEntry;
   if Good then
     if CheckLimits then ProcessFile;

    CloseFiles;
    KillStatusLine;
end.
