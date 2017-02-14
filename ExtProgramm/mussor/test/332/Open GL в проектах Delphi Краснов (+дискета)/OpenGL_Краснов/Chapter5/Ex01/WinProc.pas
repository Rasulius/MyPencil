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
      glDeleteLists (1, 11);
      wglMakeCurrent(0, 0);
      wglDeleteContext (hrc); // �������� ��������� ���������������
      // �������� ��������� �� ����������
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
      // ���� - ���������������
      SendMessage(Window, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
      dc := GetDC (Window);
      SetDCPixelFormat;
      hrc := wglCreateContext (dc); // �������� ��������� ���������������
      wglMakeCurrent(DC, hrc);

      Start; // ��������� ������ ������ �� �����

      If not flgCursor then ShowCursor (False); // �������� �� ������

      glColor3f (Colors [1], Colors [2], Colors [3]);
      InitializeRC;   // ������������� ��������� �����
      Angle := 0;     // ����, ������������ �� ��������

      ObjCylinder := gluNewQuadric; // ������ - �������
      ObjSphere := gluNewQuadric;   // ������ - �����
      For i := 0 to 5 do begin      // ��������������� ������
        MyX [i] := 0.8 * sin ( Pi / 3 * i );
        MyY [i] := 0.8 * cos ( Pi / 3 * i );
        wrkArray [i] := 60.0 * i;
      end;
      For i := 1 to 20 do begin
        wrkArraySin [i] := 0.125 * sin (Pi / 10 * i);
        wrkArrayCos [i] := 0.125 * cos (Pi / 10 * i);
      end;

      If Perspective < PerspNear then begin
         Styles [1] := GLU_FILL; // ������ ������
         Styles [2] := GLU_FILL;
         gluQuadricDrawStyle(ObjSphere, Styles [1]);   // ����� ������������
         gluQuadricDrawStyle(ObjCylinder, Styles [1]); // ����� ������������
         end
         else begin
         Styles [1] := GLU_LINE; // ������ ������
         Styles [2] := GLU_LINE;
         gluQuadricDrawStyle(ObjSphere, Styles [1]); // ����� ������������
         gluQuadricDrawStyle(ObjCylinder, Styles [1]); // ����� ������������
      end;
      flgRotation := True;    // ����, ������� �� ����
      wrkI := 0;              // ������� �������� ������
      MakeTexImage;           // ��������� ����� ��������
      hStopki := 1;           // ������ ������ ���������

      Lists;                  // ��������� �������� �������
      uTimerID := timeSetEvent (5, 0, @FNTimeCallBack, 100, TIME_PERIODIC);
      end; // wm_Create
  wm_Size:  // ��� ��������� �������� ���� ����������� ������� ������� ����
      begin
      glnWidth := LoWord (lParam);         // ������ ����
      glnHeight := HiWord (lParam);        // ������ ����
      glMatrixMode(GL_PROJECTION);
      glLoadIdentity;
      gluPerspective(Perspective, glnWidth / glnHeight, 1.0, 10.0);
      glViewport(0, 0, glnWidth, glnHeight);
      glMatrixMode(GL_MODELVIEW);
      glLoadIdentity;
      glTranslatef(0.0 , 0.0, -7.0);       // ������������ �����
      InvalidateRect(Window, nil, False);
      end;
  wm_Help : // ������ ������� F1
      begin
      ShowCursor (True);
      WinHelp(Window, 'ARM', HELP_CONTENTS, 0);
      If not flgCursor then ShowCursor (False); // �������� �� ������
      end;
  wm_Paint: {$I DrawScene} // ��� ���������� ���������� ����������
  wm_Char:  // ������ ������� ������
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
  { O, o } $4F,$6F : flgOc := not (flgOc);
  { P, p}  $50,$70 : flgSquare := not (flgSquare);
  { Space } $20    : If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then begin
                     Perspective := Perspective - 0.2;
                     If Perspective < PerspNear then begin
                     Styles [1] := GLU_FILL;
                     Styles [2] := GLU_FILL;
                     end;
                     glMatrixMode(GL_PROJECTION);
                     glLoadIdentity;
                     gluPerspective(Perspective, glnWidth / glnHeight, 1.0, 10.0);
                     glViewport(0, 0, glnWidth, glnHeight);
                     glMatrixMode(GL_MODELVIEW);
                     glLoadIdentity;
                     glTranslatef(0.0 , 0.0, -7.0);       // ������������ �����
                     InvalidateRect(Window, nil, False);
                     end
                     else begin
                     Perspective := Perspective + 0.2;
                     If Perspective > PerspNear then begin
                     Styles [1] := GLU_LINE;
                     Styles [2] := GLU_LINE;
                     end;
                     glMatrixMode(GL_PROJECTION);
                     glLoadIdentity;
                     gluPerspective(Perspective, glnWidth / glnHeight, 1.0, 10.0);
                     glViewport(0, 0, glnWidth, glnHeight);
                     glMatrixMode(GL_MODELVIEW);
                     glLoadIdentity;
                     glTranslatef(0.0 , 0.0, -7.0);       // ������������ �����
                     InvalidateRect(Window, nil, False);
                     end;
  { M, m } $4D, $6D : IncMaterials; // ��������� ��������� ���������� ���������
  { R, r } $52,$72 : begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then Colors [1] := Colors [1] + 0.05
                     else Colors [1] := Colors [1] - 0.05;
                     If Colors [1] > 1.0 then begin
                                         Colors [1] := 1.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     If Colors [1] < 0.0 then begin
                                         Colors [1] := 0.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     glColor3f (Colors [1], Colors [2], Colors [3]);
                     end;
  { G, g } $47,$67 : begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then Colors [2] := Colors [2] + 0.05
                     else Colors [2] := Colors [2] - 0.05;
                     If Colors [2] > 1.0 then begin
                                         Colors [2] := 1.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     If Colors [2] < 0.0 then begin
                                         Colors [2] := 0.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     glColor3f (Colors [1], Colors [2], Colors [3]);
                     end;
  { B, b } $42,$62 : begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then Colors [3] := Colors [3] + 0.05
                     else Colors [3] := Colors [3] - 0.05;
                     If Colors [3] > 1.0 then begin
                                         Colors [3] := 1.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     If Colors [3] < 0.0 then begin
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

                     // ��������� ��������� �����
                     PLPosition^ [1] := 0.5;
                     PLPosition^ [2] := 0.5;
                     PLPosition^ [3] := 0.5;
                     PLPosition^ [4] := 0.0;

                     // ����������� �����
                     PRPosition^ [1] := 0.0;
                     PRPosition^ [2] := 0.0;
                     PRPosition^ [3] := -1.0;

                     // ������������� �����
                     PFAmbient^ [1] := 0.2;
                     PFAmbient^ [2] := 0.2;
                     PFAmbient^ [3] := 0.2;
                     PFAmbient^ [4] := 1.0;

                     InitializeRC;
                     end;
   { L, l }$4C, $6C: flgLight := not (flgLight);
   { S, s }$53, $73: SavePar; // ������ ���������� � ����
   { C, c }$43, $63: begin
                     flgCursor := not flgCursor;
                     If flgCursor=False then ShowCursor (False)
                                        else ShowCursor (True); // �������� �� ������
                     end;
      end; // wm_Char
   wm_KeyDown:  // ������ ������� ������
      case wParam of
  // ������� ���������� �������� - ��������� ��������� �����
  // � Ctrl - ����������� �����
  { Left }$25      : begin
                     If HiWord (GetKeyState (vk_CONTROL)) = 0  { Ctrl �� �����}
                     then begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PLPosition^ [1] := PLPosition^ [1] + 0.01
                     else PLPosition^ [1] := PLPosition^ [1] - 0.01;
                     end
                     else begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PRPosition^ [1] := PRPosition^ [1] + 0.025
                     else PRPosition^ [1] := PRPosition^ [1] - 0.025;
                     end;
                     InitializeRC;
                     end;
  { Up }  $26      : begin
                     If HiWord (GetKeyState (vk_CONTROL)) = 0  { Ctrl �� �����}
                     then begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PLPosition^ [3] := PLPosition^ [3] + 0.01
                     else PLPosition^ [3] := PLPosition^ [3] - 0.01;
                     end
                     else begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PRPosition^ [3] := PRPosition^ [3] + 0.025
                     else PRPosition^ [3] := PRPosition^ [3] - 0.025;
                     end;
                     InitializeRC;
                     end;
  { Right }$27     : begin
                     If HiWord (GetKeyState (vk_CONTROL)) = 0  { Ctrl �� �����}
                     then begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PLPosition^ [2] := PLPosition^ [2] + 0.01
                     else PLPosition^ [2] := PLPosition^ [2] - 0.01;
                     end
                     else begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PRPosition^ [2] := PRPosition^ [2] + 0.025
                     else PRPosition^ [2] := PRPosition^ [2] - 0.025;
                     end;
                     InitializeRC;
                     end;
  { Down } $28     : begin
                     If HiWord (GetKeyState (vk_CONTROL)) = 0  { Ctrl �� �����}
                     then begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PLPosition^ [4] := PLPosition^ [4] + 0.01
                     else PLPosition^ [4] := PLPosition^ [4] - 0.01;
                     end;
                     InitializeRC;
                     end;
  // ������� ���������� �������� �� �������� ����������
  // - ������������� ����� ��� ���������� NumLock
  { Left }$64      : begin
                     If HiWord (GetKeyState (vk_NumLock)) = 1 { NumLock ������� }
                     then begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PFAmbient^ [1] := PFAmbient^ [1] + 0.01
                     else PFAmbient^ [1] := PFAmbient^ [1] - 0.01;
                     If PFAmbient^ [1] > 1.0 then begin
                                         PFAmbient^ [1] := 1.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     If PFAmbient^ [1] < 0.0 then begin
                                         PFAmbient^ [1] := 0.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     end;
                     InitializeRC;
                     end;
  { Up }  $68      : begin
                     If HiWord (GetKeyState (vk_NumLock)) = 1 { NumLock ������� }
                     then begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PFAmbient^ [3] := PFAmbient^ [3] + 0.01
                     else PFAmbient^ [3] := PFAmbient^ [3] - 0.01;
                     If PFAmbient^ [3] > 1.0 then begin
                                         PFAmbient^ [3] := 1.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     If PFAmbient^ [3] < 0.0 then begin
                                         PFAmbient^ [3] := 0.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     end;
                     InitializeRC;
                     end;
  { Right }$66     : begin
                     If HiWord (GetKeyState (vk_NumLock)) = 1 { NumLock ������� }
                     then begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PFAmbient^ [2] := PFAmbient^ [2] + 0.01
                     else PFAmbient^ [2] := PFAmbient^ [2] - 0.01;
                     If PFAmbient^ [2] > 1.0 then begin
                                         PFAmbient^ [2] := 1.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     If PFAmbient^ [2] < 0.0 then begin
                                         PFAmbient^ [2] := 0.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     end;
                     InitializeRC;
                     end;
  { Down }$62     : begin
                     If HiWord (GetKeyState (vk_NumLock)) = 1 { NumLock ������� }
                     then begin
                     If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                     then PFAmbient^ [4] := PFAmbient^ [4] + 0.01
                     else PFAmbient^ [4] := PFAmbient^ [4] - 0.01;
                     If PFAmbient^ [4] > 1.0 then begin
                                         PFAmbient^ [4] := 1.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     If PFAmbient^ [4] < 0.0 then begin
                                         PFAmbient^ [4] := 0.0;
                                         MessageBeep (MB_ICONQUESTION);
                                         end;
                     end;
                     InitializeRC;
                     end;
       end; // wm_KeyDown
       // ��������� ���������, ��������� � ����
       wm_LButtonDown :
       begin
       ShowCursor (True);
       TrackPopupMenu (MenuPopup, TPM_LEFTBUTTON,10,10,0,Window, nil);
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
                          else ShowCursor (True); // �������� �� ������
       end; // wm_command

  end; // case - ���������

  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
End;
