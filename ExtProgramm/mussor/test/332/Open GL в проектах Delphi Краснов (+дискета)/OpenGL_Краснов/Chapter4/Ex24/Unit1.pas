{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  OpenGL;

type
  TfrmGL = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGL:TfrmGL;
  dc:HDC;
  hrc:HGLRC;
  ps:TPAINTSTRUCT;
  quadSphere1:GLUquadricObj;
  quadSphere2:GLUquadricObj;
  angle:GLfloat;
  xGlob:GLfloat;
  yGlob:GLfloat;
  x:GLfloat;
  y:GLfloat;
  stepX:GLfloat;
  stepY:GLfloat;
  disk1:GLUquadricObj;
  disk2:GLUquadricObj;
  disk3:GLUquadricObj;

implementation

{$R *.DFM}

const
  //массив свойств материала
  ColorSphere1:Array[0..3] of GLfloat = (0.65, 0.65, 0.0, 0.0);
  ColorSphere2:Array[0..3] of GLfloat = (0.75, 0.5, 0.25, 0.0);
  ColorDisk1:Array[0..3] of GLfloat = (0.65, 0.65, 0.0, 0.0);
  ColorDisk2:Array[0..3] of GLfloat = (0.5, 0.5, 0.0, 0.0);
  ColorDisk3:Array[0..3] of GLfloat = (0.35, 0.35, 0.0, 0.0);
  SPHERE1=1;
  SPHERE2=2;

procedure TfrmGL.FormCreate(Sender: TObject);
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;
begin
   angle:=0;
   xGlob:=4.0;
   stepX:=-0.1;
   yGlob:=-7.0;
   stepY:=-0.1;

   dc := GetDC(Handle);
   FillChar(pfd, SizeOf(pfd), 0);
   pfd.dwFlags   := PFD_DRAW_TO_WINDOW or
                 PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;
   nPixelFormat := ChoosePixelFormat(DC, @pfd);
   SetPixelFormat(DC, nPixelFormat, @pfd);

   hrc := wglCreateContext(dc);
   wglMakeCurrent(dc,hrc);

     glEnable(GL_DEPTH_TEST);//разрешаем тест глубины
     glEnable(GL_LIGHTING);//разрешаем работу с освещенностью
     glEnable(GL_LIGHT0);//включаем источник света 0
     disk1:=gluNewQuadric;
     gluQuadricNormals(disk1,GLU_SMOOTH);
     disk2:=gluNewQuadric;
     gluQuadricNormals(disk2,GLU_SMOOTH);
     disk3:=gluNewQuadric;
     gluQuadricNormals(disk3,GLU_SMOOTH);

     //Создаем сферу1
     quadSphere1:=gluNewQuadric;
     //Стиль визуализации
     gluQuadricDrawStyle(quadSphere1,GLU_FILL);
     glNewList (SPHERE1,GL_COMPILE);
     glMaterialfv(GL_FRONT,GL_AMBIENT_AND_DIFFUSE,@ColorSphere1);
     gluSphere(quadSphere1,0.75,20,20);
     glEndList;

     //Создаем сферу2
     quadSphere2:=gluNewQuadric();
     //Стиль визуализации
     gluQuadricDrawStyle(quadSphere2,GLU_FILL);
     glNewList(SPHERE2,GL_COMPILE);
     glMaterialfv(GL_FRONT,GL_AMBIENT_AND_DIFFUSE,@ColorSphere2);
     gluSphere(quadSphere2,0.35,20,20);
     glEndList;
end;

procedure TfrmGL.FormPaint(Sender: TObject);
begin
  // очистка буфера цвета и буфера глубины
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  //Создание объектов
  glPushMatrix;
  glMaterialfv(GL_FRONT,GL_AMBIENT_AND_DIFFUSE,@ColorDisk1);
  glTranslatef(0.0,-0.5,-7.0);
  glRotatef(110,1,0.35,0);
  gluDisk(disk1,0.85,1.0,25,25);
  glPopMatrix;

  glPushMatrix;
  glMaterialfv(GL_FRONT,GL_AMBIENT_AND_DIFFUSE,@ColorDisk2);
  glTranslatef(0.0,-0.5,-7.0);
  glRotatef(110,1,0.35,0);
  gluDisk(disk2,1.0,1.20,25,25);
  glPopMatrix;

  glPushMatrix;
  glMaterialfv(GL_FRONT,GL_AMBIENT_AND_DIFFUSE,@ColorDisk3);
  glTranslatef(0.0,-0.5,-7.0);
  glRotatef(110,1,0.35,0);
  gluDisk(disk2,1.20,1.45,25,25);

  glPopMatrix;

  glPushMatrix;
  glTranslatef(0.0,-0.5,-7.0);
  glRotatef(angle,0,1,0);//поворот на угол
  glCallList(SPHERE1);
  glPopMatrix;

  glPushMatrix;
  glTranslatef(xGlob,-0.2,yGlob);
  glRotatef(angle,0,1,0);//поворот на угол
  glCallList(SPHERE2);
  glPopMatrix;

  SwapBuffers(DC);
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(30.0, ClientWidth / ClientHeight, 1.0, 10.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.Timer1Timer(Sender: TObject);
begin
   angle:=angle+2.0;
   If abs(xGlob+4.0)<0.15 then stepX:=0.1;
   If abs(xGlob-4.0)<0.15 then stepX:=-0.1;
   xGlob:=xGlob+stepX;
   If abs(y+4)<0.15 then stepY:=0.1;
   If abs(y-4)<0.15 then stepY:=-0.1;
   y:=y+stepY;
   yGlob:=-7+y;
   If angle>359.0 then angle:=0.0;
   InvalidateRect(Handle, nil, False);
end;


procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close
end;

procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  gluDeleteQuadric (disk1);
  gluDeleteQuadric (disk2);
  gluDeleteQuadric (disk3);
  gluDeleteQuadric (quadSphere1);
  gluDeleteQuadric (quadSphere2);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

end.
