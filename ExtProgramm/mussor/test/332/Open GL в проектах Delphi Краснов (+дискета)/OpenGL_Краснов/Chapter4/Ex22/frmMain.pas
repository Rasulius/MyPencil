{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{	osc1.c
	Objects oscillating (or being squeezed and expanded, rather) at
	different frequencies.
        (c) Mahesh Venkitachalam 1999. http://home.att.net/~bighesh
}

unit frmMain;
interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Dialogs,
  SysUtils, OpenGL;

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

    theta : Integer;
    fRot : Boolean;
    nf : Integer;

    procedure Init;
    procedure SetDCPixelFormat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
 ell = 1;
 cyl = 2;
 light_pos : Array [0..3] of GLfloat = (100.0, 100.0, 100.0, 0.0);

var
  frmGL: TfrmGL;

implementation

uses mmSystem;

{$R *.DFM}

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
 light_diffuse : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 0.0);
 light_specular : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 0.0);
 mat_specular : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 1.0);
 mat_shininess : Array [0..0] of GLfloat = (50.0);
var
 qobj : GLUquadricObj;
begin
 glLightfv(GL_LIGHT0, GL_DIFFUSE, @light_diffuse);
 glLightfv(GL_LIGHT0, GL_SPECULAR, @light_specular);
 glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, @mat_specular);
 glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, @mat_shininess);
 glColorMaterial(GL_FRONT_AND_BACK,GL_DIFFUSE);
 glEnable(GL_COLOR_MATERIAL);
 glLightfv(GL_LIGHT0,GL_POSITION, @light_pos);
 glEnable(GL_LIGHT0);
 glEnable(GL_LIGHTING);

 glClearColor(1.0, 1.0, 1.0, 0.0);
 glEnable(GL_DEPTH_TEST);
 glEnable(GL_NORMALIZE);
 // glu stuff
 qobj := gluNewQuadric;
 glNewList(ell,GL_COMPILE);
   gluSphere(qobj,1.0,20,20);
 glEndList;
 glNewList(cyl,GL_COMPILE);
   glPushMatrix;
   glRotatef(180.0,1.0,0.0,0.0);
   gluDisk(qobj,0.0,1.0,20,20);
   glPopMatrix;
   gluCylinder(qobj,1.0,1.0,4.0,20,20);
   glPushMatrix;
   glTranslatef(0.0,0.0,4.0);
   gluDisk(qobj,0.0,1.0,20,20);
   glPopMatrix;
 glEndList;
 gluDeleteQuadric (qobj);
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
  a,b,c1,c2,c3 : GLfloat;
begin
  BeginPaint(Handle, ps);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  a := 10.0*(1.0 + abs(sin(2.0*PI*nf/100.0)));
  b := 10.0*(1.0 + abs(sin(2.0*PI*nf/10.0)));
  c1 := 10.0*(1.0 + abs(sin(2.0*PI*nf/50.0)));
  c2 := 10.0*(1.0 + abs(sin(2.0*PI*nf/50.0 + PI/4.0)));
  c3 := 10.0*(1.0 + abs(sin(2.0*PI*nf/50.0 + PI/8.0)));
  glLoadIdentity;
  // viewing transform
  glTranslatef(0.0,0.0,-200.0);
  If fRot then
      glRotatef(theta,0.0,0.0,1.0);
  // modelling transforms
  glPushMatrix;
  glColor3f(1.0,0.0,0.0);
  glPushMatrix;
  glTranslatef(-40.0,-40.0,40.0);
  glScalef(c1,c2,c3);
  glCallList(ell);

  glPopMatrix;
  glColor3f(1.0,1.0,0.0);
  glPushMatrix;
  glRotatef(60.0,1.0,0.0,0.0);
  glScalef(10.0,10.0,a);
  glCallList(cyl);
  glPopMatrix;
  glColor3f(0.0,1.0,0.0);
  glPushMatrix;
  glTranslatef(20.0,40.0,20.0);
  glRotatef(30.0,1.0,0.0,0.0);
  glScalef(b,10.0,10.0);
  glCallList(cyl);
  glPopMatrix;
  glPopMatrix;
  SwapBuffers(DC);                 // конец работы
  EndPaint(Handle, ps);
end;

{=======================================================================
Обработка таймера}
procedure FNTimeCallBack(uTimerID, uMessage: UINT;dwUser, dw1, dw2: DWORD) stdcall;
begin
  With frmGL do begin
   nf := nf + 1;
   theta := theta + 4;
   If theta = 360 then theta := 0;
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

  nf := 0;
  theta := 0;
  fRot := FALSE;
  Init;
  uTimerID := timeSetEvent (30, 0, @FNTimeCallBack, 0, TIME_PERIODIC);
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
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(50.0, 1.0, 10.0, 500.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  timeKillEvent(uTimerID);
  glDeleteLists (ell, 2);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
  If Key = VK_INSERT then fRot := not fRot;
end;

end.


