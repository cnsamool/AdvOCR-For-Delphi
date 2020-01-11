object Form1: TForm1
  Left = 357
  Top = 191
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #39564#35777#30721#35782#21035' -- flying99koo.com'
  ClientHeight = 257
  ClientWidth = 266
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Image: TImage
    Left = 16
    Top = 176
    Width = 233
    Height = 65
    Center = True
  end
  object Lbl: TLabel
    Left = 215
    Top = 48
    Width = 24
    Height = 13
    Alignment = taRightJustify
    Caption = #25551#36848
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Layout = tlCenter
  end
  object Label1: TLabel
    Left = 24
    Top = 20
    Width = 48
    Height = 13
    Caption = #35782#21035#31867#22411
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 24
    Top = 99
    Width = 48
    Height = 13
    Caption = #35782#21035#32467#26524
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Bevel1: TBevel
    Left = 24
    Top = 76
    Width = 217
    Height = 3
  end
  object btn: TButton
    Left = 80
    Top = 136
    Width = 105
    Height = 25
    Caption = #35782#21035#22806#37096#22270#29255
    TabOrder = 0
    OnClick = btnClick
  end
  object edtResult: TEdit
    Left = 144
    Top = 96
    Width = 97
    Height = 21
    TabOrder = 1
  end
  object CbbType: TComboBox
    Left = 144
    Top = 16
    Width = 97
    Height = 21
    ItemHeight = 13
    TabOrder = 2
    OnClick = CbbTypeClick
  end
end
