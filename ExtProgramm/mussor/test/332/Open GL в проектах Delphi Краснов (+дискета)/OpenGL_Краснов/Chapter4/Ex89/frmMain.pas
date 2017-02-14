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
    procedure Init;
    procedure SetDCPixelFormat;
    procedure PrepareImage(bmap: string);
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
  Earth = 1;

var
  frmGL: TfrmGL;
  Angle : GLfloat = 0;
  time : LongInt;

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
  Data, DataA : PPixelArray;
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
    GetMem (DataA, ImageSize * 4);
    try
      GetDIBits (MemDC, Bitmap.Handle, 0, biHeight, Data, BMInfo, DIB_RGB_COLORS);
      For I := 0 to ImageSize - 1 do begin
          Temp := Data [I * 3];
          Data [I * 3] := Data [I * 3 + 2];
          Data [I * 3 + 2] := Temp;
      end;

      For I := 0 to ImageSize - 1 do begin
          DataA [I * 4] := Data [I * 3];
          DataA [I * 4 + 1] := Data [I * 3 + 1];
          DataA [I * 4 + 2] := Data [I * 3 + 2];
          If (Data [I * 3 + 2] > 50) and
             (Data [I * 3 + 1] < 200) and
             (Data [I * 3] < 200)
             then DataA [I * 4 + 3] := 27
             else DataA [I * 4 + 3] := 255;
      end;

      glTexImage2d(GL_TEXTURE_2D, 0, 3, biWidth,
                   biHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, DataA);
     finally
      FreeMem (Data);
      FreeMem (DataA);
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
var
 Quadric : GLUquadricObj;
begin
 Quadric := gluNewQuadric;
 gluQuadricTexture (Quadric, TRUE);

 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

 glEnable(GL_TEXTURE_2D);

 glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

 glNewList (Earth, GL_COMPILE);
   prepareImage ('..\earth.bmp');
    glEnable (GL_BLEND);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_FRONT);
    gluSphere (Quadric, 1.0, 24, 24);
    glCullFace(GL_BACK);
    gluSphere (Quadric, 1.0, 24, 24);
    glDisable(GL_CULL_FACE);
    glDisable (GL_BLEND);
 glEndList;

 gluDeleteQuadric (Quadric);

 glEnable(GL_DEPTH_TEST);
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
 glFrustum( -1.0, 1.0, -1.0, 1.0, 5.0, 50.0 );
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
  glDeleteLists (Earth, 1);
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


