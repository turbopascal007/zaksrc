Program SRVDRVR; { Survey Driver }

Uses Dos, Crt, Etc, SLDriv, SlFiles, FileDef;

type sctype = record
      perc: byte;
      haha: string[50];
      end;
Var
   User         : UserType;
   InpFName     : string[60];
   InpF         : Text;
   UserName     : string[25];
   NumofQ       : integer;
   NumYes       : integer;
   CurLine      : string;
   Done         : Boolean;
   nos          : integer;
   score        : array[1..20] of sctype;

Function UpCASEStr(s: string):string;
  var a: integer;
  begin
  for a:=1 to ord(s[0]) do s[a]:=upcase(s[a]);
  UpCASEStr := s;
  end;

Procedure Parse;
  var a: integer;
  begin
  if Paramcount =  0 then
      begin
      textcolor(lightcyan);
      writeln('SRVDRVR - Survey Driver by Zak Smith');
      writeln('SRVDRVR <filename> <user name, optional>');
      halt(1);
      end;

  If ParamCount > 0 then
     begin
     InpFName := Paramstr(1);

     if InpFName[ord(InpFName[0])] = '.' then InpFName := InpFName + 'DRV';

     if upcaseSTR(Copy(InpFName,ord(InpFName[0])-3, 4)) <> '.DRV' then
        InpFName := InpFName + '.DRV';

     If Paramcount >1 then
      begin
      UserName := Paramstr(2);
      For a:=3 to paramcount do
        begin
        UserName := UserName + ' ' + Paramstr(a);
        end;
      end;
     end;
  end;

procedure OpenFile;
  begin
  Assign(InpF, InpFName);
  Reset(InpF);
  end;

Procedure CloseFile;
  begin
  Close(InpF);
  end;


Function LTrim(s: string): string;
var a: byte;
  begin
  a:=0;
  Repeat
   begin
   inc(a);
   end;
  until (s[a] <> ' ') or (a=ord(s[0]));
  Delete(s, 1, a-1);
  Ltrim := S;
  end;


Procedure CommentLine(s:string);
  begin
  TextBackground(Black);
  TextColor(LightGray);
  Writeln(copy(S, 2, ord(s[0])-1));
  end;


Procedure Funct(S:string);
  var  temp: string[10];
       a : byte;
       b : byte;
       c : integer;
  begin
  a:=0;
  temp := '';
  if Upcasestr(Copy(S,2,5)) = 'SCORE' then
     begin
     inc(nos);

     repeat
       begin
       inc(a);
       temp := temp + s[a+7];
       end;
     until s[a+1+7] = ' ';
     val(temp,Score[nos].Perc, c);
     Score[nos].haha := copy(s, a+1+7+1, ord(s[0])-(a+1+7));
     end;

  if UpCaseStr(copy(S, 2, ord(s[0])-1)) = 'MORE' then
    begin
    textcolor(cyan);
    write('[MORE]');
    repeat until readkey <> #0;
    gotoxy(1, wherey);
    clreol;
    end;
  end;

procedure Question(s:string);
  Var i1: byte;
      i2: byte;
      i : byte;
      t : char;
      r : byte;
      l : byte;


  const ll=78;

  begin

  l := ord(s[0]);

  textcolor(lightgray);

  if ord(s[0]) > ll then
     BEGIN
     i1 := 1;
     i2 := ll;
     i  := ll;

     WHILE i2 < l do
        BEGIN
        i:=i2;
        WHILE NOT (s[i] IN [' ']) do
          BEGIN
          dEC(i);
          if i = i1 then i:=i2-1;
          END;
          i2:=i+i1-1;
        write(copy(s,i1,i2));
        i1:=i2+1;
        if i2 > l then
           begin
           end
        else
           begin
           writeln;
           end;
        END;
     END
  else write(s);

  if ansi then textcolor(lightmagenta);
  write(' ');
  repeat t:=upcase(readkey) until t in ['Y','N','Q'];
  write(t);
  case t of
    'Y': R := 2;
    'Q': R := 3;
    'N': R := 1;
    end;

  case R of
    2: inc(NumYes);
    3: begin done := true;if NumofQ = 0 then inc(NumofQ); end
    end;

  if not Done then inc(NumOfQ);
  writeln;
  end;

Procedure ProcessFile;
  begin
  Repeat
     begin
     ReadLn(InpF, CurLine);
     if EOF(InpF) then Done := True;

     CurLine := LTrim(CurLine);

     Case CurLine[1] of
         '#':  CommentLine(CurLine);
         '$':  Funct(CurLine);
         else Question(CurLine)
         end; {case}
     end;
  until Done;
  end;

Procedure ShowScore;
  var a: integer;
  begin
  a:=0;
  repeat inc(a) until Score[a].Perc <=  ((NumYes / NumOfQ) * 100);
  writeln;writeln;
  textcolor(Lightcyan);write('Congradulations ',UserName,', You are ');
  textcolor(lightgreen);Write(Score[a].haha);
  writeln;
  writeln;
  end;

begin
  Parse;

  {LoadSlData;}

  DirectVideo := false;
  PathToConfig := '';
  If SLActive then
    begin
    Open_Config;
    Read_Config;
    Close_Config;

    Open_User;
    Read_User_GenHdr;
    Read_User_Hdr;

    Read_User(Cfg.Curruser, User);
    Close_User;
    UserName := User.Name;
    Ansi := Data^.Ansi;
   end

  else
    begin
    Ansi := true;
    end;

  writeln;
  textbackground(blue);textcolor(white);
  write(' SURVEY DRIVER - Copyright (c) copyright by Zak Smith 1991 all rights reserved ');
  textbackground(black);writeln;writeln;

  Textcolor(lightgray);write('Hi ');
  textcolor(yellow);write(casestr(username));
  textcolor(lightgray);writeln('.');
  writeln('Use the ARROW,Y,N,and Q keys to answer.');writeln;

  NumofQ := 0;
  Done := False;
  nos := 0;
  numyes := 0;

  if SlActive then LocalOnly;
  writeln('Opening ',InpFName,' for input');
  if SlActive then LocalAndRemote;

  OpenFile;
  ProcessFile;
  ShowScore;
  CloseFile;
end.
