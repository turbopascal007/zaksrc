
Unit SlMenus;
 { Definitions & Code for Searchlight 2.25 file based menu system }

 { Definitions and code in this file are provided as-is and without
   documentation for now. }

Interface

  Uses Filedef,Block,Users;


type EntryType = (Internal,Door,Menu);
     PauseType = (NoPause,Delay,KeyHit);
     ExecType = (Display,Execute);
     PromptOptionType  = (WordPrompt,SingleChar,MenuBar);

     MenuDefType = record
       commands: integer;           { total # of commands on menu }
       ExitCmd: boolean;            { no longer used }
       ClearScreen: boolean;        { clear screen before displaying menu? }
       DisplayFile: string[30];     { optional/external display file }
       DisplayOption: array [Expert..Novice]
         of Boolean;
       PromptOption: array[Expert..Novice]
         of PromptOptionType;
       Prompt: array[1..3]
         of string[40];
       title: string[40];
       displaytitle: boolean;
       extra: string[49];           { pad to 256 bytes }
     end;

     MenuItemType = record
       name: string[15];            { menu item name }
       key: char;                   { hotkey that executes item }
       descrip: string[40];         { choice description }
       p: pausetype;                { [not used] }
       minaccess: integer;          { minimum access }
       reqattrib: attribset;        { minimum attributes }
       maxaccess: integer;          { maximum access }
       exattrib: attribset;         { exclude attributes }
       helplevels: byte;            { help levels that command supports, 0=All }
       userpref: attribset;         { user preferences }

       extra: string[9];      { pad to 256 }

       case Entry: EntryType of
         Internal: (
           commands: array[1..4] of integer;
           params: array[1..4] of string[30];
           extra1: string[36]);
         Door: (
           d: AutoDoorType);
         Menu: (
           menuname: string[8];
           command: ExecType);
     end;


     MenuItemArray = Array[1..1] of MenuItemType;
     MenuItemPtr = ^MenuItemArray;

     MenuType = record             { Menu structure in RAM }
       name: string[8];
       size: integer;
       data: MenuDefType;
       items: MenuItemPtr;
     end;

     AccessPtr = ^AccessType;

 Function ReadMenu (filename: string; var m: menutype): boolean;
 Function WriteMenu (filename: string; var m: menutype): boolean;
Procedure ScanMenu (var m: menutype; a: AccessPtr; h: helplevel;
                    upref: attribset; system: integer);
Procedure ClearMenu (var m: menutype);
Procedure DisposeMenu (var m: menutype);

const MaxMenuSize = 64;

var Main: MenuType;        { Main, or currently active, menu }


Implementation

var MenuFile: BlockFileType;


Function ReadMenu (filename: string; var m: menutype): boolean;
  { loads a menu from the menu directory into memory }
var i: integer;
Begin
  assign(MenuFile.Filevar,cf.Menupath+filename+'.MNU');
  if OpenBlockFile(MenuFile) then begin
    m.name:=filename;
    m.size:=0;
    block_read(menufile.filevar,m.data,sizeof(fileheader),sizeof(m.data));
    GetMem(m.items,sizeof(menuitemtype)*m.data.commands);
    for i:=1 to m.data.commands do begin
      inc(m.size);
      ReadBlockFile(menufile,i,@m.items^[i]);
    end;
    CloseBlockFile(MenuFile);
    ReadMenu:=true;
  end
  else ReadMenu:=false;
end;


Function WriteMenu (filename: string; var m: menutype): boolean;
  { writes menu in memory back to disk (overwrites existing file) }
var x: word;
Begin
  assign(MenuFile.Filevar,cf.Menupath+filename+'.MNU');
  {$I-} erase(MenuFile.Filevar); {$I+}
  x:=IOResult;

  assign(MenuFile.Filevar,cf.Menupath+filename+'.MNU');
  with menufile do begin
    recsize:=sizeof(menuitemtype);
    offset:=sizeof(menudeftype);
  end;
  if CreateBlockFile(MenuFile,m.data.commands) then begin
    block_write(menufile.filevar,m.data,sizeof(fileheader),sizeof(m.data));
    for x:=1 to m.data.commands do
      WriteBlockFile(menufile,x,@m.items^[x]);
    m.name:=filename;
    m.size:=m.data.commands;
    CloseBlockFile(menufile);
    WriteMenu:=true;
  end
  else WriteMenu:=false;
end;


Procedure ClearMenu (var m: menutype);
Begin
  fillchar(m,sizeof(m),0);
end;

Procedure DisposeMenu (var m: menutype);
Begin
  if m.items<>Nil
    then FreeMem(m.items,sizeof(menuitemtype)*m.data.commands);
  ClearMenu(m);
end;



Procedure ScanMenu (var m: menutype; a: AccessPtr; h: helplevel;
                    upref: attribset; system: integer);

  { removes commands from menu which fail access level test }

const sysaccess: accesstype = (Attrib: [1..24]; MsgLevel: 255; FileLevel: 255);

var i,d: integer;
    t: MenuItemPtr;

  Function HelpOK (var i: menuitemtype): Boolean;
  Begin
    case h of
      Expert: HelpOK:=(i.helplevels in [0,3,5,6]);
      Intermediate: HelpOK:=(i.helplevels in [0,2,4,6]);
      Novice: HelpOK:=(i.helplevels in [0,1,4,5]);
    end;
  end;

  Function PrefOK (var i: menuitemtype): Boolean;
  var n: integer;
      result: boolean;
  Begin
    result:=(i.userpref=[]);
    for n:=1 to 24 do
      result:=result or ((n in i.userpref) and (n in upref));
    PrefOK:=result;
  end;

  Function Allow (var i: menuitemtype): boolean;
  var ok: boolean;
  Begin
    case system of
      1: begin  { Main/Message }
        ok:=(i.minaccess<=a^.msglevel) and (i.reqattrib-a^.attrib=[]);
        if ok then begin
          if a^.msglevel>i.maxaccess
            then ok:=false;
          if (i.exattrib<>[]) and (i.exattrib-a^.attrib=[])
            then ok:=false;
        end;
      end;

      2: begin  { Files }
        ok:=(i.minaccess<=a^.filelevel) and (i.reqattrib-a^.attrib=[]);
        if ok then begin
          if a^.filelevel>i.maxaccess
            then ok:=false;
          if (i.exattrib<>[]) and (i.exattrib-a^.attrib=[])
            then ok:=false;
        end;
      end;
    end;
    Allow:=Ok and HelpOK(i) and PrefOK(i);
  end;

Begin
  if cf.superuser then a:=@sysaccess;
  d:=0;
  for i:=1 to m.data.commands do begin
    if not Allow(m.items^[i]) then begin
      inc(d);
      dec(m.size);
    end else begin
      if (d<>0)
        then m.items^[i-d]:=m.items^[i];
    end;
  end;

end;



end.
