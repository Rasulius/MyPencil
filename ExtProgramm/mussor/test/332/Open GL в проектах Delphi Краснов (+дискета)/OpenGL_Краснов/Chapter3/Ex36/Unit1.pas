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
    hrc: HGLRC;
    quadObj : GLUquadricObj;
  end;

var
  frmGL: TfrmGL;
  year : Integer = 0;
  day : Integer = 0;

implementation

{$R *.DFM}

procedure dayAdd;
begin
    day := (day + 10);
    If day > 360 then day := 0;
end;

procedure daySubtract;
begin
    day := (day - 10);
    If day > 360 then day := 0;
end;

procedure yearAdd;
begin
    year := (year + 5);
    If year > 360 then year := 0;
end;

procedure yearSubtract;
begin
    year := (year - 5);
    If year > 360 then year := 0;
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 glClear (GL_COLOR_BUFFER_BIT);      // очистка буфера цвета

 glPushMatrix;

 // рисуем солнце
 gluSphere (quadObj, 1.0, 15, 10);
 // рисуем маленькую планету
 glRotatef (year, 0.0, 1.0, 0.0);
 glTranslatef (2.0, 0.0, 0.0);
 glRotatef (day, 0.0, 1.0, 0.0);
 gluSphere (quadObj, 0.2, 10, 10);

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
 gluQuadricDrawStyle (quadObj, GLU_LINE);
 glShadeModel (GL_FLAT);
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 gluDeleteQuadric (quadObj);
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC (Handle, DC);
 DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close;
 If Key = VK_LEFT then begin
    yearSubtract;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_RIGHT then begin
    yearAdd;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_UP then begin
    dayAdd;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_DOWN then begin
    daySubtract;
    InvalidateRect(Handle, nil, False);
 end;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluPerspective(60.0, ClientWidth / ClientHeight, 1.0, 20.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef (0.0, 0.0, -5.0);

 InvalidateRect(Handle, nil, False);
end;


end.

