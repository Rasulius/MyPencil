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
    quadObj : GLUquadricObj;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 glClearColor (0.0, 0.0, 0.0, 1.0);
 glClear (GL_COLOR_BUFFER_BIT);

 glPushMatrix;
 gluQuadricDrawStyle (quadObj, GLU_FILL);
 glColor3f (1.0, 1.0, 1.0);
 glTranslatef (10.0, 10.0, 0.0);
 gluDisk (quadObj, 0.0, 5.0, 10, 2);
 glPopMatrix;

 glPushMatrix;
 glColor3f (1.0, 1.0, 0.0);
 glTranslatef (20.0, 20.0, 0.0);
 gluPartialDisk (quadObj, 0.0, 5.0, 10, 3, 30.0, 120.0);
 glPopMatrix;

 glPushMatrix;
 gluQuadricDrawStyle (quadObj, GLU_SILHOUETTE);
 glColor3f (0.0, 1.0, 1.0);
 glTranslatef (30.0, 30.0, 0.0);
 gluPartialDisk (quadObj, 0.0, 5.0, 10, 3, 135.0, 270.0);
 glPopMatrix;

 glPushMatrix;
 gluQuadricDrawStyle (quadObj, GLU_LINE);
 glColor3f (1.0, 0.0, 1.0);
 glTranslatef (40.0, 40.0, 0.0);
 gluDisk (quadObj, 2.0, 5.0, 10, 10);
 glPopMatrix;

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
 quadObj := gluNewQuadric;
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 gluDeleteQuadric (quadObj);
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
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  If ClientWidth <= ClientHeight
    then glOrtho (0.0, 50.0, 0.0, 50.0 * ClientHeight / ClientWidth, -1.0, 1.0)
    else glOrtho (0.0, 50.0 * ClientWidth / ClientHeight, 0.0, 50.0, -1.0, 1.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  InvalidateRect(Handle, nil, False);
end;

end.

