Unit Search;

type
  bigarray = array[0..65520] of byte;
  baptr    = ^bigarray;
  BMTable  = array[0..255] of byte;

  SearchObj = Object;
   Procedure

   Private
     Btable : BMtable;
     buffer : baptr;
   end;



procedure MakeBMTable(var t : BMtable; var s);
  { Makes a Boyer-Moore search table. s = the search string t = the table }
  var
    st  : BMtable absolute s;
    slen: byte absolute s;
    x   : byte;
  begin
    FillChar(t,sizeof(t),slen);
    for x := slen downto 1 do
      if (t[st[x]] = slen) then
        t[st[x]] := slen - x
  end;

function BMSearch(var buff,st; size : word): word;
  { Not quite a standard Boyer-Moore algorithm search routine }
  { To use:  pass buff as a dereferenced pointer to the buffer}
  {          st is the string being searched for              }
  {          size is the size of the buffer                   }
  { If st is not found, returns $ffff                         }
  var
    buffer : bigarray absolute buff;
    s      : array[0..255] of byte absolute st;
    len    : byte absolute st;
    s1     : string absolute st;
    s2     : string;
    count,
    x      : word;
    fond  : boolean;
  begin
    s2[0] := chr(len); { sets the length to that of the search string }
    found := false;
    count := pred(len);
    while (not found) and (count < (size - len)) do begin
      if (buffer[count] = s[len]) then { there is a partial match } begin
        if buffer[count-pred(len)] = s[1] then { less partial! } begin
          move(buffer[count-pred(len)],s2[1],len);
          found := s1 = s2;                 { if = it is a complete match}
          BMSearch := count - pred(len);    { will stick unless not found}
        end;
        inc(count);              { bump by one char - match is irrelevant}
      end
      else
        inc(count,Btable[buffer[count]]);   { no match so increment maximum}
    end;
    if not found then
      BMSearch := $ffff;
  end;  { BMSearch }
