Program SlCOut;

Uses Dos,SlFiles;

Var
  ColorFile: File of ColorChartType;

begin
 Open_Config;
 Read_Config;
 Close_Config;

 Assign(ColorFile,'COLORS.DEF');
 rewrite(ColorFile);
 Write(ColorFile,Cfg.ColorChart);
 Close(ColorFile);

end.