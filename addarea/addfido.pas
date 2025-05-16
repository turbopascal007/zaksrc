Program AddFido;

Uses Crt,Dos,Etc;

{$V-}

Const
      sqfn    = 'd:\db\squish\squish.cfg';
      inafn   = 'd:\db\belfry\in.all';
      outafn  = 'd:\db\belfry\out.at';

{
  squish.cfg
    EchoArea FidoTag c:\path\ aliasnode

  in.all

  out.at
    E sl_tag   -g c:\path   -n -l

}

Var
   hostnode,
   FidoTag,
   MsgPath,
   SLTag     : string;

   f         : text;

procedure squish;
 begin
 assign(f,sqfn); write('.');
 append(f);      write('.');
 writeln(f,'EchoArea ',FidoTag,' ',msgpath,'\ ',hostnode);  write('.');
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

Begin
{
Editor(maxlen: byte; var Answerformain: string;
 prestring: string;fgc,bgc:byte);
}

if paramcount=0 then begin
  writeln('AddFido [host node]');
  halt;
  end;

hostnode := paramstr(1);

CapsOn:=False;

Writeln('AddArea: UU');

textcolor(lightgray);
write('     FidoNet Area Tag: ');Editor(50,fidotag,'',white,blue);writeln;

textcolor(lightgray);
write('  SLBBS Subboard Name: ');Editor(8,sltag,'',white,blue);writeln;

textcolor(lightgray);
write('        Path to *.MSG: ');editor(50,msgpath,'c:\msg\',white,blue);writeln;

textcolor(lightgray);
writeln('Is everything Correct?');

if upcase(readkey)<>'Y' then halt;

textcolor(lightgray);

fidotag:=upcasestr(fidotag);

write('Processing SQUISH.CFG');  Squish; Writeln;

Write('Processing IN.ALL'); INALL; writeln;

write('Processing OUT.AT'); outat; writeln;

writeln('Making Directory'); mkdir(msgpath); writeln;

writeln('done.  now update SL!');

End.