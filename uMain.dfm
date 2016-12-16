object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Process Killer'
  ClientHeight = 477
  ClientWidth = 751
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 24
    Top = 24
    Width = 92
    Height = 13
    Caption = 'Lista de Processos:'
  end
  object btnCarregar: TButton
    Left = 479
    Top = 43
    Width = 242
    Height = 25
    Caption = 'Carregar Processos'
    TabOrder = 0
    OnClick = btnCarregarClick
  end
  object btnMatar: TButton
    Left = 479
    Top = 91
    Width = 242
    Height = 25
    Caption = 'Matar Processo'
    TabOrder = 1
    OnClick = btnMatarClick
  end
  object mmLogs: TMemo
    Left = 479
    Top = 144
    Width = 242
    Height = 297
    TabOrder = 2
  end
  object grdProcessos: TStringGrid
    Left = 24
    Top = 43
    Width = 417
    Height = 398
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    TabOrder = 3
  end
  object srchProcesso: TSearchBox
    Left = 248
    Top = 21
    Width = 193
    Height = 21
    TabOrder = 4
    OnInvokeSearch = srchProcessoInvokeSearch
  end
  object statProcess: TStatusBar
    Left = 0
    Top = 458
    Width = 751
    Height = 19
    Panels = <
      item
        Width = 300
      end>
    ExplicitLeft = 40
    ExplicitTop = 456
    ExplicitWidth = 0
  end
end
