object BadBitmapForm: TBadBitmapForm
  Left = 370
  Top = 143
  Width = 442
  Height = 447
  Caption = 'This bitmap'#39's bits couldnt be read'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  DesignSize = (
    434
    414)
  PixelsPerInch = 120
  TextHeight = 16
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 433
    Height = 345
    Anchors = [akLeft, akTop, akRight]
    Center = True
  end
  object Label1: TLabel
    Left = 8
    Top = 349
    Width = 38
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 104
    Top = 349
    Width = 38
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'Label2'
  end
  object Button1: TButton
    Left = 80
    Top = 389
    Width = 274
    Height = 25
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
  end
end
