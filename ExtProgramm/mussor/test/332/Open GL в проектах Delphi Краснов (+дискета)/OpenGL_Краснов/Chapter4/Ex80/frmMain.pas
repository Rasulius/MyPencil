{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Controls,
  SysUtils, Dialogs,
  OpenGL;

type
  TfrmGL = class(TForm)
    PopupMenu1: TPopupMenu;
    Object1: TMenuItem;
    Sphere1: TMenuItem;
    Cylinder1: TMenuItem;
    Teapot1: TMenuItem;
    Width1: TMenuItem;
    N41: TMenuItem;
    N81: TMenuItem;
    N161: TMenuItem;
    N321: TMenuItem;
    N641: TMenuItem;
    N1281: TMenuItem;
    N1: TMenuItem;
    GENS1: TMenuItem;
    ON1: TMenuItem;
    OFF1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Sphere1Click(Sender: TObject);
    procedure N21Click(Sender: TObject);
    procedure ON1Click(Sender: TObject);
    procedure OFF1Click(Sender: TObject);
  private
    DC: HDC;
    hrc: HGLRC;
    procedure Init;
    procedure SetDCPixelFormat;
    procedure Idle (Sender:TObject;var Done:boolean);
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
  Sphere = 1;
  Cylinder = 2;
  Teapot = 3;

var
  frmGL: TfrmGL;
  obj : 1..3 = 1;
  Angle : GLfloat = 0;
  time : LongInt;

implementation

uses DGLUT;

{$R *.DFM}

var
  TexWidth : GLint = 16;
  GenSOn : Boolean = True;

procedure MakeTexImage (TexImageWidth : GLint);
const                     // параметры текстуры
 TexParams : Array [0..3] of GLfloat = (0.0, 0.0, 1.0, 0.0);
var
 TexImage : Array [0..128 * 3] of GLUbyte;
 j : GLint;
begin
 j := 0;
 While j < TexImageWidth * 3 - 1 do begin
    TexImage [j] := 255;     // красный
    TexImage [j + 1] := 0;   // зеленый
    TexImage [j + 2] := 0;   // синий
    TexImage [j + 3] := 0;   // красный
    TexImage [j + 4] := 0;   // зеленый
    TexImage [j + 5] := 255; // синий
    Inc (j, 6);
 end;

 glTexParameteri (GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
 glTexParameteri (GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
 glTexImage1D (GL_TEXTURE_1D, 0, 3, TexImageWidth, 0, GL_RGB,
               GL_UNSIGNED_BYTE, @TexImage);

 If GenSOn
    then glEnable (GL_TEXTURE_GEN_S)
    else glDisable (GL_TEXTURE_GEN_S);

 glTexGeni  (GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR); // иначе как штриховка
 glTexGenfv (GL_S, GL_OBJECT_PLANE, @TexParams); // для поворота полосок

 glEnable (GL_TEXTURE_1D);
end;

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
var
 Quadric : GLUquadricObj;
begin
 glEnable(GL_LIGHTING);
 glEnable(GL_LIGHT0);
 glEnable(GL_DEPTH_TEST);

 MakeTexImage (TexWidth);

 Quadric := gluNewQuadric;
 gluQuadricTexture (Quadric, TRUE);

 glNewList (Sphere, GL_COMPILE);
   glRotatef (45, 1.0, 0.0, 0.0);
   gluSphere (Quadric, 1.0, 24, 12);
 glEndList;

 glNewList (Cylinder, GL_COMPILE);
   glRotatef (45, 1.0, 0.0, 0.0);
   gluCylinder (Quadric, 1.0, 1.0, 1.0, 24, 12);
 glEndList;

 glNewList (Teapot, GL_COMPILE);
   glRotatef (45, 1.0, 0.0, 0.0);
   glutSolidTeapot (1.0);
 glEndList;

 gluDeleteQuadric (Quadric);
end;

procedure TfrmGL.Idle (Sender:TObject;var Done:boolean);
begin
 Angle := Angle + 0.1 * (GetTickCount - time) * 360 / 1000;
 If Angle >= 360.0 then Angle := 0.0;
 time := GetTickCount;

 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT );
  glPushMatrix;
     glRotatef (Angle, 0.0, 0.0, 1.0);
     glCallList(obj);
  glPopMatrix;

  SwapBuffers(DC);
  EndPaint(Handle, ps);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  Init;
  time := GetTickCount;
  Application.OnIdle := Idle;
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight );
 glMatrixMode( GL_PROJECTION );
 glLoadIdentity;
 glFrustum( -0.75, 0.75, -0.75, 0.75, 5.0, 15.0 );
 glMatrixMode( GL_MODELVIEW );
 glLoadIdentity;
 glTranslatef( 0.0, 0.0, -12.0 );
 glRotatef(45.0, 1.0, 0.0, 0.0);
 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  glDeleteLists (sphere, 1);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

{=======================================================================
Обработка нажатия клавиши}
procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
end;

{=======================================================================
Устанавливаем формат пикселей}
procedure TfrmGL.SetDCPixelFormat;
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;
begin
  FillChar(pfd, SizeOf(pfd), 0);

  pfd.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;

  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;


procedure TfrmGL.Sphere1Click(Sender: TObject);
begin
  obj := (Sender as TMenuItem).Tag;
end;

procedure TfrmGL.N21Click(Sender: TObject);
begin
 TexWidth := (Sender as TMenuItem).Tag;
 MakeTexImage (TexWidth);
end;

procedure TfrmGL.ON1Click(Sender: TObject);
begin
 GenSOn := True;
 ON1.Checked := True;
 OFF1.Checked := False;
 MakeTexImage (TexWidth);
end;

procedure TfrmGL.OFF1Click(Sender: TObject);
begin
 GenSOn := False;
 ON1.Checked := False;
 OFF1.Checked := True;
 MakeTexImage (TexWidth);
end;

end.

