unit AviThread;

interface

uses
  Windows, Graphics, Classes, AviWriter_2;

type

  TBitmapsDoneEvent = procedure(Sender: TObject; BitmapList: TList; BitmapCount: integer) of object;

  TTransObject = class
  private
    fsbm, ftbm, fres: TBitmap;
    fTransitTime: integer;
    fImageTime: integer;
    ftInv: double;
    procedure SetTransittime(const value: integer);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Initialize(sbm, tbm: TBitmap); virtual;
    procedure Finalize; virtual;
    procedure Render(t: integer); virtual;
    procedure WriteToAvi(const AviWriter: TAviWriter_2; sbm, tbm: TBitmap; NewWidth, NewHeight: integer);
    property TransitTime: integer read fTransitTime write SetTransittime;
    property ImageTime: integer read fImageTime write fImageTime;
    property Result: TBitmap read fres;
  end;

  TFadeObject = class(TTransObject)
  public
    procedure Render(t: integer); override;
  end;


  TAviThread = class(TThread)
  private
    fAviWriter: TAviWriter_2;
    fImageFileList: TStringList;
    fBitmapList: TList;
    fFadeObject: TFadeObject;
    fFrameCount: integer;
    fOnUpdate: TProgressEvent;
    fOnBitmapsDone: TBitmapsDoneEvent;
    fOnBadBitmap: TBadBitmapEvent;
    fError: TBitmap;
    fErrorHeaderSize, fErrorBitsSize: integer;
    fCancelled, fTempWrite: boolean;
    NewWidth, NewHeight: integer;
    procedure SetImageFileList(const value: TStringList);
    procedure CallOnUpDate;
    procedure CallOnBitmapsDone;
    procedure CallOnBadBitmap;
    procedure CompInvalid;
    procedure MakeBitmapList;
    procedure AviWriterProgress(Sender: TObject; FrameCount: integer; var abort: boolean);
    procedure AviWriterBadBitmap(Sender: TObject; bmp: TBitmap; InfoHeaderSize, BitsSize: integer);
    { Private declarations }
  protected
    procedure Execute; override;
  public
    AviWidth, AviHeight, AviFrameTime: integer;
    Avifile: string;
    musiclist: TStringlist;
    FourCC: TFourCC;
    quality: integer;
    ImageTime, TransitTime: integer;
    constructor Create(CreateSuspended: boolean);
    destructor Destroy; override;
    property ImageFileList: TStringList read fImageFileList write SetImageFileList;
    property WritingTemporary: boolean read fTempWrite;
    property Cancelled: boolean read fCancelled;
    //either cancelled by user or by main thread via calling Terminate
    property OnUpdate: TProgressEvent read fOnUpdate write fOnUpdate;
    property OnBitmapsDone: TBitmapsDoneEvent read fOnBitmapsDone write fOnBitmapsDone;
    property OnBadBitmap: TBadBitmapEvent read fOnBadBitmap write fOnBadBitmap;
  end;

implementation

uses SysUtils, Dialogs, HelperProcs, math, Forms;


{ TTransObject }

constructor TTransObject.Create;
begin
  fTransitTime := 8000;
  ftInv := 1 / 8000;
  fImageTime := 16000;
end;

destructor TTransObject.Destroy;
begin
  inherited;
end;

procedure TTransObject.Finalize;
begin
  fsbm.Free;
  ftbm.Free;
  fres.Free;
end;

procedure TTransObject.Initialize(sbm, tbm: TBitmap);
begin
  if (sbm.Width <> tbm.Width) or (sbm.Height <> tbm.Height) then
    raise Exception.Create('Source and Target must have same dimensions.');
  fsbm := TBitmap.Create;
  ftbm := TBitmap.Create;
  fres := TBitmap.Create;
  fsbm.assign(sbm);
  ftbm.assign(tbm);
  fsbm.PixelFormat := pf24bit;
  ftbm.PixelFormat := pf24bit;
  fres.PixelFormat := pf24bit; //to be safe
  fres.Width := fsbm.Width;
  fres.Height := fsbm.Height;
end;

procedure TTransObject.Render(t: integer);
begin
end;

procedure TTransObject.SetTransittime(const value: integer);
begin
  if value <= 0 then
    raise Exception.Create('Transition time must be positive');
  fTransitTime := value;
  ftInv := 1 / value;
end;

procedure TTransObject.WriteToAvi(const AviWriter: TAviWriter_2; sbm, tbm: TBitmap; NewWidth, NewHeight: integer);
var t: integer;
  Temp: TBitmap;
  DoStretch: boolean;
begin
  t := 0;
  Initialize(sbm, tbm);
  DoStretch := (sbm.Width <> NewWidth) or (sbm.Height <> NewHeight);
  while (t < fTransitTime) and (not AviWriter.Aborted) do
  begin
    Render(t);
    if DoStretch then
    begin
      Temp := TBitmap.Create;
      try
        Temp.PixelFormat := pf24bit;
        Temp.Width := NewWidth;
        Temp.Height := NewHeight;
        Temp.Canvas.Lock;
        try
          fres.Canvas.Lock;
          try
            CopyRectEx(Temp.Canvas, Rect(0, 0, NewWidth, NewHeight), fres, Rect(0, 0, fres.Width, fres.Height), true);
          finally
            fres.Canvas.UnLock;
          end;
        finally
          Temp.Canvas.UnLock;
        end;
        AviWriter.AddFrame(Temp);
      finally
        Temp.Free;
      end;
    end
    else
      AviWriter.AddFrame(fres);
    t := t + AviWriter.FrameTime;
  end;
  if DoStretch then
  begin
    Temp := TBitmap.Create;
    try
      Temp.PixelFormat := pf24bit;
      Temp.Width := NewWidth;
      Temp.Height := NewHeight;
      Temp.Canvas.Lock;
      try
        ftbm.Canvas.Lock;
        try
          CopyRectEx(Temp.Canvas, Rect(0, 0, NewWidth, NewHeight), ftbm, Rect(0, 0, ftbm.Width, ftbm.Height), true);
        finally
          ftbm.Canvas.UnLock;
        end;
      finally
        Temp.Canvas.UnLock;
      end;
      AviWriter.AddStillImage(Temp, fImageTime - fTransitTime);
    finally
      Temp.Free;
    end;
  end
  else
    AviWriter.AddStillImage(ftbm, fImageTime - fTransitTime);
  Finalize;
end;

{ TFadeObject }

procedure TFadeObject.Render(t: integer);
var
  alpha: double;
  TimeLeft, n, m: integer;
  at, bt: PAlphaTable;
begin
  inherited;
  TimeLeft := max(fTransitTime - t, 0);
  alpha := AlphaHigh * ftInv * TimeLeft;
  n := round(alpha);
  m := AlphaHigh - n;
  at := @FracAlphaTable[n];
  bt := @FracAlphaTable[m];
  Tween3(fsbm, ftbm, fres, at, bt);
end;



{ TAviThread }

procedure TAviThread.AviWriterProgress(Sender: TObject;
  FrameCount: integer; var abort: boolean);
begin
  fFrameCount := FrameCount;
  SYNCHRONIZE(CallOnUpDate);
  abort := fCancelled or terminated;
  if terminated then
    fCancelled := true;
end;


procedure TAviThread.CompInvalid;
begin
  ShowMessage('The selected video compression is not supported');
end;

constructor TAviThread.Create(CreateSuspended: boolean);
begin
  fImageFileList := TStringList.Create;
  fBitmapList := TList.Create;
  Musiclist:=TStringlist.create;
  inherited Create(CreateSuspended);
end;

destructor TAviThread.Destroy;
var i: integer;
begin
  inherited;
  for i := 0 to fBitmapList.Count - 1 do
    TBitmap(fBitmapList.Items[i]).Free;
  fImageFileList.Free;
  fBitmapList.Free;
  MusicList.free;
end;

procedure TAviThread.Execute;
var i: integer;
  sbm, tbm: TBitmap;
begin
  fCancelled := false;
  MakeBitmapList;
  fAviWriter := TAviWriter_2.Create(nil);
  try
    fAviWriter.Width := AviWidth;
    fAviWriter.Height := AviHeight;
    fAviWriter.FrameTime := AviFrameTime;
    fAviWriter.filename := Avifile;
    //fAviWriter.WavFileName := musicfile;
    fAviWriter.Stretch := false;
    fAviWriter.OnProgress := AviWriterProgress;
    fAviWriter.OnBadBitmap := AviWriterBadBitmap;
    fAviWriter.PixelFormat := pf24bit;
    fAviWriter.SetCompressionQuality(quality);
    fAviWriter.SilenceName:=ExtractFilePath(Application.Exename)+'Silence.wav';
    try
      fAviWriter.SetCompression(FourCC);
    except
      SYNCHRONIZE(CompInvalid);
      FourCC := '';
    end;
    for i:=0 to musiclist.Count-1 do
    fAviWriter.AddWaveFile(musiclist.Strings[i],Integer(musiclist.Objects[i]));
    fFadeObject := TFadeObject.Create;
    fFadeObject.ImageTime := ImageTime;
    fFadeObject.TransitTime := TransitTime;
    try
      fTempWrite := true;
      fFrameCount := 0;
      SYNCHRONIZE(CallOnUpDate);
      sbm := TBitmap.Create;
      try
        sbm.PixelFormat := pf24bit;
        sbm.Width := NewWidth;
        sbm.Height := NewHeight;
        sbm.Canvas.Lock;
        try
          sbm.Canvas.Brush.Color := clBlack;
          sbm.Canvas.FillRect(Rect(0, 0, sbm.Width, sbm.Height));
        finally
          sbm.Canvas.UnLock;
        end;
        fAviWriter.InitVideo;
        fAviWriter.AddFrame(sbm);
        fFadeObject.WriteToAvi(fAviWriter, sbm, TBitmap(fBitmapList.Items[0]), NewWidth, NewHeight);
      finally
        sbm.Free;
      end;
      for i := 1 to fBitmapList.Count - 1 do
        if not fCancelled then
        begin
          sbm := TBitmap(fBitmapList.Items[i - 1]);
          tbm := TBitmap(fBitmapList.Items[i]);
          fFadeObject.WriteToAvi(fAviWriter, sbm, tbm, NewWidth, NewHeight);
        end
        else
          Break;
    finally
      fFadeObject.Free;
    end;
    fTempWrite := false;
    fAviWriter.FinalizeVideo;
    fAviWriter.WriteAvi;
  finally
    fAviWriter.Free;
  end;
end;

procedure TAviThread.SetImageFileList(const value: TStringList);
begin
  fImageFileList.assign(value);
end;

procedure TAviThread.CallOnUpDate;
begin
  if Assigned(fOnUpdate) then
    fOnUpdate(Self, fFrameCount, fCancelled);
end;

procedure TAviThread.MakeBitmapList;
var i: integer;
  rbm, sbm: TBitmap;
  Pic: TPicture;
  sasp, tasp: double;
  w, h: integer;
  r: TRect;
begin
  NewWidth := round(9 / 10 * AviWidth);
  NewHeight := round(9 / 10 * AviHeight);
  //leave a little black frame for those crummy TVs
  tasp := NewWidth / NewHeight;
  for i := 0 to fImageFileList.Count - 1 do
  begin
    rbm := TBitmap.Create;
    try
      Pic := TPicture.Create;
      try
        Pic.loadfromfile(fImageFileList.Strings[i]);
        rbm.PixelFormat := pf24bit;
        rbm.Width := Pic.Width;
        rbm.Height := Pic.Height;
        rbm.Canvas.Lock;
        try
          rbm.Canvas.draw(0, 0, Pic.Graphic);
        finally
          rbm.Canvas.UnLock;
        end;
      finally
        Pic.Free;
      end;
      sasp := rbm.Width / rbm.Height;
      sbm := TBitmap.Create;
      sbm.PixelFormat := pf24bit;
      if sasp > tasp then
      begin
        w := NewWidth;
        h := round(w / sasp);
      end
      else
      begin
        h := NewHeight;
        w := round(h * sasp);
      end;
      sbm.Width := NewWidth;
      sbm.Height := NewHeight;
      sbm.Canvas.Lock;
      try
        sbm.Canvas.Brush.Color := clBlack;
        sbm.Canvas.FillRect(Rect(0, 0, NewWidth, NewHeight));
        r.Left := (NewWidth - w) div 2;
        r.Top := (NewHeight - h) div 2;
        r.Right := r.Left + w;
        r.Bottom := r.Top + h;
        rbm.Canvas.Lock;
        try
          CopyRectEx(sbm.Canvas, r, rbm, Rect(0, 0, rbm.Width, rbm.Height), true);
        finally
          rbm.Canvas.UnLock;
        end;
      finally
        sbm.Canvas.UnLock;
      end;
      fBitmapList.add(sbm);
    finally
      rbm.Free;
    end;
  end;
  SYNCHRONIZE(CallOnBitmapsDone);
end;

{procedure TAviThread.WriteToAvi(sbm, tbm: TBitmap);
var t: integer;
  Res, Temp: TBitmap;
  alpha: double;
  TimeLeft, n, m: integer;
  at, bt: PAlphaTable;
  tinv: double;
begin
  t := 0;
  if (sbm.Width <> tbm.Width) or (sbm.Height <> tbm.Height) then
    raise Exception.Create('Source and Target must have same dimensions.');
  sbm.Canvas.Lock;
  try
    tbm.Canvas.Lock;
    try
      Res := TBitmap.Create;
      try
        Res.Canvas.Lock;
        try
          sbm.PixelFormat := pf24bit;
          tbm.PixelFormat := pf24bit; //just to be safe
          Res.PixelFormat := pf24bit;
          Res.Width := sbm.Width;
          Res.Height := sbm.Height;
          tinv := 1 / TransitTime;
          while (t < TransitTime) and (not fAviWriter.Aborted) do
          begin
            TimeLeft := max(TransitTime - t, 0);
            alpha := AlphaHigh * tinv * TimeLeft;
            n := round(alpha);
            m := AlphaHigh - n;
            at := @FracAlphaTable[n];
            bt := @FracAlphaTable[m];
            Tween3(sbm, tbm, Res, at, bt);
            Temp := TBitmap.Create;
            try
              Temp.Canvas.Lock;
              try
                Temp.PixelFormat := pf24bit;
                Temp.Width := NewWidth;
                Temp.Height := NewHeight;
                CopyRectEx(Temp.Canvas, Rect(0, 0, NewWidth, NewHeight), Res, Rect(0, 0, Res.Width, Res.Height), true);
              finally
                Temp.Canvas.UnLock;
              end;
              fAviWriter.AddFrame(Temp);
            finally
              Temp.Free;
            end;
            t := t + fAviWriter.FrameTime;
          end;
        finally
          Res.Canvas.UnLock;
        end;
      finally
        Res.Free;
      end;
      if (not fAviWriter.Aborted) then
      begin
        Temp := TBitmap.Create;
        try
          Temp.Canvas.Lock;
          try
            Temp.PixelFormat := pf24bit;
            Temp.Width := NewWidth;
            Temp.Height := NewHeight;
            CopyRectEx(Temp.Canvas, Rect(0, 0, NewWidth, NewHeight), tbm, Rect(0, 0, tbm.Width, tbm.Height), true);
          finally
            Temp.Canvas.UnLock;
          end;
          fAviWriter.AddStillImage(Temp, ImageTime - TransitTime);
        finally
          Temp.Free;
        end;
      end;
    finally
      tbm.Canvas.UnLock;
    end;
  finally
    sbm.Canvas.UnLock;
  end;
end; }

procedure TAviThread.CallOnBitmapsDone;
begin
  if Assigned(fOnBitmapsDone) then
    fOnBitmapsDone(Self, fBitmapList, fBitmapList.Count);
end;

procedure TAviThread.AviWriterBadBitmap(Sender: TObject; bmp: TBitmap;
  InfoHeaderSize, BitsSize: integer);
begin
  fError := TBitmap.Create;
  try
    fError.assign(bmp);
    fErrorHeaderSize := InfoHeaderSize;
    fErrorBitsSize := BitsSize;
    SYNCHRONIZE(CallOnBadBitmap);
  finally
    fError.Free;
  end;
end;

procedure TAviThread.CallOnBadBitmap;
begin
  if Assigned(fOnBadBitmap) then
    fOnBadBitmap(Self, fError, fErrorHeaderSize, fErrorBitsSize);
end;

end.

 