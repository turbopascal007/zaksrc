 {
  type buftype = array[1..16384] of char;
  var i,o:text;
      ib,ob: ^buftype;
      s:string;
  procedure ProcLine;
    var Name,Address,Date:string;

    begin
    if copy(s,1,5)='From ' then
      begin
      Name := copy(s,6,pos(' ',copy(s,6,length(s)-6))-7);
      end
    else
     begin
     writeln(o,s);
     end
    end;

  begin
  if Mail then
    begin
    new(ib);
    new(ob);

    assign(i,fn);
    settextbuf(i,ib^,sizeof(ib^));
    reset(i);

    assign(o,copy(fn,1,pos('.',fn)-1)+'DA#');
    settextbuf(o,ob^,sizeof(ob^));
    rewrite(o);

    readln(i,s);
    while not eof(i) do begin
      procline;
      readln(i,s);
      end;

    dispose(ib);
    dispose(ob);
    end;
  }