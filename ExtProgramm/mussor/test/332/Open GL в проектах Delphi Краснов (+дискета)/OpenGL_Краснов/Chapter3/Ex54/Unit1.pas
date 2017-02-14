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
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    DC : HDC;
    hrc: HGLRC;
    theNurb : GLUnurbsObj;
  end;

var
  frmGL: TfrmGL;
  wrkX, wrkY : Integer;
  down : Boolean = False;
  solid : Boolean = True;
  points : Boolean = False;

implementation

{$R *.DFM}

const
    S_NUMPOINTS = 13;
    S_ORDER     = 3;
    S_NUMKNOTS  = (S_NUMPOINTS + S_ORDER);
    T_NUMPOINTS = 3;
    T_ORDER     = 3;
    T_NUMKNOTS  = (T_NUMPOINTS + T_ORDER);
    SQRT2       = 1.41421356237309504880; // Sqrt(2)

// initialized local data

const
    sknots      : array[0..S_NUMKNOTS-1] of GLfloat =
        (-1.0, -1.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0,
          4.0,  5.0,  6.0, 7.0, 8.0, 9.0, 9.0, 9.0);

    tknots      : array[0..T_NUMKNOTS-1] of GLfloat =
        (1.0, 1.0, 1.0, 2.0, 2.0, 2.0);

    ctlpoints   : array[0..S_NUMPOINTS-1,0..T_NUMPOINTS-1,0..3] of GLfloat =
        (
            ((4.0,2.0,2.0,1.0),
             (4.0,1.6,2.5,1.0),
             (4.0,2.0,3.0,1.0)),
            ((5.0,4.0,2.0,1.0),
             (5.0,4.0,2.5,1.0),
             (5.0,4.0,3.0,1.0)),
            ((6.0,5.0,2.0,1.0),
             (6.0,5.0,2.5,1.0),
             (6.0,5.0,3.0,1.0)),
            ((SQRT2*6.0,SQRT2*6.0,SQRT2*2.0,SQRT2),
             (SQRT2*6.0,SQRT2*6.0,SQRT2*2.5,SQRT2),
             (SQRT2*6.0,SQRT2*6.0,SQRT2*3.0,SQRT2)),
            ((5.2,6.7,2.0,1.0),
             (5.2,6.7,2.5,1.0),
             (5.2,6.7,3.0,1.0)),
            ((SQRT2*4.0,SQRT2*6.0,SQRT2*2.0,SQRT2),
             (SQRT2*4.0,SQRT2*6.0,SQRT2*2.5,SQRT2),
             (SQRT2*4.0,SQRT2*6.0,SQRT2*3.0,SQRT2)),
            ((4.0,5.2,2.0,1.0),
             (4.0,4.6,2.5,1.0),
             (4.0,5.2,3.0,1.0)),
            ((SQRT2*4.0,SQRT2*6.0,SQRT2*2.0,SQRT2),
             (SQRT2*4.0,SQRT2*6.0,SQRT2*2.5,SQRT2),
             (SQRT2*4.0,SQRT2*6.0,SQRT2*3.0,SQRT2)),
            ((2.8,6.7,2.0,1.0),
             (2.8,6.7,2.5,1.0),
             (2.8,6.7,3.0,1.0)),
            ((SQRT2*2.0,SQRT2*6.0,SQRT2*2.0,SQRT2),
             (SQRT2*2.0,SQRT2*6.0,SQRT2*2.5,SQRT2),
             (SQRT2*2.0,SQRT2*6.0,SQRT2*3.0,SQRT2)),
            ((2.0,5.0,2.0,1.0),
             (2.0,5.0,2.5,1.0),
             (2.0,5.0,3.0,1.0)),
            ((3.0,4.0,2.0,1.0),
             (3.0,4.0,2.5,1.0),
             (3.0,4.0,3.0,1.0)),
            ((4.0,2.0,2.0,1.0),
             (4.0,1.6,2.5,1.0),
             (4.0,2.0,3.0,1.0))
        );


{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
var
 i, j : GLint;
begin
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 glPushMatrix;

 If solid
   then gluNurbsProperty(theNurb, GLU_DISPLAY_MODE, GLU_FILL)
   else gluNurbsProperty(theNurb, GLU_DISPLAY_MODE, GLU_OUTLINE_POLYGON);

 gluBeginSurface(theNurb);
   gluNurbsSurface(theNurb,
       S_NUMKNOTS, @sknots,
       T_NUMKNOTS, @tknots,
       4 * T_NUMPOINTS,
       4,
       @ctlpoints,
       S_ORDER, T_ORDER,
       GL_MAP2_VERTEX_4);
 gluEndSurface(theNurb);

 If points then begin
    glPointSize(5.0);
    glDisable (GL_LIGHTING);
    glColor3f(1.0, 1.0, 0.0);
    glBegin(GL_POINTS);
      For j := 0 to S_NUMPOINTS-1 do
          For i := 0 to T_NUMPOINTS-1 do
              glVertex3fv(@ctlpoints[i][j][0]);
    glEnd;
    glEnable (GL_LIGHTING);
 end;

 glPopMatrix;

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

 glEnable (GL_DEPTH_TEST);
 glEnable (GL_AUTO_NORMAL);

 glClearColor (1.0, 1.0, 1.0, 1.0);

 // источник света
 glEnable(GL_LIGHTING);
 glEnable(GL_LIGHT0);

 theNurb := gluNewNurbsRenderer;
 gluNurbsProperty (theNurb, GLU_SAMPLING_TOLERANCE, 25.0);
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 gluDeleteNurbsRenderer(theNurb);
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC (Handle, DC);
 DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close;
 If Key = VK_RETURN then begin
    solid := not solid;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_SPACE then begin
    points := not points;
    InvalidateRect(Handle, nil, False);
 end;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 glFrustum(-1.0, 1.0, -1.5, 0.5, 0.8, 15.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 gluLookAt(7.0,4.5,4.0, 4.5,4.5,2.0, 6.0,-3.0,2.0);

 InvalidateRect(Handle, nil, False);
end;


procedure TfrmGL.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Down := True;
  wrkX := X;
  wrkY := Y;
end;

procedure TfrmGL.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Down := False;
end;

procedure TfrmGL.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  If Down then begin
     glRotatef (X - wrkX, 0.0, 1.0, 0.0);
     glRotatef (Y - wrkY, 1.0, 0.0, 0.0);
     InvalidateRect(Handle, nil, False);
     wrkX := X;
     wrkY := Y;
  end;
end;

end.

