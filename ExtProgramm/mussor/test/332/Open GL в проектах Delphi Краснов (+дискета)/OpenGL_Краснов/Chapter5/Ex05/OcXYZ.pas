// ��� ���������
procedure OcXYZ;
begin
  glColor3f (0,1,0);
  glBegin (GL_LINES);
    glVertex3f (0, 0, 0);
    glVertex3f (3, 0, 0);
    glVertex3f (0, 0, 0);
    glVertex3f (0, 3, 0);
    glVertex3f (0, 0, 0);
    glVertex3f (0, 0, 3);
  glEnd;

  // ����� X
  glBegin (GL_LINES);
    glVertex3f (3.1, -0.2, 0.5);
    glVertex3f (3.1, 0.2, 0.1);
    glVertex3f (3.1, -0.2, 0.1);
    glVertex3f (3.1, 0.2, 0.5);
  glEnd;

  // ����� Y
  glBegin (GL_LINES);
    glVertex3f (0.0, 3.1, 0.0);
    glVertex3f (0.0, 3.1, -0.1);
    glVertex3f (0.0, 3.1, 0.0);
    glVertex3f (0.1, 3.1, 0.1);
    glVertex3f (0.0, 3.1, 0.0);
    glVertex3f (-0.1, 3.1, 0.1);
  glEnd;

  // ����� Z
  glBegin (GL_LINES);
    glVertex3f (0.1, -0.1, 3.1);
    glVertex3f (-0.1, -0.1, 3.1);
    glVertex3f (0.1, 0.1, 3.1);
    glVertex3f (-0.1, 0.1, 3.1);
    glVertex3f (-0.1, -0.1, 3.1);
    glVertex3f (0.1, 0.1, 3.1);
  glEnd;

  // ��������������� �������� �������� �����
  glColor3f (Colors [1], Colors [2], Colors [3]);
end;
