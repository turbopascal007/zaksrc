#@echo off
if [%1] == [] goto sorry
if [%2] == [-] set DRV=c:\tp\work\whatsnew\regtemp
if [%2] == [360] set DRV=B:
if [%2] == [720] set DRV=A:
c:
cd\tp\work\whatsnew
md temp
cd temp
copy c:\tp\work\whatsnew\reg\whatsnew.exe
copy c:\tp\work\whatsnew\doc\whatsnew.doc
c:\tp\work\whatsnew\wnewreg %1
if [%DRV%] == [B:] goto 360
if [%DRV%] == [A:] goto 720
:again
pkzip %DRV%\whatsnew.zip c:\tp\work\whatsnew\temp\*.*
echo Y | del c:\tp\work\whatsnew\temp\*.*
cd\tp\work\whatsnew
rd temp
echo don't forget to add it to SETALLDL.BAT and j:\slbbs\bisearch.pwd !!
goto end
:sorry
Echo MakeReg # [360,720]
goto end
:360
type c:\tp\work\whatsnew\keepme.--- | format %DRV% /U /F:360 /V:WHATSNEW
goto again
:720
type c:\tp\work\whatsnew\keepme.--- | format %DRV% /U /F:720 /V:WHATSNEW
goto again
:end
