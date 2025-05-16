Program BalTree;

Uses bTree,etc;

procedure r;far;
 begin
 write('Reading... ');
 end;

Procedure s;far;
 begin
 write('Sorting... ');
 end;

procedure u;far;
 begin
 write('Updating... ');
 end;

Var Data:pbTreeObj;
    fn:string;

begin


if paramcount=0 then
 begin
 writeln('BalTree [filename.ext]');
 halt;
 end;

fn:=paramstr(1);

if not existfile(fn) then
 begin
 writeln('file ',fn,' does not exist!');
 halt;
 end;

Data:=New(pbTreeObj,init(fn,0));

{
  Function  BalanceHeapReq:longint;
  Procedure Balance(Reading,Sorting,Updating:GenericProcedure);
}

writeln('Balancing ',upcasestr(fn));

Writeln('Memory Available: ',memavail,' Memory Required: ',Data^.BalanceHeapReq);

if MaxAvail <= Data^.BalanceHeapReq then
 begin
 writeln('Not Enough Ram Available!');
 dispose(data,done);
 halt;
 end
else
 begin
 Write('Status: ');
 Data^.Balance(r,s,u);
 writeln(' done');;
 end;
dispose(data,done);

end.
