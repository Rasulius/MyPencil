// процедура описани€ списков
procedure Lists;
const
  Num_Line = 15; // количество линий долготы и широты, задает сглаженность
begin
  // список - штырь накопител€
  glNewList (1, GL_COMPILE);
    glTranslatef (0.1, 0.1, 0.1);
    gluCylinder (ObjCylinder, 0.01, 0.01, 1.5, Num_Line, Num_Line);
    glTranslatef (0.0, -0.2, 0.0);
    gluCylinder (ObjCylinder, 0.01, 0.01, 1.5, Num_Line, Num_Line);
    glTranslatef (-0.2, 0.0, 0.0);
    gluCylinder (ObjCylinder, 0.01, 0.01, 1.5, Num_Line, Num_Line);
    glTranslatef (0.0, 0.2, 0.0);
    gluCylinder (ObjCylinder, 0.01, 0.01, 1.5, Num_Line, Num_Line);
  glEndList;

  // список шесть цилиндров
  glNewList (2, GL_COMPILE);
    For i := 0 to 5 do begin // цикл поворота рабочего стола - шесть цилиндров
      glRotatef (60.0, 1.0, 0.0, 0.0);
      gluCylinder (ObjCylinder, 0.025, 0.025, 0.75, Num_Line, Num_Line);
    end;
  glEndList;

  // список - шесть кубиков
  glNewList (3, GL_COMPILE);
    For i := 0 to 5 do begin // цикл рисовани€ кубиков
      glPushMatrix;
      glTranslatef (MyX [i], MyY [i], 0.0);
      glRotatef (-wrkArray [i], 0.0, 0.0, 1.0);
      glScalef (0.25, 0.25, 0.25);
      // Ўесть сторон куба - деталь
      glBegin(GL_QUADS);                 // верхн€€
        glNormal3f(0.0, 0.0, 0.5);
        glVertex3f(0.5, 0.75, 0.75);
        glVertex3f(-0.5, 0.75, 0.75);
        glVertex3f(-0.5, -0.25, 0.75);
        glVertex3f(0.5, -0.25, 0.75);
      glEnd;

      glBegin(GL_QUADS);                 // нижн€€
        glNormal3f(0.5, 0.25, -0.25);
        glVertex3f(0.5, 0.25, -0.25);
        glVertex3f(0.5, -0.75, -0.25);
        glVertex3f(-0.5, -0.75, -0.25);
        glVertex3f(-0.5, 0.25, -0.25);
      glEnd;

      glBegin(GL_QUADS);
        glNormal3f(-0.5, 0.0, 0.0);
        glVertex3f(-0.5, 0.75, 0.75);
        glVertex3f(-0.5, 0.25, -0.25);
        glVertex3f(-0.5, -0.75, -0.25);
        glVertex3f(-0.5, -0.25, 0.75);
      glEnd;

      glBegin(GL_QUADS);
        glNormal3f(0.5, 0.0, 0.0);
        glVertex3f(0.5, 0.75, 0.75);
        glVertex3f(0.5, -0.25, 0.75);
        glVertex3f(0.5, -0.75, -0.25);
        glVertex3f(0.5, 0.25, -0.25);
      glEnd;

      glBegin(GL_QUADS);
        glNormal3f(0.0, 0.5, 0.0);
        glVertex3f(-0.5, 0.25, -0.25);
        glVertex3f(-0.5, 0.75, 0.75);
        glVertex3f(0.5, 0.75, 0.75);
        glVertex3f(0.5, 0.25, -0.25);
      glEnd;

      glBegin(GL_QUADS);
        glNormal3f(0.5, -0.75, -0.25);
        glVertex3f(-0.5, -0.75, -0.25);
        glVertex3f(0.5, -0.75, -0.25);
        glVertex3f(0.5, -0.25, 0.75);
        glVertex3f(-0.5, -0.25, 0.75);
      glEnd;

      glPopMatrix;
  end; // конец цикла кубиков
  glEndList;

  // список - площадка
  glNewList (4, GL_COMPILE);
  glBegin(GL_QUADS);
      glNormal3f(1.0, 1.0, -0.3);
      glVertex3f(2.0, 2.0, -0.3);
      glVertex3f(-2.0, 2.0, -0.3);
      glVertex3f(-2.0,-2.0, -0.3);
      glVertex3f(2.0, -2.0, -0.3);
  glEnd;
  glEndList;

  // список - последн€€ прокладка в стопке
  glNewList (5, GL_COMPILE);
  glBegin(GL_POLYGON);
    For j := 1 to 20 do
         glVertex3f(wrkArraySin [j], wrkArrayCos [j], 0.0);
  glEnd;
  glEndList;

  // список - пневмоцилиндр
  glNewList (6, GL_COMPILE);
    gluCylinder (ObjCylinder, 0.05, 0.05, 0.5, Num_Line, Num_Line);
  glEndList;

  // список - ось рабочего стола
  glNewList (7, GL_COMPILE);
    gluCylinder (ObjCylinder, 0.05, 0.05, 1.5, Num_Line, Num_Line);
  glEndList;

  // список - штырь пневмоцилиндра
  glNewList (8, GL_COMPILE);
    gluCylinder (ObjCylinder, 0.015, 0.015, 0.5, Num_Line, Num_Line);
  glEndList;

  // список - шибер
  glNewList (9, GL_COMPILE);
  glPushMatrix;
  glScalef (0.05, 0.25, 0.25);
  glBegin(GL_QUADS);
    glNormal3f(0.0, 0.0, 0.5);
    glVertex3f(0.5, 0.5, 0.5);
    glVertex3f(-0.5, 0.5, 0.5);
    glVertex3f(-0.5,-0.5, 0.5);
    glVertex3f(0.5, -0.5, 0.5);
  glEnd;

  glBegin(GL_QUADS);
    glNormal3f(0, 0, -0.5);
    glVertex3f(0.5, 0.5, -0.5);
    glVertex3f(0.5, -0.5, -0.5);
    glVertex3f(-0.5, -0.5, -0.5);
    glVertex3f(-0.5, 0.5, -0.5);
  glEnd;

  glBegin(GL_QUADS);
    glNormal3f(-0.5, 0.0, 0.0);
    glVertex3f(-0.5, 0.5, 0.5);
    glVertex3f(-0.5, 0.5, -0.5);
    glVertex3f(-0.5, -0.5, -0.5);
    glVertex3f(-0.5, -0.5, 0.5);
  glEnd;

  glBegin(GL_QUADS);
    glNormal3f(0.5, 0.0, 0.0);
    glVertex3f(0.5, 0.5, 0.5);
    glVertex3f(0.5, -0.5, 0.5);
    glVertex3f(0.5, -0.5, -0.5);
    glVertex3f(0.5, 0.5, -0.5);
  glEnd;

  glBegin(GL_QUADS);
    glNormal3f(0.0, 0.5, 0.0);
    glVertex3f(-0.5, 0.5, -0.5);
    glVertex3f(-0.5, 0.5, 0.5);
    glVertex3f(0.5, 0.5, 0.5);
    glVertex3f(0.5, 0.5, -0.5);
  glEnd;

  glBegin(GL_QUADS);
    glNormal3f(0.0, -0.5, 0.0);
    glVertex3f(-0.5, -0.5, -0.5);
    glVertex3f(0.5, -0.5, -0.5);
    glVertex3f(0.5, -0.5, 0.5);
    glVertex3f(-0.5, -0.5, 0.5);
  glEnd;
  glPopMatrix;
  glEndList;

  // список - крышка накопител€
  glNewList (10, GL_COMPILE);
  glPushMatrix;
  glScalef (0.25, 0.25, 1);
  // Ўесть сторон куба - крышка накопител€
  glBegin(GL_QUADS);
    glNormal3f(0.0, 0.0, 0.025);
    glVertex3f(0.5, 0.5, 0.025);
    glVertex3f(-0.5, 0.5, 0.025);
    glVertex3f(-0.5,-0.5, 0.025);
    glVertex3f(0.5, -0.5, 0.025);
  glEnd;

  glBegin(GL_QUADS);
    glNormal3f(0, 0, -0.025);
    glVertex3f(0.5, 0.5, -0.025);
    glVertex3f(0.5, -0.5, -0.025);
    glVertex3f(-0.5, -0.5, -0.025);
    glVertex3f(-0.5, 0.5, -0.025);
  glEnd;

  glBegin(GL_QUADS);
    glNormal3f(-0.5, 0.0, 0.0);
    glVertex3f(-0.5, 0.5, 0.025);
    glVertex3f(-0.5, 0.5, -0.025);
    glVertex3f(-0.5, -0.5, -0.025);
    glVertex3f(-0.5, -0.5, 0.025);
  glEnd;

  glBegin(GL_QUADS);
    glNormal3f(0.5, 0.0, 0.0);
    glVertex3f(0.5, 0.5, 0.025);
    glVertex3f(0.5, -0.5, 0.025);
    glVertex3f(0.5, -0.5, -0.025);
    glVertex3f(0.5, 0.5, -0.025);
  glEnd;

  glBegin(GL_QUADS);
    glNormal3f(0.0, 0.5, 0.0);
    glVertex3f(-0.5, 0.5, -0.025);
    glVertex3f(-0.5, 0.5, 0.025);
    glVertex3f(0.5, 0.5, 0.025);
    glVertex3f(0.5, 0.5, -0.025);
  glEnd;

  glBegin(GL_QUADS);
    glNormal3f(0.0, -0.5, 0.0);
    glVertex3f(-0.5, -0.5, -0.025);
    glVertex3f(0.5, -0.5, -0.025);
    glVertex3f(0.5, -0.5, 0.025);
    glVertex3f(-0.5, -0.5, 0.025);
  glEnd;

  glPopMatrix;
  glEndList;

 // список - основание
  glNewList (11, GL_COMPILE);
  glTranslatef (1.351, 0.0, 0.325);
  glPushMatrix;
  glScalef (0.25, 0.25, 1);

  // Ўесть сторон куба
  glBegin(GL_QUADS);
    glNormal3f(0.0, 0.0, 0.1);
    glVertex3f(0.5, 0.5, 0.1);
    glVertex3f(-0.5, 0.5, 0.1);
    glVertex3f(-0.5,-0.5, 0.1);
    glVertex3f(0.5, -0.5, 0.1);
  glEnd;

  glBegin(GL_QUADS);
    glNormal3f(0, 0, -0.1);
    glVertex3f(0.5, 0.5, -0.1);
    glVertex3f(0.5, -0.5, -0.1);
    glVertex3f(-0.5, -0.5, -0.1);
    glVertex3f(-0.5, 0.5, -0.1);
  glEnd;

  glBegin(GL_QUADS);
    glNormal3f(-0.5, 0.0, 0.0);
    glVertex3f(-0.5, 0.5, 0.1);
    glVertex3f(-0.5, 0.5, -0.1);
    glVertex3f(-0.5, -0.5, -0.1);
    glVertex3f(-0.5, -0.5, 0.1);
  glEnd;

  glBegin(GL_QUADS);
    glNormal3f(0.5, 0.0, 0.0);
    glVertex3f(0.5, 0.5, 0.1);
    glVertex3f(0.5, -0.5, 0.1);
    glVertex3f(0.5, -0.5, -0.1);
    glVertex3f(0.5, 0.5, -0.1);
  glEnd;

  glBegin(GL_QUADS);
    glNormal3f(0.0, 0.5, 0.0);
    glVertex3f(-0.5, 0.5, -0.1);
    glVertex3f(-0.5, 0.5, 0.1);
    glVertex3f(0.5, 0.5, 0.1);
    glVertex3f(0.5, 0.5, -0.1);
  glEnd;

  glBegin(GL_QUADS);
    glNormal3f(0.0, -0.5, 0.0);
    glVertex3f(-0.5, -0.5, -0.1);
    glVertex3f(0.5, -0.5, -0.1);
    glVertex3f(0.5, -0.5, 0.1);
    glVertex3f(-0.5, -0.5, 0.1);
  glEnd;

  glPopMatrix;
  glEndList;
end;