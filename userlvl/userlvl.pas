Program UserLvl;

Uses Crt,SLfGen,SLfiles;

Function Compare(r:longint;u:usertype):boolean;far;
var i:byte;
 begin
 Compare := True;
 Write(U.Name:25,': ');
 for i:=1 to 25 do
    begin
    if ((Cfg.AccessDef[i].A.Attrib     = U.Access.Attrib     ) and
        (Cfg.AccessDef[i].A.MsgLevel   = U.Access.MsgLevel   ) and
        (Cfg.AccessDef[i].A.FileLevel  = U.Access.FileLevel  ) and
        (Cfg.AccessDef[i].A.Ratio      = U.Access.Ratio      ) and
        (Cfg.AccessDef[i].A.TimeLimit  = U.Access.TimeLimit  ) and
        (Cfg.AccessDef[i].A.SessLimit  = U.Access.SessLimit  )) then
     begin writeln(Cfg.AccessDef[i].Name); exit end;
    end;
 Writeln('Undefined');
 end;

begin

Init_Config ( Closed , 'd:\slnode2\' );

UserList( Closed , Compare );

end.