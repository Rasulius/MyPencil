{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{/*
 * (c) Copyright 1993, Silicon Graphics, Inc.
 *               1993-1995 Microsoft Corporation
 * ALL RIGHTS RESERVED
 */}

unit frmMain;
interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Controls,
  Dialogs, OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    DC: HDC;
    hrc: HGLRC;
    procedure Init;
    procedure SetDCPixelFormat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  Closed : Boolean = False;

implementation

uses DGLUT;

{$R *.DFM}

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
    ambient : Array [0..3] of GLfloat = (0.0, 0.0, 0.0, 1.0);
    diffuse : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 1.0);
    position : Array [0..3] of GLfloat = (0.0, 3.0, 3.0, 0.0);
begin
    glLightfv(GL_LIGHT0, GL_AMBIENT, @ambient);
    glLightfv(GL_LIGHT0, GL_DIFFUSE, @diffuse);
    glLightfv(GL_LIGHT0, GL_POSITION, @position);

    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_DEPTH_TEST);
end;

procedure renderTeapot (x, y, ambr, ambg, ambb,
    difr, difg, difb, specr, specg, specb, shine : GLfloat);
var
    mat : Array [0..2] of GLfloat;
begin
    glPushMatrix;
    glTranslatef (x, y, 0.0);
    mat[0] := ambr; mat[1] := ambg; mat[2] := ambb;
    glMaterialfv (GL_FRONT, GL_AMBIENT, @mat);
    mat[0] := difr; mat[1] := difg; mat[2] := difb;
    glMaterialfv (GL_FRONT, GL_DIFFUSE, @mat);
    mat[0] := specr; mat[1] := specg; mat[2] := specb;
    glMaterialfv (GL_FRONT, GL_SPECULAR, @mat);
    glMaterialf (GL_FRONT, GL_SHININESS, shine*128.0);
    glutSolidTeapot (1.0);
    glPopMatrix;
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
    renderTeapot (2.0, 17.0, 0.0215, 0.1745, 0.0215, 
    0.07568, 0.61424, 0.07568, 0.633, 0.727811, 0.633, 0.6);
    renderTeapot (2.0, 14.0, 0.135, 0.2225, 0.1575,
    0.54, 0.89, 0.63, 0.316228, 0.316228, 0.316228, 0.1);
    renderTeapot (2.0, 11.0, 0.05375, 0.05, 0.06625,
    0.18275, 0.17, 0.22525, 0.332741, 0.328634, 0.346435, 0.3);
    renderTeapot (2.0, 8.0, 0.25, 0.20725, 0.20725,
    1, 0.829, 0.829, 0.296648, 0.296648, 0.296648, 0.088);
    renderTeapot (2.0, 5.0, 0.1745, 0.01175, 0.01175,
    0.61424, 0.04136, 0.04136, 0.727811, 0.626959, 0.626959, 0.6);
    renderTeapot (2.0, 2.0, 0.1, 0.18725, 0.1745,
    0.396, 0.74151, 0.69102, 0.297254, 0.30829, 0.306678, 0.1);
    renderTeapot (6.0, 17.0, 0.329412, 0.223529, 0.027451,
    0.780392, 0.568627, 0.113725, 0.992157, 0.941176, 0.807843,
    0.21794872);
    renderTeapot (6.0, 14.0, 0.2125, 0.1275, 0.054,
    0.714, 0.4284, 0.18144, 0.393548, 0.271906, 0.166721, 0.2);
    renderTeapot (6.0, 11.0, 0.25, 0.25, 0.25, 
    0.4, 0.4, 0.4, 0.774597, 0.774597, 0.774597, 0.6);
    renderTeapot (6.0, 8.0, 0.19125, 0.0735, 0.0225,
    0.7038, 0.27048, 0.0828, 0.256777, 0.137622, 0.086014, 0.1);
    renderTeapot (6.0, 5.0, 0.24725, 0.1995, 0.0745,
    0.75164, 0.60648, 0.22648, 0.628281, 0.555802, 0.366065, 0.4);
    renderTeapot (6.0, 2.0, 0.19225, 0.19225, 0.19225,
    0.50754, 0.50754, 0.50754, 0.508273, 0.508273, 0.508273, 0.4);
    renderTeapot (10.0, 17.0, 0.0, 0.0, 0.0, 0.01, 0.01, 0.01,
    0.50, 0.50, 0.50, 0.25);
    renderTeapot (10.0, 14.0, 0.0, 0.1, 0.06, 0.0, 0.50980392, 0.50980392,
    0.50196078, 0.50196078, 0.50196078, 0.25);
    renderTeapot (10.0, 11.0, 0.0, 0.0, 0.0, 
    0.1, 0.35, 0.1, 0.45, 0.55, 0.45, 0.25);
    renderTeapot (10.0, 8.0, 0.0, 0.0, 0.0, 0.5, 0.0, 0.0,
    0.7, 0.6, 0.6, 0.25);
    renderTeapot (10.0, 5.0, 0.0, 0.0, 0.0, 0.55, 0.55, 0.55,
    0.70, 0.70, 0.70, 0.25);
    renderTeapot (10.0, 2.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.0,
    0.60, 0.60, 0.50, 0.25);
    renderTeapot (14.0, 17.0, 0.02, 0.02, 0.02, 0.01, 0.01, 0.01,
    0.4, 0.4, 0.4, 0.078125);
    renderTeapot (14.0, 14.0, 0.0, 0.05, 0.05, 0.4, 0.5, 0.5,
    0.04, 0.7, 0.7, 0.078125);
    renderTeapot (14.0, 11.0, 0.0, 0.05, 0.0, 0.4, 0.5, 0.4,
    0.04, 0.7, 0.04, 0.078125);
    renderTeapot (14.0, 8.0, 0.05, 0.0, 0.0, 0.5, 0.4, 0.4,
    0.7, 0.04, 0.04, 0.078125);
    renderTeapot (14.0, 5.0, 0.05, 0.05, 0.05, 0.5, 0.5, 0.5,
    0.7, 0.7, 0.7, 0.078125);
    renderTeapot (14.0, 2.0, 0.05, 0.05, 0.0, 0.5, 0.5, 0.4, 
    0.7, 0.7, 0.04, 0.078125);
  glPopMatrix;

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
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight );
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 If ClientWidth <= ClientHeight
    then glOrtho (0.0, 16.0, 0.0, 16.0*ClientHeight / ClientWidth, -10.0, 10.0)
    else glOrtho (0.0, 16.0*ClientWidth / ClientHeight, 0.0, 16.0,  -10.0, 10.0);
 glMatrixMode(GL_MODELVIEW);

 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
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

  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;



end.


