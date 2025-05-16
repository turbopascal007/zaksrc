Uses Dos,Crt;

var findstr: string;
    insertfile: pointer;
    ifs:word;


procedure sig(var s:searchrec;p:pathstr);far;
 const bs=200;
 type bt = array[1..bs] of char;

 var f      :file;
     fs     :word;
     thisofs:word;

     buf    :^bt;

 procedure arg;
  var c:word;
  begin
  for c:=bs downto 4 do
   begin
   if (buf^[c]='-') and
      (buf^[c-1]='-') and
      (buf^[c-2]='-') then
     begin thisofs:=c; exit end;
   end;

  end;


 begin
 assign(f,p+s.name);
 reset(f,1);
 fs:=filesize(f);

 getmem(buf,bs);

 seek(f,fs-bs);
 blockread(f,buf^,bs);

 thisofs:=$ffff;

 arg;

 if thisofs<>$FFFF then
  begin
  seek(f,fs-bs-3+thisofs);
  blockwrite(f,insertfile^,ifs);
  blockwrite(f,buf^[thisofs-3],bs-thisofs-3);
  end;

 freemem(buf,bs);
 close(f);

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

  if (E='.MSG') then

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
    if ValidExtention(S) then Proc(S, P);
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

procedure readfile;
 var f:file;
 begin
 if paramcount=0 then halt;
 assign(f,paramstr(1));
 reset(f,1);
 ifs:=filesize(f);
 getmem(insertfile,ifs);
 blockread(f,insertfile^,ifs);
 close(f);
 end;

var err: byte;

begin

readfile;

SearchEngineAll (
  fExpand('.\'),
  '*.MSG',
  anyfile,
  Sig,
  err);

freemem(insertfile,ifs);

end.