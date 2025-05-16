Uses Dos,Crt,SlFgen,SlFiles,Etc;

var textfile : text;
    curline  : string;

    Dir      : DirType;


procedure procline;
  var fn:string[12];
      fd:string[120];
      rn:longint;

  begin
  fn:=rtrim(copy(curline,1,12));

  if fn='' then exit;

  delete(curline,1,27);

  fd:=curline;

  rn:=fileinsldir(fn,paramstr(2),'c:\tp\',open);

  gotoxy(length('Processing: '),wherey);

  write(fn:12);

  if not(rn=0) then
    begin

    read_dir(rn,dir);
    dir.descrip:=lowcasestr(fd);

    if length(fd)>40 then dir.EDescrip[1] :=
      copy(fd,41,length(fd)-41);

    write_dir(rn,dir);

    writeln(': ',fd);
    gotoxy(1,wherey);
    write('Processing: ');
    end
  else write(' ..not in slbbs!');

  end;

begin

cursoroff;

directvideo := true;

assign(textfile,paramstr(1));
reset(textfile);

readln(textfile,curline);

init_dir('c:\tp\',paramstr(2));

writeln;
writeln;
write('Processing: ');

while not eof(textfile) do
   begin
   procline;
   readln(textfile,curline);
   end;

close_dir;
close(textfile);

cursoron;

end.
