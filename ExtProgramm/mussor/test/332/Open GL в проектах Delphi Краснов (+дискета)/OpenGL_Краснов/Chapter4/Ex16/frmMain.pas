{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Controls,
  Dialogs, OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC: HDC;
    hrc: HGLRC;
    uTimerId : uint;

    year : Integer;
    day : Integer;

    procedure SetDCPixelFormat;

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

implementation

uses mmSystem, DGLUT;

{$R *.DFM}

{=======================================================================
Обработка таймера}
procedure FNTimeCallBack(uTimerID, uMessage: UINT;dwUser, dw1, dw2: DWORD) stdcall;
begin
  With frmGL do begin
       year := (year + 3) mod 360;
       day := (day + 6) mod 360;
       InvalidateRect(Handle, nil, False);
  end;
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
const
  sColor: array [0..3] of GLfloat = (1, 0.75, 0, 1);
  pColor: array [0..3] of GLfloat = (0.4, 0, 0.2, 1);
  mColor: array [0..3] of GLfloat = (0.4, 0.4, 0.5, 1);
  black: array [0..3] of GLfloat = (0, 0, 0, 1);
begin
  BeginPaint(Handle, ps);

  glClear(GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT);
  glPushMatrix;
  glPushMatrix;

  glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, @sColor);
  glutSolidSphere(0.8, 32, 16);     // солнце
  glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, @black);

  glRotatef(-20, 0.0, 0.0, 1.0);
  glRotatef(year, 0.0, 1.0, 0.0);
  glTranslatef(2.4, 0.0, 0.0);

  glPushMatrix;
  glRotatef(day, 0.0, 1.0, 0.0);

  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @pColor);
  glutSolidSphere(0.25, 32, 16);     // планета

  glPopMatrix;
  glRotatef(40, 0.0, 0.0, 1.0);
  glRotatef(-2*day, 0.0, 1.0, 0.0);
  glTranslatef(0.4, 0.0, 0.0);
  glRotatef(day, 0.0, 1.0, 0.0);

  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @mColor);
  glutSolidSphere(0.1, 32, 16);      // луна

  glPopMatrix;

  glPopMatrix;
  SwapBuffers(DC);
  EndPaint(Handle, ps);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
const
  lcol : Array [0..3] of GLFloat = (1, 0.75, 0, 1);
  lpos : Array [0..3] of GLFloat = (0, 0, 0, 1);
  spec: array [0..3] of GLfloat = (0.5, 0.5, 0.5, 0.5);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  // Добавляем источник света 0
  glLightfv(GL_LIGHT0, GL_POSITION, @lpos);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @lcol);
  glMaterialf(GL_FRONT, GL_SHININESS, 40);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @spec);

  glEnable(GL_LIGHTING); // разрешаем работу с освещенностью
  glEnable(GL_LIGHT0);   // включаем источник света 0

  glEnable(GL_DEPTH_TEST);

  year := 0;
  day := 0;

  uTimerID := timeSetEvent (50, 0, @FNTimeCallBack, 0, TIME_PERIODIC);
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

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewPort (0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(60.0, ClientWidth/ClientHeight, 1.0, 20.0);
  gluLookAt(0.0, 0.0, 5.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  timeKillEvent(uTimerID);
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

