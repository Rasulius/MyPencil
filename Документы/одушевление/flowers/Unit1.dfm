object Form1: TForm1
  Left = 42
  Top = 157
  Width = 465
  Height = 600
  HorzScrollBar.Color = 12639992
  HorzScrollBar.ParentColor = False
  Caption = 'plants'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 8
    Top = 8
    Width = 441
    Height = 526
    Anchors = [akLeft, akTop, akRight, akBottom]
  end
  object Button1: TButton
    Left = 373
    Top = 538
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Еще'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 8
    Top = 538
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Сама'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Timer1: TTimer
    Interval = 600
    OnTimer = Timer1Timer
    Left = 376
    Top = 8
  end
end
