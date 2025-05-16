{$M 32768,50000,50000}

Program SlView;

Uses ExitErr, Dos, Crt, SlfLow, SlfHigh, Etc, UnArc, Modem, ZSLKey;

{$DEFINE BETA}

{$IFDEF BETA}
 Const Ver: String[40] = '0.82á [ BETA ]';
{$ELSE}
 Const Ver: String[5] = '0.82';
{$ENDIF}

const PC: string[26] = '666,2112,42,DNAR_NYA,HSUR';

Var User      : UserType;
    CurDirName: String;

    sx,sy     :byte;

    logofftime:word;
    reg       :boolean;
    sln       :word;
    regto     :string;

Procedure CheckKey;
  var s:string;
      n:word;
  begin

  sln:=slnumber;

  if sln=0 then
    begin
    writeln;
    writeln('I cannot find LOGIN.EXE in Primary Program Path: ',cfg.progpath);
    writeln('Cannot verify Registration number');
    end;

  progcode := PC;
  KeyFileName:='SLVIEW';

  Reg:=ReadKeyOK(RegTo,n);

  if reg and not(n=sln) then
    begin
    writeln('not registered to this sl number');
    halt(500);

    end

  end;


function timecheck: boolean;
  begin
  timecheck := nowmins < logofftime;
  end;

function ccheck: boolean; far;
  begin
  if not timecheck then
    begin
    ccheck := false;
    exit;
    end;
  ccheck := carrierdetect or not cfg.rsactive;
  end;

procedure windowon;
 var x,y:byte;
 begin
 x:=wherex;
 y:=wherey;
 if y=25 then y:=24;
 gotoxy(1,25);

 comtoggle;

 textbackground(red);
 textcolor(white);
 write(' SLView        ');
 write(user.name);

 write('    ..',(logofftime div 60):2,':',(logofftime mod 60):2);

 clreol;
 textbackground(black);

 comtoggle;

 window(1,1,80,24);
 gotoxy(x,y);
 end;

procedure windowoff;
 var x,y:byte;
 begin
 x:=wherex;
 y:=wherey;
 window(1,1,80,25);

 comtoggle;
 gotoxy(1,25);
 clreol;
 comtoggle;

 gotoxy(x,y);
 end;


Procedure WhichKindOfArc(s:string);far;
  begin
  writeln;
  writeln('Un-',s,'ing File, Please Wait ... ');
  writeln;
  end;

Procedure PostExec;far;
 begin
 windowon;
 end;

Procedure PreExec;far;
 begin
 windowoff;
 end;


Procedure ExecProc(c,p:string);far; { for unarc }
 var tv:integer;
 begin

 if cfg.ansi then textbackground(blue);
 if cfg.ansi then textcolor(yellow);
 write(' $ ');
 if cfg.ansi then textcolor(white);
 write(c,' ',p);
 if cfg.ansi then write(ltab(3+1+length(c)+length(p),79));
 if cfg.ansi then textbackground(black);
 writeln;

 exec(c,p);

 tv:=dosexitcode;

 if tv<>0 then
   begin
   writeln('ErrHi: ',hi(tv),' ErrLo: ',low(tv));
   writeln('Report this error to sysop and press enter to continue');
   readln;
   writeln;
   exit;
   end;

 if cfg.ansi then clrscr;

 writeln;
 end;

procedure neatline(c:word);
 const a: array[1..4] of byte = (Blue,lightblue,lightgray,white);
 var i,j:byte;
 begin
 for i:=1 to 4 do
   begin
   textcolor(a[i]);
   for j:=1 to (c div 4) do write('Ä');
   end;
 end;


Procedure title;
 begin
 neatline(79);
 end;


Procedure PrintDir2;
 function datestr(s:searchrec):string;
  var d:datetime;
      t:string;
  begin
  unpacktime(s.time,d);
  t:=tostr2(d.year,4)+ '-' + tostr2(d.month,2) + '-' + tostr2(d.day,2) +
   ' ' + tostr2(d.hour,2) + ':' + tostr2(d.min,2) + ':' + tostr2(d.sec,2);
  datestr:=t;
  end;


 var s:searchrec;
     c:byte;
 begin
 c:=0;
 if cfg.ansi then clrscr;
 title;
 writeln;
 if cfg.ansi then textcolor(lightgray);
 findfirst('.\TEMP$$.$$\*.*',$3f,s);
 while doserror=0 do
   begin
   if s.name[1]<>'.' then
      begin
      if cfg.ansi then
        begin
         case (c mod 2) of
           0: textcolor(cyan);
           1: textcolor(green);
         end;
        end;
      write(s.name,ltab(length(s.name),13),s.size:6,' ',datestr(s));

      inc(c);
      if (c mod 2)>0 then
        begin
        if cfg.ansi then
          begin
          textcolor(white);write('³');
          end
        else
          begin
          write(' ');
          end
        end;

      if (c mod 2)=0 then writeln;

      if (c mod (23*2))=0 then
       begin
       if cfg.ansi then textcolor(white);
       write('More? (Yes No)');
       if upcase(readkey)='N' then break;
       if not ccheck then exit;
       write(#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8);
       write('              ');
       write(#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8);
       if cfg.ansi then textcolor(lightgray);
       end;
    end;

   findnext(s);
   end;
 writeln;
 writeln;
 end;



Procedure PrintDir;
 var s:searchrec;
     c:byte;
 begin
 c:=0;
 if cfg.ansi then clrscr;
 title;
 writeln;
 if cfg.ansi then textcolor(lightgray);
 findfirst('.\TEMP$$.$$\*.*',$3f,s);
 while doserror=0 do
   begin
   if s.name[1]<>'.' then
      begin
      if cfg.ansi then
        begin
         case (c mod 4) of
           0: textcolor(cyan);
           1: textcolor(green);
           2: textcolor(lightgray);
           3: textcolor(cyan);
         end;
        end;
      write(s.name,ltab(length(s.name),13),s.size:6);

      inc(c);
      if (c mod 4)>0 then
        begin
        if cfg.ansi then
          begin
          textcolor(white);write('³');
          end
        else
          begin
          write(' ');
          end
        end;

      if (c mod 4)=0 then writeln;

      if (c mod (23*4))=0 then
       begin
       if cfg.ansi then textcolor(white);
       write('More? (Yes No)');
       if upcase(readkey)='N' then break;
       if not ccheck then exit;
       write(#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8);
       write('              ');
       write(#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8);
       if cfg.ansi then textcolor(lightgray);
       end;
    end;

   findnext(s);
   end;
 writeln;
 writeln;
 end;


function SubArcName:string;
  var s :string;
      sr:searchrec;
      b :byte;
  begin
  editor(12,s,'',white,blue);
  if not ccheck then exit;

  s:=upcasestr(s);

  write('                       ');

  findfirst('TEMP$$.$$\*.*',anyfile,sr);

  while doserror=0 do
   begin
   if (sr.name[1]<>'.') and (copy(sr.name,1,length(s))=s)  then
    begin
    write(#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8);
    if sr.name=s then
      begin
      write(sr.name);
      subarcname := sr.name;
      exit;
      end;

    if cfg.ansi then textcolor(cyan);

    write(sr.name:13,' ');

    if cfg.ansi then textcolor(white);     write('Y');
    if cfg.ansi then textcolor(lightgray); write(',');
    if cfg.ansi then textcolor(white);     write('N');
    if cfg.ansi then textcolor(lightgray); write(',');
    if cfg.ansi then textcolor(white);     write('Q');
    if cfg.ansi then textcolor(lightgray); write('? ');

    case upcase(readkey) of
      'Y': begin
         subarcname := sr.name;
         exit;
         end;
      'Q': begin
         subarcname := '';
         exit;
         end;
      end;
    if not ccheck then exit;
    end;
   findnext(sr);
   end;
  end;

procedure TypeFile;
 var c:byte;
     fn:string;
     se:string;
      f:text;
      l:string;
 begin
 c:=0;
 writeln;
 write('File to View: ');

 fn:=SubArcName;
 if not ccheck then exit;

 writeln;

 writeln;
 fn:=upcasestr(fn);
 if existfile('TEMP$$.$$\'+fn,anyfile) then
   begin
   se:= splitfileext(fn);
   if (se='.EXE') or (se='.COM') or (se='.GIF') or (se='.BMP') or (se='.OVL') or (se='.OVR') then
      begin
      writeln;
      writeln('`` I''m sorry Dave, I can''t let you do that ''''');
      end
   else
      begin
      if cfg.ansi then textcolor(lightgray);
      assign(f,'TEMP$$.$$\'+fn);
      reset(f);

      readln(f,l);
      while not eof(f) do
        begin
        writeln(l);
        inc(c);
        if (c=23) then
         begin
         if cfg.ansi then textcolor(white);
         write('More? (Yes No)');
         if upcase(readkey)='N' then break;
         if not ccheck then exit;
         write(#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8);
         write('              ');
         write(#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8);
         if cfg.ansi then textcolor(lightgray);
         c:=1;
         end;
        readln(f,l);
        end;

      close(f);
      end
   end
 else writeln('I couldn''t find that file!');
 writeln;

 end;

Function CheckLimits(f:string;setup:setupdata):boolean;
 var tv:word;
     fs:longint;

 begin
 CheckLimits := true;
 fs:=sizeoffilespec(f);
 if (cfg.rsactive and not(user.access.filelevel=255)) then
   begin
   if user.uploads=0 then tv:=1 else tv:=user.uploads;
   if (user.access.ratio>0) and ((((Setup.Value div 10 * fs div 1024)+user.Downloads) div       tv)>user.Access.Ratio)
   then
     begin
     CheckLimits:=false;
     writeln;
     if cfg.ansi then Textcolor(cfg.colorchart[special]);
     writeln('Picking that file would overrun your ratio');
     end;
   end;
  end;


Procedure Download(setup:setupdata;batch:boolean);
 var dszspec:string;
     filen  :string;
     proto  :char;
     ok     :boolean;
     c      :char;
     b      :byte;
     ts     :string;
     tv     :integer;
     nfn    :string;
     src    :string;
     tim    :longint;
     fs     :string;
 begin
 writeln;
 nfn := '';

 if not batch then
  begin
  writeln;
  write('File to Download: ');

  filen := subarcname;
  if not ccheck then exit;

  if not existfile('.\TEMP$$.$$\'+filen,anyfile) then
    begin
    writeln('File Not Found!');
    exit;
    end;

  end;

 if batch and not existfile('TEMP$$.DL\*.*',anyfile) then
   begin
   {prunedir('TEMP$$.DL');}
   exit;
   end;

 if not batch or (batch and existfile('TEMP$$.DL\*.*',anyfile xor directory)) then
  begin

  writeln;
  textcolor(lightgray);
  write('Should I compress the file(s) before you download them? ');
  getchoice(2,'Yes No',white,blue,cyan,b);
  if not ccheck then exit;
  if b=1 then
     begin
     Writeln;
     textcolor(cyan);
     tim := nowsecondssincemidnight;
       nfn := tostr(tim);
       Writeln('PLEASE WAIT -- Creating ',nfn+'.'+compresstype);
       if batch then
       begin
       src := 'TEMP$$.DL\*.*';
       end
     else
       begin
       src := 'TEMP$$.$$\'+filen;
       end;
       if not UnArc.Compress('TEMP$$.$$\'+nfn,src,execproc,preexec,postexec,src) then
       begin
       writeln(src);
       exit;
       end;
       if cfg.ansi then clrscr;
       filen := nfn + '.' + compresstype;
       writeln('New File Name is ',filen);

       batch := false;
       end else writeln;
  writeln;

  if not batch then ts:='TEMP$$.$$\'+filen else ts:='TEMP$$.DL\*.*';

  if checklimits(ts,setup) then
   begin
   Write('Protocol? ');
   Getchoice(4,'Zmodem Ymodem Xmodem Abort',white,blue,cyan,b);
   if not ccheck then exit;
   writeln;
   case b of
     1: c:='z';
     2: c:='b';
     3: c:='x';
     4: begin
        if nfn<>'' then killfilespec('TEMP$$.$$\'+filen);
        exit;
        end;
     end;
   dszspec:=fsearch('GSZ.COM',getenv('PATH'));
   if dszspec='' then dszspec:=fsearch('GSZ.EXE',getenv('PATH'));
   if dszspec='' then dszspec:=fsearch('DSZ.EXE',getenv('PATH'));
   if dszspec='' then dszspec:=fsearch('DSZ.COM',getenv('PATH'));
   if dszspec='' then
     begin
     writeln;
     writeln('GSZ or DSZ not found! Ack!');
     halt(1);
     end;

   fs:=ts;
   if not batch then
      ts:='port '+tostrb(cfg.comport)+' s'+c+' TEMP$$.$$\'+filen
   else
      ts:='port '+tostrb(cfg.comport)+' s'+c+' TEMP$$.DL\*.*';

   writeln(dszspec,' ',ts);

   If cfg.rsactive then
     begin
     comtoggle;

     {tv:=Do_Exec(dszspec,ts,USE_FILE,25000,false);}

     exec(dszspec,ts);
     tv:=dosexitcode;

     ok:=lo(dosexitcode)=0;
     comtoggle;

     while keypressed do readkey;

     if cfg.ansi then clrscr;

     if ok then
        begin
        write('Updating Status... ');

        inc(user.dlcount,1);
        inc(user.downloads,sizeoffilespec(fs) div 1024);

        write_user(cfg.curruser,user);

        end;
     end;
   end;

  end;

 if nfn<>'' then killfilespec('TEMP$$.$$\'+filen);

 end;

procedure MarkFiles(setup:setupdata);
  var s:searchrec;
  begin
  mkdir('TEMP$$.DL');

  writeln;
  writeln;
  if cfg.ansi then textcolor(lightgray);
  findfirst('.\TEMP$$.$$\*.*',$3f,s);
  while doserror=0 do
    begin
    if s.name[1]<>'.' then
      begin
      if cfg.ansi then textcolor(cyan);
      write(s.name,ltab(length(s.name),13),' ');
      if cfg.ansi then textcolor(lightgray);
      write(s.size:6);
      if cfg.ansi then textcolor(lightcyan);
      write('  Mark This File? (Y/N/Q)  ');
      case upcase(readkey) of
       'Y': begin
            if cfg.ansi then textcolor(yellow);writeln('Chosen!');
            copyfile('TEMP$$.$$\'+s.name,'TEMP$$.DL\'+s.name);
            end;
       'Q': begin
            if cfg.ansi then textcolor(magenta);
            writeln('Aborted');
            break;
            end
        else
        begin
        if cfg.ansi then textcolor(magenta);writeln('NOT!');
        end
       end;
      if not ccheck then exit;

      end;
    findnext(s);
    end;
  writeln;
  DownLoad(setup,true);
  prunedir('TEMP$$.DL');
  end;


procedure showhelpscreen;
  begin
  writeln;
  writeln;
  neatline(50);

  writeln;

  if cfg.ansi then textcolor(white);     write  ('    List ');
  if cfg.ansi then textcolor(lightgray); writeln('List files in this Archive');

  if cfg.ansi then textcolor(white);     write  ('    Quit ');
  if cfg.ansi then textcolor(lightgray); writeln('Quit this Archive');

  if cfg.ansi then textcolor(white);     write  ('    Type ');
  if cfg.ansi then textcolor(lightgray); writeln('Type Text Files');

  if cfg.ansi then textcolor(white);     write  ('    Mark ');
  if cfg.ansi then textcolor(lightgray); writeln('Mark Files for Batch Download');

  if cfg.ansi then textcolor(white);     write  ('Download ');
  if cfg.ansi then textcolor(lightgray); writeln('Download Single File from Archive');

  neatline(50);
  writeln;



  end;

Procedure Do_File(filename,sldirname:string);
  var r    :longint;
      setup:SetupData;

      broken,sfx: boolean;
      ErrorS: string;
      c     : byte;
      done  : boolean;
      Flavour:string;

      df  : file;

      fhdr: fileheader;
      hdr : dirheader;

      fd: dirtype;

      pwdstr: string;
      pwd:pwtype;

  begin
  writeln;
  writeln('Please Wait.  Accessing File Data...');

  if not Setup_Info(sldirname,SetupDir,setup) then
    begin
    writeln;
    writeln('Error! -- Sub not found!');
    halt(1);
    end;

  r:=FileInSlDir(filename,sldirname,setup.path);
  if (r=0) then
    begin
    writeln;
    writeln('Error! -- Files not Consistent!');
    halt(1);
    end;

  if not existfile(setup.filepath+filename,anyfile) then
    begin
    writeln;
    writeln('I''m Sorry, that file appears to be offline.');
    exit;
    end;


  init_vardata(df,DirF,setup.path,sldirname,fhdr,hdr);
  read_data(df,dirF,r,fd);
  close_data(df);


  if not(USER.NAME='SYSOP') then
   if hdr.writeonly then
    begin
    writeln;
    writeln('This directory is write only, sorry.');
    exit;
    end;

  if ((fd.passwd[1]<>0) or (fd.passwd[2]<>0) or (fd.passwd[3]<>0))
        and not(USER.NAME='SYSOP') then    begin
    if cfg.ansi then textcolor(cyan);
    write('File is password protected; Enter Password: ');
    if cfg.ansi then textcolor(white);

    pwdstr:=upcasestr(barepasswdinput(30));
    if not ccheck then exit;

    longhash(pwdstr,pwd);

    writeln;

    if (pwd[1]=fd.passwd[1]) and (pwd[2]=fd.passwd[2]) and (pwd[3]=fd.passwd[3]) then
      begin
      if cfg.ansi then textcolor(lightgray);
      writeln('Ok.');
      end
    else
      begin
      if cfg.ansi then textcolor(lightred);
      writeln('Passwords do not match');
      exit;
      end;

    end;


  Write('Continue With Extraction? ');
  getchoice(2,'Yes No',white,blue,cyan,c);
  if not ccheck then exit;
  if c=2 then exit;

  writeln;
  if cfg.ansi then begin clrscr;clrscr end;
  modem.waitout;


  if not UnCompressFile(setup.filepath+filename,WhichKindOfArc,
            ExecProc,PreExec,PostExec,broken,sfx,errors)
  then
    begin
    writeln;
    writeln('Duh! I don''t know that kind of file!');
    exit;
    end;

  while keypressed do readkey;
  if not ccheck then exit;

  if cfg.ansi then clrscr;

  if broken then
   begin
   writeln;
   writeln('Archive if Broken!');
   prunedir('.\TEMP$$.$$');
   exit;
   end;

  Printdir2;
  if not ccheck then exit;

  done:=false;

  writeln;

  GetChoice(6,'List Quit Type Mark Download Help',white,blue,cyan,c);
  while c<>2 do
    begin
    case c of
     2:done:=true;
     1:PrintDir2;
     3:TypeFile;
     4:MarkFiles(setup);
     5:Download(setup,false);
     6:ShowHelpScreen;
     end;
    if not ccheck then exit;
    if not done then GetChoice(6,'List Quit Type Mark Download Help',white,blue,cyan,c);
    if not ccheck then exit;
    end;

  writeln;
  write('Please wait while I clean up all the merde.. ');
  prunedir('.\TEMP$$.$$');
  writeln(' .. Ahh much better...');
  end;


Procedure LookingStatus(s:string);far;
 begin
 if cfg.ansi then
     begin
     gotoxy(10,wherey);
     clreol;
     end
 else
   begin
   write(ltabc(1,wherex-9,#8));
   end;

 write(s);
 end;

function ThisOne(s:string):partialmatchfunctype;far;
 var c:byte;
 begin
 if cfg.ansi then gotoxy(20,wherey)
 else
   begin
   if wherex<20 then write(ltabc(wherex,20,' ')) else write(ltabc(20,wherex,#8));
   end;

 if cfg.ansi then textcolor(white);
 write(s+ltab(length(s),13));
 write(' ');
 if cfg.ansi then textcolor(lightgray);
 getchoice(3,'Yes No Abort',white,blue,cyan,c);
 if not ccheck then exit;
 case c of
  1: ThisOne:=Pick;
  2: ThisOne:=Continue;
  3: ThisOne:=Quit;
  end;
 if cfg.ansi then textcolor(cyan);

 end;


Function ProcessEntry: boolean;

 Procedure Prompt;
   begin
   if cfg.ansi then textcolor(cfg.colorchart[normal]);
   write('[');
   if cfg.ansi then textcolor(cfg.colorchart[special]);
   write(curdirname);
   if cfg.ansi then textcolor(cfg.colorchart[normal]);
   write(']',ltab(ord(curdirname[0]),8));
   if cfg.ansi then textcolor(cfg.colorchart[promptcolor]);
   Write(' Enter Filename: ');
   end;
 var curline:string;
     t:longint;
 begin
 writeln;
 prompt;
 Editor(12, curline, '', white, blue);
 if not ccheck then exit;
 if rtrim(curline)='' then begin ProcessEntry:=false; exit end;
 writeln;
 curline:=upcasestr(curline);

 if cfg.ansi then textcolor(lightgray);
 write('Scanning ');
 if cfg.ansi then textcolor(cyan);

 case Partialmatches(curline,curdirname,ThisOne,LookingStatus,curdirname,curline,t,user.access) of
   Aborted: begin
            writeln;
            writeln('Aborted');
            end;

      None: begin
            writeln;
            if cfg.ansi then textcolor(red);
            writeln('No Match for "',curline,'" found');
            end;

    Picked: begin
            writeln;
            Do_File(curline,curdirname);
            end;

   end;


 end;

procedure cleanshit(p:string);
 begin
 if existfile(p,anyfile) then
   begin
   if cfg.ansi then textcolor(lightred);
   writeln;
   write('Wait while I clean up ',fexpand(p));
   prunedir(p);
   writeln(' . . . Ok better.');
   end;
 end;

procedure badthing;
 const urs:string[30] = 'unregistered';
 const crc:longint = 2081342026;
 var   ccrc: longint;
       u: string[30];
 begin
 u:=urs;
 ccrc := crc32array( ptr(seg(u),ofs(u)),length(u)+1);
 randomize;
 if ccrc<>crc then
   begin
   sound(3000);   delay(20);   nosound;   delay(10);
   sound(3000);   delay(20);   nosound;   delay(10);
   sound(3000);   delay(20);   nosound;   delay(10);
   sound(3000);   delay(20);   nosound;   delay(10);
   sound(3000);   delay(20);   nosound;   delay(10);
   sound(3000);   delay(20);   nosound;   delay(10);
   sound(3000);   delay(20);   nosound;   delay(10);
   sound(3000);   delay(20);   nosound;   delay(10);
   sound(3000);   delay(20);   nosound;   delay(10);
   sound(3000);   delay(20);   nosound;   delay(10);
   sound(3000);   delay(20);   nosound;   delay(10);
   sound(3000);   delay(20);   nosound;   delay(10);
   writeln('HOW DARE YOU HACK ME?');
   repeat until keypressed;
   exit;
   end;

 write(^G);
 for ccrc:= 1 to length(u) do
   begin
   textcolor(random(7)+9);
   if (ccrc mod 2)=1 then write(upcase(u[ccrc])) else write(u[ccrc]);
   textcolor(random(7)+9);
   write(u[ccrc]);
   delay(275);
   write(#8);
   end;
 write(' ',#8)
 end;

Begin

Init_Config( '' , opened );
User_Info(cfg.curruser,user);

checkkey;

ansi:=cfg.ansi;
portcheck:=true;
carrierfunc := ccheck;
useinsert:= false;

if user.access.msglevel>=240 then logofftime := 24*60 else
  begin
  logofftime := (cfg.logtime.hour*60+cfg.logtime.minute)+cfg.timelimit;
  if logofftime>=(24*60) then
    begin
    logofftime := 24*60-1;
    end
  end;

windowon;

DirectVideo:=False;
LoadArchiveDef ( 'archive.cfg' );
cleanshit('.\TEMP$$.$$');
cleanshit('.\TEMP$$.DL');

etc.ansi := cfg.ansi;

if cfg.ansi then textcolor(lightgray);
writeln; writeln;

{$IFNDEF BETAZAK}
if not reg then
{$ENDIF}
  begin
  writeln;
  write('              `` . . . ');
  if cfg.ansi then textcolor(lightred);
  write('We Have Assumed Control');
  if cfg.ansi then textcolor(lightgray);
  write(' . . . ''''');
  if cfg.ansi then textcolor(cyan); write(' -- ');
  if cfg.ansi then textcolor(lightcyan);write('2112');
  writeln;
  end;

CurDirName := cfg.currdir;

if cfg.ansi then textbackground(black);

writeln;
if cfg.ansi then textcolor(cyan);
writeln;

repeat until not ProcessEntry or not ccheck;

cfg.currdir := curdirname;
write_config;
close_config;

writeln;
if cfg.ansi then textbackground(blue);
if cfg.ansi then textcolor(white);
write(' SLView ');
if cfg.ansi then textbackground(black);
if cfg.ansi then textcolor(lightgray);
write(' v'+ver);

if cfg.ansi then textcolor(lightgray);
write(' #');
if cfg.ansi then textcolor(yellow);
write(sln);
if cfg.ansi then textcolor(lightgray);
write(', ');
if cfg.ansi then textcolor(lightcyan);

if reg then
  begin
  write('Registered');
  if cfg.ansi then textcolor(lightgray);write(': ');
  if cfg.ansi then textcolor(cyan); write(regto);
  end else badthing;

if cfg.ansi then textcolor(white);
writeln;
writeln('         (c) copyright 1993 by Zak Smith, all rights reserved');
windowoff
EnD.
