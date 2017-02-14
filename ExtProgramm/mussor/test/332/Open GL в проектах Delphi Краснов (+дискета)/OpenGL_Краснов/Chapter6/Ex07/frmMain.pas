{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus,
  Controls, Dialogs, SysUtils,
  OpenGL;

const
  MAXSELECT = 128;                      // размер буфера выбора

type
  TVector = record
    x, y, z, w : GLfloat;
  end;
  AVector = Array [0..15] of TVector;

type
  PPointArray = ^TPointArray;
  TPointArray = Array [0..0] of AVector;
  ColorArray = Array [0..2] of GLfloat;
  PColorArray = ^TColorArray;
  TColorArray = Array [0..0] of ColorArray;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    DC: HDC;
    hrc: HGLRC;
    model : PPointArray;
    PatchColor : PColorArray;
    numpoint : Integer;

    lastx : Integer;
    vp : Array [0..3] of GLint;
    selectBuf : Array [0..MAXSELECT - 1] of GLuint;// буфер выбора

    function DoSelect(x : GLint; y : GLint) : GLint;
    procedure init_surface;
    procedure Init;
    procedure SetDCPixelFormat;
    procedure Render (mode : GLEnum);
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  showPoints : Boolean = false;
  Down : Boolean = false;

implementation

{$R *.DFM}

{=======================================================================
Выбор объекта в точке}
function TfrmGL.DoSelect(x : GLint; y : GLint) : GLint;
var
  hits : GLint;
begin
  glRenderMode(GL_SELECT);
  glInitNames;             // инициализация стека имен
  glPushName(0);           // помещение имени в стек имен

  glGetIntegerv(GL_VIEWPORT, @vp);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPickMatrix(x, ClientHeight - y, 4, 4, @vp);
  gluPerspective (45.0, ClientWidth / ClientHeight, 3.0, 25.0);
  glMatrixMode(GL_MODELVIEW);

  glClear(GL_COLOR_BUFFER_BIT);

  Render(GL_SELECT);

  hits := glRenderMode(GL_RENDER);

  if hits <= 0
     then DoSelect := -1
     else DoSelect := selectBuf[3];

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective (45.0, ClientWidth / ClientHeight, 3.0, 25.0);
  glMatrixMode(GL_MODELVIEW);
end;

{=======================================================================
Инициализация контрольных точек поверхности}
procedure TfrmGL.Init_Surface;
var
 f : TextFile;
 i, j : Integer;
begin
 AssignFile (f, 'Eye.txt');
 ReSet (f);
 ReadLn (f, numpoint);
 GetMem (Model, (numpoint + 1)* SizeOf (AVector));
 GetMem (PatchColor, (numpoint + 1)* SizeOf (ColorArray));
 For i := 0 to numpoint do begin
   For j := 0 to 15 do begin
      ReadLn (f, Model [i][j].x);
      ReadLn (f, Model [i][j].y);
      ReadLn (f, Model [i][j].z);
   end;
   PatchColor [i][0] := 1.0;
   PatchColor [i][1] := 0.0;
   PatchColor [i][2] := 0.0;
 end;
 CloseFile (f);
end;

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
  position : Array [0..3] of GLfloat = (5.0, -3.0, -18.0, 1.0);
const
  mat_specular : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 1.0);
  mat_shininess : GLfloat = 100.0;
begin
  glMaterialfv (GL_FRONT, GL_SHININESS, @mat_shininess);
  glEnable (GL_LIGHTING);
  glEnable (GL_LIGHT0);
  glLightfv(GL_LIGHT0, GL_POSITION, @position);
  glEnable (GL_DEPTH_TEST);
  glEnable (GL_AUTO_NORMAL);
  glEnable (GL_NORMALIZE);
  glEnable(GL_MAP2_VERTEX_3);
  glMapGrid2f(4, 0.0, 1.0, 4, 0.0, 1.0);

  glClearColor (1.0, 1.0, 1.0, 1.0);
  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, 1);

  glColorMaterial(GL_FRONT_AND_BACK, GL_DIFFUSE);
  glEnable(GL_COLOR_MATERIAL);

  glPointSize (5.0);
  init_surface;

  glTranslatef (0.0, 0.0, -7.0);
end;

procedure TfrmGL.Render (Mode : GLEnum);
var
  i : Integer;
begin
  glPushMatrix;
  glScalef (2.5, 2.5, 2.5);
  For i := 0 to numpoint do begin
      If mode = GL_SELECT
         then glLoadName (i)
         else glColor3fv(@PatchColor[i]);
      glMap2f(GL_MAP2_VERTEX_3, 0, 1, 4, 4, 0, 1, 16, 4, @model[i]);
      glEvalMesh2(GL_FILL, 0, 4, 0, 4);
  end;
  glPopMatrix;
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
  i, j : Integer;
begin
  BeginPaint (Handle, ps);

  glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  Render (GL_RENDER);

  glPushMatrix;

  // вывод опорных точек поверхности
  If showPoints then begin
    glScalef (2.5, 2.5, 2.5);
    glDisable (GL_LIGHTING);
    glBegin (GL_POINTS);
    For i := 0 to numpoint do
      For j := 0 to 15 do
	glVertex3f (model[i][j].x, model[i][j].y, model[i][j].z);
    glEnd;
    glEnable (GL_LIGHTING);
  end;

  glPopMatrix;

  SwapBuffers (DC);
  EndPaint (Handle, ps);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  glSelectBuffer(SizeOf(SelectBuf), @SelectBuf); // создание буфера выбора
  Init;
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective (45.0, ClientWidth / ClientHeight, 3.0, 25.0);
  glMatrixMode(GL_MODELVIEW);
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
  FreeMem (Model);
  FreeMem (PatchColor);
end;

{=======================================================================
Обработка нажатия клавиши}
procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
  If Key = VK_SPACE then begin
     showPoints := not showPoints;
     InvalidateRect(Handle, nil, False);
  end;
end;

{=======================================================================
Движение мыши}
procedure TfrmGL.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  If Down then begin
     glRotatef (lastx - x, 0, 1, 0);
     lastx := x;
     InvalidateRect(Handle, nil, False);
  end;
end;

{=======================================================================
Кнопка мыши отжата}
procedure TfrmGL.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Down := False;
end;

{=======================================================================
Кнопка мыши нажата}
procedure TfrmGL.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 hits : Integer;
begin
 hits := DoSelect (X, Y);
 If (button = mbLeft) and (hits = -1) then begin
    lastx := x;
    Down := True;
    end
    else begin
    PatchColor [hits][0] := 0.0;
    PatchColor [hits][1] := 1.0;
    PatchColor [hits][2] := 0.0;
    InvalidateRect(Handle, nil, False);
 end;
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


end.

