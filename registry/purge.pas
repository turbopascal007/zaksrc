{$X+}
Uses Modem,etc;

var m:modemobj;

begin
m.init(toint(paramstr(1)));

m.killin;
m.killout;

m.close;
end.