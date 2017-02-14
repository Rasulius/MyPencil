{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, Forms, Classes, OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);

  private
    hrc: HGLRC;
    {позиция курсора}
    xpos : GLFloat;
    ypos : GLFloat;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
var
 i : 1..100;
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glViewPort (0, 0, ClientWidth, ClientHeight); // область вывода

 glClear (GL_COLOR_BUFFER_BIT);      // очистка буфера цвета

 glEnable (GL_LINE_STIPPLE);
 For i := 1 to 100 do begin
     glColor3f (random, random, random);
     glLineStipple (random (5), random ($FFFF));
     glBegin (GL_LINES);
       glVertex2f (xpos, ypos);
       glVertex2f (xpos + 0.5 * random * sin (random (360)),
                   ypos + 0.5 * random * cos (random (360)));
     glEnd;
 end;

 SwapBuffers(Canvas.Handle);         // содержимое буфера - на экран
 wglMakeCurrent(0, 0);
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
 SetDCPixelFormat(Canvas.Handle);
 hrc := wglCreateContext(Canvas.Handle);
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglDeleteContext(hrc);
end;

{=======================================================================
Обрабока движения курсора}
procedure TfrmGL.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  xpos := 2 * X / ClientWidth - 1;
  ypos := 2 * (ClientHeight - Y) / ClientHeight - 1;
  Refresh;  // перерисовка окна при каждом движении курсора
end;

end.

