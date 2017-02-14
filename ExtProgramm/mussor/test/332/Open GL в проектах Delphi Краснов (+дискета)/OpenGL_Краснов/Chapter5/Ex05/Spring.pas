procedure Spring (rBegin, rEnd, rSpring, Height : GLFloat;
                  nVitkov, nHorizontal, nVertical : Byte);
var
 x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4 : GLFloat;
 Radius,dRadius,dHeight,HeightNew : GLFloat;
 HorAngle,VertAngle,dHorAngle,dVertAngle : GLFloat;
 Hor,Vert : Byte;
begin
 If nVitkov * 2 * rSpring > height then
    Height := nVitkov * 2 * rSpring;
 dHorAngle := nVitkov * 360 / nHorizontal;
 HorAngle := 0;
 dVertAngle := 360 / nVertical;
 HeightNew := 0;
 dHeight := Height / nHorizontal;
 Radius := rBegin;
 dRadius := (rEnd-rBegin) / nHorizontal;
 For Hor := 1 to nHorizontal do begin
   VertAngle := 0;
   For Vert := 1 to nVertical do begin
    x1:=(Radius+rSpring+rSpring*cos(VertAngle*pi/180))*cos(HorAngle*pi/180);
    y1:=(Radius+rSpring+rSpring*cos(VertAngle*pi/180))*sin(HorAngle*pi/180);
    z1:=rSpring*sin(VertAngle*pi/180)+HeightNew;
    x2:=(Radius+rSpring+rSpring*cos((VertAngle+dVertAngle)*pi/180))*cos(HorAngle*pi/180);
    y2:=(Radius+rSpring+rSpring*cos((VertAngle+dVertAngle)*pi/180))*sin(HorAngle*pi/180);
    z2:=rSpring*sin((VertAngle+dVertAngle)*pi/180)+HeightNew;
    x3:=(Radius+dRadius+rSpring+rSpring*cos((VertAngle+dVertAngle)*pi/180))*cos((HorAngle+dHorAngle)*pi/180);
    y3:=(Radius+dRadius+rSpring+rSpring*cos((VertAngle+dVertAngle)*pi/180))*sin((HorAngle+dHorAngle)*pi/180);
    z3:=rSpring*sin((VertAngle+dVertAngle)*pi/180)+HeightNew+dHeight;
    x4:=(Radius+dRadius+rSpring+rSpring*cos(VertAngle*pi/180))*cos((HorAngle+dHorAngle)*pi/180);
    y4:=(Radius+dRadius+rSpring+rSpring*cos(VertAngle*pi/180))*sin((HorAngle+dHorAngle)*pi/180);
    z4:=rSpring*sin(VertAngle*pi/180)+HeightNew+dHeight;
    glBegin(GL_POLYGON);
      glNormal3f(x1,y1,z1);
      glVertex3f(x1,y1,z1);
      glVertex3f(x2,y2,z2);
      glVertex3f(x3,y3,z3);
      glVertex3f(x4,y4,z4);
    glEnd;
    VertAngle:=VertAngle+dVertAngle;
 end;
 HorAngle:=HorAngle+dHorAngle;
 HeightNew:=HeightNew+dHeight;
 Radius:=Radius+dRadius;
 end;
end;
