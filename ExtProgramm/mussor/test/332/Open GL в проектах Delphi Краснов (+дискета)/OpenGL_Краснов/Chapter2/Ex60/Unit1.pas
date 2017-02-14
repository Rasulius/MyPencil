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
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    hrc: HGLRC;  
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

{=======================================================================
Перерисовка окна}
procedure TForm1.FormPaint(Sender: TObject);
var
 Color : TGLArrayf3;
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glViewPort (0, 0, ClientWidth, ClientHeight);

 glClearColor (1.0, 1, 1, 1.0);
 glClear (GL_COLOR_BUFFER_BIT);

 glPointSize (10);
 glColor3f (1.0, 0.0, 0.0);
 glGetFloatv (GL_CURRENT_COLOR, @Color);

 glBegin (GL_POINTS);
    glVertex2f (-0.25, -0.25);
    glColor3f (0.0, 0.0, 1.0);
    glVertex2f (-0.25, 0.25);
    glColor3f (Color [0], Color [1], Color [2]);
    glVertex2f (0.25, 0.25);
 glEnd;

 SwapBuffers(Canvas.Handle);        // содержимое буфера - на экран
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
procedure TForm1.FormCreate(Sender: TObject);
begin
 SetDCPixelFormat(Canvas.Handle);
 hrc := wglCreateContext(Canvas.Handle);
end;

{=======================================================================
Конец работы приложения}
procedure TForm1.FormDestroy(Sender: TObject);
begin
 wglDeleteContext(hrc);
end;

end.

