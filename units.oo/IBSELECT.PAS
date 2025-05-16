Unit IBSelect;
{$O+,F+}

interface

Const CrLf:string[2]=#13+#10;


Type
     WriteType = procedure (s:string);
     movexType = procedure (x:integer);
     TextColorType = procedure(c:byte);
     TextBackgroundtype = procedure(c:byte);
     ReadKeyType = function(var extend:char):char;
     ClrEolType = procedure;

Type
 pIBSelObj = ^IBSelObj;
 IBSelObj = object
   Constructor Init(fg,bg,abarcolor_:byte;
               command_string:string;
               nch:byte;
               ansi_:boolean;
               Write_:WriteType;
               movex_:movextype;
               textcolor_:textcolortype;
               textbackground_:textbackgroundtype;
               readkey_:readkeytype);

   Function Run: byte;
   Destructor done;
   private
       FGc,BGc,abarcolor:byte;
       comstr:string;
       numch:byte;
       ansi: boolean;
       movex:movextype;
       write:writetype;
       textcolor:textcolortype;
       textbackground:textbackgroundtype;
       readkey:readkeytype;
   end;


implementation

uses etc;

Constructor IBSelObj.Init(fg,bg,abarcolor_:byte;
               command_string:string;
               nch:byte;
               ansi_:boolean;
               Write_:WriteType;
               movex_:movextype;
               textcolor_:textcolortype;
               textbackground_:textbackgroundtype;
               readkey_:readkeytype);
begin

fgc:=fg;
bgc:=bg;
abarcolor:=abarcolor_;

ansi := ansi_;

comstr:=command_string;
if comstr[ord(comstr[0])]<>#32 then comstr:=comstr+' ';

numch:=nch;

write:=write_;
movex:=movex_;

textcolor:=textcolor_;
textbackground:=textbackground_;
readkey:=readkey_;

end;


Function IBSelObj.Run: byte;
   { last char of comstr must NOT be #32 }
   type
       datatype = record
         ofs     : byte;
         text    : string;
         end;
        choicetype = array[1..10] of datatype;
   var
      i      : byte;
      c      : choicetype;
      incr   : byte;
      done_  : boolean;
      baseX  : byte;
      tempkey: char;
      last   : byte;
      curc   : byte;
      oldc   : byte;

 var e:char;

   begin
   if ANSI then
    Begin

    done_ := false;
    last := 1;
    incr := 0;
    for i := 1 to length(comstr) do
        if comstr[i] = ' ' then
           begin
           inc(incr);
           c[incr].ofs := (incr+last-2);
           c[incr].text := ' '+copy(comstr,last,i-last)+' ';
           last := i+1;
           end;

    textcolor(abarcolor);
    textbackground(0);

    for i := 1 to incr do
         begin
         write(c[i].text);
         end;

    OldC := 1;
    CurC := 1;

    moveX(- length(comstr)- numch );

    Textcolor(fgc);
    textbackground(bgc);

    write(c[CurC].text);

    repeat
      begin
      tempkey := readkey(e);
      case upcase(tempkey) of
          #0:begin
             case e of
                #77:
                   begin
                   inc(CurC);
                   if CurC = numch+1 then CurC := 1;
                   end;
                #75:
                   begin
                   dec(CurC);
                   if CurC = 0 then CurC := numch;
                   end;
                end
             end;

          #32:begin
              CurC := CurC +1;
              if CurC = numch+1 then CurC := 1
              end;

          #13: done_ := true;
          else
               for i := 1 to numch do
                   if upcase(tempkey) = c[i].text[2] then
                                      begin
                                      CurC := i;
                                      done_ := true;
                                      end;

          end;
       if OldC <> CurC then
         begin
         textcolor(abarcolor);
         textbackground(0);

         moveX ( - length(c[oldc].text)  );

         write(c[oldc].text);

         textbackground(bgc);
         textcolor(fgc);

         movex ( -length(c[oldc].text)+c[curc].ofs-c[oldc].ofs );

         write(c[curc].text);
         end;

       OldC := CurC
       end;
    until done_;

    textbackground(0);

    Run := CurC;

    end

   else

    begin
    incr := 0;
    last := 1;
    done_ := false;

    for i := 1 to length(comstr) do
     if comstr[i] = ' ' then
        begin
        inc(incr);
        c[incr].text := copy(comstr, last, i-last);
        c[incr].text := '['+c[incr].text[1]+']'+copy(c[incr].text,2,ord(c[incr].text[0])-1)+' ';
        last := i+1;
        end;
    For i := 1 to numch do write(c[i].text);
    write('-> ');
    repeat
        begin
        tempkey := upcase(readkey(e));
        for i := 1 to numch do
            begin
            if tempkey = c[i].text[2] then begin done_ := true; oldc := i;end
            end;
        end;
    until done_;
    write(c[oldc].text[2] + copy(c[oldc].text,4,length(c[oldc].text)-4));
    run:=oldc;
    end;
   end;

destructor IBSelObj.done; begin end;

end.
