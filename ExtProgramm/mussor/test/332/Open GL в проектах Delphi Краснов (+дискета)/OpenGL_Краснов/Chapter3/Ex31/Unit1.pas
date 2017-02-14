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
    ry : GLfloat;
    tx : GLfloat;
  end;

var
  frmGL: TfrmGL;
  mode : (POINT, LINE, FILL) = FILL;
  shoulder : GLint = 0;
  elbow : GLint = 0;

implementation

uses DGLUT;

{$R *.DFM}

procedure elbowAdd;
begin
 elbow := elbow + 5;
 If elbow > 360 then elbow := 0;
end;

procedure elbowSubtract;
begin
 elbow := elbow - 5;
 If elbow < -360 then elbow := 0;
end;

procedure shoulderAdd;
begin
 shoulder := shoulder + 5;
 If shoulder > 360 then shoulder := 0;
end;

procedure shoulderSubtract;
begin
 shoulder := shoulder - 5;
 If shoulder < -360 then shoulder := 0;
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);      // очистка буфера цвета

 case mode of
   POINT : glPolygonMode (GL_FRONT_AND_BACK, GL_POINT);
   LINE  : glPolygonMode (GL_FRONT_AND_BACK, GL_LINE);
   FILL  : glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
 end;

 glPushMatrix;

 glRotatef (ry, 0.0, 1.0, 0.0);
 glTranslatef (tx, 0.0, 0.0);

 glTranslatef (-1.0, 0.0, 0.0);
 glRotatef (shoulder, 0.0, 0.0, 1.0);
 glTranslatef (1.0, 0.0, 0.0);
 glPushMatrix;
 glScalef (2.0, 0.4, 1.0);
 glutSolidCube(1.0);
 glPopMatrix;

 glTranslatef (1.0, 0.0, 0.0);
 glRotatef (elbow, 0.0, 0.0, 1.0);
 glTranslatef (1.0, 0.0, 0.0);
 glPushMatrix;
 glScalef (2.0, 0.4, 1.0);
 glutSolidCube(1.0);
 glPopMatrix;

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
 glClearColor (0.5, 0.5, 0.75, 1.0); // цвет фона
 glLineWidth (1.5);
 glEnable (GL_LIGHTING);
 glEnable (GL_LIGHT0);
 glEnable (GL_DEPTH_TEST);
 glEnable (GL_COLOR_MATERIAL);
 glColor3f (0.0, 0.0, 1.0);

 ry := 0.0;
 tx := 0.0;
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
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
    ry := ry + 2.0;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_RIGHT then begin
    ry := ry - 2.0;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_UP then begin
    tx := tx - 0.1;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_DOWN then begin
    tx := tx + 0.1;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = 49 then begin
    Inc (mode);
    If mode > High (mode) then mode := Low (mode);
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_HOME then begin
    shoulderSubtract;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_END then begin
    shoulderAdd;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_INSERT then begin
    elbowAdd;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_DELETE then begin
    elbowSubtract;
    InvalidateRect(Handle, nil, False);
 end;

end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluPerspective(65.0, ClientWidth/ClientHeight, 1.0, 20.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef (0.0, 0.0, -5.0);  //* viewing transform  */

 InvalidateRect(Handle, nil, False);
end;


end.

