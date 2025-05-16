@echo off
if [%1] == [] goto err
call compile
pkzip slvw%1 slview.exe archive.cfg docs\slview.doc docs\slview.hst
copy slvw%1.zip j:\files\sl200
j:
cd\files\sl200
j:\slbbs\utils\dirmaint j:\slbbs\dir\SL200 A /R/D SLVW%1.ZIP "SLView - ARCHIVE View/DL/Type for SL" 
exit
:err
echo MakeZip VER
