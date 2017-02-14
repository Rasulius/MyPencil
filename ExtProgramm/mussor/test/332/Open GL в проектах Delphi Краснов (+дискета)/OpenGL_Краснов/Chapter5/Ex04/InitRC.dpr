{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
{**********************************************************************}

// ���������� ���������� ������ � ���������,
// ��������� � ���������� ����� � ����������
// ������ � ��������� ������������ � �������� ������ �
// �� ���������� ���� ����������

library InitRC;

uses
  OpenGL;

type
  Array3D = Array [1..3] of GlFloat;
  Array4D = Array [1..4] of GlFloat;
  TMaterial = 1..8;
  PMaterial = ^TMaterial;
  PArray3D = ^Array3D;
  PArray4D = ^Array4D;

var
  Materials : TMaterial;      // ������� ��������
  Material : Array [1..3] of PGlfloat; // ������ ���������� ������� �������� ���������
  LPosition : Array4D; // ������ ��������� ��������� �����
  FAmbient  : Array4D; // ������ ���������� ������� ��������� �����, ������������� �����
  LDirection : Array3D; // ������ ����������� ��������� �����

const
  // �������
  // ������� �������� ����� ���������
  AmbSteel : Array[0..3] of GLfloat = (0.19225, 0.19225, 0.19225, 1.0);
  // ������� ��������� ������� ���������
  DifSteel : Array[0..3] of GLfloat = (0.50754, 0.50754, 0.50754, 1.0);
  // ������� ����������� �����
  SpecSteel: Array[0..3] of GLfloat = (0.508273, 0.508273, 0.508273, 1.0);

  // ������
  // ������� �������� ����� ���������
  AmbLatun : Array[0..3] of GLfloat = (0.329412, 0.223529, 0.027451, 1.0);
  // ������� ��������� ������� ���������
  DifLatun : Array[0..3] of GLfloat = (0.780392, 0.568627, 0.113725, 1.0);
  // ������� ����������� �����
  SpecLatun: Array[0..3] of GLfloat = (0.992157, 0.941176, 0.807843, 1.0);

  // ������
  // ������� �������� ����� ���������
  AmbBronza : Array[0..3] of GLfloat = (0.2125, 0.1275, 0.054, 1.0);
  // ������� ��������� ������� ���������
  DifBronza : Array[0..3] of GLfloat = (0.714, 0.4284, 0.18144, 1.0);
  // ������� ����������� �����
  SpecBronza : Array[0..3] of GLfloat = (0.393548, 0.271906, 0.166721, 1.0);

  // ����
  // ������� �������� ����� ���������
  AmbXPOM : Array[0..3] of GLfloat = (0.25, 0.25, 0.25, 1.0);
  // ������� ��������� ������� ���������
  DifXPOM : Array[0..3] of GLfloat = (0.4, 0.4, 0.4, 1.0);
  // ������� ����������� �����
  SpecXPOM : Array[0..3] of GLfloat = (0.774597, 0.774597, 0.774597, 1.0);

  // ������� ������
  // ������� �������� ����� ���������
  AmbRedK : Array[0..3] of GLfloat = (0.05, 0.0, 0.0, 1.0);
  // ������� ��������� ������� ���������
  DifRedK : Array[0..3] of GLfloat = (0.5, 0.4, 0.4, 1.0);
  // ������� ����������� �����
  SpecRedK : Array[0..3] of GLfloat = (0.7, 0.04, 0.04, 1.0);

  // ������������� ������
  // ������� �������� ����� ���������
  AmbGlassV : Array[0..3] of GLfloat = (0.05375, 0.05, 0.06625, 1.0);
  // ������� ��������� ������� ���������
  DifGlassV : Array[0..3] of GLfloat = (0.18275, 0.17, 0.22525, 1.0);
  // ������� ����������� �����
  SpecGlassV : Array[0..3] of GLfloat = (0.332741, 0.328634, 0.346435, 1.0);

  // �������� �������
  // ������� �������� ����� ���������
  AmbCyanP : Array[0..3] of GLfloat = (0.0, 0.1, 0.06, 1.0);
  // ������� ��������� ������� ���������
  DifCyanP : Array[0..3] of GLfloat = (0.0, 0.50980392, 0.50980392, 1.0);
  // ������� ����������� �����
  SpecCyanP : Array[0..3] of GLfloat = (0.50196078, 0.50196078, 0.50196078, 1.0);

  // ������
  AmbGold : Array[0..3] of GLfloat = (0.24725, 0.1995, 0.0745, 1.0);
  DifGold : Array[0..3] of GLfloat = (0.75164, 0.60648, 0.22648, 1.0);
  SpecGold : Array[0..3] of GLfloat = (0.628281, 0.555802, 0.366065, 1.0);

// ��������� ������������� ��������� �����
procedure InitializeRC; export; stdcall;
begin
  glEnable(GL_DEPTH_TEST);// ��������� ���� �������
  glEnable (GL_COLOR_MATERIAL);
  glEnable(GL_NORMALIZE);

  // ��������� �������� ����� 0
  glLightfv(GL_LIGHT0, GL_AMBIENT, Material [1]); // ������� ���� ���������
  glLightfv(GL_LIGHT0, GL_DIFFUSE, Material [2]); // ��������� �������� ���������
  glLightfv(GL_LIGHT0, GL_SPECULAR,Material [3]); // ���������� ���� ���������

  // ��������� ��������� �����
  glLightfv(GL_LIGHT0, GL_POSITION, @LPosition);
  // ����������� �����
  glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, @LDirection);

  // ������� ������ � ������� ������������
  glLightModelfv (GL_LIGHT_MODEL_AMBIENT, @FAmbient); // ������� ������������

  glEnable(GL_LIGHTING); // ��������� ������ � �������������
  glEnable(GL_LIGHT0);   // �������� �������� ����� 0
end;

// ��������� ��������� ���������� ���������
procedure SetMaterial; export; stdcall;
begin
  Case Materials of
  1 : begin
      Material [1] := @AmbBronza;
      Material [2] := @DifBronza;
      Material [3] := @SpecBronza;
      glMaterialf(GL_FRONT, GL_SHININESS, 25.6); // ������ - 0.2*128.0
      end;
  2 : begin
      Material [1] := @AmbSteel;
      Material [2] := @DifSteel;
      Material [3] := @SpecSteel;
      glMaterialf(GL_FRONT, GL_SHININESS, 51.2);//0.4*128.0); - �������
      end;
  3 : begin
      Material [1] := @AmbLatun;
      Material [2] := @DifLatun;
      Material [3] := @SpecLatun;
      glMaterialf(GL_FRONT, GL_SHININESS, 27.89743616); // ������ - 0.21794872*128.0
      end;
  4 : begin
      Material [1] := @AmbXPOM;
      Material [2] := @DifXPOM;
      Material [3] := @SpecXPOM;
      glMaterialf(GL_FRONT, GL_SHININESS, 76.8); // ���� - 0.6*128.0
      end;
  5 : begin
      Material [1] := @AmbRedK;
      Material [2] := @DifRedK;
      Material [3] := @SpecRedK;
      glMaterialf(GL_FRONT, GL_SHININESS, 10.0); // ������� ������ - .078125*128.0
      end;
  6 : begin
      Material [1] := @AmbGlassV;
      Material [2] := @DifGlassV;
      Material [3] := @SpecGlassV;
      glMaterialf(GL_FRONT, GL_SHININESS, 38.4); // ������������� ������ - .3*128.0
      end;
  7 : begin
      Material [1] := @AmbCyanP;
      Material [2] := @DifCyanP;
      Material [3] := @SpecCyanP;
      glMaterialf(GL_FRONT, GL_SHININESS, 32.0); // �������� ������� - .25*128.0
      end;
  8 : begin
      Material [1] := @AmbGold;
      Material [2] := @DifGold;
      Material [3] := @SpecGold;
      glMaterialf(GL_FRONT, GL_SHININESS, 51.2); // ������ - .4*128.0
      end;
  end; // case
  // ���� ��������� � ��������� ��������� ��������� - �������� �� �������
  glMaterialfv (GL_FRONT, GL_AMBIENT, Material [1]);
  glMaterialfv (GL_FRONT, GL_DIFFUSE, Material [2]);
  glMaterialfv (GL_FRONT, GL_SPECULAR, Material [3]);
  InitializeRC;
end;

// ��������� ���������� ��������� ���������
// ���������� ��� ������� �� ������� "M"
procedure IncMaterials; export; stdcall;
begin
  Inc (Materials);
  If Materials > 8 then Materials := 1; // ���������� ����������
  SetMaterial; // ��� �������� ����� �� ��������������� ��������
end;

// ��������� ���������� ��� ������� ����������
// ��������� ������ �������� ���������� �� ������ ������ DLL
// ���������� ���������� �������� ����������
procedure GetData (var PMaterials : PMaterial;
                   var PLPosition : PArray4D;
                   var PFAmbient  : PArray4D;
                   var PLDirection : PArray3D); export; stdcall;
begin
  PMaterials := @Materials;
  PLPosition := @LPosition;
  PFAmbient  := @FAmbient;
  PLDirection := @LDirection;
end;

exports { ������ �������������� ������� }
        InitializeRC,
        SetMaterial,
        IncMaterials,
        GetData;
begin // ������������� ����������
  // ��� ������������� �������� ������ "������"
  // ���� �������� ����������� �� �����, �������������� ��������� ����������

  Materials := 1;

  Material [1] := @AmbBronza;
  Material [2] := @DifBronza;
  Material [3] := @SpecBronza;
  // ���� ��������� � ��������� ��������� ��������� - �������� �� �������
  glMaterialfv(GL_FRONT, GL_AMBIENT, Material [1]);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, Material [2]);
  glMaterialfv(GL_FRONT, GL_SPECULAR, Material [3]);
  glMaterialf(GL_FRONT, GL_SHININESS, 51.2);
end.
