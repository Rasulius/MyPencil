{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
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
  wBrick=16;
  hBrick=8;

type
  TRGB = record
    Red,
    Green,
    Blue : GLubyte;
  end;

type
  TBrickLine = Array [0..wBrick-1] of TRGB;

var
  Brick : Array [0..hBrick-1] of TBrickLine;

procedure MakeBrick;
var
  sTex, {x}
  tTex: {y} integer;
begin
  For tTex := 0 to hBrick-1 do
    For sTex := 0 to wBrick-1 do
    With Brick[tTex][sTex] do begin
      If (tTex=hBrick-1) or (sTex=wBrick-1) then begin
        Red := 220;
        Green := 220;
        Blue := 220;
        end
        else begin
        Red := 150 + Random(60);
        Green := 60;
        Blue := 0;
      end;
    end;
end;

procedure Init;
begin
  glPixelStorei(GL_UNPACK_ALIGNMENT,1);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
  MakeBrick;
  glTexImage2D(GL_TEXTURE_2D, 0, 4,wBrick,hBrick, 0,
               GL_RGB,GL_UNSIGNED_BYTE,@Brick);
end;

{=======================================================================
����������� ����}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
 ps : TPaintStruct;
begin
 BeginPaint(Handle, ps);

 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 glEnable(GL_TEXTURE_2D);
 glBegin(GL_TRIANGLE_STRIP);
    glTexCoord2f(0.0, 16.0); glVertex3f(-1.0,  1.0, 0.0);
    glTexCoord2f(0.0, 0.0);  glVertex3f(-1.0, -1.0, 0.0);
    glTexCoord2f(8.0, 16.0); glVertex3f( 1.0,  1.0, 0.0);
    glTexCoord2f(8.0, 0.0);  glVertex3f( 1.0, -1.0, 0.0);
 glEnd;
 glDisable(GL_TEXTURE_2D);

 SwapBuffers(DC);

 EndPaint(Handle, ps);
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
 DC := GetDC (Handle);
 SetDCPixelFormat(DC);
 hrc := wglCreateContext(DC);
 wglMakeCurrent(DC, hrc);
 Randomize;
 Init;
end;

{=======================================================================
����� ������ ����������}
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
 gluPerspective(40.0, ClientWidth / ClientHeight, 1.0, 30.0);
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

