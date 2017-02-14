{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
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
    dc : HDC;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
����������� ����}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 wglMakeCurrent(dc, hrc);

 glClearColor (0.5, 0.5, 0.75, 1.0); // ���� ����
 glClear (GL_COLOR_BUFFER_BIT);      // ������� ������ �����

 glPointSize (20);                   // ������ �����
 glColor3f (1.0, 0.0, 0.5);          // ������� ���� ����������
 glBegin (GL_POINTS);                // ��������� ��������� ������
   glVertex2f (-1, -1);
   glVertex2f (-1, 1);
   glVertex2f (0, 0);
   glVertex2f (1, -1);
   glVertex2f (1, 1);
 glEnd;                              // ��������� ��������� ������

 SwapBuffers(dc);         // ���������� ������ - �� �����
 wglMakeCurrent(0, 0);
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
 dc := GetDC (0);
 SetDCPixelFormat(dc);
 hrc := wglCreateContext(dc);
end;

{=======================================================================
����� ������ ����������}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglDeleteContext(dc);
 InvalidateRect (0, nil, False);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close
end;

end.

