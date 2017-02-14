// Процедура собственно рисования - команды OpenGL.
begin // используется в case
  // очистка буфера цвета и буфера глубины
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix; // запомнили текущую систему координат - 0,0
  // Установочный сдвиг
  glTranslatef(AddXYZ [1], AddXYZ [2], AddXYZ [3] - 7.0);
  glRotatef (AngleXYZ [1], 1, 0, 0);
  glRotatef (AngleXYZ [2], 0, 1, 0);
  glRotatef (AngleXYZ [3], 0, 0, 1);

  If flgSquare then glCallList (1); // рисуем площадку (плоскость узла)
  If flgOc then OcXYZ; // рисуем оси
  If flgLight then begin    // рисуем источник света
     glTranslatef (PLPosition^ [1], PLPosition^ [2], PLPosition^ [3]);
     gluSphere (ObjSphere, 0.01, 5, 5);
     glTranslatef (-PLPosition^ [1], -PLPosition^ [2], -PLPosition^ [3]);
  end;

  glScalef (CoeffX, CoeffY, CoeffZ);
  glTranslatef (0.0, 0.0, SmallB);
  glCallList (3);                  // пружина
  glCallList (10);                 // дырки в плите под болты
  glCallList (5);                  // плита

  glRotatef (AngleX, 1.0, 0.0, 0.0);
  glRotatef (AngleY, 0.0, 1.0, 0.0);
  glTranslatef (0.0, 0.0, Smallh);
  glCallList (4);                  // диск
  glCallList (8);                  // первый болт
  glCallList (9);                  // второй болт
  glRotatef (AngleZ, 0.0, 0.0, 1.0);
  glCallList (2);                  // шпильковерт со шпинделем
  glCallList (6);                  // патрон
  glCallList (7);                  // деталь

  glPopMatrix;

  // конец работы
  SwapBuffers(DC);
end;
