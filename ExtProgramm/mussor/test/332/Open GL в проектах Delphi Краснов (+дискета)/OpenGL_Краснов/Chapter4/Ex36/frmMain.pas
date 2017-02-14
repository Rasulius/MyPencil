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
    procedure Init;
    procedure SetDCPixelFormat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

const
  YELLOWMAT = 1;
  BLUEMAT = 2;

implementation

uses DGLUT;

{$R *.DFM}

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
    position_one : Array [0..3] of GLfloat = ( 1.0, 1.0, 1.0, 0.0 );
    global_ambient : Array [0..3] of GLfloat = ( 0.75, 0.75, 0.75, 1.0 );
    yellow_diffuse : Array [0..3] of GLfloat = ( 0.7, 0.7, 0.0, 1.0 );
    yellow_specular : Array [0..3] of GLfloat = ( 1.0, 1.0, 1.0, 1.0 );

    blue_diffuse : Array [0..3] of GLfloat = ( 0.1, 0.1, 0.7, 1.0 );
    blue_specular : Array [0..3] of GLfloat = ( 0.1, 1.0, 1.0, 1.0 );
begin
    glNewList(YELLOWMAT, GL_COMPILE);
      glMaterialfv(GL_FRONT, GL_DIFFUSE, @yellow_diffuse);
      glMaterialfv(GL_FRONT, GL_SPECULAR, @yellow_specular);
      glMaterialf(GL_FRONT, GL_SHININESS, 64.0);
    glEndList;

    glNewList(BLUEMAT, GL_COMPILE);
      glMaterialfv(GL_FRONT, GL_DIFFUSE, @blue_diffuse);
      glMaterialfv(GL_FRONT, GL_SPECULAR, @blue_specular);
      glMaterialf(GL_FRONT, GL_SHININESS, 45.0);
    glEndList;

    glLightfv(GL_LIGHT0, GL_POSITION, @position_one);

    glEnable(GL_LIGHT0);
    glEnable(GL_LIGHTING);
    glEnable(GL_DEPTH_TEST);

    glEnable(GL_STENCIL_TEST);
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT );

    //* draw blue sphere where the stencil is 1 */
    glStencilFunc (GL_EQUAL, $1, $1);
    glCallList (BLUEMAT);
    glutSolidSphere (0.5, 20, 20);

    //* draw the tori where the stencil is not 1 */
    glStencilFunc (GL_NOTEQUAL, $1, $1);
    glStencilOp (GL_KEEP, GL_KEEP, GL_KEEP);
    glPushMatrix;
    glRotatef (45.0, 0.0, 0.0, 1.0);
    glRotatef (45.0, 0.0, 1.0, 0.0);
    glCallList (YELLOWMAT);
    glutSolidTorus (0.275, 0.85, 20, 20);
    glPushMatrix;
        glRotatef (90.0, 1.0, 0.0, 0.0);
        glutSolidTorus (0.275, 0.85, 20, 20);
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
  Init;
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight );
 glClear(GL_STENCIL_BUFFER_BIT);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 glOrtho(-3.0, 3.0, -3.0, 3.0, -1.0, 1.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;

 glStencilFunc (GL_ALWAYS, $1, $1);
 glStencilOp (GL_REPLACE, GL_REPLACE, GL_REPLACE);
 glBegin(GL_QUADS);
   glVertex3f (-1.0, 0.0, 0.0);
   glVertex3f (0.0, 1.0, 0.0);
   glVertex3f (1.0, 0.0, 0.0);
   glVertex3f (0.0, -1.0, 0.0);
 glEnd;

 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluPerspective(45.0, ClientWidth / ClientHeight, 3.0, 7.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef(0.0, 0.0, -5.0);

 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  glDeleteLists (YELLOWMAT, 2);
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


