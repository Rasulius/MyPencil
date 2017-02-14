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
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);

  private
    DC: HDC;
    hrc: HGLRC;
    Angle: GLfloat;
    uTimerId : uint;

    procedure SetDCPixelFormat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  useStencil: Boolean = True;
  mtx : Array [0..3, 0..3] of GLfloat;

implementation

uses mmSystem, DGLUT;

{$R *.DFM}

procedure DrawScene;
begin
  glPushMatrix;
    glutSolidTorus(0.1, 0.2, 8, 32);
    glTranslatef(0, 0, 0.3);
    glutSolidCube(0.1);
    glTranslatef(0, 0, -0.6);
    glutSolidCube(0.1);
  glPopMatrix;
end;

{=======================================================================
Обработка таймера}
procedure FNTimeCallBack(uTimerID, uMessage: UINT;dwUser, dw1, dw2: DWORD) stdcall;
begin
  With frmGL do begin
     Angle := Angle + 0.1;
     If Angle >= 360.0 then Angle := 0.0;
     InvalidateRect(Handle, nil, False);
  end;
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix;
    glDisable (GL_LIGHT0);
    glDisable (GL_LIGHTING);
    glColor3f(1.0, 1.0, 1);
    glBegin(GL_QUADS);
      glVertex3f(-0.5, -0.5, 0.5);
      glVertex3f(0.5, -0.5, 0.5);
      glVertex3f(0.5, -0.5, -0.5);
      glVertex3f(-0.5, -0.5, -0.5);
    glEnd;
    glEnable (GL_LIGHTING);
    glEnable (GL_LIGHT0);
  glPopMatrix;
  glPushMatrix;
    glColor3f(1, 0, 0);
    glRotatef(Angle, 1, 1, 1);
    DrawScene;
  glPopMatrix;
  If useStencil then begin
    glClear(GL_STENCIL_BUFFER_BIT);
    glEnable(GL_STENCIL_TEST);
  end;
  glPushMatrix;
    glColor4f(0, 0, 0, 0.3);
    glTranslatef(0, -0.5, 0);
    glMultMatrixf(@mtx);
    glRotatef(Angle, 1, 1, 1);
    glDisable(GL_DEPTH_TEST);
    DrawScene;
    glEnable(GL_DEPTH_TEST);
  glPopMatrix;
  glDisable(GL_STENCIL_TEST);

  SwapBuffers(DC);
  EndPaint(Handle, ps);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  mtx[0,0] := 1.0;
  mtx[1,1] := 0;
  mtx[2,2] := 1.0;
  mtx[3,3] := 1.0;

  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  glEnable(GL_DEPTH_TEST);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_COLOR_MATERIAL);

  glClearStencil(0);
  glStencilOp(GL_INCR, GL_INCR, GL_INCR);
  glStencilFunc(GL_EQUAL, 0, $FFFFFFF);

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

  pfd.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or
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
  DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
  If Key = Ord ('S') then useStencil := not useStencil;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight );
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(35, 1, 1, 5);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(0, 0, -2);
  InvalidateRect(Handle, nil, False);
end;

end.

