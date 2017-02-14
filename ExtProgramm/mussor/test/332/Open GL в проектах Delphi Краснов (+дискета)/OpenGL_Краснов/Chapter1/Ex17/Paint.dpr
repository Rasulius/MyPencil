{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

program Paint;

uses
   Windows, Messages;

const
  AppName = 'WinPaint';
  id_Timer = 100; // идентификатор таймера

Var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;

function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; stdcall;
Var
    dc : HDC;
    MyPaint : TPaintStruct;
    Brush : hBrush;
Begin
  WindowProc := 0;
  case Message of
   wm_Create  : dc := GetDC(Window);
   wm_Destroy : begin
                KillTimer (Window, id_Timer);
                DeleteDC (dc);
                PostQuitMessage (0);
                Exit;
                end;
   wm_Timer:    InvalidateRect(Window, nil, False);
   wm_Paint:    begin
                dc := BeginPaint (Window, MyPaint);
                Brush := CreateSolidBrush (RGB (random (255), random (255), random (255)));
                SelectObject (dc, Brush); 
                Ellipse (dc, 10, 10, 110, 110);
                DeleteObject (Brush);
                EndPaint (Window, MyPaint);
                ReleaseDC (Window, dc);
                end;
  end; // case
  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
End;


begin
      With WindowClass do
        begin
        Style := cs_DblClks;
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
       If RegisterClass (WindowClass) = 0 then
          Halt (255);
       Window := CreateWindow (AppName, 'Таймер',
        ws_OverlappedWindow, 100, 100, 150, 150, 0, 0, HInstance, nil);
       ShowWindow (Window, CmdShow);
       UpdateWindow (Window);
       SetTimer (Window, id_Timer, 200, nil); // Установка таймера
       Randomize;
       while GetMessage (Message, 0, 0, 0) do begin
         TranslateMessage (Message);
         DispatchMessage (Message);
        end;
      Halt (Message.wParam);
end.
