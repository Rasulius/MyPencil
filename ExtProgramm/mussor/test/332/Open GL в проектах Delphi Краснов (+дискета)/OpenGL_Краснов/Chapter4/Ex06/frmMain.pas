{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
 Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Controls,
 SysUtils, Dialogs, OpenGL;

type
  TfrmGL = class(TForm)
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC : HDC;
    hrc : HGLRC;
    Angle : GLfloat;

    procedure DrawScene;
    procedure SetDCPixelFormat;

  protected
    {��������� ��������� WM_PAINT - ������ ������� OnPaint}
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;

  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

const
  // ������ ������� ���������
  MaterialColor: Array [0..3] of GLfloat = (0.1, 0.0, 1.0, 1.0);

{=======================================================================
��������� ��������}
procedure TfrmGL.DrawScene;
begin
  // ������� ������ ����� � ������ �������
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix;

  glRotatef(Angle, 0.0, 1.0, 0.0); // ������� �� ����

  glScalef (0.2,0.2,0.2);

  glBegin (GL_POLYGON);
    glNormal3f (0, 1, 0);
    glVertex3f (6.875, 0, 0);
    glVertex3f (10, 0, 0);
    glVertex3f (10, 7.0606, 0);
    glVertex3f (8.2966, 8.764, 0);
    glVertex3f (6.8678, 8.764, 0);
    glVertex3f (6.8678, 4.5118, 0);
  glEnd;

  glBegin (GL_POLYGON);
    glVertex3f (3.1322, 4.5118, 0);
    glVertex3f (3.1424, 0, 0);
    glVertex3f (6.875, 0, 0);
    glVertex3f (6.8678, 4.5118, 0);
  glEnd;

  glBegin (GL_POLYGON);
    glVertex3f (3.1322, 4.5118, 0);
    glVertex3f (3.1322, 8.764, 0);
    glVertex3f (1.7034, 8.764, 0);
    glVertex3f (0, 7.0606, 0);
    glVertex3f (0, 0, 0);
    glVertex3f (3.1424, 0, 0);
  glEnd;

  glBegin (GL_POLYGON);
    glNormal3f (1.0, 0.0, 0.0);
    glVertex3f (10, 7.0606, 0);
    glVertex3f (10, 0, 0);
    glVertex3f (10, 0, -5);
    glVertex3f (10, 7.0606, -5);
  glEnd;

  glBegin (GL_POLYGON);
    glNormal3f (1.0, 1.0, 0.0);
    glVertex3f (8.2966, 8.764, 0);
    glVertex3f (10, 7.0606, 0);
    glVertex3f (10, 7.0606, -5);
    glVertex3f (8.2966, 8.764, -5);
  glEnd;

  glBegin (GL_POLYGON);
    glNormal3f (0.0, 1.0, 0.0);
    glVertex3f (6.8678, 8.764, 0);
    glVertex3f (8.2966, 8.764, 0);
    glVertex3f (8.2966, 8.764, -5);
    glVertex3f (6.8678, 8.764, -5);
  glEnd;

  glBegin (GL_POLYGON);
    glNormal3f (-1.0, 0.0, 0.0);
    glVertex3f (6.8678, 4.5118, 0);
    glVertex3f (6.8678, 8.764, 0);
    glVertex3f (6.8678, 8.764, -5);
    glVertex3f (6.8678, 4.5118, -5);
  glEnd;

  glBegin (GL_POLYGON);
    glNormal3f (0.0, 1.0, 0.0);
    glVertex3f (6.8678, 4.5118, -5);
    glVertex3f (3.1322, 4.5118, -5);
    glVertex3f (3.1322, 4.5118, 0);
    glVertex3f (6.8678, 4.5118, 0);
  glEnd;

  glBegin (GL_POLYGON);
    glNormal3f (1.0, 0.0, 0.0);
    glVertex3f (3.1322, 8.764, 0);
    glVertex3f (3.1322, 4.5118, 0);
    glVertex3f (3.1322, 4.5118, -5);
    glVertex3f (3.1322, 8.764, -5);
  glEnd;

  glBegin (GL_POLYGON);
    glNormal3f (0.0, 1.0, 0.0);
    glVertex3f (1.7034, 8.764, 0);
    glVertex3f (3.1322, 8.764, 0);
    glVertex3f (3.1322, 8.764, -5);
    glVertex3f (1.7034, 8.764, -5);
  glEnd;

  glBegin (GL_POLYGON);
    glNormal3f (-1.0, 1.0, 0);
    glVertex3f (0, 7.0606, 0);
    glVertex3f (1.7034, 8.764, 0);
    glVertex3f (1.7034, 8.764, -5);
    glVertex3f (0, 7.0606, -5);
  glEnd;

  glBegin (GL_POLYGON);
    glNormal3f (-1.0, 0.0, 0.0);
    glVertex3f (0, 7.0606, -5);
    glVertex3f (0, 0, -5);
    glVertex3f (0, 0, 0);
    glVertex3f (0, 7.0606, 0);
 glEnd;

 glBegin (GL_POLYGON);
    glNormal3f (0.0, -1.0, 0.0);
    glVertex3f (10, 0, 0);
    glVertex3f (6.875, 0, 0);
    glVertex3f (3.1424, 0, 0);
    glVertex3f (0, 0, 0);
    glVertex3f (0, 0, -5);
    glVertex3f (3.1424, 0, -5);
    glVertex3f (6.875, 0, -5);
    glVertex3f (10, 0, -5);
 glEnd;

 glBegin (GL_POLYGON);
    glNormal3f (0.0, 0.0, -1.0);
    glVertex3f (6.8678, 4.5118, -5);
    glVertex3f (6.8678, 8.764, -5);
    glVertex3f (8.2966, 8.764, -5);
    glVertex3f (10, 7.0606, -5);
    glVertex3f (10, 0, -5);
    glVertex3f (6.875, 0, -5);
 glEnd;

 glBegin (GL_POLYGON);
    glVertex3f (6.8678, 4.5118, -5);
    glVertex3f (6.875, 0, -5);
    glVertex3f (3.1424, 0, -5);
    glVertex3f (3.1322, 4.5118, -5);
 glEnd;

 glBegin (GL_POLYGON);
    glVertex3f (0, 7.0606, -5);
    glVertex3f (1.7034, 8.764, -5);
    glVertex3f (3.1322, 8.764, -5);
    glVertex3f (3.1322, 4.5118, -5);
    glVertex3f (3.1424, 0, -5);
    glVertex3f (0, 0, -5);
 glEnd;

 glPopMatrix;

 SwapBuffers(DC);   // ����� ������
end;

{=======================================================================
��������� �������}
procedure TfrmGL.TimerTimer(Sender: TObject);
begin
  // ������ "���" ���������� �������� ����
  Angle := Angle + 2.0;

  If (Angle >= 360.0) then Angle := 0.0;

  InvalidateRect(Handle, nil, False); // ����������� ������� (Windows API)
end;

{=======================================================================
�������� ����}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  Angle := 0;
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  glEnable(GL_DEPTH_TEST); // ��������� ���� �������
  glEnable(GL_LIGHTING);   // ��������� ������ � �������������
  glEnable(GL_LIGHT0);     // �������� �������� ����� 0
  // ���������� �������� ��������� - ������� ������� - ����������
  // ���� ��������� � ��������� ��������� ��������� - �������� �� �������
  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @MaterialColor);
  Timer.Enabled := True;
end;

{=======================================================================
��������� ������� ��������}
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
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(50.0, ClientWidth / ClientHeight, 1.0, 20.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;

  glTranslatef(0.0, -1.0, -6.0);
  glRotatef(30.0, 1.0, 0.0, 0.0);

  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
��������� ��������� WM_PAINT, ��������� ����}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);
  DrawScene;
  EndPaint(Handle, ps);
end;

{=======================================================================
����� ������ ���������}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  Timer.Enabled := False;
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESACPE then Close
end;

end.

