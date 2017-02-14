{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{/* Draw test patterns to help determine correct gamma value for a display.
   When the intensities in the top row nearly match the intensities in
   the bottom row you've found the right gamma value.

   For more info about gamma correction see:
   http://www.inforamp.net/~poynton/notes/colour_and_gamma/GammaFAQ.html
   This program is in the public domain
   Brian Paul  19 Oct 1995 */}

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
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

const
 p25 : Array [0..127] of GLUbyte =
( $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00
);

 p50 : Array [0..127] of GLUbyte =
( $aa, $aa, $aa, $aa, $55, $55, $55, $55,
  $aa, $aa, $aa, $aa, $55, $55, $55, $55,
  $aa, $aa, $aa, $aa, $55, $55, $55, $55,
  $aa, $aa, $aa, $aa, $55, $55, $55, $55,
  $aa, $aa, $aa, $aa, $55, $55, $55, $55,
  $aa, $aa, $aa, $aa, $55, $55, $55, $55,
  $aa, $aa, $aa, $aa, $55, $55, $55, $55,
  $aa, $aa, $aa, $aa, $55, $55, $55, $55,
  $aa, $aa, $aa, $aa, $55, $55, $55, $55,
  $aa, $aa, $aa, $aa, $55, $55, $55, $55,
  $aa, $aa, $aa, $aa, $55, $55, $55, $55,
  $aa, $aa, $aa, $aa, $55, $55, $55, $55,
  $aa, $aa, $aa, $aa, $55, $55, $55, $55,
  $aa, $aa, $aa, $aa, $55, $55, $55, $55,
  $aa, $aa, $aa, $aa, $55, $55, $55, $55,
  $aa, $aa, $aa, $aa, $55, $55, $55, $55
);

 p75 : Array [0..127] of GLUbyte =
( $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff,
  $aa, $aa, $aa, $aa, $ff, $ff, $ff, $ff
);

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
  glClear(GL_COLOR_BUFFER_BIT);

  //** DITHERED ROW **/
  //* solid black */
  //* 25% white */
  glEnable(GL_POLYGON_STIPPLE);
  glColor3f(1.0, 1.0, 1.0);
  glPolygonStipple(@p25);
  glRectf(-0.6, 1.0, -0.2, 0.01);

  //* 50% white */
  glPolygonStipple(@p50);
  glRectf(-0.2, 1.0, 0.2, 0.01);

  //* 75% white */
  glPolygonStipple(@p75);
  glRectf(0.2, 1.0, 0.6, 0.01);

  //* 100% white */
  glDisable(GL_POLYGON_STIPPLE);
  glRectf(0.6, 1.0, 1.0, 0.01);

  //*** GRAY ROW ***/

  //* solid black */

  //* 25% white */
  glColor3f(0.25, 0.25, 0.25);
  glRectf(-0.6, -0.01, -0.2, -1.0);

  //* 50% white */
  glColor3f(0.5, 0.5, 0.5);
  glRectf(-0.2, -0.01, 0.2, -1.0);

  //* 75% white */
  glColor3f(0.75, 0.75, 0.75);
  glRectf(0.2, -0.01, 0.6, -1.0);

  //* 100% white */
  glColor3f(1.0, 1.0, 1.0);
  glRectf(0.6, -0.01, 1.0, -1.0);

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
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 glOrtho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;

 InvalidateRect(Handle, nil, False);
end;


end.

