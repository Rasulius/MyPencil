{
  Professional Screen Camera Delphi Unit v3.0 (Delphi 7 To Up)
  Developed 2008 by Mohammad Reza Hanifeh Pour (MRH Software Co)
  E-Mail: mrh.info2007@gmail.com
  Tel: +98-2177644130
  Address: 29 Rezai St. Namjo Av. F2 Tehran-Iran.
  see README.TXT for license details
}

unit ScrCam;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
     Dialogs, StdCtrls, ExtCtrls, ActiveX, Vfw, FlashWnd, MMSystem, WaveMixer,
     WaveUtils, WaveRecorders;

{$WARNINGS OFF}
{$HINTS OFF}
{$RANGECHECKS OFF}

type
  TRegion = record
    Left, Top, Width, Height: Integer;
    end;

  TTimerRecord = record
    TimerON: Boolean;
    Hour, Min, Sec: Byte;
    end;

  TGetAudioInfo = record
    AudioInputNames: TStringList;
    AudioInputIndex: Integer;
    AudioInputVolume: Integer;
    AudioInputEnabled: Boolean;
    end;

  TScreenRegion = (FreeHand, FixedMoving, FixedStable, FullScreen);

  TOperation = (None, Success, Fail);

  TScreenCamEvent = procedure(Sender: TObject) of object;

  TScreenCamErrorEvent = procedure(Sender: TObject; ErrorMessage: string) of object;

  TPreviewEvent = procedure(Sender: TObject;
      PreviewBitmap: TBitmap; Active: Boolean; Recording: Boolean) of object;

  TSaveEvent = procedure(Sender: TObject; Percent: Integer; var Continue: Boolean) of object;

  TRecordAVIThread = class;

  TICINFOS = array[0..31] of TICINFO;

  TScreenCamera = class(TObject)
  private
    FOwner: TComponent;
    Bits: Integer;
    nColors: Integer;
    CompfccHandler: DWORD;
    StrCodec: string;
    RecordState: Boolean;
    MaxXScreen, MaxYScreen: Integer;
    InitialTime: DWORD;
    FActualmspF : Real;
    FSkippedFrames : Integer;
    FComputedFrameNo, FActualFrameNo : Integer;
    ActualWidth, ActualHeight: Integer;
    FOnUpdate, FOnStart, FOnStop: TScreenCamEvent;
    FOnError: TScreenCamErrorEvent;
    FOnPreview: TPreviewEvent;
    FOnSaving: TSaveEvent;
    FRegion: TRegion;
    FPriority: Integer;
    FRecordAVIThread: TRecordAVIThread;
    FPlaybackFPS : Integer;
    FmspFRecord : Integer;
    FKeyFramesEvery: Integer;
    FSelectedCompressor: Integer;
    FCompressionQuality: Integer;
    FVideoCompressorCount: Integer;
    FVideoCompressorInfo: TICINFOS;
    FFilterCopy: Integer;
    FFrame: TFlashingWnd;
    FFreeHandFrame: TForm;
    FPreviewTimer, FTimer: TTimer;
    FCursorPos: TMouse;
    FAutoPan, FRecordCursor, FAudioRecord, FFlashingRect,
    FLineRectClear, FMinimize, FRestore,
    FFullScreen, FShowPreview,
    FStartRecording, FFreeHandMode, FRecompressAVIAfterCapture: Boolean;
    FTimerRecord: TTimerRecord;
    FElapsedTime: string;
    FWndHandle: HWnd;
    FHotKey1, FHotKey2: Integer;
    FBitmap: TBitmap;
    FScreenRegion: TScreenRegion;
    FShape1, FShape2, FShape3, FShape4: TShape;
    FVideoCodecList: TStringList;
    FAudioFormatList: TStringList;
    FAudioFormatsDefaultItemIndex: Integer;
    FAudioInfo: TGetAudioInfo;
    AudioMixer: TAudioMixer;
    StockAudioRecorder: TStockAudioRecorder;
    procedure FinalSaveAvi(const FileName: string; nStreams: Integer;
              Streams: APAVISTREAM; CompressOptions: PAVICOMPRESSOPTIONS);
    function LoadAVIFileToStream(const FileName: string): PAVIStream;
    function GetVideoCompressorsInfo: TStringList;
    function GetAudioFormatsInfo: TStringList;
    function GetAudioInputsInfo: TGetAudioInfo;
    function GetShowPreview: Boolean;
    procedure SetShowPreview(Value: Boolean);
    procedure FFreeHandFrameDraw;
    procedure GlobalHotKey(var Msg : TMessage);
    function PreviewScreenFrame(Left, Top, Width, Height: Integer; CopyMode: Integer): TBitmap;
    function CaptureScreenFrame(Left, Top, Width, Height: Integer; CopyMode: Integer): PBITMAPINFOHEADER;
    procedure ThreadDone(Sender: TObject);
    function RecordVideo(szFilename: string): Integer;
    procedure FFrameMinimize(Sender: TObject);
    procedure FOnTimer(Sender: TObject);
    procedure FShowPreviewTimer(Sender: TObject);
    function Bitmap2Ddb(HBitmap: HBitmap; Bits: LongWord): THandle;
    procedure MouseKeyDown(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
    procedure MouseMove(Sender: TObject; Shift: TShiftState; X,
              Y: Integer);
    procedure MouseKeyUp(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
  public
    constructor Create(Owner: TComponent); virtual;
    destructor Destroy; override;
    function StartRecording(szFileName: string): Boolean;
    procedure SetAudioInputIndex(Index: Integer);
    procedure SetAudioInputVolume(Index, Volume: Integer);
    procedure StopRecording;
    procedure CompressorHasFeatures(Compressor: Byte; var HasAbout: Boolean; var hasConfig: Boolean);
    procedure CompressorAbout(Compressor: Byte; WND: HWND);
    procedure CompressorConfigure(Compressor: Byte; WND: HWND);
    // report values (read-only)
    property ComputedFrameNo: Integer read FComputedFrameNo;
    property FramesCaptured: Integer read FActualFrameNo;
    property Avragefps: Real read FActualmspF; // actual FPS rate = should be Playback-fps rate on fast machines!
    property ElapsedTime: string read FElapsedTime;
    property DropedFrames: Integer read FSkippedFrames;
    property Colors: Integer read nColors;
    property CurrentVideoCodecName: string read StrCodec;
    property VideoCodecsList: TStringList read GetVideoCompressorsInfo;
    property AudioFormatsList: TStringList read GetAudioFormatsInfo;
    property Width: Integer read ActualWidth;
    property Height: Integer read ActualHeight;
    property GetAudioInputInfo: TGetAudioInfo read GetAudioInputsInfo;  // = Get audio input information
  protected
  published
    // options
    property FPSPlayback: Integer read FPlaybackFPS write FPlaybackFPS default 10;  // = FPS Playback rate
    property msPFRecord: Integer read FmsPFRecord write FmsPFRecord default 100;  // = FPS Record rate (100 = 1 Second)
    property KeyFramesEvery: Integer read FKeyFramesEvery write FKeyFramesEvery default 8; // key frame rate
    property CompressionQuality: Integer read FCompressionQuality write FCompressionQuality default 9000; // 1 - 10000
    property SelectedCompressor: Integer read FSelectedCompressor write FSelectedCompressor default -1; // No select any codec
    property Region: TRegion read FRegion write FRegion;
    property UseAudioRecord: Boolean read FAudioRecord write FAudioRecord default False;
    property AudioFormatsDefaultItemIndex: Integer read FAudioFormatsDefaultItemIndex write FAudioFormatsDefaultItemIndex default -1;
    property RecordCursor: Boolean read FRecordCursor write FRecordCursor default True;
    property DrawAreaCapture: Boolean read FFlashingRect write FFlashingRect default True;
    property LineRectClear: Boolean read FLineRectClear write FLineRectClear default True;
    property MinimizeAppOnStart: Boolean read FMinimize write FMinimize default True;
    property RestoreAppAfterRecord: Boolean read FRestore write FRestore default True;
    property RecompressAVIAfterRecord: Boolean read FRecompressAVIAfterCapture write FRecompressAVIAfterCapture default False;
    property ScreenRegion: TScreenRegion read FScreenRegion write FScreenRegion default FixedMoving; // FixedMoving = Move window by mouse
    property ShowPreview: Boolean read GetShowPreview write SetShowPreview default False;
    property Priority: Integer read FPriority write FPriority default 3; // 3 = Normal
    property SetTimer: TTimerRecord read FTimerRecord write FTimerRecord;
    property FilterColor: Integer read FFilterCopy write FFilterCopy default 0;
    // events
    property OnError: TScreenCamErrorEvent read FOnError write FOnError;
    property OnUpdate: TScreenCamEvent read FOnUpdate write FOnUpdate;
    property OnStart: TScreenCamEvent read FOnStart write FOnStart;
    property OnStop: TScreenCamEvent read FOnStop write FOnStop;
    property OnPreview: TPreviewEvent read FOnPreview write FOnPreview;
    property OnSaving: TSaveEvent read FOnSaving write FOnSaving;
  end;


  TRecordAVIThread = class(TThread)
  private
    FScrCam: TScreenCamera;
  protected
    procedure Execute; override;
  public
    constructor Create(ScrCam: TScreenCamera);
  end;

implementation

const
  hWndGlobal = 0;

var
  FSuccess: TOperation;
  TempVideoFile, TempAudioFile, FFileName: string;
  StartRegionSel, FLRC: Boolean;
  FRestor, SelectRegion1, SelectRegion2, RegionOK: Boolean;
  Sec, Min, Hur: Integer;
  X1, Y1, X2, Y2: Integer;

function TScreenCamera.GetShowPreview: Boolean;
begin
  Result := not FShowPreview;
end;

procedure TScreenCamera.SetShowPreview(Value: Boolean);
begin
  if Value then begin
    FShowPreview := True;
    FPreviewTimer.Enabled := True;
    end
  else begin
    FShowPreview := False;
    if not RecordState then begin
      FPreviewTimer.Enabled := False;
      ShowWindow(FFrame.Handle, SW_HIDE);
      if Assigned(FOnPreview) then
        FOnPreview(Self, nil, False, False);
      end;
    end;
end;

constructor TScreenCamera.Create(Owner: TComponent);
var
  hScreenDC: HDC;
  TempDir: String;
  I: Integer;
begin
  FOwner := Owner;

  SetLength(TempDir, MAX_PATH + 1);
  I := GetTempPath(MAX_PATH, pchar(TempDir));
  SetLength(TempDir, I);
  if Copy(TempDir, Length(TempDir), 1) <> '\' then TempDir := TempDir + '\';
  TempVideoFile := TempDir + '~vstream.avi';
  TempAudioFile := TempDir + '~astream.wav';

  RecordState := False;

	hScreenDC := GetDC(0);
	Bits := GetDeviceCaps(hScreenDC, BITSPIXEL);
	nColors := Bits;
	MaxXScreen := GetDeviceCaps(hScreenDC, HORZRES);
	MaxYScreen := GetDeviceCaps(hScreenDC, VERTRES);
	ReleaseDC(0, hScreenDC);

	CompfccHandler := mmioFOURCC('M', 'S', 'V', 'C');
  FVideoCodecList := TStringList.Create;
  StrCodec := 'Microsoft Video Codec';
  FVideoCodecList.Add(StrCodec);

  FAudioFormatList := TStringList.Create;
  FAudioInfo.AudioInputNames := TStringList.Create;

  Sec := 0;
  Min := 0;
  Hur := 0;

  StartRegionSel := False;

  X1 := 0; Y1 := 0; X2 := 0; Y2 := 0;

  FTimerRecord.TimerON := False;
  FTimerRecord.Hour := 0;
  FTimerRecord.Min := 0;
  FTimerRecord.Sec := 0;
  FmsPFRecord := 100;
  FPlaybackFPS := 10;
  FKeyFramesEvery := 8; // every 8 frames keyframe
  FCompressionQuality := 9000;
  FVideoCompressorCount := 0;
  FSelectedCompressor := -1;
  FAudioRecord := False;
  FRecordCursor := True;
  FFlashingRect := True;
  FLineRectClear := True;
  FRecompressAVIAfterCapture := False;
  FLRC := True;
  FAutoPan := False;
  FMinimize := True;
  FRestore := True;
  FRestor := True;

  FScreenRegion := FixedMoving;

  FFreeHandMode := False;
  FFullScreen := False;

  FRegion.Left := 0;
  FRegion.Top := 0;
  FRegion.Width := 300;
  FRegion.Height := 200;

  AudioMixer := TAudioMixer.Create(FOwner);
  StockAudioRecorder := TStockAudioRecorder.Create(FOwner);
  FAudioFormatsDefaultItemIndex := -1;

  FTimer := TTimer.Create(FOwner);
  FTimer.OnTimer := FOnTimer;
  FTimer.Interval := 1000;
  FTimer.Enabled := False;

  FFilterCopy := 0;

  FLRC := FLineRectClear;
  FBitmap := TBitmap.Create;

  FFrame := TFlashingWnd.Create(FOwner);
  ShowWindow(FFrame.Handle, SW_HIDE);

  FFreeHandFrame := TForm.Create(FOwner);
  FFreeHandFrame.BorderStyle := bsNone;
  FFreeHandFrame.Ctl3D := False;
  FFreeHandFrame.AlphaBlend := True;
  FFreeHandFrame.OnMouseDown := MouseKeyDown;
  FFreeHandFrame.OnMouseMove := MouseMove;
  FFreeHandFrame.OnMouseUp := MouseKeyUp;
  ShowWindow(FFreeHandFrame.Handle, SW_HIDE);

  SelectRegion1 := False;
  SelectRegion2 := False;
  RegionOK := False;

  FShape1 := TShape.Create(FOwner);
  FShape2 := TShape.Create(FOwner);
  FShape3 := TShape.Create(FOwner);
  FShape4 := TShape.Create(FOwner);
  FShape1.Parent := FFreeHandFrame;
  FShape2.Parent := FFreeHandFrame;
  FShape3.Parent := FFreeHandFrame;
  FShape4.Parent := FFreeHandFrame;

  FShape1.OnMouseDown := MouseKeyDown;
  FShape1.OnMouseMove := MouseMove;
  FShape1.OnMouseUp := MouseKeyUp;
  FShape2.OnMouseDown := MouseKeyDown;
  FShape2.OnMouseMove := MouseMove;
  FShape2.OnMouseUp := MouseKeyUp;
  FShape3.OnMouseDown := MouseKeyDown;
  FShape3.OnMouseMove := MouseMove;
  FShape3.OnMouseUp := MouseKeyUp;
  FShape4.OnMouseDown := MouseKeyDown;
  FShape4.OnMouseMove := MouseMove;
  FShape4.OnMouseUp := MouseKeyUp;

  FShape1.Visible := False;
  FShape2.Visible := False;
  FShape3.Visible := False;
  FShape4.Visible := False;
  FShape1.Pen.Style := psSolid;
  FShape1.Brush.Style := bsClear;
  FShape2.Pen.Style := psSolid;
  FShape2.Brush.Style := bsClear;
  FShape3.Pen.Style := psSolid;
  FShape3.Brush.Style := bsClear;
  FShape4.Pen.Style := psSolid;
  FShape4.Brush.Style := bsClear;

  GetAudioFormatsInfo;
  GetAudioInputsInfo;
  GetVideoCompressorsInfo;


  Application.OnMinimize := FFrameMinimize;

  FWndHandle := AllocateHWnd(GlobalHotKey);
  FHotKey1 := GlobalAddAtom('FHotKey1');
  RegisterHotKey(FWndHandle, FHotKey1, MOD_SHIFT, VK_ESCAPE);
  FHotKey2 := GlobalAddAtom('FHotKey2');
  RegisterHotKey(FWndHandle, FHotKey2, 0, VK_ESCAPE);

  FSuccess := None;
  FAutoPan := False;
  FRecordAVIThread := nil;

  FPreviewTimer := TTimer.Create(FOwner);
  FPreviewTimer.OnTimer := FShowPreviewTimer;
  FPreviewTimer.Interval := 20;
  FPreviewTimer.Enabled := False;
end;

destructor TScreenCamera.Destroy;
begin
  UnRegisterHotKey(FWndHandle, FHotKey1);
  UnRegisterHotKey(FWndHandle, FHotKey2);

  if FileExists(TempVideoFile) then
    DeleteFile(TempVideoFile);
  if FileExists(TempAudioFile) then
    DeleteFile(TempAudioFile);

  if FWndHandle <> 0 then
    DeAllocateHWnd(FWndHandle);
  AudioMixer.Free;
  StockAudioRecorder.Free;
  FAudioInfo.AudioInputNames.Free;
  FVideoCodecList.Free;
  FAudioFormatList.Free;
  FTimer.Free;
  FShape1.Free;
  FShape2.Free;
  FShape3.Free;
  FShape4.Free;
  FFreeHandFrame.Free;
  FFrame.Free;
end;

procedure TScreenCamera.MouseKeyDown(Sender: TObject; Button: TMouseButton;
          Shift: TShiftState; X, Y: Integer);
var
  MousePos: TMouse;
begin
  if (ssCtrl in Shift) and (Button = mbLeft) and RegionOK then begin
    if FShape1.Visible then
      FShape1.Visible := False;
    if FShape2.Visible then
      FShape2.Visible := False;
    if FShape3.Visible then
      FShape3.Visible := False;
    if FShape4.Visible then
      FShape4.Visible := False;

    RegionOK := False;

    FScreenRegion := FixedStable;

    ShowWindow(FFreeHandFrame.Handle, SW_HIDE);

    if StartRegionSel then begin
      StartRegionSel := False;
      if FFileName <> '' then
        StartRecording(FFileName);
      end;
    end
  else begin
    if (Button = mbLeft) then begin
      X1 := 0; Y1 := 0; X2 := 0; Y2 := 0;

      SelectRegion1 := True;
      RegionOK := False;

      if not FShape1.Visible then
        FShape1.Visible := True;
      if not FShape2.Visible then
        FShape2.Visible := True;
      if FShape3.Visible then
        FShape3.Visible := False;
      if FShape4.Visible then
        FShape4.Visible := False;

      FShape1.Height := FFreeHandFrame.Height;
      FShape1.Width := 2;
      FShape2.Height := 2;
      FShape2.Width := FFreeHandFrame.Width;

      FShape1.Left := MousePos.CursorPos.X;
      FShape1.Top := 0;

      FShape2.Left := 0;
      FShape2.Top := MousePos.CursorPos.Y;

      X1 := MousePos.CursorPos.X;
      Y1 := MousePos.CursorPos.Y;
      end;
    end;  
end;

procedure TScreenCamera.MouseMove(Sender: TObject; Shift: TShiftState;
          X, Y: Integer);
var
  MousePos: TMouse;
begin
  FFreeHandFrame.AlphaBlendValue := 180;
  FShape1.Pen.Color := clLime;
  FShape2.Pen.Color := clLime;
  FShape3.Pen.Color := clLime;
  FShape4.Pen.Color := clLime;

  if SelectRegion1 then begin
    if not FShape1.Visible then
      FShape1.Visible := True;
    if not FShape2.Visible then
      FShape2.Visible := True;
    if not FShape3.Visible then
      FShape3.Visible := True;
    if not FShape4.Visible then
      FShape4.Visible := True;

    FShape3.Height := FFreeHandFrame.Height;
    FShape3.Width := 2;
    FShape4.Height := 2;
    FShape4.Width := FFreeHandFrame.Width;

    FShape3.Left := MousePos.CursorPos.X;
    FShape3.Top := 0;

    FShape4.Left := 0;
    FShape4.Top := MousePos.CursorPos.Y;

    X2 := MousePos.CursorPos.X;
    Y2 := MousePos.CursorPos.Y;

    RegionOK := True;
    end
  else begin
    if not RegionOK then begin
      if not FShape1.Visible then
        FShape1.Visible := True;
      if not FShape2.Visible then
        FShape2.Visible := True;
      if FShape3.Visible then
        FShape3.Visible := False;
      if FShape4.Visible then
        FShape4.Visible := False;

      FShape1.Height := FFreeHandFrame.Height;
      FShape1.Width := 2;
      FShape2.Height := 2;
      FShape2.Width := FFreeHandFrame.Width;

      FShape1.Left := MousePos.CursorPos.X;
      FShape1.Top := 0;

      FShape2.Left := 0;
      FShape2.Top := MousePos.CursorPos.Y;
      end;
    end;
end;

procedure TScreenCamera.MouseKeyUp(Sender: TObject; Button: TMouseButton;
          Shift: TShiftState; X, Y: Integer);
begin
  SelectRegion1 := False;

  if X1 < X2 then begin
    FRegion.Left := X1;
    FRegion.Width := X2 - X1;
    end
  else begin
    FRegion.Left := X2;
    FRegion.Width := X1 - X2;
    end;

  if Y1 < Y2 then begin
    FRegion.Top := Y1;
    FRegion.Height := Y2 - Y1;
    end
  else begin
    FRegion.Top := Y2;
    FRegion.Height := Y1 - Y2;
    end;
end;

function TScreenCamera.PreviewScreenFrame(Left, Top, Width, Height: Integer; CopyMode: Integer): TBitmap;
var
	hScreenDC: HDC;
  IconInf: TIconInfo;
  CursorInf: TCursorInfo;
  Icon: TIcon;
  CopySrc: Integer;
begin
  case CopyMode of
    0 : CopySrc := SRCCOPY;
    1 : CopySrc := NOTSRCCOPY;
    else CopySrc := SRCCOPY;
  end;

  FBitmap.Width := Width;
  FBitmap.Height := Height;

  hScreenDC := GetDC(0);

  FBitmap.Canvas.Handle := CreateCompatibleDC(hScreenDC);

  BitBlt(FBitmap.Canvas.Handle,
         0,
         0,
         Width,
         Height,
         hScreenDC,
         Left,
         Top,
         CopySrc);

 	if (FRecordCursor) then begin
    Icon := TIcon.Create;
    try
      CursorInf.cbSize := SizeOf(TCursorInfo);
      if GetCursorInfo(CursorInf) then
      if CursorInf.Flags = CURSOR_SHOWING then begin
        Icon.Handle := CursorInf.hCursor;
        if GetIconInfo(Icon.Handle, IconInf) then
          DrawIcon(FBitmap.Canvas.Handle,
                   CursorInf.ptScreenPos.x - (IconInf.xHotspot + Left),
                   CursorInf.ptScreenPos.y - (IconInf.yHotspot+ Top),
                   Icon.Handle);
        end;
    finally
      Icon.Free;
      end;
    end;

 	ReleaseDC(0, hScreenDC);

  Result := FBitmap;
end;

procedure TScreenCamera.FFreeHandFrameDraw;
begin
  FFreeHandFrame.Left := 0;
  FFreeHandFrame.Top := 0;
  FFreeHandFrame.Width := Screen.Width;
  FFreeHandFrame.Height := Screen.Height;
  FFreeHandFrame.Canvas.Brush.Style := bsClear;
  FFreeHandFrame.Canvas.Font.Color := clYellow;
  FFreeHandFrame.Canvas.Font.Name := 'Arial Black';
  FFreeHandFrame.Canvas.Font.Size := 15;
  FFreeHandFrame.Canvas.TextOut(50, 5, 'For Cancel Press (Esc Key)');
  FFreeHandFrame.Canvas.TextOut(390, 5, 'For Save Press (Ctrl + Left Click)');
end;

procedure TScreenCamera.FShowPreviewTimer(Sender: TObject);
begin
  if not RecordState then begin
    case FScreenRegion of
      FreeHand:    begin
                     FFreeHandMode := True;
                     FAutoPan := False;
                     FFullScreen := False;
                   end;
      FixedMoving: begin
                     FFreeHandMode := False;
                     FAutoPan := True;
                     FFullScreen := False;
                   end;
      FixedStable: begin
                     FFreeHandMode := False;
                     FAutoPan := False;
                     FFullScreen := False;
                   end;
      FullScreen:  begin
                     FFreeHandMode := False;
                     FAutoPan := False;
                     FFullScreen := True;
                   end;
      end;
    end
  else begin
    if FScreenRegion = FreeHand then begin
      FScreenRegion := FixedStable;
      FFreeHandMode := False;
      FAutoPan := False;
      FFullScreen := False;
      end;
    end;

  if StartRegionSel or FShowPreview or (RecordState and not FFullScreen) then begin
    if FFullScreen then begin
      FRegion.Left := 0;
      FRegion.Top := 0;
      FRegion.Width := Screen.Width;
      FRegion.Height := Screen.Height;
      end
    else begin
      if FFreeHandMode then begin
        FFreeHandFrameDraw;
        ShowWindow(FFreeHandFrame.Handle, SW_SHOW);
        SetWindowPos(FFreeHandFrame.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOREPOSITION or SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
        Exit;
        end
      else begin
        if FAutoPan then begin
          FRegion.Left := FCursorPos.CursorPos.X - (FRegion.Width div 2);
          FRegion.Top := FCursorPos.CursorPos.Y - (FRegion.Height div 2);

          if FRegion.Left < 0 then
            FRegion.Left := 0;
          if FRegion.Top < 0 then
            FRegion.Top := 0;

          if FRegion.Left + FRegion.Width > Screen.Width then
            FRegion.Left := Screen.Width - FRegion.Width;
          if FRegion.Top + FRegion.Height > Screen.Height then
            FRegion.Top := Screen.Height - FRegion.Height;
          end;
        end;
      end;

    if (FFlashingRect) then begin
      if (not RecordState) and FShowPreview then begin
        FFrame.SetUpRegion(FRegion.Left, FRegion.Top, FRegion.Width, FRegion.Height, FLineRectClear, 'Preview... Cancel: Esc');
        FFrame.PaintBorder(clRed, 'Preview... Cancel: Esc');
        end
      else begin
        FFrame.SetUpRegion(FRegion.Left, FRegion.Top, FRegion.Width, FRegion.Height, FLineRectClear, 'Start Recording... Cancel: Esc --- End: Shift+Esc');
        FFrame.PaintBorder(clRed, 'Start Recording... Cancel: Esc --- End: Shift+Esc');
        end;
        ShowWindow(FFrame.Handle, SW_SHOW);
        SetWindowPos(FFrame.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOREPOSITION or SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
      end
    else begin
      ShowWindow(FFrame.Handle, SW_HIDE);
      end;

    if Assigned(FOnPreview) then begin
      if FShowPreview and not RecordState then begin
        FOnPreview(Self, PreviewScreenFrame(FRegion.Left, FRegion.Top, FRegion.Width, FRegion.Height, FFilterCopy), True, False)
        end
      else begin
        if (FShowPreview) and (RecordState)
           //Notice: some of sizes on record mode for preview equal system error.
           //and not (FRegion.Right  > 800)  // Width of region
           //and not (FRegion.Bottom > 700)  // Height of region
           then
          FOnPreview(Self, PreviewScreenFrame(FRegion.Left, FRegion.Top, FRegion.Width, FRegion.Height, FFilterCopy), True, True)
        else begin
          if RecordState then
            FOnPreview(Self, nil, False, True)
          else
            FOnPreview(Self, nil, False, False);
          end;
        end;
      end;
    end
  else begin
    ShowWindow(FFrame.Handle, SW_HIDE);
    if Assigned(FOnPreview) then begin
      if RecordState then
        FOnPreview(Self, nil, False, True)
      else
        FOnPreview(Self, nil, False, False);
      end;
    end;
end;

procedure TScreenCamera.FOnTimer(Sender: TObject);
begin
  Sec := Sec + 1;
  if Sec = 60 then begin
    Sec := 0;
    Min := Min + 1;
    if Min = 60 then begin
      Hur := Hur + 1;
      Min := 0;
      end;
    end;

  FElapsedTime := IntToStr(Hur) + ':' +
                  IntToStr(Min) + ':' +
                  IntToStr(Sec);

  if FTimerRecord.TimerON then
    if (Hur = FTimerRecord.Hour) and
       (Min = FTimerRecord.Min) and
       (Sec = FTimerRecord.Sec) then
       StopRecording;
end;

procedure TScreenCamera.FFrameMinimize(Sender: TObject);
begin
  if FFrame.Showing then
    SendMessage(FFrame.Handle, WM_SYSCOMMAND, SC_RESTORE, 0)
end;

procedure TScreenCamera.GlobalHotKey(var Msg: TMessage);
begin
  case Msg.Msg of
    WM_HOTKEY:
      begin
        if Msg.WParam = FHotKey1 then
          FSuccess := Success;

        if Msg.WParam = FHotKey2 then begin
          FSuccess := Fail;
          ShowWindow(FFreeHandFrame.Handle, SW_HIDE);

          if FShape1.Visible then
            FShape1.Visible := False;
          if FShape2.Visible then
            FShape2.Visible := False;
          if FShape3.Visible then
            FShape3.Visible := False;
          if FShape4.Visible then
            FShape4.Visible := False;

          StartRegionSel := False;

          if FRestore then
            Application.Restore;

          if FShowPreview and not RecordState then
            SetShowPreview(False);
          end;

        if RecordState then begin
          RecordState := False;
          if not FShowPreview then
            SetShowPreview(False)
          else
            SetShowPreview(True);
          end;
      end;
  end;
end;

procedure TScreenCamera.CompressorAbout(Compressor: Byte; WND: HWND);
var
  icv: hic;
begin
  if Compressor >= FVideoCompressorCount then Exit;
	icv := ICOpen(FVideoCompressorInfo[Compressor].fccType, FVideoCompressorInfo[compressor].fccHandler, ICMODE_QUERY);
	if (icv <> 0) then
  begin
  	ICAbout(icv, WND);
    ICClose(icv);
  end;
end;

procedure TScreenCamera.CompressorConfigure(Compressor: Byte; WND: HWND);
var
  icv: hic;
begin
  if Compressor >= FVideoCompressorCount then Exit;
	icv := ICOpen(FVideoCompressorInfo[compressor].fccType, FVideoCompressorInfo[compressor].fccHandler, ICMODE_QUERY);
	if (icv <> 0) then
  begin
  	ICConfigure(icv, WND);
    ICClose(icv);
  end;
end;


procedure TScreenCamera.CompressorHasFeatures(Compressor: Byte; var hasAbout: Boolean; var hasConfig: Boolean);
var
  icv: hic;
begin
  hasAbout := False;
  hasConfig := False;
  if Compressor >= FVideoCompressorCount then Exit;
	icv := ICOpen(FVideoCompressorInfo[Compressor].fccType, FVideoCompressorInfo[Compressor].fccHandler, ICMODE_QUERY);
	if (icv <> 0) then
  begin
  	hasAbout := ICQueryAbout(icv);
  	hasConfig := ICQueryConfigure(icv);
    ICClose(icv);
  end;
end;


function TScreenCamera.Bitmap2Ddb(HBitmap: HBitmap; Bits: LongWord): Thandle;
var
	hdib: THANDLE;
  ahdc: HDC;
	Bitmap: Windows.TBitmap;
	wLineLen: longword;
	dwSize: DWORD;
	wColSize: DWORD;
	lpbi: PBITMAPINFOHEADER;
	lpBits: PByte;
begin
	GetObject(HBitmap, Sizeof(Bitmap), @Bitmap);
	// DWORD align the width of the DIB
	// Figure out the size of the colour table
	// Calculate the size of the DIB

	wLineLen := (bitmap.bmWidth*bits+31)div 32 * 4;
  if (bits <= 8) then wColSize := sizeof(RGBQUAD)* (1 SHL bits)
    else wColSize := 0;
	dwSize := sizeof(BITMAPINFOHEADER) + wColSize +
		wLineLen*bitmap.bmHeight;

	// Allocate room for a DIB and set the LPBI fields
	hdib := GlobalAlloc(GHND,dwSize); //allocate bitmap handle
	if (hdib=0) then
  begin
		result := hdib;
    exit;
  end;

	lpbi := GlobalLock(hdib) ;  // lock bitmap handle and get back pointer

	lpbi^.biSize := sizeof(BITMAPINFOHEADER) ;
	lpbi^.biWidth  :=  bitmap.bmWidth ;
	lpbi^.biHeight := bitmap.bmHeight ;
	lpbi^.biPlanes := 1 ;
	lpbi^.biBitCount := bits ;
	lpbi^.biCompression := BI_RGB ;
	lpbi^.biSizeImage := dwSize - sizeof(BITMAPINFOHEADER) - wColSize ;
	lpbi^.biXPelsPerMeter := 0 ;
	lpbi^.biYPelsPerMeter := 0 ;
  if bits <= 8 then lpbi^.biClrUsed := 1 SHL bits
    else lpbi^.biClrUsed := 0;
	lpbi^.biClrImportant := 0 ;

	// Get the bits from the bitmap and stuff them after the LPBI
	lpBits := pointer(longword(lpbi)+lpbi^.biSize+wColSize) ;

	ahdc := CreateCompatibleDC(0) ;

  // retrieve the bits of hbitmap and copy them into the buffer lpBits using the specified format in lpbi
  if GetDIBits(ahdc,hbitmap,0,bitmap.bmHeight,lpBits,PBITMAPINFO(lpbi)^, DIB_RGB_COLORS) = 0 then
  begin
    if Assigned(FOnError) then FOnError(Self, 'Error retrieving bitmap bits');
  end;

  if bits <= 8 then	lpbi^.biClrUsed := (1 SHL bits)
    else lpbi^.biClrUsed := 0;

	DeleteDC(ahdc);
	GlobalUnlock(hdib);

	Result := hdib;
end;


function TScreenCamera.CaptureScreenFrame(Left, Top, Width, Height: Integer; CopyMode: Integer): PBITMAPINFOHEADER;
var
	hScreenDC: HDC;
  IconInf: TIconInfo;
  CursorInf: TCursorInfo;
  Icon: TIcon;
  hMemDC: HDC;
  hbm: HBITMAP;
  Oldbm: HBITMAP;
  pBM_HEADER: PBITMAPINFOHEADER;
  CopySrc: Integer;
begin
  case CopyMode of
    0 : CopySrc := SRCCOPY;
    1 : CopySrc := NOTSRCCOPY;
    else CopySrc := SRCCOPY;
  end;

  if RecordState then
    case FPriority of
      0: FRecordAVIThread.Priority := tpIdle;
      1: FRecordAVIThread.Priority := tpLowest;
      2: FRecordAVIThread.Priority := tpLower;
      3: FRecordAVIThread.Priority := tpNormal;
      4: FRecordAVIThread.Priority := tpHigher;
      5: FRecordAVIThread.Priority := tpHighest;
      6: FRecordAVIThread.Priority := tpTimeCritical;
    end;

  hScreenDC := GetDC(0);

  hMemDC := CreateCompatibleDC(hScreenDC);

  hbm := CreateCompatibleBitmap(hScreenDC, Width, Height);
 	Oldbm := SelectObject(hMemDC, hbm);

  // bit block transfer from  hScreenDC to hMemdc
  BitBlt(hMemDC,
         0,
         0,
         Width,
         Height,
         hScreenDC,
         Left,
         Top,
         CopySrc);

	//Draw the Cursor
 	if (FRecordCursor) then begin
    Icon := TIcon.Create;
    try
      CursorInf.cbSize := SizeOf(TCursorInfo);
      if GetCursorInfo(CursorInf) then
      if CursorInf.Flags = CURSOR_SHOWING then begin
        Icon.Handle := CursorInf.hCursor;
        if GetIconInfo(Icon.Handle, IconInf) then
          DrawIcon(hMemDC,
                   CursorInf.ptScreenPos.x - (IconInf.xHotspot + Left),
                   CursorInf.ptScreenPos.y - (IconInf.yHotspot+ Top),
                   Icon.Handle);
        end;
    finally
      Icon.Free;
      end;
    end;

	SelectObject(hMemDC, Oldbm);

	pBM_HEADER := GlobalLock(Bitmap2Ddb(hbm, Bits));	// lock bitmap handle and get pointer

	if (pBM_HEADER = nil) then begin
    if Assigned(FOnError) then FOnError(Self, 'Error capturing a frame!');
		Result := nil;
    Exit;
  	end;

	DeleteObject(hbm);
	DeleteDC(hMemDC);

	ReleaseDC(0, hScreenDC);

  Result := pBM_HEADER;
end;

procedure FreeFrame(var alpbi: PBITMAPINFOHEADER);
begin
	if (alpbi = nil) then Exit;
	GlobalFreePtr(alpbi);
	//GlobalFree(alpbi);
	alpbi := 0;
end;

function TScreenCamera.GetAudioInputsInfo: TGetAudioInfo;
var
  I, J: Integer;
begin
  FAudioInfo.AudioInputNames.Clear;
  AudioMixer.MixerID := 0;
  for I := 0 to AudioMixer.DestinationCount - 1 do begin
    AudioMixer.DestinationID := I;
    if mcSelect in AudioMixer.Master.AvailableControls then begin
      FAudioInfo.AudioInputIndex := AudioMixer.Master.SelectedLine;
      FAudioInfo.AudioInputVolume := AudioMixer.Master.Mixer.Lines[FAudioInfo.AudioInputIndex].Volume;
      FAudioInfo.AudioInputEnabled := mcVolume in AudioMixer.Master.Mixer.Lines[FAudioInfo.AudioInputIndex].AvailableControls;
      for J := 0 to AudioMixer.Master.Mixer.LineCount - 1 do begin
        FAudioInfo.AudioInputNames.Add(AudioMixer.Master.Mixer.Lines[J].Name);
        end;
      end;
    end;
  Result := FAudioInfo;
end;

procedure TScreenCamera.SetAudioInputIndex(Index: Integer);
var
  I: Integer;
begin
  AudioMixer.MixerID := 0;
  AudioMixer.Master.SelectedLine := Index;
end;

procedure TScreenCamera.SetAudioInputVolume(Index, Volume: Integer);
begin
  AudioMixer.MixerID := 0;
  AudioMixer.Master.Mixer.Lines[Index].Volume := Volume;
end;

function TScreenCamera.GetAudioFormatsInfo: TStringList;
var
  pcm: TPCMFormat;
  WaveFormatEx: TWaveFormatEx;
begin
  FAudioFormatList.Clear;
  for pcm := Succ(Low(TPCMFormat)) to High(TPCMFormat) do begin
    SetPCMAudioFormatS(@WaveFormatEx, pcm);
    FAudioFormatList.Add(GetWaveAudioFormat(@WaveFormatEx));
    end;
  if FAudioFormatsDefaultItemIndex = -1 then
    FAudioFormatsDefaultItemIndex := Ord(StockAudioRecorder.PCMFormat) - 1;
  Result := FAudioFormatList;
end;

function TScreenCamera.GetVideoCompressorsInfo: TStringList;
var
  icv: hic;
 	first_alpbi: PBITMAPINFOHEADER;
  i: Integer;
begin
  first_alpbi := CaptureScreenFrame(0, 0, 88, 72, FFilterCopy);
  FVideoCompressorCount := 0;
  FVideoCodecList.Clear;

  for i := 0 to 31 do begin
   	ICInfo(ICTYPE_VIDEO, i, @FVideoCompressorInfo[FVideoCompressorCount]);
 		icv := ICOpen(FVideoCompressorInfo[FVideoCompressorCount].fccType, FVideoCompressorInfo[FVideoCompressorCount].fccHandler, ICMODE_QUERY);
		if (icv <> 0) then begin
			if (ICCompressQuery(icv, first_alpbi, nil) = ICERR_OK) then begin
				ICGetInfo(icv, @FVideoCompressorInfo[FVideoCompressorCount], sizeof(TICINFO));
    		inc(FVideoCompressorCount);
        end;
			ICClose(icv);
      end;
    end;

  for i := 0 to FVideoCompressorCount - 1 do
    FVideoCodecList.Add(FVideoCompressorInfo[i].szDescription);

	FreeFrame(first_alpbi);
  
  Result := FVideoCodecList;
end;


function TScreenCamera.RecordVideo(szFileName: string): Integer;
var
	alpbi: PBitmapInfoHeader;
	strhdr: TAVISTREAMINFO;
	pfile: PAVIFile;
	ps: PAVIStream;
  psCompressed: PAVIStream;
  TempCompressed: APAVIStream;
  opts: TAVICOMPRESSOPTIONS;
	Option: PAVICOMPRESSOPTIONS;
	TempOption: PAVICOMPRESSOPTIONS;
	hr: HRESULT;
  wVer: WORD;
	szTitle: string;
  ic: HIC;
  newleft, newtop, newwidth, newheight: Integer;
  N, align: Integer;
  hm, wm: Integer;
 	timeexpended, savingtime, oldframetime, oldupdatetime : LongWord;
  oldcomputedframeno, sleepdivider: Integer;
	divx, oldsec: LongWord;
  remaintime, no_iteration, j: Integer;
label
  Error;
begin
  ActualWidth  := FRegion.Width;
	ActualHeight := FRegion.Height;

	wVer := HIWORD(VideoForWindowsVersion);
	if (wVer < $010a) then begin
    if Assigned(FOnError) then FOnError(Self, 'Failure: Video for Windows version too old!');
    RecordState := False;
    if not FShowPreview then begin
      ShowWindow(FFrame.Handle, SW_HIDE);
      FPreviewTimer.Enabled := False;
      end;
		Result := 0;
    Exit;
  	end;

	// CAPTURE FIRST FRAME -------------------------------------------
	alpbi := CaptureScreenFrame(FRegion.Left, FRegion.Top, FRegion.Width, FRegion.Height, FFilterCopy);
  // ---------------------------------------------------------------

	// TEST VALIDITY OF COMPRESSOR
  if (FSelectedCompressor <> -1) then begin
		ic := ICOpen(FVideoCompressorInfo[FSelectedCompressor].fccType, FVideoCompressorInfo[FSelectedCompressor].fccHandler, ICMODE_QUERY);
		if (ic <> 0) then begin
      align := 1;
			while (ICERR_OK <> ICCompressQuery(ic, alpbi, nil)) do begin
				//Try adjusting width/height a little bit
				align := align * 2 ;
				if (align>8) then break;

				newleft := FRegion.Left;
				newtop := FRegion.Top;
				wm := (FRegion.Width mod align);
				if (wm > 0) then begin
					newwidth := FRegion.Width + (align - wm);
					if (newwidth > maxxScreen) then
						newwidth := FRegion.Width - wm;
				  end;

				hm := (FRegion.Height mod align);
				if (hm > 0) then begin
					newheight := FRegion.Height + (align - hm);
					if (newheight > maxyScreen) then
						newwidth := FRegion.Height - hm;
  				end;

				if (alpbi <> nil) then FreeFrame(alpbi);
				alpbi := CaptureScreenFrame(newleft, newtop, newwidth, newheight, FFilterCopy);
        end;

  		//if succeed with new width/height, use the new width and height
	  	//else if still fails ==> default to MS Video 1 (MSVC)
		  if (align = 1) then begin
			  //Compressor has no problem with the current dimensions...so proceed
  			//do nothing here
        CompfccHandler := FVideoCompressorInfo[FSelectedCompressor].fccHandler;
 				StrCodec := FVideoCompressorInfo[FSelectedCompressor].szName;
		  	end
      else if (align <= 8) then begin
	  		//Compressor can work if the dimensions is adjusted slightly
		  	FRegion.Left   := newleft;
  			FRegion.Top    := newtop;
	  		FRegion.Width  := newwidth;
		  	FRegion.Height := newheight;
      	actualwidth  := newwidth;
	  		actualheight := newheight;
        CompfccHandler := FVideoCompressorInfo[FSelectedCompressor].fccHandler;
 				StrCodec := FVideoCompressorInfo[FSelectedCompressor].szName;
		    end
      else begin
      	if (MessageBox(Application.MainForm.Handle, 'Error: This compressor cann`t work if the dimensions is adjusted slightly' + #13#10 +
                          'Use default compressor? ', 'Notice',
                           MB_YESNO or MB_ICONEXCLAMATION) = IDYES) then begin
				  CompfccHandler := mmioFOURCC('M', 'S', 'V', 'C');
  				StrCodec := 'Microsoft Video Codec';
          end
        else begin
          if Assigned(FOnError) then FOnError(Self, 'User aborted!');
          RecordState := False;
          if not FShowPreview then begin
            ShowWindow(FFrame.Handle, SW_HIDE);
            FPreviewTimer.Enabled := False;
            end;
     	    Result := 0;
          Exit;
          end;
  			end;
	  		ICClose(ic);
		  end
    else begin
      if (MessageBox(Application.MainForm.Handle, 'Error: Not recording AVI file using current compressor.' + #13#10 +
                        'Use default compressor? ', 'Notice',
                         MB_YESNO or MB_ICONEXCLAMATION) = IDYES) then begin
	  	  CompfccHandler := mmioFOURCC('M', 'S', 'V', 'C');
		    StrCodec := 'Microsoft Video Codec';
        end
      else begin
        if Assigned(FOnError) then FOnError(Self, 'User aborted!');
        RecordState := False;
        if not FShowPreview then begin
          FPreviewTimer.Enabled := False;
          ShowWindow(FFrame.Handle, SW_HIDE);
          end;
   	    Result := 0;
        Exit;
        end;
	  	end;
	  end
  else begin
    if (MessageBox(Application.MainForm.Handle, 'You no selected compressor, use default compressor?', 'Notice',
                       MB_YESNO or MB_ICONEXCLAMATION) = IDYES) then begin
 	    CompfccHandler := mmioFOURCC('M', 'S', 'V', 'C');
      StrCodec := 'Microsoft Video Codec';
      end
    else begin
      if Assigned(FOnError) then FOnError(Self, 'User aborted!');
      RecordState := False;
      if not FShowPreview then begin
        FPreviewTimer.Enabled := False;
        ShowWindow(FFrame.Handle, SW_HIDE);
        end;
   	  Result := 0;
      Exit;
      end;
    end;

	// INIT AVI USING FIRST FRAME
	AVIFileInit;
	// Open the movie file for writing....
  if FileExists(TempVideoFile) then
    DeleteFile(TempVideoFile);

	hr := AVIFileOpen(pfile, pchar(TempVideoFile), OF_WRITE or OF_CREATE, nil);
	if (hr <> AVIERR_OK) then begin
    if Assigned(FOnError) then FOnError(Self, 'Error on create AVI file.');
    goto Error;
    end;

	// Fill in the header for the video stream....
	// The video stream will run in 15ths of a second....
  FillChar(strhdr, SizeOf(strhdr), 0);
	strhdr.fccType               := streamtypeVIDEO;// stream type
	strhdr.fccHandler            := 0;
	strhdr.dwScale               := 1;              // no time scaling
	strhdr.dwRate                := FPlaybackFPS;   // set playback rate in fps
	strhdr.dwFlags	             := AVICOMPRESSF_VALID or AVICOMPRESSF_KEYFRAMES;  // flags
	strhdr.dwSuggestedBufferSize := alpbi^.biSizeImage;
	SetRect(strhdr.rcFrame,                         // rectangle for stream
          0,
          0,
	        alpbi^.biWidth,
	        alpbi^.biHeight);

	// And create the stream;
	hr := AVIFileCreateStream(pfile,	ps, @strhdr); // returns ps as uncompressed stream pointer
	if (hr <> AVIERR_OK) then	begin
    if Assigned(FOnError) then FOnError(Self, 'Error on create AVI stream.');
    goto Error;
    end;

  fillchar(opts, sizeof(opts), 0);
  longword(Option)           := longword(@opts);      
	Option^.fccType	           := streamtypeVIDEO;        // Stream type
	Option^.fccHandler         := CompfccHandler;         // Selected video codec
	Option^.dwKeyFrameEvery	   := FKeyFramesEvery;        // Keyframe rate
	Option^.dwQuality          := FCompressionQuality;    // Compress quality 0-10,000
	Option^.dwBytesPerSecond   := 0; 	                    // Bytes per second
	Option^.dwFlags	           := AVICOMPRESSF_VALID or
                                AVICOMPRESSF_KEYFRAMES; // flags
	Option^.lpFormat           := $00;                    // Save format
	Option^.cbFormat           := 0;
	Option^.dwInterleaveEvery  := 0;	                    // For non-video streams only

	hr := AVIMakeCompressedStream(psCompressed, ps, @opts, nil);  // Compress ps stream to psCompressed
	if (hr <> AVIERR_OK) then	begin
    if Assigned(FOnError) then FOnError(Self, 'Error on compress AVI stream.');
    goto Error;
    end;

	hr := AVIStreamSetFormat(psCompressed, 0,
    	                     alpbi,	           // Stream format      (this is the first frame!)
			                     alpbi^.biSize +   // Format size
			                     alpbi^.biClrUsed * sizeof(RGBQUAD));
	if (hr <> AVIERR_OK) then begin
    if Assigned(FOnError) then FOnError(Self, 'Error on set AVI stream format.');
    goto Error;
    end;
 	FreeFrame(alpbi);
	alpbi := nil;

  SleepDivider := FmspFRecord div 10;
  if SleepDivider = 0 then SleepDivider := 1;

	// WRITING FRAMES
	DivX := 0;
	OldSec := 0;

  OldFrametime := 0;
  OldUpdateTime := 0;
	OldComputedFrameNo := 0;
  FActualFrameNo := 0;
  fActualmspF := 0;
	InitialTime := TimeGetTime;
  FSkippedFrames := 0;

  if Assigned(FOnStart) then FOnStart(Self); // Notify to start record

  if not FTimer.Enabled then  // Elapsed time
    FTimer.Enabled := True;

  if FAudioRecord then begin  // Start audio recording
    StockAudioRecorder.PCMFormat := TPCMFormat(FAudioFormatsDefaultItemIndex + 1);
    StockAudioRecorder.Async := True;
    if FileExists(TempAudioFile) then
      DeleteFile(TempAudioFile);
    StockAudioRecorder.RecordToFile(TempAudioFile);
    end;

  // ===============  recording loop =====================================================
	while (RecordState) do begin //repeatedly loop
    TimeExpended := TimeGetTime - InitialTime; // timeexpended = verstrichene Zeit seit Video-Beginn in ms

    if FAutoPan then begin
      FRegion.Left := FCursorPos.CursorPos.X - (FRegion.Width div 2);
      FRegion.Top := FCursorPos.CursorPos.Y - (FRegion.Height div 2);
      alpbi := CaptureScreenFrame(FRegion.Left, FRegion.Top, FRegion.Width, FRegion.Height, FFilterCopy);
      end
    else
      alpbi := CaptureScreenFrame(FRegion.Left, FRegion.Top, FRegion.Width, FRegion.Height, FFilterCopy);

    FComputedFrameNo := Round(TimeExpended / FmspFRecord); // loop duty - time syncronous

    if (FComputedFrameNo - OldComputedFrameNo) > 1 then
      Inc(FSkippedFrames, FComputedFrameNo - OldComputedFrameNo - 1);

		if (FComputedFrameNo = 0) or (FComputedFrameNo > OldComputedFrameNo) then // (video start) or (new loop=(keyframe) necessary) ?
    begin
			//if frameno repeats...the avistreamwrite will cause an error
			hr := AVIStreamWrite(psCompressed,            // stream pointer
      				             FComputedFrameNo,	      // number this frame
				                   1,			         	        // number to write
				                   PBYTE(longword(alpbi) +	// pointer to data
					                 alpbi^.biSize +
					                 alpbi^.biClrUsed * sizeof(RGBQUAD)),
					                 alpbi^.biSizeImage,	    // size of this frame
				                   //AVIIF_KEYFRAME,		  	  // flags....
				                   0,                       //Dependent n previous frame, not key frame
				                   nil,
				                   nil);
			if (hr <> AVIERR_OK) then begin
        if Assigned(FOnError) then FOnError(Self, 'Error on write data to AVI stream.');
        Break;
        end;

			Inc(FActualFrameNo); // just a counter
  		fActualmspF := (TimeExpended - OldFrameTime);
      OldFrameTime := TimeExpended;
      OldComputedFrameNo := FComputedFrameNo;

			//free memory
			FreeFrame(alpbi);
			alpbi := nil;
		end;

    //Update record stats every half a second
    if (TimeExpended > OldUpdateTime + 250) then begin
      OldUpdateTime := TimeExpended;
      if Assigned(FOnUpdate) then
        FOnUpdate(Self); // user event for current status
      end;

    SavingTime := ((TimeGetTime - InitialTime) - TimeExpended); // = time for saving frame
    if SavingTime >= FmspFRecord then begin // saving took to much time => hurry up / notice user!!!
      //------------
      end
    else begin // ok, we have to wait.....
  		//introduce time lapse  ( for creating long time movies, e.g. every hour one shot )
      no_iteration := (FmspFRecord - SavingTime) div SleepDivider;  // number of sleepdivider lapses
      RemainTime := (FmspFRecord - SavingTime) - no_iteration * SleepDivider;  // rest of Integer DIV
      for j := 0 to no_iteration - 1 do begin     // loop the lapses
        Sleep(SleepDivider); //Sleep for sleepdivider milliseconds many times
        if (RecordState = False) then Break;
        end;
      if (RecordState = True) then Sleep(RemainTime);
      end;

    FRestor := FRestore;
    FLRC := FLineRectClear;
	end;
  // ===============  recording loop ends =====================================================

  if Assigned(FOnStop) then FOnStop(Self);

Error:

  if FTimer.Enabled then
    FTimer.Enabled := False;

  if Assigned(Option) then
    AVISaveOptionsFree(1, Option);

	if Assigned(ps) then
    AVIStreamRelease(ps);

  if Assigned(psCompressed) then
    AVIStreamRelease(psCompressed);

	if Assigned(pfile) then
    AVIFileRelease(pfile);

  if FAudioRecord and StockAudioRecorder.Active then begin
    StockAudioRecorder.Active := False;
    StockAudioRecorder.Stop;
    end;

  if (hr = AVIERR_OK) and (FSuccess = Success) then begin

    TempCompressed[0] := nil;
    TempCompressed[1] := nil;
    TempOption := nil;

    TempCompressed[0] := LoadAVIFileToStream(TempVideoFile);
    if FAudioRecord then
      TempCompressed[1] := LoadAVIFileToStream(TempAudioFile);

    if Assigned(TempCompressed[1]) then N := 2 else N := 1;

    if FRecompressAVIAfterCapture then begin
      FillChar(opts, SizeOf(opts), 0);
      LongWord(TempOption)           := LongWord(@opts);
    	TempOption^.fccType	           := streamtypeVIDEO;
	    TempOption^.fccHandler         := CompfccHandler;
     	TempOption^.dwKeyFrameEvery	   := FKeyFramesEvery;      // keyframe rate
	    TempOption^.dwQuality          := FCompressionQuality;  // compress quality 0-10,000
	    TempOption^.dwBytesPerSecond   := 0; 	                  // bytes per second
	    TempOption^.dwFlags	           := AVICOMPRESSF_VALID or AVICOMPRESSF_KEYFRAMES;  // flags
	    TempOption^.lpFormat           := $00;                  // save format
	    TempOption^.cbFormat           := 0;
	    TempOption^.dwInterleaveEvery  := 0;	                  // for non-video streams only

      if Assigned(TempCompressed[0]) or Assigned(TempCompressed[1]) then
        FinalSaveAvi(szFileName, N, TempCompressed, @opts);
      end
    else begin
      if Assigned(TempCompressed[0]) or Assigned(TempCompressed[1]) then
        FinalSaveAvi(szFileName, N, TempCompressed, nil);
      end;

    if Assigned(TempOption) then
      AVISaveOptionsFree(1, TempOption);
    end;

	AVIFileExit;

  if FileExists(TempVideoFile) then
    DeleteFile(TempVideoFile);
  if FileExists(TempAudioFile) then
    DeleteFile(TempAudioFile);

	if (hr <> AVIERR_OK) then begin
 		if (CompfccHandler <> mmioFOURCC('M', 'S', 'V', 'C'))	then begin
			if (IDYES = MessageBox(Application.MainForm.Handle, 'Error: Not recording AVI file using current compressor.' + #13#10 +
                                'Use default compressor? ', 'Notice',
                                MB_YESNO or MB_ICONEXCLAMATION)) then begin
				CompfccHandler := mmioFOURCC('M', 'S', 'V', 'C');
				StrCodec := 'Microsoft Video Codec';
        // indicate to restart recording...
        Result := -1;
			  end
      else begin
       if Assigned(FOnError) then FOnError(Self, 'User aborted!');
       RecordState := False;
       if not FShowPreview then begin
          FPreviewTimer.Enabled := False;
          ShowWindow(FFrame.Handle, SW_HIDE);
          end;
        Result := 0;
        end;
		  end
    else begin
      if Assigned(FOnError) then FOnError(Self, 'Error creating AVI file with microsoft video codec.');
      RecordState := False;
      if not FShowPreview then begin
        FPreviewTimer.Enabled := False;
        ShowWindow(FFrame.Handle, SW_HIDE);
        end;
      Result := 0;
      end;
    Exit;
    end;

	//Save the file on success
  Result := 1;
end;

procedure TScreenCamera.StopRecording;
begin
  FSuccess := Success;
  RecordState := False;
  if not FShowPreview then
    SetShowPreview(False)
  else
    SetShowPreview(True);
end;

function TScreenCamera.StartRecording(szFileName: string): Boolean;
begin
  if RecordState then Exit; // exit if still recording

  FFileName := szFileName;

  FRestor := FRestore;

  if FMinimize then
    Application.Minimize;

  Sec := 0;
  Min := 0;
  Hur := 0;

  FPreviewTimer.Enabled := True;

  case FScreenRegion of
    FreeHand:    begin
                   FFreeHandMode := True;
                   FAutoPan := False;
                   FFullScreen := False;
                 end;
    FixedMoving: begin
                   FFreeHandMode := False;
                   FAutoPan := True;
                   FFullScreen := False;
                 end;
    FixedStable: begin
                   FFreeHandMode := False;
                   FAutoPan := False;
                   FFullScreen := False;
                 end;
    FullScreen:  begin
                   FFreeHandMode := False;
                   FAutoPan := False;
                   FFullScreen := True;
                 end;
  end;

  if FFreeHandMode then begin
    StartRegionSel := True;
    Exit; // exit if region selecting
    end;

  StartRegionSel := False;

  if FFullScreen then begin
    FRegion.Left := 0;
    FRegion.Top := 0;
    FRegion.Width := Screen.Width;
    FRegion.Height := Screen.Height;
    end;

  FRecordAVIThread := TRecordAVIThread.Create(Self);
  FRecordAVIThread.OnTerminate := ThreadDone;

  RecordState := True;
end;

// message from thread informing that it is done
procedure TScreenCamera.ThreadDone(Sender: TObject);
begin
  RecordState := False;
  FRecordAVIThread := nil;
end;

var
  SC: TScreenCamera;

function SaveCallBack(nPercent: Integer): LONG; stdcall;
var
  Continue: Boolean;
begin
  Result := 0;
  if Assigned(SC.OnSaving) then begin
    Continue := True;
    SC.OnSaving(SC, nPercent, Continue);
    if not Continue then
      Result := -1;
  end;
end;

procedure TScreenCamera.FinalSaveAvi(const FileName: string; nStreams: Integer;
              Streams: APAVISTREAM; CompressOptions: PAVICOMPRESSOPTIONS);
var
  AVIERR: Cardinal;
  ErrMess: string;
  StreamCompressed: PAVISTREAM;
  ACompressOptions: APAVICOMPRESSOPTIONS;
  Variable: Boolean;
begin
  Variable := True;
  ACompressOptions[0] := nil;
  ACompressOptions[1] := nil;

  SC := Self; //for callback
  AVIERR := AVIERR_OK;

  if Assigned(CompressOptions) then begin
    AVIERR := AVIMakeCompressedStream(StreamCompressed, Streams[0], CompressOptions, nil);
    Streams[0] := StreamCompressed;
    end;

	if (AVIERR = AVIERR_OK) then begin

    if FileExists(FileName) then
      DeleteFile(FileName);

    AVIERR := AVISaveV(PChar(FileName),  // File name
                       nil,              // File handler
                       SaveCallBack,     // Callback
                       nStreams,         // Number of streams
                       Streams,          // Audio/Video streams
                       ACompressOptions); // Compress options for Streams

    if Assigned(FOnSaving) then
      FOnSaving(Self, 100, Variable);

    case AVIERR of
      AVIERR_OK:
            begin
              ErrMess := '';
              MessageBox(Application.MainForm.Handle, 'Avi sucessfully created!', 'Information', MB_OK);
            end;
      AVIERR_UNSUPPORTED:
          ErrMess := 'Error, unsupported format!';
      AVIERR_BADFORMAT:
          ErrMess := 'Error, bad format!';
      AVIERR_FILEREAD:
          ErrMess := 'Error reading files!';
      AVIERR_FILEWRITE:
          ErrMess := 'Error writing files!';
      AVIERR_MEMORY:
          ErrMess := 'Error in memory!';
      AVIERR_INTERNAL:
          ErrMess := 'Error internal!';
      AVIERR_BADFLAGS:
          ErrMess := 'Error bad flags!';
      AVIERR_BADPARAM:
          ErrMess := 'Error bad params!';
      AVIERR_BADSIZE:
          ErrMess := 'Error bad size!';
      AVIERR_BADHANDLE:
          ErrMess := 'Error bad handle!';
      AVIERR_FILEOPEN:
          ErrMess := 'Error opening files!';
      AVIERR_COMPRESSOR:
          ErrMess := 'Error in compressor!';
      AVIERR_NOCOMPRESSOR:
          ErrMess := 'Error no compressor!';
      AVIERR_READONLY:
          ErrMess := 'Error read-only files!';
      AVIERR_NODATA:
          ErrMess := 'Error no data!';
      AVIERR_BUFFERTOOSMALL:
          ErrMess := 'Error buffer too small!';
      AVIERR_CANTCOMPRESS:
          ErrMess := 'Error cannot compress!';
      AVIERR_USERABORT:
          ErrMess := 'Error user abort!';
      AVIERR_ERROR:
          ErrMess := 'Error generic!';
      else
        ErrMess := 'Avi error number: ' + IntToStr(AVIERR);
      end;
    if ErrMess <> '' then
      if Assigned(FOnError) then FOnError(Self, ErrMess);
    end
  else begin
    if Assigned(FOnError) then FOnError(Self, 'Unable to recompress AVI file');
    end;
end;

function TScreenCamera.LoadAVIFileToStream(const FileName: string): PAVIStream;
var
   InputFile           : PAVIFILE;
   hr                  : integer;
   InputStream         : PAVIStream;
   avisClip            : TAVISTREAMINFO;
   l, selstart         : DWORD;
   pastecode           : integer;
begin
   // Open the audio file.
   Result := nil;
   if FileExists(FileName) then begin
     hr := AVIFileOpen(InputFile, PChar(FileName), OF_READ, nil);
     case hr of
        0: ;
        AVIERR_BADFORMAT  : raise Exception.Create('The file could not be read, indicating a corrupt file or an unrecognized format.');
        AVIERR_MEMORY     : raise Exception.Create('The file could not be opened because of insufficient memory.');
        AVIERR_FILEREAD   : raise Exception.Create('A disk error occurred while reading the AVI file.');
        AVIERR_FILEOPEN   : raise Exception.Create('A disk error occurred while opening the AVI file.');
        REGDB_E_CLASSNOTREG : raise Exception.Create('According to the registry, the type of AVI file specified in AVIFileOpen does not have a handler to process it.');
        else raise Exception.Create('Unknown error opening AVI file');
     end;

     // Open the AVI stream.
     try
       if (AVIFileGetStream(InputFile, InputStream, 0, 0) <> AVIERR_OK) then
         raise Exception.Create('Unable to get AVI stream');
       try
         // Create output AVI Stream as a copy of InputStream
         if (CreateEditableStream(Result, InputStream) <> AVIERR_OK) then
           raise Exception.Create('Failed to create editable AVI file stream');
       finally
         AviStreamRelease(InputStream);
         end;
     finally
         AviFileRelease(InputFile);
       end;
     end;
end;

// --------------------------------------------------------------------------
//    TRecordAVI Thread
// --------------------------------------------------------------------------

constructor TRecordAVIThread.Create(ScrCam: TScreenCamera);
begin
  FScrCam := ScrCam;
  FreeOnTerminate := True;
  inherited Create(False);
end;


{ The Execute method is called when the thread starts }
procedure TRecordAVIThread.Execute;
var
  Res: Integer;
begin
  repeat
    Res := FScrCam.RecordVideo(FFileName);
  until not (Res = -1);

  if (FSuccess = Fail) then begin
    if FileExists(FFileName) then
      DeleteFile(FFileName);
    if FileExists(TempVideoFile) then
      DeleteFile(TempVideoFile);
    if FileExists(TempAudioFile) then
      DeleteFile(TempAudioFile);
    end;

  if FRestor then
    Application.Restore;
end;

end.

