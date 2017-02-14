{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

program FeedBack;

uses
  Messages,  Windows,  OpenGL;

const
  AppName = 'glFeedBack';
  MAXOBJS = 20;                       // максимальное число объектов

{--- запись для хранения объектов ---}
type
  TGLObject = record                  // объект - треугольник
     {вершины треугольника}
     v1 : Array [0..1] of GLFloat;
     v2 : Array [0..1] of GLFloat;
     v3 : Array [0..1] of GLFloat;
     color : Array [0..2] of GLFloat; // цвет объекта
  end;

Var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;
  windW, windH : GLint;
  dc : HDC;
  hrc : HGLRC;
  ps : TPAINTSTRUCT;
  objects : Array [0..MAXOBJS - 1] of TGLObject;  // массив объектов
  vp : Array [0..3] of GLint;
  mouseX, mouseY : Integer;
  FBBuf : Array [0..100] of GLFloat;
  n : Integer;

{=======================================================================
Инициализация объектов}
procedure InitObjects;
var
  i : GLint ;
  x, y : GLfloat ;
begin
  For i := 0 to MAXOBJS - 1 do begin
    x := random(300) - 150;
    y := random(300) - 150;
    // вершины треугольника - случайно
    objects[i].v1[0] := x + random(50) - 25;
    objects[i].v2[0] := x + random(50) - 25;
    objects[i].v3[0] := x + random(50) - 25;
    objects[i].v1[1] := y + random(50) - 25;
    objects[i].v2[1] := y + random(50) - 25;
    objects[i].v3[1] := y + random(50) - 25;
    // цвета выбираются случайными
    objects[i].color[0] := (random(100) + 50) / 150.0;
    objects[i].color[1] := (random(100) + 50) / 150.0;
    objects[i].color[2] := (random(100) + 50) / 150.0;
  end;
end;

{=======================================================================
Рисование массива объектов}
procedure Render (mode : GLenum); // параметр - режим (выбора/рисования)
var
  i : GLuint;
begin
  For i := 0 to MAXOBJS - 1 do begin
    If mode = GL_FEEDBACK then glPassThrough (i); // загрузка очередного имени
    glColor3fv(@objects[i].color);          // цвет для очередного объекта
    glBegin(GL_POLYGON);                    // рисуем треугольник
        glVertex2fv(@objects[i].v1);
        glVertex2fv(@objects[i].v2);
        glVertex2fv(@objects[i].v3);
    glEnd;
  end;
end;

{=======================================================================
Изменение цвета объекта номер h}
procedure RecolorTri (h : GLint);
begin
  objects[h].color[0] := (random(100) + 50) / 150.0;
  objects[h].color[1] := (random(100) + 50) / 150.0;
  objects[h].color[2] := (random(100) + 50) / 150.0;
end;

{=======================================================================
Выбор объекта в точке}
procedure DoSelect(x : GLint; y : GLint);
var
  i, k : GLint;
  token : GLFloat;
  vcount, w, nx, ny : Integer;
begin
  i := n;
  While i <> 0 do begin
    token := FBBuf[n-i];
    DEC(i);
    If token = GL_PASS_THROUGH_TOKEN then begin
      w := round(FBBUF [n-i]);
      DEC(i);
    end
    else If token = GL_POLYGON_TOKEN then begin
      vcount := Round(FBBUF[n-i]);
      DEC(i);
      For k := 1 to vcount do begin
        nx := round (FBBUF[n-i]);
        DEC(i);
        ny := windH - round (FBBUF[n-i]);
        DEC(i);
        If (nx + 30 > x) and (nx - 30 < x) and
           (ny + 30 > y) and (ny - 30 < y) then
           RecolorTri (w);
        end;
      end;
    end;
end;


{=======================================================================
Основная процедура рисования картинки}
procedure DrawScene;
begin
  glPushMatrix;

  glGetIntegerv(GL_VIEWPORT, @vp);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluOrtho2D(-175, 175, -175, 175);
  glMatrixMode(GL_MODELVIEW);

  glClear(GL_COLOR_BUFFER_BIT);

  Render(GL_RENDER); // рисуем массив объектов без выбора

  glRenderMode(GL_FEEDBACK);
  Render (GL_FEEDBACK);
  n := glRenderMode(GL_RENDER);

  glPopMatrix;

  glFlush;
end;

procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPIXELFORMATDESCRIPTOR; // данные формата пикселей
 nPixelFormat : Integer;
Begin
 With pfd do
  begin
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
  dwLayerMask := 0;            //
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
  wm_Destroy : begin
               wglMakeCurrent (0, 0);
               wglDeleteContext (hrc);
               ReleaseDC (Window, DC);
               DeleteDC (DC);
               PostQuitMessage (0);
               Exit;
               end;
  WM_CREATE:   begin
               Randomize;
               dc := GetDC (Window);
               SetDCPixelFormat (dc);
               hrc := wglCreateContext (dc);
               wglMakeCurrent (dc, hrc);
               InitObjects;
               glFeedbackBuffer(SizeOf (FBBuf), GL_2D, @FBBuf);
               end;
  WM_SIZE:     begin
               windW := LOWORD (lParam);
               windH := HIWORD (lParam);
               glViewport(0, 0, windW, windH);
               end;
  WM_PAINT:    begin
               BeginPaint (Window, ps);
               DrawScene;
               EndPaint (Window, ps);
               end;
  WM_LBUTTONDOWN: {--- реакция на щелчок мыши ---}
               begin
               mouseX := LoWord (lParam);
               mouseY := HiWord (lParam);
               DoSelect(mouseX, mouseY);
               InvalidateRect(Window, nil, False); // обновляем картинку
               end;
  end; // case

  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
End;

Begin
   With WindowClass do begin
     Style := cs_HRedraw or cs_VRedraw;
     lpfnWndProc := @WindowProc;
     hCursor := LoadCursor (0, idc_Arrow);
     lpszClassName := AppName;
   end;
   RegisterClass (WindowClass);
   Window := CreateWindow (AppName, AppName,
   ws_OverlappedWindow or ws_ClipChildren or ws_Clipsiblings,
   cw_UseDefault, cw_UseDefault,  cw_UseDefault, cw_UseDefault,
   HWND_DESKTOP, 0, HInstance, nil);
   ShowWindow (Window, CmdShow);
   While GetMessage (Message, 0, 0, 0) do begin
     TranslateMessage (Message);
     DispatchMessage (Message);
   end;
End.

