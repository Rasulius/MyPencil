unit MagicBrush;

interface

uses Graphics;

{* ���������� ����� ������ 1.0 ���������� ��������� ������ � �������
      �������� ������������ ������ ���������� � �������  *}


type
  TMagicBrush = class
    FCurrentValue: TColor;
  private
    FPenWidth: Integer;
    FBrushIcon: TIcon;
    FName: string;
    FCanvas: TCanvas;
    FColor: TColor;
    FIsFirstCall: Boolean;

    procedure SetPenWidth(const Value: Integer);
    procedure SetBrushIcon(const Value: TIcon);
    procedure SetName(const Value: string);
    procedure SetColor(const Value: TColor);
  public
    constructor Create(aCanvas: TCanvas); virtual;
    // �������� � ������� ����� ��� ����� ����
    procedure Draw(X, Y: Integer); virtual; abstract;
    procedure RefreshBrush(); virtual; abstract;

   // ������ ����
    property Width: Integer read FPenWidth write SetPenWidth;
    // �������� ������
    property Icon: TIcon read FBrushIcon write  SetBrushIcon;
    // �������� ���
    property Name: string read FName write SetName;
    // �������� ����
    property ActiveColor: TColor read FColor write SetColor;
    // ����� ��������
    property Canvas: Tcanvas read FCanvas write FCanvas;
    // ���� ������� ����� �������
    property ISFirstCall: Boolean read FIsFirstCall write FIsFirstCall;

  end;

implementation

{ TMagicBrush }

constructor TMagicBrush.Create(aCanvas: TCanvas);
begin
  FCanvas := aCanvas;
  FIsFirstCall := true;
end;

procedure TMagicBrush.SetBrushIcon(const Value: TIcon);
begin
  FBrushIcon := Value;
end;

procedure TMagicBrush.SetColor(const Value: TColor);
begin
  FColor := Value;
  FCanvas.Pen.Color := Value;
  FCurrentValue := FColor;
end;

procedure TMagicBrush.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TMagicBrush.SetPenWidth(const Value: Integer);
begin
  FPenWidth := Value;
end;

end.
