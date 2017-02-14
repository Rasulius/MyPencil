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
 mode1 : Boolean = False;
 mode2 : Boolean = False;
 size : GLint = 1;
 pntA : Array [0..2] of GLfloat = (-160.0, 0.0, 0.0);
 pntB : Array [0..2] of GLfloat = (-130.0, 0.0, 0.0);
 pntC : Array [0..2] of GLfloat = (-40.0, -50.0, 0.0);
 pntD : Array [0..2] of GLfloat = (30.0, 60.0, 0.0);

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
var
 i : GLint;
begin
 glClear (GL_COLOR_BUFFER_BIT);      // очистка буфера цвета

 glLineWidth(size);

 If mode1
    then glEnable(GL_LINE_STIPPLE)
    else glDisable(GL_LINE_STIPPLE);

 If mode2
    then glEnable (GL_LINE_SMOOTH)
    else glDisable(GL_LINE_SMOOTH);

 glPushMatrix;
 For i := 0 to 71 do begin
    glRotatef(5.0, 0, 0, 1);

    glColor3f(1.0, 1.0, 0.0);
    glBegin(GL_LINE_STRIP);
      glVertex3fv(@pntA);
      glVertex3fv(@pntB);
    glEnd;

    glColor3f(0.0, 1.0, 0.0);
    glBegin(GL_POINTS);
      glVertex3fv(@pntA);
      glVertex3fv(@pntB);
    glEnd;
 end;

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
 glLineStipple(1, $F0E0);
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
    mode1 := not mode1;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = 50 then begin
    mode2 := not mode2;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = ord ('W') then begin
    If ssShift in Shift
       then size := size + 1
       else size := size - 1;
       If size < 1 then size := 1;
    InvalidateRect(Handle, nil, False);
 end;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluOrtho2D(-175, 175, -175, 175);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;

 InvalidateRect(Handle, nil, False);
end;


end.

