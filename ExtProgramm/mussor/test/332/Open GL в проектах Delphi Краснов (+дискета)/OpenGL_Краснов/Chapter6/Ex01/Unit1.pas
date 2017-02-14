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
 wglMakeCurrent(Canvas.Handle, hrc);

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

 SwapBuffers(Canvas.Handle);         // содержимое буфера - на экран
 wglMakeCurrent(0, 0);
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
 SetDCPixelFormat(Canvas.Handle);
 hrc := wglCreateContext(Canvas.Handle);
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglDeleteContext(hrc);
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
 R, G, B : GLfloat;
begin
  ColorToGL (Canvas.Pixels [X,Y], R, G, B);
  If (R <> 0) and (B = 0) then
     ShowMessage ('Выбран красный треугольник')
     else
     If (R = 0) and (B <> 0) then
     ShowMessage ('Выбран синий треугольник')
     else
     ShowMessage ('Ничего не выбрано');
end;

end.

