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
    procedure FormResize(Sender: TObject);

  private
    DC : HDC;
    hrc: HGLRC;
    vLeft, vRight, vBottom, vTop, vNear, vFar : GLFloat;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 glClear (GL_COLOR_BUFFER_BIT);      // очистка буфера цвета

 // рисование шести сторон куба
 glBegin(GL_QUADS);
   glVertex3f(1.0, 1.0, 1.0);
   glVertex3f(-1.0, 1.0, 1.0);
   glVertex3f(-1.0, -1.0, 1.0);
   glVertex3f(1.0, -1.0, 1.0);
 glEnd;

 glBegin(GL_QUADS);
   glVertex3f(1.0, 1.0, -1.0);
   glVertex3f(1.0, -1.0, -1.0);
   glVertex3f(-1.0, -1.0, -1.0);
   glVertex3f(-1.0, 1.0, -1.0);
 glEnd;

 glBegin(GL_QUADS);
   glVertex3f(-1.0, 1.0, 1.0);
   glVertex3f(-1.0, 1.0, -1.0);
   glVertex3f(-1.0, -1.0, -1.0);
   glVertex3f(-1.0, -1.0, 1.0);
 glEnd;

 glBegin(GL_QUADS);
   glVertex3f(1.0, 1.0, 1.0);
   glVertex3f(1.0, -1.0, 1.0);
   glVertex3f(1.0, -1.0, -1.0);
   glVertex3f(1.0, 1.0, -1.0);
 glEnd;

 glBegin(GL_QUADS);
   glVertex3f(-1.0, 1.0, -1.0);
   glVertex3f(-1.0, 1.0, 1.0);
   glVertex3f(1.0, 1.0, 1.0);
   glVertex3f(1.0, 1.0, -1.0);
 glEnd;

 glBegin(GL_QUADS);
   glVertex3f(-1.0, -1.0, -1.0);
   glVertex3f(1.0, -1.0, -1.0);
   glVertex3f(1.0, -1.0, 1.0);
   glVertex3f(-1.0, -1.0, 1.0);
 glEnd;

 SwapBuffers(DC);
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
 glClearColor (0.5, 0.5, 0.75, 1.0); // цвет фона
 glColor3f (1.0, 0.0, 0.5);          // текущий цвет примитивов
 vLeft := -1;
 vRight := 1;
 vBottom := -1;
 vTop := 1;
 vNear := 3;
 vFar := 10;
 glPolygonMode (GL_FRONT_AND_BACK, GL_LINE);
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
 If Key = VK_SPACE then begin
    If ssShift in Shift then begin
       vLeft := vLeft - 0.1;
       vRight := vRight + 0.1;
       vBottom := vBottom - 0.1;
       vTop := vTop + 0.1;
       end
       else begin
       vLeft := vLeft + 0.1;
       vRight := vRight - 0.1;
       vBottom := vBottom + 0.1;
       vTop := vTop - 0.1;
    end;
 FormResize(nil);
 end;
 If Key = VK_LEFT then begin
    If ssShift in Shift
       then vLeft := vLeft - 0.1
       else vLeft := vLeft + 0.1;
 FormResize(nil);
 end;
 If Key = VK_RIGHT then begin
    If ssShift in Shift
       then vRight := vRight - 0.1
       else vRight := vRight + 0.1;
 FormResize(nil);
 end;
 If Key = VK_DOWN then begin
    If ssShift in Shift
       then vBottom := vBottom - 0.1
       else vBottom := vBottom + 0.1;
 FormResize(nil);
 end;
 If Key = VK_UP then begin
    If ssShift in Shift
       then vTop := vTop - 0.1
       else vTop := vTop + 0.1;
 FormResize(nil);
 end;
 If Key = VK_INSERT then begin
    If ssShift in Shift
       then vNear := vNear - 0.1
       else vNear := vNear + 0.1;
 FormResize(nil);
 end;
 If Key = VK_DELETE then begin
    If ssShift in Shift
       then vFar := vFar - 0.1
       else vFar := vFar + 0.1;
 FormResize(nil);
 end;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glLoadIdentity;
 glFrustum (vLeft, vRight, vBottom, vTop, vNear, vFar);    // задаем перспективу
 // этот фрагмент нужен для придания трёхмерности
 glTranslatef(0.0, 0.0, -8.0);   // перенос объекта - ось Z
 glRotatef(30.0, 1.0, 0.0, 0.0); // поворот объекта - ось X
 glRotatef(70.0, 0.0, 1.0, 0.0); // поворот объекта - ось Y

 InvalidateRect(Handle, nil, False);
end;

end.

