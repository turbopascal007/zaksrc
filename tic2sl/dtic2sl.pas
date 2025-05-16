Program Tick2Sl;

{$M 16384,0,655360}

Uses Crt,Etc,FileDef,Dir,Dates,Sublist;

var descfile:text;
    descname:string;

    dirname :string;
    curl    :string;

procedure pline;
  var desc:string;
  fn:string;

  function exist:boolean;

     (*
     Procedure Dsearch ( key: string;           { filename to look for }
                    var drec: dirtype;     { resulting record }
                    var dpos: longint);    { resulting pointer }
     *)
     var drec:dirtype;
         dpos:longint;
     begin
     Dsearch(fn,drec,dpos);
     exist:=dpos<>0;
     end;


  var
  d:dirtype;
  rec:longint;

  d1:string[40];
  d2,d3:string[60];

  tval,s2,s3:byte;

  begin
  d1:='';
  d2:='';
  d3:='';

  fn:=upcasestr(rtrim(ltrim(copy(curl,1,pos('/',curl)-1))));

  writeln('fn: "',fn,'"');

  desc:=ltrim(copy(curl,pos('/',curl)+1,length(curl)));

  textcolor(white);write(fn+ltab(length(fn),12));

  textcolor(lightgray);write(' - ');

  if length(desc)>40 then tval:=40 else tval:=length(desc);
  d1:=copy(desc,1,tval);
  if length(desc)>100 then tval:=60 else tval:=length(desc)-40;
  if tval<1 then tval:=0;
  if length(desc) < 41 then s2:=0 else s2:=41;
  d2:=copy(desc,s2,tval);
  if length(desc) >= 160 then tval:=60 else tval:=length(desc)-40;
  if tval<1 then tval:=0;
  if length(desc) < 101 then s3:=0 else s3:=101;
  d3:=copy(desc,s3,length(desc)-101);
  d1:=rtrim(d1);
  d2:=rtrim(d2);
  d3:=rtrim(d3);

  if exist then
    begin
    textcolor(white);
    writeln('Skipped');
    exit;
    end;

  textcolor(green);
  writeln(d1);

  if d1[0]<>#0 then writeln('   ',d2);
  if d3[0]<>#0 then write('   ',d3);

{
Procedure AddFile (var newentry: dirtype; var result: longint);

This procedure call adds a new file to the current directory.  You should
clear the 'Dirtype' parameter and then initialize it with the proper
filename, date, description and file length (note that the length is
expressed as the number of 128 byte blocks in the file, not the size in
bytes).  The 'Id' field in Dirtype should contain the record number of the
user who uploaded the file, if applicable.

This procedure does not check whether the file actually exists.  It is up to
the application program to make that determination before adding the record.
It is permissible to add a record for a file that does not exist, if that is
desired.
}
(*
     DirType = record      { File directory record format }
       leaf: treeleaftype;     { tree/list leaf data }

       name: string[12];       { filename }
       descrip: string[40];    { description }
       edescrip: array[1..2]
         of string[60];        { extended description }
       spare: byte;            { spare byte }
       length: longint;        { length in 128-char blocks }
       id: longint;            { ID of uploader }
       cksum: integer;         { checksum of uploader }
       date: datetype;         { date uploaded }
       times: longint;         { # of times downloaded }
       passwd: pwtype;         { password }
       offline: boolean;       { flag if file not available }

       pad: array[1..41] of byte;    { pad to 256 bytes }
*)
    writeln('filepath: "',maindir.dirinfo.filepath,'"');
    writeln('filename: "',maindir.dirinfo.filepath+fn,'"');

    d.name := fn;
    d.descrip:=d1;
    d.Edescrip[1]:=d2;
    d.edescrip[2]:=d3;
    d.length := sizeoffile(maindir.dirinfo.filepath+fn) div 128;
    d.id := 0;
    d.cksum := 0;
    d.date.year := today_year - 1900;
    d.date.month := today_month;
    d.date.day := today_day;
    d.times := 0;
    fillchar(d.passwd,sizeof(d.passwd),0);
    d.offline := false;

    AddFile(d,rec);

    textcolor(red);

    if rec=0 then
     write(' Error')
    else write(' Added');

  writeln;
  end;

begin

writeln('Tic2Sl v2.01 - long description importer');
writeln;

if paramcount=0 then
  begin
  writeln;
  writeln('no command line parameters present');
  writeln;
  writeln('Tic2Sl [dirname] [files.bbs]');
  writeln('tic2sl SL200 D:\FILES\SL200\FILES.DSC');
  writeln;
  writeln('ListFmt var in tic.cfg _must_ be listfmt %3:-13/%1:-160');
  writeln('you should probably delete the ''files.bbs'' file after this is run');
  writeln;
  halt(1);
  end;

dirname:=upcasestr(paramstr(1));

writeln('dirname: "',dirname,'"');

if not OpenFiles([CONFIGF,NODESF]) then
 begin
 writeln('could not open config or nodes file..');
 halt(1);
 end;

write('initializing directory');

SubListInit(FileDirs);
writeln;

if not OpenDir(dirname,maindir) then
  begin
  writeln('could not open ',dirname);
  halt(1);
  end;

descname := maindir.dirinfo.filepath+paramstr(2);

writeln('descname: "',descname,'"');

if not existfile(descname) then
  begin
  closeallfiles;
  closedir(maindir);
  writeln('No ',descname);
  halt(1);
  end;

assign(descfile,descname);
reset(descfile);

readln(descfile,curl);
pline;

while not eof(descfile) do
  begin
  readln(descfile,curl);
  pline;
  end;

closedir(maindir);
CloseAllFiles;

close(descfile);
end.
