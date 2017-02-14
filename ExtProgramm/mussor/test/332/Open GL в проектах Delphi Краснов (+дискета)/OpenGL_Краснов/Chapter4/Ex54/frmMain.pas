{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Controls,
  SysUtils, Dialogs,
  OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC: HDC;
    hrc: HGLRC;
    Torus : GLint;
    procedure MakeList;
    procedure SetDCPixelFormat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  Angle : GLfloat = 0.0;

implementation

uses DGLUT;

{$R *.DFM}


{=======================================================================
���������� ������}
procedure TfrmGL.MakeList;
begin
 Torus := glGenLists(1);
 glNewList(Torus, GL_COMPILE);
    glutSolidTorus(5.0, 15.0, 16, 32);
 glEndList;
end;

{=======================================================================
����������� ����}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
 ps : TPaintStruct;
begin
 BeginPaint(Handle, ps);

 glPushMatrix;
 glViewport(0,0,round(ClientWidth/2), ClientHeight);
 glScissor(0,0,round(ClientWidth/2), ClientHeight);
 glClearColor(0.55, 0.9, 0.4,0.0);
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 glPushMatrix;
 gluLookAt(25.0,25.0,50.0,25.0,25.0,20.0,0.0,1.0,0.0);
 glTranslatef(25.0,25.0,10.0);
 glRotatef (Angle, 1.0, 0.0, 0.0);
 glCallList(Torus);
 glPopMatrix;

 // View 2
 glViewport(round(ClientWidth/2) + 1,round(ClientHeight/2) +1,
            round(ClientWidth/2), round(ClientHeight/2));
 glScissor(round(ClientWidth/2) + 1,round(ClientHeight/2) +1,
           round(ClientWidth/2), round(ClientHeight/2));
 glClearColor(0.7, 0.7, 0.9,0.0);
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 glPushMatrix;
 gluLookAt(25.0,50.0,50.0,25.0,25.0,20.0,0.0,1.0,0.0);
 glTranslatef(25.0,25.0,10.0);
 glRotatef (Angle, 1.0, 0.0, 0.0);
 glCallList(Torus);
 glPopMatrix;

 // View 3
 glViewport(round(ClientWidth/2) +1,0,round(ClientWidth/2),
            round(ClientHeight/2));
 glScissor(round(ClientWidth/2) +1,0,round(ClientWidth/2),round(ClientHeight/2));
 glClearColor(0.0, 0.6, 0.7, 0.0);
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 glPushMatrix;
 gluLookAt(0.0,25.0,50.0,25.0,25.0,20.0,0.0,1.0,0.0);
 glTranslatef(25.0,25.0,10.0);
 glRotatef (Angle, 1.0, 0.0, 0.0);
 glCallList(Torus);

 glPopMatrix;
 glPopMatrix;
 SwapBuffers(DC);
 EndPaint(Handle, ps);

 Angle := Angle + 2;
 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
�������� ����}
procedure TfrmGL.FormCreate(Sender: TObject);
const
  amb_dif : Array [0..3] of GLfloat = (0.2,0.8,1.0,1.0);
  spec : Array [0..3] of GLfloat = (1.0,1.0,1.0,1.0);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  glMaterialfv(GL_FRONT,GL_AMBIENT_AND_DIFFUSE, @amb_dif);
  glMaterialfv(GL_FRONT,GL_SPECULAR,@spec);
  glMaterialf(GL_FRONT,GL_SHININESS,50.0);

  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_SCISSOR_TEST);
  MakeList;
end;

{=======================================================================
��������� ������� �������}
procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
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
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluPerspective (60.0, ClientWidth / ClientHeight, 5.0, 70.0);
 glMatrixMode (GL_MODELVIEW);
 glLoadIdentity;
 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
����� ������ ���������}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  glDeleteLists (Torus, 1);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

end.

