unit DrawStateMachine;

interface

uses Graphics, Classes;

type
// ���� ������������

  // ��������� ������
  TCurrentStatesInstrument = (csNone, csRemeberCoord, csPencil, csFill, csCircle, csKvadrat, csArc, csline, cslastic, csSelect, csSelectMoveOrRotate);
  // ������ ���������


  TDrawStateMachine = class
  private
    FirstCall: Boolean; // ���� ������ ����� ������� �� ���� ���������� � false;
    FCurrentState: TCurrentStatesInstrument;
  public
      constructor Create;

      procedure OnMouseMove(aCanvas: TCanvas; aBuffer: TCanvas;
        Sender: TObject; Shift: TShiftState; X, Y: Integer);
//      procedure OnMouseDown(aCanvas: TCanvas; aBuffer: TCanvas;
//        Sender: TObject; Shift: TShiftState; X, Y: Integer);

  end;


implementation

{ TDrawStateMachine }

constructor TDrawStateMachine.Create;
begin
  FirstCall := true;
  FCurrentState := csNone;
end;

procedure TDrawStateMachine.OnMouseMove(aCanvas, aBuffer: TCanvas;
 Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin


end;

end.
