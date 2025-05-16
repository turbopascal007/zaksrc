Program AddUU;

Uses Crt,Dos,Etc;

{$V-}

Const FakeNode = '1:1000/4000';
      sqfn =   'j:\db\squish\squish.cfg';
      inafn =  'j:\db\belfry\in.all';
      outafn = 'j:\db\belfry\out.at';
      auufn =  'i:\fred\areas.uu';

{
  squish.cfg
    EchoArea FidoTag i:\path\ aliasnode

  in.all

  out.at
    E sl_tag   -g i:\path   -n -l

  areas.uu
    Map [code]* UN_tag fidotag
}

Var
   FidoTag,
   MsgPath,
   SLTag,
   UseNetTag : string;

   Code      : string[1];

   f         : text;

procedure squish;
 begin
 assign(f,sqfn); write('.');
 append(f);      write('.');
 writeln(f,'EchoArea ',FidoTag,' ',msgpath,'\ ',fakenode);  write('.');
 close(f); write('.');
 end;

procedure inall;
 begin
 assign(f,inafn); write('.');
 append(f); write('.');
 writeln(f,msgpath,ltab(length(msgpath),15),';I ',sltag,' -g ',msgpath,' -k'); write('.');
 close(f); write('.');
 end;

procedure outat;
 begin
 assign(f,outafn); write('.');
 append(f); write('.');
 writeln(f,'E ',sltag,' -g ',msgpath,' -n -l'); write('.');
 close(f); write('.');
 end;

procedure areasuu;
 begin
 assign(f,auufn); write('.');
 append(f); write('.');
 writeln(f,'Map ',code,'* ',usenettag,' ',fidotag); write('.');
 close(f); write('.');
 end;


Begin
{
Editor(maxlen: byte; var Answerformain: string;
 prestring: string;fgc,bgi:byte);
}

CapsOn:=False;

Writeln('AddArea: UU');

textcolor(lightgray);
write('UseNet Newsgroup Name: ');Editor(50,usenettag,'',white,blue);writeln;

textcolor(lightgray);
write('     FidoNet Area Tag: ');Editor(50,fidotag,usenettag,white,blue);writeln;

textcolor(lightgray);
write('  SLBBS Subboard Name: ');Editor(8,sltag,'',white,blue);writeln;

textcolor(lightgray);
write('        Path to *.MSG: ');editor(50,msgpath,'i:\msg\uu\msg\'+sltag,white,blue);writeln;

textcolor(lightgray);
Write('         Mapping Code: ');editor(1,code,'+',white,blue);writeln;
writeln;
writeln('Is everything Correct?');

if upcase(readkey)<>'Y' then halt;

textcolor(lightgray);

fidotag:=upcasestr(fidotag);

write('Processing SQUISH.CFG');  Squish; Writeln;

Write('Processing IN.ALL'); INALL; writeln;

write('Processing OUT.AT'); outat; writeln;

write('Processing AREAS.UU'); areasuu; writeln;

writeln('Making Directory'); mkdir(msgpath); writeln;

writeln('done.  now update SL!');

End.
