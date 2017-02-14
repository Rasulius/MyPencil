{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

program Select;

uses
  Messages,  Windows,  OpenGL;

const
  AppName = 'GLSelect';
  MaxSelect = 4;     // размер буфера выбора

Var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;
  dc : HDC;
  hrc : HGLRC;
  ps : TPaintStruct;
  mouseX, mouseY : Integer;                       // координаты курсора
  windW, windH : GLint;                           // размеры окна
  {--- для выбора элементов ---}
  vp : Array [0..3] of GLint;                     // хранит видовую матрицу
  SelectBuf : Array [0..MaxSelect - 1] of GLint;  // массив для буфера выбора
  hit : GLint;

{=======================================================================
Рисование объектов}
procedure Render (mode : GLenum); // параметр - режим (выбора/рисования)
begin
 // красный треугольник
 If mode = GL_SELECT then glLoadName (1); // именуем под именем 1
 glColor3f (1.0, 0.0, 0.0);
 glBegin(GL_POLYGON);
       glVertex2f(-1, -1);
       glVertex2f(-1, 1);
       glVertex2f(-0.1, 0);
 glEnd;

 // синий треугольник
 If mode = GL_SELECT then glLoadName (2); // именуем под именем 2
 glColor3f (0.0, 0.0, 1.0);
 glBegin(GL_POLYGON);
       glVertex2f(0.1, 0);
       glVertex2f(1, 1);
       glVertex2f(1, -1);
 glEnd;
end;

{=======================================================================
Выбор объекта в точке}
function DoSelect(x : GLint; y : GLint) : GLint;
var
 hits : GLint;
begin
 glRenderMode(GL_SELECT);               // включаем режим выбора
 // режим выбора нужен для работы следующих команд
 glInitNames;                           // инициализация стека имен
 glPushName(0);                         // помещение имени в стек имен

 glLoadIdentity;
 gluPickMatrix(x, windH - y, 2, 2, @vp);

 Render(GL_SELECT); // рисуем объекты с именованием объектов

 hits := glRenderMode(GL_SELECT);

 if hits <= 0
    then Result := -1
    else Result := SelectBuf [(hits - 1) * 4 + 3];
end;

{=======================================================================
Формат пикселя}
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPIXELFORMATDESCRIPTOR;
 nPixelFormat : Integer;
begin
 FillChar (pfd, SizeOf (pfd), 0);
 pfd.dwFlags  := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;

 nPixelFormat := ChoosePixelFormat (hdc, @pfd);
 SetPixelFormat (hdc, nPixelFormat, @pfd);
end;

function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; export; stdcall;
begin
  WindowProc := 0;
  case Message of
  WM_PAINT:    begin
               BeginPaint (Window, ps);

               glLoadIdentity;
               glClear(GL_COLOR_BUFFER_BIT);
               Render(GL_RENDER); // рисуем массив объектов без выбора

               SwapBuffers (dc);
               EndPaint (Window, ps);
               end;
  WM_LBUTTONDOWN: {--- реакция на щелчок мыши ---}
               begin
               mouseX := LoWord (lParam);
               mouseY := HiWord (lParam);
               hit := DoSelect(mouseX, mouseY);    // номер объекта под курсором
               case hit of
                 -1 : MessageBox (Window, 'Пустое место', 'Нажата кнопка', 0);
                  1 : MessageBox (Window, 'Красный треугольник', 'Нажата кнопка', 0);
                  2 : MessageBox (Window, 'Синий треугольник', 'Нажата кнопка', 0);
               end;
               end;
  WM_DESTROY : begin
               wglMakeCurrent (0, 0);
               wglDeleteContext (hrc);
               ReleaseDC (Window, dc);
               DeleteDC (dc);
               PostQuitMessage (0);
               Exit;
               end;
  WM_CREATE:   begin
               dc := GetDC (Window);
               SetDCPixelFormat (dc);
               hrc := wglCreateContext (dc);
               wglMakeCurrent (dc, hrc);
               glSelectBuffer(MaxSelect, @SelectBuf); // создание буфера выбора
               glClearColor (0.5, 0.5, 0.75, 1.0);    // цвет фона
               end;
  WM_SIZE:     begin
               windW := LOWORD (lParam);
               windH := HIWORD (lParam);
               glViewport(0, 0, windW, windH);
               glGetIntegerv(GL_VIEWPORT, @vp);
               end;
  end; // case

  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
end;

begin
   With WindowClass do begin
     Style := cs_HRedraw or cs_VRedraw;
     lpfnWndProc := @WindowProc;
     hCursor := LoadCursor (0, idc_Arrow);
     lpszClassName := AppName;
   end;
   RegisterClass (WindowClass);
   Window := CreateWindow (AppName, 'Выбор объекта',
   ws_OverlappedWindow or ws_ClipChildren or ws_Clipsiblings,
   cw_UseDefault, cw_UseDefault,  cw_UseDefault, cw_UseDefault,
   HWND_DESKTOP, 0, HInstance, nil);
   ShowWindow (Window, CmdShow);
   While GetMessage (Message, 0, 0, 0) do begin
     TranslateMessage (Message);
     DispatchMessage (Message);
   end;
end.

