{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

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

  private
    DC : HDC;
    hrc: HGLRC;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure Idle (Sender:TObject;var Done:boolean);
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

type
  TCol = record
     r : GLfloat;
     g : GLfloat;
     b : GLfloat;
  end;

const
  Step = 0.04;
  Fade = 0.385;
  NumX = 50;
  NumY = 50;

var
  Fire : array [1..NumX, 1..NumY] of TCol;
  PreF : array [1..NumX] of TCol;

procedure DrawPix(X,Y:integer);
begin
  glBegin(GL_QUADS);
    glColor3fv(@Fire[x , y]);
    glVertex2f(x*(step)-1, y*step-1.1);
    glColor3fv(@Fire[x,y + 1]);
    glVertex2f(x*(step)-1, y*step + step-1.1);
    glColor3fv(@Fire[x + 1,y + 1]);
    glVertex2f(x*(step) + step-1, y*step + step-1.1);
    glColor3fv(@Fire[x + 1,y]);
    glVertex2f(x*(step) + step-1, y*step-1.1);
  glEnd;
end;

procedure SetFire;
var
  i : GLint;
  f : GLfloat;
begin
  For i := 2 to NumX-1 do begin
      f := random(300) / 100 - 0.8;
      PreF[i].r := f;
      PreF[i].g := f / 1.4;
      PreF[i].b := f / 2;
  end;
end;

procedure MixFire;
var
  i, j : GLint;
begin
  For i := 2 to NumX - 1 do begin
      Fire[i,1].r := (PreF[i - 1].r + PreF[i + 1].r + PreF[i].r)/3;
      Fire[i,1].g := (PreF[i - 1].g + PreF[i + 1].g + PreF[i].g)/3;
      Fire[i,1].b := (PreF[i - 1].b + PreF[i + 1].b + PreF[i].b)/3;
  end;
  For j := 2 to NumY - 1 do
  For i := 2 to NumX-1 do begin
      Fire[i,j].r:=(Fire[i-1,j].r+Fire[i+1,j].r+Fire[i-1,j-1].r+Fire[i,j-1].r+
                    Fire[i+1,j-1].r+Fire[i,j].r)/5;
      Fire[i,j].g:=(Fire[i-1,j].g+Fire[i+1,j].g+Fire[i-1,j-1].g+Fire[i,j-1].g+
                    Fire[i+1,j-1].g+Fire[i,j].g)/5;
      Fire[i,j].b:=(Fire[i-1,j].b+Fire[i+1,j].b+Fire[i-1,j-1].b+Fire[i,j-1].b+
                    Fire[i+1,j-1].b+Fire[i,j].b)/5;
    end;
end;

procedure FireUp;
var
  i, j : GLint;
begin
  For j := NumY downto 2 do
    For i := 1 to NumX do begin
      Fire[i, j].r := Fire[i,j - 1].r - Fade;
      Fire[i, j].g := Fire[i,j - 1].g - Fade;
      Fire[i, j].b := Fire[i,j - 1].b - Fade;
    end;
end;

procedure DrawFire;
var
  i, j : GLint;
begin
  SetFire;
  MixFire;
  For j := 2 to NumY - 1 do
    For i:=2 to NumX-1 do
      DrawPix(i,j);
  FireUp;
end;

procedure TfrmGL.Idle (Sender:TObject;var Done:boolean);
begin
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
 ps : TPaintStruct;
begin
 BeginPaint(Handle, ps);

 glClear(GL_COLOR_BUFFER_BIT);

 DrawFire;

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

 Application.OnIdle := Idle;
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
 InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
end;

end.

