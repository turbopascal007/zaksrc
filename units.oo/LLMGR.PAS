Unit LLMgr;  { Provides General Purpose Linked List Functions }

interface

Type
  SinglyLinkedListObj - Object
   Constructor Init(DRS:longint);




   private
   DataRecSize:longint;

   end;

implementation



Type LinkType = ^PtrToLinkType;
     PtrToLinkType = record
      Next: LinkType;
      Data: Pointer;
      end;

Var CurListRec : LinkType;

function AddNextListRec(Root,ToData:pointer;l:longint):pointer;
  begin
  CurListRec:=Root;

  if CurListRec=Nil then

     begin
     new(CurListRec);

     GetMem(CurListRec^.Data, L);
     Move(ToData^,CurListRec^.Data^,L);

     CurListRec^.Next := Nil;
     AddNextListRec:=CurListRec;

     end

   else
     begin

     New(CurListRec^.next);

     CurListRec:=CurListRec^.Next;

     GetMem(CurListRec^.Data, L);
     Move(ToData^,CurListRec^.Data^,L);

     CurListRec^.Next := Nil;
     AddNextListRec:=CurListRec;
     end;

  end;


begin
  CurListRec := nil;
end.