{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

program WinMin;

uses
  Windows,
  Messages;

const
  AppName = 'WinMin';

Var
  Window : HWnd;
  hButton1, hLabel1 : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;

function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; stdcall;
begin
  WindowProc := 0;

  case Message of
       wm_Destroy : begin
                    PostQuitMessage (0);
                    Exit;
                    end;
       // реакция на нажатие кнопки
       wm_Command : if lParam = hButton1 then MessageBeep (mb_OK);
  end; // case

  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
end;

begin
  with WindowClass do begin
    Style := cs_HRedraw or cs_VRedraw;
    lpfnWndProc := @WindowProc;
    cbClsExtra := 0;
    cbWndExtra := 0;
    hInstance := 0;
    hIcon := LoadIcon (0, idi_Application);
    hCursor := LoadCursor (0, idc_Arrow);
    hbrBackground := COLOR_BTNFACE + 1;
    lpszMenuName := '';
    lpszClassName := AppName;
  end;

  If RegisterClass (WindowClass) = 0 then Halt (255);
  Window := CreateWindow (AppName, 'Win_Min', ws_OverlappedWindow,
     cw_UseDefault, cw_UseDefault, cw_UseDefault, cw_UseDefault,
     0, 0, HInstance, nil);

  // Создание окна кнопки
  hButton1 := CreateWindow ('Button', 'Button1',
    WS_VISIBLE or WS_CHILD or BS_PUSHLIKE or BS_TEXT,
    5, 5, 65, 24, Window, 0, hInstance, nil);

  // Создание окна метки
  hLabel1 := CreateWindow('Static', 'Label1', WS_VISIBLE or WS_CHILD or SS_LEFT,
    80, 10, 70, 20, Window, 0, hInstance, nil);

  ShowWindow (Window, CmdShow);
  UpdateWindow (Window);

  // Устанавливаем фокус на кнопке
  SetFocus(hButton1);

  while GetMessage (Message, 0, 0, 0) do begin
    TranslateMessage (Message);
    DispatchMessage (Message);
  end;
  Halt (Message.wParam);
end.
