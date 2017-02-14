{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);

  private
    DC : HDC;
    hrc: HGLRC;
    Palette : HPalette;
    procedure SetDCPixelFormat (DC : HDC);
  protected
    procedure WMQueryNewPalette(var Msg: TWMQueryNewPalette); message WM_QUERYNEWPALETTE;
    procedure WMPaletteChanged(var Msg: TWMPaletteChanged); message WM_PALETTECHANGED;
  end;

var
  frmGL: TfrmGL;

implementation

uses DGLUT;

{$R *.DFM}

{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 glutSolidTeapot (1.0);

 SwapBuffers(DC);

 glRotatef (1, 1.0, 1.0, 1.0);
 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Создание формы}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
 DC := GetDC (Handle);
 SetDCPixelFormat(DC);
 hrc := wglCreateContext(DC);
 wglMakeCurrent(DC, hrc);
 glClearColor (0.5, 0.5, 0.75, 1.0);
 glColor3f (1.0, 0.0, 0.5);

 glEnable (GL_DEPTH_TEST);
 glEnable (GL_COLOR_MATERIAL);
 glEnable (GL_LIGHTING);
 glEnable (GL_LIGHT0);
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC (Handle, DC);
 DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 glFrustum (-1, 1, -1, 1, 5, 10);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;

 glTranslatef(0.0, 0.0, -8.0);   // перенос объекта - ось Z
 glRotatef(30.0, 1.0, 0.0, 0.0); // поворот объекта - ось X
 glRotatef(70.0, 0.0, 1.0, 0.0); // поворот объекта - ось Y

 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Задаем формат пикселей}
procedure TfrmGL.SetDCPixelFormat (DC : HDC);
var
  hHeap: THandle;
  nColors, i: Integer;
  lpPalette: PLogPalette;
  byRedMask, byGreenMask, byBlueMask: Byte;
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;

begin
  FillChar(pfd, SizeOf(pfd), 0);

  pfd.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;

  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);

  DescribePixelFormat(DC, nPixelFormat, sizeof(TPixelFormatDescriptor), pfd);

  if ((pfd.dwFlags and PFD_NEED_PALETTE) <> 0) then begin
    nColors   := 1 shl pfd.cColorBits;
    hHeap     := GetProcessHeap;
    lpPalette := HeapAlloc(hHeap, 0, sizeof(TLogPalette) + (nColors * sizeof(TPaletteEntry)));

    // Стандартные установки номера версии и числа элементов палитры
    lpPalette^.palVersion := $300;
    lpPalette^.palNumEntries := nColors;

    byRedMask   := (1 shl pfd.cRedBits) - 1;
    byGreenMask := (1 shl pfd.cGreenBits) - 1;
    byBlueMask  := (1 shl pfd.cBlueBits) - 1;

    // Заполняем палитру цветами
    for i := 0 to nColors - 1 do begin
      lpPalette^.palPalEntry[i].peRed   := (((i shr pfd.cRedShift)   and byRedMask)   * 255) DIV byRedMask;
      lpPalette^.palPalEntry[i].peGreen := (((i shr pfd.cGreenShift) and byGreenMask) * 255) DIV byGreenMask;
      lpPalette^.palPalEntry[i].peBlue  := (((i shr pfd.cBlueShift)  and byBlueMask)  * 255) DIV byBlueMask;
      lpPalette^.palPalEntry[i].peFlags := 0;
    end;

    // Создаем палитру
    Palette := CreatePalette(lpPalette^);
    HeapFree(hHeap, 0, lpPalette);

    // Устанавливаем палитру в контексте устройства
    if (Palette <> 0) then begin
      SelectPalette(DC, Palette, False);
      RealizePalette(DC);
    end;
  end;

end;

{=======================================================================
Сообщение WM_QUERYNEWPALETTE}
procedure TfrmGL.WMQueryNewPalette(var Msg : TWMQueryNewPalette);
begin
  // Это сообщение посылается окну, которое становится активным
  // В ответ мы должны реализовать свою логическую палитру, т.к.
  // пока главное окно не было активным, другое прложение
  // могло изменить системную палитру
  if (Palette <> 0) then begin
    Msg.Result := RealizePalette(DC);

  // Если удалось отобразить хоть один цвет в системную палитру,
  // перерисовываем окно
  if (Msg.Result <> GDI_ERROR) then
    InvalidateRect(Handle, nil, False);
  end;
end;

{=======================================================================
Сообщение WM_PALETTECHANGED}
procedure TfrmGL.WMPaletteChanged(var Msg : TWMPaletteChanged);
begin
  // Этот обработчик активизируется всегда, когда какое-либо приложение
  // изменяет системную палитру
  if ((Palette <> 0) and (THandle(TMessage(Msg).wParam) <> Handle))
  then begin
    if (RealizePalette(DC) <> GDI_ERROR) then
      UpdateColors(DC);

    Msg.Result := 0;
  end;
end;

end.

