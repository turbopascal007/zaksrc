Uses Dos,BoyrMore,Crt,Etc;

Const S1: string = '\%s'; { s1[0] = s2[0] !!!! }
      S2: string = '\&s';

      p1: string = ' Processing: ';

Procedure Grunge(var s:searchrec; p:pathstr);far;
  Const BackSearch = 512;
  type BufType = Array[1..BackSearch] of char;
  Var f     : file;
      fLen  : word;
      ofs   : word;
      Buf   : ^BufType;
      base  : word;
      slen  : word;
      ftime : longint;
  begin
  gotoxy(length(p1)+1,wherey);
  textcolor(cyan);
  write(p+s.name,' ');
  {$I-}
  Assign(f,p+s.name);
  Reset(f,1);
  {$I+}
  if not(IoResult=0) then Exit;
  New(Buf);
  fLen := FileSize(f);
  if (fLen)<512 then
     begin
     Base:=0;
     slen:=flen;
     end
  Else
     begin
     Base:=fLen-Backsearch;
     slen:=BackSearch;
     end;
  Seek(f,base);
  BlockRead(f,Buf^,slen);
  ofs := BMSearch(Buf^,S1,slen);
  if ofs=$ffff then
      begin
      textcolor(lightred);
      write('UnGrunged');clreol;
      { not found }
      end
  else
      begin {process}
      textcolor(yellow);
      write('Grunged');clreol;
      seek(f,base+ofs);
      blockwrite(f,s2[1],length(s2));
      end;
  Dispose(Buf);
  Close(f);
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


var err: byte;
begin
CursorOff;
MakeBMTable(btable,S1);
textbackground(black);
textcolor(lightgray);
writeln;
writeln('GMSG - The Message Grunger (Customized for SCBBS)');
textcolor(white);
write(p1);
SearchEngineAll (
  fExpand('.\'),
  '*.MSG',
  anyfile,
  Grunge,
  err);
writeln;
writeln;
CursorOn;
end.