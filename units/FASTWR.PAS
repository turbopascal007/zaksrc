
{
ITE routine and example.
                Code by Marshall Brain.
    This program contains a routine called FASTWRITE, that can
be used on the IBM PC, XT, and compatibles to update the screen
much faster than can be done with write statements. It handles
graphics and monochrome screens.
    As can be seen, four variables are passed to Fastwrite. They
are: the cursor's column location to begin printing (0..79), the
cursor's row location (0..24), the screen attribute (contols
color, underlining, and intensity), and the string to be printed.
A typical call to fastwrite would be as follows:

     tempstring:='Fastwrite is fast as lightning';
     fastwrite(15,10,$07,tempstring);

This would print tempstring at location (15,10), with characters
that are white on black (if you are not familiar with attribute
bytes, look them up in the Technical Reference manual, or get a
book such as "Inside the IBM PC" by Peter Norton).
    These four parameters are crucial to Fastwrite's speed. In
order to write to the screen as quickly as it does, Fastwrite
ignores all of the normal channels used for screen updating such
as DOS and BIOS calls. Instead, it dumps the string to be
displayed directly into the display's memory buffer. The
advantage of speed is gained, but in the process you lose the
use of the gotoxy statement, the color statements, and
windowing. If you like, you can mix Fastwrite and regular write
statements and continue to make use of some of these features. Or
you can, as I have, create new routines to handle windows,
gotoxy, etc.
    An article on this routine was submitted to the TUG
newsletter in October - it contains code listings, etc, but
it has not been printed and I have not been told when it will
be printed. If there is any demand, I can upload the source code
for FASTWRITE.
     Good luck using this routine.  MB.   }


unit fastwr;

interface

type
  string80 = string[80];

procedure fastwrite(col,row,attrib:byte;str:string80);

implementation


var
  x:string[80];
  y : byte;
  I: integer;

procedure fastwrite(col,row,attrib:byte;str:string80);
begin
  inline
    ($1E/$1E/$8A/$86/row/$B3/$50/$F6/$E3/$2B/$DB/$8A/$9E/col/
     $03/$C3/$03/$C0/$8B/$F8/$be/$00/$00/$8A/$BE/attrib/
     $8a/$8e/str/$22/$c9/$74/$3e/$2b/$c0/$8E/$D8/$A0/$49/$04/
     $1F/$2C/$07/$74/$22/$BA/$00/$B8/$8E/$DA/$BA/$DA/$03/$46/
     $8a/$9A/str/$EC/$A8/$01/$75/$FB/$FA/$EC/$A8/$01/$74/$FB/
     $89/$1D/$47/$47/$E2/$Ea/$2A/$C0/$74/$10/$BA/$00/$B0/
     $8E/$DA/$46/$8a/$9A/str/$89/$1D/$47/$47/$E2/$F5/$1F);
end;

end.