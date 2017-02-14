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
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);

  private
    DC: HDC;
    hrc: HGLRC;
    qobj : GLUquadricObj ;
    procedure SetDCPixelFormat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  Angle : GLint = 0;

implementation

{$R *.DFM}

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
 ps : TPaintStruct;
begin
 BeginPaint(Handle, ps);

 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 glPushMatrix;
 glRotatef (Angle, 1.0, 1.0, 0.0);

 {красная сфера внутри}
 glColor4f (1.0, 1.0, 0.0, 1.0);
 gluSphere(qobj, 0.5, 20, 20);

 {наружняя сфера}
 glPushMatrix;
 glTranslatef(0, -0.3, 0);
 glRotatef(angle, 0, 1, 0);
 glTranslatef(0, 0, 0.6);
 glColor4f (1.0, 0.0, 0.5, 0.5);
 gluSphere(qobj, 0.3, 20, 20);
 glPopMatrix;

 glPopMatrix;

 SwapBuffers(DC);
 EndPaint(Handle, ps);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
const
  mat_specular : Array [0..3] of GLFloat = (1.0, 1.0, 1.0, 1.0);
  mat_shininess : GLFloat = 50.0;
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, @mat_specular);
  glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, @mat_shininess);

  glEnable(GL_LIGHT0);
  glEnable(GL_LIGHTING);
  glEnable(GL_BLEND);
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_COLOR_MATERIAL);

  qObj := gluNewQuadric;

  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
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
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluPerspective(2.0, ClientWidth / ClientHeight, 80.0, 150.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef(0.0, 0.0, -100.0);
 glRotatef (90.0, 0.0, 1.0, 0.0);
 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 gluDeleteQuadric (qObj);
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC(Handle, DC);
 DeleteDC (DC);
end;

procedure TfrmGL.Timer1Timer(Sender: TObject);
begin
 Angle := (Angle + 2) mod 360;
 InvalidateRect(Handle, nil, False);
end;

end.

