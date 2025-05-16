Program Example;

{$M 5000,0,5000}

{ This $M statement is VERY important if you are going to shell to DOS.
  It tells the compiler how much memory to reserve for the program.

  $M X, Y, Z

  X = Stack Space.  Not much required for this program; there is no
      recursion or anything interesting like that

  Y = Minimum Heap Space.  I usually leave this at 0 and then test within
      the program for available memory when I am allocating space for
      dynamic variables.

  Z = Maximum Heap Required.  This is how much the program will be able to
      use.  The default is all (655360b).  This memory is used for dynamic
      variables and pointers, etc..   In order to shell to DOS or execute
      any other program from within, you must lower this so that

        Free Memory in Dos - Z  >=  Memory Required for External Program
}

Uses Dos;

Const FileName = 'Example.Dat';

Type  HandType = (Left,Right);

Type  RecordType = Record
         Name: string;
        Value: word;
         Hand: HandType
        end;

Var   f: file;
    wrec: RecordType;
    rrec: RecordType;


begin
WriteLn;
WriteLn('Assigning Values');

with wrec do
 begin
 Name  := 'Test';   { equivalent to wrec.Name ... }
 Value := $2112;    {    "        "  "  .Value    }
 Hand  := Left
 end;

WriteLn('Writing File');

Assign(f,FileName);            { Assign the file var to a filename }
ReWrite(f,SizeOf(RecordType)); { open it for the first time or overwrite}

 { the SizeOf(RecordType) tells TP that the default block size for the file
  is however big RecordType is.  Then we can use 1 for the number of blocks
  to use using BlockRead and BlockWrite

  SizeOf(RecordType) could be changed to 1 if you wanted to always specify
  the exact size in bytes for each individual BlockRead/BlockWrite
 }

Seek(f,0);                     { Seek to the 1st record just in case, ofs 0 }
BlockWrite(f,wrec,1);          { write the data, 1 block long }
Close(f);

WriteLn('Type EXIT to return to program ',ParamStr(0));

 { Now we will shell to DOS because that is somewhat interesting.. }

SwapVectors; { SwapVectors are not really required, but they are general
               good programming practice, because when you start to grab
               ahold of interrupts, havok can occur. }

Exec(GetEnv('COMSPEC'),'');
SwapVectors;                { and then restore whatever interrupts you
                              grabbed, in this case nothing }

WriteLn;
WriteLn('Reading File');

Assign(f,FileName);
Reset(f,SizeOf(RecordType));
Seek(f,0);
BlockRead(f,rrec,1);
Close(f);

with rrec do
 begin
 WriteLn(' Name: ',Name);
 WriteLn('Value: ',Value);
 Case Hand of
    Left: WriteLn('Left Hand');
   Right: Writeln('Right Hand')
   else WriteLn('Illegal Value -or- You have a hand which is not right or left.')
   end
 end

end.

blah