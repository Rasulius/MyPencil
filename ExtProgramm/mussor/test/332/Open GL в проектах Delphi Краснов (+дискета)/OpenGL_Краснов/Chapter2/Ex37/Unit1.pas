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
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    hrc: HGLRC;
    mode : Boolean; // режим вывода объекта - сплошной или контурный
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glViewPort (0, 0, ClientWidth, ClientHeight);

 glClearColor (0.75, 0.75, 0.75, 1.0);
 glClear (GL_COLOR_BUFFER_BIT);

 glColor3f (0.0, 0.0, 0.75);

 // устанавливаем режим в зависимости от значения mode
 If mode
    then glPolygonMode (GL_FRONT_AND_BACK, GL_LINE)
    else glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);

 glBegin (GL_POLYGON);
   glEdgeFlag (TRUE);
   glVertex2f (-0.23678, 0.35118);
   glVertex2f (-0.23678, 0.7764);
   glVertex2f (-0.37966, 0.7764);
   glVertex2f (-0.55, 0.60606);
   glVertex2f (-0.55, -0.4);
   glEdgeFlag (FALSE);                     // эти вершины не включать
   glVertex2f (-0.23576, -0.4);
   glVertex2f (-0.23678, 0.35118);
   glEdgeFlag (TRUE);
   glVertex2f (-0.23576, -0.4);
   glEdgeFlag (FALSE);
   glVertex2f (0.1375, -0.4);
   glEdgeFlag (TRUE);
   glVertex2f (0.13678, 0.35118);
 glEnd;

 glBegin (GL_POLYGON);
   glVertex2f (0.1375, -0.4);
   glVertex2f (0.45, -0.4);
   glVertex2f (0.45, 0.60606);
   glVertex2f (0.27966, 0.7764);
   glVertex2f (0.13678, 0.7764);
   glEdgeFlag (FALSE);
   glVertex2f (0.13678, 0.35118);
   glEdgeFlag (TRUE);
 glEnd;

 SwapBuffers(Canvas.Handle);
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
 mode := True;
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglDeleteContext(hrc);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_SPACE then begin
    mode := not mode;
    Refresh;
 end;
 If Key = VK_ESCAPE then Close;
end;

end.

