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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC : HDC;
    hrc: HGLRC;
    Angle : GLfloat;
    wrkX, wrkY : Array [0..49] of GLfloat;
    TimerId : uint;  // идентификатор таймера
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

implementation

uses DGLUT, MMSystem;

{$R *.DFM}

procedure TimeProc(uTimerID, uMessage: UINT;dwUser, dw1, dw2: DWORD) stdcall;
begin
 // Каждый "тик" изменяется значение угла
 With frmGL do begin
      Angle := Angle + 0.1;
      If Angle >= 360.0 then Angle := 0.0;
      InvalidateRect(Handle, nil, False);
 end;
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
 ps : TPaintStruct;
 i : 0..49;
begin
 BeginPaint(Handle, ps);

 // очистка буфера цвета и буфера глубины
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 glPushMatrix;
 glRotatef(2 * Angle, 0.0, 1.0, 0.0);  // поворот на угол
 glRotatef(Angle, 0.0, 0.0, 1.0);  // поворот на угол
 {Цикл рисования шести кубиков}
 For i := 0 to 49 do begin
  glPushMatrix;                    // запомнили точку

  glTranslatef(wrkX [i], wrkY [i], 0.0);
  glRotatef(-7.2 * i, 0.0, 0.0, 1.0); // поворот кубика

  glScalef (1.0, 7.0, 1.0);
  glutSolidCube (0.1);

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
 i : 0..49;
begin
 DC := GetDC (0);
 SetDCPixelFormat(DC);
 hrc := wglCreateContext(DC);
 wglMakeCurrent(DC, hrc);
 For i := 0 to 49 do begin
      wrkX [i] := sin (Pi / 25 * i);
      wrkY [i] := cos (Pi / 25 * i);
 end;
 glClearColor (1.0, 1.0, 1.0, 1.0);

 glEnable(GL_DEPTH_TEST);// разрешаем тест глубины
 // Добавляем источник света 0
 glEnable(GL_LIGHTING); // разрешаем работу с освещенностью
 glEnable(GL_LIGHT0);   // включаем источник света 0
 glEnable (GL_COLOR_MATERIAL);
 glColor3f (0.0, 0.0, 1.0);
 Angle := 0;
 FormResize (nil);
 TimerID := timeSetEvent (2, 0, @TimeProc, 0, TIME_PERIODIC);
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 timeKillEvent(TimerID);
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC (Handle, DC);
 DeleteDC (DC);
 InvalidateRect (0, nil, False);
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluPerspective(18.0, ClientWidth / ClientHeight, 7.0, 13.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef(0.0, 0.0, -9.0);
 glRotatef(60.0, 1.0, 0.0, 1.0);
 InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
end;

end.

