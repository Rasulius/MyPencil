{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Controls,
  SysUtils, Dialogs,
  OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC: HDC;
    hrc: HGLRC;
    procedure SetDCPixelFormat;

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
 vertex : Array [0..5, 0..3, 0..2] of GLFloat = (
  ((-1.0,-1.0, 1.0),(-1.0, 1.0, 1.0),( 1.0,-1.0, 1.0),( 1.0, 1.0, 1.0)),
  ((-1.0, 1.0, 1.0),(-1.0, 1.0,-1.0),( 1.0, 1.0, 1.0),( 1.0, 1.0,-1.0)),
  (( 1.0,-1.0, 1.0),( 1.0, 1.0, 1.0),( 1.0,-1.0,-1.0),( 1.0, 1.0,-1.0)),
  (( 1.0,-1.0,-1.0),( 1.0, 1.0,-1.0),(-1.0,-1.0,-1.0),(-1.0, 1.0,-1.0)),
  ((-1.0,-1.0,-1.0),(-1.0,-1.0, 1.0),( 1.0,-1.0,-1.0),( 1.0,-1.0, 1.0)),
  ((-1.0,-1.0,-1.0),(-1.0, 1.0,-1.0),(-1.0,-1.0, 1.0),(-1.0, 1.0, 1.0)));

 colors : Array [0..5, 0..2] of GLFloat = (
	(1.0, 1.0, 1.0), (1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0),
	(1.0, 1.0, 0.0), (0.0, 1.0, 1.0));

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
Перерисовка окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
 ps : TPaintStruct;
 i : integer;
begin
  BeginPaint(Handle, ps);

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glPushMatrix;
  glTranslatef(0.0, 0.0, -5.0);
  glRotatef(-45.0, 1.0, 0.0, 0.0);
  glRotatef(45.0, 0.0, 1.0, 0.0);
  For i := 0 to 5 do begin
    glColor3fv(@colors[i][0]);
    glBegin(GL_TRIANGLE_STRIP);
      glVertex3fv (@vertex[i][0][0]);
      glVertex3fv (@vertex[i][1][0]);
      glVertex3fv (@vertex[i][2][0]);
      glVertex3fv (@vertex[i][3][0]);
    glEnd;
  end;
  glPopMatrix;

  SwapBuffers(DC);
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

  glEnable(GL_DEPTH_TEST);// разрешаем тест глубины
  glEnable(GL_LIGHTING); // разрешаем работу с освещенностью
  glEnable(GL_LIGHT0);   // включаем источник света 0
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
  gluPerspective (45.0, ClientWidth / ClientHeight, 1.0, 100.0);
  gluLookAt(0.0, 0.0, 0.0, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_COLOR_MATERIAL);
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
var
 Viewport : Array [0..3] of GLInt;
 mvMatrix, ProjMatrix : Array [0..15] of GLDouble;
 RealY : GLint ;          // позиция OpenGL y - координаты
 wx, wy, wz : GLdouble ;  // возвращаемые мировые x, y, z координаты
 Zval : GLfloat;
begin
 glGetIntegerv (GL_VIEWPORT, @Viewport);
 glGetDoublev (GL_MODELVIEW_MATRIX, @mvMatrix);
 glGetDoublev (GL_PROJECTION_MATRIX, @ProjMatrix);
 // viewport[3] - высота окна в пикселях
 RealY := viewport[3] - Y - 1;
 Caption := 'Координаты курсора ' + IntToStr (x) + ' ' +
            FloatToStr (RealY);

 glReadPixels(X, RealY, 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, @Zval);

 gluUnProject (X, RealY, Zval,
                @mvMatrix, @ProjMatrix, @Viewport, wx, wy, wz);

 ShowMessage ('Мировые координаты для z=' + FloatToStr(Zval)
              + ' : ' + chr (13) + '(' + FloatToStr(wx)
              + '; ' + FloatToStr(wy)
              + '; ' + FloatToStr(wz) + ')');
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
end;

end.

