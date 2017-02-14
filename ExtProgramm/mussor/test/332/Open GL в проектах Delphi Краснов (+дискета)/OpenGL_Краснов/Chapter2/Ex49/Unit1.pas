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
    GL_INVALID_ENUM  : Result := '�������� ��������!';
    GL_INVALID_VALUE : Result := '�������� �������� ���������!';
    GL_INVALID_OPERATION : Result := '�������� ��������!';
    GL_STACK_OVERFLOW : Result := '������������ �����!';
    GL_STACK_UNDERFLOW : Result := '������ ���������� �����!';
    GL_OUT_OF_MEMORY : Result := '�� ������� ������!';
    GL_NO_ERROR : Result := '��� ������.';
 end;
end;

{=======================================================================
��������� ��������}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glViewPort (0, 0, ClientWidth, ClientHeight); // ������� ������

 glClearColor (0.5, 0.5, 0.75, 1.0); // ���� ����
 glClear (GL_COLOR_BUFFER_BIT);      // ������� ������ �����

 glPointSize (20);                   // ������ �����
 glColor3f (1.0, 0.0, 0.5);          // ������� ���� ����������
 glBegin (GL_POINT);                 // ��������� ��������� ������
   glVertex2f (-1, -1);
   glVertex2f (-1, 1);
   glVertex2f (0, 0);
   glVertex2f (1, -1);
   glVertex2f (1, 1);
 glEnd;                              // ��������� ��������� ������

 Caption := GetError;

 SwapBuffers(Canvas.Handle);         // ���������� ������ - �� �����
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
 SetDCPixelFormat(Canvas.Handle);
 hrc := wglCreateContext(Canvas.Handle);
end;

{=======================================================================
����� ������ ����������}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglDeleteContext(hrc);
end;

end.

