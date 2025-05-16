Program Findesc;
{$M 16384,0,$3200} {$X+} {$B+} {$N-) {$E+} {$G-} {$I+} {$A-}

Uses Dos,FileDef,Etc,SlFiles;


{$IFNDEF DEBUG}
 const dir = 'TEMP';
      dir2 = 'OFFLINE';
      pathdir = 'g:\slbbs\dir\';
      default = 'File from OFFLINE dir.  Here Temporarily';
{$ELSE}
 const dir = 'TEMP';
      dir2 = 'OFFLINE';
      pathdir = 'd:\sltest\';
      default = 'File from OFFLINE dir.  Here Temporarily';
{$ENDIF}

Procedure InitVars;
  var a:byte;
      b:byte;
  begin
  PathToConfig := 'd:\slbbs\';
  end;

Procedure OpenFiles;
  begin

  Open_Config;
  Read_Config;
  Close_Config;

  end;


function FileInSlbbs(s:string):string;
 var found:boolean;
     dir  :dirtype;
     setup:setupdata;
     d    : string;

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
    Read_Dir(rec,dir);

    if leftStr(s,dir.name) then
         climbtree_dir(dir.leaf.left)

      else if rightStr(s,dir.name) then
          climbtree_dir(dir.leaf.right)

        else
         begin
         found :=true;
         d:=dir.descrip;
         exit
         end;
    end;
  end;

  begin
  d:='';
  found:=false;
    Open_Dir(pathdir,dir2);
    Read_Dir_GenHdr;
    Read_Dir_Hdr;
    Climbtree_Dir(DirHdr.Root.Treeroot);
    Close_Dir;

  if found then fileinslbbs:=d else fileinslbbs:='';

  end;

var dirrec: dirtype;
    currec: longint;
    cfd   : string;
    a     : longint;
    tval  : longint;

procedure reopendir;
  begin
  open_dir(pathdir,dir);
  read_dir_genhdr;
  read_dir_hdr;
  end;


begin

currec:=1;
reopendir;

tval:=((filesize(dirfile)-sizeof(dirhdr)) mod sizeof(dirrec));

for a:=1 to tval do
  begin
  currec:=a;
  reopendir;
  read_dir(currec,dirrec);
  close_dir;

  if dirrec.leaf.status<>$FF then
    begin
    cfd:=fileinslbbs(dirrec.name);
    if cfd='' then dirrec.descrip:=default else dirrec.descrip:=cfd;

    writeln('did: ',dirrec.name,' ',dirrec.descrip);

    reopendir;
    write_dir(currec,dirrec);
    close_dir;
    end;

  end;

end.