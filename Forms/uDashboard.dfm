object frmDashboard: TfrmDashboard
  Left = 0
  Top = 0
  BiDiMode = bdRightToLeft
  ClientHeight = 500
  ClientWidth = 900
  Color = 13160660
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  ParentBiDiMode = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 500
    Align = alClient
    BevelOuter = bvNone
    Color = 13160660
    TabOrder = 0
    object pnlCards: TPanel
      Left = 0
      Top = 0
      Width = 900
      Height = 90
      Align = alTop
      BevelOuter = bvNone
      Color = 13160660
      TabOrder = 0
    end
    object pnlBottom: TPanel
      Left = 0
      Top = 440
      Width = 900
      Height = 60
      Align = alBottom
      BevelOuter = bvNone
      Color = 13160660
      TabOrder = 1
      object pnlUrgStats: TPanel
        Left = 450
        Top = 0
        Width = 450
        Height = 60
        Align = alRight
        BevelOuter = bvNone
        Color = clWhite
        TabOrder = 0
        object pnlUrgHdr: TLabel
          Left = 274
          Top = 0
          Width = 176
          Height = 13
          Align = alTop
          Caption = '  '#1578#1608#1586#1610#1593' '#1575#1604#1576#1585#1602#1610#1575#1578' '#1581#1587#1576' '#1575#1604#1575#1587#1578#1593#1580#1575#1604#1610#1577
          Color = 6567967
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
        end
      end
      object pnlStatStats: TPanel
        Left = 0
        Top = 0
        Width = 450
        Height = 60
        Align = alClient
        BevelOuter = bvNone
        Color = clWhite
        TabOrder = 1
        object pnlStatHdr: TLabel
          Left = 333
          Top = 0
          Width = 117
          Height = 13
          Align = alTop
          Caption = '  '#1575#1604#1576#1585#1602#1610#1575#1578' '#1581#1587#1576' '#1575#1604#1581#1575#1604#1577
          Color = 6567967
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
        end
      end
    end
    object pnlRecent: TPanel
      Left = 0
      Top = 90
      Width = 900
      Height = 350
      Align = alClient
      BevelOuter = bvNone
      Color = clWhite
      TabOrder = 2
      object pnlRecentHdr: TPanel
        Left = 0
        Top = 0
        Width = 900
        Height = 24
        Align = alTop
        BevelOuter = bvNone
        Color = 6567967
        TabOrder = 0
        object lblRecentHdr: TLabel
          Left = 0
          Top = 0
          Width = 107
          Height = 13
          Align = alClient
          Alignment = taRightJustify
          Caption = '  '#1570#1582#1585' '#1575#1604#1576#1585#1602#1610#1575#1578' '#1575#1604#1608#1575#1585#1583#1577
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          Layout = tlCenter
        end
      end
      object sgRecent: TStringGrid
        Left = 0
        Top = 24
        Width = 900
        Height = 326
        Align = alClient
        ColCount = 6
        FixedCols = 0
        RowCount = 8
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSizing, goColSizing, goRowSelect]
        TabOrder = 1
      end
    end
  end
end
