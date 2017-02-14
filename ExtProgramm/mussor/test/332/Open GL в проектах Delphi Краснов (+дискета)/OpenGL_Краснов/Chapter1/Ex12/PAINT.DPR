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
Var
    dc : HDC;               { ссылка на контекст, должна использоваться для работы с окном }
    MyPaint : TPaintStruct; { структура для работы функций отображения }
    Brush : hBrush;         { тип "кисть" }
    Pen : hPen;             { тип "карандаш" }
Begin
  WindowProc := 0;
  case Message of
       wm_Destroy : begin
                    PostQuitMessage (0);
                    Exit;
                    end;
       wm_Paint:    begin { сообщение посылается при необходимости перерисовки окна }
                    dc := BeginPaint (Window, MyPaint); { получить контекст устройства }
// Создать необходимые графические примитивы - получаем ссылки на обьекты
                    Brush := CreateSolidBrush (RGB (0, 255, 255)); { кисть }
                    Pen := CreatePen (PS_SOLID, 1, RGB (0, 0, 0)); { карандаш }
                    SelectObject (dc, Brush); { выбираем ссылку для текущего контекста }
                    SelectObject (dc, Pen);   { выбираем ссылку для текущего контекста }
                    Rectangle (dc, 10, 10, 110, 110); { рисуем прямоугольник }
                    Brush := CreateSolidBrush (RGB (255, 255, 0));
                    Pen := CreatePen (PS_SOLID, 1, RGB (255, 0, 0));
                    SelectObject (dc, Brush);
                    SelectObject (dc, Pen);
                    Ellipse (dc, 130, 10, 230, 110); { рисуем эллипс }
                    DeleteObject (Pen); { для нормального функционирования программы }
                    DeleteObject (Brush); { необходимо удалить все создаваемые объекты }
                    EndPaint (Window, MyPaint); { завершение операции по отображению в окне }
                    ReleaseDC (Window, dc); { освобождает контекст }
                    end;
  end; // case
  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
End;

procedure WinMain;
Begin
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
       Window := CreateWindow (AppName, 'Пример рисования в окне',
        ws_OverlappedWindow, 100, 100, 250, 150, 0, 0, HInstance, nil);
       ShowWindow (Window, CmdShow);
       UpdateWindow (Window);
       while GetMessage (Message, 0, 0, 0) do
        begin
         TranslateMessage (Message);
         DispatchMessage (Message);   
        end;
      Halt (Message.wParam);
End;

begin
  WinMain;
end.
