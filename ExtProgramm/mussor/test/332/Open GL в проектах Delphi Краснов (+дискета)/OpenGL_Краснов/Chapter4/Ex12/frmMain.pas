{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{/*
 * (c) Copyright 1993, Silicon Graphics, Inc.
 *               1993-1995 Microsoft Corporation
 * ALL RIGHTS RESERVED
 */}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Controls,
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
    Quadric : GLUquadricObj;
    procedure Init;
    procedure SetDCPixelFormat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

implementation

uses DGLUT;

{$R *.DFM}

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
    light_diffuse : Array [0..3] of GLfloat = ( 1.0, 0.0, 1.0, 1.0 );
    light_position : Array [0..3] of GLfloat = ( 1.0, 1.0, 1.0, 0.0 );
begin
    glLightfv(GL_LIGHT0, GL_POSITION, @light_position);
    glLightfv(GL_LIGHT0, GL_DIFFUSE, @light_diffuse);

    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_DEPTH_TEST);
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT );

  glPushMatrix;
  glRotatef (20.0, 1.0, 0.0, 0.0);

  glPushMatrix;
  glTranslatef (-0.75, 0.5, 0.0);
  glRotatef (90.0, 1.0, 0.0, 0.0);

  glutSolidTorus (0.275, 0.85, 20, 20);
  glPopMatrix;

  glPushMatrix;
  glTranslatef (-0.75, -0.5, 0.0);
  glRotatef (270.0, 1.0, 0.0, 0.0);
  gluCylinder (Quadric, 1.0, 0.0, 2.0, 20, 20);
  glPopMatrix;

  glPushMatrix;
  glTranslatef (0.75, 0.0, -1.0);
  gluSphere (Quadric, 1.0, 20, 20);
  glPopMatrix;

  glPopMatrix;

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
  Quadric := GLUNewQuadric;
  Init;
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight );
 glMatrixMode (GL_PROJECTION);
 glLoadIdentity;
 If ClientWidth <= ClientHeight
    then glOrtho (-2.5, 2.5, -2.5*ClientHeight/ClientWidth,
        2.5*ClientHeight/ClientWidth, -10.0, 10.0)
    else glOrtho (-2.5*ClientWidth/ClientHeight,
        2.5*ClientWidth/ClientHeight, -2.5, 2.5, -10.0, 10.0);
 glMatrixMode (GL_MODELVIEW);

 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  gluDeleteQuadric (Quadric);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
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

end.


