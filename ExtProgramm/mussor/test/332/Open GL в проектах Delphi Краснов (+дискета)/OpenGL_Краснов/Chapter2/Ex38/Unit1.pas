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
    Vertex : Array [0..3, 0..1] of GLFloat;
    Colors : Array [0..3, 0..2] of GLFloat;
    procedure Init;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

procedure glVertexPointer (size: GLint; atype: GLenum;
          stride: GLsizei; data: pointer); stdcall; external OpenGL32;
procedure glColorPointer (size: GLint; atype: GLenum; stride: GLsizei;
          data: pointer); stdcall; external OpenGL32;
procedure glDrawArrays (mode: GLenum; first: GLint; count: GLsizei);
          stdcall; external OpenGL32;
procedure glEnableClientState (aarray: GLenum); stdcall; external OpenGL32;
procedure glDisableClientState (aarray: GLenum); stdcall; external OpenGL32;

const
 GL_VERTEX_ARRAY                    = $8074;
 GL_COLOR_ARRAY                     = $8076;

procedure TfrmGL.Init;
begin
    Vertex[0][0] := -0.9;
    Vertex[0][1] := -0.9;
    Colors[0][0] := 0.1;
    Colors[0][1] := 0.5;
    Colors[0][2] := 0.85;

    Vertex[1][0] := -0.9;
    Vertex[1][1] := 0.9;
    Colors[1][0] := 0.85;
    Colors[1][1] := 0.1;
    Colors[1][2] := 0.5;

    Vertex[2][0] := 0.9;
    Vertex[2][1] := 0.9;
    Colors[2][0] := 0.85;
    Colors[2][1] := 0.85;
    Colors[2][2] := 0.85;

    Vertex[3][0] := 0.9;
    Vertex[3][1] := -0.9;
    Colors[3][0] := 0.5;
    Colors[3][1] := 0.85;
    Colors[3][2] := 0.1;
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glViewPort (0, 0, ClientWidth, ClientHeight);

 glClearColor (0.5, 0.5, 0.75, 1.0);
 glClear (GL_COLOR_BUFFER_BIT);

 glVertexPointer(2, GL_FLOAT, 0, @Vertex);
 glColorPointer(3, GL_FLOAT, 0, @Colors);
 glEnableClientState(GL_VERTEX_ARRAY);
 glEnableClientState(GL_COLOR_ARRAY);
 glDrawArrays(GL_POLYGON, 0, 4);
 glDisableClientState(GL_COLOR_ARRAY);
 glDisableClientState(GL_VERTEX_ARRAY);

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
 Init;
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglDeleteContext(hrc);
end;

end.

