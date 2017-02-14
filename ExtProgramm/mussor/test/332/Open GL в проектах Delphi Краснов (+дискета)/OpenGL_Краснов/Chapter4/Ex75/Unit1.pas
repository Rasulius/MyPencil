{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls,
  OpenGL;

type
  TfrmGL = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);

  private
    DC : HDC;
    hrc: HGLRC;
    procedure Init;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

const
 p75 : Array [0..127] of GLUbyte =
( $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff
);

procedure gluTessBeginPolygon (tess: GLUtesselator; polygon_data: Pointer); stdcall; external GLU32;

procedure errorCallback(errorCode : GLenum);stdcall;
begin
  Showmessage (gluErrorString(errorCode));
end;

type
  TVector = Array [0..2] of GLdouble;

procedure TfrmGL.Init;
var
   tobj : GLUtesselator;
   i : 0..9;
const
   detal : Array [0..9] of TVector =
   ((-0.23678, 0.35118, 0.0),
   (-0.23678, 0.7764, 0.0),
   (-0.37966, 0.7764, 0.0),
   (-0.55, 0.60606, 0.0),
   (-0.55, -0.4, 0.0),
   (0.45, -0.4, 0.0),
   (0.45, 0.60606, 0.0),
   (0.27966, 0.7764, 0.0),
   (0.13678, 0.7764, 0.0),
   (0.13678, 0.35118, 0.0)
   );
begin
   tobj := gluNewTess;
   gluTessCallback(tobj, GLU_TESS_VERTEX, @glVertex3dv);
   gluTessCallback(tobj, GLU_TESS_BEGIN, @glBegin);
   gluTessCallback(tobj, GLU_TESS_END, @glEnd);
   gluTessCallback(tobj, GLU_TESS_ERROR, @errorCallback);

   glNewList(1, GL_COMPILE);
   gluTessBeginPolygon (tobj, nil);
      gluTessBeginContour(tobj);
      For i := 0 to 9 do
         gluTessVertex(tobj, @detal[i], @detal[i]);
      gluTessEndContour(tobj);
   gluTessEndPolygon(tobj);
   glEndList;

   gluDeleteTess(tobj);
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 glClear (GL_COLOR_BUFFER_BIT);
 glPushMatrix;
   glScalef (200, 125, 1);
   glCallList(1);
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
 glEnable(GL_POLYGON_STIPPLE);
 glPolygonStipple(@p75);
 Randomize;
 Init;
 glClearColor (0.5, 0.5, 0.75, 1.0);
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 glDeleteLists (1, 1);
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC (Handle, DC);
 DeleteDC (DC);
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewPort (0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluOrtho2D(0.0, ClientWidth, 0.0, ClientHeight);
 glTranslatef (250, 100, 0);
 InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
end;

procedure TfrmGL.Timer1Timer(Sender: TObject);
begin
  glColor3f (random, random, random);
  InvalidateRect(Handle, nil, False);
end;

end.

