// ��������� �������� �������
procedure Lists;
const
  Num_Line = 15; // ���������� ����� ������� � ������, ������ ������������
begin
  // ������ - ����� ����������
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

  // ������ ����� ���������
  glNewList (2, GL_COMPILE);
    For i := 0 to 5 do begin // ���� �������� �������� ����� - ����� ���������
      glRotatef (60.0, 1.0, 0.0, 0.0);
      gluCylinder (ObjCylinder, 0.025, 0.025, 0.75, Num_Line, Num_Line);
    end;
  glEndList;

  // ������ - ����� �������
  glNewList (3, GL_COMPILE);
    For i := 0 to 5 do begin // ���� ��������� �������
      glPushMatrix;
      glTranslatef (MyX [i], MyY [i], 0.0);
      glRotatef (-wrkArray [i], 0.0, 0.0, 1.0);
      glScalef (0.25, 0.25, 0.25);
      // ����� ������ ���� - ������
      glBegin(GL_QUADS);                 // �������
        glNormal3f(0.0, 0.0, 0.5);
        glVertex3f(0.5, 0.75, 0.75);
        glVertex3f(-0.5, 0.75, 0.75);
        glVertex3f(-0.5, -0.25, 0.75);
        glVertex3f(0.5, -0.25, 0.75);
      glEnd;

      glBegin(GL_QUADS);                 // ������
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
  end; // ����� ����� �������
  glEndList;

  // ������ - ��������
  glNewList (4, GL_COMPILE);
  glBegin(GL_QUADS);
      glNormal3f(1.0, 1.0, -0.3);
      glVertex3f(2.0, 2.0, -0.3);
      glVertex3f(-2.0, 2.0, -0.3);
      glVertex3f(-2.0,-2.0, -0.3);
      glVertex3f(2.0, -2.0, -0.3);
  glEnd;
  glEndList;

  // ������ - ��������� ��������� � ������
  glNewList (5, GL_COMPILE);
  glBegin(GL_POLYGON);
    For j := 1 to 20 do
         glVertex3f(wrkArraySin [j], wrkArrayCos [j], 0.0);
  glEnd;
  glEndList;

  // ������ - �������������
  glNewList (6, GL_COMPILE);
    gluCylinder (ObjCylinder, 0.05, 0.05, 0.5, Num_Line, Num_Line);
  glEndList;

  // ������ - ��� �������� �����
  glNewList (7, GL_COMPILE);
    gluCylinder (ObjCylinder, 0.05, 0.05, 1.5, Num_Line, Num_Line);
  glEndList;

  // ������ - ����� ��������������
  glNewList (8, GL_COMPILE);
    gluCylinder (ObjCylinder, 0.015, 0.015, 0.5, Num_Line, Num_Line);
  glEndList;

  // ������ - �����
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

  // ������ - ������ ����������
  glNewList (10, GL_COMPILE);
  glPushMatrix;
  glScalef (0.25, 0.25, 1);
  // ����� ������ ���� - ������ ����������
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

 // ������ - ���������
  glNewList (11, GL_COMPILE);
  glTranslatef (1.351, 0.0, 0.325);
  glPushMatrix;
  glScalef (0.25, 0.25, 1);

  // ����� ������ ����
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