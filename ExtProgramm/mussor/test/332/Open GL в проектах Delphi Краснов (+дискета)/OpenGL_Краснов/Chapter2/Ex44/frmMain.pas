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
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    hrc: HGLRC;
    Xzoom, Yzoom : GLFloat;
    SkipPixels, SkipRows : GLUint;

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
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
  wglMakeCurrent(Canvas.Handle, hrc);
  glClearColor (0.5, 0.5, 0.75, 1.0);
  glClear(GL_COLOR_BUFFER_BIT);
  glRasterPos2f(-0.25, -0.25);
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

  glPixelStorei(GL_UNPACK_SKIP_PIXELS, SkipPixels);
  glPixelStorei(GL_UNPACK_SKIP_ROWS, SkipRows);

  glPixelZoom(Xzoom, Yzoom);

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

 Xzoom := 1.0;
 Yzoom := 1.0;

 SkipPixels := 0;
 SkipRows := 0;
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

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
  If Key = Ord ('X') then begin
     If ssShift in Shift
        then Xzoom := Xzoom - 0.1
        else Xzoom := Xzoom + 0.1;
     Refresh
     end;
  If Key = Ord ('Y') then begin
     If ssShift in Shift
        then Yzoom := Yzoom - 0.1
        else Yzoom := Yzoom + 0.1;
     Refresh
     end;
  If Key = Ord ('P') then begin
     If ssShift in Shift
        then begin
        If SkipPixels > 0 then SkipPixels := SkipPixels - 1
        end
        else SkipPixels := SkipPixels + 1;
     Refresh
     end;
  If Key = ord ('R') then begin
     If ssShift in Shift
        then begin
        If SkipRows > 0 then SkipRows := SkipRows - 1
        end
        else SkipRows := SkipRows + 1;
     Refresh
     end;
end;

end.

