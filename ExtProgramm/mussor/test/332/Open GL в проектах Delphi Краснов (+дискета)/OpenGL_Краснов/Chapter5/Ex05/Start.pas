// ��������� ���������
// �������� ���������� InitRC
// � ������ ������ �� �����

// ���������, ����������� �� ���������� InitRC
type
  Array3D = Array [1..3] of GlFloat;
  Array4D = Array [1..4] of GlFloat;
  TMaterial = 1..8;
  PMaterial = ^TMaterial;
  PArray3D = ^Array3D; // ��������� �� �������
  PArray4D = ^Array4D;
  TIncMaterials = procedure stdcall;
  TInitializeRC = procedure stdcall;
  TGetData = procedure (var PMaterials : PMaterial;
                        var PLPosition : PArray4D;
                        var PFAmbient  : PArray4D;
                        var PRPosition : PArray3D); stdcall;

var
  hcDllMaterials : THandle; // �������� ��� ���������� ��������� ���������
  IncMaterials : TIncMaterials;
  InitializeRC : TInitializeRC;
  GetData : TGetData;
  PMaterials : PMaterial; // ��������� �� ��������
  // ��������� �� ������� � ����������
  PLPosition : PArray4D;
  PFAmbient  : PArray4D;
  PRPosition : PArray3D;

procedure Start;
var
  flgFileError : Boolean;
  ResFile : File of GlFloat;
  wrk : TWIN32FindData;
  wrkSingle : Single;
begin
  // �������� �������� �� ���������� InitRC.dll - ������������� ��������� �����
  IncMaterials := GetProcAddress (hcDllMaterials, 'IncMaterials');
  InitializeRC := GetProcAddress (hcDllMaterials, 'InitializeRC');
  GetData := GetProcAddress (hcDllMaterials, 'GetData');
  GetData (PMaterials, // ��������� - �� �������� � ����������
           PLPosition, // ��������� - �� ������� � ����������
           PFAmbient,
           PRPosition);

  // ������ ������ �� ����� - ���������� ���������

  flgFileError := False; // ��������������� ���� - ������ ������ �����

  If FindFirstFile ('ARM2.dat', wrk) <> INVALID_HANDLE_VALUE then
  try
     AssignFile (ResFile,'ARM2.dat');
     Reset (ResFile);
    try
     Read (ResFile, Colors [1]);
     Read (ResFile, Colors [2]);
     Read (ResFile, Colors [3]);

      // ��������� ��������� �����
     Read (ResFile, PLPosition^ [1]);
     Read (ResFile, PLPosition^ [2]);
     Read (ResFile, PLPosition^ [3]);
     Read (ResFile, PLPosition^ [4]);

      // ����������� �����
     Read (ResFile, PRPosition^ [1]);
     Read (ResFile, PRPosition^ [2]);
     Read (ResFile, PRPosition^ [3]);

      // ������������� �����
     Read (ResFile, PFAmbient^ [1]);
     Read (ResFile, PFAmbient^ [2]);
     Read (ResFile, PFAmbient^ [3]);
     Read (ResFile, PFAmbient^ [4]);

     Read (ResFile, AngleXYZ [1]);  // ���� �������� ����� ������ �� ��� X
     Read (ResFile, AngleXYZ [2]);  // ���� �������� ����� ������ �� ��� Y
     Read (ResFile, AngleXYZ [3]);  // ���� �������� ����� ������ �� ��� Z
     Read (ResFile, Perspective);   // �����������

     Read (ResFile, AddXYZ [1]);    // ����� �� ��� X
     Read (ResFile, AddXYZ [2]);    // ����� �� ��� Y
     Read (ResFile, AddXYZ [3]);    // ����� �� ��� Z

     Read (ResFile, wrkSingle);     // ���������� ���������
     Case Round (wrkSingle) of      // �� ������� ������,
          1 : PMaterials^ := 8;     // ����� ��������������� IncMaterials
          2 : PMaterials^ := 1;
          3 : PMaterials^ := 2;
          4 : PMaterials^ := 3;
          5 : PMaterials^ := 4;
          6 : PMaterials^ := 5;
          7 : PMaterials^ := 6;
          8 : PMaterials^ := 7;
     end; // case
     IncMaterials;

     // �������� �� ��������
     Read (ResFile, wrkSingle);
     If wrkSingle = 1 then flgSquare := True
                      else flgSquare := False;

     // �������� �� ���
     Read (ResFile, wrkSingle);
     If wrkSingle = 1 then flgOc := True
                      else flgOc := False;

     // �������� �� �������� �����
     Read (ResFile, wrkSingle);
     If wrkSingle = 1 then flgLight := True
                      else flgLight := False;

     // �������� �� ������
     Read (ResFile, wrkSingle);
     If wrkSingle = 1 then flgCursor := True
                      else flgCursor := False;

    finally
     CloseFile (ResFile);
    end; // try
  except
     flgFileError := True;
  end // try
  else flgFileError := True;
  If  flgFileError then   // ������ ������ �����
  begin

      // ���� ��������� �����
      Colors [1] := 1.0;
      Colors [2] := 1.0;
      Colors [3] := 1.0;

      // ��������� ��������� �����
      PLPosition^ [1] := 0.5;
      PLPosition^ [2] := 0.5;
      PLPosition^ [3] := 0.5;
      PLPosition^ [4] := 0.0;

      // ����������� �����
      PRPosition^ [1] := 0.0;
      PRPosition^ [2] := 0.0;
      PRPosition^ [3] := -1.0;

      // ������������� �����
      PFAmbient^ [1] := 0.2;
      PFAmbient^ [2] := 0.2;
      PFAmbient^ [3] := 0.2;
      PFAmbient^ [4] := 1.0;

      AngleXYZ [1] := -90;  // ���� �������� ����� ������ �� ��� X
      AngleXYZ [2] := 0;    // ���� �������� ����� ������ �� ��� Y
      AngleXYZ [3] := 220;  // ���� �������� ����� ������ �� ��� Z
      Perspective := 25.0;  // �����������

      AddXYZ [1] := 0.0;    // ����� �� ��� X
      AddXYZ [2] := 0.0;    // ����� �� ��� Y
      AddXYZ [3] := 0.0;    // ����� �� ��� Z

      flgOc := False;       // ��� - �� ��������
      flgSquare := False;   // ����, �������� �� ��������
      flgLight := False;    // ����, �������� �� �������� �����
      flgCursor := False;   // ����, �������� �� ������

  end;
end;
