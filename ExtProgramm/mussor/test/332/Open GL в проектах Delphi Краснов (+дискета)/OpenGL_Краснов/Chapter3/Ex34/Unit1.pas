{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpenGL;

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
    quadObj : GLUquadricObj;
  end;

var
  frmGL: TfrmGL;
  mode : (POINT, LINE, FILL, SILHOUETTE) = FILL;
  gluobj : (SPHERE, CONE, CYLINDER, DISK) = SPHERE;
  orientation : (OUTSIDE, INSIDE) = OUTSIDE;
  normals : (NONE, FLAT, SMOOTH) = SMOOTH;

implementation

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
   POINT : gluQuadricDrawStyle (quadObj, GLU_POINT);
   LINE  : gluQuadricDrawStyle (quadObj, GLU_LINE);
   FILL  : gluQuadricDrawStyle (quadObj, GLU_FILL);
   SILHOUETTE : gluQuadricDrawStyle (quadObj, GLU_SILHOUETTE);
 end;

 case orientation of
   INSIDE : gluQuadricOrientation (quadObj, GLU_INSIDE);
   OUTSIDE : gluQuadricOrientation (quadObj, GLU_OUTSIDE);
 end;

 case normals of
   NONE : gluQuadricNormals (quadObj, GLU_NONE);
   FLAT : gluQuadricNormals (quadObj, GLU_FLAT);
   SMOOTH : gluQuadricNormals (quadObj, GLU_SMOOTH);
 end;

 case gluobj of
   SPHERE : gluSphere (quadObj, 1.5, 10, 10);
   CONE : gluCylinder (quadObj, 0.0, 1.0, 1.5, 10, 10);
   CYLINDER : gluCylinder (quadObj, 1.0, 1.0, 1.5, 10, 10);
   DISK : gluDisk (quadObj, 0.0, 1.5, 10, 5);
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
 quadObj := gluNewQuadric;

 ry := 0.0;
 tx := 0.0;
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 gluDeleteQuadric (quadObj);
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
    Inc (mode);
    If mode > High (mode) then mode := Low (mode);
    InvalidateRect(Handle, nil, False);
 end;
 If Key = 50 then begin
    Inc (gluobj);
    If gluobj > High (gluobj) then gluobj := Low (gluobj);
    InvalidateRect(Handle, nil, False);
 end;
 If Key = 51 then begin
    If orientation = INSIDE
       then orientation := OUTSIDE
       else orientation := INSIDE;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = 52 then begin
    Inc (normals);
    If normals > High (normals) then normals := Low (normals);
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

