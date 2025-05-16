Unit ooSLFLow;
{$O+}

Interface

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

type FileInfoType = record
        RS:word;
        OS:word;
        end;

type StringHdrType = record
       Offs  : word;
       Length: byte
        end;

const NumOfStrings: word = 2048;

type
 pSLBlockFileObj = ^SLBlockFileObj;
 SLBlockFileObj = Object
   Constructor Init_ConstData(FileType_:byte; p:string;var FileHdr:FileHeader;var Hdr);
   Constructor Init_VarData  (filetype_:byte;Path,SubName:String; var FileHdr:FileHeader;var Hdr);
   Procedure   Write_FileHdr(data:fileheader);
   Procedure   Write_DataHdr(var data);
   Procedure   Read(RecNum:Longint; var Data);
   Procedure   Write(RecNum:Longint; var Data);
   Destructor  Done;
   Private
     f:file;
     FileType:byte;
   end;

 pSLConfigObj = ^SLConfigObj;
 SLConfigObj = Object
   Data : ConfigType;
   Constructor Init(p:string);
   Procedure   Write;
   Destructor  Done;
   private configfile:file of configtype;
   end;

 pSLLogObj = ^SLLogObj;
 SLLogObj = Object
   Data: LogType;
   Constructor Init(p:string);
   procedure   Write;
   Destructor  Done;
   private LogFile: File of LogType;
   end;

 pSLUpListObj = ^SLUpListObj;
 SLUpListObj = Object
   Data: UpListType;
   Constructor Init(p:string);
   Procedure   Write;
   Destructor  Done;
   private UpFile: file of UpListType;
   end;

 pSlStringObj = ^SlStringObj;
 SlStringObj = Object
   Constructor Init(p:string);
   Function    Data(i:word):string;
   Destructor  Done;
   Private
    StringHdr: array[1..2048] of StringHdrType;
    StringFile: file;
   end;

 pSlREgNumObj = ^SlRegNumObj;
 SlRegNumObj = object
  Constructor Init(p:string);
  Function    Data:word;
  Destructor  Done;
  private exefile:file;
  end;

Function Baud(rs:rsbaud):word;

implementation

Const DFI: array[UserF..QuotesF] of FileInfoType = (
 {User}(RS:Sizeof(UserType  ); OS:Sizeof(FileHeader)+Sizeof(UserHeader )),
 {MsgS}(RS:Sizeof(SetupData ); OS:Sizeof(FileHeader)+Sizeof(SetupHeader)),
 {DirS}(RS:Sizeof(SetupData ); OS:Sizeof(FileHeader)+Sizeof(SetupHeader)),
 {Mbr }(RS:Sizeof(MembType  ); OS:Sizeof(FileHeader)+sizeof(MembHeader )),
 {Hdr }(RS:Sizeof(HeaderType); OS:Sizeof(FileHeader)+sizeof(SubType    )),
 {Msg }(RS:Sizeof(IndexType ); OS:Sizeof(FileHeader)+sizeof(TexType    )),
 {Dir }(RS:Sizeof(DirType   ); OS:Sizeof(FileHeader)+sizeof(DirHeader  )),
 {Quot}(RS:Sizeof(QuoteType ); OS:Sizeof(fileheader)+sizeof(quotehead  )));


Constructor SLBlockFileObj.Init_ConstData(FileType_:byte;p:string ;var FileHdr:FileHeader;var Hdr);
 begin
 filetype:=filetype_;
 Case FileType of
  UserF    : Assign(F,p+UserSpec);
  MsgSetupF: Assign(F,p+SubSpec);
  DirSetupF: Assign(F,p+DirSpec);
  QuotesF  : Assign(F,p+QuoteSpec)
  end;
 Reset(F,1);
 Blockread(F,FileHdr,Sizeof(FileHdr));
 Blockread(f,Hdr,DFI[FileType].OS-Sizeof(FileHdr));
 end;

Constructor SLBlockFileObj.Init_VarData  (filetype_:byte;Path,SubName:String; var FileHdr:FileHeader;var Hdr);
 begin
 filetype:=filetype_;
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

Procedure SLBlockFileObj.Write_FileHdr(data:fileheader);
 begin
 Seek(f,0);
 BlockWrite(f,data,sizeof(data));
 end;


Procedure SLBlockFileObj.Write_DataHdr(var data);
 begin
 seek(f,Sizeof(FileHeader));
 BlockWrite(f,data,DFI[FileType].OS-Sizeof(FileHeader));
 end;

Procedure SLBlockFileObj.Read(RecNum:Longint; var Data);
 begin
 Seek(F, (DFI[FileType].RS*(RecNum-1))+DFI[FileType].OS);
 Blockread(F, Data, DFI[FileType].RS);
 end;


Procedure SLBlockFileObj.Write(RecNum:Longint; var Data);
 begin
 Seek(F, (DFI[FileType].RS*(RecNum-1))+DFI[FileType].OS);
 Blockwrite(F, Data, DFI[FileType].RS);
 end;

Destructor SLBlockFileObj.Done;
 begin
 close(f);
 end;

Constructor SLConfigObj.Init(p:string);
  begin
  assign(configfile, P+configspec);
  reset(configfile);
  seek(configfile,0);
  read(configfile,Data);
  end;

Procedure SLConfigObj.Write;
 begin
 seek(configfile,0);
 system.write(configfile,data);
 end;

Destructor SLConfigObj.Done;
 begin
 Close(configfile);
 end;

Constructor SLLogObj.Init(p:string);
 begin
 assign(logfile,p+logspec);
 reset(logfile);
 seek(logfile,0);
 read(logfile,data);
 end;

Procedure SLLogObj.Write;
 begin
 seek(logfile,0);
 system.write(logfile,data);
 end;

Destructor SLLogObj.Done;
 begin
 close(logfile);
 end;

Constructor SLUpListObj.Init(p:string);
 begin
 assign(UpFile, p+UListSpec);
 reset(UpFile);
 seek(upfile,0);
 read(upfile, data);
 end;

Procedure SlUpListObj.Write;
 begin
 seek(upfile,0);
 system.write(upfile,data);
 end;

Destructor SlUpListObj.Done;
 begin
 Close(upfile);
 end;

Constructor SlStringObj.Init(p:string);
  var cursum: word;
      i     : word;
      bffr  : array[1..2048] of byte;
  begin
  i:=0;
  cursum:=0;
  Assign(StringFile,p+MsysSpec);
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


Function SlStringObj.Data(i:word):string;
  var ts:string;
  begin
  Seek(StringFile,StringHdr[i].offs+NumOfStrings-1);
  BlockRead(StringFile, ts, StringHdr[i].Length+1);
  ts[0]:=chr(StringHdr[i].Length);
  Data:=ts;
  end;

Destructor SlStringObj.Done;
 begin
 close(stringfile);
 end;

Constructor SlRegNumObj.Init(p:string);
 begin
 assign(exefile,p+'LOGIN.EXE');
 end;

function SlRegNumObj.Data:word;
var   offs   : longint;
      bffr   : array[1..512] of char;
      against: integer;
      a      : integer;
  begin
  reset(exefile,1);
  offs := filesize(exefile)-sizeof(bffr);
  seek(exefile, offs);
  blockread(exefile, bffr, sizeof(bffr));
  Close(exefile);
  a:=0;
  repeat
   inc(a);
  until ((bffr[a]=#4) and (bffr[a+1]=#32) and (bffr[a+2]=#51)) or
         (a = sizeof(bffr)-3);
  dec(a,8);
  against := (ord(bffr[a+1])*$100) + ord(bffr[a]);
  Data:=Against;
 end;

Destructor SlRegNumObj.Done;
 begin
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

end.
