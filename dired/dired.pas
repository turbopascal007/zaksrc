{ Dired (c) copyright 1991 by Zak Smith all rights reserved          }

Program DIRED;

Uses ExitErr, SlfLow, SlfHigh, Dos, Crt, Etc, FastWr;

{$M 32768,0,655360 } { Default Stack  }

{ Range Checking, enabled for debugging, also so that it generates an }
{ error message intead of producing wierd output                      }

{$R+,S+);

{ because of the design of this program, it will work with even more        }
{ speed if there is a disk cache running, or it will even be faster if      }
{ your disk controller has a built in cache.   It traverses the whole dir   }
{ tree (which only takes a few seconds for 200 files), and then it assigns  }
{ pointers to the data to an array. which is [1..N] where N is the number   }
{ of files in the directory.

{ Recursive alorithm for the binary tree file directory goes at       }
{ about 41 nodes per second.                                          }

{ has not been re-timed with error detection using ARG()              }

const
       version = '1.12';
       MaxAllowedRows = 75;
       MaxAllowedCols = 150;

       MaxDirs = 200;
       maxfiles = 5000;
       buffermax = MaxAllowedRows - 4;
       BaseY = 5;

       { BufferMax is maximum number of buffers that could ever be needed }
       { this is equal to the greatest amount of lines per screen minus 4 }

var
   ScrBase : pointer;
   ScrSize : longint;

   {  Vars for Files  }

   UserFile    : file;
   UserHdr     : UserHeader;
   UserGenHdr  : FileHeader;
   User        : UserType;

   CurDirFile  : file;
   CurDirHdr   : DirHeader;
   CurDirGenHdr: fileheader;
   CurDir      : dirtype;

   SetupFile   : file;
   SetupGenHdr : Fileheader;
   SetupHdr    : SetupHeader;
   Setup       : SetupData;

type
     FiledirType = record  { name and path of dirfiles.sl2 }
        Name: string[8];
        Desc: string[40];
        Path: string[60];
     end;

     fdtype = array[1..buffermax] of Dirtype;

     fptype = array[1..maxfiles] of longint;

     FDstype = array[1..maxdirs] of filedirtype;

     chartype = record
        c:char;
        a:byte;
        end;
     screentype = array[1..MaxAllowedRows,1..MaxAllowedCols] of chartype;

Var

    FastLoadFiles : boolean;                         { no screen update    }
                                                     { while scanning dir  }

    OrigTextMode  : word;                            { original text mode  }
    NewTextMode   : word;                            { new text mode       }

    buffersize    : integer;                         { buffersize parsed   }
                                                     { from command line,  }

    PathToConfig   : string;                         { path to config file }
    FileDirs       : ^FDsType;

    CurDirIndex    : integer;                        { current open dir    }
    NumOfDirs      : integer;                        { number of dirs      }

    Files          : ^FdType;                        { buffer of files     }
    CurFileIdx     : integer;                        { current file        }

    FilePtr        : ^fptype;                        { array of pointers   }

        { the FilePtr[1] would be a LongInt which }  { of actual record    }
        { is the actual record number in the file }  { numbers..           }

    LowFile        : integer;                       { first file in buffer }
    NumOfFiles     : integer;                       { number of files      }

    Screen         : ^ScreenType;

procedure Arg(Io: word; s: string);
   begin
   if Io <> 0 then
    begin
    textbackground(black);textcolor(lightred);
    clrscr;
    if NewTextMode <> OrigTextMode then TextMode(OrigTextMode);
    writeln('Error ',IoResult,': Program Terminated: ', s);
    normvideo;
    HALT(1);     { Stop Everything!  Full Reverse, Scotty! }
    end;
   end;

procedure ClimbTree_setup(rec:longint);
  var Right     : longint;
  begin

  if rec <> 0 then
    begin


    {$I-}
    Read_Data(SetupFile,DirSetupF,rec,Setup);
    {$I+}
    Arg(IoResult, 'Error Traversing Binary Structure in FILEDIR.SL2');

    right := Setup.leaf.right;

    if setup.leaf.left <> 0 then
      begin
      ClimbTree_Setup(setup.leaf.Left);
      {$I-}
      Read_Data(SetupFile,DirSetupF,rec,Setup);
      {$I+}
      Arg(IoResult, 'Error Traversing Binary Structure in FILEDIR.SL2');
      end;

    Inc(NumOfDirs);
    if NumofDirs > MaxDirs then Arg(500,'Too Many File Directories - Contact Author');

    FileDirs^[NumOfDirs].name := Setup.Name;
    FileDirs^[NumOfDirs].path := Setup.Path;
    FileDirs^[NumOfDirs].Desc := Setup.Descrip;

    if Right <> 0 then ClimbTree_Setup(Right);

    end;

  end;


procedure Get_Dir_Names;
  var N      : longint;
  begin
  NumOfDirs := 0;
  N := SetupHdr.Root.Treeroot;

  ClimbTree_Setup(n);
  if numofdirs = 0 then Arg(1, 'No File Directories!');
  end;



procedure Choose_Dir(var Donehere: boolean);

  var
      b     : string;
      w     : byte;
      maxnum: integer;
      picked: boolean;
      k     : char;
      lowdir: integer;
      olddir: integer;
      oldscr: integer;
      scridx: integer;
      numlin: integer;
      tdone : boolean;

  Procedure Init;
   var w,a:word;

   begin
   numlin := Buffersize + 2;

   textbackground(black);
   textcolor(green);
   clrscr;

   gotoXY(1,1);pr(#213);for w:=2 to 13 do pr(#205);pr(#184);

   for W:= 2 to numlin + 1 do begin gotoxy(1,W); PR(#179) end;
   for W:= 2 to numlin + 1 do begin gotoxy(14,W); PR(#179) end;

   gotoXY(1,numlin + 2);pr(#212);for w:=2 to 13 do pr(#205);pr(#190);

   textcolor(cyan);
   if numofdirs > numlin then maxnum := numlin else maxnum := numofdirs;

   for W:=1 to maxnum do
     begin
     gotoxy(4,1+W); pr(casestr(FileDirs^[W].name));
     end;

   textcolor(blue);
   gotoxy(21, 1);for w:=21 to 79 do write(#196);
   gotoxy(21, 5);write(#196,#196,#196,' ');textcolor(red);
   write('Version ', Version,' ');textcolor(blue);

   for w:=21+3+(length(version))+2+8 to 79 do write(#196);

   textcolor(lightcyan);
   gotoxy(22, 2);write(' ÒÄ¿  Ò  ÒÄ·   ÒÄ·   ÒÄ¿ ');
   gotoxy(22, 3);write(' º ³  º  ÇÂ½   ÇÄ    º ³ ');
   gotoxy(22, 4);write(' ÐÄÙ  Ð  Ð \   ÐÄ½   ÐÄÙ ');

   textcolor(cyan)     ;gotoxy(53, 2);write('The File Directory Editor');
   textcolor(cyan)     ;gotoxy(53, 3);write('        for the');
   textcolor(cyan)     ;gotoxy(53, 4);write(' Searchlight BBS System');

   textcolor(red);
   gotoxy(21, 7);for w:=21 to 79 do write(#196);
   gotoxy(21, 9);for w:=21 to 79 do write(#196);

   Textcolor(yellow);gotoxy(21, 8);
   write(' DirEd (C) Copyright 1992 by Zak Smith all rights reserved');

   textcolor(green);
   gotoxy(21, 11);for a:=21 to 79 do write(#196);

   gotoxy(21, 19);for a:=21 to 79 do write(#196);

   textcolor(lightcyan);gotoxy(22, 12);write('Function Keys');

   gotoxy(23, 13 );textcolor(blue);write('[');textcolor(yellow);
                       write('Home');textcolor(blue);write(']       ');
                       textcolor(cyan);write('Go to begining of listing');

   gotoxy(23, 14 );textcolor(blue);write('[');textcolor(yellow);
                       write('End');textcolor(blue);write(']        ');
                       textcolor(cyan);write('Go to end of listing');

   gotoxy(23, 15 );textcolor(blue);write('[');textcolor(yellow);
                       write('Up Arrow');textcolor(blue);write(']   ');
                       textcolor(cyan);write('Scroll up one line');

   gotoxy(23, 16 );textcolor(blue);write('[');textcolor(yellow);
                       write('Down Arrow');textcolor(blue);write('] ');
                       textcolor(cyan);write('Scroll down one line');

   gotoxy(23, 17 );textcolor(blue);write('[');textcolor(yellow);
                       write('Enter');textcolor(blue);write(']      ');
                       textcolor(cyan);write('Opens current directory for viewing, editing');

   gotoxy(23, 18 );textcolor(blue);write('[');textcolor(yellow);
                       write('Escape');textcolor(blue);write(']     ');
                       textcolor(cyan);write('Quits Dired');


   textcolor(blue);

   gotoxy(21, 21);for a:=21 to 79 do write(#196);
   gotoxy(21, 25);for a:=21 to 79 do write(#196);

   gotoxy(22, 22);textcolor(lightgray);

   {
   write('Command Line Parameters (optional): ');
   textcolor(white);gotoxy(23, 23);
   write('DIRED /p<path>          /l<lines>        /B[ios]');gotoxy(22, 24);
   write('          to Config.Sl2     per screen      screen writes');
   }

   textcolor(white);write(BufferSize+4);
   textcolor(lightgray);write(' Line Video, ');
   textcolor(white);write(int2comma(memavail,6));
   textcolor(lightgray);write('b free ram, ');

   textcolor(white);write(NumOfDirs);
   textcolor(lightgray);write(' Subboards Found');



   lowdir := 1;
   CurDirIndex := 1;
   ScrIdx := 1;
   OldScr := 1;
   OldDir := 1;
   DoneHere := False;
   Picked := False;
   tdone := false;

   textbackground(Blue);textcolor(White);
      GotoXY(3,ScrIdx+1);PR(' '+CaseStr(FileDirs^[CurDirIndex].Name)+ltab(ord(filedirs^[CurDirIndex].name[0]),9));

   cursoroff;

   end;

  procedure status;
   begin
   textbackground(black);

   gotoxy(22,24);textcolor(white);write('"');
   textcolor(cyan);write(FileDirs^[CurDirIndex].Desc);
   textcolor(white);write('"');clreol;
   end;


  procedure ScrollDirs(n: integer);
    var a: integer;
    begin
    textcolor(cyan);
    textbackground(black);
    for a:= 1 to maxnum do
     begin
     gotoxy(4,1+a );  { 2..24 }
     write(casestr(FileDirs^[n+a-1].name)+ltab(ord(FileDirs^[n+a-1].name[0]),9));
     end;
    end;

  begin

  Init;

  status;

  repeat
     begin
     repeat until keypressed;
     k := readkey;

     textbackground(Black);textcolor(cyan);
     GotoXY(3,OldScr+1);PR(' '+CaseStr(FileDirs^[OldDir].Name)+ltab(ord(filedirs^[oldDir].name[0]),9));

     case upcase(K) of
      #27: begin picked := true;donehere := true end;
       #0:
           begin
           case Readkey of
   { home }   #71: if curdirindex > 1 then
                    begin
                    curdirindex := 1;
                    scridx := 1;
                    lowdir := 1;
                    scrolldirs(lowdir);
                    end;
   { up   }   #72: if curdirindex > 1 then
                    begin
                    dec(curdirindex);
                    dec(scridx);
                    if ScrIdx < 1 then
                        begin
                        ScrIdx := 1;
                        dec(lowdir);
                        scrolldirs(lowdir);
                        end;
                    end;
   { down }   #80: if curdirindex < numofdirs then
                    begin
                    inc(curdirindex);
                    inc(scridx);
                    if ScrIdx > MaxNum then
                        begin
                        ScrIdx := maxnum;
                        inc(lowdir);
                        Scrolldirs(lowdir);
                        end;
                    end;
   { end  }   #79: if curdirindex < numofdirs then
                    begin
                    if numofdirs > maxnum then lowdir := numofdirs - maxnum+1;
                    curdirindex := numofdirs;
                    scridx := maxnum;
                    scrolldirs(lowdir);
                    end;
             end; { case readkey }
           end;  {begin }

       #13: picked := true;

       end;     {case k of }


     textbackground(Blue);textcolor(White);
     GotoXY(3,ScrIdx+1);write(' '+CaseStr(FileDirs^[CurDirIndex].Name)+ltab(ord(filedirs^[CurDirIndex].name[0]),9));

     status;

     OldDir := CurDirIndex;
     OldScr := ScrIdx;

     end; { repeat }

  until picked;
  cursoron;
  end;

procedure Status(s:string);
  var x,y,a:integer;
  begin
  x:=wherex;y:=wherey;
  gotoxy(20,1);
  textcolor(green);write('[');
  textcolor(lightgray);
  write(' ',s,' ');
  textcolor(green);write(']');
  for a:= Columns-WhereX downto 1 do write(#196);
  end;


procedure ErrorBTF;
  begin
  Arg(IoResult, 'Error Traversing Binary Structure in '+FileDirs^[CurDirIndex].name );
  end;

procedure StatusBTF;
  begin
  if Not FastLoadFiles then
  Status('Scanning Directory '+CaseStr(FileDirs^[CurDirIndex].name)+
                  ' - '+ToStr(NumOfFiles));
  end;

procedure ClimbTree_Dir(rec:longint);
  var Right     : longint;
  begin
    {$I-}
    Read_Data(CurDirFile,DirF,rec,CurDir);
    {$I+}
    ErrorBTF;

    Right := CurDir.leaf.Right;

    if curdir.leaf.left <> 0 then
      begin
      ClimbTree_Dir(curdir.leaf.left);
      end;

    Inc(NumOfFiles);
    FilePtr^[NumOfFiles] := rec;

    if (numoffiles mod 10)=0 then StatusBTF;

    if Right <> 0 then ClimbTree_Dir(Right);

  end;



procedure ScanData;
  begin
  numoffiles := 0;
  If FastLoadFiles then Status('Scanning Directory '+CaseStr(FileDirs^[CurDirIndex].name));
  ClimbTree_Dir(curdirhdr.root.treeroot);
  statusBTF;
  end;


procedure Help_File;
  const numl: byte=6;

  var a   : integer;
      k   : char;
  begin
  for a:= BaseY to BaseY + numl do
    begin
    gotoxy(1,A);clreol;
    end;
  gotoxy(1,basey+numl+1);textcolor(green);for a:=1 to 69 do write(#196);

  write('[');textcolor(lightgray);write(' Key... ');textcolor(green);
  write(']Ä');

  gotoxy(2, baseY   );textcolor(lightcyan);write('Function Keys');

  gotoxy(3, baseY+1 );textcolor(blue);write('[');textcolor(yellow);
                      write('Home');textcolor(blue);write(']       ');
                      textcolor(cyan);write('Go to begining of listing');

  gotoxy(3, baseY+2 );textcolor(blue);write('[');textcolor(yellow);
                      write('End');textcolor(blue);write(']        ');
                      textcolor(cyan);write('Go to end of listing');

  gotoxy(3, baseY+3 );textcolor(blue);write('[');textcolor(yellow);
                      write('Up Arrow');textcolor(blue);write(']   ');
                      textcolor(cyan);write('Scroll up one line');

  gotoxy(3, baseY+4 );textcolor(blue);write('[');textcolor(yellow);
                      write('Down Arrow');textcolor(blue);write('] ');
                      textcolor(cyan);write('Scroll down one line');

  gotoxy(43,baseY+1 );textcolor(blue);write('[');textcolor(yellow);
                      write('Page Up');textcolor(blue);write(']    ');
                      textcolor(cyan);write('Scroll up one page');

  gotoxy(43,baseY+2 );textcolor(blue);write('[');textcolor(yellow);
                      write('Page Down');textcolor(blue);write(']  ');
                      textcolor(cyan);write('Scroll down one page');


  gotoxy(43,baseY+3 );textcolor(blue);write('[');textcolor(yellow);
                      write('Enter');textcolor(blue);write(']      ');
                      textcolor(cyan);write('Edit current file');

  gotoxy(43,baseY+4 );textcolor(blue);write('[');textcolor(yellow);
                      write('Escape');textcolor(blue);write(']     ');
                      textcolor(cyan);write('Exit to Directory listing');

  gotoxy(3, baseY+5 );textcolor(blue);write('[');textcolor(yellow);
                      write('Alt-C');textcolor(blue);write(']      ');
                      textcolor(cyan);write('Clear file''s password');

  gotoxy(43, baseY+5 );textcolor(blue);write('[');textcolor(yellow);
                      write('Alt-E');textcolor(blue);write(']');
                      textcolor(lightgray);write('/');textcolor(blue);
                      write('[');textcolor(yellow);write('F2');
                      textcolor(blue);write('] ');
                      textcolor(cyan);write('Extended file info');

  gotoxy(3, baseY+6 );textcolor(blue);write('[');textcolor(yellow);
                      write('Alt-P');textcolor(blue);write(']      ');
                      textcolor(cyan);write('Modify Password');

  k := readkey;
  for a:= basey to basey + numl+1 do
     begin
     gotoxy(1,a);clreol;
     end;
  end;

procedure SaveScreen(var p:pointer);
  begin
  getmem(p,scrsize);
  move(scrbase,p,scrsize);
  end;

procedure restorescreen(var p:pointer);
  begin
  move(p,scrbase,scrsize);
  {freemem(p,scrsize);}
  dispose(p);
  end;

Procedure Proc_Dir;
   var  k        : char;
        B        : integer;
        donehere : boolean;
        oldscr   : integer;
        scridx   : integer;
        selected : boolean;
        temp     : dirtype;
        maxnum   : integer;
        doserr   : integer;
        p        : pointer;

   const  pffile = 4;                   { file }
          pfdot  = 12+pffile;           { extend dot }
          pfofl  = 13+pffile;           { offline }
          pfdesc = 19;                  { description }
          pfpw   = 13+pffile;           { Password }

   procedure showlong(n: word);
    begin

    if directvideo then
      begin
      fastwrite(0,1,blue,'[');
      fastwrite(1,1,cyan,CaseStr(Files^[n].name) + lTab(ord(Files^[n].name[0]),12));
      fastwrite(13,1,blue,']');

      if boolean(files^[n].edescrip[1][0]) then
        begin
        fastwrite(17,1,lightgray,files^[n].edescrip[1]+ltab(length(files^[n].edescrip[1]),60));
        fastwrite(17,2,lightgray,files^[n].edescrip[2]+ltab(length(files^[n].edescrip[2]),60));
        end
      else
        begin
        fastwrite(17,1,lightgray,ltab(0,60));
        fastwrite(17,2,lightgray,ltab(0,60));
        end;
      end
    else
      begin
      GotoXY(1,2);
      TextColor(blue);write('[');
      TextColor(Cyan);write(CaseStr(Files^[n].name) + lTab(ord(Files^[n].name[0]),12));
      TextColor(Blue);Write(']');

      if Length(Files^[n].EDescrip[1]) > 0 then
       begin
       GotoXY(18, 2);TextColor(LightGray);
          Write(Files^[n].EDescrip[1]);ClrEol;
       GotoXY(18, 3);
          Write(Files^[n].EDescrip[2]);ClrEol;
       end
      else
       begin
       GotoXY(18,2);ClrEol;
       GotoXY(18,3);ClrEol;
       end;
      end;
    end;

   procedure putfile(n: word;bg:byte);
    begin
    if DirectVideo then
     begin
     fastwrite(pffile-1-1,basey-1+n-1,white+$10*bg,' '+casestr(files^[n].name)+ltab(length(files^[n].name),12));

     if (files^[n].passwd[1] <> 0) or
        (files^[n].passwd[2] <> 0) or
        (files^[n].passwd[3] <> 0) then
        fastwrite(pfpw-1,basey-2+n,red+$10*bg,'+')
     else
      if files^[n].offline then fastwrite(pfofl-1,basey-2+n,red+$10*bg,'*')
      else fastwrite(pfofl-1,basey-2+n,red+$10*bg,' ');

     if files^[n].edescrip[1] <> '' then
      fastwrite(pfdot-1,basey-2+n,cyan+$10*bg,#249)
     else
      fastwrite(pfdot-1,basey-2+n,cyan+$10*bg,#32);

     fastwrite(pfdesc-2,basey-2+n,lightgray + $10*bg,' '+files^[n].descrip);

     fastwrite(pfdesc-2+length(files^[n].descrip)+1,basey-2+n,lightgray+$10*bg,ltab(length(files^[n].descrip),62));

     end
    else
     begin
     gotoxy(pffile-1, baseY-1+n);
     textbackground(bg);
     textcolor(white);
     write(' ',casestr(Files^[n].name));clreol;

     textcolor(red);
     if (files^[n].passwd[1] <> 0) and
        (files^[n].passwd[2] <> 0) and
        (files^[n].passwd[3] <> 0) then
        begin
        gotoxy(pfpw, basey-1+n);
        write('+');
        end;

    if files^[n].offline then
      begin
      gotoxy(pfofl, basey-1+n);
      write('*');
      end;

    if Files^[n].Edescrip[1] <> '' then
       begin
       gotoxy(pfdot,baseY-1+n);
       textcolor(cyan);
       write(#249);
       end;

    textcolor(lightgray);
    gotoxy(pfdesc,basey-1+n);
    write(files^[n].Descrip);
    textbackground(black);
    end;

   end;

   procedure ScrUp;
    begin
    GotoXY(1, BaseY);
    InsLine;
    if directvideo then Putfile(1,blue) else PutFile(1,black);
    end;

   procedure ScrDn;
    begin
    gotoxy(1, BaseY);
    DelLine;
    GotoXY(1,BaseY+ (Buffersize-1) );
    if directvideo then Putfile(BufferSize,blue) else PutFile(buffersize,black);
    end;

   Procedure ScrollFiles;
        var a: integer;
        begin
        for a:=1 to maxnum do
          begin
          gotoxy(1,BaseY-1+a);
          putfile(a,black);
          end;
       end;

    procedure select(a: word);
       begin
       if DirectVideo then
         begin
{         TextBackGround(Blue);}
         PutFile(a,blue);
         end
       else
         begin
         gotoxy(1,BaseY-1 +a);
         textbackground(black);
         textcolor(white);
         write('->');
         end;
       end;

    procedure Unselect(a: integer);
       begin
       if DirectVideo then
         begin
{         TextBackGround(Black);}
         putfile(a,black);
         end
       else
         begin
         gotoxy(1,BaseY-1 +a);
         textbackground(black);
         write('  ');
         end;
       end;

   procedure Edit_Short;
       var Stringone, Stringtwo: string;
       begin
       if directvideo then
        begin
        gotoxy(pfdesc-1+40,basey+scridx-1);
        textcolor(black);clreol;
        end;

       GotoXY(pfdesc-1, BaseY+ScrIdx-1);
       Stringtwo := Files^[ScrIdx].Descrip;
       CursorOn;
       Editor(40, Stringone, stringtwo,white,blue);
       files^[scridx].descrip := stringone;
       CursorOff;

       gotoxy(pfdesc-1, wherey);textcolor(lightgray);write(' ');
       write(files^[scridx].descrip);clreol;
       end;

   procedure Edit_long;
       var Stringone, Stringtwo: string;
       begin
       GotoXY(17,2);
       Stringtwo := files^[ScrIdx].EDescrip[1];
       CursorOn;
       Editor(60, Stringone, stringtwo,white,blue);
       CursorOff;
       Textcolor(lightgray);gotoxy(17, 2);
       files^[ScrIdx].EDescrip[1] := stringone;
       Write(' ',Files^[ScrIdx].EDescrip[1]);clreol;

       if Files^[ScrIdx].EDescrip[1] <> '' then
        begin
        GotoXY(17,3);
        Stringtwo := Files^[ScrIdx].Edescrip[2];
        CursorOn;
        Editor(60, Stringone, stringtwo,white,blue);
        CursorOff;
        Textcolor(lightgray);gotoxy(17,3);
        Files^[ScrIdx].EDescrip[2] := stringone;
        Write(' ',Files^[ScrIdx].Edescrip[2]);clreol;
        end
       else { if descrip[1] DOES = '' }
         begin
         Files^[ScrIdx].EDescrip[2] := '';
         gotoxy(17, 3);clreol;
         end;
       if directvideo then putfile(scridx,blue)
        else putfile(scridx,black);
       end;

   procedure Show_Extended(n: integer);
       var k    : char;
           name : string[25];
       begin
       gotoxy(18,2);clreol;
       gotoxy(18,3);clreol;

       name := '<deleted user>';

       if Files^[n].id <> 0 then
        begin

        User_Info(files^[n].id,user);

        name := user.name;
        end;

       gotoxy(18, 2);textcolor(lightgray);write('Uploaded by ');
       textcolor(white);write(name);textcolor(lightgray);
       write(' on ');textcolor(white);

       write(Files^[n].date.month);textcolor(lightgray);write('-');
       textcolor(white);write(Files^[n].date.day);textcolor(lightgray);
       write('-');
       textcolor(white);write(Files^[n].date.year+1900);

       gotoxy(18,3);textcolor(lightgray);write('File Size ');
       textcolor(white);write(Files^[n].length*128);

       textcolor(lightgray);
       Write(' Downloaded ');textcolor(white);write(Files^[n].times);
       textcolor(lightgray);write(' times');

       gotoxy(74,2);textcolor(blue);write('[');textcolor(yellow);
       write(' Key ');textcolor(blue);write(']');

       k := readkey;
       gotoxy(1,2);clreol;

       showlong(scridx);
       end;

   procedure NewPwd;
     var s:string;
         b:byte;
         t,t2:pwtype;

     begin

     Status('Modifying Password of File '+CaseStr(Files^[ScrIdx].Name));

     textbackground(black);

     gotoxy(18,2);clreol;
     gotoxy(18,3);clreol;

     b:=2;

     if boolean(files^[scridx].passwd[1]) or
        boolean(files^[scridx].passwd[2]) or
        boolean(files^[scridx].passwd[3]) then

      begin
      gotoxy(18,2);
      textcolor(white);
      write('Password Exists. Replace? ');

      { GetChoice(numofchoices:byte; Choices:string;
       fgc,bgc,oc:byte; var Reply: byte);
      }

      GetChoice(2,'No Yes',white,blue,cyan,b);

      gotoxy(18,2);clreol;

      end;

     if boolean(b-1) then
       begin
       gotoxy(18,2);
       textcolor(lightgray);
       write('  Enter Password: ');

       cursoron;
       editor(25,s,'',white,blue);
       cursoroff;

       if length(s)>0 then
         begin
         longhash(s,t);

         gotoxy(18,3);
         textcolor(lightgray);
         write('Confirm Password: ');
         cursoron;
         editor(25,s,'',white,blue);
         cursoroff;
         if length(s)>0 then
           begin
           longhash(s,t2);
           if (t[1]=t2[1]) and
              (t[2]=t2[2]) and
              (t[3]=t2[3]) then
              begin
              move(t2[1],files^[ScrIdx].passwd[1],3);
              Write_Data(CurDirFile,DirF,FilePtr^[CurFileIdx], Files^[ScrIdx]);
              end;
           end;
         end;
       end;

     status('Viewing Files [1..'+ToStr(NumOfFiles)+']' );

     if directvideo then Putfile(ScrIdx,blue)
      else putfile(scridx,black);

     end;


   var a:word;

   begin
   CursorOff;

   textbackground(black);
   clrscr;
   textcolor(Green);
   GotoXY(1,1);pr('[');textcolor(Cyan);
   PR(casestr(FileDirs^[CurDirIndex].name) + lTab(ord(FileDirs^[CurDirIndex].name[0]),7));
   TextColor(Green);PR(']');
   for a:=1 to 70 do write(#196);
   Gotoxy(1,baseY-1);
   for a:=1 to 59 do write(#196);write('[');
   textcolor(yellow);write('F1');
   textcolor(lightgray);write(' - Help Screen');
   textcolor(green);write(']ÄÄÄ');

   Init_VarData(CurDirFile,DirF,FileDirs^[CurDirIndex].path,
      filedirs^[curdirindex].name,CurDirGenHdr,CurDirHdr);

   ScanData;

   selected := false;
   lowFile := 1;
   CurFileIdx :=1;
   donehere := false;
   scridx:=1;
   oldScr:=1;

   If NumOfFiles = 0 then
       begin
       gotoxy(5,2);
       textcolor(lightcyan);
       write('No ');textcolor(cyan);write('files in this directory! ');
       write('Press any key to continue');
       k := readkey;
       Exit;
       end;

   if numoffiles > buffersize then maxnum := buffersize
     else maxnum := numoffiles;

   for a:=1 to maxnum do Read_Data(CurDirFile, DirF, FilePtr^[a], Files^[a]);

   scrollfiles;
   select(1);
   status('Viewing Files [1..'+ToStr(NumOfFiles)+']' );
   ShowLong(ScrIdx);

    repeat
      begin
      repeat until keypressed;
      k := readkey;
      UnSelect(OldScr);
      case k of

   {Ntr} #13: selected := true;
   {Esc} #27: donehere := true;
         #0 :
            case readkey of
   { F1   }   #59:
                   begin
                   Help_file;
                   scrollfiles
                   end;
   (*
   { ALT-D }  #32: begin
                   SaveScreen(p);
                   cursoron;
                   textbackground(black);
                   textcolor(cyan);
                   clrscr;
                   Writeln('Swapping to EMS/XMS/Disk... ');
                {   PutEnv('PROMPT=[DirEd] '+getenv('PROMPT'));}
                   doserr:=do_exec(getenv('COMSPEC'),'',use_file{USE_EMS or USE_XMS or USE_FILE or EMS_FIRST}, $FFFF, false);
                   cursoroff;
                   RestoreScreen(p);
                   end;
   *)

   { ALT-E }  #18,#60:
                   begin
                   Show_Extended(ScrIdx);
                   end;

   { ALT-P }  #25: NewPwd;

   { ALT-C }  #46:
                   begin
                   Files^[ScrIdx].passwd[1] := 0;
                   Files^[ScrIdx].passwd[2] := 0;
                   Files^[ScrIdx].passwd[3] := 0;

                   Write_Data(CurDirFile,DirF,FilePtr^[CurFileIdx],Files^[ScrIdx]);

                   if directvideo then putfile(ScrIdx,blue)
                     else putfile(scridx,black);

                   end;
   { PGDN }   #81: if curfileidx<numoffiles then
                   begin
                   if CurFileIdx + Maxnum +(Maxnum-ScrIdx) < NumOfFiles then
                     begin
                     Lowfile := Lowfile + Maxnum;
                     CurFileIdx := LowFile + ScrIdx;
                     end
                   else
                       begin
                       CurFileIdx := NumOfFiles;
                       ScrIdx := MaxNum;
                       if NumOfFiles = Maxnum then
                         LowFile := 1
                       else
                         LowFile := NumOfFiles - MaxNum;
                       end;

                   For A:=1 to Maxnum do Read_Data(CurDirFile, DirF,
                        FilePtr^[LowFile+A-1], Files^[A]);
                   ScrollFiles;
                   end;

   { PGUP }   #73: if curfileidx>1 then
                   begin
                   If CurFileIdx-Maxnum-ScrIdx > 0 then
                     begin
                     LowFile := LowFile - Maxnum;
                     CurFileIdx := LowFile + ScrIdx - 1 ;
                     end
                   else
                     begin
                     CurFileIdx := 1;
                     ScrIdx := 1;
                     LowFile := 1;
                     end;
                   For A:=1 to Maxnum do
                     Read_Data(CurDirFile, DirF, FilePtr^[LowFile+A-1], Files^[A]);

                   ScrollFiles;
                   end;

   { HOME }   #71: if CurFileIdx > 1 then
                     begin
                     LowFile := 1;
                     ScrIdx := 1;
                     CurFileIdx := 1;
                     For A:=1 to MaxNum do Read_Data(CurDirFile, DirF, fileptr^[A], Files^[A]);
                     ScrollFiles;
                     end;

   { END }    #79: If CurFileIdx < NumOfFiles then
                    begin

                    CurFileIdx := NumOfFiles;
                    ScrIdx := MaxNum;

                    if MaxNum >= NumOfFiles then LowFile := 1
                    else LowFile := NumOfFiles - MaxNum + 1;

                    For A:=1 to Maxnum do
                      Read_Data(CurDirFile, Dirf, fileptr^[LowFile+A-1], Files^[A]);

                    ScrollFiles;
                    end;
   { DOWN }   #80:
                   if CurFileIdx < NumOfFiles then
                    begin
                    Inc(CurFileIdx);
                    Inc(ScrIdx);
                    if ScrIdx > MaxNum then
                      begin
                      For A:=1 to MaxNum-1 Do Files^[A] := Files^[A+1];
                      Read_Data(CurDirFile,DirF,fileptr^[LowFile+MaxNum], Files^[MaxNum]);
                      Inc(LowFile);
                      ScrIdx := MaxNum;
                      ScrDn;
                      end
                    end;
   { UP }     #72:
                if CurFileIdx > 1  then
                   begin
                   dec(CurFileIdx);
                   dec(ScrIdx);
                   if (ScrIdx < 1) and (LowFile > 1) then
                    begin
                    Dec(LowFile);
                    ScrIdx :=1;
                    For A:=Maxnum Downto 2 do Files^[A] := Files^[A-1];
                    Read_Data(CurDirFile,DirF,fileptr^[LowFile], Files^[1]);
                    ScrUp;
                    end;
                  end;
              end; { case of #0/x codes }
         end;

 {      UnSelect(oldscr);}
       select(scridx);

       oldscr:=scridx;

       Showlong(ScrIdx);

       if selected then
         begin

         Status('Editing short description of File '+CaseStr(Files^[ScrIdx].Name));

         Edit_Short;

         Status('Editing long description of File '+CaseStr(Files^[ScrIdx].Name));
         Edit_Long;

         Write_Data(CurDirFile,DirF,FilePtr^[CurFileIdx], Files^[ScrIdx]);
         Selected := false;
         status('Viewing Files [1..'+ToStr(NumOfFiles)+']' );

         if directvideo then
          begin
{          textbackground(blue);}
          Putfile(ScrIdx,blue);
          end;

         end;

     end;

   until donehere;

   Close_Data(CurDirFile);

   end;

Var DifVid: boolean;

procedure ParseParam;
  { DIRED /pd:\sl-test /l25 /b /f}
  var idx : integer;
      d   : boolean;
      t   : string;
      s   : string;
      a   : integer;
      l   : string;

  begin
  d := false;
  idx := 0;
  DirectVideo := True;

  DifVid := false;

  buffersize := 25 - 4;

  FastLoadFiles := false;

  if Paramcount = 0 then
     begin
     Buffersize := 21;
     PathToConfig := '';
     end
  else
     begin
     repeat
        begin
        inc(idx);
        if Idx <= ParamCount then
         begin
         s := paramstr(idx);
         for a := 1 to ord(s[0]) do s[a] := upcase(s[a]);
         t :=  S[1] + S[2]  ;
          if T = '/P' then
                begin
                if s = '/P' then
                   PathToConfig := ParamStr(idx+1)
                else PathToConfig := copy(paramstr(idx),3,ord(s[0])-2);
                end;
          if  t = '/L' then
                begin
                difvid := true;
                if s = '/L' then
                   begin
                   L := paramstr(idx+1);
                   end
                else
                   begin
                   L := copy(paramstr(idx),3,ord(s[0])-2);
                   end;
                if L = '25' then buffersize := 25 - 4;
              { if L = '40' then buffersize := 40 - 4; }
                if L = '43' then buffersize := 43 - 4;
                if L = '50' then buffersize := 50 - 4;
                end;

          if t = '/B' then  DirectVideo := False;
          if t = '/F' then  FastLoadFiles := true;
         end { idx < para.. }
         else d := true;
        end; { repeat.. }
     until d;
     if PathToConfig <> '' then
       if PathToConfig[ord(PathToConfig[0])] <> '\' then
         PathToConfig := PathtoConfig + '\';
     end;

  end;


var  done    : boolean;

     x,y:byte;

begin

   new(files);
   new(filedirs);
   new(fileptr);

   Ansi := True;
   CapsOn := false;
   textbackground(black);
   portcheck := false;

   CheckSnow := False;

   Origtextmode := lastmode;

   Writeln('DirEd v',version,' File Directory Editor/SL (c) copyright 1992 by Zak Smith');

   x:=wherex;
   y:=wherey;

   ParseParam;

   if difvid then
    case BufferSize of
       43 - 4: Newtextmode := Co80+Font8x8;
       50 - 4: NewTextMode := Co80+Font8x8;
       else    NewTextMode := OrigTextMode;
       end;

   if DifVid then
    begin
    TextMode(NewTextMode)
    end
   else BufferSize := Rows - 4;

   if lastmode=mono then scrsize:=80*25*2 else scrsize:=Rows*Columns*2;

   GetMem(screen,scrsize);

   if lastmode = Mono then ScrBase := ptr($b000,0)
   else ScrBase := ptr($b800,0);

   move(scrbase^,screen^,scrsize);

   clrscr;

   textcolor(lightgray);
   write('Initializing: Config');

   Init_Config( '' , closed );
   write('... ');

   if Cfg.Version < 214 then arg(1, 'Wrong version of Config.Sl2!');


   write('Directory Setup');
   Init_ConstData(SetupFile,DirSetupF,SetupGenHdr,SetupHdr);
   Get_Dir_Names;
   Close_Data(SetupFile);
   write('... ');

   repeat
       begin

       Choose_Dir(done);
       if done <> true then Proc_Dir;

       end;
   until done;

   if DifVid then
    TextMode(OrigTextMode);

   cursoron;
   normvideo;
   clrscr;

   dispose(files);
   dispose(filedirs);
   dispose(fileptr);

   move(screen^,scrbase^,scrsize);
   gotoxy(x,y);

   Dispose(screen);
end.
