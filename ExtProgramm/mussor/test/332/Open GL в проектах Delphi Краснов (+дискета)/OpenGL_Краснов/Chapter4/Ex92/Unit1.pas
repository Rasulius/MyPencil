{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls,
  OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    DC: HDC;
    hrc: HGLRC;
    ps : TPaintStruct;
    uTimerId : uint;
    spin : GLFloat;
    step: single;
    procedure SetDCPixelFormat;
    procedure make;
  protected
    { Public declarations }
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

const
  CyList=1;

implementation

uses mmSystem;

{$R *.DFM}

{======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
begin
 BeginPaint(Handle, ps);

 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 glPushMatrix;
 gluLookAt(10*cos(spin), 5*cos(spin)*sin(spin), 15*sin(spin),
           0.0, 0.0, 0.0,  1.0, 0.0, 0.0);
 glCallList(CyList);
 glPopMatrix;

 SwapBuffers(DC);

 EndPaint(Handle, ps);
end;
{======================================================================
Подготовка списков}
procedure TfrmGL.make;
var
  q : GLUquadricObj;
begin
  q := gluNewQuadric;
  glNewList(CyList, GL_COMPILE);
   glTranslatef(0.0, 0.0, -1.0);
   gluQuadricNormals(q, GL_SMOOTH);
   gluQuadricTexture(q, TRUE);
   gluCylinder(q, 0.6, 0.6, 2.0, 24, 1);
   glTranslatef(0.0, 0.0, 2.0);
   gluDisk(q, 0.0, 0.6, 24, 1);
   glTranslatef(0.0, 0.0, -2.0);
   gluQuadricOrientation(q, GLU_INSIDE);
   gluDisk(q, 0.0, 0.6, 24, 1);
  glEndList;
  gluDeleteQuadric(q);

  glEnable(GL_CULL_FACE);
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
  glHint(GL_LINE_SMOOTH_HINT, GL_FASTEST);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND);
  glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
  glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);

  glEnable(GL_TEXTURE_2D);
  glEnable(GL_TEXTURE_GEN_S);
  glEnable(GL_TEXTURE_GEN_T);
end;

function ReadBitmap(const FileName : String;
                    var sWidth, tHeight: GLsizei): pointer;
const
  szh = SizeOf(TBitmapFileHeader);
  szi = SizeOf(TBitmapInfoHeader);
type
  TRGB = record
    r, g, b : GLbyte;
  end;
  TWrap = Array [0..0] of TRGB;
var
  BmpFile : File;
  bfh : TBitmapFileHeader;
  bmi : TBitmapInfoHeader;
  x, size: GLint;
  temp: GLbyte;
begin
  AssignFile (BmpFile, FileName);
  Reset (BmpFile, 1);
  Size := FileSize (BmpFile) - szh - szi;
  Blockread(BmpFile, bfh, szh);
  BlockRead (BmpFile, bmi, szi);
  If Bfh.bfType <> $4D42 then begin
    MessageBox(0, 'Invalid Bitmap', 'Error', MB_OK);
    Result := nil;
    Exit;
  end;
  sWidth := bmi.biWidth;
  tHeight := bmi.biHeight;
  GetMem (Result, Size);
  BlockRead(BmpFile, Result^, Size);
  For x := 0 to sWidth*tHeight-1 do
    With TWrap(result^)[x] do begin
      temp := r;
      r := b;
      b := temp;
  end;
end;

{======================================================================
Тик таймера}
procedure FNTimeCallBack (uTimerID, uMessage: UINT; dwUser, dw1, dw2: DWORD) stdcall;
begin
 With frmGL do begin
  if spin<360.0
     then spin:=spin+step
     else step:=-step;
  InvalidateRect(Handle, nil, False);
 end;
end;

procedure TfrmGL.FormCreate(Sender: TObject);
var
  sWidth,
  tHeight: GLsizei;
  wrkPointer : Pointer;
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  glPixelStorei(GL_UNPACK_ALIGNMENT,1);

  wrkPointer := ReadBitmap('..\earth.bmp',sWidth,tHeight);

  glTexImage2D(GL_TEXTURE_2D, 0, 3, sWidth, tHeight, 0,
               GL_RGB,GL_UNSIGNED_BYTE, wrkPointer);
  Freemem(wrkPointer);

  make; // подготовить объекты

  spin := 0.0;
  step:=-0.005;

  glEnable(GL_NORMALIZE);
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);

  glClearColor(0.2, 0.2, 0.2, 1.0);
  uTimerID := timeSetEvent(4, 0, @FNTimeCallBack, 0, TIME_PERIODIC);
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glFrustum(-0.5 * ClientWidth / ClientHeight,
             0.5 * ClientWidth / ClientHeight,
            -0.5, 0.5, 4.0, 25.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  timeKillEvent (uTimerID);
  glDeleteLists (CyList, 1);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

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

  pfd.dwFlags   := PFD_DRAW_TO_WINDOW or
                 PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;
  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;

end.
