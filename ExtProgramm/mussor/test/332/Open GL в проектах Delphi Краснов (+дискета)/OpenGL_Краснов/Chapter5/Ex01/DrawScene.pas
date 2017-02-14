begin // используется в case
  // очистка буфера цвета и буфера глубины
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix; // запомнили текущую систему координат
  glRotatef (AngleXYZ [1], 1, 0, 0);
  glRotatef (AngleXYZ [2], 0, 1, 0);
  glRotatef (AngleXYZ [3], 0, 0, 1);

  glPushMatrix; // запомнили текущую систему координат - 0,0
  If flgSquare then glCallList (4); // рисуем площадку
  If flgOc then OcXYZ;              // рисуем оси
  If flgLight then begin            // рисуем источник света
     glPushMatrix;
     glTranslatef (PLPosition^ [1], PLPosition^ [2], PLPosition^ [3]);
     gluSphere (ObjSphere, 0.01, 5, 5);
     glPopMatrix;
  end;

  glCallList (11);   // список - основание накопителя
  glCallList (1);    // штыри накопителя
  // стопка прокладок
  glTranslatef (0.1, -0.1, 0.0);

  glEnable (GL_TEXTURE_1D);  // на цилиндр накладывается текстура
  gluCylinder (ObjCylinder, 0.125, 0.125, hStopki, 50, 50);

  // последний уплотнитель в стопке
  glTranslatef (0.0, 0.0, hStopki);
  glCallList (5);
  glDisable (GL_TEXTURE_1D);

  // рисуем крышку накопителя
  glTranslatef (0.0, 0.0, 1.5 - hStopki);
  glCallList (10);

  // рисуем пневмоцилиндр
  glTranslatef (0.15, 0.0, -1.725);
  glRotatef (90.0, 0.0, 1.0, 0.0);
  glCallList (6);
  glRotatef (-90.0, 0.0, 1.0, 0.0);
  glTranslatef (-1.4, 0.0, 0.0);

  // рисуем штырь пневмоцилиндра
  If not (flgRotation) then begin        // флаг, вращать ли стол
  If wrkI = 0 then begin
     hStopki := hStopki - 0.025;         // уменьшить стопку
     If hStopki < 0 then hStopki := 1;   // стопка закончилась
  end;
  glPushMatrix;
  glTranslatef (0.9, 0.0, 0.0);
  glRotatef (90.0, 0.0, 1.0, 0.0);
  glCallList (8); // список - штырь пневмоцилиндра
  glPopMatrix;
  end;

  // рисуем шибер
  If flgRotation         // флаг, вращать ли стол
     then glTranslatef (1.25, 0.0, 0.0)
     else begin
     glTranslatef (0.75, 0.0, 0.0);
     Inc (wrkI);
  end;

  glRotatef (90.0, 0.0, 1.0, 0.0);
  // шибер - кубик
  glCallList (9);

  If (not flgRotation) and (wrkI = 4) then begin // пауза закончилась
     flgRotation := True;
     Angle := 0;
     wrkI := 0;
  end;

  glPopMatrix;     // текущая точка - 0, 0
  glCallList (7);  // ось рабочего стола

  glRotatef (90.0, 0.0, 1.0, 0.0);
  If flgRotation then // флаг, вращать ли стол
     glRotatef ( Angle, 1.0, 0.0, 0.0);
  glCallList (2);     // шесть цилиндров

  glRotatef (-90.0, 0.0, 1.0, 0.0);   // систему координат - назад
  glRotatef (-30.0, 0.0, 0.0, 1.0);   // смещаем для соответствия с кубиками

  // список - шесть кубиков - деталь
  glCallList (3);
  glPopMatrix;
  // конец работы
  SwapBuffers(DC);
end;
