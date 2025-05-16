{$M 16384,0,4192}

program NMSZip;

uses Dos,Etc;

var zfn: string;
    fn: string;
    p:string;

begin

fn := paramstr(1);

zfn := copy(fn,1,pos('.',fn)-1)+'.ZIP';
getdir(0,p);

exec('c:\utils\pkzip.exe',' k:\files\rush\'+zfn+' '+fn);

chdir('k:\files\rush');

exec('d:\slbbs\dirmaint.exe','j:\slbbs\dir\rush A /D '+ZFN+
  ' "National Midnight Star/RUSH News #'+copy(zfn,5,3)+'"');

chdir(p);

end.