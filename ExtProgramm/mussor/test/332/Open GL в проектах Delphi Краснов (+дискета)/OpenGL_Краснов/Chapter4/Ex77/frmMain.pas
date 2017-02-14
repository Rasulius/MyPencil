{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, OpenGL;

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

    procedure SetDCPixelFormat;
    procedure Init;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  Angle : GLfloat = 0.0;
  time : LongInt;
  mode : Boolean = True;

implementation

uses DGLUT;

{$R *.DFM}

const
pattern : Array [0..16 * 8 - 1] of GLubyte =
   ($00, $00, $00, $00, $00, $00, $00, $00,
    $03, $80, $01, $C0, $06, $C0, $03, $60,
    $04, $60, $06, $20, $04, $30, $0C, $20,
    $04, $18, $18, $20, $04, $0C, $30, $20,
    $04, $06, $60, $20, $44, $03, $C0, $22,
    $44, $01, $80, $22, $44, $01, $80, $22,
    $44, $01, $80, $22, $44, $01, $80, $22,
    $44, $01, $80, $22, $44, $01, $80, $22,
    $66, $01, $80, $66, $33, $01, $80, $CC,
    $19, $81, $81, $98, $0C, $C1, $83, $30,
    $07, $e1, $87, $e0, $03, $3f, $fc, $c0,
    $03, $31, $8c, $c0, $03, $33, $cc, $c0,
    $06, $64, $26, $60, $0c, $cc, $33, $30,
    $18, $cc, $33, $18, $10, $c4, $23, $08,
    $10, $63, $C6, $08, $10, $30, $0c, $08,
    $10, $18, $18, $08, $10, $00, $00, $08);

p25 : Array [0..127] of GLUbyte =
( $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00,
  $aa, $aa, $aa, $aa, $00, $00, $00, $00
);
procedure TfrmGL.Init;
const
    lightpos : Array [0..3] of GLfloat = (0.5, 0.75, 1.5, 1.0);
begin
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);

    glLightfv(GL_LIGHT0, GL_POSITION, @lightpos);
    glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
    glEnable(GL_COLOR_MATERIAL);
    glEnable(GL_NORMALIZE);
    glColor3f(1.0, 0.5, 0.0);
end;


procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix;
    glScalef(5.0, 5.0, 5.0);
    glRotatef(Angle, 0.0, 1.0, 0.0);
    glutSolidDodecahedron;
  glPopMatrix;

  SwapBuffers(DC);

  EndPaint(Handle, ps);

  Angle := Angle + 0.1 * (GetTickCount - time) * 360 / 1000;
  If Angle >= 360.0 then Angle := 0.0;
  time := GetTickCount;

  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  Init;
  glPolygonStipple(@p25);
  glEnable(GL_POLYGON_STIPPLE);
  glEnable(GL_NORMALIZE);
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glOrtho(-10.0, 10.0, -10.0, 10.0, 0.0, 20.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(0.0, 0.0, -10.0);
  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close;
 If Key = VK_SPACE then begin
    mode := not mode;
    If mode
       then glPolygonStipple(@p25)
       else glPolygonStipple(@pattern);
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

end.

