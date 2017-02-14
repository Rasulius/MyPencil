begin // ������������ � case
  // ������� ������ ����� � ������ �������
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix; // ��������� ������� ������� ���������
  glRotatef (AngleXYZ [1], 1, 0, 0);
  glRotatef (AngleXYZ [2], 0, 1, 0);
  glRotatef (AngleXYZ [3], 0, 0, 1);

  glPushMatrix; // ��������� ������� ������� ��������� - 0,0
  If flgSquare then glCallList (4); // ������ ��������
  If flgOc then OcXYZ;              // ������ ���
  If flgLight then begin            // ������ �������� �����
     glPushMatrix;
     glTranslatef (PLPosition^ [1], PLPosition^ [2], PLPosition^ [3]);
     gluSphere (ObjSphere, 0.01, 5, 5);
     glPopMatrix;
  end;

  glCallList (11);   // ������ - ��������� ����������
  glCallList (1);    // ����� ����������
  // ������ ���������
  glTranslatef (0.1, -0.1, 0.0);

  glEnable (GL_TEXTURE_1D);  // �� ������� ������������� ��������
  gluCylinder (ObjCylinder, 0.125, 0.125, hStopki, 50, 50);

  // ��������� ����������� � ������
  glTranslatef (0.0, 0.0, hStopki);
  glCallList (5);
  glDisable (GL_TEXTURE_1D);

  // ������ ������ ����������
  glTranslatef (0.0, 0.0, 1.5 - hStopki);
  glCallList (10);

  // ������ �������������
  glTranslatef (0.15, 0.0, -1.725);
  glRotatef (90.0, 0.0, 1.0, 0.0);
  glCallList (6);
  glRotatef (-90.0, 0.0, 1.0, 0.0);
  glTranslatef (-1.4, 0.0, 0.0);

  // ������ ����� ��������������
  If not (flgRotation) then begin        // ����, ������� �� ����
  If wrkI = 0 then begin
     hStopki := hStopki - 0.025;         // ��������� ������
     If hStopki < 0 then hStopki := 1;   // ������ �����������
  end;
  glPushMatrix;
  glTranslatef (0.9, 0.0, 0.0);
  glRotatef (90.0, 0.0, 1.0, 0.0);
  glCallList (8); // ������ - ����� ��������������
  glPopMatrix;
  end;

  // ������ �����
  If flgRotation         // ����, ������� �� ����
     then glTranslatef (1.25, 0.0, 0.0)
     else begin
     glTranslatef (0.75, 0.0, 0.0);
     Inc (wrkI);
  end;

  glRotatef (90.0, 0.0, 1.0, 0.0);
  // ����� - �����
  glCallList (9);

  If (not flgRotation) and (wrkI = 4) then begin // ����� �����������
     flgRotation := True;
     Angle := 0;
     wrkI := 0;
  end;

  glPopMatrix;     // ������� ����� - 0, 0
  glCallList (7);  // ��� �������� �����

  glRotatef (90.0, 0.0, 1.0, 0.0);
  If flgRotation then // ����, ������� �� ����
     glRotatef ( Angle, 1.0, 0.0, 0.0);
  glCallList (2);     // ����� ���������

  glRotatef (-90.0, 0.0, 1.0, 0.0);   // ������� ��������� - �����
  glRotatef (-30.0, 0.0, 0.0, 1.0);   // ������� ��� ������������ � ��������

  // ������ - ����� ������� - ������
  glCallList (3);
  glPopMatrix;
  // ����� ������
  SwapBuffers(DC);
end;
