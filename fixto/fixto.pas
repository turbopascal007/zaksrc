Program FixFrom;

{$R-}

Uses Dos,Etc;

const ss = 'C rmail ';

var sysn: string;

function dof(fn:string):boolean;far;
 type at = array[1..1] of char;
 var f:file;
     b:^at;
     a:word;
     fs:word;
     ofs:word;
     newtostr:string;


 begin
 assign(f,fn);
 reset(f,1);
 fs:=filesize(f);
 getmem(b,fs);
 blockread(f,b^[1],fs);


 ofs:= FindStrInArray(b^,fs,ss);

 write(fn,'  ');

 if ofs<>$FfFf then
   begin
   newtostr[0]:=char(fs-ofs+length(ss));
   move(b^[ofs+length(ss)],newtostr[1],fs-ofs+length(ss));

   if pos('%',newtostr)=0 then writeln(' allready done.') else
    begin
    newtostr := copy(newtostr,1,pos('%',newtostr)-1) + '@' + sysn;
    seek(f,ofs+length(ss)-1);
    blockwrite(f,newtostr[1],byte(newtostr[0]));
    truncate(f);
    writeln('Remapped to: ',newtostr);
    end
   end
 else writeln('Not Remapped');



 close(f);
 freemem(b,fs);

 dof:=true;
 end;


begin

if paramcount=0 then sysn:='xanadu.mil.wi.us' else sysn:=paramstr(1);

ThroughFiles('*.X',dof);

end.
