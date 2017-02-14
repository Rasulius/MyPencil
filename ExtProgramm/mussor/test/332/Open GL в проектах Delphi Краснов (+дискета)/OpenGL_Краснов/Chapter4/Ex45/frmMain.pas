{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{/*
 * (c) Copyright 1993, Silicon Graphics, Inc.
 *               1993-1995 Microsoft Corporation
 *
 * ALL RIGHTS RESERVED
 */}

unit frmMain;
interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Controls, SysUtils,
  Dialogs, OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    DC: HDC;
    hrc: HGLRC;
    procedure SetDCPixelFormat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
 ps : TPaintStruct;
 i : GLint;
begin
 BeginPaint(Handle, ps);

 glClear (GL_COLOR_BUFFER_BIT);
 glColor4f (1.0, 1.0, 1.0, 1.0);
 glBegin (GL_POINTS);
   For i := 1 to 10 do
        glVertex2f (i * 10.0, i * 10.0);
 glEnd;

 SwapBuffers(DC);
 EndPaint(Handle, ps);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  glEnable (GL_POINT_SMOOTH);
  glEnable (GL_BLEND);
  glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glHint (GL_POINT_SMOOTH_HINT, GL_DONT_CARE);
  glPointSize (3.0);

  glClearColor(0.0, 0.0, 0.0, 0.0);
end;

{=======================================================================
Обработка нажатия клавиши}
procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
end;

{=======================================================================
Устанавливаем формат пикселей}
procedure TfrmGL.SetDCPixelFormat;
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;

begin
  FillChar(pfd, SizeOf(pfd), 0);

  pfd.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;
  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewPort (0, 0, ClientWidth, ClientHeight);

 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 If ClientWidth < ClientHeight
    then glOrtho (0.0, 100.0, 0.0, 100.0* ClientHeight / ClientWidth, -1.0, 1.0)
    else glOrtho (0.0, 100.0*ClientWidth / ClientHeight, 0.0, 100.0, -1.0, 1.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;

 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC(Handle, DC);
 DeleteDC (DC);
end;


end.

