{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpenGL;

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
    Quadric : GLUquadricObj;
    LightPos : Array [0..3] of GLfloat;
    Delta : GLfloat;
    procedure Init;
    procedure SetDCPixelFormat;

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
 Sphere = 1;

var
  frmGL: TfrmGL;

implementation

uses mmSystem;

{$R *.DFM}

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
begin
 glEnable(GL_LIGHTING);
 glEnable(GL_LIGHT0);
 glEnable(GL_DEPTH_TEST);
 glEnable(GL_COLOR_MATERIAL);
 glColor3f (0.0, 1.0, 1.0);

 Quadric := gluNewQuadric;

 glNewList (Sphere, GL_COMPILE);
   gluSphere (Quadric, 1.5, 24, 24);
 glEndList;
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT );

  glLightfv(GL_LIGHT0, GL_POSITION, @LightPos);
  glCallList(Sphere);

  SwapBuffers(DC);
  EndPaint(Handle, ps);
end;

{=======================================================================
Обработка таймера}
procedure FNTimeCallBack(uTimerID, uMessage: UINT;dwUser, dw1, dw2: DWORD) stdcall;
begin
  With frmGL do begin
    LightPos[0] := LightPos[0] + Delta;
    If LightPos[0] > 15.0
       then Delta := -1.0
       else If (LightPos[0] < -15.0) then
            Delta := 1.0;
    InvalidateRect(Handle, nil, False);
  end;
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  Delta := 1.0;
  LightPos [0] := 10.0;
  LightPos [1] := 10.0;
  LightPos [2] := 10.0;
  LightPos [3] := 1.0;
  Init;
  uTimerID := timeSetEvent (15, 0, @FNTimeCallBack, 0, TIME_PERIODIC);
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight );
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 glFrustum(-1.0, 1.0, -1.0, 1.0, 5.0, 25.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef( 0.0, 0.0, -12.0 );
 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  timeKillEvent(uTimerID);
  glDeleteLists (sphere, 1);
  gluDeleteQuadric (Quadric);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
end;

{=======================================================================
Обработка нажатия клавиши}
procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
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


