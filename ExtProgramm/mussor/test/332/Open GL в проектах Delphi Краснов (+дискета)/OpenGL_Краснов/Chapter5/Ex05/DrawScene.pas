// ��������� ���������� ��������� - ������� OpenGL.
begin // ������������ � case
  // ������� ������ ����� � ������ �������
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix; // ��������� ������� ������� ��������� - 0,0
  // ������������ �����
  glTranslatef(AddXYZ [1], AddXYZ [2], AddXYZ [3] - 7.0);
  glRotatef (AngleXYZ [1], 1, 0, 0);
  glRotatef (AngleXYZ [2], 0, 1, 0);
  glRotatef (AngleXYZ [3], 0, 0, 1);

  If flgSquare then glCallList (1); // ������ �������� (��������� ����)
  If flgOc then OcXYZ; // ������ ���
  If flgLight then begin    // ������ �������� �����
     glTranslatef (PLPosition^ [1], PLPosition^ [2], PLPosition^ [3]);
     gluSphere (ObjSphere, 0.01, 5, 5);
     glTranslatef (-PLPosition^ [1], -PLPosition^ [2], -PLPosition^ [3]);
  end;

  glScalef (CoeffX, CoeffY, CoeffZ);
  glTranslatef (0.0, 0.0, SmallB);
  glCallList (3);                  // �������
  glCallList (10);                 // ����� � ����� ��� �����
  glCallList (5);                  // �����

  glRotatef (AngleX, 1.0, 0.0, 0.0);
  glRotatef (AngleY, 0.0, 1.0, 0.0);
  glTranslatef (0.0, 0.0, Smallh);
  glCallList (4);                  // ����
  glCallList (8);                  // ������ ����
  glCallList (9);                  // ������ ����
  glRotatef (AngleZ, 0.0, 0.0, 1.0);
  glCallList (2);                  // ����������� �� ���������
  glCallList (6);                  // ������
  glCallList (7);                  // ������

  glPopMatrix;

  // ����� ������
  SwapBuffers(DC);
end;
