if [%1]==[] goto sorry
c:
cd\tp\work\antibody
del antibody.key
makekey %1 %3 %4 %5 %6 %7 %8 %9
pkzip j:\files\private\abk-%1.zip antibody.key
del antibody.key
j:
cd\files\private
j:\slbbs\utils\dirmaint j:\slbbs\dir\PRIVATE A /R/D ABK-%1.ZIP "AntiBody Key for SLBBS # %1" 
j:\slbbs\utils\dirmaint j:\slbbs\dir\private P /R ABK-%1.ZIP "%2"  >nul
:sorry
echo makekey sl# passwd bbs name
