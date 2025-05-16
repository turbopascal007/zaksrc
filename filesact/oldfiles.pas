Uses Dos,Crt,Etc,SlFiles,Dates;

Var Dir       : Dirtype;
    FileLog   : text;

    Uploads   : longint;
    UploadsK  : Longint;

    Downloads : longint;
    DownloadsK: longint;

function FileInSlbbs(s:string;var size:longint):boolean;


 var here:boolean;
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
  if not (here or (rec=0)) then
    begin
    Read_Dir(rec,dir);
    if leftStr(s,dir.name) then
         climbtree_dir(dir.leaf.left)
      else if rightStr(s,dir.name) then
          climbtree_dir(dir.leaf.right)
        else begin here :=true; size:=dir.length*128;exit end;
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
  gotoxy(36,wherey);write(Setup.Name);clreol;
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

    if not here then
      begin
      Status;
      ScanDir;
      end;

    if here then exit;
    ClimbTree_DirSetup(Setup.leaf.right);
    end;
  end;

  begin
  write('Processing: ',s:12,' Scanning: ');
  here:=false;

  Open_Setup(Setupdir);
  read_setup_genhdr;
  read_setup_hdr;
  ClimbTree_DirSetup(setuphdr.root.treeroot);
  close_setup;

  if not here then write(' NOT FOUND');
  writeln;

  FileInSlbbs:=here;
  end;




procedure GetRatios;
  type bt = array[1..16384] of byte;

  var ts:string;
      b : ^bt;
      s : longint;
      dd:longint;

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
        inc(uploads);
        inc(uploadsk,s);
        end
      end;

      if copy(ts,13,3)='D/L' then begin
       if fileinslbbs(rtrim(copy(ts,17,12)),s) then
        begin
        inc(downloads);
        inc(downloadsk,s);
        end
      end;

      end;
    end;

  begin
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

  end;


begin
PathToConfig:='';

Uploads:=0;
uploadsk:=0;

downloads:=0;
downloadsk:=0;

Open_Config;
Read_Config;
Close_Config;

GetRatios;

writeln('Recent File System Statistics for ',casestr(cfg.systemname));

writeln('Number of Downloads: ',downloads:5,'          Number of Uploads: ',uploads:5);

writeln('   Bytes Downloaded:',(downloadsk/1024):9:1,'k         Bytes Uploaded:',       (uploadsk/1024):9:1,'k');

Writeln('  Average File Size:',((downloadsk/1024)/downloads):9:1,'k      Average File Size:',
         ((uploadsk/1024)/uploads):9:1,'k');

writeln;
if (uploadsk/downloadsk)>0 then
  writeln('Overall Upload:Download Ratio -> ',trunc(uploadsk/downloadsk),'k:1k')
else
  writeln('Overall Upload:Download Ratio ->  1k:',trunc(downloadsk/uploadsk),'k')


end.
