{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

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
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC : HDC;
    hrc: HGLRC;
    procedure Init;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

type
  TVector = Array [0..2] of GLdouble;

procedure gluTessBeginPolygon (tess: GLUtesselator; polygon_data: Pointer); stdcall; external GLU32;

procedure vertexCallback (vertex : Pointer);stdcall;
begin
  glColor3f (random, random, random);
  glVertex3dv (vertex);
end;

var
 star : Array [0..20] of TVector;

procedure InitStar;
var
  i : 0..20;
begin
  For i := 0 to 20 do
    If Odd(i) then begin
      star [i, 0] := 75 * cos (i * Pi / 10) + 300;
      star [i, 1] := 75 * sin (i * Pi / 10) + 125;
      star [i, 2] := 0.0;
      end
      else begin
      star [i, 0] := 25 * cos (i * Pi / 10) + 300;
      star [i, 1] := 25 * sin (i * Pi / 10) + 125;
      star [i, 2] := 0.0;
  end;
end;

procedure errorCallback(errorCode : GLenum);stdcall;
begin
  ShowMessage (gluErrorString(errorCode));
end;

procedure TfrmGL.init;
var
   tobj : GLUtesselator;
   i : 0..20;
const
   rect : Array [0..3] of TVector = ((50.0, 50.0, 0.0),
                          (200.0, 50.0, 0.0),
                          (200.0, 200.0, 0.0),
                          (50.0, 200.0, 0.0));
   tri : Array[0..2] of TVector = ((75.0, 75.0, 0.0),
                         (125.0, 175.0, 0.0),
                         (175.0, 75.0, 0.0));
begin
   tobj := gluNewTess;
   gluTessCallback(tobj, GLU_TESS_BEGIN, @glBegin);
   gluTessCallback(tobj, GLU_TESS_VERTEX, @glVertex3dv);
   gluTessCallback(tobj, GLU_TESS_END, @glEnd);
   gluTessCallback(tobj, GLU_TESS_ERROR, @errorCallback);

   glNewList(1, GL_COMPILE);
   glColor3f(0.0, 0.0, 1.0);
   gluTessBeginPolygon (tobj, nil);
      gluTessBeginContour(tobj);
         gluTessVertex(tobj, @rect[0], @rect[0]);
         gluTessVertex(tobj, @rect[1], @rect[1]);
         gluTessVertex(tobj, @rect[2], @rect[2]);
         gluTessVertex(tobj, @rect[3], @rect[3]);
      gluTessEndContour(tobj);
      gluTessBeginContour(tobj);
         gluTessVertex(tobj, @tri[0], @tri[0]);
         gluTessVertex(tobj, @tri[1], @tri[1]);
         gluTessVertex(tobj, @tri[2], @tri[2]);
      gluTessEndContour(tobj);
   gluTessEndPolygon(tobj);
   glEndList;

   InitStar;

   gluTessCallback(tobj, GLU_TESS_VERTEX, @vertexcallback);

   glNewList(2, GL_COMPILE);
   gluTessBeginPolygon (tobj, nil);
      gluTessBeginContour(tobj);
        For i := 0 to 20 do
         gluTessVertex(tobj, @star [i], @star [i]);
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

 glCallList(1);
 glCallList(2);

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

 glClearColor (0.5, 0.5, 0.75, 1.0);
 Init;
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC(Handle, DC);
 DeleteDC (DC);
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewPort (0, 0, ClientWidth, ClientHeight);
 glClearColor (0.5, 0.5, 0.75, 1.0);
 glClear (GL_COLOR_BUFFER_BIT);

 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluOrtho2D(0.0, ClientWidth, 0.0, ClientHeight);
 InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
end;

end.

