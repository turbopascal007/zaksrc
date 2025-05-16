Uses Dos,Crt,SlFiles,FileDef;

var user: usertype;

procedure ClimbTree_mbr(rec:longint);
  var Right     : longint;
      Left      : longint;

  begin

  if rec <> 0 then
    begin

    Read_user(rec,user);

    Right :=user.leaf.Right;
    Left := user.leaf.left;

    climbtree_mbr(left);

    read_user(rec,user);

    writeln(user.name);
    User.Laston.Month := 2;
    User.Laston.day := 2;
    user.laston.year := 90;
    Write_User(Rec,User);

    climbtree_mbr(right);

    end;
  end;

begin
 cfg.datapath := 'd:\sl-test\data\';

 directvideo := true;

 open_user;
 read_user_genhdr;
 read_user_hdr;
 climbtree_mbr(userhdr.root.treeroot);


 close_user;
end.

