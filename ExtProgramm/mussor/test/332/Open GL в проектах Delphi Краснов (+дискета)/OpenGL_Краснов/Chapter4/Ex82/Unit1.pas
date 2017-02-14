{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls,
  OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC : HDC;
    hrc: HGLRC;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

const
 checkImageWidth = 64;
 checkImageHeight  = 64;
 subImageWidth = 16;
 subImageHeight = 16;

var
 checkImage : Array [0..checkImageHeight - 1, 0..checkImageWidth - 1, 0..3] of GLubyte;
 subImage : Array [0..subImageHeight - 1, 0..subImageWidth - 1, 0..3] of GLubyte;

procedure makeCheckImages;
var
 i, j : 0..63;
 k : GLint;
begin
 For i := 0 to 63 do
    For j := 0 to 63 do begin
       k := ((i shr 3) and 1) xor ((j shr 3) and 1);
       checkImage [i][j][0] := 255 * k;
       checkImage [i][j][1] := 255 * k;
       checkImage [i][j][2] := 255 * k;
       checkImage [i][j][3] := 255;
 end;

 For i := 0 to subImageHeight - 1 do
    For j := 0 to subImageWidth - 1 do begin
       k := ((i shr 2) and 1) xor ((j shr 2) and 1);
       subImage [i][j][0] := 255 * k;
       subImage [i][j][1] := 0;
       subImage [i][j][2] := 0;
       subImage [i][j][3] := 255;
 end;
end;

procedure glTexSubImage2D (target: GLEnum; level, xoffset, yoffset: GLint; width, height: GLsizei; format,
    atype: GLEnum; pixels: Pointer); stdcall; external opengl32;

procedure Init;
begin
   makeCheckImages;
   glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
   glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, checkImageWidth, checkImageHeight,
                0, GL_RGBA, GL_UNSIGNED_BYTE, @checkImage);
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
 ps : TPaintStruct;
begin
 BeginPaint(Handle, ps);

 // очистка буфера цвета и буфера глубины
 glClear(GL_COLOR_BUFFER_BIT);

 glPushMatrix;

 glEnable(GL_TEXTURE_2D);
 glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
   glBegin(GL_QUADS);
   glTexCoord2f(0.0, 0.0); glVertex3f(-2.0, -1.0, 0.0);
   glTexCoord2f(0.0, 1.0); glVertex3f(-2.0, 1.0, 0.0);
   glTexCoord2f(1.0, 1.0); glVertex3f(0.0, 1.0, 0.0);
   glTexCoord2f(1.0, 0.0); glVertex3f(0.0, -1.0, 0.0);

   glTexCoord2f(0.0, 0.0); glVertex3f(1.0, -1.0, 0.0);
   glTexCoord2f(0.0, 1.0); glVertex3f(1.0, 1.0, 0.0);
   glTexCoord2f(1.0, 1.0); glVertex3f(2.41421, 1.0, -1.41421);
   glTexCoord2f(1.0, 0.0); glVertex3f(2.41421, -1.0, -1.41421);
 glEnd;
 glDisable(GL_TEXTURE_2D);

 glPopMatrix;

 SwapBuffers(DC);

 EndPaint(Handle, ps);
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
 Init;
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

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewPort (0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluPerspective(60.0, ClientWidth / ClientHeight, 1.0, 30.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef(0.0, 0.0, -3.6);
 InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
  If Key = Ord ('S') then begin
     glTexSubImage2D(GL_TEXTURE_2D, 0, 12, 44, subImageWidth,
                         subImageHeight, GL_RGBA,
                         GL_UNSIGNED_BYTE, @subImage);
     InvalidateRect(Handle, nil, False);
  end;
  If Key = Ord ('R') then begin
     glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, checkImageWidth,
                      checkImageHeight, 0, GL_RGBA,
                      GL_UNSIGNED_BYTE, @checkImage);
     InvalidateRect(Handle, nil, False);
  end;
end;

end.

