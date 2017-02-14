inherited AviDialog: TAviDialog
  Left = 244
  Top = 166
  Caption = 'AVI-File Settings'
  ClientHeight = 365
  ClientWidth = 454
  OldCreateOrder = True
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object Label11: TLabel [0]
    Left = 2
    Top = 2
    Width = 447
    Height = 55
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'The video compression box lists suitable compression codecs whic' +
      'h are installed on your system. Using video compression reduces ' +
      'the .avi-filesize substantially.'
    Color = clInfoBk
    Font.Charset = ANSI_CHARSET
    Font.Color = clInfoText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    WordWrap = True
  end
  object Label14: TLabel [1]
    Left = 8
    Top = 128
    Width = 137
    Height = 33
    AutoSize = False
    Caption = 'Video compression codec: '
    WordWrap = True
  end
  object Label16: TLabel [2]
    Left = 352
    Top = 128
    Width = 89
    Height = 33
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Compression Quality: '
    WordWrap = True
  end
  object Label1: TLabel [3]
    Left = 8
    Top = 64
    Width = 127
    Height = 16
    Caption = 'Frame Width x Height'
  end
  object Label2: TLabel [4]
    Left = 328
    Top = 64
    Width = 116
    Height = 16
    Alignment = taRightJustify
    Caption = 'Frames per second:'
  end
  inherited BitBtn1: TBitBtn
    Left = 181
    Top = 342
  end
  inherited BitBtn2: TBitBtn
    Left = 253
    Top = 342
  end
  object ComboBox1: TComboBox
    Left = 8
    Top = 168
    Width = 305
    Height = 24
    ItemHeight = 16
    TabOrder = 2
    OnChange = ComboBox1Change
  end
  object ComboBox2: TComboBox
    Left = 320
    Top = 168
    Width = 129
    Height = 24
    ItemHeight = 16
    TabOrder = 3
    Text = 'High'
    Items.Strings = (
      'Highest'
      'Very High'
      'High'
      'Medium'
      'Low')
  end
  object GroupBox1: TGroupBox
    Left = 38
    Top = 264
    Width = 349
    Height = 65
    Caption = 'Output:'
    TabOrder = 4
    object Label5: TLabel
      Left = 8
      Top = 26
      Width = 127
      Height = 16
      Caption = 'AVI-filesize (MB, est.)'
    end
    object Label9: TLabel
      Left = 160
      Top = 26
      Width = 177
      Height = 16
      AutoSize = False
      Caption = 'Label9'
      Color = clInfoBk
      Font.Charset = ANSI_CHARSET
      Font.Color = clInfoText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
  end
  object Button1: TButton
    Left = 56
    Top = 192
    Width = 257
    Height = 25
    Caption = 'Advanced Codec Settings (if supported)'
    TabOrder = 5
    OnClick = Button1Click
  end
  object ComboBox3: TComboBox
    Left = 8
    Top = 88
    Width = 305
    Height = 24
    Style = csDropDownList
    ItemHeight = 16
    ItemIndex = 0
    TabOrder = 6
    Text = '352 x 240 (VCD NTSC format)'
    OnChange = RadioGroup1Click
    Items.Strings = (
      '352 x 240 (VCD NTSC format)'
      '352 x 288 (VCD PAL format)'
      '480 x 480 (SVCD NTSC format)'
      '480 x 576 (SVCD PAL format)'
      '240 x 180'
      '400 x 300'
      '592 x 444')
  end
  object ComboBox4: TComboBox
    Left = 320
    Top = 88
    Width = 129
    Height = 24
    Style = csDropDownList
    ItemHeight = 16
    ItemIndex = 1
    TabOrder = 7
    Text = '16'
    OnChange = ComboBox4Change
    Items.Strings = (
      '15'
      '16'
      '18'
      '20'
      '22'
      '23.976'
      '24'
      '25'
      '26'
      '28'
      '29.97'
      '30')
  end
  object AviWriter: TAviWriter_2
    Height = 96
    Width = 128
    FrameTime = 1000
    Stretch = True
    PixelFormat = pf24bit
    Left = 248
    Top = 136
  end
end
