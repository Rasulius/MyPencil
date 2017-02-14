{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
 Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus,
 Controls, Dialogs, SysUtils,
 OpenGL, DGLUT;

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
    procedure SetDCPixelFormat;
  end;

const
  GLF_START_LIST = 1000;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}


{=======================================================================
Вывод текста}
procedure OutText (Litera : PChar);
begin
  glListBase(GLF_START_LIST);
  glCallLists(Length (Litera), GL_UNSIGNED_BYTE, Litera);
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 // трехмерность
 glLoadIdentity;
 glTranslatef(0.0, 0.0, -8.0);
 glRotatef(30.0, 1.0, 0.0, 0.0);
 glRotatef(30.0, 0.0, 1.0, 0.0); // поворот на угол

 glutSolidTeapot (1.0);
 glRasterPos2f (-0.4,-1.75);

 OutText ('Чайник');             // вывод текста

 SwapBuffers(DC);
end;


{=======================================================================
Установка формата пикселей}
procedure TfrmGL.SetDCPixelFormat;
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;

begin
  FillChar(pfd, SizeOf(pfd), 0);

  pfd.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  glClearColor (0.3, 0.1, 0.5, 1.0);
  wglUseFontBitmaps (Canvas.Handle, 0, 255, GLF_START_LIST);

  glEnable(GL_DEPTH_TEST);// разрешаем тест глубины
  glEnable(GL_LIGHTING); // разрешаем работу с освещенностью
  glEnable(GL_LIGHT0);   // включаем источник света 0
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(30.0, ClientWidth / ClientHeight, 1.0, 20.0);
  glMatrixMode(GL_MODELVIEW);
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  glDeleteLists (GLF_START_LIST, 256);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC(DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close
end;

end.

