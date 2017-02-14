{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  OpenGL;

type
  TfrmGL = class(TForm)
    btnColor: TButton;
    ColorDialog1: TColorDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnColorClick(Sender: TObject);

  private
    hrc : HGLRC;
    R, G, B : GLFloat;
    procedure ColorToGL (c : TColor; var R, G, B : GLFloat);
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
������� ����� �� TColor � OpenGL}
procedure TfrmGL.ColorToGL (c : TColor; var R, G, B : GLFloat);
begin
 R := (c mod $100) / 255;
 G := ((c div $100) mod $100) / 255;
 B := (c div $10000) / 255;
end;

{=======================================================================
��������� ��������}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glClearColor (R, G, B, 1.0);        // ���� ����
 glClear (GL_COLOR_BUFFER_BIT);      // ������� ������ �����

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
 nPixelFormat := ChoosePixelFormat (hdc, @pfd);
 SetPixelFormat (hdc, nPixelFormat, @pfd);
end;

{=======================================================================
�������� �����}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
 SetDCPixelFormat(Canvas.Handle);
 hrc := wglCreateContext(Canvas.Handle);
 Randomize;
 R := random;
 G := random;
 B := random;
end;

{=======================================================================
����� ������ ����������}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglDeleteContext(hrc);
end;

procedure TfrmGL.btnColorClick(Sender: TObject);
begin
 If ColorDialog1.Execute then begin
    ColorToGL (ColorDialog1.Color, R, G, B);
    Refresh;
 end;
end;

end.

