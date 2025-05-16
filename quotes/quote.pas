uses slflow,dos,crt;

var i:longint;
    f:file;
    fh:fileheader;
    qh:quotehead;
    q :quotetype;


var nqh  :quotehead;
    nq   :quotetype;
    newf : file;

begin

init_config ( 'd:\slnode2\' , closed );

init_constdata(f,quotesF,fh,qh);

assign(newf,cfg.datapath+'QUOTES.NEW');
rewrite(newf,1);
blockwrite(newf,fh,sizeof(fileheader));

nqh.head:=0;
nqh.tail:=0;

i:= qh.head;
while i<>qh.tail do
 begin
 if i=0 then i:=96;
  read_data(f,quotesf,i,q);
 writeln(q.quote);
 case upcase(readkey) of
     'S','Y',#13: begin
          writeln(' left');

          nq:=q;
          inc(nqh.head);
          if nqh.head=96+1 then nqh.head:=1;
          if nqh.head=nqh.tail then inc(nqh.tail);
          write_data(newf,quotesf,nqh.head,nq);

          end;


     'D','N':begin
         writeln(' deleted');
         end;
      end;
 dec(i,1);

 end;

close_data(f);

seek(newf,sizeof(fileheader));
blockwrite(newf,nqh,sizeof(quotehead));
close(newf);

end.