Unit SLfHigh;
{$O+} { Allow it to be overlaid }

{ High Level Searchlight Data File Routines}

interface

Uses SlfLow;

type
     StatusType = Procedure(s:string);
     FindMainSubListFuncType = Function(PathToFiles,SubName:string):boolean;
     UserListFuncType = Function(r:longint;u:UserType):boolean;
     FileListFuncType = Function(var f:file;R:longint;D:dirtype):boolean;
     FindMainSubListRecFuncType = function(var f:file;r:longint):boolean;
     KindOfSetup = (SetupMSG,SetupDIR);

     PartialMatchFuncType = (Pick,Continue,Quit);
     PMRetType = (Aborted,Picked,None);
     PartialFuncType = function(s:string):partialmatchfunctype;


function  FileInSlbbs(s:string; Status:StatusType;var dirname:string):boolean;

function  FileInSlDir(findname,dirname,pathname:string):longint;

Function  MemberOf(Path,Subboard,Username:string):longint;

procedure MainSubList(TFileName:String;SetupFlav:KindOfSetup;Func: FindMainSubListFuncType);

procedure MainSubListRec(TFileName:String;SetupFlav:KindOfSetup;Func: FindMainSubListRecFuncType);

Procedure UserList(Func:UserListFuncType);

Procedure FileList(SubName,pathname:string;Func:FileListFuncType;var dFH:dirheader);

function  Setup_Info(SubName: String; SetupFlav:KindofSetup;var setup:setupdata):boolean;

Function  FindUser_Info(uName:String;var u:usertype):boolean;

Procedure User_Info(n:longint;var u:usertype);

procedure Write_User(n:longint;u:usertype);

Function  GetBytesInDir(p,s:string;dossize:boolean):longint;

function PartialMatches(fn:string;startdir:string;pmf:partialfunctype;
                         stat:statustype;
                         var dn:string;var rfn:string;var r:longint;
                         acc:accesstype):PmRetType;
implementation

Uses Dos,Etc,Crt;

function PartialMatches(fn:string;startdir:string;pmf:partialfunctype;
                         stat:statustype;
                         var dn:string;var rfn:string;var r:longint;acc:accesstype):PmRetType;
var
     dir              :dirtype;
     setup            :setupdata;
     dF,sF            :file;
     abort,found,dwtd :boolean;
     subs             :string;

 function leftStr(s1,s2:string):boolean;
   begin leftStr:=upcasestr(s1)<upcasestr(s2) end;

 function rightStr(s1,s2:string):boolean;
   begin rightStr:=upcasestr(s1)>upcasestr(s2); end;

 function trim(grr:string):string;
  begin trim:=copy(grr,1,length(fn)) end;

 function checktrimed(t,n:string):boolean;
  begin checktrimed:=trim(t)=n end;

 function childname(rec:longint):string;
   var d:dirtype;
   begin read_data(dF,dirF,rec,d);
   childname:=d.name  end;

 procedure ScanChildren(rec:longint);
   begin
   read_Data(dF,dirF,rec,dir);
   if (dir.Leaf.Left<>0) then
      begin
      scanchildren(dir.Leaf.Left);
      if abort or found then exit;
      Read_Data(dF,dirF,rec,dir);
      end;

      if checktrimed(dir.name,fn) then
       Case PMF(dir.name) of
         Pick    : begin
                   found := true;
                   dn := setup.name;
                   rfn := dir.name;
                   r :=rec;
                   PartialMatches := Picked;
                   end;
         Continue: { nothing };
         Quit    : begin
                   Abort := true;
                   exit;
                   PartialMatches := Aborted;
                   end;
         end;
    if abort or found then exit;
    if (dir.leaf.right<>0)  then scanchildren(dir.leaf.right);
   end;


 Procedure look(rec:longint);
   begin
   if dwtd then exit;
   read_data(dF,dirF,rec,dir);
   if fn=dir.name then
    begin
    dwtd:=true;
    found := true;
    PartialMatches := Picked;
    dn := setup.name;
    rfn := dir.name;
    r:=rec;
    end
    else
   if checktrimed(dir.name,fn) then
     scanchildren(rec)
    else
   if ((dir.leaf.left=0) and (fn<dir.name)) or ((dir.leaf.right=0) and (fn>dir.name)) then
     begin
     dwtd:=true; exit;
     end
    else
   if  (dir.leaf.left<>0) and (fn<dir.name) then
     look(dir.leaf.left)
    else
   if (dir.leaf.right<>0) and (fn>dir.name) then
     look(dir.leaf.right)
    else
     begin
     writeln('I should never get here!');
     writeln(' Tell Zak Right Away! ');
     end;
   end;

 procedure ScanDir;
   var
      dGFH:fileheader;
      dFH :dirheader;
  begin
    if abort or found then exit;
    Init_VarData(dF,DirF,setup.path,setup.name,dGFH,dFH);
    dwtd:=false;
    stat(setup.name);
    Look(dFH.Root.Treeroot);
    Close_data(dF);
  end;

 procedure ClimbTree_DirSetup(rec:longint);
  begin
  if rec <> 0 then
    begin
    read_Data(sF,dirsetupf,rec,setup);
    if Setup.Leaf.Left <> 0 then
      begin
      ClimbTree_DirSetup(Setup.Leaf.Left);
      Read_Data(sF,dirsetupf,rec,setup);
      end;
    if not(found or abort) then
      begin
      if (setup.name<>startdir) and
        (acc.filelevel>=setup.access) and
        (acc.attrib>=setup.attrib)
        then ScanDir;
      end;
    if found or abort then exit;
    ClimbTree_DirSetup(Setup.leaf.right);
    end;
  end;

  var sGFH:fileheader;
      sFH :setupheader;
  begin
  r:=0;
  PartialMatches := None;
  found:=false;
  abort:=false;

  Setup_Info(startdir,setupDIR,setup);
  ScanDir;

  if Found and (r<>0) then
    begin
    exit;
    end;

  Init_ConstData(sF,DirSetupF,sGFH,sFH);
  ClimbTree_DirSetup(sFH.root.treeroot);
  close_data(sF);
  end;
 { end PartialMatches }

Function GetBytesInDir(p,s:string;dossize:boolean):longint;
  var
      Dir      : DirType;
      dF       : file;
      curs     : longint;
      dGFH:fileheader;
      dFH :dirheader;

  Function GetFileSize:longint;
   var dosf:file;
   begin
   if not dossize then GetFileSize:=dir.length * 128
   else
    if not existfile(dfh.filepath+dir.name,anyfile) then getfilesize:=0
    else
     begin
     assign(dosf,dFH.filepath+dir.name);
     reset(dosf,1);
     getfilesize:=filesize(dosf);
     close(dosf);
     end;
   end;

  procedure ClimbTree_Dir(rec:longint);
  var Right: longint;
    begin
    if (rec <> 0) then
      begin
      Read_Data(dF,DirF,rec,dir);
      Right := dir.Leaf.Right;
      if dir.Leaf.Left <> 0 then
        begin
        ClimbTree_Dir(dir.Leaf.Left);
        Read_Data(dF,DirF,rec,dir);
        end;
      inc(curs,GetFileSize);
      ClimbTree_dir(right);
      end;
    end;
  begin
  Init_vardata(dF,DirF,p,s,dGFH,dFH);
  curs:=0;
  ClimbTree_dir ( dFH.root.treeroot );
  Close_data(dF);
  GetBytesInDir:=Curs;
  end;

procedure user_info(n:longint;var u:usertype);
 var uF:file;
     uGFH:fileheader;
     uFH:userheader;
 begin
 Init_ConstData(uF,UserF,uGFH,uFH);
 Read_Data(uF,UserF,n,u);
 Close_data(uF);
 end;

procedure Write_User(n:longint;u:usertype);
 var uF:file;
     uGFH:fileheader;
     uFH:userheader;
 begin
 Init_ConstData(uF,UserF,uGFH,uFH);
 Write_Data(uF,UserF,n,u);
 Close_data(uF);
 end;


Procedure UserList (Func   : UserListFuncType );
  var
      uF       : file;
      KeepGoing: Boolean;
      User     : UserType;
  procedure ClimbTree_User(rec:longint);
  var Right: longint;
    begin
    if (rec <> 0) and KeepGoing then
      begin
      Read_Data(uf, userf, rec,user);
      Right := User.Leaf.Right;
      if User.Leaf.Left <> 0 then
        begin
        ClimbTree_User(User.Leaf.Left);
        Read_data(uf,userf,rec,User);
        end;
      KeepGoing := Func(rec,user);
      if not keepgoing then exit;
      ClimbTree_User(right);
      end;
    end;

  var uGFH: fileheader;
      uFH : userheader;
  begin
  Init_ConstData(uF,userf,uGFH,uFH);
  KeepGoing := True;
  ClimbTree_user ( uFH.root.treeroot );
  Close_Data(uF);
  end;

function Setup_Info ( SubName: String; SetupFlav:KindofSetup;var setup:setupdata): boolean;
 Var found : boolean;
     sF    : file;
  procedure findsub(r:longint);
    begin
    if r <> 0 then
      begin
                   { can by msgsetupf or dirsetupf}
      Read_Data(sF,MsgSetupF,r,setup);
      case compare(Subname, setup.name) of
        0: begin
           found := true;
           exit;
           end;
        1: findsub(setup.leaf.right);
        2: findsub(setup.leaf.left);
        end;
      end;
    end;

 var sGFH:fileheader;
     sFH :setupheader;
 begin
 if setupflav=SetupMsg then
          Init_ConstData(sF,MsgSetupF,sGFH,sFH)
   else
          Init_ConstData(sF,DirSetupF,sGFH,sFH);
 found := false;
 FindSub(sFH.Root.TreeRoot);
 Close_Data(sF);
 Setup_Info := Found;
 end;

procedure MainSubList(TFileName:string;SetupFlav:KindOfSetup;
       Func: FindMainSubListFuncType);
  var
      mainfile : text;
      templn   : string[8];
      KeepGoing: boolean;
      Setup    : setupdata;
      sF       : file;

  procedure findsub(r:longint);
    begin
    if r <> 0 then
      begin
      Read_Data(sF,MsgSetupF,r,setup);
      case compare(templn, setup.name) of
        0: begin
           KeepGoing:=Func(setup.path,Setup.Name);  exit;
           end;
        1: findsub(setup.leaf.right);
        2: findsub(setup.leaf.left);
        end;
      end;
    end;

  procedure ClimbTree_Setup(rec:longint);
  var Right: longint;
    begin
    if (rec <> 0) and KeepGoing then
      begin
      Read_Data(sF,MsgSetupF,Rec,setup);
      Right := Setup.Leaf.Right;
      if Setup.Leaf.Left <> 0 then
        begin
        ClimbTree_Setup(Setup.Leaf.Left);
        Read_Data(sF,MsgSetupF,Rec,setup);
        end;
      KeepGoing := Func(Setup.Path,Setup.Name);
      if not keepgoing then exit;
      ClimbTree_Setup(right);
      end;
    end;

 var sGFH:fileheader;
     sFH :setupheader;
 begin
 if setupflav=SetupMsg then
          Init_ConstData(sF,MsgSetupF,sGFH,sFH)
   else
          Init_ConstData(sF,DirSetupF,sGFH,sFH);
  KeepGoing := True;
  if ExistFile(Cfg.DataPath+TFileName,anyfile) then
    begin
    assign(mainfile,cfg.datapath+TFileName);
    reset(mainfile);
    repeat
     begin
     readln(mainfile,templn);
     templn := rtrim(upcasestr(templn));
     FindSub(sFH.root.treeroot)
     end
    until eof(mainfile) or not KeepGoing;
    close(mainfile);
    end
  else
   begin
   ClimbTRee_Setup ( sFH.root.treeroot );
   end;
  Close_data(sF);
  end;

procedure MainSubListrec(TFileName:string;SetupFlav:KindOfSetup;
       Func: FindMainSubListRecFuncType);
  var
      mainfile : text;
      templn   : string[8];
      KeepGoing: boolean;
      Setup    : setupdata;
      sF       : file;
  procedure findsub(r:longint);
    begin
    if r <> 0 then
      begin
      Read_Data(sF,MsgSetupF,r,setup);
      case compare(templn, setup.name) of
        0: begin
           KeepGoing:=Func(sf,r);
           exit;
           end;
        1: findsub(setup.leaf.right);
        2: findsub(setup.leaf.left);
        end;
      end;
    end;

  procedure ClimbTree_Setup(rec:longint);
  var Right: longint;
    begin
    if (rec <> 0) and KeepGoing then
      begin
      Read_Data(sF,MsgSetupF,Rec,setup);
      Right := Setup.Leaf.Right;
      if Setup.Leaf.Left <> 0 then
        begin
        ClimbTree_Setup(Setup.Leaf.Left);
        Read_Data(sF,MsgSetupF,Rec,setup);
        end;
      KeepGoing := Func(sf,rec);
      if not keepgoing then exit;
      ClimbTree_Setup(right);
      end;
    end;

 var sGFH:fileheader;
     sFH :setupheader;
 begin
 if setupflav=SetupMsg then
          Init_ConstData(sF,MsgSetupF,sGFH,sFH)
   else
          Init_ConstData(sF,DirSetupF,sGFH,sFH);
  KeepGoing := True;
  if ExistFile(Cfg.DataPath+TFileName,anyfile) then
    begin
    assign(mainfile,cfg.datapath+TFileName);
    reset(mainfile);
    repeat
     begin
     readln(mainfile,templn);
     templn := rtrim(upcasestr(templn));
     FindSub(sFH.root.treeroot)
     end
    until eof(mainfile) or not KeepGoing;
    close(mainfile);
    end
  else
   begin
   ClimbTRee_Setup ( sFH.root.treeroot );
   end;
  Close_data(sF);
  end;

function MemberOf(path,subboard,username:string): longint;
 var found:boolean;
     mbr  : membtype;
     mF   : file;
 procedure ClimbTree_mbr(rec:longint);
  begin
  if rec <> 0 then
    begin
    Read_Data(mF,msgmbrF,rec,mbr);
    case compare(username, mbr.name) of
      0: begin
         memberof:=rec;
         found:=true;
         exit;
         end;
      1: Climbtree_mbr(mbr.leaf.right);
      2: Climbtree_mbr(mbr.leaf.left);
      end;
    end;
  end;

 var mGFH: fileheader;
     mFH : membheader;
 begin
 found:=false;
 memberof:=0;
 Init_VarData(mF,MsgMbrF,path,subboard,mGFH,mFH);
 climbtree_mbr(mFH.root.treeroot);
 close_data(mF);
 end;

function FileInSlbbs(s:string;Status:StatusType;var dirname:string):boolean;
 var found:boolean;
     dir:dirtype;
     setup:setupdata;
     dF   :file;
     sF   :file;
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
    Read_data(dF,dirf,rec,dir);
    if leftStr(s,dir.name) then
         climbtree_dir(dir.leaf.left)
      else if rightStr(s,dir.name) then
          climbtree_dir(dir.leaf.right)
        else begin dirname:=setup.name; found :=true; exit end;
    end;
  end;

 procedure ScanDir;
   var
      dGFH:fileheader;
      dFH :dirheader;
  begin
    Init_VarData(dF,DirF,setup.path,setup.name,dGFH,dFH);
    Climbtree_Dir(dFH.Root.Treeroot);
    Close_data(dF);
  end;

 Procedure CallStat;
   begin
   Status(Setup.Name);
   end;

 procedure ClimbTree_DirSetup(rec:longint);
  begin
  if rec <> 0 then
    begin
    read_Data(sF,dirsetupf,rec,setup);
    if Setup.Leaf.Left <> 0 then
      begin
      ClimbTree_DirSetup(Setup.Leaf.Left);
      Read_Data(sF,dirsetupf,rec,setup);
      end;
    if not found then
      begin
      CallStat;
      ScanDir;
      end;
    if found then exit;
    ClimbTree_DirSetup(Setup.leaf.right);
    end;
  end;

  var sGFH:fileheader;
      sFH :setupheader;
  begin
  found:=false;
  Init_ConstData(sF,DirSetupF,sGFH,sFH);
  ClimbTree_DirSetup(sFH.root.treeroot);
  close_data(sF);
  FileInSlbbs:=found;
  end;
 { end FileInSlbbs }

function FileInSlDir(findname,dirname,pathname:string):longint;
 var found:boolean;
     dir:dirtype;
     dF :file;

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
    Read_Data(dF,dirf,rec,dir);
    if leftStr(findname,dir.name) then climbtree_dir(dir.leaf.left)
      else
    if rightStr(findname,dir.name) then climbtree_dir(dir.leaf.right)
        else begin fileinsldir:=rec; found :=true; exit end;
    end;
  end;

 var dFGH:fileheader;
     dFH :dirheader;
 procedure ScanDir;
  begin
  Init_VarData(dF,DirF,pathname,dirname,dFGH,dFH);
  Climbtree_Dir(dFH.Root.Treeroot);
  Close_data(dF);
  end;
  begin
    FileInSlDir:=0;
    found:=false;
    ScanDir;
  end;
 { end FileInSlDir }

Procedure FileList (SubName,PathName:string;
                    Func   : FileListFuncType; var dFH:dirheader);
  var
      KeepGoing: Boolean;
      Dir      : DirType;
      dF       : file;
  procedure ClimbTree_Dir(rec:longint);
  var Right: longint;
    begin
    if (rec <> 0) and KeepGoing then
      begin
      Read_Data(dF,DirF,rec,dir);
      Right := dir.Leaf.Right;
      if dir.Leaf.Left <> 0 then
        begin
        ClimbTree_Dir(dir.Leaf.Left);
        Read_Data(dF,DirF,rec,dir);
        end;
      KeepGoing := Func(dF,rec,dir);
      if not keepgoing then exit;
      ClimbTree_dir(right);
      end;
    end;

  Var dGFH:fileheader;
  begin
  Init_vardata(dF,DirF,pathname,subname,dGFH,dFH);
  KeepGoing := True;
  ClimbTree_dir ( dFH.root.treeroot );
  Close_data(dF);
  end;

Function  FindUser_Info (uName:String;var u:usertype):boolean;
 Var found : boolean;
     uF    : file;
  procedure findu(r:longint);
    begin
    if r <> 0 then
      begin
      Read_Data(uF,userF,r,u);
      case compare(uname, u.name) of
        0: begin
           found := true;
           exit;
           end;
        1: findu(u.leaf.right);
        2: findu(u.leaf.left);
        end;
      end;
    end;

 var uGFH:fileheader;
     uFH :userheader;
 begin
 Init_ConstData(uF,userF,uGFH,uFH);
 found := false;
 Findu(uFH.Root.TreeRoot);
 Close_Data(uF);
 FindUser_Info := Found;
 end;

 { hey }
end.
