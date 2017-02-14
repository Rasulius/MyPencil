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
    quadObj : GLUquadricObj;
  end;

var
  frmGL: TfrmGL;
  mode : (POINT, LINE, FILL, SILHOUETTE) = FILL;

implementation

{$R *.DFM}

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
const
 eqn : Array [0..3] of GLdouble = (0.0, 1.0, 0.0, 0.0);
 eqn2 : Array [0..3] of GLdouble = (1.0, 0.0, 0.0, 0.0);
begin
 glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);      // очистка буфера цвета

 glPushMatrix;

 glRotatef (ry, 0.0, 1.0, 0.0);
 glTranslatef (tx, 0.0, 0.0);

 glColor3f (1.0, 1.0, 1.0);
 glTranslatef (0.0, 0.0, -5.0);

 //*    clip lower half -- y < 0      */
 glClipPlane (GL_CLIP_PLANE0, @eqn);
 glEnable (GL_CLIP_PLANE0);
 //*    clip left half -- x < 0       */
 glClipPlane (GL_CLIP_PLANE1, @eqn2);
 glEnable (GL_CLIP_PLANE1);

 glRotatef (90.0, 1.0, 0.0, 0.0);

 case mode of
   POINT : gluQuadricDrawStyle (quadObj, GLU_POINT);
   LINE  : gluQuadricDrawStyle (quadObj, GLU_LINE);
   FILL  : gluQuadricDrawStyle (quadObj, GLU_FILL);
   SILHOUETTE : gluQuadricDrawStyle (quadObj, GLU_SILHOUETTE);
 end;

 gluSphere (quadObj, 1.0, 10, 10);

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
 glColor3f (1.0, 0.0, 0.0);
 quadObj := gluNewQuadric;

 ry := 0.0;
 tx := 0.0;
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
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluPerspective(30.0, ClientWidth/ClientHeight, 2.0, 10.0);
 glMatrixMode(GL_MODELVIEW);

 InvalidateRect(Handle, nil, False);
end;


end.

