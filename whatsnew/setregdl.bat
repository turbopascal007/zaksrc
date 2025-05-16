@echo off
if [%1] == [] goto sorry
c:
cd\tp\work\whatsnew
echo y|del c:\tp\work\whatsnew\temp\*.* >nul
rd temp
md temp
cd temp
copy c:\tp\work\whatsnew\reg\whatsnew.exe >nul
copy c:\tp\work\whatsnew\doc\whatsnew.doc >nul
c:\tp\work\whatsnew\wnewreg %1 
pkzip j:\files\private\%2.zip c:\tp\work\whatsnew\temp\*.* >nul
echo Y | del c:\tp\work\whatsnew\temp\*.* >nul
cd\tp\work\whatsnew
rd temp
j:
cd\files\private
j:\slbbs\utils\dirmaint j:\slbbs\dir\PRIVATE A /R/D %2.ZIP "WhatsNew for %2"  >nul
j:\slbbs\utils\dirmaint j:\slbbs\dir\private P /R %2.ZIP "%3"  >nul
c:
d:
cd\slnode2
echo Yeah!  Your Registered Version of WHATSNEW is available as "%2.ZIP" in the > temp.msg
echo "Private" Directory, with the password of "%3" >> Temp.MSG
echo Note: If you don't seem to have access to the "PRIVATE" dir., leave >>temp.msg
echo       mail to the SYSOP so I can upgrade your access! >> temp.msg
slmail S MAIL -fSYSOP -t%4 %5 %6 %7 -sWhatsNew Update! -xTemp.MSG
del temp.msg
c:
cd\tp\work\whatsnew
goto end
:sorry
Echo SetRegDl # Name Passwd USER NAME ...
exit
:end
