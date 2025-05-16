Program What;

uses crt,etc,btree;

Type Rectype = string[25];
type dt = char;

Var          datafile: file;
             datarec : rectype;
             lastrec : longint;
             instr   : string;

             log     : text;

             f       :file;
             d       :dt;

var i:longint;

begin
filemode := 66;

InitNewFile(f,'WHAT.DAT',sizeof(d));

assign(datafile,'WHAT.OLD');
reset(datafile,sizeof(datarec));


writeln;
for i:=1 to filesize(datafile) do
 begin
 Seek(datafile,i);
 blockread(datafile,datarec,1);
 if AddRecord(f,DataRec,d) then Writeln('''',datarec,'''') else writeln('ACK! ','''',datarec,'''');
 end;

CloseFile(f);
close(datafile);

end.