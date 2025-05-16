const active=0;
      deleted=255;
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

{The follwing is a reference of the data types provided by FILEDEF.TPU.
Note: do not attempt to compile this file.  Doing so may cause the
updated FILEDEF.TPU file to be incompatible with the other TPU files.}

const logsize   =  75;  { size of last caller log }
      chatsize  =   4;  { chat queue size - 1 }
      ulistmax  =  50;  { upload list size }
      maxproto  =  15;  { number of external protocols }


const { Message File Constants }
      indexsize = 1024;       { size of index hash table }
      blocksize = 250;        { text block size }


const configspec  = 'CONFIG.SL2';   { Configuration Info }
      nodesspec   = 'NODES.SL2';    { Node Information }

      QuoteSpec   = 'QUOTES.SL2';
      chatspec    = 'CHAT.SL2';     { Chat File }
      logspec     = 'LOG.SL2';      { Caller Log }

      subspec     = 'SUBBOARD.SL2'; { Subboard Definitions }
      dirspec     = 'FILEDIR.SL2';  { UL/DL Directory Definitions }
      doorspec    = 'DOORS.SL2';    { External Program Definitions }

      msysspec: string[80]
                  = 'STRINGS.SYS';  { Offline Message Strings }

      userspec    = 'USER.SL2';
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
       dropfile: byte;      { 0=None 1=PCB14 2=PCB12 }
       pause: boolean;      { pause after door executes? }
       extra: string[8];
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
       flogspec: string[45];   { files log filespec [std] }
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
       indoors: byte;          { doors active flag }

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

       MainlevelsX: array[1..30] of byte;
         { access levels for main menu - Not used in 2.25 & up }

       FileslevelsX: array[1..30] of byte;
         { access levels for files menu - Not used in 2.25 & up }

       ftime: timetype;        { start of xfer time }
       fdisc: char;            { disconnect from external xfer }

       fileset: string[60];
         { name of DIR file to use upon startup }

       invis: boolean;         { Alt-I invisible switch }

       expireaction: byte;     { 0=none, 1=reset access, 2=delete account }
       usesession: boolean;    { Use session time limit? }
       junk: boolean;          { reserved }

       UserAnsiMode: AnsiType;   { Ansi type of person running door }
       RegDays: integer;         { reserved }
       subdoors: boolean;        { internal flag for doors menu }

       menupath: string[45];     { Path to menu files }

       { Misc. Functionality Security Attributes }
       FwdAttrib: AttribSet;     { Attribs. needed to forward messages }
       ChatAttrib: AttribSet;    { Needed to use internode chatting }
       QuotAttrib: AttribSet;    { Needed to use F4 message quoting }

       More: Array[1..8] of AttribSet;  { Room for more }

       UploadDoor: Autodoortype;        { Upload autodoor }
       ExUD: boolean;                   { Execute upload autodoor? }

       extra: array[1..701] of byte;

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
       pref: attribset;        { user preference attributes }
       NoSubPrompt,
       NoMsgPrompt: boolean;   { display subboard/mail disposition prompts? }
       LastMailDate: datetype; { date specified in last mail list/inquire }
       extra: string[42];      { extra space }
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
       msgpause: byte;         { msg pause default prompt/yes/no }

       pad: array[1..18] of byte;   { pad to 256 bytes }

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


     IndexType = array [SEQ..UID,0..IndexSize-1]
       of longint;           { index for sequential and uid values }


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



