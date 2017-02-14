unit ProgressU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, AviThread, ExtCtrls;

type

  TAviFinishEvent = procedure(Sender: TObject; const filename: string; Success: boolean) of object;

  TProgressForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    ProgressBar1: TProgressBar;
    Button1: TButton;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    AviAbort: boolean;
    function AbortAviQuery: boolean;
    { Private declarations }
  public
    OnAviFinish: TAviFinishEvent;
    AviThread: TAviThread;
    //This variable is supposed to keep track of the thread
    //which was created together with the TProgressForm.
    //But there's always a share violation or something
    //when I try to spawn a second thread.
    MovieFrames: integer;
    procedure AviProgress(Sender: TObject; FrameCount: integer; var abort: boolean);
    procedure AviTerminate(Sender: TObject);
    procedure BitmapsDone(sender: TObject; BitmapList: TList; BitmapCount: integer);
    procedure BadBitmap(Sender: TObject; Bmp: TBitmap; InfoHeaderSize, BitsSize: integer);
    { Public declarations }
  end;


implementation

{$R *.dfm}

uses BadBitmapU;

{ TProgressForm }

function TProgressForm.AbortAviQuery: boolean;
begin
  Result := MessageDlg('Abort Avi writing?', mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

procedure TProgressForm.AviProgress(Sender: TObject; FrameCount: integer;
  var abort: boolean);
begin
  ProgressBar1.position := FrameCount;
  if AviThread.WritingTemporary then
    Label2.Caption := '... adding video frames'
  else
    Label2.Caption := '... writing final file';
  abort := AviAbort;
end;

procedure TProgressForm.AviTerminate(Sender: TObject);
var e: Exception;
begin
  e := Exception(AviThread.fatalexception);
  show;
  if e <> nil then
    ShowMessage('Avi file writing failed. Err: ' + e.Message)
  else
    if AviThread.Cancelled then
      ShowMessage('Avi file writing aborted')
    else
      ShowMessage('Avi file writing finished');
  if Assigned(OnAviFinish) then
    OnAviFinish(Self, AviThread.Avifile, (e = nil) and (not AviThread.Cancelled));
  Close;
end;

procedure TProgressForm.FormShow(Sender: TObject);
begin
  //assume the fields have been assigned by then
  ProgressBar1.max := MovieFrames;
  Label1.Caption := 'Avi file: ' + AviThread.Avifile;
  Label2.Caption := '... Loading images';
  AviThread.OnUpdate := AviProgress;
  AviThread.OnTerminate := AviTerminate;
  AviThread.OnBitmapsDone:=BitmapsDone;
  AviThread.OnBadBitmap:=BadBitmap;
end;

procedure TProgressForm.Button1Click(Sender: TObject);
begin
  AviAbort := AbortAviQuery;
end;

procedure TProgressForm.FormCreate(Sender: TObject);
begin
  SetBounds(screen.Width - Width, 0, Width, Height);
  AviAbort := false;
end;

procedure TProgressForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TProgressForm.BitmapsDone(sender: TObject; BitmapList: TList;
  BitmapCount: integer);
var i: integer;
    im: TImage;
begin
  for i:=0 to BitmapCount-1 do
  begin
    im:=TImage(FindComponent('Image'+inttostr(i+1)));
    im.picture.bitmap:=TBitmap(Bitmaplist.items[i]);
  end;
end;

procedure TProgressForm.BadBitmap(Sender: TObject; Bmp: TBitmap;
  InfoHeaderSize, BitsSize: integer);
begin
  with TBadBitmapForm.Create(nil) do
  try
    Image1.Picture.Bitmap:=Bmp;
    Label1.Caption:=InttoStr(InfoHeaderSize);
    Label2.Caption:=InttoStr(BitsSize);
    ShowModal;
  finally
    free;
  end;
end;

end.

