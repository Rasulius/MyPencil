object MainForm: TMainForm
  Left = 258
  Top = 163
  Width = 877
  Height = 633
  Caption = 'AviWriter Thread Demo'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 120
  TextHeight = 16
  object Splitter1: TSplitter
    Left = 225
    Top = 33
    Width = 8
    Height = 389
    Cursor = crHSplit
  end
  object Label1: TLabel
    Left = 0
    Top = 0
    Width = 869
    Height = 33
    Align = alTop
    Alignment = taCenter
    AutoSize = False
    Caption = 
      'Drop thumbs into the eight movie frames at the bottom. Then choo' +
      'se  (not too long)  .wav files via '#39'Music | Add Wave File'#39', then' +
      ' click '#39'Movie | Write Avi'#39'. The movie contains the  images alpha' +
      '-blended together and the wave files played  in sequence.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object Label2: TLabel
    Left = 0
    Top = 422
    Width = 869
    Height = 16
    Align = alBottom
    AutoSize = False
    Caption = 'Music File: None'
    Color = clWhite
    ParentColor = False
  end
  object ScrollBox1: TScrollBox
    Left = 233
    Top = 33
    Width = 636
    Height = 389
    HorzScrollBar.Smooth = True
    HorzScrollBar.Tracking = True
    VertScrollBar.Smooth = True
    VertScrollBar.Tracking = True
    Align = alClient
    Color = clWhite
    ParentColor = False
    TabOrder = 0
    object MediaPlayer1: TMediaPlayer
      Left = 8
      Top = 48
      Width = 253
      Height = 30
      Visible = False
      TabOrder = 0
    end
  end
  object ScrollBox2: TScrollBox
    Left = 0
    Top = 438
    Width = 869
    Height = 136
    Align = alBottom
    Color = clWhite
    ParentColor = False
    TabOrder = 1
    object Image1: TImage
      Left = 0
      Top = 1
      Width = 137
      Height = 97
      OnDragDrop = Image1DragDrop
      OnDragOver = Image1DragOver
    end
    object Image2: TImage
      Left = 144
      Top = 1
      Width = 137
      Height = 97
      OnDragDrop = Image1DragDrop
      OnDragOver = Image1DragOver
    end
    object Image3: TImage
      Left = 288
      Top = 1
      Width = 137
      Height = 97
      OnDragDrop = Image1DragDrop
      OnDragOver = Image1DragOver
    end
    object Image4: TImage
      Left = 432
      Top = 1
      Width = 137
      Height = 97
      OnDragDrop = Image1DragDrop
      OnDragOver = Image1DragOver
    end
    object Image5: TImage
      Left = 576
      Top = 1
      Width = 137
      Height = 97
      OnDragDrop = Image1DragDrop
      OnDragOver = Image1DragOver
    end
    object Image6: TImage
      Left = 720
      Top = 1
      Width = 137
      Height = 97
      OnDragDrop = Image1DragDrop
      OnDragOver = Image1DragOver
    end
    object Image7: TImage
      Left = 864
      Top = 1
      Width = 137
      Height = 97
      OnDragDrop = Image1DragDrop
      OnDragOver = Image1DragOver
    end
    object Image8: TImage
      Left = 1008
      Top = 1
      Width = 137
      Height = 97
      OnDragDrop = Image1DragDrop
      OnDragOver = Image1DragOver
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 33
    Width = 225
    Height = 389
    Align = alLeft
    Caption = 'Panel1'
    TabOrder = 2
    DesignSize = (
      225
      389)
    object DriveComboBox1: TDriveComboBox
      Left = 0
      Top = 0
      Width = 225
      Height = 22
      Anchors = [akLeft, akTop, akRight]
      DirList = Foldertree
      TabOrder = 0
    end
    object Foldertree: TDirectoryListBox
      Left = 0
      Top = 24
      Width = 225
      Height = 365
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 16
      TabOrder = 1
      OnChange = FolderTreeChange
    end
  end
  object MainMenu1: TMainMenu
    Left = 24
    Top = 8
    object humbSize1: TMenuItem
      Caption = 'Thumb Size'
      object Medium1: TMenuItem
        Action = acMediumThumbs
      end
      object Large1: TMenuItem
        Action = acLargeThumbs
      end
      object Small1: TMenuItem
        Action = acSmallThumbs
      end
    end
    object Music1: TMenuItem
      Caption = 'Music'
      object LoadWaveFile1: TMenuItem
        Caption = 'Add Wave File'
        OnClick = LoadWaveFile1Click
      end
      object ClearMusiclist1: TMenuItem
        Caption = 'Clear Musiclist'
        OnClick = ClearMusiclist1Click
      end
    end
    object Movie1: TMenuItem
      Caption = 'Movie'
      object WriteAvi1: TMenuItem
        Caption = 'Write Avi'
        OnClick = WriteAvi1Click
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object SimpleHelptext1: TMenuItem
        Caption = 'Simple Help text'
        OnClick = SimpleHelptext1Click
      end
    end
  end
  object ActionList1: TActionList
    Left = 224
    Top = 40
    object acLargeThumbs: TAction
      Caption = 'Large'
      GroupIndex = 1
      OnExecute = acLargeThumbsExecute
    end
    object acMediumThumbs: TAction
      Caption = 'Medium'
      Checked = True
      GroupIndex = 1
      OnExecute = acMediumThumbsExecute
    end
    object acSmallThumbs: TAction
      Caption = 'Small'
      GroupIndex = 1
      OnExecute = acSmallThumbsExecute
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Wave Files|*.wav'
    Left = 112
    Top = 8
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'avi'
    Filter = 'Avi Files|*.avi'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 152
    Top = 8
  end
  object PopupMenu1: TPopupMenu
    Left = 248
    Top = 160
    object ShowImage1: TMenuItem
      Caption = 'Show Image'
      OnClick = ShowImage1Click
    end
  end
  object PopupMenu2: TPopupMenu
    Left = 248
    Top = 216
    object Exit1: TMenuItem
      Caption = 'Exit'
      OnClick = Exit1Click
    end
  end
end
