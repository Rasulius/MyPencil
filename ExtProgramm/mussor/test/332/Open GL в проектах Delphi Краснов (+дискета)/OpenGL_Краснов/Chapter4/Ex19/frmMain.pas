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

implementation

uses DGLUT;

{$R *.DFM}

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
    light_position : Array [0..3] of GLfloat = ( 1.0, 1.0, 1.0, 0.0 );
    global_ambient : Array [0..3] of GLfloat = ( 0.75, 0.75, 0.75, 1.0 );
begin
    glLightfv(GL_LIGHT0, GL_POSITION, @light_position);
 
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @global_ambient);
    
    glFrontFace (GL_CW);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_DEPTH_TEST);
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
const
  eqn : Array [0..3] of GLdouble  = (1.0, 0.0, -1.0, 1.0);
  mat_diffuse : Array [0..3] of GLfloat = ( 0.8, 0.8, 0.8, 1.0 );
  back_diffuse : Array [0..3] of GLfloat = ( 0.8, 0.2, 0.8, 1.0 );
begin
  BeginPaint(Handle, ps);

  glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT );

  glPushMatrix;
  glClipPlane (GL_CLIP_PLANE0, @eqn);  //*  slice objects   */
  glEnable (GL_CLIP_PLANE0);

  glPushMatrix;
  glTranslatef (0.0, 2.0, 0.0);
  glutSolidTeapot(1.0);    //*  one-sided lighting  */
  glPopMatrix;

  //*  two-sided lighting, but same material   */
  glLightModelf (GL_LIGHT_MODEL_TWO_SIDE, 1);
  glMaterialfv (GL_FRONT_AND_BACK, GL_DIFFUSE, @mat_diffuse);
  glPushMatrix;
  glTranslatef (0.0, 0.0, 0.0);
  glutSolidTeapot(1.0);
  glPopMatrix;

  //*  two-sided lighting, two different materials */
  glMaterialfv (GL_FRONT, GL_DIFFUSE, @mat_diffuse);
  glMaterialfv (GL_BACK, GL_DIFFUSE, @back_diffuse);
  glPushMatrix;
  glTranslatef (0.0, -2.0, 0.0);
  glutSolidTeapot(1.0);
  glPopMatrix ;

  glLightModelf (GL_LIGHT_MODEL_TWO_SIDE, GL_FALSE);
  glDisable (GL_CLIP_PLANE0);

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
 glMatrixMode (GL_PROJECTION);
 glLoadIdentity;
 If ClientWidth <= ClientHeight
    then glOrtho (-4.0, 4.0, -4.0*ClientHeight/ClientWidth,
        4.0*ClientHeight/ClientWidth, -10.0, 10.0)
    else glOrtho (-4.0*ClientWidth/ClientHeight,
        4.0*ClientWidth/ClientHeight, -4.0, 4.0, -10.0, 10.0);
 glMatrixMode (GL_MODELVIEW);

 InvalidateRect(Handle, nil, False);
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


