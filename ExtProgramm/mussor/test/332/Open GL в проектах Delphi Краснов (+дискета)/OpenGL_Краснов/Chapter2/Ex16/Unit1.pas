{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{/*
 * (c) Copyright 1993, Silicon Graphics, Inc.
 *               1993-1995 Microsoft Corporation
 *
 * ALL RIGHTS RESERVED
 *
 * Please refer to OpenGL/readme.txt for additional information
 *
 */}

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
    procedure drawOneLine(x1,y1,x2,y2 : GLfloat);
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

procedure TfrmGL.drawOneLine(x1,y1,x2,y2 : GLfloat);
begin
 glBegin(GL_LINES);
  glVertex2f (2 * x1 / ClientWidth - 1.0, y1 / ClientHeight - 0.5);
  glVertex2f (2 * x2 / ClientWidth - 1.0, y2 / ClientHeight - 0.5);
 glEnd;
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
var
 i : GLint;
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glViewPort (0, 0, ClientWidth, ClientHeight); // область вывода

 glClear (GL_COLOR_BUFFER_BIT);

//*  draw all lines in white */
    glColor3f (1.0, 1.0, 1.0);

//*  in 1st row, 3 lines drawn, each with a different stipple    */
    glEnable (GL_LINE_STIPPLE);
    glLineStipple (1, $0101);  //*  dotted  */
    drawOneLine (50.0, 125.0, 150.0, 125.0);
    glLineStipple (1, $00FF);  //*  dashed  */
    drawOneLine (150.0, 125.0, 250.0, 125.0);
    glLineStipple (1, $1C47);  //*  dash/dot/dash   */
    drawOneLine (250.0, 125.0, 350.0, 125.0);

//*  in 2nd row, 3 wide lines drawn, each with different stipple */
    glLineWidth (5.0);
    glLineStipple (1, $0101);
    drawOneLine (50.0, 100.0, 150.0, 100.0);
    glLineStipple (1, $00FF);
    drawOneLine (150.0, 100.0, 250.0, 100.0);
    glLineStipple (1, $1C47);
    drawOneLine (250.0, 100.0, 350.0, 100.0);
    glLineWidth (1.0);

//*  in 3rd row, 6 lines drawn, with dash/dot/dash stipple,  */
//*  as part of a single connect line strip          */
    glLineStipple (1, $1C47);
    glBegin (GL_LINE_STRIP);
      for i := 0 to 6 do
          glVertex2f ( 2 * (50.0 + (i * 50.0)) / ClientWidth - 1.0,
          75.0 / ClientHeight);
    glEnd;

//*  in 4th row, 6 independent lines drawn,  */
//*  with dash/dot/dash stipple          */
    for i := 0 to 5 do
        drawOneLine (50.0 + i * 50.0, 50.0, 50.0 + (i+1) * 50.0, 50.0);

//*  in 5th row, 1 line drawn, with dash/dot/dash stipple    */
//*  and repeat factor of 5          */
    glLineStipple (5, $1C47);
    drawOneLine (50.0, 25.0, 350.0, 25.0);

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

