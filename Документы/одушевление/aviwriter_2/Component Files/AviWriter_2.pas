unit AviWriter_2;

/////////////////////////////////////////////////////////////////////////////
//                                                                         //
//       AviWriter -- a component to create rudimentary AVI files          //
//                  by Elliott Shevin, with large pieces of code           //
//                  stolen from Anders Melander                            //
//       version 1.0. Please send comments, suggestions, and advice        //
//       to shevine@aol.com.                                               //
//                                                                         //
//       Extended to AviWriter_2 by Renate Schaaf                          //
//       renates@xmission.com                                              //
//       http://www.xydot.com/delphi/                                      //
/////////////////////////////////////////////////////////////////////////////
//                                                                         //
//  AviWriter will build an AVI file containing one stream of any          //
//  number of TBitmaps, plus a single WAV file.                            //
//                                                                         //
//  Properties:                                                            //
//     Bitmaps : A TList of pointers to TBitmap objects which become       //
//               frames of the AVI video stream. The component             //
//               allocates and frees the TList, but the caller             //
//               is responsible for managing the TBitmaps themselves.      //
//               Manipulate the list as you would any other TList.         //
//               At least one bitmap is required.                          //
//     Height, Width:                                                      //
//               The dimensions of the AVI video, in pixels.               //
//     FrameTime:                                                          //
//               The duration of each video frame, in milliseconds.        //
//     Stretch:  If TRUE, each TBitmap on the Bitmaps list is              //
//               stretches to the dimensions specified in Height           //
//               and Width. If FALSE, each TBitmap is copied from          //
//               its upper left corner without stretching.                 //
//     FileName: The name of the AVI file to be written.                   //
//     WAVFileName:                                                        //
//               The name of a WAV file which will become the audio        //
//               stream for the AVI. Optional.                             //
//                                                                         //
//  Method:                                                                //
//      Write:  Creates the AVI file named by FileName.                    //
/////////////////////////////////////////////////////////////////////////////
//  Wish List:                                                             //
//    I'd like to be able to enhance this component in two ways, but       //
//    don't know how. Please send ideas to shevine@aol.com.                //
//       1. So far, it's necessary to transform the video stream into      //
//          and AVI file on disk. I'd prefer to do this in memory.         //
//       2. MIDI files for audio.                                          //
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
//  Modifications by Renate Schaaf (renates@xmission.com):                 //
//                                                                         //
//  1. Support for pixel-formats other than pf8bit                         //
//     (in the routines I added, the AddVideo and Write routines           //
//     are unchanged)
//  2. Support for adding bitmaps on the fly                               //
//     (the bitmap list is OK for small avis, but not for "movies")        //                                                     //
//  3. Avi-Compression support, optionally with On-the-fly compression,    //
//     which avoids the writing of a temporary uncompressed file.          //                                     //
//  4. Support for progress feedback                                       //
//  5. Got the on-the-fly bitmap adding to work in my threads by           //
//     avoiding the use of InternalGet... functions. It uses a             //
//     TDIBSection and GetObject instead in AddFrame.                      //
//  6. More than one wave file can be written to Audiostream,              //
//     and start times can be specified in ms-delays                       //
//                                                                         //
//  Methods added:                                                         //
//      Compressionlist                                                    //
//        (Utility to get a list of supported codecs                       //
//        The first 4 characters in each item are the FourCC-code.         //
//        Pass a list which has ancestor type TStrings, and                //
//        which has been created. TCombobox.Items is a good one.)          //
//      SetCompression                                                     //
//        (Set FourCC-code for compression)                                //
//      SetCompressionQuality                                              //
//        (Set a value between 0 and 10 000 for the quality of the         //
//         compression. How it interpretes it, is up to the Codec :(       //
//      InitVideo                                                          //
//        (call before adding any bitmaps)                                 //
//      AddFrame                                                           //
//        (add a bitmap as the next (key-)frame)                           //
//      AddStillImage                                                      //
//        (add a bitmap which is to be shown unchanged for                 //
//          more than the frame time. Helps to keep an uncompressed        //
//         file smaller and saves a bit of time.)                          //
//      AddWaveFile                                                        //
//         (add wavefile(s) to be included as audiostream. Specify a delay //
//          in ms for when the file should start playing. All wave files   //
//          must have the same format. The format is determined by the     //
//          first file. If a subsequent file does not match, is is being   //
//          skipped.                                                       //
//          Exception: if OnTheFlyCompression is false, only one wave file //
//          can be added.)                                                 //
//      FinalizeVideo                                                      //
//        (no more bitmaps to add)                                         //
//      WriteAvi                                                           //
//        (combine the video and audiostream to the final .avi.            //
//        if OnTheFlyCompression is false, but compression is requested,   //
//        then the videostream is compressed here. Otherwise just the      //
//        audiostream is added.)                                           //
// Events added:                                                           //
//      OnProgress                                                         //
//        (Sends the current framecount for your update procedure.         //
//         Set Abort to true, if the user or you requests termination.)    //
// Properties added:                                                       //
//      Pixelformat (needs to be global for the whole movie)               //
//      OnTheFlyCompression (if true (default), frames are compressed      //
//         as they come in. Careful, some codecs, like MS-RLE              //
//         do not support it. Most of mine do, though.)                    //
//      Aborted                                                            //
//       (read whether the user or you or me killed the writing.           //
//         The user's input can be fetched in OnProgress.)                 //
// Fields added/changed:                                                   //
//      Several private fields/methods                                     //
//      TempfileName (made public, the default temp-folder                 //
//         would not have enough disk-space on my system)                  //
// Types added/changed:                                                    //
//      axed TPixelFormat                                                  //
//        (the original overwrites the same type in graphics.pas,          //
//         as a result MyBitmap.pixelformat:=pf24bit would not compile,    //
//           but I wonder whether it hadn't been there for a reason... )   //
//      TFourCC                                                            //
//        (string[4] for FourCC-codes of compression codecs)               //
//      TProgressEvent                                                     //
//Constants changed:                                                       //
//      Typecast of AVIERR_*** as HResult to avoid compiler                //
//      warnings.                                                          //
//                                                                         //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////
// Procedures/Types/Constants to convert part of MS VCM (MSVFW32.DLL).     //
/////////////////////////////////////////////////////////////////////////////                                                                         //
//      Source:                                                            //
//      VFW.pas available from delphi-jedi.org.                            //
//      by Ronald Dittrich, Ivo Steinmann, Peter Haas                      //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////
//                                                                         //
//                                                                         //
//      ***********No guaranties, warranty, liability :)****               //
//                                                                         //
//                                                                         //
// Thanks: To all cited authors! I would not have dared to get into this   //
//         stuff without this component plus the API-headers               //
//         being available.                                                //
//                                                                         //
//                                                                         //
// Comments:                                                                //
//     The component now seems to work in my threads. Thread safety        //
//     turned out not to have anything to do with it being a class         //
//     or a component, but everything with protecting the incoming bitmaps //
//     via locking/unlocking the canvas. Another important step seemed to  //
//     be to avoid using the routine InternalGetDIB. It kept failing for   //
//     me on larger frame sizes, as soon as another one of my threads      //
//     started. Don't know why, but maybe                                  //
//     Graphics.pas didn't like it with its shared handles.                //
//                                                                         //
////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs,
  StdCtrls,
{$IFDEF VER90}
  ole2;
{$ELSE}
  ActiveX;
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                      Video for Windows                                     //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Adapted from Thomas Schimming's VFW.PAS                                    //
// (c) 1996 Thomas Schimming, schimmin@iee1.et.tu-dresden.de                  //
// (c) 1998,99 Anders Melander                                                //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Ripped all COM/ActiveX stuff and added some AVI stream functions.          //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

type

  LONG = Longint;

  PAVIStream = Pointer;
  PAVIFile = Pointer;
  TAVIStreamList = array[0..0] of PAVIStream;
  PAVIStreamList = ^TAVIStreamList;

  PAVIStreamInfo = ^TAviStreamInfo;
  TAviStreamInfo = packed record
    fccType: DWord;
    fccHandler: DWord;
    dwFlags: DWord; // Contains AVITF_* flags
    dwCaps: DWord;
    wPriority: Word;
    wLanguage: Word;
    dwScale: DWord;
    dwRate: DWord; // dwRate / dwScale == samples/second
    dwStart: DWord;
    dwLength: DWord; // In units above...
    dwInitialFrames: DWord;
    dwSuggestedBufferSize: DWord;
    dwQuality: DWord;
    dwSampleSize: DWord;
    rcFrame: TRect;
    dwEditCount: DWord;
    dwFormatChangeCount: DWord;
    szName: array[0..63] of WideChar;
  end;

  PAVICompressOptions = ^TAVICompressOptions;
  TAVICompressOptions = packed record
    fccType: DWord; // stream type, for consistency
    fccHandler: DWord; // compressor
    dwKeyFrameEvery: DWord; // keyframe rate
    dwQuality: DWord; // compress quality 0-10,000
    dwBytesPerSecond: DWord; // bytes per second
    dwFlags: DWord; // flags... see below
    lpFormat: Pointer; // save format
    cbFormat: DWord;
    lpParms: Pointer; // compressor options
    cbParms: DWord;
    dwInterleaveEvery: DWord; // for non-video streams only
  end;

  APAVISTREAM = array[0..1] of PAVIStream;
  APAVICompressOptions = array[0..1] of PAVICompressOptions;

  TAVISaveCallback = function(i: integer): LONG; pascal;

procedure AVIFileInit; stdcall;
procedure AVIFileExit; stdcall;
function AVIFileOpen(var ppfile: PAVIFile; szFile: PChar; uMode: UINT; lpHandler: Pointer): HRESULT; stdcall;
function AVIFileCreateStream(pfile: PAVIFile; var ppavi: PAVIStream; var psi: TAviStreamInfo): HRESULT; stdcall;
function AVIStreamSetFormat(pavi: PAVIStream; lPos: LONG; lpFormat: Pointer; cbFormat: LONG): HRESULT; stdcall;
function AVIStreamReadFormat(pavi: PAVIStream; lPos: LONG; lpFormat: Pointer; var cbFormat: LONG): HRESULT; stdcall;
function AVIStreamWrite(pavi: PAVIStream; lStart, lSamples: LONG; lpBuffer: Pointer; cbBuffer: LONG; dwFlags: DWord; var plSampWritten: LONG; var plBytesWritten: LONG): HRESULT; stdcall;
function AVIStreamRelease(pavi: PAVIStream): ULONG; stdcall;
function AVIFileRelease(pfile: PAVIFile): ULONG; stdcall;
function AVIFileGetStream(pfile: PAVIFile; var ppavi: PAVIStream; fccType: DWord; LParam: LONG): HRESULT; stdcall;
function CreateEditableStream(var ppsEditable: PAVIStream; psSource: PAVIStream): HRESULT; stdcall;
function AVISaveV(szFile: PChar; pclsidHandler: PCLSID; lpfnCallback: TAVISaveCallback;
  nStreams: integer; pavi: APAVISTREAM; lpOptions: APAVICompressOptions): HRESULT; stdcall;
function AVIMakeCompressedStream(
  var ppsCompressed: PAVIStream;
  ppsSource: PAVIStream;
  lpOptions: PAVICompressOptions;
  pclsidHandler: PCLSID
  ): HRESULT; stdcall;
function AVIStreamInfo(pavi: PAVIStream; var psi: TAviStreamInfo; lSize: LONG): HRESULT; stdcall;
function AVIStreamRead(
  pavi: PAVIStream;
  lStart: LONG;
  lSamples: LONG;
  lpBuffer: Pointer;
  cbBuffer: LONG;
  plBytes: PInteger;
  plSamples: PInteger
  ): HRESULT; stdcall;
function AVIStreamStart(pavi: PAVIStream): LONG; stdcall;
function AVIStreamLength(pavi: PAVIStream): LONG; stdcall;
function EditStreamCopy(pavi: PAVIStream; var plStart, plLength: LONG; var ppResult: PAVIStream): HRESULT; stdcall;
function EditStreamPaste(pavi: PAVIStream; var plPos, plLength: LONG; pstream: PAVIStream; lStart, lEnd: LONG): HRESULT; stdcall;
function EditStreamSetInfo(pavi: PAVIStream; lpInfo: PAVIStreamInfo; cbInfo: LONG): HRESULT; stdcall;


type TFourCC = string[4];



type
  TProgressEvent = procedure(Sender: TObject; FrameCount: integer; var abort: boolean) of object;

  TBadBitmapEvent = procedure(Sender: TObject; bmp: TBitmap; InfoHeaderSize, BitsSize: integer) of object;
type
  TAviWriter_2 = class(TComponent)
  private
    pfile: PAVIFile;
    fHeight: integer;
    fWidth: integer;
    fStretch: boolean;
    fFrameTime: integer;
    fFilename: string;
    fWavFileName: string;
    VideoStream: PAVIStream;
    AudioStream: PAVIStream;
    fPstream, fCompStream: PAVIStream;
    fStreamInfo: TAviStreamInfo;
    fFrameCount: integer;
    fFourCC: TFourCC;
    fPixelFormat: TPixelFormat;
    //fInHeader: TBitmapInfoHeader;
    fPInInfo: PBitmapInfo;
    fInInfoSize: integer;
    AviCompressoptions: TAVICompressOptions;
    fAbort: boolean;
    fCompressionQuality: integer;
    fInitialized, fFinalized: boolean;
    fWaveFileList: TStringList;
    fCompOnFly: boolean;

    fOnProgress: TProgressEvent;
    fOnBadBitmap: TBadBitmapEvent;


    procedure AddVideo;
    procedure AddAudio;
    procedure InternalGetDIBSizes(Bitmap: HBITMAP; var InfoHeaderSize: integer;
      var ImageSize: Longint; PixelFormat: TPixelFormat);
    function InternalGetDIB(Bitmap: HBITMAP; Palette: Hpalette;
      var BitmapInfo; var Bits; PixelFormat: TPixelFormat): boolean;
    procedure InitializeBitmapInfoHeader(Bitmap: HBITMAP; var Info: TBitmapInfoHeader;
      PixelFormat: TPixelFormat);
    procedure SetWavFileName(value: string);
    function AviSaveCallback(i: integer): LONG; pascal;
    procedure SetPixelFormat(const value: TPixelFormat);
    procedure InitStreamFormat(const bm: TBitmap);
    procedure AddAudioMod;
    procedure InternalAddFrame(const Bitmap: TBitmap; Key: boolean);
    { Private declarations }

  protected
    { Protected declarations }
  public

    Bitmaps: TList;
    TempFileName: string;
    SilenceName: string;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Write;

    procedure InitVideo;
    procedure AddFrame(const ABmp: TBitmap);
    procedure AddStillImage(const ABmp: TBitmap; Showtime: integer);
    //showtime is in ms
    procedure FinalizeVideo;
    procedure WriteAvi;
    procedure Compressorlist(const List: TStrings);
    procedure SetCompression(FourCC: TFourCC);
    procedure SetCompressionQuality(q: integer);
    procedure ShowCompressorDialog(ADialogParent: TWinControl);
    procedure AddWaveFile(const filename: string; Delay: integer);
    //properties:
    property Aborted: boolean read fAbort;
    property OnTheFlyCompression: boolean read fCompOnFly write fCompOnFly;
    property OnBadBitmap: TBadBitmapEvent read fOnBadBitmap write fOnBadBitmap;
  published
    property Height: integer read fHeight write fHeight;
    property Width: integer read fWidth write fWidth;
    property FrameTime: integer read fFrameTime write fFrameTime;
    property Stretch: boolean read fStretch write fStretch;
    property PixelFormat: TPixelFormat read fPixelFormat write SetPixelFormat;
    property filename: string read fFilename write fFilename;
    property WavFileName: string read fWavFileName write SetWavFileName;
    property OnProgress: TProgressEvent read fOnProgress write fOnProgress;
  end;

procedure Register;


implementation

uses MMsystem, Silence;

procedure Register;
begin
  RegisterComponents('Custom', [TAviWriter_2]);
end;

type
  PICINFO = ^TICINFO;
  TICINFO = packed record
    dwSize: DWord; // sizeof(ICINFO)
    fccType: DWord; // compressor type     'vidc' 'audc'
    fccHandler: DWord; // compressor sub-type 'rle ' 'jpeg' 'pcm '
    dwFlags: DWord; // flags LOWORD is type specific
    dwVersion: DWord; // version of the driver
    dwVersionICM: DWord; // version of the ICM used
    //
    // under Win32, the driver always returns UNICODE strings.
    //
    szName: array[0..15] of WChar; // short name
    szDescription: array[0..127] of WChar; // DWORD name
    szDriver: array[0..127] of WChar; // driver that contains compressor
  end;

const
  AVICOMPRESSF_INTERLEAVE = $00000001; // interleave
  AVICOMPRESSF_DATARATE = $00000002; // use a data rate
  AVICOMPRESSF_KEYFRAMES = $00000004; // use keyframes
  AVICOMPRESSF_VALID = $00000008; // has valid data?

  //Typecast as HResult to eliminate compiler warnings
  //about violating subrange bounds
  AVIERR_OK = 0;
  AVIERR_UNSUPPORTED = HRESULT($80044065); // MAKE_AVIERR(101)
  AVIERR_BADFORMAT = HRESULT($80044066); // MAKE_AVIERR(102)
  AVIERR_MEMORY = HRESULT($80044067); // MAKE_AVIERR(103)
  AVIERR_INTERNAL = HRESULT($80044068); // MAKE_AVIERR(104)
  AVIERR_BADFLAGS = HRESULT($80044069); // MAKE_AVIERR(105)
  AVIERR_BADPARAM = HRESULT($8004406A); // MAKE_AVIERR(106)
  AVIERR_BADSIZE = HRESULT($8004406B); // MAKE_AVIERR(107)
  AVIERR_BADHANDLE = HRESULT($8004406C); // MAKE_AVIERR(108)
  AVIERR_FILEREAD = HRESULT($8004406D); // MAKE_AVIERR(109)
  AVIERR_FILEWRITE = HRESULT($8004406E); // MAKE_AVIERR(110)
  AVIERR_FILEOPEN = HRESULT($8004406F); // MAKE_AVIERR(111)
  AVIERR_COMPRESSOR = HRESULT($80044070); // MAKE_AVIERR(112)
  AVIERR_NOCOMPRESSOR = HRESULT($80044071); // MAKE_AVIERR(113)
  AVIERR_READONLY = HRESULT($80044072); // MAKE_AVIERR(114)
  AVIERR_NODATA = HRESULT($80044073); // MAKE_AVIERR(115)
  AVIERR_BUFFERTOOSMALL = HRESULT($80044074); // MAKE_AVIERR(116)
  AVIERR_CANTCOMPRESS = HRESULT($80044075); // MAKE_AVIERR(117)
  AVIERR_USERABORT = HRESULT($800440C6); // MAKE_AVIERR(198)
  AVIERR_ERROR = HRESULT($800440C7); // MAKE_AVIERR(199)

  streamtypeVIDEO = $73646976; // mmioFOURCC('v', 'i', 'd', 's')
  streamtypeAUDIO = $73647561; // mmioFOURCC('a', 'u', 'd', 's')
  AVIIF_KEYFRAME = $00000010;

  ICTYPE_VIDEO = $63646976; {vidc}
  ICMODE_COMPRESS = 1;
  ICMODE_QUERY = 4;

  ICM_USER = (DRV_USER + $0000);
  ICM_RESERVED_LOW = (DRV_USER + $1000);
  ICM_RESERVED_HIGH = (DRV_USER + $2000);
  ICM_RESERVED = ICM_RESERVED_LOW;
  ICM_COMPRESS_QUERY = (ICM_USER + 6); // query support for compress
  ICM_CONFIGURE = (ICM_RESERVED + 10); // show the configure dialog
  ICMF_CONFIGURE_QUERY = $00000001;

procedure AVIFileInit; stdcall; external 'avifil32.dll' Name 'AVIFileInit';

procedure AVIFileExit; stdcall; external 'avifil32.dll' Name 'AVIFileExit';
function AVIFileOpen; external 'avifil32.dll' Name 'AVIFileOpenA';
function AVIFileCreateStream; external 'avifil32.dll' Name 'AVIFileCreateStreamA';
function AVIStreamSetFormat; external 'avifil32.dll' Name 'AVIStreamSetFormat';
function AVIStreamReadFormat; external 'avifil32.dll' Name 'AVIStreamReadFormat';
function AVIStreamWrite; external 'avifil32.dll' Name 'AVIStreamWrite';
function AVIStreamRelease; external 'avifil32.dll' Name 'AVIStreamRelease';
function AVIFileRelease; external 'avifil32.dll' Name 'AVIFileRelease';
function AVIFileGetStream; external 'avifil32.dll' Name 'AVIFileGetStream';
function CreateEditableStream; external 'avifil32.dll' Name 'CreateEditableStream';
function AVISaveV; external 'avifil32.dll' Name 'AVISaveV';
function AVIMakeCompressedStream; external 'avifil32.dll' Name 'AVIMakeCompressedStream';

function AVIStreamInfo(pavi: PAVIStream; var psi: TAviStreamInfo; lSize: LONG): HRESULT; stdcall; external 'avifil32.dll' Name 'AVIStreamInfoA';

function AVIStreamRead(
  pavi: PAVIStream;
  lStart: LONG;
  lSamples: LONG;
  lpBuffer: Pointer;
  cbBuffer: LONG;
  plBytes: PInteger;
  plSamples: PInteger
  ): HRESULT; stdcall; external 'avifil32.dll';

function AVIStreamStart(pavi: PAVIStream): LONG; stdcall; external 'avifil32.dll';

function AVIStreamLength(pavi: PAVIStream): LONG; stdcall; external 'avifil32.dll';

function EditStreamCopy(pavi: PAVIStream; var plStart, plLength: LONG; var ppResult: PAVIStream): HRESULT; stdcall; external 'avifil32.dll';

function EditStreamPaste(pavi: PAVIStream; var plPos, plLength: LONG; pstream: PAVIStream; lStart, lEnd: LONG): HRESULT; stdcall; external 'avifil32.dll';

function EditStreamSetInfo(pavi: PAVIStream; lpInfo: PAVIStreamInfo; cbInfo: LONG): HRESULT; stdcall; external 'avifil32.dll' Name 'EditStreamSetInfoA';

function ICInfo(fccType, fccHandler: DWord; lpicinfo: PICINFO): BOOL; stdcall; external 'MSVFW32.DLL';

function ICOpen(fccType, fccHandler: DWord; wMode: UINT): THandle; stdcall; external 'MSVFW32.DLL';

function ICSendMessage(hic: THandle; Msg: UINT; dw1, dw2: DWord): DWord; stdcall; external 'MSVFW32.DLL';

function ICCompressQuery(hic: THandle; lpbiInput, lpbiOutput: PBitmapInfoHeader): DWord;
begin
  Result := ICSendMessage(hic, ICM_COMPRESS_QUERY, DWord(lpbiInput), DWord(lpbiOutput));
end;

function ICGetInfo(hic: THandle; PICINFO: PICINFO; cb: DWord): DWord; stdcall; external 'MSVFW32.DLL';

function ICClose(hic: THandle): DWord; stdcall; external 'MSVFW32.DLL';

function ICLocate(fccType, fccHandler: DWord; lpbiIn, lpbiOut: PBitmapInfoHeader; wFlags: Word): THandle; stdcall; external 'MSVFW32.DLL';

function ICQueryConfigure(hic: THandle): BOOL;
begin
  Result := ICSendMessage(hic, ICM_CONFIGURE, DWord(-1), ICMF_CONFIGURE_QUERY) = 0;
end;

function ICConfigure(hic: THandle; HWND: HWND): DWord;
begin
  Result := ICSendMessage(hic, ICM_CONFIGURE, HWND, 0);
end;

{TAVIWriter_2}

constructor TAviWriter_2.Create(AOwner: TComponent);
var
  TempDir: string;
  l: integer;
begin
  inherited Create(AOwner);
  fHeight := screen.Height div 10;
  fWidth := screen.Width div 10;
  fFrameTime := 1000;
  fStretch := true;
  fFilename := '';
  Bitmaps := TList.Create;
  AVIFileInit;

  fFourCC := '';
  fPixelFormat := pf24bit;
  fAbort := false;
  fCompressionQuality := 5000;
  fCompOnFly := true;
  fWaveFileList := TStringList.Create;

  SetLength(TempDir, MAX_PATH + 1);
  l := GetTempPath(MAX_PATH, PChar(TempDir));
  SetLength(TempDir, l);
  if copy(TempDir, Length(TempDir), 1) <> '\'
    then TempDir := TempDir + '\';
  TempFileName := TempDir + '~AWTemp.avi';
end;

destructor TAviWriter_2.Destroy;
var refcount: integer;
begin
  Bitmaps.Free;
  fWaveFileList.Free;
  if fPInInfo <> nil then
    FreeMem(fPInInfo);
  //any junk from a previous bomb?
  if Assigned(pfile) then
  try
    repeat
      refcount := AVIFileRelease(pfile);
    until refcount <= 0;
  except
    pfile := nil;
  end;

  if Assigned(fCompStream) then
    AVIStreamRelease(fCompStream);
  if Assigned(fPstream) then
    AVIStreamRelease(fPstream);
  if Assigned(VideoStream) then
    AVIStreamRelease(VideoStream);
  if Assigned(AudioStream) then
    AVIStreamRelease(AudioStream);

  if FileExists(TempFileName) then
    Deletefile(TempFileName);
  AVIFileExit;
  inherited;
end;

procedure TAviWriter_2.Write;
var
  ExtBitmap: TBitmap;
  nStreams: integer;
  i: integer;
  Streams: APAVISTREAM;
  CompOptions: APAVICompressOptions;
  AVIERR: HRESULT;
  refcount: integer;

begin
  AudioStream := nil;
  VideoStream := nil;

    // If no bitmaps are on the list, raise an error.
  if Bitmaps.Count < 1 then
    raise Exception.Create('No bitmaps on the Bitmaps list');

    // If anything on the Bitmaps TList is not a bitmap, raise
    // an error.
  for i := 0 to Bitmaps.Count - 1 do begin
    ExtBitmap := Bitmaps[i];
    if not (ExtBitmap is TBitmap)
      then raise Exception.Create('Bitmaps[' + IntToStr(i)
        + '] is not a TBitmap');
  end;

  try
    AddVideo;

    if WavFileName <> ''
      then AddAudio;

      // Create the output file.
    if WavFileName <> ''
      then nStreams := 2
    else nStreams := 1;

    Streams[0] := VideoStream;
    Streams[1] := AudioStream;
    CompOptions[0] := nil;
    CompOptions[1] := nil;

    AVIERR := AVISaveV(PChar(filename), nil, nil, nStreams, Streams, CompOptions);

    if AVIERR <> AVIERR_OK then
      raise Exception.Create('Unable to write output file');
  finally
    if Assigned(VideoStream)
      then AVIStreamRelease(VideoStream);
    if Assigned(AudioStream)
      then AVIStreamRelease(AudioStream);
    try
      repeat
        refcount := AVIFileRelease(pfile);
      until refcount <= 0;
    except
    end;

    pfile := nil;
    VideoStream := nil;
    AudioStream := nil;

    Deletefile(TempFileName);
  end;
end;

procedure TAviWriter_2.AddVideo;
var
  pstream: PAVIStream;
  StreamInfo: TAviStreamInfo;
  BitmapInfo: PBitmapInfoHeader;
  BitmapInfoSize: integer;
  BitmapSize: Longint;
  BitmapBits: Pointer;
  Bitmap: TBitmap;
  ExtBitmap: TBitmap;
  Samples_Written: LONG;
  Bytes_Written: LONG;
  AVIERR: integer;
  i: integer;
begin

    // Open AVI file for write
  if (AVIFileOpen(pfile, PChar(TempFileName),
    OF_WRITE or OF_CREATE or OF_SHARE_EXCLUSIVE, nil)
    <> AVIERR_OK)
    then
    raise Exception.Create('Failed to create AVI video work file');

    // Allocate the bitmap to which the bitmaps on the Bitmaps Tlist
    // will be copied.
  Bitmap := TBitmap.Create;
  Bitmap.Height := Self.Height;
  Bitmap.Width := Self.Width;

    // Write the stream header.
  try
    FillChar(StreamInfo, SizeOf(StreamInfo), 0);

       // Set frame rate and scale
    StreamInfo.dwRate := 1000;
    StreamInfo.dwScale := fFrameTime;
    StreamInfo.fccType := streamtypeVIDEO;
    StreamInfo.fccHandler := 0;
    StreamInfo.dwFlags := 0;
    StreamInfo.dwSuggestedBufferSize := 0;
    StreamInfo.rcFrame.Right := Self.Width;
    StreamInfo.rcFrame.Bottom := Self.Height;

       // Open AVI data stream
    if (AVIFileCreateStream(pfile, pstream, StreamInfo) <> AVIERR_OK) then
      raise Exception.Create('Failed to create AVI video stream');

    try
          // Write the bitmaps to the stream.
      for i := 0 to Bitmaps.Count - 1 do begin
        BitmapInfo := nil;
        BitmapBits := nil;
        try

               // Copy the bitmap from the list to the AVI bitmap,
               // stretching if desired. If the caller elects not to
               // stretch, use the first pixel in the bitmap as a
               // background color in case either the height or
               // width of the source is smaller than the output.
               // If Draw fails, do a StretchDraw.
          ExtBitmap := Bitmaps[i];
          if fStretch
            then Bitmap.Canvas.stretchdraw
            (Rect(0, 0, Self.Width, Self.Height), ExtBitmap)
          else try
            with Bitmap.Canvas do begin
              Brush.Color := ExtBitmap.Canvas.Pixels[0, 0];
              Brush.Style := bsSolid;
              FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
              draw(0, 0, ExtBitmap);
            end;
          except
            Bitmap.Canvas.stretchdraw
              (Rect(0, 0, Self.Width, Self.Height), ExtBitmap);
          end;

               // Determine size of DIB
          InternalGetDIBSizes(Bitmap.Handle, BitmapInfoSize, BitmapSize, pf8bit);
          if (BitmapInfoSize = 0) then
            raise Exception.Create('Failed to retrieve bitmap info');

               // Get DIB header and pixel buffers
          GetMem(BitmapInfo, BitmapInfoSize);
          GetMem(BitmapBits, BitmapSize);
          InternalGetDIB
            (Bitmap.Handle, 0, BitmapInfo^, BitmapBits^, pf8bit);

               // On the first time through, set the stream format.
          if i = 0 then
            if (AVIStreamSetFormat(pstream, 0, BitmapInfo, BitmapInfoSize) <> AVIERR_OK) then
              raise Exception.Create('Failed to set AVI stream format');

               // Write frame to the video stream
          AVIERR :=
            AVIStreamWrite(pstream, i, 1, BitmapBits, BitmapSize, AVIIF_KEYFRAME,
            Samples_Written, Bytes_Written);
          if AVIERR <> AVIERR_OK then
            raise Exception.Create
              ('Failed to add frame to AVI.')
        finally
          if (BitmapInfo <> nil) then
            FreeMem(BitmapInfo);
          if (BitmapBits <> nil) then
            FreeMem(BitmapBits);
        end;
      end;

          // Create the editable VideoStream from pStream.
      if CreateEditableStream(VideoStream, pstream) <> AVIERR_OK then
        raise Exception.Create
          ('Could not create Video Stream');
    finally
      AVIStreamRelease(pstream);
    end;

  finally
    Bitmap.Free;
  end;
end;

procedure TAviWriter_2.AddAudio;
var
  InputFile: PAVIFile;
  hr: HRESULT;
  InputStream: PAVIStream;
begin
   // Open the audio file.
  try
    hr := AVIFileOpen(InputFile, PChar(WavFileName), OF_READ, nil);
    if hr <> 0 then
      fWavFileName := '';
    case hr of
      0: ;
      AVIERR_BADFORMAT: raise Exception.Create('The file could not be read, indicating a corrupt file or an unrecognized format.');
      AVIERR_MEMORY: raise Exception.Create('The file could not be opened because of insufficient memory.');
      AVIERR_FILEREAD: raise Exception.Create('A disk error occurred while reading the audio file.');
      AVIERR_FILEOPEN: raise Exception.Create('A disk error occurred while opening the audio file.');
      REGDB_E_CLASSNOTREG: raise Exception.Create('According to the registry, the type of audio file specified in AVIFileOpen does not have a handler to process it.');
    else raise Exception.Create('Unknown error opening audio file');
    end;

   // Open the audio stream.
    if (AVIFileGetStream(InputFile, InputStream, streamtypeAUDIO, 0) <> AVIERR_OK) then
      raise Exception.Create('Unable to get audio stream');

    try
       // Create AudioStream as a copy of InputStream
      if (CreateEditableStream(AudioStream, InputStream) <> AVIERR_OK) then
        raise Exception.Create('Failed to create editable AVI audio stream');
    finally
      AVIStreamRelease(InputStream);
    end;

  finally
    AVIFileRelease(InputFile);
  end;
end;

function SortCompare(AList: TStringList; Index1, Index2: integer): integer;
begin
  if integer(AList.Objects[Index1]) < integer(AList.Objects[Index2]) then
    Result := -1 else
    if integer(AList.Objects[Index1]) > integer(AList.Objects[Index2]) then
      Result := 1 else
      Result := 0;
end;

function IsCompatible(si1, si2: TAviStreamInfo): boolean;
//checks compatibility of 2 audiostreams
begin
  Result := false;
  if si1.fccType <> si2.fccType then exit;
  if si1.dwScale <> si2.dwScale then exit;
  if si1.dwRate <> si2.dwRate then exit;
  if si1.dwSampleSize <> si2.dwSampleSize then exit;
  Result := true;
end;

function IsCompatibleWavefmt(w1, w2: TWaveFormatEx): boolean;
begin
  Result := (w1.nChannels = w2.nChannels) and (w1.wBitsPerSample = w2.wBitsPerSample);
end;




procedure TAviWriter_2.AddAudioMod;
var
  InputFile: PAVIFile;
  InputStream, AudStream: PAVIStream;
  hr: HRESULT;
  OldInfo, AudStreamInfo: TAviStreamInfo;
  fsize, fNewSize: integer;
  pformat: Pointer;
  i, j, il, jp, jmin, ss: integer;
  SampleSize: integer;
  pSample: Pointer;
  SamplesWritten, BytesWritten: integer;
  SamplesSoFar, l: Cardinal;
  Start, NextStart: Cardinal;
  SampPerSec: double;
  pSilence, pModSilence: PByteArray;
  Wavefmt, NewWavefmt: TWaveFormatEx;
begin
  if fWaveFileList.Count = 0 then
    if fWavFileName <> '' then
      AddWaveFile(fWavFileName, 0);
  if fWaveFileList.Count = 0 then
    exit;
  fWaveFileList.CustomSort(SortCompare);
  //sort by delay


  AudStream := nil;
  InputFile := nil;
  InputStream := nil;


  try
    SamplesSoFar := 0;
    for i := 0 to fWaveFileList.Count - 1 do
    begin
      if InputStream <> nil then AVIStreamRelease(InputStream);
      if InputFile <> nil then AVIFileRelease(InputFile);
      InputFile := nil;
      InputStream := nil;
      hr := AVIFileOpen(InputFile, PChar(fWaveFileList.Strings[i]), OF_READ, nil);
      Assert(hr = 0, 'FileOpen failed. Err: $' + IntToHex(hr, 8));
   // Open the audio stream.
      hr := AVIFileGetStream(InputFile, InputStream, streamtypeAUDIO, 0);
      Assert(hr = 0, 'GetStream failed. Err: $' + IntToHex(hr, 8));
      hr := AVIStreamInfo(InputStream, OldInfo, SizeOf(OldInfo));
      Assert(hr = 0, 'StreamInfo failed. Err: $' + IntToHex(hr, 8));
      if i > 0 then
        if not IsCompatible(OldInfo, AudStreamInfo) then
          Continue; //no sense in writing combined stream wouldn't play. try next one.
      hr := AVIStreamReadFormat(InputStream, 0, nil, fsize);
      Assert(hr = 0, 'ReadFormat failed. Err: $' + IntToHex(hr, 8));
      GetMem(pformat, fsize);
      try
        hr := AVIStreamReadFormat(InputStream, 0, pformat, fsize);
        Assert(hr = 0, 'ReadFormat failed. Err: $' + IntToHex(hr, 8));
        NewWavefmt := TWaveFormatEx(pformat^);
      finally
        FreeMem(pformat);
      end;
      if i > 0 then
        if (not IsCompatibleWavefmt(Wavefmt, NewWavefmt)) then
          Continue; //incompatible files, skip
      with OldInfo do
        SampPerSec := dwRate / dwScale;
      Start := trunc(1 / 1000 * SampPerSec * integer(fWaveFileList.Objects[i]));

      if i = 0 then
      begin
        AudStreamInfo := OldInfo;
        //AudStreamInfo.dwInitialFrames := round(0.75 * 1000 / fFrameTime); //not sure about that one.
        AudStreamInfo.dwLength := 0;
        AudStreamInfo.dwStart := 0;//FirstStart;
        //the rest should be OK from copying from first stream.

        //create the audiostream
        hr := AVIFileCreateStream(pfile, AudStream, AudStreamInfo);
        Assert(hr = 0, 'CreateStream failed. Err: $' + IntToHex(hr, 8));

        //write format to first sample
        hr := AVIStreamReadFormat(InputStream, 0, nil, fsize);
        Assert(hr = 0, 'ReadFormat failed. Err: $' + IntToHex(hr, 8));
        GetMem(pformat, fsize);
        try
          hr := AVIStreamReadFormat(InputStream, 0, pformat, fsize);
          Assert(hr = 0, 'ReadFormat failed. Err: $' + IntToHex(hr, 8));
          hr := AVIStreamSetFormat(AudStream, 0, pformat, fsize);
          Assert(hr = 0, 'SetFormat failed. Err: $' + IntToHex(hr, 8));
          Wavefmt := TWaveFormatEx(pformat^);
        finally
          FreeMem(pformat);
        end;
      end;

      if Start > SamplesSoFar then
        //if i > 0 then
        begin //pad with "silent" samples
          jmin := SamplesSoFar;
          pSilence := GetSilence(AudStreamInfo, Wavefmt, fsize);
          if pSilence <> nil then
          begin
            if fsize < integer(AudStreamInfo.dwSampleSize) then
              fNewSize := AudStreamInfo.dwSampleSize
            else
              fNewSize := fsize;
            GetMem(pModSilence, fNewSize);
            try
              ss := fNewSize div fsize;
            //write pSilence into pModSilence (fNewsize div fSize) times
              for j := 0 to ss - 1 do
                for jp := 0 to fsize - 1 do
                  pModSilence^[ss * j + jp] := pSilence^[jp];
              j := jmin;
              il := fNewSize div integer(AudStreamInfo.dwSampleSize);
              while j + il < integer(Start) do
              //dunno, the avistream things take integers,
              //the format has cardinals. That means,
              //it won't work anyway above the integer range.
              //So I can typecast these guys anywhich way I like.
              begin
                jp := j;
                hr := AVIStreamWrite(AudStream, jp, il, pModSilence, fNewSize, 0, SamplesWritten, BytesWritten);
                Assert(hr = 0, 'StreamWrite failed. Err: $' + IntToHex(hr, 8));
                j := jp + il;
                inc(SamplesSoFar, il);
              end;
              il := Start - Cardinal(j);
              if il > 0 then
              begin
                jp := j;
                hr := AVIStreamWrite(AudStream, jp, il, pModSilence, fNewSize, 0, SamplesWritten, BytesWritten);
                Assert(hr = 0, 'StreamWrite failed. Err: $' + IntToHex(hr, 8));
                inc(SamplesSoFar, il);
              end;
            finally
              FreeMem(pModSilence);
            end;
          end;
        end;
      l := AVIStreamLength(InputStream);

      if i < fWaveFileList.Count - 1 then
      begin
        NextStart := trunc(1 / 1000 * SampPerSec * integer(fWaveFileList.Objects[i + 1]));
        if NextStart < Start + l then
          l := NextStart - Start; //shorten audio length
      end;
      //write next audiofile into audstream.
      //if the silence didn't work, it goes at the end of
      //the previous file.
      SampleSize := l * AudStreamInfo.dwSampleSize;
      GetMem(pSample, SampleSize);
      try
        hr := AVIStreamRead(InputStream, OldInfo.dwStart, l, pSample, SampleSize, nil, nil);
        Assert(hr = 0, 'StreamRead failed. Err: $' + IntToHex(hr, 8));
        hr := AVIStreamWrite(AudStream, SamplesSoFar, l, pSample, SampleSize, 0, SamplesWritten, BytesWritten);
        Assert(hr = 0, 'StreamWrite failed. Err: $' + IntToHex(hr, 8));
        inc(SamplesSoFar, l);
      finally
        FreeMem(pSample);
      end;
    end; //for i looping through the wavefilelist


  finally
    if InputStream <> nil then
      AVIStreamRelease(InputStream);
    if InputFile <> nil then
      AVIFileRelease(InputFile);
    if AudStream <> nil then
      AVIStreamRelease(AudStream);
  end;

end;


// --------------
// InternalGetDIB
// --------------
// Converts a bitmap to a DIB of a specified PixelFormat.
//
// Parameters:
// Bitmap	The handle of the source bitmap.
// Pal		The handle of the source palette.
// BitmapInfo	The buffer that will receive the DIB's TBitmapInfo structure.
//		A buffer of sufficient size must have been allocated prior to
//		calling this function.
// Bits		The buffer that will receive the DIB's pixel data.
//		A buffer of sufficient size must have been allocated prior to
//		calling this function.
// PixelFormat	The pixel format of the destination DIB.
//
// Returns:
// True on success, False on failure.
//
// Note: The InternalGetDIBSizes function can be used to calculate the
// necessary sizes of the BitmapInfo and Bits buffers.
//

function TAviWriter_2.InternalGetDIB(Bitmap: HBITMAP; Palette: Hpalette;
  var BitmapInfo; var Bits; PixelFormat: TPixelFormat): boolean;
// From graphics.pas, "optimized" for our use
var
  OldPal: Hpalette;
  DC: HDC;
begin
  InitializeBitmapInfoHeader(Bitmap, TBitmapInfoHeader(BitmapInfo), PixelFormat);
  OldPal := 0;

  DC := CreateCompatibleDC(0);
  try
    if (Palette <> 0) then
    begin
      OldPal := SelectPalette(DC, Palette, false);
      realizepalette(DC);
    end;
    GDIFlush;
    Result := (GetDIBits(DC, Bitmap, 0, abs(TBitmapInfoHeader(BitmapInfo).biHeight),
      @Bits, TBitmapInfo(BitmapInfo), DIB_RGB_COLORS) <> 0);
  finally
    if (OldPal <> 0) then
      SelectPalette(DC, OldPal, false);
    DeleteDC(DC);
  end;

end;


// -------------------
// InternalGetDIBSizes
// -------------------
// Calculates the buffer sizes nescessary for convertion of a bitmap to a DIB
// of a specified PixelFormat.
// See the GetDIBSizes API function for more info.
//
// Parameters:
// Bitmap	The handle of the source bitmap.
// InfoHeaderSize
//		The returned size of a buffer that will receive the DIB's
//		TBitmapInfo structure.
// ImageSize	The returned size of a buffer that will receive the DIB's
//		pixel data.
// PixelFormat	The pixel format of the destination DIB.
//

procedure TAviWriter_2.InternalGetDIBSizes(Bitmap: HBITMAP; var InfoHeaderSize: integer;
  var ImageSize: Longint; PixelFormat: TPixelFormat);
// From graphics.pas, "optimized" for our use
var
  Info: TBitmapInfoHeader;
begin
  InitializeBitmapInfoHeader(Bitmap, Info, PixelFormat);
  // Check for palette device format
  if (Info.biBitCount > 8) then
  begin
    // Header but no palette
    InfoHeaderSize := SizeOf(TBitmapInfoHeader);
    if ((Info.biCompression and BI_BITFIELDS) <> 0) then
      inc(InfoHeaderSize, 12);
  end else
    // Header and palette
    InfoHeaderSize := SizeOf(TBitmapInfoHeader) + SizeOf(TRGBQuad) * (1 shl Info.biBitCount);
  ImageSize := Info.biSizeImage;
end;


// --------------------------
// InitializeBitmapInfoHeader
// --------------------------
// Fills a TBitmapInfoHeader with the values of a bitmap when converted to a
// DIB of a specified PixelFormat.
//
// Parameters:
// Bitmap	The handle of the source bitmap.
// Info		The TBitmapInfoHeader buffer that will receive the values.
// PixelFormat	The pixel format of the destination DIB.
//
{$IFDEF BAD_STACK_ALIGNMENT}
  // Disable optimization to circumvent optimizer bug...
{$IFOPT O+}
{$DEFINE O_PLUS}
{$O-}
{$ENDIF}
{$ENDIF}


procedure TAviWriter_2.InitializeBitmapInfoHeader(Bitmap: HBITMAP; var Info: TBitmapInfoHeader;
  PixelFormat: TPixelFormat);
// From graphics.pas, "optimized" for our use
var
  DIB: TDIBSection;
  Bytes: integer;
  function AlignBit(Bits, BitsPerPixel, Alignment: Cardinal): Cardinal;
  begin
    Dec(Alignment);
    Result := ((Bits * BitsPerPixel) + Alignment) and not Alignment;
    Result := Result shr 3;
  end;
begin
  DIB.dsbmih.biSize := 0;
  Bytes := GetObject(Bitmap, SizeOf(DIB), @DIB);
  if (Bytes = 0) then
    raise Exception.Create('Invalid bitmap');
//    Error(sInvalidBitmap);

  if (Bytes >= (SizeOf(DIB.dsBm) + SizeOf(DIB.dsbmih))) and
    (DIB.dsbmih.biSize >= SizeOf(DIB.dsbmih)) then
    Info := DIB.dsbmih
  else
  begin
    FillChar(Info, SizeOf(Info), 0);
    with Info, DIB.dsBm do
    begin
      biSize := SizeOf(Info);
      biWidth := bmWidth;
      biHeight := bmHeight;
    end;
  end;
  case PixelFormat of
    pf1Bit: Info.biBitCount := 1;
    pf4Bit: Info.biBitCount := 4;
    pf8bit: Info.biBitCount := 8;
    pf24bit: Info.biBitCount := 24;
  else
//    Error(sInvalidPixelFormat);
    raise Exception.Create('Invalid pixel foramt');
    // Info.biBitCount := DIB.dsbm.bmBitsPixel * DIB.dsbm.bmPlanes;
  end;
  Info.biPlanes := 1;
  Info.biCompression := BI_RGB; // Always return data in RGB format
  Info.biSizeImage := AlignBit(Info.biWidth, Info.biBitCount, 32) * Cardinal(abs(Info.biHeight));

end;
{$IFDEF O_PLUS}
{$O+}
{$UNDEF O_PLUS}
{$ENDIF}

procedure TAviWriter_2.SetWavFileName(value: string);
begin
  if LowerCase(fWavFileName) <> LowerCase(value)
    then if value <> ''
    then if LowerCase(ExtractFileExt(value)) <> '.wav'
      then raise Exception.Create('WavFileName must name a file '
          + 'with the .wav extension')
      else fWavFileName := value
    else fWavFileName := value;

end;


procedure TAviWriter_2.InternalAddFrame(const Bitmap: TBitmap; Key: boolean);
var
  Samples_Written: LONG;
  Bytes_Written: LONG;
  AVIERR: integer;
  DIB: TDIBSection;
  DIBErr: integer;
  flag: DWord;
begin


      // On the first time through, set the stream format.
      // A bit roundabout so the colors can be retrieved
      // in case of pixelformats <=pf8bit, but I'd rather
      // be safe.
  if fFrameCount = 0 then
  begin
    InitStreamFormat(Bitmap);
  end;

  FillChar(DIB, SizeOf(DIB), 0);
  DIBErr := GetObject(Bitmap.Handle, SizeOf(DIB), @DIB);
  if DIBErr = 0 then
  begin
      //fire event for troubleshooting
    if Assigned(fOnBadBitmap) then
      fOnBadBitmap(Self, Bitmap, SizeOf(DIB.dsbmih), DIB.dsbmih.biSizeImage);
    raise Exception.Create('Failed to retrieve bitmap header and pixels. Err: ' + IntToStr(GetLastError));
  end;
               // Write frame to the video stream
  if Key then
    flag := AVIIF_KEYFRAME
  else
    flag := 0;
  try
    AVIERR :=
      AVIStreamWrite(fCompStream, fFrameCount, 1, DIB.dsBm.bmBits, DIB.dsbmih.biSizeImage, flag,
      Samples_Written, Bytes_Written);
  except
    AVIERR := AVIERR_ERROR; //for the DivX unhandled floating point..
  end;
  if AVIERR <> AVIERR_OK then
    raise Exception.Create('Failed to add Frame. Err: ' + IntToHex(AVIERR, 8));
  inc(fFrameCount);

  if Assigned(fOnProgress) then
    if (fFrameCount mod 20 = 0) then
      fOnProgress(Self, fFrameCount, fAbort);
end;

procedure TAviWriter_2.FinalizeVideo;
begin
  fInitialized := false;
  fFinalized := true;
  //Doesn't do much anymore...
end;

procedure TAviWriter_2.InitVideo;
var S, Workfile: string;
  AVIERR: HRESULT;
begin
  VideoStream := nil;
  fCompStream := nil;
  fPstream := nil;
  AudioStream := nil;
  fAbort := false;
  pfile := nil;

  if fPixelFormat = pfDevice then
  begin
    fAbort := true;
    raise Exception.Create('For adding frames on the fly the pixelformat must be <> pfDevice');
    exit;
  end;

  if fCompOnFly then
    Workfile := fFilename
  else
    Workfile := TempFileName;
  if FileExists(Workfile) then
    if not Deletefile(Workfile) then
      raise Exception.Create('Could not delete ' + Workfile + ' file might be in use. Try to close the folder if it''s open in Explorer');


  //need to start with new files,
  //otherwise the compression doesn't
  //work, and the files just get larger and larger



    // Open AVI file for write
  AVIERR := AVIFileOpen(pfile, PChar(Workfile),
    OF_WRITE or OF_CREATE, nil);
    //Shareexclusive causes nothing but trouble on an exception
  if AVIERR <> AVIERR_OK
    then
    raise Exception.Create('Failed to create AVI video file. Err: $' + IntToHex(AVIERR, 8));

    // Write the stream header.
  FillChar(fStreamInfo, SizeOf(fStreamInfo), 0);

       // Set frame rate and scale
  fStreamInfo.dwRate := 1000;
  fStreamInfo.dwScale := fFrameTime;
  fStreamInfo.fccType := streamtypeVIDEO;
  S := fFourCC;
  if S = '' then
    fStreamInfo.fccHandler := 0
  else
    fStreamInfo.fccHandler := mmioStringToFOURCC(PChar(S), 0);
  fStreamInfo.dwQuality := fCompressionQuality;
  fStreamInfo.dwFlags := 0;
  fStreamInfo.dwSuggestedBufferSize := 0;
  fStreamInfo.rcFrame.Right := Self.Width;
  fStreamInfo.rcFrame.Bottom := Self.Height;

       // Open AVI data stream
  if (AVIFileCreateStream(pfile, fPstream, fStreamInfo) <> AVIERR_OK) then
    raise Exception.Create('Failed to create AVI video stream');

  //the initialization of the compressed stream needs to
  //be deferred until the first frame comes in.
  fFrameCount := 0;
  fInitialized := true;
end;


function TAviWriter_2.AviSaveCallback(i: integer): LONG; pascal;

begin
  if Assigned(fOnProgress) then fOnProgress(Self, trunc(1 / 100 * fFrameCount * i), fAbort);
  if fAbort then
    Result := AVIERR_USERABORT
  else
    Result := AVIERR_OK;
end;

procedure TAviWriter_2.WriteAvi;

type
  TCallbackThunk = packed record
    POPEDX: byte;
    MOVEAX: byte;
    SelfPtr: Pointer;
    PUSHEAX: byte;
    PUSHEDX: byte;
    JMP: byte;
    JmpOffset: integer;
  end;

var
  Callback: TCallbackThunk;
  nStreams: integer;
  Streams: APAVISTREAM;
  CompOptions: APAVICompressOptions;
  AVIERR: HRESULT;
  refcount: integer;

begin
  if fAbort or (not fFinalized) then
  begin
    if fPstream <> nil then
      AVIStreamRelease(fPstream);
    if fCompStream <> nil then
      AVIStreamRelease(fCompStream);
    fCompStream := nil;
    fPstream := nil;
    fWaveFileList.Clear;
    try
      repeat
        refcount := AVIFileRelease(pfile);
      until refcount <= 0;
      pfile := nil;
    except
      pfile := nil;
    end;
    if not fFinalized then
      raise Exception.Create('Video must be finalized');
    exit;
  end;

  try
    if not fCompOnFly then
      if fWavFileName = '' then
        if fWaveFileList.Count > 0 then
          fWavFileName := fWaveFileList.Strings[0];

    if fCompOnFly then
      AddAudioMod
    else
      if WavFileName <> '' then
        AddAudio;

    if not fCompOnFly then
    begin

      if FileExists(filename) then
        if not Deletefile(filename) then
          raise Exception.Create('File ' + ExtractFileName(filename) + ' could not be deleted. It could be in use by another application.');

      if WavFileName <> ''
        then nStreams := 2
      else nStreams := 1;

      Streams[0] := fCompStream;
      Streams[1] := AudioStream;
      if fFourCC = '' then
        CompOptions[0] := nil
      else
        CompOptions[0] := @AviCompressoptions;
      CompOptions[1] := nil;

    //trick a method into a callback.
    //from SysUtils.TLanguages.Create
      Callback.POPEDX := $5A;
      Callback.MOVEAX := $B8;
      Callback.SelfPtr := Self;
      Callback.PUSHEAX := $50;
      Callback.PUSHEDX := $52;
      Callback.JMP := $E9;
      Callback.JmpOffset := integer(@TAviWriter_2.AviSaveCallback) - integer(@Callback.JMP) - 5;


      AVIERR := AVISaveV(PChar(filename), nil, TAVISaveCallback(@Callback), nStreams, Streams, CompOptions);

      if AVIERR <> AVIERR_OK then
        if not fAbort then
        raise Exception.Create('Unable to write output file. Error ' + IntToHex(AVIERR, 8));

    end;
  finally
    if fCompStream <> nil then
      AVIStreamRelease(fCompStream);
    if fPstream <> nil then
      AVIStreamRelease(fPstream);
    if AudioStream <> nil then
      AVIStreamRelease(AudioStream);
    AudioStream := nil;
    fCompStream := nil;
    fPstream := nil;
    fWaveFileList.Clear;
    if FileExists(TempFileName) then
      Deletefile(TempFileName);
    try
      repeat
        refcount := AVIFileRelease(pfile);
      until refcount <= 0;
      pfile := nil;
    except
      pfile := nil;
    end;
    fFinalized := false;
  end;
end;


const
  BitCounts: array[pf1Bit..pf32Bit] of byte = (1, 4, 8, 16, 16, 24, 32);

function FourCCToString(f: DWord): TFourCC;
var
  S, s1: string;
  b: byte;
  c: Char;
begin
  SetLength(Result, 4);
  S := IntToHex(f, 8);
  s1 := '$' + copy(S, 7, 2);
  b := StrToInt(s1);
  c := chr(b);
  Result[1] := c;
  Result[2] := chr(StrToInt('$' + copy(S, 5, 2)));
  Result[3] := chr(StrToInt('$' + copy(S, 3, 2)));
  Result[4] := chr(StrToInt('$' + copy(S, 1, 2)));
  //strings are easier than math :)
end;

procedure TAviWriter_2.Compressorlist(const List: TStrings);
var
  ii: TICINFO;
  i: DWord;
  ic: THandle;
  BitmapInfoHeader: TBitmapInfoHeader;
  Name: WideString;
  j: integer;

begin
  List.Clear;
  List.add('No Compression');

  FillChar(BitmapInfoHeader, SizeOf(BitmapInfoHeader), 0);
  with BitmapInfoHeader do
  begin
    biSize := SizeOf(BitmapInfoHeader);
    biWidth := fWidth;
    biHeight := fHeight;
    biPlanes := 1;
    biCompression := BI_RGB;
    biBitCount := BitCounts[fPixelFormat];
  end;

  ii.dwSize := SizeOf(ii);
  for i := 0 to 200 do //what's a safe number to get all?
  begin
    if ICInfo(ICTYPE_VIDEO, i, @ii) then
    begin
      ic := ICOpen(ICTYPE_VIDEO, ii.fccHandler, ICMODE_QUERY);
      try
        if ic <> 0 then
        begin
          if ICCompressQuery(ic, @BitmapInfoHeader, nil) = 0 then
          begin
            ICGetInfo(ic, @ii, SizeOf(ii));
          //can the following be done any simpler?
            Name := '';
            for j := 0 to 15 do
              Name := Name + ii.szName[j];
            List.add(FourCCToString(ii.fccHandler) + ' ' + string(Name));
          end;
        end;
      finally
        ICClose(ic);
      end;
    end;
  end;
end;

procedure TAviWriter_2.SetCompression(FourCC: TFourCC);
var S: string;
  ic: THandle;
  BitmapInfoHeader: TBitmapInfoHeader;
begin
  fFourCC := '';
  if FourCC = '' then
    exit;
  FillChar(BitmapInfoHeader, SizeOf(BitmapInfoHeader), 0);
  with BitmapInfoHeader do
  begin
    biSize := SizeOf(BitmapInfoHeader);
    biWidth := fWidth;
    biHeight := fHeight;
    biPlanes := 1;
    biCompression := BI_RGB;
    biBitCount := BitCounts[fPixelFormat];
  end;
  S := FourCC;
  ic := ICLocate(ICTYPE_VIDEO, mmioStringToFOURCC(PChar(S), 0), @BitmapInfoHeader, nil,
    ICMODE_COMPRESS);
  if ic <> 0 then
  begin
    fFourCC := FourCC;
    ICClose(ic);
  end
  else
    raise Exception.Create('No compressor for ' + FourCC + ' available');
end;


procedure TAviWriter_2.AddStillImage(const ABmp: TBitmap; Showtime: integer);
var i: integer;
  Samples_Written: LONG;
  Bytes_Written: LONG;
  AVIERR: HRESULT;
  Bitmap: TBitmap;
  r1, r2: TRect;
begin
  if fAbort then
    exit;
  if not fInitialized then
    raise Exception.Create('Video must be initialized.');
  if (fFourCC = '') or (not fCompOnFly) then
  begin
    AddFrame(ABmp);
    for i := 1 to (Showtime div FrameTime) do
  //might be a tad longer than showtime
    begin
               // Write empty frame to the video stream

      AVIERR :=
        AVIStreamWrite(fCompStream, fFrameCount, 1, nil, 0, 0,
        Samples_Written, Bytes_Written);
      if AVIERR <> AVIERR_OK then
        raise Exception.Create
          ('Failed to add frame to AVI. Err='
          + IntToHex(AVIERR, 8));

      inc(fFrameCount);

      if (fFrameCount mod 10 = 0) then
        if Assigned(fOnProgress) then
          fOnProgress(Self, fFrameCount, fAbort);
    end;
  end
  else
  begin
    Bitmap := TBitmap.Create;
    try

      Bitmap.PixelFormat := fPixelFormat;
    //need to force the same for all

      Bitmap.Width := Self.Width;
      Bitmap.Height := Self.Height;
      Bitmap.Canvas.Lock;
      try
        ABmp.Canvas.Lock;
        try
          if fStretch
            then Bitmap.Canvas.stretchdraw
            (Rect(0, 0, Self.Width, Self.Height), ABmp)
          else
           //center image on black background
            with Bitmap.Canvas do begin
              Brush.Color := clBlack;
              Brush.Style := bsSolid;
              FillRect(ClipRect);
              r1 := Rect(0, 0, ABmp.Width, ABmp.Height);
              r2 := r1;
              OffsetRect(r2, (Width - ABmp.Width) div 2, (Height - ABmp.Height) div 2);
              CopyRect(r2, ABmp.Canvas, r1);
            end;
        finally
          ABmp.Canvas.Unlock;
        end;

      finally
        Bitmap.Canvas.Unlock;
      end;
      for i := 0 to (Showtime div FrameTime) do
        InternalAddFrame(Bitmap, true);
    finally
      Bitmap.Free;
    end;
  end;
end;


procedure TAviWriter_2.SetCompressionQuality(q: integer);
begin
  fCompressionQuality := q;
end;

procedure TAviWriter_2.ShowCompressorDialog(ADialogParent: TWinControl);
var ic: THandle;
  S: string;
begin
  if fFourCC = '' then
    exit;
  S := fFourCC;
  ic := ICOpen(ICTYPE_VIDEO, mmioStringToFOURCC(PChar(S), 0), ICMODE_QUERY);
  try
    if ic <> 0 then
    begin
      if ICQueryConfigure(ic) then
        ICConfigure(ic, ADialogParent.Handle);
    end;
  finally
    ICClose(ic);
  end;
end;

procedure TAviWriter_2.SetPixelFormat(const value: TPixelFormat);
begin
  if not (value in [pf1Bit, pf4Bit, pf8bit, pf24bit, pf32Bit]) then
    raise Exception.Create('Pixelformat not supported');
  fPixelFormat := value;
end;

procedure TAviWriter_2.InitStreamFormat(const bm: TBitmap);
var DIB: TDIBSection;
  Bits: Pointer;
  DIBErr: integer;
  S: string;
begin
  FillChar(DIB, SizeOf(DIB), 0);
  DIBErr := GetObject(bm.Handle, SizeOf(DIB), @DIB);
  if DIBErr = 0 then
  begin
      //fire event for troubleshooting
    if Assigned(fOnBadBitmap) then
      fOnBadBitmap(Self, bm, SizeOf(DIB.dsbmih), DIB.dsbmih.biSizeImage);
    raise Exception.Create('Failed to retrieve bitmap header and pixels. Err: ' + IntToStr(GetLastError));
  end;
  if fPInInfo <> nil then
    FreeMem(fPInInfo);
  fPInInfo := nil;
  fInInfoSize := SizeOf(TBitmapInfoHeader);
  if DIB.dsbmih.biBitCount <= 8 then
    fInInfoSize := fInInfoSize + SizeOf(TRGBQuad) * (1 shl DIB.dsbmih.biBitCount);

  GetMem(fPInInfo, fInInfoSize);
  GetMem(Bits, DIB.dsbmih.biSizeImage);
  try
    if not GetDIB(bm.Handle, 0, fPInInfo^, Bits^)
      then raise Exception.Create('Failed to retrieve bitmap info');
  finally
    FreeMem(Bits);
      //fPInInfo^ needs to stay around
  end;
  FillChar(AviCompressoptions, SizeOf(AviCompressoptions), 0);
  if fFourCC <> '' then
  begin
    with AviCompressoptions do
    begin
      fccType := streamtypeVIDEO;
      S := fFourCC;
      fccHandler := mmioStringToFOURCC(PChar(S), 0);
      dwKeyFrameEvery := round(1000 / fFrameTime);
      dwQuality := fCompressionQuality;
      dwFlags := AVICOMPRESSF_KEYFRAMES or AVICOMPRESSF_VALID;
      lpFormat := fPInInfo;
      cbFormat := fInInfoSize;
    end;
    if fCompOnFly then
    begin
      if AVIMakeCompressedStream(fCompStream, fPstream, @AviCompressoptions, nil) <> AVIERR_OK then
        raise Exception.Create('Failed to create compressed stream');
    end
    else
    begin
      fCompStream := fPstream;
      fPstream := nil;
    end;
  end
  else
  begin
    fCompStream := fPstream;
    fPstream := nil;
  end;
  if (AVIStreamSetFormat(fCompStream, 0, fPInInfo, fInInfoSize) <> AVIERR_OK) then
    raise Exception.Create('Failed to set AVI stream format');
end;

procedure TAviWriter_2.AddWaveFile(const filename: string; Delay: integer);
begin
  if LowerCase(ExtractFileExt(filename)) <> '.wav'
    then raise Exception.Create('WavFileName must name a file '
      + 'with the .wav extension')
  else
    fWaveFileList.AddObject(filename, TObject(Delay))
end;

procedure TAviWriter_2.AddFrame(const ABmp: TBitmap);
var Bitmap: TBitmap;
  r1, r2: TRect;
begin
  if fAbort then
    exit;
  if not fInitialized then
    raise Exception.Create('Video must be initialized.');
  Bitmap := TBitmap.Create;
  try

    Bitmap.PixelFormat := fPixelFormat;
    //need to force the same for all

    Bitmap.Width := Self.Width;
    Bitmap.Height := Self.Height;
    Bitmap.Canvas.Lock;
    try
      ABmp.Canvas.Lock;
      try
        if fStretch
          then Bitmap.Canvas.stretchdraw
          (Rect(0, 0, Self.Width, Self.Height), ABmp)
        else
           //center image on black background
          with Bitmap.Canvas do begin
            Brush.Color := clBlack;
            Brush.Style := bsSolid;
            FillRect(ClipRect);
            r1 := Rect(0, 0, ABmp.Width, ABmp.Height);
            r2 := r1;
            OffsetRect(r2, (Width - ABmp.Width) div 2, (Height - ABmp.Height) div 2);
            CopyRect(r2, ABmp.Canvas, r1);
          end;
      finally
        ABmp.Canvas.Unlock;
      end;

    finally
      Bitmap.Canvas.Unlock;
    end;

    InternalAddFrame(Bitmap, true);

  finally
    Bitmap.Free;
  end;
end;

end.

