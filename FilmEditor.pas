unit FilmEditor;

interface

uses Windows, Graphics, SysUtils;

{* ����������� ����� ��������
  ��������� ��������� ����, �������, ����������


 *}
type
  TFilmEditorType = (feBitmapFileEditor);
  TFilmEditor = class
  public
    constructor Create; virtual; abstract;
    destructor Destroy; override;

      // �������� ����
     procedure AddFrame(aFrame: TBitmap); virtual; abstract;
     // ������� ����
     procedure DeleteFrame(anIndex: Integer); virtual; abstract;
     //  ���������� ����
     procedure CopyFrame(anSourceIndex: Integer; aCopyIndex: Integer); virtual; abstract;
     // �������� ����
     procedure GetFrame(anIndex: Integer; aBitmap: TBitmap); virtual; abstract;
     // �������������� ����
     procedure ModifyFrame(anIndex: Integer; aBitmap: TBitmap); virtual; abstract;
     // ���� ���������� ����
     function FrameExist(anIndex: Integer): Boolean; virtual; abstract;
      // ���������� ������
     function FrameCount: Integer; virtual; abstract;

  end;

  // ���������� ������ FilmEditor

  TFileFilmEditor = class(TFilmEditor)
  private
    FBaseFileName: String;
    FTempFolderName: String;
    FAbsolutePath: String;
    FIndex: Integer;
    Fcount: Integer;

    function CreateFilename(aBase: String; Number: Integer; NumberOfPlaces: Integer = 10): String;
    procedure CheckIndex(anIndex: Integer);

    function GetStartName: String;
    function GetEndFileName: String;
    //.unction GetNameByIndex(Index: Integer): String;

  public
    constructor Create(); override;
    destructor Destroy; override;

    procedure AddFrame(aFrame: TBitmap);override;
    // ������� ����
    procedure DeleteFrame(anIndex: Integer); override;
 //  ���������� ����
    procedure CopyFrame(anSourceIndex: Integer; aCopyIndex: Integer); override;
 // ������������� ����
    procedure ModifyFrame(anIndex: Integer; aBitmap: TBitmap); override;

    procedure GetFrame(anIndex: Integer; aBitmap: TBitmap);override;

    function FrameExist(anIndex: Integer): Boolean;  override;
      // ���������� ������
    function FrameCount: Integer;  override;


    property StartFileName: String read GetStartName;
    property EndFileName: String read GetEndFileName;
    property AbsolutePath: String read FAbsolutePath;

  end;


  TEditorFabrics=class
    function CreateFilmEditor(aEditorType: TFilmEditorType): TFileFilmEditor;
  end;

implementation


{ TFileFilmEditor }

constructor TFileFilmEditor.Create;
begin
  FBaseFileName :='temp_';
  FTempFolderName := 'temp_project';
  FAbsolutePath := IncludeTrailingBackslash(GetCurrentDir)+FTempFolderName;
  FIndex := -1;
  Fcount := 0;
  // ������� ������� ��� ���������� ��������� ������
  if not DirectoryExists(FAbsolutePath) then begin
    CreateDir(FAbsolutePath);
  end;
end;

function TFileFilmEditor.CreateFilename(aBase: String; Number,
  NumberOfPlaces: Integer): String;
var
  aFormatString: String;
begin
  aFormatString := '%s%.'+IntToStr(NumberOfPlaces)+'d.bmp';
  Result := IncludeTrailingBackslash(FAbsolutePath) + Format(aFormatString,[aBase,Number]);
end;

function TFileFilmEditor.FrameCount: Integer;
begin
  Result := Fcount;
end;

function TFileFilmEditor.FrameExist(anIndex: Integer): Boolean;
var
  aFileName: String;
begin
  CheckIndex(anIndex);
  aFileName:= CreateFilename(FBaseFileName, anIndex);
  Result := FileExists(aFileName);
end;

function TFileFilmEditor.GetEndFileName: String;
begin
  Result := CreateFilename(FBaseFileName, FIndex);
end;

procedure TFileFilmEditor.GetFrame(anIndex: Integer; aBitmap: TBitmap);
begin
  CheckIndex(anIndex);
  aBitmap.LoadFromFile(CreateFilename(FBaseFileName, anIndex));
end;


function TFileFilmEditor.GetStartName: String;
begin
  Result := CreateFilename(FBaseFileName, 0);
end;


procedure TFileFilmEditor.AddFrame(aFrame: TBitmap);
begin
  Inc(Findex);
  Inc(FCount);
  aFrame.SaveToFile(CreateFilename(FBaseFileName, FIndex));
end;

// ��������� ���� �� �������

procedure TFileFilmEditor.CheckIndex(anIndex: Integer);
begin
  if anIndex > Fcount then begin
    raise Exception.Create('�������� ������ ������������ ���������� #10#13 ������������������ �������� � �������');
  end;

end;

procedure TFileFilmEditor.CopyFrame(anSourceIndex: Integer; aCopyIndex: Integer);
var
  aBitmap: TBitmap;
begin
  CheckIndex(anSourceIndex);
  aBitmap := TBitmap.Create;
  // ���� �������� �� ����� ����� ������ ������� ����� ����,
  // �������������� ���������� ������ �����������
  if aCopyIndex>Fcount then begin
    Fcount := aCopyIndex
  end;

  try
    aBitmap.LoadFromFile(CreateFilename(FBaseFileName, anSourceIndex));
    aBitmap.SaveToFile(CreateFilename(FBaseFileName, aCopyIndex));
  finally
    aBitmap.Free;
  end;

end;

// ������������ �������

procedure TFileFilmEditor.ModifyFrame(anIndex: Integer; aBitmap: TBitmap);
begin
  CheckIndex(anIndex);
  aBitmap.SaveToFile(CreateFilename(FBaseFileName, anIndex));
end;


procedure TFileFilmEditor.DeleteFrame(anIndex: Integer);
var
  aFileName: String;
begin
  CheckIndex(anIndex);
  aFileName := CreateFilename(FBaseFileName, anIndex);
  if FileExists(aFileName) then begin
    SysUtils.DeleteFile(aFileName);
  end;

end;

destructor TFileFilmEditor.Destroy;
begin
  inherited;
end;



{ TEditorFabrics }

function TEditorFabrics.CreateFilmEditor(
  aEditorType: TFilmEditorType): TFileFilmEditor;
begin
//
  Result := nil;

  if aEditorType = feBitmapFileEditor then begin
    Result := TFileFilmEditor.Create;
  end;

end;

{ TFilmEditor }

destructor TFilmEditor.Destroy;
begin
  inherited;
end;

end.
