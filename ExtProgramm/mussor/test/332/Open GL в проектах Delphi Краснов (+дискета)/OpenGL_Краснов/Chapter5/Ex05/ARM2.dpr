{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

program ARM2;

uses
  Windows, Messages, mmSystem, OpenGL;

const
  AppName = 'Robot'; // имя приложения

const // идентификаторы пунктов меню
  id_param = 101;    // пункт "Параметры"
  id_about = 102;    // пункт "О авторах"
  id_close = 103;    // пункт "Выход"
  id_help = 104;     // пункт "Помощь"

const
  znear : GLFloat = 300.0;

{$I Constants}

var
  AngleXYZ : Array [1..3] of GlFloat; // Массив поворота вокруг осей
  AddXYZ : Array [1..3] of GlFloat;   // Массив сдвига по осям
  Colors : Array [1..3] of GlFloat;   // Массив цветов источника света
  Window : HWnd;
  uTimerId : uint;  // идентификатор таймера
  Message : TMsg;
  WindowClass : TWndClass;
  dc : HDC;
  hrc : HGLRC;
  hcDll : THandle; // контекст для DLL
  gldAspect : GLdouble ;
  glnWidth, glnHeight : GLsizei;
  Perspective : GlFloat;
  flgOc : Boolean;       // Флаг, рисовать ли ось
  flgRotation : Boolean; // Флаг, вращать ли стол
  flgLight : Boolean;    // Флаг, рисовать ли источник света
  flgSquare : Boolean;   // Флаг, рисовать ли площадку
  flgCursor : Boolean;   // Флаг, рисовать ли курсор

// объекты
var
  ObjSphere : GLUquadricObj ;    // источник света
  Sp, SpDisk : GLUquadricObj ;   // шпильковерт с диском
  CylCentral : GLUquadricObj ;   // центральное отверстие
  Cpindel : GLUquadricObj ;      // шпиндель
  Patron : GLUquadricObj ;       // патрон
  Disk1, Disk2 : GLUquadricObj ; // диски по бокам патрона
  Detal : GLUquadricObj ;        // цилиндрическая деталь
  Cyl1, Cyl2 : GLUquadricObj ;   // отверстия под винты

// переменные связанные с системой
var
  psi : GLFloat;         // угол "пси"
  tetta : GLFloat;       // угол "тетта"
  stepAngleX, stepAngleY, stepAngleZ : GLFloat;   // шаг изменения угла
  AngleX, AngleY, AngleZ : GlFloat;
  t, stept : GLFloat;    // время
  omega : GLFloat;       // угловая скорость - омега

var
  i, j : byte;

var                       // переменные, связанные с меню
  MenuPopup : HMenu;      // всплывающее меню

procedure FNTimeCallBack(uTimerID, uMessage: UINT;dwUser, dw1, dw2: DWORD) stdcall;
begin
  t := t + stept;
  AngleX := AngleX + stepAngleX;
  If (AngleX > 10.0) or (AngleX < -10.0) then  stepAngleX := -stepAngleX;
  AngleY := AngleY + stepAngleY;
  If (AngleY > 15.0) or (AngleY < -15.0) then stepAngleY := -stepAngleY;
  AngleZ := AngleZ + stepAngleZ;
  If (AngleZ > 360.0) then AngleZ := 0.0;

  InvalidateRect(Window, nil, False);
end;

{$I SetDC}     // процедура установки формата пикселя
{$I OcXYZ}     // процедура рисования оси
{$I Start}     // стартовая процедура - чтение из файла, загрузка InitRC.dll
{$I SavePar}   // процедура записи параметров в файл
{$I About}     // процедура вывода окна "Об авторах" - работа c DLL
{$I ParForm}   // форма отображения параметров - работа c DLL
{$I Hole}      // процедура отверстий
{$I Spring}    // пружина
{$I Lists}     // процедура описания списков
{$I WinProc}   // оконная функция
{$I WinMain}   // точка входа в программу

begin
  {проверяем, есть ли указатель на предыдущую копию приложения}
  If FindWindow (AppName, AppName) <> 0  then Exit;

  // Приоритет процесса - наивысший
  SetPriorityClass (GetCurrentProcess(), HIGH_PRIORITY_CLASS);
  // загрузка процедур из библиотеки InitRC.dll - инициализация источника света
  hcDllMaterials := LoadLibrary('InitRC');
  If hcDllMaterials <= HINSTANCE_ERROR then begin
      MessageBox (0, 'Невозможно загрузить файл библиотеки InitRC.dll',
                     'Ошибка инициализации программы', mb_OK);
      Exit
  end;

  WinMain;
end.

