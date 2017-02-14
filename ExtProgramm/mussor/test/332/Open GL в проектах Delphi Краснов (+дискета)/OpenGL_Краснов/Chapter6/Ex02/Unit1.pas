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
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

  private
    DC : HDC;
    hrc: HGLRC;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 glViewPort (0, 0, ClientWidth, ClientHeight); // область вывода

 glClearColor (0.5, 0.5, 0.75, 1.0); // цвет фона
 glClear (GL_COLOR_BUFFER_BIT);      // очистка буфера цвета

 {--- красный треугольник ---}
 glColor3f (1.0, 0.0, 0.0);          // текущий цвет примитивов
 glBegin (GL_TRIANGLES);
   glVertex2f (-1, -1);
   glVertex2f (-1, 1);
   glVertex2f (-0.1, 0);
 glEnd;

 {--- синий треугольник ---}
 glColor3f (0.0, 0.0, 1.0);          // текущий цвет примитивов
 glBegin (GL_TRIANGLES);
   glVertex2f (0.1, 0);
   glVertex2f (1, 1);
   glVertex2f (1, -1);
 glEnd;

 SwapBuffers (DC);
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

procedure TfrmGL.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
{=======================================================================
Перевод цвета из TColor в OpenGL}
procedure ColorToGL (c : TColor; var R, G, B : GLfloat);
begin
 R := (c mod $100) / 255;
 G := ((c div $100) mod $100) / 255;
 B := (c div $10000) / 255;
end;
var
 wrk : Array [0..2] of GLUbyte;
begin
  glReadPixels (X, Y, 1, 1, GL_RGB, GL_UNSIGNED_BYTE, @wrk);
  If (wrk [0] <> 0) and (wrk [2] = 0) then
     ShowMessage ('Выбран красный треугольник')
     else
     If (wrk [0] = 0) and (wrk [2] <> 0) then
     ShowMessage ('Выбран синий треугольник')
     else
     ShowMessage ('Ничего не выбрано');
end;

end.

