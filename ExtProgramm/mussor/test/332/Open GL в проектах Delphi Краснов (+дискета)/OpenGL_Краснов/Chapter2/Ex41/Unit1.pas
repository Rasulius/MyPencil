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
    mode : Boolean;
  end;

const
   Vertex1 : Array [0..9, 0..1] of GLFloat =
     ((-0.23678, 0.35118), (-0.23678, 0.7764),
      (-0.37966, 0.7764), (-0.55, 0.60606),
      (-0.55, -0.4), (-0.23576, -0.4),
      (-0.23678, 0.35118), (-0.23576, -0.4),
      (0.1375, -0.4), (0.13678, 0.35118));

   Colors1 : Array [0..9, 0..2] of GLFloat =
     ((0.66, 0.3, 0.5), (0.55, 0.30, 0.8),
      (0.66, 0.3, 0.4), (0.55, 0.30, 0.8),
      (0.66, 0.3, 0.3), (0.55, 0.30, 0.8),
      (0.66, 0.3, 0.2), (0.55, 0.30, 0.8),
      (0.66, 0.3, 0.8), (0.55, 0.30, 0.8));

   Edge1 : Array [0..9] of Boolean =
     (True, True, True, True, True, False, False, True, False, True);

   Vertex2 : Array [0..5, 0..1] of GLFloat =
      ((0.1375, -0.4), (0.45, -0.4),
       (0.45, 0.60606), (0.27966, 0.7764),
       (0.13678, 0.7764), (0.13678, 0.35118));

   Colors2 : Array [0..5, 0..2] of GLFloat =
     ((0.66, 0.3, 0.8), (0.55, 0.30, 0.8),
      (0.66, 0.3, 0.8), (0.55, 0.30, 0.8),
      (0.66, 0.3, 0.8), (0.55, 0.30, 0.8));

   Edge2 : Array [0..5] of Boolean =
     (True, True, True, True, True, False);

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
procedure glEdgeFlagPointer (stride: GLsizei; data: pointer); stdcall; external OpenGL32;

const
 GL_VERTEX_ARRAY                    = $8074;
 GL_COLOR_ARRAY                     = $8076;
 GL_EDGE_FLAG_ARRAY                 = $8079;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 wglMakeCurrent(Canvas.Handle, hrc);

 glViewPort (0, 0, ClientWidth, ClientHeight);

// устанавливаем режим в зависимости от значения mode
 If mode
    then glPolygonMode (GL_FRONT_AND_BACK, GL_LINE)
    else glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);

 glClearColor (0.5, 0.5, 0.75, 1.0);
 glClear (GL_COLOR_BUFFER_BIT);

 glEnableClientState(GL_VERTEX_ARRAY);
 glEnableClientState(GL_COLOR_ARRAY);
 glEnableClientState(GL_EDGE_FLAG_ARRAY);
// glEnable (GL_EDGE_FLAG_ARRAY_EXT); // - согласно документации 

 glVertexPointer(2, GL_FLOAT, 0, @Vertex1);
 glColorPointer(3, GL_FLOAT, 0, @Colors1);
 glEdgeFlagPointer(1, @Edge1);
 glDrawArrays(GL_POLYGON, 0, 10);

 glVertexPointer(2, GL_FLOAT, 0, @Vertex2);
 glColorPointer(3, GL_FLOAT, 0, @Colors2);
 glEdgeFlagPointer(1, @Edge2);
 glDrawArrays(GL_POLYGON, 0, 6);

 glDisableClientState(GL_COLOR_ARRAY);
 glDisableClientState(GL_VERTEX_ARRAY);
 glDisableClientState(GL_EDGE_FLAG_ARRAY);

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
end;

end.

