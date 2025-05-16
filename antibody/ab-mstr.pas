program ABMSTR;

uses dos,crt,etc;

Var Hdr : array[1..100] of byte;
    Strs: array[1..100] of string;
    txt : text;
    sys : file;

    tl  : string;
    tn  : word;
    c   : word;
    offs: longint;
    num : word;
    bffr: array[0..255] of char;

begin
  assign(txt,'c:\tp\work\antibody\ANTIBODY.TXT');
  reset(txt);

  assign(sys,'c:\tp\work\antibody\ANTIBODY.SYS');
  rewrite(sys,1);

 fillchar(hdr,sizeof(hdr),#0);
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

        hdr[tn]:=length(copy(tl,1,pos('''',tl)-1));
        strs[tn]:=copy(tl,1,pos('''',tl)-1);
        end else begin writeln('error: ',tl); halt end;
     end;
  end;
 until eof(txt);

{ seek(sys,0);
 blockwrite(sys,hdr,sizeof(hdr));
 seek(sys,100);

 offs:=100;
}
 blockwrite(sys,num,sizeof(num));

 for c:=1 to 100 do
   begin
   if not(hdr[c]=0) then
       begin
       move(strs[c],bffr,sizeof(bffr));
       blockwrite(sys,bffr,hdr[c]+1);
       writeln(strs[c]);
       end;
   end;
close(sys);
close(txt);
end.