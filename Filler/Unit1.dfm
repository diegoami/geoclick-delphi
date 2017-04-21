object Form1: TForm1
  Left = 546
  Top = 288
  Width = 696
  Height = 549
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object TreeView1: TTreeView
    Left = 0
    Top = 0
    Width = 233
    Height = 481
    Indent = 19
    TabOrder = 0
  end
  object Button1: TButton
    Left = 336
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 288
    Top = 72
    Width = 401
    Height = 385
    TabOrder = 2
  end
  object HTMLTreeViewPArser1: THTMLTreeViewPArser
    TReeView = TreeView1
    Left = 256
    Top = 160
  end
  object OpenDialog1: TOpenDialog
    Left = 184
    Top = 136
  end
end
