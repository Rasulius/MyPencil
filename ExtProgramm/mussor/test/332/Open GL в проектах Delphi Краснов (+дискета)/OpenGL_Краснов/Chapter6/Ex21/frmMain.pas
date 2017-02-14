{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
 Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus,
 Controls, Dialogs, SysUtils, StdCtrls,
 OpenGL;


type
  TfrmGL = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);

  private
    DC: HDC;
    hrc: HGLRC;
    Angle: GLfloat;
    uTimerId : uint;  // идентификатор таймера - необходимо запомнить

    procedure SetDCPixelFormat;
    procedure Print;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

implementation

uses mmSystem;

{$R *.DFM}

{=======================================================================
Обработка таймера}
procedure FNTimeCallBack(uTimerID, uMessage: UINT;dwUser, dw1, dw2: DWORD) stdcall;
begin
  // Каждый "тик" изменяется значение угла
  With frmGL do begin
    Angle := Angle + 0.1;
    If Angle >= 360.0 then Angle := 0.0;
    InvalidateRect(Handle, nil, False);
  end;
end;

procedure TfrmGL.Print;
var
 Viewport : Array [0..3] of GLInt;
 mvMatrix, ProjMatrix : Array [0..15] of GLDouble;
 wx, wy, wz : GLdouble;
begin
 glGetIntegerv (GL_VIEWPORT, @Viewport);
 glGetDoublev (GL_MODELVIEW_MATRIX, @mvMatrix);
 glGetDoublev (GL_PROJECTION_MATRIX, @ProjMatrix);

 gluProject (0, 0, -0.5, @mvMatrix, @ProjMatrix, @Viewport, wx, wy, wz);

 Memo1.Clear;
 Memo1.Lines.Add('');
 Memo1.Lines.Add('Оконные координаты:');
 Memo1.Lines.Add(' x = ' + FloatToStr (wx));
 Memo1.Lines.Add(' y = ' + FloatToStr (ClientHeight - wy));
 Memo1.Lines.Add(' z = ' + FloatToStr (wz));
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glLoadIdentity;
  glRotatef(Angle, 1, 0, 0.1);
  glColor3f(1, 1, 0);
  glBegin(GL_POINTS);
    glNormal3f(0, 0, -1);
    glVertex3f(0, 0, -0.5);
  glEnd;

  Print;

  SwapBuffers(DC);                 // конец работы
  EndPaint(Handle, ps);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
const
  position : Array [0..2] of GLFloat = (0, 0, -1);
  diffuse : Array [0..3] of GLFloat = (1, 1, 1, 1);
  ambient : Array [0..3] of GLFloat = (0.4, 0.4, 0.8, 1);
begin
  Angle := 0;
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  glViewport(0, 0, (ClientWidth - Memo1.Width), ClientHeight);
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_COLOR_MATERIAL);
  glPointSize(20);
  glEnable(GL_POINT_SMOOTH);

  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glLightfv(GL_LIGHT0, GL_POSITION, @position);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @diffuse);
  glLightfv(GL_LIGHT0, GL_AMBIENT, @ambient);

  glClearColor (0.25, 0.75, 0.25, 0.0);
  uTimerID := timeSetEvent (2, 0, @FNTimeCallBack, 0, TIME_PERIODIC);
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
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  timeKillEvent(uTimerID);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
end;

procedure TfrmGL.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  Caption := IntToStr (X) + ' ' + IntToStr (Y)
end;

end.

