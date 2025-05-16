@echo off
c:
cd\tp\work\antibody
tpc antibody.pas /B /GD
attrib -r c:\tp\work\antibody\exe\antibody.exe
copy c:\tp\bin\antibody.exe c:\tp\work\antibody\exe
attrib +r c:\tp\work\antibody\exe\antibody.exe
copy c:\tp\bin\antibody.map c:\tp\work\antibody
