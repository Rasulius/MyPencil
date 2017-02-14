unit OptDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Unit1, Math;

type
  TfrmOption = class(TForm)
    Compressor: TGroupBox;
    VideoCompressor: TComboBox;
    AboutB: TButton;
    VideoQuality: TTrackBar;
    Label1: TLabel;
    LabelQuality: TLabel;
    GroupBox1: TGroupBox;
    ConfigB: TButton;
    Button2: TButton;
    Button3: TButton;
    EditKeyFrames: TEdit;
    Label3: TLabel;
    Label2: TLabel;
    TrackBarRecord: TTrackBar;
    Label4: TLabel;
    Label6: TLabel;
    labelmspFrecord: TLabel;
    AudioFormat: TComboBox;
    Label8: TLabel;
    Label9: TLabel;
    AudioVolume: TTrackBar;
    Label10: TLabel;
    AudioInput: TComboBox;
    Label11: TLabel;
    LabelVolume: TLabel;
    Label12: TLabel;
    TrackBarPlayback: TTrackBar;
    Label7: TLabel;
    labelFPSPlayback: TLabel;
    Label5: TLabel;
    Label13: TLabel;
    AutoMode: TCheckBox;
    AudioRecord: TCheckBox;
    procedure AboutBClick(Sender: TObject);
    procedure ConfigBClick(Sender: TObject);
    procedure TrackBarPlaybackChange(Sender: TObject);
    procedure VideoQualityChange(Sender: TObject);
    procedure AudioVolumeChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure AudioInputClick(Sender: TObject);
    procedure TrackBarRecordChange(Sender: TObject);
    procedure AutoModeClick(Sender: TObject);
    procedure AudioRecordClick(Sender: TObject);
    procedure VideoCompressorClick(Sender: TObject);
  private
    { Private declarations }
    procedure RefreshCompressorButtons;
    procedure UpdateAdjustSliderVal;
  public
    { Public declarations }
    Auto: Boolean;
  end;

var
  frmOption: TfrmOption;

implementation

{$R *.dfm}

procedure TfrmOption.AboutBClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := VideoCompressor.ItemIndex;
  ScrCam.CompressorAbout(Idx, WindowHandle);
end;

procedure TfrmOption.ConfigBClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := VideoCompressor.ItemIndex;
  ScrCam.CompressorConfigure(Idx, WindowHandle);
end;

procedure TfrmOption.RefreshCompressorButtons;
var
  Idx: Integer;
  About, Config: Boolean;
begin
  Idx := VideoCompressor.ItemIndex;
  ScrCam.CompressorHasFeatures(Idx, About, Config);
  AboutB.Enabled := About;
  ConfigB.Enabled := Config;
  VideoQuality.Enabled := VideoCompressor.ItemIndex > -1;
  Label1.Enabled := VideoCompressor.ItemIndex > -1;
  LabelQuality.Enabled := VideoCompressor.ItemIndex > -1;
end;


procedure TfrmOption.UpdateAdjustSliderVal;
var
  LmspFRecord, LFPSPlayback : Integer;
begin
  LmspFRecord := TrackBarRecord.Position;
  LFPSPlayback := TrackBarPlayback.Position;
  LabelmspfRecord.Caption := Format('%d Milisecond', [LmspFRecord]);
  LabelFPSPlayback.Caption := Format('%d fps', [LFPSPlayback]);
  LabelQuality.Caption := IntToStr(VideoQuality.Position);
  LabelVolume.Caption := IntToStr(AudioVolume.Position);

  ScrCam.SetAudioInputVolume(AudioInput.ItemIndex, AudioVolume.Position);
end;


procedure TfrmOption.TrackBarPlaybackChange(Sender: TObject);
begin
  if (Sender = TrackBarPlayback) and (AutoMode.Checked) then
    TrackBarRecord.Position := 1000 div TrackBarPlayback.Position;
  UpdateAdjustSliderVal;
end;

procedure TfrmOption.VideoQualityChange(Sender: TObject);
begin
  UpdateAdjustSliderVal;
end;

procedure TfrmOption.AudioVolumeChange(Sender: TObject);
begin
  UpdateAdjustSliderVal;
end;

procedure TfrmOption.Button2Click(Sender: TObject);
begin
  UpdateAdjustSliderVal;
  ScrCam.SelectedCompressor := VideoCompressor.ItemIndex;
  ScrCam.CompressionQuality := VideoQuality.Position * 100;
  ScrCam.KeyFramesEvery := StrToInt(EditKeyFrames.Text);
  ScrCam.msPFRecord := TrackBarRecord.Position;
  ScrCam.FPSPlayback := TrackBarPlayback.Position;
  ScrCam.UseAudioRecord := AudioRecord.Checked;
  ScrCam.AudioFormatsDefaultItemIndex := AudioFormat.ItemIndex;
end;

procedure TfrmOption.FormShow(Sender: TObject);
begin
  VideoCompressor.Items.Assign(ScrCam.VideoCodecsList);
  AudioFormat.Items.Assign(ScrCam.AudioFormatsList);
  AudioInput.Items.Assign(ScrCam.GetAudioInputInfo.AudioInputNames);

  VideoCompressor.ItemIndex := ScrCam.SelectedCompressor;
  AudioFormat.ItemIndex := ScrCam.AudioFormatsDefaultItemIndex;
  AudioInput.ItemIndex := ScrCam.GetAudioInputInfo.AudioInputIndex;

  if ScrCam.GetAudioInputInfo.AudioInputEnabled then begin
    if AudioRecord.Checked then begin
      AudioVolume.Enabled := True;
      LabelVolume.Enabled := True;
      end;
    AudioVolume.Position := ScrCam.GetAudioInputInfo.AudioInputVolume;
    end
  else begin
    AudioVolume.Position := 0;
    AudioVolume.Enabled := False;
    LabelVolume.Enabled := False;
    end;

  TrackBarRecord.Position := ScrCam.mspFRecord;
  TrackBarPlayback.Position := ScrCam.FPSPlayback;

  EditKeyFrames.Text := Format('%d', [ScrCam.KeyFramesEvery]);
  VideoQuality.Position := ScrCam.CompressionQuality div 100;

  RefreshCompressorButtons;
end;

procedure TfrmOption.Button3Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmOption.AudioInputClick(Sender: TObject);
begin
  ScrCam.SetAudioInputIndex(AudioInput.ItemIndex);
  if ScrCam.GetAudioInputInfo.AudioInputEnabled then begin
    AudioVolume.Enabled := True;
    LabelVolume.Enabled := True;
    AudioVolume.Position := ScrCam.GetAudioInputInfo.AudioInputVolume;
    end
  else begin
    AudioVolume.Position := 0;
    AudioVolume.Enabled := False;
    LabelVolume.Enabled := False;
    end;
end;

procedure TfrmOption.TrackBarRecordChange(Sender: TObject);
begin
  if (Sender = TrackBarRecord) and (AutoMode.Checked) then
    TrackBarPlayback.Position := 1000 div TrackBarRecord.Position;
  UpdateAdjustSliderVal;
end;

procedure TfrmOption.AutoModeClick(Sender: TObject);
begin
  if AutoMode.Checked then
    TrackBarRecord.Position := 1000 div TrackBarPlayback.Position;
end;

procedure TfrmOption.AudioRecordClick(Sender: TObject);
begin
  if AudioRecord.Checked then begin
    Label9.Enabled := True;
    AudioFormat.Enabled := True;
    Label11.Enabled := True;
    AudioInput.Enabled := True;
    Label10.Enabled := True;
    if ScrCam.GetAudioInputInfo.AudioInputEnabled then begin
      AudioVolume.Enabled := True;
      LabelVolume.Enabled := True;
      AudioVolume.Position := ScrCam.GetAudioInputInfo.AudioInputVolume;
      end
    else begin
      AudioVolume.Enabled := False;
      LabelVolume.Enabled := False;
      AudioVolume.Position := 0;
      end;
    end
  else begin
    Label9.Enabled := False;
    AudioFormat.Enabled := False;
    Label11.Enabled := False;
    AudioInput.Enabled := False;
    Label10.Enabled := False;
    AudioVolume.Enabled := False;
    LabelVolume.Enabled := False;
    end;
end;

procedure TfrmOption.VideoCompressorClick(Sender: TObject);
begin
	RefreshCompressorButtons;
end;

end.
