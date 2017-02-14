unit Thumblist;

/////////////////////////////////////////////////////////////
//                                                         //
//   Copyright:  © 2002 Renate Schaaf                      //
//                                                         //
//   For personal use, do not distribute.                  //
//                                                         //
/////////////////////////////////////////////////////////////

interface

uses Windows, Graphics, SysUtils, Messages, Classes, Controls,
  Forms, Menus, SyncObjs, IniFiles, ExtCtrls, ThumbFile;

const
  FireUpdate = WM_User + 77;

type


  TThumb = class(TControl)
  private
    fThumbFile: TThumbFile;
    FIndex: Longint;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure SetThumbFile(const value: TThumbFile);
  protected
    //procedure Paint; override;
    //not a TGraphicControl anymore, because
    //I don't want each of them to have a
    //permanent canvas, including a TCriticalSection.
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property ThumbFile: TThumbFile read fThumbFile write SetThumbFile;
    property FileIndex: Longint read FIndex write FIndex;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property DragMode;
    property DragCursor;
    property OnDragOver;
    property OnDragDrop;
    property PopupMenu;
    property Visible;
    property Hint;
    property ShowHint;
  published
  end;

type

  TThumblist = class(TStringList)
  //Organize a list of imagefiles
  //with their associated thumbs
  //This list still lacks implementation
  //of things like overridden Add, etc..
  private
    fThumbheight: integer;
    fPicDirectory: string;
    fThumbDirectory: string;

    fScrollbarWidth: integer;

    fThumbsPopup: TPopupMenu;
    //Caution this could blow,
    //since fThumbsPopup is just a pointer
    //to an existing Popup, and there is
    //no freenotification.

    fInifile: TCustomIniFile;
    fThumbFile: TThumbFile;
    //used to associate the image file names
    //with the index of their thumb files stored
    //in fThumbFile.
    //Possible, because TMemInfile now is so nice and fast (>=Delphi6)

    fThreadList: TThreadList;

    fHandle: HWND; //to receive messages

    JustCreated: boolean;

    fOnUpdate: TNotifyEvent;
    procedure ThreadTerminate(Sender: TObject);
    procedure DisplayUpdate {(sender: TObject);}(var Msg: TMessage);
    procedure MakeThumbs;
    procedure RemoveThread(i: integer);
    procedure FreeThreads;
    procedure SetPicDirectory(const value: string);
   // procedure SetScrollbox(const value: TScrollbox);
    procedure SetThumbDirectory(const value: string);
    procedure SetThumbHeight(const value: integer);
    function GetImageFile(i: integer): string;
    procedure SetThumbsPopup(const value: TPopupMenu);
  protected
  public
    procedure Clear; override;
    constructor Create;
    destructor Destroy; override;
    procedure DisplayThumbs(aWinControl: TWinControl; OrgX, OrgY, dx, dy: integer);
    procedure DrawThumbImage(AImage: TImage; Index: integer);
    function GetImageFileFromThumb(aThumb: TThumb): string;
    function GetIndex(aThumb: TThumb): integer;
    property ThumbHeight: integer read fThumbheight write SetThumbHeight;
    property ThumbDirectory: string read fThumbDirectory write SetThumbDirectory;
    //property Scrollbox: TScrollbox read fScrollbox write SetScrollbox;
    property ThumbsPopup: TPopupMenu read fThumbsPopup write SetThumbsPopup;
    property PicDirectory: string read fPicDirectory write SetPicDirectory;
    property ImageFile[i: integer]: string read GetImageFile;
    property OnUpdate: TNotifyEvent read fOnUpdate write fOnUpdate;
  end;

  TMakeThumbsThread = class(TThread)
  //takes a list of image file names and
  //makes thumbs from them. Each thumb is
  //stored in ThumbFile, if not already there, and its index
  //in the file is written to Inifile.
  private
    fFileList: TStringList;
    fOnUpdate: TNotifyEvent;
    procedure CallOnUpDate;
    procedure SetFileList(const value: TStringList);
  protected
    procedure Execute; override;
  public
    Number: integer;
    PicDirectory, ThumbDirectory: string;
    ThumbHeight: integer;
    Inifile: TCustomIniFile;
    ThumbFile: TThumbFile;
    ListHandle: HWnd;
    constructor Create(CreateSuspended: boolean);
    destructor Destroy; override;
    property FileList: TStringList read fFileList write SetFileList;
    property OnUpdate: TNotifyEvent read fOnUpdate write fOnUpdate;
  end;



implementation

uses FileCtrl, HelperProcs, math, Dialogs;

var SaveLock, VCLLock: TCriticalSection;


{ TThumb }

constructor TThumb.Create(AOwner: TComponent);
begin
  inherited;
  FIndex := -1;
end;

destructor TThumb.Destroy;
begin

  inherited;
end;



procedure TThumb.SetThumbFile(const value: TThumbFile);
begin
  fThumbFile := value;
end;

procedure TThumb.WMPaint(var Msg: TWMPaint);
var c: TCanvas;
  r1, r2: TRect;
begin
  if Msg.DC <> 0 then
  begin
    if not assigned(parent) then
      exit;
    if (Top + Height < 0) then
      exit;
    if (Top > Parent.Height) then
      exit;
    if (Left + Width < 0) then
      exit;
    if (Left > Parent.Width) then
      exit;
    c := TCanvas.Create;
    try
      c.Handle := Msg.DC;
      try
        c.Pen.Color := clGreen;
        c.Brush.Style := bsClear;
        c.Rectangle(0, 0, Width, Height);
        if fThumbFile <> nil then
          if FIndex >= 0 then
          begin
            r1 := fThumbFile.ThumbRect[FIndex];
            r2 := r1;
            OffsetRect(r2, (Width - r1.Right) div 2, (Height - r1.Bottom) div 2);
            fThumbFile.DrawThumb(c, FIndex, r2);
          end;
      finally
        c.Handle := 0;
      end;
    finally
      c.Free;
    end;
  end;
end;

{ TThumblist }


procedure TThumblist.Clear;
var i: integer;
begin
  for i := 0 to Count - 1 do
    if Assigned(Objects[i]) then
    begin
      TThumb(Objects[i]).Free;
      Objects[i] := nil;
    end;
  inherited;
end;

constructor TThumblist.Create;
begin
  inherited;
  fThreadList := TThreadList.Create;
  fThreadList.Duplicates := dupAccept;
  fThumbheight := 80;
  fScrollbarWidth := GetSystemMetrics(SM_CXVSCROLL);
  fHandle := AllocateHwnd(DisplayUpdate);
  JustCreated := true;
  //substitute for csLoading in ComponentState
end;

destructor TThumblist.Destroy;
begin
  FreeThreads;
  SaveLock.Enter;
  //Necessary? If, then it should blow sometimes ...
  fInifile.UpdateFile;
  fInifile.Free;
  SaveLock.Leave;
  fThreadList.Free;
  fThumbFile.Free;
  Clear;
  DeallocateHwnd(fHandle);
  inherited;
end;

procedure TThumblist.DisplayThumbs(aWinControl: TWinControl; OrgX, OrgY, dx, dy: integer);
var i, t, l: integer;
  TH: TThumb;
  Save: boolean;
begin
  if not assigned(aWinControl) then
    raise exception.create('Display parent is nil.');
  Save := aWinControl.Doublebuffered;
  try
    aWinControl.Doublebuffered := true;
    aWinControl.DisableAlign;
  //speeds up rearrangement
    t := OrgY; l := OrgX;
    try
      for i := 0 to Count - 1 do
        if Assigned(Objects[i]) then
          TThumb(Objects[i]).Parent := nil;
    //speeds up rearrangement
      for i := 0 to Count - 1 do
        if Objects[i] is TThumb then
        begin
          TH := TThumb(Objects[i]);
          TH.SetBounds(l + dx, t + dy, fThumbheight, fThumbheight);
          TH.Parent := aWinControl;
          l := l + fThumbheight + dx;
          if l + fThumbheight > aWinControl.Width - fScrollbarWidth - dx then
          begin
            t := t + fThumbheight + dy;
            l := 0;
          end;
        end;
    finally
      aWinControl.EnableAlign;
    end;
    aWinControl.Repaint;
  //eliminates flicker;
  finally
    aWinControl.Doublebuffered := Save;
  end;
end;

procedure TThumblist.DisplayUpdate {(sender: TObject)}(var Msg: TMessage);
var
  i: integer;
  Index: integer;
  TH: TMakeThumbsThread;
begin
  if Msg.Msg = FireUpdate then
  begin
    TH := TMakeThumbsThread(Msg.Wparam);
    if TH.terminated then
      exit;
    if TH.PicDirectory <> fPicDirectory then
  //not current picture folder
      exit;
    if not Assigned(fInifile) then
      exit;
  //Read whatever thumbs are there
    for i := 0 to Count - 1 do
    // assume all thumbs have been created
      if Assigned(Objects[i]) then
        if TThumb(Objects[i]).ThumbFile = nil then
        begin
          SaveLock.Enter;
          try
            Index := fInifile.ReadInteger(ExtractFilePath(Strings[i]), ExtractFileName(Strings[i]), -1);
          finally
            SaveLock.Leave;
          end;
          if Index <> -1 then
          begin
            TThumb(Objects[i]).ThumbFile := fThumbFile;
            TThumb(Objects[i]).FIndex := Index;
          end;
        end;
    if assigned(fOnUpdate) then fOnUpdate(self);
  end;
end;




procedure TThumblist.FreeThreads;
var l: TList;
  i: integer;
  TH: TMakeThumbsThread;
begin
  l := fThreadList.LockList;
  for i := 0 to l.Count - 1 do
  begin
    TH := TMakeThumbsThread(l.Items[i]);
    TH.OnTerminate := nil;
    TH.OnUpdate := nil;
    TH.FreeOnTerminate := false;
  end;
  fThreadList.UnlockList;
  l := fThreadList.LockList;
  for i := l.Count - 1 downto 0 do
  begin
    if TObject(l.Items[i]) is TMakeThumbsThread then
    begin
      TH := TMakeThumbsThread(l.Items[i]);
      TH.Terminate;
      TH.WaitFor;
      TH.Free;
      l.Delete(i);
    end;
  end;
  fThreadList.UnlockList;
end;

function TThumblist.GetImageFile(i: integer): string;
begin
  Result := '';
  if (i >= 0) and (i < Count) then
    Result := Strings[i];
end;

function TThumblist.GetImageFileFromThumb(aThumb: TThumb): string;
begin
  Result := '';
  if (aThumb.Tag >= 0) and (aThumb.Tag < Count) then
    Result := Strings[aThumb.Tag];
end;

function TThumblist.GetIndex(aThumb: TThumb): integer;
begin
  Result := IndexOfObject(aThumb);
end;

procedure TThumblist.DrawThumbImage(AImage: TImage; Index: integer);
var TH: TThumb;
begin
  if (Index >= 0) and (Index < Count) then
  begin
    TH := TThumb(Objects[Index]);
    if TH.fThumbFile <> nil then
    begin
      AImage.Center := true;
      TH.fThumbFile.GetThumb(AImage.Picture.Bitmap, TH.FIndex);
    end;
  end;
end;

procedure TThumblist.MakeThumbs;
var
  i: integer;
  TH: TMakeThumbsThread;
  l: TList;
begin
  TH := TMakeThumbsThread.Create(true);
  TH.FileList := Self;
  TH.ThumbHeight := fThumbheight;
  TH.PicDirectory := fPicDirectory;
  TH.FreeOnTerminate := true;
  TH.OnTerminate := ThreadTerminate;
  //TH.OnUpdate := DisplayUpdate;
  TH.ListHandle := FHandle;
  TH.ThumbDirectory := fThumbDirectory;
  TH.Inifile := fInifile;
  TH.ThumbFile := fThumbFile;
  fThreadList.add(TH);
  l := fThreadList.LockList;
  try
    TH.Number := l.Count - 1;
   // for i := 0 to l.Count - 2 do
   //   TMakeThumbsThread(l.Items[i]).Priority := tpLowest;
    if l.Count > 1 then
    //no more that 2 concurrent threads allowed
      for i := l.Count - 2 downto 0 do
        TMakeThumbsThread(l.Items[i]).Terminate;
  finally
    fThreadList.UnlockList;
  end;
  TH.Resume;
end;


procedure TThumblist.RemoveThread(i: integer);
var j: integer;
  l: TList;
begin
  l := fThreadList.LockList;
  try
    if (i >= 0) and (i < l.Count) then
    begin
      l.Delete(i);
      for j := 0 to l.Count - 1 do
        TMakeThumbsThread(l.Items[j]).Number := j;
    end;
  finally
    fThreadList.UnlockList;
  end;
end;


procedure TThumblist.SetPicDirectory(const value: string);
var
  fl: TFileListBox;
  i: integer;
  TH: TThumb;
begin
  if fPicDirectory = value then
    exit;
  if not DirectoryExists(value) then
  begin
    raise Exception.Create('Picture Directory is invalid');
    exit;
  end;

  {thp := PathGetLongName(fThumbDirectory);
  newp := PathGetLongName(value);

  if newp = thp then
  begin
    ShowMessage('It''s not possible to browse the thumb folder');
    exit;
  end; }


  fPicDirectory := value;
  Clear;
  fl := TFileListBox.Create(nil);
  //because I'm lazy
  fl.Visible := false;
  fl.ParentWindow := fHandle;
  try
    fl.directory := fPicDirectory;
    fl.mask := '*.bmp;*.jpg;*.jpeg';
    for i := 0 to fl.Items.Count - 1 do
      add(fPicDirectory + '\' + fl.Items.Strings[i]);
    for i := 0 to Count - 1 do
    begin
      TH := TThumb.Create(nil);
      TH.Width := fThumbheight;
      TH.Height := fThumbheight;
      TH.Tag := i;
      TH.Hint := ExtractFileName(Strings[i]);
      TH.ShowHint := true;
      TH.DragKind := dkDrag;
      TH.DragMode := dmAutomatic;
      TH.PopupMenu := fThumbsPopup;
      Objects[i] := TH;
    end;
  finally
    fl.ParentWindow := 0;
    fl.Free;
  end;
  MakeThumbs;
end;


procedure TThumblist.SetThumbDirectory(const value: string);
begin
  if fThumbDirectory = value then
    exit;
  if not DirectoryExists(value) then
  begin
    raise Exception.Create('Temp thumb-folder does not exist');
    exit;
  end;
  FreeThreads;
  fInifile.Free;
  fThumbFile.Free;
  {if DirectoryExists(fThumbDirectory) then
  DeleteFolder(fThumbDirectory); }
  //That should be the responsibility of the user
  fThumbDirectory := value;
  fInifile := TMemIniFile.Create(fThumbDirectory + '\Thumbs.dat');
  fThumbFile := TThumbFile.Create(fThumbDirectory + '\Thumbs.tfl');
  if Count > 0 then
    MakeThumbs;
end;

procedure TThumblist.SetThumbHeight(const value: integer);
var i: integer;
begin
  if JustCreated then
  begin
    JustCreated := false;
    fThumbheight := value;
    exit;
  end;
  if fThumbheight <> value then
  begin
    FreeThreads;
    SaveLock.Enter;
    try
      fInifile.Free;
      fThumbFile.Free;
      DeleteFolderContent(fThumbDirectory);
      fThumbheight := value;
      fInifile := TMemInifile.Create(fThumbDirectory + '\Thumbs.dat');
      fThumbFile := TThumbFile.Create(fThumbDirectory + '\Thumbs.tfl');
      for i := 0 to Count - 1 do
        if Objects[i] <> nil then
        begin
          TThumb(Objects[i]).fThumbFile := nil;
          TThumb(Objects[i]).FIndex := -1;
        end;
    finally
      SaveLock.Leave;
    end;
    MakeThumbs;
  end;
end;

procedure TThumblist.ThreadTerminate(Sender: TObject);
begin
  RemoveThread(TMakeThumbsThread(Sender).Number);
end;

{procedure TThumblist.AllThumbsEndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
  if sender is TThumb then
  DrawSelFrame(TThumb(sender),DOld.X, DOld.Y);
end;}

procedure TThumblist.SetThumbsPopup(const value: TPopupMenu);
begin
  fThumbsPopup := value;
end;

{ TMakeThumbsThread }

procedure TMakeThumbsThread.CallOnUpDate;
begin
  PostMessage(ListHandle, FireUpdate, integer(self), 0);
 // if assigned(fOnUpdate) then fOnUpdate(self);
end;

constructor TMakeThumbsThread.Create(CreateSuspended: boolean);
begin
  fFileList := TStringList.Create;
  inherited Create(CreateSuspended);
end;

destructor TMakeThumbsThread.Destroy;
begin
  inherited;
  fFileList.Free;
  //need to free fFileList after inherited,
  //because inherited.free first terminates,
  //then waits for the thread to finish.
  //For this the fFileList needs to be in place
end;

procedure TMakeThumbsThread.Execute;
var
  i: integer;
  sbm, tbm: TBitmap;
  strm: TStream;
  ext: string;
  asp: double;
  w, h: integer;
  ThumbsMade: integer;
  ThumbIndex: integer;
  UpdateChunk: integer;
begin
  ThumbsMade := 0;
  UpdateChunk := fFileList.Count div 25 + 4;
  for i := 0 to fFileList.Count - 1 do
  begin
    if terminated then Break;

    SaveLock.Enter;
    try
      ThumbIndex := Inifile.ReadInteger(ExtractFilePath(fFileList[i]), ExtractFileName(fFileList[i]), -1);
    finally
      SaveLock.Leave;
    end;
    if ThumbIndex = -1 then
    begin
      inc(ThumbsMade);
      sbm := TBitmap.Create;
      //try
      strm := TFileStream.Create(fFileList.Strings[i], fmOpenRead or fmShareDenyNone);
      //try
      ext := AnsiupperCase(ExtractFileExt(fFileList.Strings[i]));
      if (ext = '.BMP') then
      begin
        try
          LoadThumbFromBMPStream(sbm, strm {fFileList.Strings[i]}, ThumbHeight + 20)
        except
          sbm.Width := 1;
          sbm.Height := 1;
        end;
      end
      else
        if (ext = '.JPG') or (ext = '.JPEG') then
        begin
          try
            LoadThumbFromJpegStream(sbm, strm {fFileList.Strings[i]}, ThumbHeight + 20);
          except
            sbm.Width := 1;
            sbm.Height := 1;
          end;
        end;
      //finally
      strm.Free;
     // end;
      if (sbm.Width > 4) and (sbm.Height > 4) then
         //otherwise futile to make a thumb
      begin
        asp := sbm.Width / sbm.Height;
        if asp > 1 then
        begin
          w := ThumbHeight - 8;
          h := round(w / asp);
        end
        else
        begin
          h := ThumbHeight - 8;
          w := round(h * asp);
        end;
        if h = 0 then
          h := 1;
        tbm := TBitmap.Create;
        tbm.PixelFormat := pf24bit;
        sbm.PixelFormat := pf24bit;
        tbm.Width := w;
        tbm.Height := h;
        tbm.Canvas.Lock;
        MakeThumbNailMod(sbm, tbm);
        sbm.Free;
        if not terminated then
          //otherwise inifile might be gone
        begin
          SaveLock.Enter;
          try
            ThumbIndex := Inifile.ReadInteger(ExtractFilePath(fFileList[i]), ExtractFileName(fFileList[i]), -1);
              //does it still not exist?
            if ThumbIndex = -1 then
            begin
              ThumbFile.AddThumb(tbm);
              Inifile.WriteInteger(ExtractFilePath(fFileList[i]), ExtractFileName(fFileList[i]), ThumbFile.ThumbCount - 1);
            end;
          finally
            SaveLock.Leave;
          end;
        end;
       // finally
        tbm.Free;
      //  end;
      end;
    end;
    if (i = 1) or (ThumbsMade > UpdateChunk) then
      if not terminated then
      begin
        ThumbsMade := 0;
        if not terminated then
          {SYNCHRONIZE(} CallOnUpDate {)};
      end;
  end;
  if not terminated then
    {SYNCHRONIZE(} CallOnUpDate {)};
end;

procedure TMakeThumbsThread.SetFileList(const value: TStringList);
begin
  fFileList.assign(value);
end;

initialization
  SaveLock := TCriticalSection.Create;
  VCLLock := TCriticalSection.Create;


finalization
  SaveLock.Free;
  VCLLock.Free;
end.

