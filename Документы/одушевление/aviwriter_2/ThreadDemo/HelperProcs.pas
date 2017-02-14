unit HelperProcs;

/////////////////////////////////////////////////////////////
//                                                         //
//   Copyright:  © 2002 Renate Schaaf                      //
//                                                         //
//   (unless noted otherwise)                              //
//                                                         //
//   For personal use, do not distribute.                  //
//                                                         //
/////////////////////////////////////////////////////////////
interface

uses Windows, Graphics, Classes, Controls;

function DeleteFolder(
  const folderName: string
  ): boolean;
(*Erases a nonempty folder*)
(*returns true unless error or user abort*)
(*Routine by Philip Ranger*)

function DeleteFolderContent(
  const folderName: string
  ): boolean;
(*Erases the content of the given folder*)
(*Routine by Philip Ranger*)

function PathGetLongName(
  const Path: string
  ): string;
//from JCLFileUtils:
//Returns the long form of a given path name
//(versus C:\Progr~1).

function IsOpenInExplorer(
  const folderName: string;
  var h: THandle
  ): boolean;

function ExtractFolder(const filename: string): string;

function GetJpegSize(
  Stream: TStream): TPoint;
{by Finn Tolderlund, Thanks! Use to read width/height of
a jpeg from a filestream without actually loading the file
into a TJpegImage.
It needs to be speed optimized, though. I tried a bit,
but it's still too slow.}

function LoadThumbFromBMPStream(
  const ABmp: TBitmap;
  const AStream: TStream;
  ForThumbHeight: integer
  ): boolean;

procedure LoadThumbFromBMPFile(
  const ABmp: TBitmap;
  const filename: string;
  ForThumbHeight: integer);
//no result, we throw exceptions. Yes.

function LoadThumbFromJpegStream(
  const Bitmap: TBitmap;
  const Stream: TStream;
  ForThumbHeight: integer
  ): boolean;

function LoadThumbFromJpegFile
  (const Bitmap: TBitmap;
  const filename: string;
  ForThumbHeight: integer
  ): boolean;

procedure CopyRectEx(
  ADest: TCanvas;
  DestR: TRect;
  aSource: TBitmap;
  SourceR: TRect;
  SmoothStretch: boolean);

procedure MakeThumbNail(Src, Dest: TBitmap);
// By Roy Magne Klever

procedure MakeThumbNailMod(const Src, Dest: TBitmap);
// By Roy Magne Klever
// modified a bit

procedure MakeThumbNailFloat(const Src, Dest: TBitmap);

procedure Upsample(const Src, Dest: TBitmap);

procedure MakeThumb(const Src, Dest: TBitmap);

type TAlphaTable = array[0..255] of byte;
  PAlphaTable = ^TAlphaTable;

const AlphaHigh = 255;

var FracAlphaTable: array of TAlphaTable;

procedure SharpenMod(
  const Src, Dest: TBitmap;
  alpha: Single);

procedure Tween3(
  const sbm1, sbm2, tbm: TBitmap;
  const at, bt: PAlphaTable);

function ScreenRect(
  AControl: TControl
  ): TRect;

procedure DrawSelFrame(
  AControl: TControl;
  dx, dy: integer);


implementation

{$DEFINE JPG}
//Define if you have JPG.pas and want to use a nicer
//thumb routine

uses SysUtils, ShellApi, ShlObj, ActiveX, jpeg, math
{$IFDEF JPG}
  , jpg
{$ENDIF}
  ;



procedure MakeFracAlphaTable;
var i, j: integer;
  alpha: double;
begin
  SetLength(FracAlphaTable, AlphaHigh + 1);
  for i := 0 to AlphaHigh do
  begin
    alpha := 1 / AlphaHigh * i;
    for j := 0 to 254 do
      FracAlphaTable[i][j] := trunc(alpha * j);
    FracAlphaTable[i][255] := trunc(alpha * 255);
  end;
end;

function DeleteFolder(const folderName: string): boolean;
(*Erases a nonempty folder*)
(*returns true unless error or user abort*)
var
  r: TSHFileOpStruct;
  i: DWord;
  S: string;
begin
  S := folderName + #0#0;
  Result := false;
  i := GetFileAttributes(PChar(S));
  if (i = $FFFFFFFF) or ((i and FILE_ATTRIBUTE_DIRECTORY) = 0) then exit;

  FillChar(r, SizeOf(r), 0);
  r.wFunc := FO_DELETE;
  r.pFrom := PChar(S);
  r.fFlags := FOF_NOCONFIRMATION;

  Result := (0 = SHFileOperation(r)) and
    (not r.fAnyOperationsAborted) and (GetFileAttributes(PChar(S)) = $FFFFFFFF);
end;

function DeleteFolderContent(const folderName: string): boolean;
begin
  Result := DeleteFolder(folderName);
  if Result then
    Result := CreateDir(folderName);
end;

function PathGetLongName(const Path: string): string;
var
  Pidl: PItemIdList;
  Desktop: IShellFolder;
  AnsiName: AnsiString;
  WideName: array[0..MAX_PATH] of WideChar;
  Eaten, Attr: ULONG; // both unused but API requires them (incorrect translation)
begin
  Result := Path;
  if Path <> '' then
  begin
    if Succeeded(SHGetDesktopFolder(Desktop)) then
    begin
      MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, PChar(Path), -1, WideName, MAX_PATH);
      if Succeeded(Desktop.ParseDisplayName(0, nil, WideName, Eaten, Pidl, Attr)) then
      try
        SetLength(AnsiName, MAX_PATH);
        if SHGetPathFromIdList(Pidl, PChar(AnsiName)) then
          Result := PChar(AnsiName);
      finally
        CoTaskMemFree(Pidl);
      end;
    end;
  end;
end;

function IsOpenInExplorer(const folderName: string; var h: THandle): boolean;
begin
  Result := false;
  if folderName <> '' then
  begin
    h := FindWindow(PChar('CabinetWClass'), PChar(folderName));
    if h = 0 then
      h := FindWindow(PChar('CabinetWClass'), PChar(ExtractFileName(folderName)));
    Result := (h <> 0);
  end;
end;

function ExtractFolder(const filename: string): string;
begin
  Result := ExtractFilePath(filename);
  if Result[Length(Result)] = '\' then
    Result := copy(Result, 1, Length(Result) - 1);
end;





procedure ReadBMPHeader(const AStream: TStream; var BmpHdr: TBitmapInfoHeader; var IsOS2: boolean);
var
  FileHdr: TBitmapFileHeader;
  InfoHeaderPosition, HeaderSize: integer;
begin
  IsOS2 := true;
  AStream.ReadBuffer(FileHdr, SizeOf(TBitmapFileHeader));
  if FileHdr.bfType <> $4D42 then
    raise EInvalidGraphic.Create('Bitmap is invalid');

  //Read Headers:
  InfoHeaderPosition := AStream.position;
  AStream.read(HeaderSize, SizeOf(HeaderSize));
  IsOS2 := (HeaderSize = SizeOf(TBitmapCoreHeader));
  if not IsOS2 then
  begin
    AStream.position := InfoHeaderPosition;
    AStream.ReadBuffer(BmpHdr, SizeOf(TBitmapInfoHeader));
  end;
end;

procedure ReadBMPPixels(const ABmp: TBitmap; const AStream: TStream; var BmpHdr: TBitmapInfoHeader; ScaleDen: integer);

var
  ColorBytes, RowSize, PixelSize, Rowstep, Colstep,
    BmpWidth, BmpHeight, DIBPadBytes: integer;
  DIB: TDIBSection;
  Quads, Col, Row, Quad, Triple: PByte;
  i, j: integer;
  WidthChunks, HeightChunks: integer;
begin
  //Scaling is 1/ScaleDen
  with BmpHdr do
  begin
    if biClrUsed = 0 then
      if biBitCount < 16 then
        biClrUsed := 1 shl biBitCount
      else
        biClrUsed := 0;
    ColorBytes := SizeOf(TRGBQuad) * biClrUsed;
    RowSize := (((biWidth * biBitCount) + 31) and not 31) shr 3;
    PixelSize := biBitCount shr 3;
    Colstep := ScaleDen * PixelSize;
    Rowstep := (ScaleDen - 1) * RowSize;
    //TargetChunk := ScaleNum * 3;
    WidthChunks := biWidth div ScaleDen;
    HeightChunks := biHeight div ScaleDen;

    with ABmp do
    begin
      BmpWidth := WidthChunks;
      BmpHeight := HeightChunks;
      Width := 0;
      PixelFormat := pf24bit;
      Width := BmpWidth;
      Height := BmpHeight;
    end;
      //GetDIB from ABMP
    GDIFlush; //Necessary and right place to call?
    FillChar(DIB, SizeOf(DIB), 0);
    GetObject(ABmp.Handle, SizeOf(DIB), @DIB);

    GetMem(Quads, ColorBytes);
    GetMem(Row, RowSize);
    try
      AStream.ReadBuffer(Quads^, ColorBytes);
        //Pad bytes for 4 bytes alignment of rows:
      DIBPadBytes := ((((BmpWidth * 3) + 3) div 4) * 4) - (BmpWidth * 3);
      //Triple points to beginning of DIB-bits:
      Triple := DIB.dsBm.bmBits;
      //Row := AStream.Memory;
      //inc(Row, AStream.position);
      //row now points to beginning of pixels in stream
      if (PixelSize = 3) or (PixelSize = 4) then
      begin
        for i := 1 to HeightChunks do
        begin
          AStream.ReadBuffer(Row^, RowSize);
          Col := Row;

          for j := 1 to WidthChunks do
          begin
            pRGBTriple(Triple)^ := pRGBTriple(Col)^;
            inc(Col, Colstep);
            inc(Triple, 3);
          end;
          inc(Triple, DIBPadBytes);
          //inc(Row, Rowstep);
          AStream.Seek(Rowstep, soFromCurrent)
        end;
      end;


      if PixelSize = 1 then
      begin
        for i := 1 to HeightChunks do
        begin
          AStream.ReadBuffer(Row^, RowSize);
          Col := Row;
          for j := 1 to WidthChunks do
          begin
            Quad := Quads;
            inc(Quad, Col^ * SizeOf(TRGBQuad));
            pRGBTriple(Triple)^ := pRGBTriple(Quad)^;
              //move(Quad^, Triple^, 3);
            inc(Col, ScaleDen);
            inc(Triple, 3);
          end;
          inc(Triple, DIBPadBytes);
          //inc(Row, Rowstep);
          AStream.Seek(Rowstep, soFromCurrent);
        end;
      end;

      ABmp.Modified := true;

    finally
      FreeMem(Quads);
      FreeMem(Row);
    end;
  end;
end;

procedure LoadThumbFromBMPFile(
  const ABmp: TBitmap;
  const filename: string;
  ForThumbHeight: integer);
var fh, mh: integer;
  Start, Buff: PByte;
  IHeader: TBitmapInfoHeader;
  ScaleNum, ScaleDen: integer;
  ColorBytes, RowSize, PixelSize, Rowstep, Colstep,
    DIBPadBytes: integer;
  DIB: TDIBSection;
  Quads, Col, Quad, Triple: PByte;
  i, j: integer;
  WidthChunks, HeightChunks: integer;

  procedure Backout;
  begin
    UnmapViewOfFile(Start);
    ABmp.loadfromfile(filename);
  end;

begin
  fh := FileOpen(filename, fmOpenRead or fmShareDenyWrite);
  if fh < 0 then
    RaiseLastOSError;
  mh := CreateFileMapping(fh, nil, PAGE_READONLY, 0, 0, nil);
  CloseHandle(fh);
  if mh = 0 then
    RaiseLastOSError;
  Start := MapViewOfFile(mh, FILE_MAP_READ, 0, 0, 0);
  CloseHandle(mh);
  if Start = nil then
    RaiseLastOSError;
  Buff := Start;
  if PBitmapFileHeader(Buff)^.bfType <> $4D42 then
    raise EInvalidGraphic.Create('Bitmap is invalid');

  //Read Headers:
  inc(Buff, SizeOf(TBitmapFileHeader));
  if PInteger(Buff)^ = SizeOf(TBitmapCoreHeader) then
  //is an OS2 Bm
    Backout;

  IHeader := PBitmapInfoHeader(Buff)^;
  with IHeader do
  begin
    if not (((biBitCount = 8) or (biBitCount >= 24)) and (biCompression = BI_RGB)) then
      Backout; //Too dumb to do those.

    ScaleNum := trunc(16 * ForThumbHeight / biHeight + 1);
    if ScaleNum = 1 then
      ScaleDen := 16
    else
      if ScaleNum = 2 then
        ScaleDen := 8
      else
        if ScaleNum < 5 then
          ScaleDen := 4
        else
          if ScaleNum < 9 then
            ScaleDen := 2
          else
            ScaleDen := 1;
    if ScaleDen = 1 then
      Backout;

    if biClrUsed = 0 then
      if biBitCount < 16 then
        biClrUsed := 1 shl biBitCount
      else
        biClrUsed := 0;
    ColorBytes := SizeOf(TRGBQuad) * biClrUsed;
    RowSize := (((biWidth * biBitCount) + 31) and not 31) shr 3;
    PixelSize := biBitCount shr 3;
    Colstep := ScaleDen * PixelSize;
    Rowstep := ScaleDen * RowSize;
    WidthChunks := biWidth div ScaleDen;
    HeightChunks := biHeight div ScaleDen;

  end; //with IHeader

  with ABmp do
  begin
    Width := 0;
    PixelFormat := pf24bit;
    Width := WidthChunks;
    Height := HeightChunks;
  end;
      //GetDIB from ABMP
  GDIFlush; //Necessary and right place to call?
  FillChar(DIB, SizeOf(DIB), 0);
  GetObject(ABmp.Handle, SizeOf(DIB), @DIB);

  inc(Buff, SizeOf(TBitmapInfoHeader));

  GetMem(Quads, ColorBytes);
  try
    if ColorBytes > 0 then
    begin
      move(Buff^, Quads^, ColorBytes);
      inc(Buff, ColorBytes);
    end;
        //Pad bytes for 4 bytes alignment of rows:
    DIBPadBytes := ((((WidthChunks * 3) + 3) div 4) * 4) - (WidthChunks * 3);
      //Triple points to beginning of DIB-bits:
    Triple := DIB.dsBm.bmBits;
    //buff now points to beginning of pixels in stream
    if (PixelSize = 3) or (PixelSize = 4) then
    begin
      for i := 1 to HeightChunks do
      begin
        Col := Buff;

        for j := 1 to WidthChunks do
        begin
          pRGBTriple(Triple)^ := pRGBTriple(Col)^;
          inc(Col, Colstep);
          inc(Triple, 3);
        end;

        inc(Triple, DIBPadBytes);
        inc(Buff, Rowstep);
      end;
    end;


    if PixelSize = 1 then
    begin
      for i := 1 to HeightChunks do
      begin
        Col := Buff;
        for j := 1 to WidthChunks do
        begin
          Quad := Quads;
          inc(Quad, Col^ * SizeOf(TRGBQuad));
          pRGBTriple(Triple)^ := pRGBTriple(Quad)^;
          inc(Col, ScaleDen);
          inc(Triple, 3);
        end;
        inc(Triple, DIBPadBytes);
        inc(Buff, Rowstep);
      end;
    end;

    ABmp.Modified := true;

  finally
    FreeMem(Quads);
  end;
  UnmapViewOfFile(Start);
end;


function LoadThumbFromBMPStream(
  const ABmp: TBitmap;
  const AStream: TStream;
  ForThumbHeight: integer
  ): boolean;

var
  BmpHdr: TBitmapInfoHeader;
  OrgPosition: integer;
  ScaleNum, ScaleDen: integer;
  IsOS2, DoRead: boolean;
begin
  Result := false;
  if ABmp = nil then
    exit;
  if AStream = nil then
    exit;

  OrgPosition := AStream.position;
  //Read Headers:
  ReadBMPHeader(AStream, BmpHdr, IsOS2);
  DoRead := not IsOS2;
  if DoRead then
    with BmpHdr do
      DoRead := ((biBitCount = 8) or (biBitCount >= 24)) and (biCompression = BI_RGB);

  if not DoRead then
  begin
    AStream.position := OrgPosition;
    ABmp.PixelFormat := pf24bit;
    ABmp.LoadFromStream(AStream);
    Result := true;
    exit;
  end;

  with BmpHdr do
  begin
    ScaleNum := trunc(16 * ForThumbHeight / biHeight + 1);
    if ScaleNum = 1 then
      ScaleDen := 16
    else
      if ScaleNum = 2 then
        ScaleDen := 8
      else
        if ScaleNum < 5 then
          ScaleDen := 4
        else
          if ScaleNum < 9 then
            ScaleDen := 2
          else
            ScaleDen := 1;
    if ScaleDen = 1 then
    //direct loading is faster
    begin
      AStream.position := OrgPosition;
      ABmp.PixelFormat := pf24bit;
      ABmp.LoadFromStream(AStream);
      Result := true;
      exit;
    end;
  end;

  ReadBMPPixels(ABmp, AStream, BmpHdr, ScaleDen);
  Result := true;
end;

var tbljpeg1, tbljpeg2: array[byte] of byte;

procedure makejpegtables;
var b: byte;
begin
  for b := Low(byte) to High(byte) do
  begin
    tbljpeg1[b] := 0;
    tbljpeg2[b] := 0;
    if b = $FF then
    begin
      tbljpeg1[b] := 1;
      tbljpeg2[b] := 1;
    end
    else
      if b in [$D8, $DA] then
        tbljpeg1[b] := 2
      else
        if b in [$C0, $C1, $C2] then
          tbljpeg2[b] := 2;
  end;
end;

function GetJpegSize2(Stream: TStream): TPoint; //umh
var jpeg: TJPegImage;
begin
  jpeg := TJPegImage.Create;
  try
    jpeg.LoadFromStream(Stream);
    Result.x := jpeg.Width;
    Result.y := jpeg.Height;
  finally
    jpeg.Free;
  end;
end;

{$IFDEF JPG}

function GetJpegSize3(Stream: TStream): TPoint; overload;
// the fastest but requires JPG.pas by Mike Lischke
// www.lischke-online.de
var w, h: Cardinal;
begin
  GetJpegInfo(Stream, w, h);
  Result.x := w; Result.y := h;
end;

function GetJpegSize3(const filename: string): TPoint; overload;
var w, h: Cardinal;
begin
  GetJpegInfo(filename, w, h);
  Result.x := w; Result.y := h;
end;
{$ENDIF}


function GetJpegSize(Stream: TStream): TPoint;
//still too slow
var
  fs: TStream;
  SegmentPos: integer;
  SOIcount: integer;
  x, y: Word;
  b: byte;
  db: array[1..2] of byte;
  fpos, fsize: integer;
  p: byte;
begin
  //fs := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  //try
  fs := Stream; //to save retyping
  fs.position := 0;
  fs.read(x, 2);
  if x <> $D8FF then
    raise Exception.Create('Not a Jpeg file');
  SOIcount := 0;
  fs.position := 0;
  fpos := 0;
  fsize := fs.Size;
  while fpos + 7 < fsize do
  begin
    fs.read(db, 2);
    inc(fpos, 2);
    p := tbljpeg1[db[2]];
    if p <> 0 then
    begin
      if p = 2 then
        if tbljpeg1[db[1]] <> 1 then
          Continue
        else
          b := db[2]
      else
      begin
        fs.read(b, 1);
        p := tbljpeg1[b];
        if p = 1 then
          fs.Seek(-1, soFromCurrent)
        else
          inc(fpos);
        if p <> 2 then
          Continue;
      end;
      if b = $D8
        then
        inc(SOIcount)
      else
        Break;
    end;
  end;
       { fs.Read(b,1);
        if b = $FF then
          begin
            fs.Read(b, 1);
            if b = $D8 then
              Inc(SOIcount);
            if b = $DA then
              Break;
          end;
      end;}
  if b <> $DA then
    raise Exception.Create('Corrupt Jpeg file');
  SegmentPos := -1;
  fs.position := 0;
  fpos := 0;
  while fpos + 7 < fsize do
  begin
    fs.read(db, 2);
    inc(fpos, 2);
    p := tbljpeg2[db[2]];
    if p <> 0 then
    begin
      if p = 2 then
        if tbljpeg2[db[1]] <> 1 then
          Continue
        else
          b := db[2]
      else
      begin
        fs.read(b, 1);
        p := tbljpeg2[b];
        if p = 1 then
          fs.Seek(-1, soFromCurrent)
        else
          inc(fpos);
        if p <> 2 then
          Continue;
      end;
      if b in [$C0, $C1, $C2] then //should always be true here..
      begin
        SegmentPos := fpos;
        Dec(SOIcount);
        if SOIcount = 0 then
          Break;
      end;
    end;
  end;

        {fs.Read(b, 1);
        if b = $FF then
          begin
            fs.Read(b, 1);
            if b in [$C0, $C1, $C2] then
              begin
                SegmentPos := fs.Position;
                Dec(SOIcount);
                if SOIcount = 0 then
                  Break;
              end;
          end; }
  if SegmentPos = -1 then
    raise Exception.Create('Corrupt Jpeg file');
  if SegmentPos + 7 > fsize then
    raise Exception.Create('Corrupt Jpeg file');
  fs.position := SegmentPos + 3;
  fs.read(y, 2);
  fs.read(x, 2);
  Result := Point(Swap(x), Swap(y));
  //finally
  //  fs.Free;
  //end;
end;




function LoadFromJpegStream(const Bitmap: TBitmap; const Stream: TStream;
  SkipWidth: integer): boolean;
var Skip: TJpegScale;
  aJpeg: TJPegImage;
  orgpos: integer;
begin
  Result := false;
  if Bitmap = nil then
    exit;
  if Stream = nil then
    exit;
  orgpos := Stream.position;
  Stream.position := orgpos;
  if SkipWidth >= 10 then
  begin
    Skip := jsEighth;
  end
  else
    if SkipWidth >= 5 then
    begin
      Skip := jsQuarter;
    end
    else
      if SkipWidth >= 3 then
      begin
        Skip := jsHalf;
      end
      else
      begin
        Skip := jsFullSize;
      end;
  aJpeg := TJPegImage.Create;
  try
    aJpeg.scale := Skip;
    aJpeg.LoadFromStream(Stream);
    Bitmap.Width := 0;
    Bitmap.assign(aJpeg);
    Bitmap.PixelFormat := pf24bit;
  finally
    aJpeg.Free;
  end;
  Result := true;
end;


function LoadThumbFromJpegStream(const Bitmap: TBitmap; const Stream: TStream;
  ForThumbHeight: integer): boolean;
var SkipWidth: integer;
{$IFDEF JPG}
  orgpos, OrgHeight: integer;
  p: TPoint;
{$ENDIF}
begin
{$IFDEF JPG}
  orgpos := Stream.position;
  p := GetJpegSize3(Stream);
  OrgHeight := p.y;
  Stream.position := orgpos;
  SkipWidth := OrgHeight div ForThumbHeight;
{$ELSE}
  SkipWidth := 800 div ForThumbHeight;
{$ENDIF}
  Result := LoadFromJpegStream(Bitmap, Stream, SkipWidth);
end;

function LoadThumbFromJpegFile(const Bitmap: TBitmap; const filename: string;
  ForThumbHeight: integer): boolean;
var strm: TFileStream;
begin
  strm := TFileStream.Create(filename, fmOpenRead or fmShareDenyWrite);
  try
    Result := LoadThumbFromJpegStream(Bitmap, strm, ForThumbHeight);
  finally
    strm.Free;
  end;
end;

procedure CopyRectEx(ADest: TCanvas; DestR: TRect; aSource: TBitmap; SourceR: TRect; SmoothStretch: boolean);
var //aDC, bDC: HDC;  //no, it's better to not cache the handles in threads.
  OldPalette: Hpalette;
  pt: TPoint;

begin
  OldPalette := SelectPalette(ADest.Handle, aSource.Palette, true);
  realizepalette(ADest.Handle);
  //Note: SmoothStretch has no effect under Toy-Windows, an acknowlegded bug.
  if SmoothStretch then
  begin
    GetBrushOrgEx(ADest.Handle, pt);
    SetStretchBltMode(ADest.Handle, STRETCH_HALFTONE);
    SetBrushOrgEx(ADest.Handle, pt.x, pt.y, @pt);
  end
  else
    SetStretchBltMode(ADest.Handle, STRETCH_DELETESCANS);
  StretchBlt(ADest.Handle, DestR.Left, DestR.Top, DestR.Right - DestR.Left, DestR.Bottom - DestR.Top, aSource.Canvas.Handle, SourceR.Left, SourceR.Top, SourceR.Right - SourceR.Left, SourceR.Bottom - SourceR.Top, SRCCopy);
  SelectPalette(ADest.Handle, OldPalette, true);
end;

procedure ClampByte(i: integer; var Result: byte);
begin
  if i < 0 then
    Result := 0
  else
    if i > 255 then
      Result := 255
    else
      Result := i;
 //not sure this is optimized,
                       //but I guess it's better than
                       //max(min(i,255),0)
end;

//procedure MakeThumbnailMod
//Original source: Roy Magne Klever
//Altered to avoid division by 0
//and tried to make it a bit faster (RS)

type
  PRGB24 = ^TRGB24;
  TRGB24 = packed record
    b: byte;
    g: byte;
    r: byte;
  end;
  TLine24 = array[0..maxint div SizeOf(TRGB24) - 1] of TRGB24;
  PLine24 = ^TLine24;

  TIntArray = array of integer;
  TDeltaArray = array of array of integer;

procedure MakeAlphas(xscale, yscale: Single; xw, yh: integer; var dxmin, dymin: integer; var alphas: TDeltaArray; var xsteps, ysteps: TIntArray);
var i, j: integer;
  x1, x2: integer;
  dxmax, dymax, intscale: integer;
  fact: Single;
begin
  SetLength(xsteps, xw);
  SetLength(ysteps, yh);
  intscale := round(xscale * $10000);
  //won't work if xcale > $10000/2, because then intscale
  //exceeds 32bit integer. I don't see that happening.
  x1 := 0;
  x2 := intscale shr 16;
  for i := 0 to xw - 1 do
  begin
    xsteps[i] := x2 - x1;
    x1 := x2;
    x2 := (i + 2) * intscale shr 16;
  end;
  dxmin := Ceil(xscale - 1);
  dxmax := trunc(xscale + 1);

  intscale := round(yscale * $10000);
  x1 := 0;
  x2 := intscale shr 16;
  for i := 0 to yh - 1 do
  begin
    ysteps[i] := x2 - x1;
    x1 := x2;
    x2 := (i + 2) * intscale shr 16;
  end;
  dymin := Ceil(yscale - 1);
  dymax := trunc(yscale + 1);
  SetLength(alphas, dxmax - dxmin + 1, dymax - dymin + 1);
  for i := 0 to dxmax - dxmin do
  begin
    fact := 1 / (dxmin + i);
    for j := 0 to dymax - dymin do
      alphas[i, j] := round(fact / (dymin + j) * $10000);
  end;
end;


procedure MakeThumbNailMod(const Src, Dest: TBitmap);
var
  xscale, yscale: Single;
  x1: integer;
  ix, iy: integer;
  totalRed, totalGreen, totalBlue: integer;
  ratio: integer;
  p: PRGB24;
  pt1: PRGB24;
  ptrD, ptrS: integer;
  x, y: integer;
  r1, r2: TRect;
  x3: integer;
  RowDest, RowSource, RowSourceStart: integer;
  alphas: TDeltaArray;
  xsteps, ysteps: TIntArray;
  w, h, dxmin, dymin: integer;
  dx, dy: integer;
  Work: TBitmap;

begin
  if (Dest.Width <= 0) or (Dest.Height <= 0) then
    raise Exception.Create('Destination must have positive width and height');
  if (Dest.Width >= Src.Width) or (Dest.Height >= Src.Height) then
  begin
    r1 := Rect(0, 0, Src.Width, Src.Height);
    r2 := r1;
    OffsetRect(r2, (Dest.Width - Src.Width) div 2, (Dest.Height - Src.Height) div 2);
    Dest.Canvas.CopyRect(r2, Src.Canvas, r1);
    exit;
  end;
  Src.PixelFormat := pf24bit;
  Dest.PixelFormat := pf24bit; //safety
  Work := TBitmap.Create;
  Work.PixelFormat := pf24bit;
  w := Dest.Width;
  h := Dest.Height;
  Work.Width := w;
  Work.Height := h;
  ptrD := (w * 24 + 31) and not 31;
  ptrD := ptrD div 8; //BytesPerScanline
  ptrS := (Src.Width * 24 + 31) and not 31;
  ptrS := ptrS div 8;

  xscale := Src.Width / w;
  yscale := Src.Height / h; //turns div into mults
  MakeAlphas(xscale, yscale, w, h, dxmin, dymin, alphas, xsteps, ysteps);
  //Make 3 lookup tables for the steps and the ratios

  w := w - 1;
  h := h - 1;
  RowDest := integer(Work.Scanline[0]);
  RowSourceStart := integer(Src.Scanline[0]);
  RowSource := RowSourceStart;
  for y := 0 to h do begin
    dy := ysteps[y];
    x1 := 0;
    x3 := 0;
    for x := 0 to w do begin
      dx := xsteps[x];
      totalRed := 0;
      totalGreen := 0;
      totalBlue := 0;
      RowSource := RowSourceStart;
      for iy := 1 to dy do
      begin
        p := PRGB24(RowSource + x1);
        for ix := 1 to dx do begin
          totalRed := totalRed + p^.r;
          totalGreen := totalGreen + p^.g;
          totalBlue := totalBlue + p^.b;
          inc(p);
        end;
        RowSource := RowSource - ptrS;
      end;
      pt1 := PRGB24(RowDest + x3);
      ratio := alphas[dx - dxmin, dy - dymin];
      pt1^.r := (totalRed * ratio) shr 16;
      pt1^.g := (totalGreen * ratio) shr 16;
      pt1^.b := (totalBlue * ratio) shr 16;
      x1 := x1 + 3 * dx;
      x3 := x3 + 3;
    end;
    RowDest := RowDest - ptrD;
    RowSourceStart := RowSource;
  end;
  SharpenMod(Work, Dest, min(1 + 0.4 * (xscale - 1),2.5));
  Work.Free;
end;

type
  TStep = record
    Steps, jump: integer;
    weights: array[0..3] of integer;
  end;

  TStepsArray = array of TStep;

procedure MakeWeights(xscale, yscale: Single; xw, yh, xsw, ysh, SourceBytes: integer; var xsteps, ysteps: TStepsArray);
var i, j: integer;
  x, xcenter: integer;
  intscale, Left,
    newleft, newright, radInt,
    maxsteps: integer;
  fact: single;
  Weight, total: integer;
  function filter(x: integer): integer;
  begin
    if x < -$10000 then
      Result := 0
    else
      if x < 0 then
        Result := x + $10000
      else
        if x < $10000 then
          Result := $10000 - x
        else
          Result := 0;
  end;
begin
  SetLength(xsteps, xw);
  SetLength(ysteps, yh);
  //xswint := (xsw - 2) * $100;
 // yshint := (ysh - 2) * $100;
  intscale := round(xscale * $10000);
  radInt := round(1 * $10000);
  //won't work if xcale > $10000/2, because then intscale
  //exceeds 32bit integer. I don't see that happening.
  Left := 0;
  xcenter := 0;
  for i := 0 to xw - 1 do
  begin
    newleft := max(xcenter - radInt, 0) shr 16;
    newright := (xcenter + radInt + $FFFF) shr 16;
    if newright >= xsw then newright := xsw - 1;
    maxsteps := newright - newleft;
    newleft := newleft - 1;
    with xsteps[i] do
    begin
      //x := newleft shl 16;
      Total := 0;
      j := -1;
      Weight := 0;
      while (Weight = 0) and (j <= maxsteps) do
      begin
        inc(newleft);
        x := newleft shl 16;
        Weight := filter(xcenter - x);
        inc(j);
      end;
      Steps := -1;
      x := newleft shl 16;
      while (j <= maxsteps) and (Weight > 0) do
      begin
        Total := Total + Weight;
        inc(Steps);
        weights[Steps] := weight;
        inc(x, $10000);
        inc(j);
        Weight := filter(xcenter - x);
      end;
      if Steps >= 0 then
      begin
        fact := $1000 / Total;
        for j := 0 to Steps do
          weights[j] := round(weights[j] * fact);
      end
      else
      begin
        Steps := 0;
        newleft := newleft - 1;
        weights[0] := $1000;
      end;
    end;
    xsteps[i].jump := 3 * (newleft - left);
    Left := newleft;
    inc(xcenter, intscale);
  end;

  intscale := round(yscale * $10000);
  Left := 0;
  xcenter := 0;
  for i := 0 to yh - 1 do
  begin
    newleft := max(xcenter - radInt, 0) shr 16;
    newright := (xcenter + radInt + $FFFF) shr 16;
    if newright >= ysh then newright := ysh - 1;
    maxsteps := newright - newleft;
    newleft := newleft - 1;
    with ysteps[i] do
    begin
     // x := newleft shl 16;
      Total := 0;
      j := -1;
      Weight := 0;
      while (Weight = 0) and (j <= maxsteps) do
      begin
        inc(newleft);
        x := newleft shl 16;
        Weight := filter(xcenter - x);
        inc(j);
      end;
      Steps := -1;
      x := newleft shl 16;
      while (j <= maxsteps) and (Weight > 0) do
      begin
        Total := Total + Weight;
        inc(Steps);
        weights[Steps] := weight;
        inc(x, $10000);
        inc(j);
        Weight := filter(xcenter - x);
      end;
      if Steps >= 0 then
      begin
        fact := $1000 / Total;
        for j := 0 to Steps do
          weights[j] := round(weights[j] * fact);
      end
      else
      begin
        Steps := 0;
        newleft := newleft - 1;
        weights[0] := $1000;
      end;
    end;
    ysteps[i].jump := SourceBytes * (newleft - left);
    Left := newleft;
    inc(xcenter, intscale);
  end;
end;


procedure Upsample(const Src, Dest: TBitmap);
var
  xscale, yscale: Single;
  x1: integer;
  ix, iy: integer;
  totalRed, totalGreen, totalBlue: integer;
  xRed, xGreen, xBlue: integer;
  ratio: integer;
  p: PRGB24;
  q: PByte;
  pt1: PRGB24;
  ptrD, ptrS: integer;
  x, y: integer;
  r1, r2: TRect;
  x3: integer;
  RowDest, RowSource, RowSourceStart: integer;
  xsteps, ysteps: TStepsArray;
  w, h, dxmin, dymin: integer;
  xweight, yweight: integer;
  dx, dy: integer;
  xstart, ystart: PByte;

begin
  if (Src.Width <= 2) or (Src.Height <= 2) then
    raise Exception.Create('Source must have width and height >2');
  if (Dest.Width <= Src.Width) or (Dest.Height <= Src.Height) then
  begin
    r1 := Rect(0, 0, Src.Width, Src.Height);
    r2 := r1;
    OffsetRect(r2, (Dest.Width - Src.Width) div 2, (Dest.Height - Src.Height) div 2);
    Dest.Canvas.CopyRect(r2, Src.Canvas, r1);
    exit;
  end;
  Src.PixelFormat := pf24bit;
  Dest.PixelFormat := pf24bit; //safety
  w := Dest.Width;
  h := Dest.Height;
  ptrD := (w * 24 + 31) and not 31;
  ptrD := ptrD div 8; //BytesPerScanline
  ptrS := (Src.Width * 24 + 31) and not 31;
  ptrS := ptrS div 8;

  xscale := (Src.Width - 1) / (w - 1);
  yscale := (Src.Height - 1) / (h - 1); //turns div into mults
  MakeWeights(xscale, yscale, w, h, Src.Width, Src.Height, -ptrS, xsteps, ysteps);
  //Make 3 lookup tables for the steps and the ratios

  w := w - 1;
  h := h - 1;
  RowDest := integer(Dest.Scanline[0]);
  //RowSourceStart := integer(Src.Scanline[0]);
  //RowSource := RowSourceStart;
  xstart := Src.Scanline[0];
  ystart := xstart;
  for y := 0 to h do begin
    dy := ysteps[y].Steps;
    x3 := 0;
    inc(ystart, ysteps[y].jump);
    xstart := ystart;
    for x := 0 to w do begin
      dx := xsteps[x].Steps;
      inc(xstart, xsteps[x].jump);
      totalRed := 0;
      totalGreen := 0;
      totalBlue := 0; //shut up compiler
      q := xstart;
      for iy := 0 to dy do
      begin
        yweight := ysteps[y].weights[iy];
        p := PRGB24(q);
        xweight := xsteps[x].weights[0];
        xRed := xweight * p^.r;
        xGreen := xweight * p^.g;
        xBlue := xweight * p^.b;
        for ix := 1 to dx do
        begin
          inc(p);
          xweight := xsteps[x].weights[ix];
          xRed := xRed + xweight * p^.r;
          xGreen := xGreen + xweight * p^.g;
          xBlue := xBlue + xweight * p^.b;
        end;
       // xRed := (xRed + $7FFF) shr 16;
       // xGreen := (xGreen + $7FFF) shr 16;
       // xBlue := (xBlue + $7FFF) shr 16;
        if iy = 0 then
        begin
          totalRed := yweight * xRed;
          totalGreen := yweight * xGreen;
          totalBlue := yweight * xBlue;
          inc(q, -ptrS);
        end
        else
        begin
          totalRed := totalRed + yweight * xRed;
          totalGreen := totalGreen + yweight * xGreen;
          totalBlue := totalBlue + yweight * xBlue;
          inc(q, -ptrS);
        end;
      end;
      pt1 := PRGB24(RowDest + x3);
      //.ratio. := alphas[dx - 1, dy - 1];
      pt1^.r := (totalRed + $7FFFFF) shr 24;
      pt1^.g := (totalGreen + $7FFFFF) shr 24;
      pt1^.b := (totalBlue + $7FFFFF) shr 24;
      x3 := x3 + 3;
    end;
    RowDest := RowDest - ptrD;
  end;
end;

type
  TDownStep = record
    steps, jump: integer;
    weights: array of integer;
  end;

  TDownStepsArray = array of TDownStep;

procedure MakeDownWeights(xscale, yscale: Single; xw, yh, xsw, ysh, SourceBytes: integer; var xsteps, ysteps: TDownStepsArray);
var i, j: integer;
  x, xcenter: integer;
  intscale, Left,
    newleft, newright, radInt,
    maxsteps: integer;
  fact: single;
  Weight, total: integer;
  function filter(x: integer): integer;
  begin
    if x < -intscale then
      Result := 0
    else
      if x < 0 then
        Result := x + intscale
      else
        if x < intscale then
          Result := intscale - x
        else
          Result := 0;
  end;
begin
  SetLength(xsteps, xw);
  SetLength(ysteps, yh);
  //xswint := (xsw - 2) * $100;
 // yshint := (ysh - 2) * $100;
  intscale := round(xscale * $100);
  radInt := intscale; //radius=1
  //won't work if xcale > $10000/2, because then intscale
  //exceeds 32bit integer. I don't see that happening.
  Left := 0;
  xcenter := 0;
  for i := 0 to xw - 1 do
  begin
    newleft := max(xcenter - radInt, 0) shr 8;
    newright := (xcenter + radInt + $FF) shr 8;
    if newright >= xsw then newright := xsw - 1;
    maxsteps := newright - newleft;
    newleft := newleft - 1;
    with xsteps[i] do
    begin
      SetLength(weights, maxsteps + 1);
      Total := 0;
      j := -1;
      Weight := 0;
      while (Weight = 0) and (j <= maxsteps) do
      begin
        inc(newleft);
        x := newleft shl 8;
        Weight := filter(xcenter - x);
        inc(j);
      end;
      Steps := -1;
      x := newleft shl 8;
      while (j <= maxsteps) and (Weight > 0) do
      begin
        Total := Total + Weight;
        inc(Steps);
        weights[Steps] := weight;
        inc(x, $100);
        inc(j);
        Weight := filter(xcenter - x);
      end;
      if Steps >= 0 then
      begin
        fact := $1000 / Total;
        for j := 0 to Steps do
          weights[j] := round(weights[j] * fact);
      end
      else
      begin
        Steps := 0;
        newleft := newleft - 1;
        weights[0] := $1000;
      end;
    end;
    xsteps[i].jump := 3 * (newleft - left);
    Left := newleft;
    inc(xcenter, intscale);
  end;

  intscale := round(yscale * $100);
  Left := 0;
  xcenter := 0;
  for i := 0 to yh - 1 do
  begin
    newleft := max(xcenter - radInt, 0) shr 8;
    newright := (xcenter + radInt + $FF) shr 8;
    if newright >= ysh then newright := ysh - 1;
    maxsteps := newright - newleft;
    newleft := newleft - 1;
    with ysteps[i] do
    begin
      setlength(weights, maxsteps + 1);
      Total := 0;
      j := -1;
      Weight := 0;
      while (Weight = 0) and (j <= maxsteps) do
      begin
        inc(newleft);
        x := newleft shl 8;
        Weight := filter(xcenter - x);
        inc(j);
      end;
      Steps := -1;
      x := newleft shl 8;
      while (j <= maxsteps) and (Weight > 0) do
      begin
        Total := Total + Weight;
        inc(Steps);
        weights[Steps] := weight;
        inc(x, $100);
        inc(j);
        Weight := filter(xcenter - x);
      end;
      if Steps >= 0 then
      begin
        fact := $1000 / Total;
        for j := 0 to Steps do
          weights[j] := round(weights[j] * fact);
      end
      else
      begin
        Steps := 0;
        newleft := newleft - 1;
        weights[0] := $1000;
      end;
    end;
    ysteps[i].jump := SourceBytes * (newleft - left);
    Left := newleft;
    inc(xcenter, intscale);
  end;
end;


procedure Downsample(Src, Dest: TBitmap);
var
  xscale, yscale: Single;
  x1: integer;
  ix, iy: integer;
  totalRed, totalGreen, totalBlue: integer;
  xRed, xGreen, xBlue: integer;
  ratio: integer;
  p: PRGB24;
  q: PByte;
  pt1: PRGB24;
  ptrD, ptrS: integer;
  x, y: integer;
  r1, r2: TRect;
  x3: integer;
  RowDest, RowSource, RowSourceStart: integer;
  xsteps, ysteps: TDownStepsArray;
  w, h, dxmin, dymin: integer;
  xweight, yweight: integer;
  dx, dy: integer;
  xstart, ystart: PByte;

begin
  if (Src.Width <= 2) or (Src.Height <= 2) then
    raise Exception.Create('Source must have width and height >2');
  if (Dest.Width >= Src.Width) or (Dest.Height >= Src.Height) then
  begin
    r1 := Rect(0, 0, Src.Width, Src.Height);
    r2 := r1;
    OffsetRect(r2, (Dest.Width - Src.Width) div 2, (Dest.Height - Src.Height) div 2);
    Dest.Canvas.CopyRect(r2, Src.Canvas, r1);
    exit;
  end;
  Src.PixelFormat := pf24bit;
  Dest.PixelFormat := pf24bit; //safety
  w := Dest.Width;
  h := Dest.Height;
  ptrD := (w * 24 + 31) and not 31;
  ptrD := ptrD div 8; //BytesPerScanline
  ptrS := (Src.Width * 24 + 31) and not 31;
  ptrS := ptrS div 8;

  xscale := (Src.Width - 1) / (w - 1);
  yscale := (Src.Height - 1) / (h - 1); //turns div into mults
  MakeDownWeights(xscale, yscale, w, h, Src.Width, Src.Height, -ptrS, xsteps, ysteps);
  //Make 3 lookup tables for the steps and the ratios

  w := w - 1;
  h := h - 1;
  RowDest := integer(Dest.Scanline[0]);
  //RowSourceStart := integer(Src.Scanline[0]);
  //RowSource := RowSourceStart;
  xstart := Src.Scanline[0];
  ystart := xstart;
  for y := 0 to h do begin
    dy := ysteps[y].Steps;
    x3 := 0;
    inc(ystart, ysteps[y].jump);
    xstart := ystart;
    for x := 0 to w do begin
      dx := xsteps[x].Steps;
      inc(xstart, xsteps[x].jump);
      totalRed := 0;
      totalGreen := 0;
      totalBlue := 0;
      q := xstart;
      for iy := 0 to dy do
      begin
        yweight := ysteps[y].weights[iy];
        p := PRGB24(q);
        xweight := xsteps[x].weights[0];
        xRed := xweight * p^.r;
        xGreen := xweight * p^.g;
        xBlue := xweight * p^.b;
        for ix := 1 to dx do
        begin
          inc(p);
          xweight := xsteps[x].weights[ix];
          inc(xRed, xweight * p^.r);
          inc(xGreen, xweight * p^.g);
          inc(xBlue, xweight * p^.b);
        end;
       // xRed := (xRed + $7FFF) shr 16;
       // xGreen := (xGreen + $7FFF) shr 16;
       // xBlue := (xBlue + $7FFF) shr 16;
        if iy = 0 then
        begin
          totalRed := yweight * xRed;
          totalGreen := yweight * xGreen;
          totalBlue := yweight * xBlue;
          inc(q, -ptrS);
        end
        else
        begin
          inc(totalRed, yweight * xRed);
          inc(totalGreen, yweight * xGreen);
          inc(totalBlue, yweight * xBlue);
          inc(q, -ptrS);
        end;
      end;
      pt1 := PRGB24(RowDest + x3);
      //.ratio. := alphas[dx - 1, dy - 1];
      pt1^.r := (totalRed + $7FFFFF) shr 24;
      pt1^.g := (totalGreen + $7FFFFF) shr 24;
      pt1^.b := (totalBlue + $7FFFFF) shr 24;
      x3 := x3 + 3;
    end;
    RowDest := RowDest - ptrD;
  end;
end;

procedure MakeThumb(const Src, Dest: TBitmap);
begin
  if Src.Height > Dest.Height then
    DownSample(Src, Dest)
  else
    Upsample(Src, Dest);
end;

type TFloatarray = array of array of Single;

procedure MakeAlphasFloat(xscale, yscale: Single; xw, yh: integer; var dxmin, dymin: integer; var alphas: TFloatarray; var xsteps, ysteps: TIntArray);
var i, j: integer;
  x1, x2: integer;
  dxmax, dymax: integer;
  fact: Single;
begin
  SetLength(xsteps, xw);
  SetLength(ysteps, yh);
  x1 := 0;
  x2 := trunc(xscale);
  for i := 0 to xw - 1 do
  begin
    xsteps[i] := x2 - x1;
    x1 := x2;
    x2 := trunc((i + 2) * xscale);
  end;
  dxmin := Ceil(xscale - 1);
  dxmax := trunc(xscale + 1);

  x1 := 0;
  x2 := trunc(yscale);
  for i := 0 to yh - 1 do
  begin
    ysteps[i] := x2 - x1;
    x1 := x2;
    x2 := trunc((i + 2) * yscale);
  end;
  dymin := Ceil(yscale - 1);
  dymax := trunc(yscale + 1);
  SetLength(alphas, dxmax - dxmin + 1, dymax - dymin + 1);
  for i := 0 to dxmax - dxmin do
  begin
    fact := 1 / (dxmin + i);
    for j := 0 to dymax - dymin do
      alphas[i, j] := fact / (dymin + j);
  end;
end;


procedure MakeThumbNailFloat(const Src, Dest: TBitmap);
var
  xscale, yscale: Single;
  x1: integer;
  ix, iy: integer;
  totalRed, totalGreen, totalBlue: integer;
  ratio: Single;
  p: PRGB24;
  pt1: PRGB24;
  ptrD, ptrS: integer;
  x, y: integer;
  r1, r2: TRect;
  x3: integer;
  RowDest, RowSource, RowSourceStart: integer;
  alphas: TFloatarray;
  xsteps, ysteps: TIntArray;
  w, h, dxmin, dymin: integer;
  dx, dy: integer;

begin
  if (Dest.Width <= 0) or (Dest.Height <= 0) then
    raise Exception.Create('Destination must have positive width and height');
  if (Dest.Width >= Src.Width) or (Dest.Height >= Src.Height) then
  begin
    r1 := Rect(0, 0, Src.Width, Src.Height);
    r2 := r1;
    OffsetRect(r2, (Dest.Width - Src.Width) div 2, (Dest.Height - Src.Height) div 2);
    Dest.Canvas.CopyRect(r2, Src.Canvas, r1);
    exit;
  end;
  Src.PixelFormat := pf24bit;
  Dest.PixelFormat := pf24bit; //safety
  w := Dest.Width;
  h := Dest.Height;
  ptrD := (w * 24 + 31) and not 31;
  ptrD := ptrD div 8; //BytesPerScanline
  ptrS := (Src.Width * 24 + 31) and not 31;
  ptrS := ptrS div 8;

  xscale := Src.Width / w;
  yscale := Src.Height / h; //turns div into mults
  MakeAlphasFloat(xscale, yscale, w, h, dxmin, dymin, alphas, xsteps, ysteps);
  //Make 3 lookup tables for the steps and the ratios

  w := w - 1;
  h := h - 1;
  RowDest := integer(Dest.Scanline[0]);
  RowSourceStart := integer(Src.Scanline[0]);
  RowSource := RowSourceStart;
  for y := 0 to h do begin
    dy := ysteps[y];
    x1 := 0;
    x3 := 0;
    for x := 0 to w do begin
      dx := xsteps[x];
      totalRed := 0;
      totalGreen := 0;
      totalBlue := 0;
      RowSource := RowSourceStart;
      for iy := 1 to dy do
      begin
        p := PRGB24(RowSource + x1);
        for ix := 1 to dx do begin
          totalRed := totalRed + p^.r;
          totalGreen := totalGreen + p^.g;
          totalBlue := totalBlue + p^.b;
          inc(p);
        end;
        RowSource := RowSource - ptrS;
      end;
      pt1 := PRGB24(RowDest + x3);
      ratio := alphas[dx - dxmin, dy - dymin];
      pt1^.r := round(totalRed * ratio);
      pt1^.g := round(totalGreen * ratio);
      pt1^.b := round(totalBlue * ratio);
      x1 := x1 + 3 * dx;
      x3 := x3 + 3;
    end;
    RowDest := RowDest - ptrD;
    RowSourceStart := RowSource;
  end;
end;



procedure MakeThumbNail(Src, Dest: TBitmap);
// By Roy Magne Klever
//The src image is the original bitmap you want to downscale, dest is the
//bitmap to write the thumbnail into.
//NB!  they must be 24 bit!
// NB! Only downscaling supported and only prop... but exelent quality...

var
  xscale, yscale: double;
  x1, x2, y1, y2: integer;
  ix, iy: integer;
  totalRed, totalGreen, totalBlue: double;
  ratio: double;
  p: PRGB24;
  pt1: PRGB24;
  ptrD, ptrS: integer;
  s1, s3: PLine24;
  x, y: integer;
  yrat: double;
  r1, r2: TRect;
begin
  if (Dest.Width >= Src.Width) or (Dest.Height >= Src.Height) then
  begin
    r1 := Rect(0, 0, Src.Width, Src.Height);
    r2 := r1;
    OffsetRect(r2, (Dest.Width - Src.Width) div 2, (Dest.Height - Src.Height) div 2);
    Dest.Canvas.CopyRect(r2, Src.Canvas, r1);
    exit;
  end;
  s1 := Dest.Scanline[0];
  ptrD := integer(Dest.Scanline[1]) - integer(s1);
  s3 := Src.Scanline[0];
  ptrS := integer(Src.Scanline[1]) - integer(s3);

  xscale := Src.Width / Dest.Width; //Dest.Width / Src.Width;
  yscale := Src.Height / Dest.Height;
  y1 := 0;
  y2 := trunc(yscale) - 1;
  for y := 0 to Dest.Height - 1 do begin
    //y1 := trunc(y / yscale);
    //y2 := trunc((y + 1) / yscale) - 1;
    yrat := 1 / (y2 + 1 - y1);
    x1 := 0;
    x2 := trunc(xscale) - 1;
    for x := 0 to Dest.Width - 1 do begin
      //x1 := trunc(x / xscale);
      //x2 := trunc((x + 1) / xscale) - 1;
      totalRed := 0;
      totalGreen := 0;
      totalBlue := 0;
      for iy := y1 to y2 do
        for ix := x1 to x2 do begin
          p := PRGB24(ptrS * iy + (ix * 3) + integer(s3));
          totalRed := totalRed + p^.r;
          totalGreen := totalGreen + p^.g;
          totalBlue := totalBlue + p^.b;
        end;
      ratio := 1 / (x2 - x1 + 1) * yrat;
      pt1 := PRGB24(ptrD * y + (x * 3) + integer(s1));
      pt1.r := round(totalRed * ratio);
      pt1.g := round(totalGreen * ratio);
      pt1.b := round(totalBlue * ratio);
      x1 := x2 + 1;
      x2 := trunc(xscale * (x + 2)) - 1;
    end;
    y1 := y2 + 1;
    y2 := trunc(yscale * (y + 2)) - 1;
  end;
end;




procedure SharpenMod(const Src, Dest: TBitmap; alpha: Single);
//to sharpen, alpha must be >1.
var
  i, j, k: integer;
  sr: array[0..2] of PByte;
  st: array[0..4] of pRGBTriple;
  tr: PByte;
  tt, p: pRGBTriple;
  beta: Single;
  fracb: integer;
  inta: integer;
  //at, bt: PAlphaTable;
  bmh, bmw: integer;
  re, gr, bl: integer;
  BytesPerScanline: integer;
  //sumre, sumgr, sumbl: array[0..2] of integer;

begin
  if (Src.Width < 3) or (Src.Height < 3) then
    raise Exception.Create('Bitmap is too small');
  if alpha <= 1 then
    raise Exception.Create('Alpha must be >1');
  if alpha >= 6 then
    raise Exception.Create('Alpha must be <6');
  beta := (alpha - 1) / 5; //we assume alpha>1 and beta<1
  fracb := round(beta * $10000);
  //sharpening is blending of the current pixel
  //with the average of the surrounding ones,
  //but with a negative weight for the average
  inta := round(alpha * $10000);
  Src.PixelFormat := pf24bit;
  Dest.PixelFormat := pf24bit;
  Dest.Width := Src.Width;
  Dest.Height := Src.Height;
  bmw := Src.Width - 2;
  bmh := Src.Height - 2;
  BytesPerScanline := ((bmw + 2) * 24 + 31) and not 31;
  BytesPerScanline := BytesPerScanline div 8;

  tr := Dest.Scanline[0];
  tt := pRGBTriple(tr);

  sr[0] := Src.Scanline[0];
  st[0] := pRGBTriple(sr[0]);
  for j := 0 to bmw + 1 do
  begin
    tt^ := st[0]^;
    inc(tt); inc(st[0]); //first row unchanged
  end;

  sr[1] := PByte(integer(sr[0]) - BytesPerScanline);
  sr[2] := PByte(integer(sr[1]) - BytesPerScanline);
  for i := 1 to bmh do
  begin
    Dec(tr, BytesPerScanline);
    tt := pRGBTriple(tr);
    st[0] := pRGBTriple(integer(sr[0]) + 3); //top
    st[1] := pRGBTriple(sr[1]); //left
    st[2] := pRGBTriple(integer(sr[1]) + 3); //center
    st[3] := pRGBTriple(integer(sr[1]) + 6); //right
    st[4] := pRGBTriple(integer(sr[2]) + 3); //bottom
    tt^ := st[1]^; //1st col unchanged
    for j := 1 to bmw do
    begin
    //calcutate average weighted by -beta
      re := 0; gr := 0; bl := 0;
      for k := 0 to 4 do
      begin
        re := re + st[k]^.rgbtRed; {- bt^[st[k]^.rgbtRed];}
        gr := gr + st[k]^.rgbtGreen; {- bt^[st[k]^.rgbtGreen];}
        bl := bl + st[k]^.rgbtBlue; {- bt^[st[k]^.rgbtBlue];}
        inc(st[k]);
      end;

      re := (fracb * re + $7FFF) shr 16;
      gr := (fracb * gr + $7FFF) shr 16;
      bl := (fracb * bl + $7FFF) shr 16;
    //add center pixel weighted by alpha
      p := pRGBTriple(st[1]); //after inc, st[1] is at center
      re := (inta * p^.rgbtRed + $7FFF) shr 16 - re;
      gr := (inta * p^.rgbtGreen + $7FFF) shr 16 - gr;
      bl := (inta * p^.rgbtBlue + $7FFF) shr 16 - bl;

    //clamp and move into target pixel
      inc(tt);
      if re < 0 then //this is my inline version of ClampByte.
        re := 0
      else
        if re > 255 then
          re := 255;
      if gr < 0 then
        gr := 0
      else
        if gr > 255 then
          gr := 255;
      if bl < 0 then
        bl := 0
      else
        if bl > 255 then
          bl := 255;
      tt^.rgbtRed := re;
      tt^.rgbtGreen := gr;
      tt^.rgbtBlue := bl;
    end;
    inc(tt);
    inc(st[1]);
    tt^ := st[1]^; //Last col unchanged
    sr[0] := sr[1];
    sr[1] := sr[2];
    Dec(sr[2], BytesPerScanline);
  end;
  // copy last row
  Dec(tr, BytesPerScanline);
  tt := pRGBTriple(tr);
  st[1] := pRGBTriple(sr[1]);
  for j := 0 to bmw + 1 do
  begin
    tt^ := st[1]^;
    inc(tt); inc(st[1]);
  end;
end;


procedure Tween3(const sbm1, sbm2, tbm: TBitmap; const at, bt: PAlphaTable {; const t: TBitsArray});
var
  SP1, SP2, TargetP: pRGBTriple;
  SR1, SR2, TargetR: PByte;
  j, k, w, h: integer;
  BytesPerScanline: integer;
begin
  w := sbm1.Width;
  h := sbm1.Height;
  BytesPerScanline := (w * 24 + 31) and not 31;
  BytesPerScanline := BytesPerScanline div 8;
  SR1 := sbm1.Scanline[0];
  SR2 := sbm2.Scanline[0];
  TargetR := tbm.Scanline[0];
  for j := 0 to h - 1 do
  begin
    SP1 := pRGBTriple(SR1); SP2 := pRGBTriple(SR2); TargetP := pRGBTriple(TargetR);
    for k := 0 to w - 1 do
    begin
      TargetP.rgbtBlue := at^[SP1.rgbtBlue] + bt^[SP2.rgbtBlue];
      TargetP.rgbtGreen := at^[SP1.rgbtGreen] + bt^[SP2.rgbtGreen];
      TargetP.rgbtRed := at^[SP1.rgbtRed] + bt^[SP2.rgbtRed];
      inc(TargetP); inc(SP1); inc(SP2);
    end;
    Dec(SR1, BytesPerScanline); Dec(SR2, BytesPerScanline); Dec(TargetR, BytesPerScanline);
  end;
end;

function ScreenRect(AControl: TControl): TRect;
begin
  Result.TopLeft := AControl.ClientToScreen(Point(0, 0));
  Result.Right := Result.Left + AControl.Width;
  Result.Bottom := Result.Top + AControl.Height;
end;

procedure DrawSelFrame(AControl: TControl; dx, dy: integer);
var r: TRect;
  ScreenDC: HDC;
begin
  ScreenDC := GetDC(0);
  try
    r := ScreenRect(AControl);
    OffsetRect(r, dx, dy);
    DrawFocusRect(ScreenDC, r);
  finally
    ReleaseDC(0, ScreenDC);
  end;
end;

initialization
  MakeFracAlphaTable;

  makejpegtables;


end.

