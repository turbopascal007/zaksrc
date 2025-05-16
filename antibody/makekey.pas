uses etc,ZSlKey;

var n :word;
    c :integer;
    s :string;
begin
ProgCode:=^J+^W+^[+^]+^_+'(z'+#123+ '5&# ?2gKy~'+^@+^U;

keyfilepath:='';
keyfilename:='ANTIBODY';

s:='';
for c:=2 to paramcount do s:=s+' '+paramstr(c);
s:=ltrim(rtrim(s));

val(paramstr(1),n,c);

MakeKeyFile(s,n);

end.