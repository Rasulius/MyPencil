{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls,
  OpenGL;

type
  TfrmMain = class(TForm)
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
    procedure PrepareImage;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmMain: TfrmMain;
  Angle : GLfloat = 0;
  time : LongInt;

implementation

uses DGLUT;

{$R *.DFM}

{=======================================================================
Инициализация}
procedure TfrmMain.Init;
const
 light_diffuse : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 0.0);
 light_specular : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 0.0);
 mat_specular : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 1.0);
 lmodel_ambient : Array [0..3] of GLfloat = (0.0, 0.0, 0.0, 0.0);
 mat_shininess : GLfloat = 50.0;
begin
 glEnable(GL_DEPTH_TEST);
 glLightfv(GL_LIGHT0, GL_DIFFUSE, @light_diffuse);
 glLightfv(GL_LIGHT0, GL_SPECULAR, @light_specular);
 glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, @mat_specular);
 glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, @mat_shininess);
 glColorMaterial(GL_FRONT_AND_BACK,GL_DIFFUSE);
 glEnable(GL_COLOR_MATERIAL);
 glEnable(GL_LIGHT0);
 glEnable(GL_LIGHTING);
 glColor3f(1.0, 1.0, 0.0);
 PrepareImage;
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
end;

{=======================================================================
Перерисовка окна}
procedure TfrmMain.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glMatrixMode(GL_PROJECTION);
  glPushMatrix;
  glLoadIdentity;
  glOrtho(-50.0,50.0,-50.0,50.0,200.0,300.0);
  glMatrixMode(GL_MODELVIEW);
  // без записи в буфер глубины
  glDepthMask(FALSE);
  glEnable(GL_TEXTURE_2D);
  glBegin(GL_QUADS);
    glNormal3f(0.0,0.0,1.0);
    glTexCoord2f(0.0,0.0);
    glVertex3f(0.0,0.0,0.0);
    glTexCoord2f(1.0,0.0);
    glVertex3f(100.0,0.0,0.0);
    glTexCoord2f(1.0,1.0);
    glVertex3f(100.0,100.0,0.0);
    glTexCoord2f(0.0,1.0);
    glVertex3f(0.0,100.0,0.0);
  glEnd;
  glDisable(GL_TEXTURE_2D);
  glDepthMask(TRUE);
  glMatrixMode(GL_PROJECTION);
  glPopMatrix;
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix;
    glTranslatef(50.0, 50.0, 150.0);
    glRotatef(Angle, 1.0, 1.0, 0.0);
    glRotatef(Angle / (random (1) + 1), 0.0, 0.0, 1.0);
    glutSolidIcosahedron;
  glPopMatrix;

 SwapBuffers(DC);
 EndPaint(Handle, ps);

 Angle := Angle + 0.25 * (GetTickCount - time) * 360 / 1000;
 If Angle >= 360.0 then Angle := 0.0;
 time := GetTickCount;
 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmMain.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 glFrustum(-1.0, 1.0, -1.0, 1.0, 50.0, 300.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef(-50.0, -50.0, -250.0);
 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmMain.FormDestroy(Sender: TObject);
begin
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC(Handle, DC);
 DeleteDC(DC);
end;

{=======================================================================
Создание окна}
procedure TfrmMain.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  Init;
  time := GetTickCount;
end;

{=======================================================================
Обработка нажатия клавиши}
procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close
end;

{=======================================================================
Устанавливаем формат пикселей}
procedure TfrmMain.SetDCPixelFormat;
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

{======================================================================
Подготовка текстуры}
procedure TfrmMain.PrepareImage;
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
  Bitmap.LoadFromFile ('..\earth.bmp');
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
      GetDIBits (MemDC, Bitmap.Handle, 0, biHeight, Data, BMInfo, DIB_RGB_COLORS);
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

end.


