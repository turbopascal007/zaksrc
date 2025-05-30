Unit checkpat;
{
   --- Version 3.1 91-08-17 23:08 ---

   CHECKPAT.PAS: Wrapper unit for path check function.

   Needs Assembler file 'checkpat.asm' (assembled as 'checkpap.obj').

Public domain software by

        Thomas Wagner
        Ferrari electronic GmbH
        Beusselstrasse 27
        D-1000 Berlin 21
        Germany

        BIXname: twagner
}

Interface

const

{e Error Return codes }
{d Fehlercodes }

ERR_DRIVE       = -1;  { Invalid drive }
ERR_PATH        = -2;  { Invalid path }
ERR_FNAME       = -3;  { Malformed filename }
ERR_DRIVECHAR   = -4;  { Illegal drive letter }
ERR_PATHLEN     = -5;  { Path too long }
ERR_CRITICAL    = -6;  { Critical error (invalid drive) }

{e Good returns (values ORed): }
{d R�ckgabewerte wenn kein Fehler auftrat: }

HAS_WILD     =     1;  { Filename/ext has wildcard characters }
HAS_EXT      =     2;  { Extension specified }
HAS_FNAME    =     4;  { Filename specified }
HAS_PATH     =     8;  { Path specified }
HAS_DRIVE    =   $10;  { Drive specified }
FILE_EXISTS  =   $20;  { File exists, upper byte has attributes }
IS_DIR       = $1000;  { Directory, upper byte has attributes }


{ The file attributes returned if FILE_EXISTS or IS_DIR is set }

IS_READ_ONLY = $0100;
IS_HIDDEN    = $0200;
IS_SYSTEM    = $0400;
IS_ARCHIVED  = $2000;
IS_DEVICE    = $4000;


function checkpath (var name; var drive; var dir; var fname; var ext;
                    var fullpath) : integer;

function exists (var fname): boolean;

Implementation

{$L checkpap}
function checkpath (var name; var drive; var dir; var fname; var ext;
                    var fullpath) : integer; external;
function exists (var fname): boolean; external;

end.

