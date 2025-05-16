uses SLfLow,SLfHigh,Crt;

Type
     pFType = ^FType;
     FType = record
      FName: String[12];
      Next: pFType;
      end;

     pDType = ^DType;
     DType = record
      DName: String[8];
      Files: pFType;
      Next: pDType;
      end;

Var Root,Cur   : pDType;
    CurrentDir : string[8];

Procedure FindFiles;
  Procedure Find(f:pFType);
    var c:pDType;
    begin
    C := Root;
    Repeat
        begin
        if (NOT(f=c^.Files)) AND (c^.Files^.FName=f^.fname) then
          begin
          Writeln(f^.fname:12,' ',cur^.dname:8,' ',c^.dname:8);
          end;
        C^.Files := C^.Files^.Next;
        if C^.Files=NIL then C:=C^.Next;
        end;
    until (C=NIL);
    end;

  begin
  Cur := Root;
  writeln('Processing: ',cur^.dname);
  Repeat
    begin
    Find(Cur^.Files);
    Cur^.Files := Cur^.Files^.Next;
    if Cur^.Files=NIL then
      begin
      Cur:=Cur^.Next;
      writeln('Processing: ',cur^.dname);
      end;
    end;
  until (Cur=NIL);
  end;


procedure Add(n:string);
  begin
  If Root=NIL then
    begin
    New(Root);
    Cur := Root;
    Cur^.DName := CurrentDir;
    Cur^.Next := Nil;
    New(Cur^.Files);
    Cur^.Files^.FName := n;
    Cur^.Files^.Next := Nil;
    end
  else
    begin
    if CurrentDir<>Cur^.DName then
      begin
      New(Cur^.Next);
      Cur:=Cur^.Next;
      Cur^.DName := CurrentDir;
      Cur^.Next := Nil;
      New(Cur^.Files);
      Cur^.Files^.FName := n;
      Cur^.Files^.Next := Nil;
      end
    else { another file }
      begin
      New(Cur^.Files^.Next);
      Cur^.Files := Cur^.Files^.Next;
      Cur^.Files^.Fname := n;
      Cur^.Files^.Next := Nil;
      end
    end

  end;


function DoSub(var f:file; r:longint;d:dirtype):boolean;far;
  begin
  DoSub:=true;
  Add(d.name);
  end;

Function CycleSubs (PathtoFiles,subname:string):boolean;far;
 begin
 CycleSubs:=true;
 Currentdir:=subname;
 write(' Adding: ',subname:8,': ');
 FileList (subname,pathtofiles,DoSub);
 Writeln(MemAvail,'b mem free');
 end;

begin
 Root := Nil;

 DirectVideo := True;
 writeln;writeln;writeln;
 Init_Config (  '' , closed);
 MainSubList ( 'Main.dir' , SetupDir , CycleSubs );
 FindFiles;

end.

