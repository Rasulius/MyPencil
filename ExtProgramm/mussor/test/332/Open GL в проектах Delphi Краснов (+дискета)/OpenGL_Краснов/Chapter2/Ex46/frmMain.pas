{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Controls, SysUtils,
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

    RedScale, GreenScale, BlueScale : GLFloat;

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

  glPixelTransferf(GL_RED_SCALE, RedScale);
  glPixelTransferf(GL_GREEN_SCALE, GreenScale);
  glPixelTransferf(GL_BLUE_SCALE, BlueScale);

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

 RedScale := 1.0;
 GreenScale := 1.0;
 BlueScale := 1.0;
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
  If Key = Ord ('R') then
     begin
     If ssShift in Shift
        then RedScale := RedScale - 0.1
        else RedScale := RedScale + 0.1;
     Refresh
     end;
  If Key = Ord ('G') then
     begin
     If ssShift in Shift
        then GreenScale := GreenScale - 0.1
        else GreenScale := GreenScale + 0.1;
     Refresh
     end;
  If Key = Ord ('B') then
     begin
     If ssShift in Shift
        then BlueScale := BlueScale - 0.1
        else BlueScale := BlueScale + 0.1;
     Refresh
     end;
  If Key = VK_SPACE then begin
     RedScale := 1.0;
     GreenScale := 1.0;
     BlueScale := 1.0;
     Refresh;
  end;
  Caption := 'R=' + Format('%*.*f', [4, 1, RedScale])+
            ' G=' + Format('%*.*f', [4, 1, GreenScale])+
            ' B=' + Format('%*.*f', [4, 1, BlueScale]);
end;

end.

