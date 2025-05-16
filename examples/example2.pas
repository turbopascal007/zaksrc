Program Example2;

{
   This program will demonstrate the use of dynamic variables and maybe
   even some disk handling if I get around to it..
}

{ Compiled with Turbo Pascal 7.0; Should work with 6.0 as well }


Uses Dos,Crt;

Type  pPathType = ^PathType;
      PathType = record
       Name     : String[13];
       Children : pPathType;
       end;
{

  The structure will look like this:
     [Root]|
           |Path1|
           |     |SubPath1
           |     |SubPath2
           |
           |Path2|
           |     |SubPath3
                 |SubPath4

}




Function BuildList:boolean;

 Function AddPath(p:string;var c:pPathType):boolean;
   begin




   end;

 var Cur: pPathType;
 Prcoedure DoPath(p:string);
  begin

  end;

 var s:SearchRec;
 begin




 BuildList:=True;
 end;



Var Root:pPathType;
    Mrk :pointer;

begin
Root:=nil;
Mark(Mrk); { save heap state }
if not BuildList then
  begin
  Writeln;
  Writeln('Not Enough Memory; Aborting');
  Release(Mrk)
  Halt(1);
  end;

Release(Mrk) { restore heap state }
end.

froo!