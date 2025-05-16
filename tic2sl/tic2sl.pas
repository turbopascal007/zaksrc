Program Tick2Sl;

{$M 16384,0,655360}

Uses ExitErr,Crt,Etc,FileDef,Dir,Dates,Sublist;

Const AnnFN = 'NewFiles.Txt';
      ver   = '2.04';

var descfile:text;
    descname:string;

    dirname :string;
    curl    :string;

    AnnFile :text;

    numf    :longint;
    tsize   :longint;

Procedure Announce(filename,desc,size,area:string);

  procedure wrap(var d1,d2:string);
    function lastsp(i:byte):byte;
      var a:byte;
      begin
      for a:=i downto 1 do
        if desc[a]=' ' then begin
          lastsp:=a;exit;end;
      lastsp:=0;
      end;
    const l=50;
    var lastspace:byte;
        nextspaace:byte;

        t1,t2:string;
        tv,begin2:byte;
    begin
    if length(desc)<=l then
      begin
      tv:=length(desc);
      d1:=desc;
      d2:='';
      exit;
      end
    else
      begin
      tv:=l;
      if desc[tv]<>' ' then
        begin
        begin2:=lastsp(tv);
        if begin2=0 then
          begin
          d1:=copy(desc,1,l);
          d2:=copy(desc,l,length(desc)-l);
          exit;
          end
        else
          begin
          d1:=copy(desc,1,begin2-1);
          d2:=copy(desc,begin2+1,length(desc)-begin2);
          end;
        end
      else
        begin
        d1:=copy(desc,1,l);
        d2:=copy(desc,l+2,length(desc)-l);
        end;
      end;
    end;
  var d1,d2:string;
  begin
  inc(numf);
  wrap(d1,d2);
  d1:=ltrim(rtrim(d1));
  d2:=ltrim(rtrim(d2));
  writeln(annfile,'\gy    File: \ye',filename,'\gy, \wh',ltrim(size),'\gy bytes, File Subboard: \wh',area);
  writeln(annfile,'\gy    Desc: \gr',d1);
  if not(d2[0]=char(0)) then
    writeln(annfile,'          ',d2);
    writeln(annfile);
  end;

procedure pline;
  var desc:string;
  fn:string;

  function exist:boolean;
     var dpos:longint;
         drec:dirtype;
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
  fs:longint;

  begin
  d1:='';
  d2:='';
  d3:='';

  fn:=upcasestr(rtrim(ltrim(copy(curl,1,pos('/',curl)-1))));

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

    d.name := fn;
    d.descrip:=d1;
    d.Edescrip[1]:=d2;
    d.edescrip[2]:=d3;

    fs:=sizeoffile(maindir.dirinfo.filepath+fn);
    d.length := fs div 128;

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
    else
      begin
      inc(tsize,fs);
      Announce(fn,desc,int2comma(fs,6),upcasestr(maindir.name));
      write(' Added');
      end;

  writeln;
  end;

begin

numf:=0;
tsize:=0;

writeln('Tic2Sl v',ver,' - long description importer');
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
  writeln('Must be run from a directory with a valid CONFIG.SL2');
  writeln;
  halt(0);
  end;

dirname:=upcasestr(paramstr(1));

if not OpenFiles([CONFIGF,NODESF]) then
 begin
 writeln('could not open config or nodes file..');
 halt(2);
 end;

SubListInit(FileDirs);

if not OpenDir(dirname,maindir) then
  begin
  writeln('could not open ',dirname);
  closeallfiles;
  closedir(maindir);
  halt(2);
  end;

descname := maindir.dirinfo.filepath+paramstr(2);

if not existfile(descname) then
  begin
  closeallfiles;
  closedir(maindir);
  writeln('No ',descname);
  halt(0);
  end;

assign(AnnFile,cf.textpath+AnnFN);
if existfile(cf.textpath+AnnFN) then
  append(AnnFile)
else
  rewrite(AnnFile);

writeln(annfile,'\gyThe following were received on ',
        '\wh',days[today_day_of_week],' ',months[today_month-1],' ',
        today_day,'\gy,\wh ',today_year,'\gy.');
writeln(annfile);

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

writeln(annfile,'\gr-- \wh',numf,'\gy files totalling \wh',tsize,' \gybytes',
         '\bk -- Tic2Sl v',ver,' by Zak Smith\no');
writeln(annfile);

close(descfile);
close(AnnFile);

if paramcount>2 then begin
  erase(descfile);
  writeln(descname,' erased.');
  end;

end.
