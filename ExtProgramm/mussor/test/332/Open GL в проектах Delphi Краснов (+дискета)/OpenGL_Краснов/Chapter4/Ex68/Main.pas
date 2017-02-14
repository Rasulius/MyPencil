{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}
unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ComCtrls, StdCtrls, Menus, Buttons,
  OpenGL;

const
  // цвет тумана
  fogColor : Array [0..3] of GLfloat = (0.5, 0.5, 0.5, 1.0);
  // цвет площадки
  glfSquareAmbient : Array[0..3] of GLfloat = (0.24725, 0.1995, 0.0745, 1.0);
  glfSquareDiffuse : Array[0..3] of GLfloat = (0.75164, 0.60648, 0.22648, 1.0);
  glfSquareSpecular : Array[0..3] of GLfloat = (0.628281, 0.555802, 0.366065, 1.0);

const
  // источник света
  glfLightAmbient : Array[0..3] of GLfloat = (0.25, 0.25, 0.25, 1.0);
  glfLightDiffuse : Array[0..3] of GLfloat = (1.0, 1.0, 1.0, 1.0);
  glfLightSpecular: Array[0..3] of GLfloat = (1.0, 1.0, 1.0, 1.0);
  glfLightPosition: Array[0..3] of GLfloat = (0.0, 0.0, 20.0, 1.0);
  glfLightModelAmbient: Array[0..3] of GLfloat = (0.25, 0.25, 0.25, 1.0);

  // позиция первого источника света
  LightPosition : Array[0..3] of GLfloat = (0.0, 0.0, 15.0, 1.0);

  // позиция второго источника света
  glfLight1Position: Array[0..3] of GLfloat = (15.0, 15.0, -5.0, 1.0);

type
  TfrmGL = class(TForm)
    procedure Init;
    procedure SetProjection(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetDCPixelFormat;
    procedure FormDestroy(Sender: TObject);

    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  public
    DC : HDC;
    hrc : HGLRC;
    cubeX, cubeY, cubeZ : GLfloat;
    cubeL, cubeH, cubeW : GLfloat;
    AddX, AddY, AddZ : GLfloat;            // начальные сдвиги
    SquareLength : GLfloat;                // сторона площадки
    procedure Square;
    procedure Shadow;
   protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
   end;

var
  frmGL: TfrmGL;

implementation

uses DGLUT;

{$R *.DFM}


{=======================================================================
Нажатие клавиши}
procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
  If Key = VK_LEFT then begin
     cubeX := cubeX + 0.1;
     InvalidateRect(Handle, nil, False);
  end;
  If Key = VK_RIGHT then begin
     cubeX := cubeX - 0.1;
     InvalidateRect(Handle, nil, False);
  end;
  If Key = VK_UP then begin
     cubeZ := cubeZ + 0.1;
     InvalidateRect(Handle, nil, False);
  end;
  If Key = VK_DOWN then begin
     cubeZ := cubeZ - 0.1;
     InvalidateRect(Handle, nil, False);
  end;
end;

{======================================================================
Рисование тени}
procedure TfrmGL.Shadow;
// подсчет точки тени для одной точки
procedure OneShadow (x, y, z, h : GLfloat; var x1, y1 : GLfloat);
begin
  x1 := x * LightPosition [2] / (LightPosition [2] - (z + h));
  If LightPosition [0] < x
     then begin If x1 > 0 then x1 := LightPosition [0] + x1 end
     else begin If x1 > 0 then x1 := LightPosition [0] - x1 end;
  y1 := y * LightPosition [2] / (LightPosition [2] - (z + h));
  If LightPosition [1] < y
     then begin If y1 > 0 then y1 := LightPosition [1] + y1 end
     else begin If y1 > 0 then y1 := LightPosition [1] - y1 end;
  If x1 < 0 then x1 := 0 else
     If x1 > SquareLength then x1 := SquareLength;
  If y1 < 0 then y1 := 0 else
     If y1 > SquareLength then y1 := SquareLength;
end;

var
  x1, y1, x2, y2, x3, y3, x4, y4 : GLfloat;
  wrkx1, wrky1, wrkx2, wrky2, wrkx3, wrky3, wrkx4, wrky4 : GLfloat;
begin
  OneShadow (cubeX + cubeL, cubeY + cubeH, cubeZ, cubeW, x1, y1);
  OneShadow (cubeX, cubeY + cubeH, cubeZ, cubeW, x2, y2);
  OneShadow (cubeX, cubeY, cubeZ, cubeW, x3, y3);
  OneShadow (cubeX + cubeL, cubeY, cubeZ, cubeW, x4, y4);

  If cubeZ + cubeW >= 0 then begin
  glBegin (GL_QUADS);
    glVertex3f (x1, y1, -0.99);
    glVertex3f (x2, y2, -0.99);
    glVertex3f (x3, y3, -0.99);
    glVertex3f (x4, y4, -0.99);
  glEnd;
  end;

  If cubeZ >= 0 then begin
     wrkx1 := x1;
     wrky1 := y1;
     wrkx2 := x2;
     wrky2 := y2;
     wrkx3 := x3;
     wrky3 := y3;
     wrkx4 := x4;
     wrky4 := y4;

     OneShadow (cubeX + cubeL, cubeY + cubeH, cubeZ, 0, x1, y1);
     OneShadow (cubeX, cubeY + cubeH, cubeZ, 0, x2, y2);
     OneShadow (cubeX, cubeY, cubeZ, 0, x3, y3);
     OneShadow (cubeX + cubeL, cubeY, cubeZ, 0, x4, y4);

     glBegin (GL_QUADS);
       glVertex3f (x1, y1, -0.99);
       glVertex3f (x2, y2, -0.99);
       glVertex3f (x3, y3, -0.99);
       glVertex3f (x4, y4, -0.99);
       glVertex3f (wrkx2, wrky2, -0.99);
       glVertex3f (x2, y2, -0.99);
       glVertex3f (x3, y3, -0.99);
       glVertex3f (wrkx3, wrky3, -0.99);
       glVertex3f (wrkx1, wrky1, -0.99);
       glVertex3f (wrkx4, wrky4, -0.99);
       glVertex3f (x4, y4, -0.99);
       glVertex3f (x1, y1, -0.99);
       glVertex3f (wrkx1, wrky1, -0.99);
       glVertex3f (x1, y1, -0.99);
       glVertex3f (x2, y2, -0.99);
       glVertex3f (wrkx2, wrky2, -0.99);
       glVertex3f (wrkx3, wrky3, -0.99);
       glVertex3f (x3, y3, -0.99);
       glVertex3f (x4, y4, -0.99);
       glVertex3f (wrkx4, wrky4, -0.99);
     glEnd;
  end;
end;

{======================================================================
Рисование площадки}
procedure TfrmGL.Square;
begin
  glPushAttrib (GL_ALL_ATTRIB_BITS );

  glMaterialfv(GL_FRONT, GL_AMBIENT, @glfSquareAmbient);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @glfSquareDiffuse);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @glfSquareSpecular);
  glMaterialf (GL_FRONT, GL_SHININESS, 90.2);

  glBegin(GL_QUADS);
    glNormal3f(squarelength / 2.0, squarelength / 2.0, -1.0);
    glVertex3f(squarelength, squarelength, -1.0);
    glVertex3f(0.0, squarelength, -1.0);
    glVertex3f(0.0, 0.0, -1.0);
    glVertex3f(squarelength, 0.0, -1.0);
  glEnd;

  glPopAttrib;
end;


{======================================================================
Инициализация}
procedure TfrmGL.Init;
begin
 glEnable (GL_FOG);
 glEnable(GL_NORMALIZE);
 glEnable(GL_DEPTH_TEST);

 glLightfv(GL_LIGHT0, GL_AMBIENT, @glfLightambient);
 glLightfv(GL_LIGHT0, GL_DIFFUSE, @glfLightdiffuse);
 glLightfv(GL_LIGHT0, GL_SPECULAR, @glfLightspecular);
 glLightfv(GL_LIGHT0, GL_POSITION, @glfLightposition);

 glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @glfLightmodelambient);

 // второй источник света
 glLightfv(GL_LIGHT1, GL_AMBIENT, @glfLightambient);
 glLightfv(GL_LIGHT1, GL_DIFFUSE, @glfLightdiffuse);
 glLightfv(GL_LIGHT1, GL_SPECULAR, @glfLightspecular);
 glLightfv(GL_LIGHT1, GL_POSITION, @glfLight1position);

 glEnable(GL_LIGHTING);
 glEnable(GL_LIGHT0);
 glEnable(GL_LIGHT1);
end;

{======================================================================
Изменение размеров окна}
procedure TfrmGL.SetProjection(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 glFrustum (-0.5, 0.5, -0.5, 0.5, 1.0, 100.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef(0.0, 0.0, -32.0);

 glRotatef(120.0, 1.0, 0.0, 0.0);
 glRotatef(180.0, 0.0, 1.0, 0.0);
 glRotatef(40.0, 0.0, 0.0, 1.0);
 InvalidateRect(Handle, nil, False);
end;

{======================================================================
Начало работы приложения}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
 DC := GetDC(Handle);
 SetDCPixelFormat;
 hrc := wglCreateContext(DC);
 wglMakeCurrent(DC, hrc);
 Init;

 // параметры тумана
 glFogi(GL_FOG_MODE, GL_EXP);
 glFogfv(GL_FOG_COLOR, @fogColor);
 glFogf(GL_FOG_DENSITY, 0.015);

 SquareLength := 50.0;

 AddX := 0;
 AddY := 0;
 AddZ := 0;

 cubeX := 1.0;
 cubeY := 2.0;
 cubeZ := 3.0;

 cubeL := 1.0;
 cubeH := 2.0;
 cubeW := 3.0;
end;

{======================================================================
Аналог события OnPaint}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
const
  CubeColor : Array [0..3] of GLfloat = (1.0, 0.0, 0.0, 0.0);
begin
  BeginPaint(Handle, ps);

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix;

  glTranslatef(AddX, AddY, AddZ);

  glEnable (GL_LIGHT1);
  Square;
  glDisable (GL_LIGHT1);

  glPushAttrib (GL_ALL_ATTRIB_BITS );

  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @CubeColor);
  glPushMatrix;
  glTranslatef (cubeX, cubeY, cubeZ);
  glScalef (cubeL, cubeH, cubeW);

  glutSolidCube (1.0);
  glPopMatrix;
  glPopAttrib;

  Shadow;
  glPopMatrix;

  SwapBuffers(DC);

  EndPaint(Handle, ps);
end;

{======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

{======================================================================
Формат пикселей}
procedure TfrmGL.SetDCPixelFormat;
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;
begin
  FillChar(pfd, SizeOf(pfd), 0);

  with pfd do begin
    nSize     := sizeof(pfd);
    nVersion  := 1;
    dwFlags   := PFD_DRAW_TO_WINDOW or
                 PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;
    iPixelType:= PFD_TYPE_RGBA;
    cColorBits:= 24;
    cDepthBits:= 32;
    iLayerType:= PFD_MAIN_PLANE;
  end;

  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;

end.
