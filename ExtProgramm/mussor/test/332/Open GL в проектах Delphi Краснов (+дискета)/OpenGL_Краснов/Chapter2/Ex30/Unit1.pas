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
    procedure FormKeyPress(Sender: TObject; var Key: Char);

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

 glClearColor (0.75, 0.75, 0.5, 1.0);
 glClear (GL_COLOR_BUFFER_BIT);

 glBegin (GL_QUADS);
   glColor3f (random, random, random);
   glVertex2f (-0.6, 0.2);
   glVertex2f (-0.7, 0.7);
   glVertex2f (0.1, 0.65);
   glVertex2f (0.25, -0.78);
   glColor3f (random, random, random);
   glVertex2f (0.3, -0.6);
   glVertex2f (0.45, 0.7);
   glVertex2f (0.8, 0.65);
   glVertex2f (0.9, -0.8);
 glEnd;

 SwapBuffers(Canvas.Handle);
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
 Randomize;
 SetDCPixelFormat(Canvas.Handle);
 hrc := wglCreateContext(Canvas.Handle);
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglDeleteContext(hrc);
end;

{=======================================================================
Обработка нажатия клавиши}
procedure TfrmGL.FormKeyPress(Sender: TObject; var Key: Char);
begin
  Refresh
end;

end.

