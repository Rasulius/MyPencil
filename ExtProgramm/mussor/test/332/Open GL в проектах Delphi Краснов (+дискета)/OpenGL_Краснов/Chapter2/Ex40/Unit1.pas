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
    aVertex : Array [0..63, 0..1] of GLFloat;
    aColors : Array [0..63, 0..2] of GLFloat;
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
var
  i : 0..63;
begin
  For i := 0 to 63 do begin
    aVertex[i][0] := ClientWidth / 450 * sin (0.1 * i);
    aVertex[i][1] := ClientHeight / 450 * cos (0.1 * i);
    aColors[i][0] := 0.75 - 0.01 * i;
    aColors[i][1] := 0.85 - 0.02 * i;
    aColors[i][1] := 0.85 - 0.02 * i;
  end;
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glViewPort (0, 0, ClientWidth, ClientHeight);

 Init;

 glClearColor (0.5, 0.5, 0.75, 1.0);
 glClear (GL_COLOR_BUFFER_BIT);

 glVertexPointer(2, GL_FLOAT, 0, @aVertex);
 glColorPointer(3, GL_FLOAT, 0, @aColors);
 glEnableClientState(GL_VERTEX_ARRAY);
 glEnableClientState(GL_COLOR_ARRAY);
 glDrawArrays(GL_POLYGON, 0, 64);
 glDisableClientState(GL_COLOR_ARRAY);
 glDisableClientState(GL_VERTEX_ARRAY);

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

