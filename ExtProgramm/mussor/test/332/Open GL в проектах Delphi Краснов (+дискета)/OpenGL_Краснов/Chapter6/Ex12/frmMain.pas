{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
 Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus,
 Controls, Dialogs, SysUtils,
 OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC : HDC;
    hrc : HGLRC;
    Angle : GLfloat;
    uTimerId : uint;
    // массив свойств материала
    MaterialColor: Array[0..3] of GLfloat;

    procedure Init;
    procedure SetDCPixelFormat;
  end;

const
  GLF_START_LIST = 1000;

var
  frmGL: TfrmGL;

implementation

uses mmSystem;

{$R *.DFM}

const
 stripeImageWidth = 32;
var
 stripeImage : Array [0..3*stripeImageWidth-1] of GLubyte;

procedure makeStripeImage;
var
   j : GLint;
begin
    For j := 0 to stripeImageWidth - 1 do begin
      If j <= 4
        then stripeImage[3*j] := 255
        else stripeImage[3*j] := 0;
      If j > 4
        then stripeImage[3*j + 1] := 255
        else stripeImage[3*j + 1] := 0;
        stripeImage[3*j+2] := 0;
    end;
end;

{=======================================================================
Вывод текста}
procedure OutText (Litera : PChar);
begin
  glListBase(GLF_START_LIST);
  glCallLists(Length (Litera), GL_UNSIGNED_BYTE, Litera);
end;

{=======================================================================
Процедура инициализации источника цвета}
procedure TfrmGL.Init;
const
  sgenparams : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 0.0);
begin
  glEnable(GL_DEPTH_TEST);// разрешаем тест глубины
  glEnable(GL_LIGHTING); // разрешаем работу с освещенностью
  glEnable(GL_LIGHT0);   // включаем источник света 0

  makeStripeImage();
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  glTexParameterf(GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameterf(GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexImage1D(GL_TEXTURE_1D, 0, 3, stripeImageWidth, 0,
       GL_RGB, GL_UNSIGNED_BYTE, @stripeImage);
  glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);
  glTexGenfv(GL_S, GL_OBJECT_PLANE, @sgenparams);
  glEnable(GL_TEXTURE_GEN_S);
  glEnable(GL_TEXTURE_1D);
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 // очистка буфера цвета и буфера глубины
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 glPushMatrix;
 glRotatef(Angle, 0.0, 1.0, 0.0); // поворот на угол
 glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @MaterialColor);
 // вывод текста
 OutText ('Проба');
 glPopMatrix;

 SwapBuffers(DC);
end;

{=======================================================================
Обработка таймера}
procedure FNTimeCallBack(uTimerID, uMessage: UINT;dwUser, dw1, dw2: DWORD) stdcall;
begin
  With frmGL do begin
    Angle := Angle + 0.2;
    If (Angle >= 720.0) then Angle := 0.0;
    MaterialColor [0] := (720.0 - Angle) / 720.0;
    MaterialColor [1] := Angle / 720.0;
    MaterialColor [2] := Angle / 720.0;
    InvalidateRect(Handle, nil, False);
  end;
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  Angle := 0;
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  wglUseFontOutlines(Canvas.Handle, 0, 255, GLF_START_LIST, 0.0, 0.15,
               WGL_FONT_POLYGONS, nil);
  Init;
  uTimerID := timeSetEvent (1, 0, @FNTimeCallBack, 0, TIME_PERIODIC);
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(40.0, ClientWidth / ClientHeight, 1.0, 20.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(0.0, 0.0, -8.0);
  glRotatef(30.0, 1.0, 0.0, 0.0);
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  timeKillEvent(uTimerID);
  glDeleteLists (GLF_START_LIST, 256);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close
end;

{=======================================================================
Установка формата пикселей}
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

