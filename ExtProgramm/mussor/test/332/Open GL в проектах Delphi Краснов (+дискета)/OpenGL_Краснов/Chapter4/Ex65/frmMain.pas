{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, OpenGL;

type
  TfrmGL = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);

  private
    DC: HDC;
    hrc: HGLRC;

    procedure DrawScene;
    procedure SetDCPixelFormat;

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  A : Glint = 180;
  useAccum: Boolean = TRUE;

implementation

uses DGLUT;

{$R *.DFM}

procedure Render;
begin
  glColor3f(1, 0, 0);
  glutSolidTorus(0.2, 0.6, 16, 32);
  glColor3f(0, 1, 0);
  glutSolidSphere(0.25, 32, 16);
end;

procedure TfrmGL.DrawScene;
var
  i: Integer;
type
  TVector = record
    x,y,z : GLFloat;
  end;
const
  N = 8;
  JITTER: array [1..N] of TVector =
    ( (x: -0.005; y: 0;      z: -0.005),
      (x: 0.005;  y: 0;      z: 0.005),
      (x: 0;      y: -0.005; z: -0.005),
      (x: 0;      y: 0.005;  z: 0.005),
      (x: -0.005; y: -0.005; z: -0.005),
      (x: 0.005;  y: -0.005; z: 0.005),
      (x: -0.005; y: 0.005;  z: -0.005),
      (x: 0.005;  y: 0.005;  z: 0.005)  );
begin
  If useAccum then glClear(GL_ACCUM_BUFFER_BIT)
              else glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;
  glRotatef(A, 1, 1, 1);
  If useAccum then begin
    For i := 1 to N do begin
      glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
      glPushMatrix;
        glTranslatef(JITTER[i].x, JITTER[i].y, JITTER[i].z);
        Render;
      glPopMatrix;
      glAccum(GL_ACCUM, 1/N);
    end;
    glAccum(GL_RETURN, 1);
  end
  else Render;
  SwapBuffers(DC);
end;

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

procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  glEnable(GL_DEPTH_TEST);// разрешаем тест глубины
  glColorMaterial(GL_FRONT_AND_BACK, GL_DIFFUSE);
  glEnable(GL_COLOR_MATERIAL);
  glEnable(GL_LIGHTING); // разрешаем работу с освещенностью
  glEnable(GL_LIGHT0);   // включаем источник света 0
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(30.0, ClientWidth / ClientHeight, 1.0, 10.0);
  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);
  DrawScene;
  EndPaint(Handle, ps);
end;

procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

procedure TfrmGL.Timer1Timer(Sender: TObject);
begin
  A := (A + 1) mod 360;
  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close;
end;

procedure TfrmGL.FormKeyPress(Sender: TObject; var Key: Char);
begin
 If Key in ['a', 'A'] then useAccum := not useAccum;
end;

end.

