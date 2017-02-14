unit FilmManager;

interface

uses SysUtils, Graphics, FilmEditor, ExtCtrls, Controls;

{*
������� ���������, ��������� ������� ����� ������ ��� �����.
����� �������� Editor. Editor �������� ��������� ����� - ���������
*}

const
  FILM_EDITOR_DONT_ASSIGNED = '�������� �� ������ � ����������';
  EDITOR_NOT_ASSIGNED = '�� ��������������� ��������';

type
  TFrameSize = (fsSmall, fsMedium, fsBig);
  TFilmManager = class
  private
    CurrentSelectFrame: Integer;
    FEditor: TFilmEditor;
  public
    constructor Create; virtual; abstract;
   // �������� �� ���������� image �������� ��������
    procedure DrawByFrameInterval(aStartIndex: Integer; aEndIndex: Integer); virtual; abstract;
    // ������� ����� ������
    procedure MoveLentToRight; virtual; abstract;
    // ������� ����� �����
    procedure MoveLentToLeft; virtual; abstract;
    procedure OnSelect(anXm, anY: Integer); virtual; abstract;
    function GetEditor: TFilmEditor; virtual; abstract;
    procedure Repaint; virtual; abstract;
  end;


  TImageBoxFilmManager = class(TFilmManager)
  protected
    const DrawFrameCount = 10; // ������� ������ ���������� �� ���������
    const DefaultImage = 0;
  private


    FImage: TImage;
    FActiveFrame: Integer;
    FCurrentStartFrame: Integer;
    FImageList: TImageList;
    procedure InitFilmEditor;
    procedure SetActiveFrame(const Value: Integer);

  public
    constructor Create(); override;
    procedure InitImage(anImage: TImage; anImageList: TImageList);


    procedure DrawByFrameInterval(aStartIndex: Integer; aEndIndex: Integer); override;
    // ������� ����� ������
    procedure MoveLentToRight; override;
    // ������� ����� �����
    procedure MoveLentToLeft; override;
    procedure OnSelect(anXm, anY: Integer); override;
    function GetEditor: TFilmEditor; override;
    procedure Repaint; override;

    property ActiveFrame: Integer read FActiveFrame write SetActiveFrame;
  end;


implementation

uses ImageUtils;

{ TImageBoxFilmManager }

constructor TImageBoxFilmManager.Create;
var
  aFabric: TEditorFabrics;
begin
  CurrentSelectFrame := -1;
  FActiveFrame:= 0;
  aFabric := TEditorFabrics.Create;
  try
    FEditor := aFabric.CreateFilmEditor(feBitmapFileEditor);
    // �������������� ������ ������
    InitFilmEditor;
  finally
    aFabric.Free;
  end;

end;



function TImageBoxFilmManager.GetEditor: TFilmEditor;
begin
  if not Assigned(FEditor) then begin
    raise Exception.Create(FILM_EDITOR_DONT_ASSIGNED);
  end;
  Result := FEditor;

end;

procedure TImageBoxFilmManager.DrawByFrameInterval(aStartIndex,
  aEndIndex: Integer);
begin
  {* �������� ����������� ����������� �������� � ���������� �� ���� �� ������ *}
  if not Assigned(FEditor) then begin
    raise Exception.Create(FILM_EDITOR_DONT_ASSIGNED);
  end;
  //
end;

// ������������� ����������� �����������

procedure TImageBoxFilmManager.InitFilmEditor;
var
  aBitmap: TBitmap;
  i: Integer;
begin
  aBitmap := TBitmap.Create;
  try
  // ��������� ������ ����
    aBitmap.SetSize(640, 480);
    FEditor.AddFrame(aBitmap);
    // ������� 10 ������ ������������ �� �������
    for i := 1 to DrawFrameCount do begin
      FEditor.CopyFrame(0, i);
    end;

  finally
    aBitmap.Free;
  end;
end;

procedure TImageBoxFilmManager.InitImage(anImage: TImage; anImageList: TImageList);
begin
  FImage := anImage;
  FImageList := anImageList;
end;

// ��������� ����������� ������

procedure TImageBoxFilmManager.Repaint;
var
  aBitmap: TBitmap;
  aScaleImages: TBitmap;
  i: Integer;
begin
  aBitmap:= TBitmap.Create;
  try
  // ����������� �������� �� ���������� ��������� �� (����� ������� ��������� � �����.)

     aScaleImages:= TBitmap.Create;

     try
        for I := FCurrentStartFrame to DrawFrameCount - 1 do begin
         // ���� ���� ����������, �� �������� ��� � ��������������� ���������
          if FEditor.FrameExist(i) then begin
             FEditor.GetFrame(i, aBitmap);
             ResizeImage(aBitmap, aScaleImages, 60, PROPRTIONAL_RESIZE);
          end else begin
             aScaleImages.SetSize(60,80);
          end;
          // ������ ����������� ������ � �� ��� ���� ������� �����������
            FImageList.GetBitmap(DefaultImage, aBitmap);
            FImage.Canvas.Draw(i*aBitmap.Width+10, 0, aBitmap);
            FImage.Canvas.Draw(i*aBitmap.Width+12,20, aScaleImages);
      end;

     finally
      aScaleImages.Free;
     end;
//    FImage.Canvas.Draw();
  finally
    aBitmap.Free;
  end;
end;


procedure TImageBoxFilmManager.SetActiveFrame(const Value: Integer);
begin
  FActiveFrame := Value;
end;

procedure TImageBoxFilmManager.MoveLentToLeft;
begin

end;

procedure TImageBoxFilmManager.MoveLentToRight;
begin

end;

procedure TImageBoxFilmManager.OnSelect(anXm, anY: Integer);
begin

end;
end.
