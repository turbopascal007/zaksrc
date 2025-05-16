{Talk is a speech program which uses phonemes to speak numbers through}
{the PC's speaker port.}

{This program was derived from a program found in }
{the IBMPRO forum library of Compuserve called TPSPCH.ARC }
{ Authors: David Neal Dubois,  Michael Day }
{ released by authors to the public domain as of 22 April 1989 }

program Talk;
Uses Speech;

procedure NumSpeak(N: integer);
  begin
    case N of
      01:           Speak(' wh-uh-n');
      02:           Speak(' t-oo');
      03:           Speak(' th-r-ee');
      04:           Speak(' f-oh-r');
      05:           Speak(' f-i-v');
      06:           Speak(' s-ih-k-s');
      07:           Speak(' s-eh-v-eh-n');
      08:           Speak(' a-ee-t');
      09:           Speak(' n-i-n');
      10:           Speak(' t-eh-n');
      11:           Speak(' eh-l-eh-v-eh-n');
      12:           Speak(' t-w-eh-l-v');
      13:           Speak(' th-ih-r-t-ee-n');
      14:           Speak(' f-oh-r-t-ee-n');
      15:           Speak(' f-ih-f-t-ee-n');
      16:           Speak(' s-ih-k-s-t-ee-n');
      17:           Speak(' s-eh-v-eh-n-t-ee-n');
      18:           Speak(' a-ee-t-t-ee-n');
      19:           Speak(' n-i-n-t-ee-n');
      20..29:       begin
                      Speak(' t-w-eh-n-t-ee');
                      NumSpeak(N - 20);
                    end;
      30..39:       begin
                      Speak(' th-ih-r-t-ee');
                      NumSpeak(N - 30);
                    end;
      40..49:       begin
                      Speak(' f-oh-r-t-ee');
                      NumSpeak(N - 40);
                    end;
      50..59:       begin
                      Speak(' f-ih-f-t-ee');
                      NumSpeak(N - 50);
                    end;
      60..69:       begin
                      Speak(' s-ih-k-s-t-ee');
                      NumSpeak(N - 60);
                    end;
      70..79:       begin
                      Speak(' s-eh-v-eh-n-t-ee');
                      NumSpeak(N - 70);
                    end;
      80..89:       begin
                      Speak(' a-ee-t-ee');
                      NumSpeak(N - 80);
                    end;
      90..99:       begin
                      Speak(' n-i-n-t-ee');
                      NumSpeak(N - 90);
                    end;
      100..999:     begin
                      NumSpeak(N div 100);
                      Speak(' h-uh-n-d-r-eh-d');
                      NumSpeak(N mod 100);
                    end;
      1000..maxint: begin
                      NumSpeak(N div 1000);
                      Speak(' th-aw-u-s-ae-n-d');
                      NumSpeak(N mod 1000);
                    end;
    end;
  end; {NumSpeak}

var
  Value : integer;
  I : word;

begin
  Resolve := 1;
  SpeedDelay := 22*Resolve;

  CalibrateSpeech(false);

  {for I := 0 to 15 do                   (* to speak your computer's memory *)
    Talk ( ptr ( I * $1000, 0 ), 0 );}

  Value := 100;
  while Value > 0 do
  begin
     write ( 'Enter value: ');
     readln ( Value );
     NumSpeak ( Value );
     writeln;
  end;

end.
