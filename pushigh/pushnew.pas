Program PusHigh;

Uses Crt, Dos, SlDriv, SLfLow, SlfHigh, Etc;

var include    : string;
    exclude    : string;
    all        : boolean;
    username   : string;

    setup      : setupdata;
    mbr        : membtype;
    savembrrec : longint;



procedure Parse;
  { PusHigh User_Name -subname +subname /all }
  var idx : integer;
      d   : boolean;
      t   : char;
      s   : string;
      a   : integer;
      l   : string;

  begin
  d := false;
  idx := 0;

  Include   := '';
  Exclude   := '';
  All := False;

  if Paramcount = 0 then
     begin
     writeln;
     textcolor(white);
     write('PUSHIGH ');
     textcolor(lightgray);
     write(' user_name [-subname] [+subname] [/ALL] ');
     writeln;
     normvideo;
     halt(1);
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

         t :=  S[1] ;
          case T of
           '+':
                begin
                Include := concat(include,' ',copy(s,2,length(s)-1));
                end;
           '-':
                begin
                exclude := concat(exclude,' ',copy(s,2,length(s)-1));
                end;
           '/':
                begin
                if upcasestr(copy(s,2,length(s)-1)) = 'ALL' then
                  All := True;
                end;
           else
                begin
                Username := s;
                for a:=1 to length(username) do
                     if username[a] = '_' then username[a] := ' ';
                end;
           end;

         end { idx < para.. }
         else d := true;
        end; { repeat.. }
     until d;
     end;
  end;

var msghdr

function find_high_msg:longint;
  var f:file;
      fh:fileheader;
      fgh:Subtype;

  begin

  Init_VarData(f,MsgHdrF,setup.path, setup.name,fh,fgh);
  Close_Data(f);

  find_high_msg := fgh.lastmsg;

  end;

procedure Status_Push_High;
  begin
  textbackground(black);
  TextColor(cyan);
  Write('  - Pushing high to ');
  textcolor(lightcyan);

  write(msghdrhdr.lastmsg);

  textcolor(cyan);
  write(' in ');
  textcolor(lightcyan);
  write(setup.name);
  textcolor(cyan);
  writeln('.');
  end;


procedure ClimbTree_mbr(rec:longint);
  var Right     : longint;
      Left      : longint;

  begin

  if rec <> 0 then
    begin

    Read_msgmbr(rec,mbr);

    Right := mbr.leaf.Right;
    Left := mbr.leaf.left;

    case compare(username, mbr.name) of
      0: begin
         mbr.lastread := find_high_msg;
         write_msgmbr(rec,mbr);
         Status_Push_High;
         exit;
         end;

      1: Climbtree_mbr(right);
      2: Climbtree_mbr(left);
      end;
    end;
  end;

procedure process_mbr;
  begin
  open_msgmbr(setup.path, setup.name);
  read_msgmbr_genhdr;
  read_msgmbr_hdr;
  climbtree_mbr(msgmbrhdr.root.treeroot);
  close_msgmbr_file;
  end;


procedure ClimbTree_Setup(rec:longint);
var left:longint;
    right:longint;

  begin

   if rec <> 0 then
    begin

    Read_Setup_data(rec,setup);

    Right := Setup.leaf.Right;
    Left := setup.leaf.left;

    ClimbTree_Setup(Left);

    Read_Setup_Data(rec,setup);

    if   ((Pos(UpcaseStr(Setup.Name),Exclude) = 0) AND
          ((Include = '') or ((pos(upcasestr(setup.name),include))>0)
           or (All and (pos(upcasestr(setup.name),exclude)= 0)))
       or
         (Pos(UpCaseStr(Setup.Name),Include) > 0))
      then
         process_mbr;


    ClimbTree_Setup(Right);

    end;
  end;



begin
  PathToConfig := '';
  Directvideo := false;

  textbackground(black);
  Textcolor(lightcyan);write('PUSHIGH');
  textcolor(cyan);write(' - ');
  textcolor(lightgray);
  writeln('Push High Msg Utility by Zak Smith');

  loadsldata;
  if SlActive then LocalOnly;
  textcolor(white);
  write('  PUSHIGH');
  textcolor(lightgray);
  write(' (c) copyright 1991 by ');
  textcolor(white);
  write('Zak Smith');
  textcolor(lightgray);
  write(' All Rights Reserved.');
  writeln;
  if SlActive then LocalAndRemote;

  Parse;

  open_config;
  read_config;
  close_config;

  Open_Setup(setupmsg);
  read_setup_genhdr;
  read_setup_hdr;

  Climbtree_setup(setuphdr.root.treeroot);

  close_setup;

  normvideo;

end.
