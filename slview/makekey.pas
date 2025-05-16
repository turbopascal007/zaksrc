uses etc,ZSlKey;

var n :word;
    c :integer;
    s :string;
begin
ProgCode:='666,2112,42,DNAR_NYA,HSUR';

keyfilepath:='';
keyfilename:='SLVIEW';

s:='';
for c:=2 to paramcount do s:=s+' '+paramstr(c);
s:=ltrim(rtrim(s));

val(paramstr(1),n,c);

MakeKeyFile(s,n);

end.