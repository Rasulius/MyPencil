{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpenGL, ExtCtrls, StdCtrls;

type
  TfrmGL = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);

  private
    DC : HDC;
    hrc: HGLRC;
    newCount, frameCount, lastCount : LongInt;
    fpsRate : GLfloat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

const
  POINT_COUNT = 2000;

var
  points: Array [0..POINT_COUNT - 1] of TGLArrayf3;
  motion: Array [0..POINT_COUNT - 1] of TGLArrayf3;

procedure Reset;
var
  i : 0..POINT_COUNT - 1;
begin
  For i := 0 to POINT_COUNT - 1 do begin
    points[i][0] := 0.0;
    points[i][1] := -0.5;
    points[i][2] := 0.0;
    motion[i][0] := (Random - 0.5) / 20;
    motion[i][1] := Random / 7 + 0.01;
    motion[i][2] := (Random - 0.5) / 20;
  end;
end;

procedure UpdatePOINT(i: Word);
begin
  points[i][0] := points[i][0] + motion[i][0];
  points[i][1] := points[i][1] + motion[i][1];
  points[i][2] := points[i][2] + motion[i][2];

  If points[i][1] < -0.75 then begin
    points[i][0] := 0.0;
    points[i][1] := -0.5;
    points[i][2] := 0.0;
    motion[i][0] := (Random - 0.5) / 20;
    motion[i][1] := Random / 7 + 0.01;
    motion[i][2] := (Random - 0.5) / 20;
    end
    else motion[i][1] := motion[i][1] - 0.01;
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
 ps : TPaintStruct;
 i : GLUint;
begin
 BeginPaint(Handle, ps);

 glClear(GL_COLOR_BUFFER_BIT);

 glBegin(GL_POINTS);
    For i := 0 to POINT_COUNT - 1 do begin
      UpdatePOINT(i);
      glVertex3fv(@points[i]);
    end;
 glEnd;

 SwapBuffers(DC);

 EndPaint(Handle, ps);

 // определяем и выводим количество кадров в секунду
 newCount := GetTickCount;
 Inc(frameCount);
 If (newCount - lastCount) > 1000 then  begin // прошла секунда
    fpsRate := frameCount * 1000 / (newCount - lastCount);
    Caption := 'FPS - ' + FloatToStr (fpsRate);
    lastCount := newCount;
    frameCount := 0;
 end;
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
begin
 DC := GetDC (Handle);
 SetDCPixelFormat(DC);
 hrc := wglCreateContext(DC);
 wglMakeCurrent(DC, hrc);

 lastCount := GetTickCount;
 frameCount := 0;

 glPointSize(2);

 Reset;

 glColor3f(0, 0.5, 1);
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

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
  If Key = VK_SPACE then Reset;
end;

procedure TfrmGL.Timer1Timer(Sender: TObject);
begin
 InvalidateRect(Handle, nil, False);
end;

end.

