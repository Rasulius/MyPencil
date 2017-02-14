{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{/*
 * (c) Copyright 1993, Silicon Graphics, Inc.
 *               1993-1995 Microsoft Corporation
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
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

// Initialize material property, light source, and lighting model.
procedure   MyInit;
const
    // mat_specular and mat_shininess are NOT default values
    mat_ambient     : array[0..3] of GLfloat = ( 0.0, 0.0, 0.0, 1.0 );
    mat_diffuse     : array[0..3] of GLfloat = ( 0.4, 0.4, 0.4, 1.0 );
    mat_specular    : array[0..3] of GLfloat = ( 1.0, 1.0, 1.0, 1.0 );
    mat_shininess   : GLfloat = 15.0;
begin
    glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_ambient);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_specular);
    glMaterialfv(GL_FRONT, GL_SHININESS, @mat_shininess);

    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_DEPTH_TEST);
end;

procedure   DrawPlane;
begin
    glBegin (GL_QUADS);
    glNormal3f (0.0, 0.0, 1.0);
    glVertex3f (-1.0, -1.0, 0.0);
    glVertex3f (0.0, -1.0, 0.0);
    glVertex3f (0.0, 0.0, 0.0);
    glVertex3f (-1.0, 0.0, 0.0);

    glNormal3f (0.0, 0.0, 1.0);
    glVertex3f (0.0, -1.0, 0.0);
    glVertex3f (1.0, -1.0, 0.0);
    glVertex3f (1.0, 0.0, 0.0);
    glVertex3f (0.0, 0.0, 0.0);

    glNormal3f (0.0, 0.0, 1.0);
    glVertex3f (0.0, 0.0, 0.0);
    glVertex3f (1.0, 0.0, 0.0);
    glVertex3f (1.0, 1.0, 0.0);
    glVertex3f (0.0, 1.0, 0.0);

    glNormal3f (0.0, 0.0, 1.0);
    glVertex3f (0.0, 0.0, 0.0);
    glVertex3f (0.0, 1.0, 0.0);
    glVertex3f (-1.0, 1.0, 0.0);
    glVertex3f (-1.0, 0.0, 0.0);
    glEnd;
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.FormPaint(Sender: TObject);
const
    infinite_light  : array[0..3] of GLfloat = ( 1.0, 1.0, 1.0, 0.0 );
    local_light     : array[0..3] of GLfloat = ( 1.0, 1.0, 1.0, 1.0 );
begin
    glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

    glPushMatrix;
    glTranslatef (-1.5, 0.0, 0.0);
    glLightfv (GL_LIGHT0, GL_POSITION, @infinite_light);
    drawPlane;
    glPopMatrix;

    glPushMatrix;
    glTranslatef (1.5, 0.0, 0.0);
    glLightfv (GL_LIGHT0, GL_POSITION, @local_light);
    drawPlane;
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
 MyInit;
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
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode (GL_PROJECTION);
 glLoadIdentity;
 if ClientWidth <= ClientHeight then
     glOrtho (-1.5, 1.5, -1.5*ClientHeight/ClientWidth,
     1.5*ClientHeight/ClientWidth, -10.0, 10.0)
 else
     glOrtho (-1.5*ClientWidth/ClientHeight, 1.5*ClientWidth/ClientHeight, -1.5, 1.5, -10.0, 10.0);
 glMatrixMode (GL_MODELVIEW);

 InvalidateRect(Handle, nil, False);
end;

end.

