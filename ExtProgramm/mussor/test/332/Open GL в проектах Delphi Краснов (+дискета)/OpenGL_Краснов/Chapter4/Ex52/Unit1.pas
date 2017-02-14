{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{/*
 * (c) Copyright 1993, 1994, 1995, 1996 Silicon Graphics, Inc.
 * ALL RIGHTS RESERVED
 */}

unit Unit1;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Controls,
  Dialogs, SysUtils, OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    DC: HDC;
    hrc: HGLRC;
    procedure SetDCPixelFormat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
  density = 36;

type
 TDrip = class
   public
     outer_color, ring_color, inner_color : Array [0..3] of GLfloat;
     outer_radius, ring_radius : GLfloat;
     procedure Draw;
     procedure fill_points;
   private
     divisions : GLint;
     points : Array [0..density * 8 - 1] of GLfloat;
 end;

const
 max_drips = 20;
 max_ring_radius = 250.0;

var
 drip_position : Array [0..max_drips-1, 0..1] of GLfloat;
 first_drip, new_drip : GLint;
 drips : Array [0..max_drips - 1] of TDrip;

var
 frmGL: TfrmGL;

implementation

{$R *.DFM}

procedure TDrip.Draw;
var
  i : GLint;
begin
  glBegin(GL_TRIANGLES);
  For i := 0 to divisions-1 do begin
    glColor4fv(@inner_color);
    glVertex2f(0.0, 0.0);
    glColor4fv(@ring_color);
    glVertex2f(points[2*i] * ring_radius, points[2*i + 1] * ring_radius);
    glVertex2f(points[2*((i+1) mod divisions)] * ring_radius,
	       points[(2*((i+1) mod divisions)) + 1] * ring_radius);
  end;
  glEnd;
end;

procedure TDrip.fill_points;
var
  i : GLint;
  theta : GLfloat;
  delta : GLfloat;
begin
  delta := 2.0 * PI / divisions;
  theta := 0.0;
  For i := 0 to divisions-1 do begin
    points[2 * i] := cos(theta);
    points[2 * i + 1] := sin(theta);
    theta := theta + delta;
  end;
end;

procedure create_drip(x, y, r, g, b : GLfloat);
begin
   drips[new_drip] := TDrip.Create;
   With drips[new_drip] do begin
    divisions := density;
    fill_points;
    inner_color[0] := r;ring_color[0] := r;outer_color[0] := r;
    inner_color[1] := g;ring_color[1] := g;outer_color[1] := g;
    inner_color[2] := b;ring_color[2] := b;outer_color[2] := b;

    inner_color[3] := 1.0;ring_color[3] := 1.0;outer_color[3] := 0.0;

    ring_radius := 0.0;outer_radius := 0.0;
   end;

   drip_position[new_drip][0] := x;
   drip_position[new_drip][1] := y;

   new_drip := (new_drip + 1) mod max_drips;
   If (new_drip = first_drip)
   	then first_drip := (first_drip + 1) mod max_drips;
end;


{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
  rel_size : GLfloat;
  i : GLint;
begin
  BeginPaint(Handle, ps);

  i := first_drip;

  glClear(GL_COLOR_BUFFER_BIT);

  While i<>new_drip do begin
        drips[i].ring_radius := drips[i].ring_radius + 1;
	drips[i].outer_radius := drips[i].outer_radius + 1;

   	rel_size := drips[i].ring_radius / max_ring_radius;
 	drips[i].ring_color[3] := 0;
	drips[i].inner_color[3] := 5-5*rel_size*rel_size;

        glPushMatrix;
	glTranslatef(drip_position[i][0], drip_position[i][1], 0.0);
	drips[i].draw;
	glPopMatrix;

	If (drips[i].ring_radius > max_ring_radius)
            then first_drip := (first_drip + 1) mod max_drips;
          i:=(i+1) mod max_drips;
  end;

  SwapBuffers(DC);
  EndPaint(Handle, ps);
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_BLEND);
  new_drip := 0;
  first_drip := 0;
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight );
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 glOrtho(0, ClientWidth, 0, ClientHeight, -1, 1);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
var
  i : 0..max_drips - 1;
begin
  For i := 0 to max_drips - 1 do
    drips [i].Free;
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

procedure TfrmGL.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  create_drip(X, ClientHeight - Y, random, random, random);
end;

end.


