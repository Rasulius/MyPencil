{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

program GLOutText;

uses
  Messages,  Windows,  OpenGL;

const
  AppName = 'GL_Text';
  GLF_START_LIST = 1000;

Var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;
  windW, windH : GLint;
  dc : HDC;
  hrc : HGLRC;
  ps : TPAINTSTRUCT;
  lf : TLOGFONT;
  hFontNew, hOldFont : HFONT;

{=======================================================================
Вывод текста}
procedure OutText (Litera : PChar);
begin
  glListBase(GLF_START_LIST);
  glCallLists(Length (Litera), GL_UNSIGNED_BYTE, Litera);
end;

{=======================================================================
Основная процедура рисования картинки}
procedure DrawScene;
begin
  glPushMatrix;

  // очистка буфера цвета и буфера глубины
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  // трехмерность
  glLoadIdentity;
  glTranslatef(-0.8, -0.7, -9.0);
  glRotatef(30.0, 1.0, 1.0, 0.0);
  glRotatef(30.0, 0.0, 1.0, 0.0); // поворот на угол
  // вывод текста
  OutText ('Проба');

  glPopMatrix;

  SwapBuffers (DC);
end;

procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPIXELFORMATDESCRIPTOR; // данные формата пикселей
 nPixelFormat : Integer;
Begin
 FillChar(pfd, SizeOf(pfd), 0);

  with pfd do begin
    nSize     := sizeof(pfd);
    nVersion  := 1;
    dwFlags   := PFD_DRAW_TO_WINDOW or
                 PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;
    iPixelType:= PFD_TYPE_RGBA;
    cColorBits:= 24;
    cDepthBits:= 32;
    iLayerType:= PFD_MAIN_PLANE;
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
               glDeleteLists (GLF_START_LIST, 256);
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

               glClearColor (0.3, 0.4, 0.6, 1.0);

               glEnable(GL_DEPTH_TEST);// разрешаем тест глубины
               glEnable(GL_LIGHTING);  // разрешаем работу с освещенностью
               glEnable(GL_LIGHT0);    // включаем источник света 0

               // подготовка вывода текста
               FillChar(lf, SizeOf(lf), 0);
               lf.lfHeight               :=   -28 ;
               lf.lfWeight               :=   FW_NORMAL ;
               lf.lfCharSet              :=   ANSI_CHARSET ;
               lf.lfOutPrecision         :=   OUT_DEFAULT_PRECIS ;
               lf.lfClipPrecision        :=   CLIP_DEFAULT_PRECIS ;
               lf.lfQuality              :=   DEFAULT_QUALITY ;
               lf.lfPitchAndFamily       :=   FF_DONTCARE OR DEFAULT_PITCH;
               lstrcpy (lf.lfFaceName, 'Arial Cyr') ;

               hFontNew := CreateFontIndirect(lf);
               hOldFont := SelectObject(DC,hFontNew);

               wglUseFontOutlines(DC, 0, 255, GLF_START_LIST, 0.0, 0.15,
                                      WGL_FONT_POLYGONS, nil);

               DeleteObject(SelectObject(DC,hOldFont));
               DeleteObject(SelectObject(DC,hFontNew));
               end;
  WM_SIZE:     begin
               windW := LOWORD (lParam);
               windH := HIWORD (lParam);
               glViewport(0, 0, windW, windH);
               glMatrixMode(GL_PROJECTION);
               glLoadIdentity;
               gluPerspective(15.0, windW / windH, 1.0, 20.0);
               glViewport(0, 0, windW, windH);
               glMatrixMode(GL_MODELVIEW);
               end;
  WM_PAINT:    begin
               BeginPaint (Window, ps);
               DrawScene;
               EndPaint (Window, ps);
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

