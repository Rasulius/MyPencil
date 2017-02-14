{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Controls,
  SysUtils, Dialogs,
  OpenGL;

 type
  TVector = record
    x, y, z : GLfloat;
  end;
  TPatch = Array [0..24] of TVector;

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
    AngX, AngY, AngZ : GLfloat;
    procedure Init;
    procedure init_surface;
    procedure SetDCPixelFormat;

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
  ROZA = 1;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}


{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
  ambient : Array [0..3] of GLFloat = (0.2, 0.2, 0.2, 1.0);
  position1 : Array [0..3] of GLFloat = (0.0, 2.0, -2.0, 0.0);
  position2 : Array [0..3] of GLFloat = (0.0, 2.0, 5.0, 0.0);
  mat_diffuse : Array [0..3] of GLFloat = (1.0, 0.0, 0.0, 1.0);
  mat_specular : Array [0..3] of GLFloat = (1.0, 1.0, 1.0, 0.0);
  mat_shininess : GLFloat = 2.0;
begin
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_AUTO_NORMAL);
  glEnable(GL_NORMALIZE);

  // источник света
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glEnable(GL_LIGHT1);
  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, 1);
  glLightfv(GL_LIGHT0, GL_AMBIENT, @ambient);
  glLightfv(GL_LIGHT0, GL_POSITION, @position1);
  glLightfv(GL_LIGHT1, GL_POSITION, @position2);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, @mat_diffuse);
  glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, @mat_specular);
  glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, @mat_shininess);
  glEnable (GL_COLOR_MATERIAL);
  glClearColor (0.0, 0.75, 1.0, 1.0);
  // поверхность
  glEnable(GL_MAP2_VERTEX_3);
  glMapGrid2f(20, 0.0, 1.0, 20, 0.0, 1.0);

  init_surface;
end;

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
 AssignFile (f, 'Roza.txt');
 ReSet (f);
 While not eof (f) do begin
   For i := 0 to 24 do
      ReadLn (f, wrkPatch [i].x, wrkPatch [i].y, wrkPatch [i].z);
   New (pwrkPatch);
   pwrkPatch^ := wrkPatch;
   Model.Add (pwrkPatch);
 end;
 CloseFile (f);

 glNewList (ROZA, GL_COMPILE);
   glPushMatrix;
   glScalef (0.5, 0.5, 0.5);
   For i := 0 to 11 do begin
     glColor3f (1.0, 0.0, 0.0);
     glMap2f(GL_MAP2_VERTEX_3, 0, 1, 3, 5, 0, 1, 15, 5, Model.Items[i]);
     glEvalMesh2(GL_FILL, 0, 20, 0, 20);
   end;

   For i := 12 to  Model.Count - 1 do begin
     glColor3f (0.0, 1.0, 0.0);
     glMap2f(GL_MAP2_VERTEX_3, 0, 1, 3, 5, 0, 1, 15, 5, Model.Items[i]);
     glEvalMesh2(GL_FILL, 0, 20, 0, 20);
   end;

   glPopMatrix;
 glEndList;
 Model.Free;
end;


{=======================================================================
Перерисовка окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint (Handle, ps);

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix;
    glRotatef(AngX, 1.0, 0.0, 0.0);
    glRotatef(AngY, 0.0, 1.0, 0.0);
    glRotatef(AngZ, 0.0, 0.0, 1.0);

    glCallList (ROZA);
  glPopMatrix;

  SwapBuffers (DC);
  EndPaint (Handle, ps);
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluPerspective (20.0, ClientWidth / ClientHeight, 1.0, 50.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef (0.0, 0.0, -18.0);
 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  glDeleteLists (ROZA, 1);
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
    VK_ESCAPE : begin
                Close;
                Exit;
                end;
    VK_LEFT :   AngY := AngY + 5;
    VK_UP :     AngZ := AngZ + 5;
    VK_RIGHT :  AngX := AngX + 5;
  end;
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
  Init;
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

