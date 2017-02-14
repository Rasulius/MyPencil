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
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Controls, SysUtils,
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
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
 ps : TPaintStruct;
begin
 BeginPaint(Handle, ps);

 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 glColor4f (1.0, 1.0, 1.0, 1.0);
 glutWireIcosahedron;

 SwapBuffers(DC);
 EndPaint(Handle, ps);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
var
  values : Array [0..1] of GLfloat;
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  glGetFloatv (GL_LINE_WIDTH_GRANULARITY, @values);
  ShowMessage(Format ('GL_LINE_WIDTH_GRANULARITY value is %3.1f', [values[0]]));

  glGetFloatv (GL_LINE_WIDTH_RANGE, @values);

  ShowMessage(Format ('GL_LINE_WIDTH_RANGE values are %3.1f %3.1f', [values[0],
                       values[1]]));

  glEnable (GL_LINE_SMOOTH);
  glEnable (GL_BLEND);
  glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glHint (GL_LINE_SMOOTH_HINT, GL_DONT_CARE);
  glLineWidth (1.5);

  glShadeModel(GL_FLAT);
  glClearColor(0.0, 0.0, 0.0, 0.0);
  glDepthFunc(GL_LESS);
  glEnable(GL_DEPTH_TEST);
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

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewPort (0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluPerspective (45.0, ClientWidth / ClientHeight, 3.0, 5.0);

 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef (0.0, 0.0, -4.0);

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


end.

