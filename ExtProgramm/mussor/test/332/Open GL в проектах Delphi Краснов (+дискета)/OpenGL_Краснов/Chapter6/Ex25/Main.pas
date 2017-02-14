{***************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"              *}
{* Краснов М.В. softgl@chat.ru                                 *}
{***************************************************************}

{***************************************************************}
{***     ПРИМЕР ГРАФИЧЕСКОГО РЕДАКТОРА НА ОСНОВЕ OpenGL      ***}
{***************************************************************}
{*** Редактор работает с объектами трех типов - параллепипед,***}
{*** сферический объект, цилиндрический объект.              ***}
{*** Всплывающее меню содержит пункты по работе с объектами. ***}
{*** Размещенный объект маркируется при щелчке на нем.       ***}
{*** Маркированный объект перемещается указателем мыши       ***}
{*** (при нажатом Ctrl - по оси Z). Маркеры используются для ***}
{*** изменения размеров объектов.                            ***}
{*** Enter - вывод окна параметров маркированного объекта.   ***}
{*** Home, End - переключение маркированного объекта.        ***}
{***************************************************************}
{*** Автор: Краснов М.В. softgl@chat.ru                      ***}
{***************************************************************}

unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ComCtrls, StdCtrls, Menus, Buttons,
  OpenGL, Splash;

const
  id_Text = 1000;
  XLetter : PChar = 'X';
  YLetter : PChar = 'Y';
  ZLetter : PChar = 'Z';
  MaxObjects = 100;
  MaxSelect = 8;
  // списки
  DrawCube = 1;
  Marker = 2;
  DrawSphere = 3;
  DrawCylinder = 4;
  startObjects = 16;       // с какого номера начинается нумерация объектов

const
  // цвет осей координат
  ColorAxes : Array[0..3] of GLFloat = (1.0, 1.0, 1.0, 0.5);
  // цвет тумана
  ColorFog : Array [0..3] of GLFloat = (0.5, 0.5, 0.5, 1.0);
  // цвет площадки и сетки
  SquareAmbient : Array[0..3] of GLFloat = (0.24725, 0.1995, 0.0745, 1.0);
  SquareDiffuse : Array[0..3] of GLFloat = (0.75164, 0.60648, 0.22648, 1.0);
  SquareSpecular : Array[0..3] of GLFloat = (0.628281, 0.555802, 0.366065, 1.0);
  // источники света
  LightAmbient : Array[0..3] of GLFloat = (0.25, 0.25, 0.25, 1.0);
  LightDiffuse : Array[0..3] of GLFloat = (1.0, 1.0, 1.0, 1.0);
  LightSpecular: Array[0..3] of GLFloat = (1.0, 1.0, 1.0, 1.0);
  LightPosition: Array[0..3] of GLFloat = (0.0, 0.0, 20.0, 1.0);
  LightModelAmbient: Array[0..3] of GLFloat = (0.25, 0.25, 0.25, 1.0);
  // позиция второго источника света
  Light2Position: Array[0..3] of GLFloat = (15.0, 15.0, -5.0, 1.0);
  // цвет маркера
  ColorMarker : Array[0..3] of GLFloat = (1.0, 0.0, 1.0, 1.0);
  // имя файла с параметрами системы
  FileParam = 'Editor.dat';

{--- тип рисуемых объектов ---}
type
  TGLObject = record
    Kind : (Cube, Sphere, Cylinder);
    X, Y, Z, L, W, H : GLDouble;
    RotX, RotY, RotZ : GLDouble;
    Color : Array [0..2] of GLFloat;
  end;

type
  TfrmMain = class(TForm)
    Panel1: TPanel;
    udDistance: TUpDown;
    lblDistance: TLabel;
    udRotX: TUpDown;
    udRotY: TUpDown;
    udRotZ: TUpDown;
    lblRotX: TLabel;
    lblRotY: TLabel;
    lblRotZ: TLabel;
    pmMain: TPopupMenu;
    N1: TMenuItem;
    cbxAxes: TCheckBox;
    udAxesLength: TUpDown;
    lblAxesLength: TLabel;
    itAddObject: TMenuItem;
    cbxGrid: TCheckBox;
    cbxFog: TCheckBox;
    cbxGround: TCheckBox;
    lblAddX: TLabel;
    udAddX: TUpDown;
    lblAddY: TLabel;
    udAddY: TUpDown;
    udAddZ: TUpDown;
    lblAddZ: TLabel;
    pmSdvig: TPopupMenu;
    N3: TMenuItem;
    sbtnLoad: TSpeedButton;
    sbtnRefresh: TSpeedButton;
    pmAngle: TPopupMenu;
    N4: TMenuItem;
    ColorDialog1: TColorDialog;
    sbtnSave: TSpeedButton;
    itLoadParam: TMenuItem;
    N7: TMenuItem;
    itColorBkGround: TMenuItem;
    itDelObject: TMenuItem;
    itObjectParam: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    N21: TMenuItem;
    itAxesOn: TMenuItem;
    itAxesOff: TMenuItem;
    itGridOn: TMenuItem;
    itGridOff: TMenuItem;
    itGroundOff: TMenuItem;
    itFogOn: TMenuItem;
    itFogOff: TMenuItem;
    itSaveParam: TMenuItem;
    N9: TMenuItem;
    itAddCube: TMenuItem;
    itAddSphere: TMenuItem;
    N12: TMenuItem;
    itUnDo: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    itAddCylinder: TMenuItem;
    Timer1: TTimer;
    itGroundOn: TMenuItem;
    itColorLetter: TMenuItem;
    itLetterScale: TMenuItem;
    procedure SetProjection(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetDCPixelFormat;
    procedure FormDestroy(Sender: TObject);
    procedure udDistanceChanging(Sender: TObject; var AllowChange: Boolean);
    procedure cbxAxesClick(Sender: TObject);
    procedure udAxesLengthChanging(Sender: TObject; var AllowChange: Boolean);
    procedure lblRotXMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure itAddObjectClick(Sender: TObject);
    procedure cbxGridClick(Sender: TObject);
    procedure cbxFogClick(Sender: TObject);
    procedure cbxGroundClick(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblAddXMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure N3Click(Sender: TObject);
    procedure lblAxesLengthMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sbtnLoadClick(Sender: TObject);
    procedure sbtnRefreshClick(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure itLoadParamClick(Sender: TObject);
    procedure itColorBkGroundClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure itDelObjectClick(Sender: TObject);
    procedure itObjectParamClick(Sender: TObject);
    procedure itAxesOnClick(Sender: TObject);
    procedure itGridOnClick(Sender: TObject);
    procedure itGroundOnClick(Sender: TObject);
    procedure itFogOnClick(Sender: TObject);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure itSaveParamClick(Sender: TObject);
    procedure itAddSphereClick(Sender: TObject);
    procedure itAddCubeClick(Sender: TObject);
    procedure itUnDoClick(Sender: TObject);
    procedure itAddCylinderClick(Sender: TObject);
    procedure udRotYMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure udRotYMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure udRotXMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure udRotXMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure udRotZMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure udRotZMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure udAddXMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure udAddXMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure udAddYMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure udAddYMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure udAddZMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure udAddZMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure udRotZMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure itColorLetterClick(Sender: TObject);
    procedure itLetterScaleClick(Sender: TObject);
  private
    SplashWindow : TSplashWindow;
  public
    {--- системные переменные ---}
    DC : HDC;
    hrc : HGLRC;
    {--- видовые параметры ---}
    Perspective : GLFloat;                 // перспектива
    zNear, zFar : GLFloat;                 // параметры вида
    vLeft, vRight, vTop, vBottom : GLFloat;// параметры вида
    AngX, AngY, AngZ : GLFloat;            // углы поворота по осям
    AddX, AddY, AddZ : GLFloat;            // начальные сдвиги
    {--- цвет букв ---}
    ColorLetter : TGLArrayf4;
    {--- рабочие флаги ---}
    flgAxes : Boolean;                     // показывать ли ось
    flgGrid : Boolean;                     // показывать ли сетку
    flgSquare : Boolean;                   // показывать ли площадку
    flgDraging : Boolean;                  // происходит ли буксирование площадки
    flgDragObject : Boolean;               // происходит ли буксирование объекта
    flgFirst : Boolean;                    // совершенно рабочий флаг
    flgMouseMove : Boolean;                // было движение мыши
    flgMoveObject : Boolean;               // происходит перемещение объекта
    flgudRotXChange : Boolean;             // происходит ли изменение udRotX
    flgudRotYChange : Boolean;             // происходит ли изменение udRotY
    flgudRotZChange : Boolean;             // происходит ли изменение udRotZ
    flgudAddXChange : Boolean;             // происходит ли изменение udAddX
    flgudAddYChange : Boolean;             // происходит ли изменение udAddY
    flgudAddZChange : Boolean;             // происходит ли изменение udAddZ
    {--- система объектов ---}
    objectCount : GLInt;                   // количество объектов
    objects : Array [0..MaxObjects - 1] of TGLObject; // массив объектов
    SysFile : String;                      // имя файла системы
    {--- дублирование системы для UnDo ---}
    DobjectCount : GLInt;                  // количество объектов
    Dobjects : Array [0..MaxObjects - 1] of TGLObject; // массив объектов
    {--- рабочие переменные системы объектов ---}
    MarkerObject : GLInt;                  // номер помеченного объекта
    PopupObject : GLInt;                   // номер объекта под курсором
    DragingObject : GLInt;                 // номер буксируемого объекта
    {--- для выбора объектов под курсором ---}
    selectBuf : Array [0..MaxSelect - 1] of GLInt;
    hit : GLInt;
    vp : Array [0..3] of GLInt;
    {--- рабочие параметры текущего вида ---}
    LineLength : GLFloat;                  // длина линий осей
    SquareLength : GLFloat;                // сторона площадки
    PrevX, PrevY : GLInt;                  // координаты на экране
    ColorBackground : TGLArrayf3;          // цвет фона экрана
    ScaleLetter : 1..10;

    DataFile : File of GLFloat;            // файл параметров
    Quadric : GLUQuadricObj ;              // сфера / цилиндр
    function DoSelect(x : GLint; y : GLint) : GLint;
    function Max (a, b : GLFloat) : GLFloat;
    function Min (a, b : GLFloat) : GLFloat;
    procedure Axes (mode : GLenum);
    procedure ColorToGLU (var R, G, B: GLFloat);
    procedure DeleteMarkerObject;
    procedure DrawScene (mode : GLEnum);
    procedure GLInit;
    procedure Grid;
    procedure ListPrep;
    procedure LoadParam;
    procedure LoadSystem;
    procedure MarkerCube (n : GLInt; mode : GLEnum);
    procedure MoveObject (mouseX, mouseY : GLInt);
    procedure ObjectDelete;
    procedure ResizeObject (h : GLInt; mouseX, mouseY : GLInt);
    procedure ResizeObjectXYZ (h : GLInt; mouseX, mouseY : GLInt);
    procedure ResizeSquare (h : GLInt; mouseX, mouseY : GLInt);
    procedure Save;
    procedure SaveParam;
    procedure SaveProgram;
    procedure SaveSystem;
    procedure ScreenToSpace (mouseX, mouseY : GLInt; var X, Y : GLFloat);
    procedure Square (mode : GLEnum);
    procedure Start;
    procedure TransformView (h : GLint);
    procedure UnDo;
   protected
    procedure WMRestore (var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
   end;

var
  frmMain: TfrmMain;

implementation

uses AddObject, ParSdvig, ParAngle, ParObject, ScaleLetter;

{$R *.DFM}

{**********************************************************************}
{****                   CUSTOM - методы формы                      ****}
{**********************************************************************}

{======================================================================
Стартовая процедура, задает начальные значения параметров}
procedure TfrmMain.Start;
begin
 vLeft := -0.5;
 vRight := 0.5;
 vBottom := -0.5;
 vTop := 0.5;
 zNear := 1.0;
 zFar := 100.0;
 Perspective := 30.0;
 udDistance.Position := Round(Perspective);
 AngX := 120.0;
 AngY := 180.0;
 AngZ := 40.0;
 flgAxes := True;            // показывать ли ось
 flgGrid := True;            // показывать ли сетку
 flgSquare := True;          // показывать ли площадку
 cbxAxes.Checked := True;
 itAxesOn.Checked := True;        // пункты попап
 itAxesOff.Checked := False;
 cbxGrid.Checked := True;
 itAxesOn.Checked := True;
 itGridOff.Checked := False;
 cbxFog.Checked := True;
 itFogOn.Checked := True;
 itFogOff.Checked := False;
 cbxGround.Checked := True;
 itGroundOn.Checked := True;
 itGroundOff.Checked := False;
 AddX := 0;
 AddY := 0;
 AddZ := 0;
 linelength := 10.0;         // длина осевых
 squarelength := 10.0;;      // сторона площадки
 udAxesLength.Position := round(linelength);
 {--- цвет фона ---}
 ColorBackground [0] := 0;
 ColorBackground [1] := 0;
 ColorBackground [2] := 0;

 {--- цвет букв ---}
 ColorLetter [0] := 1.0;
 ColorLetter [1] := 0.0;
 ColorLetter [2] := 1.0;
 ColorLetter [3] := 1.0;

 {--- масштаб букв ---}
 ScaleLetter := 1;
end;

{======================================================================
Пометка маркерами объекта n}
procedure TfrmMain.MarkerCube (n : GLInt; mode : GLEnum);
begin
  glPushMatrix;

  glPushAttrib (GL_ALL_ATTRIB_BITS );
  glMaterialfv (GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @ColorMarker);

  glTranslatef (0.5, 0.0, 0.0);
  If mode = GL_SELECT then glLoadName (8); // XZ внизу
  glCallList (Marker);

  glTranslatef (0.0, 0.0, 1.0);
  If mode = GL_SELECT then glLoadName (9); // XZ вверху
  glCallList (Marker);

  glTranslatef (-0.5, 0.5, 0.0);
  If mode = GL_SELECT then glLoadName (10); // YZ вверху
  glCallList (Marker);

  glTranslatef (0.0, 0.0, -1.0);
  If mode = GL_SELECT then glLoadName (11); // YZ внизу
  glCallList (Marker);

  glTranslatef (0.5, 0.5, 0.0);
  If mode = GL_SELECT then glLoadName (12); // XY внизу
  glCallList (Marker);

  glTranslatef (0.0, 0.0, 1.0);
  If mode = GL_SELECT then glLoadName (13); // XY вверху
  glCallList (Marker);

  glTranslatef (0.5, -0.5, 0.0);
  If mode = GL_SELECT then glLoadName (14); // XYZ вверху
  glCallList (Marker);

  glTranslatef (0.0, 0.0, -1.0);
  If mode = GL_SELECT then glLoadName (15); // XYZ внизу
  glCallList (Marker);

  glPopAttrib;
  glPopMatrix;
end;

{=======================================================================
Перемещение точки зрения}
procedure TfrmMain.TransformView (h : GLint);
begin
  Case h of
  1 : begin
      AngX := 90;
      AngY := -180;
      AngZ := 90;
      end;
  2 : begin
      AngX := 90;
      AngY := 180;
      AngZ := 0;
      end;
  3 : begin
      AngX := 0;
      AngY := 0;
      AngZ := 0;
      end;
  end; // case
end;

{=======================================================================
Выбор объекта под курсором}
function TfrmMain.DoSelect(x : GLInt; y : GLInt) : GLint;
var
  hits : GLInt;
begin
  glRenderMode(GL_SELECT);               // режим выбора
  glInitNames;                           // инициализация стека имен
  glPushName(0);                         // помещение имени в стек имен
  glPushMatrix;

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPickMatrix(x, ClientHeight - y, 2, 2, @vp);
  glFrustum (vLeft, vRight, vBottom, vTop, zNear, zFar);

  glMatrixMode(GL_MODELVIEW);

  DrawScene (GL_SELECT);

  glPopMatrix;

  hits := glRenderMode(GL_RENDER);

  If hits <= 0
     then Result := -1
     else Result := SelectBuf[(hits - 1) * 4 + 3];
end;

{=======================================================================
Основная процедура рисования}
procedure TfrmMain.DrawScene (mode : GLEnum);
var
  i : GLInt;
begin
  glClearColor (ColorBackground [0], ColorBackground [1], ColorBackground [2], 1.0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;
  glTranslatef(0.0, 0.0, -32.0);

  glRotatef(AngX, 1.0, 0.0, 0.0);
  glRotatef(AngY, 0.0, 1.0, 0.0);
  glRotatef(AngZ, 0.0, 0.0, 1.0);

  glTranslatef(AddX, AddY, AddZ);

  If (mode <> GL_SELECT) and flgGrid then Grid;

  // дальше включается режим выбора объектов
  If flgAxes then Axes (mode);
  If flgSquare then Square (mode);

  // массив объектов
  glPushAttrib (GL_ALL_ATTRIB_BITS );
  glDisable (GL_LIGHT1);

  For i := 1 to objectcount do begin
      glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @objects[i].color);
      glPushMatrix;
      glTranslatef (objects[i].X, objects[i].Y, objects[i].Z);
      glScalef (objects[i].L, objects[i].W, objects[i].H);
      glRotatef (objects[i].RotX, 1.0, 0.0, 0.0);
      glRotatef (objects[i].RotY, 0.0, 1.0, 0.0);
      glRotatef (objects[i].RotZ, 0.0, 0.0, 1.0);

      If mode = GL_SELECT then glLoadName (i + startObjects);
      case objects [i].Kind of
           Cube : glCallList (DrawCube);
           Sphere : glCallList (DrawSphere);
           Cylinder : glCallList (DrawCylinder);
      end; {case}
      If i = MarkerObject then MarkerCube (i, mode);

      glPopMatrix;
  end;

  glEnable (GL_LIGHT1);
  glPopAttrib;

  SwapBuffers(DC);
end;

{======================================================================
Вывод диалога задания цвета для RGB}
procedure TfrmMain.ColorToGLU (var R, G, B: GLFloat);
begin
  {заполняем цвет диалога}
  ColorDialog1.Color := round(R*255) or (round(G*255) shl 8) or (round(B*255) shl 16);
  If ColorDialog1.Execute then begin
     R := (ColorDialog1.Color and $FF) / 255;
     G := ((ColorDialog1.Color and $FF00) shr 8) /255;
     B := ((ColorDialog1.Color and $FF0000) shr 16) /255;
  end;
end;

{======================================================================
Перевод экранных координат в пространственные}
procedure TfrmMain.ScreenToSpace (mouseX, mouseY : GLInt; var X, Y : GLFloat);
var
   x0, xW, y0, yH : GLFloat;
begin
   x0 := 4 * zFar * vLeft / (zFar + zNear);   // 0
   xW := 4 * zFar * vRight / (zFar + zNear);  // Width

   y0 := 4 * zFar * vTop / (zFar + zNear);    // 0
   yH := 4 * zFar * vBottom / (zFar + zNear); // Heigth

   X := x0 + mouseX * (xW - x0) / (ClientWidth - Panel1.Width);
   Y := y0 + mouseY * (yH - y0) / ClientHeight;
end;

{======================================================================
Чтение параметров системы из файла}
procedure TfrmMain.LoadParam;
var
  wrk : GLFloat;
begin
  AssignFile (DataFile, FileParam);
  try
  ReSet (DataFile);
  Read (DataFile, zNear, zFar, Perspective);
  udDistance.Position := Round(Perspective);
  Read (DataFile, vLeft, vRight, vTop, vBottom);
  Read (DataFile, AngX, AngY, AngZ);
  Read (DataFile, AddX, AddY, AddZ);
  Read (DataFile, SquareLength, LineLength);
  udAxesLength.Position := round(linelength);
  Read (DataFile, wrk);
  If wrk = 1.0 then flgAxes := True
               else flgAxes := False;
  cbxAxes.Checked := flgAxes;
  If cbxAxes.Checked then begin
     itAxesOn.Checked := True;   // пункты попап
     itAxesOff.Checked := False;
     end
     else begin
     itAxesOn.Checked := False;  // пункты попап
     itAxesOff.Checked := True;
  end;
  // сетка
  Read (DataFile, wrk);
  If wrk = 1.0 then flgGrid := True
               else flgGrid := False;
  cbxGrid.Checked := flgGrid;
  If cbxGrid.Checked then begin
     itGridOn.Checked := True;
     itGridOff.Checked := False;
     end
     else begin
     itGridOn.Checked := False;
     itGridOff.Checked := True;
  end;
  // туман
  Read (DataFile, wrk);
  If wrk = 1.0 then cbxFog.Checked := True
               else cbxFog.Checked := False;
  If cbxFog.Checked then begin
     itFogOn.Checked := True;
     itFogOff.Checked := False;
     glEnable (GL_FOG);
     end
     else begin
     itFogOn.Checked := False;
     itFogOff.Checked := True;
     glDisable (GL_FOG);
  end;
  // площадка
  Read (DataFile, wrk);
  If wrk = 1.0 then flgSquare := True
               else flgSquare := False;
  cbxGround.Checked := flgSquare;
  If cbxGround.Checked then begin
     itGroundOn.Checked := True;
     itGroundOff.Checked := False;
     end
     else begin
     itGroundOn.Checked := False;
     itGroundOff.Checked := True;
  end;
  Read (DataFile, wrk);
  udRotX.Increment := Round (wrk);
  udRotY.Increment := Round (wrk);
  udRotZ.Increment := Round (wrk);
  Read (DataFile, wrk);
  udAddX.Increment := Round (wrk);
  udAddY.Increment := Round (wrk);
  udAddZ.Increment := Round (wrk);
  Read (DataFile, ColorBackground [0]);
  Read (DataFile, ColorBackground [1]);
  Read (DataFile, ColorBackground [2]);
  {--- цвет букв ---}
  Read (DataFile, ColorLetter [0]);
  Read (DataFile, ColorLetter [1]);
  Read (DataFile, ColorLetter [2]);
  Read (DataFile, ColorLetter [3]);
  {--- масштаб букв ---}
  Read (DataFile, wrk);
  ScaleLetter := round (wrk);

  finally
  CloseFile (DataFile);
  end;
end;

{======================================================================
Запись параметров системы}
procedure TfrmMain.SaveParam;
var
  wrk : GLFloat;
begin
  AssignFile (DataFile, FileParam);
  try
  try
  Rewrite (DataFile);
  Write (DataFile, zNear, zFar, Perspective);
  Write (DataFile, vLeft, vRight, vTop, vBottom);
  Write (DataFile, AngX, AngY, AngZ);
  Write (DataFile, AddX, AddY, AddZ);
  Write (DataFile, SquareLength, LineLength);
  If flgAxes then wrk := 1.0
             else wrk := 0.0;
  Write (DataFile, wrk);
  If flgGrid then wrk := 1.0
             else wrk := 0.0;
  Write (DataFile, wrk);
  If cbxFog.Checked then wrk := 1.0
                       else wrk := 0.0;
  Write (DataFile, wrk);
  If flgSquare then wrk := 1.0
               else wrk := 0.0;
  Write (DataFile, wrk);
  wrk := udRotX.Increment;
  Write (DataFile, wrk);
  wrk := udAddX.Increment;
  Write (DataFile, wrk);
  Write (DataFile, ColorBackground [0]);
  Write (DataFile, ColorBackground [1]);
  Write (DataFile, ColorBackground [2]);
  {--- цвет букв ---}
  Write (DataFile, ColorLetter [0]);
  Write (DataFile, ColorLetter [1]);
  Write (DataFile, ColorLetter [2]);
  Write (DataFile, ColorLetter [3]);

  {--- масштаб букв ---}
  wrk := ScaleLetter;
  Write (DataFile, wrk);
  finally
  CloseFile (DataFile);
  end;
  except
  ShowMessage ('Ошибка записи в файл параметров ' + FileParam);
  end;
end;

{======================================================================
Максимум двух чисел}
function TfrmMain.Max (a, b : GLFloat) : GLFloat;
begin
  If a > b then Max := a else Max := b
end;

{======================================================================
Минимум двух чисел}
function TfrmMain.Min (a, b : GLFloat) : GLFloat;
begin
  If a < b then Min := a else Min := b
end;

{======================================================================
Рисование линий осей координат}
procedure TfrmMain.Axes (mode : GLenum);
begin
  glPushMatrix;
  glPushAttrib (GL_ALL_ATTRIB_BITS );

  glMaterialfv (GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @ColorAxes);

  glBegin (GL_LINES);
    glVertex3f (0.0, 0.0, 0.0);
    glVertex3f (linelength, 0.0, 0.0);
    glVertex3f (0.0, 0.0, 0.0);
    glVertex3f (0.0, linelength, 0.0);
    glVertex3f (0.0, 0.0, 0.0);
    glVertex3f (0.0, 0.0, linelength);
  glEnd;

  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @ColorLetter);

  glTranslatef(linelength + 1.0, 0.0, 0.0);
  glRotatef (90.0, 0.0, 1.0, 0.0);
  glRotatef (90.0, 0.0, 0.0, 1.0);
  If mode = GL_SELECT then glLoadName (1);
  glListBase(id_Text);
  glScalef(ScaleLetter, ScaleLetter, ScaleLetter);
  glCallLists(1, GL_UNSIGNED_BYTE, XLetter);
  glScalef(1 / ScaleLetter, 1 / ScaleLetter, 1 / ScaleLetter);

  glPopMatrix;
  glPushMatrix;
  glTranslatef(0.0, linelength + 1.0, 0.0);
  glRotatef (90.0, 1.0, 0.0, 0.0);
  If mode = GL_SELECT then glLoadName (2);

  glScalef(ScaleLetter, ScaleLetter, ScaleLetter);
  glCallLists(1, GL_UNSIGNED_BYTE, YLetter);
  glScalef(1 / ScaleLetter, 1 / ScaleLetter, 1 / ScaleLetter);

  glPopMatrix;
  glPushMatrix;
  glTranslatef(0.0, 0.0, linelength + 1.0);
  If mode = GL_SELECT then glLoadName (3);

  glScalef(ScaleLetter, ScaleLetter, ScaleLetter);
  glCallLists(1, GL_UNSIGNED_BYTE, ZLetter);
  glScalef(1 / ScaleLetter, 1 / ScaleLetter, 1 / ScaleLetter);

  glPopAttrib;
  glPopMatrix;
end;

{======================================================================
Инициализация списков}
procedure TfrmMain.ListPrep;
begin
  glNewList(DrawCube, GL_COMPILE);
  glTranslatef (0.5, 0.5, 0.5);
  glBegin(GL_QUADS);
    glNormal3f(-1.0,  0.0,  0.0);
    glVertex3f(-0.5, -0.5,-0.5);
    glVertex3f(-0.5, -0.5, 0.5);
    glVertex3f(-0.5,  0.5, 0.5);
    glVertex3f(-0.5,  0.5,-0.5);
  glEnd;
  glBegin(GL_QUADS);
    glNormal3f( 0.0,  1.0,  0.0);
    glVertex3f(-0.5,  0.5,-0.5);
    glVertex3f(-0.5,  0.5, 0.5);
    glVertex3f( 0.5,  0.5, 0.5);
    glVertex3f( 0.5,  0.5,-0.5);
  glEnd;
  glBegin(GL_QUADS);
    glNormal3f( 1.0,  0.0,  0.0);
    glVertex3f( 0.5,  0.5,-0.5);
    glVertex3f( 0.5,  0.5, 0.5);
    glVertex3f( 0.5, -0.5, 0.5);
    glVertex3f( 0.5, -0.5,-0.5);
  glEnd;
  glBegin(GL_QUADS);
    glNormal3f( 0.0, -1.0,  0.0);
    glVertex3f( 0.5, -0.5,-0.5);
    glVertex3f( 0.5, -0.5, 0.5);
    glVertex3f(-0.5, -0.5, 0.5);
    glVertex3f(-0.5, -0.5,-0.5);
  glEnd;
  glBegin(GL_QUADS);
    glNormal3f( 0.0,  0.0,  1.0);
    glVertex3f( 0.5, -0.5, 0.5);
    glVertex3f( 0.5,  0.5, 0.5);
    glVertex3f(-0.5,  0.5, 0.5);
    glVertex3f(-0.5, -0.5, 0.5);
  glEnd;
  glBegin(GL_QUADS);
    glNormal3f( 0.0,  0.0, -1.0);
    glVertex3f( 0.5,  0.5,-0.5);
    glVertex3f( 0.5, -0.5,-0.5);
    glVertex3f(-0.5, -0.5,-0.5);
    glVertex3f(-0.5,  0.5,-0.5);
  glEnd;
  glTranslatef (-0.5, -0.5, -0.5);
  glEndList;

  glNewList(DrawSphere, GL_COMPILE);
    glTranslatef (0.5, 0.5, 0.5);
    gluSphere(Quadric, 0.5, 50, 50);
    glTranslatef (-0.5, -0.5, -0.5);
  glEndList;

  glNewList(DrawCylinder, GL_COMPILE);
    glTranslatef (0.5, 0.5, 0.0);
    gluCylinder (Quadric, 0.5, 0.5, 1.0,  50, 50);
    glTranslatef (-0.5, -0.5, 0.0);
  glEndList;

  glNewList(Marker, GL_COMPILE);
    glBegin(GL_POLYGON);
      glNormal3f(-0.025, -0.025, 0.025);
      glVertex3f(0.025, 0.025, 0.025);
      glVertex3f(-0.025, 0.025, 0.025);
      glVertex3f(-0.025, -0.025, 0.025);
      glVertex3f(0.025, -0.025, 0.025);
    glEnd;

    glBegin(GL_POLYGON);
      glNormal3f(-0.025, -0.025, 0.025);
      glVertex3f(0.025, 0.025, -0.025);
      glVertex3f(0.025, -0.025, -0.025);
      glVertex3f(-0.025, -0.025, -0.025);
      glVertex3f(-0.025, 0.025, -0.025);
    glEnd;

    glBegin(GL_POLYGON);
      glNormal3f(-0.025, -0.025, 0.025);
      glVertex3f(-0.025, 0.025, 0.025);
      glVertex3f(-0.025, 0.025, -0.025);
      glVertex3f(-0.025, -0.025, -0.025);
      glVertex3f(-0.025, -0.025, 0.025);
    glEnd;

    glBegin(GL_POLYGON);
      glNormal3f(0.025, -0.025, 0.025);
      glVertex3f(0.025, 0.025, 0.025);
      glVertex3f(0.025, -0.025, 0.025);
      glVertex3f(0.025, -0.025, -0.025);
      glVertex3f(0.025, 0.025, -0.025);
    glEnd;

    glBegin(GL_POLYGON);
      glNormal3f(-0.025, 0.025, -0.025);
      glVertex3f(-0.025, 0.025, -0.025);
      glVertex3f(-0.025, 0.025, 0.025);
      glVertex3f(0.025, 0.025, 0.025);
      glVertex3f(0.025, 0.025, -0.025);
    glEnd;

    glBegin(GL_POLYGON);
      glNormal3f(-0.025, -0.025, -0.025);
      glVertex3f(-0.025, -0.025, -0.025);
      glVertex3f(0.025, -0.025, -0.025);
      glVertex3f(0.025, -0.025, 0.025);
      glVertex3f(-0.025, -0.025, 0.025);
    glEnd;
  glEndList;
end;

{======================================================================
Рисование сетки}
procedure TfrmMain.Grid;
var
  i, j : GLInt;
begin
  glPushAttrib (GL_ALL_ATTRIB_BITS );

  glMaterialfv(GL_FRONT, GL_AMBIENT, @SquareAmbient);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @SquareDiffuse);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @SquareSpecular);
  glMaterialf (GL_FRONT, GL_SHININESS, 99.0);

  glEnable (GL_LINE_STIPPLE);
  glLineStipple (1, 4095);

  j := Round (linelength);

  glBegin (GL_LINES);
    For i := 1 to j do begin
      glVertex3f (i, 0.0, 0.0);
      glVertex3f (i, j, 0.0);
      glVertex3f (0.0, i, 0.0);
      glVertex3f (j, i, 0.0); // xy

      glVertex3f (i, 0.0, 0.0);
      glVertex3f (i, 0.0, j);
      glVertex3f (0.0, 0.0, i);
      glVertex3f (j, 0.0, i); // xz

      glVertex3f (0.0, i, 0.0);
      glVertex3f (0.0, i, j);
      glVertex3f (0.0, 0.0, i);
      glVertex3f (0.0, j, i); // yz
    end;
  glEnd;

  glDisable (GL_LINE_STIPPLE);

  glPopAttrib;
end;

{======================================================================
Задаем формат пикселей}
procedure TfrmMain.SetDCPixelFormat;
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;
begin
  FillChar(pfd, SizeOf(pfd), 0);

  With pfd do begin
    nSize     := SizeOf(pfd);
    nVersion  := 1;
    dwFlags   := PFD_DRAW_TO_WINDOW or
                 PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;
    iPixelType:= PFD_TYPE_RGBA;
    cColorBits:= 24;
    cDepthBits:= 32;
    iLayerType:= PFD_MAIN_PLANE;
  end;

  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;

{======================================================================
Рисование площадки}
procedure TfrmMain.Square (mode : GLEnum);
begin
  glPushAttrib (GL_ALL_ATTRIB_BITS);

  glMaterialfv(GL_FRONT, GL_AMBIENT, @SquareAmbient);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @SquareDiffuse);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @SquareSpecular);
  glMaterialf (GL_FRONT, GL_SHININESS, 90.2);

  If (mode <> GL_SELECT) then begin
  glBegin(GL_QUADS); // сама площадка
    glNormal3f(squarelength / 2, squarelength / 2, -1.0);
    glVertex3f(squarelength, squarelength, -1.0);
    glVertex3f(0.0, squarelength, -1.0);
    glVertex3f(0.0, 0.0, -1.0);
    glVertex3f(squarelength, 0.0, -1.0);
  glEnd;
  end;

  {--- ограничивающие линии ---}

  If mode = GL_SELECT then glLoadName (4); // вверху
  glBegin(GL_LINE_STRIP);
    glVertex3f(squarelength, squarelength, -1.0);
    glVertex3f(0.0, squarelength, -1.0);
  glEnd;

  If mode = GL_SELECT then glLoadName (5); // слева
  glBegin(GL_LINE_STRIP);
    glVertex3f(0.0, squarelength, -1.0);
    glVertex3f(0.0, 0.0, -1.0);
  glEnd;

  If mode = GL_SELECT then glLoadName (6); // снизу
  glBegin(GL_LINE_STRIP);
    glVertex3f(0.0, 0.0, -1.0);
    glVertex3f(squarelength, 0.0, -1.0);
  glEnd;

  If mode = GL_SELECT then glLoadName (7); // справа
  glBegin(GL_LINE_STRIP);
    glVertex3f(squarelength, 0.0, -1.0);
    glVertex3f(squarelength, squarelength, -1.0);
  glEnd;

  glPopAttrib;
end;

{======================================================================
Изменение размеров площадки}
procedure TfrmMain.ResizeSquare (h : GLInt; mouseX, mouseY : GLInt);
var
  dX, dY : GLInt;
  WX1, WY1, WX2, WY2, dXS, dYS : GLFloat;
begin
  If PrevX < 0 then begin
     PrevX := mouseX;
     PrevY := mouseY;
     Exit;
  end;

  dX := mouseX - PrevX;
  dY := mouseY - PrevY;

  If not ((dX = 0) and (dY = 0)) then  begin
     ScreenToSpace (PrevX, PrevY, WX1, WY1);
     ScreenToSpace (mouseX, mouseY, WX2, WY2);

     dXS := Max (WX1, WX2) - Min(WX1, WX2);
     dYS := Max (WY1, WY2) - Min(WY1, WY2);

     If h = 5 then // слева
        If dX > 0 then squarelength := squarelength - 10 * dXS
                  else squarelength := squarelength + 10 * dXS;

     If h = 7 then // справа
        If dX > 0 then squarelength := squarelength + 10 * dXS
                  else squarelength := squarelength - 10 * dXS;

     If h = 4 then // сверху
        If dY > 0 then squarelength := squarelength - 10 * dYS
                  else squarelength := squarelength + 10 * dYS;

     If h = 6 then // снизу
        If dY > 0 then squarelength := squarelength + 10 * dYS
                  else squarelength := squarelength - 10 * dYS;

     If squarelength < 0 then squarelength := 0;

     PrevX := mouseX;
     PrevY := mouseY;
     DrawScene (GL_RENDER);
  end;
end;

{=======================================================================
Удаление помеченного объекта}
procedure TfrmMain.DeleteMarkerObject;
var
  i : GLInt;
begin
  Save;
  For i := MarkerObject to objectcount - 1 do
    objects [i] := objects [i + 1];
  MarkerObject := 0;
  objectcount := objectcount - 1;
  SetProjection(nil);
end;

{=======================================================================
Удаление объекта с номером PopupObject}
procedure TfrmMain.ObjectDelete;
var
  i : GLInt;
begin
  Save;
  For i := PopupObject to objectcount - 1 do
    objects [i] := objects [i + 1];
  objectcount := objectcount - 1;
  If MarkerObject > PopupObject then MarkerObject := MarkerObject - 1
     else If MarkerObject = PopupObject then MarkerObject := 0;
  SetProjection(nil);
end;

{=======================================================================
Запись системы}
procedure TfrmMain.SaveSystem;
var
  F : File of TGLObject;
  wrkI : GLInt;
begin
  If SysFile = '' then
     If SaveDialog1.Execute then
        SysFile := SaveDialog1.FileName;
  If SysFile = '' then Exit;

  {--- записать как программу ---}
  If copy (SysFile, Length (SysFile), 1) = 'c' // заканчивается на inc
     then begin
     SaveProgram;
     Exit;
  end;

  AssignFile (F, SysFile);
  try
  try
    ReWrite (F);
    For wrkI := 1 to objectCount do
        Write (F, objects [wrkI]);
    Caption := 'Editor - ' + ExtractFileName (SysFile);
  finally
    CloseFile (F);
  end; // try
  except
    ShowMessage ('Ошибка при записи файла' + SysFile);
  end; //try
  SetProjection(nil);
end;

{=======================================================================
Загрузить систему}
procedure TfrmMain.LoadSystem;
var
  F : File of TGLObject;
  wrkI : GLInt;
begin
  If OpenDialog1.Execute
     then SysFile := OpenDialog1.FileName
     else Exit;

  AssignFile (F, SysFile);
  Save;
  wrkI := 0;
  try
  try
    ReSet (F);
    While not EOF(F) do begin
      Inc (wrkI);
      Read (F, objects [wrkI]);
    end;
    ObjectCount := wrkI;
    MarkerObject := 0;
    Caption := 'Editor - ' + ExtractFileName (SysFile);
  finally
    CloseFile (F);
  end; // try
  except
    UnDo;
    ShowMessage ('Ошибка чтения файла' + SysFile);
    SysFile := '';
  end; //try
  SetProjection(nil);
end;

{=======================================================================
Запись системы в виде программы}
procedure TfrmMain.SaveProgram;
var
  F : TextFile;
  wrkI : GLInt;
begin
  If SysFile = '' then
     If SaveDialog1.Execute then
        SysFile := SaveDialog1.FileName;
  If SysFile = '' then Exit;

  AssignFile (F, SysFile);
  try
  try
    ReWrite (F);
    For wrkI := 1 to objectCount do begin
        WriteLn (F, ' glPushMatrix;');
        WriteLn (F, '  glTranslatef (', objects [wrkI].X:5:2, ',',
                                        objects [wrkI].Y:5:2, ',',
                                        objects [wrkI].Z:5:2, ');');
        If (objects[wrkI].RotX <> 0) then
           WriteLn (F, '  glRotatef (', objects [wrkI].RotX:4:0,
                                        ', 1.0, 0.0, 0.0');
        If (objects[wrkI].RotY <> 0) then
           WriteLn (F, '  glRotatef (', objects [wrkI].RotY:4:0,
                                        ', 0.0, 1.0, 0.0');
        If (objects[wrkI].RotZ <> 0) then
           WriteLn (F, '  glRotatef (', objects [wrkI].RotZ:4:0,
                                        ', 0.0, 0.0, 1.0');

        WriteLn (F, '  glScalef (', objects [wrkI].L:5:2, ',',
                                    objects [wrkI].W:5:2, ',',
                                    objects [wrkI].H:5:2, ');');

        WriteLn (F, '  color [0] := ', objects [wrkI].color [0]:5:3, ';');
        WriteLn (F, '  color [1] := ', objects [wrkI].color [1]:5:3, ';');
        WriteLn (F, '  color [2] := ', objects [wrkI].color [2]:5:3, ';');

        WriteLn (F, '  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @color);');

        case objects [wrkI].Kind of
          Cube :     WriteLn (F, '  glCallList (DrawCube)');
          Sphere :   WriteLn (F, '  glCallList (DrawSphere)');
          Cylinder : WriteLn (F, '  glCallList (DrawCylinder)');
        end; {case}
        WriteLn (F, ' glPopMatrix;');
        WriteLn (F, '');
    end;
    Caption := 'Editor - ' + ExtractFileName (SysFile);
  finally
    CloseFile (F);
  end; // try
  except
    ShowMessage ('Ошибка при записи файла' + SysFile);
  end; //try
  SetProjection(nil);
end;

{======================================================================
Сохранение текущего состояния системы}
procedure TfrmMain.Save;
var
 wrkI : GLInt;
begin
 DobjectCount := objectCount;           // количество объектов
 For wrkI := 1 to objectCount do        // массив объектов
     Dobjects [wrkI] := objects [wrkI];
 itUnDo.Enabled := True;                // пункт "Отменить"
end;

{=======================================================================
Восстановление состояния системы}
procedure TfrmMain.UnDo;
var
 wrkI : GLInt;
begin
 objectCount := DobjectCount;        // количество объектов
 For wrkI := 1 to DobjectCount do    // массив объектов
     objects [wrkI] := Dobjects [wrkI];
 itUnDo.Enabled := False;            // пункт "Отменить"
 SetProjection(nil);
end;

{======================================================================
Изменение размеров объекта, если смотрим сверху}
procedure TfrmMain.ResizeObject (h : GLInt; mouseX, mouseY : GLInt);
var
  dX, dY : GLInt;
  WX1, WY1, WX2, WY2, dXS, dYS : GLFloat;
begin
  If PrevX < 0 then begin
     PrevX := mouseX;
     PrevY := mouseY;
     Exit;
  end;

  dX := mouseX - PrevX;
  dY := mouseY - PrevY;

  If (dX = 0) and (dY = 0) then Exit;

  ScreenToSpace (PrevX, PrevY, WX1, WY1);
  ScreenToSpace (mouseX, mouseY, WX2, WY2);

  dXS := Max (WX1, WX2) - Min(WX1, WX2);
  dYS := Max (WY1, WY2) - Min(WY1, WY2);

  Case h of
    // слева
    10, 11 : If dX > 0 then begin
                objects [MarkerObject].L  := objects [MarkerObject].L - 5 * dXS;
                objects [MarkerObject].X  := objects [MarkerObject].X + 5 * dXS;
                end
                else begin
                objects [MarkerObject].L  := objects [MarkerObject].L + 5 * dXS;
                objects [MarkerObject].X  := objects [MarkerObject].X - 5 * dXS;
             end;

    // справа
    14, 15 : If dX > 0 then objects [MarkerObject].L  := objects [MarkerObject].L + 10 * dXS
                       else objects [MarkerObject].L  := objects [MarkerObject].L - 10 * dXS;

    // сверху
    12, 13 : If dY > 0 then objects [MarkerObject].W  := objects [MarkerObject].W - 10 * dYS
                       else objects [MarkerObject].W  := objects [MarkerObject].W + 10 * dYS;

    // снизу
    8, 9 :   If dY > 0 then begin
                objects [MarkerObject].Y  := objects [MarkerObject].Y - 5 * dYS;
                objects [MarkerObject].W  := objects [MarkerObject].W + 5 * dYS;
                end
                else begin
                objects [MarkerObject].Y  := objects [MarkerObject].Y + 5 * dYS;
                objects [MarkerObject].W  := objects [MarkerObject].W - 5 * dYS;
             end;
  end; {case}

  If objects [MarkerObject].L < 0 then objects [MarkerObject].L := 0.001;
  If objects [MarkerObject].W < 0 then objects [MarkerObject].W := 0.001;

  PrevX := mouseX;
  PrevY := mouseY;
  DrawScene (GL_RENDER);
end;

{======================================================================
Изменение размеров объекта при произвольной точке зрения}
procedure TfrmMain.ResizeObjectXYZ (h : GLInt; mouseX, mouseY : GLInt);
var
  dX, dY : GLInt;
  WX1, WY1, WX2, WY2, dXS, dYS : GLFloat;
begin
  If PrevX < 0 then begin
     PrevX := mouseX;
     PrevY := mouseY;
     Exit;
  end;

  dX := mouseX - PrevX;
  dY := mouseY - PrevY;

  If (dX = 0) and (dY = 0) then Exit;

  ScreenToSpace (PrevX, PrevY, WX1, WY1);
  ScreenToSpace (mouseX, mouseY, WX2, WY2);

  dXS := Max (WX1, WX2) - Min(WX1, WX2);
  dYS := Max (WY1, WY2) - Min(WY1, WY2);

  // 8, 11, 12, 15 - внизу
  // 9, 10, 13, 14 - вверху

  case h of

     9 : begin
         If dX > 0 then begin
               objects [MarkerObject].Y  := objects [MarkerObject].Y + 5 * dXS;
               objects [MarkerObject].W  := objects [MarkerObject].W - 5 * dXS;
               end
               else begin
               objects [MarkerObject].Y  := objects [MarkerObject].Y - 5 * dXS;
               objects [MarkerObject].W  := objects [MarkerObject].W + 5 * dXS;
               end;
         If dY > 0 then objects [MarkerObject].H  := objects [MarkerObject].H - 10 * dYS
                   else objects [MarkerObject].H  := objects [MarkerObject].H + 10 * dYS;
         end;

     13: begin
         If dX > 0 then objects [MarkerObject].W  := objects [MarkerObject].W + 10 * dXS
                   else objects [MarkerObject].W  := objects [MarkerObject].W - 10 * dXS;
         If dY > 0 then objects [MarkerObject].H  := objects [MarkerObject].H - 10 * dYS
                   else objects [MarkerObject].H  := objects [MarkerObject].H + 10 * dYS;
         end;

     14: begin
         If dX > 0 then objects [MarkerObject].L  := objects [MarkerObject].L - 10 * dXS
                   else objects [MarkerObject].L  := objects [MarkerObject].L + 10 * dXS;
         If dY > 0 then objects [MarkerObject].H  := objects [MarkerObject].H - 10 * dYS
                   else objects [MarkerObject].H  := objects [MarkerObject].H + 10 * dYS;
         end;

     10: begin
         If dX > 0 then begin
               objects [MarkerObject].X  := objects [MarkerObject].X - 5 * dXS;
               objects [MarkerObject].L  := objects [MarkerObject].L + 5 * dXS;
               end
               else begin
               objects [MarkerObject].X  := objects [MarkerObject].X + 5 * dXS;
               objects [MarkerObject].L  := objects [MarkerObject].L - 5 * dXS;
         end;
         If dY > 0 then objects [MarkerObject].H  := objects [MarkerObject].H - 10 * dYS
                   else objects [MarkerObject].H  := objects [MarkerObject].H + 10 * dYS;
         end;

     12: begin
         If dX > 0 then objects [MarkerObject].W  := objects [MarkerObject].W + 10 * dXS
                   else objects [MarkerObject].W  := objects [MarkerObject].W - 10 * dXS;
         If dY > 0 then begin
               objects [MarkerObject].Z  := objects [MarkerObject].Z - 5 * dYS;
               objects [MarkerObject].H  := objects [MarkerObject].H + 5 * dYS;
               end
               else begin
               objects [MarkerObject].Z  := objects [MarkerObject].Z + 5 * dYS;
               objects [MarkerObject].H  := objects [MarkerObject].H - 5 * dYS;
         end;
         end;

     15: begin
         If dX > 0 then objects [MarkerObject].L  := objects [MarkerObject].L - 10 * dXS
                   else objects [MarkerObject].L  := objects [MarkerObject].L + 10 * dXS;
         If dY > 0 then begin
               objects [MarkerObject].Z  := objects [MarkerObject].Z - 5 * dYS;
               objects [MarkerObject].H  := objects [MarkerObject].H + 5 * dYS;
               end
               else begin
               objects [MarkerObject].Z  := objects [MarkerObject].Z + 5 * dYS;
               objects [MarkerObject].H  := objects [MarkerObject].H - 5 * dYS;
         end;
         end;

     8 : begin
         If dX > 0 then objects [MarkerObject].L  := objects [MarkerObject].L + 10 * dXS
                   else objects [MarkerObject].L  := objects [MarkerObject].L - 10 * dXS;
         If dY > 0 then begin
               objects [MarkerObject].Z  := objects [MarkerObject].Z - 5 * dYS;
               objects [MarkerObject].H  := objects [MarkerObject].H + 5 * dYS;
               end
               else begin
               objects [MarkerObject].Z  := objects [MarkerObject].Z + 5 * dYS;
               objects [MarkerObject].H  := objects [MarkerObject].H - 5 * dYS;
         end;
         end;

     11: begin
         If dX > 0 then objects [MarkerObject].L  := objects [MarkerObject].L - 10 * dXS
                   else objects [MarkerObject].L  := objects [MarkerObject].L + 10 * dXS;
         If dY > 0 then begin
               objects [MarkerObject].Z  := objects [MarkerObject].Z - 5 * dYS;
               objects [MarkerObject].H  := objects [MarkerObject].H + 5 * dYS;
               end
               else begin
               objects [MarkerObject].Z  := objects [MarkerObject].Z + 5 * dYS;
               objects [MarkerObject].H  := objects [MarkerObject].H - 5 * dYS;
         end;
         end;

  end; {case}

  If objects [MarkerObject].L < 0 then objects [MarkerObject].L := 0.001;
  If objects [MarkerObject].W < 0 then objects [MarkerObject].W := 0.001;
  If objects [MarkerObject].H < 0 then objects [MarkerObject].H := 0.001;

  PrevX := mouseX;
  PrevY := mouseY;
  DrawScene (GL_RENDER);
end;

{======================================================================
Перемещение объекта}
procedure TfrmMain.MoveObject (mouseX, mouseY : GLInt);
var
  dX, dY : GLInt;
  WX1, WY1, WX2, WY2, dXS, dYS : GLFloat;
begin
  If PrevX < 0 then begin
     PrevX := mouseX;
     PrevY := mouseY;
     Exit;
  end;

  dX := mouseX - PrevX;
  dY := mouseY - PrevY;

  If (dX = 0) and (dY = 0) then Exit;

  ScreenToSpace (PrevX, PrevY, WX1, WY1);
  ScreenToSpace (mouseX, mouseY, WX2, WY2);

  dXS := Max (WX1, WX2) - Min(WX1, WX2);
  dYS := Max (WY1, WY2) - Min(WY1, WY2);

  If HiWord (GetKeyState (VK_CONTROL)) = 0  {Ctrl не нажат}
     then begin
     If dX > 0 then objects [MarkerObject].x  := objects [MarkerObject].x - 10 * dXS
               else objects [MarkerObject].x  := objects [MarkerObject].x + 10 * dXS;
     If dY > 0 then objects [MarkerObject].y  := objects [MarkerObject].y + 10 * dYS
               else objects [MarkerObject].y  := objects [MarkerObject].y - 10 * dYS;
     end
     else  {Ctrl нажат}
     If dY > 0 then objects [MarkerObject].Z  := objects [MarkerObject].Z - 10 * dYS
               else objects [MarkerObject].Z  := objects [MarkerObject].Z + 10 * dYS;

  PrevX := mouseX;
  PrevY := mouseY;

  DrawScene (GL_RENDER);
end;

{**********************************************************************}
{****                        МЕТОДЫ ФОРМЫ                          ****}
{**********************************************************************}

{======================================================================
Обработка активизации редактора}
procedure TfrmMain.WMRestore (var Msg: TWMSysCommand);
begin
 inherited;
 SetProjection(nil);
end;

{======================================================================
Инициализация}
procedure TfrmMain.GLInit;
begin
 glEnable(GL_FOG);
 glEnable(GL_NORMALIZE);
 glEnable(GL_DEPTH_TEST);
 glEnable(GL_AUTO_NORMAL);

 glLightfv(GL_LIGHT0, GL_AMBIENT, @LightAmbient);
 glLightfv(GL_LIGHT0, GL_DIFFUSE, @LightDiffuse);
 glLightfv(GL_LIGHT0, GL_SPECULAR, @LightSpecular);
 glLightfv(GL_LIGHT0, GL_POSITION, @LightPosition);

 glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @LightModelAmbient);

 // второй источник света
 glLightfv(GL_LIGHT1, GL_AMBIENT, @LightAmbient);
 glLightfv(GL_LIGHT1, GL_DIFFUSE, @LightDiffuse);
 glLightfv(GL_LIGHT1, GL_SPECULAR, @LightSpecular);
 glLightfv(GL_LIGHT1, GL_POSITION, @Light2Position);

 glEnable(GL_LIGHTING);
 glEnable(GL_LIGHT0);
 glEnable(GL_LIGHT1);
end;

{======================================================================
Изменение размеров окна}
procedure TfrmMain.SetProjection(Sender: TObject);
begin
 flgMouseMove := False;

 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 glFrustum (vLeft, vRight, vBottom, vTop, zNear, zFar);
 glViewport(0, 0, ClientWidth - Panel1.Width, ClientHeight);
 glMatrixMode(GL_MODELVIEW);
 glGetIntegerv(GL_VIEWPORT, @vp);
 InvalidateRect(Handle, nil, False);
end;

{======================================================================
Начало работы приложения}
procedure TfrmMain.FormCreate(Sender: TObject);
begin
 SplashWindow := TSplashWindow.Create (nil);
 SplashWindow.Show;
 SplashWindow.Refresh;
 DC := GetDC(Handle);
 SetDCPixelFormat;
 hrc := wglCreateContext(DC);
 wglMakeCurrent(DC, hrc);
 Randomize;

 try
  LoadParam;
 except
  Start;
  itSaveParamClick (nil); // запишем параметры
 end;

 GLInit;

 // подготовка списков
 // подготовка к выводу символов
 wglUseFontOutlines(Canvas.Handle, 0, 91, id_Text, 0.0, 0.15, WGL_FONT_POLYGONS, nil);

 Quadric := gluNewQuadric;
 ListPrep;

 // параметры тумана
 glFogi(GL_FOG_MODE, GL_EXP);
 glFogfv(GL_FOG_COLOR, @ColorFog);
 glFogf(GL_FOG_DENSITY, 0.015);

 objectCount := 0;
 DobjectCount := 0;
 Markerobject := 0;
 PrevX := -100;
 PrevY := -100;
 SysFile := '';
 itUnDo.Enabled := False;                        // пункт "Отменить"

 glSelectBuffer(SizeOf(selectBuf), @selectBuf);  // создание буфера выбора

 SplashWindow.Free;
 SystemParametersInfo (spi_SetBeep, 0, nil, 0);  // выключить звуковой сигнал
 SetProjection(nil);
end;

{======================================================================
Аналог события OnPaint}
procedure TfrmMain.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);
  DrawScene(GL_RENDER);
  EndPaint(Handle, ps);
end;

{======================================================================
Конец работы приложения}
procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  // освобождение памяти - удаление списков и объекта
  glDeleteLists (id_Text, 92);
  glDeleteLists (DrawCube, 4);
  gluDeleteQuadric (Quadric);
  wglMakeCurrent (0, 0);
  wglDeleteContext (HRC);
  ReleaseDC (Handle, DC);
  SystemParametersInfo (spi_SetBeep, 1, nil, 0);  // включить звуковой сигнал
end;

{=======================================================================
Нажатие кнопки мыши}
procedure TfrmMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  hit := DoSelect (X, Y);
  If Button = mbLeft then
    case hit of
         -1 :    MarkerObject := 0;      // перестать метить объект
         1,2,3 : TransformView (hit);    // буква осей
         4,5,6,7 :// границы площадки разрешаем изменять только при виде сверху
                  If (AngX = 0) and (AngY = 0) then begin
                   flgDraging := True;    // площадка изменяется в размерах
                   DragingObject := hit;
                  end;
         8..15 :  begin                  // один из маркеров
                  Save;
                  flgDragObject := True; // объект изменяется в размерах
                  DragingObject := hit;
                  end;
         else {нажато на объекте}
            Save;
            MarkerObject := hit - startObjects; // пометить объект маркерами
            flgMoveObject := True;              // объект можно передвигать
    end // case
    else  {правая кнопка мыши}
    If hit < startObjects then begin
       itDelObject.Enabled := False;            // "удалить объект"
       itObjectParam.Enabled := False;          // "параметры объекта"
       end
       else begin
       PopupObject := hit - startObjects;    // номер объекта под курсором
       itDelObject.Enabled := True;          // "удалить объект"
       itObjectParam.Enabled := True;        // "параметры объекта"
  end;
  SetProjection(nil);
end;

{=======================================================================
Перемещение мыши}
procedure TfrmMain.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  // первое шевеление мышью пропускаем
  If not flgMouseMove then begin
     flgMouseMove := True;
     Exit;
  end;

  // изменяем в размерах площадку
  If flgDraging then begin
     ResizeSquare (DragingObject, X, Y);
     Exit;
  end;

  // изменяем в размерах объект
  If flgDragObject then begin
     If (AngX = 0) and (AngY = 0) then begin
        ResizeObject (DragingObject, X, Y);
        Exit;
        end
        else begin
        ResizeObjectXYZ (DragingObject, X, Y);
        Exit;
        end;
  end;

  // маркированнный объект перемещается
  If flgMoveObject then begin
     MoveObject (X, Y);
     Exit;
  end;

  // определяем, какой объект под курсором
  hit := DoSelect (X, Y);

  If (AngX = 0) and (AngY = 0) then           // Z
     case hit of
           4, 6, 8, 9, 12, 13 : Cursor := crSizeNS;   // стрелки вверх
           5, 7, 10, 11, 14, 15 : Cursor := crSizeWE; // стрелки вбок
           else
           Cursor := crDefault;      // курсор - обычный
     end // case
     else                            
     case hit of
       8..15 : Cursor := crSizeNS;   // маркеры - стрелки вверх
           else
           Cursor := crDefault;      // курсор - обычный
     end; // case
end;

{=======================================================================
Кнопка мыши отжата}
procedure TfrmMain.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  PrevX := -100;
  PrevY := -100;
  flgDraging := False;
  flgDragObject := False;
  flgMoveObject := False;
  SetProjection(nil);
end;

{=======================================================================
Нажатие клавиши}
procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then begin
     Close;
     Exit;
  end;
  If (Key = VK_DELETE) and (MarkerObject <> 0) then begin
     DeleteMarkerObject;
     Exit;
  end;
  If (Key = VK_RETURN) and (MarkerObject <> 0) then begin
     PopupObject := MarkerObject;
     itObjectParamClick (nil);
     Exit;
  end;
  If Key = VK_HOME then begin
     MarkerObject := MarkerObject - 1;
     If MarkerObject < 1 then MarkerObject := objectcount;
     SetProjection(nil);
     Exit;
  end;
  If Key = VK_END then begin
     MarkerObject := MarkerObject + 1;
     If MarkerObject > objectcount then MarkerObject := 1;
     SetProjection(nil);
     Exit;
  end;

  If Key = ord('X') then begin
     If MarkerObject = 0 then begin
        If not (ssAlt in Shift) then begin  {Alt  не нажат}
           If (ssShift in Shift)               {Shift нажат}
              then AngX := AngX - udRotX.Increment
              else AngX := AngX + udRotX.Increment;
           end
           else begin
           If (ssShift in Shift)               {Shift нажат}
              then AddX := AddX - udAddX.Increment
              else AddX := AddX + udAddX.Increment;
        end
        end
        else begin
        If not (ssAlt in Shift) then begin  {Alt  не нажат}
           If ssShift in Shift {Shift нажат}
              then objects [MarkerObject].X := objects [MarkerObject].X - udAddX.Increment
              else objects [MarkerObject].X := objects [MarkerObject].X + udAddX.Increment;
           end
           else begin
           If ssShift in Shift {Shift нажат}
              then objects [MarkerObject].RotX := objects [MarkerObject].RotX - udRotX.Increment
              else objects [MarkerObject].RotX := objects [MarkerObject].RotX + udRotX.Increment;
           end;
     end;
     SetProjection(nil);
     Exit;
  end;

  If Key = ord('Y') then begin
     If MarkerObject = 0 then begin
        If not (ssAlt in Shift) then begin  {Alt  не нажат}
           If (ssShift in Shift)               {Shift нажат}
              then AngY := AngY - udRotY.Increment
              else AngY := AngY + udRotY.Increment;
           end
           else begin
           If (ssShift in Shift)               {Shift нажат}
              then AddY := AddY - udAddY.Increment
              else AddY := AddY + udAddY.Increment;
        end
        end
        else begin
        If not (ssAlt in Shift) then begin  {Alt  не нажат}
           If ssShift in Shift {Shift нажат}
              then objects [MarkerObject].Y := objects [MarkerObject].Y - udAddY.Increment
              else objects [MarkerObject].Y := objects [MarkerObject].Y + udAddY.Increment;
           end
           else begin
           If ssShift in Shift {Shift нажат}
              then objects [MarkerObject].RotY := objects [MarkerObject].RotY - udRotY.Increment
              else objects [MarkerObject].RotY := objects [MarkerObject].RotY + udRotY.Increment;
           end;
     end;
     SetProjection(nil);
     Exit;
  end;

  If Key = ord('Z') then begin
     If MarkerObject = 0 then begin
        If not (ssAlt in Shift) then begin  {Alt  не нажат}
           If (ssShift in Shift)               {Shift нажат}
              then AngZ := AngZ - udRotZ.Increment
              else AngZ := AngZ + udRotZ.Increment;
           end
           else begin
           If (ssShift in Shift)               {Shift нажат}
              then AddZ := AddZ - udAddZ.Increment
              else AddZ := AddZ + udAddZ.Increment;
        end
        end
        else begin
        If not (ssAlt in Shift) then begin  {Alt  не нажат}
           If ssShift in Shift {Shift нажат}
              then objects [MarkerObject].Z := objects [MarkerObject].Z - udAddZ.Increment
              else objects [MarkerObject].Z := objects [MarkerObject].Z + udAddZ.Increment;
           end
           else begin
           If ssShift in Shift {Shift нажат}
              then objects [MarkerObject].RotZ := objects [MarkerObject].RotZ - udRotZ.Increment
              else objects [MarkerObject].RotZ := objects [MarkerObject].RotZ + udRotZ.Increment;
           end;
     end;
     SetProjection(nil);
     Exit;
  end;

  // I и i - "изометрическая" точка зрения
  If Key = 73 then begin
     AngX := 120;
     AngY := 180;
     AngZ := 40;
     AddX := 0;
     AddY := 0;
     AddZ := 0;
     SetProjection(nil);
     Exit;
  end;
end;

{*****************========   UP DOWN    =======************************}

{======================================================================
Расстояние}
procedure TfrmMain.udDistanceChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  If udDistance.Position < Perspective then begin
     vLeft := vLeft + 0.025;
     vRight := vRight - 0.025;
     vTop := vTop - 0.025;
     vBottom := vBottom + 0.025;
     end
     else If udDistance.Position > Perspective then begin
     vLeft := vLeft - 0.025;
     vRight := vRight + 0.025;
     vTop := vTop + 0.025;
     vBottom := vBottom - 0.025;
  end;
  Perspective := udDistance.Position;
  SetProjection(nil);
end;

{======================================================================
Нажатие кнопки на "Угол по оси Y"}
procedure TfrmMain.udRotYMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  If MarkerObject = 0 then begin
     If Y < udRotY.Height / 2
        then AngY := AngY - udRotY.Increment
        else AngY := AngY + udRotY.Increment;
     If AngY <= -360 then AngY := AngY + 360 else
        If AngY >= 360 then AngY := AngY - 360;
     end
     else begin
     If Y < udRotY.Height / 2
        then objects [MarkerObject].RotY := objects [MarkerObject].RotY - udRotY.Increment
        else objects [MarkerObject].RotY := objects [MarkerObject].RotY + udRotY.Increment;
     If objects [MarkerObject].RotY <= -360 then objects [MarkerObject].RotY := objects [MarkerObject].RotY + 360
     else
     If objects [MarkerObject].RotY >= 360 then objects [MarkerObject].RotY := objects [MarkerObject].RotY - 360;
  end;
  If not flgFirst then begin
     flgFirst := True;
     Save;
     Timer1.Enabled := True;
     flgudRotYChange := True;
  end;
  SetProjection(nil);
end;

{======================================================================
Кнопка отжата на "Угол по оси Y"}
procedure TfrmMain.udRotYMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  flgFirst := False;
  Timer1.Enabled := False;
  flgudRotYChange := False;
end;

{======================================================================
Кнопка нажата на "Угол по оси X"}
procedure TfrmMain.udRotXMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  If MarkerObject = 0 then begin
     If Y < udRotX.Height / 2
        then AngX := AngX - udRotX.Increment
        else AngX := AngX + udRotX.Increment;
     If AngX <= -360 then AngX := AngX + 360 else
        If AngX >= 360 then AngX := AngX - 360;
     end
     else begin
     If Y < udRotX.Height / 2
        then objects [MarkerObject].RotX := objects [MarkerObject].RotX - udRotX.Increment
        else objects [MarkerObject].RotX := objects [MarkerObject].RotX + udRotX.Increment;
     If objects [MarkerObject].RotX <= -360 then objects [MarkerObject].RotX := objects [MarkerObject].RotX + 360
     else
     If objects [MarkerObject].RotX >= 360 then objects [MarkerObject].RotX := objects [MarkerObject].RotX - 360;
  end;
  If not flgFirst then begin
     flgFirst := True;
     Save;
     flgudRotXChange := True;
     Timer1.Enabled := True;
  end;
  SetProjection(nil);
end;

{======================================================================
Кнопка отжата на "Угол по оси X"}
procedure TfrmMain.udRotXMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  flgFirst := False;
  Timer1.Enabled := False;
  flgudRotXChange := False;
end;

{======================================================================
Кнопка нажата на "Угол по оси Z"}
procedure TfrmMain.udRotZMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  If MarkerObject = 0 then begin
     If Y < udRotZ.Height / 2
        then AngZ := AngZ - udRotZ.Increment
        else AngZ := AngZ + udRotZ.Increment;
     If AngZ <= -360 then AngZ := AngZ + 360 else
        If AngZ >= 360 then AngZ := AngZ - 360;
     end
     else begin
     If Y < udRotZ.Height / 2
        then objects [MarkerObject].RotZ := objects [MarkerObject].RotZ - udRotZ.Increment
        else objects [MarkerObject].RotZ := objects [MarkerObject].RotZ + udRotZ.Increment;
     If objects [MarkerObject].RotZ <= -360 then objects [MarkerObject].RotZ := objects [MarkerObject].RotZ + 360
     else
     If objects [MarkerObject].RotZ >= 360 then objects [MarkerObject].RotZ := objects [MarkerObject].RotZ - 360;
  end;
  If not flgFirst then begin
     flgFirst := True;
     Save;
     flgudRotZChange := True;
     Timer1.Enabled := True;
  end;
  SetProjection(nil);
end;

{======================================================================
Кнопка отжата на "Угол по оси Z"}
procedure TfrmMain.udRotZMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  flgFirst := False;
  Timer1.Enabled := False;
  flgudRotZChange := False;
end;

{======================================================================
Кнопка нажата на "Сдвиг по оси X"}
procedure TfrmMain.udAddXMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  If MarkerObject = 0 then begin
     If Y < udAddX.Height / 2
        then AddX := AddX - udAddX.Increment
        else AddX := AddX + udAddX.Increment;
     end
     else begin
     If Y < udAddX.Height / 2
        then objects [MarkerObject].x := objects [MarkerObject].x - udAddX.Increment
        else objects [MarkerObject].x := objects [MarkerObject].x + udAddX.Increment;
  end;
  If not flgFirst then begin
     flgFirst := True;
     Save;
     flgudAddXChange := True;
     Timer1.Enabled := True;
  end;
  SetProjection(nil);
end;

{======================================================================
Кнопка отжата на "Сдвиг по оси X"}
procedure TfrmMain.udAddXMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  flgFirst := False;
  Timer1.Enabled := False;
  flgudAddXChange := False;
end;

{======================================================================
Кнопка нажата на "Сдвиг по оси Y"}
procedure TfrmMain.udAddYMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  If MarkerObject = 0 then begin
     If Y < udAddY.Height / 2
        then AddY := AddY - udAddY.Increment
        else AddY := AddY + udAddY.Increment;
     end
     else begin
     If Y < udAddY.Height / 2
        then objects [MarkerObject].y := objects [MarkerObject].y - udAddY.Increment
        else objects [MarkerObject].y := objects [MarkerObject].y + udAddY.Increment;
  end;
  If not flgFirst then begin
     flgFirst := True;
     Save;
     flgudAddYChange := True;
     Timer1.Enabled := True;
  end;
  SetProjection(nil);
end;

{======================================================================
Кнопка отжата на "Сдвиг по оси Y"}
procedure TfrmMain.udAddYMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  flgFirst := False;
  Timer1.Enabled := False;
  flgudAddYChange := False;
end;

{======================================================================
Кнопка нажата на "Сдвиг по оси Z"}
procedure TfrmMain.udAddZMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  If MarkerObject = 0 then begin
     If Y < udAddZ.Height / 2
        then AddZ := AddZ - udAddZ.Increment
        else AddZ := AddZ + udAddZ.Increment;
     end
     else begin
     If Y < udAddZ.Height / 2
        then objects [MarkerObject].Z := objects [MarkerObject].Z - udAddZ.Increment
        else objects [MarkerObject].Z := objects [MarkerObject].Z + udAddZ.Increment;
  end;
  If not flgFirst then begin
     flgFirst := True;
     Save;
     flgudAddZChange := True;
     Timer1.Enabled := True;
  end;
  SetProjection(nil);
end;

{======================================================================
Кнопка отжата на "Сдвиг по оси Z"}
procedure TfrmMain.udAddZMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  flgFirst := False;
  Timer1.Enabled := False;
  flgudAddYChange := False;
end;

{======================================================================
Уход указателя с UpDown углов и сдвигов}
procedure TfrmMain.udRotZMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 If (X < 0) or (X > 10) then begin
    flgudRotXChange := False;
    flgudRotYChange := False;
    flgudRotZChange := False;
    flgudAddXChange := False;
    flgudAddYChange := False;
    flgudAddZChange := False;
    flgFirst := False;
    Timer1.Enabled := False;
 end;
end;

{======================================================================
Длина осевых}
procedure TfrmMain.udAxesLengthChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  linelength := udAxesLength.Position;
  SetProjection(nil);
end;

{*****************========   CHECKBOX   =======************************}

{======================================================================
Оси}
procedure TfrmMain.cbxAxesClick(Sender: TObject);
begin
  If cbxAxes.Checked then begin
     itAxesOn.Checked := True;  // пункты попап
     itAxesOff.Checked := False;
     flgAxes := True;
     lblAxesLength.Visible := True;
     udAxesLength.Visible := True;
     end
     else begin
     itAxesOn.Checked := False;  // пункты попап
     itAxesOff.Checked := True;
     flgAxes := False;
     lblAxesLength.Visible := False;
     udAxesLength.Visible := False;
  end;
  SetProjection(nil);
end;

{======================================================================
Cетка}
procedure TfrmMain.cbxGridClick(Sender: TObject);
begin
  If cbxGrid.Checked then begin
     itGridOn.Checked := True;
     itGridOff.Checked := False;
     flgGrid := True
     end
     else begin
     itGridOn.Checked := False;
     itGridOff.Checked := True;
     flgGrid := False;
  end;
  SetProjection(nil);
end;

{======================================================================
Туман}
procedure TfrmMain.cbxFogClick(Sender: TObject);
begin
  If cbxFog.Checked then begin
     itFogOn.Checked := True;
     itFogOff.Checked := False;
     glEnable (GL_FOG);
     end
     else begin
     itFogOn.Checked := False;
     itFogOff.Checked := True;
     glDisable (GL_FOG);
  end;
  SetProjection(nil);
end;

{======================================================================
Площадка}
procedure TfrmMain.cbxGroundClick(Sender: TObject);
begin
  If cbxGround.Checked then begin
     itGroundOn.Checked := True;
     itGroundOff.Checked := False;
     flgSquare := True
     end
     else begin
     itGroundOn.Checked := False;
     itGroundOff.Checked := True;
     flgSquare := False;
  end;
  SetProjection(nil);
end;

{*****************==========   МЕТКИ  =========************************}

{======================================================================
Метки углов}
procedure TfrmMain.lblRotXMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  If MarkerObject = 0 then begin
     lblRotX.Hint := FloatToStr(AngX);
     lblRotY.Hint := FloatToStr(AngY);
     lblRotZ.Hint := FloatToStr(AngZ);
     end
     else begin
     lblRotX.Hint := FloatToStr(objects[MarkerObject].RotX);
     lblRotY.Hint := FloatToStr(objects[MarkerObject].RotY);
     lblRotZ.Hint := FloatToStr(objects[MarkerObject].RotZ);
  end;
end;

{======================================================================
Метка длины осевых}
procedure TfrmMain.lblAxesLengthMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  lblAxesLength.Hint := FloatToStr (LineLength)
end;

{======================================================================
Метки сдвигов}
procedure TfrmMain.lblAddXMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  If MarkerObject = 0 then begin
     lblAddX.Hint := FloatToStr(AddX);
     lblAddY.Hint := FloatToStr(AddY);
     lblAddZ.Hint := FloatToStr(AddZ);
     end
     else begin
     lblAddX.Hint := FloatToStr(objects[MarkerObject].x);
     lblAddY.Hint := FloatToStr(objects[MarkerObject].y);
     lblAddZ.Hint := FloatToStr(objects[MarkerObject].z);
  end;
end;

{*****************====== SPEEDBUTTON  =========************************}

{======================================================================
Кнопка "Загрузить"}
procedure TfrmMain.sbtnLoadClick(Sender: TObject);
begin
  LoadSystem;
end;

{======================================================================
Кнопка "Освежить"}
procedure TfrmMain.sbtnRefreshClick(Sender: TObject);
begin
 SetProjection(nil);
end;

{======================================================================
Кнопка "Записать"}
procedure TfrmMain.sbtnSaveClick(Sender: TObject);
begin
 SaveSystem;
end;

{*****************======== КНОПКИ МЕНЮ =======************************}

{======================================================================
Добавить ящик}
procedure TfrmMain.itAddObjectClick(Sender: TObject);
begin
 frmAddObject.Show;
end;

{======================================================================
Параметры сдвига}
procedure TfrmMain.N3Click(Sender: TObject);
begin
  frmParSdvig.Show;
end;

{======================================================================
Параметры углов}
procedure TfrmMain.N4Click(Sender: TObject);
begin
  frmParAngle.Show;
end;

{======================================================================
Записать параметры системы}
procedure TfrmMain.itSaveParamClick(Sender: TObject);
begin
 SaveParam;
end;

{======================================================================
Удалить объект}
procedure TfrmMain.itDelObjectClick(Sender: TObject);
begin
 ObjectDelete;
end;

{======================================================================
Параметры объекта}
procedure TfrmMain.itObjectParamClick(Sender: TObject);
begin
 frmParObject.Show;
end;

{======================================================================
Вкл - оси}
procedure TfrmMain.itAxesOnClick(Sender: TObject);
begin
 cbxAxes.Checked := not cbxAxes.Checked;
 cbxAxesClick (nil);
end;

{======================================================================
Вкл - сетка}
procedure TfrmMain.itGridOnClick(Sender: TObject);
begin
 cbxGrid.Checked := not cbxGrid.Checked;
 cbxGridClick (nil);
end;

{======================================================================
Вкл - площадка}
procedure TfrmMain.itGroundOnClick(Sender: TObject);
begin
 cbxGround.Checked := not cbxGround.Checked;
 cbxGroundClick (nil);
end;

{======================================================================
Вкл - туман}
procedure TfrmMain.itFogOnClick(Sender: TObject);
begin
 cbxFog.Checked := not cbxFog.Checked;
 cbxFogClick (nil);
end;

{======================================================================
Параметры системы - загрузить}
procedure TfrmMain.itLoadParamClick(Sender: TObject);
begin
 LoadParam;
 SetProjection(nil);
end;

{======================================================================
Цвет фона}
procedure TfrmMain.itColorBkGroundClick(Sender: TObject);
begin
 ColorToGLU(ColorBackground [0], ColorBackground [1], ColorBackground [2]);
 SetProjection(nil);
end;

{======================================================================
Цвет букв}
procedure TfrmMain.itColorLetterClick(Sender: TObject);
begin
 ColorToGlu (ColorLetter [0], ColorLetter [1], ColorLetter [2]);
 SetProjection(nil);
end;

{======================================================================
Масштаб букв}
procedure TfrmMain.itLetterScaleClick(Sender: TObject);
begin
 frmScaleLetter.Show;
end;

{======================================================================
Добавить параллепипед}
procedure TfrmMain.itAddCubeClick(Sender: TObject);
begin
 frmAddObject.Show;
 frmAddObject.cmbKind.ItemIndex := 0;
end;

{======================================================================
Добавить сферу}
procedure TfrmMain.itAddSphereClick(Sender: TObject);
begin
 frmAddObject.Show;
 frmAddObject.cmbKind.ItemIndex := 1;
end;

{======================================================================
Добавить цилиндр}
procedure TfrmMain.itAddCylinderClick(Sender: TObject);
begin
 frmAddObject.Show;
 frmAddObject.cmbKind.ItemIndex := 2;
end;

{======================================================================
Кнопка "Отменить"}
procedure TfrmMain.itUnDoClick(Sender: TObject);
begin
 UnDo;
end;

{*********************======== ПРОЧЕЕ =======**************************}

{======================================================================
Переход курсора на панель}
procedure TfrmMain.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 flgMouseMove := False;
end;

{======================================================================
Обработка таймера}
procedure TfrmMain.Timer1Timer(Sender: TObject);
var
 Cur: TPoint;
begin
 // Таймер используется, когда кнопка нажата на любом из UpDown
 // сдвига или угла.
 // Работа с UpDown углов и сдвигов прописана вручную, анализируется
 // местонахождение курсора и нажатие кнопки мыши.
 // Этим обеспечивается корректная работа UpDown.
 // Для сравнения UpDown расстояния и длины осевых на первое нажатие
 // срабатывает как нажатие с противоположным действием.
 GetCursorPos (Cur);
 If flgudRotXChange then begin
    Cur := udRotX.ScreenToClient (Cur);
    udRotXMouseDown(nil, mbLeft, [], Cur.X, Cur.Y);
    Exit;
 end;
 If flgudRotYChange then begin
    Cur := udRotY.ScreenToClient (Cur);
    udRotYMouseDown(nil, mbLeft, [], Cur.X, Cur.Y);
    Exit;
 end;
 If flgudRotZChange then begin
    Cur := udRotZ.ScreenToClient (Cur);
    udRotZMouseDown(nil, mbLeft, [], Cur.X, Cur.Y);
    Exit;
 end;
 If flgudAddXChange then begin
    Cur := udAddX.ScreenToClient (Cur);
    udAddXMouseDown(nil, mbLeft, [], Cur.X, Cur.Y);
    Exit;
 end;
 If flgudAddYChange then begin
    Cur := udAddY.ScreenToClient (Cur);
    udAddYMouseDown(nil, mbLeft, [], Cur.X, Cur.Y);
    Exit;
 end;
 If flgudAddZChange then begin
    Cur := udAddZ.ScreenToClient (Cur);
    udAddZMouseDown(nil, mbLeft, [], Cur.X, Cur.Y);
    Exit;
 end;
end;

end.
