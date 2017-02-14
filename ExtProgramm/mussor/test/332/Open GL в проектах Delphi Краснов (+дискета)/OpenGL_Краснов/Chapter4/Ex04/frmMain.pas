{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Controls,
  SysUtils, Dialogs, OpenGL;

type
  TfrmGL = class(TForm)
    PopupMenu1: TPopupMenu;
    Ambient1: TMenuItem;
    Diffuse1: TMenuItem;
    Specular1: TMenuItem;
    ColorDialog1: TColorDialog;
    N2: TMenuItem;
    Reset1: TMenuItem;
    N3: TMenuItem;
    Info1: TMenuItem;
    N5: TMenuItem;
    MatAmbient1: TMenuItem;
    MatDiffuse1: TMenuItem;
    MatSpecular1: TMenuItem;
    MatEmission1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Ambient1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Diffuse1Click(Sender: TObject);
    procedure Specular1Click(Sender: TObject);
    procedure Reset1Click(Sender: TObject);
    procedure Info1Click(Sender: TObject);
    procedure MatAmbient1Click(Sender: TObject);
    procedure MatDiffuse1Click(Sender: TObject);
    procedure MatSpecular1Click(Sender: TObject);
    procedure MatEmission1Click(Sender: TObject);
  private
    DC: HDC;
    hrc: HGLRC;
    LightPos : Array [0..3] of GLfloat;
    Delta : GLfloat;
    procedure Init;
    procedure SetDCPixelFormat;
    procedure ColorToGL (c : TColor; var R, G, B : GLFloat);
  public
    Ambient, Specular, Diffuse : Array [0..3] of GLfloat;
    MaterialAmbient, MaterialSpecular,
    MaterialDiffuse, MaterialEmission : Array [0..3] of GLfloat;
    SHININESS : GLfloat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
  Sphere = 1;

var
  frmGL: TfrmGL;
  Closed : Boolean = False;

implementation

uses Unit1;

{$R *.DFM}

{=======================================================================
Перевод цвета из TColor в OpenGL}
procedure TfrmGL.ColorToGL (c : TColor; var R, G, B : GLFloat);
begin
 R := (c mod $100) / 255;
 G := ((c div $100) mod $100) / 255;
 B := (c div $10000) / 255;
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

 SHININESS := 20.0;

 Quadric := gluNewQuadric;

 glNewList (Sphere, GL_COMPILE);
   gluSphere (Quadric, 1.5, 50, 50);
 glEndList;

 LightPos [0] := 10.0;
 LightPos [1] := 10.0;
 LightPos [2] := 10.0;
 LightPos [3] := 0.0;

 MaterialAmbient [0] := 0.2;
 MaterialAmbient [1] := 0.2;
 MaterialAmbient [2] := 0.2;
 MaterialAmbient [3] := 1.0;

 MaterialDiffuse [0] := 0.8;
 MaterialDiffuse [1] := 0.8;
 MaterialDiffuse [2] := 0.8;
 MaterialDiffuse [3] := 1.0;

 MaterialSpecular [0] := 0.0;
 MaterialSpecular [1] := 0.0;
 MaterialSpecular [2] := 0.0;
 MaterialSpecular [3] := 1.0;

 MaterialEmission [0] := 0.0;
 MaterialEmission [1] := 0.0;
 MaterialEmission [2] := 0.0;
 MaterialEmission [3] := 1.0;

 Ambient [0] := 0.0;
 Ambient [1] := 0.0;
 Ambient [2] := 0.0;
 Ambient [3] := 1.0;

 Diffuse [0] := 1.0;
 Diffuse [1] := 1.0;
 Diffuse [2] := 1.0;
 Diffuse [3] := 1.0;

 Specular [0] := 1.0;
 Specular [1] := 1.0;
 Specular [2] := 1.0;
 Specular [3] := 1.0;
 gluDeleteQuadric (Quadric);
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix;
  glLightfv(GL_LIGHT0, GL_POSITION, @LightPos);
  glLightfv(GL_LIGHT0, GL_AMBIENT, @Ambient);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @Diffuse);
  glLightfv(GL_LIGHT0, GL_SPECULAR, @Specular);

  glMaterialfv (GL_FRONT, GL_AMBIENT, @MaterialAmbient);
  glMaterialfv (GL_FRONT, GL_DIFFUSE, @MaterialDiffuse);
  glMaterialfv (GL_FRONT, GL_SPECULAR, @MaterialSpecular);
  glMaterialfv (GL_FRONT, GL_EMISSION, @MaterialEmission);
  glMaterialf(GL_FRONT, GL_SHININESS, SHININESS);

  glCallList(Sphere);
  glPopMatrix;

  SwapBuffers(DC);
  EndPaint(Handle, ps);

  If not Closed then begin
     LightPos[0] := LightPos[0] + Delta;
     LightPos[1] := LightPos[1] + Delta;
     If LightPos[0] > 15.0
        then Delta := -1.0
        else If (LightPos[0] < -15.0) then
             Delta := 1.0;
     Application.ProcessMessages;
     InvalidateRect(Handle, nil, False);
  end;
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  Delta := 1.0;

  Init;
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight );
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 glFrustum(-1.0, 1.0, -1.0, 1.0, 6.0, 20.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef(0.0, 0.0, -12.0);
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
  If Key = Ord ('S') then begin
     If ssShift in Shift
        then SHININESS := SHININESS - 1
        else SHININESS := SHININESS + 1;
     If (SHININESS < 0) or (SHININESS > 128) then
        SHININESS := 0;
  end;
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


procedure TfrmGL.Ambient1Click(Sender: TObject);
begin
  If ColorDialog1.Execute then
     ColorToGL (ColorDialog1.Color, Ambient [0], Ambient [1], Ambient [2]);
end;

procedure TfrmGL.Diffuse1Click(Sender: TObject);
begin
  If ColorDialog1.Execute then
     ColorToGL (ColorDialog1.Color, Diffuse [0], Diffuse [1], Diffuse [2]);
end;

procedure TfrmGL.Specular1Click(Sender: TObject);
begin
  If ColorDialog1.Execute then
     ColorToGL (ColorDialog1.Color, Specular [0], Specular [1], Specular [2]);
end;

procedure TfrmGL.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Closed := True;
end;

procedure TfrmGL.Reset1Click(Sender: TObject);
begin
  Init
end;

procedure TfrmGL.Info1Click(Sender: TObject);
begin
  frmInfo.Show
end;

procedure TfrmGL.MatAmbient1Click(Sender: TObject);
begin
  If ColorDialog1.Execute then
     ColorToGL (ColorDialog1.Color, MaterialAmbient [0], MaterialAmbient [1],
                MaterialAmbient [2]);
end;

procedure TfrmGL.MatDiffuse1Click(Sender: TObject);
begin
  If ColorDialog1.Execute then
     ColorToGL (ColorDialog1.Color, MaterialDiffuse [0], MaterialDiffuse [1],
                MaterialDiffuse [2]);
end;

procedure TfrmGL.MatSpecular1Click(Sender: TObject);
begin
  If ColorDialog1.Execute then
     ColorToGL (ColorDialog1.Color, MaterialSpecular [0], MaterialSpecular [1],
                MaterialSpecular [2]);
end;

procedure TfrmGL.MatEmission1Click(Sender: TObject);
begin
  If ColorDialog1.Execute then
     ColorToGL (ColorDialog1.Color, MaterialEmission [0], MaterialEmission [1],
                MaterialEmission [2]);
end;

end.


