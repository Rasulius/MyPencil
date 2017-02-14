{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, OpenGL;

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

    procedure SetDCPixelFormat;
    procedure Init;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  Angle : GLint = 0;

implementation

uses DGLUT;

{$R *.DFM}

procedure decal_poly;
begin
    glBegin(GL_QUADS);
    glNormal3f(0.0, 0.0, -1.0);
    glVertex3i(-2, 2, 0);
    glVertex3i(-2, 3, 0);
    glVertex3i( 2, 3, 0);
    glVertex3i( 2, 2, 0);

    glVertex3f(-0.5, -3.0, 0);
    glVertex3f(-0.5, 2.0, 0);
    glVertex3f( 0.5, 2.0, 0);
    glVertex3f( 0.5,-3.0, 0);
    glEnd;
end;

procedure TfrmGL.Init;
const
    lightpos : Array [0..3] of GLfloat = (0.5, 0.75, 1.5, 1.0);
begin
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);

    glLightfv(GL_LIGHT0, GL_POSITION, @lightpos);
    glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
    glEnable(GL_COLOR_MATERIAL);
    glEnable(GL_NORMALIZE);
end;


procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);

    glEnable(GL_STENCIL_TEST);
    glStencilFunc(GL_ALWAYS, 1, 1);
    glStencilOp(GL_KEEP, GL_REPLACE, GL_REPLACE);
    glDepthFunc(GL_LESS);

    glPushMatrix();
    glColor3f(1.0, 0.0, 0.0);
    glTranslatef(0.0, 0.0, -10.0);
    glScalef(5.0, 5.0, 5.0);
    glRotatef(Angle, 0.0, 1.0, 0.0);
    glEnable(GL_NORMALIZE);
    glutSolidDodecahedron;
    glDisable(GL_NORMALIZE);
    glPopMatrix;

    glStencilFunc(GL_EQUAL, 1, 1);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    glDepthFunc(GL_ALWAYS);

    glPushMatrix;
    glTranslatef(0.0, 0.0, -10.0);
    glRotatef(angle, 0.0, 1.0, 0.0);
    glRotatef(58.2850, 0.0, 1.0, 0.0);
    glTranslatef(0.0, 0.0, -7.2650);
    glColor3f(0.0, 1.0, 0.0);
    decal_poly;
    glPopMatrix;

    glDisable(GL_STENCIL_TEST);

  SwapBuffers(DC);

  EndPaint(Handle, ps);

  Angle := (Angle + 2) mod 360;
  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  Init;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glOrtho(-10.0, 10.0, -10.0, 10.0, 0.0, 20.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  InvalidateRect(Handle, nil, False);
end;

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
 If Key = VK_ESCAPE then Close;
end;

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

end.

