{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

//* Copyright (c) Mark J. Kilgard, 1997.  */

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ExtCtrls,
  Menus, Dialogs,
  OpenGL;

type
  TfrmGL = class(TForm)
    PopupMenu1: TPopupMenu;
    Blendon1: TMenuItem;
    Blendoff1: TMenuItem;
    Resettime1: TMenuItem;
  procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure Blendon1Click(Sender: TObject);
    procedure Blendoff1Click(Sender: TObject);
    procedure Resettime1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

  private
    DC: HDC;
    hrc: HGLRC;
    procedure DrawScene;
    procedure InitializeRC;
    procedure SetDCPixelFormat;
    
  public
    procedure makePointList;
    procedure updatePointList;
    procedure recalcModelView;
    function  randomRange(lo, hi: GLfloat): GLfloat;

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
 end;

const
  constant: Array[1..3]of GLfloat=(1/5.0, 0.0, 0.0);
  linear: Array[1..3]of GLfloat=(0.0, 1/5.0, 0.0);
  theQuad: Array[1..3]of GLfloat=(0.25, 0.0, 1/60.0);
  colorSet: Array[0..5, 0..3]of GLfloat=((0.7, 0.2, 0.4, 0.5),
                 {оттенки красного}      (0.8, 0.0, 0.7, 0.5),
                  {пока 6}               (1.0, 0.0, 0.0, 0.5),
                                         (0.9, 0.3, 0.6, 0.5),
                                         (1.0, 0.4, 0.0, 0.5),
                                         (1.0, 0.0, 0.5, 0.5)
                                                            );

  MAX_POINTS=2000;
  NUM_COLORS=round((sizeof(colorSet)/sizeof(colorSet[0])));
  DEAD=(NUM_COLORS+1);
  MEAN_VELOCITY=3.0;
  GRAVITY=2.0;
  TIME_DELTA=0.05; {шаг по времени}
  EDGE=12.0;
  POINT_SIZE=8.0;

var
  frmGL: TfrmGL;
  angle: GLfloat;
  moving: integer;
  newModel: boolean;
  theTime: GLfloat;
  blend: boolean;
  numPoints: integer;
  motion: boolean;
  pointList: Array [0..MAX_POINTS - 1, 0..2] of GLfloat;
  pointTime: Array [0..MAX_POINTS - 1] of GLfloat;
  pointVelocity: Array [0..MAX_POINTS - 1, 0..1] of GLfloat;
  pointDirection: Array [0..MAX_POINTS - 1, 0..1] of GLfloat;
  colorList: Array [0..MAX_POINTS - 1] of GLint;
  Closed : Boolean = False;

implementation

{$R *.DFM}

function TfrmGL.randomRange(lo, hi: GLfloat): GLfloat;
begin
 Result := random*(hi-lo) + lo;
end;

procedure TfrmGL.makePointList;
var
 angle_in, velocity, direction: GLfloat;
 i : integer;
begin
 motion := true;
 For i := 0 to numPoints do begin
  pointList[i][0] := 0.0;
  pointList[i][1] := 0.0;
  pointList[i][2] := 0.0;
  pointTime[i] := 0.0;
  angle_in := randomRange(60.0, 70.0)*Pi/180.0;
  direction := randomRange(0.0, 360.0)*Pi/180.0;
  pointDirection[i][0] := cos(direction);
  pointDirection[i][1] := sin(direction);
  velocity := MEAN_VELOCITY + randomRange(-0.8, 1.0);
  pointVelocity[i][0] := velocity*cos(angle_in);
  pointVelocity[i][1] := velocity*sin(angle_in);
  colorList[i] := random(NUM_COLORS);
 end;
 theTime:=0.0;
end;

procedure TfrmGL.updatePointList;
var
 distance: GLfloat;
 i: integer;
begin
 motion := false;
 For i := 0 to numPoints do begin
  distance := pointVelocity[i][0]*theTime;

  {X and Z}
  pointList[i][0]:=pointDirection[i][0]*distance;
  pointList[i][2]:=pointDirection[i][1]*distance;
  {Z}
  pointList[i][1]:=
  (pointVelocity[i][1] - 0.5 * GRAVITY * pointTime[i])*pointTime[i];

  {при ударе о землю точка отскакивает}
  If pointList[i][1]<=0.0 then begin
   If distance > EDGE
      then colorList[i] := NUM_COLORS;
   pointVelocity[i][1]:=pointVelocity[i][1]*0.8; {80% предыдущей скорости}
   pointTime[i]:=0.0;
  end;
  motion:=true;
  pointTime[i]:=pointTime[i]+TIME_DELTA;
 end;
 theTime := theTime + TIME_DELTA;
end;

procedure TfrmGL.recalcModelView;
begin
 glPopMatrix;
 glPushMatrix;
 glRotatef(angle, 0.0, 1.0, 0.0);
 newModel:=false;
end;

procedure TfrmGL.InitializeRC;
begin
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_POINT_SMOOTH);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glPointSize(POINT_SIZE);
  glMatrixMode(GL_PROJECTION);
  gluPerspective(40.0, 1.0, 0.5, 40.0);
  glMatrixMode(GL_MODELVIEW);
  gluLookAt( 0.0, 1.0, 8.0, {положение наблюдателя}
  0.0, 1.0, 0.0,            {центр в точке (0, 0, 0)}
  0.0, 1.0, 0.0);           {верх - положительное направление оси Y}
  glPushMatrix;             {}
end;

procedure TfrmGL.DrawScene;
var
 i: integer;
begin
  // очистка буфера цвета и буфера глубины
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  If newModel then recalcModelView;
  glDisable(GL_BLEND);

  {рисуем пол}
  glColor3f(0.5, 1.0, 0.5);
  glBegin(GL_QUADS);
   glVertex3f(-EDGE, -0.25, -EDGE);
   glVertex3f(EDGE, -0.25, -EDGE);
   glVertex3f(EDGE, -0.25, EDGE);
   glVertex3f(-EDGE, -0.25, EDGE);
  glEnd;

  If blend then glEnable(GL_BLEND);

  glBegin(GL_POINTS);
   For i := 0 to numPoints do
     If colorList[i] <> DEAD then begin
      glColor4fv(@colorSet[colorList[i]]);
      glVertex3fv(@pointList[i]);
     end;
  glEnd;

  SwapBuffers(DC);
end;

procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);
  DrawScene;
  updatePointList;
  EndPaint(Handle, ps);
  If not Closed then begin
    Application.ProcessMessages;
    InvalidateRect(frmGL.Handle, nil, False);
  end;
end;

procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

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
  DescribePixelFormat(DC, nPixelFormat, sizeof(TPixelFormatDescriptor), pfd);
end;

procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  InitializeRC;
  angle:=-150.0;
  newModel:=true;
  blend:=true;
  numPoints := 200;
  motion:=false;

  makePointList;
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close;
 If Key = VK_RETURN then makePointList;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, Width, Height);
  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.Blendon1Click(Sender: TObject);
begin
  Blend := True
end;

procedure TfrmGL.Blendoff1Click(Sender: TObject);
begin
  Blend := False
end;

procedure TfrmGL.Resettime1Click(Sender: TObject);
begin
  makePointList;
end;

procedure TfrmGL.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Closed := True
end;

end.
