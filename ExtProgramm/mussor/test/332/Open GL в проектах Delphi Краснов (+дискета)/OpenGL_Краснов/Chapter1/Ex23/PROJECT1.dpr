{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

program Project1;

uses
  Messages, Windows, OpenGL;

const
  AppName = 'WinError';

var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;
  dc : HDC;
  hrc : HGLRC;
  ps : TPAINTSTRUCT;
  lpMsgBuf: PChar;

// Процедура заполнения полей структуры PIXELFORMATDESCRIPTOR
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPIXELFORMATDESCRIPTOR; // данные формата пикселей
 nPixelFormat : Integer;
Begin
 With pfd do begin
  nSize := sizeof (TPIXELFORMATDESCRIPTOR); // размер структуры
  nVersion := 1;                            // номер версии
  dwFlags := PFD_DRAW_TO_WINDOW OR PFD_SUPPORT_OPENGL; // множество битовых флагов, определяющих устройство и интерфейс
  iPixelType := PFD_TYPE_RGBA; // режим для изображения цветов
  cColorBits := 16;            // число битовых плоскостей в каждом буфере цвета
  cRedBits := 0;               // число битовых плоскостей красного в каждом буфере RGBA
  cRedShift := 0;              // смещение от начала числа битовых плоскостей красного в каждом буфере RGBA
  cGreenBits := 0;             // число битовых плоскостей зелёного в каждом буфере RGBA
  cGreenShift := 0;            // смещение от начала числа битовых плоскостей зелёного в каждом буфере RGBA
  cBlueBits := 0;              // число битовых плоскостей синего в каждом буфере RGBA
  cBlueShift := 0;             // смещение от начала числа битовых плоскостей синего в каждом буфере RGBA
  cAlphaBits := 0;             // число битовых плоскостей альфа в каждом буфере RGBA
  cAlphaShift := 0;            // смещение от начала числа битовых плоскостей альфа в каждом буфере RGBA
  cAccumBits := 0;             // общее число битовых плоскостей в буфере аккумулятора
  cAccumRedBits := 0;          // число битовых плоскостей красного в буфере аккумулятора
  cAccumGreenBits := 0;        // число битовых плоскостей зелёного в буфере аккумулятора
  cAccumBlueBits := 0;         // число битовых плоскостей синего в буфере аккумулятора
  cAccumAlphaBits := 0;        // число битовых плоскостей альфа в буфере аккумулятора
  cDepthBits := 32;            // размер буфера глубины (ось z)
  cStencilBits := 0;           // размер буфера трафарета
  cAuxBuffers := 0;            // число вспомогательных буферов
  iLayerType := PFD_MAIN_PLANE;// тип плоскости
  bReserved := 0;              // число плоскостей переднего и заднего плана
  dwLayerMask := 0;            // игнорируется
  dwVisibleMask := 0;          // индекс или цвет прозрачности нижней плоскости
  dwDamageMask := 0;           // игнорируется
  end;

  nPixelFormat := ChoosePixelFormat (hdc, @pfd); // запрос системе - поддерживается ли выбранный формат пикселей

  SetPixelFormat (hdc, nPixelFormat, @pfd);      // устанавливаем формат пикселей в контексте устройства
End;

function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; export; stdcall;
Begin
  WindowProc := 0;
  case Message of
  wm_Destroy :
      begin
      wglDeleteContext (hrc); // удаление контекста воспроизведения
      ReleaseDC (Window, dc);
      DeleteDC (dc);
      PostQuitMessage (0);
      Exit;
      end;
  wm_Create:
      begin
//      dc := GetDC (Window);
      SetDCPixelFormat (dc);
      hrc := wglCreateContext (dc);

      FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM,
                    nil, GetLastError(), LANG_NEUTRAL, @lpMsgBuf, 0, nil);

      MessageBox(Window, lpMsgBuf, 'GetLastError', MB_OK);

      end;
  wm_Paint:
      begin
      BeginPaint (Window, ps);
      wglMakeCurrent (dc, hrc);    // установить текущий контекст воспроизведения

      glClearColor (0.5, 0.1, 0.2, 1.0);
      glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); // очищаются буфер цвета и буфер глубины

      wglMakeCurrent (0,0);
      EndPaint (Window, ps);
      end;

  end; // case

  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
  End;

procedure WinMain;
Begin
  With WindowClass do
      begin
      Style := CS_HRedraw OR cs_VRedraw;
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
      ws_OverLappedWindow OR ws_ClipChildren OR ws_ClipSiBlings, // обязательно для OpenGL
      cw_UseDefault, cw_UseDefault,
      cw_UseDefault, cw_UseDefault,
      HWND_DESKTOP, 0, HInstance, nil);
      ShowWindow (Window, CmdShow);
      UpdateWindow (Window);
  While GetMessage (Message, 0, 0, 0) do
      begin
      TranslateMessage (Message);
      DispatchMessage (Message);
      end;
  Halt (Message.wParam);
end;

begin
  WinMain;
end.

