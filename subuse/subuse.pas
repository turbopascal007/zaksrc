Program SubUse;

Uses Dos, Crt, SlFiles, SlFGen;

procedure thing(l:word);
 var i:word;
 begin
 for i:=1 to l do write('Û');
 end;

Function SubStat(pathname, subname:string): boolean; far;
 begin

 Init_Mbr(pathname,subname);

 close_msgmbr;

 write(subname:8,':'{,' ',msgmbrhdr.root.entries-1:4});
 thing(msgmbrhdr.root.entries-1);

 writeln;
 { -1 for slmail }

 SubStat := True;
 end;

 
begin

init_Config ( Closed , 'd:\slnode2\' );

MainSubList ( 'MAIN.SUB' , SetupMSG, Closed, SubStat );


end.