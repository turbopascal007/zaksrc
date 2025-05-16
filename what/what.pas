Program What;
{$X+}

uses Crt,SLfLow,SLfHigh,bTree,Etc;

Type Rectype = string[25];
Type DataRec = byte;

Var          f       : file;
             user    : usertype;
             log     : text;
             d       :datarec;

             key     :keytype;
             instr   :string;

var fo:boolean;
begin

filemode := 66;

directvideo:=false;

Init_Config ( '' , Closed );

User_Info(cfg.curruser,user);

if user.calls < 5 then halt;

fo:=InitFile(f,'WHAT.DAT');

If Not fo{bTree.InitFile(f,'WHAT.DAT')} then InitNewFile(f,'WHAT.DAT',Sizeof(d));

if not KeyFind(F,upcasestr(User.Name)) then
 begin
 writeln;
 writeln('If Sirius Cybernetics was to be improved, what would you change/add?');
 write('> ');
 readln(instr);

 if rtrim(ltrim(instr))<>'' then
   begin
   AddRecord(f,upcasestr(user.name),d);

   assign(log,'WHAT.LOG');
   if existfile('WHAT.LOG') then append(log) else rewrite(log);
   writeln(log,dttmstamp,' ',user.name,' -> ',instr);
   close(log);
   end;

 closefile(f);

 end;

end.
