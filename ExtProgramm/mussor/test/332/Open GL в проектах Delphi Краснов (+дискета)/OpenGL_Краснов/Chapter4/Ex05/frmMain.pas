{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Controls,
  SysUtils, Dialogs, OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    DC: HDC;
    hrc: HGLRC;
    Pos, Angle, Delta : GLfloat;
    procedure Init;
    procedure SetDCPixelFormat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
  Cylinder = 1;

var
  frmGL: TfrmGL;
  Closed : Boolean = False;

implementation

{$R *.DFM}

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
var
 Quadric : GLUquadricObj;
begin
 glEnable(GL_LIGHTING);
 glEnable(GL_LIGHT0);
 glEnable(GL_DEPTH_TEST);

 Quadric := gluNewQuadric;

 glNewList (Cylinder, GL_COMPILE);
   gluCylinder (Quadric, 1.0, 1.0, 5.0, 50, 50);
 glEndList;

 gluDeleteQuadric (Quadric);
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
const
  ambFront : Array [0..3] of GLfloat = (0.0, 0.0, 1.0, 1.0);
  ambBack : Array [0..3] of GLfloat = (1.0, 0.0, 0.0, 1.0);
begin
  BeginPaint(Handle, ps);

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix;

  glTranslatef (Pos, Pos, Pos);
  glRotatef (Angle, 1.0, 1.0, 0.0);

  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, 1);

  glMaterialfv (GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @ambFront);
  glMaterialfv (GL_BACK, GL_AMBIENT_AND_DIFFUSE, @ambBack);

  glCallList(Cylinder);

  glPopMatrix;

  SwapBuffers(DC);
  EndPaint(Handle, ps);

  If not Closed then begin
     Angle := Angle + 2;
     If Angle > 360.0 then Angle := 0.0;
     Pos := Pos + Delta;
     If Pos > 2.0
        then Delta := -0.1
        else If Pos < -2.0 then
             Delta := 0.1;
     Application.ProcessMessages;
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

  Pos := 0.0;
  Delta := 0.1;
  Angle := 0.0;

  Init;
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight );
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 glFrustum(-1.0, 1.0, -1.0, 1.0, 2.0, 25.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef(0.0, 0.0, -12.0);
 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 glDeleteLists (Cylinder, 1);
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


procedure TfrmGL.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Closed := True;
end;

end.


