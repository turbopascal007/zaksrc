@echo off
if [%1] == [] goto sorry
c:
cd\tp\work\whatsnew
md temp
cd temp
copy c:\tp\work\whatsnew\reg\whatsnew.exe
copy c:\tp\work\whatsnew\doc\whatsnew.doc
c:\tp\work\whatsnew\wnewreg %1
pkzip whatsnew.zip c:\tp\work\whatsnew\temp\*.*
