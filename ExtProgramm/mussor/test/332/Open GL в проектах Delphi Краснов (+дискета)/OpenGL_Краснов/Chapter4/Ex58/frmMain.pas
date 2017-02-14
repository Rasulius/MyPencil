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
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, OpenGL;

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
  thing1, thing2 : GLint;

implementation

{$R *.DFM}

procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  glClearColor(0.0, 0.0, 0.0, 0.0);
  glClearAccum(0.0, 0.0, 0.0, 0.0);

  thing1 := glGenLists(1);
  glNewList(thing1, GL_COMPILE);
    glColor3f(1.0, 0.0, 0.0);
    glRectf(-1.0, -1.0, 1.0, 0.0);
  glEndList;

  thing2 := glGenLists(1);
  glNewList(thing2, GL_COMPILE);
    glColor3f(0.0, 1.0, 0.0);
    glRectf(0.0, -1.0, 1.0, 1.0);
  glEndList;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  glPushMatrix;

  glScalef(0.8, 0.8, 1.0);

  glClear(GL_COLOR_BUFFER_BIT);
  glCallList(thing1);
  glAccum(GL_LOAD, 0.5);

  glClear(GL_COLOR_BUFFER_BIT);
  glCallList(thing2);
  glAccum(GL_ACCUM, 0.5);

  glAccum(GL_RETURN, 1.0);

  glPopMatrix;

  SwapBuffers(DC);
  EndPaint(Handle, ps);
end;

procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  glDeleteLists (thing1, 1);
  glDeleteLists (thing2, 1);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close;
 If Key = 49 then glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
 If Key = 50 then glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
 InvalidateRect(Handle, nil, False);
end;

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

