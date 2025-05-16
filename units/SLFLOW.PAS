Unit SLFLow;
{$O+}

Interface

{ Include the file format/type definitions }

{$I C:\TP\UNITS\SLFFRMT.PAS}

Const   UserF    =0;
        MsgSetupF=1;
        DirSetupF=2;
        MsgMbrF  =3;
        MsgHdrF  =4;
        MsgMsgF  =5;
        DirF     =6;
        QuotesF  =7;

Type OpenFileType = (Opened, Closed);
     FileInfoType = record
        RS:word;
        OS :word;
        end;

var UpFile     : file of UpListType;
    UpRec      : UpListType;

    Configfile : file of configtype;
    Cfg        : configtype;

    logfile    : logfiletype;

function  Baud(rs:rsbaud):word;

procedure Init_Log(var Log:LogType);
Procedure Close_Log;

procedure Open_UpFile(f:string);
Procedure Close_UpFile;
Procedure Write_UpFile;
Procedure Read_Upfile;
function  SlNumber:word;

procedure Open_Strings;
Procedure Close_Strings;
Function  SlStr(i:word):string;

Procedure Init_Config(pathtoconfig:string;fileopen:openfiletype);
Procedure Write_Config;
procedure Close_config;
Procedure Init_ConstData(var F:file; FileType:byte; var FileHdr:FileHeader;var Hdr);
Procedure Init_VarData(var F:File;filetype:byte;Path,SubName:String; var FileHdr:FileHeader;var Hdr);
Procedure Write_DataFileHdr(var f:file;data:fileheader);
Procedure Write_DataHdr(var f:file; filetype:byte; var data);

Procedure Read_Data(var F:file;FileType:byte; RecNum:Longint; var Data);
Procedure Write_Data(var F:file;FileType:byte; RecNum:Longint; var Data);
Procedure Close_Data(var  F   : file);

implementation

uses dos,etc;

Const DFI: array[UserF..QuotesF] of FileInfoType = (
 {User}(RS:Sizeof(UserType  ); OS:Sizeof(FileHeader)+Sizeof(UserHeader )),
 {MsgS}(RS:Sizeof(SetupData ); OS:Sizeof(FileHeader)+Sizeof(SetupHeader)),
 {DirS}(RS:Sizeof(SetupData ); OS:Sizeof(FileHeader)+Sizeof(SetupHeader)),
 {Mbr }(RS:Sizeof(MembType  ); OS:Sizeof(FileHeader)+sizeof(MembHeader )),
 {Hdr }(RS:Sizeof(HeaderType); OS:Sizeof(FileHeader)+sizeof(SubType    )),
 {Msg }(RS:Sizeof(IndexType ); OS:Sizeof(FileHeader)+sizeof(TexType    )),
 {Dir }(RS:Sizeof(DirType   ); OS:Sizeof(FileHeader)+sizeof(DirHeader  )),
 {Quot}(RS:Sizeof(QuoteType ); OS:Sizeof(fileheader)+sizeof(quotehead  )));

Procedure Init_Config(pathtoconfig:string;fileopen:openfiletype);
  begin
  assign(configfile, PathToConfig+configspec);
  reset(configfile);
  seek(configfile,0);
  read(configfile,cfg);
  if fileopen=closed then Close_config;
  end;

Procedure Write_Config;
 begin
 Seek(Configfile,0);
 write(configfile,cfg);
 end;

Procedure Close_Config;
 begin
 close(configfile);
 end;

procedure Init_Log(var Log:LogType);
 begin
 assign(logfile,cfg.datapath+logspec);
 reset(logfile);
 seek(logfile,0);
 read(logfile,log);
 end;

Procedure Close_Log;
 begin
 close(logfile);
 end;

Procedure Init_ConstData(var F:file; FileType:Byte; var FileHdr:FileHeader; var Hdr);
 begin
 Case FileType of
  UserF    : Assign(F,Cfg.DataPath+UserSpec);
  MsgSetupF: Assign(F,Cfg.DataPath+SubSpec);
  DirSetupF: Assign(F,Cfg.DataPath+DirSpec);
  QuotesF  : Assign(F,Cfg.DataPath+QuoteSpec)
  end;
 Reset(F,1);
 Blockread(F,FileHdr,Sizeof(FileHdr));
 Blockread(f,Hdr,DFI[FileType].OS-Sizeof(FileHdr));
 end;

Procedure Init_VarData(var F:File;filetype:byte; Path,SubName:String ; var FileHdr:FileHeader; var Hdr);
 begin
 case FileType of
  DirF    : Assign(F,Path+SubName+'.SL2');
  MsgHdrF : Assign(F,Path+SubName+'.HDR');
  MsgMbrF : Assign(F,Path+SubName+'.MBR');
  MsgMsgF : Assign(F,Path+SubName+'.MSG')
  end;
 Reset(F,1);
 Blockread(F,FileHdr,Sizeof(FileHdr));
 Blockread(f,Hdr,DFI[FileType].OS-Sizeof(FileHdr))
 end;

Procedure Write_DataFileHdr(var f:file;data:fileheader);
 begin
 Seek(f,0);
 BlockWrite(f,data,sizeof(data));
 end;

Procedure Write_DataHdr(var f:file; filetype:byte; var data);
 begin
 seek(f,Sizeof(FileHeader));
 BlockWrite(f,data,DFI[FileType].OS-Sizeof(FileHeader));
 end;


Procedure Read_Data(var F:file;FileType:byte; RecNum:Longint; var Data);
 begin
 Seek(F, (DFI[FileType].RS*(RecNum-1))+DFI[FileType].OS);
 Blockread(F, Data, DFI[FileType].RS);
 end;

Procedure Write_Data(var F:file;FileType:byte; RecNum:Longint; var Data);
 begin
 Seek(F, (DFI[FileType].RS*(RecNum-1))+DFI[FileType].OS);
 Blockwrite(F, Data, DFI[FileType].RS);
 end;

Procedure Close_data(var f:file);
 begin
 close(f);
 end;

function Baud(rs:rsbaud):word;
  begin
  case rs of
   B110  : baud := 110;
   B150  : baud := 150;
   B300  : baud := 300;
   B600  : baud := 600;
   B1200 : baud := 1200;
   B2400 : baud := 2400;
   B4800 : baud := 4800;
   B9600 : baud := 9600;
   B19200: baud := 19200;
   B38400: baud := 38400;
  end;
  end;

{$I c:\tp\units\slnumber.inc}


procedure Open_UpFile(f:string);
 begin
 assign(UpFile, f+UListSpec);
 reset(UpFile);
 end;

Procedure Close_UpFile;
 begin
 close(upfile);
 end;

Procedure Write_UpFile;
 begin
 seek(upfile,0);
 write(UpFile,UpRec);
 end;

Procedure Read_Upfile;
 begin
 read(Upfile, UpRec);
 end;

type StringHdrType = record
       Offs  : word;
       Length: byte
        end;

const NumOfStrings: word = 2048;

var StringHdr: array[1..2048] of StringHdrType;
    StringFile: file;

procedure Open_Strings;
  var cursum: word;
      i     : word;
      bffr  : array[1..2048] of byte;
  begin
  i:=0;
  cursum:=0;
  Assign(StringFile,Cfg.ProgPath+MsysSpec);
  Reset(StringFile,1);
  seek(stringFile,0);
  blockread(StringFile,Bffr,Sizeof(Bffr));

  For i:=1 to NumOfStrings do
    begin
    StringHdr[i].Length:=Bffr[i];
    StringHdr[i].Offs:=CurSum;
    inc(CurSum,StringHdr[i].Length);
    end;
  end;

procedure Close_Strings;
  begin
  Close(StringFile);
  end;

Function SlStr(i:word):string;
  var ts:string;
  begin
  Seek(StringFile,StringHdr[i].offs+NumOfStrings-1);
  BlockRead(StringFile, ts, StringHdr[i].Length+1);

  ts[0]:=chr(StringHdr[i].Length);
  SlStr:=ts;
  end;

begin
filemode:=66;
end.
