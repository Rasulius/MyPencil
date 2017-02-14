{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus,
  OpenGL;

type
  TfrmGL = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure N1Click(Sender: TObject);

  private
    DC : HDC;
    hrc: HGLRC;
  public
    eyex, eyey, eyez,
    centerx, centery, centerz,
    upx, upy, upz : GLdouble;

  end;

var
  frmGL: TfrmGL;

implementation

uses Unit2;

{$R *.DFM}

{=======================================================================
����������� ����}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 glClear (GL_COLOR_BUFFER_BIT);      // ������� ������ �����

 // ��������� ����� ������ ����
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
������ �������}
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
�������� �����}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
 DC := GetDC (Handle);
 SetDCPixelFormat (DC);
 hrc := wglCreateContext (DC);
 wglMakeCurrent (DC, hrc);
 glClearColor (0.5, 0.5, 0.75, 1.0); // ���� ����
 glColor3f (1.0, 0.0, 0.5);          // ������� ���� ����������
 glPolygonMode (GL_FRONT_AND_BACK, GL_LINE);
 eyex := 2.7;
 eyey := 2.0;
 eyez := 2.5;
 centerx := 0.4;
 centery := 0.5;
 centerz := 0.5;
 upx := 0;
 upy := 0;
 upz := 1;
end;

{=======================================================================
����� ������ ����������}
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
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glLoadIdentity;
 gluPerspective (50.0, ClientWidth / ClientHeight, 2.0, 10.0);
 gluLookAt (eyex, eyey, eyez,
            centerx, centery, centerz,
            upx, upy, upz);
 InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.N1Click(Sender: TObject);
begin
 Form2.Show
end;

end.

