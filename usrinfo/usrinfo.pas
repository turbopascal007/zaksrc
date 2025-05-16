program USRINFO;

{$I+,D+,L+,R+,S+,V+}


Uses DOS, { Needed for Date and Time Functions   }
     CRT, { Needed for Color Variables           }
     ETC, { Needed for Interface/Editor Routines }
     SLDRIV;

{ ETC -                                                           }
{      Variables  - ANSI                                          }
{      Procedures - PR, Newline, ColorG, ColorG, PhoneEditor,     }
{                   Editor, Setup_Output, ShowMC,                 }
{                   GetChoice, Lowcase, CaseStr, ClearScreen      }

type
  computertype = (IBMXT,IBMAT,AMIGA,MAC,APPLE,TERMINAL,OTHER) ;
  sextype = (MALE,FEMALE);
  inforec = record
        loginname: string[25];
        realname : string[25];
        phonenum : string[10];
        yob      : string[4];
        baud     : string[9];
        sex      : sextype;
        computer : computertype;
        interests: string[240];
      end;

const
     logfilespec  = 'USRINFO.LOG';
     mailfilespec = 'USRMAIL.TXT';
     progname     = 'USRINFO';
     ver          = '1.0b';
     author       = 'Zak Smith';

var
   INFO      : inforec;
   tempstr   : string;
   logfile   : text;
   compstring: string[25];
   mailfile  : text;
   sexstr    : string[6];

Procedure parse_param_str;
 { uses format                                                 }
 { d:\path\usrinfo [Grahpicsmode] [User Name]                  }
   var
      tempparam1: char;
      tempparam2: string;
      i         : byte;
   begin
   if Paramstr(1) = '' then
      begin
      Writeln('USRINFO Graphics_Mode User Name');
      Writeln('usrinfo C Fred Flintstone');
      HALT(1);
      end;
   Tempparam2 := Paramstr(1);
   tempparam1 := upcase(tempparam2[1]);
   if TempParam1 <> 'N' then ANSI := True else ANSI := False;
   for i := 2 to 5 do
       begin
       if length(paramstr(i)) <> 0 then info.loginname := info.loginname + paramstr(i) + ' ';
       end;
   end;

procedure title;
   begin
   colorFG(lightcyan);colorBG(black);
   ClearScreen;
   Newline;
   PR(PROGNAME);
   colorFG(Cyan);

 {  PR(' by '+Author+' version '+ver); }
   PR(' version '+ver);

   newline;
   newline;
   end;

procedure get_realname;
    begin
    tempstr := '';
    colorFG(lightgray);
    PR('Your Real Name ');
    editor(25, tempstr,'',white,blue);
    info.realname := tempstr;
    end;

procedure get_phonenum;
    begin
    tempstr := '';
    colorFG(lightgray);
    PR('Your Phone Number ');
    phoneeditor(tempstr,'',white,blue);
    {info.phonenum := copy(tempstr,1,10);}
    info.phonenum := tempstr;
    end;

procedure get_yob;

    var age, code: integer;
        agestr   : string;
        month, day, year, dayofweek: word;


    begin
    tempstr := '';
    colorFG(lightgray);
    PR('Year of Birth ');
    editor(4, tempstr,'19',white,blue);
    info.yob := tempstr;

    val(tempstr, age,code);
    getdate(year, month, day, dayofweek);
    age := year - age;

    case age of
          0..9 : agestr := 'Young';
         10..19: agestr := 'Teenager';
         20..29: agestr := 'Twenties';
         30..39: agestr := 'Thirties';
         40..49: agestr := 'Forties';
         50..59: agestr := 'Fiftiess';
         60..69: agestr := 'Sixties';
         70..79: agestr := 'Seventies';
         else    agestr := 'Lying About Your Age';
    end;
    PR(' '+AgeStr+', Eh?');

    end;

procedure get_baud;
    var
         done   : boolean;
        tempchar: char;
    begin
    colorFG(lightgray);
    newline; newline;
    write('Maximum Baud Rate Supported by Your Modem');
    newline;
    showmc('A'); PR('300');  newline;
    showmc('B'); PR('1200'); newline;
    showmc('C'); PR('2400'); newline;
    showmc('D'); PR('9600'); newline;
    colorFG(Lightgray);PR('Choice [A-D] -> ');
    done := false;
    repeat
      tempchar := {read} key;
      case upcase(tempchar) of
      'A':begin INFO.baud := '300' ;done := true;end;
      'B':begin info.baud := '1200';done := true;end;
      'C':begin info.baud := '2400';done := true;end;
      'D':begin info.baud := '9600';done := true;end;
      end;
    until done;
    colorFG(lightgreen);
    PR(info.baud);
    end;

procedure get_computer;
    var
       done   : boolean;
      tempchar: char;
    begin
    done := false;
    colorFG(lightgray);
    newline; newline;
    PR('Type of Computer You Own');
    newline;
    showmc('A'); PR('IBM XT Class - 8088, 8086 CPU');         newline;
    showmc('B'); PR('IBM AT Class - 80286, 80386, 80486 CPU');newline;
    showmc('C'); PR('Amiga');                                 newline;
    showmc('D'); PR('Macintosh');                             newline;
    showmc('E'); PR('Apple');                                 newline;
    showmc('F'); PR('Dumb Terminal');                         newline;
    showmc('G'); PR('Other - Not Listed');                    newline;
    newline;
    PR('Choice [A-G] -> ');
    repeat
    tempchar := {read} key;
    case upcase(tempchar) of
      'A':begin info.computer := IBMXT   ;done := true; end;
      'B':begin info.computer := IBMAT   ;done := true; end;
      'C':begin info.computer := AMIGA   ;done := true; end;
      'D':begin info.computer := MAC     ;done := true; end;
      'E':begin info.computer := APPLE   ;done := true; end;
      'F':begin info.computer := TERMINAL;done := true; end;
      'G':begin info.computer := OTHER   ;done := true; end;
      end;
    until done;
    ColorFG(lightgreen);
    PR(Upcase(Tempchar));
    end;


procedure Get_Sex;
   var sexval: byte;
   Begin
   newline; newline;
   ColorFG(Cyan);
   PR('Sex - ');
   GetChoice(2, 'Male Female',white,blue,lightgray,sexval);
   case SexVal of
     1: info.sex := male;
     2: info.sex := female;
   end;
   end;

procedure Get_Text;
 var t:boolean;
   begin
   newline;newline;
   colorFG(lightgray);

   PR('Tell me something about yourself.  Don''t say "I don''t know"');
   newline;

   PR('You will have 240 characters (about 3 lines).');newline;

   colorfg(white);

   t:=ansi;
   ansi:=false;

   Editor(239,tempstr,'',white,black);

   newline;

   ansi:=t;

   info.interests:=tempstr;

   end;


procedure get_info;
   begin
   title;
   get_realname;
{   get_phonenum; }
   newline;newline;
   get_yob;
   get_baud;
{   get_computer;}
{   Get_Sex; }                        { Heck, Sounds Good, Eh? }
   Get_Text;
   end;

procedure open_mail;
   begin
   assign(mailfile, mailfilespec);
   rewrite(mailfile);
   end;

procedure open_log;
   begin
   assign(logfile, logfilespec);
   {$I-}
   append(logfile);
   if IOResult <> 0 then rewrite(logfile);
   {$I+}
   end;

procedure open_files;
   begin
   open_log;
   open_mail;
   end;

function tab(i:integer):string;
   var A: integer;
       B: string;
   begin
   B := '';
   For A := 1 to I do B := B + ' ';
   tab := B;
   end;

procedure write_log;
   var
      year        : word;
      month       : word;
      day         : word;
      dayofweek   : word;
      hour        : word;
      min         : word;
      sec         : word;
      hundsec     : word;
      dayofweekstr: string[3];
   begin
   getdate(year, month, day,dayofweek);
   case dayofweek of
        1: dayofweekstr := 'Mon';
        2: dayofweekstr := 'Tue';
        3: dayofweekstr := 'Wed';
        4: dayofweekstr := 'Thu';
        5: dayofweekstr := 'Fri';
        6: dayofweekstr := 'Sat';
        0: dayofweekstr := 'Sun';
        end;
   gettime(hour, min, sec,hundsec);
   writeln(logfile, year:2,'-',month:2,'-',dayofweekSTR,'/',hour:2,':',min:2,':',sec:2,' ',
                     info.loginname:26 ,
                     info.realname:26 ,
                     {info.phonenum:12 ,} ' ':12,
                     info.yob:4,' ',info.baud:5,' ',{compstring:25}' ':25,' '{,SexStr:4});
   end;

procedure write_mail;
   begin
   writeln(mailfile, '\gyUser logged in  \lc',casestr(info.loginname));
   writeln(mailfile, '\gy     Real Name  \lc',casestr(info.realname));
{   writeln(mailfile, '\gy  Phone Number  \lc',info.phonenum); }
   writeln(mailfile, '\gy Year of Birth  \lc',info.yob);
   writeln(mailfile, '\gy Max Baud rate  \lc',info.baud);
{   writeln(mailfile, '\gy Computer type  \lc',compstring);}
{   Writeln(Mailfile, '\gy           Sex  \lc',SexStr);}
   Writeln(Mailfile);
   writeln(Mailfile, '\gyText\lc');
   Writeln(MailFile, '      ',info.interests);

   end;

procedure write_files;
   begin
   write_log;
   write_mail;
   end;

procedure close_log;
   begin
   close(logfile);
   end;

Procedure close_mail;
   begin
   close(mailfile);
   end;

procedure close_files;
   begin
   close_log;
   close_mail;
   end;

procedure convert_stuff;
   begin
   case info.computer of
     IBMAT   : compstring := 'IBM AT 80286/80386';
     IBMXT   : compstring := 'IBM XT 8088/8086';
     APPLE   : compstring := 'Apple';
     AMIGA   : compstring := 'Amiga';
     MAC     : compstring := 'Macintosh';
     TERMINAL: compstring := 'Dumb Term';
     OTHER   : compstring := 'Other';
   end;
   case info.sex of
    MALE  : sexstr := 'Male';
    FEMALE: sexstr := 'Female';
   end;
   end;

Procedure Show_Credit;
   Begin
   ColorFG(White);
   PR('USRINFO');
   ColorFG(LightGray);
   PR(' was in Turbo Pascal 6.0');
   end;

procedure Show_Info;
   var tempkey : char;
       done    : boolean;
       tempkey2: char;
       done2   : boolean;
   begin
   newline;
   ShowMC('A');
         colorfg(lightgray);PR('     Real Name  ');
         colorFG(lightcyan);PR(casestr(info.realname)); newline;
   ShowMC('B');
         ColorFG(lightgray);PR('  Phone Number  ');
         colorFG(lightcyan);PR(info.phonenum);newline;
   ShowMC('C');
         Colorfg(lightgray);PR(' Year of Birth  ');
         ColorFG(lightcyan);PR(info.yob);newline;
   ShowMC('D');
         Colorfg(lightgray);PR(' Max Baud rate  ');
         Colorfg(lightcyan);PR(info.baud);newline;
   ShowMC('E');
         Colorfg(lightgray);PR(' Computer type  ');
         ColorFG(lightcyan);PR(compstring);newline;
   ShowMC('F');
         ColorFG(lightgray);PR('           Sex  ');
         Colorfg(lightcyan);PR(SexStr);newline;

   ShowMC('G');
         Colorfg(lightgray);PR(' Text ');
         Colorfg(lightcyan);newline;
         PR('    '+info.interests[1]);newline;
         PR('    '+ info.interests[2]);newline;

   ColorFG(lightgray);
   PR('Is this correct? ');
   done := false;
   repeat
     begin
     tempkey := upcase(key);
     ColorFG(lightgreen);
     if (tempkey = 'Y') or (tempkey = 'N') then PR(Tempkey);
     if tempkey = 'Y' then done := true;
     if tempkey = 'N' then
        begin
        done2 := false;
        newline;
        ColorFG(lightgray);
        PR('Edit which field? ');
        ColorFG(lightgreen);
        {case}


        done := true;
        end;
     end;
   until done;
   end;

var x,y:byte;

begin
     x:=wherex;y:=wherey;
     if y=25 then y:=24;

     if Slactive then localonly;
     window(1,1,80,24);
     if slactive then localandremote;

     if slactive then localonly;
     gotoxy(x,y);
     if slactive then localandremote;

     directvideo := false;
     CapsOn := false;
     parse_param_str;            { parse name, graphics mode }
     setup_output;               { setup standard output, or Bios }
     get_info;                   { user enters junk }


     convert_stuff;              { converts computer type  and sex type }
                                 { to strings                           }

  {  Show_info;  }

     newline;
     ColorFG(lightgray);
     PR('Status... ');


     PR('Opening Files... ');
     open_files;                 { opens files.. }

     PR('Writing Files... ');
     write_files;                { writes files.. }

     PR('Closing Files... ');
     close_files;                { closes files.. }

     newline;

     Show_Credit;

     newline;

     x:=wherex;y:=wherey;

     if Slactive then localonly;
     window(1,1,80,25);
     if slactive then localandremote;

     if slactive then localonly;
     gotoxy(x,y);
     if slactive then localandremote;

end.
