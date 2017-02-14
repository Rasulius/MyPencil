{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    hrc: HGLRC;  
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
const
 Level = 15;    // уровень детализации
 radius = 0.4;  // радиус отверстия
var
 i : 0 .. Level - 1;
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glViewPort (0, 0, ClientWidth, ClientHeight);

 glClearColor (1.0, 1.0, 1.0, 1.0);
 glClear (GL_COLOR_BUFFER_BIT);
 glColor3f(0.0, 0.0, 0.0);

 glBegin(GL_QUAD_STRIP);
 // верхняя четверть
 For i := 0 to Level - 1 do begin
    glVertex2f(radius * sin (Pi * i / (2 * Level) - Pi /4),
               radius * cos (Pi * i / (2 * Level) - Pi /4));
    glVertex2f(i / Level - 0.5, 0.5);
    glVertex2f(radius * sin (Pi * (i + 1) / (2 * Level) - Pi /4),
               radius * cos (Pi * (i + 1) / (2 * Level) - Pi /4));
    glVertex2f((i + 1) / Level - 0.5, 0.5);
 end;
 glEnd;

 // правая четверть
 glBegin(GL_QUAD_STRIP);
 For i := 0 to Level - 1 do begin
    glVertex2f(radius * sin (Pi * i / (2 * Level) + Pi / 4),
               radius * cos (Pi * i / (2 * Level) + Pi / 4));
    glVertex2f(0.5, 0.5 - i / Level);
    glVertex2f(radius * sin (Pi * (i + 1) / (2 * Level) + Pi / 4),
               radius * cos (Pi * (i + 1) / (2 * Level) + Pi / 4));
    glVertex2f(0.5, 0.5 - (i + 1)/ Level);
 end;
 glEnd;

 // левая четверть
 glBegin(GL_QUAD_STRIP);
 For i := 0 to Level - 1 do begin
    glVertex2f(radius * sin (Pi * i / (2 * Level) - 3 * Pi / 4 ),
               radius * cos (Pi * i / (2 * Level) - 3 * Pi / 4));
    glVertex2f(-0.5, i / Level - 0.5);
    glVertex2f(radius * sin (Pi * (i + 1) / (2 * Level) - 3 * Pi / 4 ),
               radius * cos (Pi * (i + 1) / (2 * Level) - 3 * Pi / 4));
    glVertex2f(-0.5, (i + 1) / Level - 0.5);
 end;
 glEnd;

 // нижняя четверть
 glBegin(GL_QUAD_STRIP);
 For i := 0 to Level - 1 do begin
    glVertex2f(radius * sin (Pi * i / (2 * Level) + 3 * Pi / 4 ),
               radius * cos (Pi * i / (2 * Level) + 3 * Pi / 4));
    glVertex2f(0.5 - i / Level, -0.5);
    glVertex2f(radius * sin (Pi * (i + 1) / (2 * Level) + 3 * Pi / 4),
               radius * cos (Pi * (i + 1) / (2 * Level) + 3 * Pi / 4));
    glVertex2f(0.5 - (i + 1) / Level, -0.5);
 end;
 glEnd;

 SwapBuffers(Canvas.Handle);        // содержимое буфера - на экран
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

end.

