unit MainU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtDlgs, StdCtrls, ComCtrls, MPlayer, AviWriter_2, Spin,
  jpeg;

type
  TMainForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    ListBox1: TListBox;
    Button1: TButton;
    OpenPictureDialog1: TOpenPictureDialog;
    PopupMenu1: TPopupMenu;
    DeleteSelectedfromList1: TMenuItem;
    TabSheet2: TTabSheet;
    AviWriter: TAviWriter_2;
    MediaPlayer1: TMediaPlayer;
    OpenDialog1: TOpenDialog;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    TabSheet3: TTabSheet;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ComboBox1: TComboBox;
    Label6: TLabel;
    SpinEdit3: TSpinEdit;
    Label7: TLabel;
    ComboBox2: TComboBox;
    Label8: TLabel;
    Button3: TButton;
    TabSheet4: TTabSheet;
    Label9: TLabel;
    Button4: TButton;
    CheckBox1: TCheckBox;
    SaveDialog1: TSaveDialog;
    Button5: TButton;
    Button6: TButton;
    ProgressBar1: TProgressBar;
    Label10: TLabel;
    Label11: TLabel;
    Button8: TButton;
    TabSheet5: TTabSheet;
    Animate1: TAnimate;
    Button7: TButton;
    Button9: TButton;
    ComboBox3: TComboBox;
    Label12: TLabel;
    CheckBox2: TCheckBox;
    Label13: TLabel;
    procedure DeleteSelectedfromList1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure AviWriterProgress(Sender: TObject; FrameCount: integer;
      var abort: boolean);
    procedure Button6Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
  private
    { Private declarations }
    procedure UpdateCompressorList;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.DeleteSelectedfromList1Click(Sender: TObject);
begin
  ListBox1.DeleteSelected;
end;

procedure TMainForm.Button1Click(Sender: TObject);
var i: integer;
begin
  if not OpenPictureDialog1.Execute then
    exit;
  with OpenPictureDialog1 do
    for i := 0 to Files.Count - 1 do
      ListBox1.Items.add(Files.Strings[i]);
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  if not OpenDialog1.Execute then
    exit;
  Label9.Caption := OpenDialog1.filename;
  MediaPlayer1.Close;
  MediaPlayer1.filename := Label9.Caption;
  MediaPlayer1.open;
  MediaPlayer1.Timeformat := tfMilliseconds;
  Label2.Caption := IntToStr(round(1 / 1000 * MediaPlayer1.Length)) + ' sec';
end;

procedure TMainForm.ComboBox1Change(Sender: TObject);
begin
  case ComboBox1.ItemIndex of
    0: AviWriter.PixelFormat := pf1Bit;
    1: AviWriter.PixelFormat := pf4Bit;
    2: AviWriter.PixelFormat := pf8bit;
    3: AviWriter.PixelFormat := pf24bit;
    4: AviWriter.PixelFormat := pf32Bit;
  end;
  UpdateCompressorList;
end;

procedure TMainForm.UpdateCompressorList;
var Save: integer;
begin
  Save := ComboBox2.ItemIndex;
  AviWriter.Compressorlist(ComboBox2.Items);
  if (Save >= 0) and (Save < ComboBox2.Items.Count) then
    ComboBox2.ItemIndex := Save
  else
    ComboBox2.ItemIndex := 0;
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  if ComboBox2.ItemIndex > 0 then
    AviWriter.ShowCompressorDialog(Self);
end;

procedure TMainForm.ComboBox2Change(Sender: TObject);
begin
  if ComboBox2.ItemIndex > 0 then
    AviWriter.SetCompression(copy(ComboBox2.Items.Strings[ComboBox2.ItemIndex], 1, 4))
  else
    AviWriter.SetCompression('');
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  UpdateCompressorList;
end;

procedure TMainForm.Button4Click(Sender: TObject);
begin
  ListBox1.Clear;
end;

procedure TMainForm.Button5Click(Sender: TObject);
begin
  if not SaveDialog1.Execute then
    exit;
  AviWriter.filename := SaveDialog1.filename;
  AviWriter.TempFileName :=
    ExtractFilePath(AviWriter.filename) + '~AWTemp' + ExtractFileName(AviWriter.filename);
  Label10.Caption := ExtractFileName(AviWriter.filename);
end;

procedure TMainForm.AviWriterProgress(Sender: TObject; FrameCount: integer;
  var abort: boolean);
begin
  ProgressBar1.position := FrameCount;
end;

procedure TMainForm.Button6Click(Sender: TObject);
var i: integer;
  Pic: TPicture;
  bm: TBitmap;
begin
  if AviWriter.filename = '' then
  begin
    ShowMessage('Choose an output file name first');
    exit;
  end;
  if Listbox1.Items.count<=0 then
  begin
    ShowMessage('No images selected.');
    exit;
  end;
    
  if FileExists(AviWriter.filename) then
    if MessageDlg('File exists, overwrite?', mtWarning, [mbYes, mbNo], 0) = mrNo
      then
      exit;
  Animate1.Active := false;
  Animate1.filename := '';
  MediaPlayer1.Close; //for Share Violation
  with AviWriter do
  begin
    Width := SpinEdit1.value;
    Height := SpinEdit2.value;
    FrameTime := SpinEdit3.value;
    if Label9.Caption = 'None' then
      WavFileName := ''
    else
      WavFileName := Label9.Caption;
    Stretch := CheckBox1.checked;
    OnTheFlyCompression:=Checkbox2.checked;
  end;

  ProgressBar1.max := ListBox1.Items.Count;
  ProgressBar1.position := 0;
  Label11.Caption := '... Initializing Video';
  Label11.Refresh;
  AviWriter.InitVideo;

  Label11.Caption := '... Adding Video Frames';
  Label11.Refresh;
  for i := 0 to ListBox1.Items.Count - 1 do
  begin
    Pic := TPicture.Create;
    try
      Pic.loadfromfile(ListBox1.Items.Strings[i]);
      bm := TBitmap.Create;
      try
        bm.PixelFormat := AviWriter.PixelFormat;
        bm.Width := Pic.Width;
        bm.Height := Pic.Height;
        bm.Canvas.draw(0, 0, Pic.Graphic);
        AviWriter.AddFrame(bm);
      finally
        bm.Free;
      end;
    finally
      Pic.Free;
    end;
  end;

  AviWriter.FinalizeVideo;

  Label11.Caption := '... Writing Final File';
  Label11.Refresh;
  AviWriter.WriteAvi;

  Label11.Caption := '... Done';
  Button7.enabled := true;
end;

procedure TMainForm.Button8Click(Sender: TObject);
begin
  Label9.Caption := 'None';
  MediaPlayer1.Close;
end;

procedure TMainForm.Button7Click(Sender: TObject);
begin
  MediaPlayer1.Close;
  Animate1.Active := false;
  Animate1.filename := '';
  if FileExists(AviWriter.filename) then
  begin
    MediaPlayer1.filename := AviWriter.filename;
    MediaPlayer1.open;
    MediaPlayer1.Play;
  end
  else
    ShowMessage('Avi-File not found');
end;

procedure TMainForm.Button9Click(Sender: TObject);
begin
  MediaPlayer1.Close;
  Animate1.Active := false;
  Animate1.filename := '';
  if AviWriter.PixelFormat = pf24bit then
    if ComboBox2.ItemIndex > 0 then
      if MessageDlg('The avi probably won''t work in a TAnimate with pf24bit compressed movies. Do you still want to try?',
        mtWarning, [mbYes, mbNo], 0) = mrNo then
        exit;
  if FileExists(AviWriter.filename) then
  begin
    Animate1.filename := AviWriter.filename;
    Animate1.Active := true;
  end
  else
    ShowMessage('Avi-File not found');
end;

procedure TMainForm.ComboBox3Change(Sender: TObject);
begin
  case ComboBox3.ItemIndex of
    0: AviWriter.SetCompressionQuality(10000);
    1: AviWriter.SetCompressionQuality(9000);
    2: AviWriter.SetCompressionQuality(8000);
    3: AviWriter.SetCompressionQuality(6000);
    4: AviWriter.SetCompressionQuality(4000);
  else
    AviWriter.SetCompressionQuality(10000);
  end;
end;

end.

