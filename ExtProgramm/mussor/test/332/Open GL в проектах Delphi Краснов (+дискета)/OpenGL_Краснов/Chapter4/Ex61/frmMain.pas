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

uses jitter, DGLUT;

// AccFrustum()
// The first 6 arguments are identical to the glFrustum() call.
//
// pixdx and pixdy are anti-alias jitter in pixels.
// Set both equal to 0.0 for no anti-alias jitter.
// eyedx and eyedy are depth-of field jitter in pixels.
// Set both equal to 0.0 for no depth of field effects.
//
// focus is distance from eye to plane in focus.
// focus must be greater than, but not equal to 0.0.
//
// Note that AccFrustum() calls glTranslatef().  You will
// probably want to insure that your ModelView matrix has been
// initialized to identity before calling accFrustum().
procedure   AccFrustum(left, right, bottom, top: GLdouble;
                       anear, afar, pixdx, pixdy, eyedx, eyedy: GLdouble;
                       focus: GLdouble);
var
    xwsize, ywsize  : GLdouble;
    dx, dy          : GLdouble;
    viewport        : array[0..3] of GLint;
begin
    glGetIntegerv (GL_VIEWPORT, @viewport);

    xwsize := right - left;
    ywsize := top - bottom;

    dx := -(pixdx*xwsize/viewport[2] + eyedx*anear/focus);
    dy := -(pixdy*ywsize/viewport[3] + eyedy*anear/focus);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustum (left + dx, right + dx, bottom + dy, top + dy, anear, afar);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef (-eyedx, -eyedy, 0.0);
end;

// AccPerspective()
//
// The first 4 arguments are identical to the gluPerspective() call.
// pixdx and pixdy are anti-alias jitter in pixels.
// Set both equal to 0.0 for no anti-alias jitter.
// eyedx and eyedy are depth-of field jitter in pixels.
// Set both equal to 0.0 for no depth of field effects.
//
// focus is distance from eye to plane in focus.
// focus must be greater than, but not equal to 0.0.
//
// Note that AccPerspective() calls accFrustum().
procedure   AccPerspective(fovy, aspect, anear, afar, pixdx, pixdy,
                           eyedx, eyedy, focus: GLdouble);
var
    fov2,left,right,bottom,top  : GLdouble;
begin
    fov2    := ((fovy*Pi) / 180.0) / 2.0;

    top     := anear / (cos(fov2) / sin(fov2));
    bottom  := -top;

    right   := top * aspect;
    left    := -right;

    AccFrustum (left, right, bottom, top, anear, afar, pixdx, pixdy, eyedx, eyedy, focus);
end;

procedure   MyInit;
const
    mat_ambient: Array [0..3] of GLfloat = ( 1.0, 1.0, 1.0, 1.0 );
    mat_specular: Array [0..3] of GLfloat = ( 1.0, 1.0, 1.0, 1.0 );
    light_position: Array [0..3] of GLfloat = ( 0.0, 0.0, 10.0, 1.0 );
    lm_ambient: Array [0..3] of GLfloat = ( 0.2, 0.2, 0.2, 1.0 );
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
    glShadeModel (GL_FLAT);

    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClearAccum(0.0, 0.0, 0.0, 0.0);
end;

const
 ACSIZE = 8;

procedure displayObjects;
const
    torus_diffuse: Array [0..3] of GLfloat = ( 0.7, 0.7, 0.0, 1.0 );
    cube_diffuse: Array [0..3] of GLfloat = ( 0.0, 0.7, 0.7, 1.0 );
    sphere_diffuse: Array [0..3] of GLfloat = ( 0.7, 0.0, 0.7, 1.0 );
    octa_diffuse: Array [0..3] of GLfloat = ( 0.7, 0.4, 0.4, 1.0 );
begin
    glPushMatrix;
    glTranslatef (0.0, 0.0, -5.0);
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
end;

{=======================================================================
Отрисовка картинки}
procedure TfrmGL.DrawScene;
var
    jitter      : GLint;
    viewport    : array[0..3] of GLint;
begin
    glGetIntegerv (GL_VIEWPORT, @viewport);
    glClear(GL_ACCUM_BUFFER_BIT);
   For jitter := 0 to ACSIZE - 1 do begin
        glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
        accPerspective (50.0,
            viewport[2] / viewport[3],
            1.0, 15.0, j8[jitter].x, j8[jitter].y,
            0.0, 0.0, 1.0);
        displayObjects;
        glAccum(GL_ACCUM, 1.0/ACSIZE);
    end;
    glAccum (GL_RETURN, 1.0);

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
  If Key = VK_ESCAPE then Close;
end;

end.

