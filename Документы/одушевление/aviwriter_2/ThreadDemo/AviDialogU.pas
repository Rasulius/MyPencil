unit AviDialogU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PersistentDialogU, StdCtrls, Buttons, ExtCtrls, ComCtrls,
  AviWriter_2;

type
  TAviDialog = class(TPersistentDialog)
    AviWriter: TAviWriter_2;
    Label11: TLabel;
    Label14: TLabel;
    Label16: TLabel;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    Label9: TLabel;
    Button1: TButton;
    ComboBox3: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    ComboBox4: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox4Change(Sender: TObject);
  private
    procedure UpdateGroupbox;
    procedure UpdateCompressorList;
    { Private declarations }
  public
    Totaltime: integer;
    KeyFrameTime: integer;
    FrameTime: integer;
    AviWidth, AviHeight: integer;
    BitRate: integer;
    { Public declarations }
  end;


implementation

{$R *.dfm}


procedure TAviDialog.FormCreate(Sender: TObject);
begin
  inherited;
  Totaltime := 600000;
  KeyFrameTime := 300000;
  FrameTime:=40;
  UpdateCompressorList;
  RadioGroup1Click(nil);
end;

procedure TAviDialog.RadioGroup1Click(Sender: TObject);
begin
  inherited;
  case ComboBox3.ItemIndex of
    0: begin
         AviWidth:=352;
         AviHeight:=240;
       end;
    1: begin
         AviWidth:=352;
         AviHeight:=288;
       end;
    2: begin
         AviWidth:=480;
         AviHeight:=480;
       end;
    3: begin
         AviWidth:=480;
         AviHeight:=576;
       end;
    4:
      begin
        AviWidth := 240;
        AviHeight := 180;
      end;
    5:
      begin
        AviWidth := 400;
        AviHeight := 300;
      end;
    6:
      begin
        AviWidth := 592;
        AviHeight := 444;
      end;
  end;


  AviWriter.Width := AviWidth;
  AviWriter.Height := AviHeight;
  UpdateCompressorList;
  //give each codec a chance to back off if the
  //size is wrong for it. None ever does so far.

  UpdateGroupbox;
end;


procedure TAviDialog.UpdateGroupbox;
var VideoSize, AudioSize, Comp1, Comp2: double;
begin
  //Label6.Caption := ' ' + IntToStr(AviWidth) + ' ';
  //Label7.Caption := ' ' + IntToStr(AviHeight) + ' ';
  //Label8.Caption := ' ' + IntToStr(FrameTime) + ' ';
  VideoSize := 1 / 8 * 1 / 1024 * 1 / 1024 * AviHeight * AviWidth * 1 / FrameTime * 24 * KeyFrameTime;
  if ComboBox1.ItemIndex > 0 then
  begin
    Comp1 := 1 / 20 * VideoSize;
    Comp2 := 1 / 2 * VideoSize; //wild guesses
  end
  else
  begin
    Comp1 := VideoSize;
    Comp2 := VideoSize;
  end;
  AudioSize := 1 / 8 * 1 / 1024 * 1 / 1024 * (41.4 * 16 * 2) * Totaltime;
  Label9.Caption := ' ' + FloatToStrf(Comp1 + AudioSize, ffFixed, 7, 2) + ' -> ' + FloatToStrf(Comp2 + AudioSize, ffFixed, 7, 2) + ' ';
  //Totaltime is in ms
end;

procedure TAviDialog.FormShow(Sender: TObject);
begin
  inherited;
  RadioGroup1Click(nil);
end;

procedure TAviDialog.Button1Click(Sender: TObject);
begin
  AviWriter.ShowCompressorDialog(Self);
end;

procedure TAviDialog.UpdateCompressorList;
var Save: integer;
begin
  Save := ComboBox1.ItemIndex;
  AviWriter.Compressorlist(ComboBox1.Items);
  if (Save = -1) or (Save >= ComboBox1.Items.Count) then
    ComboBox1.ItemIndex := 0
  else
    ComboBox1.ItemIndex := Save;
  ComboBox1Change(nil);
end;

procedure TAviDialog.ComboBox1Change(Sender: TObject);
begin
  if (ComboBox1.ItemIndex > 0) then
    AviWriter.SetCompression(copy(ComboBox1.Items.Strings[ComboBox1.ItemIndex], 1, 4))
  else
    AviWriter.SetCompression('');
  UpdateGroupBox;
end;

procedure TAviDialog.ComboBox4Change(Sender: TObject);
begin
  FrameTime:=round(1000/StrToFloat(Combobox4.Items.Strings[combobox4.itemindex]));
  UpdateGroupBox;
end;

end.

