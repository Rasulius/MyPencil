{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{/*
 * (c) Copyright 1993, Silicon Graphics, Inc.
 *               1993-1995 Microsoft Corporation
 *
 * ALL RIGHTS RESERVED
 */}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, OpenGL;

type
  TfrmGL = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    DC: HDC;
    hrc: HGLRC;
    solidZ : GLfloat;
    transparentZ : GLfloat;
    procedure Init;
    procedure SetDCPixelFormat;

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
 MAXZ = 8.0;
 MINZ = -8.0;
 ZINC = 0.8;

var
  frmGL: TfrmGL;

implementation

uses DGLUT;

{$R *.DFM}

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
   mat_specular : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 0.15);
   mat_shininess : GLfloat = 100.0;
   position : Array [0..3] of GLfloat = (0.5, 0.5, 1.0, 0.0);
begin
   // оптические свойства материалов и источник света
   glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_specular);
   glMaterialfv(GL_FRONT, GL_SHININESS, @mat_shininess);
   glLightfv(GL_LIGHT0, GL_POSITION, @position);
   glEnable(GL_LIGHTING);
   glEnable(GL_LIGHT0);
   glEnable(GL_DEPTH_TEST);
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
const
  mat_solid : Array [0..3] of GLfloat = (0.75, 0.75, 0.0, 1.0);
  mat_zero : Array [0..3] of GLfloat = (0.0, 0.0, 0.0, 1.0);
  mat_transparent : Array [0..3] of GLfloat = (0.0, 0.8, 0.8, 0.6);
  mat_emission : Array [0..3] of GLfloat = (0.0, 0.3, 0.3, 0.6);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glPushMatrix;
  // сфера
  glTranslatef (-0.15, -0.15, solidZ);
  glMaterialfv(GL_FRONT, GL_EMISSION, @mat_zero);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_solid);
  glutSolidSphere (0.4, 16, 16);
  glPopMatrix;
  glPushMatrix;
  // куб
  glTranslatef (0.15, 0.15, transparentZ);
  glRotatef (15.0, 1.0, 1.0, 0.0);
  glRotatef (30.0, 0.0, 1.0, 0.0);
  glMaterialfv(GL_FRONT, GL_EMISSION, @mat_emission);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_transparent);
  glEnable (GL_BLEND);             // для смешения
  glBlendFunc (GL_SRC_ALPHA, GL_ONE);
  glutSolidCube (0.6);
  glDisable (GL_BLEND);
  glPopMatrix;

  SwapBuffers(DC);
  EndPaint(Handle, ps);
end;

{=======================================================================
Обработка нажатия клавиши}
procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = Ord ('A') then Timer1.Enabled := True;

  If Key = Ord ('R') then begin
     solidZ := MAXZ;
     transparentZ := MINZ;
     InvalidateRect(Handle, nil, False);
  end;

  If Key = VK_ESCAPE then Close;
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  solidZ := MAXZ;
  transparentZ := MINZ;
  Init;
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  If ClientWidth <= ClientHeight
     then glOrtho (-0.8, 0.8, -0.8*ClientHeight/ ClientWidth, 0.8*ClientHeight/ClientWidth, -10.0, 10.0)
     else glOrtho (-0.8*ClientWidth/ClientHeight, 0.8*ClientWidth/ClientHeight, -0.8, 0.8, -10.0, 10.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  Timer1.Enabled := False;
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

{=======================================================================
Обработка таймера}
procedure TfrmGL.Timer1Timer(Sender: TObject);
begin
  If (solidZ <= MINZ) and (transparentZ >= MAXZ)
   then Timer1.Enabled := False
   else begin
     solidZ := solidZ - ZINC;
     transparentZ := transparentZ + ZINC;
   end;
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Устанавливаем формат пикселей}
procedure TfrmGL.SetDCPixelFormat;
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;
begin
  FillChar(pfd, SizeOf(pfd), 0);

  pfd.dwFlags   := PFD_DRAW_TO_WINDOW or
                 PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;
  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;


end.

