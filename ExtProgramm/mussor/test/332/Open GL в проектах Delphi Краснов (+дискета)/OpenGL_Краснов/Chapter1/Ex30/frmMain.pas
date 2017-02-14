{**********************************************************************}
{* »ллюстраци€ к книге "OpenGL в проектах Delphi"                     *}
{*  раснов ћ.¬. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;
interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Controls,
  SysUtils, Dialogs, OpenGL;

const
  MaxVideoModes = 200; // этого должно хватить

type TVideoMode = record
  Width,
  Height,
  ColorDepth : Word;
  Description : String[20];
end;

type
  TLowResMode = record
     Width,
     Height,
     ColorDepth : Word;
  end;

const

NumberLowResModes = 60;
LowResModes : array[0..NumberLowResModes-1] of TLowResMode =
((Width:320;Height:200;ColorDepth: 8),(Width:320;Height:200;ColorDepth:15),
 (Width:320;Height:200;ColorDepth:16),(Width:320;Height:200;ColorDepth:24),
 (Width:320;Height:200;ColorDepth:32),(Width:320;Height:240;ColorDepth: 8),
 (Width:320;Height:240;ColorDepth:15),(Width:320;Height:240;ColorDepth:16),
 (Width:320;Height:240;ColorDepth:24),(Width:320;Height:240;ColorDepth:32),
 (Width:320;Height:350;ColorDepth: 8),(Width:320;Height:350;ColorDepth:15),
 (Width:320;Height:350;ColorDepth:16),(Width:320;Height:350;ColorDepth:24),
 (Width:320;Height:350;ColorDepth:32),(Width:320;Height:400;ColorDepth: 8),
 (Width:320;Height:400;ColorDepth:15),(Width:320;Height:400;ColorDepth:16),
 (Width:320;Height:400;ColorDepth:24),(Width:320;Height:400;ColorDepth:32),
 (Width:320;Height:480;ColorDepth: 8),(Width:320;Height:480;ColorDepth:15),
 (Width:320;Height:480;ColorDepth:16),(Width:320;Height:480;ColorDepth:24),
 (Width:320;Height:480;ColorDepth:32),(Width:360;Height:200;ColorDepth: 8),
 (Width:360;Height:200;ColorDepth:15),(Width:360;Height:200;ColorDepth:16),
 (Width:360;Height:200;ColorDepth:24),(Width:360;Height:200;ColorDepth:32),
 (Width:360;Height:240;ColorDepth: 8),(Width:360;Height:240;ColorDepth:15),
 (Width:360;Height:240;ColorDepth:16),(Width:360;Height:240;ColorDepth:24),
 (Width:360;Height:240;ColorDepth:32),(Width:360;Height:350;ColorDepth: 8),
 (Width:360;Height:350;ColorDepth:15),(Width:360;Height:350;ColorDepth:16),
 (Width:360;Height:350;ColorDepth:24),(Width:360;Height:350;ColorDepth:32),
 (Width:360;Height:400;ColorDepth: 8),(Width:360;Height:400;ColorDepth:15),
 (Width:360;Height:400;ColorDepth:16),(Width:360;Height:400;ColorDepth:24),
 (Width:360;Height:400;ColorDepth:32),(Width:360;Height:480;ColorDepth: 8),
 (Width:360;Height:480;ColorDepth:15),(Width:360;Height:480;ColorDepth:16),
 (Width:360;Height:480;ColorDepth:24),(Width:360;Height:480;ColorDepth:32),
 (Width:400;Height:300;ColorDepth: 8),(Width:400;Height:300;ColorDepth:15),
 (Width:400;Height:300;ColorDepth:16),(Width:400;Height:300;ColorDepth:24),
 (Width:400;Height:300;ColorDepth:32),(Width:512;Height:384;ColorDepth: 8),
 (Width:512;Height:384;ColorDepth:15),(Width:512;Height:384;ColorDepth:16),
 (Width:512;Height:384;ColorDepth:24),(Width:512;Height:384;ColorDepth:32));

var
  VideoModes : array [0..MaxVideoModes] of TVideoMode;
  ScreenModeChanged : Boolean;
  NumberVideomodes : Integer = 1; // как минимум 1, 'default' режим

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    hrc: HGLRC;
    procedure SetDCPixelFormat (DC : HDC);
    function SetFullscreenMode(ModeIndex: Integer) : Boolean;
    procedure TryToAddToList(DeviceMode: TDevMode);
    procedure ReadVideoModes;
    procedure RestoreDefaultMode;
  public
    SelectedMode : Integer;
  end;

var
  frmGL: TfrmGL;

implementation

uses Unit1;

{$R *.DFM}

function TfrmGL.SetFullscreenMode(ModeIndex: Integer) : Boolean;
// устанавливаем видеорежим согласно аргументу 'ModeIndex'
var
  DeviceMode : TDevMode;
begin
  with DeviceMode do begin
    dmSize := SizeOf(DeviceMode);
    dmBitsPerPel := VideoModes[ModeIndex].ColorDepth;
    dmPelsWidth := VideoModes[ModeIndex].Width;
    dmPelsHeight := VideoModes[ModeIndex].Height;
    dmFields := DM_BITSPERPEL or DM_PELSWIDTH or DM_PELSHEIGHT;
    // если режим не устанавливаетс€, ScreenModeChanged = False
    Result := ChangeDisplaySettings(DeviceMode,CDS_FULLSCREEN) = DISP_CHANGE_SUCCESSFUL;
    if Result then ScreenModeChanged := True;
    if ModeIndex = 0 then ScreenModeChanged:=False;
  end;
end;

procedure TfrmGL.TryToAddToList(DeviceMode: TDevMode);
// ƒобавить видеорежим в список, если это не дублированный
// и действительно его можно установить
var
  I : Integer;
begin
// отделить дублированный режим (может случитьс€ из-за освежени€
// показателей, или из-за того, что мы €вно пробуем весь низкоуровневые режимы).
  for I := 1 to NumberVideomodes - 1 do
    with DeviceMode do
      if ((dmBitsPerPel = VideoModes[I].ColorDepth) and
          (dmPelsWidth = VideoModes[I].Width) and
          (dmPelsHeight = VideoModes[I].Height)) then Exit;

// тестирование режима (не устанавливает режим, но сообщает, удалось ли бы это).

  if ChangeDisplaySettings(DeviceMode,CDS_TEST or CDS_FULLSCREEN) <> DISP_CHANGE_SUCCESSFUL then Exit;

// это - новый, правильный способ, так что дополн€ем его в список
  with DeviceMode do begin
    VideoModes[NumberVideomodes].ColorDepth:=dmBitsPerPel;
    VideoModes[NumberVideomodes].Width:=dmPelsWidth;
    VideoModes[NumberVideomodes].Height:=dmPelsHeight;
    VideoModes[NumberVideomodes].Description:=Format('%d x %d, %d bpp',[dmPelsWidth,dmPelsHeight,dmBitsPerPel]);
  end;
  Inc(NumberVideomodes);
end;

procedure TfrmGL.ReadVideoModes;
var
  I, ModeNumber : Integer;
  done : Boolean;
  DeviceMode : TDevMode;
  DeskDC : HDC;
begin
  // подготовим 'default' режим
  with VideoModes[0] do
  try
    DeskDC := GetDC (0);
    ColorDepth := GetDeviceCaps (DeskDC, BITSPIXEL);
    Width := Screen.Width;
    Height := Screen.Height;
    Description := 'default';
  finally
    ReleaseDC(0, DeskDC);
  end;

  // перечисл€ем все доступные видеорежимы
  ModeNumber:=0;
  done := False;
  repeat
    done := not EnumDisplaySettings(nil,ModeNumber,DeviceMode);
    TryToAddToList(DeviceMode);
    Inc(ModeNumber);
  until (done or (NumberVideomodes >= MaxVideoModes));

  // запрашиваем €вно о низкоуровневых режимах
  with DeviceMode do begin
    dmBitsPerPel:=8;
    dmPelsWidth:=42;
    dmPelsHeight:=37;
    dmFields:=DM_BITSPERPEL or DM_PELSWIDTH or DM_PELSHEIGHT;

  // убедимс€, что драйвер не отвечает "да" во всех тестах
  if ChangeDisplaySettings(DeviceMode,CDS_TEST or CDS_FULLSCREEN) <> DISP_CHANGE_SUCCESSFUL then
  begin
    I:=0;
    while (I < NumberLowResModes-1) and (NumberVideoModes < MaxVideoModes) do
    begin
      dmSize:=Sizeof(DeviceMode);
      dmBitsPerPel:=LowResModes[I].ColorDepth;
      dmPelsWidth:=LowResModes[I].Width;
      dmPelsHeight:=LowResModes[I].Height;
      dmFields:=DM_BITSPERPEL or DM_PELSWIDTH or DM_PELSHEIGHT;
      TryToAddToList(DeviceMode);
      Inc(I);
    end;
  end;
end;

end;

procedure TfrmGL.RestoreDefaultMode;
// возвращение первоначального режима экрана
var
  T : TDevMode absolute 0; // небольша€ хитрость, чтобы создать указатель нул€
begin
// ѕервый параметр должен быть переменной, нельз€ использовать непосредственно нуль
// ¬замен мы используем переменную с абсолютным адресом 0.
  ChangeDisplaySettings(T, CDS_FULLSCREEN);
end;


{=======================================================================
—оздание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
var
  i : 0..MaxVideoModes;
  Form1 : TForm1;
begin
  ReadVideoModes;
  Form1 := TForm1.Create (Self);
  For i := 0 to MaxVideoModes do
      If VideoModes[i].Description <> '' then
         Form1.ComboBox1.Items.Add (VideoModes[i].Description);
  Form1.ComboBox1.ItemIndex := 0;
  Form1.Showmodal;
  Form1.Free;

  SetFullscreenMode(SelectedMode);

  WindowState := wsMaximized;

  SetDCPixelFormat (Canvas.Handle);
  hrc := wglCreateContext(Canvas.Handle);

  If hrc = 0 then
     ShowMessage ('ќшибка получени€ контекста воспроизведени€!');
end;

{=======================================================================
‘ормат пикселей}
procedure TfrmGL.SetDCPixelFormat (DC : HDC);
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;
begin
  FillChar(pfd, SizeOf(pfd), 0);
  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;


{=======================================================================
 онец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglDeleteContext(hrc);
 RestoreDefaultMode;
end;

procedure TfrmGL.FormPaint(Sender: TObject);
begin
 If hrc = 0 then Close;
 wglMakeCurrent(Canvas.Handle, hrc);

 glClearColor(0.25, 0.1, 0.75,0.0);
 glClear (GL_COLOR_BUFFER_BIT);      // очистка буфера цвета

 wglMakeCurrent(0, 0);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close
end;

end.

