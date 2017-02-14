{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Controls, SysUtils,
  OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    hrc: HGLRC;
    Pixel : Array [0..50, 0..50, 0..2] of GLUbyte;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
var
 i : 1..30000;
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glViewPort (0, 0, ClientWidth, ClientHeight); // область вывода
 glClear (GL_COLOR_BUFFER_BIT);      // очистка буфера цвета

 glColor3f (1.0, 1.0, 1.0);
 For i := 1 to 30000 do begin
     glPointSize (random * 3);
     glBegin (GL_POINTS);
       glVertex2f (random * 4 - 2, random * 4 - 2);
       glVertex2f (random * 4 - 2, random * 4 - 2);
     glEnd;
 end;

 glReadPixels(round(ClientWidth / 2), round(ClientHeight / 2), 50, 50,
              GL_RGB, GL_UNSIGNED_BYTE, @Pixel);

 glRasterPos2f (-0.5, 0.0);
 glDrawPixels(50, 50, GL_RGB, GL_UNSIGNED_BYTE, @Pixel);

 glRasterPos2f (-0.25, 0.0);
 glDrawPixels(50, 50, GL_RGB, GL_UNSIGNED_BYTE, @Pixel);

 glRasterPos2f (0.0, 0.0);
 glDrawPixels(50, 50, GL_RGB, GL_UNSIGNED_BYTE, @Pixel);

 glRasterPos2f (0.25, 0.0);
 glDrawPixels(50, 50, GL_RGB, GL_UNSIGNED_BYTE, @Pixel);

 glRasterPos2f (-0.5, -0.25);
 glDrawPixels(50, 50, GL_RGB, GL_UNSIGNED_BYTE, @Pixel);

 glRasterPos2f (-0.25, -0.25);
 glDrawPixels(50, 50, GL_RGB, GL_UNSIGNED_BYTE, @Pixel);

 glRasterPos2f (0.0, -0.25);
 glDrawPixels(50, 50, GL_RGB, GL_UNSIGNED_BYTE, @Pixel);

 glRasterPos2f (0.25, -0.25);
 glDrawPixels(50, 50, GL_RGB, GL_UNSIGNED_BYTE, @Pixel);

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

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
  If Key = VK_SPACE then Refresh;
end;

end.

