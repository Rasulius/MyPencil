{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus,
  Controls, Dialogs, SysUtils, OpenGL;

type
  TVector = record
    x, y, z : GLfloat;
  end;
  TPatch = Array [0..15] of TVector;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    DC: HDC;
    hrc: HGLRC;
    lastx: Integer;
    procedure init_surface;
    procedure Init;
    procedure SetDCPixelFormat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  AddX : GLfloat = 0.0;
  AddY : GLfloat = 0.0;
  AddZ : GLfloat = 0.0;
  Down : Boolean = False;

const
  SURFACE = 1;

implementation

{$R *.DFM}

{=======================================================================
Инициализация контрольных точек поверхности}
procedure TfrmGL.Init_Surface;
var
 f : TextFile;
 i : Integer;
 Model : TList;
 wrkPatch : TPatch;
 pwrkPatch : ^TPatch;
begin
 Model := TList.Create;
 AssignFile (f, 'Parrot.txt');
 ReSet (f);
 While not eof (f) do begin
   For i := 0 to 15 do
      ReadLn (f, wrkPatch [i].x, wrkPatch [i].y, wrkPatch [i].z);
   New (pwrkPatch);
   pwrkPatch^ := wrkPatch;
   Model.Add (pwrkPatch);
 end;
 CloseFile (f);

 glNewList (SURFACE, GL_COMPILE);
   glPushMatrix;
   glScalef (2.5, 2.5, 2.5);
   For i := 0 to Model.Count - 1 do begin
    glMap2f(GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, Model.Items[i]);
    glEvalMesh2(GL_FILL, 0, 4, 0, 4);
   end;
   glPopMatrix;
 glEndList;
 Model.Free;
end;

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
  position : Array [0..3] of GLFloat = (5.0, -3.0, -18.0, 0.0);
begin
  glEnable (GL_LIGHTING);
  glEnable (GL_LIGHT0);
  glLightfv(GL_LIGHT0, GL_POSITION, @position);
  glEnable (GL_DEPTH_TEST);
  glEnable (GL_AUTO_NORMAL);
  glEnable (GL_NORMALIZE);
  glEnable (GL_COLOR_MATERIAL);
  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, 1);

  glEnable(GL_MAP2_VERTEX_3);
  glMapGrid2f(4, 0.0, 1.0, 4, 0.0, 1.0);

  glClearColor (1.0, 1.0, 1.0, 1.0);
  glColor3f (1.0, 1.0, 0.0);

  init_surface;
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint (Handle, ps);

  glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix;

  glTranslatef (AddX, AddY, AddZ);

  glCallList (SURFACE);
  glPopMatrix;

  SwapBuffers (DC);
  EndPaint (Handle, ps);
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
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective (40.0, ClientWidth / ClientHeight, 1.0, 50.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef (0.0, -10.0, -18.0);
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  glDeleteLists (SURFACE, 1);
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
  Case Key of
     VK_ESCAPE : Close;
     Ord ('X') : If ssShift in Shift
                    then AddX := AddX - 0.3
                    else AddX := AddX + 0.3;
     Ord ('Y') : If ssShift in Shift
                    then AddY := AddY - 0.3
                    else AddY := AddY + 0.3;
     Ord ('Z') : If ssShift in Shift
                    then AddZ := AddZ - 0.3
                    else AddZ := AddZ + 0.3;
  end;
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Движение мыши}
procedure TfrmGL.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  If down then begin
     glRotatef (lastX - X, 0.0, 1.0, 0.0);
     lastX := X;
     InvalidateRect(Handle, nil, False);
  end;
end;

{=======================================================================
Кнопка мыши отжата}
procedure TfrmGL.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  down := False;
end;

{=======================================================================
Кнопка мыши нажата}
procedure TfrmGL.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  lastX := X;
  down := True;
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

