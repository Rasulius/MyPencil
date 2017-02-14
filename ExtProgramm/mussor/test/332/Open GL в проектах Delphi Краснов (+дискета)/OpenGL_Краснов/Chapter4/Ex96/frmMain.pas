{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls,
  OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    DC: HDC;
    hrc: HGLRC;
    Pixels : Array [0..127, 0..127, 0..2] of GLUbyte;
    procedure Init;
    procedure SetDCPixelFormat;
    procedure PrepareImage(bmap: string);
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
  Earth = 1;
  Zoom = 2;

var
  frmGL: TfrmGL;
  Angle : GLfloat = 0;
  time : LongInt;
  AddX : GLfloat = 0.0;
  AddZ : GLfloat = 0.0;
  posX : GLint = 135;
  posY : GLint = 135;

implementation

{$R *.DFM}

{======================================================================
Подготовка текстуры}
procedure TfrmGL.PrepareImage(bmap: string);
type
  PPixelArray = ^TPixelArray;
  TPixelArray = array [0..0] of Byte;
var
  Bitmap : TBitmap;
  Data : PPixelArray;
  BMInfo : TBitmapInfo;
  I, ImageSize : Integer;
  Temp : Byte;
  MemDC : HDC;
begin
  Bitmap := TBitmap.Create;
  Bitmap.LoadFromFile (bmap);
  with BMinfo.bmiHeader do begin
    FillChar (BMInfo, SizeOf(BMInfo), 0);
    biSize := sizeof (TBitmapInfoHeader);
    biBitCount := 24;
    biWidth := Bitmap.Width;
    biHeight := Bitmap.Height;
    ImageSize := biWidth * biHeight;
    biPlanes := 1;
    biCompression := BI_RGB;
    MemDC := CreateCompatibleDC (0);
    GetMem (Data, ImageSize * 3);
    try
      GetDIBits (MemDC, Bitmap.Handle, 0, biHeight, Data,
                 BMInfo, DIB_RGB_COLORS);
      For I := 0 to ImageSize - 1 do begin
          Temp := Data [I * 3];
          Data [I * 3] := Data [I * 3 + 2];
          Data [I * 3 + 2] := Temp;
      end;
      glTexImage2d(GL_TEXTURE_2D, 0, 3, biWidth,
                   biHeight, 0, GL_RGB, GL_UNSIGNED_BYTE, Data);
    finally
      FreeMem (Data);
      DeleteDC (MemDC);
      Bitmap.Free;
    end;
  end;
end;

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
 LightPos : Array [0..3] of GLFloat = (10.0, 10.0, 0.0, 1.0);
 eqn : Array [0..3] of GLdouble  = (0.0, -1.0, 0.0, 0.0);
var
 Quadric : GLUquadricObj;
begin
 glEnable(GL_LIGHTING);
 glEnable(GL_LIGHT0);
 glLightfv(GL_LIGHT0, GL_POSITION, @LightPos);

 Quadric := gluNewQuadric;
 gluQuadricTexture (Quadric, TRUE);

 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

 glNewList (Earth, GL_COMPILE);
   prepareImage ('..\earth.bmp');
   glEnable(GL_TEXTURE_2D);
   gluSphere (Quadric, 1.0, 24, 24);
   glDisable(GL_TEXTURE_2D);
 glEndList;

 glNewList (Zoom, GL_COMPILE);
   glClipPlane (GL_CLIP_PLANE0, @eqn);
   glEnable (GL_CLIP_PLANE0);
   glScalef (1.0, 0.15, 1.0);
   glEnable(GL_TEXTURE_2D);
   gluSphere (Quadric, 0.5, 24, 24);
   glDisable(GL_TEXTURE_2D);
   glDisable (GL_CLIP_PLANE0);
 glEndList;

 gluDeleteQuadric (Quadric);

 glEnable(GL_DEPTH_TEST);
 glClearColor (0.25, 0.0, 0.75, 1.0);
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT );

  glPushMatrix;
     glRotatef (-10, 0.0, 1.0, 0.0);
     glRotatef (Angle, 0.0, 0.0, 1.0);
     glCallList(Earth);
  glPopMatrix;

  glReadPixels (posX, posY, 128, 128, GL_RGB, GL_UNSIGNED_BYTE, @Pixels);

  glPushMatrix;
     glTranslatef (AddX, -5.0, AddZ);
     glTexImage2d(GL_TEXTURE_2D, 0, 3, 128, 128,
                  0, GL_RGB, GL_UNSIGNED_BYTE, @Pixels);
     glCallList(Zoom);
  glPopMatrix;

  SwapBuffers(DC);
  EndPaint(Handle, ps);

  Angle := Angle + 0.25 * (GetTickCount - time) * 360 / 1000;
  If Angle >= 360.0 then Angle := 0.0;
  time := GetTickCount;

  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  Init;
  time := GetTickCount;
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight );
 glMatrixMode( GL_PROJECTION );
 glLoadIdentity;
 glFrustum( -1.0, 1.0, -1.0, 1.0, 5.0, 1500.0 );
 glMatrixMode( GL_MODELVIEW );
 glLoadIdentity;
 glTranslatef( 0.0, 0.0, -12.0 );
 glRotatef(-90.0, 1.0, 0.0, 0.0);
 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  glDeleteLists (Earth, 2);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

{=======================================================================
Обработка нажатия клавиши}
procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
  If Key = VK_LEFT then begin
     AddX := AddX - 0.1;
     posX := posX - 9;
  end;
  If Key = VK_RIGHT then begin
     AddX := AddX + 0.1;
     posX := posX + 9;
  end;
  If Key = VK_UP then begin
     AddZ := AddZ + 0.1;
     posY := posY + 9;
  end;
  If Key = VK_DOWN then begin
     AddZ := AddZ - 0.1;
     posY := posY - 9;     
  end;
end;

{=======================================================================
Устанавливаем формат пикселей}
procedure TfrmGL.SetDCPixelFormat;
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;

begin
  FillChar(pfd, SizeOf(pfd), 0);

  pfd.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;

  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;


end.


