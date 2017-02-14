{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpenGL;

const
  ImageWidth = 74;
  ImageHeight = 74;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);

  private
    hrc: HGLRC;
    DC : HDC;

    Image : Array [0..ImageHeight-1, 0..ImageWidth - 1, 0..2] of GLUbyte;
    procedure MakeImage;
    procedure SetDCPixelFormat (hdc : HDC);
  end;

var
  frmGL: TfrmGL;
  Down : Boolean = False;

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
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
  glViewPort (0, 0, ClientWidth, ClientHeight);

  glClearColor (0.5, 0.5, 0.75, 1.0);
  glClear(GL_COLOR_BUFFER_BIT);
  glRasterPos2f(-1.0, -1.0);
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

  glDrawPixels(ImageWidth, ImageHeight, GL_RGB, GL_UNSIGNED_BYTE, @Image);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
 dc := GetDC (Handle);
 SetDCPixelFormat(DC);
 hrc := wglCreateContext(DC);
 wglMakeCurrent(DC, hrc);

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
 nPixelFormat := ChoosePixelFormat (hdc, @pfd);
 SetPixelFormat (hdc, nPixelFormat, @pfd);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC (Handle, DC);
 DeleteDC (DC);
end;

procedure TfrmGL.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Down := True;
end;

procedure TfrmGL.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Down := False;
end;

procedure TfrmGL.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 If Down then begin
    {--- копирование части экрана ---}
    glRasterPos2f(2 * X / ClientWidth - 1,
                  2 * (ClientHeight - Y) / ClientHeight - 1);
    glCopyPixels (0, 0, ImageWidth, ImageHeight, GL_COLOR);
    glFlush
 end;
end;

end.

