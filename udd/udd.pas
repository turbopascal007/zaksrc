Program UDD;

{$X+}

Uses ExitErr,Dos,Crt,Etc,Dates;

Var Ask: boolean;

function a:boolean;
 begin
 write(' ? ');
 a:=upcase(readkey)='Y';
 end;

procedure copyfile(s,d:string);
 const blocksize=60000;
 type bt = array[1..blocksize] of char;
 var sf,df:file;
     b:^bt;
     sfs:longint;

     i:word;
     time: longint;

 begin
 filemode := 0;

 assign(sf,s);
 reset(sf,1);

 filemode := 1;

 {$I-}
 assign(df,d);
 rewrite(df,1);
 {$I+}

 if ioresult<>0 then
   begin
   writeln;
   textcolor(lightred);
   writeln(^G,d,' is obstructed, cannot copy.  Press Any Key to Continue');
   readkey;
   exit;
   end;


 new(b);
 sfs := filesize(sf);


 for i:=1 to sfs div blocksize do
   begin
   textcolor(lightgray);write('.');
   blockread(sf,b^,blocksize);
   textcolor(cyan);
   gotoxy(wherex-1,wherey);write('o');
   blockwrite(df,b^,blocksize);
   textcolor(white);
   gotoxy(wherex-1,wherey);write('.');
   end;


 textcolor(lightgray);write('.');
 blockread(sf,b^,sfs mod blocksize);

 textcolor(cyan);gotoxy(wherex-1,wherey);write('o');
 blockwrite(df,b^,sfs mod blocksize);
 textcolor(white);gotoxy(wherex-1,wherey);write('.');

 getftime(sf,time);
 setftime(df,time);

 close(sf);
 close(df);

 dispose(b);

 end;

function SecondsSince1980(t:datetime):longint;
 var r:longint;
 begin

 secondssince1980:=
   ((serial_day(t.day,t.month,t.year)-serial_day(1,1,1980))*24*3600)+
   t.hour*3600 + t.min*60 + t.sec;

 end;

procedure Update(source,dest:string);
 var   dest_base: string;
     source_base: string;

 procedure dofile(sourcefn:string;source_time:longint);
  VAR
   desttime:longint;
   f2s: searchrec;
   dt,st:datetime;

  begin
  gotoxy(1,wherey);
  textcolor(cyan);write('Processing ');
  textcolor(lightcyan);write(sourcefn:12);
  textcolor(lightgray);write(': ');clreol;


  findfirst(dest_base+sourcefn,ANYFILE xor directory xor volumeid xor sysfile
             xor hidden xor readonly,f2s);

  if doserror<>0 then
    begin
    textcolor(white);write('Adding ');
    textcolor(green);write(source_base);
    textcolor(lightgray);write(' -> ');
    textcolor(green);write(dest_base,' ');

    copyfile(source_base+sourcefn,dest_base+sourcefn);
    writeln;
    end
  else
   begin
   if source_time=f2s.time then
      begin
      TextColor(Random(16)+1);
      write('Same Date & Time');
      end
   else
      begin
      unpacktime(source_time,st);
      unpacktime(f2s.time,dt);

      if SecondsSince1980(st)>SecondsSince1980(dt) then
       begin

       textcolor(white);write('Updating ');
       textcolor(green);write(source_base);
       textcolor(lightgray);write(' -> ');
       textcolor(green);write(dest_base,' ');

       if ask then
        begin
        if a then copyfile(source_base+sourcefn,dest_base+sourcefn)
        end
       else
        copyfile(source_base+sourcefn,dest_base+sourcefn);
       writeln;
       end;

      end;
   end;
  end;


  var s:searchrec;
  begin
  dest_base  :=splitfilepath(dest);
  source_base:=splitfilepath(source);

  findfirst(source,ANYFILE xor directory xor volumeid xor sysfile xor hidden,s);

  while doserror=0 do
    begin
    dofile(s.name,s.time);
    findnext(s);
    end;

  if wherex>5 then
   begin
   textcolor(lightgray);gotoxy(26,wherey);write('Done');clreol;writeln;
   end;

  end;

procedure FPC(c:char);
 begin
 textcolor(random(7)+9);write(c);
 end;


procedure fps(s:string);
 var i:byte;
 begin
 for i:=1 to byte(s[0]) do fpc(s[i]);
 end;



const bragline = 'udd -- Zak Smith, Jan 1993, zak.smith@xanadu.mil.wi.us';

Var
    FS1: string;
    FS2: string;

begin

randomize;

writeln;
textbackground(0);
fps(bragline);

if paramcount=0 then
   begin
   writeln;
   fps('Fool!');write(^G);
   writeln;
   textcolor(cyan);
   writeln;
   writeln('Udd takes two directories and makes sure they both have the latest version');
   writeln('of each file in each directory.');
   writeln;
   writeln('  þ Copies files which exist in [1] but not [2] to [2], and the reverse');
   writeln('  þ If a filename exists in both, it overwrites the older with the newer');
   writeln;
   writeln('This is ideal for a floppy courier system between a home and work computer.');
   writeln;
   textcolor(lightgreen);writeln('Syntax');
   textcolor(white);
   writeln(paramstr(0),' [filespec1] [filespec2] [/A]');
   textcolor(cyan);
   writeln('  /A will cause it to ask whether you are sure if you want to overwrite a file.');
   writeln('  Note a filespec must be specified, not just the path. (ex: \*.*, NOT \)');
   writeln;
   textcolor(yellow);
   writeln('Udd was written by Zak Smith, for reasons unknown.');
   writeln('sysop Sirius Cybernetics, 414-966-3552, xanadu.mil.wi.us');
   halt(0);
   end;



FS1:=fexpand(upcasestr(paramstr(1)));
FS2:=fexpand(upcasestr(paramstr(2)));


if paramcount=3 then ask:=upcasestr(paramstr(3))='/A' else ask:=false;

writeln;
textcolor(white);write('Phase I');
textcolor(lightgray);write('; ');
textcolor(green);write(fs1);
textcolor(lightgray);write(' -> ');
textcolor(green);writeln(fs2);


Update(fs1,fs2);


if wherex>5 then writeln;
writeln;

textcolor(white);write('Phase II');
textcolor(lightgray);write('; ');
textcolor(green);write(fs2);
textcolor(lightgray);write(' -> ');
textcolor(green);writeln(fs1);


Update(fs2,fs1);

end.