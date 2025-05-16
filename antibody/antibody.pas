Program AntiBody;
{$M 16384,0,10240} {$X+} {$B+} {$N-) {$E+} {$G-} {$I+} {$A-}

Uses Dos,Etc,SlFiles,AsyncCrt,ExecWin,ZSlKey,WildChck,Crt,ExitErr;

const numofmsgs = 90;
      NumOfIDBytes = 20;

Type MsgStrType = record
       t:string[120];
       end;

Type MsgType = Array[1..NumOfMsgs] of ^MsgStrType;

Const Version: string[ 6]  = '1.05';

      Logo1  : string[ 8]  = 'AntiBody';   { Do NOT Change }
      Logo2  : string[47]  = ' - Upload Virus Scanner / Compression Convertor';
      Done1  : string[51]  = '(c) copyright 1993 by Zak Smith all rights reserved';

      SysStrSpec: String[12] = 'ANTIBODY.SYS';

      RegCode: String[20]  = #137+#150+#154+#156+#158+#167+#249+#250+#180+#165+
                              #162+#159+#190+#177+#230+#202+#248+#253+#127+#148;

      NoHack : longint = -204905927; { was -1946093142; in 1992 }

Type ABCfgType = Record
       Escape     : array[1..4] of char;
       ConfigPath : string;
       ProgPath   : string;
       BadPath    : string;
       ScanDupe   : boolean;
       SplitScreen: boolean;
       ShowGifRes : Byte;
       GifResAtB  : boolean;
      end;

Const No=0;VideoMode=1;Resolution=2;
const ShowGif: Array[0..2] of string[20] = ('No','VideoMode','Resolution');

Const
      ABCfg: ABCfgType =
           (Escape       :'здды';
            ConfigPath   :'..\';
            ProgPath     :'.\';
            BadPath      :'.\BADFILE\';
            ScanDupe     : TRUE;
            SplitScreen  : TRUE;
            ShowGifRes   : VideoMode;
            GifResAtB    : True);

Type FileNameArrayType  = array[1..40] of string[12];

     RejectType = record  Count   : byte;
                          FileName: ^FileNameArrayType;
                          end;

const lengthofstr = 2048;

Type ToFileProcessed= ^FileProcessedType;
     FileProcessedType = record
     next:ToFileProcessed;
     name:string[12];
     end;


Type MsgChckArray = array[1..lengthofstr] of byte;

Type ByteUsed = record Used: boolean;Val : byte; end;
     ToArcDefType = ^ArcDefType;
     ArcDefType = record
       Next     : ToArcDefType;
       Sfx      : boolean;
       ProgID   : String[3];
       Prog     : String[12];
       Param    : String[20];
       IDBlock  : array[1..NumOfIDBytes] of ByteUsed;
     end;

     ReCompressType = Record
       ProgID : String[3];
       Prog   : String[12];
       Param  : String[20];
       end;

var ArcDefRoot  : ToArcDefType;
    ReCompress  : ReCompressType;
    FileProcRoot: ToFileProcessed;
    MSG         : ^MsgType;
    User        : UserType;
    Log         : text;
    ArcP        : string;
    CurLine     : byte;
    Reg         : boolean;
    Reject      : RejectType;
    RegTo       : String;
    OX,OY       : byte;
    CMDX,CMDY   : byte;

    TopX,TopY,
    BotX,BotY   : byte;
    StatX,StatY : byte;

Procedure LoadSysStr;
  var f         :file;
      CurStrNum :word;
      NumOfStr  :word;
      CurLen    :byte;
      bffr      :array[0..255] of char;

  begin
  New(Msg);
  Assign(f,fexpand(ABCfg.progpath+SysStrSpec));
  reset(f,1);

  if not (ioresult=0) then begin
           writeln('Cannot find ANTIBODY.SYS');
           halt(1);
           end;

  blockread(f,NumOfStr,sizeof(NumOfStr));
  for CurStrNum:=1 to NumOfStr do
     begin
     blockread(f,curlen,1);
     Seek(f,filepos(f)-1);
     blockread(f,bffr,curlen+1);

     GetMem(Msg^[CurStrNum],Curlen+1);

     Move(bffr,MSG^[CurStrNum]^.t,CurLen+1);

     end;
  close(f);
  end;

procedure PreExecWindow(cmd,parm:string;f,b:byte);
 type str78 = string[78];
 var   s78:str78;

 begin
  OX := WhereX;  { Store upper window X and Y }
  OY := WhereY;

  window(1,8,80,25);

  clrscr;

  Window(1,1,80,25);  { Make entire screen active window }
  GotoXY(1,7);      { Go to line 14 (COMMAND bar) }
  TextAttr := $10 * b + f;
  s78:=' '+Cmd+' '+Parm;
  Write(s78); clreol;

  GotoXY(1,8);     { Go to location in bottom window }
  textattr:=$07;
 end;

procedure FixForScanExe;
 begin
 gotoxy(1,9);
 end;

procedure PostExecWindow(b:byte);
  begin

  CmdY := WhereY;     {  Store new Y location }
  CmdX := WhereX;

  window(1,8,80,25);
  gotoxy(cmdx,cmdy-7);
  textattr:=$07;
  writeln;
  writeln;
  window(1,1,80,25);

  GotoXY(1,7);
  TextAttr := $10*b;    { Erase the COMMAND bar }
  ClrEol;
  Window(1,1,80,6);   { Reset the upper window }
  GotoXY(OX,OY);       { Re-position cursor }
  textattr:=$07;
end;

procedure StatusForScanningDupe(s:string;f,b:byte);
 var g:integer;
 begin
 g:=textattr;
 OX := WhereX;  { Store upper window X and Y }
 OY := WhereY;

 window(1,1,80,25);
 gotoxy(1,7);

 textattr:=$10*b+f;write(s);clreol;

 window(1,1,80,6);

 gotoxy(ox,oy);
 textattr:=g;
 end;

procedure CheckForHack;
  type stray=array[1..256] of byte;
  var r  :pwtype;
      rc :pwtype;
      a  :msgchckarray;
      i  :word;
      j,k:byte;
      ts :string;
      tsr:stray;

  begin
  i:=1;
  for j:=1 to numofmsgs do
      begin

      move( mem[seg(msg^[j]^.t):ofs(msg^[j]^.t)+1],a[i],length(msg^[j]^.t));

      inc(i,length(msg^[j]^.t));
      end;

  ts:=Logo1+Logo2+Done1+SysStrSpec;

  move( mem[seg(ts):ofs(ts)+1],a[i],length(ts) );

  inc(i,length(ts));

  if not(CRC32Array(@a[1],i-1)=NoHack) then
    begin
    Writeln('Program Illegally Modified!');
    halt(1);
    end;

  end;

procedure LoadRejectList;
  var rjf :text;
      bffr:array[1..1024] of char;
      c   :byte;
  begin
  c:=0;
  if ExistFile(ABCfg.Progpath+Msg^[58]^.t,anyfile) then
      begin
      new(Reject.FileName);
      assign(rjf,ABCfg.progpath+Msg^[58]^.t);
      reset(rjf);
      settextbuf(rjf,bffr,sizeof(bffr));
      inc(c);

      readln(rjf,Reject.FileName^[c]);
      reject.filename^[c]:=ltrim(rtrim(upcasestr(reject.filename^[c])));

      while ((not eof(rjf)) and (c<=40)) do
         begin
         inc(c);
         readln(rjf,Reject.FileName^[c]);
         if (c<=40) then reject.filename^[c]:=upcasestr(reject.filename^[c]);
         end;
      end;
  Reject.Count:=c;
  end;

Procedure ConfigProgram;
  var offs    : longint;
      subbffr : array[1..4] of char;
      a       : integer;
      found   : boolean;
      thisfile: file;
      bffr    : array[1..5120] of char;
      Info    : ABCfgType;


  Procedure ShowInfo;
   begin
   Writeln(Msg^[59]^.t,info.ConfigPath);
   Writeln(Msg^[60]^.t,info.ProgPath);
   Writeln(Msg^[61]^.t,info.BadPath);
   Writeln(Msg^[62]^.t,info.scandupe);
   Writeln(Msg^[63]^.t,info.splitscreen);
   Writeln(Msg^[81]^.t,ShowGif[info.ShowGifRes]);
   if Info.ShowGifRes=Resolution then Writeln(Msg^[84]^.t,info.GifResAtB);
   writeln;
   writeln(Msg^[64]^.t);
   writeln(Msg^[65]^.t);
   writeln;
   writeln(Msg^[66]^.t);
   writeln;
   end;

 function AskOpt(q:string;b:byte): boolean;
  var a:byte;
  begin
  write(q);
  GetChoice(2,Msg^[67]^.t,white,blue,lightcyan,a);
  if a=b then askopt := true else askopt:=false;
  writeln;
  end;

 function AskOpt4Graph(q:string):byte;
  var a:byte;
  begin
  write(q);
  GetChoice(3,Msg^[83]^.t,white,blue,lightcyan,a);
  if a=1 then AskOpt4Graph:=No
   else if a=2 then AskOpt4Graph:=VideoMode
    else if a=3 then AskOpt4Graph:=Resolution;
  writeln;
  end;

  Function GetInfo: boolean;
    var t:string;
    begin
    ShowInfo;
    GetInfo:=false;
    case upcase(localreadkey) of
      'A': begin
           Write(Msg^[6]^.t);
           Editor(45,T,'',White,Blue);writeln;
           info.configpath:=t;
           end;

      'B': begin
           Write(Msg^[7]^.t );
           Editor(45,T,'',White,Blue);writeln;
           info.progpath:=t;
           end;

      'C': begin
           Write(Msg^[8]^.t);
           Editor(45,T,'',White,Blue);writeln;
           info.badpath:=t;
           end;

      'D': begin
           info.scandupe:=askopt(Msg^[9]^.t,1);
           end;

      'E': info.splitscreen:=askopt(Msg^[10]^.t,1);

      'F': begin
           Info.ShowGifRes:=AskOpt4Graph(Msg^[82]^.t);
           end;

      'G': if Info.ShowGifRes=Resolution then
             begin
             writeln(Msg^[85]^.t);
             Info.GifResAtB:=AskOpt(ltab(0,5)+Msg^[16]^.t,1);
             end;

      'S': begin
           seek(thisfile,offs);
           blockwrite(thisfile,info,sizeof(info));
           GetInfo:=true;
           exit;
           end;

      'Q': begin GetInfo:=true; exit end;

     end;

    end;

  begin
  PortCheck:=false;
  Ansi:=true;
  useinsert:=true;
  found := false;

  assign(thisfile, paramstr(0));
  reset(thisfile, 1);

  offs := filesize(thisfile);

  write(Msg^[11]^.t,Paramstr(0));
  repeat
     begin
     dec(offs,sizeof(bffr));

     write('.');

     seek(thisfile,offs);
     blockread(thisfile,bffr,sizeof(bffr));

     a:=0;
     repeat
       begin
       inc(a);
       subbffr[1]:=bffr[a];
       subbffr[2]:=bffr[a+1];
       subbffr[3]:=bffr[a+2];
       subbffr[4]:=bffr[a+3];

       if (subbffr[1]='з') and (subbffr[2]='д') and (subbffr[4]='ы')
         then
         begin
         offs:=offs+a-1;
         found := true;
         end;
       end;
     until found or (a=sizeof(bffr)-3);

     if offs < 1024 then
       begin
       writeln;
       writeln(Msg^[12]^.t);
       exit;
       end;
     end;
  until found;

  writeln;

  seek(thisfile,offs);
  Blockread(thisfile,info,sizeof(info));

  repeat until GetInfo;
  Close(thisfile);
  Halt;
  end;


procedure CloseFiles;
 begin
 Close(log);
 end;

Procedure CheckKey;
  var s:string;
      n:word;
  begin
  KeyFileName:=Msg^[13]^.t;

   { if hacked ..
      begin
      Writeln(keyfilename+Msg^[14]^.t);
      close(log);
      halt(1);
      end; }

  Reg:=ReadKeyOK(RegTo,n);

  if not(n=slnumber) and reg then
      begin
      writeln(Msg^[1]^.t);
      close(log);
      halt(1);
      end;

  end;

Procedure BarfExit;
  begin
  writeln(log,DtTmStamp,Msg^[70]^.t,casestr(User.Name),Msg^[15]^.t);
  closefiles;
  halt(1);
  end;

Procedure InitVars;
  var a:byte;
      b:byte;
  begin
  ProgCode:=RegCode;

  if DVLoaded then ABCfg.SplitScreen:=False;

  TopX:=1;
  TopY:=8;

  BotX:=80;
  BotY:=25;

  statx:=40;
  staty:=10;

  FileProcRoot:=nil;

  ArcDefRoot:=nil;

  for a:=1 to length(progcode) do progcode[a]:=chr(byte(ord(progcode[a])-127));

  ABCfg.ConfigPath:=fexpand(abcfg.configpath);
  abcfg.progpath:=fexpand(abcfg.progpath);
  Abcfg.badPath:=fexpand(abcfg.badpath);

  KeyFilePath:=ABCfg.progpath;
  KeyFileName:=msg^[13]^.t;

  PathToConfig := ABCfg.ConfigPath;

  end;

Procedure CloseAll;
  begin
  Close(log)
  end;

procedure ChDirect(s:string);
  var ts:string;
  begin
  ts:=fexpand(s);
  chdir(s);
  end;

Procedure KillOpenWorkDir;
  begin
  if existfile(ABCfg.ProgPath+Msg^[17]^.t,directory) then
    begin
    {$I-}
    PruneDir(fexpand(ABCfg.ProgPath+Msg^[17]^.t));
    rmdir(fexpand(ABCfg.ProgPath+Msg^[17]^.t));
    {$I+}
    end;
  end;


Procedure OpenFiles;
  begin

  assign(Log,ABCfg.ProgPath+Msg^[18]^.t);
  if existfile(ABCfg.ProgPath+Msg^[18]^.t,anyfile) then append(log) else rewrite(log);

  Open_Config;
  Read_Config;
  Close_Config;

  Open_User;
  Read_User_GenHdr;
  Read_User_Hdr;
  Read_User(Cfg.CurrUser,User);
  Close_User;
  end;


function FileInSlbbs(s:string):boolean;
 var found:boolean;
     dir:dirtype;
     setup:setupdata;

 function leftStr(s1,s2:string):boolean;
   begin
   leftStr:=upcasestr(s1)<upcasestr(s2);
   end;

 function rightStr(s1,s2:string):boolean;
   begin
   rightStr:=upcasestr(s1)>upcasestr(s2);
   end;


 procedure ClimbTree_Dir(rec:longint); {recursive..}
  var Right     : longint;     {saved right pointer}
      Left      : longint;     {saved left  pointer}

  begin
  if not (found or (rec=0)) then
    begin
    Read_ShortDir(rec,dir);

    if leftStr(s,dir.name) then
         climbtree_dir(dir.leaf.left)

      else if rightStr(s,dir.name) then
          climbtree_dir(dir.leaf.right)

        else begin found :=true; exit end;
    end;
  end;


 procedure ScanDir;
  begin
    Open_Dir(setup.path,setup.name);
    Read_Dir_GenHdr;
    Read_Dir_Hdr;
    Climbtree_Dir(DirHdr.Root.Treeroot);
    Close_Dir;

  end;

 procedure Status;
  begin
  if abcfg.splitscreen then StatusForScanningDupe(Msg^[72]^.t+Msg^[2]^.t+setup.name,
        cfg.colorchart[inverse],cfg.colorchart[background])
  else
   begin
   agotoxy(length(Msg^[2]^.t)+1,curline, wherey);
   write(setup.name);AsyncCrt.clreol;
   end;
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

    if not found then
      begin
      Status;
      ScanDir;
      end;

    if found then exit;
    ClimbTree_DirSetup(Setup.leaf.right);
    end;
  end;

  begin
  if ABCfg.ScanDupe then
    begin
    found:=false;
    if not abcfg.splitscreen then
      begin
      writeremote:=false;
      writelocal:=true;
      awrite(Msg^[2]^.t);
      end;

    Open_Setup(Setupdir);
    read_setup_genhdr;
    read_setup_hdr;
    ClimbTree_DirSetup(setuphdr.root.treeroot);
    close_setup;

    if not abcfg.splitscreen then
      begin
      awriteln('');
      writeremote:=true;
      writelocal:=abcfg.splitscreen;
      end;
    end
  else found:=false;
  FileInSlbbs:=found;
  end;

function CheckReject(f:string):boolean;
  var i:byte;
  begin
  CheckReject:=false;
  f:=upcasestr(f);
  for i:=1 to Reject.Count do
    begin
    if ((f=Reject.Filename^[i]) or MatchWC(Reject.Filename^[i],f)) then
       begin
       CheckReject:=true;
       exit;
       end;
    end;
  end;


Function ScanFiles:boolean;
  var p     :string;
      derror:integer;
  begin
  p:=fsearch(Msg^[19]^.t,GetEnv('PATH'));
  if p='' then
     begin
     writeln(log,DtTmStamp,Msg^[70]^.t,casestr(User.Name),Msg^[73]^.t,Msg^[4]^.t);

     AWriteln(Msg^[3]^.t);
     BarfExit;
     end;

  if abcfg.splitscreen then PreExecWindow(Shortpath(p),Msg^[72]^.t+ABCfg.ProgPath+Msg^[5]^.t,
     Cfg.ColorChart[inverse],cfg.colorchart[background]);

  if abcfg.splitscreen then fixforscanexe;

  if abcfg.splitscreen then
     ExecWindow(p,Msg^[72]^.t+ABCfg.ProgPath+Msg^[20]^.t,TopX,TopY,BotX,BotY,cfg.colorchart[normal])
   else
     Exec(p,Msg^[72]^.t+ABCfg.ProgPath+Msg^[20]^.t);

  if abcfg.splitscreen then postexecwindow(cfg.colorchart[background]);

  derror:=dosexitcode;

  if lo(derror)=2 then
    begin
    if cfg.ansi then
       begin

       Agotoxy(Length(Msg^[40]^.t)+11,curline,wherey);

       ASettextcolor(cfg.colorchart[Errcolor],black);
       AWrite(Msg^[21]^.t);AsyncCrt.clreol;
       end
    else AWrite(Msg^[21]^.t);
    writeln(log,DtTmStamp,Msg^[70]^.t,casestr(User.Name),Msg^[73]^.t,Msg^[72]^.t,Msg^[19]^.t+Msg^[72]^.t+Msg^[21]^.t);
    BarfExit;
    end;

  ScanFiles:=lo(derror)=0;

  if not cfg.ansi then AWrite(Msg^[22]^.t);

  end;

Function CheckForGif(fs:string;var width,height,colors:word):boolean;
  type GifHdrType = record
        ID     : array[1..6] of char;
        rwidth : word;
        rheight: word;
        colorb : byte;
        end;

  var f     :file;
      GifHdr:GifHdrType;
      bpp   :byte;
  begin
  fillchar(GifHdr,Sizeof(GifHdr),' ');
  assign(f,fs);




  reset(f,1);
  if filesize(f)<sizeof(gifhdr) then { bail out ! }
    begin
    CheckForGif:=False;
    close(f);
    Exit;
    end;


  blockread(f,GifHdr,sizeof(gifhdr));
  close(f);

  if ((GifHdr.ID[1]='G') and (GifHdr.ID[2]='I') and (GifHdr.ID[3]='F') and
      (GifHdr.ID[4]='8') and (GifHdr.ID[5]='7') and (GifHdr.ID[6]='a')) then
     begin
     Width :=GifHdr.rWidth;
     Height:=GifHdr.rHeight;
     BPP:=GifHdr.ColorB and 7 +1;
     If BPP=1 then Colors:=2 else Colors:=1 shl BPP;
     CheckForGif:=True;
     end
   else CheckForGif:=False;

  end;

Function UnCompressFile(filepath:string;var broken,Sfx:boolean):boolean;
  var tempfile :file;
      uncompstr:string;
      p        :string;
      bffr     :array[1..NumOfIDBytes] of byte;
      derror   :integer;

  var tts:string;

  Procedure WhichFormat;
    var cur      : ToArcDefType;

    function match:boolean;
     var i:byte;
     begin
     for i:=1 to NumOfIDBytes do
      if Cur^.IDBlock[i].Used then
       begin
       if not (bffr[i]=Cur^.IDBlock[i].Val) then
         begin
         Match:=False;
         Exit;
         end;
       end;
     Match:=true;
     end;

    begin
    { set uncompstr to '' for unrecognized compression }
    UnCompStr:='';

    Cur:=ArcDefRoot;

    while cur<>nil do
      begin
      if Match then begin
       UnCompStr:=Cur^.Prog;
       Sfx:=Cur^.Sfx;
       ArcP:=Cur^.ProgID;
       P:=Cur^.param;
       end;

      Cur:=Cur^.Next;
      end;
    end;

  var SizeToRead:word;

  begin

  assign(tempfile,filepath);
  reset(tempfile,1);

  if filesize(tempfile)<sizeof(bffr) then
      begin
      fillchar(bffr,sizeof(bffr),#0);
      sizetoread:=filesize(tempfile)-1;
      end
  else SizeToRead:=Sizeof(Bffr);

  blockread(tempfile,bffr,sizetoread);
  close(tempfile);

  Sfx:=false;

  WhichFormat;

  if UnCompStr='' then
     begin
     Broken:=False;
     UnCompressFile:=False;
     Exit;
     end;


   uncompstr:=FSearch(UnCompStr,GetEnv('PATH'));
   if uncompstr='' then
     begin
     writeln(log,DtTmStamp,Msg^[70]^.t,casestr(User.Name),Msg^[73]^.t,ArcP,Msg^[23]^.t);
     AWriteln(Msg^[24]^.t+ArcP+Msg^[25]^.t);
     BarfExit;
     end;

  if cfg.ansi then
    begin
    Agotoxy(Length(Msg^[40]^.t)+11,curline,wherey);
    ASettextcolor(cfg.colorchart[altcolor],black);
    AWrite(Msg^[24]^.t+ArcP+Msg^[26]^.t);AsyncCrt.clreol;
    end
  else AWrite(Msg^[24]^.t+ArcP+Msg^[26]^.t);

  tts:=fexpand(ABCfg.ProgPath+Msg^[17]^.t);

  mkdir(tts);
  chdirect(ABCfg.ProgPath+Msg^[17]^.t);

  if abcfg.splitscreen then PreexecWindow(shortpath(uncompstr),shortpath(p)+Msg^[72]^.t+shortpath(filepath)+
       Msg^[72]^.t+Msg^[27]^.t,cfg.colorchart[inverse],cfg.colorchart[background]);

  if ABCfg.splitscreen then
    execwindow(uncompstr,p+Msg^[72]^.t+filepath+Msg^[72]^.t+Msg^[27]^.t,TopX,TopY,BotX,BotY,cfg.colorchart[normal])
  else
    exec(uncompstr,p+Msg^[72]^.t+filepath+Msg^[72]^.t+Msg^[27]^.t);

  if abcfg.splitscreen then PostExecWindow(cfg.colorchart[background]);

  derror:=dosexitcode;

  if not (hi(derror)=0) then
    begin
    if cfg.ansi then
       begin
       Agotoxy(Length(Msg^[40]^.t)+11,curline,wherey);
       ASettextcolor(cfg.colorchart[Errcolor],black);
       AWrite(Msg^[21]^.t);AsyncCrt.clreol;
       end
    else AWrite(Msg^[21]^.t);
    writeln(log,DtTmStamp,Msg^[70]^.t,casestr(User.Name),Msg^[73]^.t,'Msg^[24]^.t'+Arcp+Msg^[72]^.t+Msg^[21]^.t);
    BarfExit;
    end;


  UnCompressFile := DError=0;
  Broken:=Not (DError=0);

  if not cfg.ansi then AWrite(Msg^[22]^.t);

  chdirect(copy(Abcfg.ProgPath,1,Length(Abcfg.ProgPath)-1));

  if not broken then
    writeln(log,DtTmStamp,Msg^[68]^.t,casestr(User.Name),Msg^[73]^.t+Msg^[72]^.t,Msg^[28]^.t,SplitFilename(filepath),
           Msg^[72]^.t+Msg^[24]^.t,ArcP,Msg^[29]^.t)
  else
    writeln(log,DtTmStamp,Msg^[70]^.t,casestr(User.Name),Msg^[73]^.t+Msg^[72]^.t,Msg^[28]^.t,SplitFilename(filepath),
           Msg^[72]^.t+Msg^[30]^.t+Msg^[24]^.t,ArcP,Msg^[26]^.t);
  end;

procedure FixDesc4Graf(f:string;h,w,c:word);
  var a:word;
     tc:char;
      l:byte;
      i:byte;
  begin
  {s} if (((c>16) and ((h>480) or (w>640))) or ((h>480) or (w>640)))
                                               then tc:=Msg^[77]^.t[1]

  {v}   else if (c>16) then                    tc:=Msg^[78]^.t[1]
  {e}    else if (c>4) then                    tc:=Msg^[79]^.t[1]
  {c}     else                                 tc:=Msg^[80]^.t[1];

    Open_Upfile(ABCfg.ConfigPath);
    Read_Upfile;
    if not (UpRec.Count=0) then
       for a:=1 to UpRec.Count do
         begin
         if UpRec.files[a].Name=Upcasestr(f) then
           begin
           Case ABCfg.ShowGifRes of
            NO        :;  { do nothing }
            VideoMode :Insert(tc+Msg^[73]^.t,UpRec.files[a].Descrip,1);
            Resolution:if ABCfg.GifResAtB then Insert(ToStr(W)+Msg^[74]^.t+ToStr(H)+Msg^[74]^.t+ToStr(C)+Msg^[73]^.t,
                             UpRec.files[a].Descrip,1)
                    else begin
                         l:=length(ToStr(W)+Msg^[74]^.t+ToStr(H)+Msg^[74]^.t+ToStr(C));
                         for i:=length(UpRec.files[a].eDescrip[2])+1 to 60 do
                             begin
                             UpRec.files[a].eDescrip[2][i]:=' ';
                             end;
                         UpRec.files[a].eDescrip[2][0]:=chr(60);
                         Insert(ToStr(W)+Msg^[74]^.t+ToStr(H)+Msg^[74]^.t+ToStr(C),UpRec.files[a].eDescrip[2],(60-l+1));
                         end;
            end;
           end;
         end;
    write_UpFile;
    Close_UpFile;
  end;


Procedure ProcessFile(var filename:string);
  procedure RePackArchive;
    var
     Dir   : DirStr;
     Name  : NameStr;
     Ext   : ExtStr;
     a     : byte;
     f     : file;
     runstr: string;
     runparmr:string;
     runparmd:string;
     derror: integer;

    begin

    runstr:=FSearch(ReCompress.Prog,GetEnv('PATH'));
    if runstr='' then
     begin
     writeln(log,DtTmStamp,Msg^[70]^.t,casestr(User.Name),Msg^[73]^.t,Msg^[72]^.t,ReCompress.Prog,Msg^[31]^.t);
     AWriteln(ReCompress.Prog+Msg^[32]^.t);
     BarfExit;
     end;

    FSplit(Filename,Dir,Name,Ext);

    if cfg.ansi then
       begin
       Agotoxy(Length(Msg^[40]^.t)+11,curline,wherey);
       ASettextcolor(cfg.colorchart[altcolor],black);

       AWrite(Msg^[34]^.t+ArcP+Msg^[35]^.t+ReCompress.ProgID);AsyncCrt.clreol;

       end
    else AWrite(Msg^[72]^.t+Msg^[72]^.t+ArcP+Msg^[33]^.t+ReCompress.ProgID);

    if not abcfg.splitscreen then
      begin
      writeremote:=false;
      writelocal:=true;
      Awriteln(Msg^[34]^.t+ArcP+Msg^[35]^.t+ReCompress.ProgID);
      writeremote:=true;
      writelocal:=false;
      end;

    chdirect(ABCfg.progpath+Msg^[17]^.t);

    runparmd:=ReCompress.Param+Msg^[72]^.t+shortpath(Cfg.ProgPath+Msg^[37]^.t+Name)+Msg^[72]^.t+Msg^[27]^.t;

    runparmr:=ReCompress.Param+Msg^[72]^.t+Cfg.ProgPath+Msg^[37]^.t+Name+Msg^[72]^.t+Msg^[27]^.t;

    if abcfg.splitscreen then PreExecWindow(shortpath(RunStr),RunParmD,Cfg.ColorChart[inverse],
         cfg.colorchart[background]);

    if ABCfg.splitscreen then
        execwindow(runstr,runparmR,topx,topy,botx,boty,cfg.colorchart[normal])
    else
        Exec(RunStr, RunParmR);

    if abcfg.splitscreen then postexecwindow(cfg.colorchart[background]);

  derror:=dosexitcode;

  if not ((derror)=0) then
    begin
    if cfg.ansi then
       begin
       Agotoxy(Length(Msg^[40]^.t)+11,curline,wherey);
       ASettextcolor(cfg.colorchart[Errcolor],black);
       AWrite(Msg^[21]^.t);AsyncCrt.clreol;
       end
    else AWrite(Msg^[21]^.t);
    writeln(log,DtTmStamp,Msg^[70]^.t,casestr(User.Name),Msg^[73]^.t,Msg^[72]^.t,ReCompress.Prog,Msg^[72]^.t,Msg^[21]^.t);
    BarfExit;
    end;

    assign(f,filename);
    erase(f);

   chdirect(copy(Abcfg.ProgPath,1,Length(Abcfg.ProgPath)-1));

    if not cfg.ansi then AWriteln(Msg^[22]^.t);

    Open_Upfile(fexpand(ABCfg.ConfigPath));
    Read_Upfile;
    if not (UpRec.Count=0) then
       begin
       for a:=1 to UpRec.Count do
         begin
         if {upcasestr(Copy(UpRec.files[a].Name,1,pos('.',
             uprec.files[a].name)-1))}
             upcasestr(splitfilename(uprec.files[a].name))=Upcasestr(Name)
         then UpRec.files[a].Name:=Name+Msg^[39]^.t+ReCompress.progID;
         end;
       end;
    write_UpFile;
    Close_UpFile;

    Filename:=splitfilename(filename)+Msg^[39]^.t+ReCompress.ProgID;

    end;


  var f     :file;
      broken:boolean;
      tempfindstr:string;
      found:boolean;
      GWDTH,GHGHT,GCLRS:word;
      Sfx:boolean;

 procedure PreProcess;
   begin
   if cfg.ansi then
      begin
      ASettextcolor(cfg.colorchart[subcolor],black);
      AWrite(Msg^[40]^.t+ltab(length(splitfilename(filename)),8)+splitfilename(filename)+': ');
      end
   else
      AWrite(Msg^[40]^.t+ltab(length(splitfilename(filename)),8)+splitfilename(filename)+': ');
   if not abcfg.splitscreen then
    begin
    writeremote:=false;
    writelocal:=true;
    awriteln('');
    Awriteln(Msg^[40]^.t+ltab(length(splitfilename(filename)),8)+splitfilename(filename));
    writeremote:=true;
    writelocal:=false;
    end;
   end;

  procedure MsgForScanDupe;
   begin
    if abcfg.scandupe then
     begin
     if Cfg.ansi then
      begin
      Agotoxy(Length(Msg^[40]^.t)+11,curline,wherey);
      ASettextcolor(cfg.colorchart[altcolor],black);
      AWrite(Msg^[41]^.t);AsyncCrt.clreol;
      end;
     if not abcfg.splitscreen then
      begin
      writeremote:=false;
      writelocal:=true;
      Awriteln(Msg^[41]^.t);
      writeremote:=true;
      writelocal:=false;
      end;
     end;
   end;

  procedure MsgForScanningVirus;
   begin
   if cfg.ansi then
    begin
    Agotoxy(Length(Msg^[40]^.t)+11,curline,wherey);
    ASettextcolor(cfg.colorchart[altcolor],black);
    AWrite(Msg^[42]^.t);AsyncCrt.clreol;
    end
   else AWrite(Msg^[43]^.t);
   if not abcfg.splitscreen then
    begin
    writeremote:=false;
    writelocal:=true;
    Awriteln(Msg^[42]^.t);
    writeremote:=true;
    writelocal:=false;
    end;
   end;

  procedure goodfile;
   begin
   if Cfg.ansi then
    begin
    Agotoxy(Length(Msg^[40]^.t)+11,curline,wherey);
    ASettextcolor(cfg.colorchart[altcolor],black);
    AWrite(Msg^[46]^.t);AsyncCrt.clreol;
    Awriteln('');inc(curline);
    end;
   if not abcfg.splitscreen then
    begin
    writeremote:=false;
    writelocal:=true;
    Awriteln(Msg^[46]^.t);
    writeremote:=true;
    writelocal:=false;
    end;
   PruneDir(fexpand(ABCfg.ProgPath+Msg^[17]^.t));
   end;

  procedure NoPassVirus;
   begin
   writeln(log,DtTmStamp,Msg^[76]^.t,casestr(User.Name),Msg^[73]^.t,Msg^[28]^.t,SplitFilename(filename),Msg^[47]^.t);
   if Cfg.ansi then
    begin
    Agotoxy(Length(Msg^[40]^.t)+11,curline,wherey);
    ASettextcolor(cfg.colorchart[altcolor],black);
    AWrite(Msg^[48]^.t);AsyncCrt.clreol;
    Awriteln('');inc(curline);
    end
   else AWriteln(Msg^[72]^.t+Msg^[48]^.t);
   if not abcfg.splitscreen then
    begin
    writeremote:=false;
    writelocal:=true;
    Awriteln(Msg^[48]^.t);
    writeremote:=true;
    writelocal:=false;
    end;
   {$I-}
   assign(f,filename);
   rename(f,ABCfg.BadPath+splitfilename(filename)+splitfileext(filename));
   {$I+}
   if existfile(filename,anyfile) then erase(f);
   PruneDir(fexpand(ABCfg.ProgPath+Msg^[17]^.t));
   end;

  procedure ProcessNoVirus;
   begin
   writeln(log,DtTmStamp,Msg^[68]^.t,casestr(User.Name),Msg^[73]^.t+Msg^[72]^.t,Msg^[28]^.t,
       SplitFilename(filename),Msg^[45]^.t);
   If not(ArcP=ReCompress.ProgID) and NOT SFX then
    begin
    RePackArchive;
    writeln(log,DtTmStamp,Msg^[71]^.t,casestr(User.Name),Msg^[73]^.t+Msg^[72]^.t,Msg^[28]^.t,SplitFilename(filename),
       Msg^[73]^.t,Msg^[72]^.t,
        ArcP,Msg^[33]^.t,ReCompress.ProgID);
    end
   else if not cfg.ansi then AWriteln('');
   end;

  procedure FileAllreadyHere;
   begin
   if cfg.ansi then
     begin
     AGotoXY(Length(Msg^[40]^.t)+11,curline,wherey);
     ASettextcolor(cfg.colorchart[altcolor],black);
     AWrite(Msg^[49]^.t);AsyncCrt.clreol;
     Awriteln('');inc(curline);
     end
   else AWriteln(Msg^[49]^.t);
   if not abcfg.splitscreen then
     begin
     writeremote:=false;
     writelocal:=true;
     Awriteln(Msg^[49]^.t);
     writeremote:=true;
     writelocal:=false;
     end;
   writeln(log,DtTmStamp,Msg^[70]^.t,casestr(User.Name),Msg^[73]^.t,Msg^[72]^.t+Msg^[28]^.t,SplitFilename(filename),
       Msg^[50]^.t);
   assign(f,filename);
   erase(f);

    if existfile(abcfg.progpath+Msg^[17]^.t,anyfile) then
     begin
     PruneDir(fexpand(ABCfg.ProgPath+Msg^[17]^.t));
     end;
   end;

  Procedure BrokenArc;
   begin  { if corrupted archive }
   writeln(log,DtTmStamp,Msg^[70]^.t,casestr(User.Name),Msg^[73]^.t+Msg^[72]^.t,Msg^[28]^.t,Msg^[72]^.t,
          SplitFilename(filename),
   Msg^[72]^.t+Msg^[51]^.t,ArcP,Msg^[52]^.t);
   if cfg.ansi then
     begin
     Agotoxy(Length(Msg^[40]^.t)+11,curline,wherey);
     ASettextcolor(cfg.colorchart[altcolor],black);
     AWrite(ArcP+' Archive Corrupted');AsyncCrt.clreol;
     Awriteln('');inc(curline);
     end
   else Awriteln(Msg^[72]^.t+ArcP+Msg^[53]^.t);
   if not abcfg.splitscreen then
     begin
     writeremote:=false;
     writelocal:=true;
     Awriteln(Msg^[72]^.t+ArcP+Msg^[53]^.t);
     writeremote:=true;
     writelocal:=false;
     end;

   {$I-}
   assign(f,filename);
   rename(f,ABCfg.BadPath+splitfilename(filename)+splitfileext(filename));
   {$I+}
   if existfile(filename,anyfile) then erase(f);

   PruneDir(fexpand(ABCfg.ProgPath+Msg^[17]^.t));

   {assign(f,filename);}
   {erase(f);}
   end;

  Procedure UnknownFormat;
   begin
   writeln(log,DtTmStamp,Msg^[69]^.t,casestr(User.Name),Msg^[73]^.t,Msg^[72]^.t,Msg^[28]^.t,SplitFilename(filename),
         Msg^[72]^.t,Msg^[54]^.t);
   if cfg.ansi then
     begin
     Agotoxy(Length(Msg^[40]^.t)+11,curline,wherey);
     ASettextcolor(cfg.colorchart[altcolor],black);
     AWrite(Msg^[54]^.t);AsyncCrt.clreol;
     Awriteln('');inc(curline);
     end
   else Awriteln(Msg^[54]^.t);
   if not abcfg.splitscreen then
     begin
     writeremote:=false;
     writelocal:=true;
     Awriteln(Msg^[54]^.t);
     writeremote:=true;
     writelocal:=false;
     end;
   end;

  procedure ProcessGif;
   begin
   writeln(log,DtTmStamp,Msg^[68]^.t,casestr(User.Name),Msg^[73]^.t,Msg^[72]^.t,Msg^[28]^.t,SplitFilename(filename),
   Msg^[72]^.t,ToStr(GWDTH),Msg^[74]^.t,ToStr(GHGHT),Msg^[74]^.t,ToStr(GCLRS),Msg^[75]^.t);
   if cfg.ansi then
     begin
     Agotoxy(Length(Msg^[40]^.t)+11,curline,wherey);
     ASettextcolor(cfg.colorchart[altcolor],black);
     AWrite(ToStr(GWDTH)+Msg^[74]^.t+ToStr(GHGHT)+Msg^[74]^.t+ToStr(GCLRS)+Msg^[75]^.t);AsyncCrt.clreol;
     Awriteln('');inc(curline);
     end
   else Awriteln(ToStr(GHGHT)+Msg^[74]^.t+ToStr(GCLRS)+Msg^[75]^.t);
   if not abcfg.splitscreen then
     begin
     writeremote:=false;
     writelocal:=true;
     Awriteln(ToStr(GHGHT)+Msg^[74]^.t+ToStr(GCLRS)+Msg^[75]^.t);
     writeremote:=true;
     writelocal:=false;
     end;
   FixDesc4Graf(splitfilename(filename)+splitfileext(filename),GHGHT,GWDTH,GCLRS);
   end;

  procedure RejectFile;
   begin
   if cfg.ansi then
     begin
     Agotoxy(Length(Msg^[40]^.t)+11,curline,wherey);
     ASettextcolor(cfg.colorchart[altcolor],black);
     AWrite(Msg^[55]^.t);AsyncCrt.clreol;
     Awriteln('');inc(curline);
     end
   else Awriteln(Msg^[55]^.t);
   if not abcfg.splitscreen then
     begin
     writeremote:=false;
     writelocal:=true;
     Awriteln(Msg^[55]^.t);
     writeremote:=true;
     writelocal:=false;
     end;
   writeln(log,DtTmStamp,Msg^[70]^.t,casestr(User.Name),Msg^[73]^.t+Msg^[72]^.t,Msg^[28]^.t,SplitFilename(filename),
          Msg^[72]^.t+Msg^[55]^.t);

   KillFileSpec(filename);
   end;

  procedure AddFileProc(s:string);
   var cur: ToFileProcessed;
   begin
   cur:=FileProcRoot;

   if cur<>nil then
     while (cur^.next<>nil) do
      begin
      cur:=cur^.next
      end;

   if cur<>nil then begin new(cur^.next);
               cur:=cur^.next; end
         else new(cur);

   cur^.next:=nil;
   cur^.name:=upcasestr(s);

   if FileProcRoot=Nil then FileprocRoot:=Cur;
   end;

  begin  { main file processing code }
  KillOpenWorkDir;
  PreProcess;
  if NOT CheckReject(splitfilename(Filename)+splitfileext(filename)) then
   if UnCompressFile(filename,Broken,Sfx) then
     begin
     MsgForScanDupe;

     if not SFX then tempfindstr:=upcasestr(splitfilename(filename)+Msg^[39]^.t+ArcP)
      else tempfindstr:=upcasestr(splitfilename(filename)+splitfileext(filename));

     if not FileInSlbbs(tempfindstr) then
      begin
      MsgForScanningVirus;

      {$IFDEF DEBUG}
      if true then
      {$ENDIF}

      {$IFNDEF DEBUG}
      If ScanFiles then
      {$ENDIF}
         begin
         ProcessNoVirus;
         GoodFile; {done with good processed file }
         end
      else NoPassVirus;
      end
     else FileAllreadyHere; { if file is in bbs allready }
     end
    else
     begin { bad uncompression }
     if Broken then BrokenArc
     else
        begin  { no or unsupported compression }
        tempfindstr:=upcasestr(splitfilename(filename)+splitfileext(filename));
        MsgForScanDupe;
        if FileInSlbbs(tempfindstr)then
          FileAllreadyHere
        else
            if not CheckForGif(filename,GWDTH,GHGHT,GCLRS) then UnKnownFormat
              else ProcessGif
        end
     end
  else RejectFile;

  AddFileProc(splitfilename(filename)+SplitFileExt(filename));

  end;

Procedure LoadArchiveDef;
  type bt = array[1..2048] of byte;
  Var Cur: ToArcDefType;
      ADF: text;
      cl : string;
      b  : ^bt;

  procedure ProcessLine;
    var hdr:string[20];
        i  : byte;

    procedure Seek(a:char); begin cl:=copy(cl,pos(a,cl)+1,length(cl)); { seek to " } end;

    procedure Clean(a:char); begin cl:=copy(cl,pos(a,cl)+1,length(cl)) end;

    begin
    cl:=rtrim(ltrim(cl));
    if cl[1]<>';' then
      begin
      hdr:=upcasestr(copy(cl,1,pos(':',cl)));

      if copy(hdr,1,2)=copy(msg^[44]^.t,1,2) then {'UN'}
        begin
        if cur=nil then
             begin
             new(cur);
             cur^.next:=nil;
             ArcDefRoot:=Cur;
             end
          else
            begin
            new(cur^.next);
            cur:=cur^.next;
            cur^.next:=nil;
            end;

        Seek('"');
        Cur^.ProgID:=copy(cl,1,pos('"',cl)-1);
        Clean('"');

        Seek('"');
        Cur^.Prog:=Copy(cl,1,pos('"',cl)-1);
        clean('"');

        Seek('"');
        Cur^.Param:=copy(cl,1,pos('"',cl)-1);
        Clean('"');

        For i:=1 to NumOfIDBytes do Cur^.IDBlock[i].Used:=false;

        For i:=1 to NumOfIDBytes do
         begin
         seek('$');
         if length(cl)>0 then
           begin
           if copy(cl,1,2)<>'--' then
             begin
             Cur^.IDBlock[i].Val:=Hex2Byte(copy(cl,1,2));
             Cur^.IDBlock[i].used:=true;
             end
           else Cur^.IDblock[i].used:=false;
           delete(cl,1,2);
           end;
         end;

        if hdr=msg^[86]^.t then Cur^.SFX:=true else Cur^.SFX:=false;
        end
      else
       if HDR=msg^[38]^.t then
        begin
        seek('"');
        ReCompress.ProgID:=copy(cl,1,pos('"',cl)-1);
        clean('"');

        Seek('"');
        ReCompress.Prog:=copy(cl,1,pos('"',cl)-1);
        Clean('"');

        seek('"');
        ReCompress.Param:=copy(cl,1,pos('"',cl)-1);
        clean('"');

        end;
     end;
    end;

  begin
  new(b);
  ArcDefRoot := nil;
  cur:=ArcDefRoot;

  if not existfile(ABCfg.progpath+msg^[36]^.t,anyfile) then
   begin
   writeln(log,DtTmStamp,Msg^[70]^.t,casestr(User.Name),msg^[87]^.t);
   halt(1);
   end;

  Assign(adf,ABCfg.progpath+msg^[36]^.t);
  reset(adf);
  settextbuf(adf,b^,sizeof(b^));

  readln(adf,cl);
  processline;

  while not eof(adf) do
     begin
     Readln(adf,cl);
     processline;
     end;

  close(adf);
  Dispose(b);
  end;


Function AllReadyDone(s:string):boolean;
  var cur:ToFileProcessed;
 begin
 cur:=fileprocroot;
 Allreadydone:=false;
 while cur<>nil do
   begin
   if upcasestr(cur^.name)=upcasestr(s) then begin
      Allreadydone:=true;
      exit;
      end;
   cur:=cur^.next;
   end;
 end;

var DosRec: SearchRec;
    mpath : string;
    pfn   : string;

begin
 loadsysstr;

 CheckForHack;

 LoadRejectList;

 if Paramcount>0 then
   if upcasestr(paramstr(1))=Msg^[56]^.t then
    ConfigProgram;

 InitVars;
 filemode:=66;

 OpenFiles;

 CheckKey;

 LoadArchiveDef;

 UsingAsync:=Cfg.RsActive;
 portnum:=cfg.comport;

 {$IFNDEF DEBUG}

 InitAsync(Cfg.Comport);

 {$ENDIF}

 writelocal:=true;

 clrlocalscr;

 If cfg.ansi then
   begin
   Curline:=1;

   ClrAllScr;

   AGotoxy(1,curline,wherey);

   ASettextcolor(cfg.colorchart[altcolor],black);
   AWrite(logo1);

   ASetTextColor(cfg.colorchart[normal],black);
   AWriteln(logo2);
   end
 else writeln(logo1+logo2);

 Curline:=2; { init val }
 if cfg.ansi then AGotoxy(1,curline,wherey);

 mpath:=ABCfg.ConfigPath+Msg^[37]^.t;

 writelocal:=abcfg.splitscreen;

 if REG or (upcasestr(User.Name)=Msg^[90]^.t) then
   begin
   FindFirst(mpath+Msg^[27]^.t,AnyFile,DosRec);
   While DosError=0 do
    begin
    pfn:=mpath+dosrec.name;
     if not((DosRec.name='.') or (DosRec.Name='..')) and Not Allreadydone(dosrec.name)
        then ProcessFile(pfn);
    FindNext(DosRec);
    end;
   end;

  WriteLocal:=true;

  Awriteln('');

  if cfg.ansi then ASetTextColor(cfg.colorchart[normal],black);

  AWriteln(logo1+ Msg^[57]^.t+version+Msg^[72]^.t+Done1);

  if cfg.ansi then ASettextColor(cyan,black);

  if Reg then AWrite(Msg^[88]^.t);

  If Cfg.Ansi then ASetTextColor(yellow,black);

  if Reg then AWriteln(RegTo) else Awriteln(Msg^[89]^.t);

  CloseFiles;
end.

