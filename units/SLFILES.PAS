Unit SLFiles;

Interface

type
     uprectype = record
       name: string[12];      { filename }
       descrip: string[40];   { short description }
       edescrip: array[1..2]  { long description }
         of string[60];
     end;

     uplisttype = record
       count: integer;
       files: array[1..40] of uprectype;
     end;

     frectype = record        { returned file spec }
       name: string[12];      { filename }
       length: integer;       { size in blocks }
       dir: string[12];       { source directory name }
       rec: longint;          { record # in directory }
       romcopy: boolean;      { set if file to be copied }
       data: pointer;      { pointer: always NIL }
     end;

     filelist = record
       count: integer;
       totalsize: longint;
       data: array[1..40] of frectype;
     end;
{ FILEDEF.LIB                                }
{ File Definitions for Searchlight BBS 2.0   }

{ (C) Copyright 1990 by Frank LaRosa. ALL RIGHTS RESERVED.
      No part of this source code may be reproduced in any form,
      including compiled form, without the written permission of
      the author.                                                   }


{ The following files make up the core of the BBS. They will
  reside in the current directory when the BBS is run. }

{ General definitions for all Searchlight block oriented files }

type FileHeader = record      { header info on file }
       version: word;              { version of unit that created file }
       recsize: word;              { record size }
       offset: longint;            { offset to 1st record }
       nextfree: longint;          { next free record }
     end;

     RecordHeader = record    { control header to records }
       mark: byte;                 { FF to indicate deleted rec }
       extra: byte;
       next: longint;              { ptr to next free rec }
     end;

     TreeRootType = record     { root info for tree/list type files }
       treeroot: longint;      { root of tree }
       listroot: longint;      { linked list root }
       entries: longint;       { # of entries }
     end;

     TreeLeafType = record     { leaf info for tree/list type files }
       status: byte;           { 0=active, 255=deleted }
       left,right: longint;    { pointers to child nodes }
       last,next: longint;     { linked list ptrs }
     end;


const logsize   =  75;  { size of last caller log }
      chatsize  =   4;  { chat queue size - 1 }
      ulistmax  =  50;  { upload list size }
      maxproto  =  15;  { number of external protocols }


const { Message File Constants }
      indexsize = 1024;       { size of index hash table }
      blocksize = 250;        { text block size }


const configspec  = 'CONFIG.SL2';   { Configuration Info }
      nodesspec   = 'NODES.SL2';    { Node Information }

      chatspec    = 'CHAT.SL2';     { Chat File }
      logspec     = 'LOG.SL2';      { Caller Log }

      userspec    = 'USER.SL2';

      subspec     = 'SUBBOARD.SL2'; { Subboard Definitions }
      dirspec     = 'FILEDIR.SL2';  { UL/DL Directory Definitions }
      doorspec    = 'DOORS.SL2';    { External Program Definitions }

      msysspec: string[80]
                  = 'STRINGS.SYS';  { Offline Message Strings }

      ulistspec   = 'UPLIST.BBS';   { Batch Upload Description List }

      configpath: string[60] = '';
        { path to CONFIG file }


Type  { -- Preliminary Type Definitions ------------------------------------ }

     RSbaud = (B110,B150,B300,B600,B1200,B2400,B4800,B9600,B19200,B38400);

     cmpresult = (Less,Equal,Greater);
     comparefunction = function (p1,p2: pointer): cmpresult;

     ansitype = (GENERIC,PROCOMM,STANDARD);
     helplevel = (EXPERT,INTERMEDIATE,NOVICE);

     IxType = (SEQ,UID,MAIL);
       { index type, seqential/universal/mail }

     filetype = (CONFIGF,NODESF,CHATF);
     fileset = set of filetype;

     timetype = record   { time }
       hour: byte;
       minute: byte;
     end;

     datetype = record   { date }
       year: byte;
       month: byte;
       day: byte;
     end;

     pwtype = array[1..3] of byte;  { 3-byte password }

     maillogtype = (MLOFF,MLON,MLTAP);

     attribtype = 1..24;
     attribset = set of attribtype;    { access attribute set A-X }

     ExProtocol = record
       name: string[40];      { protocol name }
       sendcmd: string[72];   { send command }
       rcvcmd: string[72];    { receive command }
       extra: string[20];     { expansion room }
     end;

     ColorType = (NULLCOLOR,     { no color set }
                  NORMAL,        { normal screen color for most i/o }
                  INVERSE,       { foreground color for input highlighting }
                  BACKGROUND,    { background color for input highlighting }
                  COMCOLOR,      { color for command highlight }
                  SUBCOLOR,      { subboard information }
                  HEADCOLOR,     { color for headings }
                  CHATCOLOR,     { chat mode color }
                  SPECIAL,       { special prompts and messages }
                  ERRCOLOR,      { error and warning messages }
                  ALTCOLOR,      { alt. special color }
                  PROMPTCOLOR ); { colour for prompts }

     MsgType = record    { inter-terminal message }
       from: integer;         { node where from }
       name: string[25];      { name of sender }
       message: string[73];   { text of msg }
     end;

     AutoDoorType = record   { automatic door }
       command: string[60];
       directory: string[60];
       commtype: byte;
       abort: byte;
       writeprot: boolean;
       extra: string[10];
     end;

     PortDefType = record   { COM port definition }
       PortType: byte;        { type of port; 0=standard }
       BaseAddress: word;     { base address }
       IRQ: word;             { interrupt }
       Num: byte;             { physical port number }
       extra: string[7];      { extra bytes }
     end;

     AccessType = record   { access level set }
       attrib: attribset;    { attributes }
       msglevel: integer;    { message system access level }
       filelevel: integer;   { file system access level }
       ratio: byte;          { download:upload ratio }
       timelimit: integer;   { daily time limit }
       sesslimit: integer;   { per session time limit }
       expiredate: datetype; { expiration date }
     end;

     AccessDefType = record
       name: string[20];     { name of access level }
       days: integer;        { # of days added to expiration date }
       a: accesstype;        { access levels }
     end;




Type  { -- CONFIG, NODES and CHAT file types ------------------------------- }

     configtype = record   { format of CONFIG file }

       systemname: string[30]; { the name of the BBS }
       sysopname: string[25];  { sysop's name }
       node: integer;          { node number this node }
       maxnode: integer;       { total number of nodes }
       version: integer;       { version of SLBBS program in use }

       progpath: string[45];   { path to program files }
       altprogpath: string[45];{ alternate program path }
       datapath: string[45];   { path to data files }
       chatpath: string[45];   { path to chat.bbs }
       textpath: string[45];   { path to text files }
       incpath: string[45];    { path to user include files }
       mailpath: string[45];   { path for MAIL.LOG files }
       alogspec: string[45];   { activity log filespec }
       flogspec: string[45];   { files log filespec }
       logfile: string[45];    { default general log file }
       sysfile: string[45];    { path/filename for pcboard.sys file }
       defaultpw: string[45];  { default password for uploads }
       presshard: byte;        { reserved }

       curruser: longint;      { current user ID number }
       currsub: string[8];     { current/last used message area }
       currdir: string[8];     { current/last used file area }
       lastdoor: string[45];   { current/last door menu executed }
       logtime: timetype;      { time current user logged on }
       laston: datetype;       { last logon date of current user }
       remote: boolean;        { set if remote logon }
       rsactive: boolean;      { set if rs port active }
       baudrate: rsbaud;       { caller's actual effective baud rate }
       errorfree: boolean;     { set if error free connect detected }
       ansi: boolean;          { caller's ANSI graphics mode }
       color: boolean;         { caller's color mode indicator }
       timelimit: integer;     { caller's time limit for this session }
       newlogon: boolean;      { set if main program not yet run }

       sysavail: boolean;      { set if sysop is available }
       sysopnext: boolean;     { set if sysop will be next login }
       paged: boolean;         { set if sysop was paged }
       superuser: boolean;     { set if superuser key (alt-s) pressed }

       newusers: boolean;      { new user registration? }
       reginfo: word;          { registration info to collect? }
       minaccess: byte;        { min. access lev req. for login }
       noquotes: boolean;      { set if Quotes are Off }
       inithelp: helplevel;    { initial help level }
       partreg: boolean;       { collect partial user info? }

       comport: byte;          { com port to use }
       bsupport: byte;         { baud rates supported }
       initstr: string[45];    { modem 'remote' init string }
       localstr: string[45];   { modem 'local' init string }
       buffactor: integer;     { output buffer size }
       bufferdoors: boolean;   { buffer DOOR output? }
       modemmsg: boolean;      { true for modem msg baud detect }
       flowcntrl: boolean;     { set for harware cts/dsr flow control }
       lockedbaud: rsbaud;     { baud rate to lock modem at }
       hardbreak: boolean;     { if set, bbs uses hard modem breaks }

       directvid: boolean;     { direct screen/BIOS output switch }
       dateformat: byte;       { desired date format }
       timeformat: byte;       { desired time format }
       payback: byte;          { upload time payback }
       romcopy: boolean;       { set for ROM file copies }
       userpriv: boolean;      { set if user lists are private }
       PauseSource: byte;      { source for pause routine (dos/bios/ram) }

       command: string[255];   { next command executed by slbbs.exe }
       commtype: byte;         { next command type }
       commdir: string[80];    { default dir for command }
       wp: boolean;            { write protection for command }
       abort: byte;            { abort type for command }
       doorflag: byte;         { program to run on return from door }
       keyflag: boolean;       { set if "press return" desired }
       indoors: boolean;       { set if a doors menu is active }

       relog: boolean;         { relog flag }
       lastevent: integer;     { line number of last event }
       lastday: byte;          { day last event executed }
       nextevent: integer;     { time until next system event (-1=None) }
       eventsoon: boolean;     { set if event scheduled after current session }
       idletime: byte;         { idle time limit }

       lastactive: boolean;    { set if lastuser currently logged in }
       host: boolean;          { if set, return to DOS on logout }
       hangup: boolean;        { if set, hang up after each call }
       disablekeys: boolean;   { if set, hot keys are disabled }

       AccessDef: array[1..25]
         of AccessDefType;     { access level definitions }

       Colorchart: array [NORMAL..PROMPTCOLOR]
         of byte;              { color definitions }

       PortDef: array[1..8]
         of PortDefType;       { COM port setup info }

       Ex: array[1..MaxProto]
         of exprotocol;        { external protocols setup }

       Autodoors: array[1..3] of autodoortype;

       mainlevels: array[1..30] of byte;
         { access levels for main menu }

       fileslevels: array[1..30] of byte;
         { access levels for files menu }

       ftime: timetype;        { start of xfer time }
       fdisc: char;            { disconnect from external xfer }

       fileset: string[60];
         { name of DIR file to use upon startup }

       invis: boolean;         { Alt-I invisible switch }

       extra: array[1..935] of boolean;

     end;


type nodetype = record    { NODES file }

       syscalls: longint;      { record 0: total calls to system }
       lastuser: longint;      { record 0: last user on the system }
       lastquote: string[72];  { record 0: quote left by last user }

       name: string[25];       { logged user's name }
       id: longint;            { logged user's id }
       stat: byte;             { logged user's chat status }
       savestat: byte;         { saved status from door or ext. proto. }

       extra: string[14];      { pad to 128 bytes }

     end;


type chattype = record      { CHAT.BBS file }

       head,tail: byte;          { head, tail of msg queue }
       msg: array[0..chatsize]   { up to four messages }
         of msgtype;

     end;



{ -- USER file ----------------------------------------------------------- }


type UserHeader = record       { file header info }
       root: TreeRootType;       { tree root info }
       pad: array[1..116] of byte;
     end;


     Usertype = record
       Leaf: TreeLeafType;     { tree leaf info }

       name: string[25];       { user's real name }
       alias: string[25];      { user's alias name }
       passwd: pwtype;         { password }
       cksum: integer;         { checksum of name }

       firston: datetype;      { date of first logon }
       laston: datetype;       { date of last logon }
       lasttime: timetype;     { time of last logon }
       calls: longint;         { total number of calls }

       location: string[20];   { user's location }
       systype: string[15];    { system type }
       phoneno: string[12];    { phone number }
       pref   : attribset;

       extra: string[47];      { extra space }

       subboard: string[8];    { current or last used subboard }

       xproto: byte;           { default file xfer protocol }
       logmail: maillogtype;   { log mail sent/rcv'd }
       scrnsize: byte;         { screen size (0=continuous scroll) }
       help: helplevel;        { help level }
       ansimode: ansitype;     { default ANSI mode }

       access: accesstype;     { access & time limits }
       timeleft: integer;      { time left today }

       uploads: longint;       { Kbytes uploaded }
       ulcount: longint;       { File upload count }
       downloads: longint;     { Kbytes downloaded }
       dlcount: longint;       { File download count }

       listformat: byte;       { file list format prompt/short/long }

       pad: array[1..19] of byte;   { pad to 256 bytes }

     end;



{ -- Setup Files ------------------------------------------------------------ }

type SetupHeader = record
       root: TreeRootType;       { tree root info }
       pad: string[116];         { header for subboard SETUP files }
     end;

     SetupData = record             { data for SETUP files }
       Leaf: TreeLeafType;     { tree leaf info }
       name: string[8];        { eight-char item name }
       path: string[40];       { path to HDR/DIR file }
       descrip: string[40];    { name of subboard/file area }
       access: integer;        { access level required to use }
       attrib: attribset;      { attributes required to read/join }

       case integer of
         1: (                { Subboards }
         subsysop: string[25];   { subop's name }
         echomail: boolean;      { echomail attrib for subboards }
         postattrib: attribset;  { attributes required to post }
         visible: boolean;       { subboard visible? }
         pad: string[13]);       { extra bytes }

         2: (                { Filedirs }
         filepath: string[38];   { path to upload/download files }
         readonly,
         writeonly: boolean;
         Free: word;
         Value: integer;
         display: boolean);      { subboard visible? }

     end;



{ -- Message Files ---------------------------------------------------------- }

type SubType = record   { subboard header information }
       access: integer;        { access level required to use subboard }
       attrib: attribset;      { attributes required to read/join }
       name: string[40];       { long sub board name }
       subsysop: string[25];   { sub-sysop's name }
       maxsize: longint;       { maximum number of msgs allowed }
       maxmsglen: integer;     { max. message length }
       anonymous: boolean;     { set if anonymous posts are allowed }
       echomail: boolean;      { set if echomail on this subboard }
       autokill: boolean;      { purge old messages automatically }
       compress: boolean;      { set to compress message texts }

       messages: longint;      { number of active headers }
       nextid: longint;        { next MSG ID number }

       firstmsg,
       lastmsg: longint;       { first & last active msg by ID # }

       orignode: word;         { originating node, for echomail }
       orignet: word;          { originating net, for echomail }
       origzone: word;         { originating zone, for echomail }
       origpoint: word;        { originating point }

       userjoin: boolean;      { set if users allowed to join }
       postattrib: attribset;  { attributes required to post msgs }
       visible: boolean;       { false hides subboard from list }

       pad: string[14];        { pad to 128 bytes }

     end;


{     IndexType = array [SEQ..UID,0..IndexSize-1]
       of longint;          }

      IndexType = Array [SEQ..UID] of Array[0..IndexSize-1] of Longint;

        { index for sequential and uid values }

     HeaderType = record        { message header }
       status: byte;         { 0=header, 255=deleted }
       id: array[SEQ..UID]
         of longint;         { sequential and universal ID numbers }
       next: array[SEQ..UID]
         of longint;         { pointers to next headers if any }
       txt: longint;         { pointer to start of text in text file }

       from: string[25];     { text of sender's name }
       fromid: longint;      { sender's user record, if local }
       touser: string[25];   { text of receiver's name }
       toid: longint;        { receiver's user record, if local }
       subj: string[40];     { subject }

       time: timetype;       { time recorded }
       date: datetype;       { date recorded }
       rd: longint;          { times read }
       replies: longint;     { times replied-to }

       ffrom: string[40];    { forwarded-from }
       extra: string[19];    { extra heading information }

       prot: boolean;        { purge protection }
       logged: boolean;      { set if mail logged to disk }

       lastseq,
       nextseq: longint;     { next/previous sequential message }

       lastthread,
       nextthread: longint;  { next/previous threaded message }

       topthread,            { first msg in this thread }
       lastreply,            { last reply to this message }
       replyto: longint;     { message to which this is a direct reply }

       lastmail,
       nextmail: longint;    { next/previous personal mail message }

       attribute: word;      { echomail flags/attributes }

       nextseqrec: longint;  { record # of next sequential msg }
       nextmailrec: longint; { record # of next mail message }

       pad: string[11];   { pad to 256 bytes }
     end;


     TextHeader = record     { header info for message file }
       pad: string[127];
     end;

     TexType = record        { block of text from text file }
       copies: byte;              { #of copies 255=deleted }
       data: string[blocksize];   { block of text }
       next: longint;             { pointer to next block }
     end;


     MembHeader = record      { header for member file }
       root: treeroottype;
       pad: string[116];
     end;

     MembType = record        { block data for member file }
       Leaf: treeleaftype;
       name: string[25];      { member's name }
       firston: datetype;     { date joined this subboard }
       laston: datetype;      { date last accessed this subboard }
       lastread: longint;     { highest message read }
       firstmail,
       lastmail: longint;     { first/last personal message this subboard }
       pad: string[66];
     end;


{ -- Log and Quotes Files ------------------------------------------------- }

type logtype = record  { LOG file }
       head: integer;
       users: array[1..logsize] of record
         id: longint;     { user ID # }
         chksum: integer; { user checksum }
         time: timetype;  { time of login }
         date: datetype;  { date of login }
       end;
     end;

     logfiletype = file of logtype;


type quotehead = record
       head: longint;
       tail: longint;
       pad: string[7];
     end;

     quotetype = record
       status: byte;
       name: string[25];    { their name }
       quote: string[72];   { what they said }
       time: timetype;      { when they said it }
       date: datetype;
       pad: string[22];
     end;



{ -- File Directories ------------------------------------------------------ }

type DirHeader = record    { File directory header info }
       root: treeroottype;     { root information }

       access: byte;           { access level required to use directory }
       attrib: attribset;      { attributes required to use/upload }
       name: string[40];       { long directory name }
       visible: boolean;       { directory visible? }
       subsysop: string[25];   { directory subsysop }

       filepath: string[45];   { path to files }
       maxsize: word;          { max number of files allowed }
       autokill: boolean;      { auto kill oldest files }
       readonly: boolean;      { read only dir }
       writeonly: boolean;     { write only dir }
       free: longint;          { free files limit }
       value: integer;         { value multiplier }
       dlattrib: attribset;    { attributes required to download }

       pad: array[1..110] of byte;   { pad to 256 bytes }
     end;


     DirType = record      { File directory record format }
       leaf: treeleaftype;     { tree/list leaf data }

       name: string[12];       { filename }
       descrip: string[40];    { description }
       edescrip: array[1..2]
         of string[60];        { extended description }
       spare: byte;            { spare byte }
       length: longint;        { length in 128-char blocks }
       id: longint;            { ID of uploader }
       cksum: integer;         { checksum of uploader }
       date: datetype;         { date uploaded }
       times: longint;         { # of times downloaded }
       passwd: pwtype;         { password }
       offline: boolean;       { flag if file not available }

       pad: array[1..41] of byte;    { pad to 256 bytes }
     end;





type kindofsetup = (setupMSG,setupDIR);

var

   PathtoConfig   : string[80];

   {  Vars for Files  }

   UpFile         : file of UpListType;
   UpRec          : UpListType;

   UserFile       : file;
   UserHdr        : UserHeader;
   UserGenHdr     : FileHeader;

   Configfile     : file of configtype;
   Cfg            : configtype;

   DirFile        : file;
   DirHdr         : DirHeader;
   DirGenHdr      : fileheader;

   MsgMbrFile     : file;
   MsgMbrHdr      : MembHeader;
   MsgMbrGenHdr   : fileheader;

   SetupFile      : file;
   SetupGenHdr    : Fileheader;
   SetupHdr       : SetupHeader;

   MsgHdrFile     : file;
   MsgHdrGenHdr   : fileheader;
   MsgHdrHdr      : subtype;

procedure Open_UpFile(f:string);
Procedure Close_UpFile;
Procedure Write_UpFile;
Procedure Read_Upfile;
function  SlNumber:word;

procedure Open_Strings;
Procedure Close_Strings;
Function  SlStr(i:word):string;

procedure Close_config;
procedure Close_Setup;
procedure Close_Dir;
procedure Close_user;
Procedure Read_Dir(n: longint;Var Rec: DirType);
procedure Read_ShortDir(n:longint;var rec:dirtype);
Procedure Open_Config;
Procedure Open_Dir(path: string; name: string);
procedure Open_Setup(n:kindofsetup);
procedure Open_user;

Procedure Read_User(n: longint; Var User: UserType);
procedure Read_config;
Procedure Read_Dir_GenHdr;
procedure Read_Dir_Hdr;
Procedure Read_Setup_Data(n: longint;Var Setup: SetupData);
Procedure Read_Setup_GenHdr;
procedure Read_Setup_Hdr;
procedure Read_User_GenHdr;
Procedure Read_User_Hdr;

Procedure Write_dir(n: longint; Rec: DirType);
Procedure Write_User(n: longint;Var User: UserType);
Procedure Write_Config;
Procedure Write_Setup_Data(n: longint; var Setup: SetupData);
procedure Write_Setup_GenHdr;
procedure Write_Setup_Hdr;

procedure open_msgmbr(p,s:string);
procedure Read_msgmbr_GenHdr;
procedure read_msgmbr_hdr;
procedure read_msgmbr(n:longint;var m:membtype);
procedure write_msgmbr(n:longint;m:membtype);
procedure write_msgmbr_hdr;
procedure write_msgmbr_genhdr;
procedure Close_msgmbr;

procedure open_msghdr(p,s:string);
procedure read_msghdr_genhdr;
procedure read_msghdr_hdr;
procedure read_msghdr_data(n:longint;var m:headertype);
procedure write_msghdr_hdr;
procedure close_msghdr;

procedure read_record_Hdr(var f:file;n:longint;rs:word;ofs:longint;var r:recordheader);

function AttribIn(user,Against:attribset):boolean;

function Baud(rs:rsbaud):word;

Procedure ReadHdrData(r:longint;var HdrData:HeaderType);
Procedure ReadHdrIndex(var toindex);

implementation

uses dos,etc;

Procedure ReadHdrIndex(var toindex);
 begin
 seek(msghdrfile,sizeof(fileheader)+sizeof(subtype));
 blockread(msghdrfile,toindex,sizeof(indextype));
 end;

Procedure ReadHdrData(r:longint;var HdrData:HeaderType);
 var t:longint;
 begin
 Seek(msghdrfile, sizeof(fileheader)+sizeof(subtype)+sizeof(indextype)+(sizeof(headertype)*(r-1)));
 blockread(msghdrfile,hdrdata,sizeof(hdrdata));
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

function AttribIn(User,Against:attribset):boolean;
 begin

 AttribIn:= (User >= Against)
          { superset of.. }
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

procedure read_record_Hdr(var f:file;n:longint;rs:word;ofs:longint;var r:recordheader);
 begin
 {error i- here}
 Seek(f, (rs*(n-1))+ofs);
 BlockRead(f, r, sizeof(r));
 {$I+}
 end;

{ msg }
procedure open_msghdr(p,s:string);
  begin
  {error i- here}
  Assign(msghdrfile,p+s+'.HDR');
  reset(msghdrfile,1);
  {$I+}
  end;


procedure read_msghdr_genhdr;
  begin
  {error i- here}
  Seek(msghdrFile,0);
  BlockRead(msghdrFile, msghdrGenHdr, Sizeof(msgmbrgenHdr));
  {$I+}
  end;

procedure read_msghdr_hdr;
  begin
  {error i- here}
  Seek(msghdrFile,Sizeof(msgHdrGenHdr));
  BlockRead(msghdrFile,MsgHdrHdr,sizeof(msghdrHdr));
  {$I+}
  end;

procedure write_msghdr_hdr;
  begin
  {error i- here}
  Seek(msghdrFile,Sizeof(msgHdrGenHdr));
  Blockwrite(msghdrFile,MsgHdrHdr,sizeof(msghdrHdr));
  {$I+}
  end;

procedure read_msghdr_data(n:longint;var m:headertype);
  begin
  {error i- here}
  Seek(MsgHdrFile, (MsgHdrGenHdr.RecSize*(n-1))+MsgHdrGenHdr.Offset);
  BlockRead(MsgHdrFile, m, MsgHdrGenHdr.RecSize);
  {$I+}
  end;

procedure close_msghdr;
  begin
  {error i- here}
  Close(MsgHdrFile);
  {$I+}
  end;


{******** member ****}
procedure open_msgmbr(p,s:string);
  begin
  {error i- here}
  Assign(MsgMbrFile,p+s+'.MBR');
  reset(MsgMbrFile,1);
  {$I+}
  end;

procedure Read_msgmbr_GenHdr;
  begin
  {error i- here}
  Seek(MsgMbrFile,0);
  BlockRead(MsgMbrFile, MsgmbrGenHdr, Sizeof(MsgmbrGenHdr));
  {$I+}
  end;

procedure Read_msgmbr_Hdr;
  begin
  {error i- here}
  Seek(MsgMbrFile,Sizeof(MsgmbrGenHdr));
  BlockRead(MsgMbrFile,MsgmbrHdr,sizeof(MsgmbrHdr));
  {$I+}
  end;


procedure Write_msgmbr_GenHdr;
  begin
  {error i- here}
  Seek(MsgMbrFile,0);
  Blockwrite(MsgMbrFile, MsgmbrGenHdr, Sizeof(MsgmbrGenHdr));
  {$I+}
  end;

procedure Write_msgmbr_Hdr;
  begin
  {error i- here}
  Seek(MsgMbrFile, Sizeof(MsgmbrGenHdr));
  BlockWrite(MsgMbrFile , MsgmbrHdr , sizeof(MsgmbrHdr));
  {$I+}
  end;

procedure Read_msgmbr(n:longint;var m:membtype);
  begin
  {error i- here}
  Seek(MsgMbrFile, (MsgMbrGenHdr.RecSize*(n-1))+MsgMbrGenHdr.Offset);
  BlockRead(MsgMbrFile, m, MsgMbrGenHdr.RecSize);
  {$I+}
  end;

procedure Write_msgmbr(n:longint;m:membtype);
  begin
  {error i- here}
  Seek(MsgMbrFile, (MsgMbrGenHdr.RecSize*(n-1))+MsgMbrGenHdr.Offset);
  Blockwrite(MsgMbrFile, m, MsgMbrGenHdr.RecSize);
  {$I+}
  end;

procedure Close_msgmbr;
  begin
  {error i- here}
  Close(MsgMbrFile);
  {$I+}
  end;

{*********  config file *******}

Procedure Open_Config;
  begin
  {error i- here}
  assign(configfile, PathToConfig+configspec);
  reset(configfile);
  {$I+}
  end;

procedure Read_config;
  begin
  {error i- here}
  Seek(configfile, 0);
  read(configfile, cfg);
  {$I+}
  end;

Procedure Write_Config;
  begin
  {error i- here}
  Seek(configfile, 0);
  write(configfile, cfg);
  {$I+}
  end;

procedure Close_config;
  begin
  {error i- here}
  close(configfile);
  {$I+}
  end;

{*********  dir setup .. filedir.sl2   ***********}

procedure Open_Setup(n:kindofsetup);
  begin
  {error i- here}
  case N of
      setupDIR:Assign(SetupFile,Cfg.DataPath + DirSpec);
      setupMSG:assign(setupfile,cfg.datapath + subspec);
      end;
  Reset(SetupFile, 1);
  {$I+}
  end;

Procedure Read_Setup_GenHdr;
  begin
  {error i- here}
  Seek(SetupFile, 0);
  BlockRead(SetupFile, SetupGenHdr, Sizeof(SetupGenHdr));
  {$I+}
  end;

procedure Write_Setup_GenHdr;
  begin
  {error i- here}
  Seek(SetupFile, 0);
  BlockWrite(SetupFile, SetupGenHdr, Sizeof(SetupGenHdr));
  {$I+}
  end;

procedure Read_Setup_Hdr;
  begin
  {error i- here}
  Seek(SetupFile, Sizeof(SetupGenHdr));
  BlockRead(SetupFile , SetupHdr , sizeof(SetupHdr));
  {I+}
  end;

procedure Write_Setup_Hdr;
  begin
  {error i- here}
  Seek(SetupFile, Sizeof(SetupGenHdr));
  BlockWrite(SetupFile , SetupHdr , sizeof(SetupHdr));
  {$I+}
  end;

Procedure Read_Setup_Data(n: longint;Var Setup: SetupData);
  Begin
  {error i- here}
  Seek(SetupFile, (SetupGenHdr.RecSize*(n-1))+SetupGenHdr.Offset);
  BlockRead(SetupFile, Setup, SetupGenHdr.RecSize);
  {$I+}

  end;

Procedure Write_Setup_Data(n: longint; var Setup: SetupData);
  Begin
  {error i- here}
  Seek(SetupFile, (SetupGenHdr.RecSize*(n-1))+SetupGenHdr.Offset);
  BlockWrite(SetupFile, Setup, SetupGenHdr.RecSize);
  {$I+}
  end;

procedure Close_Setup;
  begin
  {error i- here}
  close(SetupFile);
  {$I+}
  end;

{*********   User File    **********}

procedure Open_user;
  begin
  {error i- here}
  Assign(userfile, Cfg.Datapath+userspec);
  reset(userfile, 1);
  {$I+}
  end;

procedure Read_User_GenHdr;
  begin
  {error i- here}
  seek(userfile, 0);
  blockread(userfile, usergenhdr, sizeof(usergenhdr));
  {$I+}
  end;

Procedure Read_User_Hdr;
  begin
  {error i- here}
  seek(userfile, sizeof(usergenhdr));
  blockread(userfile, userhdr, sizeof(userhdr));
  {$I+}
  end;

Procedure Read_User(n: longint; Var User: UserType);
  begin
  {error i- here}
  Seek(Userfile, (UserGenHdr.RecSize*(n-1))+UserGenHdr.Offset);
  Blockread(UserFile, User, UserGenHdr.Recsize);
  {$I+}
  end;

Procedure Write_User(n: longint;Var User: UserType);
  begin
  {error i- here}
  Seek(Userfile, (UserGenHdr.RecSize*(n-1))+UserGenHdr.Offset);
  Blockwrite(UserFile, User, UserGenHdr.Recsize);
  {$I+}
  end;

procedure Close_user;
  begin
  {error i- here}
  close(userfile);
  {$I+}
  end;

{********* File directories *********}

Procedure Open_Dir(path: string; name: string);
  begin
  {error i- here}
  Assign(DirFile, path+name+'.SL2');
  reset(DirFile, 1);
  {$I+}
  end;

procedure Close_Dir;
  begin
  {error i- here}
  close(DirFile);
  {$I+}
  end;

Procedure Read_Dir_GenHdr;
  begin
  {error i- here}
  Seek(DirFile, 0);
  BlockRead(DirFile, DirGenHdr, Sizeof(DirGenHdr));
  {$I+}
  end;

procedure Read_Dir_Hdr;
  begin
  {error i- here}
  Seek(DirFile, Sizeof(DirGenHdr));
  BlockRead(DirFile , DirHdr , sizeof(DirHdr));
  {$I+}
  end;

Procedure Write_dir(n: longint; Rec: DirType);
  begin
  {error i- here}
  Seek(DirFile, (DirGenHdr.RecSize*(n-1))+DirGenHdr.Offset);
  Blockwrite(DirFile, Rec, DirGenHdr.RecSize);
  {$I+}
  end;

Procedure Read_dir(n: longint;Var Rec: DirType);
  begin
  {error i- here}
  Seek(DirFile, (DirGenHdr.RecSize*(n-1))+DirGenHdr.Offset);
  BlockRead(DirFile, Rec, DirGenHdr.RecSize);
  {$I+}
  end;

Procedure Read_Shortdir(n: longint;Var Rec: DirType);
  begin
  {error i- here}
  Seek(DirFile, (DirGenHdr.RecSize*(n-1))+DirGenHdr.Offset);
  BlockRead(DirFile, Rec, 30); {sizeof(dir.leaf)+13}
  {$I+}
  end;



begin
 pathtoconfig:='';
 filemode := 66;
end.
