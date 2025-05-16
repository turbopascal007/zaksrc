unit nl;

interface

implementation

uses etc;

const crc1:longint = -1887570771;

var crc2:longint;
    t:string;

begin

if paramcount=0 then
  begin
  writeln('key sl# bbs name');
  halt;
  end;

t:=barepasswdinput(20);

crc2:=crc32array(@t[1],length(t));

if crc2<>crc1 then
  begin
  writeln('bad passwd');
  halt;
  end;

end.