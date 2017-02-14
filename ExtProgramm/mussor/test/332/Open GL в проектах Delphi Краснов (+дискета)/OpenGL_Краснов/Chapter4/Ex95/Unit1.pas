{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls,
  OpenGL;

type
  TfrmGL = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
  private
    DC : HDC;
    hrc : HGLRC;
    left, up, right : GLfloat;
    ctrlpoints : Array [0..16, 0..16, 0..2] of GLfloat ;
    texpts : Array [0..1, 0..1, 0..1] of GLfloat;
    procedure SetDCPixelFormat;
    procedure init_surface;
    procedure Init;
    procedure PrepareImage (FileName : String);
 public
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
 end;

var
  frmGL: TfrmGL;
  A : GLfloat = 0.0;
  step : GLfloat = 0.05;

implementation

{$R *.DFM}

{=======================================================================
Инициализация контрольных точек поверхности}
procedure TfrmGL.init_surface;
var
 x,y:integer;
begin
    For x:=0 to 16 do
     For y:=0 to 16 do begin
      ctrlpoints [x][y][0] := (x-8)/3;
      ctrlpoints [x][y][1] := (y-8)/3;
      ctrlpoints [x][y][2] := cos(sqrt(sqr(x)+sqr(y)) - Pi / 8 * a);
   end;
end;

{======================================================================
Подготовка текстуры}
procedure TfrmGL.PrepareImage (FileName : String);
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
  Bitmap.LoadFromFile (FileName);
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

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
  ambient : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 1.0);
  position : Array [0..3] of GLfloat = (0.0, 0.0, -12.0, 1.0);
  mat_diffuse : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 1.0);
  mat_specular : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 1.0);
  mat_shininess : GLfloat = 50.0;
begin
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_AUTO_NORMAL);
  glEnable(GL_NORMALIZE);

  // источник света
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, 1);
  glLightfv(GL_LIGHT0, GL_AMBIENT, @ambient);
  glLightfv(GL_LIGHT0, GL_POSITION, @position);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_specular);
  glMaterialfv(GL_FRONT, GL_SHININESS, @mat_shininess);
  glClearColor (0.0, 0.75, 1.0, 1.0);

  init_surface;
  PrepareImage ('..\earth.bmp');

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glEnable(GL_TEXTURE_2D);

  glMap2f(GL_MAP2_TEXTURE_COORD_2, 0, 1, 2, 2, 0, 1, 4, 2, @texpts);
  glEnable(GL_MAP2_TEXTURE_COORD_2);
  glMap2f(GL_MAP2_VERTEX_3, 0, 1, 3, 17, 0, 1, 51, 17, @ctrlpoints);
  glEnable(GL_MAP2_VERTEX_3);
  glMapGrid2f(20, 0.0, 1.0, 20, 0.0, 1.0);
end;

procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  left := 0.0;
  up := 0.0;
  right := 0.0;

  texpts [0][0][0] := 0.0;
  texpts [0][0][1] := 0.0;

  texpts [1][0][0] := 0.0;
  texpts [1][0][1] := 1.0;

  texpts [0][1][0] := 1.0;
  texpts [0][1][1] := 0.0;

  texpts [1][1][0] := 1.0;
  texpts [1][1][1] := 1.0;

  Init;
end;

{=======================================================================
Установка формата пикселей}
procedure TfrmGL.SetDCPixelFormat;
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;
begin
  FillChar(pfd, SizeOf(pfd), 0);

  pfd.dwFlags   := PFD_DRAW_TO_WINDOW or
                 PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;

  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  If (ClientWidth <= ClientHeight)
     then glOrtho(-4.0, 4.0, -4.0 * ClientHeight / ClientWidth, 4.0 * ClientHeight / ClientWidth, -4.0, 4.0)
     else glOrtho(-4.0 * ClientWidth / ClientHeight, 4.0 * ClientWidth / ClientHeight, -4.0, 4.0, -4.0, 4.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Обработка сообщения WM_PAINT, рисование окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix;
  glRotatef(left, 0.0, 1.0, 0.0);
  glRotatef(up, 1.0, 0.0, 0.0);
  glRotatef(right, 0.0, 0.0, 1.0);
  glEvalMesh2(GL_FILL, 0, 20, 0, 20);
  glPopMatrix;

  SwapBuffers(DC);

  EndPaint(Handle, ps);
end;

procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  wglMakeCurrent (0, 0);
  wglDeleteContext (hrc);
  ReleaseDC (Handle, DC);
  DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 Case Key of
    VK_ESCAPE : begin
                Close;
                Exit;
                end;
    VK_LEFT :   left := left + 5;
    VK_RIGHT:   right := right + 5;
    VK_UP :     up := up + 5;
 end;
end;

procedure TfrmGL.Timer1Timer(Sender: TObject);
begin
    A := A + 0.5;
    init_surface;

    glMap2f(GL_MAP2_VERTEX_3, 0, 1, 3, 17, 0, 1, 51, 17, @ctrlpoints);
    texpts [0][0][0] := texpts [0][0][0] - step;
    texpts [0][0][1] := texpts [0][0][1] - step;

    If (texpts [0][0][0] < -4.0) or (texpts [0][0][0] > 1.0)
       then step := - step;

    glMap2f(GL_MAP2_TEXTURE_COORD_2, 0, 1, 2, 2, 0, 1, 4, 2, @texpts);

    InvalidateRect(Handle, nil, False);
end;

end.
