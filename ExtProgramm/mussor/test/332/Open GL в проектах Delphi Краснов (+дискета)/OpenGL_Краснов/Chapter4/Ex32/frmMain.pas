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

{$R *.DFM}

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
begin
    glClearColor(0.0, 0.0, 0.0, 0.0);

    glClearStencil(0);
    glStencilMask(1);
    glEnable(GL_STENCIL_TEST);
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

    glClear( GL_COLOR_BUFFER_BIT or GL_STENCIL_BUFFER_BIT );

    glStencilFunc(GL_ALWAYS, 1, 1);
    glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);

    glColor3ub(200, 0, 0);
      glBegin(GL_POLYGON);
      glVertex3i(-4, -4, 0);
      glVertex3i( 4, -4, 0);
      glVertex3i( 0,  4, 0);
    glEnd;

    glStencilFunc(GL_EQUAL, 1, 1);
    glStencilOp(GL_INCR, GL_KEEP, GL_DECR);

    glColor3ub(0, 200, 0);
    glBegin(GL_POLYGON);
      glVertex3i(3, 3, 0);
      glVertex3i(-3, 3, 0);
      glVertex3i(-3, -3, 0);
      glVertex3i(3, -3, 0);
    glEnd;

    glStencilFunc(GL_EQUAL, 1, 1);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);

    glColor3ub(0, 0, 200);
    glBegin(GL_POLYGON);
      glVertex3i(3, 3, 0);
      glVertex3i(-3, 3, 0);
      glVertex3i(-3, -3, 0);
      glVertex3i(3, -3, 0);
    glEnd;

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

 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 glOrtho(-5.0, 5.0, -5.0, 5.0, -5.0, 5.0);
 glMatrixMode(GL_MODELVIEW);

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


