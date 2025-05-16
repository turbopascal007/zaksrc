Program StripNL;

Type Bffrtype = array[1..65520] of char;

var InBffr : ^bffrtype;
    OutBffr: ^Bffrtype;
    CurL   : string;
    InFile : text;
    OutFile: text;

procedure ProcLine;
  var pos1,pos2,pos3,pos4:byte;
  var ts:string;
  begin
  pos1:=pos(',',curl);

  ts:=copy(curl,pos1+1,length(curl)-pos1);

  pos2:=pos(',',ts)+pos1;

  ts:=copy(curl,pos2+1,length(curl)-pos2);

  pos3:=pos(',',ts)+pos2;

  ts:=copy(curl,pos3+1,length(curl)-pos3);

  pos4:=pos(',',ts)+pos3;

  if pos3-pos2>5 then
    delete(curl, pos2+1,5);

  if pos4-pos3>5 then
    delete(curl, pos3+1,5);

  end;


begin
new(inbffr);
new(outbffr);

Assign(InFile,paramstr(1));
reset(infile);
SetTextBuf(InFile,InBffr^,sizeof(InBffr^));

Assign(OutFile,'nodelist.!!!');
rewrite(outfile);
settextbuf(outfile,outbffr^,sizeof(outbffr^));

readln(infile,curl);

while not eof(infile) do
  begin
  if curl[1]<>';' then procline;
  writeln(outfile,curl);

  readln(infile,curl);

  end;

close(infile);
close(outfile);

end.