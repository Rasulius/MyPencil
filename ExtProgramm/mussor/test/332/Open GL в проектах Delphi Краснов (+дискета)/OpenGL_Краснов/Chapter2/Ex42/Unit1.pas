{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpenGL;

const
  ImageWidth = 64;
  ImageHeight = 64;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    hrc: HGLRC;
    Image : Array [0..ImageHeight-1, 0..ImageWidth - 1, 0..2] of GLUbyte;

    procedure MakeImage;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
�������� ������ ��������� �����}
procedure TfrmGL.MakeImage;
var
 i, j : Integer;
begin
 For i := 0 to ImageHeight - 1 do
     For j := 0 to ImageWidth - 1 do begin
         If ((i and 8) = 0) xor ((j and 8) = 0)
         then begin
         Image[i][j][0] := 0;
         Image[i][j][1] := 0;
         Image[i][j][2] := 255;
         end
         else begin
         Image[i][j][0] := 255;
         Image[i][j][1] := 0;
         Image[i][j][2] := 0;
         end;
 end;
end;

{=======================================================================
��������� ��������}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glViewPort (0, 0, ClientWidth, ClientHeight); // ������� ������

 glClearColor (0.5, 0.5, 0.75, 1.0);
 glClear (GL_COLOR_BUFFER_BIT);

 glRasterPos2f(-0.25, -0.25);
 glDrawPixels(ImageWidth, ImageHeight, GL_RGB, GL_UNSIGNED_BYTE, @Image);

 SwapBuffers(Canvas.Handle);
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
 MakeImage;
end;

{=======================================================================
����� ������ ����������}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglDeleteContext(hrc);
end;

end.

