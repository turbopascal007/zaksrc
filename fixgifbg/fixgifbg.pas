
uses dos,crt,gifinfo;

procedure procfile(var s:searchrec;p:pathstr);far;
 var w,h,c:word;
     bg,bc:byte;
     tv:byte;

     f:file;
 begin
 if CheckForGif(p+s.name,w,h,c,bc,bg) then
    begin
    write('Processing '+p+s.name+' .. ');

    if bg=75 then
       begin
       write('left');
       end
    else
       begin
       assign(f,p+s.name);
       reset(f,1);
       seek(f,12);
       tv:=75;
       blockwrite(f,tv,1);
       close(f);
       write('modified');
       end;
    end;

 writeln;

 end;


(********* The following search engine routines are sneakly swiped *********)
(********* from Turbo Technix v1n6.  See there for further details *********)

type
  ProcType=             procedure(var S: SearchRec; P: PathStr);
var
  EngineMask:           PathStr;
  EngineAttr:           byte;
  EngineProc:           ProcType;
  EngineCode:           byte;

function ValidExtention(var S: SearchRec): boolean;
var
  Junk1: dirstr                ;
  junk2: namestr;
  E:                    ExtStr;
begin
  if S.Attr and Directory=Directory then
  begin
    ValidExtention := true;
    exit;
  end;
  FSplit(S.Name,Junk1,Junk2,E);

  if (E='.') then

  ValidExtention := true else ValidExtention := false;
end;

procedure SearchEngine(M: dirstr; Attr: byte; Proc: ProcType;
                       var ErrorCode: byte);
var
  S:                    SearchRec;
  P:                    dirStr;
  Ext:                  ExtStr;
  Mask:                 Namestr;
begin
  FSplit(M, P, Mask, Ext);
  Mask := Mask+Ext;
  FindFirst(P+Mask,Attr,S);
  if DosError<>0 then
  begin
    ErrorCode := DosError;
    exit;
  end;
  while DosError=0 do
  begin
    {if ValidExtention(S) then} Proc(S, P);
    FindNext(S);
  end;
  if DosError=18 then ErrorCode := 0
  else ErrorCode := DosError;
end;

function GoodDirectory(S: SearchRec): boolean;
begin
  GoodDirectory := (S.name<>'.') and (S.Name<>'..') and
  (S.Attr and Directory=Directory);
end;

procedure SearchOneDir(var S: SearchRec; P: PathStr); far;
begin
  if GoodDirectory(S) then
  begin
    P := P+S.Name;
    SearchEngine(P+'\'+EngineMask,EngineAttr,EngineProc,EngineCode);
    SearchEngine(P+'\*.*',Directory or Archive, SearchOneDir ,EngineCode);
  end;
end;

procedure SearchEngineAll(Path: PathStr; Mask: pathStr; Attr: byte;
                          Proc: ProcType; var ErrorCode: byte);
begin
  EngineMask := Mask;
  EngineProc := Proc;
  EngineAttr := Attr;
  SearchEngine(Path+Mask,Attr,Proc,ErrorCode);
  SearchEngine(Path+'*.*',Directory or Archive,SearchOneDir,ErrorCode);
  ErrorCode := EngineCode;
end;

(************** Thus ends the sneakly swiped code *************)
(**** We now return you to our regularly scheduled program ****)

var err:byte;

begin

SearchEngineAll (
  fExpand('.\'),
  '*.GIF',
  anyfile,
  ProcFile,
  err);

end.