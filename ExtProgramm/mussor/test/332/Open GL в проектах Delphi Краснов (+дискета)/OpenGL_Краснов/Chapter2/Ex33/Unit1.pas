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

 glViewPort (0, 0, ClientWidth, ClientHeight);

 glClearColor (0.75, 0.75, 0.75, 1.0);
 glClear (GL_COLOR_BUFFER_BIT);

 glColor3f (0.0, 0.0, 0.75);

 glBegin (GL_POLYGON);
   glVertex2f (-0.23678, 0.35118);
   glVertex2f (-0.23678, 0.7764);
   glVertex2f (-0.37966, 0.7764);
   glVertex2f (-0.55, 0.60606);
   glVertex2f (-0.55, -0.4);
   glVertex2f (-0.23576, -0.4);
   glVertex2f (-0.23678, 0.35118);
   glVertex2f (-0.23576, -0.4);
   glVertex2f (0.1375, -0.4);
   glVertex2f (0.13678, 0.35118);
 glEnd;

 glBegin (GL_POLYGON);
   glVertex2f (0.1375, -0.4);
   glVertex2f (0.45, -0.4);
   glVertex2f (0.45, 0.60606);
   glVertex2f (0.27966, 0.7764);
   glVertex2f (0.13678, 0.7764);
   glVertex2f (0.13678, 0.35118);
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

