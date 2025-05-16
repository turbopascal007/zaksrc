{ Unit Searchlight File General Routines }

Unit SlFGen;

{ High Level Searchlight Data File Routines .. }

interface

Uses SlFiles;

Type OpenFileType = (OPEN,CLOSED);

     StatusType = Procedure (S:string);
     FindMainSubListFuncType = Function (PathToFiles,SubName:string):boolean;
     UserListFuncType = Function (R:longint;U:UserType):boolean;
     FileListFuncType = Function (R:longint;D:dirtype):boolean;

function  FileInSlbbs (s:string; Status:StatusType;var dirname:string):boolean;
function  FileInSlDir (findname,dirname,pathname:string;fstat:OpenFileType):longint;
Function  MemberOf    (Path,Subboard,Username:string;fstat:OpenFileType):longint;
procedure MainSubList (TFileName:String;SetupFlav:KindOfSetup;
                            FStat       : OpenFileType;
                            Func        : FindMainSubListFuncType);
Procedure UserList ( FStat  : OpenFileType;
                     Func   : UserListFuncType );

Procedure FileList ( SubName,pathname : string;
                     FStat  : OpenFileType;
                     Func   : FileListFuncType);

Procedure Init_Config ( Fstat : OpenFileType; Path:String );
Procedure Init_User;
function  Setup_Info ( SubName: String; SetupFlav:KindofSetup;FStat: OpenFileType;var setup:setupdata):boolean;
Procedure Init_Dir(Pathname,DirName:string);
Procedure Init_Mbr(pathname, dirname:string);

implementation

Uses Dos,Etc,Crt;

Procedure UserList ( FStat  : OpenFileType;
                     Func   : UserListFuncType );
  var
      KeepGoing: Boolean;
      User     : UserType;

  procedure ClimbTree_User(rec:longint);
  var Right: longint;
    begin
    if (rec <> 0) and KeepGoing then
      begin
      read_User(rec,user);

      Right := User.Leaf.Right;

      if User.Leaf.Left <> 0 then
        begin
        ClimbTree_User(User.Leaf.Left);
        Read_User(rec,User);
        end;

      KeepGoing := Func(rec,user);

      if not keepgoing then exit;

      ClimbTree_User(right);

      end;
    end;


  begin

  if Fstat=Closed then Init_User;

  KeepGoing := True;

  ClimbTree_user ( UserHDR.root.treeroot );

  if Fstat=Closed then Close_User;

  end;



procedure init_mbr(pathname, dirname:string);
 begin
 Open_MsgMbr(pathname,dirname);
 read_msgmbr_genhdr;
 read_msgmbr_hdr;
 end;


procedure init_user;
 begin
 open_user;
 read_user_genhdr;
 read_user_hdr;
 end;

Procedure Init_Config (fstat : openfiletype; Path:String);
 begin
 PathToConfig := Path;
 open_config;
 read_config;
 if fstat=closed then close_config;
 end;


Procedure Init_Setup ( SetupFlav: KindOfSetup );
 begin
 Open_Setup( SetupFlav );
 read_setup_genhdr;
 read_setup_hdr;
 end;

Procedure Init_MsgMbr ( Path,SubName: string );
 begin
 open_msgmbr(path, subname);
 read_msgmbr_genhdr;
 read_msgmbr_hdr;
 end;

Procedure Init_Dir (Pathname,dirname:string);
 begin
 Open_Dir(pathname,dirname);
 Read_Dir_GenHdr;
 Read_Dir_Hdr;
 end;


function Setup_Info ( SubName: String; SetupFlav:KindofSetup;FStat: OpenFileType;var setup:setupdata): boolean;
 Var found : boolean;

  procedure findsub(r:longint);
    begin
    if r <> 0 then
      begin

      Read_setup_data(r,setup);

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


 begin
 if Fstat=Closed then Init_Setup ( SetupFlav );

 found := false;

 FindSub(SetupHdr.Root.TreeRoot);

 if Fstat=Closed then Close_Setup;

 Setup_Info := Found;
 end;

procedure MainSubList(TFileName:string;SetupFlav:KindOfSetup;
       FStat:OpenFileType;Func: FindMainSubListFuncType);
  var
      mainfile : text;
      templn   : string[8];
      KeepGoing: boolean;
      Setup    : setupdata;

  procedure findsub(r:longint);
    begin
    if r <> 0 then
      begin

      Read_setup_data(r,setup);

      case compare(templn, setup.name) of
        0: begin
           KeepGoing:=Func(setup.path,Setup.Name);
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
      read_setup_data(rec,setup);

      Right := Setup.Leaf.Right;

      if Setup.Leaf.Left <> 0 then
        begin
        ClimbTree_Setup(Setup.Leaf.Left);
        Read_Setup_Data(rec,setup);
        end;

      KeepGoing := Func(Setup.Path,Setup.Name);

      if not keepgoing then exit;

      ClimbTree_Setup(right);

      end;
    end;


  begin

  if Fstat=Closed then Init_Setup ( SetupFlav );

  KeepGoing := True;

  if ExistFile(Cfg.DataPath+TFileName,anyfile) then
    begin
    assign(mainfile,cfg.datapath+TFileName);
    reset(mainfile);

    repeat
     begin
     readln(mainfile,templn);
     templn := rtrim(upcasestr(templn));
     FindSub(SetupHdr.root.treeroot)
     end
    until eof(mainfile) or not KeepGoing;
    close(mainfile);
    end
  else
   begin
   ClimbTRee_Setup ( SetupHDR.root.treeroot );
   end;

  if Fstat=Closed then Close_Setup;

  end;

function MemberOf(path,subboard,username:string;fstat:OpenFileType): longint;
 var found:boolean;
     mbr  : membtype;
 procedure ClimbTree_mbr(rec:longint);
  begin
  if rec <> 0 then
    begin
    Read_msgmbr(rec,mbr);
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

 begin
 found:=false;
 memberof:=0;

 if FStat=Closed then
    begin
    Init_MsgMbr ( Path, Subboard );
    end;

 climbtree_mbr(msgmbrhdr.root.treeroot);

 if Fstat=Closed then close_msgmbr;

 end;



function FileInSlbbs(s:string;Status:StatusType;var dirname:string):boolean;
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

        else begin dirname:=dir.name; found :=true; exit end;
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

 Procedure CallStat;
   begin
   Status(Setup.Name);
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
      CallStat;
      ScanDir;
      end;

    if found then exit;
    ClimbTree_DirSetup(Setup.leaf.right);
    end;
  end;

  begin
    found:=false;

    Init_Setup ( SetupDir );

    ClimbTree_DirSetup(setuphdr.root.treeroot);
    close_setup;

  FileInSlbbs:=found;
  end;
 { end FileInSlbbs }

function FileInSlDir(findname,dirname,pathname:string;Fstat:OpenFileType):longint;
 var found:boolean;
     dir:dirtype;

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

    if leftStr(findname,dir.name) then
         climbtree_dir(dir.leaf.left)

      else if rightStr(findname,dir.name) then
          climbtree_dir(dir.leaf.right)

        else begin fileinsldir:=rec; found :=true; exit end;
    end;
  end;

 procedure ScanDir;
  begin
  if Fstat=Closed then
   begin

   Init_Dir ( PathName, DirName );
   end;
    Climbtree_Dir(DirHdr.Root.Treeroot);
  if Fstat=Closed then Close_Dir;
  end;

  begin
    FileInSlDir:=0;
    found:=false;
    ScanDir;
  end;
 { end FileInSlDir }


Procedure FileList (SubName,PathName:string;FStat  : OpenFileType;
                     Func   : FileListFuncType);
  var
      KeepGoing: Boolean;
      Dir      : DirType;

  procedure ClimbTree_Dir(rec:longint);
  var Right: longint;
    begin
    if (rec <> 0) and KeepGoing then
      begin
      read_dir(rec,dir);
      Right := dir.Leaf.Right;
      if dir.Leaf.Left <> 0 then
        begin
        ClimbTree_Dir(dir.Leaf.Left);
        Read_dir(rec,dir);
        end;

      KeepGoing := Func(rec,dir);

      if not keepgoing then exit;

      ClimbTree_dir(right);

      end;
    end;


  begin
  if Fstat=Closed then
             begin


             end;

  KeepGoing := True;
  ClimbTree_dir ( DirHDR.root.treeroot );
  if Fstat=Closed then Close_dir;
  end;

end.