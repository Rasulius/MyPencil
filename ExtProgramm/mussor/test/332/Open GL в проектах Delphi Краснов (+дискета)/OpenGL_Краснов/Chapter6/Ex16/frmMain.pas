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
 Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus,
 Controls, Dialogs, SysUtils,
 OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    DC : HDC;
    hrc : HGLRC;
    procedure SetDCPixelFormat;
  end;


var
  frmGL: TfrmGL;
  fontOffset : GLuint;
  rasters : Array [0..94, 0..12] of GLUByte = (
($00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00),
($00, $00, $18, $18, $00, $00, $18, $18, $18, $18, $18, $18, $18),
($00, $00, $00, $00, $00, $00, $00, $00, $00, $36, $36, $36, $36),
($00, $00, $00, $66, $66, $ff, $66, $66, $ff, $66, $66, $00, $00),
($00, $00, $18, $7e, $ff, $1b, $1f, $7e, $f8, $d8, $ff, $7e, $18),
($00, $00, $0e, $1b, $db, $6e, $30, $18, $0c, $76, $db, $d8, $70),
($00, $00, $7f, $c6, $cf, $d8, $70, $70, $d8, $cc, $cc, $6c, $38),
($00, $00, $00, $00, $00, $00, $00, $00, $00, $18, $1c, $0c, $0e),
($00, $00, $0c, $18, $30, $30, $30, $30, $30, $30, $30, $18, $0c),
($00, $00, $30, $18, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $18, $30),
($00, $00, $00, $00, $99, $5a, $3c, $ff, $3c, $5a, $99, $00, $00),
($00, $00, $00, $18, $18, $18, $ff, $ff, $18, $18, $18, $00, $00),
($00, $00, $30, $18, $1c, $1c, $00, $00, $00, $00, $00, $00, $00),
($00, $00, $00, $00, $00, $00, $ff, $ff, $00, $00, $00, $00, $00),
($00, $00, $00, $38, $38, $00, $00, $00, $00, $00, $00, $00, $00),
($00, $60, $60, $30, $30, $18, $18, $0c, $0c, $06, $06, $03, $03),
($00, $00, $3c, $66, $c3, $e3, $f3, $db, $cf, $c7, $c3, $66, $3c),
($00, $00, $7e, $18, $18, $18, $18, $18, $18, $18, $78, $38, $18),
($00, $00, $ff, $c0, $c0, $60, $30, $18, $0c, $06, $03, $e7, $7e),
($00, $00, $7e, $e7, $03, $03, $07, $7e, $07, $03, $03, $e7, $7e),
($00, $00, $0c, $0c, $0c, $0c, $0c, $ff, $cc, $6c, $3c, $1c, $0c),
($00, $00, $7e, $e7, $03, $03, $07, $fe, $c0, $c0, $c0, $c0, $ff),
($00, $00, $7e, $e7, $c3, $c3, $c7, $fe, $c0, $c0, $c0, $e7, $7e),
($00, $00, $30, $30, $30, $30, $18, $0c, $06, $03, $03, $03, $ff),
($00, $00, $7e, $e7, $c3, $c3, $e7, $7e, $e7, $c3, $c3, $e7, $7e),
($00, $00, $7e, $e7, $03, $03, $03, $7f, $e7, $c3, $c3, $e7, $7e),
($00, $00, $00, $38, $38, $00, $00, $38, $38, $00, $00, $00, $00),
($00, $00, $30, $18, $1c, $1c, $00, $00, $1c, $1c, $00, $00, $00),
($00, $00, $06, $0c, $18, $30, $60, $c0, $60, $30, $18, $0c, $06),
($00, $00, $00, $00, $ff, $ff, $00, $ff, $ff, $00, $00, $00, $00),
($00, $00, $60, $30, $18, $0c, $06, $03, $06, $0c, $18, $30, $60),
($00, $00, $18, $00, $00, $18, $18, $0c, $06, $03, $c3, $c3, $7e),
($00, $00, $3f, $60, $cf, $db, $d3, $dd, $c3, $7e, $00, $00, $00),
($00, $00, $c3, $c3, $c3, $c3, $ff, $c3, $c3, $c3, $66, $3c, $18),
($00, $00, $fe, $c7, $c3, $c3, $c7, $fe, $c7, $c3, $c3, $c7, $fe),
($00, $00, $7e, $e7, $c0, $c0, $c0, $c0, $c0, $c0, $c0, $e7, $7e),
($00, $00, $fc, $ce, $c7, $c3, $c3, $c3, $c3, $c3, $c7, $ce, $fc),
($00, $00, $ff, $c0, $c0, $c0, $c0, $fc, $c0, $c0, $c0, $c0, $ff),
($00, $00, $c0, $c0, $c0, $c0, $c0, $c0, $fc, $c0, $c0, $c0, $ff),
($00, $00, $7e, $e7, $c3, $c3, $cf, $c0, $c0, $c0, $c0, $e7, $7e),
($00, $00, $c3, $c3, $c3, $c3, $c3, $ff, $c3, $c3, $c3, $c3, $c3),
($00, $00, $7e, $18, $18, $18, $18, $18, $18, $18, $18, $18, $7e),
($00, $00, $7c, $ee, $c6, $06, $06, $06, $06, $06, $06, $06, $06),
($00, $00, $c3, $c6, $cc, $d8, $f0, $e0, $f0, $d8, $cc, $c6, $c3),
($00, $00, $ff, $c0, $c0, $c0, $c0, $c0, $c0, $c0, $c0, $c0, $c0),
($00, $00, $c3, $c3, $c3, $c3, $c3, $c3, $db, $ff, $ff, $e7, $c3),
($00, $00, $c7, $c7, $cf, $cf, $df, $db, $fb, $f3, $f3, $e3, $e3),
($00, $00, $7e, $e7, $c3, $c3, $c3, $c3, $c3, $c3, $c3, $e7, $7e),
($00, $00, $c0, $c0, $c0, $c0, $c0, $fe, $c7, $c3, $c3, $c7, $fe),
($00, $00, $3f, $6e, $df, $db, $c3, $c3, $c3, $c3, $c3, $66, $3c),
($00, $00, $c3, $c6, $cc, $d8, $f0, $fe, $c7, $c3, $c3, $c7, $fe),
($00, $00, $7e, $e7, $03, $03, $07, $7e, $e0, $c0, $c0, $e7, $7e),
($00, $00, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $ff),
($00, $00, $7e, $e7, $c3, $c3, $c3, $c3, $c3, $c3, $c3, $c3, $c3),
($00, $00, $18, $3c, $3c, $66, $66, $c3, $c3, $c3, $c3, $c3, $c3),
($00, $00, $c3, $e7, $ff, $ff, $db, $db, $c3, $c3, $c3, $c3, $c3),
($00, $00, $c3, $66, $66, $3c, $3c, $18, $3c, $3c, $66, $66, $c3),
($00, $00, $18, $18, $18, $18, $18, $18, $3c, $3c, $66, $66, $c3),
($00, $00, $ff, $c0, $c0, $60, $30, $7e, $0c, $06, $03, $03, $ff),
($00, $00, $3c, $30, $30, $30, $30, $30, $30, $30, $30, $30, $3c),
($00, $03, $03, $06, $06, $0c, $0c, $18, $18, $30, $30, $60, $60),
($00, $00, $3c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $3c),
($00, $00, $00, $00, $00, $00, $00, $00, $00, $c3, $66, $3c, $18),
($ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00),
($00, $00, $00, $00, $00, $00, $00, $00, $00, $18, $38, $30, $70),
($00, $00, $7f, $c3, $c3, $7f, $03, $c3, $7e, $00, $00, $00, $00),
($00, $00, $fe, $c3, $c3, $c3, $c3, $fe, $c0, $c0, $c0, $c0, $c0),
($00, $00, $7e, $c3, $c0, $c0, $c0, $c3, $7e, $00, $00, $00, $00),
($00, $00, $7f, $c3, $c3, $c3, $c3, $7f, $03, $03, $03, $03, $03),
($00, $00, $7f, $c0, $c0, $fe, $c3, $c3, $7e, $00, $00, $00, $00),
($00, $00, $30, $30, $30, $30, $30, $fc, $30, $30, $30, $33, $1e),
($7e, $c3, $03, $03, $7f, $c3, $c3, $c3, $7e, $00, $00, $00, $00),
($00, $00, $c3, $c3, $c3, $c3, $c3, $c3, $fe, $c0, $c0, $c0, $c0),
($00, $00, $18, $18, $18, $18, $18, $18, $18, $00, $00, $18, $00),
($38, $6c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $00, $00, $0c, $00),
($00, $00, $c6, $cc, $f8, $f0, $d8, $cc, $c6, $c0, $c0, $c0, $c0),
($00, $00, $7e, $18, $18, $18, $18, $18, $18, $18, $18, $18, $78),
($00, $00, $db, $db, $db, $db, $db, $db, $fe, $00, $00, $00, $00),
($00, $00, $c6, $c6, $c6, $c6, $c6, $c6, $fc, $00, $00, $00, $00),
($00, $00, $7c, $c6, $c6, $c6, $c6, $c6, $7c, $00, $00, $00, $00),
($c0, $c0, $c0, $fe, $c3, $c3, $c3, $c3, $fe, $00, $00, $00, $00),
($03, $03, $03, $7f, $c3, $c3, $c3, $c3, $7f, $00, $00, $00, $00),
($00, $00, $c0, $c0, $c0, $c0, $c0, $e0, $fe, $00, $00, $00, $00),
($00, $00, $fe, $03, $03, $7e, $c0, $c0, $7f, $00, $00, $00, $00),
($00, $00, $1c, $36, $30, $30, $30, $30, $fc, $30, $30, $30, $00),
($00, $00, $7e, $c6, $c6, $c6, $c6, $c6, $c6, $00, $00, $00, $00),
($00, $00, $18, $3c, $3c, $66, $66, $c3, $c3, $00, $00, $00, $00),
($00, $00, $c3, $e7, $ff, $db, $c3, $c3, $c3, $00, $00, $00, $00),
($00, $00, $c3, $66, $3c, $18, $3c, $66, $c3, $00, $00, $00, $00),
($c0, $60, $60, $30, $18, $3c, $66, $66, $c3, $00, $00, $00, $00),
($00, $00, $ff, $60, $30, $18, $0c, $06, $ff, $00, $00, $00, $00),
($00, $00, $0f, $18, $18, $18, $38, $f0, $38, $18, $18, $18, $0f),
($18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18),
($00, $00, $f0, $18, $18, $18, $1c, $0f, $1c, $18, $18, $18, $f0),
($00, $00, $00, $00, $00, $00, $06, $8f, $f1, $60, $00, $00, $00)
);

implementation

{$R *.DFM}

procedure makeRasterFont;
var
  i : GLuint;
begin
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  fontOffset := glGenLists (128);
  For i := 32 to 127 do begin
    glNewList(i + fontOffset, GL_COMPILE);
      glBitmap(8, 13, 0.0, 2.0, 10.0, 0.0, @rasters[i-32]);
    glEndList;
  end;
end;

procedure printString(s : String);
begin
  glPushAttrib (GL_LIST_BIT);
  glListBase(fontOffset);
  glCallLists(length(s), GL_UNSIGNED_BYTE, PChar(s));
  glPopAttrib;
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 glClear(GL_COLOR_BUFFER_BIT);
 glRasterPos2i(20, 100);
 printString('The quick brown fox jump');
 glRasterPos2i(20, 82);
 printString('over a lazy dog.');

 SwapBuffers(DC);
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
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  glClearColor (0.3, 0.4, 0.6, 1.0);
  glColor3f (1.0, 0.0, 0.0);
  makeRasterFont;
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glOrtho (0.0, ClientWidth, 0.0, ClientHeight, -1.0, 1.0);
  glMatrixMode(GL_MODELVIEW);
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  glDeleteLists (fontOffset, 95);
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

