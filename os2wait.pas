uses crt;

procedure a;assembler;
 asm
 mov ax, $1680;
 int $2f;
 end;

begin
repeat a until keypressed;
end.

