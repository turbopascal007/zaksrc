uses exiterr,crt,dos,etc,slflow,slfhigh,sldriv,dates,modem;

const lfn='slnodel.lst';
const nld='slnodel.cfg';

const bs=64000;

const ver:string = '1.0à [ ALPHA Do xxx Distribute ]';

type
     arraytype = record
       num : word;
       list: array[1..50] of string;
       end;

var NLs: ^arraytype;

    u:usertype;
    logofftime:word;

    fulllist: boolean;

    linecount:byte;

    Zone,Region,Net,Node: string[10];

    cns:string[20];

var log:text;


function timecheck: boolean;
 begin
 timecheck := nowmins < logofftime;
 end;

function abort:boolean;
 begin
 if keypressed then abort := upcase(readkey) in [' ',^C] else abort := false;
 end;

function ccheck: boolean; far;
 begin
 if not timecheck then begin
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
 write(' SLNodeL        ');
 write(u.name);

 write('    ..',(logofftime div 60):2,':',(logofftime mod 60):2);

 clreol;
 textbackground(black);

 comtoggle;

 window(1,1,80,24);
 gotoxy(x,y);
 end;

function nodestr:string;
 var t:string;
 begin
 t:=zone + ':' + net + '/' + node;
 nodestr:=t+ltab(length(t),13);
 end;

procedure processnode(s:string);
  begin
  if not(s[1]=',') then
    begin
    if not(s[1]=';') then
      begin
      case s[1] of
        'Z': begin
             Zone := copy(s,nthoc(',',1,s)+1,(nthoc(',',2,s)-nthoc(',',1,s)-1));
             Region := '1';
             Net := '1';
             Node := '0';
             end;
        'R': begin
             Region := copy(s,nthoc(',',1,s)+1,(nthoc(',',2,s)-nthoc(',',1,s)-1));
             Net := Region;
             end;
        'H': begin
             if s[2]='o' then Net := copy(s,nthoc(',',1,s)+1,(nthoc(',',2,s)-nthoc(',',1,s)-1));
             end;
        end;
      end;
    end
  else
    begin
    Node := copy(s,nthoc(',',1,s)+1,(nthoc(',',2,s)-nthoc(',',1,s)-1));
    end;
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

procedure stripunderscores(var st:string);
    var i:byte;
    begin
    for i:=1 to length(st) do if st[i]='_' then st[i]:=' ';
    end;

Procedure Search(t:string);

 function PrintInfo(s:string):boolean;
  var bbsn,sysop,loc,phnum,speed,flags,ts,ts2:string;
  begin
  if fulllist then
   begin
   inc(linecount,3);
   if (linecount mod 22)=0 then
    begin
    if cfg.ansi then textcolor(white);
    write('More? (Yes No)');
    if upcase(readkey)='N' then
      begin
      printinfo := false;
      exit;
      end;
    if not ccheck then exit;
    write(#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8);
    write('              ');
    write(#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8+#8);
    if cfg.ansi then textcolor(lightgray);
    end;
   end;

  bbsn  :=copy(s,nthoc(',',2,s)+1,(nthoc(',',3,s)-nthoc(',',2,s)-1));
  sysop :=copy(s,nthoc(',',4,s)+1,(nthoc(',',5,s)-nthoc(',',4,s)-1));
  loc   :=copy(s,nthoc(',',3,s)+1,(nthoc(',',4,s)-nthoc(',',3,s)-1));
  phnum :=copy(s,nthoc(',',5,s)+1,(nthoc(',',6,s)-nthoc(',',5,s)-1));
  speed :=copy(s,nthoc(',',6,s)+1,(nthoc(',',7,s)-nthoc(',',6,s)-1));
  flags :=copy(s,nthoc(',',7,s)+1,length(s)-nthoc(',',7,s));

  if length(bbsn)>28 then bbsn[0]:=#28;
  if length(loc)>25 then loc[0]:=#25;

  if (pos('MO',flags)=0) and (pos('-UNPUBLISHED-',upcasestr(phnum))=0) and
     (s[1]<>';') then
    begin
    ts:=cns+bbsn+ltab(length(bbsn),28)+phnum+ltab(length(phnum),15)+speed+ltab(length(speed),5)+' ';
    ts2:='     '+sysop+ltab(length(sysop),25)+ loc+ltab(length(loc),25)

;

{
;S           V21       CCITT V21      300 bps full duplex
;S           V22       CCITT V22     1200 bps full duplex
;S           V29       CCITT V29     9600 bps half duplex
;S           V32       CCITT V32     9600 bps full duplex
;S           V32b      CCITT V32bis 14400 bps full duplex
;S           V33       CCITT V33
;S           V34       CCITT V34
;S           V42       LAP-M error correction w/fallback to MNP
;S           V42b      CCITT V42bis
;S           MNP       Microcom Networking Protocol error correction
;S
;S           H96       Hayes V9600
;S           HST       USR Courier HST
;S           H14       USR Courier HST 14.4
;S           H16       USR Courier HST 16.8
;S           MAX       Microcom AX/96xx series
;S           PEP       Packet Ensemble Protocol
;S           CSP       Compucom Speedmodem
;S           ZYX       Zyxel series
}

    if pos('HST' ,flags)>0 then ts:=ts+'HST ';
    if pos('H16' ,Flags)>0 then ts:=ts+'HST16 ';
    if pos('H14' ,flags)>0 then ts:=ts+'HST14 ';
    if pos('V32' ,flags)>0 then ts:=ts+'V32 ';
    if pos('V32B',flags)>0 then ts:=ts+'V32B ';
    if pos('H96' ,flags)>0 then ts:=ts+'HAY96 ';
    if pos('PEP' ,flags)>0 then ts:=ts+'PEP ';
    if pos('CSP' ,flags)>0 then ts:=ts+'CSP ';

    if pos('FDN' ,flags)>0 then ts2:=ts2+'FDN ';
    if pos('G'   ,flags)>0 then ts2:=ts2+copy(flags,pos('G',flags),length(flags)-pos('G',flags)+1)+' ';


    if fulllist then
     begin
     if cfg.ansi then
        begin
        if (pos(upcasestr(t),upcasestr(ts))>0) then
          begin
          textcolor(lightgray);
          write(copy(ts,1,pos(upcasestr(t),upcasestr(ts))-1));
          textcolor(white);
          write(copy(ts,pos(upcasestr(t),upcasestr(ts)),length(t)));
          textcolor(lightgray);
          writeln(copy(ts,pos(upcasestr(t),upcasestr(ts))+length(t),length(ts)-
          pos(upcasestr(t),upcasestr(ts))+length(t)+1));
          end
         else writeln(ts);
        if pos(upcasestr(t),upcasestr(ts2))>0 then
          begin
          textcolor(lightgray);
          write(copy(ts2,1,pos(upcasestr(t),upcasestr(ts2))-1));
          textcolor(white);
          write(copy(ts2,pos(upcasestr(t),upcasestr(ts2)),length(t)));
          textcolor(lightgray);
          writeln(copy(ts2,pos(upcasestr(t),upcasestr(ts2))+length(t),length(ts2)-
          pos(upcasestr(t),upcasestr(ts2))+length(t)+1));
          end
         else writeln(ts2);
        end
     else
        begin
        writeln(ts);
        writeln(ts2);
        end;
     writeln;
     end;

    writeln(log,ts);
    writeln(log,ts2);
    end;

  printinfo := true;
  end;

 function ssingle(fn:string):boolean;
  var buf:pointer;
      f  :text;
      l  :string;
   begin
   ssingle := true;
   getmem(buf,bs);
   assign(f,fn);
   writeln;
   linecount:=1;
   if cfg.ansi then
     begin
     textbackground(red);
     textcolor(lightgray);
     end;
   write(' Scanning ');
   if cfg.ansi then textcolor(white);
   write(casestr(fn),' ');
   if cfg.ansi then textbackground(black);
   if cfg.ansi then textcolor(lightgray);
   writeln;

   filemode:=0;
   reset(f);
   settextbuf(f,buf^,bs);

   readln(f,l);
   while not(eof(f)) do
    begin
    stripunderscores(l);

    ProcessNode(l);

    cns:=nodestr;

    if (pos(t,upcasestr(l))>0)
       or (pos(t,cns)>0) then
      begin
      if not printinfo(l) then
        begin
        ssingle := false;
        break;
        end;
      if not ccheck then
        begin
        ssingle:=false;
        break;
        end;
      end;

    if not fulllist then
     begin
     inc(linecount);
     if (linecount mod 500) = 0 then
      if cfg.ansi then
       begin
       gotoxy(1,wherey);
       write('Zone ',Zone,'   Reg ',region,'   Net ',net,'    ');
       end
      else
       begin
       write(ltabc(1,wherex,#8));
       write('Zone ',Zone,'   Reg ',region,'   Net ',net,'    ');
       end;
     end;

    if abort then
     begin
     ssingle := false;
     break;
     end;

    readln(f,l);
    end;

   close(f);
   freemem(buf,bs);
   end;

 var i:word;
  begin
  t:=upcasestr(t);

  for i:=1 to nls^.num do
    begin
    if not ssingle(nls^.list[i]) then exit;
    if not ccheck then break;
    end;

  end;


function DOThing:boolean;
 var s:string;
     c:byte;
 begin

 writeln;
 write('Enter text to search for: ');
 editor(25,s,'',white,blue);
 if not ccheck then
   begin
   dothing := false;
   exit;
   end;

 if s[0]=#0 then
  begin
  dothing:=false;
  end
 else
  begin
  writeln;
  writeln;
  textcolor(lightgray);
  writeln('Do you want to view the listing online or just download it?');
  getchoice(3,'View DL Quit',white,blue,cyan,c);
  if not ccheck then
    begin
    dothing := false;
    exit;
    end;
  case c of
    1: fulllist := true;
    2: fulllist := false;
    3: begin
       dothing := true;
       exit;
       end;
    end;
  search(s);
  dothing:=true;
  end;

 end;

procedure load_nls;
 procedure addnl(s:string);
  function lastdate(fp:string):string;
   var sr:searchrec;
       d :datetime;
       lsd:longint;
   begin
   lsd:=0;
   lastdate := '';
   findfirst(fp,anyfile,sr);
   while doserror=0 do
    begin
    unpacktime(sr.time,d);
    if serial_day(d.day,d.month,d.year)>lsd then
      begin
      lastdate:=splitfilepath(fp)+sr.name;
      lsd := serial_day(d.day,d.month,d.year);
      end;
    findnext(sr);
    end;

   end;

  var fn:string;
  begin

  fn:=lastdate(s+'.*');
  if fn<>'' then
    begin
    writeln('Adding: ',s);
    inc(nls^.num);
    nls^.list[nls^.num] := fn;
    end;
  end;

 var f:text;
     l:string;
 begin

 assign(f,nld);
 reset(f);

 while not eof(f) do
   begin
   readln(f,l);
   addnl(l);
   end;

 close(f);

 end;

begin

Init_Config( '' , opened );

user_info(cfg.curruser,u);

ansi:=cfg.ansi;
portcheck:=true;
carrierfunc := ccheck;
useinsert:= false;

if u.access.msglevel>=240 then logofftime := 24*60
 else
 begin
 logofftime := (cfg.logtime.hour*60+cfg.logtime.minute)+cfg.timelimit;
 if logofftime>=(24*60) then
  begin
  logofftime := 24*60-1;
  end
 end;

windowon;

DirectVideo:=False;

 write('              `` . . . ');
 if cfg.ansi then textcolor(lightred);
 write('We Have Assumed Control');
 if cfg.ansi then textcolor(lightgray);
 write(' . . . ''''');
 if cfg.ansi then textcolor(cyan); write(' -- ');
 if cfg.ansi then textcolor(lightcyan);write('2112');
 writeln;


new(nls);
nls^.num := 0;
load_nls;

assign(log,lfn);
rewrite(log);

while DOthing do;

close(log);
dispose(nls);


writeln;
if cfg.ansi then textbackground(blue);
if cfg.ansi then textcolor(white);
write(' SLNodeL ');
if cfg.ansi then textbackground(black);
if cfg.ansi then textcolor(lightgray);
write(' v'+ver);

if cfg.ansi then textcolor(lightgray);

if cfg.ansi then textcolor(white);
writeln;
writeln('         (c) copyright 1992 by Zak Smith, a.r.r., etc. (Send Me Money!)');
windowoff;

end.
