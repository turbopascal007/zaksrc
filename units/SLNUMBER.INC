function SlNumber:word;
  var exefile: file;
      offs   : longint;
      bffr   : array[1..512] of char;
      against: integer;
      a      : integer;
      oldfilemode: byte;
  begin
  if not existfile(cfg.progpath+'login.exe',anyfile) then
    begin
    slnumber := 0;
    exit;
    end;

  if cfg.version<300 then
    begin
    oldfilemode:=filemode;
    filemode:=0;
    assign(exefile, cfg.progpath+'login.exe');
    reset(exefile,1);
    filemode:=oldfilemode;
    offs := filesize(exefile)-sizeof(bffr);
    seek(exefile, offs);
    blockread(exefile, bffr, sizeof(bffr));
    Close(exefile);
    a:=0;
    repeat
     inc(a);
    until ((bffr[a]=#4) and (bffr[a+1]=#32) and (bffr[a+2]=#51)) or
           (a = sizeof(bffr)-3);
    dec(a,8);
    against := (ord(bffr[a+1])*$100) + ord(bffr[a]);
    SlNumber:=Against;
    end
 else
      begin
      oldfilemode:=filemode;
      filemode:=0;
      assign(exefile, cfg.progpath+'login.exe');
      reset(exefile,1);
      filemode:=oldfilemode;
      offs := filesize(exefile)-sizeof(bffr);
      seek(exefile, offs);
      blockread(exefile, bffr, sizeof(bffr));
      Close(exefile);
      a:=0;
      repeat
       inc(a);
      until ((bffr[a]='0') and (bffr[a+1]='1') and (bffr[a+2]='2') and
        (bffr[a+3]='3')) or
             (a = sizeof(bffr)-3);

      { this is pretty much broken for 3.5BETA }

      dec(a,17);

      against := (ord(bffr[a+1])*$100) + ord(bffr[a]);

      if against=0 then  { for 3.5 beta }
        begin
        inc(a,6); {total dec 17}
        against := (ord(bffr[a+1])*$100) + ord(bffr[a]);
        end;

      SlNumber:=Against;
      end
   end;
