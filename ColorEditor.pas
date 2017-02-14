unit ColorEditor;

interface

uses Graphics, ExtCtrls;

// Функция загружает нашу политру цветов
procedure LoadColors(aColorListBox: TColorListBox);


implementation


procedure LoadColors(aColorListBox: TColorListBox);
var
  aColor: TColor;
begin
  aColorListBox.Items.Clear;
  aColor := clRed;
  aColorListBox.Items.AddObject('Красный',TObject(aColor));
  aColor := clGreen;
  aColorListBox.Items.AddObject('Зеленый',TObject(aColor));
  aColor := clBlue;
  aColorListBox.Items.AddObject('Синий',TObject(aColor));
  aColor := clYellow;
  aColorListBox.Items.AddObject('Желтый',TObject(aColor));
end;


end.
