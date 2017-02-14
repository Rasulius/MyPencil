{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
 Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus,
 Controls, Dialogs, SysUtils,
 OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    hrc: HGLRC;

    PText: pointer;
    bmWidth, bmHeight:GLsizei;
    procedure SetDCPixelFormat (hdc : HDC);
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

function ReadMonochrome(const FilePath:string;var bmWidth,bmHeight:
  GLsizei): Pointer;
const
  szh = SizeOf(TBitmapFileHeader);
  szi = SizeOf(TBitmapInfoHeader);
var
  BmpFile: file;
  bfh: TBitmapFileHeader;
  bmi: TBitmapInfoHeader;
  siz,
  size: integer;
begin
  AssignFile(bmpfile,FilePath);
  Reset(bmpfile,1);
  size := FileSize(bmpfile) - szh - szi;
  BlockRead(bmpfile,bfh,szh);
  If Bfh.bfType<>$4D42 then
    raise EInvalidGraphic.Create('Invalid Bitmap');
  BlockRead(bmpfile,bmi,szi);
  With bmi do begin
    bmWidth := biWidth;
    bmHeight := biHeight;
    siz := biSizeImage;
  end;
  If size > siz then seek(bmpfile,szh+szi+size-siz);
  GetMem(Result, siz);
  BlockRead(bmpfile, Result^, siz);
  CloseFile(bmpfile)
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
  wglMakeCurrent(Canvas.Handle, hrc);
  glViewport (0, 0, ClientWidth, ClientHeight);

  glClearColor (0.5, 0.5, 0.75, 1.0);
  glClear(GL_COLOR_BUFFER_BIT);

  glBitmap(bmWidth, bmHeight, 0, 0, 0, 0, PText);

  SwapBuffers (Canvas.Handle);

  wglMakeCurrent(0, 0);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
 SetDCPixelFormat (Canvas.Handle);
 hrc := wglCreateContext(Canvas.Handle);
 glPixelStorei(GL_UNPACK_ALIGNMENT,1);
 PText := ReadMonochrome('Text.bmp', bmWidth, bmHeight);
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
 FreeMem(PText);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close
end;

end.

