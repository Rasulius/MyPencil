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
  Vector = record
    x, y, z : GLfloat;
  end;

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
    Model, Normals : TList;
    lastx, down : Integer;

    procedure Init;
    procedure CalcNormals;
    procedure SetDCPixelFormat;
    procedure LoadDXF (st : String);
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
  SURFACE = 1;

var
  frmGL: TfrmGL;
  Angle : GLfloat = 0;
  Step : GLfloat = 1;
  wrkStep : GLfloat = 1;
  wrkTime : longint;
  wrkX, wrkY : Integer;

implementation

{$R *.DFM}

{$WARNINGS OFF}
procedure TfrmGL.LoadDXF (st : String);
var
  f : TextFile;
  wrkString : String;
  group, err : GLint;
  x1, x2, y1, y2, z1, z2, x3, y3, z3 : GLfloat;

procedure AddToList (x, y, z : GLfloat);
var
  wrkVector : Vector;
  pwrkVector : ^Vector;
begin
  wrkVector.x := x;
  wrkVector.y := y;
  wrkVector.z := z;
  New (pwrkVector);
  pwrkVector^ := wrkVector;
  Model.Add (pwrkVector);
end;

begin
  AssignFile(f,st);
  Reset(f);
  repeat // пропускаем файл до секции объектов "ENTITIES"
    ReadLn(f, wrkString);
  until (wrkString = 'ENTITIES') or eof(f);
  While not eof (f) do begin
      ReadLn (f, group);     // маркер
      ReadLn (f, wrkString); // идентификатор либо координата
      case group of
         0: begin            // начался следующий объект
            AddToList (x3, y3, z3);
            AddToList (x2, y2, z2);
            AddToList (x1, y1, z1);
            end;
        10: val(wrkString, x1, err);
        20: val(wrkString, y1, err);
        30: val(wrkString, z1, err);
        11: val(wrkString, x2, err);
        21: val(wrkString, y2, err);
        31: val(wrkString, z2, err);
        12: val(wrkString, x3, err);
        22: val(wrkString, y3, err);
        32: val(wrkString, z3, err);
      end;
  end;
  CloseFile(f);
end;
{$WARNINGS ON}

{$HINTS OFF}
procedure TfrmGL.CalcNormals;
var
  i : Integer;
  wrki, vx1, vy1, vz1, vx2, vy2, vz2 : GLfloat;
  nx, ny, nz : GLfloat;
  wrkVector : Vector;
  pwrkVector : ^Vector;
  wrkVector1, wrkVector2, wrkVector3 : Vector;
  pwrkVector1, pwrkVector2, pwrkVector3 : ^Vector;
begin
  New (pwrkVector1);
  New (pwrkVector2);
  New (pwrkVector3);

  For i := 0 to round (Model.Count / 3) - 1 do begin
     pwrkVector1 := Model [i * 3];
     wrkVector1 := pwrkVector1^;
     pwrkVector2 := Model [i * 3 + 1];
     wrkVector2 := pwrkVector2^;
     pwrkVector3 := Model [i * 3 + 2];
     wrkVector3 := pwrkVector3^;

     vx1 := wrkVector1.x - wrkVector2.x;
     vy1 := wrkVector1.y - wrkVector2.y;
     vz1 := wrkVector1.z - wrkVector2.z;

     vx2 := wrkVector2.x - wrkVector3.x;
     vy2 := wrkVector2.y - wrkVector3.y;
     vz2 := wrkVector2.z - wrkVector3.z;

     // вектор перпендикулярен центру треугольника
     nx := vy1 * vz2 - vz1 * vy2;
     ny := vz1 * vx2 - vx1 * vz2;
     nz := vx1 * vy2 - vy1 * vx2;

     // получаем унитарный вектор единичной длины
     wrki := sqrt (nx * nx + ny * ny + nz * nz);
     If wrki = 0 then wrki := 1; // для предотвращения деления на ноль

     wrkVector.x := nx / wrki;
     wrkVector.y := ny / wrki;
     wrkVector.z := nz / wrki;

     New (pwrkVector);
     pwrkVector^ := wrkVector;

     Normals.Add (pwrkVector);
  end;
end;
{$HINTS ON}

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
begin
 glEnable(GL_DEPTH_TEST);
 glEnable(GL_LIGHTING);
 glEnable(GL_LIGHT0);
 glEnable (GL_COLOR_MATERIAL);
 glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, 1);
 glColor3f (0.4, 0.6, 0.6);
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

  glRotatef (Angle, 1.0, 0.0, 1.0);
  glRotatef (2 * Angle, 0.0, 1.0, 0.0);

  glCallList (SURFACE);

  glPopMatrix;

  SwapBuffers (DC);
  EndPaint (Handle, ps);

  Angle := Angle + Step;
  If Angle >= 360.0 then Angle := 0.0;
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
var
  i : Integer;
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  glClearColor (1.0, 1.0, 1.0, 1.0);
  down := 0;
  Init;
  Model := TList.Create;
  Normals := TList.Create;
  LoadDxf ('Dolphin.dxf');
  CalcNormals;
  glNewList (SURFACE, GL_COMPILE);
   For i := 0 to round (Model.Count / 3) - 1 do begin
    glBegin(GL_TRIANGLES);
      glNormal3fv(Normals.Items [i]);
      glvertex3fv(Model.Items [i * 3]);
      glvertex3fv(Model.Items [i * 3 + 1]);
      glvertex3fv(Model.Items [i * 3 + 2]);
    glEnd;
   end;
  glEndList;
  Model.Free;
  Normals.Free;
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewPort (0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluPerspective(40.0, ClientWidth / ClientHeight, 3.0, 13.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef(0.0, 0.0, -9.0);
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
  If Key = VK_ESCAPE then Close;
  If Key = VK_SPACE then begin
     If step = 0
        then step := wrkStep
        else begin
        wrkStep := step;
        step := 0;
        end
  end;
end;

{=======================================================================
Движение мыши}
procedure TfrmGL.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  If down <> 0 then begin
     glRotatef (lastx - x, 1, 0, 1);
     lastx := x;
     step := sqrt (sqr(X - wrkX) + sqr (Y - wrkY)) / (GetTickCount - wrkTime + 1);
     InvalidateRect(Handle, nil, False);
  end;
end;

{=======================================================================
Кнопка мыши отжата}
procedure TfrmGL.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  down := 0;
end;

{=======================================================================
Кнопка мыши нажата}
procedure TfrmGL.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 If button = mbLeft then begin
    lastx := X;
    wrkX := X;
    wrkY := Y;
    down := 1;
    wrkTime := GetTickCount;
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

end.

