{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
{**********************************************************************}

program ARM2;

uses
  Windows, Messages, mmSystem, OpenGL;

const
  AppName = 'Robot'; // ��� ����������

const // �������������� ������� ����
  id_param = 101;    // ����� "���������"
  id_about = 102;    // ����� "� �������"
  id_close = 103;    // ����� "�����"
  id_help = 104;     // ����� "������"

const
  znear : GLFloat = 300.0;

{$I Constants}

var
  AngleXYZ : Array [1..3] of GlFloat; // ������ �������� ������ ����
  AddXYZ : Array [1..3] of GlFloat;   // ������ ������ �� ����
  Colors : Array [1..3] of GlFloat;   // ������ ������ ��������� �����
  Window : HWnd;
  uTimerId : uint;  // ������������� �������
  Message : TMsg;
  WindowClass : TWndClass;
  dc : HDC;
  hrc : HGLRC;
  hcDll : THandle; // �������� ��� DLL
  gldAspect : GLdouble ;
  glnWidth, glnHeight : GLsizei;
  Perspective : GlFloat;
  flgOc : Boolean;       // ����, �������� �� ���
  flgRotation : Boolean; // ����, ������� �� ����
  flgLight : Boolean;    // ����, �������� �� �������� �����
  flgSquare : Boolean;   // ����, �������� �� ��������
  flgCursor : Boolean;   // ����, �������� �� ������

// �������
var
  ObjSphere : GLUquadricObj ;    // �������� �����
  Sp, SpDisk : GLUquadricObj ;   // ����������� � ������
  CylCentral : GLUquadricObj ;   // ����������� ���������
  Cpindel : GLUquadricObj ;      // ��������
  Patron : GLUquadricObj ;       // ������
  Disk1, Disk2 : GLUquadricObj ; // ����� �� ����� �������
  Detal : GLUquadricObj ;        // �������������� ������
  Cyl1, Cyl2 : GLUquadricObj ;   // ��������� ��� �����

// ���������� ��������� � ��������
var
  psi : GLFloat;         // ���� "���"
  tetta : GLFloat;       // ���� "�����"
  stepAngleX, stepAngleY, stepAngleZ : GLFloat;   // ��� ��������� ����
  AngleX, AngleY, AngleZ : GlFloat;
  t, stept : GLFloat;    // �����
  omega : GLFloat;       // ������� �������� - �����

var
  i, j : byte;

var                       // ����������, ��������� � ����
  MenuPopup : HMenu;      // ����������� ����

procedure FNTimeCallBack(uTimerID, uMessage: UINT;dwUser, dw1, dw2: DWORD) stdcall;
begin
  t := t + stept;
  AngleX := AngleX + stepAngleX;
  If (AngleX > 10.0) or (AngleX < -10.0) then  stepAngleX := -stepAngleX;
  AngleY := AngleY + stepAngleY;
  If (AngleY > 15.0) or (AngleY < -15.0) then stepAngleY := -stepAngleY;
  AngleZ := AngleZ + stepAngleZ;
  If (AngleZ > 360.0) then AngleZ := 0.0;

  InvalidateRect(Window, nil, False);
end;

{$I SetDC}     // ��������� ��������� ������� �������
{$I OcXYZ}     // ��������� ��������� ���
{$I Start}     // ��������� ��������� - ������ �� �����, �������� InitRC.dll
{$I SavePar}   // ��������� ������ ���������� � ����
{$I About}     // ��������� ������ ���� "�� �������" - ������ c DLL
{$I ParForm}   // ����� ����������� ���������� - ������ c DLL
{$I Hole}      // ��������� ���������
{$I Spring}    // �������
{$I Lists}     // ��������� �������� �������
{$I WinProc}   // ������� �������
{$I WinMain}   // ����� ����� � ���������

begin
  {���������, ���� �� ��������� �� ���������� ����� ����������}
  If FindWindow (AppName, AppName) <> 0  then Exit;

  // ��������� �������� - ���������
  SetPriorityClass (GetCurrentProcess(), HIGH_PRIORITY_CLASS);
  // �������� �������� �� ���������� InitRC.dll - ������������� ��������� �����
  hcDllMaterials := LoadLibrary('InitRC');
  If hcDllMaterials <= HINSTANCE_ERROR then begin
      MessageBox (0, '���������� ��������� ���� ���������� InitRC.dll',
                     '������ ������������� ���������', mb_OK);
      Exit
  end;

  WinMain;
end.

