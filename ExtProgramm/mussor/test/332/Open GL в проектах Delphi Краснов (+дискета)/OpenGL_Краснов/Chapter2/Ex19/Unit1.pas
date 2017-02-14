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
var
 i : 0..5;
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glViewPort (0, 0, ClientWidth, ClientHeight); // ������� ������

 glClearColor (0.5, 0.5, 0.75, 1.0); // ���� ����
 glClear (GL_COLOR_BUFFER_BIT);      // ������� ������ �����

 glColor3f (1.0, 0.0, 0.5);          // ������� ���� ����������
 glBegin (GL_TRIANGLES);
   For i := 0 to 5 do begin
       glVertex2f (0, 0);
       glVertex2f (0.5 * cos (2 * Pi * i / 6),
                   0.5 * sin (2 * Pi * i / 6));
       glVertex2f (0.5 * cos (2 * Pi * (i + 1) / 6),
                   0.5 * sin (2 * Pi * (i + 1) / 6));
   end;
 glEnd;

 SwapBuffers(Canvas.Handle);         // ���������� ������ - �� �����
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

