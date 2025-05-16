Unit ZSLKey;

interface

var KeyFileName: String;
    KeyFilePath: String;
    ProgCode   : String;

Procedure MakeKeyFile(RegName:string;RegNum:word);
Function  ReadKeyOK(Var regname:string;var regnum:word):boolean;

implementation

Uses Dos,Etc;

Type
    CRCType = record
      NormCRC    : longint;
      EncryptCRC : longint;
      end;
    RegDataType = record
     RegName: string[30];
     RegNum : Word;
     end;
    RegInfoType = record
     Data   : RegDataType;
     CRC    : CRCType;
     end;
    RegKeyType = record
    ID      : Array[1..23] of char;
    RegInfo : RegInfoType;
    AllCrc  : CrcType;
  end;

var  KeyFile    : file of RegKeyType;
     Key        : RegKeyType;

function CRC32(p:pointer;l:word):longint;
 var i   :word;crc :longint;
 begin
 CRC:=$FfFfFfFf;
 for i:= 1 to l do CRC:=UpDC32(mem[seg(p^):ofs(p^)+i-1],crc);
 CRC32:=crc;
 end;

Procedure Crypt(P: pointer;l:word);
 var i:word;
 begin
 for i:=0 to l-1 do
  begin
  mem[seg(p^):ofs(p^)+i]:=mem[seg(p^):ofs(p^)+i] xor Byte(ProgCode[i mod ord (ProgCode [0])+1])
  end;
 end;

Procedure MakeKeyFile(RegName:string;RegNum:word);
 Var TempRec: RegKeyType;

 begin
 Key.RegInfo.Data.RegName:=RegName; { groupings for crc routine }
 Key.RegInfo.Data.RegNum :=RegNum;

 Key.RegInfo.Crc.NormCrc:=Crc32(@Key.RegInfo.Data,sizeof(Key.RegInfo.Data));

 Crypt(@Key.RegInfo.Data,sizeof(Key.RegInfo.Data));

 Key.RegInfo.Crc.EncryptCrc:=Crc32(@Key.RegInfo.Data,sizeof(Key.RegInfo.Data));

 Key.AllCrc.NormCrc:=Crc32(@Key.RegInfo,Sizeof(Key.RegInfo));

 move(Key,TempRec,sizeof(temprec));

 Crypt(@temprec,sizeof(temprec)-sizeof(Key.AllCrc.EncryptCRC));

 Key.AllCrc.EncryptCRC:=CRC32(@temprec,sizeof(temprec)-sizeof(Key.AllCrc.EncryptCrc));

 assign(KeyFile,KeyFilePath+KeyFileName+'.KEY');
 rewrite(KeyFile);
 write(KeyFile,Key);
 Close(KeyFile);
 end;

Function ReadKeyOK(Var regname:string;var regnum:word):boolean;
 Var TempRec: RegKeyType;

 begin
 ReadKeyOK:=false;

 if not existfile(KeyFilePath+KeyFileName+'.KEY',anyfile) then exit;
 assign(KeyFile,KeyFilePath+KeyFileName+'.KEY');
 {$I-}
 reset(KeyFile);
 read(KeyFile,Key);
 Close(KeyFile);
 {$I+}
 if ioresult<>0 then exit;

 move(Key,TempRec,sizeof(temprec)); { used for crypting }

 Crypt(@temprec,sizeof(temprec)-sizeof(Key.AllCrc.EncryptCRC));

 If Key.AllCrc.EncryptCrc<>CRC32(@temprec,sizeof(temprec)-sizeof(Key.AllCrc.EncryptCrc)) then exit;

 if Key.AllCrc.NormCRC<>Crc32(@Key.RegInfo,Sizeof(Key.RegInfo)) then exit;

 if Key.RegInfo.Crc.EncryptCRC<>Crc32(@Key.RegInfo.Data,sizeof(Key.RegInfo.Data)) then exit;

 Crypt(@Key.RegInfo.Data,sizeof(Key.RegInfo.Data));

 if Key.RegInfo.Crc.NormCrc<>Crc32(@Key.RegInfo.Data,sizeof(Key.RegInfo.Data)) then exit;

 RegName:=Key.RegInfo.Data.RegName;

 RegNum:=Key.RegInfo.Data.RegNum;

 ReadKeyOK:=TRUE; { phew, made it! }

 end;

Const Author:array[1..23] of char = 'KEY File (c) Zak Smith'+^Z;

begin
move (Author,Key.ID,sizeof(key.id));
end.
