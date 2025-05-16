Uses Dos,Crt,Etc,SlFiles,Dates;

type ToLstType = ^LstType;
     LstType = record
     next: tolsttype;
     name: string[12];
     size: longint;
     end;

const SYSOP='SYSOP';

Var Dir       : Dirtype;
    FileLog   : text;

    Uploads   : longint;
    UploadsK  : Longint;

    Downloads : longint;
    DownloadsK: longint;

    root      : tolsttype;
    sysopsrec : longint;

    output    :text;

function SysopRec:longint;
  var user:usertype;
      sr  :longint;

  function leftStr(s1,s2:string):boolean;
   begin
   leftStr:=upcasestr(s1)<upcasestr(s2);
   end;

 function rightStr(s1,s2:string):boolean;
   begin
   rightStr:=upcasestr(s1)>upcasestr(s2);
   end;


  procedure climbuser(r:longint);
   begin
   read_user(r,user);

   if leftstr(sysop,user.name) then climbuser(user.leaf.left)
     else if rightstr(sysop,user.name) then climbuser(user.leaf.right)
      else if sysop=user.name then begin SR:=R; exit; end;

   end;

  begin
  sr:=0;
  open_user;
  read_user_genhdr;
  read_user_hdr;

  climbuser(userhdr.root.treeroot);

  close_user;
  sysoprec:=sr;
  end;


function FileInSlbbs(s:string;var l:longint):boolean;
  var cur:tolsttype;
  begin
  cur:=root;
  fileinslbbs:=false;
  while not(cur=nil) do
    begin
    if cur^.name=s then begin
      l:=cur^.size;
      FileInSlbbs:=True;
      exit;
      end;
    cur:=cur^.next;
    end;
  end;


procedure AddToList(s:string;l:longint);
  var cur:tolsttype;
  begin
  if root=nil then
   begin
   new(root);
   root^.next:=nil;
   root^.name:=s;
   root^.size:=l;
   end
  else
   begin
   cur:=root;
   while cur^.next<>nil do cur:=cur^.next;
   new(cur^.next);
   cur:=cur^.next;
   cur^.next:=nil;
   cur^.name:=s;
   cur^.size:=l;
   end;
  end;


procedure LoadList;

 var dir:dirtype;
     setup:setupdata;
     num  :longint;

 procedure status2;
  begin
  inc(num);

  if (num mod 10)=0 then
    begin
    gotoxy(20,wherey);
    write('(',((num*100) div dirhdr.root.entries):3,'%)');
    end;

  end;

 procedure ClimbTree_Dir(rec:longint); {recursive..}
  var Right     : longint;     {saved right pointer}
      Left      : longint;     {saved left  pointer}

  begin
  if not (rec=0) then
    begin
    Read_Dir(rec,dir);
    right:=dir.leaf.right;
    left:=dir.leaf.left;

    if left <> 0 then ClimbTree_Dir(left);

    if left<>0 then read_dir(rec,dir);

    {if not(dir.id=sysopsrec) then} AddtoList(dir.name,dir.length*128);
    status2;

    if right<>0 then climbtree_dir(right);

    end;
  end;

 procedure ScanDir;
  begin
  num:=0;
    Open_Dir(setup.path,setup.name);
    Read_Dir_GenHdr;
    Read_Dir_Hdr;
    Climbtree_Dir(DirHdr.Root.Treeroot);
    Close_Dir;
  end;

 procedure Status;
  begin
  gotoxy(11,wherey);write(Setup.Name);clreol;
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

    Status;
    ScanDir;

    ClimbTree_DirSetup(Setup.leaf.right);
    end;
  end;

  begin
  num:=0;
  writeln;
  writeln('Pre-Processing..');
  write('Scanning: ');

  Open_Setup(Setupdir);
  read_setup_genhdr;
  read_setup_hdr;
  ClimbTree_DirSetup(setuphdr.root.treeroot);
  close_setup;
  writeln;
  end;


procedure GetRatios;
  type bt = array[1..16384] of byte;

  var ts:string;
      b : ^bt;
      s : longint;
      dd:longint;
      n :longint;

  procedure process;
    begin
    s:=0;
    ts:=ltrim(rtrim(ts));
    dd:=(DAy_Diff(today_day, today_month, today_year,
        toint(copy(ts,5,2)),toint(copy(ts,3,2)),1900+toint(copy(ts,1,2))));

    if dd>=-10 then
      begin
      if copy(ts,13,3)='U/L' then begin
       if fileinslbbs(rtrim(copy(ts,17,12)),s) then
        begin
        inc(n);
        gotoxy(11,wherey);write(n);clreol;
        inc(uploads);
        inc(uploadsk,s);
        end
      end;

      if copy(ts,13,3)='D/L' then begin
       if fileinslbbs(rtrim(copy(ts,17,12)),s) then
        begin
        inc(n);
        gotoxy(11,wherey);write(n);clreol;
        inc(downloads);
        inc(downloadsk,s);
        end
      end;

      end;
    end;

  begin
  n:=0;
  writeln('Processing . . .');
  write('Progress: ');
  new(b);
  assign(filelog,pathtoconfig+'files.log');
  reset(filelog);
  settextbuf(filelog,b^,sizeof(b^));
  readln(filelog,ts);
  process;

  while not eof(filelog) do
    begin
    readln(filelog,ts);
    process;
    end;

  close(filelog);
  writeln;
  end;


begin
 assign(output,'');
 rewrite(output);

 PathToConfig:='';
 root:=nil;
 Uploads:=0;
 uploadsk:=0;

 downloads:=0;
 downloadsk:=0;

 Open_Config;
 Read_Config;
 Close_Config;

 sysopsrec:=sysoprec;

 LoadList;

 GetRatios;

 writeln(output,'Recent File System Statistics for ',casestr(cfg.systemname));

 writeln(output,'Number of Downloads: ',downloads:6,'          Number of Uploads: ',uploads:6);

 writeln(output,'   Bytes Downloaded:',(downloadsk/1024):9:1,'k         Bytes Uploaded:',       (uploadsk/1024):9:1,'k');

 Writeln(output,'  Average File Size:',((downloadsk/1024)/downloads):9:1,'k      Average File Size:',
          ((uploadsk/1024)/uploads):9:1,'k');

 if (uploadsk/downloadsk)>1 then
   writeln(output,'Overall Upload:Download Ratio -> ',(uploadsk/downloadsk):0:1,'k upload for every 1k download')
 else
   writeln(output,'Overall Upload:Download Ratio ->  1k upload for every ',(downloadsk/uploadsk):0:1,'k download');
 close(output);
end.
