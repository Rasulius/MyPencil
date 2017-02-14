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
    ctrlpoints : Array [0..3, 0..3, 0..2] of GLfloat;
    procedure init_surface;
  end;

var
  frmGL: TfrmGL;
  wrkX, wrkY : Integer;
  mode : Boolean = False;
  down : Boolean = False;
  solid : Boolean = True;

implementation

{$R *.DFM}

const
 uknots : Array [0..7] of GLfloat = (1.0, 1.0, 1.0, 1.0, 3.0, 5.0, 10.0, 15);
 vknots : Array [0..7] of GLfloat = (0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

{=======================================================================
Инициализация контрольных точек поверхности}
procedure TfrmGL.init_surface;
var
 u, v : Integer;
begin
  // диапазон точек от -3 до +3 по x, y, и z
  For u := 0 to 3 do
    For v := 0 to 3 do begin
      ctrlpoints [u][v][0] := 2.0 * (u - 1.5);
      ctrlpoints [u][v][1] := 2.0 * (v - 1.5);
      If (( (u = 1) or (u = 2)) and ((v = 1) or (v = 2)))
            then ctrlpoints[u][v][2] := 7.0
	    else ctrlpoints[u][v][2] := -3.0;
  end;
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
var
 i, j : Integer;
begin
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 glPushMatrix;
 glScalef (0.25, 0.25, 0.25);
 glColor3f (1.0, 0.0, 1.0);
 If solid
   then gluNurbsProperty(theNurb, GLU_DISPLAY_MODE, GLU_FILL)
   else gluNurbsProperty(theNurb, GLU_DISPLAY_MODE, GLU_OUTLINE_POLYGON);

 gluBeginSurface (theNurb);
    gluNurbsSurface (theNurb,
	             8, @uknots,
	             8, @vknots,
	             4 * 3,
	             3,
	             @ctrlpoints,
	             4, 4,
	             GL_MAP2_VERTEX_3);
 gluEndSurface (theNurb);

 // вывод опорных точек поверхности
 If mode then begin
    glDisable (GL_LIGHTING);
    glBegin (GL_POINTS);
    glColor3f (1.0, 1.0, 0.0);
    For i := 0 to 3 do
      For j := 0 to 3 do
	glVertex3fv (@ctrlpoints[i][j][0]);
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

 glEnable(GL_DEPTH_TEST);
 glEnable (GL_AUTO_NORMAL);
 glEnable (GL_NORMALIZE);
 glEnable (GL_COLOR_MATERIAL);

 // источник света
 glEnable(GL_LIGHTING);
 glEnable(GL_LIGHT0);
 glPointSize (5.0);

 // поверхность
 init_surface;

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
 If Key = VK_SPACE then begin
    mode := not mode;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_RETURN then begin
    solid := not solid;
    InvalidateRect(Handle, nil, False);
 end;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluPerspective (30.0, ClientWidth / ClientHeight, 3.0, 8.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef (0.0, 0.0, -5.0);

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

