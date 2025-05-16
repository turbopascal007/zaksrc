Uses Dos,Crt,SlFiles,Filedef;

var user:usertype;

begin
  if paramcount<1 then
    begin
    writeln('lastsub subname');
    halt(1);
    end;

  pathtoconfig := '';
  open_config;
  read_config;

  cfg.currsub := paramstr(1);
  write_config;
  close_config;

  open_user;

  read_user_genhdr;
  read_user_hdr;

  read_user(cfg.curruser,user);
  user.subboard := paramstr(1);
  write_user(cfg.curruser,user);

  close_user;
end.