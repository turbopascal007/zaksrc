{ Lists files as does sld. }
{$M 32768,0,655360}

(*{$A+} {$B-} {$I+} {$L-} {$R-} {$S-} {$V-}*) {$X+}

Program ListFile;
Uses SLfLow,SLfHigh,Crt,Etc;

Const
  Version  = '1.04';
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
   ShowNumDL      : boolean;
   TMark          : longint;
   TotalNumOfFiles: longint;
   OutFileN       : string;
   ShowStuff      : boolean;
   Out            : text;

   exclude  : string;
   include  : string;
   searchstr: string;
   lowaccess: byte;

   OneLine  : boolean;
   fhdr: fileheader;
   dirhdr: dirheader;

procedure Parse;
  { Listfile access /dir -dir =string !NOT $filename ONE NDLC }
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

  oneline := false;

  ShowNumDL := true;

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
           'O': begin
                if upcasestr(copy(s,2,length(s)-1)) = 'NE' then
                  OneLine := true;
                end;

           'N': begin
                if upcasestr(copy(s,2,length(s)-1)) = 'DLC' then
                  ShowNumDL := false;
                end;

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

function ShowFile(var f:file;r:longint;d:dirtype):boolean;far;
 function checkin: boolean;
  begin
  checkin := (pos(searchstr,upcasestr(concat(d.name,d.descrip,
         d.edescrip[1],d.edescrip[2])))>0);
  end;

   var
      size: string[12];
      m   : string[2];
      day   : string[2];
      y   : string[2];
      t   : string[4];
      fs  : string[1];
      ttm : longint;
 begin
 if (SearchStr = '') or CheckIn then
  begin
  ShowFile:=True;
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

   if (d.offline) AND (d.passwd[1]<>0) AND
                        (d.passwd[2]<>0) AND
                        (d.passwd[3]<>0) then
    fs := '*'
   else
     if (NOT d.offline) and (d.passwd[1]<>0) AND
                              (d.passwd[2]<>0) AND
                              (d.passwd[3]<>0) then
     fs := '+' else fs := '';
   str(d.date.month:2,m);
   str(d.date.day  :2,day); if day[1]=' 'then day[1] := '0';
   str(d.date.year :2,y); if y[1]=' 'then y[1] := '0';
   if ShowNumDL then
    Write(Out,d.Name,ltab(ord(d.name[0]),12),' ',(d.length*128/1024):7:1,'k',
          d.times:4,' ',m,'-',day,'-',y,' ',d.descrip)
   else
    Write(Out,d.Name,ltab(ord(d.name[0]),12),' ',(d.length*128/1024):7:1,'k',
          ' ',m,'-',day,'-',y,' ',d.descrip);
  if Not OneLine then Writeln(out);
  if OneLine then
    if d.EDescrip[1][0] <> #0 then
      begin
      writeln(out,' ',d.edescrip[1],' ',d.edescrip[2]);
      end
    else writeln(out)
   else
    if d.EDescrip[1][0] <> #0 then
      begin
      write(Out,'         ');writeln(Out,d.edescrip[1]);
      write(Out,'         ');writeln(Out,d.edescrip[2]);
      writeln(Out);
      end;
  end;
 end;


Function ShowDir(p, s:string):boolean;far;
   var AccessStr : string[3];
      FreeStr   : string[4];
      ValStr    : string[5];
      NumOffiles: string[4];
      TTM       : longint;

      dirsetup  : setupdata;

      var f:file;

 begin
 ShowDir:=True;

 Setup_Info(s,setupDir,dirsetup);

     { if it's Higher and not in exclude then... }

    { or if its included then no matter what }

    if   ((DirSetup.Access<=LowAccess) AND
          (Pos(UpcaseStr(DirSetup.Name),Exclude) = 0) AND
          ((Include = '') or ((pos(upcasestr(dirsetup.name),include))>0))
       or
         (Pos(UpCaseStr(DirSetup.Name),Include) > 0))

      then
  begin
  TotalNumOfFiles:=0;

  if OutFileN<>'' then begin
     Gotoxy(1,wherey);write('Processing: ',ltab(length(s),8),s);clreol;
     Tmark:=Nowsecondssincemidnight;
     end;

  if ShowStuff then
   begin

   init_vardata(f,dirF,p,s,fhdr,dirhdr);

 {
0        1         2         3         4         5         6         7
12345678901234567890123456789012345678901234567890123456789012345678901234567890
ÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ
û³ Uploadsx ³ 1234567890123456789012345678901234567890 ³ xxxx files ³ Read/Write/Frozen
ÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÂÄÄÄÄÄÄÄ
ð³ Access: xxx ³ Value Multiplier: xxx ³ xxxk free ³ xxx,xxx,xxx bytes ³
ÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ

x files
x access req.
x readonly writeonly
x value
  free

 }
  if outfilen<>'' then
    begin
    gotoxy(22,wherey);
    write('Scanning ...');
    end;


  writeln(out);
  writeln(out,'ÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ');

  write(out,'û³ ',casestr(s),ltab(length(s),8),' ³ ',dirhdr.name,
          ltab(length(dirhdr.name),40),' ³ ',dirhdr.root.entries:4,' files ³ ');

  if dirhdr.readonly and dirhdr.writeonly then writeln(out,'Frozen')
   else if dirhdr.readonly then writeln(out,'Read')
   else if dirhdr.writeonly then writeln(out,'Write')
   else writeln(out,'Re/Wr');

  writeln(out,'ÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÂÄÄÄÄÄÄÄ');

  writeln(out,'ð³ Access: ',dirhdr.access:3,' ³ Value Multiplier: ', (dirhdr.value / 10):3:1,
         ' ³ ',dirhdr.free:3,'k free ³ ',int2comma(GetBytesInDir(p,s,false),9),' bytes ³');

  writeln(out,'ÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ');
  writeln(out);


  {
   Writeln(Out);
   writeln(Out,'ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·');
   Writeln(Out, #186, ' Directory ',s:8,' -> ',
            dirhdr.name,ltab(ord(dirhdr.name[0]),40),' - ',DirHdr.Root.Entries:4,' files ',#186);
   Writeln(Out, #186, ' Access level needed: ',DirHdr.Access:3,',   Free from Ratio:',DirHdr.Free:4,'k',
           ',   Value multiplier: ',(DirHdr.Value / 10):4:1,' ',#186);
   writeln(Out,'ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½');
   writeln(Out);
  }

   close_data(f);
   end;

   FileList(  s , p , ShowFile );

   if OutFileN<>'' then
       begin
       ttm:=nowsecondssincemidnight;
       gotoxy(22,wherey);
       if not dirhdr.root.entries=0 then
         begin
         write( '(',(Totalnumoffiles / dirhdr.root.entries * 100):5:1,'%) ');
         if ttm-tmark>0 then Write('(',(TotalNumOfFiles div (ttm-Tmark)):2,' files/sec)');
         end;
       clreol;
       writeln;
       end;
  end;
 end;

var tmark2:longint;

begin
  directvideo:=true;
  Filemode := 66;
  tmark2:=nowsecondssincemidnight;
  Init_Config ( '' , Closed );
  Parse;
  Totalnumoffiles:=0;
  Assign(Out, OutFileN);
  rewrite(Out);
  writeln;
  Writeln('ListFile - "The Superior" File Lister for SLBBS');
  if ShowStuff then
   begin
   BBS_brag;
   Writeln(out,bragline);
   end;

  MainSubList( 'MAIN.DIR' , SetupDir , ShowDir );

  Close(out);

  writeln(nowsecondssincemidnight-tmark2);

end.
