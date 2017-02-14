{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);

  private
    DC: HDC;
    hrc: HGLRC;

    procedure SetDCPixelFormat;
    procedure DrawFloor;
    procedure DrawObjects;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  Angle: GLint = 0;

implementation

uses DGLUT;

{$R *.DFM}

procedure TfrmGL.DrawFloor;
begin
  glPushMatrix;
    glColor4f(0.5, 0.5, 0.5, 0.8);
    glBegin(GL_QUADS);
      glTexCoord2f(0, 1);  glVertex3f(-2, 0, 2);
      glTexCoord2f(1, 1);  glVertex3f(2, 0, 2);
      glTexCoord2f(1, 0);  glVertex3f(2, 0, -2);
      glTexCoord2f(0, 0);  glVertex3f(-2, 0, -2);
    glEnd;
  glPopMatrix;
end;

procedure TfrmGL.DrawObjects;
begin
  glPushMatrix;
    glColor3f(1, 0, 0);
    glTranslatef(0, 0.5, 0);
    glRotatef(Angle, 1, 0.5, 0);
    glutSolidTorus(0.1, 0.3, 16, 32);
    glTranslatef(0, 0, -0.25);
    glColor3f(0, 0.5, 0);
    glPushMatrix;
    glScalef (0.05, 0.05, 0.05);
    glutSolidDodecahedron;
    glPopMatrix;
    glPushMatrix;
    glTranslatef(0, 0, 0.5);
    glColor3f(0, 0, 1);
    glScalef (0.05, 0.05, 0.05);
    glutSolidDodecahedron;
    glPopMatrix;
  glPopMatrix;
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;
  glTranslatef(0, -0.5, -4);

  glEnable(GL_STENCIL_TEST);
  glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);
  glStencilFunc(GL_ALWAYS, 1, $FFFF);
  glColorMask(FALSE, FALSE, FALSE, FALSE);
  glDisable(GL_DEPTH_TEST);
  DrawFloor;

  glColorMask(TRUE, TRUE, TRUE, TRUE);
  glEnable(GL_DEPTH_TEST);

  glStencilFunc(GL_EQUAL, 1, $FFFF);
  glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
  glPushMatrix;
    glScalef(1, -1, 1);
    DrawObjects;
  glPopMatrix;

  glDepthMask(FALSE);
  DrawFloor;
  glDepthMask(TRUE);
  glDisable(GL_STENCIL_TEST);
  DrawObjects;
  glFinish;

  SwapBuffers(DC);                 // конец работы
  EndPaint(Handle, ps);

  Angle := (Angle + 2) mod 360;
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_COLOR_MATERIAL);
  glColorMaterial(GL_FRONT_AND_BACK, GL_DIFFUSE);

  glEnable(GL_DEPTH_TEST);
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glEnable(GL_NORMALIZE);

  glClearColor (0.25, 0.1, 0.25, 0.0);
  glClearStencil(0);
end;

{=======================================================================
Устанавливаем формат пикселей}
procedure TfrmGL.SetDCPixelFormat;
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;
begin
  FillChar(pfd, SizeOf(pfd), 0);

  pfd.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;

  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight );
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(35, 1, 2, 6);
  glMatrixMode(GL_MODELVIEW);
  InvalidateRect(Handle, nil, False);
end;

end.

