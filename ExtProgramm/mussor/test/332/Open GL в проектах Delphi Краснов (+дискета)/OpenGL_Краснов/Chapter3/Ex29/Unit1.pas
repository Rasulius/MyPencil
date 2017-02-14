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
    ry : GLfloat;
    tx : GLfloat;
    procedure Detal;
  end;

var
  frmGL: TfrmGL;
  mode : (POINT, LINE, FILL) = LINE;

implementation

{$R *.DFM}

procedure TfrmGL.Detal;
begin
 glColor3f (0.0, 0.0, 1.0);
 glBegin (GL_POLYGON);
   glNormal3f (0, 1, 0);
   glVertex3f (6.875, 0, 0);
   glVertex3f (10, 0, 0);
   glVertex3f (10, 7.0606, 0);
   glVertex3f (8.2966, 8.764, 0);
   glVertex3f (6.8678, 8.764, 0);
   glVertex3f (6.8678, 4.5118, 0);
 glEnd;

 glBegin (GL_POLYGON);
   glVertex3f (3.1322, 4.5118, 0);
   glVertex3f (3.1424, 0, 0);
   glVertex3f (6.875, 0, 0);
   glVertex3f (6.8678, 4.5118, 0);
 glEnd;

 glBegin (GL_POLYGON);
   glVertex3f (3.1322, 4.5118, 0);
   glVertex3f (3.1322, 8.764, 0);
   glVertex3f (1.7034, 8.764, 0);
   glVertex3f (0, 7.0606, 0);
   glVertex3f (0, 0, 0);
   glVertex3f (3.1424, 0, 0);
 glEnd;

 glColor3f (1.0, 0.0, 0.0);
 glBegin (GL_POLYGON);
   glNormal3f (1.0, 0.0, 0.0);
   glVertex3f (10, 7.0606, 0);
   glVertex3f (10, 0, 0);
   glVertex3f (10, 0, -5);
   glVertex3f (10, 7.0606, -5);
 glEnd;

 glBegin (GL_POLYGON);
   glNormal3f (1.0, 1.0, 0.0);
   glVertex3f (8.2966, 8.764, 0);
   glVertex3f (10, 7.0606, 0);
   glVertex3f (10, 7.0606, -5);
   glVertex3f (8.2966, 8.764, -5);
 glEnd;

 glBegin (GL_POLYGON);
   glNormal3f (0.0, 1.0, 0.0);
   glVertex3f (6.8678, 8.764, 0);
   glVertex3f (8.2966, 8.764, 0);
   glVertex3f (8.2966, 8.764, -5);
   glVertex3f (6.8678, 8.764, -5);
 glEnd;

 glBegin (GL_POLYGON);
   glNormal3f (-1.0, 0.0, 0.0);
   glVertex3f (6.8678, 4.5118, 0);
   glVertex3f (6.8678, 8.764, 0);
   glVertex3f (6.8678, 8.764, -5);
   glVertex3f (6.8678, 4.5118, -5);
 glEnd;
 
 glBegin (GL_POLYGON);
   glNormal3f (0.0, 1.0, 0.0);
   glVertex3f (6.8678, 4.5118, -5);
   glVertex3f (3.1322, 4.5118, -5);
   glVertex3f (3.1322, 4.5118, 0);
   glVertex3f (6.8678, 4.5118, 0);
 glEnd;

 glBegin (GL_POLYGON);
   glNormal3f (1.0, 0.0, 0.0);
   glVertex3f (3.1322, 8.764, 0);
   glVertex3f (3.1322, 4.5118, 0);
   glVertex3f (3.1322, 4.5118, -5);
   glVertex3f (3.1322, 8.764, -5);
 glEnd;

 glBegin (GL_POLYGON);
   glNormal3f (0.0, 1.0, 0.0);
   glVertex3f (1.7034, 8.764, 0);
   glVertex3f (3.1322, 8.764, 0);
   glVertex3f (3.1322, 8.764, -5);
   glVertex3f (1.7034, 8.764, -5);
 glEnd;

 glBegin (GL_POLYGON);
   glNormal3f (-1.0, 1.0, 0);
   glVertex3f (0, 7.0606, 0);
   glVertex3f (1.7034, 8.764, 0);
   glVertex3f (1.7034, 8.764, -5);
   glVertex3f (0, 7.0606, -5);
 glEnd;

 glBegin (GL_POLYGON);
   glNormal3f (-1.0, 0.0, 0.0);
   glVertex3f (0, 7.0606, -5);
   glVertex3f (0, 0, -5);
   glVertex3f (0, 0, 0);
   glVertex3f (0, 7.0606, 0);
 glEnd;

 glBegin (GL_POLYGON);
    glNormal3f (0.0, -1.0, 0.0);
    glVertex3f (10, 0, 0);
    glVertex3f (6.875, 0, 0);
    glVertex3f (3.1424, 0, 0);
    glVertex3f (0, 0, 0);
    glVertex3f (0, 0, -5);
    glVertex3f (3.1424, 0, -5);
    glVertex3f (6.875, 0, -5);
    glVertex3f (10, 0, -5);
 glEnd;

 glColor3f (0.0, 0.0, 1.0);
 glBegin (GL_POLYGON);
    glNormal3f (0.0, 0.0, -1.0);
    glVertex3f (6.8678, 4.5118, -5);
    glVertex3f (6.8678, 8.764, -5);
    glVertex3f (8.2966, 8.764, -5);
    glVertex3f (10, 7.0606, -5);
    glVertex3f (10, 0, -5);
    glVertex3f (6.875, 0, -5);
 glEnd;

 glBegin (GL_POLYGON);
    glVertex3f (6.8678, 4.5118, -5);
    glVertex3f (6.875, 0, -5);
    glVertex3f (3.1424, 0, -5);
    glVertex3f (3.1322, 4.5118, -5);
 glEnd;

 glBegin (GL_POLYGON);
    glVertex3f (0, 7.0606, -5);
    glVertex3f (1.7034, 8.764, -5);
    glVertex3f (3.1322, 8.764, -5);
    glVertex3f (3.1322, 4.5118, -5);
    glVertex3f (3.1424, 0, -5);
    glVertex3f (0, 0, -5);
 glEnd;
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);      // очистка буфера цвета

 glPushMatrix;
 glScalef (0.3, 0.3, 0.3);

 glRotatef (ry, 0.0, 1.0, 0.0);
 glTranslatef (tx, 0.0, 0.0);

 case mode of
  POINT : glPolygonMode (GL_FRONT_AND_BACK, GL_POINT);
  LINE  : glPolygonMode (GL_FRONT_AND_BACK, GL_LINE);
  FILL  : glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
 end;

 Detal;
 glPopMatrix;
 
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
 glLineWidth (1.5);
 glEnable (GL_LIGHTING);
 glEnable (GL_LIGHT0);
 glEnable (GL_DEPTH_TEST);
 glEnable (GL_COLOR_MATERIAL);

 ry := 0.0;
 tx := 0.0;
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
 If Key = VK_LEFT then begin
    ry := ry + 2.0;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_RIGHT then begin
    ry := ry - 2.0;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_UP then begin
    tx := tx - 0.1;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_DOWN then begin
    tx := tx + 0.1;
    InvalidateRect(Handle, nil, False);
 end;

 If Key = 49 then begin
    mode := POINT;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = 50 then begin
    mode := LINE;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = 51 then begin
    mode := FILL;
    InvalidateRect(Handle, nil, False);
 end;

end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode (GL_PROJECTION);
 glLoadIdentity;
 glFrustum (-1, 1, -1, 1, 2, 9);
 glMatrixMode (GL_MODELVIEW);
 glLoadIdentity;

 // этот фрагмент нужен для придания трёхмерности
 glTranslatef(0.0, -1.0, -6.0);   // перенос объекта - ось Z
 glRotatef(30.0, 1.0, 0.0, 0.0); // поворот объекта - ось X
 glRotatef(70.0, 0.0, 1.0, 0.0); // поворот объекта - ось Y

 InvalidateRect(Handle, nil, False);
end;


end.

