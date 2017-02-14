procedure WinMain;
Begin
  // создание всплывающего меню
  MenuPopup := CreatePopupMenu;
  If MenuPopup <> 0 then begin
     AppendMenu (MenuPopup, MF_Enabled, id_help,  '&Помощь');
     AppendMenu (MenuPopup, MF_Enabled, id_param, 'П&араметры');
     AppendMenu (MenuPopup, MF_Enabled, id_about, '&Об авторах');
     AppendMenu (MenuPopup, MF_Enabled, id_close, '&Выход');
  end;

  With WindowClass do begin
      Style := cs_HRedraw or cs_VRedraw;
      lpfnWndProc := @WindowProc;
      cbClsExtra := 0;
      cbWndExtra := 0;
      hInstance := 0;
      hIcon := LoadIcon (0, idi_Application);
      hCursor := LoadCursor (0, idc_Arrow);
      hbrBackground := GetStockObject (White_Brush);
      lpszMenuName := '';
      lpszClassName := AppName;
  end;
  If RegisterClass (WindowClass) = 0 then Halt (255);
  Window := CreateWindow (AppName, AppName,
      // окно без рамки и без границ, поверх остальных
      ws_Visible or ws_PopUp or ws_EX_TOPMOST,
      20, 10, 600, 400, HWND_DESKTOP, 0, HInstance, nil);
  ShowWindow (Window, CmdShow);
  UpdateWindow (Window);
  While GetMessage (Message, 0, 0, 0) do begin
      TranslateMessage (Message);
      DispatchMessage (Message);
  end;
  Halt (Message.wParam);
end;
