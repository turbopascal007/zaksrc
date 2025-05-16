Program SLRead;

  { Sample program to read a message from a subboard }

Uses General,Block,Filedef,SubList,Message,Users;

var msg     : msgptr;
    subboard: string;
    Msgnum  : longint;
    valid   : boolean;
    header  : headertype;
    p       : SubListPtr;
    result  : longint;
    i       : integer;


Begin

  { Open CONFIG, NODES and USER files }

  if OpenFiles([CONFIGF,NODESF]) and OpenUserFile then begin

    { Initialize subboard list }
    SubListInit(Subboards);

    { Prompt user to enter a subboard name }
    repeat
      writeln('Enter Subboard Name: ');

      readln(subboard);
      upstr(subboard);          { make all uppercase }
      stripspaces(subboard);    { strip spaces }

      p:=ListIndex(subboard);   { get list index, if valid subboard name }

      if (p=Nil) or (p^.fname<>subboard) then begin
        writeln('Invalid subboard. Try again.');
        valid:=false;
      end else valid:=true;

    until valid;

    if OpenSub(subboard,Mainsub,Allfiles) then begin     { Open subboard }

      { display message number range }
      writeln;
      writeln('Messages are numbered from ',
        Mainsub.Subinfo.Firstmsg,' to ',Mainsub.Subinfo.Lastmsg);

      repeat
        { prompt user to enter desired message number }
        writeln;
        writeln('Enter Message Number: ');
        readln(Msgnum);

        { attempt to lookup the message header }
        result:=FindHeader(Header,Seq,Msgnum,0);

        if (result=0) then begin
          writeln('That message does not exist.');
          valid:=false;
        end else begin
          { write information from message header }
          writeln;
          writeln('From: ',header.from);
          writeln('  To: ',header.touser);
          writeln('Date: ',StrDate(header.date));
          writeln('Read: ',header.rd,' Times');
          writeln;

          { retrieve text from message }
          UnpackMsg(Header.Txt,Msg,True);

          { display lines of text }
          for i:=1 to msg^.msglen do
            writeln(msg^.msglin[i]^);

          { increment number of times read counter in header }
          if LockFile(Mainsub.Headerf) then begin
            ReadBlockFile(Mainsub.Headerf,result,@header);
            inc(header.rd);
            WriteBlockFile(Mainsub.Headerf,result,@header);
            UnlockFile(Mainsub.Headerf);
          end;

          { dispose of message ram buffer }
          DisposeMsg(msg);

          valid:=true;
        end;

      until valid;


      { close the subboard }
      CloseSub(Mainsub);

    end
    else writeln('Error opening subboard!');

    CloseUserFile;
    CloseAllFiles;
  end
  else writeln('Could not open CONFIG File!');

end.