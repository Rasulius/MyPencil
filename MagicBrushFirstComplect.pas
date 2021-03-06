unit MagicBrushFirstComplect;

interface

uses Windows, MagicBrush, Graphics;
 {
 ������� ����� ������ ��������, ����� �������������� ��� ����� ����� ���������� �����������
  ������ 1.0
 }

type
  TGradientBrush = class(TMagicBrush)
    FRemeberColor: TColor; // ���������� ��������� �������� �����

  public
      constructor Create(aCanvas: TCanvas);override;

      procedure Draw(X, Y: Integer); override;
      procedure RefreshBrush(); override;
end;


implementation

{ TGradientBrush }

constructor TGradientBrush.Create(aCanvas: TCanvas);
begin
  inherited Create(aCanvas);
  ActiveColor := clRed;
  Width := 10;
  Name:= 'Gradient brush';
  FRemeberColor:= ActiveColor;
end;

procedure TGradientBrush.Draw(X, Y: Integer);
const
  DivParams = 5;
var
  aRed,aGreen, aBlue: Byte;
  aCurrent: Byte;

begin
  aRed := GetRValue(FCurrentValue);
  aGreen := GetGValue(FCurrentValue);
  aBlue := GetBValue(FCurrentValue);

  if (aRed >= aGreen) and (aRed >= aBlue ) then begin
    aCurrent := aRed - 1;

    if aCurrent <= 0 then begin
      ActiveColor := RGB(0, aGreen, aBlue);
    end else begin
      ActiveColor := RGB(aCurrent, aGreen, aBlue);
    end;

  end else if (aGreen >= aRed) and (aGreen >= aBlue )  then begin

    aCurrent := aGreen - 1;

    if aCurrent <= 0 then begin
      ActiveColor := RGB(aRed, 0, aBlue);
    end else begin
      ActiveColor := RGB(aRed, aCurrent, aBlue);
    end;

  end else if (aBlue >= aRed) and (aBlue >= aGreen )  then begin

    aCurrent := aBlue - 1;

    if aCurrent <= 0 then begin
      ActiveColor := RGB(aRed, aGreen, 0);
    end else begin
      ActiveColor := RGB(aRed, aGreen, aCurrent);
    end;

  end else begin
     ActiveColor := RGB(aRed, aGreen , aBlue);
  end;


  if (ISFirstCall) then begin
    ISFirstCall := False;
    Canvas.MoveTo(X,Y);
  end;
  Canvas.LineTo(X,Y);

end;

procedure TGradientBrush.RefreshBrush;
begin
  inherited;
  ActiveColor := FRemeberColor;

end;

end.
