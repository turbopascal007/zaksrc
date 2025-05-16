{$M 20000,0,655360} 

Uses ExitErr,Dos,Crt,Etc,
     General,Filedef,SubList,Message,Users,Post,
     Dates,bTree;

Const ConfigFile = 'SLFDNANN.CFG';
      Ver = '1.03';

      dlen = 50;
      numfileps = 50;

type FilePT = record
       num: byte;
       p  : array[1..numfileps] of string;
       end;

  Var FileP   : FilePT;
      SearchP : String;

      NetName : string;

      FromWho : String;
      ExtraL  : String;

      NumSubs : byte;
      SubNames: array[1..10] of string[8];

      DataBase: ^btreeobj;

Procedure ReadConfig;
 var cf: text;
     l : string;

 procedure proc;
  var hdr: string;
  begin
  hdr := upcasestr(copy(l,1,pos(' ',l)-1));
  if hdr[1]<>';' then
   begin
   if hdr='OUTBOUND' then
      begin
      inc(filep.num);
      FileP.p[filep.num]:=ltrim(rtrim(copy(l,pos(' ',l)+1,length(l)-pos(' ',l))))
      end

   else if hdr='TIC' then SearchP:=ltrim(rtrim(copy(l,pos(' ',l)+1,length(l)-pos(' ',l))))
   else if hdr='FROM' then FromWho:=ltrim(rtrim(copy(l,pos(' ',l)+1,length(l)-pos(' ',l))))
   else if hdr='EXTRA' then ExtraL:=ltrim(rtrim(copy(l,pos(' ',l)+1,length(l)-pos(' ',l))))
   else if hdr='NET' then NetName:=ltrim(rtrim(copy(l,pos(' ',l)+1,length(l)-pos(' ',l))))

   else if hdr='SUB' then
     begin
     inc(numsubs);
     SubNames[numsubs] := ltrim(rtrim(copy(l,pos(' ',l)+1,length(l)-pos(' ',l))));
     end;
   end;
  end;

 begin
 SearchP := '';
 FromWho := '';
 ExtraL := '';
 netname:='';
 fillchar(filep,sizeof(filep),0);

 NumSubs := 0;
 FillChar(SubNames,sizeof(subnames),0);

 if not existfile(configfile) then
   begin
   Writeln('Could not locate ',configfile);
   halt;
   end;

 assign(cf,configfile);
 reset(cf);

 readln(cf,l);
 while not eof(cf) do
   begin
   proc;
   readln(cf,l);
   end;

 close(cf);

 end;


var NumF : word;
    TSize: Longint;

    f    :text;

procedure AddTic(var s:searchrec; p:pathstr);far;
var       Area, FileName, Desc, size, fullpathname: string;

  procedure wrap(dsc:string;var d1,d2:string);
    function lastsp(i:byte):byte;
      var a:byte;
      begin
      for a:=i downto 1 do
        if dsc[a]=' ' then begin
          lastsp:=a;exit;end;
      lastsp:=0;
      end;

    var lastspace:byte;
        nextspaace:byte;

        t1,t2,t3:string;
        tv,begin2:byte;

    begin
    if length(dsc)<=dlen then
      begin
      tv:=length(dsc);
      d1:=dsc;
      d2:='';
      exit;
      end
    else
      begin
      tv:=dlen;
      if dsc[tv]<>' ' then
        begin
        begin2:=lastsp(tv);
        if begin2=0 then
          begin
          d1:=copy(dsc,1,dlen);
          d2:=copy(dsc,dlen,length(dsc)-dlen);
          exit;
          end
        else
          begin
          d1:=copy(dsc,1,begin2-1);
          d2:=copy(dsc,begin2+1,length(dsc)-begin2);
          end;
        end
      else
        begin
        d1:=copy(dsc,1,dlen);
        d2:=copy(dsc,dlen+2,length(dsc)-dlen);
        end;
      end;
    end;

    var inf: text;
      l  : string;

      tf: file;

  function filepindex(fn:string): byte;
    var a:byte;
    begin
    filepindex := 0;
    for a:=1 to numfileps do
      if existfile(filep.p[a]+fn) then
        begin
        filepindex:=a;
        exit;
        end;
    end;


  procedure proc;
    { sample..
     Area SL_FDN
     Origin 250:200/736
     From 250:200/736
     File AMIJD104._SL
     Desc Displays a list of subboards and highlights the ones that the user is joined to
     CRC EE46A053
     Created by Hatch v2.00 (C) Copyright Barry Geller - 1988,1989,1990
     Path 1:154/736 715172621 Sun Aug 30 11:03:41 1992 GMT
     Seenby 1:154/736
     Seenby 250:200/736
     Seenby 250:2/1
    }
    var hdr: string;
    begin
    hdr := copy(l,1,pos(' ',l)-1);
    if hdr='Area' then Area:=copy(l,pos(' ',l)+1,length(l)-pos(' ',l))
    else if hdr='File' then FileName:=copy(l,pos(' ',l)+1,length(l)-pos(' ',l))
    else if hdr='Desc' then Desc:=copy(l,pos(' ',l)+1,length(l)-pos(' ',l));
    end;

  var d1,d2,d3,d4,d5,d6:string;
      tfpi: byte;


  begin
  writeln('Processing ',p+s.name);

  assign(inf,p+s.name);
  reset(inf);

  while not eof(inf) do
    begin
    proc;
    readln(inf,l);
    end;
  close(inf);

  tfpi := filepindex(filename);

  if tfpi=0 then
    begin
    writeln(filename,' not found in any of the outbound directories!');
    exit;
    end;

  If not DataBase^.Find(upcasestr(filename)) then
    begin

    {$I-}
    assign(tf,filep.p[tfpi]+filename);
    reset(tf,1);
    {$I+}
    if IOResult=0 then
      begin
      size:=Int2Comma(FileSize(tf),6);
      inc(tsize,filesize(tf));
      inc(numf);
      Close(tf);
      end
    else size:='<ERROR>';

    d1:='';d2:='';d3:='';d4:='';d5:='';d6:='';

    wrap(desc,d1,d2);

    if length(d2)>dlen then wrap(d2,d2,d3);
    if length(d3)>dlen then wrap(d3,d3,d4);

    if length(d4)>dlen then wrap(d4,d4,d5);
    if length(d5)>dlen then wrap(d5,d5,d6);

    writeln(f,'\gy    Area: \wh',Area);
    writeln(f,'\gy    File: \ye',filename,'\gy, \wh',ltrim(size),'\gy bytes');

    writeln(f,'\gy    Desc: \gr',d1);
    if not(d2[0]=char(0)) then  writeln(f,'          ',d2);

    if not(d3[0]=char(0)) then  writeln(f,'          ',d3);

    if not(d4[0]=char(0)) then  writeln(f,'          ',d4);

    if not(d5[0]=char(0)) then  writeln(f,'          ',d5);

    if not(d6[0]=char(0)) then  writeln(f,'          ',d6);

    writeln(f);

    writeln('    Area: ',Area);
    writeln('    File: ',filename);
    writeln('  Length: ',size,' bytes');
    writeln('    Desc: ',d1);

   if not(d2[0]=char(0)) then writeln('          ',d2);
   if not(d3[0]=char(0)) then writeln('          ',d3);
   if not(d4[0]=char(0)) then writeln('          ',d4);
   if not(d5[0]=char(0)) then writeln('          ',d5);
   if not(d6[0]=char(0)) then writeln('          ',d6);

    writeln;



    if not DataBase^.Add(upcasestr(filename),filename){any thing.. not used}
     then writeln('error adding!');
   end
  else
   writeln(filename,'  -- Allready hatched!');

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

  if (E='.TIC') then

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

procedure PostMSG(sn:string);
 var msg: msgptr;
     s,subboard,filename: string;
     valid: boolean;
     header: headertype;
     inputfile: text;
     p: SubListPtr;
     result: longint;
 Begin

    Subboard := rtrim(ltrim(upcasestr(sn)));

    Write('Writing Message to ',casestr(subboard),'  ');

    p:=ListIndex(subboard);   { get list index, if valid subboard name }
    if (p=Nil) or (p^.fname<>subboard) then
        begin
        writeln('Cannot find subboard ',subboard);
        exit;
        end;

    if OpenSub(subboard,Mainsub,Allfiles) then begin     { Open subboard }

      { initialize message pointer }
      new(msg);
      clearmsg(msg);

      { input text file name and open text file }

      assign(inputfile,'slfdnann.$$$');
      reset(inputfile);

      while (not eof(inputfile)) and (msg^.msglen<=MaxLines) do begin
        readln(inputfile,s);
        if length(s)>MaxLinlen
          then s:=copy(s,1,maxlinlen);    { truncate if necessary }
        AddLine(msg,s);
      end;
      close(inputfile);

      fillchar(header,sizeof(header),0);
      with header do begin
        from:=FromWho;
        touser:='ALL';
        subj:=tostr(numf)+' File(s) Hatched.';
        dosdate(date);
        dostime(time);
      end;

      { post the message }
      result:=MsgPost(msg,header,0,true,true);

      { discard the text in memory }
      DisposeMsg(msg);

      { close the subboard }
      CloseSub(Mainsub);
    end
    else writeln('Error opening subboard!');

    writeln;

    end;

var err: byte;
    i  : byte;
begin

ReadConfig;

New(DataBase,Init('SlFdnAnn.DAT',0));

writeln;
writeln;

assign(f,'slfdnann.$$$');
rewrite(f);

writeln(f,'\gyThe following were hatched into the \whSL_FDN\gy on _');

writeln(f,'\wh',days[today_day_of_week],' ',months[today_month-1],' ',
today_day,'\gy,\wh ',today_year,'\gy.');

writeln('The following were hatched into the SL_FDN on ',days[today_day_of_week],' ',
  months[today_month-1],' ',today_day,', ',today_year,'.');

writeln(f);

numf:=0;
tsize:=0;

SearchEngineAll (
  SearchP,
  '*.TIC',
  anyfile,
  AddTic,
  err);

writeln(f,'\gr-- \wh',numf,'\gy files totalling \wh',tsize,' \gybytes');
writeln('-- ',numf,' files totalling ',tsize,' bytes');

writeln(f,'\gy',EXTRAL);
if extral<>'' then writeln(EXTRAL);

writeln(f,'\bk-- slfdnann v',ver,' by Zak Smith\no');

close(f);

writeln;

if NumF>0 then
 begin

 write('Opening Files... ');

 if OpenFiles([CONFIGF,NODESF]) and OpenUserFile then
   begin
   Writeln('Initializing Subboards... ');
   SubListInit(Subboards);    { Initialize subboard list }

   for i:=1 to numsubs do PostMsg(SubNames[i]);

   writeln('Closing Files..');

   CloseUserFile;
   CloseAllFiles;
   end
 else writeln('could not open config,nodes, or user file');
 end;

Dispose(DataBase,Done);

end.

