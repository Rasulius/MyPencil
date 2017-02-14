{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;
interface

uses
 Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Controls,
 SysUtils, Dialogs,
 OpenGL;

type
  TfrmGL = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
  private
    DC: HDC;
    hrc: HGLRC;
    qObj : GLUquadricObj;

    procedure Init;
    procedure SetDCPixelFormat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  fRot : Boolean = True;
  theta : Integer;

implementation

{$R *.DFM}

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
  light_diffuse : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 0.0);
  light_specular : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 0.0);
  mat_specular : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 1.0);
  mat_shininess : GLfloat = 50.0;
begin
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @light_diffuse);
  glLightfv(GL_LIGHT0, GL_SPECULAR, @light_specular);
  glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, @mat_specular);
  glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, @mat_shininess);
  glColorMaterial(GL_FRONT_AND_BACK, GL_DIFFUSE);
  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, 1);

  glEnable(GL_COLOR_MATERIAL);
  glEnable(GL_LIGHT0);
  glEnable(GL_LIGHTING);

  // объект
  qObj := gluNewQuadric;

  // операции с трафаретом
  glStencilFunc(GL_EQUAL, 0, 1);
  glStencilOp(GL_INCR, GL_INCR, GL_INCR);
  glEnable(GL_STENCIL_TEST);
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint (Handle, ps);

  glClear(GL_COLOR_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);

  glPushMatrix;

  glPushMatrix;
  glColor3f(1.0, 0.0, 0.0);
  glTranslatef (45.0, 40.0, -150.0);
  gluSphere (qObj, 50.0, 20, 20);
  glPopMatrix;

  If fRot then glRotatef(theta, 1.0, 1.0, 0.0);

  glColorMask(False, False, False, False);
  glPushMatrix;
  // первая дырка
  glTranslatef(45.0,45.0,0.0);
  gluDisk(qObj,15.0,20.0,20,20);
  // вторая дырка
  glTranslatef(20.0,20.0,0.0);
  gluDisk(qObj,15.0,20.0,20,20);
  glPopMatrix;
  glColorMask(True, True, True, True);
  glColor3f(1.0, 1.0, 0.0);
  // площадка
  glBegin(GL_QUADS);
    glNormal3f(0.0, 0.0, 1.0);
    glVertex3f(0.0, 0.0, 0.0);
    glVertex3f(100.0, 0.0, 0.0);
    glVertex3f(100.0, 100.0, 0.0);
    glVertex3f(0.0, 100.0, 0.0);
  glEnd;

  glPopMatrix;

  SwapBuffers (DC);
  EndPaint (Handle, ps);
end;

{=======================================================================
Обработка нажатия клавиши}
procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
  If Key = VK_SPACE then fRot := not fRot;
end;

{=======================================================================
Обработка таймера}
procedure TfrmGL.Timer1Timer(Sender: TObject);
begin
  theta := (theta + 5) mod 360;
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
  Init;
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(50.0, 1.0, 50.0, 400.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef (-50.0, -50.0, -200.0);
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  gluDeleteQuadric (qObj);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
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


end.

