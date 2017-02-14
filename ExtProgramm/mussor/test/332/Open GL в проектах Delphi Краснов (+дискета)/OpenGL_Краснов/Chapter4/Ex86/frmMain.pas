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
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC: HDC;
    hrc: HGLRC;
    Angle: GLUint;
    Bitmap: TBitmap;
    Bits: Array [0..63, 0..63, 0..2] of GLubyte;

    procedure SetDCPixelFormat;
    procedure BmpTexture;

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}


{**********************************************************************}
{***          ПРОЦЕДУРА ЗАГРУЗКИ И ИНИЦИАЛИЗАЦИИ ТЕКСТУРЫ           ***}
{**********************************************************************}
procedure TfrmGL.BmpTexture;
var
  i, j: Integer;
begin
   bitmap := TBitmap.Create;
   bitmap.LoadFromFile('gold.bmp'); // загрузка текстуры из файла

   {--- заполнение битового массива ---}
    For i := 0 to 63 do
      For j := 0 to 63 do begin
        bits [i, j, 0] := GetRValue(bitmap.Canvas.Pixels[i,j]);
        bits [i, j, 1] := GetGValue(bitmap.Canvas.Pixels[i,j]);
        bits [i, j, 2] := GetBValue(bitmap.Canvas.Pixels[i,j]);
    end;

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,
                 64, 64,     // здесь задается размер текстуры
                 0, GL_RGB, GL_UNSIGNED_BYTE, @Bits);
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
    glEnable(GL_TEXTURE_2D);
end;

{=======================================================================
Тик таймера}
procedure TfrmGL.TimerTimer(Sender: TObject);
begin
  Angle := (Angle + 4) mod 360;

  InvalidateRect(Handle, nil, False); // перерисовка региона (Windows API)
end;

{=======================================================================
Задаем формат пикселя}
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

{=======================================================================
Создание формы}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  Angle := 0;
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  glEnable(GL_DEPTH_TEST);// разрешаем тест глубины
  glEnable(GL_LIGHTING);  // разрешаем работу с освещенностью
  glEnable(GL_LIGHT0);    // включаем источник света 0
  BmpTexture;
  Timer.Enabled := True;
end;

{=======================================================================
Изменение размеров формы}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(30.0, ClientWidth / ClientHeight, 1.0, 9.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(0.0, 0.0, -8.0);
  glRotatef(30.0, 1.0, 0.0, 0.0);
end;

{=======================================================================
Рисование картинки, обработка сообщения WM_PAINT}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix;
  glRotatef(Angle, 1.0, 1.0, 0.0);
  glRotatef(Angle / (random (1) + 1), 0.0, 0.0, 1.0);

    glBegin (GL_QUAD_STRIP);
        glTexCoord2d (0.0, 1.0);
        glVertex3f (-1.0,  1.0, 1.0);  // 1
        glTexCoord2d (0.0, 0.0);
        glVertex3f (-1.0, -1.0, 1.0);  // 2
       	glTexCoord2d (1.0, 1.0);
        glVertex3f (1.0,  1.0, 1.0);   // 3
        glTexCoord2d (1.0, 0.0);
        glVertex3f (1.0, -1.0, 1.0);   // 4
      	glTexCoord2d (0.0, 1.0);
        glVertex3f (1.0, 1.0, -1.0);   // 5
	glTexCoord2d (0.0, 0.0);
        glVertex3f (1.0, -1.0, -1.0);  // 6
        glTexCoord2d (1.0, 1.0);
        glVertex3f (-1.0,  1.0, -1.0); // 7
        glTexCoord2d (1.0, 0.0);
        glVertex3f (-1.0, -1.0, -1.0); // 8
      	glTexCoord2d (0.0, 1.0);
        glVertex3f (-1.0,  1.0, 1.0);  // 9
        glTexCoord2d (0.0, 0.0);
        glVertex3f (-1.0, -1.0, 1.0);  // 10
    glEnd;

    glBegin (GL_QUADS);
        glTexCoord2d (1.0, 0.0);
        glVertex3f (-1.0, 1.0, 1.0);
	glTexCoord2d (1.0, 1.0);
        glVertex3f (1.0, 1.0, 1.0);
	glTexCoord2d (0.0, 1.0);
        glVertex3f (1.0, 1.0, -1.0);
        glTexCoord2d (0.0, 0.0);
        glVertex3f (-1.0, 1.0, -1.0);
    glEnd;

    glBegin (GL_QUADS);
      glTexCoord2d (1.0, 0.0);
      glVertex3f (-1.0, -1.0, 1.0);
      glTexCoord2d (1.0, 1.0);
      glVertex3f (1.0, -1.0, 1.0);
      glTexCoord2d (0.0, 1.0);
      glVertex3f (1.0, -1.0, -1.0);
      glTexCoord2d (0.0, 0.0);
      glVertex3f (-1.0, -1.0, -1.0);
    glEnd;
  glPopMatrix;

  SwapBuffers(DC);
  EndPaint(Handle, ps);
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  Timer.Enabled := False;
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close
end;

end.

