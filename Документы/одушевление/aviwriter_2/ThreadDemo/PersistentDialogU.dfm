object PersistentDialog: TPersistentDialog
  Left = 364
  Top = 240
  BorderStyle = bsDialog
  BorderWidth = 1
  Caption = 'PersistentDialog'
  ClientHeight = 73
  ClientWidth = 230
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  DesignSize = (
    230
    73)
  PixelsPerInch = 120
  TextHeight = 16
  object BitBtn1: TBitBtn
    Left = 63
    Top = 50
    Width = 54
    Height = 22
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    Default = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 0
    NumGlyphs = 2
  end
  object BitBtn2: TBitBtn
    Left = 119
    Top = 50
    Width = 54
    Height = 22
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = 'Cancel'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ModalResult = 2
    ParentFont = False
    TabOrder = 1
    NumGlyphs = 2
  end
end
