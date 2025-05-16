{$M 16384,0,2000}

Uses Dos,SlDriv,Crt,Etc,Slfiles,SlFgen;

var
    User      :usertype;


Procedure Status(s:string); far;
  begin
  writeln('scanning ',s);
  end;


function GetDirInfo(dn:string;var s:setupdata):boolean;
  var setup:setupdata;

  procedure finddir(r:longint);
  var Right     : longint;
      Left      : longint;

    begin
    if r <> 0 then
      begin

      Read_setup_data(r,setup);

      Right := setup.leaf.Right;
      Left := setup.leaf.left;

      case compare(dn, setup.name) of
        0: begin
           if (User.access.filelevel >= Setup.Access) then
              begin
              s:=Setup;
              getdirinfo:=true;
              end;
           exit;
           end;

        1: finddir(right);
        2: finddir(left);
        end;

      end;
    end;

  begin
  getdirinfo:=false;
  Open_Setup(setupDIR);
  read_setup_genhdr;
  read_setup_hdr;

  Finddir(SetupHdr.root.treeroot);
  close_setup;

  end;


var filename : string;
    dirname  : string;
    recnum   : longint;

    portstrnum: string[1];

    timeleft  : string;

    s         : setupdata;

    progname,progparam  : string;

begin
 timeleft:=paramstr(1);

 FileMode:=66;

 DirectVideo:=false;
 UseInsert:=False;

 PathToConfig:='.\';
 Open_Config;
 Read_Config;
 Close_Config;

 Ansi:=Cfg.ansi;
 CapsOn:=false;
 PortCheck:=Cfg.Remote;
 PortNum:=Cfg.comport;

 writeln;
 Writeln;
 write('(full) Filename to view archive: ');

 editor(12,filename,'',white,blue);

 FileName:=UpCaseStr(Filename);

 open_user;
 read_user_genhdr;
 read_user_hdr;
 read_user(cfg.curruser,user);
 close_user;

 DirName:=cfg.currdir;

 if not GetDirInfo(dirname,s) then
   begin
   writeln('error, subboard not found, ',dirname);
   halt(1);
   end;

 recnum:=0;

 filename := upcasestr(filename);

 if filename<>'' then

 recnum:= FileInSlDir(FileName,DirName,s.path,open);

 if not (recnum=0) then
   begin
   If SlActive then begin LocalOnly; NoComInput end;

   if (slactive and data^.rsactive) then portstrnum:=tostr(cfg.comport) else
    portstrnum:='0';

   write(portstrnum);

   progname:=fsearch('ZIPTV.EXE',getenv('PATH')+';.');

   progparam:='-T'+timeleft+' -P'+portstrnum+' '+s.filepath+filename;

   if s.filepath<>'' then

   Exec(progname,progparam);

   If SlActive then begin LocalAndRemote; ComInput end;
   end
  else
   begin
   writeln;
   writeln('File ',filename,' not found in current directory, please check the exact name.');
   writeln;
   end;

end.