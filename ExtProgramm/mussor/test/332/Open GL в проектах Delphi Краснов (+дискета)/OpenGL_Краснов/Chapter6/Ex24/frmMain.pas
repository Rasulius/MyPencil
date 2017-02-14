{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Controls,
  SysUtils, Dialogs, OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC: HDC;
    hrc: HGLRC;

    function DoSelect (x, y : GLUInt) : Integer;
    procedure ortho;
    procedure SetDCPixelFormat;

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  antialiasing : Boolean = False;
  gridSize : Integer = 20;
  selectBuffer : Array [0..63] of GLuint;
  modelMatrix, projMatrix : Array [0..15] of GLdouble;
  viewport : Array [0..3] of GLint;
  selectedPoint : GLInt = -1;

var
  grid4x4 : Array [0..3, 0..3, 0..2] of GLfloat =
(
  (
    (-2.0, -2.0, 0.0),
    (-0.5, -2.0, 0.0),
    (0.5, -2.0, 0.0),
    (2.0, -2.0, 0.0)),
  (
    (-2.0, -0.5, 0.0),
    (-0.5, -0.5, 0.0),
    (0.5, -0.5, 0.0),
    (2.0, -0.5, 0.0)),
  (
    (-2.0, 0.5, 0.0),
    (-0.5, 0.5, 0.0),
    (0.5, 0.5, 0.0),
    (2.0, 0.5, 0.0)),
  (
    (-2.0, 2.0, 0.0),
    (-0.5, 2.0, 0.0),
    (0.5, 2.0, 0.0),
    (2.0, 2.0, 0.0))
);

const
   uSize = 4;
   vSize = 4;

implementation

{$R *.DFM}

procedure DrawControlPoints (mode : GLEnum);
var
  i, j : GLUInt;
begin
  glColor3f(1.0, 0.0, 0.0);
   For i := 0 to 3 do
      For j := 0 to 3 do begin
      If mode = GL_SELECT then glLoadName (i * 4 + j);
      glBegin (GL_POINTS);
	glVertex3fv (@grid4x4[i][j]);
      glEnd;
   end;
end;

procedure TfrmGL.ortho;
begin
  if ClientWidth <= ClientHeight
  then
    glOrtho(-4.0, 4.0, -4.0 * ClientHeight / ClientWidth,
      4.0 * ClientHeight / ClientWidth, -4.0, 4.0)
  else
    glOrtho(-4.0 * ClientWidth / ClientHeight,
      4.0 * ClientWidth / ClientHeight, -4.0, 4.0, -4.0, 4.0);
end;

function TfrmGL.DoSelect (x, y : GLUInt) : Integer;
var
  hits : GLUInt;
begin
  glRenderMode(GL_SELECT);
  glInitNames;
  glPushName(0);
  glMatrixMode(GL_PROJECTION);
  glPushMatrix;
  glLoadIdentity;
  gluPickMatrix(x, ClientHeight - y, 8.0, 8.0, @viewport);
  ortho;
  glMatrixMode(GL_MODELVIEW);
  DrawControlPoints (GL_SELECT);
  glMatrixMode(GL_PROJECTION);
  glPopMatrix;
  glMatrixMode(GL_MODELVIEW);
  hits := glRenderMode(GL_RENDER);
  if hits <= 0
     then Result := -1
     else Result := selectBuffer[3];
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  glClear(GL_COLOR_BUFFER_BIT);
  glColor3f(1.0, 1.0, 1.0);
  glMap2f(GL_MAP2_VERTEX_3, 0, 1, 3, uSize, 0, 1,
          uSize * 3, vSize, @grid4x4);
  glEvalMesh2(GL_LINE, 0, gridSize, 0, gridSize);

  DrawControlPoints (GL_RENDER);

  SwapBuffers(DC);                 // конец работы
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

  glSelectBuffer(sizeof(selectBuffer), @selectBuffer);

  glEnable(GL_MAP2_VERTEX_3);
  glMapGrid2f(gridSize, 0.0, 1.0, gridSize, 0.0, 1.0);

  glPointSize(10.0);
  glClearColor (0.5, 0.5, 0.75, 1.0); // цвет фона
end;

{=======================================================================
Устанавливаем формат пикселей}
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
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport (0, 0, ClientWidth, ClientHeight);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  ortho;
  glGetDoublev(GL_PROJECTION_MATRIX, @projMatrix);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glGetDoublev(GL_MODELVIEW_MATRIX, @modelMatrix);
  viewport[0] := 0;
  viewport[1] := 0;
  viewport[2] := ClientWidth;
  viewport[3] := ClientHeight;

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

procedure TfrmGL.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  selectedPoint := DoSelect (x, y);
end;

procedure TfrmGL.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  objx, objy, objz : GLdouble;
begin
  If selectedPoint >= 0 then begin
    gluUnProject(x, ClientHeight - y , 0.95,  @modelMatrix, @projMatrix,
                 @viewport, objx, objy, objz);
    grid4x4 [selectedPoint div 4, selectedPoint mod 4, 0] := objx;
    grid4X4 [selectedPoint div 4, selectedPoint mod 4, 1] := objy;
    InvalidateRect(Handle, nil, False);
  end
end;

procedure TfrmGL.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  selectedPoint := -1;
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_SPACE then begin
 antialiasing := not antialiasing;
 If antialiasing then begin
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    glEnable(GL_LINE_SMOOTH);
    glEnable(GL_POINT_SMOOTH);
    end
    else begin
    glDisable(GL_BLEND);
    glDisable(GL_LINE_SMOOTH);
    glDisable(GL_POINT_SMOOTH);
 end;
 InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_ESCAPE then Close
end;

end.

