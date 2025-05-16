unit WnewCfg;

{$O+,F+,D-}

interface

var pathtofile: string;

procedure configure;

implementation

uses dos,crt,etc;

type CfgInfoType = record
      ProgId        : array[1..8] of char;
      Version       : Word;
      Revision      : Char;

   { User Config Starts Here }

      UseCfgColors  : Boolean;
      UsePages      : Boolean;
      ClearScr      : Boolean;
      Wide          : Boolean;
      ShowBrag      : Boolean;
      UseStatusLine : Boolean;
      Ask           : Boolean;
      NoAnsiAsk     : Boolean;
      ShowMsgs      : Boolean;
      ShowFiles     : Boolean;
      AllowAbort    : Boolean;
      ShowDetPer    : Boolean;
      end;

const ESCAPE        : array[1..4] of char = 'здды';


Var CfgInfo       : CfgInfoType;
    whatsnewfile  : file;
    offs          : longint;
    bffr          : array[1..512] of char;
    badfile       : boolean;

function YesRNo(b:boolean): string;
  begin
  if b=true then YesRno := 'Yes' else YesRno := 'No';
  end;

procedure Open_file;
  begin
  {$I-}
  assign(whatsnewfile,pathtofile);
  reset(whatsnewfile,1);
  {$I+}
  if ioresult <> 0 then badfile := true;
  if IoResult <> 0 then writeln('Error ',ioresult,' Opening ',pathtofile);
  end;

procedure seek_file;
  var subbffr: array[1..4] of char;
      a      : integer;
      found  : boolean;

  begin
  found := false;
  offs := filesize(whatsnewfile);
  write('Searching ',upcasestr(pathtofile));
  repeat
     begin
     dec(offs,sizeof(bffr));

     write('.');

     seek(whatsnewfile,offs);
     blockread(whatsnewfile,bffr,sizeof(bffr));

     a:=0;
     repeat
       begin
       inc(a);
       subbffr[1]:=bffr[a];
       subbffr[2]:=bffr[a+1];
       subbffr[3]:=bffr[a+2];
       subbffr[4]:=bffr[a+3];

       if (subbffr[1]='з') and (subbffr[2]='д') and (subbffr[4]='ы')
         then
         begin
         offs:=offs+a-1;
         found := true;
         end;
       end;
     until found or (a=sizeof(bffr)-3);

     if offs < 1024 then
       begin
       badfile := true;
       writeln;
       writeln('Escape code not found');
       exit;
       end;
     end;
  until found;

  inc(offs,4);
  writeln;
  end;
 
procedure read_data;
  begin
  seek(whatsnewfile,offs);
  blockread(whatsnewfile,CfgInfo,sizeof(CfgInfo));
  end;

procedure Writefile;
  begin
  seek(whatsnewfile,offs);
  blockwrite(whatsnewfile,CfgInfo,sizeof(CfgInfo));
  end;

procedure Display_Data;
  begin
  textcolor(white);textbackground(blue);
  write(' CURRENT SETTINGS ');clreol;
  textbackground(black);

  Writeln;
  showmc('A');
  textcolor(lightgray);Write('         Use Colors Defined in CONFIG.Sl2: ');
  textcolor(lightcyan);Writeln(yesrno(cfginfo.usecfgcolors));

  showmc('B');
  textcolor(lightgray);Write('       Use Multiple Pages w/ More prompts: ');
  textcolor(lightcyan);writeln(yesrno(cfginfo.usepages));

  if not cfginfo.usepages then Cfginfo.clearscr := false;

  if cfginfo.usepages then
    begin
    showmc('C');
    textcolor(lightgray);write('          Clear screen before each screen: ');
    textcolor(lightcyan);write(yesrno(cfginfo.clearscr));
    end;
   writeln;

  showmc('D');
  textcolor(lightgray);write('Use wide display (no sub/dir description): ');
  textcolor(lightcyan);writeln(yesrno(cfginfo.wide));

  showmc('E');
  textcolor(lightgray);write('                        Show "Brag Line" : ');
  textcolor(lightcyan);writeln(yesrno(cfginfo.showbrag));

  showmc('F');
  textcolor(lightgray);write('        Use local Status line on 25th row: ');
  textcolor(lightcyan);writeln(yesrno(cfginfo.usestatusline));

  showmc('G');
  textcolor(lightgray);write('  Ask if the user wants to see what''s new: ');
  textcolor(lightcyan);writeln(yesrno(cfginfo.ask));

  if cfginfo.ask then
    begin
    showmc('H');
    Textcolor(lightgray);write('           Force a non-ANSI style question: ');
    textcolor(lightcyan);write(yesrno(cfginfo.noansiask));
    end;
  writeln;

  Showmc('I');
  Textcolor(lightgray);write('                    Show Message Activity: ');
  Textcolor(lightcyan);writeln(yesrno(cfginfo.showmsgs));

  Showmc('J');
  Textcolor(lightgray);write('                       Show File Activity: ');
  Textcolor(lightcyan);writeln(yesrno(cfginfo.showfiles));

  Showmc('K');
  Textcolor(lightgray);write('                         Allow User Abort: ');
  textcolor(lightcyan);writeln(yesrno(cfginfo.allowabort));

  showmc('Q');
  textcolor(lightgray);writeln('Quit without saving changes');
  showmc('S');
  textcolor(lightgray);writeln('Quit and Save changes');


  end;

function AskOpt(q:string;b:byte): boolean;
  var a:byte;
  begin
  textcolor(lightgray);
  write(q);
  GetChoice(2,'Yes No',white,blue,lightcyan,a);
  if a=b then askopt := true else askopt:=false;
  writeln;
  end;


procedure configure;
var tempc: char;
    tempb: byte;
 begin
 filemode := 2;

 directvideo := false;

 ansi := true;

 badfile := false;

 open_file;
 if not badfile then seek_file;
 if badfile then
   begin
   Writeln('The WhatsNew Configuration Program Cannot Continue');
   Writeln('Check the following...');
   Writeln('       o Correct version of WHATSNEW.EXE ');
   writeln;
   writeln('       o That WHATSNEW.EXE has not been compressed');
   writeln('         with a utility such as LZEXE or PKLITE');
   writeln;
   writeln('       o That WHATSNEW.EXE is not corrupt');
   writeln;
   writeln('       o WHATSNEW.EXE exists in the current directory');
   writeln;
   halt(5);
   end;

 writeln('The WHATSNEW configuration program');
 writeln('    (c) copyright 1991 by Zak Smith all rights reserved');
 read_data;

 tempc:=#1;

 repeat
   begin
   display_data;
   textcolor(cyan);
   write('Your Choice: ');
   repeat  tempc:=upcase(readkey) until tempc in ['A'..'K','Q','S'];
   writeln;
   case tempc of
     'A': CfgInfo.UseCfgColors:=AskOpt('Use Colors Defined in CONFIG.SL2? ',1);

     'B': CfgInfo.UsePages:=askopt('Use the MORE prompt? ',1);

     'C': if CfgInfo.Usepages then
          cfginfo.clearscr:=askopt('Clear Screen before displaying array? ',1);

     'D': CfgInfo.Wide:=askopt('Use the abbreviated display? ',1);

     'E': CfgInfo.showbrag:=askopt('Display "Brag Line"? [Reg Versions Only] ',1);

     'F': Cfginfo.usestatusline:=askopt('Local Status Line of 25th row? ',1);

     'G': CfgInfo.Ask:=askopt('Ask if user wants to see what''s new? ',1);

     'H': if CfgInfo.Ask then
          cfginfo.noansiask:=askopt('Force non-ANSI style question? ',1);

     'I': Cfginfo.ShowMsgs:=AskOpt('Show Message Activity? ',1);

     'J': Cfginfo.ShowFiles:=AskOpt('Show File Activity? ',1);

     'K': Cfginfo.allowabort:=askopt('Allow User Abort? ',1);

    end;
   end;
 until tempc in ['Q','S'];

 if Tempc = 'S'then WriteFile;

 Close(whatsnewfile);
 end;

end.
