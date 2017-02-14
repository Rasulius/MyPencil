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
    procedure FormKeyPress(Sender: TObject; var Key: Char);

  private
    hrc: HGLRC;  
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
����������� ������}
procedure TfrmGL.FormPaint(Sender: TObject);
var
 i : 0..9;
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glViewPort (0, 0, ClientWidth, ClientHeight); // ������� ������

 glClearColor (0.75, 0.75, 0.5, 1.0); // ����������� ����� ����
 glClear (GL_COLOR_BUFFER_BIT);       // ������� ������ �����

 glBegin (GL_TRIANGLE_STRIP);
   glVertex2f (random * 2 - 1, random * 2 - 1);
   For i := 0 to 9 do begin
       glColor3f (random, random, random);
       glVertex2f (random * 2 - 1, random * 2 - 1);
       glVertex2f (random * 2 - 1, random * 2 - 1);
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

{=======================================================================
��������� ������� �������}
procedure TfrmGL.FormKeyPress(Sender: TObject; var Key: Char);
begin
  Refresh
end;

end.

