object ProgressForm: TProgressForm
  Left = 363
  Top = 513
  BorderStyle = bsToolWindow
  Caption = 'AviThread Progress'
  ClientHeight = 122
  ClientWidth = 668
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    668
    122)
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 8
    Top = 0
    Width = 60
    Height = 18
    Caption = 'Avi File: '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -15
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 416
    Top = 0
    Width = 241
    Height = 17
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Label2'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object Image1: TImage
    Left = 8
    Top = 48
    Width = 60
    Height = 40
    Stretch = True
  end
  object Image2: TImage
    Left = 91
    Top = 48
    Width = 60
    Height = 40
    Stretch = True
  end
  object Image3: TImage
    Left = 174
    Top = 48
    Width = 60
    Height = 40
    Stretch = True
  end
  object Image4: TImage
    Left = 258
    Top = 48
    Width = 60
    Height = 40
    Stretch = True
  end
  object Image5: TImage
    Left = 341
    Top = 48
    Width = 60
    Height = 40
    Stretch = True
  end
  object Image6: TImage
    Left = 425
    Top = 48
    Width = 60
    Height = 40
    Stretch = True
  end
  object Image7: TImage
    Left = 508
    Top = 48
    Width = 60
    Height = 40
    Stretch = True
  end
  object Image8: TImage
    Left = 592
    Top = 48
    Width = 60
    Height = 40
    Stretch = True
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 24
    Width = 657
    Height = 14
    Anchors = [akLeft, akTop, akRight]
    Min = 0
    Max = 100
    TabOrder = 0
  end
  object Button1: TButton
    Left = 264
    Top = 96
    Width = 145
    Height = 24
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = Button1Click
  end
end
