{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Controls,
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
    Torus : GLint;
    procedure MakeList;
    procedure SetDCPixelFormat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  Angle : GLint = 0;

const
  WIN_WIDTH = 200;
  WIN_HEIGHT = 200;

implementation

uses DGLUT;

{$R *.DFM}


{=======================================================================
Подготовка списка}
procedure TfrmGL.MakeList;
begin
 Torus := glGenLists(1);
 glNewList(Torus, GL_COMPILE);
    glutSolidTorus(5.0, 15.0, 16, 32);
 glEndList;
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
 ps : TPaintStruct;
 Zbuf : Array [0..WIN_WIDTH - 1, 0..WIN_HEIGHT - 1] of GLfloat;
begin
 BeginPaint(Handle, ps);

 glViewport(0,0,round(ClientWidth/2), ClientHeight);
 glScissor(0,0,round(ClientWidth/2), ClientHeight);
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluPerspective(60.0, ClientWidth / ClientHeight, 5.0, 70.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glPushMatrix;
 gluLookAt(25.0,25.0,50.0,25.0,25.0,20.0,0.0,1.0,0.0);
 glTranslatef(25.0,25.0,10.0);
 glRotatef (Angle, 1.0, 0.0, 0.0);
 glCallList(Torus);
 glReadPixels(0, 0, WIN_WIDTH, WIN_HEIGHT, GL_BLUE, GL_FLOAT, @Zbuf);
 glPopMatrix;

 // View 2
 glViewport(round(ClientWidth/2) + 1, 0, round(ClientWidth/2), ClientHeight);
 glScissor(round(ClientWidth/2) + 1, 0, round(ClientWidth/2), ClientHeight);
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 glPushMatrix;
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 glRasterPos2i (-1, -1);
 glDrawPixels(WIN_WIDTH, WIN_HEIGHT, GL_DEPTH_COMPONENT, GL_FLOAT, @Zbuf);
 glPopMatrix;

 SwapBuffers(DC);
 EndPaint(Handle, ps);

 Angle := (Angle + 2) mod 360;
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

  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_SCISSOR_TEST);
  glEnable(GL_COLOR_MATERIAL);
  glColor3f (0.7, 1.0, 1.0);

  glClearColor(0.5, 0.7, 1.0, 1.0);
  MakeList;
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
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  glDeleteLists (Torus, 1);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

end.

