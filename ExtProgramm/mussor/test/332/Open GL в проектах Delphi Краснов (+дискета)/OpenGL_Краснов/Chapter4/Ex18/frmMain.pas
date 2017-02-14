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
    Angle : GLint;

    procedure SetDCPixelFormat;
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
  With frmGL do begin
       Angle := (Angle + 3) mod 360;
       InvalidateRect(Handle, nil, False);
  end;
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
const
  difFront : Array [0..3] of GLfloat = (1.0, 0.0, 0.0, 1.0);
  difBack : Array [0..3] of GLfloat = (0.0, 0.0, 1.0, 1.0);
begin
  BeginPaint(Handle, ps);

  glClear(GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT);
  glPushMatrix;

  glRotatef (Angle, 1.0, 1.0, 0.0);

  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, 1);
  glMaterialfv (GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @difFront);
  glMaterialfv (GL_BACK, GL_AMBIENT_AND_DIFFUSE, @difBack);

  glBegin (GL_QUADS);
    glVertex3f (-0.5, -0.5, 0.0);
    glVertex3f (0.5, -0.5, 0.0);
    glVertex3f (0.5, 0.5, 0.0);
    glVertex3f (-0.5, 0.5, 0.0);
  glEnd;

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

  glEnable(GL_LIGHTING); // разрешаем работу с освещенностью
  glEnable(GL_LIGHT0);   // включаем источник света 0

  glEnable(GL_DEPTH_TEST);

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
  gluPerspective(20.0, ClientWidth/ClientHeight, 1.0, 20.0);
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
  If Key = VK_ESCAPE then Close;
  If Key = 49 then glEnable (GL_CULL_FACE);
  If Key = 50 then glDisable (GL_CULL_FACE);
  If Key = 51 then glFrontFace (GL_CCW);
  If Key = 52 then glFrontFace (GL_CW);
  If Key = 53 then glCullFace (GL_FRONT);
  If Key = 54 then glCullFace (GL_BACK);  
end;

end.

