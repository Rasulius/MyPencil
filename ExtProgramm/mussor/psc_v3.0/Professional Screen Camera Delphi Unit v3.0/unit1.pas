unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScrCam, FlashWnd, ExtCtrls, ComCtrls, XPMan;

{$WARNINGS OFF}
{$HINTS OFF}
{$RANGECHECKS OFF}

type
  TfrmMain = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Label1: TLabel;
    CheckBox1: TCheckBox;
    CheckBox3: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Bevel1: TBevel;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox8: TCheckBox;
    GroupBox1: TGroupBox;
    Edit5: TEdit;
    UpDown1: TUpDown;
    UpDown2: TUpDown;
    Edit6: TEdit;
    UpDown3: TUpDown;
    Edit7: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    CheckBox9: TCheckBox;
    RadioGroup1: TRadioGroup;
    Button5: TButton;
    Panel1: TPanel;
    Image1: TImage;
    Label9: TLabel;
    ComboBox1: TComboBox;
    Label10: TLabel;
    ComboBox2: TComboBox;
    Label11: TLabel;
    XPManifest1: TXPManifest;
    Edit8: TEdit;
    Label12: TLabel;
    CheckBox2: TCheckBox;
    Panel2: TPanel;
    Progress: TProgressBar;
    BCancel: TButton;
    LStatus: TLabel;
    UpDownTop: TUpDown;
    UpDownLeft: TUpDown;
    UpDownWidth: TUpDown;
    UpDownHeight: TUpDown;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure Button4Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure CheckBox5Click(Sender: TObject);
    procedure CheckBox6Click(Sender: TObject);
    procedure CheckBox8Click(Sender: TObject);
    procedure CheckBox9Click(Sender: TObject);
    procedure Edit5Change(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure BCancelClick(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    procedure Error(Sender: TObject; ErrorMessage: string);
    procedure UpdateForm(Sender : TObject);
    procedure Start(Sender: TObject);
    procedure Stop(Sender: TObject);
    procedure Preview(Sender: TObject;
           PreviewBitmap: TBitmap; Active: Boolean; Recording: Boolean);
    procedure Saving(Sender: TObject; Percent: Integer; var Continue: Boolean);
  public
    { Public declarations }
    Region: TRegion;
    TimerON: TTimerRecord;
    FCancel: Boolean;
  end;

var
  frmMain: TfrmMain;
  ScrCam: TScreenCamera;

implementation

uses OptDlg;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FCancel := False;
  ScrCam := TScreenCamera.Create(Self);
  ScrCam.OnError := Error;
  ScrCam.OnUpdate := UpdateForm;
  ScrCam.OnStart := Start;
  ScrCam.OnStop := Stop;
  ScrCam.OnPreview := Preview;
  ScrCam.OnSaving := Saving;
end;

procedure TfrmMain.Error(Sender: TObject; ErrorMessage: string);
begin
  // This where user can show error messages
end;

procedure TfrmMain.UpdateForm(Sender: TObject);
begin
  Label1.Caption := 'Information :' + #13#10 +
                    Format('Used Codec: %s', [ScrCam.CurrentVideoCodecName]) + #13#10 +
                    Format('Elapsed Time: %s', [ScrCam.ElapsedTime]) + #13#10 +
                    Format('Frame/S: %f', [ScrCam.Avragefps / 10]) + #13#10 +
                    Format('Frames Captured: %d', [ScrCam.FramesCaptured]) + #13#10 +
                    Format('Droped Frames: %d', [ScrCam.DropedFrames]);
end;

procedure TfrmMain.Start(Sender: TObject);
begin
  Button2.Enabled := True;
end;

procedure TfrmMain.Stop(Sender: TObject);
begin
  Button2.Enabled := False;
end;

procedure TfrmMain.Preview(Sender: TObject;
          PreviewBitmap: TBitmap; Active: Boolean; Recording: Boolean);
begin
  if Active then begin
    CheckBox8.Checked := True;
    if not Recording then begin
      Label9.Caption := 'Preview... Cancel: Esc';
      end
    else begin
      Label9.Caption := 'Start Recording... Cancel: Esc --- End: Shift+Esc';
      end;
    end
  else begin
    if not Recording then
      Label9.Caption := 'Preview Off...'
    else
      Label9.Caption := 'Start Recording... Cancel: Esc --- End: Shift+Esc';
    CheckBox8.Checked := False;
    end;
  Image1.Picture.Assign(PreviewBitmap);
end;

procedure TfrmMain.Saving(Sender: TObject; Percent: Integer; var Continue: Boolean);
begin
  Application.ProcessMessages;

  if not FCancel then begin

    if not BCancel.Enabled then begin
      BCancel.Enabled := True;
      LStatus.Enabled := True;
      LStatus.Caption := 'Saving...';
      end;

    Progress.Position := Percent;

    if Percent = 100 then begin
      FCancel := False;
      LStatus.Enabled := False;
      BCancel.Enabled := False;
      LStatus.Caption := 'No Status';
      Progress.Position := 0;
      end;

    Continue := True;
    end
  else begin
    FCancel := False;
    LStatus.Enabled := False;
    BCancel.Enabled := False;
    LStatus.Caption := 'No Status';
    Progress.Position := 0;
    Continue := False;
    end;
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
  ScrCam.StopRecording;
end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  RadioGroup1Click(Sender);
  if Edit8.Text <> '' then
    ScrCam.StartRecording(Edit8.Text);
end;

procedure TfrmMain.Button3Click(Sender: TObject);
begin
  frmOption.ShowModal;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  ScrCam.Destroy;
end;

procedure TfrmMain.Button4Click(Sender: TObject);
begin
  MessageBox(Handle, 'Professional Screen Camera By MRH Software Co.', 'About', MB_OK);
end;

procedure TfrmMain.CheckBox1Click(Sender: TObject);
begin
  ScrCam.RecordCursor := CheckBox1.Checked;
end;

procedure TfrmMain.CheckBox3Click(Sender: TObject);
begin
  ScrCam.DrawAreaCapture := CheckBox3.Checked;
end;                              

procedure TfrmMain.CheckBox4Click(Sender: TObject);
begin
  ScrCam.LineRectClear := CheckBox4.Checked;
end;

procedure TfrmMain.CheckBox5Click(Sender: TObject);
begin
  ScrCam.MinimizeAppOnStart := CheckBox5.Checked;
end;

procedure TfrmMain.CheckBox6Click(Sender: TObject);
begin
  ScrCam.RestoreAppAfterRecord := CheckBox6.Checked;
end;

procedure TfrmMain.CheckBox8Click(Sender: TObject);
begin
  RadioGroup1Click(Sender);
  ScrCam.ShowPreview := CheckBox8.Checked;
end;

procedure TfrmMain.CheckBox9Click(Sender: TObject);
begin
  TimerON.TimerON := CheckBox9.Checked;
  TimerON.Hour := StrToInt(Edit5.Text);
  TimerON.Min := StrToInt(Edit6.Text);
  TimerON.Sec := StrToInt(Edit7.Text);
  ScrCam.SetTimer := TimerON;
  if CheckBox9.Checked then begin
    Edit5.Enabled := True;
    UpDown1.Enabled := True;
    Edit6.Enabled := True;
    UpDown2.Enabled := True;
    Edit7.Enabled := True;
    UpDown3.Enabled := True;
    end
  else begin
    Edit5.Enabled := False;
    UpDown1.Enabled := False;
    Edit6.Enabled := False;
    UpDown2.Enabled := False;
    Edit7.Enabled := False;
    UpDown3.Enabled := False;
    end;
end;

procedure TfrmMain.Edit5Change(Sender: TObject);
begin
  TimerON.TimerON := CheckBox9.Checked;
  TimerON.Hour := StrToInt(Edit5.Text);
  TimerON.Min := StrToInt(Edit6.Text);
  TimerON.Sec := StrToInt(Edit7.Text);
  ScrCam.SetTimer := TimerON;
end;

procedure TfrmMain.RadioGroup1Click(Sender: TObject);
begin
  ScrCam.Priority := ComboBox1.ItemIndex;
  ScrCam.FilterColor := ComboBox2.ItemIndex;

  ScrCam.RecordCursor := CheckBox1.Checked;
  ScrCam.RecompressAVIAfterRecord := CheckBox2.Checked;
  ScrCam.DrawAreaCapture := CheckBox3.Checked;
  ScrCam.LineRectClear := CheckBox4.Checked;
  ScrCam.MinimizeAppOnStart := CheckBox5.Checked;
  ScrCam.RestoreAppAfterRecord := CheckBox6.Checked;
  ScrCam.ShowPreview := CheckBox8.Checked;

  TimerON.TimerON := CheckBox9.Checked;
  TimerON.Hour := StrToInt(Edit5.Text);
  TimerON.Min := StrToInt(Edit6.Text);
  TimerON.Sec := StrToInt(Edit7.Text);
  ScrCam.SetTimer := TimerON;

  case RadioGroup1.ItemIndex of
    0: begin
         Edit1.Enabled := False;
         Edit2.Enabled := False;
         Edit3.Enabled := False;
         Edit4.Enabled := False;

         CheckBox3.Enabled := True;
         CheckBox4.Enabled := True;

         ScrCam.ScreenRegion := FreeHand;
       end;
    1: begin
         Edit1.Enabled := False;
         Edit2.Enabled := False;
         Edit3.Enabled := True;
         Edit4.Enabled := True;

         CheckBox3.Enabled := True;
         CheckBox4.Enabled := True;

         Region.Left := StrToInt(Edit1.Text);
         Region.Top := StrToInt(Edit2.Text);
         Region.Width := StrToInt(Edit3.Text);
         Region.Height := StrToInt(Edit4.Text);
         ScrCam.Region := Region;

         ScrCam.ScreenRegion := FixedMoving;
       end;
    2: begin
         Edit1.Enabled := True;
         Edit2.Enabled := True;
         Edit3.Enabled := True;
         Edit4.Enabled := True;

         CheckBox3.Enabled := True;
         CheckBox4.Enabled := True;

         Region.Left := StrToInt(Edit1.Text);
         Region.Top := StrToInt(Edit2.Text);
         Region.Width := StrToInt(Edit3.Text);
         Region.Height := StrToInt(Edit4.Text);
         ScrCam.Region := Region;

         ScrCam.ScreenRegion := FixedStable;
       end;
    3: begin
         Edit1.Enabled := False;
         Edit2.Enabled := False;
         Edit3.Enabled := False;
         Edit4.Enabled := False;

         CheckBox3.Enabled := False;
         CheckBox4.Enabled := False;

         ScrCam.ScreenRegion := FullScreen;
       end;
  end;
  UpDownTop.Enabled := Edit1.Enabled;
  UpDownLeft.Enabled := Edit2.Enabled;
  UpDownWidth.Enabled := Edit3.Enabled;
  UpDownHeight.Enabled := Edit4.Enabled;
end;

procedure TfrmMain.Button5Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.ComboBox1Change(Sender: TObject);
begin
  ScrCam.Priority := ComboBox1.ItemIndex;
end;

procedure TfrmMain.ComboBox2Change(Sender: TObject);
begin
  ScrCam.FilterColor := ComboBox2.ItemIndex;
end;

procedure TfrmMain.CheckBox2Click(Sender: TObject);
begin
  ScrCam.RecompressAVIAfterRecord := CheckBox2.Checked;
end;

procedure TfrmMain.BCancelClick(Sender: TObject);
begin
  FCancel := True;
end;

procedure TfrmMain.Edit1Change(Sender: TObject);
begin
  if TEdit(Sender).Text = '' then
    TEdit(Sender).Text := '0';

  if StrToInt(Edit1.Text) > UpDownTop.Max then
    Edit1.Text := IntToStr(UpDownTop.Max);
  if StrToInt(Edit2.Text) > UpDownLeft.Max then
    Edit2.Text := IntToStr(UpDownLeft.Max);
  if StrToInt(Edit3.Text) > UpDownWidth.Max then
    Edit3.Text := IntToStr(UpDownWidth.Max);
  if StrToInt(Edit4.Text) > UpDownHeight.Max then
    Edit4.Text := IntToStr(UpDownHeight.Max);

  Region.Left := StrToInt(Edit1.Text);
  Region.Top := StrToInt(Edit2.Text);
  Region.Width := StrToInt(Edit3.Text);
  Region.Height := StrToInt(Edit4.Text);

  ScrCam.Region := Region;
end;

procedure TfrmMain.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Sender is TEdit then
    begin
      if Key in [#8, '0'..'9'] then
         Exit;
      Key := #0;
    end;
end;

procedure TfrmMain.FormActivate(Sender: TObject);
begin
  UpDownTop.Max := Screen.Width;
  UpDownLeft.Max := Screen.Height;
  UpDownWidth.Max := Screen.Width;
  UpDownHeight.Max := Screen.Height;
end;

end.
