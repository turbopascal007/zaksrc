Uses SlFiles,SlFGen,Etc,SlDriv,ExitErr,Crt;

Var User: UserType;

Function IfMember (PathToFiles,Subname : String):boolean; far;
 var tempchr  : char;
     tempsetup: setupdata;
     yesmbr   : boolean;
 begin



 if not (SubName='MAIL') then
  begin
  if not Setup_Info (SubName,SetupMsg,Open,tempsetup) then
   halt(1);

  If ((User.Access.MsgLevel >= TempSetup.Access) and
      (User.Access.Attrib >= TempSetup.Attrib))

   then

   begin

   YesMbr := Not  (
      MemberOf ( PathtoFiles, Subname , User.Name , Closed )
      =0
     );


   if YesMbr then TempChr := '*' else TempChr:=' ';

   if cfg.Ansi then TempChr := ' ';


   if cfg.Ansi then Write('   ')
    else Write('  ',TempChr);

   If Cfg.Ansi and yesmbr then
    begin
    TextColor ( Cfg.ColorChart [ Inverse ] );
    TextBackground ( Cfg.ColorChart [ Background ] );
    end;

   Write(' '+CaseStr(Subname)+' ');

   if Cfg.Ansi then TextColor ( Cfg.ColorChart [ Normal ] );

   If Cfg.Ansi then TextBackground ( Black );

   write( Tab (length(subname)+1,12) );

   end;
  end;

  IfMember := True;
 end;

Procedure Finale; far;
  begin
  if not(ExitCode=0) then
    begin
    writeln(ErrorString(ExitCode));
    end;

  end;

var p:pointer;

begin

FileMode := 66;

DirectVideo:=false;

writeln;

ExitProc:=@Finale;

Init_Config( closed , '' );

init_user;
read_user(cfg.curruser,user);
close_user;

If Cfg.Ansi then TextBackGround ( Black );
If Cfg.Ansi then TextColor ( Cfg.Colorchart [Normal] );

if not Cfg.Ansi then
  begin
  Write( CaseStr(User.Name) ,' is currently joined to subboards with a ''');
  Write('*');
  Writeln('''.');
  end
 Else
  begin
  TextColor ( Cfg.ColorChart [ Normal ] );
  Writeln( CaseStr(User.Name), ' is joined to the highlighted subboards.');
  end;


MainSubList ( 'MAIN.SUB' , SetupMSG , Closed , IfMember );


{$IFNDEF ZAK}
if cfg.ansi then textcolor ( cfg.colorchart [special] );
writeln;
writeln('This FreeWare Program was written by Zak Smith.');
writeln;
{$ENDIF}

end.
