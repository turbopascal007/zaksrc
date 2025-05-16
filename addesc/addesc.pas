Uses ExitErr, Etc, Crt, Dos, SlfLow, SlfHigh, SlDriv;

var
   desc: string[60];

   tabl: byte;

Function SmudgeDescriptions(var f:file;R:longint;D:dirtype):boolean;far;
   begin
   if d.edescrip[1]='' then
       begin
       d.edescrip[1]:=desc;
       end
   else
       begin
       d.edescrip[2]:=desc;
       end;
   Write_Data(f,DirF,R,D);

   gotoxy(tabl,wherey);
   write(d.name);clreol;

   SmudgeDescriptions:=TRUE;
   end;

var path   : string;
    dirname: string[8];
    i      : byte;

begin

DirectVideo := NOT SlActive;

if paramcount=0 then
   begin
   writeln;
   writeln('AdDesc path dirname text text ...');
   writeln('AdDesc \slbbs\dir\ offline This is the Description!');
   writeln;
   halt(1);
   end;

path := paramstr(1);
dirname := paramstr(2);

writeln;
if not existfile(path+dirname+'.SL2') then
   begin
   writeln;
   writeln('"',path+dirname+'.SL2" does not exist! -- Aborting');
   halt(1);
   end;

desc[0]:=chr(0);

for i:=3 to paramcount do
   begin
   desc:=concat(desc,paramstr(i),' ');
   end;

desc:=rtrim(desc);

writeln('Processing ',casestr(dirname));

write(desc);

tabl := length(desc)+2;

FileList(dirname,path,SmudgeDescriptions);
writeln;
writeln('done!');
writeln;
writeln('If you have problems or suggestions, let me know');
writeln('                                                       - Zak Smith');
writeln;

end.
