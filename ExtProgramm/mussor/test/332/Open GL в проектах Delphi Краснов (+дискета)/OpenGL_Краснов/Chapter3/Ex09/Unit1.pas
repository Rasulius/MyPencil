{**********************************************************************}
{* »ллюстраци€ к книге "OpenGL в проектах Delphi"                     *}
{*  раснов ћ.¬. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);

  private
    DC : HDC;
    hrc: HGLRC;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
ѕерерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 glClear (GL_COLOR_BUFFER_BIT);      // очистка буфера цвета

 // рисование шести сторон куба
 glBegin(GL_QUADS);
   glVertex3f(1.0, 1.0, 1.0);
   glVertex3f(-1.0, 1.0, 1.0);
   glVertex3f(-1.0, -1.0, 1.0);
   glVertex3f(1.0, -1.0, 1.0);
 glEnd;

 glBegin(GL_QUADS);
   glVertex3f(1.0, 1.0, -1.0);
   glVertex3f(1.0, -1.0, -1.0);
   glVertex3f(-1.0, -1.0, -1.0);
   glVertex3f(-1.0, 1.0, -1.0);
 glEnd;

 glBegin(GL_QUADS);
   glVertex3f(-1.0, 1.0, 1.0);
   glVertex3f(-1.0, 1.0, -1.0);
   glVertex3f(-1.0, -1.0, -1.0);
   glVertex3f(-1.0, -1.0, 1.0);
 glEnd;

 glBegin(GL_QUADS);
   glVertex3f(1.0, 1.0, 1.0);
   glVertex3f(1.0, -1.0, 1.0);
   glVertex3f(1.0, -1.0, -1.0);
   glVertex3f(1.0, 1.0, -1.0);
 glEnd;

 glBegin(GL_QUADS);
   glVertex3f(-1.0, 1.0, -1.0);
   glVertex3f(-1.0, 1.0, 1.0);
   glVertex3f(1.0, 1.0, 1.0);
   glVertex3f(1.0, 1.0, -1.0);
 glEnd;

 glBegin(GL_QUADS);
   glVertex3f(-1.0, -1.0, -1.0);
   glVertex3f(1.0, -1.0, -1.0);
   glVertex3f(1.0, -1.0, 1.0);
   glVertex3f(-1.0, -1.0, 1.0);
 glEnd;

 SwapBuffers(DC);
end;

{=======================================================================
‘ормат пиксел€}
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPixelFormatDescriptor;
 nPixelFormat : Integer;
begin
 FillChar (pfd, SizeOf (pfd), 0);
 pfd.dwFlags  := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
 nPixelFormat := ChoosePixelFormat (hdc, @pfd);
 SetPixelFormat (hdc, nPixelFormat, @pfd);
end;

{=======================================================================
—оздание формы}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
 DC := GetDC (Handle);
 SetDCPixelFormat (DC);
 hrc := wglCreateContext (DC);
 wglMakeCurrent (DC, hrc);
 glClearColor (0.5, 0.5, 0.75, 1.0); // цвет фона
 glColor3f (1.0, 0.0, 0.5);          // текущий цвет примитивов
 glPolygonMode (GL_FRONT_AND_BACK, GL_LINE);
end;

{=======================================================================
 онец работы приложени€}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC (Handle, DC);
 DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glLoadIdentity;
 // задаем перспективу
 gluPerspective(30.0,           // угол видимости в направлении оси Y
                ClientWidth / ClientHeight, // угол видимости в направлении оси X
                1.0,            // рассто€ние от наблюдател€ до ближней плоскости отсечени€
                15.0);          // рассто€ние от наблюдател€ до дальней плоскости отсечени€
 glTranslatef (0.0, 0.0, -10.0);   // перенос - ось Z
 glRotatef (30.0, 1.0, 0.0, 0.0);  // поворот - ось X
 glRotatef (60.0, 0.0, 1.0, 0.0);  // поворот - ось Y

 InvalidateRect(Handle, nil, False);
end;

end.

