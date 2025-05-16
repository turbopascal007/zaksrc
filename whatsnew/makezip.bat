@echo off
if [%1] == [] goto sorry
cd\tp\work\whatsnew
md temp
cd temp
copy c:\tp\work\whatsnew\doc\whatsnew.doc
copy c:\tp\work\whatsnew\doc\whatsnew.reg
copy c:\tp\work\whatsnew\unreg\whatsnew.exe
pkzip c:\tp\work\whatsnew\zip\wnew%1.zip *.*
echo Y|del c:\tp\work\whatsnew\temp\*.*
cd..
rd temp
j:
cd\files\sl200
copy c:\tp\work\whatsnew\zip\wnew%1.zip j:\files\sl200
j:\slbbs\utils\dirmaint j:\slbbs\dir\SL200 A /R/D WNEW%1.ZIP "Zak's WHATSNEW - Update v%1" 
c:
goto end
:sorry
echo makezip ver
:end
