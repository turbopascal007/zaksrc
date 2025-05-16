Program DelUU;

Uses Crt,Dos,Etc,timer;

{$V-}

Const sqfn =   'd:\db\squish\squish.cfg';
      inafn =  'd:\db\belfry\in.all';
      outafn = 'd:\db\belfry\out.at';
      auufn =  'c:\fred\areas.uu';
{
  squish.cfg
    EchoArea FidoTag c:\path\ aliasnode

  in.all

  out.at
    E sl_tag   -g c:\path   -n -l

  areas.uu
    Map [code]* UN_tag fidotag
}

Var
   FidoTag,
   MsgPath,
   SLTag,
   UseNetTag : string;

procedure deleteLine(fn,findstr:string);
 var i,o:text;
     s:string;
     f:string;

 procedure proc;
   begin
   if pos(f,upcasestr(s))=0 then writeln(o,s)
   else begin
        writeln;
        writeln(s);
        end;
   end;

 begin
 f:=upcasestr(findstr);
 assign(i,fn);
 reset(i);

 assign(o,copy(fn,1,pos('.',fn))+'tmp');
 rewrite(o);

 readln(i,s);
 while not eof(i) do
   begin
   proc;
   readln(i,s);
   end;

 close(i);
 close(o);

 erase(i);

 rename(o,fn);
 end;


Begin

CapsOn:=False;

Writeln('DelArea: UU');

textcolor(lightgray);
write('UseNet Newsgroup Name: ');Editor(50,usenettag,'',white,blue);writeln;

textcolor(lightgray);
write('     FidoNet Area Tag: ');Editor(50,fidotag,usenettag,white,blue);writeln;

textcolor(lightgray);
write('  SLBBS Subboard Name: ');Editor(8,sltag,'',white,blue);writeln;

textcolor(lightgray);
write('        Path to *.MSG: ');editor(50,msgpath,'c:\msg\uu\msg\'+sltag,white,blue);writeln;

writeln;
textcolor(lightgray);
writeln('Is everything Correct?');

if upcase(readkey)<>'Y' then halt;

textcolor(lightgray);

fidotag:=upcasestr(fidotag);

write('Processing SQUISH.CFG');
   deleteline(sqfn,msgpath);
   Writeln;

Write('Processing IN.ALL');
   deleteline(inafn,msgpath);
   writeln;

write('Processing OUT.AT');
   deleteline(outafn,msgpath);
   writeln;

write('Processing AREAS.UU');
   deleteline(auufn,usenettag);
   writeln;

writeln('Removing Directory');
 killfilespec(msgpath+'\*.*');
 rmdir(msgpath); writeln;

writeln('done.  now update SL!');

End.
