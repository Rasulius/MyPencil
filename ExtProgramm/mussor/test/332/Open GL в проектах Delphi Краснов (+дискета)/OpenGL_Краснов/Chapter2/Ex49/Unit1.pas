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

function GetError : String;
begin
 Case glGetError of
    GL_INVALID_ENUM  : Result := 'Неверный аргумент!';
    GL_INVALID_VALUE : Result := 'Неверное значение аргумента!';
    GL_INVALID_OPERATION : Result := 'Неверная операция!';
    GL_STACK_OVERFLOW : Result := 'Переполнение стека!';
    GL_STACK_UNDERFLOW : Result := 'Потеря значимости стека!';
    GL_OUT_OF_MEMORY : Result := 'Не хватает памяти!';
    GL_NO_ERROR : Result := 'Нет ошибок.';
 end;
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glViewPort (0, 0, ClientWidth, ClientHeight); // область вывода

 glClearColor (0.5, 0.5, 0.75, 1.0); // цвет фона
 glClear (GL_COLOR_BUFFER_BIT);      // очистка буфера цвета

 glPointSize (20);                   // размер точек
 glColor3f (1.0, 0.0, 0.5);          // текущий цвет примитивов
 glBegin (GL_POINT);                 // открываем командную скобку
   glVertex2f (-1, -1);
   glVertex2f (-1, 1);
   glVertex2f (0, 0);
   glVertex2f (1, -1);
   glVertex2f (1, 1);
 glEnd;                              // закрываем командную скобку

 Caption := GetError;

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

end.

