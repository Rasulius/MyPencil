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
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);

  private
    DC : HDC;
    hrc : HGLRC;
  end;

var
  frmGL: TfrmGL;

implementation

uses DGlut;

{$R *.DFM}

// Initialize linear fog for depth cueing.
procedure myinit;
const
 fogColor : Array [0..3] of GLFloat = (0.0, 0.0, 0.0, 1.0);
begin
 glEnable(GL_FOG);
 glFogi (GL_FOG_MODE, GL_LINEAR);
 glHint (GL_FOG_HINT, GL_NICEST);  //  per pixel
 glFogf (GL_FOG_START, 3.0);
 glFogf (GL_FOG_END, 5.0);
 glFogfv (GL_FOG_COLOR, @fogColor);
 glClearColor(0.0, 0.0, 0.0, 1.0);

 glDepthFunc(GL_LESS);
 glEnable(GL_DEPTH_TEST);
 glShadeModel(GL_FLAT);
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
 glColor3f (1.0, 1.0, 1.0);
 glutWireIcosahedron;

 SwapBuffers(DC);
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
 myinit;
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglMakeCurrent (0, 0);
 wglDeleteContext(hrc);
 ReleaseDC (Handle, DC);
 DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport (0, 0, ClientWidth, ClientHeight);
  glMatrixMode (GL_PROJECTION);
  glLoadIdentity;
  gluPerspective (45.0, ClientWidth / ClientHeight, 3.0, 5.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef (0.0, 0.0, -4.0);

  InvalidateRect(Handle, nil, False);
end;

end.

