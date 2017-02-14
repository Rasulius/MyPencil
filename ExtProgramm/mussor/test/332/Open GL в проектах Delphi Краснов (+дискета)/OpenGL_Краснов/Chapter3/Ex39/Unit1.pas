{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit unit1;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Controls, StdCtrls,
  OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC : HDC;
    hrc : HGLRC;
    right, up, left : GLfloat;
    quadObj : GLUquadricObj;
    mode : GLenum;
    procedure DrawScene;
    procedure SetDCPixelFormat;

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  distance : GLfloat = 50.0;
  solid : Boolean = TRUE;

implementation

uses DGLUT;

{$R *.DFM}

{=======================================================================
Отрисовка картинки}
procedure TfrmGL.DrawScene;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix;

  glRotatef(left, 0.0, 1.0, 0.0);
  glRotatef(up, 1.0, 0.0, 0.0);
  glRotatef(right, 0.0, 0.0, 1.0);

  // передние фары
  glPushMatrix;
  glTranslatef(0.75, 0.0, 2.01);
  glColor3f (1.0, 1.0, 1.0);
  gluDisk (quadObj, 0.0, 0.2, 10, 10);
  glTranslatef(0.0, -0.4, 0.0);
  glRotatef(45, 0.0, 0.0, 1.0);
  glColor3f (1.0, 0.5, 0.0);
  gluDisk (quadObj, 0.0, 0.1, 4, 4);
  glPopMatrix;

  glPushMatrix;
  glTranslatef(-0.75, 0.0, 2.01);
  glColor3f (1.0, 1.0, 1.0);
  gluDisk (quadObj, 0.0, 0.2, 10, 10);
  glTranslatef(0.0, -0.4, 0.0);
  glRotatef(45, 0.0, 0.0, 1.0);
  glColor3f (1.0, 0.5, 0.0);
  gluDisk (quadObj, 0.0, 0.1, 4, 4);
  glPopMatrix;

  // задние фары
  If solid
     then glPolygonMode (GL_FRONT_AND_BACK, GL_FILL)
     else glPolygonMode (GL_FRONT_AND_BACK, GL_LINE);

  glPushMatrix;
  glTranslatef(-0.75, -0.3, -2.01);
  glColor3f (1.0, 0.0, 0.0);
  glRotatef(180, 1.0, 0.0, 0.0);
  glRectf (0.1, 0.1, -0.1, -0.1);
  glTranslatef(1.5, 0.0, 0.0);
  glRectf (0.1, 0.1, -0.1, -0.1);
  glPopMatrix;

  glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);

  glColor3f (0.5, 0.0, 0.3);
  glBegin(mode);
    glNormal3f(0.0, 0.0, 1.0);
    glVertex3f(1.0, 0.5, 2.0);
    glVertex3f(-1.0, 0.5, 2.0);
    glVertex3f(-1.0, -0.5, 2.0);
    glVertex3f(1.0, -0.5, 2.0);
  glEnd;

  glBegin(mode);
    glNormal3f(0.0, 0.0, -1.0);
    glVertex3f(1.0, 0.5, -2.0);
    glVertex3f(1.0, -0.5, -2.0);
    glVertex3f(-1.0, -0.5, -2.0);
    glVertex3f(-1.0, 0.5, -2.0);
  glEnd;

  glBegin(mode);
    glNormal3f(-1.0, 0.0, 0.0);
    glVertex3f(-1.0, 0.5, 2.0);
    glVertex3f(-1.0, 0.5, -2.0);
    glVertex3f(-1.0, -0.5, -2.0);
    glVertex3f(-1.0, -0.5, 2.0);
  glEnd;

  glBegin(mode);
    glNormal3f(1.0, 0.0, 0.0);
    glVertex3f(1.0, 0.5, 2.0);
    glVertex3f(1.0, -0.5, 2.0);
    glVertex3f(1.0, -0.5, -2.0);
    glVertex3f(1.0, 0.5, -2.0);
  glEnd;

  glBegin(mode);
    glNormal3f(0.0, 1.0, 0.0);
    glVertex3f(-1.0, 0.5, -2.0);
    glVertex3f(-1.0, 0.5, 2.0);
    glVertex3f(1.0, 0.5, 2.0);
    glVertex3f(1.0, 0.5, -2.0);
  glEnd;
  glBegin(mode);
    glNormal3f(0.0, -1.0, 0.0);
    glVertex3f(-1.0, -0.5, -2.0);
    glVertex3f(1.0, -0.5, -2.0);
    glVertex3f(1.0, -0.5, 2.0);
    glVertex3f(-1.0, -0.5, 2.0);
  glEnd;


  glPushMatrix;

  glBegin(mode);
    glNormal3f(0.0, 0.0, 1.0);
    glVertex3f(1.0, 0.5, 1.5);
    glVertex3f(-1.0, 0.5, 1.5);
    glVertex3f(-1.0, 1.0, 0.7);
    glVertex3f(1.0, 1.0, 0.7);
  glEnd;

  glBegin(mode);
    glNormal3f(0.0, 0.0, -1.0);
    glVertex3f(1.0, 1.0, -1.4);
    glVertex3f(1.0, 0.5, -1.8);
    glVertex3f(-1.0, 0.5, -1.8);
    glVertex3f(-1.0, 1.0, -1.4);
  glEnd;

  glBegin(mode);
    glNormal3f(-1.0, 0.0, 0.0);
    glVertex3f(-1.0, 1.0, 0.7);
    glVertex3f(-1.0, 0.5, 1.5);
    glVertex3f(-1.0, 0.5, -1.8);
    glVertex3f(-1.0, 1.0, -1.4);
  glEnd;

  glBegin(mode);
    glNormal3f(1.0, 0.0, 0.0);
    glVertex3f(1.0, 1.0, 0.7);
    glVertex3f(1.0, 0.5, 1.5);
    glVertex3f(1.0, 0.5, -1.8);
    glVertex3f(1.0, 1.0, -1.4);
  glEnd;

  glBegin(mode);
    glNormal3f(0.0, 1.0, 0.0);
    glVertex3f(-1.0, 1.0, -1.4);
    glVertex3f(-1.0, 1.0, 0.7);
    glVertex3f(1.0, 1.0, 0.7);
    glVertex3f(1.0, 1.0, -1.4);
  glEnd;

  glPopMatrix;

  glPushMatrix;
  glTranslatef(-1.0, -0.5, 1.0);
  glRotatef(90, 0.0, 1.0, 0.0);
  glColor3f(0.5, 0.6, 0.5);
  gluCylinder (quadObj, 0.4, 0.4, 0.29, 20, 10);

  glRotatef(180, 0.0, 1.0, 0.0);
  glPushMatrix;
  glTranslatef(0.0, 0.0, -0.01);
  glColor3f (0.1, 1.0, 0.5);
  gluDisk (quadObj, 0.0, 0.4,  20, 20);
  glPopMatrix;

  glTranslatef(0.0, 0.0, -0.3);
  glRotatef(180, 0.0, 1.0, 0.0);
  gluDisk (quadObj, 0.0, 0.4,  20, 20);
  glPopMatrix;

  glPushMatrix;
  glTranslatef(0.7, -0.5, 1.0);
  glRotatef(90, 0.0, 1.0, 0.0);
  glColor3f(0.5, 0.6, 0.5);
  gluCylinder (quadObj, 0.4, 0.4, 0.29, 20, 10);

  glRotatef(180, 0.5, 1.0, 0.0);
  glColor3f (0.1, 1.0, 0.5);
  gluDisk (quadObj, 0.0, 0.4,  20, 20);

  glTranslatef(0.0, 0.0, -0.29);
  glRotatef(180, 0.5, 1.0, 0.0);
  glColor3f (0.1, 1.0, 0.5);
  gluDisk (quadObj, 0.0, 0.4,  20, 20);
  glPopMatrix;

  glPushMatrix;
  glTranslatef(0.7, -0.5, -1.0);
  glRotatef(90, 0.0, 1.0, 0.0);
  glColor3f(0.5, 0.6, 0.5);
  gluCylinder (quadObj, 0.4, 0.4, 0.29, 20, 10);

  glRotatef(180, 0.0, 1.0, 0.0);
  glColor3f (0.1, 1.0, 0.5);
  gluDisk (quadObj, 0.0, 0.4,  20, 20);

  glTranslatef(0.0, 0.0, -0.29);
  glRotatef(180, 0.0, 1.0, 0.0);
  gluDisk (quadObj, 0.0, 0.4,  20, 20);
  glPopMatrix;

  glPushMatrix;
  glTranslatef(-1.0, -0.5, -1.0);
  glRotatef(90, 0.0, 1.0, 0.0);
  glColor3f(0.5, 0.6, 0.5);
  gluCylinder (quadObj, 0.4, 0.4, 0.29, 20, 10);

  glRotatef(180, 0.5, 1.0, 0.0);
  glColor3f (0.1, 1.0, 0.5);
  glPushMatrix;
  glTranslatef(0.0, 0.0, -0.01);
  gluDisk (quadObj, 0.0, 0.4,  20, 20);
  glPopMatrix;

  glTranslatef(0.0, 0.0, -0.3);
  glRotatef(180, 0.5, 1.0, 0.0);
  gluDisk (quadObj, 0.0, 0.4,  20, 20);
  glPopMatrix;

  glPushMatrix;
  glTranslatef(-0.7, -0.5, -1.0);
  glRotatef(90, 0.0, 1.0, 0.0);
  glColor3f (0.9, 0.5, 0.5);
  gluCylinder (quadObj, 0.05, 0.05, 1.4, 10, 10);
  glPopMatrix;

  glPushMatrix;
  glTranslatef(-0.7, -0.5, 1.0);
  glRotatef(90, 0.0, 1.0, 0.0);
  gluCylinder (quadObj, 0.05, 0.05, 1.4, 10, 10);
  glPopMatrix;

  glPushMatrix;
  glTranslatef(0.0, -0.5, -1.0);
  gluCylinder (quadObj, 0.05, 0.05, 2.0, 10, 10);
  glPopMatrix;

  glPushMatrix;
  glTranslatef(0.0, -0.5, -1.0);
  glColor3f (0.0, 0.0, 1.0);
  gluSphere(quadObj, 0.17, 20, 20);
  glPopMatrix;

  glPushMatrix;
  glColor3f (0.1, 1.0, 1.0);
  glTranslatef(0.5, 0.5, 0.5);
  glRotatef(30, 1.0, 0.0, 0.0);
  // баранка
  If solid
     then glutSolidTorus (0.05, 0.15, 3, 10)
     else glutWireTorus (0.05, 0.15, 3, 10);

  glPopMatrix;

  glPushMatrix;
  glColor3f (0.5, 0.0, 0.9);
  glTranslatef(-0.1, -0.4, 1.0);

  // мотор
  glBegin(GL_POLYGON);
    glNormal3f(0.0, 0.0, 1.0);
    glVertex3f(0.2, -0.2, 0.3);
    glVertex3f(-0.2, -0.2, 0.3);
    glVertex3f(-0.2, 0.2, 0.3);
    glVertex3f(0.2, 0.2, 0.3);
  glEnd;

  glBegin(GL_POLYGON);
    glNormal3f(0.0, 0.0, -1.0);
    glVertex3f(0.2, -0.2, -0.3);
    glVertex3f(0.2, 0.2, -0.3);
    glVertex3f(-0.2, 0.2, -0.3);
    glVertex3f(-0.2, -0.2, -0.3);
  glEnd;

  glBegin(GL_POLYGON);
    glNormal3f(-1.0, 0.0, 0.0);
    glVertex3f(-0.2, 0.2, 0.3);
    glVertex3f(-0.2, 0.2, -0.3);
    glVertex3f(-0.2, -0.2, -0.3);
    glVertex3f(-0.2, -0.2, 0.3);
  glEnd;

  glBegin(GL_POLYGON);
    glNormal3f(1.0, 0.0, 0.0);
    glVertex3f(0.2, 0.2, -0.3);
    glVertex3f(0.2, -0.2, -0.3);
    glVertex3f(0.2, -0.2, 0.3);
    glVertex3f(0.2, 0.2, 0.3);
  glEnd;

  glBegin(GL_POLYGON);
    glNormal3f(0.0, 1.0, 0.0);
    glVertex3f(-0.2, 0.2, 0.3);
    glVertex3f(-0.2, 0.2, -0.3);
    glVertex3f(0.2, 0.2, -0.3);
    glVertex3f(0.2, 0.2, 0.3);
  glEnd;

  glBegin(GL_POLYGON);
    glNormal3f(0.0, -1.0, 0.0);
    glVertex3f(-0.2, -0.2, -0.3);
    glVertex3f(-0.2, -0.2, 0.3);
    glVertex3f(0.2, -0.2, 0.3);
    glVertex3f(0.2, -0.2, -0.3);
  glEnd;
  glPopMatrix;

  glPushMatrix;
  glTranslatef(0.5, 0.5, 0.5);
  glRotatef(60, 1.0, 0.0, 0.0);
  glColor3f(0.7, 0.7, 0.7);
  // рулевая колонка
  gluCylinder (quadObj, 0.03, 0.03, 1.0, 10, 10);
  glPopMatrix;

  glPushMatrix;
  glTranslatef(0.5, 0.1, 0.8);
  glRotatef(70, 1.0, 0.0, 0.0);
  gluCylinder (quadObj, 0.09, 0.09, 0.7, 10, 10);
  glPopMatrix;

  glPushMatrix;
  // кресло
  glColor3f(0.8, 0.0, 0.3);
  glTranslatef(0.5, -0.6, 0.22);
  glRotatef(70, 1.0, 0.0, 0.0);
  glRotatef(180, 1.0, 0.0, 0.0);

  glBegin(GL_POLYGON);
    glNormal3f(0.0, 0.0, 1.0);
    glVertex3f(0.3, 0.2, 0.4);
    glVertex3f(-0.3, 0.2, 0.4);
    glVertex3f(-0.3, -0.3, 0.4);
    glVertex3f(0.3, -0.3, 0.4);
  glEnd;
  glPopMatrix;

 glPushMatrix;
 glTranslatef(0.5, 0.2, -0.7);
 glRotatef(-20, 1.0, 0.0, 0.0);

 glBegin(GL_POLYGON);
  glNormal3f(0.0, 0.0, 1.0);
    glVertex3f(0.3, 0.2, 0.4);
    glVertex3f(-0.3, 0.2, 0.4);
    glVertex3f(-0.3, -0.65, 0.4);
    glVertex3f(0.3, -0.65, 0.4);
  glEnd;
 glPopMatrix;

 glPopMatrix;

 SwapBuffers(DC);
end;


{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  glEnable(GL_DEPTH_TEST); // разрешаем тест глубины
  glEnable(GL_LIGHTING);   // разрешаем работу с освещенностью
  glEnable(GL_LIGHT0);     // включаем источник света 0
  glEnable (GL_COLOR_MATERIAL);

  up := 0.0;
  left := 0.0;
  right := 0.0;

  mode := GL_POLYGON;
  quadObj := gluNewQuadric;
end;

{=======================================================================
Установка формата пикселей}
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
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(distance, ClientWidth / ClientHeight, 1.0, 10.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(0.0, 0.0, -8.0);
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Обработка сообщения WM_PAINT, прерисовка окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);
  DrawScene;
  EndPaint(Handle, ps);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  gluDeleteQuadric (quadObj);
  wglMakeCurrent (0, 0);
  wglDeleteContext (hrc);
  ReleaseDC (Handle, DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    VK_ESCAPE : Close;
    VK_LEFT   : left := left + 5;
    VK_RIGHT  : right := right + 5;
    VK_UP     : up := up + 5;
    VK_RETURN : begin
                If solid
                   then gluQuadricDrawStyle(quadObj, GLU_SILHOUETTE)
                   else gluQuadricDrawStyle(quadObj, GLU_FILL);
                solid := not solid;
                end;
    VK_SPACE  : If mode = GL_POLYGON
                   then mode := GL_LINES
                   else mode := GL_POLYGON;
    VK_INSERT : begin
                distance := distance - 0.5;
                FormResize (nil);
                end;
    VK_DELETE : begin
                distance := distance + 0.5;
                FormResize (nil);
                end;
  end; {case}
  InvalidateRect(Handle, nil, False);
end;

end.


