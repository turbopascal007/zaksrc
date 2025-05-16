Unit BasicIO;

Type
     WriteType = Procedure (s:string);
     movexType = Procedure (x:integer);
     WhereXType = Function:byte;
     TextColorType = Procedure(c:byte);
     TextBackgroundtype = procedure(c:byte);
     ReadKeyType = function(var extend:char):char;
     GotoXYType = procedure(x,y:byte);
     ClrEolType = Procedure;

 pBasicIOObj = ^BasicIOObj;
 BasicIOObj = object







  end;