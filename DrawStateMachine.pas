unit DrawStateMachine;

interface

uses Graphics, Classes;

type
// Типы инструментов

  // Состояние машины
  TCurrentStatesInstrument = (csNone, csRemeberCoord, csPencil, csFill, csCircle, csKvadrat, csArc, csline, cslastic, csSelect, csSelectMoveOrRotate);
  // Машина состоянии


  TDrawStateMachine = class
  private
    FirstCall: Boolean; // Если первый вызов функции то флаг сбрасываем в false;
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
