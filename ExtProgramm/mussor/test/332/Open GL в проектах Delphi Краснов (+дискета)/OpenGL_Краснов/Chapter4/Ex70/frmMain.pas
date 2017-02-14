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
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC: HDC;
    hrc: HGLRC;
    procedure SetDCPixelFormat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  a, b, c: GLfloat;
  Angle: GLfloat = 0.0;
  AngleSystem : GLfloat = 0.0;  

implementation

uses DGLUT;

{$R *.DFM}

procedure DrawScene (light : Boolean);
begin
  glPushMatrix;
    If light then begin
      glEnable (GL_LIGHTING);
      glEnable (GL_LIGHT0);
      glColor3f(1, 0.3, 0.5);
    end;
    glutsolidTorus(0.1, 0.2, 16, 16);
    If light then glColor3f(0.5, 0.8, 0.8);
    glTranslatef(0.05, 0.08,-0.2);
    glutSolidSphere(0.05, 16, 16);
    glTranslatef(0.2, 0.2, 0.4);
    glutsolidSphere(0.1, 16, 16);
    glTranslatef(0.3, 0.3, -0.2);
    If light then begin
      glDisable (GL_LIGHT0);
      glDisable (GL_LIGHTING);
    end;
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

  glPushMatrix;

  glPushMatrix;
    glColor3f(0.8, 0.8, 1);
    glRotatef(Angle, 0, 1, 0);
    glBegin(GL_POLYGON);
      glVertex3f(0.5, -0.5, 0.5);
      glVertex3f(0.5, 0.5, 0.5);
      glVertex3f(0.5, 0.5, -0.5);
      glVertex3f(0.5, -0.5, -0.5);
    glEnd;
  glPopMatrix;

  glPushMatrix;
    glClear(GL_STENCIL_BUFFER_BIT);
    glEnable(GL_STENCIL_TEST);
    glColor4f(0, 0, 0, 0.4);
    glTranslatef(0.5*c, 0, 0.5*a);
    glScaled(abs(a),1,abs(c));
    glDisable(GL_DEPTH_TEST);
    glRotatef(AngleSystem, 1, 1, 1);
    DrawScene (False);
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_STENCIL_TEST);
  glPopMatrix;

  glRotatef(AngleSystem, 1, 1, 1);
  DrawScene (True);

  glPopMatrix;
  SwapBuffers(DC);
  EndPaint(Handle, ps);

  Angle := Angle + 5;
  If Angle >= 360.0 then Angle := 0.0;
  AngleSystem := AngleSystem + 2.5;
  If AngleSystem >= 360.0 then AngleSystem := 0.0;
  a := -sin(Angle * Pi/180);
  b := 0;
  c := cos(Angle * Pi/180);
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

  glEnable(GL_DEPTH_TEST);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_COLOR_MATERIAL);
  glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);

  glClearStencil(0);
  glStencilOp(GL_INCR, GL_INCR, GL_INCR);
  glStencilFunc(GL_EQUAL, 0, $FF);
end;

{=======================================================================
Устанавливаем формат пикселей}
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
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(15, ClientWidth / ClientHeight, 1, 50);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(-0.5, -0.5, -8.0);
  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close
end;

end.

