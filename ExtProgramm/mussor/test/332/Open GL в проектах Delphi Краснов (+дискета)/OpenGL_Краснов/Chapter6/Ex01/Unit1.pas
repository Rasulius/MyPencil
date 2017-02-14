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
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

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
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glViewPort (0, 0, ClientWidth, ClientHeight); // ������� ������

 glClearColor (0.5, 0.5, 0.75, 1.0); // ���� ����
 glClear (GL_COLOR_BUFFER_BIT);      // ������� ������ �����

 {--- ������� ����������� ---}
 glColor3f (1.0, 0.0, 0.0);          // ������� ���� ����������
 glBegin (GL_TRIANGLES);
   glVertex2f (-1, -1);
   glVertex2f (-1, 1);
   glVertex2f (-0.1, 0);
 glEnd;

 {--- ����� ����������� ---}
 glColor3f (0.0, 0.0, 1.0);          // ������� ���� ����������
 glBegin (GL_TRIANGLES);
   glVertex2f (0.1, 0);
   glVertex2f (1, 1);
   glVertex2f (1, -1);
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

procedure TfrmGL.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
{=======================================================================
������� ����� �� TColor � OpenGL}
procedure ColorToGL (c : TColor; var R, G, B : GLfloat);
begin
 R := (c mod $100) / 255;
 G := ((c div $100) mod $100) / 255;
 B := (c div $10000) / 255;
end;
var
 R, G, B : GLfloat;
begin
  ColorToGL (Canvas.Pixels [X,Y], R, G, B);
  If (R <> 0) and (B = 0) then
     ShowMessage ('������ ������� �����������')
     else
     If (R = 0) and (B <> 0) then
     ShowMessage ('������ ����� �����������')
     else
     ShowMessage ('������ �� �������');
end;

end.

