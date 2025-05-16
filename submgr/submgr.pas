{$X+}

Uses Crt,Etc,General,Members,Users,FileDef,Message,Sublist;

Const ProgName = 'SubMgr ';
      Version  = '1.02 ';
      Descrip  = ' The Subboard-Member Manager';
      ByLine   = '       (c) Copyright 1992 by Zak Smith, All Rights Reserved';

procedure ShowSubboards;
  var p: sublistptr;

      m : membtype;
      pos : longint;
      mbr:boolean;

      tempchr:char;

  begin
  If Cf.Ansi then TextBackground ( Black );
  clrscr;
  if cf.ansi then textcolor ( cf.colorchart[special]);
  write('Joined to ');
  case cf.ansi of
     true : write('Highlighted');
     false: write('Starred');
     end;
  writeln(' Subboards');

  if Cf.Ansi then TextColor ( Cf.ColorChart [ Normal ] );
    p:=SubListRoot;

    while (p<>Nil) do begin

    if        (p^.access<=user.access.msglevel)
       and    (user.access.attrib>=p^.attrib)
       and    (p^.visible)
       and not(p^.fname='MAIL')
       and not(p^.fname='BULLETIN') then

      begin
      OpenSub(p^.fname,mainsub,[memberf]);
      Msearch(user.name,m,pos);
      CloseSub(MainSub);
      mbr := not( pos=0);
      if Mbr then TempChr := '*' else TempChr:=' ';
      if cf.Ansi then TempChr := ' ';
      if cf.Ansi then Write('   ') else Write('  ',TempChr);
      If Cf.Ansi and mbr then
       begin
       TextColor ( Cf.ColorChart [ Inverse ] );
       TextBackground ( Cf.ColorChart [ Background ] );
       end;
      Write(' '+CaseStr(p^.fname)+' ');
      if Cf.Ansi then TextColor ( Cf.ColorChart [ Normal ] );
      If Cf.Ansi then TextBackground ( Black );
      write( lTab (length(p^.fname)+1,12) );
      end;
     p:=p^.next;
    end;
  end;

Procedure Proc(s:string);
  function SubExist(sb:string):boolean;
    var p:sublistptr;
    begin
    p:=SubListRoot;
    SubExist:=false;
    while (p<>Nil) do begin
      if (p^.fname=sb) and SubIsReadAble(p,user.access) then
       begin
       SubExist:=true;
       exit;
       end;
      p:=p^.next;
      end;
    end;

  procedure AddM(ts:string);
    var m:membtype;
        l:longint;
    begin
    OpenSub(ts,mainsub,[memberf]);
    AddMember(user,m,l);
    if l=0 then write('error adding member');
    closesub(mainsub);
    end;

  Procedure DelM(ts:string);
    begin
    OpenSub(ts,mainsub,[memberf]);
    if not DeleteMember(user.name) then write('error deleting member');
    closesub(mainsub);
    end;

  var ps :string;
      ts :string;
      fst:byte;
      lst:byte;

  Function EndByte(f:byte): byte;
    var i:byte;
    begin
    for i:=f to length(ps) do
      begin
      if ps[i] in [  ' '  ,  '+'  ,  '/'  ] then begin endbyte:=i; exit; end
      end;
    endbyte:=length(ps)+1;
    end;


  Procedure DoAdd;
      begin
      fst:=pos('+',ps)+1;

      lst:=EndByte(fst)-1;

      ts:=rtrim(copy(ps,fst,lst-fst+1));
      If SubExist(ts) then AddM(ts);
      Delete(ps,1,lst);
      end;

  Procedure DoDel;
      begin
      fst:=pos('/',ps)+1;
      lst:=EndByte(fst)-1;
      ts:=rtrim(copy(ps,fst,lst-fst+1));
      If SubExist(ts) then DelM(ts);
      Delete(ps,1,lst);
      end;

  begin
  ps:=s;

  if (pos('+',ps)=0) and (pos('/',ps)=0) then
    begin
    if cf.ansi then textcolor(cf.colorchart[errcolor]);
    write('Error: ');
    if cf.ansi then textcolor(cf.colorchart[normal]);
    write('Line must contain a verb; `');
    if cf.ansi then textcolor(cf.colorchart[altcolor]);
    write('+');
    if cf.ansi then textcolor(cf.colorchart[normal]);
    write(''' or `');
    if cf.ansi then textcolor(cf.colorchart[altcolor]);
    write('/');
    if cf.ansi then textcolor(cf.colorchart[normal]);
    writeln(''' not found.');

    if cf.ansi then textcolor(cf.colorchart[promptcolor]);
    write('Press any key to continue');readkey;
    exit
    end;

  repeat
   begin

   if (pos('+',ps)>0) and (pos('/',ps)>0) then
    if pos('+',ps)<pos('/',ps) then DoAdd else DoDel
   else if (pos('+',ps)>0) and (pos('/',ps)=0) then DoAdd
   else if (pos('+',ps)=0) and (pos('/',ps)>0) then DoDel
   else ps:='';

   end;
  until Length(ps)=0;

  end;

Function GetCommands:boolean;
   var tempstr:string[120];


  Begin
  if cf.ansi then gotoxy(1,22) else writeln;

  if cf.ansi then clreol;

  if not cf.ansi then writeln;

  if cf.ansi then textcolor(cf.colorchart[altcolor]);
  write('/');

  if cf.ansi then textcolor(cf.colorchart[normal]);
  write('SubName to UnJoin, ');

  if cf.ansi then textcolor(cf.colorchart[altcolor]);
  write('+');

  if cf.ansi then textcolor(cf.colorchart[normal]);
   write('SubName to Join; [');

  if cf.ansi then textcolor(cf.colorchart[altcolor]);
  write('Enter');

  if cf.ansi then textcolor(cf.colorchart[normal]);
  writeln('] to process request or when Done.');

  write('Enter Command: ');

  readln(tempstr);

  if rtrim(tempstr)='' then getcommands:=false else
   begin
   Proc(upcasestr(ltrim(rtrim(tempstr))));
   getcommands := true
   end;

  End;

Begin

directvideo := false;

write('Initializing Node and Config Files... ');

OpenFiles([NodesF,ConfigF]);

Write('User File... ');

openuserfile;
ReadUser(user,cf.curruser);
closeuserfile;

Write('Subboards... ');

SubListInit(Subboards);

 if existfile('MAIN.SUB') then SubListOrder('MAIN.SUB',Subboards)
 else SubListOrder(Cf.DataPath+'MAIN.SUB',Subboards);

clrscr;

repeat begin
  clrscr;
  ShowSubboards end;
until not GetCommands;

CloseAllFiles;
writeln;

if cf.ansi then textcolor(cf.colorchart[headcolor]);
write(ProgName);
if cf.ansi then textcolor(cf.colorchart[normal]);
write('v');
write(version);
writeln(descrip);
writeln(byline);

End.
