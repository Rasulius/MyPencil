// процедура записи параметров в файл
procedure SavePar;
var
  ResFile : File of GlFloat;
  wrkSingle : Single;
begin
  try
     AssignFile (ResFile,'ARM.dat');
     ReWrite (ResFile);
     Write (ResFile, Colors [1]);
     Write (ResFile, Colors [2]);
     Write (ResFile, Colors [3]);
     // Положение источника света
     Write (ResFile, PLPosition^ [1]);
     Write (ResFile, PLPosition^ [2]);
     Write (ResFile, PLPosition^ [3]);
     Write (ResFile, PLPosition^ [4]);

     // Направление света
     Write (ResFile, PRPosition^ [1]);
     Write (ResFile, PRPosition^ [2]);
     Write (ResFile, PRPosition^ [3]);

     // Интенсивность света
     Write (ResFile, PFAmbient^ [1]);
     Write (ResFile, PFAmbient^ [2]);
     Write (ResFile, PFAmbient^ [3]);
     Write (ResFile, PFAmbient^ [4]);

     Write (ResFile, AngleXYZ [1]);  // Угол поворота точки зрения по оси X
     Write (ResFile, AngleXYZ [2]);  // Угол поворота точки зрения по оси Y
     Write (ResFile, AngleXYZ [3]);  // Угол поворота точки зрения по оси Z
     Write (ResFile, Perspective);   // Перспектива

     // запись материала
     wrkSingle := PMaterials^;
     Write (ResFile, wrkSingle);

     // записать - рисовать ли площадку
     If flgSquare then wrkSingle := 1.0
                  else wrkSingle := 0.0;
     Write (ResFile, wrkSingle);

     // записать - рисовать ли оси
     If flgOc then wrkSingle := 1.0
              else wrkSingle := 0.0;
     Write (ResFile, wrkSingle);

     // записать - рисовать ли источник света
     If flgLight then wrkSingle := 1.0
                 else wrkSingle := 0.0;
     Write (ResFile, wrkSingle);

     // записать - рисовать ли курсор
     If flgCursor then wrkSingle := 1.0
                 else wrkSingle := 0.0;
     Write (ResFile, wrkSingle);

  finally
     CloseFile (ResFile);
  end; // try
end;
