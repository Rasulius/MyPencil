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

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);

  private
    DC : HDC;
    hrc: HGLRC;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

const
    _PT     = 1;
    _STROKE = 2;
    _END    = 3;

type
    PCP = ^CP;
    CP  = record
        x, y    : GLfloat;
        _type   : GLint;
    end;

const
    dataA   : array[0..7] of CP =
        (
            (x: 0; y:  0; _type:     _PT),
            (x: 0; y:  9; _type:     _PT),
            (x: 1; y: 10; _type:     _PT),
            (x: 4; y: 10; _type:     _PT),
            (x: 5; y:  9; _type:     _PT),
            (x: 5; y:  0; _type: _STROKE),
            (x: 0; y:  5; _type:     _PT),
            (x: 5; y:  5; _type:    _END)
        );

    dataE   : array[0..5] of CP =
        (
            (x: 5; y:  0; _type:     _PT),
            (x: 0; y:  0; _type:     _PT),
            (x: 0; y: 10; _type:     _PT),
            (x: 5; y: 10; _type: _STROKE),
            (x: 0; y:  5; _type:     _PT),
            (x: 4; y:  5; _type:    _END)
        );

    dataP   : array[0..6] of CP =
        (
            (x: 0; y:  0; _type:     _PT),
            (x: 0; y: 10; _type:     _PT),
            (x: 4; y: 10; _type:     _PT),
            (x: 5; y:  9; _type:     _PT),
            (x: 5; y:  6; _type:     _PT),
            (x: 4; y:  5; _type:     _PT),
            (x: 0; y:  5; _type:    _END)
        );

    dataR   : array[0..8] of CP =
        (
            (x: 0; y:  0; _type:     _PT),
            (x: 0; y: 10; _type:     _PT),
            (x: 4; y: 10; _type:     _PT),
            (x: 5; y:  9; _type:     _PT),
            (x: 5; y:  6; _type:     _PT),
            (x: 4; y:  5; _type:     _PT),
            (x: 0; y:  5; _type: _STROKE),
            (x: 3; y:  5; _type:     _PT),
            (x: 5; y:  0; _type:    _END)
        );

    dataS   : array[0..11] of CP =
        (
            (x: 0; y:  1; _type:     _PT),
            (x: 1; y:  0; _type:     _PT),
            (x: 4; y:  0; _type:     _PT),
            (x: 5; y:  1; _type:     _PT),
            (x: 5; y:  4; _type:     _PT),
            (x: 4; y:  5; _type:     _PT),
            (x: 1; y:  5; _type:     _PT),
            (x: 0; y:  6; _type:     _PT),
            (x: 0; y:  9; _type:     _PT),
            (x: 1; y: 10; _type:     _PT),
            (x: 4; y: 10; _type:     _PT),
            (x: 5; y:  9; _type:    _END)
        );

procedure   DrawLetter(l: PCP);
begin
    glBegin(GL_LINE_STRIP);
    while True do
    begin
        case l._type of
            _PT     : glVertex2fv(@l.x);
            _STROKE : begin
                        glVertex2fv(@l.x);
                        glEnd();
                        glBegin(GL_LINE_STRIP);
                      end;
            _END    : begin
                        glVertex2fv(@l.x);
                        glEnd();
                        glTranslatef(8.0, 0.0, 0.0);
                        Exit;
                      end;
        end;
        Inc(l);
    end;
end;

procedure   MyInit;
var
    base    : GLuint;
begin
    glShadeModel (GL_FLAT);

    base := glGenLists (128);
    glListBase(base);
    glNewList(base+Ord('A'), GL_COMPILE); drawLetter(@dataA); glEndList();
    glNewList(base+Ord('E'), GL_COMPILE); drawLetter(@dataE); glEndList();
    glNewList(base+Ord('P'), GL_COMPILE); drawLetter(@dataP); glEndList();
    glNewList(base+Ord('R'), GL_COMPILE); drawLetter(@dataR); glEndList();
    glNewList(base+Ord('S'), GL_COMPILE); drawLetter(@dataS); glEndList();
    glNewList(base+Ord(' '), GL_COMPILE); glTranslatef(8.0, 0.0, 0.0); glEndList();
end;

const
    Test1 = 'A SPARE SERAPE APPEARS AS';
    Test2 = 'APES PREPARE RARE PEPPERS';

procedure   PrintStrokedString(const S: string);
begin
    glCallLists(Length(S), GL_BYTE, PGLbyte(PChar(s)));
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
  glClear(GL_COLOR_BUFFER_BIT);
  glColor3f(1.0, 1.0, 1.0);
  glPushMatrix;
  glScalef(2.0, 2.0, 2.0);
  glTranslatef(10.0, 30.0, 0.0);
  printStrokedString(test1);
  glPopMatrix;
  glPushMatrix;
  glScalef(2.0, 2.0, 2.0);
  glTranslatef(10.0, 13.0, 0.0);
  printStrokedString(test2);
  glPopMatrix;
  glFlush;

  SwapBuffers(DC);
end;

{=======================================================================
Формат пикселя}
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPixelFormatDescriptor;
 nPixelFormat : Integer;
begin
 FillChar (pfd, SizeOf (pfd), 0);
 pfd.dwFlags  := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
 nPixelFormat := ChoosePixelFormat (hdc, @pfd);
 SetPixelFormat (hdc, nPixelFormat, @pfd);
end;

{=======================================================================
Создание формы}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
 DC := GetDC (Handle);
 SetDCPixelFormat(DC);
 hrc := wglCreateContext(DC);
 wglMakeCurrent(DC, hrc);
 glClearColor (0.5, 0.5, 0.75, 1.0); // цвет фона
 glColor3f (1.0, 0.0, 0.5);          // текущий цвет примитивов
 MyInit;
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC (Handle, DC);
 DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 glOrtho(0.0, ClientWidth, 0.0, ClientHeight, -1.0, 1.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 InvalidateRect(Handle, nil, False);
end;

end.

