unit MainU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, Thumblist, ActnList, Menus,
  MPlayer, AviThread, FileCtrl, StdCtrls;

type
  TMainForm = class(TForm)
    ScrollBox1: TScrollbox;
    Splitter1: TSplitter;
    ScrollBox2: TScrollbox;
    MainMenu1: TMainMenu;
    humbSize1: TMenuItem;
    ActionList1: TActionList;
    acLargeThumbs: TAction;
    acMediumThumbs: TAction;
    acSmallThumbs: TAction;
    Medium1: TMenuItem;
    Large1: TMenuItem;
    Small1: TMenuItem;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Music1: TMenuItem;
    LoadWaveFile1: TMenuItem;
    Movie1: TMenuItem;
    WriteAvi1: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    MediaPlayer1: TMediaPlayer;
    PopupMenu1: TPopupMenu;
    ShowImage1: TMenuItem;
    PopupMenu2: TPopupMenu;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    SimpleHelptext1: TMenuItem;
    ClearMusiclist1: TMenuItem;
    Panel1: TPanel;
    DriveComboBox1: TDriveComboBox;
    Foldertree: TDirectoryListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure acLargeThumbsExecute(Sender: TObject);
    procedure acMediumThumbsExecute(Sender: TObject);
    procedure acSmallThumbsExecute(Sender: TObject);
    procedure Image1DragOver(Sender, Source: TObject; x, y: integer;
      State: TDragState; var Accept: boolean);
    procedure Image1DragDrop(Sender, Source: TObject; x, y: integer);
    procedure WriteAvi1Click(Sender: TObject);
    procedure LoadWaveFile1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure ShowImage1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure SimpleHelptext1Click(Sender: TObject);
    procedure ClearMusiclist1Click(Sender: TObject);
    procedure FoldertreeChange(Sender: TObject);
  private
    TempFolder: string;
    Thumblist: TThumblist;
    MovieFileList: TStringList;
    musicList: TStringList;
    AviThreadsRunning: integer;
    procedure AviFinish(Sender: TObject; const filename: string; Success: boolean);
    procedure ThumblistUpdate(sender: TObject);
    procedure RedrawThumblist;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  HelperProcs, IniFiles, AviDialogU, ProgressU, math, ShellApi;

procedure TMainForm.FormCreate(Sender: TObject);
var l: integer;
  AImage: TImage;
  ini: TMemInifile;
  thht: double;
  dt, da: string;
begin
  SetLength(TempFolder, MAX_PATH + 1);
  l := GetTempPath(MAX_PATH, PChar(TempFolder));
  SetLength(TempFolder, l);
  if TempFolder[Length(TempFolder)] = '\' then
    TempFolder := copy(TempFolder, 1, Length(TempFolder) - 1);
  dt := TempFolder + '\Thumbs';
  if DirectoryExists(dt) then
    DeleteFolder(dt);
  CreateDir(dt);
  da := TempFolder + '\AviTemp';
  if DirectoryExists(da) then
    DeleteFolder(da); //merciless
  CreateDir(da);
  Thumblist := TThumblist.Create;
  Thumblist.OnUpdate:=ThumblistUpdate;
  Thumblist.ThumbsPopup := PopupMenu1;
  Thumblist.ThumbDirectory := dt;
  ini := TMemInifile.Create(ExtractFilePath(Application.ExeName) + 'AviDemo.ini');
  try
    Thumblist.ThumbHeight := ini.ReadInteger('Thumblist', 'Thumbheight', round(screen.Height * 100 / 950));
    dt:=ini.ReadString('Browser', 'ImageFolder', FolderTree.Directory);
    if DirectoryExists(dt) then
    Foldertree.Directory:=dt;
  finally
    ini.Free;
  end;
  thht := Thumblist.ThumbHeight * 950 / screen.Height;
  acLargeThumbs.checked := thht > 120;
  if not acLargeThumbs.checked then
    acMediumThumbs.checked := thht > 90;
  acSmallThumbs.checked := thht < 80;
  MovieFileList := TStringList.Create;
  for l := 1 to 8 do
  begin
    AImage := TImage(FindComponent('Image' + IntToStr(l)));
    AImage.Canvas.Brush.Color := clBlack;
    AImage.Canvas.FillRect(AImage.ClientRect);
  end;
  AviThreadsRunning := 0;
  musiclist:=Tstringlist.create;
end;


procedure TMainForm.FormDestroy(Sender: TObject);
var ini: TMemInifile;
begin
  ini := TMemInifile.Create(ExtractFilePath(Application.ExeName) + 'AviDemo.ini');
  try
    ini.WriteInteger('Thumblist', 'Thumbheight', Thumblist.ThumbHeight);
    ini.WriteString('Browser', 'ImageFolder', FolderTree.Directory);
    ini.UpdateFile;
  finally
    ini.Free;
  end;
  MovieFileList.Free;
  Thumblist.Free;
  musiclist.Free;
  DeleteFolder(TempFolder + '\Thumbs');
  DeleteFolder(TempFolder + '\AviTemp')
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  if not (csDestroying in ComponentState) then
    if Assigned(Thumblist) then
      RedrawThumblist;
end;

procedure TMainForm.acLargeThumbsExecute(Sender: TObject);
begin
  acLargeThumbs.checked := true;
  if Assigned(Thumblist) then
    Thumblist.ThumbHeight := round(screen.Height * 160 / 950);
  RedrawThumblist;
end;

procedure TMainForm.acMediumThumbsExecute(Sender: TObject);
begin
  acMediumThumbs.checked := true;
  if Assigned(Thumblist) then
    Thumblist.ThumbHeight := round(screen.Height * 110 / 950);
  RedrawThumblist;
end;

procedure TMainForm.acSmallThumbsExecute(Sender: TObject);
begin
  acSmallThumbs.checked := true;
  if Assigned(Thumblist) then
    Thumblist.ThumbHeight := round(screen.Height * 70 / 950);
  RedrawThumblist;
end;

procedure TMainForm.Image1DragOver(Sender, Source: TObject; x, y: integer;
  State: TDragState; var Accept: boolean);
begin
  Accept := Source is TThumb;
end;

procedure TMainForm.Image1DragDrop(Sender, Source: TObject; x, y: integer);
var AImage: TImage;
  i, Index: integer;
begin
  AImage := TImage(Sender);
  i := StrToInt(copy(AImage.name, Length(AImage.name), 1));
  if Assigned(Thumblist) then
    if Source is TThumb then
    begin
      Index := Thumblist.GetIndex(TThumb(Source));
      Thumblist.DrawThumbImage(AImage, Index);
      if i > MovieFileList.Count then
        MovieFileList.add(Thumblist.ImageFile[Index])
      else
        MovieFileList.Strings[i - 1] := Thumblist.ImageFile[Index];
    end;
end;

procedure TMainForm.WriteAvi1Click(Sender: TObject);
var tt,i: integer;
  h: THandle;
  lAviThread: TAviThread;
  lAviFile: string;
begin
  if AviThreadsRunning > 0 then
  begin
    if MessageDlg
      ('For some reason, running more than one avi writing thread can fail (Win2K, e.g.). Do you still want to try?',
      mtWarning, [mbYes, mbNo], 0) = mrNo then
      exit;
  end;
  if not SaveDialog1.Execute then
    exit;
  lAviFile := SaveDialog1.filename;

  tt := MovieFileList.Count - 1;
  while MovieFileList.Strings[tt] = '' do
  begin
    MovieFileList.Delete(tt);
    Dec(tt);
  end;

  if MovieFileList.Count = 0 then
  begin
    ShowMessage('No images selected');
    exit;
  end;
  //So it doesn't support gaps in the frames.
  //Well it's just a stupid demo, hey.

  MediaPlayer1.Close; //if still open from avi-playing

  tt:=0;
  for i:=0 to musiclist.count-1 do
  if FileExists(musiclist.Strings[i]) then
  begin
    musiclist.Objects[i]:=TObject(tt);
    MediaPlayer1.filename := musiclist.Strings[i];
    MediaPlayer1.open;
    MediaPlayer1.Timeformat := tfMilliseconds;
    tt := tt+MediaPlayer1.Length+3000; //3 seconds pause
    MediaPlayer1.Close;
  end;
  if tt=0 then
    tt := MovieFileList.Count * 30 * 1000; //1/2 minute per picture

  with TAviDialog.Make(TempFolder + '\AviTemp') do
  try
    Totaltime := tt;
    KeyFrameTime := tt div 3;
    ShowModal;
    if ModalResult = mrOK then
    begin
      if IsOpenInExplorer(ExtractFolder(lAviFile), h) then
        ShowMessage('The folder ' + ExtractFolder(lAviFile) + ' is open in explorer. Please close it, then click OK, otherwise the writing might fail');
      lAviThread := TAviThread.Create(true);
      lAviThread.ImageFileList := MovieFileList;
      lAviThread.musiclist.Assign(musiclist);
      lAviThread.AviWidth := AviWidth;
      lAviThread.AviHeight := AviHeight;
      lAviThread.AviFrameTime := FrameTime;
      lAviThread.Avifile := lAviFile;
      //lAviThread.musicfile := musicfile;
      if ComboBox1.ItemIndex = 0 then
        lAviThread.FourCC := '' else
        lAviThread.FourCC := copy(ComboBox1.Items.Strings[ComboBox1.ItemIndex], 1, 4);
      case ComboBox2.ItemIndex of
        0: lAviThread.quality := 10000;
        1: lAviThread.quality := 9000;
        2: lAviThread.quality := 8000;
        3: lAviThread.quality := 5000;
        4: lAviThread.quality := 3000;
      else
        lAviThread.quality := 10000;
      end;
      lAviThread.ImageTime := tt div MovieFileList.Count;
      lAviThread.TransitTime := lAviThread.ImageTime div 3;
      lAviThread.FreeOnTerminate := true;
      inc(AviThreadsRunning);
      with TProgressForm.Create(Application) do
      begin
        AviThread := lAviThread;
        MovieFrames := tt div AviThread.AviFrameTime;
        OnAviFinish := AviFinish;
        show;
      end;
      lAviThread.Resume;
    end;
  finally
    Free;
  end;
end;

procedure TMainForm.LoadWaveFile1Click(Sender: TObject);
begin
  with OpenDialog1 do
    if Execute then
    begin
      musicList.Add(filename);
      if musiclist.count=1 then
      Label2.Caption := 'Music Files: ' + filename
      else
      Label2.Caption:=Label2.Caption+'  '+filename;
    end;
end;

procedure TMainForm.AviFinish(Sender: TObject; const filename: string;
  Success: boolean);
begin
  Dec(AviThreadsRunning);
  if Success then
  begin
    {MediaPlayer1.filename := filename;
    MediaPlayer1.open;
    MediaPlayer1.Play;}
    //The Shell-Mediaplayer is probably better than
    //TMediaPlayer
    ShellExecute(Handle,'open', PChar(filename),nil,nil,SW_SHOWNORMAL);
  end;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var i: integer;
begin
  CanClose := (AviThreadsRunning = 0);
  if not CanClose then
  begin
    ShowMessage('Be patient while we finish the avi writing threads. Then try again.');
    for i := 0 to screen.FormCount - 1 do
      if screen.Forms[i] is TProgressForm then
        TProgressForm(screen.Forms[i]).AviThread.Terminate;
  end;
end;

procedure TMainForm.ShowImage1Click(Sender: TObject);
var TH: TThumb;
  imf: string;
  Pic: TPicture;
  sbm, tbm: TBitmap;
  sasp, tasp: double;
  w, h: integer;
  im: TImage;
  f: TForm;
begin
  if not (PopupMenu1.PopupComponent is TThumb) then
    exit;
  TH := TThumb(PopupMenu1.PopupComponent);
  imf := Thumblist.GetImageFileFromThumb(TH);
  Pic := TPicture.Create;
  Pic.loadfromfile(imf);
  sbm := TBitmap.Create; //not trys, I don't know how to free them in the logical order, otherwise
  sbm.PixelFormat := pf24bit;
  sbm.Width := Pic.Width;
  sbm.Height := Pic.Height;
  sbm.Canvas.draw(0, 0, Pic.Graphic);
  Pic.Free;
  if (sbm.Width < screen.Width) and (sbm.Height < screen.Height) then
  begin
    w := sbm.Width;
    h := sbm.Height;
  end
  else
  begin
    sasp := max(sbm.Width, 1) / max(sbm.Height, 1);
    //just to avoid division by 0 in funny situations
    tasp := screen.Width / screen.Height;
    if sasp > tasp then
    begin
      w := screen.Width;
      h := round(w / sasp);
    end
    else
    begin
      h := screen.Height;
      w := round(h * sasp);
    end;
  end;
  tbm := TBitmap.Create;
  tbm.PixelFormat := pf24bit;
  tbm.Width := w;
  tbm.Height := h;
  CopyRectEx(tbm.Canvas, Rect(0, 0, w, h), sbm, Rect(0, 0, sbm.Width, sbm.Height), true);
  sbm.Free;
  im := TImage.Create(nil);
  im.Picture.Bitmap := tbm;
  tbm.Free;
  f := TForm.Create(nil);
  with f do
  begin
    Borderstyle := bsNone;
    Color := clBlack;
    SetBounds(0, 0, screen.Width, screen.Height);
  end;
  im.SetBounds((screen.Width - w) div 2, (screen.Height - h) div 2, w, h);
  im.Parent := f;
  im.PopupMenu := PopupMenu2;
  f.ShowModal;
  f.Free; //also frees im, because it's the parent
end;

procedure TMainForm.Exit1Click(Sender: TObject);
var im: TImage;
begin
  if not (PopupMenu2.PopupComponent is TImage) then
    exit;
  im := TImage(PopupMenu2.PopupComponent);
  if not (im.Parent is TForm) then
    exit;
  TForm(im.Parent).ModalResult := mrOK;
end;

procedure TMainForm.SimpleHelptext1Click(Sender: TObject);
begin
  WinExec(PChar('Notepad.exe ' + ExtractFilePath(Application.ExeName) + 'Help.txt'), SW_SHOWNORMAL);
end;

procedure TMainForm.ThumblistUpdate(sender: TObject);
begin
  Scrollbox1.DoubleBuffered:=true;
  try
    Scrollbox1.Repaint;
  finally
    Scrollbox1.DoubleBuffered:=false;
  end;    
end;

procedure TMainForm.RedrawThumblist;
begin
  if assigned(Thumblist) then
  Thumblist.DisplayThumbs(Scrollbox1,-scrollbox1.HorzScrollBar.Position,
   -scrollbox1.VertScrollBar.Position,4,4);
end;

procedure TMainForm.ClearMusiclist1Click(Sender: TObject);
begin
  musicList.Clear;
  label2.Caption:='Music Files: None';
end;

procedure TMainForm.FoldertreeChange(Sender: TObject);
var p: string;
begin
   p:=FolderTree.Directory;
  if Assigned(Thumblist) then
  if directoryexists(p) then
    Thumblist.PicDirectory := p;
  RedrawThumblist;
end;

end.

