Uses Dos,SlMenus;

Var Old,NewM:Menutype;
    p1,p2,p3:string;
    t:menuitemptr;
    NewNewM:menutype;

begin

if paramcount=0 then begin
 writeln('MergeMNU Input1 Input2 NewFile');
 writeln('MergeMNU \slbbs\menus\main \slbbs\menus\files \slbbs\menus\glob');
 halt end;

p1:=paramstr(1);
p2:=paramstr(2);
p3:=paramstr(3);

swapvectors;
Exec( getenv('comspec'),'/C COPY '+p1+'.MNU '+p3+'.MNU');
swapvectors;

if not ReadMenu(p2,old) then halt;

if not Readmenu(p3,newm) then halt;

inc(old.size,newm.size);






end;
