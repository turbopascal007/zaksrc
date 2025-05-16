Unit EdLMgr;
{$O+,F+}

interface

Uses EditLine;

Const EditingFieldsStr: string[80] = 'Editing Fields. Press [ESC] or ^Z when finished; F2 or ^U to restore old values';

Type pLL_t= ^ll_t;
 LL_t = record
   next,prev:pll_t;
   me:pLineEditObj;
 end;

Type
  pLineEditMgrObj = ^LineEditMgrObj;
  LineEditMgrObj = Object
   Constructor Init(fg,bg,abarcolor_,psmlen_,psc_:byte;
                   ansi_:boolean;
                   exf:editorexitallowtype;
                   Write_:WriteType;
                   MoveX_:MoveXType;
                   WhereX_:WhereXType;
                   textcolor_:textcolortype;
                   textbackground_:textbackgroundtype;
                   readkey_:readkeytype;
                   gotoxy_:gotoxytype;
                   ClrEol_:ClrEolType;
                   AEC_:string;
                   instruc_y_,instruc_c_:byte);

   Procedure Add(Sx,Sy,Mlen:byte;instr:string;edf:editorfuncflagstype;pstr:string);
   Procedure Run;

   Function Out:String;

   Destructor Done;
   private
    AEC:string;
    fgc,bgc,abarcolor,psmlen,psc,instruc_y,instruc_c:byte;
    ansi:boolean;
    exitflags:EditorExitAllowType;
    write:writetype;
    movex:movextype;
    wherex:wherextype;
    textcolor:textcolortype;
    textbackground:textbackgroundtype;
    readkey:readkeytype;
    gotoxy:gotoxytype;
    ClrEol:ClrEolType;

    Root,  { root of list }
    Last, { last in list, to prevent an endless loop an endless loop an.. }
    Current { current, used for Add and Out }
      : pLL_t;
    Procedure NoMore;
   end;


implementation

Constructor LineEditMgrObj.Init(fg,bg,abarcolor_,psmlen_,psc_:byte;
                   ansi_:boolean;
                   exf:editorexitallowtype;
                   Write_:WriteType;
                   MoveX_:MoveXType;
                   WhereX_:WhereXType;
                   textcolor_:textcolortype;
                   textbackground_:textbackgroundtype;
                   readkey_:readkeytype;
                   gotoxy_:gotoxytype;
                   clreol_:clreoltype;
                   AEC_:string;
                   instruc_y_,instruc_c_:byte);
 begin
 clreol:=clreol_;
 instruc_c:=instruc_c_;
 instruc_y:=instruc_y_;
 psc:=psc_;
 psmlen:=psmlen_;
 AEC:=AEC_;
 fgc:=fg;
 bgc:=bg;
 abarcolor:=abarcolor_;
 exitflags:=exf;
 write:=write_;
 movex:=movex_;
 wherex:=wherex_;
 textcolor:=textcolor_;
 textbackground:=textbackground_;
 readkey:=readkey_;
 gotoxy:=gotoxy_;

 root:=nil;
 Root^.me := Nil;
 root^.next:=nil;
 root^.prev:=nil;
 ansi:=ansi_
 end;

Destructor LineEditMgrObj.Done;
 var cur:pll_t;
 begin
 cur:=root;
 if cur=last then
   begin
   dispose(cur^.me,done);
   cur^.me := nil;
   dispose(cur);
   cur := nil;
   end
  else
   begin
   repeat
    begin
    cur^.me^.done;
    dispose(cur^.me,done);
    cur^.me := nil;
    if cur<>root then begin dispose(cur^.prev); cur^.prev := nil end;
    cur:=cur^.next;
    end;
    until cur=root;
   dispose(last);
   end;
 last:=nil;
 root:=nil;
 current:=nil;
 end;

Procedure LineEditMgrObj.Add(Sx,Sy,Mlen:byte;instr:string;edf:editorfuncflagstype;pstr:string);
 var cur:pll_t;
 begin
 cur:=root;
 if cur=nil then
     begin
     new(cur);

     cur^.me:= New(pLineEditObj,Init(Sx,Sy,MLen,fgc,bgc,abarcolor,
              ansi,instr,edf,exitflags,write,movex,wherex,textcolor,
              textbackground,readkey,gotoxy,clreol,pstr,psmlen,psc));

     cur^.next := nil;
     cur^.prev:=nil;
     root:=cur;
     end
   else
     begin
     cur:=root;
     while cur^.next<>nil do cur:=cur^.next;
     new (cur^.next);
     cur^.next^.prev := cur;
     cur := cur^.next;

     cur^.me := New(pLineEditObj,Init(Sx,Sy,MLen,fgc,bgc,abarcolor,
              ansi,instr,edf,exitflags,write,movex,wherex,textcolor,
              textbackground,readkey,gotoxy,clreol,pstr,psmlen,psc));

     cur^.next := nil;
     end;
 end;

procedure LineEditMgrObj.NoMore;
 var cur: pll_t;
 begin
 last := nil;
 cur:=root;
 while cur^.next<>nil do
   begin
   cur:=cur^.next;
   if cur=nil then exit;
   end;
 cur^.next:=root;
 last:=cur;

 root^.prev:=last;

 end;

Procedure LineEditMgrObj.Run;
 var cur  : pll_t;
     d    : boolean;
     trash: char;
 begin
 if ansi and (instruc_y>0) then
   begin
   Gotoxy( ((80-length(EditingFieldsStr)) div 2)+1, instruc_y);
   TextBackground(0);
   TextColor(Instruc_c);
   Write(EditingFieldsStr);
   end;

 NoMore;

 cur:=root;
 d:=false;

 if ansi then
  if cur=last then cur^.me^.antibar(false) else
   begin
   repeat
    begin
    cur^.me^.ansiprompt;
    cur^.me^.antibar(false);
    cur:=cur^.next;
    end;
    until cur=root
   end;

  cur:=root;

  if ansi then
   repeat
     begin
     case cur^.me^.edit of
       up    : begin
               Cur^.me^.antibar(true);
               cur:=cur^.prev;
               end;

       down  : begin
               Cur^.me^.antibar(true);
               cur:=cur^.next;
               end;

       enter : begin
               Cur^.me^.antibar(true);
               cur:=cur^.next;
               end;

       tab   : begin
               Cur^.me^.antibar(true);
               cur:=cur^.next;
               end;

       esc   : begin
               Cur^.me^.antibar(true);
               d := true
               end

       end; { case }
     end
   until d
 else
   repeat
   begin
   if cur=last then
     begin
     cur^.me^.NonAnsiPrompt;
     write('>');
     if cur^.me^.edit=enter then {nothing};
     Write(crlf);
     Write(AEC+' ');
     case upcase(readkey(trash)) of
       'Y': d:=true;
       'N': { do nothing here };
       end
     end
    else
     begin
     repeat
      begin
      cur^.me^.nonansiprompt;
      write('>');
      if cur^.me^.edit=enter then {nothing};
      cur:=cur^.next;
      end;
      until cur=root;
      Write(crlf);
      Write(AEC+' ');
      case upcase(readkey(trash)) of
       'Y': d:=true;
       'N': { do nothing here };
       end
     end;
   end
   until d;

 if ansi and (instruc_y>0) then
   begin
   gotoxy(1,instruc_y);
   textbackground(0);
   clreol;
   end;

 Current := root;
 end;

Function LineEditMgrObj.Out:string;
 begin
 Out:=Current^.Me^.Answer;
 if current^.next<>nil then current:=current^.next;
 end;

end.
