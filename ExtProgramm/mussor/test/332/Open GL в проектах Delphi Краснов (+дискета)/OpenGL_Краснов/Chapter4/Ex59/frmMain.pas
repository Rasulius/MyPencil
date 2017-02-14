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

// Initialize lighting and other values.
procedure   MyInit;
const
    mat_ambient     : Array[0..3] of GLfloat = ( 1.0, 1.0,  1.0, 1.0 );
    mat_specular    : Array[0..3] of GLfloat = ( 1.0, 1.0,  1.0, 1.0 );
    light_position  : Array[0..3] of GLfloat = ( 0.0, 0.0, 10.0, 1.0 );
    lm_ambient      : Array[0..3] of GLfloat = ( 0.2, 0.2,  0.2, 1.0 );
begin
    glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_ambient);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_specular);
    glMaterialf(GL_FRONT, GL_SHININESS, 50.0);
    glLightfv(GL_LIGHT0, GL_POSITION, @light_position);
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @lm_ambient);

    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glDepthFunc(GL_LESS);
    glEnable(GL_DEPTH_TEST);
end;

{=======================================================================
Отрисовка картинки}
procedure TfrmGL.DrawScene;
const
    torus_diffuse: Array [0..3] of GLfloat = ( 0.7, 0.7, 0.0, 1.0 );
    cube_diffuse: Array [0..3] of GLfloat = ( 0.0, 0.7, 0.7, 1.0 );
    sphere_diffuse: Array [0..3] of GLfloat = ( 0.7, 0.0, 0.7, 1.0 );
    octa_diffuse: Array [0..3] of GLfloat = ( 0.7, 0.4, 0.4, 1.0 );
begin
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

    glShadeModel (GL_FLAT);
    glPushMatrix;
    glRotatef (30.0, 1.0, 0.0, 0.0);

    glPushMatrix;
    glTranslatef (-0.80, 0.35, 0.0);
    glRotatef (100.0, 1.0, 0.0, 0.0);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @torus_diffuse);
    glutSolidTorus (0.275, 0.85, 16, 16);
    glPopMatrix;

    glPushMatrix;
    glTranslatef (-0.75, -0.50, 0.0);
    glRotatef (45.0, 0.0, 0.0, 1.0);
    glRotatef (45.0, 1.0, 0.0, 0.0);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @cube_diffuse);
    glutSolidCube (1.5);
    glPopMatrix;

    glPushMatrix;
    glTranslatef (0.75, 0.60, 0.0);
    glRotatef (30.0, 1.0, 0.0, 0.0);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @sphere_diffuse);
    glutSolidSphere (1.0, 16, 16);
    glPopMatrix;

    glPushMatrix;
    glTranslatef (0.70, -0.90, 0.25);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @octa_diffuse);
    glutSolidOctaheadron;
    glPopMatrix;

    glPopMatrix;

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
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;
    if ClientWidth <= ClientHeight then
        glOrtho (-2.25, 2.25, -2.25*ClientHeight/ClientWidth,
         2.25*ClientHeight/ClientWidth, -10.0, 10.0)
    else
        glOrtho (-2.25*ClientWidth/ClientHeight, 2.25*ClientWidth/ClientHeight,
        -2.25, 2.25, -10.0, 10.0);
    glMatrixMode(GL_MODELVIEW);
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

