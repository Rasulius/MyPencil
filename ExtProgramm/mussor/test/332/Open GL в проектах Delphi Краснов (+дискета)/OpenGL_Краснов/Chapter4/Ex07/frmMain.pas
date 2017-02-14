{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
 Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Controls,
 SysUtils, Dialogs, OpenGL;

type
  TfrmGL = class(TForm)
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC : HDC;
    hrc : HGLRC;
    Angle : GLfloat;
    qObj : gluQuadricObj;

    procedure SetDCPixelFormat;

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

implementation

uses DGLUT;

{$R *.DFM}

const
  MaterialCyan : Array[0..3] of GLfloat = (0.0, 1.0, 1.0, 1.0);
  MaterialYellow : Array[0..3] of GLfloat = (1.0, 1.0, 0.0, 0.0);

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  // очистка буфера цвета и буфера глубины
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  // трехмерность
  glPushMatrix;
  glRotatef(Angle, 0.0, 1.0, 0.0); // поворот на угол
  glRotatef(Angle, 1.0, 0.0, 0.0); // поворот на угол

  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @MaterialCyan);
  glutSolidCube (2.0);
  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @MaterialYellow);
  glTranslatef (0.0, 0.0, -2.0);
  gluCylinder (qObj, 0.2, 0.2, 4.0, 10, 10);
  glRotatef (90, 1.0, 0.0, 0.0);
  glTranslatef (0.0, 2.0, -2.0);
  gluCylinder (qObj, 0.2, 0.2, 4.0, 10, 10);
  glTranslatef (-2.0, 0.0, 2.0);
  glRotatef (90, 0.0, 1.0, 0.0);
  gluCylinder (qObj, 0.2, 0.2, 4.0, 10, 10);

  glPopMatrix;

  SwapBuffers(DC);   // конец работы
  EndPaint(Handle, ps);
end;

{=======================================================================
Обработка таймера}
procedure TfrmGL.TimerTimer(Sender: TObject);
begin
  // Каждый "тик" изменяется значение угла
  Angle := Angle + 1.0;

  InvalidateRect(Handle, nil, False); // перерисовка региона
end;

{=======================================================================
Установка формата пикселей}
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
Создание формы}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  Angle := 0;
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  glEnable(GL_DEPTH_TEST); // разрешаем тест глубины
  glEnable(GL_LIGHTING);   // разрешаем работу с освещенностью
  glEnable(GL_LIGHT0);     // включаем источник света 0
  // Определяем свойства материала - лицевые стороны - рассеянный
  // цвет материала и диффузное отражение материала - значения из массива

  qObj := gluNewQuadric;

  Timer.Enabled := True;
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(40.0, ClientWidth / ClientHeight, 3.0, 20.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(0.0, 0.0, -8.0);

  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  Timer.Enabled := False;
  gluDeleteQuadric (qObj);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close
end;

end.

