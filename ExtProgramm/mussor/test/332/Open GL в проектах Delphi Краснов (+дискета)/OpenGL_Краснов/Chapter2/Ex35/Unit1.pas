{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
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

  private
    hrc: HGLRC;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
����������� ����}
procedure TfrmGL.FormPaint(Sender: TObject);
const
 Level = 20;     // ������� �����������
 radius1 = 0.4;  // ������ ����������� ���������
 radius2 = 0.7;  // ������ ������� ������
var
 i : 0 .. Level - 1;
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glViewPort (0, 0, ClientWidth, ClientHeight);

 glClearColor (1.0, 1.0, 1.0, 1.0);
 glClear (GL_COLOR_BUFFER_BIT);
 glColor3f(1.0, 0.0, 0.0);

 glBegin(GL_QUAD_STRIP);
 For i := 0 to Level - 1 do begin
    glVertex2f(radius1 * sin (2 * Pi * i / Level),
               radius1 * cos (2 * Pi * i / Level));
    glVertex2f(radius2 * sin (2 * Pi * i / Level),
               radius2 * cos (2 * Pi * i / Level));
    glVertex2f(radius1 * sin (2 * Pi * (i + 1) / Level),
               radius1 * cos (2 * Pi * (i + 1) / Level));
    glVertex2f(radius2 * sin (2 * Pi * (i + 1) / Level),
               radius2 * cos (2 * Pi * (i + 1) / Level));
 end;
 glEnd;

 SwapBuffers(Canvas.Handle);        // ���������� ������ - �� �����
 wglMakeCurrent(0, 0);
end;

{=======================================================================
������ �������}
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
�������� �����}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
 SetDCPixelFormat(Canvas.Handle);
 hrc := wglCreateContext(Canvas.Handle);
end;

{=======================================================================
����� ������ ����������}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglDeleteContext(hrc);
end;

end.

