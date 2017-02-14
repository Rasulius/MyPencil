// ��������� ������ ���������� � ����
procedure SavePar;
var
  ResFile : File of GlFloat;
  wrkSingle : Single;
begin
  try
     AssignFile (ResFile,'ARM.dat');
     ReWrite (ResFile);
     Write (ResFile, Colors [1]);
     Write (ResFile, Colors [2]);
     Write (ResFile, Colors [3]);
     // ��������� ��������� �����
     Write (ResFile, PLPosition^ [1]);
     Write (ResFile, PLPosition^ [2]);
     Write (ResFile, PLPosition^ [3]);
     Write (ResFile, PLPosition^ [4]);

     // ����������� �����
     Write (ResFile, PRPosition^ [1]);
     Write (ResFile, PRPosition^ [2]);
     Write (ResFile, PRPosition^ [3]);

     // ������������� �����
     Write (ResFile, PFAmbient^ [1]);
     Write (ResFile, PFAmbient^ [2]);
     Write (ResFile, PFAmbient^ [3]);
     Write (ResFile, PFAmbient^ [4]);

     Write (ResFile, AngleXYZ [1]);  // ���� �������� ����� ������ �� ��� X
     Write (ResFile, AngleXYZ [2]);  // ���� �������� ����� ������ �� ��� Y
     Write (ResFile, AngleXYZ [3]);  // ���� �������� ����� ������ �� ��� Z
     Write (ResFile, Perspective);   // �����������

     // ������ ���������
     wrkSingle := PMaterials^;
     Write (ResFile, wrkSingle);

     // �������� - �������� �� ��������
     If flgSquare then wrkSingle := 1.0
                  else wrkSingle := 0.0;
     Write (ResFile, wrkSingle);

     // �������� - �������� �� ���
     If flgOc then wrkSingle := 1.0
              else wrkSingle := 0.0;
     Write (ResFile, wrkSingle);

     // �������� - �������� �� �������� �����
     If flgLight then wrkSingle := 1.0
                 else wrkSingle := 0.0;
     Write (ResFile, wrkSingle);

     // �������� - �������� �� ������
     If flgCursor then wrkSingle := 1.0
                 else wrkSingle := 0.0;
     Write (ResFile, wrkSingle);

  finally
     CloseFile (ResFile);
  end; // try
end;
