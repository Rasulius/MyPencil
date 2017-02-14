{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{*********************************************************************}
{***              НАЛОЖЕНИЕ БЛИКОВ НА ТЕКСТУРУ                     ***}
{*** Пункты всплывающего меню содержат пункты различных режимов.   ***}
{*** OpenGL применяет текстуру после прорисовки отражающей         ***}
{*** составляющей источника света. Для смешения бликов и текстуры  ***}
{*** необходимо выполнить двухшаговый алгоритм:                    ***}
{*** 1. Нарисовать поверхность с текстурой без отражения источника ***}
{*** света;                                                        ***}
{*** 2. Включить смешение для следующего шага;                     ***}
{*** 3. Перерисовать поверхность с матовым белым материалом и      ***}
{*** только отражающей составляющей источника света.               ***}
{*********************************************************************}

// (c) Brian Paul  February 1997

unit frmMain;
interface

uses
 Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
 ExtCtrls, StdCtrls, Menus,
 OpenGL;

type
  TfrmGL = class(TForm)
    PopupMenu1: TPopupMenu;
    N1passlightingtexturing1: TMenuItem;
    specularlighting1: TMenuItem;
    diffuselightingtexturing1: TMenuItem;
    N2passlightingtexturing1: TMenuItem;
    Quit1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure N1passlightingtexturing1Click(Sender: TObject);
    procedure Quit1Click(Sender: TObject);
  private
    DC: HDC;
    hrc: HGLRC;
    uTimerId : uint;
    Quadric : GLUquadricObj;
    LightPos, Black, White : Array [0..3] of GLfloat;
    Delta : GLfloat;
    Mode : GLint;
    procedure Init;
    procedure SetDCPixelFormat;

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
 Sphere = 1;

var
  frmGL: TfrmGL;
  Angle : GLfloat = 0.0;

implementation

uses mmSystem;

{$R *.DFM}

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
var
 i, j, k : Integer;
 texImage : Array [0..63, 0..63, 0..2] of GLUbyte;
begin
 glEnable(GL_LIGHTING);
 glEnable(GL_LIGHT0);
 glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, 0);
 glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @Black);
 glMaterialfv(GL_FRONT, GL_DIFFUSE, @White);
 glMaterialfv(GL_FRONT, GL_SPECULAR, @White);
 glMaterialf(GL_FRONT, GL_SHININESS, 20.0);
 glLightfv(GL_LIGHT0, GL_DIFFUSE, @White);
 glLightfv(GL_LIGHT0, GL_SPECULAR, @White);
 Quadric := gluNewQuadric;
 gluQuadricTexture (Quadric, TRUE);

 glNewList (Sphere, GL_COMPILE);
   gluSphere (Quadric, 1.0, 24, 24);
 glEndList;

 For i := 0 to 63 do
    For j := 0 to 63 do begin
       k := ((i shr 3) and 1) xor ((j shr 3) and 1);
       texImage [i][j][0] := 255 * k;
       texImage [i][j][1] := 255 * (1 - k);
       texImage [i][j][2] := 0;
 end;
 glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
 glTexImage2D (GL_TEXTURE_2D, 0, 3, 64, 64, 0, GL_RGB, GL_UNSIGNED_BYTE,
               @texImage);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
 glEnable(GL_TEXTURE_2D);
 glEnable(GL_DEPTH_TEST);
 glEnable(GL_CULL_FACE);
 glBlendFunc(GL_ONE, GL_ONE);
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT );

  // меняем позицию источника света
  glLightfv(GL_LIGHT0, GL_POSITION, @LightPos);
  glPushMatrix;
  glRotatef(Angle, 1.0, 1.0, 1.0);
  Case Mode of
   0:begin
     // типичный способ: diffuse + specular + texture
     glEnable(GL_TEXTURE_2D);
     glLightfv(GL_LIGHT0, GL_DIFFUSE, @White);  // enable diffuse
     glLightfv(GL_LIGHT0, GL_SPECULAR, @White); // enable specular
     glCallList(Sphere);
     end;
   1:begin
     // только блик источника света
     glDisable(GL_TEXTURE_2D);
     glLightfv(GL_LIGHT0, GL_DIFFUSE, @Black);  // disable diffuse
     glLightfv(GL_LIGHT0, GL_SPECULAR, @White); // enable specular
     glCallList(Sphere);
     end;
   2:begin
     // только первый шаг
     glEnable(GL_TEXTURE_2D);
     glLightfv(GL_LIGHT0, GL_DIFFUSE, @White);  // enable diffuse
     glLightfv(GL_LIGHT0, GL_SPECULAR, @Black); // disable specular
     glCallList(Sphere);
     end;
   3:begin
     // 2 шага: после текстуры добавляем блик
     glEnable(GL_TEXTURE_2D);
     glLightfv(GL_LIGHT0, GL_DIFFUSE, @White);  // enable diffuse
     glLightfv(GL_LIGHT0, GL_SPECULAR, @Black); // disable specular
     glCallList(Sphere);
     // второй шаг
     glDisable(GL_TEXTURE_2D);
     glEnable(GL_BLEND);                        // режим смешения
     glLightfv(GL_LIGHT0, GL_DIFFUSE, @Black);  // disable diffuse
     glLightfv(GL_LIGHT0, GL_SPECULAR, @White); // enable specular
     glDisable(GL_DEPTH_TEST);
     glCallList(Sphere);
     glEnable(GL_DEPTH_TEST);
     glDisable(GL_BLEND);
     end;
  end; {case}
  glPopMatrix;

  SwapBuffers(DC);
  EndPaint(Handle, ps);
end;

{=======================================================================
Обработка таймера}
procedure FNTimeCallBack(uTimerID, uMessage: UINT;dwUser, dw1, dw2: DWORD) stdcall;
begin
  With frmGL do begin
    LightPos[0] := LightPos[0] + Delta;
    If LightPos[0] > 15.0
       then Delta := -1.0
       else If (LightPos[0] < -15.0) then
            Delta := 1.0;
    Angle := Angle + 2;
    If Angle >= 360.0 then Angle := 0.0;
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
  Mode := 0;
  LightPos [0] := 10.0;
  LightPos [1] := 10.0;
  LightPos [2] := 10.0;
  LightPos [3] := 1.0;
  Black [0] := 0.0;
  Black [1] := 0.0;
  Black [2] := 0.0;
  Black [3] := 1.0;
  White [0] := 1.0;
  White [1] := 1.0;
  White [2] := 1.0;
  White [3] := 1.0;
  Init;
  uTimerID := timeSetEvent (15, 0, @FNTimeCallBack, 0, TIME_PERIODIC);
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode( GL_PROJECTION );
 glLoadIdentity;
 glFrustum( -0.75, 0.75, -0.75, 0.75, 5.0, 25.0 );
 glMatrixMode( GL_MODELVIEW );
 glLoadIdentity;
 glTranslatef( 0.0, 0.0, -12.0 );
 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  timeKillEvent(uTimerID);
  glDeleteLists (sphere, 1);
  gluDeleteQuadric (Quadric);
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
Пункты меню}
procedure TfrmGL.N1passlightingtexturing1Click(Sender: TObject);
begin
  Mode := (Sender as TComponent).Tag;
end;

{=======================================================================
Пункт меню "Quit"}
procedure TfrmGL.Quit1Click(Sender: TObject);
begin
  Close;
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

end.


