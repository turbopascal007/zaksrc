{$X+} { - eXtended Syntax - Allow for functions to act like procedures,
          not returning anything. }

{$B+} { - Complete Boolean Evaluation - Allow functions that aren't just
          functions to be executed. }

{$M 16384,0,81920} { Allow 384k for DSZ.COM and TAPE.EXE }

Uses Dos,Crt,etc;

Type
    QuickIndexType = Record
     FileName: string[12];
     RecNum  : longint;
     end;

    FileListPtr = ^FileListType;
    FileListType = record
     FileName: string[12];
     RecNum  : longint;
     next    : FileListPtr;
     end;


Var
    CurFile : FileListPtr;
    NextFile: FileListPtr;
    listroot: filelistptr;

    QuickFile: File;

  Procedure LoadFromQuick;
    var           n:longint;
        QuickIdxRec: QuickIndexType;
    begin
    assign(QuickFile,'d:\sltest\TAPEFILE.IDX');
    reset(QuickFile,17);

    for n:= 1 to filesize(QuickFile) do
      begin
      BlockRead(QuickFile,QuickIdxRec,1);

      if ListRoot=Nil then
       begin
       new(CurFile);
       ListRoot := CurFile;
       CurFile^.Next := Nil;
       end
      else
       begin
       PrevFile := CurFile;
       New(CurFile);
       PrevFile^.Next := CurFile;
       CurFile^.Next := Nil;
       end;

     With CurFile^ do
      begin
      FileName := QuickIdxRec.FileName;
      RecNum := QuickIdxRec.RecNum;
      end;

     inc(cnt);
     if (cnt mod 85)=0 then status;
     end;

    if not ANSI then writeln else gotoxy(24,wherey);
     write(cnt:5, ' files read');

    end;




   CurFile := ListRoot;
   While CurFile <> Nil do
    begin
    if N=Copy(CurFile^.FileName,1,length(N)) then
      begin


      end;
    CurFile := CurFile^.Next
    end;




    type bffrtype = array[1..20480] of char;
    var tfile: text;
        ts   : string;
        bffr : ^bffrtype;
        a    : byte;

begin
  loadfromquick;

  for a:=1 to 2 do
    begin
    new(bffr);
    assign(tfile,'d:\sltest\VOLUME.'+Tostrb(z));
    reset(tfile);
    SetTextBuf(tfile, bffr^,sizeof(bffr^));
    readln(tfile,ts);
    repeat
     begin
     ts:=copy(upcasestr(Rtrim(ts)),1,20);




     readln(tfile,ts);
     end
    until eof(tfile);
    dispose(bffr);
    end;
end.