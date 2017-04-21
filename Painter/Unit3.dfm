object Form3: TForm3
  Left = 53
  Top = 135
  Width = 1032
  Height = 748
  BorderStyle = bsSizeToolWin
  Caption = 'Form3'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 1024
    Height = 33
    ButtonHeight = 21
    Caption = 'ToolBar1'
    TabOrder = 0
    object SpeedButton1: TSpeedButton
      Left = 0
      Top = 2
      Width = 23
      Height = 21
      OnClick = SpeedButton1Click
    end
    object Edit1: TEdit
      Left = 23
      Top = 2
      Width = 121
      Height = 21
      TabOrder = 0
      OnChange = Edit1Change
    end
    object SpeedButton2: TSpeedButton
      Left = 144
      Top = 2
      Width = 23
      Height = 21
      OnClick = SpeedButton2Click
    end
  end
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 40
    Width = 1024
    Height = 681
    Align = alBottom
    TabOrder = 1
    object PaintBox1: TPaintBox
      Left = 0
      Top = 0
      Width = 1017
      Height = 521
      OnMouseDown = ImageFrame1ImageMouseDown
      OnMouseMove = ImageFrame1ImageMouseMove
      OnPaint = PaintBox1Paint
    end
  end
  object ColorDialog1: TColorDialog
    Ctl3D = True
    Left = 880
    Top = 232
  end
  object OpenDialog1: TOpenDialog
    Left = 712
    Top = 168
  end
end
