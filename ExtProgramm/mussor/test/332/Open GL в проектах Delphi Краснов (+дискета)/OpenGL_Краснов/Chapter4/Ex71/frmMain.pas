{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{/*
 *  decal.c
 *  Brad Grantham, 1997
 *
 *  Demonstrates how to use the stencil buffer to produce decals on
 *  co-planar surfaces.
 */}

unit frmMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Menus, OpenGL;

type
  TfrmGL = class(TForm)
    PopupMenu1: TPopupMenu;
    turnonstencildecal1: TMenuItem;
    visiblebuffer1: TMenuItem;
    Colorbuffer1: TMenuItem;
    Stencilbuffer1: TMenuItem;
    Depthbuffre1: TMenuItem;
    Finishframeafter1: TMenuItem;
    Clearingscreen1: TMenuItem;
    Drawingairplane1: TMenuItem;
    Drawingground1: TMenuItem;
    Drawingasphalt1: TMenuItem;
    Drawingpaint1: TMenuItem;
    Drawingshadow1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure turnonstencildecal1Click(Sender: TObject);
    procedure Colorbuffer1Click(Sender: TObject);
    procedure Stencilbuffer1Click(Sender: TObject);
    procedure Depthbuffre1Click(Sender: TObject);
    procedure Clearingscreen1Click(Sender: TObject);

  private
    DC: HDC;
    hrc: HGLRC;

    procedure SetDCPixelFormat;
    procedure Init;
    procedure pushOrthoView(left, right, bottom, top, znear, zfar : GLfloat);
    procedure popView;
    procedure copyDepthToColor(whichColorBuffer : GLenum);
    procedure copyStencilToColor(whichColorBuffer : GLenum);
    procedure setupLight;
    procedure setupNormalDrawingState;
    procedure setupDecalState(decalNum : GLint);
    procedure setupBasePolygonState(maxDecal : GLint);
    procedure drawStripes;
    procedure drawAsphalt;
    procedure drawGround;
    procedure drawAirplane;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
  winWidth = 400;
  winHeight = 400;

var
  depthSave : Array [0..winWidth * winHeight-1] of GLfloat;
  colorSave : Array [0..3*winWidth * winHeight-1] of GLUbyte;
  stencilSave : Array [0..winWidth * winHeight-1] of GLUbyte;
  quadric : GLUquadricObj;
  Down : Boolean = False;
  ox : GLint;
  oy : GLint;
  ang : GLfloat = 0;
  sheight : GLfloat = 10;
  useStencil : Boolean = True;
  stage : GLint = 6;
  dataChoice : (DCOLOR, DEPTH, STENCIL)  = DCOLOR;
  numStripes : GLint = 5;
  stripeGap  : GLfloat = 0.66;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

procedure TfrmGL.pushOrthoView(left, right, bottom, top, znear, zfar : GLfloat);
begin
  glPushMatrix;
  glLoadIdentity;
  glMatrixMode(GL_PROJECTION);
  glPushMatrix;
  glLoadIdentity;
  glOrtho(left, right, bottom, top, znear, zfar);
end;

procedure TfrmGL.popView;
begin
  glPopMatrix;
  glMatrixMode(GL_MODELVIEW);
  glPopMatrix;
end;

procedure TfrmGL.copyDepthToColor(whichColorBuffer : GLenum);
var
  x, y : GLint;
  max, min : GLfloat;
  previousColorBuffer : GLint;
begin
  glReadPixels(0, 0, winWidth, winHeight, GL_DEPTH_COMPONENT, GL_FLOAT,
      @depthSave);

  //* I'm sure this could be done much better with OpenGL */
  max := 0;
  min := 1;
  For y := 0 to winHeight - 1 do
      For x := 0 to winWidth - 1 do begin
        If (depthSave[winWidth * y + x] < min)
            then min := depthSave[winWidth * y + x];
  	If (depthSave[winWidth * y + x] > max) and (depthSave[winWidth * y + x] < 0.999)
            then max := depthSave[winWidth * y + x];
  end;

  For y := 0 to winHeight - 1 do
      For x := 0 to winWidth - 1 do
  	If (depthSave[winWidth * y + x] <= max)
 	    then depthSave[winWidth * y + x] := 1 -  (depthSave[winWidth * y + x] - min) / (max - min)
  	    else depthSave[winWidth * y + x] := 0;

  pushOrthoView(0, 1, 0, 1, 0, 1);
  glRasterPos3f(0, 0, -0.5);
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_STENCIL_TEST);
  glColorMask(TRUE, TRUE, TRUE, TRUE);
  glGetIntegerv(GL_DRAW_BUFFER, @previousColorBuffer);
  glDrawBuffer(whichColorBuffer);
  glDrawPixels(winWidth, winHeight, GL_LUMINANCE , GL_FLOAT, @depthSave);
  glDrawBuffer(previousColorBuffer);
  glEnable(GL_DEPTH_TEST);
  popView;
end;

const
colors : Array [0..6, 0..2] of Byte =
(
    (255, 0, 0),	//* red *//
    (255, 218, 0),	//* yellow *//
    (72, 255, 0),	//* yellowish green *//
    (0, 255, 145),	//* bluish cyan *//
    (0, 145, 255),	//* cyanish blue *//
    (72, 0, 255),	//* purplish blue *//
    (255, 0, 218)	//* reddish purple *//
);

procedure TfrmGL.copyStencilToColor(whichColorBuffer : GLenum);
var
  x, y : GLint;
  previousColorBuffer : GLint;
  stencilValue : GLint;
begin
  glReadPixels(0, 0, winWidth, winHeight, GL_STENCIL_INDEX, GL_UNSIGNED_BYTE,
      @stencilSave);

  //* I'm sure this could be done much better with OpenGL */
  For y := 0 to winHeight - 1 do
      For x := 0 to winWidth - 1 do begin
          stencilValue := stencilSave [winWidth * y + x];

          colorSave[(winWidth * y + x) * 3 + 0] := colors[stencilValue mod 7][0];
          colorSave[(winWidth * y + x) * 3 + 1] := colors[stencilValue mod 7][1];
          colorSave[(winWidth * y + x) * 3 + 2] := colors[stencilValue mod 7][2];
  end;

  pushOrthoView(0, 1, 0, 1, 0, 1);
  glRasterPos3f(0, 0, -0.5);
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_STENCIL_TEST);
  glColorMask(TRUE, TRUE, TRUE, TRUE);
  glGetIntegerv(GL_DRAW_BUFFER, @previousColorBuffer);
  glDrawBuffer(whichColorBuffer);
  glDrawPixels(winWidth, winHeight, GL_RGB, GL_UNSIGNED_BYTE, @colorSave);
  glDrawBuffer(previousColorBuffer);
  glEnable(GL_DEPTH_TEST);
  popView;
end;

procedure TfrmGL.Init;
begin
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_CULL_FACE);
  glCullFace(GL_BACK);

  quadric := gluNewQuadric;
  glMatrixMode(GL_PROJECTION);
  glFrustum(-0.33, 0.33, -0.33, 0.33, 0.5, 40);

  glMatrixMode(GL_MODELVIEW);
  gluLookAt(-4, 10, 6, 0, 0, 0, 0, 1, 0);

  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);

  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  glEnable(GL_NORMALIZE);
{    /*
     * only need this to clear stencil and only need to clear stencil
     * when you're looking at it; the algorithm works without it.
     */}
  glClearStencil(5);
end;

procedure TfrmGL.setupLight;
const
  lightpos : Array [0..3] of GLfloat = (0, 1, 0, 0);
begin
  glLightfv(GL_LIGHT0, GL_POSITION, @lightpos);
end;

procedure TfrmGL.setupNormalDrawingState;
begin
  glDisable(GL_STENCIL_TEST);
  glEnable(GL_DEPTH_TEST);
  glDepthMask(TRUE);
end;

procedure TfrmGL.setupBasePolygonState(maxDecal : GLint);
begin
  glEnable(GL_DEPTH_TEST);
  If useStencil then begin
     glEnable(GL_STENCIL_TEST);
     glStencilFunc(GL_ALWAYS, maxDecal + 1, $ff);
     glStencilOp(GL_KEEP, GL_REPLACE, GL_ZERO);
  end
end;

procedure TfrmGL.setupDecalState(decalNum : GLint);
begin
  If useStencil then begin
     glDisable(GL_DEPTH_TEST);
     glDepthMask(FALSE);
     glEnable(GL_STENCIL_TEST);
     glStencilFunc(GL_GREATER, decalNum, $ff);
     glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
  end
end;

procedure TfrmGL.drawAirplane;
const
  airplaneColor : Array [0..3] of GLfloat = (0.75, 0.75, 0.75, 1);
begin
  glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, @airplaneColor);

  glDisable(GL_CULL_FACE);
  glPushMatrix;
  glTranslatef(0, 0, -2.5);

  gluCylinder(quadric, 0.5, 0.5, 5, 10, 10);

  glPushMatrix;
  glTranslatef(0, 0, 5);
  gluCylinder(quadric, 0.5, 0, 1, 10, 10);
  glPopMatrix;
  glPushMatrix;
  glTranslatef(0, 0, 3);
  glScalef(3, 0.1, 1);
  gluSphere(quadric, 1, 10, 10);
  glPopMatrix;

  glPushMatrix;
  glTranslatef(0, 0, 0.5);
  glScalef(2, 0.1, 0.5);
  gluSphere(quadric, 1, 10, 10);
  glPopMatrix;

  glEnable(GL_CULL_FACE);

  glBegin(GL_TRIANGLES);
  glNormal3f(1, 0, 0);
  glVertex3f(0, 1.5, 0);
  glVertex3f(0, 0.5, 1);
  glVertex3f(0, 0.5, 0);
  glNormal3f(-1, 0, 0);
  glVertex3f(0, 1.5, 0);
  glVertex3f(0, 0.5, 0);
  glVertex3f(0, 0.5, 1);
  glEnd;

  glDisable(GL_CULL_FACE);

  glRotatef(180, 0, 1, 0);
  gluDisk(quadric, 0, 0.5, 10, 10);

  glPopMatrix;

  glEnable(GL_CULL_FACE);
end;

procedure TfrmGL.drawGround;
const
  groundColor : Array [0..3] of GLfloat = (0.647, 0.165, 0.165, 1);
begin
  glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, @groundColor);

  glBegin(GL_QUADS);
  glNormal3i(0, 1, 0);
  glVertex3f(10, 0, 10);
  glVertex3f(10, 0, -10);
  glVertex3f(-10, 0, -10);
  glVertex3f(-10, 0, 10);
  glEnd;
end;

procedure TfrmGL.drawAsphalt;
const
  asphaltColor : Array [0..3] of GLfloat = (0.25, 0.25, 0.25, 1);
begin
  glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, @asphaltColor);

  glBegin(GL_QUADS);
  glNormal3i(0, 1, 0);
  glVertex3f(5, 0, 9.5);
  glVertex3f(5, 0, -9.5);
  glVertex3f(-5, 0, -9.5);
  glVertex3f(-5, 0, 9.5);
  glEnd;
end;

procedure TfrmGL.drawStripes;
const
  stripeColor : Array [0..3] of GLfloat = (1, 1, 0, 1);
var
  i : GLint;
  stripeLength : GLfloat;
begin
  stripeLength := (16 - stripeGap * (numStripes - 1)) / numStripes;

  glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, @stripeColor);

  glBegin(GL_QUADS);
  glNormal3i(0, 1, 0);
  glVertex3f(4.5, 0, 8.5);
  glVertex3f(4.5, 0, -8.5);
  glVertex3f(3.5, 0, -8.5);
  glVertex3f(3.5, 0, 8.5);

  glVertex3f(-3.5, 0, 8.5);
  glVertex3f(-3.5, 0, -8.5);
  glVertex3f(-4.5, 0, -8.5);
  glVertex3f(-4.5, 0, 8.5);

  For i := 0 to numStripes - 1 do begin
      glVertex3f(0.5, 0, 8 - i * (stripeLength + stripeGap));
      glVertex3f(0.5, 0, 8 - i * (stripeLength + stripeGap) - stripeLength);
      glVertex3f(-0.5, 0, 8 - i * (stripeLength + stripeGap) - stripeLength);
      glVertex3f(-0.5, 0, 8 - i * (stripeLength + stripeGap));
  end;
  glEnd;
end;

procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
label
  doneWithFrame;
begin
  BeginPaint(Handle, ps);

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  //* Only need this If you care to look at the stencil buffer */
  If dataChoice = STENCIL
     then glClear(GL_STENCIL_BUFFER_BIT);

  glPushMatrix;
  glScalef(0.5, 0.5, 0.5);
  If stage = 1
     then goto doneWithFrame;

  setupLight;

  setupNormalDrawingState;
  glPushMatrix;
  glTranslatef(0, 1, 4);
  glRotatef(135, 0, 1, 0);
  drawAirplane;
  glPopMatrix;
  If stage = 2
     then goto doneWithFrame;

  setupBasePolygonState(3);	//* 2 decals */
  drawGround;
  If stage = 3
     then goto doneWithFrame;

  setupDecalState(1);		//* decal # 1 = the runway asphalt */
  drawAsphalt;
  If stage = 4
     then goto doneWithFrame;

  setupDecalState(2);		//* decal # 2 = yellow paint on the runway */
  drawStripes;
  If stage = 5
     then goto doneWithFrame;

  setupDecalState(3);		//* decal # 3 = the plane's shadow */
  glDisable(GL_LIGHTING);
  glEnable(GL_BLEND);
  glPushMatrix;
  glColor4f(0, 0, 0, 0.5);
  glTranslatef(0, 0, 4);
  glRotatef(135, 0, 1, 0);
  glScalef(1, 0, 1);
  drawAirplane;
  glPopMatrix;
  glDisable(GL_BLEND);
  glEnable(GL_LIGHTING);

{label} doneWithFrame:
  setupNormalDrawingState;

  glPopMatrix;

//    If  dataChoice = DCOLOR then Exit;
  If  dataChoice = STENCIL
      then copyStencilToColor(GL_BACK);
  If  dataChoice = DEPTH
      then copyDepthToColor(GL_BACK);

  SwapBuffers(DC);
  EndPaint(Handle, ps);
end;

procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  Init;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  gluDeleteQuadric (quadric);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close;
 If (Key >= 49) and (Key<=54) then begin
    stage := Key - 48;
    InvalidateRect(Handle, nil, False);
 end;
end;

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

procedure TfrmGL.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  eyex, eyez : GLfloat;
begin
  If Down then begin
        ang := ang + (x - ox) / 512.0 * PI;
        sheight := sheight + (y - oy) / 512.0 * 10;
	eyex := cos(ang) * 7;
	eyez := sin(ang) * 7;
	glLoadIdentity;
	gluLookAt(eyex, sheight, eyez, 0, 0, 0, 0, 1, 0);
        InvalidateRect(Handle, nil, False);
	ox := x;
	oy := y;
  end;
end;

procedure TfrmGL.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Down := True;
  ox := x;
  oy := y;
end;

procedure TfrmGL.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Down := False;
end;

procedure TfrmGL.turnonstencildecal1Click(Sender: TObject);
begin
  useStencil := not useStencil;
  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.Colorbuffer1Click(Sender: TObject);
begin
 dataChoice := DCOLOR;
 InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.Stencilbuffer1Click(Sender: TObject);
begin
 dataChoice := STENCIL;
 InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.Depthbuffre1Click(Sender: TObject);
begin
 dataChoice := DEPTH;
 InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.Clearingscreen1Click(Sender: TObject);
begin
 stage := (Sender as TMenuItem).Tag;
 InvalidateRect(Handle, nil, False);
end;

end.

