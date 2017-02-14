function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; export; stdcall;
Begin
  WindowProc := 0;
  case Message of
  wm_Destroy :
      begin
      ShowCursor (True);
      PostMessage(Window, WM_SYSCOMMAND, SC_MINIMIZE, 0);
      timeKillEvent(uTimerID);
      glDeleteLists (1, 10);
      gluDeleteQuadric (ObjSphere);
      gluDeleteQuadric (Sp);
      gluDeleteQuadric (SpDisk);
      gluDeleteQuadric (CylCentral);
      gluDeleteQuadric (Cpindel);
      gluDeleteQuadric (Patron);
      gluDeleteQuadric (Disk1);
      gluDeleteQuadric (Disk2);
      gluDeleteQuadric (Detal);
      gluDeleteQuadric (Cyl1);
      gluDeleteQuadric (Cyl2);
      wglMakeCurrent (0, 0);
      wglDeleteContext (hrc); // удаление контекста воспроизведени€
      // удаление ссылки на библиотеку
      If not hcDllMaterials = NULL then begin
         FreeLibrary(hcDllMaterials);
         hcDllMaterials := NULL;
      end;
      DestroyMenu (MenuPopup);
      ReleaseDC (Window, DC);
      DeleteDC (DC);
      PostQuitMessage (0);
      Exit;
      end;
  wm_Create:
      begin
      // окно - максимизировать
      SendMessage(Window, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
      dc := GetDC (Window);
      SetDCPixelFormat;
      hrc := wglCreateContext (dc); // создание контекста воспроизведени€
      wglMakeCurrent(DC, hrc);
      ObjSphere := gluNewQuadric;   // источник света
      Sp := gluNewQuadric;          // шпильковерт
      SpDisk := gluNewQuadric;      // диск
      CylCentral := gluNewQuadric;  // центральное отверстие в плите
      gluQuadricOrientation (CylCentral, GLU_INSIDE);
      Cpindel := gluNewQuadric;     // шпиндель
      Patron :=  gluNewQuadric;     // патрон
      Disk1 :=  gluNewQuadric;
      Disk2 :=  gluNewQuadric;      // диски по бокам патрона
      gluQuadricOrientation (Disk2, GLU_INSIDE);
      Detal :=  gluNewQuadric;      // цилиндрическа€ деталь
      Cyl1 :=  gluNewQuadric;
      Cyl2 :=  gluNewQuadric;       // отверсти€ под болты
      gluQuadricOrientation (Cyl1, GLU_INSIDE);
      gluQuadricOrientation (Cyl2, GLU_INSIDE);

      Start; // ѕроцедура чтени€ данных из файла

      If not flgCursor then ShowCursor (False); // рисовать ли курсор

      glColor3f (Colors [1], Colors [2], Colors [3]);
      InitializeRC;   // »нициализаци€ источника света

      Lists;                  // процедура описани€ списков
      AngleX := 0.0;
      AngleY := 0.0;
      AngleZ := 0.0;
      stepAngleX := 0.025;
      stepAngleY := 0.065;
      stepAngleZ := 1.25;
      t := 0;
      stept := 0.01;
      omega := 0.5;
      end; // wm_Create
  wm_Size:  // при изменении размеров окна отслеживаем текущие размеры окна
      begin
      glnWidth := LoWord (lParam);
      glnHeight := HiWord (lParam);
      gldAspect := glnWidth / glnHeight;
      glMatrixMode(GL_PROJECTION);
      glLoadIdentity;
      gluPerspective(Perspective,  gldAspect, 1.0, znear);
      glViewport(0, 0, glnWidth, glnHeight);
      glMatrixMode(GL_MODELVIEW);
      glLoadIdentity; 
      end;
  wm_Help : // нажата клавиша F1
      begin
      ShowCursor (True);
      WinHelp(Window, 'ARM', HELP_CONTENTS, 0);
      If not flgCursor then ShowCursor (False); // рисовать ли курсор
      end;
  wm_Paint:
      {$I DrawScene} // дл€ сокращени€ количества инструкций
  wm_Char:  // анализ нажатых клавиш
      case wParam of
           VK_ESCAPE : SendMessage (Window, wm_Destroy, wParam, lParam);
  { X, x } $58,$78 : If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then AngleXYZ [1] := AngleXYZ [1] + 5
                     else AngleXYZ [1] := AngleXYZ [1] - 5;
  { Y, y } $59,$79 : If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then AngleXYZ [2] := AngleXYZ [2] + 5
                     else AngleXYZ [2] := AngleXYZ [2] - 5;
  { Z, z } $5A,$80 : If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then AngleXYZ [3] := AngleXYZ [3] + 5
                     else AngleXYZ [3] := AngleXYZ [3] - 5;
  { O, o } $4F,$6F : flgOc := not flgOc;
  { P, p}  $50,$70 : flgSquare := not flgSquare;
  { >, .}   62,46  : If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then AddXYZ [1] := AddXYZ [1] + 0.1
                     else AddXYZ [1] := AddXYZ [1] - 0.1;
  { <, ,}   60,44  : If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then AddXYZ [2] := AddXYZ [2] + 0.1
                     else AddXYZ [2] := AddXYZ [2] - 0.1;
  { /, ?}   47,63  : If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then AddXYZ [3] := AddXYZ [3] + 0.1
                     else AddXYZ [3] := AddXYZ [3] - 0.1;
  { Space } $20    : begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then
                     begin
                     Perspective := Perspective - 0.5;
                     end
                     else
                     begin
                     Perspective := Perspective + 0.5;
                     end;
                     glMatrixMode(GL_PROJECTION);
                     glLoadIdentity;
                     gluPerspective(Perspective, gldAspect, 1.0, znear);
                     glViewport(0, 0, glnWidth, glnHeight);
                     glMatrixMode(GL_MODELVIEW);
                     glLoadIdentity;
                     end;
  { M, m } $4D, $6D : IncMaterials; // ѕроцедура установки выбранного материала
  { R, r } $52,$72 : begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then Colors [1] := Colors [1] + 0.05
                     else Colors [1] := Colors [1] - 0.05;
                     If Colors [1] > 1.0 then
                                         begin
                                         Colors [1] := 1.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     If Colors [1] < 0.0 then
                                         begin
                                         Colors [1] := 0.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     glColor3f (Colors [1], Colors [2], Colors [3]);
                     end;
  { G, g } $47,$67 : begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then Colors [2] := Colors [2] + 0.05
                     else Colors [2] := Colors [2] - 0.05;
                     If Colors [2] > 1.0 then
                                         begin
                                         Colors [2] := 1.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     If Colors [2] < 0.0 then
                                         begin
                                         Colors [2] := 0.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     glColor3f (Colors [1], Colors [2], Colors [3]);
                     end;
  { B, b } $42,$62 : begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then Colors [3] := Colors [3] + 0.05
                     else Colors [3] := Colors [3] - 0.05;
                     If Colors [3] > 1.0 then
                                         begin
                                         Colors [3] := 1.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     If Colors [3] < 0.0 then
                                         begin
                                         Colors [3] := 0.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     glColor3f (Colors [1], Colors [2], Colors [3]);
                     end;
  { W, w }$57, $77 : begin
                     Colors [1] := 1.0;
                     Colors [2] := 1.0;
                     Colors [3] := 1.0;
                     glColor3f (Colors [1], Colors [2], Colors [3]);

                     // ѕоложение источника света
                     PLPosition^ [1] := 0.5;
                     PLPosition^ [2] := 0.5;
                     PLPosition^ [3] := 0.5;
                     PLPosition^ [4] := 0.0;

                     // Ќаправление света
                     PRPosition^ [1] := 0.0;
                     PRPosition^ [2] := 0.0;
                     PRPosition^ [3] := -1.0;

                     // »нтенсивность света
                     PFAmbient^ [1] := 0.2;
                     PFAmbient^ [2] := 0.2;
                     PFAmbient^ [3] := 0.2;
                     PFAmbient^ [4] := 1.0;

                     InitializeRC;
                     end;
   { L, l }$4C, $6C: flgLight := not (flgLight);
   { S, s }$53, $73: SavePar; // «апись параметров в файл
   { C, c }$43, $63: begin
                     flgCursor := not flgCursor;
                     If flgCursor=False then ShowCursor (False)
                                        else ShowCursor (True); // рисовать ли курсор
                     end;
      end; // wm_Char
   wm_KeyDown:  // анализ нажатых клавиш
      case wParam of
//  лавиши управлени€ курсором - положение источника света
// — Ctrl - направление света
  { Left }$25      : begin
                     If HiWord (GetKeyState (vk_CONTROL)) = 0  { Ctrl не нажат}
                     then
                     begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PLPosition^ [1] := PLPosition^ [1] + 0.01
                     else PLPosition^ [1] := PLPosition^ [1] - 0.01;
                     end
                     else
                     begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PRPosition^ [1] := PRPosition^ [1] + 0.025
                     else PRPosition^ [1] := PRPosition^ [1] - 0.025;
                     end;
                     InitializeRC;
                     end;
  { Up }  $26      : begin
                     If HiWord (GetKeyState (vk_CONTROL)) = 0  { Ctrl не нажат}
                     then
                     begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PLPosition^ [3] := PLPosition^ [3] + 0.01
                     else PLPosition^ [3] := PLPosition^ [3] - 0.01;
                     end
                     else
                     begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PRPosition^ [3] := PRPosition^ [3] + 0.025
                     else PRPosition^ [3] := PRPosition^ [3] - 0.025;
                     end;
                     InitializeRC;
                     end;
  { Right }$27     : begin
                     If HiWord (GetKeyState (vk_CONTROL)) = 0  { Ctrl не нажат}
                     then
                     begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PLPosition^ [2] := PLPosition^ [2] + 0.01
                     else PLPosition^ [2] := PLPosition^ [2] - 0.01;
                     end
                     else
                     begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PRPosition^ [2] := PRPosition^ [2] + 0.025
                     else PRPosition^ [2] := PRPosition^ [2] - 0.025;
                     end;
                     InitializeRC;
                     end;
  { Down } $28     : begin
                     If HiWord (GetKeyState (vk_CONTROL)) = 0  { Ctrl не нажат}
                     then
                     begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PLPosition^ [4] := PLPosition^ [4] + 0.01
                     else PLPosition^ [4] := PLPosition^ [4] - 0.01;
                     end;
                     InitializeRC;
                     end;
//  лавиши управлени€ курсором на цифровой клавиатуре
// - интенсивность света при включенном NumLock
  { Left }$64      : begin
                     If HiWord (GetKeyState (vk_NumLock)) = 1 { NumLock включен }
                     then
                     begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PFAmbient^ [1] := PFAmbient^ [1] + 0.01
                     else PFAmbient^ [1] := PFAmbient^ [1] - 0.01;
                     If PFAmbient^ [1] > 1.0 then
                                         begin
                                         PFAmbient^ [1] := 1.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     If PFAmbient^ [1] < 0.0 then
                                         begin
                                         PFAmbient^ [1] := 0.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     end;
                     InitializeRC;
                     end;
  { Up }  $68      : begin
                     If HiWord (GetKeyState (vk_NumLock)) = 1 { NumLock включен }
                     then
                     begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PFAmbient^ [3] := PFAmbient^ [3] + 0.01
                     else PFAmbient^ [3] := PFAmbient^ [3] - 0.01;
                     If PFAmbient^ [3] > 1.0 then
                                         begin
                                         PFAmbient^ [3] := 1.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     If PFAmbient^ [3] < 0.0 then
                                         begin
                                         PFAmbient^ [3] := 0.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     end;
                     InitializeRC;
                     end;
  { Right }$66     : begin
                     If HiWord (GetKeyState (vk_NumLock)) = 1 { NumLock включен }
                     then
                     begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PFAmbient^ [2] := PFAmbient^ [2] + 0.01
                     else PFAmbient^ [2] := PFAmbient^ [2] - 0.01;
                     If PFAmbient^ [2] > 1.0 then
                                         begin
                                         PFAmbient^ [2] := 1.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     If PFAmbient^ [2] < 0.0 then
                                         begin
                                         PFAmbient^ [2] := 0.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     end;
                     InitializeRC;
                     end;
  { Down }$62     : begin
                     If HiWord (GetKeyState (vk_NumLock)) = 1 { NumLock включен }
                     then
                     begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PFAmbient^ [4] := PFAmbient^ [4] + 0.01
                     else PFAmbient^ [4] := PFAmbient^ [4] - 0.01;
                     If PFAmbient^ [4] > 1.0 then
                                         begin
                                         PFAmbient^ [4] := 1.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     If PFAmbient^ [4] < 0.0 then
                                         begin
                                         PFAmbient^ [4] := 0.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     end;
                     InitializeRC;
                     end;
       end; // wm_KeyDown
       // обработка сообщений, св€занных с меню
       wm_LButtonDown :
       begin
       ShowCursor (True);
       TrackPopupMenu (MenuPopup, TPM_LEFTBUTTON,
                        10,10,0,Window, nil);
       end;
       wm_Command :
       begin
       case wParam of
                    id_param : CreateParWindow;
                    id_help : WinHelp(Window, 'ARM', HELP_CONTENTS, 0);
                    id_close : SendMessage (Window, wm_Destroy, wParam, lParam);
                    id_about : About;
       end; // case
       If flgCursor=False then ShowCursor (False)
                          else ShowCursor (True); // рисовать ли курсор
       end; // wm_command

  end; // case - сообщений

  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
  End;
