Unit SysText;
{$R-}

interface

Type MsgType = Array[1..1] of ^String;
     pMsgType = ^MsgType;

     SystemTextObj = Object
     Constructor Init(filename:string);
     Function    Hacked:boolean;
     Function    Data(n:word):string;


     private
       Data       : pMsgType;
       NumStrings : word;
       DataLength : longint;
       StoredCRC  : longint;

       Function CalcCrc:longint;
     end;

implementation


MsgChckArray = array[1..1] of byte;



procedure function SystemTextObjectHacked(ag:longint);
    var
      a  :msgchckarray;
      i  :word;
      j:byte;
  begin
  i:=1;
  for j:=1 to numofmsgs do
      begin
      move( mem[seg(m^[j]^.t):ofs(m^[j]^.t)+1],a[i],length(m^[j]^.t));
      inc(i,length(m^[j]^.t));
      end;

  if not(CRC32Array(@a[1],i-1)=ag) then
    begin
    Writeln('Program Illegally Modified!');
    halt;
    end;

  end;


Procedure LoadSysStr;
  var f         :file;
      CurStrNum :word;
      NumOfStr  :word;
      CurLen    :byte;
      bffr      :array[0..255] of char;
      CRCVal    :longint;
  begin
  New(M);
  {$I-}
  Assign(f,SysStrSpec);
  reset(f,1);
  {$I+}

  if not (ioresult=0) then begin
           system.writeln('Cannot find REGISTRY.SYS');
           halt;
           end;

  blockread(f,crcval,sizeof(crcval));

  blockread(f,NumOfStr,sizeof(NumOfStr));
  for CurStrNum:=1 to NumOfStr do
     begin
     blockread(f,curlen,1);
     Seek(f,filepos(f)-1);
     blockread(f,bffr,curlen+1);
     GetMem(M^[CurStrNum],Curlen+1);
     Move(bffr,M^[CurStrNum]^.t,CurLen+1);
     end;
  close(f);

  CheckForHack(crcval);

  end;
