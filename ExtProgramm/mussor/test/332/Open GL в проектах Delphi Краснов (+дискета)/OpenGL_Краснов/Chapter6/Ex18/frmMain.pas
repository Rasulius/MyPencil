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
    procedure FormResize(Sender: TObject);

  private
    DC : HDC;
    hrc: HGLRC;

    PText : pointer;
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
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix;
  glColor3f (1.0, 0.0, 0.0);
  glBegin (GL_TRIANGLES);
    glVertex3f (0.0, 0.0, 1.0);
    glVertex3f (2.0, -0.5, 1.0);
    glVertex3f (1.0, 1.0, 1.0);
  glEnd;

  glColor3f (0.0, 0.0, 1.0);
  glBegin (GL_TRIANGLES);
    glVertex3f (0.0, 0.0, -2.1);
    glVertex3f (1.0, 0.0, -2.1);
    glVertex3f (0.0, 6.0, -2.1);
  glEnd;

  glColor3f (1.0, 1.0, 0.0);
  glRasterPos3f(-0.4, 0.9, -2.0);
  glBitmap(bmWidth, bmHeight, 0, 0, 0, 0, PText);

  glPopMatrix;
  SwapBuffers (DC);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
 DC := GetDC (Handle);
 SetDCPixelFormat (DC);
 hrc := wglCreateContext(DC);
 wglMakeCurrent(DC, hrc);
 PText := ReadMonochrome('Text.bmp',bmWidth,bmHeight);
 glClearColor (0.5, 0.5, 0.75, 1.0);
 glPixelStorei(GL_UNPACK_ALIGNMENT,1);
 glEnable(GL_DEPTH_TEST); // можно удалить, буквы станут выше объектов
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
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 freemem(PText);
 ReleaseDC (Handle, DC);
 DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport (0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective (45.0, ClientWidth / ClientHeight, 1.0, 100.0);
  gluLookAt(0.0, 0.0, 0.0, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(0.0, 0.0, -5.0);
  glRotatef(-45.0, 1.0, 0.0, 0.0);
  glRotatef(45.0, 0.0, 1.0, 0.0);
  InvalidateRect(Handle, nil, False);
end;

end.

