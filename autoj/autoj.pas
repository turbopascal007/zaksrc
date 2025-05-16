program AUTOJ;

{$S+}
{$V-}
{$R-}
{$D-}
{$G-}
{$N-}
{$E+}

{$M 32768,0,655360}

Uses Crt, Dos, SlFiles, Etc, FileDef, SlDriv;

const
      ver      : string[6]    = '1.0';

var
   {  Vars for Files  }

   DelHdr      : RecordHeader;

   Mbr         : Membtype;

   Setup       : SetupData;

   foundsub    : boolean;

   donelooking : boolean;

   virginf     : boolean;

   lastmbr     : membtype;
   Exist       : boolean;
   curmbrf     : string;
   curname     : string[25];
   lastnode    : longint;

function upstr(s: string):string;
  var a   :integer;
  begin
  for a:=1 to ord(s[0]) do s[a] := upcase(s[a]);
  upstr := s;
  end;

function compare(s1: string; s2: string): byte;
 function bytecomp(c1:char; c2:char): byte;
  var temp: byte;
  begin
  if ord(c1) > ord(c2) then temp := 1;
  if ord(c1) < ord(c2) then temp := 2;
  if ord(c1) = ord(c2) then temp := 0;
  bytecomp := temp;
  end;

  var a    : integer;
      temp : byte;
      done : boolean;
      j    : byte;
  begin
  a := 1;
  done := false;
  repeat
    begin
    j := bytecomp(s1[a], s2[a]);
    if j = 0 then
       begin
       inc(a);
       end;
    if j = 1 then
       begin
       compare := 1;
       exit;
       end;
    if j = 2 then
       begin
       compare := 2;
       exit;
       end;
    end;
  until done;
  end;

procedure ClimbTree_mbr(rec:longint);
 { var Right     : longint;
      Left      : longint;}

  begin

  if rec <> 0 then
   if (not exist) and (not donelooking) then

    begin

    Read_msgmbr(rec,lastmbr);

   { Right := lastmbr.leaf.Right;
    Left := lastmbr.leaf.left;}

    if curname = lastmbr.name then exist := true;

     if compare(curname,lastmbr.name) = 2 then
       if lastmbr.leaf.Left <> 0 then
          begin
          ClimbTree_mbr(lastmbr.leaf.Left);
          end
       else
          begin
          lastnode := rec;
          donelooking := true;
          exit;
          end;

     if (compare(Curname,lastmbr.name) = 1) and (not donelooking) then
       if lastmbr.leaf.Right <> 0 then
          begin
          ClimbTree_mbr(lastmbr.leaf.Right)
          end
       else
          begin
          lastnode := rec;
          donelooking := true;
          exit;
          end;
    end
  end;

procedure scan_mbr;
  var n: longint;
  begin
  exist := false;
  lastnode := 0;
  n := msgmbrhdr.root.treeroot;
  climbtree_mbr(n);
  end;

procedure add_mbr;
var year,month,day,dayofweek: word;a:longint;
  numofrecords: longint;
  nextfreetemp: longint;
  begin

  mbr.name := curname;

  mbr.leaf.status := 0;
  mbr.leaf.right := 0;
  mbr.leaf.left  := 0;
  mbr.leaf.last := 0;
  mbr.leaf.next := 0;

  getdate(year, month, day, dayofweek);

  mbr.firston.day := day;
  mbr.firston.month := month;
  mbr.firston.year := year-1900;
  mbr.laston.day := day;
  mbr.laston.month := month;
  mbr.laston.year := year-1900;

  mbr.lastread := 0;
  mbr.firstmail := 0;
  mbr.lastmail := 0;
  mbr.leaf.status := 0;
  mbr.leaf.left := 0;
  mbr.leaf.right := 0;
  mbr.leaf.last := 0;
  mbr.leaf.next := 0;

  numofrecords := (filesize(msgmbrfile) - (sizeof(msgmbrgenhdr)
                    + sizeof(msgmbrhdr))) div msgmbrgenhdr.recsize;

  if not ((msgmbrgenhdr.nextfree=0) or (MsgMbrGenHdr.Nextfree=numofrecords+1))
      then

    read_record_hdr(msgmbrfile, msgmbrgenhdr.nextfree, msgmbrgenhdr.recsize,
                  msgmbrgenhdr.offset, delhdr)

  else delhdr.next := 0;

  if not VirginF then
    begin
    if msgmbrgenhdr.nextfree = 0 then nextfreetemp := numofrecords+1
     else nextfreetemp := msgmbrgenhdr.nextfree;

    read_msgmbr(lastnode,lastmbr);
    if compare(curname,lastmbr.name) = 1 then
                       lastmbr.leaf.right := nextfreetemp;
    if compare(curname,lastmbr.name) = 2 then
                       lastmbr.leaf.left  := nextfreetemp;
    Write_msgmbr(nextfreetemp,mbr);
    write_msgmbr(lastnode,lastmbr);
    end
  else
    begin
    MsgMbrHdr.Root.Treeroot := 1;
    Write_msgmbr(MsgMbrHdr.Root.Treeroot,Mbr);
    end;

  inc(msgmbrhdr.root.entries);
  write_msgmbr_hdr;

  if (delhdr.next = 0) THEN
    begin
    MsgMbrGenHdr.Nextfree := 0;
    end
  else
   msgmbrgenhdr.nextfree := delhdr.next;

  write_msgmbr_genhdr;

  TextColor(lightcyan);write(casestr(curname));
  textcolor(cyan);write(' joined to ');
  textcolor(lightcyan);write(casestr(curmbrf));
  writeln;

  end;

procedure parse_ps;
  {autoj subname user name}
  var a: integer;
  begin
  if paramcount < 2 then
    begin
    writeln('AUTOJ subname user name');
    halt(1);      
    end;
  Curname := '';
  CurMbrF := upcasestr(Paramstr(1));
  Curname := paramstr(2);
  for a:=3 to paramcount do CurName := CurName + ' '+ Paramstr(a);
  curname := upstr(curname);
  end;


procedure ClimbTree_Setup(rec:longint);
var left:longint;
    right:longint;
  begin
  if not foundsub then
   if rec <> 0 then
    begin

    Read_Setup_data(rec,setup);

    Right := Setup.leaf.Right;
    Left := setup.leaf.left;

    ClimbTree_Setup(Left);

    read_setup_data(rec,setup);

    if (CurMbrF = setup.name) then
       begin
       FoundSub := True;
       end;

    ClimbTree_Setup(Right);

    end;
  end;

begin
  directvideo := false;
  donelooking := false;

  pathtoconfig := '';

  parse_ps;

  if SlActive then LocalOnly;
  Textcolor(lightcyan);
  write('AUTOJ');
  textcolor(lightgray);
  write(' v');textcolor(white);
  write(ver);
  textcolor(lightgray);write(' - ');
  textcolor(cyan);
  writeln('The Subboard Joiner (c) 1991 by Zak Smith all rights reserved');
  if SlActive then LocalAndRemote;

  Open_config;
  Read_config;
  Close_Config;

  Open_Setup(setupMSG);
  Read_Setup_GenHdr;
  Read_Setup_Hdr;
  foundsub := false;
  ClimbTree_Setup(SetupHdr.Root.Treeroot);
  if not foundsub then
    begin
    if SlActive then LocalOnly;
    textcolor(cyan);
    write('Could not find subboard ');
    textcolor(lightcyan);
    writeln(curmbrf);
    if SlActive then LocalAndRemote;
    halt(1);
    end;

  Close_Setup;

  Open_MsgMbr(Setup.Path,CurMbrF);
  read_msgmbr_genhdr;
  read_msgmbr_hdr;
  if (msgmbrhdr.root.treeroot = 0) then virginf:=true else virginf:=false;

  if not VirginF then Scan_Mbr; {only scan if not a the root}

 If (not Exist) or VirginF then Add_Mbr
     ELSE {if exist}
       begin
       if SlActive then LocalOnly;
       TextColor(lightcyan);write(casestr(curname));
       textcolor(cyan);write(' is allready a member of ');
       textcolor(lightcyan);write(casestr(curmbrf));
       writeln;
       if SlActive then LocalAndRemote;
       end;
  Close_msgMbr;

end.
dos
