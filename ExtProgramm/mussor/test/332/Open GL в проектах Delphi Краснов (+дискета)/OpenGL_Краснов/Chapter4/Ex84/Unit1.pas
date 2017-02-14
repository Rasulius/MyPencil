{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

// Brian Paul   June 1996   This file is in the public domain.

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
  Angle : GLfloat = 0;
  time : LongInt;
  HaveTexObj : Boolean = True;
  TexObj : Array [0..1] of GLUint;

implementation

{$R *.DFM}

procedure glGenTextures (n: GLsizei; textures: PGLuint); stdcall; external opengl32;
procedure glBindTexture (target: GLEnum; texture: GLuint); stdcall; external opengl32;
procedure glTexSubImage2D (target: GLEnum; level, xoffset, yoffset: GLint; width, height: GLsizei; format,
    atype: GLEnum; pixels: Pointer); stdcall; external opengl32;
procedure glDeleteTextures (n: GLsizei; textures: PGLuint); stdcall; external opengl32;

procedure Init;
const
   width=8;
   height=8;
   tex1 : Array [0..63] of GLubyte = (
     0, 0, 0, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 1, 0, 0, 0,
     0, 0, 0, 1, 1, 0, 0, 0,
     0, 0, 0, 0, 1, 0, 0, 0,
     0, 0, 0, 0, 1, 0, 0, 0,
     0, 0, 0, 0, 1, 0, 0, 0,
     0, 0, 0, 1, 1, 1, 0, 0,
     0, 0, 0, 0, 0, 0, 0, 0 );

   tex2 : Array [0..63] of GLubyte  = (
     0, 0, 0, 0, 0, 0, 0, 0,
     0, 0, 0, 2, 2, 0, 0, 0,
     0, 0, 2, 0, 0, 2, 0, 0,
     0, 0, 0, 0, 0, 2, 0, 0,
     0, 0, 0, 0, 2, 0, 0, 0,
     0, 0, 0, 2, 0, 0, 0, 0,
     0, 0, 2, 2, 2, 2, 0, 0,
     0, 0, 0, 0, 0, 0, 0, 0 );

var
   tex : Array [0..63, 0..2] of GLubyte;
   i, j, p : GLint;
begin
   //* Setup texturing */
   glEnable( GL_TEXTURE_2D );
   glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL );
   glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST );

   //* generate texture object IDs */
   if HaveTexObj
      then glGenTextures( 2, @TexObj )
      else begin
      TexObj[0] := glGenLists(2);
      TexObj[1] := TexObj[0]+1;
   end;

   //* setup first texture object */
   if HaveTexObj
      then glBindTexture( GL_TEXTURE_2D, TexObj[0] )
      else glNewList( TexObj[0], GL_COMPILE );
   //* red on white */
   for i:=0 to height-1 do
      for j:=0 to width - 1 do begin
         p := i*width+j;
         if (tex1[(height-i-1)*width+j])<>0 then begin
            tex[p][0] := 255;
            tex[p][1] := 0;
            tex[p][2] := 0;
         end
         else begin
            tex[p][0] := 255;
            tex[p][1] := 255;
            tex[p][2] := 255;
         end
   end;

   glTexImage2D( GL_TEXTURE_2D, 0, 3, width, height, 0,
                 GL_RGB, GL_UNSIGNED_BYTE, @tex );
   glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
   glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
   if not HaveTexObj then glEndList();
   //* end of texture object */

   //* setup second texture object */
   if HaveTexObj
      then glBindTexture( GL_TEXTURE_2D, TexObj[1] )
      else glNewList( TexObj[1], GL_COMPILE );
   //* green on blue */
   for i:=0 to height-1 do
      for j:=0 to width - 1 do begin
         p := i*width+j;
         if (tex2[(height-i-1)*width+j])<>0 then begin
            tex[p][0] := 0;
            tex[p][1] := 255;
            tex[p][2] := 0;
         end
         else begin
            tex[p][0] := 0;
            tex[p][1] := 0;
            tex[p][2] := 255;
         end;
   end;

   glTexImage2D( GL_TEXTURE_2D, 0, 3, width, height, 0,
                 GL_RGB, GL_UNSIGNED_BYTE, @tex );
   glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
   glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
   if not HaveTexObj then  glEndList;
   //* end texture object */
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
 ps : TPaintStruct;
begin
 BeginPaint(Handle, ps);

 // очистка буфера цвета и буфера глубины
 glDepthFunc(GL_EQUAL);
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 glColor3f( 1.0, 1.0, 1.0 );

 //* draw first polygon */
 glPushMatrix();
 glTranslatef( -1.0, 0.0, 0.0 );
 glRotatef( Angle, 0.0, 0.0, 1.0 );
 if HaveTexObj
    then glBindTexture( GL_TEXTURE_2D, TexObj[0] )
    else glCallList( TexObj[0] );
 glBegin( GL_POLYGON );
 glTexCoord2f( 0.0, 0.0 );   glVertex2f( -1.0, -1.0 );
 glTexCoord2f( 1.0, 0.0 );   glVertex2f(  1.0, -1.0 );
 glTexCoord2f( 1.0, 1.0 );   glVertex2f(  1.0,  1.0 );
 glTexCoord2f( 0.0, 1.0 );   glVertex2f( -1.0,  1.0 );
 glEnd();
 glPopMatrix();

 //* draw second polygon */
 glPushMatrix();
 glTranslatef( 1.0, 0.0, 0.0 );
 glRotatef( Angle-90.0, 0.0, 1.0, 0.0 );
 if HaveTexObj
    then      glBindTexture( GL_TEXTURE_2D, TexObj[1] )
    else      glCallList( TexObj[1] );
 glBegin( GL_POLYGON );
 glTexCoord2f( 0.0, 0.0 );   glVertex2f( -1.0, -1.0 );
 glTexCoord2f( 1.0, 0.0 );   glVertex2f(  1.0, -1.0 );
 glTexCoord2f( 1.0, 1.0 );   glVertex2f(  1.0,  1.0 );
 glTexCoord2f( 0.0, 1.0 );   glVertex2f( -1.0,  1.0 );
 glEnd();
 glPopMatrix();

 SwapBuffers(DC);

 EndPaint(Handle, ps);

 Angle := Angle + 0.75 * (GetTickCount - time) * 360 / 1000;
 If Angle >= 360.0 then Angle := 0.0;
 time := GetTickCount;

 InvalidateRect(Handle, nil, False);
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
 time := GetTickCount; 
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 if HaveTexObj
    then glDeleteTextures( 2, @TexObj )
    else glDeleteLists (TexObj[0], 2 );
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
end;

end.

