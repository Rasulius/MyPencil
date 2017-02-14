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
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Controls,
  Dialogs, SysUtils, OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC : HDC;
    hrc : HGLRC;

    procedure DrawScene;
    procedure SetDCPixelFormat;

  protected
    {Обработка сообщения WM_PAINT - аналог события OnPaint}
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;

  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

uses DGLUT;

procedure   MyInit;
const
    ambient         : array[0..3] of GLfloat = ( 0.0, 0.0, 0.0, 1.0 );
    diffuse         : array[0..3] of GLfloat = ( 1.0, 1.0, 1.0, 1.0 );
    specular        : array[0..3] of GLfloat = ( 1.0, 1.0, 1.0, 1.0 );
    position        : array[0..3] of GLfloat = ( 0.0, 3.0, 3.0, 0.0 );
    lmodel_ambient  : array[0..3] of GLfloat = ( 0.2, 0.2, 0.2, 1.0 );
    local_view      : array[0..0] of GLfloat = ( 0.0 );
begin
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);

    glLightfv(GL_LIGHT0, GL_AMBIENT, @ambient);
    glLightfv(GL_LIGHT0, GL_DIFFUSE, @diffuse);
    glLightfv(GL_LIGHT0, GL_POSITION, @position);

    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @lmodel_ambient);
    glLightModelfv(GL_LIGHT_MODEL_LOCAL_VIEWER, @local_view);

    glFrontFace (GL_CW);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_AUTO_NORMAL);
    glEnable(GL_NORMALIZE);
    glClearColor(0.0, 0.0, 0.0, 0.0);
end;

procedure   RenderTeapot (x, y, z, ambr, ambg, ambb, difr, difg, difb,
                          specr, specg, specb, shine: GLfloat);
var
    mat : array[0..3] of GLfloat;
begin
    glPushMatrix();
    glTranslatef (x, y, z);
    mat[0] := ambr; mat[1] := ambg; mat[2] := ambb; mat[3] := 1.0;
    glMaterialfv (GL_FRONT, GL_AMBIENT, @mat);
    mat[0] := difr; mat[1] := difg; mat[2] := difb;
    glMaterialfv (GL_FRONT, GL_DIFFUSE, @mat);
    mat[0] := specr; mat[1] := specg; mat[2] := specb;
    glMaterialfv (GL_FRONT, GL_SPECULAR, @mat);
    glMaterialf (GL_FRONT, GL_SHININESS, shine*128.0);
    glutSolidTeapot(0.5);
    glPopMatrix();
end;

{=======================================================================
Отрисовка картинки}
procedure TfrmGL.DrawScene;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
        // ruby, gold, silver, emerald, and cyan teapots
        renderTeapot (-1.1, -0.5, -4.5, 0.1745, 0.01175, 0.01175,
                      0.61424, 0.04136, 0.04136, 0.727811, 0.626959, 0.626959, 0.6);
        renderTeapot (-0.5, -0.5, -5.0, 0.24725, 0.1995, 0.0745,
                      0.75164, 0.60648, 0.22648, 0.628281, 0.555802, 0.366065, 0.4);
        renderTeapot (0.2, -0.5, -5.5, 0.19225, 0.19225, 0.19225,
                      0.50754, 0.50754, 0.50754, 0.508273, 0.508273, 0.508273, 0.4);
        renderTeapot (1.0, -0.5, -6.0, 0.0215, 0.1745, 0.0215,
                      0.07568, 0.61424, 0.07568, 0.633, 0.727811, 0.633, 0.6);
        renderTeapot (1.8, -0.5, -6.5, 0.0, 0.1, 0.06, 0.0, 0.50980392,
                      0.50980392, 0.50196078, 0.50196078, 0.50196078, 0.25);
  SwapBuffers(DC);   // конец работы
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  MyInit;
end;

{=======================================================================
Установка формата пикселей}
procedure TfrmGL.SetDCPixelFormat;
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;
begin
  FillChar(pfd, SizeOf(pfd), 0);

  pfd.dwFlags   := PFD_DRAW_TO_WINDOW or
                 PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;
  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode (GL_PROJECTION);
  glLoadIdentity;
  gluPerspective (45.0, ClientWidth / ClientHeight, 1.0, 15.0);
  glMatrixMode (GL_MODELVIEW);
  glLoadIdentity;
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Обработка сообщения WM_PAINT, рисование окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);
  DrawScene;
  EndPaint(Handle, ps);
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

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close
end;

end.

