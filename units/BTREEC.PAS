Unit bTree;
{$O+}

Interface

Type KeyType = String[25];

Type StatusType = (Used,Free);
type
 LeafType = record
      Status: StatusType;
      Mother,Left,Right:longint;
      Key: KeyType;
     end;

Type GenericProcedure = procedure;

Procedure InitNewFile  ( var F:file; FileName: String; DataRecSize: longint);
Function  InitFile     ( Var f:file; fn:string):boolean;
Procedure CloseFile    ( var f:file );
Function  AddRecord    ( var f:file; Key: keytype; Var Data):boolean;
Function  KeyFind      ( var f:file; key: keytype):boolean;
Function  KeyFindData  ( var f:file; key: keytype; var data):boolean;
Function  DeleteRecord ( var f:file; key: keytype):boolean;
Function  BalanceHeap  ( var f:file):longint;

Procedure BalanceTree ( var f:file; Reading,Sorting,Updating:GenericProcedure );

Procedure ListNodes    ( var f:file );
Procedure ListNodes2   ( var f:file );
Procedure ListFreeNodes(var f:file);
procedure diagnosticlist (var f:file);


Implementation

Uses Dos;


Type FileHeaderType = record
      DataRecSize,Root,NextFree: longint;
     end;

Type DirectionType = (Right,Left);

Type
     DeletedLeaf = record
      Status  : StatusType;
      NextFree: longint;
      Filler  : array[1..2] of longint;
      Filler2 : KeyType;
      end;

Function RecOfs(n:longint;DataRecSize:longint):longint;
 begin
 RecOfs:=Sizeof(FileHeaderType)+((n-1)*(DataRecSize+Sizeof(LeafType)));
 end;

Procedure ReadRecLeaf(var f:file;n:longint;datarecsize:longint;var RecHdr:LeafType);
 begin
 seek(f,recofs(n,datarecsize));
 blockread(f,rechdr,sizeof(leaftype));
 end;

Procedure ReadRecBoth(var f:file;n:longint;datarecsize:longint;var RecHdr:LeafType;var data);
 begin
 seek(f,recofs(n,datarecsize));
 blockread(f,rechdr,sizeof(rechdr));
 blockread(f,data,datarecsize);
 end;

Procedure WriteRecLeaf(var f:file;n:longint;datarecsize:longint;RecHdr:LeafType);
 begin
 seek(f,recofs(n,datarecsize));
 blockwrite(f,rechdr,sizeof(rechdr));
 end;

Procedure WriteRecBoth(var f:file;n:longint;datarecsize:longint;RecHdr:LeafType;var data);
 begin
 seek(f,recofs(n,datarecsize));
 blockwrite(f,rechdr,sizeof(rechdr));
 blockwrite(f,data,datarecsize);
 end;

Function NumRecords(var f:file;filehdr:fileheadertype):longint;
 var tv:longint;

 begin
 NumRecords := (FileSize(f)-Sizeof(FileHdr)) div (Sizeof(LeafType)+FileHdr.DataRecSize);
 end;

Function GetNewRecNum(var f:file;filehdr:fileheadertype):longint;
 begin
 if filehdr.nextfree=0 then
  begin
  GetNewRecNum := NumRecords(f,filehdr)+1;
  exit
  end
 else
  GetNewRecNum := FileHdr.NextFree;
 end;

Procedure ReadFileHdr(var f:file;var filehdr:fileheadertype);
 begin
 seek(f,0);
 blockread(f,FileHdr, sizeof(filehdr));
 end;

Procedure WriteFileHdr(var f:file; filehdr:fileheadertype);
 begin
 seek(f,0);
 blockwrite(f,FileHdr, sizeof(filehdr));
 end;

Procedure FindNewMother ( var f:file;r:longint;filehdr:fileheadertype);
    var rechdr:leaftype;

    Function FindMother(var direction:directiontype):longint;
      var Hdr  :leaftype;
          LastNode:longint;
      procedure Search_Tree(n:longint);
        begin
        ReadRecLeaf(f,n,FileHdr.DataRecSize,Hdr);
          if RecHdr.Key>Hdr.Key then
             if not(Hdr.Right=0) then Search_Tree(Hdr.Right) else
                 begin
                 LastNode:=n;
                 Direction:=Right;
                 end
          else if RecHdr.Key<Hdr.Key then
             if not(Hdr.Left=0) then Search_Tree(Hdr.Left) else
                 begin
                 LastNode:=n;
                 Direction:=left;
                 end;
        end;
      begin
      Search_Tree(filehdr.root);
      FindMother:=LastNode;
      end;

    var mhdr:leaftype;
        mrec:longint;
        motherdirection:directiontype;
    begin
    ReadRecLeaf(f,r,filehdr.datarecsize,RecHdr);
    mrec:=FindMother(motherdirection);
    ReadRecLeaf(f,mrec,filehdr.datarecsize,MHdr);
    RecHdr.Mother := mrec;
    Case MotherDirection of
       Right: MHdr.Right:=r;
       Left : MHdr.Left :=r;
       end;
    WriteRecLeaf(f,mrec,FileHdr.DataRecSize,MHdr);
    WriteRecLeaf(f,r,filehdr.datarecsize,RecHdr);
    end;

Procedure UpdatePointersWithNoChildren ( var f:file;r:longint;filehdr:fileheadertype);
    var rechdr:leaftype;
    Function FindMother(var direction:directiontype):longint;
      var
             Hdr  :leaftype;
          LastNode:longint;
      procedure Search_Tree(n:longint);
        begin
        ReadRecLeaf(f,n,FileHdr.DataRecSize,Hdr);
        if rEcHdr.Key>Hdr.Key then
             if not(Hdr.Right=0) then Search_Tree(Hdr.Right) else
                 begin
                 LastNode:=n;
                 Direction:=Right;
                 end
        else if RecHdr.Key<Hdr.Key then
             if not(Hdr.Left=0) then Search_Tree(Hdr.Left) else
                 begin
                 LastNode:=n;
                 Direction:=left;
                 end;
        end;
      begin
      Search_Tree(filehdr.root);
      FindMother:=LastNode;
      end;

    var mhdr:leaftype;
        mrec:longint;
        motherdirection:directiontype;

    begin
    ReadRecLeaf(f,r,filehdr.datarecsize,RecHdr);

    mrec:=FindMother(motherdirection);

    ReadRecLeaf(f,mrec,filehdr.datarecsize,MHdr);

    RecHdr.right:=0;
    RecHdr.Left:=0;
    RecHdr.Mother := mrec;

    Case MotherDirection of
       Right: MHdr.Right:=r;
       Left : MHdr.Left :=r;
       end;

    WriteRecLeaf(f,mrec,FileHdr.DataRecSize,MHdr);
    WriteRecLeaf(f,r,filehdr.datarecsize,RecHdr);
    end;

Function FindKeyRec    ( var f:file; key: keytype):longint;
 var filehdr:fileheadertype;
     rechdr :leaftype;

   procedure FindKey(r:longint);
     begin
     ReadRecLeaf(f,r,FileHdr.DataRecSize,RecHdr);

     if Key>RecHdr.Key then
        if not(RecHdr.Right=0) then FindKey(RecHdr.Right) else
               begin
               FindKeyRec:=0;
               end
        else if Key<RecHdr.Key then
             if not(RecHdr.Left=0) then FindKey(RecHdr.Left) else
               begin
               FindKeyRec:=0;
               end
        else if Key=RecHdr.Key then FindKeyRec:=r;
     end;
 begin
 ReadFileHdr(f,filehdr);
 if filehdr.root=0 then FindKeyRec:=0 else FindKey(filehdr.root)
 end;

Function DeleteRecord  ( var f:file; key: keytype):boolean;
 var filehdr:fileheadertype;

 procedure Unlink(r:longint;var delhdr:leaftype);
  Function GetDirection(sonhdr:leaftype):directiontype;
   var sonrighthdr,sonlefthdr,motherhdr:leaftype;
       sre,sle:boolean;
   begin
   ReadRecLeaf(f,sonhdr.mother,filehdr.datarecsize,motherhdr);
   if not(motherhdr.left=0) then
     begin
     ReadRecLeaf(f,motherhdr.left,filehdr.datarecsize,sonlefthdr);
     sle:=true
     end
     else sle:=false;

   if not(motherhdr.right=0) then
     begin
     ReadRecLeaf(f,motherhdr.right,filehdr.datarecsize,sonrighthdr);
     sre:=true;
     end
     else sre:=false;

   {$B-}
   if      sle and not sre then GetDirection:=Left
   else if sre and not sle then GetDirection:=Right
   else if (sle and sre) and (sonrighthdr.key=sonhdr.key) then GetDirection:=Right
   else if (sle and sre) and (sonlefthdr.key=sonhdr.key) then GetDirection:=left;
   {$B+}
   end;

   var MotherHdr:leaftype;
       direction:directiontype;
   begin
   if not(DelHdr.Mother=0) then
     begin
     ReadRecLeaf(f,DelHdr.Mother,FileHdr.DataRecSize,MotherHdr);
     Direction:=GetDirection(DelHdr);
     case Direction Of
       Left : MotherHdr.Left:=0;
       Right: MotherHdr.Right:=0;
       end;
     WriteRecLeaf(f,delhdr.mother,filehdr.datarecsize,motherhdr);
     end
   end;

 Procedure UpdateFreeList(r:longint);

   function LastFree:longint;
    var rechdr:leaftype;n,ths:longint;
     begin
     n:=filehdr.nextfree;
     ths:=n;
     repeat
       begin
       ReadRecLeaf(f,n,filehdr.datarecsize,rechdr);
       ths:=n;
       n:=deletedleaf(rechdr).nextfree;
       end
     until DeletedLeaf(RecHdr).nextfree=0;
     LastFree:=ths;
     end;

   Var updatedptrhdr:leaftype;lf:longint;
   begin
   if filehdr.nextfree=0 then
     begin
     filehdr.nextfree:=r;
     writefilehdr(f,filehdr);
     end
   else
     begin
     lf:=lastfree;
     ReadRecLeaf(f,Lf,filehdr.datarecsize,updatedptrhdr);
     DeletedLeaf(updatedptrhdr).nextfree:=r;
     WriteRecLeaf(f,lf,filehdr.datarecsize,updatedptrhdr);
     end;
   end;

 Procedure AddChildren(var dhdr:leaftype);
   begin
   if not(dhdr.left=0) then FindNewMother(f,dhdr.left,filehdr);
   if not(dhdr.right=0) then FindNewMother(f,dhdr.right,filehdr);
   end;

 Procedure ChangeMother( var f:file;datarecsize:longint;r,tor:longint);
  var rechdr:leaftype;
  begin
  ReadRecLeaf(f,r,filehdr.datarecsize,rechdr);
  rechdr.mother:=tor;
  WriteRecLeaf(f,r,filehdr.datarecsize,rechdr);
  end;

 var DelRecNum:longint;
     delhdr   :leaftype;

 begin
 ReadFileHdr(f,filehdr);
 DelRecNum:=FindKeyRec(f,key);

 DelHdr.Status:=Free;

 if not(DelRecNum>0) then DeleteRecord:=False else
  begin
   ReadRecLeaf(f,delrecnum,filehdr.datarecsize,delhdr);
  if delhdr.Mother=0 then
    begin
    DeleteRecord:=true;

    UpdateFreeList(delrecnum);

    if not(delhdr.Right=0) then
      begin
      FileHdr.Root := delhdr.Right;
      ChangeMother(f,filehdr.datarecsize,delhdr.Right,0);
      if not(delhdr.left=0) then FindNewMother(f,delhdr.left,filehdr);
      end;

    if not(delhdr.left=0) and (delhdr.right=0) then
      begin
      FileHdr.Root := delhdr.Left;
      ChangeMother(f,filehdr.datarecsize,delhdr.Left,0);
      end;

    if (delhdr.right=0) and (delhdr.left=0) then
      begin
      FileHdr.Root:=0;
      end;

    DelHdr.Status:=Free;
    WriteFileHdr(f,filehdr);
    DeletedLeaf(DelHdr).NextFree:=0;
    WriteRecLeaf(f,delrecnum,filehdr.datarecsize,delhdr);
    end
  else
    begin
    DeleteRecord:=true;
    Unlink(DelRecNum,delhdr);
    UpdateFreeList(delrecnum);
    DeletedLeaf(DelHdr).NextFree:=0;
    WriteRecLeaf(f,delrecnum,filehdr.datarecsize,delhdr);
    AddChildren(delhdr);
    end;
  end;
 end;

Function  AddRecord    ( var f:file; Key: keytype; var data):boolean;
  var FileHdr: FileHeaderType;
      RecHdr  : LeafType;

  Procedure AddNewRec;

    Function FindMother(var direction:directiontype):longint;
      var
          RecHdr  :leaftype;
          LastNode:longint;

      procedure Search_Tree(n:longint);
        begin
        ReadRecLeaf(f,n,FileHdr.DataRecSize,RecHdr);

        if Key>RecHdr.Key then
             if not(RecHdr.Right=0) then Search_Tree(RecHdr.Right) else
                 begin
                 LastNode:=n;
                 Direction:=Right;
                 end
        else if Key<RecHdr.Key then
             if not(RecHdr.Left=0) then Search_Tree(RecHdr.Left) else
                 begin
                 LastNode:=n;
                 Direction:=left;
                 end;
        end;

      begin
      Search_Tree(filehdr.root);
      FindMother:=LastNode;
      end;

    var MotherRec      :longint;
        MotherRecHdr   :Leaftype;
        MotherDirection:directiontype;
        NewRecNum      :longint;
        NewRecHdr      :leaftype;

    begin
    MotherRec:=FindMother(MotherDirection);
    ReadRecLeaf(f,MotherRec,filehdr.datarecsize,MotherRecHdr);
    NewRecNum := GetNewRecNum(f,filehdr);

    if not(NewRecNum>NumRecords(f,filehdr)) then
      begin
      ReadRecLeaf(f,NewRecNum,FileHdr.DataRecSize,NewRecHdr);
      FileHdr.NextFree:=DeletedLeaf(NewRecHdr).NextFree;
      end;

    Case MotherDirection of
       Right: MotherRecHdr.Right:=NewRecNum;
       Left : MotherRecHdr.Left :=NewRecNum;
       end;

    With NewRecHdr do
      begin
      Status := used;
      Right  := 0;
      Left   := 0;
      Mother := MotherRec;
      end;

    NewRecHdr.Key:=Key;

    WriteFileHdr(f,FileHdr);
    WriteRecLeaf(f,MotherRec,FileHdr.DataRecSize,MotherRecHdr);
    WriteRecBoth(f,newrecnum,filehdr.datarecsize,NewRecHdr,Data);

    end;


  procedure AddFirstRec;
    begin
    With RecHdr do
      begin
      Status := Used;
      Right  := 0;
      Left   := 0;
      Mother := 0;
      end;
    RecHdr.key:=key;
    FileHdr.Root := 1;
    FileHdr.NextFree := 0;
    Seek(f,0);
    BlockWrite(f,Filehdr,sizeof(filehdr));
    BlockWrite(f,RecHdr,Sizeof(RecHdr));
    BlockWrite(f,data,FileHdr.DataRecSize);
    end;

  begin
  if not KeyFind(f,key) then
    begin
    ReadFileHdr(f,filehdr);
    if FileHdr.Root=0 then AddFirstRec else AddNewRec;
    addrecord := true;
    end
  else AddRecord := false;

  end;

Procedure InitNewFile ( var F:file;FileName: String; DataRecSize: longint);
  Var FileHeader :FileHeaderType;
  begin
  Assign(F,FileName);
  ReWrite(F,1);
  FileHeader.DataRecSize:=DataRecSize;
  FileHeader.Root:=0;
  FileHeader.NextFree:=0;
  BlockWrite(F,FileHeader,Sizeof(FileHeader));
  end;

Function InitFile(var f:file;fn:string):boolean;
 begin
 {$I-}
 Assign(f,fn);
 reset(f,1);
 {$I+}
 InitFile:=ioresult=0;
 end;

Procedure CloseFile(var f:file);
 begin
 close(f);
 end;

Function  KeyFind     ( var f:file; key: keytype):boolean;
 begin
 KeyFind:=FindKeyRec(f,key)>0;
 end;

Function  KeyFindData    ( var f:file; key: keytype; var data):boolean;
 var filehdr:fileheadertype;
     rechdr :leaftype;
     r      :longint;
 begin
 r:=FindKeyRec(f,key);
 if r>0 then
   begin
   ReadRecBoth(f,r,filehdr.datarecsize,rechdr,data);
   KeyFindData:=true;
   end
 else
   keyfinddata:=false
 end;

Function  BalanceHeap  ( var f:file):longint;
  var rechdr    :leaftype;
      filehdr   :fileheadertype;
      numnodes  :longint;

   procedure Climb(r:longint);
      begin
      ReadRecLeaf(f,r,filehdr.datarecsize,rechdr);
      if not(rechdr.left=0) then Climb(rechdr.left);
      ReadRecLeaf(f,r,filehdr.datarecsize,rechdr);
      inc(numnodes);
      if not(rechdr.right=0) then Climb(rechdr.right);
      end;

   begin
   numnodes:=0;
   readfilehdr(f,filehdr);
   if not(FileHdr.Root=0) then Climb(FileHdr.Root);
   balanceheap:=numnodes*20; { sizeof(ListRecType) }
   end;


Procedure BalanceTree ( var f:file; Reading,Sorting,Updating:GenericProcedure );
 type ToListRecType = ^ListRecType;
      ListRecType   = Record
         node,mother,left,right:longint;
         Next:ToListRecType;
         end;
 var filehdr     : fileheadertype;
     ListRecRoot : ToListRecType;
     NumNodes    : longint;
     MarkMem     : pointer;

 Procedure ReadFileToLL;
  var rechdr    :leaftype;
      curlistrec:tolistrectype;
   Procedure Add(r:longint);
     begin
     inc(NumNodes);
     if CurListRec=Nil then
       begin
       new(CurListRec);
       CurListRec^.Next := Nil;
       ListRecRoot := CurListRec;
       end
     else
       begin
       New(CurListRec^.next);
       CurListRec:=CurListRec^.Next;
       CurListRec^.Next := Nil;
       end;
     CurListRec^.Node:=r;
     CurListRec^.Mother:=0;
     CurListRec^.Left:=0;
     CurListRec^.Right:=0;
     end;
   procedure Climb(r:longint);
      begin
      ReadRecLeaf(f,r,filehdr.datarecsize,rechdr);
      if not(rechdr.left=0) then Climb(rechdr.left);
      ReadRecLeaf(f,r,filehdr.datarecsize,rechdr);
      Add(r);
      if not(rechdr.right=0) then Climb(rechdr.right);
      end;
   begin
   CurListRec:=ListRecRoot;
   if not(FileHdr.Root=0) then Climb(FileHdr.Root);
   end;

 Procedure GetRecNumInfo(n:longint; var mother,left,right:longint);
   var c:tolistrectype;
   begin
   c:=listrecroot;
   while c^.node<>n do c:=c^.next;
   mother:=c^.mother;
   left:=c^.left;
   right:=c^.right;
   end;

 Procedure PutRecNumInfo(n,mother,left,right:longint);
  var c:tolistrectype;
   begin
   c:=listrecroot;
   while c^.node<>n do c:=c^.next;
   c^.mother:=mother;
   c^.left:=left;
   c^.right:=right;
   end;

 Function Power(b,e:longint):longint;
   var t,c:longint;
   begin
   t:=b;
   if e=0 then begin power:=1 ; exit end;
   for c:=1 to e-1 do t:=t*b;
   power:=t;
   end;

 Procedure ProcessLL;
  var MaxNumNodes: longint;
      NumSubLevels  : longint;
      TempMother,TempRight,TempLeft:longint;
      Modifier   : longint;


  Function FindNumSubLevels(n:longint):longint;
    var i:longint;
    begin
    i:=1;
    repeat inc(i,1) until (power(2,i)>=n+1);
    FindNumSubLevels:=i-1;
    end;

  Function RightMod(root,modi:longint):longint;
    begin
    repeat
      begin
      modi := modi div 2;
      end
    until root+modi<=numnodes;
    RightMod := modi;
    end;

  Procedure FixSubTree(root:longint;mthr:longint);
     var sr:longint;

     begin

     if not(abs(mthr-root)=1) then
       begin
       modifier:=abs(mthr-root) div 2;
       templeft:=root-modifier;

       if (root+modifier<=NumNodes) then
          tempright:=root+modifier
       else
          begin
          modifier:=Rightmod(root,modifier);
          if not(modifier=0) then TempRight:=root+modifier else tempright:=0;
          end;

       tempmother:=mthr;
       PutRecNumInfo(root,tempmother,templeft,tempright);
       sr:=tempright;

       if not(templeft=0) then FixSubTree(templeft,root);
       if not(sr=0) then FixSubTree(sr,root);

       end
     else { lowest leaves }
       begin
       PutRecNumInfo(root,mthr,0,0);
       end;

     end;

   Function MaxNodes:longint;
    var i:longint;
    begin
    i:=0;
    repeat inc(i,1) until (power(2,i+1)-1)>=NumNodes;
    MaxNodes:= Power(2,i+1)-1;
    end;

   Var NewRoot:longint;

   begin
   MaxNumNodes := MaxNodes;
   NumSubLevels := FindNumSubLevels(MaxNumNodes);

   if NumNodes<2 then NewRoot:=FileHdr.Root else NewRoot:=Power(2,NumSubLevels);

   FileHdr.Root := NewRoot;

   FixSubTree(NewRoot,0);
   end;

 Procedure WriteLLtoFile;
   var CurListRec: tolistrectype;
       l:leaftype;
   begin
   curlistrec:=listrecroot;

   while curlistrec<>nil do
      begin

      ReadRecLeaf(f,curlistrec^.node,filehdr.datarecsize,l);
      l.left:=curlistrec^.left;
      l.right:=curlistrec^.right;
      l.mother:=curlistrec^.mother;
      WriteRecLeaf(f,curlistrec^.node,filehdr.datarecsize,l);
      curlistrec:=curlistrec^.next;
      end;

   end;

 begin
 NumNodes := 0;
 ListRecRoot:=nil;

 Mark(MarkMem);
 ReadFileHdr(f,filehdr);

 reading;

 if not(filehdr.root=0) then ReadFileToLL;

 sorting;

 if not(filehdr.root=0) then ProcessLL;

 updating;

 if not(filehdr.root=0) then WriteLLtoFile;

 WriteFileHdr(f,filehdr);

 Release(MarkMem);
 end;


Procedure ListNodes (var f:file);
 var filehdr:fileheadertype;
     rh     :leaftype;

   procedure s(s:string;t,m,r,l:longint);
    begin
    writeln(t:4,' ',s:4,'  m:',m:4,'  r:',r:4,'  l:',l:4);
    end;

   procedure climb(r:longint);
      var right:longint;
      begin
      ReadRecLeaf(f,r,filehdr.datarecsize,rh);
      right:=rh.right;


      if not(rh.left=0) then Climb(rh.left);

      ReadRecLeaf(f,r,filehdr.datarecsize,rh);
      s(rh.key,r,rh.mother,rh.right,rh.left);

      if not(right=0) then Climb(right);
      end;


 begin
 ReadFileHdr(f,filehdr);
 if filehdr.root<>0 then Climb(filehdr.root);
 end;

Procedure ListNodes2 (var f:file);
 var filehdr:fileheadertype;
     rh     :leaftype;
     ind    :longint;
     di     :directiontype;
     fr:boolean;

   procedure s(s:string;t,m,r,l:longint);
    var i:byte;
    begin
    for i:=1 to ind do write(' ');

    if fr then
    if di=left then Write('Left : ') else write ('Right: ')
    else begin
         fr:=true;
         write('Root : ');
         end;

    writeln(t:3,' "',s,'" m:',m:3,' r:',r:3,' l:',l:3);
    end;

   procedure climb(r:longint);
      var sright:longint;
      begin
      inc(ind,2);
      ReadRecLeaf(f,r,filehdr.datarecsize,rh);
      s(rh.key,r,rh.mother,rh.right,rh.left);

      sright:=rh.right;
      if not(rh.left=0) then begin di:=Left;Climb(rh.left) end;

      if not(sright=0) then begin di:=Right ;Climb(sright) end;
      dec(ind,2);
      end;


 begin
 fr:=false;
 ind:=0;
 ReadFileHdr(f,filehdr);
 if filehdr.root<>0 then Climb(filehdr.root);
 end;

Procedure ListFreeNodes(var f:file);
    var fhdr:fileheadertype;rechdr:leaftype;n,ths:longint;
     begin
     readfilehdr(f,fhdr);

     n:=fhdr.nextfree;
     writeln('Root.NextFree: ',n);
     if n=0 then exit;
     ths:=n;
     repeat
       begin
       ReadRecLeaf(f,n,fhdr.datarecsize,rechdr);
       Writeln(n:3,' DeletedLeaf.NextFree: ',deletedleaf(rechdr).nextfree:2);
       ths:=n;
       n:=deletedleaf(rechdr).nextfree;
       end
     until DeletedLeaf(RecHdr).nextfree=0;
     end;

procedure diagnosticlist(var f:file);
 var i:longint;
     fhdr:fileheadertype;
     l:leaftype;
 begin
 ReadFileHdr(f,fhdr);

 for i:=1 to numrecords(f,fhdr) do
   begin
   readrecleaf(f,i,fhdr.datarecsize,l);
   writeln(i:3,' ',l.key:4,'  m:',l.mother:4,'  r:',l.right:4,'  l:',l.left:4);
   end;

 end;

end.
