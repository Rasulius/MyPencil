{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Controls,
  Dialogs, SysUtils,
  OpenGL;

type
  TfrmGL = class(TForm)
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    Quit: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure N1Click(Sender: TObject);
    procedure QuitClick(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    DC: HDC;
    hrc: HGLRC;
    theNurb : GLUnurbsObj;
    ctlpoints : Array [0..3, 0..3, 0..2] of GLFloat;
    lastx : Integer;
    selu, selv : 0..3;
    procedure init_surface;
    procedure Init;
    procedure SetDCPixelFormat;

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  showPoints : Boolean = False;
  down : Boolean = False;

implementation

{$R *.DFM}

{=======================================================================
Инициализация контрольных точек поверхности}
procedure TfrmGL.init_surface;
var
 u, v : Integer;
begin
  // диапазон точек от -3 до +3 по x, y, и z
  For u := 0 to 3 do
    For v := 0 to 3 do begin
      ctlpoints [u][v][0] := 2.0 * (u - 1.5);
      ctlpoints [u][v][1] := 2.0 * (v - 1.5);
      If (( (u = 1) or (u = 2)) and ((v = 1) or (v = 2)))
            then ctlpoints[u][v][2] := 7.0
	    else ctlpoints[u][v][2] := -3.0;
  end;
end;

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
  mat_diffuse : Array [0..3] of GLFloat = (0.7, 0.7, 0.7, 1.0);
  mat_specular : Array [0..3] of GLFloat = (1.0, 1.0, 1.0, 1.0);
  mat_shininess : GLFloat = 100.0;
begin
  glClearColor (0.0, 0.0, 0.0, 1.0);
  glMaterialfv (GL_FRONT, GL_DIFFUSE, @mat_diffuse);
  glMaterialfv (GL_FRONT, GL_SPECULAR, @mat_specular);
  glMaterialfv (GL_FRONT, GL_SHININESS, @mat_shininess);
  glEnable (GL_LIGHTING);
  glEnable (GL_LIGHT0);
  glEnable (GL_DEPTH_TEST);
  glEnable (GL_AUTO_NORMAL);
  glEnable (GL_NORMALIZE);
  glPointSize (5.0);
  init_surface;
  theNurb := gluNewNurbsRenderer;
  gluNurbsProperty (theNurb, GLU_SAMPLING_TOLERANCE, 25.0);
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
  i, j : Integer;
const
  knots : Array [0..7] of GLFloat = (0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);
begin
  BeginPaint (Handle, ps);

  glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glPushMatrix;
  glRotatef (330.0, 1.0,0.0,0.0);
  glScalef (0.25, 0.25, 0.25);
  gluBeginSurface (theNurb);
  gluNurbsSurface (theNurb,
	    8, @knots,
	    8, @knots,
	    4 * 3,
	    3,
	    @ctlpoints,
	    4, 4,
	    GL_MAP2_VERTEX_3);
  gluEndSurface (theNurb);
  // вывод опорных точек
  If showPoints then begin
    glDisable (GL_LIGHTING);
    glBegin (GL_POINTS);
    For i := 0 to 3 do
      For j := 0 to 3 do begin
        If (i = selu) and (j = selv)     // выбранная точка - красная
           then glColor3f (1.0, 0.0, 0.0)
           else glColor3f (1.0, 1.0, 0.0);
	glVertex3f (ctlpoints[i][j][0], ctlpoints[i][j][1], ctlpoints[i][j][2]);
    end;
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
  selu := 0;
  selv := 0;
  Init;
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective (45.0, ClientWidth / ClientHeight, 3.0, 8.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef (0.0, 0.0, -5.0);
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  gluDeleteNurbsRenderer (theNurb);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

{=======================================================================
Пункты меню}
procedure TfrmGL.N1Click(Sender: TObject);
begin
  Case (Sender as TComponent).Tag of
    0 : showPoints := False;
    1 : showPoints := True;
    2 : gluNurbsProperty(theNurb, GLU_DISPLAY_MODE, GLU_FILL);
    3 : gluNurbsProperty(theNurb, GLU_DISPLAY_MODE, GLU_OUTLINE_POLYGON);
  end;
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Пункт меню 'Quit'}
procedure TfrmGL.QuitClick(Sender: TObject);
begin
  Close;
end;

{=======================================================================
Движение мыши}
procedure TfrmGL.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  If down then begin
     glRotatef (lastx - x, 0, 1, 0);
     lastx := x;
     InvalidateRect(Handle, nil, False);
  end;
end;

{=======================================================================
Кнопка мыши отпущена}
procedure TfrmGL.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  down := False;
end;

{=======================================================================
Кнопка мыши нажата}
procedure TfrmGL.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 If button = mbLeft then begin
    lastx := x;
    down := True;
 end;
end;

{=======================================================================
Обработка нажатия клавиши}
procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then begin
     Close;
     Exit;
  end;
  // работа с выбранной опорной точкой
  Case Key of
     VK_UP   : selu := (selu + 1) and 3;
     VK_DOWN : selu := (selu - 1) and 0;
     VK_LEFT : selv := (selv + 1) and 3;
     VK_RIGHT: selv := (selv - 1) and 0;
     Ord ('X') : If ssShift in Shift
                    then ctlpoints [selu][selv][0] := ctlpoints [selu][selv][0] + 0.1
                    else ctlpoints [selu][selv][0] := ctlpoints [selu][selv][0] - 0.1;
     Ord ('Y') : If ssShift in Shift
                    then ctlpoints [selu][selv][1] := ctlpoints [selu][selv][1] + 0.1
                    else ctlpoints [selu][selv][1] := ctlpoints [selu][selv][1] - 0.1;
     Ord ('Z') : If ssShift in Shift
                    then ctlpoints [selu][selv][2] := ctlpoints [selu][selv][2] + 0.1
                    else ctlpoints [selu][selv][2] := ctlpoints [selu][selv][2] - 0.1
  end;
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Устанавливаем формат пикселей}
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

