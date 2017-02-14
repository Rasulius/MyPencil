// ��������� �������� �������
procedure Lists;
begin
  // ������ - �������� (��������� ����)
  glNewList (1, GL_COMPILE);
  glBegin(GL_QUADS);
      glNormal3f(1.0, 1.0, 0.3);
      glVertex3f(2.0, 2.0, -0.3);
      glVertex3f(-2.0, 2.0, -0.3);
      glVertex3f(-2.0,-2.0, -0.3);
      glVertex3f(2.0, -2.0, -0.3);
  glEnd;
  glEndList;

  // �������
  glNewList(3, GL_COMPILE);
   glTranslatef (0.0, 0.0, 10.0);
   Spring(20.0, 20.0, 1.0, 15.0, 3, 50, 10);
   glTranslatef (0.0, 0.0, -10.0);
  glEndList;

  // ����
  glNewList(4, GL_COMPILE);
   gluDisk (Disk2, Rad4, Rad1a, Level, Level);     // ������ ������
   gluCylinder (SpDisk, Rad1a, Rad1a, H1a, Level, Level); // ����
   glTranslatef (0.0, 0.0, H1a);
   gluDisk (Disk1, Rad1, Rad1a, Level, Level);     // ������� ������
  glEndList;

  // ����������� �� ���������
  glNewList(2, GL_COMPILE);
  gluCylinder (Sp, Rad1, Rad1, H1, Level, Level); // �����������

  glTranslatef (0.0, 0.0, H1);
  gluDisk (Disk1, 0, Rad1, Level, Level);         // ������� ������

  glTranslatef (0.0, 0.0, -H1a - H2 - H1);
  gluCylinder (Cpindel, Rad4, Rad4, H2, Level, Level); // ��������
  gluDisk (Disk1, Rad4, Rad5, Level, Level);
  glEndList;

  // ������ - �����
  glNewList(5, GL_COMPILE);
  glNormal3f (1.0, 1.0, -0.3);
  Hole (Rad3);

  glBegin(GL_POLYGON);
    glNormal3f(0.0, 0.0, 0.0);
    glVertex3f(-LPlit / 2, LPlit / 2, SmallL4);
    glVertex3f(-LPlit / 2, LPlit / 2, 0.0);
    glVertex3f(-LPlit / 2, -LPlit / 2, 0.0);
    glVertex3f(-LPlit / 2, -LPlit / 2, SmallL4);
  glEnd;

  glBegin(GL_POLYGON);
    glNormal3f(LPlit / 2, 0.0, 0.0);
    glVertex3f(LPlit / 2, LPlit / 2, SmallL4);
    glVertex3f(LPlit / 2, -LPlit / 2, SmallL4);
    glVertex3f(LPlit / 2, -LPlit / 2, 0.0);
    glVertex3f(LPlit / 2, LPlit / 2, 0.0);
  glEnd;

  glBegin(GL_POLYGON);
    glNormal3f(0.0, LPlit / 2, 0.0);
    glVertex3f(-LPlit / 2, LPlit / 2, 0.0);
    glVertex3f(-LPlit / 2, LPlit / 2, SmallL4);
    glVertex3f(LPlit / 2, LPlit / 2, SmallL4);
    glVertex3f(LPlit / 2, LPlit / 2, 0.0);
  glEnd;

  glBegin(GL_POLYGON);
    glNormal3f(0.0, 0.0, 0.0);
    glVertex3f(-LPlit / 2, -LPlit / 2, 0.0);
    glVertex3f(LPlit / 2, -LPlit / 2, 0.0);
    glVertex3f(LPlit / 2, -LPlit / 2, SmallL4);
    glVertex3f(-LPlit / 2, -LPlit / 2, SmallL4);
  glEnd;

  gluCylinder (CylCentral, Rad3, Rad3, SmallL4, Level, Level * 2);
  glTranslatef (0.0, 0.0, SmallL4);

  glNormal3f(0.0, 0.0, SmallL4);
  Hole (Rad3);
  glTranslatef (0.0, 0.0, -SmallL4);

  glEndList;

  // ������ - ������
  glNewList(6, GL_COMPILE);
    glTranslatef (0.0, 0.0, -H3);
    gluCylinder (Patron, Rad5, Rad5, H3, Level, Level * 2);
    gluDisk (Disk2, Rad6, Rad5, Level, Level);
  glEndList;

  // ������ - ������
  glNewList(7, GL_COMPILE);
    glTranslatef (0.0, 0.0, -H4);
    gluCylinder (Detal, Rad6, Rad6, H4, Level, Level * 2);
  glEndList;

  // ������ - ������ ������� �����
  glNewList(8, GL_COMPILE);
    glPushMatrix;
    glTranslatef ((Rad1a + Rad1) / 2, 0.0, 0.0);
    gluCylinder (Detal, Rad7, Rad7, H5, 6, 6); // ������� ������
    glTranslatef (0.0, 0.0, H5);
    gluDisk (Disk1, 0.0, Rad7, 6, 6);          // ������� ������
    glTranslatef (0.0, 0.0, - H5 - H6);
    gluCylinder (Detal, Rad8, Rad8, H6, Level, Level); // ��������� �����
    gluCylinder (Detal, Rad7, Rad7, H5, 6, 6); // ������ ������
    gluDisk (Disk2, 0.0, Rad7, 6, 6);          // ������ ������
    glTranslatef (0.0, 0.0, H5);
    gluDisk (Disk1, Rad8, Rad7, 6, 6);          // ������� ������
    glPopMatrix;
  glEndList;

  // ������ - ������ ������� �����
  glNewList(9, GL_COMPILE);
    glPushMatrix;
    glTranslatef (-(Rad1a + Rad1) / 2, 0.0, 0.0);
    gluCylinder (Detal, Rad7, Rad7, H5, 6, 6); // ������� ������
    glTranslatef (0.0, 0.0, H5);
    gluDisk (Disk1, 0.0, Rad7, 6, 6);          // ������� ������
    glTranslatef (0.0, 0.0, - H5 - H6);
    gluCylinder (Detal, Rad8, Rad8, H6, Level, Level);
    gluCylinder (Detal, Rad7, Rad7, H5, 6, 6); // ������ ������
    gluDisk (Disk2, 0.0, Rad7, 6, 6);          // ������ ������
    glTranslatef (0.0, 0.0, H5);
    gluDisk (Disk1, Rad8, Rad7, 6, 6);         // ������� ������
    glPopMatrix;
  glEndList;

  // ������ - ����� � ����� ��� �����
  glNewList(10, GL_COMPILE);
    glPushMatrix;
    glTranslatef (-(Rad1a + Rad1) / 2, 0.0, 0.0);
    glNormal3f(1.0, 1.0, -0.3);
    Hole (Rad9);
    gluCylinder (Cyl1, Rad9, Rad9, SmallL4, Level, Level);
    glTranslatef (Rad1a + Rad1, 0.0, 0.0);
    glNormal3f(1.0, 1.0, -0.3);
    Hole (Rad9);
    gluCylinder (Cyl2, Rad9, Rad9, SmallL4, Level, Level);
    glTranslatef (0.0, 0.0, SmallL4);
    // ������� ���������
    glNormal3f(0.0, 0.0, SmallL4);
    Hole (Rad9);
    glTranslatef (-Rad1a - Rad1, 0.0, 0.0);
    Hole (Rad9);
    glPopMatrix;
    // ������ �����
    glNormal3f(1.0, 1.0, -0.3);
    glBegin(GL_QUADS);
      glVertex3f(-LPlit / 2, -LPlit / 2, 0.0);
      glVertex3f(-LPlit / 2, -Rad3, 0.0);
      glVertex3f(LPlit / 2, -Rad3, 0.0);
      glVertex3f(LPlit / 2, -LPlit / 2, 0.0);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f(LPlit / 2, LPlit / 2, 0.0);
      glVertex3f(LPlit / 2, Rad3, 0.0);
      glVertex3f(-LPlit / 2, Rad3, 0.0);
      glVertex3f(-LPlit / 2, LPlit / 2, 0.0);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f(Rad3, Rad3, 0.0);
      glVertex3f((Rad1a + Rad1) / 2 - Rad9, Rad3, 0.0);
      glVertex3f((Rad1a + Rad1) / 2 - Rad9, -Rad3, 0.0);
      glVertex3f(Rad3, -Rad3, 0.0);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f(-Rad3, Rad3, 0.0);
      glVertex3f(-(Rad1a + Rad1) / 2 + Rad9, Rad3, 0.0);
      glVertex3f(-(Rad1a + Rad1) / 2 + Rad9, -Rad3, 0.0);
      glVertex3f(-Rad3, -Rad3, 0.0);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f((Rad1a + Rad1) / 2 - Rad9, Rad3, 0.0);
      glVertex3f(LPlit / 2, Rad3, 0.0);
      glVertex3f(LPlit / 2, Rad9, 0.0);
      glVertex3f((Rad1a + Rad1) / 2 - Rad9, Rad9, 0.0);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f((Rad1a + Rad1) / 2 - Rad9, -Rad3, 0.0);
      glVertex3f(LPlit / 2, -Rad3, 0.0);
      glVertex3f(LPlit / 2, -Rad9, 0.0);
      glVertex3f((Rad1a + Rad1) / 2 - Rad9, -Rad9, 0.0);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f(-(Rad1a + Rad1) / 2 + Rad9, Rad3, 0.0);
      glVertex3f(-LPlit / 2, Rad3, 0.0);
      glVertex3f(-LPlit / 2, Rad9, 0.0);
      glVertex3f(-(Rad1a + Rad1) / 2 + Rad9, Rad9, 0.0);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f(-(Rad1a + Rad1) / 2 + Rad9, -Rad3, 0.0);
      glVertex3f(-LPlit / 2, -Rad3, 0.0);
      glVertex3f(-LPlit / 2, -Rad9, 0.0);
      glVertex3f(-(Rad1a + Rad1) / 2 + Rad9, -Rad9, 0.0);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f((Rad1a + Rad1) / 2 + Rad9, Rad9, 0.0);
      glVertex3f(LPlit / 2, Rad9, 0.0);
      glVertex3f(LPlit / 2, -Rad9, 0.0);
      glVertex3f((Rad1a + Rad1) / 2 + Rad9, -Rad9, 0.0);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f(-(Rad1a + Rad1) / 2 - Rad9, Rad9, 0.0);
      glVertex3f(-LPlit / 2, Rad9, 0.0);
      glVertex3f(-LPlit / 2, -Rad9, 0.0);
      glVertex3f(-(Rad1a + Rad1) / 2 - Rad9, -Rad9, 0.0);
    glEnd;
    // ������� �����
    glNormal3f(0.0, 0.0, SmallL4);
    glBegin(GL_QUADS);
      glVertex3f(-LPlit / 2, -LPlit / 2, SmallL4);
      glVertex3f(-LPlit / 2, -Rad3, SmallL4);
      glVertex3f(LPlit / 2, -Rad3, SmallL4);
      glVertex3f(LPlit / 2, -LPlit / 2, SmallL4);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f(LPlit / 2, LPlit / 2, SmallL4);
      glVertex3f(LPlit / 2, Rad3, SmallL4);
      glVertex3f(-LPlit / 2, Rad3, SmallL4);
      glVertex3f(-LPlit / 2, LPlit / 2, SmallL4);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f(Rad3, Rad3, SmallL4);
      glVertex3f((Rad1a + Rad1) / 2 - Rad9, Rad3, SmallL4);
      glVertex3f((Rad1a + Rad1) / 2 - Rad9, -Rad3, SmallL4);
      glVertex3f(Rad3, -Rad3, SmallL4);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f(-Rad3, Rad3, SmallL4);
      glVertex3f(-(Rad1a + Rad1) / 2 + Rad9, Rad3, SmallL4);
      glVertex3f(-(Rad1a + Rad1) / 2 + Rad9, -Rad3, SmallL4);
      glVertex3f(-Rad3, -Rad3, SmallL4);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f((Rad1a + Rad1) / 2 - Rad9, Rad3, SmallL4);
      glVertex3f(LPlit / 2, Rad3, SmallL4);
      glVertex3f(LPlit / 2, Rad9, SmallL4);
      glVertex3f((Rad1a + Rad1) / 2 - Rad9, Rad9, SmallL4);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f((Rad1a + Rad1) / 2 - Rad9, -Rad3, SmallL4);
      glVertex3f(LPlit / 2, -Rad3, SmallL4);
      glVertex3f(LPlit / 2, -Rad9, SmallL4);
      glVertex3f((Rad1a + Rad1) / 2 - Rad9, -Rad9, SmallL4);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f(-(Rad1a + Rad1) / 2 + Rad9, Rad3, SmallL4);
      glVertex3f(-LPlit / 2, Rad3, SmallL4);
      glVertex3f(-LPlit / 2, Rad9, SmallL4);
      glVertex3f(-(Rad1a + Rad1) / 2 + Rad9, Rad9, SmallL4);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f(-(Rad1a + Rad1) / 2 + Rad9, -Rad3, SmallL4);
      glVertex3f(-LPlit / 2, -Rad3, SmallL4);
      glVertex3f(-LPlit / 2, -Rad9, SmallL4);
      glVertex3f(-(Rad1a + Rad1) / 2 + Rad9, -Rad9, SmallL4);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f((Rad1a + Rad1) / 2 + Rad9, Rad9, SmallL4);
      glVertex3f(LPlit / 2, Rad9, SmallL4);
      glVertex3f(LPlit / 2, -Rad9, SmallL4);
      glVertex3f((Rad1a + Rad1) / 2 + Rad9, -Rad9, SmallL4);
    glEnd;
    glBegin(GL_QUADS);
      glVertex3f(-(Rad1a + Rad1) / 2 - Rad9, Rad9, SmallL4);
      glVertex3f(-LPlit / 2, Rad9, SmallL4);
      glVertex3f(-LPlit / 2, -Rad9, SmallL4);
      glVertex3f(-(Rad1a + Rad1) / 2 - Rad9, -Rad9, SmallL4);
    glEnd;
  glEndList;
end;
