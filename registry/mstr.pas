program ABMSTR;

uses dos,crt,etc;

Var
    Strs: array[1..200] of string;
    txt : text;
    sys : file;

    totallen: longint;

    tl  : string;
    tn  : word;
    c   : word;
    offs: longint;
    num : word;
    bffr: array[0..255] of char;

procedure Recompute;
 Const LengthOfStr = 5000;
 Type MsgChckArray = array[1..lengthofstr] of byte;

  type stray=array[1..256] of byte;
  var r  :pwtype;
      rc :pwtype;
      a  :msgchckarray;
      i  :word;
      j,k:byte;
      ts :string;
      tsr:stray;
      CRCVal: longint;
  begin
  i:=1;
  for j:=1 to num do
      begin
      move( mem[seg(strs[j]):ofs(strs[j])+1],a[i],length(strs[j]));
      inc(i,length(strs[j]));
      end;

  CRCVal :=CRC32Array(@a[1],i-1);

  Blockwrite(sys,CRCVAL,sizeof(CRCVAl));

  end;

begin
  totallen := 0;

  assign(txt,'c:\tp\work\registry\registrY.str');
  reset(txt);

  assign(sys,'c:\tp\work\registry\registry.sys');
  rewrite(sys,1);

 num:=0;
 repeat
  begin
  readln(txt,tl);
  tl:=rtrim(ltrim(tl));
     begin
     val(copy(tl,1,pos(' ',tl)-1),tn,c);
      if c=0 then
        begin
        inc(num);
        tl:=copy(tl, (pos('''',tl)+1), (length(tl)-pos('''',tl)) );

        {hdr[tn]:=length(copy(tl,1,pos('''',tl)-1));}
        strs[tn]:=copy(tl,1,pos('''',tl)-1);
        end else begin writeln('error: ',tl); halt end;
     end;
  end;
 until eof(txt);

 ReCompute;

 blockwrite(sys,num,sizeof(num));

 for c:=1 to num do
   begin
   if not(ord(strs[c][0])=0) then
       begin
       move(strs[c],bffr,sizeof(bffr));
       blockwrite(sys,bffr,ord(strs[c][0])+1);
       writeln(strs[c]);
       inc(totallen,length(strs[c])+1);
       end;
   end;
close(sys);
close(txt);
writeln;
writeln(totallen);
writeln;
end.