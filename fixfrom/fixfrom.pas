Program FixFrom;

Uses Dos,Etc;

{

 Since the course title is "Advanced Programming", I thought I'd give you
 something else along with my C programs.  This is by no means the most
 complex thing I've written in Turbo Pascal, but it's the most recent.


 Purpose:  Take outgoing *.DAT mail packets from the spool directory and
           change around the first line so that my UUCP feed can handle it.

 Sample text:

 From Zak.Smith Sat, 07 Nov 92 17:33:10 -0600 remote from xanadu.mil.wi.us
 <file data>

 .. must be changed to ..

 From Zak.Smith@xanadu.mil.wi.us  Sat, 07 Nov 92 17:33:10 -0600
 <file data>


 The lines are delimited with just LF's, not the DOS CR/LF combination, so
 we can't use the nice TEXT data type.  We will process them in binary mode.
 File size limit is 64k.  No one can send outgoing mail larger from my site
 anyhow.
}

Const CunBatch = '#! cunbatch'+^J;

Var domain: string;

Procedure ProcessFile(fn:string);
  Function Mail: boolean;
   var f: file;
       s: string[12];
   begin
   assign(f,fn);
   reset(f,1);
   s[0] := #12;
   blockread(f,s[1],12);
   close(f);
   Mail := not (s=CunBatch)
   end;

  Const BS = 512;
  Type BufType = Array[1..BS] of char;

  Var i,o  : File; { binary files must be used because it's LF, not CR/LF }
      Buf  : pointer;
      Name, Date, Addr, FullStr, DoneStr: String;
      BufSize: word;

  begin
  if Mail then
    begin
    Assign(i,fn);
    reset(i,1);
    blockread(i,FullStr[1],255);

    FullStr[0]:=#255;
    FullStr[0]:=char(Pos(#10,FullStr)-1);

    Write('Processing: ',lowcasestr(fn));
    Name := copy(fullstr,6,pos(' ',copy(fullstr,6,length(fullstr)-6))-1);

    if pos('@',name)>0 then
      begin
      writeln(': what luck, it''s already been done!');
      close(i)
      end
    else
      begin
      assign(o,copy(fn,1,pos('.',fn)-1)+'.DA#');
      rewrite(o,1);

      Date := copy(fullstr,length('From ')+length(name)+1,32);
      Addr := copy(fullstr,pos('remote from ',fullstr)+length('remote from '),50);
      addr := addr + domain;
      DoneStr:='From '+Name+'@'+Addr+' '+date;

      writeln('; Mail from ',name,'@',addr);

      blockwrite(o,donestr[1],byte(donestr[0]));
      seek(i,length(fullstr));

      if filesize(i)-1-length(fullstr)>=65535 then
        begin
        writeln('  Mem Req''d: ',filesize(i)-1-length(fullstr),
                '; max is 65535, sorry!');
        close(o);
        erase(o)
        end
      else
        begin
        bufsize:=filesize(i)-1-length(fullstr);

        write(ltab(0,length('Processing: ')));

        write('Reading ');
        getmem(buf,bufsize);
        write('[',bufsize,']');
        blockread(i,buf^,bufsize);

        write('; Writing');
        blockwrite(o,buf^,bufsize);

        freemem(buf,bufsize);
        write('; ');

        close(i);
        close(o);
        write('Deleting');
        erase(i);
        writeln('.')
        end
      end
    end;
  end;

var S: SearchRec;
    f: file;
begin

if paramcount=0 then
  begin
  writeln('fixfrom [domain]');
  writeln('fixfrom mil.wi.us');
  halt(2)
  end;

domain := '.' + lowcasestr(paramstr(1));

FindFirst('*.DAT',AnyFile XOR Directory XOR SysFile XOR ReadOnly,S);

while DosError=0 do
   begin
   ProcessFile(s.name);
   FindNext(S)
   end;

Writeln('Renaming Files');

FindFirst('*.DA#',AnyFile XOR Directory XOR SysFile XOR ReadOnly,S);

while DosError=0 do begin
   assign(f,s.name);
   rename(f,copy(s.name,1,pos('.',s.name)-1)+'.DAT');
   findnext(S)
   end

end.
