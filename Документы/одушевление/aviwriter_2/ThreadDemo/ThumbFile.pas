unit ThumbFile;

/////////////////////////////////////////////////////////////
//                                                         //
//   Copyright:  © 2002 Renate Schaaf                      //
//                                                         //
//   For personal use, do not distribute.                  //
//                                                         //
/////////////////////////////////////////////////////////////


interface

uses Windows, Graphics, SyncObjs;

type

  PThumbFileHeader = ^TThumbFileHeader;

  TThumbFileHeader = packed record
    Signature: DWord;
    RealFilesize: DWord;
    NumberThumbs: Longint;
    void1: Longint;
    void2: Longint;
    void3: Longint;
    //for future use
  end;


  PThumbInfo = ^TThumbInfo;

  TThumbInfo = packed record
    //DataSize: longint; //to know how much to skip to get to the next
    //not necessary, is stored in BitmapInfoHeader
    Tag: Longint; //for user's use, like storing valid/unvalid
    BitmapInfo: TBitmapInfo;
  end;


type
  TThumbFile = class
  //a TThumbFile stores and gives access to a
  //collection of (device independent) bitmaps.
  //they are all pf24 bit, because I'm lazy.
  private
    fNumThumbs: Longint;
    fOffsets: array of Longint;
    fStart: PByte; //pointer to start of file
    fEnd: PByte; //pointer to (current) end of file
    fReadBuff: PByte; //current pointer into the file
    fCurrOffset: Longint; //current offset into the file
    fMaxFilesize, fFileSize: DWord;
    fFilename: string;
    fSaveLock: TCriticalSection;
    fgrowing: boolean;
    function inList(i: Longint): boolean;
    function LocateInfo(i: Longint): PByte;
    procedure Grow;
    function GetTag(i: integer): Longint;
    procedure SetTag(i: integer; const value: Longint);
    function GetThumbInfo(i: integer): TThumbInfo;
    procedure SetThumbInfo(i: integer; const value: TThumbInfo);
    function GetThumbRect(i: integer): TRect;
  protected
    property ThumbInfo[i: integer]: TThumbInfo read GetThumbInfo write SetThumbInfo;
  public
    constructor Create(const filename: string);
    destructor Destroy; override;
    procedure CleanUp(aTagValue: Longint);
    //axe all thumbs that have Tag aTagValue;
    procedure AddThumb(ABmp: TBitmap);
    procedure GetThumb(ABmp: TBitmap; Index: Longint);
    procedure DrawThumb(ACanvas: TCanvas; Index: Longint; Dest: TRect);
    property filename: string read fFilename;
    property Tag[i: Longint]: Longint read GetTag write SetTag;
    property ThumbCount: Longint read fNumThumbs;
    property ThumbRect[i: integer]: TRect read GetThumbRect;
  end;


implementation

uses SysUtils, Classes;

const MySig = $6751AFFE;

{ TThumbFile }

procedure TThumbFile.AddThumb(ABmp: TBitmap);
var DIB: TDIBSection;
  Info: PThumbInfo;
  Buff: PByte;
  step1, step2, step: DWord;
begin
  {make new TThumbinfo record, fill in data,
  save ThumbInfo, flush bits of aBmp, using GetObject(aBmp,aDib),
  update foffsets, fFileSize, fEnd )}
  if ABmp = nil then
    raise Exception.Create('AddThumb: Bitmap must be created.');
  ABmp.PixelFormat := pf24bit; //to be safe
  FillChar(DIB, SizeOf(DIB), 0);
  if GetObject(ABmp.Handle, SizeOf(DIB), @DIB) = 0 then
    RaiseLastOSError
  else
  begin
    step1:=SizeOf(TThumbInfo);
    step2:=Dib.dsbmih.biSizeImage;
    step:=step1+step2;
    if fFilesize>=fMaxFileSize-step then
    grow;
    
    fSaveLock.Enter;
    try
      Buff:=fEnd;
      Info:=PThumbInfo(Buff);
      Info^.Tag:=0;
      Info^.BitmapInfo.bmiHeader := DIB.dsbmih;
      //the rest can stay dirty
      inc(fNumThumbs);
      if Length(fOffsets) < fNumThumbs then
        SetLength(fOffsets, Length(fOffsets) + 20);
      fOffsets[fNumThumbs - 1] := fFileSize;
      
      inc(Buff, step1);
      fEnd := Buff;
      move{DKC17}(DIB.dsBm.bmBits^, Buff^, step2);
      inc(fEnd, step2);
      inc(fFileSize, step);

    finally
      fSaveLock.Leave;
    end;

  end;
end;


procedure TThumbFile.CleanUp(aTagValue: integer);
begin
  {Make TempFile (filestream), flush data with right tag into Tempfile,
  write TempFile's header, save, close. Unmap filename, close, erase.
  Rename TempFile to filename, create file mapping, update offsets,
  fStart, fEnd, fFilesize, fCurrOffset

  does nothing so far}
end;


constructor TThumbFile.Create(const filename: string);
var fh, mh: integer;
  fs, ms: DWord;
  TH: TThumbFileHeader;
  st: TFileStream;
  i, off, doff: integer;
  Info: PThumbInfo;
begin
  fFilename:=Filename;
  if FileExists(filename) then
  begin
    {open file, create file mapping, read Thumbfile-header,
    make array of offsets into the file}
    fh := FileOpen(filename, fmOpenReadWrite or fmShareExclusive);
    if fh < 0 then
      RaiseLastOSError;
    //that would cause the object to be freed immediately, or?
    //I mean, that's what i want...
    fs := GetFileSize(fh, nil);
    ms := fs;
  end
  else
  begin
    {create file}
    fh := FileCreate(filename);
    if fh < 0 then
      RaiseLastOSError;
    FileClose(fh);
    FillChar(TH, SizeOf(TThumbFileHeader), 0);
    TH.Signature := MySig;
    TH.RealFilesize := SizeOf(TThumbFileHeader);
    st := TFileStream.Create(filename, fmOpenReadWrite);
    try
      st.position := 0;
      st.Write(TH, SizeOf(TThumbFileHeader))
    finally
      st.Free;
    end;
    fh := FileOpen(filename, fmOpenReadWrite or fmShareExclusive);
    if fh < 0 then
      RaiseLastOSError;
    fs := GetFileSize(fh, nil);
    ms := fs + 5 * 1024 * 1024; //grow in chunks of 5MB. Could be made a property
  end;

  mh := CreateFileMapping(fh, nil, PAGE_READWRITE, 0, ms, nil);
  if mh = 0 then
  begin
    CloseHandle(fh);
    RaiseLastOSError;
  end;
  CloseHandle(fh);
  fStart := MapViewOfFile(mh, FILE_MAP_WRITE, 0, 0, 0);
  CloseHandle(mh);
  if fStart=nil then
    RaiseLastOSError;
  TH := PThumbFileHeader(fStart)^;
  if TH.Signature <> MySig then
  begin
    UnmapViewOfFile(fStart);
    raise Exception.Create(filename + ' is not a valid thumb file');
  end;

  fFileSize := TH.RealFilesize;
  fEnd := fStart;
  inc(fEnd, fFileSize);

  fMaxFilesize := ms;

  fNumThumbs := TH.NumberThumbs;
  SetLength(fOffsets, fNumThumbs + 20);
  fReadBuff := fStart;
  off := SizeOf(TThumbFileHeader);
  inc(fReadBuff, off);
  Info := PThumbInfo(fReadBuff);
  fOffsets[0]:=off;
  for i := 0 to fNumThumbs - 2 do
  begin
    fOffsets[i] := off;
    doff := Info^.BitmapInfo.bmiHeader.biSizeImage + SizeOf(TThumbInfo);
    inc(off, doff);
    inc(fReadBuff, doff);
    Info := PThumbInfo(fReadBuff);
  end;
  if fNumThumbs>0 then
  fOffsets[fNumThumbs - 1] := off;
  fCurrOffset:=off;

  fSaveLock := TCriticalSection.Create;

end;

destructor TThumbFile.Destroy;
var ph: PThumbFileHeader;
begin
  {flush file mapping, unmap view}
  fSaveLock.Enter;
  ph := PThumbFileHeader(fStart);
  ph^.RealFilesize := fFileSize;
  ph^.Signature := MySig;
  FlushViewOfFile(fStart, 0);
  UnmapViewOfFile(fStart);
  fSaveLock.Leave;
  fSaveLock.Free;
  inherited;
end;

procedure TThumbFile.DrawThumb(ACanvas: TCanvas; Index: integer;
  Dest: TRect);
var Bits: PByte;
  Info: PBitmapInfo;
begin
  if inList(Index) then
  begin
    Bits := LocateInfo(Index);
    Info:=@PThumbInfo(Bits)^.BitmapInfo;

    inc(Bits, SizeOf(TThumbInfo));
    with Dest do
      StretchDIBits(ACanvas.Handle,
        Left, Top, Right - Left, Bottom - Top,
        0, 0, Info.bmiHeader.biWidth, Info.bmiHeader.biHeight,
        Bits, Info^, DIB_RGB_COLORS, SRCCopy);

  end;
end;

function TThumbFile.GetTag(i: integer): Longint;
begin
  Result := -1;
  if inList(i) then
    Result := PThumbInfo(LocateInfo(i))^.Tag;
end;

procedure TThumbFile.GetThumb(ABmp: TBitmap; Index: integer);
var DIB: TDIBSection;
  Info: PThumbInfo;
  Buff: PByte;
begin
  {read data at index, make aBmp the right size, Use GetObject(aBmp, aDib),
   move bitmap data from file to aDib.dsBm.bmBits^. aBmp.modified:=true.
   }
  if ABmp = nil then
    raise Exception.Create('GetThumb: Bitmap must have been created.');
  if inList(Index) then
  begin
    Buff := LocateInfo(Index);
    Info := PThumbInfo(Buff);
    with Info^.BitmapInfo.bmiHeader do
    begin
      ABmp.Width := 0;
      ABmp.PixelFormat := pf24bit;
      ABmp.Width := biWidth;
      ABmp.Height := biHeight;
    end;
    inc(Buff, SizeOf(TThumbInfo));
    FillChar(DIB, SizeOf(DIB), 0);
    GetObject(ABmp.Handle, SizeOf(DIB), @DIB);
    move(Buff^, DIB.dsBm.bmBits^, Info^.BitmapInfo.bmiHeader.biSizeImage);
    ABmp.Modified := true;
  end;
end;

function TThumbFile.GetThumbInfo(i: integer): TThumbInfo;
begin
  FillChar(Result, SizeOf(TThumbInfo), 0);
  if inList(i) then
  {go to fOffsets[i], read in ThumbInfo}
    Result := PThumbInfo(LocateInfo(i))^;
end;

function TThumbFile.GetThumbRect(i: integer): TRect;
var bih: PBitmapInfoHeader;
begin
  Result := Rect(0, 0, 0, 0);
  if inList(i) then
  begin
    bih := @PThumbInfo(LocateInfo(i))^.BitmapInfo.bmiHeader;
    Result := Rect(0, 0, bih^.biWidth, bih^.biHeight);
  end;
end;

procedure TThumbFile.Grow;
var ph: PThumbFileHeader;
  ms: DWord;
  step: DWord;
  fh, mh: integer;
begin
  {flush file mapping, unmap view}
  step := 5 * 1024 * 1025;
  if fFileSize > High(DWord) - step then
    raise Exception.Create('TThumbfile: File cannot grow anymore.');
  //it could but I don't want it to.

  ms := fFileSize + step;
  fSaveLock.Enter;
  fgrowing:=true;
  try
    ph := PThumbFileHeader(fStart);
    ph^.RealFilesize := fFileSize;
    ph^.Signature := MySig;
    FlushViewOfFile(fStart, 0);
    UnmapViewOfFile(fStart);

    fh := FileOpen(fFilename, fmOpenReadWrite or fmShareExclusive);
    if fh < 0 then
      RaiseLastOSError;

    mh := CreateFileMapping(fh, nil, PAGE_READWRITE, 0, ms, nil);
    CloseHandle(fh);
    if mh = 0 then
      RaiseLastOSError;
    fStart := MapViewOfFile(mh, FILE_MAP_WRITE, 0, 0, 0);
    CloseHandle(mh);
    if fStart = nil then
      RaiseLastOSError;
    fEnd := fStart;
    inc(fEnd, fFileSize);
    fReadBuff:=fStart;
    inc(fReadBuff,fCurrOffset);
    fMaxFilesize:=ms;
  finally
    fgrowing:=false;
    fSaveLock.Leave;
  end;
end;

function TThumbFile.inList(i: integer): boolean;
begin
  if fgrowing then
  begin
    Result:=false;
    exit;
  end;  
  Result := (i >= 0) and (i < fNumThumbs);
  if not Result then
    raise Exception.Create('Index out of bounds');
end;

function TThumbFile.LocateInfo(i: integer): PByte;
begin
  Result := nil;
  if inList(i) then
  begin
    inc(fReadBuff,fOffsets[i]-fCurrOffset);
    fCurrOffset:=fOffsets[i];
    Result := fReadBuff;
  end;
end;

procedure TThumbFile.SetTag(i: integer; const value: Longint);
begin
  if inList(i) then
    PThumbInfo(LocateInfo(i))^.Tag := value;
end;

procedure TThumbFile.SetThumbInfo(i: integer; const value: TThumbInfo);
var PInfo: PThumbInfo;
begin
  if inList(i) then
  begin
    PInfo := PThumbInfo(LocateInfo(i));
    PInfo^ := value;
  end;
end;

end.

