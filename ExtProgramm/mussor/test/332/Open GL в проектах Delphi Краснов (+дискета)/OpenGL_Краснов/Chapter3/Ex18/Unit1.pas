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

var
 mode : Boolean = False;
 size : GLint = 1;
 point : Array [0..2] of GLfloat = (0.0, 0.0, 0.0);

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 glClear (GL_COLOR_BUFFER_BIT);

 glColor3f(1.0, 1.0, 0.0);
 glBegin(GL_LINE_STRIP);
   glVertex2f(-ClientWidth / 2, 0);
   glVertex2f(ClientWidth / 2, 0);
 glEnd;

 glBegin(GL_LINE_STRIP);
   glVertex2f(0, -ClientHeight / 2);
   glVertex2f(0, ClientHeight / 2);
 glEnd;

 If mode
    then glEnable(GL_POINT_SMOOTH)
    else glDisable(GL_POINT_SMOOTH);

 glPointSize(size);

 glColor3f(1.0, 0.0, 0.0);

 glBegin(GL_POINTS);
   glVertex3fv(@point);
 glEnd;

 glDisable(GL_POINT_SMOOTH);

 glPointSize(1);
 glColor3f(0.0, 1.0, 0.0);
 glBegin(GL_POINTS);
   glVertex3fv(@point);
 glEnd;

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
end;

{=======================================================================
Конец работы приложения}
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
 If Key = 49 then begin
    mode := not mode;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = ord ('W') then begin
    If ssShift in Shift
       then size := size + 1
       else size := size - 1;
       If size < 1 then size := 1;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_LEFT then begin
    point[0] := point[0] - 0.25;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_RIGHT then begin
    point[0] := point[0] + 0.25;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_UP then begin
    point[1] := point[1] + 0.25;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_DOWN then begin
    point[1] := point[1] - 0.25;
    InvalidateRect(Handle, nil, False);
 end;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluOrtho2D(-ClientWidth/2, ClientWidth/2, -ClientHeight/2, ClientHeight/2);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;

 InvalidateRect(Handle, nil, False);
end;


end.

