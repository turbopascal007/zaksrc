Unit Key;

interface

Type KeyObj = OBJECT
   Constructor Init(_ProgramName, _ProgID: string);
   Function   Reg(IDNum:word; var RegID: string):Boolean;
   Procedure  MakeKey(IDNum: word; RegID: string);

   PRIVATE
   ProgramName, ProgID: string;
  end;

implementation

uses dos,etc;

Constructor KeyObj.Init(_ProgramName, _ProgID:string);
 begin
 ProgramName := _ProgramName;
 ProgID := _ProgID;
 end;

Procedure KeyObj.MakeKey(IDNum: word; RegID: string);
 var f  : file;
     b  : array[1..200] of char;
     ts : string[40];
     a  : byte;
     ida: array[1..2] of byte absolute IDNum;

     crc:longint;
 begin
 assign(f,programname+'.KEY');
 rewrite(f,1);

 fillchar(ts,sizeof(ts),0);

 ts:=ProgramName+' KEY File.' + ^Z;

 ts[0]:=#19;

 blockwrite(f,mem[seg(ts):ofs(ts)+1],length(ts));

 ts:=RegID;

 crc:=crc32array(@ts,length(ts)+1);

 for a:=1 to sizeof(ts)-1 do
   begin
   ts[a]:=char(byte(ts[a]) xor ida[(a mod 2)+1] xor byte(ProgID[a mod byte(progid[0])]));
   end;

 blockwrite(f,ts,sizeof(ts));

 blockwrite(f,crc,sizeof(crc));

 close(f);
 end;

Function   KeyObj.Reg(IDNum:word; var RegID: string):Boolean;
 var f  : file;
     b  : array[1..200] of char;
     ts : string[40];
     a  : byte;
     ida: array[1..2] of byte absolute IDNum;

     crc,crc2:longint;

 begin
 {$i-}
 assign(f,programname+'.KEY');
 reset(f,1);
 {$i+}

 if doserror<>0 then
   begin
   reg:=false;
   exit;
   end;

 seek(f,19);

 blockread(f,ts,1);
 blockread(f,ts[1],integer(ts[0]));

 for a:=1 to sizeof(ts)-1 do
   begin
   ts[a]:=char(byte(ts[a]) xor ida[(a mod 2)+1] xor byte(ProgID[a mod byte(progid[0])]));
   end;

 crc:=crc32array(@ts,length(ts)+1);

 seek(f,sizeof(ts)+19);

 blockread(f,crc2,4);

 RegID:=ts;

 close(f);

 reg:=crc=crc2;

 end;


end.

