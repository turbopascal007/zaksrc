@echo off
if [%1]==[] goto sorry
c:
cd\tp\work\antibody
md temp
copy doc\antibody.hst temp
copy doc\antibody.doc temp
copy exe\antibody.exe temp
copy exe\notxmdm.exe temp
copy exe\antibody.sys temp
copy exe\reject.lst temp
copy exe\archive.cfg temp
copy doc\antibody.reg temp
copy doc\ab-sl215.doc temp
pkzip zip\antib%1 temp\*.*
echo y|del temp\*.*
rd temp
j:
cd\files\sl200
copy c:\tp\work\antibody\zip\antib%1 j:\files\sl200
j:\slbbs\utils\dirmaint j:\slbbs\dir\SL200 A /R/D ANTIB%1 "AntiBody Virus Scanner/Compression Convertor" 
c:
goto end
:sorry
echo makezip ver#.zip
:end

exit
:sorry
echo MakeZip Ver#.zip
