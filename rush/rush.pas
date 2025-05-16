Program RUSH;

Uses bTree,Crt,Etc;

Type
 CDQualityType = (AAD,ADD,DDD);

 AlbumsType = (R,FbN,CoS,TOT,AtWaS,aFtK,H,PeW,MP,ESL,
               S,GuP,PoW,HYF,aSoH,P,C,RtB);

 AlbumsSetType = Set of AlbumsType;

 AlbumType = record
  ID       : AlbumsType;
  Name     : String[25];
  RelYear  : word;
  ProdLabel: String[20];
  CDQuality: CDQualityType;
  Length   : longint;
  end;

 TxtDataType = Record
  TuneName  : String[35];
  CDTrack   : byte;
  Length    : word; { Seconds! }
  Albums    : AlbumsSetType;
  end;

 pLoadTxtDataObj = ^LoadTxtDataObj;
 LoadTxtDataObj = Object
  Constructor Init(fn:string);
  Function    Next(Var TD:TxtDataType):boolean;
  Destructor Done;
  private
   f:text;
   a:albumtype;
  end;

Constructor LoadTxtDataObj.Init(Fn:string);
 begin
 assign(f,fn);
 reset(f);
 end;

Function LoadTxtDataObj.Next(var TD:txtdatatype):boolean;
 var s:string;
 begin
 readln(f,s);
 if eof(f) then Next:=False else
  begin
  Next:=True;
  s:=ltrim(rtrim(Upcasestr(s)));
  if copy(s,1,5)='ALBUM' then
    begin { init new album data }

    s:=trimch(s,'"');

    a.name:=copy(s,1,pos('"',s)-1);

    s:=ltrim(trimch(s,'"'));

    a.relyear:=toint(copy(s,1,pos(' ',s)-1));

    s:=ltrim(trimch(s,'"'));

    a.ProdLabel:=copy(s,1,pos('"',s)-1);

    s:=ltrim(trimch(s,'"'));

    if s='AAD' then a.cdquality:=AAD
    else if s='ADD' then a.cdquality:=ADD
     else if s='DDD' then a.cdquality:=DDD;

    a.id:=R;

    a.length:=0;

    Next:=Next(td);

    end
   else { song info }
    begin
    td.albums:=td.albums and a;

    s:=ltrim(trimch(s,'"'));

    td.tunename:=copy(s,1,pos('"',s)-1);

    s:=ltrim(trimch(s,'"'));

    td.CDTrack := toint(copy(s,1,pos(' ',s)-1));

    s:=ltrim(trimch(s,' '));

    td.length:=toint(copy(s,1,pos(':',s)-1))*60;

    s:=ltrim(trimch(s,':');

    td.length:=td.length + toint(copy(s,1,lenth(s));

    td.

    end;

  end;
 end;

Destructor LoadTxtDataObj.Done;
 begin
 close(f);
 end;

Begin

end.