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

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpenGL, ExtCtrls;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

  private
    DC : HDC;
    hrc: HGLRC;
    newCount, frameCount, lastCount : LongInt;
    fpsRate : GLfloat;
    function StarSin (angle : GLfloat) : GLfloat;
    function StarCos (angle : GLfloat) : GLfloat;
    function StarPoint(n : GLint) : GLenum;
    procedure RotatePoint(var x, y : GLfloat; rotation : GLfloat);
    procedure ShowStars;
    procedure NewStar(n, d : GLint);
    procedure Init;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

type
 TstarRec = record
    StarType : (CIRCLE, STREAK);
    x, y, z : Array [0..1] of GLfloat;
    offsetX, offsetY, offsetR, rotation : GLfloat;
 end;

const
 MAXSTARS = 400;
 MAXPOS = 10000;
 MAXWARP = 10;
 MAXANGLES = 6000;

var
 frmGL: TfrmGL;
 Closed : Boolean = False;
 flag : (NORMAL, WEIRD) = NORMAL;
 starCount : GLint = 200;// MAXSTARS / 2;
 speed : GLfloat = 1.0;
 nitro : GLint = 0;
 stars : Array [0..MAXSTARS] of TstarRec;
 sinTable : Array [0..MAXANGLES] of GLfloat;

implementation

{$R *.DFM}

function TfrmGL.StarSin (angle : GLfloat) : GLfloat;
begin
  Result := sinTable[round(angle)];
end;

function TfrmGL.StarCos (angle : GLfloat) : GLfloat;
begin
  Result := sinTable[round(angle+MAXANGLES/4) mod MAXANGLES];
end;

procedure TfrmGL.NewStar(n, d : GLint);
begin
 If random(4) = 0
    then stars[n].Startype := CIRCLE
    else stars[n].Startype := STREAK;
 stars[n].x[0] := random(MAXPOS) - MAXPOS / 2;
 stars[n].y[0] := random(MAXPOS) - MAXPOS / 2;
 stars[n].z[0] := random(MAXPOS) + d;
 If (random(4) = 0) and (flag = WEIRD) then begin
     stars[n].offsetX := random(100) - 100 / 2;
     stars[n].offsetY := random(100) - 100 / 2;
     stars[n].offsetR := random(25) - 25 / 2;
     end
     else begin
     stars[n].offsetX := 0.0;
     stars[n].offsetY := 0.0;
     stars[n].offsetR := 0.0;
 end;
end;

procedure TfrmGL.RotatePoint(var x, y : GLfloat; rotation : GLfloat);
begin
  x := x * StarCos(rotation) - y * StarSin(rotation);
  y := y * StarCos(rotation) + x * StarSin(rotation);
end;

procedure MoveStars;
var
 offset : GLfloat;
 n : GLint;
begin
 offset := speed * 60.0;

 For n := 0 to starCount - 1  do begin
	stars[n].x[1] := stars[n].x[0];
	stars[n].y[1] := stars[n].y[0];
	stars[n].z[1] := stars[n].z[0];
	stars[n].x[0] := stars[n].x[0] + stars[n].offsetX;
	stars[n].y[0] := stars[n].y[0] + stars[n].offsetY;
	stars[n].z[0] := stars[n].z[0]- offset;
        stars[n].rotation := stars[n].rotation + stars[n].offsetR;
        If stars[n].rotation > MAXANGLES  then
            stars[n].rotation := 0.0;
 end;
end;

function TfrmGL.StarPoint(n : GLint) : GLenum;
var
    x, y, x0, y0, x1, y1, fwidth : GLfloat;
    i : GLint;
begin
    x0 := stars[n].x[0] * ClientWidth / stars[n].z[0];
    y0 := stars[n].y[0] * ClientHeight / stars[n].z[0];
    RotatePoint(x0, y0, stars[n].rotation);
    x0 := x0 + ClientWidth / 2.0;
    y0 := y0 + ClientHeight / 2.0;

    If (x0 >= 0.0) and (x0 < ClientWidth) and (y0 >= 0.0) and (y0 < ClientHeight)
    then begin
	if stars[n].StarType = STREAK then begin
	    x1 := stars[n].x[1] * ClientWidth / stars[n].z[1];
	    y1 := stars[n].y[1] * ClientHeight / stars[n].z[1];
	    RotatePoint(x1, y1, stars[n].rotation);
	    x1 := x1 + ClientWidth / 2.0;
	    y1 := y1 + ClientHeight / 2.0;

	    glLineWidth(MAXPOS/100.0/stars[n].z[0]+1.0);
	    glColor3f(1.0, (MAXWARP-speed)/MAXWARP, (MAXWARP-speed)/MAXWARP);
	    if (abs(x0-x1) < 1.0) and (abs(y0-y1) < 1.0) then begin
		glBegin(GL_POINTS);
		    glVertex2f(x0, y0);
		glEnd;
	      end
              else begin
		glBegin(GL_LINES);
		    glVertex2f(x0, y0);
		    glVertex2f(x1, y1);
		glEnd;
	    end
	end
        else begin
	    fwidth := MAXPOS / 10.0 / stars[n].z[0] + 1.0;
	    glColor3f(1.0, 0.0, 0.0);
	    glBegin(GL_POLYGON);
		for i := 0 to 7 do begin
		    x := x0 + fwidth * StarCos(i*MAXANGLES/8.0);
		    y := y0 + fwidth * StarSin(i*MAXANGLES/8.0);
		    glVertex2f(x, y);
		end;
	    glEnd;
	Result := GL_TRUE;
	end
        end
        else
	Result := GL_FALSE;
end;

procedure TfrmGL.ShowStars;
var
 n :  GLint;
begin
 glClear(GL_COLOR_BUFFER_BIT);

 For n := 0 to starCount - 1 do
   If (stars[n].z[0] > speed ) or ((stars[n].z[0] > 0.0) and (speed < MAXWARP))
      then begin
           if StarPoint(n) = GL_FALSE then
		NewStar(n, MAXPOS)
       end
       else NewStar(n, MAXPOS);
end;

procedure TfrmGL.Init;
var
 angle : GLfloat;
 n : GLint;
begin
 For n := 0 to MAXSTARS -1 do
 	NewStar(n, 100);
 angle := 0.0;
 For n := 0 to MAXANGLES -1 do begin
     sinTable[n] := sin(angle);
     angle := angle + PI / (MAXANGLES / 2.0);
 end;
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
 ps : TPaintStruct;
begin
 BeginPaint(Handle, ps);

 MoveStars;
 ShowStars;
 if nitro > 0 then begin
	speed := nitro / 10 + 1.0;
	if speed > MAXWARP then
	    speed := MAXWARP;
	nitro := nitro + 1;
	if nitro > MAXWARP*10 then
	    nitro := -nitro;
        end
        else if (nitro < 0) then begin
	nitro := nitro + 1;
	speed := (-nitro / 10) + 1.0;
	if speed > MAXWARP then
	    speed := MAXWARP;
 end;

 SwapBuffers(DC);

 EndPaint(Handle, ps);

 // определяем и выводим количество кадров в секунду
 newCount := GetTickCount;
 Inc(frameCount);
 If (newCount - lastCount) > 1000 then  begin // прошла секунда
    fpsRate := frameCount * 1000 / (newCount - lastCount);
    Caption := 'FPS - ' + FloatToStr (fpsRate);
    lastCount := newCount;
    frameCount := 0;
 end;

 If not Closed then begin
    Application.ProcessMessages;
    InvalidateRect(Handle, nil, False);
 end;
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
 lastCount := GetTickCount;
 frameCount := 0;
 init;
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
 gluOrtho2D(-0.5, ClientWidth+0.5, -0.5, ClientHeight+0.5);
 glMatrixMode(GL_MODELVIEW);
 InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
  If Key = VK_SPACE then
     If flag = NORMAL
        then flag := WEIRD
        else flag := NORMAL;
  If Key = Ord ('T') then nitro := 1;
end;

procedure TfrmGL.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Closed := True;
end;

end.

