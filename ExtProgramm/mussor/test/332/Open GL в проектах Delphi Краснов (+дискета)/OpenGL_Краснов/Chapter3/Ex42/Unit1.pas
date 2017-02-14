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
  selpoint : 0..3 = 0;

implementation

{$R *.DFM}

const
 ctrlpoints : Array [0..3, 0..2] of GLfloat =
       (( -4.0, -4.0, 0.0), (-2.0, 4.0, 0.0),
	(2.0, -4.0, 0.0), (4.0, 4.0, 0.0));

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
var
 i : GLint;
begin
 glClear (GL_COLOR_BUFFER_BIT);      // очистка буфера цвета

 glColor3f(1.0, 1.0, 1.0);
 glBegin(GL_LINE_STRIP);
   For i := 0 to 30 do
     glEvalCoord1f(i / 30.0);
 glEnd;
 // The following code displays the control points as dots.
 glPointSize(5.0);
 glBegin(GL_POINTS);
   For i := 0 to 3 do begin
     If i = selpoint
        then glColor3f(1.0, 0.0, 0.0)
        else glColor3f(1.0, 1.0, 0.0);  
     glVertex3fv(@ctrlpoints[i][0]);
   end;
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
 glMap1f(GL_MAP1_VERTEX_3, 0.0, 1.0, 3, 4, @ctrlpoints);
 glEnable(GL_MAP1_VERTEX_3);
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
 If Key = VK_SPACE then begin
    selpoint := selpoint + 1;
    If selpoint > High (selpoint) then selpoint := Low (selpoint);
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_LEFT then begin
    ctrlpoints [selpoint, 0] := ctrlpoints [selpoint, 0] - 0.1;
    glMap1f(GL_MAP1_VERTEX_3, 0.0, 1.0, 3, 4, @ctrlpoints);
    glEnable(GL_MAP1_VERTEX_3);
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_RIGHT then begin
    ctrlpoints [selpoint, 0] := ctrlpoints [selpoint, 0] + 0.1;
    glMap1f(GL_MAP1_VERTEX_3, 0.0, 1.0, 3, 4, @ctrlpoints);
    glEnable(GL_MAP1_VERTEX_3);
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_UP then begin
    ctrlpoints [selpoint, 1] := ctrlpoints [selpoint, 1] + 0.1;
    glMap1f(GL_MAP1_VERTEX_3, 0.0, 1.0, 3, 4, @ctrlpoints);
    glEnable(GL_MAP1_VERTEX_3);
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_DOWN then begin
    ctrlpoints [selpoint, 1] := ctrlpoints [selpoint, 1] - 0.1;
    glMap1f(GL_MAP1_VERTEX_3, 0.0, 1.0, 3, 4, @ctrlpoints);
    glEnable(GL_MAP1_VERTEX_3);
    InvalidateRect(Handle, nil, False);
 end;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 If ClientWidth <= ClientHeight
   then glOrtho(-5.0, 5.0, -5.0*ClientHeight / ClientWidth,
               5.0*ClientHeight / ClientWidth, -5.0, 5.0)
   else glOrtho(-5.0*ClientWidth / ClientHeight,
               5.0*ClientWidth / ClientHeight, -5.0, 5.0, -5.0, 5.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;

 InvalidateRect(Handle, nil, False);
end;


end.

