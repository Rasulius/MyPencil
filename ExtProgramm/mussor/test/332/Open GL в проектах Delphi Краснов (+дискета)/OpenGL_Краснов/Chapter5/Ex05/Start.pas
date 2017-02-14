// стартовая процедура
// загрузки библиотеки InitRC
// и чтения данных из файла

// процедуры, считываемые из библиотеки InitRC
type
  Array3D = Array [1..3] of GlFloat;
  Array4D = Array [1..4] of GlFloat;
  TMaterial = 1..8;
  PMaterial = ^TMaterial;
  PArray3D = ^Array3D; // указатели на массивы
  PArray4D = ^Array4D;
  TIncMaterials = procedure stdcall;
  TInitializeRC = procedure stdcall;
  TGetData = procedure (var PMaterials : PMaterial;
                        var PLPosition : PArray4D;
                        var PFAmbient  : PArray4D;
                        var PRPosition : PArray3D); stdcall;

var
  hcDllMaterials : THandle; // контекст для библиотеки установки материала
  IncMaterials : TIncMaterials;
  InitializeRC : TInitializeRC;
  GetData : TGetData;
  PMaterials : PMaterial; // указатель на материал
  // указатели на массивы в библиотеке
  PLPosition : PArray4D;
  PFAmbient  : PArray4D;
  PRPosition : PArray3D;

procedure Start;
var
  flgFileError : Boolean;
  ResFile : File of GlFloat;
  wrk : TWIN32FindData;
  wrkSingle : Single;
begin
  // загрузка процедур из библиотеки InitRC.dll - инициализация источника света
  IncMaterials := GetProcAddress (hcDllMaterials, 'IncMaterials');
  InitializeRC := GetProcAddress (hcDllMaterials, 'InitializeRC');
  GetData := GetProcAddress (hcDllMaterials, 'GetData');
  GetData (PMaterials, // указатель - на материал в библиотеке
           PLPosition, // указатели - на массивы в библиотеке
           PFAmbient,
           PRPosition);

  // чтение данных из файла - записанные параметры

  flgFileError := False; // Вспомогательный флаг - ошибка чтения файла

  If FindFirstFile ('ARM2.dat', wrk) <> INVALID_HANDLE_VALUE then
  try
     AssignFile (ResFile,'ARM2.dat');
     Reset (ResFile);
    try
     Read (ResFile, Colors [1]);
     Read (ResFile, Colors [2]);
     Read (ResFile, Colors [3]);

      // Положение источника света
     Read (ResFile, PLPosition^ [1]);
     Read (ResFile, PLPosition^ [2]);
     Read (ResFile, PLPosition^ [3]);
     Read (ResFile, PLPosition^ [4]);

      // Направление света
     Read (ResFile, PRPosition^ [1]);
     Read (ResFile, PRPosition^ [2]);
     Read (ResFile, PRPosition^ [3]);

      // Интенсивность света
     Read (ResFile, PFAmbient^ [1]);
     Read (ResFile, PFAmbient^ [2]);
     Read (ResFile, PFAmbient^ [3]);
     Read (ResFile, PFAmbient^ [4]);

     Read (ResFile, AngleXYZ [1]);  // Угол поворота точки зрения по оси X
     Read (ResFile, AngleXYZ [2]);  // Угол поворота точки зрения по оси Y
     Read (ResFile, AngleXYZ [3]);  // Угол поворота точки зрения по оси Z
     Read (ResFile, Perspective);   // Перспектива

     Read (ResFile, AddXYZ [1]);    // сдвиг по оси X
     Read (ResFile, AddXYZ [2]);    // сдвиг по оси Y
     Read (ResFile, AddXYZ [3]);    // сдвиг по оси Z

     Read (ResFile, wrkSingle);     // считывание материала
     Case Round (wrkSingle) of      // на единицу меньше,
          1 : PMaterials^ := 8;     // чтобы воспользоваться IncMaterials
          2 : PMaterials^ := 1;
          3 : PMaterials^ := 2;
          4 : PMaterials^ := 3;
          5 : PMaterials^ := 4;
          6 : PMaterials^ := 5;
          7 : PMaterials^ := 6;
          8 : PMaterials^ := 7;
     end; // case
     IncMaterials;

     // рисовать ли площадку
     Read (ResFile, wrkSingle);
     If wrkSingle = 1 then flgSquare := True
                      else flgSquare := False;

     // рисовать ли оси
     Read (ResFile, wrkSingle);
     If wrkSingle = 1 then flgOc := True
                      else flgOc := False;

     // рисовать ли источник света
     Read (ResFile, wrkSingle);
     If wrkSingle = 1 then flgLight := True
                      else flgLight := False;

     // рисовать ли курсор
     Read (ResFile, wrkSingle);
     If wrkSingle = 1 then flgCursor := True
                      else flgCursor := False;

    finally
     CloseFile (ResFile);
    end; // try
  except
     flgFileError := True;
  end // try
  else flgFileError := True;
  If  flgFileError then   // Ошибка чтения файла
  begin

      // Цвет источника света
      Colors [1] := 1.0;
      Colors [2] := 1.0;
      Colors [3] := 1.0;

      // Положение источника света
      PLPosition^ [1] := 0.5;
      PLPosition^ [2] := 0.5;
      PLPosition^ [3] := 0.5;
      PLPosition^ [4] := 0.0;

      // Направление света
      PRPosition^ [1] := 0.0;
      PRPosition^ [2] := 0.0;
      PRPosition^ [3] := -1.0;

      // Интенсивность света
      PFAmbient^ [1] := 0.2;
      PFAmbient^ [2] := 0.2;
      PFAmbient^ [3] := 0.2;
      PFAmbient^ [4] := 1.0;

      AngleXYZ [1] := -90;  // Угол поворота точки зрения по оси X
      AngleXYZ [2] := 0;    // Угол поворота точки зрения по оси Y
      AngleXYZ [3] := 220;  // Угол поворота точки зрения по оси Z
      Perspective := 25.0;  // Перспектива

      AddXYZ [1] := 0.0;    // сдвиг по оси X
      AddXYZ [2] := 0.0;    // сдвиг по оси Y
      AddXYZ [3] := 0.0;    // сдвиг по оси Z

      flgOc := False;       // Ось - не рисовать
      flgSquare := False;   // Флаг, рисовать ли площадку
      flgLight := False;    // Флаг, рисовать ли источник света
      flgCursor := False;   // Флаг, рисовать ли курсор

  end;
end;
