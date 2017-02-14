{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Controls,
  Dialogs, OpenGL;

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
    procedure Init;
    procedure SetDCPixelFormat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  Angle : GLint = 0;

implementation

uses DGLUT;

{$R *.DFM}

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
    light_position : Array [0..3] of GLfloat = ( 1.0, 1.0, 1.0, 0.0 );
    global_ambient : Array [0..3] of GLfloat = ( 0.75, 0.75, 0.75, 1.0 );
begin
    glLightfv(GL_LIGHT0, GL_POSITION, @light_position);

    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @global_ambient);

    glFrontFace (GL_CW);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_DEPTH_TEST);
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
const
  eqn : Array [0..3] of GLdouble  = (1.0, 0.0, -1.0, 1.0);

  front_amb : Array [0..3] of GLfloat = ( 0.135, 0.2225, 0.1575, 1.0 );
  front_diffuse : Array [0..3] of GLfloat = ( 0.54, 0.89, 0.63, 1.0 );
  front_specular : Array [0..3] of GLfloat = ( 0.316228, 0.316228, 0.316228, 1.0 );
  front_shine : GLfloat = 0.1;


  back_amb : Array [0..3] of GLfloat = ( 0.05, 0.05, 0.0, 1.0 );
  back_diffuse : Array [0..3] of GLfloat = ( 0.5, 0.5, 0.4, 1.0 );
  back_specular : Array [0..3] of GLfloat = ( 0.7, 0.7, 0.04, 1.0 );
  back_shine : GLfloat = 0.078125;
begin
  BeginPaint(Handle, ps);

  glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT );

  glPushMatrix;
  glClipPlane (GL_CLIP_PLANE0, @eqn);  //*  slice objects   */
  glEnable (GL_CLIP_PLANE0);

  glLightModelf (GL_LIGHT_MODEL_TWO_SIDE, 1);
  glMaterialfv (GL_FRONT, GL_DIFFUSE, @front_diffuse);
  glMaterialfv (GL_FRONT, GL_AMBIENT, @front_amb);
  glMaterialfv (GL_FRONT, GL_SPECULAR, @front_specular);
  glMaterialf (GL_FRONT, GL_SHININESS, front_shine*128.0);

  glMaterialfv (GL_BACK, GL_DIFFUSE, @back_diffuse);
  glMaterialfv (GL_BACK, GL_AMBIENT, @back_amb);
  glMaterialfv (GL_BACK, GL_SPECULAR, @back_specular);
  glMaterialf (GL_BACK, GL_SHININESS, back_shine*128.0);

  glRotatef (Angle, 1.0, 1.0, 0.0);
  glutSolidTeapot(1.0);

  glLightModelf (GL_LIGHT_MODEL_TWO_SIDE, 0);
  glDisable (GL_CLIP_PLANE0);

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
  Init;
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight );
 glMatrixMode (GL_PROJECTION);
 glLoadIdentity;
 If ClientWidth <= ClientHeight
    then glOrtho (-2.0, 2.0, -2.0*ClientHeight/ClientWidth,
        2.0*ClientHeight/ClientWidth, -10.0, 10.0)
    else glOrtho (-2.0*ClientWidth/ClientHeight,
        2.0*ClientWidth/ClientHeight, -2.0, 2.0, -10.0, 10.0);
 glMatrixMode (GL_MODELVIEW);

 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
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

end.


