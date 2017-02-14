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
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Controls,
  OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    DC: HDC;
    hrc: HGLRC;
    qObj: GLUquadricObj;
    procedure Init;
    procedure SetDCPixelFormat;

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  eyePosition : Boolean = FALSE;

implementation

uses DGLUT;

{$R *.DFM}

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
    mat_ambient : Array [0..3] of GLfloat = ( 0.0, 0.0, 0.0, 0.15 );
    mat_specular : Array [0..3] of GLfloat = ( 1.0, 1.0, 1.0, 0.15 );
    mat_shininess =  15.0 ;
begin
    glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_ambient);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_specular);
    glMaterialf(GL_FRONT, GL_SHININESS, mat_shininess);

    glEnable (GL_LIGHTING);
    glEnable (GL_LIGHT0);
    glDepthFunc(GL_LESS);
    glEnable(GL_DEPTH_TEST);
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
const
   position : Array [0..3] of GLfloat = ( 0.0, 0.0, 1.0, 1.0 );
   mat_torus : Array [0..3] of GLfloat = ( 0.75, 0.75, 0.0, 1.0 );
   mat_cylinder : Array [0..3] of GLfloat = ( 0.0, 0.75, 0.75, 0.15 );
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glPushMatrix;

  glLightfv (GL_LIGHT0, GL_POSITION, @position);
  If eyePosition
     then gluLookAt (0.0, 0.0, 9.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
     else gluLookAt (0.0, 0.0, -9.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
  glPushMatrix;
  glTranslatef (0.0, 0.0, 1.0);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_torus);
  glutSolidTorus (0.275, 0.85, 15, 15);

  glPopMatrix;

  glEnable (GL_BLEND);
  glDepthMask (FALSE);
  glBlendFunc (GL_SRC_ALPHA, GL_ONE);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_cylinder);
  glTranslatef (0.0, 1.0, -1.0);
  glRotatef (90, 1.0, 0.0, 0.0);
  gluCylinder (qObj, 1.0, 1.0, 2.0, 20, 20);
  glDepthMask (TRUE);
  glDisable (GL_BLEND);

  glPopMatrix;

  SwapBuffers(DC);
  EndPaint(Handle, ps);
end;

{=======================================================================
Обработка нажатия клавиши}
procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  qObj := gluNewQuadric;
  Init;
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(30.0, ClientWidth / ClientHeight, 1.0, 20.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  gluDeleteQuadric (qObj);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC(DC);
end;

{=======================================================================
Устанавливаем формат пикселей}
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


procedure TfrmGL.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  eyePosition := not eyePosition;
  InvalidateRect(Handle, nil, False);
end;

end.

