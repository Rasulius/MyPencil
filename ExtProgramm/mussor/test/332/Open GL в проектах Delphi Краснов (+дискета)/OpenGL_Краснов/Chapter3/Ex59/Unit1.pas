{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
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

const
 listName1 : GLUint = 1;
 listName2 : GLUint = 2;
 listName3 : GLUint = 3;

procedure init;
var
 i : GLuint;
begin
 glNewList (listName1, GL_COMPILE);
   glColor3f (1.0, 0.0, 0.0);
   glBegin (GL_TRIANGLES);
    glVertex2f (0.0, 0.0);
    glVertex2f (1.0, 0.0);
    glVertex2f (0.0, 1.0);
   glEnd;
   glTranslatef (1.5, 0.0, 0.0);
 glEndList;

 glNewList (listName3, GL_COMPILE);
   glCallList (listName2);
 glEndList;

 glNewList (listName2, GL_COMPILE);
   For i := 0 to 3 do
     glCallList (listName1);
 glEndList;
end;

procedure drawLine;
begin
 glBegin (GL_LINES);
    glVertex2f (0.0, 0.5);
    glVertex2f (15.0, 0.5);
 glEnd;
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
const
 list : Array [0..1] of GLUint = (1, 2);
begin
 glClear (GL_COLOR_BUFFER_BIT);      // очистка буфера цвета

 glColor3f (0.0, 1.0, 0.0);
 glPushMatrix;
 glListBase (1);
 glCallLists (2, GL_INT, @list);
 drawLine;
 glPopMatrix;

 SwapBuffers(DC);
end;

{=======================================================================
Формат пикселя}
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
Создание формы}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
 DC := GetDC (Handle);
 SetDCPixelFormat(DC);
 hrc := wglCreateContext(DC);
 wglMakeCurrent(DC, hrc);
 init;
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 glDeleteLists (listName1, 3);
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
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 If ClientWidth < ClientHeight
    then gluOrtho2D (0.0, 2.0, -0.5 * ClientHeight / ClientWidth,
                1.5 * ClientHeight / ClientWidth)
    else gluOrtho2D (0.0, 2.0 * ClientWidth / ClientHeight, -0.5, 1.5);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;

 InvalidateRect(Handle, nil, False);
end;

end.

