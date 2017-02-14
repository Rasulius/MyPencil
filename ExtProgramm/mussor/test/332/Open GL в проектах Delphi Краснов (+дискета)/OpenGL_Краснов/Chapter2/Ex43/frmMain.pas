{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;
interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Controls, OpenGL;

const
  ImageWidth = 74;
  ImageHeight = 74;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);

  private
    hrc: HGLRC;

    Image : Array [0..ImageHeight-1, 0..ImageWidth - 1, 0..2] of GLUByte;
    procedure MakeImage;
    procedure SetDCPixelFormat (hdc : HDC);
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
Создание образа}
procedure TfrmGL.MakeImage;
var
 i, j : Integer;
 PixCol : TColor;
 Bitmap : TBitmap;
begin
 Bitmap := TBitmap.Create;
 Bitmap.LoadFromFile ('Claudia.bmp');
 For i := 0 to ImageHeight - 1 do
 For j := 0 to ImageWidth - 1 do begin
     PixCol := Bitmap.Canvas.Pixels [j, i];
     Image[ImageHeight - i - 1][j][0] := PixCol and $FF;
     Image[ImageHeight - i - 1][j][1] := (PixCol and $FF00) shr 8;
     Image[ImageHeight - i - 1][j][2] := (PixCol and $FF0000) shr 16;
 end;
 Bitmap.Free;
end;

{=======================================================================
Рисование окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
  wglMakeCurrent(Canvas.Handle, hrc);
  glClearColor (0.5, 0.5, 0.75, 1.0);
  glClear(GL_COLOR_BUFFER_BIT);
  glRasterPos2f(-0.25, -0.25);
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  glDrawPixels(ImageWidth, ImageHeight, GL_RGB, GL_UNSIGNED_BYTE, @Image);

  SwapBuffers (Canvas.Handle);

  wglMakeCurrent(0, 0);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
 SetDCPixelFormat (Canvas.Handle);
 hrc := wglCreateContext(Canvas.Handle);
 MakeImage;
end;

{=======================================================================
Формат пикселя}
procedure TfrmGL.SetDCPixelFormat (hdc : HDC);
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
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglDeleteContext(hrc);
end;

end.

