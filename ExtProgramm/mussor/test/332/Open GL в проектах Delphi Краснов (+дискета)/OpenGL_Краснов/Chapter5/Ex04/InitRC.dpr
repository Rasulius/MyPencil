{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

// библиотека объединяет данные и процедуры,
// связанные с источником света и материалом
// данные и процедуры используются в основном модуле и
// из библиотеки окна параметров

library InitRC;

uses
  OpenGL;

type
  Array3D = Array [1..3] of GlFloat;
  Array4D = Array [1..4] of GlFloat;
  TMaterial = 1..8;
  PMaterial = ^TMaterial;
  PArray3D = ^Array3D;
  PArray4D = ^Array4D;

var
  Materials : TMaterial;      // текущий материал
  Material : Array [1..3] of PGlfloat; // Массив оптических свойств текущего материала
  LPosition : Array4D; // массив положения источника света
  FAmbient  : Array4D; // массив оптических свойств источника света, интенсивность света
  LDirection : Array3D; // массив направления источника света

const
  // Серебро
  // матрица фонового цвета материала
  AmbSteel : Array[0..3] of GLfloat = (0.19225, 0.19225, 0.19225, 1.0);
  // матрица диффузных свойств материала
  DifSteel : Array[0..3] of GLfloat = (0.50754, 0.50754, 0.50754, 1.0);
  // матрица зеркального цвета
  SpecSteel: Array[0..3] of GLfloat = (0.508273, 0.508273, 0.508273, 1.0);

  // Латунь
  // матрица фонового цвета материала
  AmbLatun : Array[0..3] of GLfloat = (0.329412, 0.223529, 0.027451, 1.0);
  // матрица диффузных свойств материала
  DifLatun : Array[0..3] of GLfloat = (0.780392, 0.568627, 0.113725, 1.0);
  // матрица зеркального цвета
  SpecLatun: Array[0..3] of GLfloat = (0.992157, 0.941176, 0.807843, 1.0);

  // Бронза
  // матрица фонового цвета материала
  AmbBronza : Array[0..3] of GLfloat = (0.2125, 0.1275, 0.054, 1.0);
  // матрица диффузных свойств материала
  DifBronza : Array[0..3] of GLfloat = (0.714, 0.4284, 0.18144, 1.0);
  // матрица зеркального цвета
  SpecBronza : Array[0..3] of GLfloat = (0.393548, 0.271906, 0.166721, 1.0);

  // Хром
  // матрица фонового цвета материала
  AmbXPOM : Array[0..3] of GLfloat = (0.25, 0.25, 0.25, 1.0);
  // матрица диффузных свойств материала
  DifXPOM : Array[0..3] of GLfloat = (0.4, 0.4, 0.4, 1.0);
  // матрица зеркального цвета
  SpecXPOM : Array[0..3] of GLfloat = (0.774597, 0.774597, 0.774597, 1.0);

  // Красный каучук
  // матрица фонового цвета материала
  AmbRedK : Array[0..3] of GLfloat = (0.05, 0.0, 0.0, 1.0);
  // матрица диффузных свойств материала
  DifRedK : Array[0..3] of GLfloat = (0.5, 0.4, 0.4, 1.0);
  // матрица зеркального цвета
  SpecRedK : Array[0..3] of GLfloat = (0.7, 0.04, 0.04, 1.0);

  // Вулканическое стекло
  // матрица фонового цвета материала
  AmbGlassV : Array[0..3] of GLfloat = (0.05375, 0.05, 0.06625, 1.0);
  // матрица диффузных свойств материала
  DifGlassV : Array[0..3] of GLfloat = (0.18275, 0.17, 0.22525, 1.0);
  // матрица зеркального цвета
  SpecGlassV : Array[0..3] of GLfloat = (0.332741, 0.328634, 0.346435, 1.0);

  // Циановый пластик
  // матрица фонового цвета материала
  AmbCyanP : Array[0..3] of GLfloat = (0.0, 0.1, 0.06, 1.0);
  // матрица диффузных свойств материала
  DifCyanP : Array[0..3] of GLfloat = (0.0, 0.50980392, 0.50980392, 1.0);
  // матрица зеркального цвета
  SpecCyanP : Array[0..3] of GLfloat = (0.50196078, 0.50196078, 0.50196078, 1.0);

  // Золото
  AmbGold : Array[0..3] of GLfloat = (0.24725, 0.1995, 0.0745, 1.0);
  DifGold : Array[0..3] of GLfloat = (0.75164, 0.60648, 0.22648, 1.0);
  SpecGold : Array[0..3] of GLfloat = (0.628281, 0.555802, 0.366065, 1.0);

// процедура инициализации источника света
procedure InitializeRC; export; stdcall;
begin
  glEnable(GL_DEPTH_TEST);// разрешаем тест глубины
  glEnable (GL_COLOR_MATERIAL);
  glEnable(GL_NORMALIZE);

  // Добавляем источник света 0
  glLightfv(GL_LIGHT0, GL_AMBIENT, Material [1]); // фоновый цвет материала
  glLightfv(GL_LIGHT0, GL_DIFFUSE, Material [2]); // диффузные свойства материала
  glLightfv(GL_LIGHT0, GL_SPECULAR,Material [3]); // зеркальный цвет материала

  // Положение источника света
  glLightfv(GL_LIGHT0, GL_POSITION, @LPosition);
  // Направление света
  glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, @LDirection);

  // Команды работы с моделью освещенности
  glLightModelfv (GL_LIGHT_MODEL_AMBIENT, @FAmbient); // Фоновая освещенность

  glEnable(GL_LIGHTING); // разрешаем работу с освещенностью
  glEnable(GL_LIGHT0);   // включаем источник света 0
end;

// Процедура установки выбранного материала
procedure SetMaterial; export; stdcall;
begin
  Case Materials of
  1 : begin
      Material [1] := @AmbBronza;
      Material [2] := @DifBronza;
      Material [3] := @SpecBronza;
      glMaterialf(GL_FRONT, GL_SHININESS, 25.6); // бронза - 0.2*128.0
      end;
  2 : begin
      Material [1] := @AmbSteel;
      Material [2] := @DifSteel;
      Material [3] := @SpecSteel;
      glMaterialf(GL_FRONT, GL_SHININESS, 51.2);//0.4*128.0); - серебро
      end;
  3 : begin
      Material [1] := @AmbLatun;
      Material [2] := @DifLatun;
      Material [3] := @SpecLatun;
      glMaterialf(GL_FRONT, GL_SHININESS, 27.89743616); // латунь - 0.21794872*128.0
      end;
  4 : begin
      Material [1] := @AmbXPOM;
      Material [2] := @DifXPOM;
      Material [3] := @SpecXPOM;
      glMaterialf(GL_FRONT, GL_SHININESS, 76.8); // хром - 0.6*128.0
      end;
  5 : begin
      Material [1] := @AmbRedK;
      Material [2] := @DifRedK;
      Material [3] := @SpecRedK;
      glMaterialf(GL_FRONT, GL_SHININESS, 10.0); // красный каучук - .078125*128.0
      end;
  6 : begin
      Material [1] := @AmbGlassV;
      Material [2] := @DifGlassV;
      Material [3] := @SpecGlassV;
      glMaterialf(GL_FRONT, GL_SHININESS, 38.4); // вулканическое стекло - .3*128.0
      end;
  7 : begin
      Material [1] := @AmbCyanP;
      Material [2] := @DifCyanP;
      Material [3] := @SpecCyanP;
      glMaterialf(GL_FRONT, GL_SHININESS, 32.0); // циановый пластик - .25*128.0
      end;
  8 : begin
      Material [1] := @AmbGold;
      Material [2] := @DifGold;
      Material [3] := @SpecGold;
      glMaterialf(GL_FRONT, GL_SHININESS, 51.2); // золото - .4*128.0
      end;
  end; // case
  // цвет материала и диффузное отражение материала - значения из массива
  glMaterialfv (GL_FRONT, GL_AMBIENT, Material [1]);
  glMaterialfv (GL_FRONT, GL_DIFFUSE, Material [2]);
  glMaterialfv (GL_FRONT, GL_SPECULAR, Material [3]);
  InitializeRC;
end;

// процедура увеличения константы материала
// вызывается при нажатии на клавишу "M"
procedure IncMaterials; export; stdcall;
begin
  Inc (Materials);
  If Materials > 8 then Materials := 1; // количество материалов
  SetMaterial; // для удобства здесь же устанавливается материал
end;

// процедура вызывается при запуске приложения
// процедура задает значения указателей на данные внутри DLL
// возвращает измененные значения указателей
procedure GetData (var PMaterials : PMaterial;
                   var PLPosition : PArray4D;
                   var PFAmbient  : PArray4D;
                   var PLDirection : PArray3D); export; stdcall;
begin
  PMaterials := @Materials;
  PLPosition := @LPosition;
  PFAmbient  := @FAmbient;
  PLDirection := @LDirection;
end;

exports { список экспортируемых функций }
        InitializeRC,
        SetMaterial,
        IncMaterials,
        GetData;
begin // инициализация библиотеки
  // при инициализации материал задаем "бронза"
  // если материал считывается из файла, первоначальные установки забиваются

  Materials := 1;

  Material [1] := @AmbBronza;
  Material [2] := @DifBronza;
  Material [3] := @SpecBronza;
  // цвет материала и диффузное отражение материала - значения из массива
  glMaterialfv(GL_FRONT, GL_AMBIENT, Material [1]);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, Material [2]);
  glMaterialfv(GL_FRONT, GL_SPECULAR, Material [3]);
  glMaterialf(GL_FRONT, GL_SHININESS, 51.2);
end.
