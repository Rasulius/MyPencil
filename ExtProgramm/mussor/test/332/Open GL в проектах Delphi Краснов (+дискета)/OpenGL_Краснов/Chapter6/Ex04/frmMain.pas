{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Controls, Dialogs,
  OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

  private
    dc : HDC;
    hrc : HGLRC;
    qObj : GLUquadricObj ;
    Pixel : Array [0..2] of GLByte;

    procedure SetDCPixelFormat (dc : HDC);
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
  // массив свойств материала
  ColorSphere: Array[0..3] of GLfloat = (1.0, 0.0, 1.0, 1.0);
  ColorConus: Array[0..3] of GLfloat = (1.0, 0.0, 1.0, 1.0);

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
Перерисовка окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);
  wglMakeCurrent (dc, hrc);

  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @ColorSphere);
  gluSphere(qObj, 0.3, 20, 20);
  glRotatef (40, 0.0, 1.0, 1.0);

  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @ColorConus);
  glTranslatef(0.0 , -0.4, 0.0);
  gluCylinder (qObj, 0.25, 0.0, 0.8, 20, 20);

  SwapBuffers(dc);

  glDisable(GL_LIGHTING);

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glLoadIdentity;
  glTranslatef (0.0, 0.0, -8.0);

  glColor3f (1.0, 0.0, 0.0);
  gluSphere(qObj, 0.3, 20, 20);
  glRotatef (40, 0.0, 1.0, 1.0);

  glTranslatef(0.0 , -0.4, 0.0);
  glColor3f (0.0, 0.0, 1.0);
  gluCylinder (qObj, 0.25, 0.0, 0.8, 20, 20);

  wglMakeCurrent (0, 0);
  EndPaint(Handle, ps);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  dc := GetDC (Handle);
  SetDCPixelFormat (dc);
  hrc := wglCreateContext(dc);

  wglMakeCurrent(dc, hrc);

  glClearColor (0.5, 0.5, 0.75, 1.0);
  glEnable(GL_DEPTH_TEST);

  qObj := gluNewQuadric;
end;

{=======================================================================
Задаем формат пикселей}
procedure TfrmGL.SetDCPixelFormat (dc : HDC);
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
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(10.0, ClientWidth / ClientHeight, 1.0, 10.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef (0.0, 0.0, -8.0);
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  gluDeleteQuadric (qObj);
  wglDeleteContext (hrc);
  ReleaseDC (Handle, dc);
  DeleteDC (dc);
end;

procedure TfrmGL.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 wglMakeCurrent(dc, hrc);

 glReadPixels(X, ClientHeight - Y, 1, 1, GL_RGB, GL_UNSIGNED_BYTE, @Pixel);

 If (Pixel [0] <> 0) and (Pixel [2] = 0)
    then ShowMessage ('Выбрана сфера')
    else
    If (Pixel [0] = 0) and (Pixel [2] <> 0)
    then ShowMessage ('Выбран конус')
    else ShowMessage ('Ничего не выбрано');

 wglMakeCurrent(0, 0);
end;

end.

