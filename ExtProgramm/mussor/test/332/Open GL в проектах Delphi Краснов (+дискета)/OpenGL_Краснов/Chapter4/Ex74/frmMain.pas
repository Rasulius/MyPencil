{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{/*
 *	mirror.c 	- This program demonstrate a mirror reflection.
 *			(An obedient version :)
 *
 *			Takehiko Terada (terada@sgi.co.jp)
 *			1997/09/09
 *			1997/09/17	ver 0.2 some bug fix(add scalef(-1))
 *					(Thanks to Ishikawa-san@CSK)
 *			1997/09/17	ver 0.3 fix the lookat bug
 *			1997/10/17	ver 0.4 fix the front-back face bug
 *					(Thanks to Yamaho-san@Hitachi)
 */}

unit frmMain;

interface

uses
 Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
 ExtCtrls, OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC : HDC;
    hrc : HGLRC;
    procedure InitializeRC;
    procedure SetDCPixelFormat;

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

{=======================================================================
Процедура инициализации источника цвета}
procedure TfrmGL.InitializeRC;
const
  mat_specular : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 1.0);
  light_position : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 0.0);
  mat_shininess = 50.0;
begin
  glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_specular);
  glMaterialf (GL_FRONT, GL_SHININESS, mat_shininess);
  glLightfv(GL_LIGHT0, GL_POSITION, @light_position);

  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
end;

{=======================================================================
Отрисовка картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
  a, b : GLfloat;
begin
  BeginPaint(Handle, ps);
  {/*
    * Normal view
    */}
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(45.0, ClientWidth / ClientHeight, 0.1, 100.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  gluLookAt(0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glPushMatrix;
    glRotatef(Angle, 0.0, 1.0, 0.0);
    glCallList(1);
  glPopMatrix;

  {/*
   * Mirror view
   */}
  glDisable(GL_LIGHTING);
  glViewport(ClientWidth shr 2, ClientHeight-(ClientHeight shr 2), ClientWidth shr 1, ClientHeight shr 3);
  glEnable(GL_SCISSOR_TEST);
  glScissor(ClientWidth shr 2, ClientHeight-(ClientHeight shr 2), ClientWidth shr 1, ClientHeight shr 3);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;

  //* Why 1.001 ? Just a tips, don't mind. :-) */
  glOrtho(-1.001, 1.001, -1.001, 1.001, -1.001, 1.001);

  glColor3f(1.0, 1.0, 1.0);
  glBegin(GL_LINE_LOOP);
    glVertex3i(-1, 1, 1);
    glVertex3i( 1, 1, 1);
    glVertex3i( 1,-1, 1);
    glVertex3i(-1,-1, 1);
  glEnd;
  glLoadIdentity;
  a := (ClientWidth shr 1) / (ClientHeight shr 3);
  b := (ClientHeight shr 3)/ (ClientWidth shr 1);
  gluPerspective(45.0*b, a, 0.1, 100.0);

  //* You can change these parameters if you want a real result. */
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  gluLookAt( 0.0, 0.0,-1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
  glEnable(GL_LIGHTING);
  glScalef(-1.0, 1.0, 1.0);

  glFrontFace(GL_CW);
  glPushMatrix;
    glRotatef(Angle, 0.0, 1.0, 0.0);
    glCallList(1);
  glPopMatrix;
  glFrontFace(GL_CCW);
  glDisable(GL_SCISSOR_TEST);

  SwapBuffers(DC);
  EndPaint(Handle, ps);

  Angle := Angle + 0.25 * (GetTickCount - time) * 360 / 1000;
  If Angle >= 360.0 then Angle := 0.0;
  time := GetTickCount;

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
  InitializeRC;

  glNewList(2, GL_COMPILE);
    glutSolidCube(1.0);
  glEndList;

  glNewList(1, GL_COMPILE);
  glPushMatrix;
    glTranslatef(3.0, 0.0, 0.0);
    glColor3f(0.0, 1.0, 0.0);
    glCallList(2);
  glPopMatrix;
  glPushMatrix;
    glTranslatef(-3.0, 0.0, 0.0);
    glColor3f(1.0, 0.0, 0.0);
    glCallList(2);
  glPopMatrix;
  glPushMatrix;
    glTranslatef(0.0, 0.0, 3.0);
    glColor3f(0.0, 0.0, 1.0);
    glCallList(2);
  glPopMatrix;
  glPushMatrix;
    glTranslatef(0.0, 0.0,-3.0);
    glColor3f(1.0, 1.0, 1.0);
    glCallList(2);
  glPopMatrix;
  glEndList;

  glClearColor (0.0, 0.0, 0.0, 0.0);
  glShadeModel (GL_SMOOTH);
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_COLOR_MATERIAL);
  glEnable(GL_CULL_FACE);

  time := GetTickCount;
end;

{=======================================================================
Установка формата пикселей}
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
  glDeleteLists (1, 2);
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

end.

