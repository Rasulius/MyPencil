{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

//  (c) Mahesh Venkitachalam 1999. http://home.att.net/~bighesh

unit frmMain;
interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Controls,
  Dialogs, SysUtils, OpenGL;

type
  TfrmGL = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
  private
    DC: HDC;
    hrc: HGLRC;

    qobj : GLUquadricObj;
    spin : Integer;
    fToggle : Boolean;
    step : GLfloat;
    dz  : GLfloat;

    // For pixel...
    pixels : Array [0..254, 0..254, 0..3] of GLUByte;
    first : Boolean;

    procedure Init;
    procedure SetDCPixelFormat;
    procedure MakeImage;
    procedure MakeSphere;
    procedure MakeWalls;    

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

const
  sphere = 1;
  walls = 2;
  zapImage = 3;
  // light
  light1_pos : Array [0..3] of GLfloat = (20.0,10.0,40.0,1.0);

  cyl_amb_dif : Array [0..3] of GLfloat = (0.2,0.8,1.0,1.0);
  cyl_spec : Array [0..3] of GLfloat = (1.0,1.0,1.0,1.0);
  sph_amb_dif : Array [0..3] of GLfloat = (0.8,0.2,0.5,1.0);
  sph_spec : Array [0..3] of GLfloat = (1.0,1.0,1.0,1.0);

implementation

{$R *.DFM}

procedure TfrmGL.MakeSphere;
begin
 glNewList(sphere,GL_COMPILE);
   glMaterialfv(GL_FRONT,GL_AMBIENT_AND_DIFFUSE, @sph_amb_dif);
   glMaterialfv(GL_FRONT,GL_SPECULAR,@sph_spec);
   glMaterialf(GL_FRONT,GL_SHININESS,100.0);

   glPushMatrix;
   gluSphere(qobj,1.0,20,20);
   glRotatef(270.0,1.0,0.0,0.0);
   gluCylinder(qobj,0.5,0.5,2.0,20,20);
   glPopMatrix;
 glEndList;
end;

procedure TfrmGL.MakeWalls;
begin
  glNewList(walls,GL_COMPILE);
    glMaterialfv(GL_FRONT,GL_AMBIENT_AND_DIFFUSE, @cyl_amb_dif);
    glMaterialfv(GL_FRONT,GL_SPECULAR, @cyl_spec);
    glMaterialf(GL_FRONT,GL_SHININESS,100.0);
    glBegin(GL_QUADS);
      glVertex3f(10.0,0.0,10.0);
      glVertex3f(30.0,0.0,10.0);
      glVertex3f(30.0,10.0,5.0);
      glVertex3f(10.0,10.0,5.0);
    glEnd;
  glEndList;
end;

procedure TfrmGL.MakeImage;
begin
  glNewList(zapImage,GL_COMPILE);
      glDisable(GL_LIGHTING);
      glClear(GL_DEPTH_BUFFER_BIT or GL_COLOR_BUFFER_BIT);
      glMatrixMode(GL_PROJECTION);
      glPushMatrix;
      glLoadIdentity;
      // how to fix these values ?
      glOrtho(0.0, ClientWidth, 0.0, ClientHeight, -5.0, 50.0);
      glMatrixMode(GL_MODELVIEW);
      glPushMatrix;
      glLoadIdentity; // Important !
      glRasterPos2i(0,0);
      glPopMatrix;
      glMatrixMode(GL_PROJECTION);
      glPopMatrix;
      glMatrixMode(GL_MODELVIEW);

      glDisable(GL_DEPTH_TEST);
      glDrawPixels(ClientWidth, ClientHeight, GL_RGBA, GL_UNSIGNED_BYTE, @pixels);
      glEnable(GL_DEPTH_TEST);
      glEnable(GL_LIGHTING);
  glEndList;
end;

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
begin
  qobj := gluNewQuadric;

  glClearColor(0.3, 0.9, 0.9, 0.0);

  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glLightfv(GL_LIGHT0,GL_POSITION, @light1_pos);

  glEnable(GL_DEPTH_TEST);
  glEnable(GL_CULL_FACE);

  MakeSphere;
  MakeWalls;
  gluDeleteQuadric (qObj);
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint (Handle, ps);

  If first then begin
     glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

     glCallList(walls);

     // save image
     glReadPixels(0, 0, 255, 255, GL_RGBA,GL_UNSIGNED_BYTE, @pixels);

     first := FALSE;

     MakeImage;
     end
     else glCallList(zapImage);

  glPushMatrix;
  glTranslatef (20.0, 5.0, 5.0 + dz);
  glCallList (sphere);
  glPopMatrix;

  SwapBuffers (DC);
  EndPaint (Handle, ps);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  spin := 0;
  fToggle := TRUE;
  step := 0.0;
  dz := 0.0;
  first := TRUE;
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
  first := TRUE;

  glViewport( 0, 0, ClientWidth, ClientHeight );

  glMatrixMode( GL_PROJECTION );
  glLoadIdentity;
  gluPerspective( 60.0, ClientWidth / ClientHeight, 5.0, 50.0);
  glMatrixMode( GL_MODELVIEW );
  glLoadIdentity;
  gluLookAt(20.0,5.0,30.0,20.0,5.0,0.0,0.0,1.0,0.0);
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  glDeleteLists (sphere, 1);
  glDeleteLists (walls, 1);
  glDeleteLists (zapImage, 1);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

{=======================================================================
Обработка нажатия клавиши}
procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
end;

procedure TfrmGL.Timer1Timer(Sender: TObject);
begin
  dz := dz + 0.5;
  InvalidateRect(Handle, nil, False);
end;

end.

