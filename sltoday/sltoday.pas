program SlToday;

Uses Crt,Dos,Etc;


type dtype    = record
     used:boolean;
     year: word;
     msg : string[80];
   end;

Type DataType= array[1..12] of array[1..31] of dtype;


procedure loadtext;
  type bt= array[1..16384] of byte;

  var tf:text;
      b : ^bt;
      l : string;
      df: file of datatype;
      d :datatype;

  begin
  assign(tf,'sltoday.all');
  reset(tf);
  new(b);
  settextbuf(tf,b^,sizeof(b^));

  assign(df,'sltoday.dat');
  rewrite(df);

  readln(tf,l);
  while not eof(tf) do
   begin

   if l[1]='S' then
      begin



      end;

   readln(tf,l);
   end;

  write(df,d);

  close(tf);
  close(df);

  end;


var d    :datatype;
    dfile:file of datatype;

begin
if not existfile('sltoday.dat') then loadtext;






end.