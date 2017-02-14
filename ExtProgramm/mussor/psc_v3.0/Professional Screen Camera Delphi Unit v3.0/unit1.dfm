object frmMain: TfrmMain
  Left = 193
  Top = 109
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Professional Screen Camera Demo'
  ClientHeight = 503
  ClientWidth = 529
  Color = clBtnFace
  TransparentColorValue = clLime
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 358
    Width = 206
    Height = 107
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 18
    Top = 367
    Width = 58
    Height = 13
    Caption = 'Information :'
    Transparent = True
  end
  object Label2: TLabel
    Left = 421
    Top = 12
    Width = 25
    Height = 13
    Caption = 'Top :'
    Transparent = True
  end
  object Label3: TLabel
    Left = 421
    Top = 36
    Width = 24
    Height = 13
    Caption = 'Left :'
    Transparent = True
  end
  object Label4: TLabel
    Left = 421
    Top = 60
    Width = 34
    Height = 13
    Caption = 'Width :'
    Transparent = True
  end
  object Label5: TLabel
    Left = 421
    Top = 84
    Width = 37
    Height = 13
    Caption = 'Height :'
    Transparent = True
  end
  object Label9: TLabel
    Left = 220
    Top = 149
    Width = 42
    Height = 13
    Caption = '--------------'
    Transparent = True
  end
  object Label10: TLabel
    Left = 178
    Top = 109
    Width = 67
    Height = 13
    Caption = 'Video Priority :'
  end
  object Label11: TLabel
    Left = 364
    Top = 109
    Width = 55
    Height = 13
    Caption = 'Filter Color :'
    Transparent = True
  end
  object Label12: TLabel
    Left = 13
    Top = 90
    Width = 66
    Height = 13
    Caption = 'Save To File :'
    Transparent = True
  end
  object Button1: TButton
    Left = 13
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Start Record'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 13
    Top = 34
    Width = 75
    Height = 25
    Caption = 'Stop'
    Enabled = False
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 89
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Options'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 89
    Top = 34
    Width = 75
    Height = 25
    Caption = 'About'
    TabOrder = 4
    OnClick = Button4Click
  end
  object CheckBox1: TCheckBox
    Left = 12
    Top = 154
    Width = 161
    Height = 17
    Caption = 'Record cursor in area capture'
    Checked = True
    State = cbChecked
    TabOrder = 7
    OnClick = CheckBox1Click
  end
  object CheckBox3: TCheckBox
    Left = 12
    Top = 176
    Width = 189
    Height = 17
    Caption = 'Draw rectangle around area capture'
    Checked = True
    State = cbChecked
    TabOrder = 8
    OnClick = CheckBox3Click
  end
  object Edit1: TEdit
    Left = 461
    Top = 8
    Width = 44
    Height = 21
    Enabled = False
    TabOrder = 17
    Text = '0'
    OnChange = Edit1Change
    OnKeyPress = Edit1KeyPress
  end
  object Edit2: TEdit
    Left = 461
    Top = 32
    Width = 44
    Height = 21
    Enabled = False
    TabOrder = 18
    Text = '0'
    OnChange = Edit1Change
    OnKeyPress = Edit1KeyPress
  end
  object Edit3: TEdit
    Left = 461
    Top = 56
    Width = 44
    Height = 21
    TabOrder = 19
    Text = '300'
    OnChange = Edit1Change
    OnKeyPress = Edit1KeyPress
  end
  object Edit4: TEdit
    Left = 461
    Top = 80
    Width = 44
    Height = 21
    TabOrder = 20
    Text = '300'
    OnChange = Edit1Change
    OnKeyPress = Edit1KeyPress
  end
  object CheckBox4: TCheckBox
    Left = 12
    Top = 198
    Width = 141
    Height = 17
    Caption = 'Draw cross rectangle line'
    Checked = True
    State = cbChecked
    TabOrder = 9
    OnClick = CheckBox4Click
  end
  object CheckBox5: TCheckBox
    Left = 12
    Top = 220
    Width = 189
    Height = 17
    Caption = 'Minimize application on start capture'
    Checked = True
    State = cbChecked
    TabOrder = 10
    OnClick = CheckBox5Click
  end
  object CheckBox6: TCheckBox
    Left = 12
    Top = 242
    Width = 173
    Height = 17
    Caption = 'Restore application after capture'
    Checked = True
    State = cbChecked
    TabOrder = 11
    OnClick = CheckBox6Click
  end
  object CheckBox8: TCheckBox
    Left = 12
    Top = 264
    Width = 76
    Height = 17
    Caption = 'Preview ON'
    TabOrder = 12
    OnClick = CheckBox8Click
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 294
    Width = 206
    Height = 60
    TabOrder = 14
    object Label6: TLabel
      Left = 34
      Top = 17
      Width = 23
      Height = 13
      Caption = 'Hour'
    end
    object Label7: TLabel
      Left = 85
      Top = 17
      Width = 17
      Height = 13
      Caption = 'Min'
    end
    object Label8: TLabel
      Left = 134
      Top = 17
      Width = 19
      Height = 13
      Caption = 'Sec'
    end
    object Edit5: TEdit
      Left = 32
      Top = 32
      Width = 25
      Height = 21
      Enabled = False
      ReadOnly = True
      TabOrder = 0
      Text = '0'
      OnChange = Edit5Change
    end
    object UpDown1: TUpDown
      Left = 57
      Top = 32
      Width = 16
      Height = 21
      Associate = Edit5
      Enabled = False
      Max = 99
      TabOrder = 1
    end
    object UpDown2: TUpDown
      Left = 107
      Top = 32
      Width = 16
      Height = 21
      Associate = Edit6
      Enabled = False
      Max = 59
      TabOrder = 3
    end
    object Edit6: TEdit
      Left = 82
      Top = 32
      Width = 25
      Height = 21
      Enabled = False
      ReadOnly = True
      TabOrder = 2
      Text = '0'
      OnChange = Edit5Change
    end
    object UpDown3: TUpDown
      Left = 157
      Top = 32
      Width = 16
      Height = 21
      Associate = Edit7
      Enabled = False
      Max = 59
      TabOrder = 5
    end
    object Edit7: TEdit
      Left = 132
      Top = 32
      Width = 25
      Height = 21
      Enabled = False
      ReadOnly = True
      TabOrder = 4
      Text = '0'
      OnChange = Edit5Change
    end
  end
  object CheckBox9: TCheckBox
    Left = 16
    Top = 287
    Width = 105
    Height = 17
    Caption = 'Timer Capture ON'
    TabOrder = 13
    OnClick = CheckBox9Click
  end
  object RadioGroup1: TRadioGroup
    Left = 176
    Top = 5
    Width = 233
    Height = 97
    Caption = 'Select Region Type'
    ItemIndex = 1
    Items.Strings = (
      'Select Region With Free Hand And Stable'
      'Fixed Region And Move By Mouse'
      'Fix Region And Stable'
      'Full Screen')
    TabOrder = 15
    OnClick = RadioGroup1Click
  end
  object Button5: TButton
    Left = 13
    Top = 60
    Width = 75
    Height = 25
    Caption = 'Exit'
    TabOrder = 2
    OnClick = Button5Click
  end
  object Panel1: TPanel
    Left = 220
    Top = 165
    Width = 300
    Height = 300
    BevelInner = bvLowered
    BevelOuter = bvNone
    Caption = 'Preview Part...'
    TabOrder = 22
    object Image1: TImage
      Left = 1
      Top = 1
      Width = 298
      Height = 298
      Align = alClient
      Stretch = True
    end
  end
  object ComboBox1: TComboBox
    Left = 248
    Top = 106
    Width = 89
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 3
    TabOrder = 16
    Text = 'Normal'
    OnChange = ComboBox1Change
    Items.Strings = (
      'Idle'
      'Lowest'
      'Lower'
      'Normal'
      'Higher'
      'Highest'
      'TimeCritical')
  end
  object ComboBox2: TComboBox
    Left = 422
    Top = 106
    Width = 97
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 21
    Text = 'Original Colors'
    OnChange = ComboBox2Change
    Items.Strings = (
      'Original Colors'
      'Reverse Colors')
  end
  object Edit8: TEdit
    Left = 12
    Top = 106
    Width = 141
    Height = 21
    TabOrder = 5
    Text = 'CaptureDemo.avi'
  end
  object CheckBox2: TCheckBox
    Left = 12
    Top = 132
    Width = 245
    Height = 17
    Caption = 'Recompress Video After Record (Less Size File)'
    TabOrder = 6
    OnClick = CheckBox2Click
  end
  object Panel2: TPanel
    Left = 0
    Top = 471
    Width = 529
    Height = 32
    Align = alBottom
    BevelInner = bvLowered
    TabOrder = 23
    object LStatus: TLabel
      Left = 3
      Top = 2
      Width = 47
      Height = 13
      Caption = 'No Status'
      Enabled = False
      Transparent = True
    end
    object Progress: TProgressBar
      Left = 82
      Top = 2
      Width = 445
      Height = 28
      Align = alRight
      Smooth = True
      TabOrder = 0
    end
    object BCancel: TButton
      Left = 2
      Top = 15
      Width = 79
      Height = 15
      Caption = 'Cancel'
      Enabled = False
      TabOrder = 1
      OnClick = BCancelClick
    end
  end
  object UpDownTop: TUpDown
    Left = 505
    Top = 8
    Width = 17
    Height = 21
    Associate = Edit1
    TabOrder = 24
    Thousands = False
  end
  object UpDownLeft: TUpDown
    Left = 505
    Top = 32
    Width = 17
    Height = 21
    Associate = Edit2
    TabOrder = 25
    Thousands = False
  end
  object UpDownWidth: TUpDown
    Left = 505
    Top = 56
    Width = 17
    Height = 21
    Associate = Edit3
    Max = 640
    Position = 300
    TabOrder = 26
    Thousands = False
  end
  object UpDownHeight: TUpDown
    Left = 505
    Top = 80
    Width = 17
    Height = 21
    Associate = Edit4
    Max = 480
    Position = 300
    TabOrder = 27
    Thousands = False
  end
  object XPManifest1: TXPManifest
    Left = 96
    Top = 64
  end
end
