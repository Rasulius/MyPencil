object MainForm: TMainForm
  Left = 250
  Top = 153
  Width = 513
  Height = 392
  Caption = 'MainForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Label3: TLabel
    Left = 24
    Top = 56
    Width = 38
    Height = 16
    Caption = 'Label3'
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 505
    Height = 359
    ActivePage = TabSheet1
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabIndex = 0
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = '1: Images'
      DesignSize = (
        497
        328)
      object ListBox1: TListBox
        Left = 24
        Top = 40
        Width = 449
        Height = 227
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 16
        MultiSelect = True
        PopupMenu = PopupMenu1
        TabOrder = 0
      end
      object Button1: TButton
        Left = 16
        Top = 282
        Width = 198
        Height = 25
        Anchors = [akLeft, akRight, akBottom]
        Caption = 'Add Image File(s)'
        TabOrder = 1
        OnClick = Button1Click
      end
      object Button4: TButton
        Left = 280
        Top = 282
        Width = 206
        Height = 25
        Anchors = [akLeft, akRight, akBottom]
        Caption = 'Clear List'
        TabOrder = 2
        OnClick = Button4Click
      end
    end
    object TabSheet2: TTabSheet
      Caption = '2: Wave File'
      ImageIndex = 1
      DesignSize = (
        497
        328)
      object Label1: TLabel
        Left = 16
        Top = 40
        Width = 65
        Height = 16
        Caption = 'Wave File: '
      end
      object Label2: TLabel
        Left = 120
        Top = 96
        Width = 32
        Height = 16
        Caption = '0 sec'
      end
      object Label9: TLabel
        Left = 8
        Top = 64
        Width = 481
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'None'
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentColor = False
        ParentFont = False
      end
      object MediaPlayer1: TMediaPlayer
        Left = 16
        Top = 96
        Width = 85
        Height = 25
        ColoredButtons = []
        EnabledButtons = [btPlay, btPause, btStop, btBack]
        VisibleButtons = [btPlay, btPause, btStop]
        TabOrder = 0
      end
      object Button2: TButton
        Left = 429
        Top = 32
        Width = 57
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Browse'
        TabOrder = 1
        OnClick = Button2Click
      end
      object Button8: TButton
        Left = 429
        Top = 96
        Width = 57
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Clear'
        TabOrder = 2
        OnClick = Button8Click
      end
    end
    object TabSheet3: TTabSheet
      Caption = '3: Avi-Settings'
      ImageIndex = 2
      object Label4: TLabel
        Left = 16
        Top = 16
        Width = 75
        Height = 16
        Caption = 'Frame Width'
      end
      object Label5: TLabel
        Left = 112
        Top = 16
        Width = 78
        Height = 16
        Caption = 'Frame Height'
      end
      object Label6: TLabel
        Left = 328
        Top = 16
        Width = 74
        Height = 16
        Caption = 'Pixel Format'
      end
      object Label7: TLabel
        Left = 216
        Top = 16
        Width = 99
        Height = 16
        Caption = 'Frame Time [ms]'
      end
      object Label8: TLabel
        Left = 16
        Top = 80
        Width = 76
        Height = 16
        Caption = 'Compression'
      end
      object Label12: TLabel
        Left = 280
        Top = 80
        Width = 83
        Height = 16
        Caption = 'Comp. Quality'
      end
      object Label13: TLabel
        Left = 24
        Top = 200
        Width = 361
        Height = 73
        AutoSize = False
        Caption = 
          'Note: Some Codecs, like MS-RLE do not support compression on-the' +
          '-fly. Others, like DivX, give an exception if the frames are too' +
          ' different (?), others, like Indeo5 want the frame sizes to be a' +
          ' factor of 4. '
        WordWrap = True
      end
      object SpinEdit1: TSpinEdit
        Left = 16
        Top = 40
        Width = 89
        Height = 26
        MaxValue = 0
        MinValue = 0
        TabOrder = 0
        Value = 400
      end
      object SpinEdit2: TSpinEdit
        Left = 112
        Top = 40
        Width = 89
        Height = 26
        MaxValue = 0
        MinValue = 0
        TabOrder = 1
        Value = 300
      end
      object ComboBox1: TComboBox
        Left = 328
        Top = 40
        Width = 81
        Height = 24
        Style = csDropDownList
        ItemHeight = 16
        ItemIndex = 3
        TabOrder = 2
        Text = '24 Bit'
        OnChange = ComboBox1Change
        Items.Strings = (
          '  1 Bit '
          '  4 Bit  '
          '  8 Bit'
          '24 Bit'
          '32 Bit')
      end
      object SpinEdit3: TSpinEdit
        Left = 216
        Top = 40
        Width = 89
        Height = 26
        MaxValue = 0
        MinValue = 0
        TabOrder = 3
        Value = 1000
      end
      object ComboBox2: TComboBox
        Left = 16
        Top = 104
        Width = 249
        Height = 24
        Style = csDropDownList
        ItemHeight = 16
        TabOrder = 4
        OnChange = ComboBox2Change
      end
      object Button3: TButton
        Left = 48
        Top = 128
        Width = 217
        Height = 25
        Caption = 'Compress Options (if available)'
        TabOrder = 5
        OnClick = Button3Click
      end
      object CheckBox1: TCheckBox
        Left = 264
        Top = 168
        Width = 121
        Height = 17
        Caption = 'Stretch Images'
        Checked = True
        State = cbChecked
        TabOrder = 6
      end
      object ComboBox3: TComboBox
        Left = 280
        Top = 104
        Width = 129
        Height = 24
        Style = csDropDownList
        ItemHeight = 16
        ItemIndex = 2
        TabOrder = 7
        Text = 'High'
        OnChange = ComboBox3Change
        Items.Strings = (
          'Highest'
          'Very High'
          'High'
          'Medium'
          'Low')
      end
      object CheckBox2: TCheckBox
        Left = 24
        Top = 168
        Width = 217
        Height = 17
        Caption = 'On-the-fly compression'
        Checked = True
        State = cbChecked
        TabOrder = 8
      end
    end
    object TabSheet4: TTabSheet
      Caption = '4: Write'
      ImageIndex = 3
      DesignSize = (
        497
        328)
      object Label10: TLabel
        Left = 16
        Top = 80
        Width = 41
        Height = 16
        Caption = 'No File'
      end
      object Label11: TLabel
        Left = 325
        Top = 80
        Width = 157
        Height = 16
        Alignment = taRightJustify
        Anchors = [akTop, akRight]
        AutoSize = False
        Caption = '.. Doing Nothing'
      end
      object Button5: TButton
        Left = 8
        Top = 40
        Width = 214
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Avi Filename'
        TabOrder = 0
        OnClick = Button5Click
      end
      object Button6: TButton
        Left = 280
        Top = 40
        Width = 214
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Write'
        TabOrder = 1
        OnClick = Button6Click
      end
      object ProgressBar1: TProgressBar
        Left = 16
        Top = 104
        Width = 470
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Min = 0
        Max = 100
        TabOrder = 2
      end
    end
    object TabSheet5: TTabSheet
      Caption = '5: Watch'
      ImageIndex = 4
      DesignSize = (
        497
        328)
      object Animate1: TAnimate
        Left = 8
        Top = 8
        Width = 281
        Height = 185
        Active = False
      end
      object Button7: TButton
        Left = 22
        Top = 299
        Width = 214
        Height = 25
        Anchors = [akLeft, akRight, akBottom]
        Caption = 'Mediaplayer'
        TabOrder = 1
        OnClick = Button7Click
      end
      object Button9: TButton
        Left = 280
        Top = 299
        Width = 206
        Height = 25
        Anchors = [akLeft, akRight, akBottom]
        Caption = 'Animate'
        TabOrder = 2
        OnClick = Button9Click
      end
    end
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofFileMustExist, ofEnableSizing]
    Left = 40
    Top = 32
  end
  object PopupMenu1: TPopupMenu
    Left = 8
    Top = 32
    object DeleteSelectedfromList1: TMenuItem
      Caption = 'Delete Selected from List'
      OnClick = DeleteSelectedfromList1Click
    end
  end
  object AviWriter: TAviWriter_2
    Height = 150
    Width = 200
    FrameTime = 100
    Stretch = True
    PixelFormat = pf24bit
    OnProgress = AviWriterProgress
    Left = 72
    Top = 32
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Wave Files|*.wav'
    Left = 104
    Top = 32
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'avi'
    Filter = 'Avi-Files|*.avi'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 136
    Top = 32
  end
end
