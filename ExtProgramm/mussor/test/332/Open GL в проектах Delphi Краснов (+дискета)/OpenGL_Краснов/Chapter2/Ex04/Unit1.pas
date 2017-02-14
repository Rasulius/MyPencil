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
var
 i : 1..100;
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glViewPort (0, 0, ClientWidth, ClientHeight); // область вывода

 glClearColor (0.5, 0.5, 0.75, 1.0); // цвет фона
 glClear (GL_COLOR_BUFFER_BIT);      // очистка буфера цвета

 glPointSize (20);                   // размер точек
 glColor3f (1.0, 0.0, 0.5);          // текущий цвет примитивов

 glBegin (GL_POINTS);
   For i := 1 to 100 do begin
      glColor3f (random, random, random);
      glVertex2f (random * 2 - 1, random * 2 - 1);
   end;
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

end.

