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
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC : HDC;
    hrc: HGLRC;
    Angle : GLfloat;
    wrkX, wrkY : Array [0..5] of GLfloat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

implementation

uses DGLUT;

{$R *.DFM}

{=======================================================================
Перерисовка окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
 ps : TPaintStruct;
 i : 0..5;
begin
 BeginPaint(Handle, ps);

 // очистка буфера цвета и буфера глубины
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 glPushMatrix;
 glRotatef(Angle, 0.0, 0.0, 1.0);  // поворот на угол
 {Цикл рисования шести кубиков}
 For i := 0 to 5 do begin
  glPushMatrix;                    // запомнили точку

  glTranslatef(wrkX [i], wrkY [i], 0.0);
  glRotatef(-60 * i, 0.0, 0.0, 1.0); // поворот кубика

  glutSolidCube (0.5);

  glPopMatrix;                     // вернулись в точку
 end;

 glPopMatrix;

 SwapBuffers(DC);

 EndPaint(Handle, ps);
end;


{=======================================================================
Формат пикселя}
procedure SetDCPixelFormat (hdc : HDC);
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
Создание формы}
procedure TfrmGL.FormCreate(Sender: TObject);
var
 i : 0..5;
begin
 DC := GetDC (Handle);
 SetDCPixelFormat(DC);
 hrc := wglCreateContext(DC);
 wglMakeCurrent(DC, hrc);
 For i := 0 to 5 do begin
      wrkX [i] := sin (Pi / 3 * i);
      wrkY [i] := cos (Pi / 3 * i);
 end;
 glClearColor (1.0, 1.0, 1.0, 1.0);

 glEnable(GL_DEPTH_TEST);// разрешаем тест глубины
 // Добавляем источник света 0
 glEnable(GL_LIGHTING); // разрешаем работу с освещенностью
 glEnable(GL_LIGHT0);   // включаем источник света 0
 glEnable (GL_COLOR_MATERIAL);
 glColor3f (0.0, 0.0, 1.0);
 Angle := 0;
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC (Handle, DC);
 DeleteDC (DC);
end;

procedure TfrmGL.Timer1Timer(Sender: TObject);
begin
 // Каждый "тик" изменяется значение угла
 Angle := Angle + 1;
 If Angle >= 60.0 then Angle := 0.0;
 InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewPort (0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluPerspective(18.0, ClientWidth / ClientHeight, 7.0, 10.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef(0.0, 0.0, -9.0);
 glRotatef(60.0, 1.0, 0.0, 1.0);
 InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close
end;

end.

