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

 glViewPort (0, 0, round (ClientWidth / 2), ClientHeight); // область вывода

 glClearColor (0.5, 0.5, 0.75, 1.0); // цвет фона
 glClear (GL_COLOR_BUFFER_BIT);      // очистка буфера цвета

 glPointSize (20);                   // размер точек
 glColor3f (1.0, 0.0, 0.5);          // текущий цвет примитивов
 // рисуем точки по углам и в центре окна
 glBegin (GL_POINTS);                // открываем командную скобку для точек
   glVertex2f (-1, 1);
   glVertex2f (1, -1);
   glVertex2f (-1, -1);
   glVertex2f (1, 1);
   glVertex2f (0, 0);
 glEnd;                              // закрываем командную скобку

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

end.

