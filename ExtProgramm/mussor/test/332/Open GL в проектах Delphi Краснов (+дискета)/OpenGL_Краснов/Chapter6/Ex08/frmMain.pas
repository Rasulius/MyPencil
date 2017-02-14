{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Controls, SysUtils,
  Dialogs, StdCtrls,
  OpenGL;

type
  TfrmGL = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC: HDC;
    hrc: HGLRC;
    wrkX, wrkY : Array [0..5] of Single;
    vp : Array [0..3] of GLint;
    selectBuf : Array [0..128] of GLuint;// буфер выбора

    procedure SetDCPixelFormat;
    procedure Render (mode : GLEnum);
    function DoSelect(x : GLint; y : GLint) : GLUInt;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

const
  // массив свойств материала
  MaterialColor: Array[0..3] of GLfloat = (0.5, 0.2, 0.5, 0.0);
  // идентификатор списка
  CUBE = 1;
var
  frmGL: TfrmGL;

implementation

{$R *.DFM}


{=======================================================================
Выбор объекта в точке}
function TfrmGL.DoSelect(x : GLint; y : GLint) : GLUInt;
begin
  glRenderMode(GL_SELECT); // режим выбора
  // режим выбора нужен для работы следующих команд
  glInitNames;             // инициализация стека имен
  glPushName(0);           // помещение имени в стек имен

  glGetIntegerv(GL_VIEWPORT, @vp);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPickMatrix(x, ClientHeight - y, 4, 4, @vp);
  gluPerspective(18.0, (ClientWidth - Memo1.Width) / ClientHeight, 6.0, 10.0);
  glViewport(0, 0, (ClientWidth - Memo1.Width), ClientHeight);
  glMatrixMode(GL_MODELVIEW);

  glClear(GL_COLOR_BUFFER_BIT);

  Render(GL_SELECT); // рисуем массив объектов с выбором

  Result := glRenderMode(GL_RENDER);
end;

procedure TfrmGL.Render (mode : GLEnum);
var
  i : 0..5;
begin
  {Цикл рисования шести кубиков}
  For i := 0 to 5 do begin
  glPushMatrix;                    // запомнили точку

  glTranslatef (wrkX [i], wrkY [i], 0.0);
  glRotatef (-60 * i, 0.0, 0.0, 1.0); // поворот кубика

  If mode = GL_SELECT then glLoadName (i);
  glCallList (CUBE);               // рисование отдельного кубика - вызов списка

  glPopMatrix;                     // вернулись в точку
  end;
end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);
  // очистка буфера цвета и буфера глубины
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  // трехмерность
  glLoadIdentity;
  glTranslatef(0.0, 0.0, -9.0);
  glRotatef(120.0, 1.0, 0.0, 1.0);

  Render (GL_RENDER);

  SwapBuffers(DC);                 // конец работы
  EndPaint(Handle, ps);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
var
  i : 0..5;
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  glEnable(GL_DEPTH_TEST);// разрешаем тест глубины
  glEnable(GL_LIGHTING); // разрешаем работу с освещенностью
  glEnable(GL_LIGHT0);   // включаем источник света 0

  For i := 0 to 5 do begin
      wrkX [i] := sin (Pi / 3 * i);
      wrkY [i] := cos (Pi / 3 * i);
  end;

  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @MaterialColor);

  glNewList (CUBE, GL_Compile);
    glScalef (0.25, 0.25, 0.25); // Изменяем масштаб

    // Стороны куба
    glBegin(GL_QUADS);
      glNormal3f(0.0, 0.0, 1.0);
      glVertex3f(1.0, 1.0, 1.0);
      glVertex3f(-1.0, 1.0, 1.0);
      glVertex3f(-1.0, -1.0, 1.0);
      glVertex3f(1.0, -1.0, 1.0);
    glEnd;

    glBegin(GL_QUADS);
      glNormal3f(-1.0, 0.0, 0.0);
      glVertex3f(-1.0, 1.0, 1.0);
      glVertex3f(-1.0, 1.0, -1.0);
      glVertex3f(-1.0, -1.0, -1.0);
      glVertex3f(-1.0, -1.0, 1.0);
    glEnd;

    glBegin(GL_QUADS);
      glNormal3f(1.0, 0.0, 0.0);
      glVertex3f(1.0, 1.0, 1.0);
      glVertex3f(1.0, -1.0, 1.0);
      glVertex3f(1.0, -1.0, -1.0);
      glVertex3f(1.0, 1.0, -1.0);
    glEnd;

    glBegin(GL_QUADS);
      glNormal3f(0.0, 1.0, 0.0);
      glVertex3f(-1.0, 1.0, -1.0);
      glVertex3f(-1.0, 1.0, 1.0);
      glVertex3f(1.0, 1.0, 1.0);
      glVertex3f(1.0, 1.0, -1.0);
    glEnd;

    glBegin(GL_QUADS);
      glNormal3f(0.0, -1.0, 0.0);
      glVertex3f(-1.0, -1.0, -1.0);
      glVertex3f(1.0, -1.0, -1.0);
      glVertex3f(1.0, -1.0, 1.0);
      glVertex3f(-1.0, -1.0, 1.0);
    glEnd;

    glScalef (4, 4, 4);                // востанавливаем масштаб

  glEndList;                           // конец описания списка
  glClearColor (0.25, 0.1, 0.25, 0.0);
  glSelectBuffer(SizeOf (selectBuf), @selectBuf); // создание буфера выбора
  Memo1.Clear;
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

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, (ClientWidth - Memo1.Width), ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(18.0, (ClientWidth - Memo1.Width) / ClientHeight, 6.0, 10.0);
  glMatrixMode(GL_MODELVIEW);
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  glDeleteLists (CUBE, 1);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

procedure TfrmGL.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  hit, hits: GLUint;
begin
  hits := DoSelect (X, Y);
  Memo1.Clear;
  Memo1.Lines.Add(Format('Объектов под курсором : %d',[hits]));
  For hit := 1 to hits do
    Memo1.Lines.Add(' Объект №' + IntToStr(hit) +
                    ' Имя: ' + IntToStr(SelectBuf[(hit - 1)* 4 + 3]));
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close
end;

end.

