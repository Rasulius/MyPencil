{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

program ARM;

uses
  Windows, Messages, mmSystem, OpenGL;

const
  AppName = 'ARM'; // имя приложения

const // идентификаторы пунктов меню
  id_param = 101; // пункт "Параметры"
  id_about = 102; // пункт "О авторах"
  id_close = 103; // пункт "Выход"
  id_help = 104;  // пункт "Помощь"

const
  PerspNear : GlFloat = 30.0; // вспомогательная константа, с какого
                              // расстояния включать высокое разрешение
var
  AngleXYZ : Array [1..3] of GlFloat; // Массив поворота вокруг осей
  MyX, MyY : Array [0..5] of GlFloat; // Вспомогательный массив синусов и косинусов
  wrkArray : Array [0..5] of GlFloat; // Вспомогательный массив синусов и косинусов
  Colors : Array [1..3] of GlFloat;   // Массив цветов источника света
  Styles : Array [1..2] of Cardinal;  // стили (GL_FILL и прочее)
  Window : HWnd;
  uTimerId : uint;  // идентификатор таймера
  Message : TMsg;
  WindowClass : TWndClass;
  dc : HDC;
  hrc : HGLRC;
  hcDll : THandle; // контекст для DLL
  hcDllMaterials : THandle; // контекст для библиотеки установки материала
  glnWidth, glnHeight : GLsizei;
  ObjSphere, ObjCylinder : GLUquadricObj ;
  Angle : GlFloat;
  Perspective : GlFloat;
  flgOc : Boolean;       // Флаг, рисовать ли ось
  flgRotation : Boolean; // Флаг, вращать ли стол
  flgLight : Boolean;    // Флаг, рисовать ли источник света
  flgSquare : Boolean;   // Флаг, рисовать ли площадку
  flgCursor : Boolean;   // Флаг, рисовать ли курсор

var
  i, j : byte;
  wrkI : byte;            // счетчик движения шибера
  hStopki : GlFloat;      // высота стопки прокладок
  // вспомогательные массивы - для последней прокладки
  wrkArraySin : Array [1..20] of Single;
  wrkArrayCos : Array [1..20] of Single;

var                       // переменные, связанные с меню
  MenuPopup : HMenu;      // всплывающее меню

procedure FNTimeCallBack(uTimerID, uMessage: UINT;dwUser, dw1, dw2: DWORD) stdcall;
begin
  Angle := Angle + 0.1;
  If Angle > 60.0 then begin
      Angle := 0.0;
      flgRotation := False; // остановить вращение рабочего стола
  end;
  InvalidateRect(Window, nil, False);
end;

{$I SetDC}     // процедура установки формата пикселя
{$I OcXYZ}     // процедура рисования оси
{$I Start}     // стартовая процедура - чтение из файла, загрузка InitRC.dll
{$I SavePar}   // процедура записи параметров в файл
{$I Texture}   // процедура, связанная с текстурой
{$I About}     // процедура вывода окна "Об авторах" - работа c DLL
{$I ParForm}   // форма отображения параметров - работа c DLL
{$I Lists}     // процедура описания списков
{$I WinProc}   // оконная функция
{$I WinMain}   // точка входа в программу

begin
 // Проверяем есть ли указатель на предыдущую копию приложения
 If FindWindow (AppName, AppName) <> 0  then Exit;

 // Приоритет процесса - наивысший
 SetPriorityClass (GetCurrentProcess, HIGH_PRIORITY_CLASS);

 // загрузка процедур из библиотеки InitRC.dll - инициализация источника света
 hcDllMaterials := LoadLibrary('InitRC');
 If hcDllMaterials <= HINSTANCE_ERROR then begin
      MessageBox (0, 'Невозможно загрузить файл библиотеки InitRC.dll',
                     'Ошибка инициализации программы', mb_OK);
      Exit
 end;

 WinMain;
end.
