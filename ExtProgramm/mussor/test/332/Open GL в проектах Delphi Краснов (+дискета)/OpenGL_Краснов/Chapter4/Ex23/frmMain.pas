{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{ osc2.c
  A damping effect is given to oscillating objects using a
  function of the type A = Ao exp(-t/a) sin(t/b). The total
  no. of frames is used to keep track of time elapsed.

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

    theta : Integer;
    fRot, fOsc : Boolean;
    nf : Integer;
    n_osc : GLint;

    procedure Init;
    procedure SetDCPixelFormat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
 ell = 1;
 cyl = 2;
 light_pos : Array [0..3] of GLFloat = (100.0, 100.0, 100.0, 0.0);

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
 light_diffuse : Array [0..3] of GLFloat = (1.0, 1.0, 1.0, 0.0);
 light_specular : Array [0..3] of GLFloat = (1.0, 1.0, 1.0, 0.0);
 mat_specular : Array [0..3] of GLFloat = (1.0, 1.0, 1.0, 1.0);
 mat_shininess : Array [0..0] of GLFloat = (50.0);
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
 glEnable(GL_CULL_FACE);
 glEnable(GL_NORMALIZE);
 glDepthFunc(GL_LEQUAL);
 // glu stuff
 qobj := gluNewQuadric;
 glNewList(ell, GL_COMPILE);
   gluSphere(qobj,1.0,20,20);
 glEndList;
 glNewList(cyl, GL_COMPILE);
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
  a, b : GLFloat;
begin
  BeginPaint(Handle, ps);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  If n_osc > 1000 then fOsc := FALSE;

  If fOsc then begin
     n_osc := n_osc + 1;

     a := 20.0*(1.0 + exp(-n_osc/100.0)*abs(sin(2.0*PI*nf/10.0)));
     b := 20.0*(1.0 + exp(-n_osc/50.0)*abs(sin(2.0*PI*nf/10.0)));

     glLoadIdentity;

     // viewing transform

     glTranslatef(0.0,0.0,-200.0);
     If fRot then
	glRotatef(theta,0.0,0.0,1.0);

	// modelling transforms

	glPushMatrix;
        glTranslatef(0.0,0.0,0.0);

	glColor3f(1.0,0.0,0.0);
	glPushMatrix;
	glTranslatef(-40.0,-40.0,40.0);
	glScalef(a,20.0,20.0);
	glCallList(ell);
	glPopMatrix;

	glColor3f(0.0,1.0,0.0);
	glPushMatrix;
	glTranslatef(20.0,40.0,20.0);
	glRotatef(30.0,1.0,0.0,0.0);
	glScalef(b,20.0,20.0);
	glCallList(cyl);
	glPopMatrix;

	glPopMatrix;
    end;
  SwapBuffers(DC);                 // конец работы
  EndPaint(Handle, ps);

  nf := nf + 1;
  theta := (theta + 2) mod 360;
  InvalidateRect(Handle, nil, False);
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
  fRot := False;
  fOsc := True;
  n_osc := 0;
  Init;
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
  If Key = VK_INSERT
     then fRot := not fRot
     else begin
     n_osc := 0;
     fOsc := TRUE;
  end;
end;

end.


