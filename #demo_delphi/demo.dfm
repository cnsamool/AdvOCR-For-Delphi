object Form1: TForm1
  Left = 405
  Top = 278
  Width = 274
  Height = 266
  Caption = 'DEMO'
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
    Top = 80
    Width = 241
    Height = 105
    Center = True
  end
  object btn: TButton
    Left = 80
    Top = 8
    Width = 105
    Height = 25
    Caption = #35782#21035#22806#37096#22270#29255
    TabOrder = 0
    OnClick = btnClick
  end
  object edtResult: TEdit
    Left = 88
    Top = 200
    Width = 89
    Height = 21
    TabOrder = 1
  end
  object CbbType: TComboBox
    Left = 80
    Top = 40
    Width = 105
    Height = 21
    ItemHeight = 13
    TabOrder = 2
  end
end
