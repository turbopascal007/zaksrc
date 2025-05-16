@echo off
if [%2] == [] goto err
set DESC=Archive View/Type/DL Replacement. What VIEW should be!
call makezip %1
d:
cd\slnode2\tick
set TZ=CST
hatch /aSL_FDN /on /r0 /fSLVW%1.ZIP /xSLVW%2.ZIP /d"SLView revision v%1 %DESC"
cd..
slfdnann
goto end
:err
echo New ThisVER PreviousVer
:end
