{**********************************************************************}
{* »ллюстраци€ к книге "OpenGL в проектах Delphi"                     *}
{*  раснов ћ.¬. softgl@chat.ru                                        *}
{**********************************************************************}

program EarthGL;

uses
  Messages, Windows, OpenGL, mmSystem;

const
  AppName = 'OpenGL_Min';

Var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;
  DC : HDC;
  hrc : HGLRC;
  MyPaint : TPaintStruct;
  uTimerId : uint;
  Angle : GLint = 0;

const
  Sphere = 1;

function ReadBitmap(const FileName : String;
                    var sWidth, tHeight: GLsizei): pointer;
const
  szh = SizeOf(TBitmapFileHeader);
  szi = SizeOf(TBitmapInfoHeader);
type
  TRGB = record
    r, g, b : GLbyte;
  end;
  TWrap = Array [0..0] of TRGB;
var
  BmpFile : File;
  bfh : TBitmapFileHeader;
  bmi : TBitmapInfoHeader;
  x, size: GLint;
  temp: GLbyte;
begin
  AssignFile (BmpFile, FileName);
  Reset (BmpFile, 1);
  Size := FileSize (BmpFile) - szh - szi;
  Blockread(BmpFile, bfh, szh);
  BlockRead (BmpFile, bmi, szi);
  If Bfh.bfType <> $4D42 then begin
    MessageBox(Window, 'Invalid Bitmap', 'Error', MB_OK);
    Result := nil;
    Exit;
  end;
  sWidth := bmi.biWidth;
  tHeight := bmi.biHeight;
  GetMem (Result, Size);
  BlockRead(BmpFile, Result^, Size);
  For x := 0 to sWidth*tHeight-1 do
    With TWrap(result^)[x] do begin
      temp := r;
      r := b;
      b := temp;
  end;
end;

{=======================================================================
»нициализаци€}
procedure Init;
const
 LightPos : Array [0..3] of GLfloat = (10.0, 10.0, 10.0, 1.0);
var
 Quadric : GLUquadricObj;
 wrkPointer : Pointer;
 sWidth, tHeight : GLsizei;
begin
 glEnable(GL_LIGHTING);
 glEnable(GL_LIGHT0);
 glLightfv(GL_LIGHT0, GL_POSITION, @LightPos);

 Quadric := gluNewQuadric;
 gluQuadricTexture (Quadric, TRUE);

 glNewList (Sphere, GL_COMPILE);
   gluSphere (Quadric, 1.0, 24, 12);
 glEndList;

 gluDeleteQuadric (Quadric);

 wrkPointer := ReadBitmap('..\earth.bmp', sWidth, tHeight);

 glTexImage2D(GL_TEXTURE_2D, 0, 3, sWidth, tHeight, 0,
              GL_RGB, GL_UNSIGNED_BYTE, wrkPointer);

 Freemem(wrkPointer);

 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
 glEnable(GL_TEXTURE_2D);

 glEnable(GL_DEPTH_TEST);
end;

{======================================================================
“ик таймера}
procedure FNTimeCallBack (uTimerID, uMessage: UINT; dwUser, dw1, dw2: DWORD) stdcall;
begin
  Angle := (Angle + 1) mod 360;
  InvalidateRect(Window, nil, False);
end;

// ѕроцедура заполнени€ полей структуры PIXELFORMATDESCRIPTOR
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPixelFormatDescriptor; // данные формата пикселей
 nPixelFormat : Integer;
Begin
 FillChar(pfd, SizeOf(pfd), 0);

 pfd.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;
 nPixelFormat := ChoosePixelFormat (hdc, @pfd); // запрос системе - поддерживаетс€ ли выбранный формат пикселей
 SetPixelFormat (hdc, nPixelFormat, @pfd);      // устанавливаем формат пикселей в контексте устройства
End;

function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; stdcall;
Begin
  WindowProc := 0;
  case Message of
  wm_Create:
       begin
       DC := GetDC (Window);
       SetDCPixelFormat (DC);        // установить формат пикселей
       hrc := wglCreateContext (DC); // создаЄт контекст воспроизведени€ OpenGL
       wglMakeCurrent (DC, hrc);     // устанавливает текущий контекст воспроизведени€
       Init;
       uTimerID := timeSetEvent(15, 0, @FNTimeCallBack, 0, TIME_PERIODIC);
       end;
  wm_Paint:
       begin
       DC := BeginPaint (Window, MyPaint);

       glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT );
       glPushMatrix;
         glRotatef (Angle, 0.0, 0.0, 1.0);
         glCallList(1);
       glPopMatrix;

       SwapBuffers(DC);
       EndPaint (Window, MyPaint);
       end;
  wm_Destroy :
       begin
       timeKillEvent (uTimerID);
       glDeleteLists (Sphere, 1);
       wglMakeCurrent (0, 0);
       wglDeleteContext (hrc);
       ReleaseDC (Window, DC);
       DeleteDC (DC);
       PostQuitMessage (0);
       Exit;
       end;
   wm_Size : begin
       glViewport(0, 0, LoWord (lParam), HiWord (lParam));
       glMatrixMode( GL_PROJECTION );
       glLoadIdentity;
       glFrustum( -1.0, 1.0, -1.0, 1.0, 5.0, 15.0 );
       glMatrixMode( GL_MODELVIEW );
       glLoadIdentity;
       glTranslatef( 0.0, 0.0, -12.0 );
       glRotatef(-90.0, 1.0, 0.0, 0.0);
       end;
   wm_Char:  // анализ нажатой клавиши
       If wParam = VK_ESCAPE then PostMessage (Window, WM_CLOSE, 0, 0);
  end; // case
  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
End;

Begin
  With WindowClass do
       begin
       Style := cs_HRedraw or cs_VRedraw;
       lpfnWndProc := @WindowProc;
       cbClsExtra := 0;
       cbWndExtra := 0;
       hInstance := 0;
       hCursor := LoadCursor (0, idc_Arrow);
       lpszClassName := AppName;
       end;
  RegisterClass (WindowClass);
  Window := CreateWindow (AppName, 'Earth',
       ws_OverLappedWindow or ws_ClipChildren
          or ws_ClipSiBlings, // об€зательно дл€ OpenGL
       cw_UseDefault, cw_UseDefault,
       400, 400,
       HWND_DESKTOP, 0, HInstance, nil);
       ShowWindow (Window, CmdShow);
       UpdateWindow (Window);
  While GetMessage (Message, 0, 0, 0) do begin
       TranslateMessage (Message);
       DispatchMessage (Message);
  end;
  Halt (Message.wParam);
end.
