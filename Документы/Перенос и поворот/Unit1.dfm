object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 524
  ClientWidth = 660
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 8
    Top = 8
    Width = 505
    Height = 385
    OnMouseMove = Image1MouseMove
    OnMouseUp = Image1MouseUp
  end
  object Button1: TButton
    Left = 519
    Top = 8
    Width = 58
    Height = 41
    Caption = 'Select'
    TabOrder = 0
    OnClick = Button1Click
  end
end
