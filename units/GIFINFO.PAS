unit gifinfo;
{$O+}

interface

Function CheckForGif(fs:string;var width,height,colors:word; bitcolor,background:byte):boolean;



implementation

Function CheckForGif(fs:string;var width,height,colors:word; bitcolor,background:byte):boolean;
  type GifHdrType = record
        ID     : array[1..6] of char;
        rwidth : word;
        rheight: word;
        colorb:byte;
        bitcolor: byte;
        background: byte;
        zeros:byte;
        end;
  var f     :file;
      GifHdr:GifHdrType;
      bpp   :byte;
  begin
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
     background:=GifHdr.BackGround;
     BitColor:=GifHdr.BitColor;
     CheckForGif:=True;
     end
   else CheckForGif:=False;

  end;

end.
