{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

program Paint;

{****************** ИСПОЛЬЗОВАНИЕ КОНТЕКСТА УСТРОЙСТВА  *****************}
{* Функции GDI (интерфейс графического устройства) взаимодействуют с    *}
{* драйвером устройства через специальную структуру данных, называемую  *}
{* "контекст устройства".                                               *}
{* Структура "контекст устройства" содержит основные характеристики ус- *}
{* тройства, а также различные средства отображения - кисти, карандаши, *}
{* цвета и т.п. Прежде чем вызывать различные функции для отображения   *}
{* информации, прикладная программа должна получить контекст устройства *}
{* вывода.                                                              *}
{* После того, как программа отработала с контекстом, она должна его    *}
{* освободить.                                                          *}
{************************************************************************}

uses
   Windows, Messages;

const
  AppName = 'WinPaint';

Var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;

function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; stdcall;
Const
  Points : Array [0..3] of TPoint =
     ((x:5; y:5), (x:20; y:70), (x:80; y:15), (x:100; y:90));
Var
  dc : HDC;
  MyPaint : TPaintStruct;
  i : Integer;
Begin
  WindowProc := 0;
  case Message of
       wm_Destroy : begin
                    PostQuitMessage (0);
                    Exit;
                    end;
       wm_Paint:    begin { сообщение посылается при необходимости перерисовки окна }
                    dc := BeginPaint (Window, MyPaint); { получить контекст устройства }
                    PolyBezier (dc, Points, 4);
                    For i := 0 to 3 do
                    Ellipse (dc, Points [i].x - 3, Points [i].y - 3,
                             Points [i].x + 3, Points [i].y + 3);
                    EndPaint (Window, MyPaint); { завершение операции по отображению в окне }
                    ReleaseDC (Window, dc); { освобождает контекст }
                    end;
  end; // case
  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
End;

Begin
  With WindowClass do begin
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
  If RegisterClass (WindowClass) = 0 then Halt (255);
  Window := CreateWindow (AppName, 'Кривая Безье',
   ws_OverlappedWindow, 100, 100, 250, 150, 0, 0, HInstance, nil);
  ShowWindow (Window, CmdShow);
  UpdateWindow (Window);
  While GetMessage (Message, 0, 0, 0) do begin
    TranslateMessage (Message);
    DispatchMessage (Message);
   end;
  Halt (Message.wParam);
End.
