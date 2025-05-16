Unit pauses;

Interface

Procedure Os2Pause;

implementation

procedure Os2Pause;assembler;
 asm
 mov ax, $1680;
 int $2f;
 end;

end.
