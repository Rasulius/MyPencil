{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;
interface

uses
  Windows, Messages, Forms, Dialogs, Classes, Controls, ExtCtrls, StdCtrls,
  OpenGL;

type
  TfrmGL = class(TForm)
    Panel1: TPanel;
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    dc : HDC;
    hrc: HGLRC;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
Рисование окна}
procedure TfrmGL.FormPaint(Sender: TObject);
var
 ps : TPaintStruct;
begin
 BeginPaint (Panel1.Handle, ps);        // для более устойчивой работы
 wglMakeCurrent(dc, hrc);
 glClearColor (1.0, 0.0, 0.0, 1.0);
 glClear (GL_COLOR_BUFFER_BIT);
 wglMakeCurrent(0, 0);
 EndPaint (Panel1.Handle, ps);
end;

{=======================================================================
Формат пикселя}
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPIXELFORMATDESCRIPTOR;
 nPixelFormat : Integer;
begin
 FillChar(pfd, SizeOf(pfd), 0);
 nPixelFormat := ChoosePixelFormat (hdc, @pfd);
 SetPixelFormat (hdc, nPixelFormat, @pfd);
end;

{=======================================================================
Начало работы приложения}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
 dc := GetDC (Panel1.Handle);
 SetDCPixelFormat(dc);
 hrc := wglCreateContext(dc);
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglDeleteContext(hrc);
end;


end.

