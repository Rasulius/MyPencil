{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{/*
 *  screendoor.c
 *  Celeste Fowler, 1997
 *
 *  An example of using screen-door transparency.
 *
 */}

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

    cone, base, qsphere : GLUquadricObj;
    procedure draw_cone;
    procedure draw_sphere(angle : GLdouble);
    procedure SetDCPixelFormat;
    procedure Init;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  Angle : GLfloat = 0;
  time : LongInt;

implementation

uses DGLUT;

{$R *.DFM}

type
 TPattern = Array [0..31] of GLuint;

var
 spherePattern : TPattern;

procedure create_stipple_pattern(var pat : TPattern; opacity : GLfloat);
var
  x, y : GLint;
begin
  For y := 0 to 31 do begin
    pat[y] := 0;
    For x := 0 to 31 do
      If (random > 0.6) then pat[y] := pat[y] xor (1 shl x);
  end;
end;

procedure TfrmGL.Init;
const
    lightpos : Array [0..3] of GLfloat = (0.5, 0.75, 1.5, 1.0);
begin
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);

    glLightfv(GL_LIGHT0, GL_POSITION, @lightpos);

    cone := gluNewQuadric;
    base := gluNewQuadric;
    qsphere := gluNewQuadric;
    gluQuadricOrientation(base, GLU_INSIDE);

    create_stipple_pattern(spherePattern, 0.5);
    glPolygonStipple(@spherePattern);
end;

procedure draw_room;
const
    //* material for the walls, floor, ceiling */
    wall_mat : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 1.0);
begin
    glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @wall_mat);

    glBegin(GL_QUADS);

    //* floor */
    glNormal3f(0, 1, 0);
    glVertex3f(-1, -1, 1);
    glVertex3f(1, -1, 1);
    glVertex3f(1, -1, -1);
    glVertex3f(-1, -1, -1);

    //* ceiling */
    glNormal3f(0, -1, 0);
    glVertex3f(-1, 1, -1);
    glVertex3f(1, 1, -1);
    glVertex3f(1, 1, 1);
    glVertex3f(-1, 1, 1);

    //* left wall */
    glNormal3f(1, 0, 0);
    glVertex3f(-1, -1, -1);
    glVertex3f(-1, -1, 1);
    glVertex3f(-1, 1, 1);
    glVertex3f(-1, 1, -1);

    //* right wall */
    glNormal3f(-1, 0, 0);
    glVertex3f(1, 1, -1);
    glVertex3f(1, 1, 1);
    glVertex3f(1, -1, 1);
    glVertex3f(1, -1, -1);

    //* far wall */
    glNormal3f(0, 0, 1);
    glVertex3f(-1, -1, -1);
    glVertex3f(1, -1, -1);
    glVertex3f(1, 1, -1);
    glVertex3f(-1, 1, -1);

    glEnd();
end;

procedure TfrmGL.draw_cone;
const
    cone_mat : Array [0..3] of GLfloat = (0.0, 0.5, 1.0, 1.0);
begin
    glPushMatrix();
    glTranslatef(0, -1, 0);
    glRotatef(-90, 1, 0, 0);

    glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @cone_mat);
    gluCylinder(cone, 0.3, 0, 1.25, 20, 1);
    gluDisk(base, 0.0, 0.3, 20, 1);

    glPopMatrix();
end;

procedure TfrmGL.draw_sphere(angle : GLdouble);
const
    sphere_mat : Array [0..3] of GLfloat = (1.0, 0.5, 0.0, 0.5);
begin
    glPushMatrix();
    glTranslatef(0, -0.3, 0);
    glRotatef(angle, 0, 1, 0);
    glTranslatef(0, 0, 0.6);

    glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @sphere_mat);
    gluSphere(qsphere, 0.3, 20, 20);

    glPopMatrix();
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

procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  Init;
  time := GetTickCount;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(60, 1, 0.01, 10);
  gluLookAt(0, 0, 2.577, 0, 0, -5, 0, 1, 0);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;

  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

    draw_room;
    draw_cone;

    glEnable(GL_POLYGON_STIPPLE);
    draw_sphere(Angle);
    glDisable(GL_POLYGON_STIPPLE);


  SwapBuffers(DC);

  EndPaint(Handle, ps);

  Angle := Angle + 0.25 * (GetTickCount - time) * 360 / 1000;
  If Angle >= 360.0 then Angle := 0.0;
  time := GetTickCount;

  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  gluDeleteQuadric (cone);
  gluDeleteQuadric (base);
  gluDeleteQuadric (qsphere);
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

end.

