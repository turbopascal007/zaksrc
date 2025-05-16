{Speech is a program unit which uses phonemes to speak through}
{the PC's speaker port.}

{This program was derived from a program found in }
{the IBMPRO forum library of Compuserve called TPSPCH.ARC }
{ Authors: David Neal Dubois,  Michael Day }
{ released by authors to the public domain as of 22 April 1989 }

{$F+}     {<-- must be compiled as Far}
Unit Speech;
interface

const
  SpeedDelay  : word = 20;
  Resolve     : word = 1;
  PhonemeSize : word = $023F;
  SpeedCal    : word = 11; {how long it takes to say "hello"}

var
  WorkSpeed : word;

  procedure Talker(Start:pointer; Size,Speed,Resolve:word; Snd:boolean);
  procedure TalkPhoneme(Snd:boolean; Phoneme:string);
  procedure Speak(S:string);      { Allows any non-alphabetic sperator }
  function InitSpeed:word;
  procedure CalibrateSpeech(Snd:boolean);

{-----------------------------------------------}
implementation

{$F+}
  procedure Talker(Start:pointer; Size,Speed,Resolve:word; Snd:boolean);
    external;
  {$L c:\tp\bin\Talker.OBJ}

{$F+}
  procedure TalkDataLink; external;
  {$L c:\tp\bin\TalkData.OBJ}

{$F+}
  function InitSpeed:word; external;
  {$L c:\tp\bin\InitSpd.OBJ}


{-----------------------------------------------}

  procedure CalibrateSpeech(Snd:boolean);
  var SysClk : longint absolute $40:$6C;
      StartTime,EndTime : longint;
      TestCal : word;
    function Cal:word;
    begin
      StartTime := SysClk;
      TalkPhoneme(Snd,' ');
      TalkPhoneme(Snd,'H');
      TalkPhoneme(Snd,'EH');
      TalkPhoneme(Snd,'L');
      TalkPhoneme(Snd,'OH');
      EndTime := SysClk;
      Cal := EndTime - StartTime;
    end;

  begin
    TestCal := 0;
    Resolve := 8;
    SpeedDelay := 1;
    while TestCal < SpeedCal do
    begin
      TestCal := Cal;
      if TestCal < SpeedCal then
      begin
        Inc(SpeedDelay,SpeedCal-TestCal);
        if (SpeedDelay > 8) and (Resolve > 1) then
        begin
          Resolve := Resolve shr (SpeedDelay shr 3);
          SpeedDelay := 1;
        end;
      end;
    end;
  end;

  {---------------------------------------------------}
  procedure TalkPhoneme(Snd:boolean; Phoneme:string);

  const
    PhonemeList : array [ 1 .. 35 ] of string [ 2 ]
                = ( 'U',  'A',  ' ',  'B',  'D',  'G',
                    'J',  'P',  'T',  'K',  'W',  'Y',
                    'R',  'L',  'M',  'N',  'S',  'V',
                    'F',  'H',  'Z',  'AW', 'AH', 'UH',
                    'AE', 'OH', 'EH', 'OO', 'IH', 'EE',
                    'WH', 'SH', 'TZ', 'TH', 'ZH' );
  var
    I, N : integer;
    Found : boolean;
  begin
    for I := 1 to length ( Phoneme ) do
      Phoneme [ I ] := upcase ( Phoneme [ I ] );
    if Phoneme = 'I' then
      begin
        TalkPhoneme (true, 'AH' );      { "I" is special. Is treated as combo. }
        TalkPhoneme (true, 'EE' );
      end
    else
      begin
        Found := false;                          { Search list }
        for I := 1 to 35 do
          if PhonemeList [ I ] = Phoneme then
            begin
              N := I;
              Found := true;
            end;
        if Found then
          begin
            write ( Phoneme, ' ' );
            Talker ( ptr( seg(TalkDataLink),
                          ofs(TalkDataLink) + pred(N) * PhonemeSize ),
                          PhonemeSize, SpeedDelay, Resolve, Snd);

          end;
      end;
  end;

{-----------------------------------------------}
  procedure Speak(S:string);      { Allows any non-alphabetic sperator }
  const
    SpaceDelay = 10;
  var
    Phoneme : string;
    I       : integer;
    C       : char;

    procedure Dump;
    begin
      if Phoneme <> '' then
        TalkPhoneme (true, Phoneme );
    end;

  begin { Speak }
    Phoneme := '';
    for I := 1 to length ( S ) do
      begin
        C := S [ I ];
        case C of
          ' '        : begin
                         Dump;
                         TalkPhoneme (true, ' ' );
                       end;
          'a' .. 'z',
          'A' .. 'Z' : Phoneme := Phoneme + C
          else         begin
                         Dump;
                         Phoneme := '';
                       end;
        end;
      end;
    Dump;
  end;

{-----------------------------------------------}
begin
   WorkSpeed := InitSpeed;
end.
