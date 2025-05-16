@echo off
rem registered version
c:\tp\tpc.exe /Ec:\tp\bin /Uc:\tp\tpu;c:\tp\sl /Oc:\tp\bin c:\tp\work\whatsnew\whatsnew /B /dREG
copy /B c:\tp\bin\whatsnew.exe + c:\tp\bin\whatsnew.ovr c:\tp\bin\tempnew.exe
del c:\tp\bin\whatsnew.ovr 
copy c:\tp\bin\tempnew.exe c:\tp\bin\whatsnew.exe
del c:\tp\bin\tempnew.exe
cd\tp\work\whatsnew\reg
attrib -r whatsnew.exe
copy c:\tp\bin\whatsnew.exe
attrib +r whatsnew.exe
del c:\tp\bin\whatsnew.exe
rem unregistered version
c:\tp\tpc.exe /Ec:\tp\bin /Uc:\tp\tpu;c:\tp\sl /Oc:\tp\bin c:\tp\work\whatsnew\whatsnew /B
copy /B c:\tp\bin\whatsnew.exe + c:\tp\bin\whatsnew.ovr c:\tp\bin\tempnew.exe
del c:\tp\bin\whatsnew.ovr 
copy c:\tp\bin\tempnew.exe c:\tp\bin\whatsnew.exe
del c:\tp\bin\tempnew.exe
cd\tp\work\whatsnew\unreg
attrib -r whatsnew.exe
copy c:\tp\bin\whatsnew.exe
attrib +r whatsnew.exe
del c:\tp\bin\whatsnew.exe
