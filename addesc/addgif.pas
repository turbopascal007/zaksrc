uses slflow,slfhigh,etc;


var d:dirtype;
    s:setupdata;

    dn: string;

    dFH:dirheader;

Function CheckForGif(fs:string;var width,height,colors:word):boolean;
  type GifHdrType = record
        ID     : array[1..6] of char;
        rwidth : word;
        rheight: word;
        colorb : byte;
        end;

  var f     :file;
      GifHdr:GifHdrType;
      bpp   :byte;
  begin

  if not existfile(fs) then
    begin
    checkforgif:=false;
    writeln(fs,' does not exist, skipping');
    exit;
    end;

  fillchar(GifHdr,Sizeof(GifHdr),' ');
  assign(f,fs);
  reset(f,1);
  if filesize(f)<sizeof(gifhdr) then { bail out ! }
    begin
    CheckForGif:=False;
    close(f);
    Exit;
    end;

  blockread(f,GifHdr,sizeof(gifhdr));
  close(f);

  if ((GifHdr.ID[1]='G') and (GifHdr.ID[2]='I') and (GifHdr.ID[3]='F') and
      (GifHdr.ID[4]='8') and (GifHdr.ID[5]='7') and (GifHdr.ID[6]='a')) then
     begin
     Width :=GifHdr.rWidth;
     Height:=GifHdr.rHeight;
     BPP:=GifHdr.ColorB and 7 +1;
     If BPP=1 then Colors:=2 else Colors:=1 shl BPP;
     CheckForGif:=True;
     end
   else CheckForGif:=False;

  end;


function Proc(var f:file;r:longint;d:dirtype):boolean;far;
  var h,w,c:word;
   ts:string;
  begin
  Proc:=true;

  if CheckForGif(dFH.filepath+d.name,h,w,c) then
    begin
    ts:='('+tostr(h)+'x'+tostr(w)+'x'+tostr(c)+')';

    if (d.descrip='') or (ts=d.descrip) then d.descrip:=ts
    else if (d.edescrip[1]='') or (d.edescrip[1]=ts) then d.edescrip[1]:=ts
    else if (d.edescrip[2]='') or (d.edescrip[2]=ts) then d.edescrip[2]:=ts
    else if copy(d.edescrip[2],length(d.edescrip[2])-length(ts),length(ts))<>ts then
       d.edescrip[2]:=d.edescrip[2]+ts;

    writeln(d.name,'  ',ts);
    write_data(f,dirF,r,d);
    end;

  end;



begin

dn:=paramstr(1);

if dn='' then
 begin
 writeln('AddGif SLDirName');
 halt;
 end;

init_config( '', closed );

if not setup_info ( dn, setupdir, s) then
  begin
  writeln('Could not find subboard: ',dn);
  halt;
  end;

filelist( dn, s.path, proc, dFH);

end.