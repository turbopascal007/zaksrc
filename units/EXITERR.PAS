Unit ExitErr;
{$O+,F+}

Interface

Const LostCarrierError = 300;

Implementation

function ErrorString(errcode:integer):string;
 begin
 { default error msg }
  ErrorString:='Unknown Error: Report Address and Error Code to Programmer';

 case ErrCode of
   1:ErrorString:='DOS error: invalid function number; internal program error; ';
   2:errorstring:='DOS error: file not found; file must exist';
   3:errorstring:='DOS error: path not found; subdirectory must exist';
   4:errorstring:='DOS error: too many open files; add to FILES=xx in CONFIG.SYS';
   5:errorstring:='DOS error: file access denied; check file attributes; check for SHARE';
   6:errorstring:='DOS error: invalid file handle';
   7:errorstring:='DOS error: memory control blocks destroyed';
   8:errorstring:='DOS error: insufficient memory';
   9:errorstring:='DOS error: invalid memory block';
  10:errorstring:='DOS error: invalid environment';
  11:errorstring:='DOS error: invalid format';
  12:errorstring:='DOS error: invalid file access code; this should never happen';
  13:errorstring:='DOS error: invalid data';
  14:errorstring:='DOS error: this error doesn''t exist';
  15:errorstring:='DOS error: invalid drive number';
  16:errorstring:='DOS error: cannot remove current directory';
  17:errorstring:='DOS error: cannot rename file across drives';

  18:errorstring:='DOS error: no more files';
  19:errorstring:='DOS error: cannot write on protected device';
  20:errorstring:='DOS error: unknown unit';

  21:errorstring:='DOS error: drive not ready';
  22:errorstring:='DOS error: unknown command';
  23:errorstring:='DOS error: data error';

  24:errorstring:='DOS error: bad request structure length';
  25:errorstring:='DOS error: seek error';
  26:errorstring:='DOS error: unknown media type';
  27:errorstring:='DOS error: sector not found';
  28:errorstring:='DOS error: printer paper alarm';
  29:errorstring:='DOS error: write fault';
  30:errorstring:='DOS error: read fault';
  31:errorstring:='DOS error: general failure';
  32:errorstring:='DOS error: sharing violation';
  33:errorstring:='DOS error: lock violation';
  34:errorstring:='DOS error: invalid disk change';
  35:errorstring:='DOS error: FCB unavailable';
  36:errorstring:='DOS error: sharing buffer overflow';
  50:errorstring:='DOS error: network request not supported';
  51:errorstring:='DOS error: remote computer not listening';
  52:errorstring:='DOS error: duplicate name on network';
  53:errorstring:='DOS error: network name not found';
  54:errorstring:='DOS error: network busy';
  55:errorstring:='DOS error: network device no longer exists';
  56:errorstring:='DOS error: net BIOS command limit exceeded';
  57:errorstring:='DOS error: network adaptor hardware error';
  58:errorstring:='DOS error: incorrect response from network';
  59:errorstring:='DOS error: unexpected network error';
  60:errorstring:='DOS error: incompatible remote adaptor';
  61:errorstring:='DOS error: print queue full';
  62:errorstring:='DOS error: not enough space for print file';
  63:errorstring:='DOS error: print file was deleted';
  64:errorstring:='DOS error: network name was deleted';
  65:errorstring:='DOS error: access denied';
  66:errorstring:='DOS error: incorrect network device type';
  67:errorstring:='DOS error: network name not found';
  68:errorstring:='DOS error: network name limit exceeded';
  69:errorstring:='DOS error: net BIOS session limit exceeded';
  70:errorstring:='DOS error: temporarily paused';
  71:errorstring:='DOS error: network request not accepted';
  72:errorstring:='DOS error: print or disk redirection is paused';
  80:errorstring:='DOS error: file exists';
  82:errorstring:='DOS error: cannot make directory entry';
  83:errorstring:='DOS error: fail on INT 24';
  84:errorstring:='DOS error: too many redirections';
  85:errorstring:='DOS error: duplicate redirection';
  86:errorstring:='DOS error: invalid password';
  87:errorstring:='DOS error: invalid parameter';
  88:errorstring:='DOS error: network device fault';

 100:errorstring:='I/O error: disk read error; read past end of file. corrupted file?';
 101:errorstring:='I/O error: disk write error; disk full';
 102:errorstring:='I/O error: file not assigned, this should never happen, ';
 103:errorstring:='I/O error: file not open';
 104:errorstring:='I/O error: file not open for input';
 105:errorstring:='I/O error: file not open for output';
 106:errorstring:='I/O error: invalid numeric format, check text file';


 150:errorstring:='Critical I/O error: disk is write-protected';
 151:errorstring:='Critical I/O error: unkown unit';
 152:errorstring:='Critical I/O error: drive not ready';
 153:errorstring:='Critical I/O error: unkown command';
 154:errorstring:='Critical I/O error: CRC error in data or LAN disruption';
 155:errorstring:='Critical I/O error: bad drive request structure length';
 156:errorstring:='Critical I/O error: disk seek error';
 157:errorstring:='Critical I/O error: unkown media type';
 158:errorstring:='Critical I/O error: sector not found, check disk integrity';
 159:errorstring:='Critical I/O error: printer out of paper, add some';
 160:errorstring:='Critical I/O error: device write fault';
 161:errorstring:='Critical I/O error: device read fault';
 162:errorstring:='Critical I/O error: hardware failure';


 200:errorstring:='FATAL error: division by zero, undefined';
 201:errorstring:='FATAL error: range check error';
 202:errorstring:='FATAL error: stack overflow';
 203:errorstring:='FATAL error: heap overflow error, program requires more free RAM';
 204:errorstring:='FATAL error: invalid pointer operation';
 205:errorstring:='FATAL error: floating point operation';
 206:errorstring:='FATAL error: floating point underflow';
 207:errorstring:='FATAL error: invalid floating point operation';
 208:errorstring:='FATAL error: overlay manager not installed';
 209:errorstring:='FATAL error: overlay file read error, check integrity of files';
 210:errorstring:='FATAL error: i don''t say OOP, I say oops';
 211:errorstring:='FATAL error: call to abstract method, OOPs';
 212:errorstring:='FATAL error: stream registration error, OOPs';
 213:errorstring:='FATAL error: collection index out of range, OOPs';
 214:errorstring:='FATAL error: collection overflow error, OOPs';

 { Custom Errors :-) }

 LostCarrierError:errorstring:='MODEM error: Carrier Lost -- Aborting';

  end;
 end;

Var ExitSave: Pointer;

Procedure Finale; far;
 begin
 ExitProc:=ExitSave;
 if not(exitcode=0) then 
   begin
   writeln;
   writeln(errorstring(exitcode));
   writeln('If you require assistance:');
   writeln(' þ Record this Message');
   writeln(' þ Record the Address listed (xxxx:yyyy)');
   writeln(' þ Record the Error Number');
   writeln(' þ Report to Programmer');
   end
 end;

begin
ExitSave := ExitProc;
ExitProc:=@Finale
end.
