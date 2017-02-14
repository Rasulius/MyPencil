{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Controls, SysUtils,
  Dialogs, StdCtrls,
  OpenGL;

type
  TfrmGL = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC: HDC;
    hrc: HGLRC;
    wrkX, wrkY : Array [0..5] of Single;
    vp : Array [0..3] of GLint;
    selectBuf : Array [0..128] of GLuint;// ����� ������

    procedure SetDCPixelFormat;
    procedure Render (mode : GLEnum);
    function DoSelect(x : GLint; y : GLint) : GLUInt;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
  // ������ ������� ���������
  MaterialColor: Array[0..3] of GLfloat = (0.5, 0.2, 0.5, 0.0);
  // ������������� ������
  CUBE = 1;
var
  frmGL: TfrmGL;

implementation

{$R *.DFM}


{=======================================================================
����� ������� � �����}
function TfrmGL.DoSelect(x : GLint; y : GLint) : GLUInt;
begin
  glRenderMode(GL_SELECT); // ����� ������
  // ����� ������ ����� ��� ������ ��������� ������
  glInitNames;             // ������������� ����� ����
  glPushName(0);           // ��������� ����� � ���� ����

  glGetIntegerv(GL_VIEWPORT, @vp);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPickMatrix(x, ClientHeight - y, 4, 4, @vp);
  gluPerspective(18.0, (ClientWidth - Memo1.Width) / ClientHeight, 6.0, 10.0);
  glViewport(0, 0, (ClientWidth - Memo1.Width), ClientHeight);
  glMatrixMode(GL_MODELVIEW);

  glClear(GL_COLOR_BUFFER_BIT);

  Render(GL_SELECT); // ������ ������ �������� � �������

  Result := glRenderMode(GL_RENDER);
end;

procedure TfrmGL.Render (mode : GLEnum);
var
  i : 0..5;
begin
  {���� ��������� ����� �������}
  For i := 0 to 5 do begin
  glPushMatrix;                    // ��������� �����

  glTranslatef (wrkX [i], wrkY [i], 0.0);
  glRotatef (-60 * i, 0.0, 0.0, 1.0); // ������� ������

  If mode = GL_SELECT then glLoadName (i);
  glCallList (CUBE);               // ��������� ���������� ������ - ����� ������

  glPopMatrix;                     // ��������� � �����
  end;
end;

{=======================================================================
����������� ����}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);
  // ������� ������ ����� � ������ �������
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  // ������������
  glLoadIdentity;
  glTranslatef(0.0, 0.0, -9.0);
  glRotatef(120.0, 1.0, 0.0, 1.0);

  Render (GL_RENDER);

  SwapBuffers(DC);                 // ����� ������
  EndPaint(Handle, ps);
end;

{=======================================================================
�������� ����}
procedure TfrmGL.FormCreate(Sender: TObject);
var
  i : 0..5;
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  glEnable(GL_DEPTH_TEST);// ��������� ���� �������
  glEnable(GL_LIGHTING); // ��������� ������ � �������������
  glEnable(GL_LIGHT0);   // �������� �������� ����� 0

  For i := 0 to 5 do begin
      wrkX [i] := sin (Pi / 3 * i);
      wrkY [i] := cos (Pi / 3 * i);
  end;

  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @MaterialColor);

  glNewList (CUBE, GL_Compile);
    glScalef (0.25, 0.25, 0.25); // �������� �������

    // ������� ����
    glBegin(GL_QUADS);
      glNormal3f(0.0, 0.0, 1.0);
      glVertex3f(1.0, 1.0, 1.0);
      glVertex3f(-1.0, 1.0, 1.0);
      glVertex3f(-1.0, -1.0, 1.0);
      glVertex3f(1.0, -1.0, 1.0);
    glEnd;

    glBegin(GL_QUADS);
      glNormal3f(-1.0, 0.0, 0.0);
      glVertex3f(-1.0, 1.0, 1.0);
      glVertex3f(-1.0, 1.0, -1.0);
      glVertex3f(-1.0, -1.0, -1.0);
      glVertex3f(-1.0, -1.0, 1.0);
    glEnd;

    glBegin(GL_QUADS);
      glNormal3f(1.0, 0.0, 0.0);
      glVertex3f(1.0, 1.0, 1.0);
      glVertex3f(1.0, -1.0, 1.0);
      glVertex3f(1.0, -1.0, -1.0);
      glVertex3f(1.0, 1.0, -1.0);
    glEnd;

    glBegin(GL_QUADS);
      glNormal3f(0.0, 1.0, 0.0);
      glVertex3f(-1.0, 1.0, -1.0);
      glVertex3f(-1.0, 1.0, 1.0);
      glVertex3f(1.0, 1.0, 1.0);
      glVertex3f(1.0, 1.0, -1.0);
    glEnd;

    glBegin(GL_QUADS);
      glNormal3f(0.0, -1.0, 0.0);
      glVertex3f(-1.0, -1.0, -1.0);
      glVertex3f(1.0, -1.0, -1.0);
      glVertex3f(1.0, -1.0, 1.0);
      glVertex3f(-1.0, -1.0, 1.0);
    glEnd;

    glScalef (4, 4, 4);                // �������������� �������

  glEndList;                           // ����� �������� ������
  glClearColor (0.25, 0.1, 0.25, 0.0);
  glSelectBuffer(SizeOf (selectBuf), @selectBuf); // �������� ������ ������
  Memo1.Clear;
end;

{=======================================================================
������������� ������ ��������}
procedure TfrmGL.SetDCPixelFormat;
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;
begin
  FillChar(pfd, SizeOf(pfd), 0);

  pfd.dwFlags   := PFD_DRAW_TO_WINDOW or
                 PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;
  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;

{=======================================================================
��������� �������� ����}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, (ClientWidth - Memo1.Width), ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(18.0, (ClientWidth - Memo1.Width) / ClientHeight, 6.0, 10.0);
  glMatrixMode(GL_MODELVIEW);
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
����� ������ ���������}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  glDeleteLists (CUBE, 1);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

procedure TfrmGL.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  hit, hits: GLUint;
begin
  hits := DoSelect (X, Y);
  Memo1.Clear;
  Memo1.Lines.Add(Format('�������� ��� �������� : %d',[hits]));
  For hit := 1 to hits do
    Memo1.Lines.Add(' ������ �' + IntToStr(hit) +
                    ' ���: ' + IntToStr(SelectBuf[(hit - 1)* 4 + 3]));
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close
end;

end.

