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

procedure gluTessBeginPolygon (tess: GLUtesselator; polygon_data: Pointer); stdcall; external GLU32;

procedure errorCallback(errorCode : GLenum);stdcall;
begin
  Showmessage (gluErrorString(errorCode));
end;

type
  TData = Array [0..4, 0..5] of GLdouble;
  TVector = Array [0..2] of GLdouble;
  PTVector = ^TVector;
  TArray4F = Array [0..3] of GLfloat;
  TVector2 = Array [0..6] of GLdouble;

procedure combineCallback(coords : PTVector; data : TData;
          weight : TArray4F; var dataout : Pointer); stdcall;
var
   vertex : ^TVector2;
   i : 3..6;
begin
   GetMem (vertex, SizeOf (TVector2));
   vertex^[0] := coords[0];
   vertex^[1] := coords[1];
   vertex^[2] := coords[2];
   For i := 3 to 6 do
      vertex[i] := weight[0] * data[0][i]
                  + weight[1] * data[1][i]
                  + weight[2] * data[2][i]
                  + weight[3] * data[3][i];
   dataOut := vertex;
end;

const
 GLU_TESS_WINDING_RULE   = 100140;

procedure TfrmGL.Init;
var
   tobj : GLUtesselator;
const
   star : Array [0..4] of TVector =
                         ((250.0, 50.0, 0.0),
                          (325.0, 200.0, 0.0),
                          (400.0, 50.0, 0.0),
                          (250.0, 150.0, 0.0),
                          (400.0, 150.0, 0.0));
begin
   glClearColor(0.0, 0.0, 0.0, 0.0);

   tobj := gluNewTess;
   gluTessCallback(tobj, GLU_TESS_VERTEX, @glVertex3dv);
   gluTessCallback(tobj, GLU_TESS_BEGIN, @glBegin);
   gluTessCallback(tobj, GLU_TESS_END, @glEnd);
   gluTessCallback(tobj, GLU_TESS_ERROR, @errorCallback);

   gluTessCallback(tobj, GLU_TESS_COMBINE, @combineCallback);

   gluTessProperty(tobj, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_POSITIVE);

   glNewList(1, GL_COMPILE);
   gluTessBeginPolygon (tobj, nil);
      gluTessBeginContour(tobj);
         gluTessVertex(tobj, @star[0], @star[0]);
         gluTessVertex(tobj, @star[1], @star[1]);
         gluTessVertex(tobj, @star[2], @star[2]);
         gluTessVertex(tobj, @star[3], @star[3]);
         gluTessVertex(tobj, @star[4], @star[4]);
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
 glTranslatef (-100.0, 0.0, 0.0);
 InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
end;

end.

