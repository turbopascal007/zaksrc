Uses Dos,SlfLow,Etc;

function mindif(h1,m1,h2,m2:word):word;
 begin
 if h2<h1 { midnight dude } then
    mindif := (h2*60 + m2) + (1440 - (h1*60 + m2))
 else
    mindif := (h2*60+m2) - (h1*60+m1);
 end;


var User: UserType;
    uF  : file;

    uGFH: fileheader;
    uFH : userheader;

    IncTime: integer;

    timefile: file of timetype;
    t:timetype;

    h,m,s:word;

begin
FileMode := 66;

if upcasestr(paramstr(1))='SET' then
  begin
  assign(timefile,'FREZTIME.DAT');
  rewrite(timefile);
  curtime(h,m,s);
  t.hour := h;
  t.minute := m;
  write(timefile,t);
  close(timefile);
  end
else
  begin
  assign(timefile,'FREZTIME.DAT');
  reset(timefile);
  read(timefile,t);
  close(timefile);

  assign(timefile,'FREZTIME.DAT');
  erase(timefile);

  CurTime(h,m,s);

  IncTime := MinDif(t.hour,t.minute,h,m);

  Init_Config('',opened);
  Init_ConstData(uF,userf,uGFH,uFH);
  Read_Data(uF,UserF,cfg.curruser,user);

  Inc(User.TimeLeft, IncTime);

  if (Cfg.NextEvent > 0) and (Cfg.NextEvent < User.TimeLeft) then
     Cfg.TimeLimit := Cfg.NextEvent
  else
     Cfg.TimeLimit := User.TimeLeft;

  If Cfg.UseSession and (User.Access.SessLimit < Cfg.TimeLimit) then
       Cfg.TimeLimit := User.Access.SessLimit;

  Write_Data(uF,UserF,cfg.curruser,user);
  Close_Data(uF);
  Write_Config;
  Close_Config;
  end;

end.