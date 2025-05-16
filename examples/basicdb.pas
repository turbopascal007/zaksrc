Program BasicDB;

{
    This is going to be a really basic database program that doesn't have
    much (any) optimization.   The basic structure of the files will not
    be very efficient.  It will just search the records; they will not be
    keyed in any way for faster searches.   A much better way to do this
    would be to use a binary tress type file.
}

Uses Dos,Crt;

Const FileName = 'BasicDB.Dat';

Type  HandType = (Left,Right);

Type  RecordType = Record
         Name: string[25];
          Age: word;
       Handed: HandType
        end;

function lowcase(ch: char): char;  { lowcase and upcasestr are useful }
  begin
  ch := upcase(Ch);
  case ord(ch) of
   65..90: Lowcase := chr(ord(ch)+32);
   else Lowcase := Ch;
  end;
  end;

function UpcaseStr(s:string):string;
  var a:byte;
  begin
  for a:=1 to ord(s[0]) do s[a] := upcase(s[a]);
  UpCaseStr := s;
  end;

procedure Editor(maxlen: byte; var answerformain: string; prestring: string);
   const ansi=true;       { these are needed because I originally designed }
         fgc=white;       { this to work in an online environment.  I have }
         bgc=blue;        { adapted it (quickly) to work normally..        }
         carrier_on=true;
         portcheck=true;
         capson=false;

   var
       tempkey : char;      { this was one of the very first procedures I  }
       done    : boolean;   { write in Pascal. (and it shows!)  This is,   }
       index   : byte;      { more than anything, an example of really bad }
       answer  : string;    { coding..                                     }
       baseX   : byte;
       i       : byte;
     insertmode: boolean;
  stringtempkey: string[1];
      useinsert: boolean;
      carrier  : boolean;

   begin
   baseX := whereX;
   done := false;
   useinsert:=false;

   insertmode:=useinsert;
   if not(ansi) then useinsert:=false;

   index := 0;
   answer := '';
   if length(prestring) <> 0 then
      begin
      answer := prestring;
      index := length(prestring);
      end;

   if (ANSI and insertmode) then
     begin
     gotoXY(baseX+maxlen+2, whereY);
     textcolor(lightred);TextBackground(black);
     Write('i');
     gotoxy(basex, wherey);
     end;

   textcolor(fgc);
   TextBackground(bgc);


   Write(' '+Prestring);

   if ANSI then
     begin
     for i:=length(prestring)+1 to maxlen+1 do Write(' ');
     gotoXY(basex+1+index,wherey);
     end;

   { functions ... backspace, right, left, overwrite mode for L, R }
   {               enter, delete                                   }

   repeat
      repeat
       if portcheck then
        If Not Carrier_On then
         begin
         Carrier:=false;
         Exit;
         end;
      until keypressed;

      tempkey := readkey;
      case tempkey of
        #32,

             {'A'..'Z', 'a'..'z','0'..'9', ',' , '.':}

             ' '..'~':

             begin
              if ord(answer[0]) < maxlen then
               begin
               inc(index);
               if index <= maxlen then
               begin
               if CapsOn then
   {for upcase} if (answer[index-1] = #32) or (Answer[index-1] = #0) then
   {checking}     begin
                  tempkey := upcase(tempkey);
                  end
                else tempkey := lowcase(tempkey);

               if insertmode and ansi then
                  begin
                  if ord(answer[0]) < maxlen then
                    begin
                    stringtempkey := tempkey;
                    insert(stringtempkey, answer, index);
                    if CapsOn then Answer := CaseStr(Answer);
                    if index <> ord(answer[0]) then
                     begin
                     gotoxy(baseX+1, wherey);
                     Write(answer);
                     gotoxy(baseX+index+1, wherey);
                     end
                    else Write(tempkey);
                    end;
                  end
               else
                  begin
                  if index < ord(answer[0])+1 then answer[index] := tempkey
                  else answer := answer + tempkey;
                  Write(tempkey)
                  end;
               end;
              end;
             end;
        #13:
             begin
             done := true;
             end;
        #8:
             begin

             if (index > 0)  then
              begin
              dec(index);
              delete(answer, Index+1, 1);
              if ANSI then
                  begin

                  gotoXY(BaseX+Index+1, whereY);
                  Write(copy(answer, index+1, ord(answer[0])-index)+' ');
                  gotoXY(BaseX+index+1, whereY);

                   end
              else Write(#8+' '+#8);
              end;
             end;
        #0:                         { test for extended characters }
             begin
             case readkey of        { poll for extended part }
               #75:                 { left arrow }
                   begin
                   if ANSI then
                    begin
                    if index >= 1 then
                     begin
                     dec(index);
                     gotoxy(whereX-1, wherey);
                     end;
                    end;
                   end;
               #77:                 { right arrow }
                  begin
                  if ANSI then
                   begin
                   if index < ord(answer[0]) then
                     begin
                     inc(index);
                     gotoxy(whereX+1, whereY);
                     end;
                   end;
                  end;
               #71:                 { home }
                  begin
                  if ANSI then
                     begin
                     index := 0;
                     gotoxy(baseX+1, wherey);
                     end;
                  end;

               #79: IF ANSI then
                  begin
                  index := ord(answer[0]);
                  gotoXY(BaseX+Ord(answer[0])+1, whereY);

                  end;

               #82:      { ins }
                if useinsert then
                  begin
                  gotoXY(baseX+maxlen+2, whereY);
                  textcolor(lightred);TextBackground(black);
                  if insertmode then begin insertmode := false; Write(' ') end
                  else begin insertmode := true; Write('i'); end;
                  GotoXY(BaseX+Index+1, whereY);
                  textcolor(white);TextBackground(blue);
                  end;

               #83:         { del }
                  begin
                  if ANSI then
                    begin
                    delete(answer,index+1,1);
                    If CapsOn then Answer := CaseStr(Answer);
                    gotoXY(baseX+1, whereY);
                    for i:=1 to ord(answer[0]) do Write(Answer[i]);
                    Write(' ');

                    gotoxy(baseX+index+1, wherey);
                    end;
                  end;

               end;                           { end of 'case readkey of' }
             end;                             { end of '#0: begin' }
        end;                                  { end of 'case tempkey of' }
   until done;

   {answer[0] := chr(ord(answer[0]));}
   answerformain := answer;
   if ANSI then gotoXY(baseX+maxlen+2, wherey) else
     for i := index to maxlen+1 do Write(' ');
   TextBackground(black);Write(' '+#8+' ');
   end;


Var   f: file;
    wrec: RecordType;
    rrec: RecordType;


begin
WriteLn;
WriteLn('Assigning Values');

with wrec do
 begin
 Name  := 'Test';   { equivalent to wrec.Name ... }
 Value := $2112;    {    "        "  "  .Value    }
 Hand  := Left
 end;

WriteLn('Writing File');

Assign(f,FileName);            { Assign the file var to a filename }
ReWrite(f,SizeOf(RecordType)); { open it for the first time or overwrite}

 { the SizeOf(RecordType) tells TP that the default block size for the file
  is however big RecordType is.  Then we can use 1 for the number of blocks
  to use using BlockRead and BlockWrite

  SizeOf(RecordType) could be changed to 1 if you wanted to always specify
  the exact size in bytes for each individual BlockRead/BlockWrite
 }

Seek(f,0);                     { Seek to the 1st record just in case, ofs 0 }
BlockWrite(f,wrec,1);          { write the data, 1 block long }
Close(f);

WriteLn('Type EXIT to return to program ',ParamStr(0));

 { Now we will shell to DOS because that is somewhat interesting.. }

SwapVectors; { SwapVectors are not really required, but they are general
               good programming practice, because when you start to grab
               ahold of interrupts, havok can occur. }

Exec(GetEnv('COMSPEC'),'');
SwapVectors;                { and then restore whatever interrupts you
                              grabbed, in this case nothing }

WriteLn;
WriteLn('Reading File');

Assign(f,FileName);
Reset(f,SizeOf(RecordType));
Seek(f,0);
BlockRead(f,rrec,1);
Close(f);

with rrec do
 begin
 WriteLn(' Name: ',Name);
 WriteLn('Value: ',Value);
 Case Hand of
    Left: WriteLn('Left Hand');
   Right: Writeln('Right Hand')
   else WriteLn('Illegal Value -or- You have a hand which is not right or left.')
   end
 end

end.

blah