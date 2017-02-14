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
    PopupMenu1: TPopupMenu;
    GLLINEAR1: TMenuItem;
    GLEXP21: TMenuItem;
    GLEXP1: TMenuItem;
    Quit1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GLLINEAR1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC : HDC;
    hrc : HGLRC;

    procedure DrawScene;
    procedure SetDCPixelFormat;
    procedure SelectFog(mode: GLint);
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  fogMode : GLint;

implementation

{$R *.DFM}

uses DGLUT;

procedure TfrmGL.SelectFog(mode: GLint);
begin
    case mode of
        1 : begin
            glFogf(GL_FOG_START, 1.0);
            glFogf(GL_FOG_END, 5.0);
            glFogi(GL_FOG_MODE, GL_LINEAR);
            InvalidateRect(Handle, nil, False);
            end;
        2 : begin
            glFogi(GL_FOG_MODE, GL_EXP2);
            InvalidateRect(Handle, nil, False);
            end;
        3 : begin
            glFogi(GL_FOG_MODE, GL_EXP);
            InvalidateRect(Handle, nil, False);
            end;
        0 : close;
    end;
end;

// Initialize z-buffer, projection matrix, light source,
// and lighting model.  Do not specify a material property here.
procedure   MyInit;
const
    position    : array[0..3] of GLfloat = (0.0, 3.0, 3.0, 0.0);
    local_view  : array[0..0] of GLfloat = (0.0);
    fogColor    : array[0..3] of GLfloat = (0.5, 0.5, 0.5, 1.0);
begin
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);

    glLightfv(GL_LIGHT0, GL_POSITION, @position);
    glLightModelfv(GL_LIGHT_MODEL_LOCAL_VIEWER, @local_view);

    glFrontFace(GL_CW);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_AUTO_NORMAL);
    glEnable(GL_NORMALIZE);
    glEnable(GL_FOG);
    fogMode := GL_EXP;
    glFogi(GL_FOG_MODE, fogMode);
    glFogfv(GL_FOG_COLOR, @fogColor);
    glFogf(GL_FOG_DENSITY, 0.35);
    glHint(GL_FOG_HINT, GL_DONT_CARE);
    glClearColor(0.5, 0.5, 0.5, 1.0);
end;

procedure   RenderRedTeapot(x, y, z: GLfloat);
var
    mat : array[0..3] of GLfloat;
begin
    glPushMatrix();
    glTranslatef(x, y, z);
    mat[0] := 0.1745;
    mat[1] := 0.01175;
    mat[2] := 0.01175;
    mat[3] := 1.0;
    glMaterialfv(GL_FRONT, GL_AMBIENT, @mat);
    mat[0] := 0.61424;
    mat[1] := 0.04136;
    mat[2] := 0.04136;
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat);
    mat[0] := 0.727811;
    mat[1] := 0.626959;
    mat[2] := 0.626959;
    glMaterialfv(GL_FRONT, GL_SPECULAR, @mat);
    glMaterialf(GL_FRONT, GL_SHININESS, 0.6 * 128.0);
    glutSolidTeapot(1.0);
    glPopMatrix();
end;

{=======================================================================
Отрисовка картинки}
procedure TfrmGL.DrawScene;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  renderRedTeapot(-4.0, -0.5, -1.0);
  renderRedTeapot(-2.0, -0.5, -2.0);
  renderRedTeapot(0.0, -0.5, -3.0);
  renderRedTeapot(2.0, -0.5, -4.0);
  renderRedTeapot(4.0, -0.5, -5.0);
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
    glLoadIdentity();
    if ClientWidth <= (ClientHeight * 3) then
        glOrtho(-6.0, 6.0, -2.0 * (ClientHeight * 3) / ClientWidth,
        2.0 * (ClientHeight * 3) / ClientWidth, 0.0, 10.0)
    else
        glOrtho(-6.0 * ClientWidth / (ClientHeight * 3),
        6.0 * ClientWidth / (ClientHeight * 3), -2.0, 2.0, 0.0, 10.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

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

procedure TfrmGL.GLLINEAR1Click(Sender: TObject);
begin
 SelectFog((Sender as TMenuItem).Tag);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
end;

end.

