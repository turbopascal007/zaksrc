program mailsessions;


uses dos,etc,crt,dates;

type tt = array[1..65520] of char;

var f:text;
    t:^tt;

    EMSIs,YOOHOOs : word;

    line: string;
    lc:longint;

    ts:string;

begin

directvideo:=true;

EMSIs := 0;

YOOHOOs := 0;

lc:=0;

new(t);

assign(f,'DB.LOG');
reset(f);
settextbuf(f,t^,sizeof(t^));

ts:= tostr2(today_month,2) + '/' + tostr2(today_day,2) + '/' + tostr2(today_year-1900,2) + ' ';

writeln('Mail Session Counter');
writeln;
writeln;

write('Processing line: ');

while not eof(f) do
 begin
 readln(f,line);
 inc(lc);

 if (lc mod 100)=0 then begin gotoxy(18,wherey);write(lc) end;

 if copy(line,1,9)=ts then
   begin
   If pos('EMSI:',line)>0 then inc(emsis);
   if pos('YOOHOO:',line)>0 then inc(yoohoos);
   end;

 end;

close(f);

release(t);

writeln;

assign(output,'');
rewrite(output);

if (emsis>0) or (yoohoos>0) then   write(output,'There have been ')
  else writeln(output,'There haven''t been ANY mail sessions today!');

if emsis>0 then write(output,emsis,' EMSI mail sessions ');

if (emsis>0) and (yoohoos>0) then write(output,'and ');

if yoohoos>0 then write(output,yoohoos,' YOOHOO mail sessions ');

if (emsis>0) or (yoohoos>0) then write(output,'today.');

close(output);

end.