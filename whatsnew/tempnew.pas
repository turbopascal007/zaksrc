Program WHATSNEW;

{$R-,S-,F+,O+}

{$IFDEF  DEBUG} {$L+,D+}  {$ENDIF}

{$IFNDEF DEBUG} {$L-,D-}  {$ENDIF}

Uses Overlay,Dos,Crt,SlFiles,SlDriv,Etc,Dates,WNEWCFG;

{$O WNEWCFG}   {Overlay the configuration program }

type CfgInfoType = record
      ProgId        : array[1..8] of char;
      Version       : Word;
      Revision      : Char;

   { User Config Starts Here }

      UseCfgColors  : Boolean;
      UsePages      : Boolean;
      ClearScr      : Boolean;
      Wide          : Boolean;
      ShowBrag      : Boolean;
      UseStatusLine : Boolean;
      Ask           : Boolean;
      NoAnsiAsk     : Boolean;
      ShowMsgs      : Boolean;
      ShowFiles     : Boolean;
      AllowAbort    : Boolean;
      ShowDetPer    : boolean;
      end;

     SetupBffrType = record
      read  : boolean;
      setup : ^setupdata;
      end;



const ESCAPE        : array[1..4] of char = 'здды';

       { BEGIN CfgInfo TYPE HERE }

       CfgInfo       : CfgInfoType  =
                         (ProgId       : 'WHATSNEW';
                          Version      : 220;
                          Revision     : 'D';

                        { User Config Starts Here }

                          UseCfgColors : True  ;
                          UsePages     : False ;
                          ClearScr     : False ;
                          Wide         : False ;
                          ShowBrag     : True  ;
                          UseStatusLine: True  ;
                          Ask          : True  ;
                          NoAnsiAsk    : False ;
                          ShowMsgs     : True  ;
                          ShowFiles    : True  ;
                          AllowAbort   : True  ;
                          ShowDetPer   : True  );

       { END CfgInfo TYPE HERE }

       NameLength    : Byte         = 20;

       OvrMaxSize    : longint      = 8192;

       author        : string[10]   = 'Zak Smith';
       BragLine      : string       = 'The "What''s New" Utility, '+
                                      'v';

       BragLine2     : string       = '           '+
                                      '(c) Copyright 1991 by Zak Smith'+
                                      ' All Rights Reserved';

       {$IFNDEF REG}
       UnRegLine     : string       = '           '+
                                      'UNREGISTERED Shareware Product'+
                                      ' - Support Software Authors!';
       {$ENDIF}

       subnamefirst  : boolean      = true;
       maxbffr       : longint      = 500;
       EscapeReg     : array[1..4] of char = '(**)';
       RegNum        : integer      = 0;

var
    doconfig    : boolean;
    saverow     : byte;
    curline     : integer;
    mbr         : membtype;
    username    : string[25];
    user        : usertype;
    setup       : setupdata;
    dir         : dirtype;
    on40        : boolean;
    nothingnew  : boolean;
    colors      : array[1..6] of byte;
    SubSetupBffr: array[1..500] of SetupBffrType;
    DirSetupBffr: array[1..500] of SetupBffrType;

procedure CheckRegNum;
  var exefile: file;
      offs   : longint;
      bffr   : array[1..512] of char;
      against: integer;
      a      : integer;
  begin
  assign(exefile, cfg.progpath+'login.exe');
  reset(exefile,1);
  offs := filesize(exefile)-sizeof(bffr);
  seek(exefile, offs);
  blockread(exefile, bffr, sizeof(bffr));
  a:=0;
  repeat
   inc(a);
  until ((bffr[a]=#4) and (bffr[a+1]=#32) and (bffr[a+2]=#51)) or
         (a = sizeof(bffr)-3);
  dec(a,8);
  against := (ord(bffr[a+1])*$100) + ord(bffr[a]);
  close(exefile);
  if against <> regnum then
     begin
     textbackground(black);
     textcolor(lightred);
     Writeln('Registration Numbers do not match!');
     textcolor(cyan);
     Writeln('Contact Author.');
     halt(4);
     end;
  end;

procedure Pause;
  begin
  textcolor(Colors[4]);
  Write('-- more --');
  repeat until readkey <> #0;
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


procedure DisposeBffr;
  var i: longint;
  begin
  for i:=1 to maxbffr do
    begin
    if SubSetupBffr[i].Read then Dispose(SubSetupBffr[i].Setup);
    if DirSetupBffr[i].Read then Dispose(DirSetupBffr[i].Setup);
    end;
  end;


procedure CheckForPause;
    begin
      if User.ScrnSize <> 0 then
        begin
        if Curline = User.ScrnSize then
          begin
          Pause;
          if CfgInfo.ClearScr then
            if Ansi then Clrscr else Write(^L)
          else Writeln;
          Curline := 1;
          end;
        end;
    end;

procedure checkforabort;
  begin
  if cfginfo.allowabort then
   if keypressed then
    if readkey in [#32,^C] then
     begin
     textcolor(colors[4]);
     write('^C');
     killstatusline;
     DisposeBffr;
     halt(3);
     end;
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
  textcolor(colors[5]);
  textbackground(colors[6]);
  Write(' User: ',CaseStr(User.Name));
  clreol;
  Gotoxy(34,25);
  Write('WHATSNEW v',(CfgInfo.Version/100):4:2);

  {$IFDEF REG}
    gotoxy(50,25);
    textcolor(yellow);
    write('[');
    write(RegNum:4);
    write(']');
  {$ELSE}
    gotoxy(50,25);
    textcolor(lightred+blink);
    write('[UNREG]');
  {$ENDIF}

  textbackground(black);
  window(1,1,80,24);
  gotoxy(x,y);
  CursorOn;
  directvideo := false;
  if SlActive then LocalandRemote;
  end;

procedure StatusLine;
  var x,y: byte;
  begin
    if cfginfo.usestatusline then
    begin
    CheckForAbort;
    if SlActive then LocalOnly;
    directvideo := cfg.directvid;
    cursoroff;
    x:=wherex;y:=wherey;
    window(1,1,80,25);
    textcolor(colors[5]);
    textbackground(colors[6]);

    gotoxy(60,25);
    write('Scanning: ',casestr(setup.name));clreol;

    textbackground(black);
    window(1,1,80,24);
    gotoxy(x,y);
    cursoron;
    directvideo := false;
    if SlActive then LocalAndRemote;
    end;
  end;


function find_high_msg:longint;
  begin
  open_msghdr(setup.path, setup.name);
  read_msghdr_genhdr;
  read_msghdr_hdr;
  find_high_msg := msghdrhdr.lastmsg;
  end;

function personal_msgs: boolean;
  begin {run after a call to find_high_msg, needs MsgHdrHdr}
  personal_msgs := (Mbr.Lastmail > Mbr.Lastread)
  end;

Procedure ShowPersonals(hm:longint);
  var Index: ^Indextype;
      d:headertype;

 function FirstNewPersonalMsg:longint;
   var l:longint;
   begin

   ReadHdrData(index^[seq,hm],d);

   l:=hm;

   while d.lastmail>mbr.lastread do
     begin
     l:=d.lastmail;
     ReadHdrData(index^[seq,d.lastmail],d);
     end;

   FirstNewPersonalMsg:=L;
   end;
 var l:longint;

 begin
 New(index);

 ReadHdrIndex(Index^);

 l:=FirstNewPersonalMsg;

 repeat
   begin
   ReadHdrData(index^[seq,l],d);
   l:=d.nextmail;

   writeln;inc(curline);
   if CfgInfo.UsePages then CheckForPause;

   textcolor(colors[1]);
   write(' Prsnl: ');
   textcolor(colors[5]);

   write(copy(d.from,1,NameLength) + ltab(length(d.from),NameLength));

   textcolor(colors[1]);
   write(' Subj: ');
   textcolor(colors[5]);
   write(d.subj);

   end
 until (d.nextmail=0);

 dispose(index);
 end;

procedure Status_Msgs(n:longint);
  var hm: longint;
      pm: boolean;

      numnew: longint;
  begin
  hm:=Find_High_Msg;
  pm:=personal_msgs;

  if HM-N>MsgHdrHdr.Messages then numnew:=MsgHdrHdr.Messages
   else numnew:=HM-N;

  if (numnew) > 0 then
    begin

    if nothingnew then nothingnew := false;

    if not subnamefirst then
      begin
      TextColor(Colors[1]);
      write(numnew:4);
      textcolor(Colors[1]);
      write(' new messages in ');
      textcolor(Colors[2]);
      write(setup.name);
      end
    else
      begin
      textcolor(Colors[2]);write(ltab(length(setup.name),8),setup.name);
      textcolor(Colors[1]);write(' has');textcolor(Colors[2]);
      write(numnew:4);textcolor(Colors[1]);write(' new msgs.');
      end;

    if not CfgInfo.wide then
      begin
      if not subnamefirst then write(ltab(length(setup.name),8));
      textcolor(Colors[3]);write(' - ');
      textcolor(Colors[1]);write(msghdrhdr.name);
      if pm and not(cfginfo.showdetper) then
        begin
        write(ltab(length(msghdrhdr.name),40));
        end;
      end;
    if pm then
      if cfginfo.showdetper then ShowPersonals(mbr.lastmail) else
       if NOT cfginfo.wide then
        begin
        textcolor(Colors[3]);write('- ');
        textcolor(Colors[4]);
        write('Personal');
        if (not on40) and (CfgInfo.wide) then write(ltab(0,4))
        end;

    if (not on40) and CfgInfo.wide and (not pm) then write(ltab(0,14));

    textcolor(Colors[1]);

    if (on40 or not CfgInfo.wide) then
      begin
      writeln;
      Inc(curline);
      end;

    if CfgInfo.UsePages then CheckForPause;

    if CfgInfo.wide then if on40=true then on40:=false else on40 := true;
    end;

  Close_MsgHdr;
  end;

procedure ClimbTree_mbr(rec:longint);
  var Right     : longint;
      Left      : longint;

  begin

  if rec <> 0 then
    begin

    Read_msgmbr(rec,mbr);

    Right := mbr.leaf.Right;
    Left := mbr.leaf.left;

    case compare(username, mbr.name) of
      0: begin
         if upcasestr(Setup.Name) <> 'MAIL' then Status_Msgs(Mbr.Lastread);
         exit;
         end;

      1: Climbtree_mbr(right);
      2: Climbtree_mbr(left);
      end;

    end;
  end;

procedure process_mbr_data;
  begin

  StatusLine;

  open_msgmbr(setup.path, setup.name);
  read_msgmbr_genhdr;
  read_msgmbr_hdr;
  climbtree_mbr(msgmbrhdr.root.treeroot);
  close_msgmbr;
  end;


procedure ClimbTree_MsgSetup(rec:longint);
var left:longint;
    right:longint;

  begin

   if rec <> 0 then
    begin

    Read_Setup_data(rec,setup);

    Right := Setup.leaf.Right;
    Left := setup.leaf.left;

    ClimbTree_MsgSetup(Left);

    if left <> 0 then Read_Setup_Data(rec,setup);

    if upcasestr(setup.name) <> 'MAIL' then process_mbr_data;

    ClimbTree_MsgSetup(Right);

    end;
  end;


procedure FindMainSubList(var mainfile: text);
  var
      templn  : string[8];

  procedure findsub(r:longint);
  var Right     : longint;
      Left      : longint;

    begin
    if r <> 0 then
      begin

      if SubSetupBffr[r].read then
         begin
         Setup := SubSetupBffr[r].setup^;
         end
       else
         begin
         Read_setup_data(r,setup);
         if MaxAvail > Sizeof(Setup) then
           begin
           new(subsetupbffr[r].setup);
           subsetupbffr[r].read := true;
           subsetupbffr[r].setup^ := setup;
           end
         end;

      Right := setup.leaf.Right;
      Left := setup.leaf.left;

      case compare(templn, setup.name) of
        0: begin
           Process_mbr_data;
           exit;
           end;

        1: findsub(right);
        2: findsub(left);
        end;

      end;
    end;


  begin
  repeat
   begin
   readln(mainfile,templn);
   templn := rtrim(upcasestr(templn));
   FindSub(SetupHdr.root.treeroot);
   end;
  until eof(mainfile);
  end;




procedure ScanMsgs;
  var mainfile:text;
  begin

  Open_Setup(setupmsg);
  read_setup_genhdr;
  read_setup_hdr;

  if existfile(pathtoconfig+'MAIN.SUB') then assign(mainfile,pathtoconfig+'MAIN.SUB')
   else assign(mainfile,cfg.datapath+'MAIN.SUB');
  {$I-}
  Reset(mainfile);
  {$I+}
  if IoResult <> 0 then
    Climbtree_msgsetup(setuphdr.root.treeroot)
  else
     begin;
     FindMainSubList(mainfile);
     close(mainfile);
     end;

  close_setup;
  end;


{*******************************}


procedure Status_dir(n:longint);
var st: string[4];
  begin
  if n > 0 then
    begin
    str(n:4,st);

    if nothingnew then nothingnew := false;

    if not subnamefirst then
      begin
      textcolor(Colors[2]);
      write(st);textcolor(Colors[1]);
      write(' new  files  in  ');
      textcolor(Colors[2]);write(setup.name);
      end
    else
      begin
      textcolor(Colors[2]);write(ltab(length(setup.name),8),setup.name);
      textcolor(Colors[1]);write(' has');textcolor(Colors[2]);
      write(st);textcolor(Colors[1]);write(' new files');
      end;
    if not CfgInfo.wide then
      begin
      if not subnamefirst then write(ltab(length(setup.name),8));
      textcolor(Colors[3]);write(' - ');
      textcolor(Colors[1]);write(dirhdr.name);
      end
    else write(ltab(0,14));
    textcolor(Colors[1]);

    if (on40 or not CfgInfo.wide) then
      begin
      writeln;
      Inc(curline);
      end;

    if CfgInfo.UsePages Then CheckForPause;

    if CfgInfo.wide then if on40=true then on40:=false else on40:=true;
    end;
  end;

procedure scandir;
var next: longint;
    num : longint;
    done: boolean;

  begin

  StatusLine;

  open_Dir(setup.path,setup.name);
  read_dir_GenHdr;
  Read_Dir_Hdr;

  num := 0;
  next := DirHdr.Root.ListRoot;

  done := false;

  repeat
     begin
     read_dir(next,dir);
     next := dir.leaf.next;

     if num>=dirhdr.root.entries then done:=true
     else
      begin
      if Serial_day(dir.date.day,dir.date.month,dir.date.year+1900) <
         Serial_day(cfg.laston.day,cfg.laston.month,cfg.laston.year+1900)
       Then
         begin
         done := true;
         end
       else
         begin
         inc(num);
         end;
      end;
     end;
  until done;

  Status_Dir(num);
  close_Dir;
  end;

procedure ClimbTree_DirSetup(rec:longint);
  begin
  if rec <> 0 then
    begin
    read_setup_data(rec,setup);

    if Setup.Leaf.Left <> 0 then
      begin
      ClimbTree_DirSetup(Setup.Leaf.Left);
      Read_Setup_Data(rec,setup);
      end;
           if (User.access.filelevel >= Setup.Access) And
              AttribIn(User.Access.Attrib,Setup.Attrib)

             then Scandir;

    ClimbTree_DirSetup(Setup.leaf.right);

    end;
  end;

procedure FindMainDirList(var mainfile: text);
  var
      templn  : string[8];

  procedure finddir(r:longint);
  var Right     : longint;
      Left      : longint;

    begin
    if r <> 0 then
      begin

      if DirSetupBffr[r].read then
         begin
         Setup := DirSetupBffr[r].setup^;
         end
       else
         begin
         Read_setup_data(r,setup);
         if MaxAvail > Sizeof(Setup) then
           begin
           new(Dirsetupbffr[r].setup);
           dirsetupbffr[r].read := true;
           dirsetupbffr[r].setup^ := setup;
           end
         end;

      Right := setup.leaf.Right;
      Left := setup.leaf.left;

      case compare(templn, setup.name) of
        0: begin
           StatusLine;
           if (User.access.filelevel >= Setup.Access) And
              AttribIn(User.Access.Attrib,Setup.Attrib)

             then Scandir;

           exit;
           end;

        1: finddir(right);
        2: finddir(left);
        end;

      end;
    end;


  begin
  repeat
   begin
   readln(mainfile,templn);
   templn := rtrim(upcasestr(templn));
   Finddir(SetupHdr.root.treeroot);
   end;
  until eof(mainfile);
  end;


procedure ScanFiles;
  var mainfile:text;
  begin

  Open_Setup(SetupDIR);
  read_setup_genhdr;
  read_setup_hdr;

  assign(mainfile,cfg.datapath+'MAIN.DIR');
  {$I-}
  reset(mainfile);
  {$I+}
  if IoResult <> 0 then
    ClimbTree_DirSetup(setuphdr.root.treeroot)
  else
    begin
    findmainDirlist(mainfile);
    close(mainfile);
    end;

  close_setup;
  end;

procedure Parse;
 { whatsnew pathtoconfig /[no]WIDE /[no]BRAG /[no]PAGES /[no]CFGCOLORS   }

 {                       /[no]CLEARSCR /[no]STATUS /[no]ASK /[no]ANSIASK }

 {                       /[no]SHOWMSGS /[no]SHOWFILES                    }

 {                       /CONFIG /[no]ALLOWABORT                         }

  var idx : byte;
      s   : string;
      code: integer;

 procedure searchcfg;
  var a: integer;
  begin
  for a := 1 to ord(s[0]) do s[a] := upcase(s[a]);

  s:=ltrim(s);

  if S[1]<>'/' then
  begin
   a := 0;
   repeat
     begin
     inc(a);
     end;
   until ((s[a]=' ') or (s[a]='/') or (a=length(s)));
   idx:=a;

   pathtoconfig := copy(s,1,idx);
   delete(s,1,idx-1);

   s:=ltrim(s);
   end;

   if pos('/WIDE',S)>0         then CfgInfo.wide         := True;
   if pos('/NOWIDE',S)>0       then cfginfo.wide         := false;

   if pos('/NOBRAG',s)>0       then CfgInfo.showbrag     := False;
   if pos('/BRAG',s)>0         then cfginfo.showbrag     := true;

   if pos('/PAGES',s)>0        then cfginfo.usepages     := true;
   if pos('/NOPAGES',s)>0      then cfginfo.usepages     := false;

   if pos('/NOCFGCOLORS',s)>0  then cfginfo.usecfgcolors := false;
   if pos('/CFGCOLORS',s)>0    then cfginfo.usecfgcolors := true;

   if pos('/CLEARSCR',s)>0     then cfginfo.clearscr     := true;
   if pos('/NOCLEARSCR',s)>0   then cfginfo.clearscr     := false;

   if pos('/STATUS',s)>0       then cfginfo.usestatusline:= true;
   if pos('/NOSTATUS',s)>0     then cfginfo.usestatusline:= false;

   if pos('/ASK',s)>0          then cfginfo.ask          := true;
   if pos('/NOASK',s)>0        then cfginfo.ask          := false;

   if pos('/ANSIASK',s)>0      then cfginfo.noansiask    := false;
   if pos('/NOANSIASK',s)>0    then cfginfo.noansiask    := true;

   if pos('/SHOWMSGS',s)>0     then cfginfo.showmsgs     := true;
   if pos('/NOSHOWMSGS',s)>0   then cfginfo.showmsgs     := false;

   if pos('/SHOWFILES',s)>0    then cfginfo.showfiles    := true;
   if pos('/NOSHOWFILES',s)>0  then cfginfo.showfiles    := false;

   if pos('/ALLOWABORT',s)>0   then cfginfo.allowabort   := true;
   if pos('/NOALLOWABORT',s)>0 then cfginfo.allowabort   := false;


  end;

  var a:integer;

  begin
  idx := 0;
  pathtoconfig := '';
  doconfig := false;
  s:='';
  if Paramcount = 0 then
     begin
     s:=getenv('WHATSNEW');
     if s<>'' then Searchcfg;
     end
  else
     begin
     s:=getenv('WHATSNEW');
     if s<>''then Searchcfg;

     s:='';
     for a:=1 to paramcount do s:=s+' '+paramstr(a);

     Searchcfg;

     if pos('/CONFIG',s)>0      then doconfig             := true;

     end;

  pathtoconfig := rtrim(pathtoconfig);

  if Pathtoconfig <> '' then
   begin
   if upcasestr(copy(pathtoconfig,length(pathtoconfig)-9,10))='CONFIG.SL2'
    then pathtoconfig := copy(pathtoconfig,1,length(pathtoconfig)-10);

   if pathtoconfig[length(pathtoconfig)] <> '\'
    then pathtoconfig := pathtoconfig + '\';
   end;
  end;

procedure LoadOverLay;
    begin
    {$I-}
    OvrFileMode := 2;
    {$IFDEF DEBUG}
    OvrInit('C:\TP\BIN\WHATSNEW.OVR');
    {$ELSE}
    OvrInit(paramstr(0));
    {$ENDIF}
    {$I+}
    if OvrResult <> 0  then writeln('Overlay Error ',OvrResult);
    OvrSetBuf(OvrMaxSize);
    end;

var QuitHere  : Boolean;
    Temp      : byte;
    TempC     : Char;
    a         : byte;
    i         : longint;
begin

  Filemode := 66;

  DirectVideo := False;

  curline := 1;

  for i:=1 to maxbffr do subsetupbffr[i].read := false;
  for i:=1 to maxbffr do dirsetupbffr[i].read := false;

  parse;

  if doconfig then
    begin
    pathtofile := paramstr(0);
    LoadOverlay;
    Configure;
    halt(0);
    end;

  open_config;
  read_config;
  Close_config;

  {$IFDEF REG}
  {$IFNDEF DEBUG}
  CheckRegNum;
  {$ENDIF}
  {$ENDIF}


  Open_User;
  Read_User_GenHdr;
  Read_User_Hdr;
  Read_User(Cfg.CurrUser, User);
  Close_User;
  Username := User.Name;


  if SlActive then Ansi := Data^.Ansi else Ansi := true;

  on40 := false;

  nothingnew := true;

  if ((SlActive and Data^.color) or NOT SlActive) then
    if Cfginfo.UseCfgColors then
      begin
      Colors[1] := Cfg.ColorChart[Normal];           {cyan}
      Colors[2] := Cfg.ColorChart[SubColor];         {lightcyan}
      Colors[3] := Cfg.ColorChart[PromptColor];      {gray}
      Colors[4] := Cfg.ColorChart[Special];          {white}
      Colors[5] := Cfg.ColorChart[Inverse];          {white}
      Colors[6] := Cfg.ColorChart[Background];       {blue}
      end
    else
      begin
      Colors[1] := Cyan;
      Colors[2] := LightCyan;
      Colors[3] := LightGray;
      Colors[4] := lightred;
      Colors[5] := white;
      Colors[6] := blue;
      end
  else
    begin
    for a:=1 to 4 do Colors[a] := lightgray;
    Colors[5] := Black;
    Colors[6] := Lightgray;
    end;

  if CfgInfo.UseStatusLine then
     begin
     if slactive then localonly;
     saverow := wherey;
     if saverow>24 then saverow:=24;
     Window(1,1,80,24);
     gotoxy(1,saverow);
     if slactive then localandremote;
     InitStatus;
     end;


  {$IFDEF REG}
  if CfgInfo.ShowBrag then
  {$ENDIF}
    begin
    TextColor(Colors[4]);
    clreol;
    write('WHATSNEW');textcolor(Colors[3]);
    write(' - ');
    textcolor(Colors[1]);
    write(BragLine,(CfgInfo.Version/100):4:2,CfgInfo.Revision);
    writeln;
    writeln(Bragline2);
    end;

  {$IFNDEF REG}
  {$IFNDEF DEBUG}
  Textcolor(Colors[4]);
  write(UnRegLine);
  for a:= 1 to 5 do
      begin
      delay(1000);
      write('.');
      end;
  for a:=1 to 4 do
      begin
      beep(3000,50);
      delay(30);
      end;
  writeln;
  {$ENDIF}
  {$ENDIF}

  if cfginfo.ASK then
    begin
    TextBackground(Black);
    TextColor(Colors[1]);

    Write('Review New activity in the ');

    if cfginfo.showmsgs then write('Subboard ');
    if cfginfo.showmsgs and cfginfo.showfiles then write('and ');
    if cfginfo.showfiles then write('File ');

    write('areas? ');

    if (Ansi and not CfgInfo.NoAnsiAsk) then
      begin
      GetChoice(2, 'Yes No', Colors[5], Colors[6], Colors[1],temp);
      case temp of
         1: QuitHere := False;
         2: QuitHere := True;
         end;
      writeln;
      end
    else
      begin
      write(' (Y/N): ');
      repeat tempc:=upcase(readkey) until tempc in ['Y','N'];
      case tempc of
        'Y': QuitHere := False;
        'N': QuitHere := True;
        end;
      writeln(tempc);
      end;

    if QuitHere then 
      begin
      if CfgInfo.UseStatusLine then KillStatusLine;
      halt(2);
      end;      
    end;

  if (CfgInfo.UsePages and CfgInfo.ClearScr) then
    if ANSI then ClrScr else Write(^L);

  if Cfginfo.ShowMsgs then ScanMsgs;

  if Not NothingNew then
      begin
      if Cfginfo.Showmsgs then
        begin
        writeln;
        inc(curline);
        end;

      On40 := false;
      if CfgInfo.UsePages then CheckForPause;
      end;

  if cfginfo.showfiles then ScanFiles;

  if nothingnew then
   begin
   if slactive then localonly;
   gotoxy(1,wherey);
   if slactive then localandremote;
   textcolor(Colors[1]);

   write('No new ');
   if cfginfo.showfiles then write ('files ');
   if cfginfo.showfiles and cfginfo.showmsgs then write('or ');
   if cfginfo.showmsgs then write('messages ');
   write('since your last call.');
   end;
  normvideo;

  Writeln;

  if CfgInfo.UseStatusLine then KillStatusLine;

  DisposeBffr;

  if NothingNew then Halt(1);

end.
