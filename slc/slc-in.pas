Program SlCIn;

Uses Dos,SlFiles;

Var
  ColorFile: File of ColorChartType;

begin
 Open_Config;
 Read_Config;



 Assign(ColorFile,'COLORS.DEF');
 reset(ColorFile);
 Read(ColorFile,Cfg.ColorChart);
 Close(ColorFile);

 Write_Config;
 Close_Config;

end.