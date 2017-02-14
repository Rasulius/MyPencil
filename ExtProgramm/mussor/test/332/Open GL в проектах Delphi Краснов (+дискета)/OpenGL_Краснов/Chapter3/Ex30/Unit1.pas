{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpenGL, Menus;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
  private
    DC : HDC;
    hrc: HGLRC;
    ry : GLfloat;
    tx : GLfloat;
  end;

var
  frmGL: TfrmGL;
  mode : (POINT, LINE, FILL) = FILL;
  glutobj : (CUBE, SPHERE, CONE, TORUS, DODECAHEDRON,
             ICOSAHEDRON, TETRAHEDRON, TEAPOT) = CUBE;

implementation

uses DGLUT;

{$R *.DFM}

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);      // очистка буфера цвета

 glPushMatrix;

 glRotatef (ry, 0.0, 1.0, 0.0);
 glTranslatef (tx, 0.0, 0.0);

 case mode of
  POINT : glPolygonMode (GL_FRONT_AND_BACK, GL_POINT);
  LINE  : glPolygonMode (GL_FRONT_AND_BACK, GL_LINE);
  FILL  : glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
 end;

 case glutobj of
   TEAPOT : glutSolidTeapot (1.5);
   CUBE : glutSolidCube (1.5);
   SPHERE : glutSolidSphere (1.5, 20, 20);
   CONE : glutSolidCone (0.5, 1.5, 20, 20);
   TORUS : glutSolidTorus (0.5, 1.5, 20, 20);
   DODECAHEDRON : glutSolidDodecahedron;
   ICOSAHEDRON : glutSolidIcosahedron;
   TETRAHEDRON : glutSolidTetrahedron;
 end;

 glPopMatrix;

 SwapBuffers(DC);
end;

{=======================================================================
Формат пикселя}
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPixelFormatDescriptor;
 nPixelFormat : Integer;
begin
 FillChar (pfd, SizeOf (pfd), 0);
 pfd.dwFlags  := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
 nPixelFormat := ChoosePixelFormat (hdc, @pfd);
 SetPixelFormat (hdc, nPixelFormat, @pfd);
end;

{=======================================================================
Создание формы}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
 DC := GetDC (Handle);
 SetDCPixelFormat(DC);
 hrc := wglCreateContext(DC);
 wglMakeCurrent(DC, hrc);
 glClearColor (0.5, 0.5, 0.75, 1.0); // цвет фона
 glLineWidth (1.5);
 glEnable (GL_LIGHTING);
 glEnable (GL_LIGHT0);
 glEnable (GL_DEPTH_TEST);
 glEnable (GL_COLOR_MATERIAL);
 glColor3f (1.0, 0.0, 0.0);

 ry := 0.0;
 tx := 0.0;
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC (Handle, DC);
 DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close;
 If Key = VK_LEFT then begin
    ry := ry + 2.0;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_RIGHT then begin
    ry := ry - 2.0;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_UP then begin
    tx := tx - 0.1;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_DOWN then begin
    tx := tx + 0.1;
    InvalidateRect(Handle, nil, False);
 end;

 If Key = 49 then begin
    mode := POINT;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = 50 then begin
    mode := LINE;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = 51 then begin
    mode := FILL;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = 52 then begin
    Inc (glutobj);
    If glutobj > High (glutobj) then glutobj := Low (glutobj);
    InvalidateRect(Handle, nil, False);
 end;

end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode (GL_PROJECTION);
 glLoadIdentity;
 glFrustum (-1, 1, -1, 1, 2, 9);
 glMatrixMode (GL_MODELVIEW);
 glLoadIdentity;

 // этот фрагмент нужен для придания трёхмерности
 glTranslatef(0.0, 0.0, -5.0);   // перенос объекта - ось Z
 glRotatef(30.0, 1.0, 0.0, 0.0); // поворот объекта - ось X
 glRotatef(70.0, 0.0, 1.0, 0.0); // поворот объекта - ось Y

 InvalidateRect(Handle, nil, False);
end;


end.

