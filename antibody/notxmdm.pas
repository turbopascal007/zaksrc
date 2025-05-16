uses filedef,slfiles;

var user: usertype;
    n   : word;
    c   : integer;

begin
 if paramcount>0 then
  begin
  open_config;
  read_config;
  close_config;

  open_user;
  read_user_genhdr;
  read_user_hdr;
  read_user(cfg.curruser,user);

  val(paramstr(1),n,c);
   if c=0 then
     if (user.xproto=1) or (user.xproto=2) or (user.xproto=3) then
       user.xproto:=n;
   if not(c=0) then writeln('Error at offs ',c,' of ',paramstr(1));

  write_user(cfg.curruser,user);
  close_user;
  end
 else begin writeln('NOTXMDM x');
            writeln('Where X is the protocol Number you want them to have');
      end;
end.
