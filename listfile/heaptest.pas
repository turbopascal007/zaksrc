{ Lists files as does sldir. }

{$A+} {$B-} {$I+} {$L-} {$R-} {$S-} {$V-}

Program Listfile;

Uses Dos, Crt, Filedef, SlFiles, Etc;

Const
  Version  = '1.1';
  Author   = 'Zak Smith';
  ProgName = 'ListFiles';
  BragLine = '...Via '+ProgName+' v'+Version+' by '+Author;

  BBSBragFileName = 'Listfile.txt';


const
   days : array [0..6] of String[9] =
      ('Sunday','Monday','Tuesday',
       'Wednesday','Thursday','Friday',
       'Saturday');

   months: array [1..12] of string[15] =
       ('January','February','March','April','May','June','July',
        'August','September','October','November','December');



var
   {  Vars for Files  }

   TMark    :longint;

   TotalNumOfFiles: longint;

   outfilen : string;

   ShowStuff: boolean;

   Out      : text;
   Dir      : dirtype;       {the dir}
   Dirsetup : SetupData;

   exclude  : string;
   include  : string;
   searchstr: string;
   lowaccess: integer;

procedure show_file;
  var
      size: string[12];
      m   : string[2];
      d   : string[2];
      y   : string[2];
      t   : string[4];
      fs  : string[1];

      ttm : longint;

  begin
  inc(Totalnumoffiles);

   if OutFileN<>'' then

    if (totalnumoffiles mod 20)=0 then
       begin
       ttm:=nowsecondssincemidnight;
       gotoxy(22,wherey);
       write( '(',(Totalnumoffiles / dirhdr.root.entries * 100):5:1,'%) ');

       if ttm-tmark>0 then Write('(',(TotalNumOfFiles div (ttm-Tmark)):2,' files/sec)');

       clreol;
       end;


   if (dir.offline) AND (dir.passwd[1]<>0) AND
                        (dir.passwd[2]<>0) AND
                        (dir.passwd[3]<>0) then
    fs := '*'
   else
     if (NOT dir.offline) and (dir.passwd[1]<>0) AND
                              (dir.passwd[2]<>0) AND
                              (dir.passwd[3]<>0) then
     fs := '+' else fs := '';

   str(dir.date.month:2,m);
   str(dir.date.day  :2,d); if d[1]=' 'then d[1] := '0';
   str(dir.date.year :2,y); if y[1]=' 'then y[1] := '0';

   Writeln(Out,Dir.Name,tab(ord(dir.name[0]),12),' ',(dir.length*128/1024):7:1,'k',
          dir.times:4,' ',m,'-',d,'-',y,' ',dir.descrip);


   if Dir.EDescrip[1][0] <> #0 then
      begin
      write(Out,'         ');writeln(Out,dir.edescrip[1]);
      write(Out,'         ');writeln(Out,dir.edescrip[2]);
      writeln(Out);
      end;
  end;

function checkin: boolean;
  begin
  checkin := (pos(searchstr,upcasestr(concat(dir.name,dir.descrip,
         dir.edescrip[1],dir.edescrip[2])))>0);
  end;

procedure ClimbTree_Dir(rec:longint); {recursive..}
  var Right     : longint;     {saved right pointer}
      Left      : longint;     {saved left  pointer}

  begin

  if rec <> 0 then             {in case it is 0, so it does not crash}
    begin

    Read_Dir(rec, Dir);

    Right := Dir.leaf.Right; {save the two pointers}
    Left := Dir.leaf.left;

    if Left <> 0 then ClimbTree_Dir(Left); {go left}

    if Left<>0 then Read_dir(Rec,Dir);

    if SearchStr = '' then show_file
    else if checkin then Show_File;

    if Right <> 0 then ClimbTree_Dir(Right); {go right}

    end;
  end;


procedure Process_Dir(path:string;dirname:string);
  var AccessStr : string[3];
      FreeStr   : string[4];
      ValStr    : string[5];
      NumOffiles: string[4];
      TTM       : longint;
  begin
  Open_Dir(path,dirname);
  Read_Dir_GenHdr;
  Read_Dir_Hdr;

  TotalNumOfFiles:=0;

  if OutFileN<>'' then begin
     Gotoxy(1,wherey);write('Processing: ',tab(length(dirname),8),Dirname);clreol;
     Tmark:=Nowsecondssincemidnight;
     end;

  if ShowStuff then
   begin
   Writeln(Out);
   writeln(Out,'ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·');
   Writeln(Out, #186, ' Directory ',dirname:8,' -> ',
            dirhdr.name,tab(ord(dirhdr.name[0]),40),' - ',DirHdr.Root.Entries:4,' files ',#186);
   Writeln(Out, #186, ' Access level needed: ',DirHdr.Access:3,',   Free from Ratio:',DirHdr.Free:4,'k',
           ',   Value multiplier: ',(DirHdr.Value / 10):4:1,' ',#186);
   writeln(Out,'ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½');
   writeln(Out);
   end;

  Climbtree_Dir(DirHdr.Root.Treeroot);
  Close_Dir;

   if OutFileN<>'' then
       begin
       ttm:=nowsecondssincemidnight;
       gotoxy(22,wherey);
       write( '(',(Totalnumoffiles / dirhdr.root.entries * 100):5:1,'%) ');

       if ttm-tmark>0 then Write('(',(TotalNumOfFiles div (ttm-Tmark)):2,' files/sec)');

       clreol;
       writeln;
       end;

  end;

procedure Parse;
  { Listfile access /dir -dir =string !NOT $filename}
  var idx : integer;
      d   : boolean;
      t   : char;
      s   : string;
      a   : integer;
      l   : string;
      code: integer;

  begin
  d := false;
  idx := 0;

  Include   := '';
  Exclude   := '';
  SearchStr := '';
  outfilen  := '';
  LowAccess := 0 ;
  ShowStuff := true;

  if Paramcount = 0 then
     begin
     end
  else
     begin
     repeat
        begin
        inc(idx);
        if Idx <= ParamCount then
         begin
         s := paramstr(idx);

         for a := 1 to ord(s[0]) do s[a] := upcase(s[a]);

         t :=  S[1] ;
          case T of
           '$':
                begin
                OutFilen := copy(s,2,length(s)-1);
                end;

           '/':
                begin
                Include := concat(include,' ',copy(s,2,length(s)-1));
                end;
           '-':
                begin
                exclude := concat(exclude,' ',copy(s,2,length(s)-1));
                end;
           '=':
                begin
                SearchStr := copy(s, 2, length(s)-1);
                end;
           '!':
                begin
                if upcasestr(copy(s,2,length(s)-1)) = 'NOT' then
                  ShowStuff := False;
                end;
           else
                begin
                val(s,lowaccess,code);
                end;
           end;

         end { idx < para.. }
         else d := true;
        end; { repeat.. }
     until d;

     end;

  end;


procedure ClimbTree_Dirsetup(rec:longint);
  var Right     : longint;     {saved right pointer}
      Left      : longint;     {saved left  pointer}

  begin

  if rec <> 0 then             {in case it is 0, so it does not crash}
    begin

    Read_Setup_Data(rec, DirSetup);

    Right := DirSetup.leaf.Right; {save the two pointers}
    Left := DirSetup.leaf.left;

    if Left <> 0 then ClimbTree_DirSetup(Left); {go left}

    Read_Setup_Data(Rec,DirSetup);

    { if it's Higher and not in exclude then... }

    { or if its included then no matter what }

    if   ((DirSetup.Access>=LowAccess) AND
          (Pos(UpcaseStr(DirSetup.Name),Exclude) = 0) AND
          ((Include = '') or ((pos(upcasestr(dirsetup.name),include))>0))
       or
         (Pos(UpCaseStr(DirSetup.Name),Include) > 0))

      then
       Process_Dir(DirSetup.Path, DirSetup.Name);

    if Right <> 0 then ClimbTree_DirSetup(Right); {go right}

    end;
  end;


procedure Intro_Brag;
 var Year, Month, Day, DayW, Hour, Min, Sec, hSec: Word;
 var ts: string[1];
 begin
 getdate(Year, Month, Day, DayW);

 if day < 10 then ts := ' ' else ts:='';

 if ShowStuff then
   begin
   writeln(Out,'ÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸');
   Writeln(Out,#179,' Files available on ',cfg.systemname,' as of ',copy(Days[dayw],1,4),'. ',
        copy(Months[Month],1,4),'. ',Day,', ',year,
        tab(ord(cfg.systemname[0]),30),ts,#179);
   writeln(Out,#179,' ',tab(length(bragline),75),bragline,' ',#179);
   writeln(Out,'ÔÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¾');
   end;
 end;

procedure BBS_Brag;
 var BBSBrag  : text;
     templine : string;
 begin
 If Existfile(cfg.textpath+BBsBragFileName) then
   begin
   assign(BBSBrag,cfg.textpath+BBSBragFileName);
   reset(BBSBrag);
   repeat
     begin
     readln(bbsbrag,templine);
     writeln(Out,Templine);
     end;
   until eof(BBSBrag);
   close(bbsbrag);
   end;
 end;


var tmark2:longint;

begin
  directvideo:=true;


  Filemode := 66;

  tmark2:=nowsecondssincemidnight;


  PathtoConfig := '';
  Parse;

  Totalnumoffiles:=0;

  Assign(Out, OutFileN);
  rewrite(Out);
  writeln;
  Writeln('ListFile - "The Superior" File Lister for SLBBS');

  Open_Config;
  Read_Config;
  Close_Config;

  if ShowStuff then
   begin
   BBS_brag;
   Intro_Brag;
   end;

  Open_setup(setupdir);
  Read_setup_GenHdr;
  Read_setup_Hdr;

  ClimbTree_Dirsetup(SetupHdr.Root.Treeroot);

  Close_setup;

  Close(out);

  writeln(nowsecondssincemidnight-tmark2);

end.

