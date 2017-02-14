{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
{**********************************************************************}

program ARM;

uses
  Windows, Messages, mmSystem, OpenGL;

const
  AppName = 'ARM'; // ��� ����������

const // �������������� ������� ����
  id_param = 101; // ����� "���������"
  id_about = 102; // ����� "� �������"
  id_close = 103; // ����� "�����"
  id_help = 104;  // ����� "������"

const
  PerspNear : GlFloat = 30.0; // ��������������� ���������, � ������
                              // ���������� �������� ������� ����������
var
  AngleXYZ : Array [1..3] of GlFloat; // ������ �������� ������ ����
  MyX, MyY : Array [0..5] of GlFloat; // ��������������� ������ ������� � ���������
  wrkArray : Array [0..5] of GlFloat; // ��������������� ������ ������� � ���������
  Colors : Array [1..3] of GlFloat;   // ������ ������ ��������� �����
  Styles : Array [1..2] of Cardinal;  // ����� (GL_FILL � ������)
  Window : HWnd;
  uTimerId : uint;  // ������������� �������
  Message : TMsg;
  WindowClass : TWndClass;
  dc : HDC;
  hrc : HGLRC;
  hcDll : THandle; // �������� ��� DLL
  hcDllMaterials : THandle; // �������� ��� ���������� ��������� ���������
  glnWidth, glnHeight : GLsizei;
  ObjSphere, ObjCylinder : GLUquadricObj ;
  Angle : GlFloat;
  Perspective : GlFloat;
  flgOc : Boolean;       // ����, �������� �� ���
  flgRotation : Boolean; // ����, ������� �� ����
  flgLight : Boolean;    // ����, �������� �� �������� �����
  flgSquare : Boolean;   // ����, �������� �� ��������
  flgCursor : Boolean;   // ����, �������� �� ������

var
  i, j : byte;
  wrkI : byte;            // ������� �������� ������
  hStopki : GlFloat;      // ������ ������ ���������
  // ��������������� ������� - ��� ��������� ���������
  wrkArraySin : Array [1..20] of Single;
  wrkArrayCos : Array [1..20] of Single;

var                       // ����������, ��������� � ����
  MenuPopup : HMenu;      // ����������� ����

procedure FNTimeCallBack(uTimerID, uMessage: UINT;dwUser, dw1, dw2: DWORD) stdcall;
begin
  Angle := Angle + 0.1;
  If Angle > 60.0 then begin
      Angle := 0.0;
      flgRotation := False; // ���������� �������� �������� �����
  end;
  InvalidateRect(Window, nil, False);
end;

{$I SetDC}     // ��������� ��������� ������� �������
{$I OcXYZ}     // ��������� ��������� ���
{$I Start}     // ��������� ��������� - ������ �� �����, �������� InitRC.dll
{$I SavePar}   // ��������� ������ ���������� � ����
{$I Texture}   // ���������, ��������� � ���������
{$I About}     // ��������� ������ ���� "�� �������" - ������ c DLL
{$I ParForm}   // ����� ����������� ���������� - ������ c DLL
{$I Lists}     // ��������� �������� �������
{$I WinProc}   // ������� �������
{$I WinMain}   // ����� ����� � ���������

begin
 // ��������� ���� �� ��������� �� ���������� ����� ����������
 If FindWindow (AppName, AppName) <> 0  then Exit;

 // ��������� �������� - ���������
 SetPriorityClass (GetCurrentProcess, HIGH_PRIORITY_CLASS);

 // �������� �������� �� ���������� InitRC.dll - ������������� ��������� �����
 hcDllMaterials := LoadLibrary('InitRC');
 If hcDllMaterials <= HINSTANCE_ERROR then begin
      MessageBox (0, '���������� ��������� ���� ���������� InitRC.dll',
                     '������ ������������� ���������', mb_OK);
      Exit
 end;

 WinMain;
end.
