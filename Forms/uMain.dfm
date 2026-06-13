object frmMain: TfrmMain
  Left = 0
  Top = 0
  BiDiMode = bdRightToLeft
  ClientHeight = 700
  ClientWidth = 1100
  Color = 13160660
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentBiDiMode = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  TextHeight = 13
  object pnlAppHeader: TPanel
    Left = 0
    Top = 24
    Width = 1100
    Height = 36
    Align = alTop
    BevelOuter = bvNone
    Color = 6567967
    TabOrder = 1
    ExplicitLeft = 8
    ExplicitTop = 120
    object lblAppTitle: TLabel
      Left = 416
      Top = 13
      Width = 290
      Height = 17
      Alignment = taRightJustify
      Caption = #62667' '#1606#1592#1575#1605' '#1578#1587#1610#1610#1585' '#1575#1604#1576#1585#1602#1610#1575#1578' '#1575#1604#1573#1583#1575#1585#1610#1577' '#8212' '#1583#1575#1574#1585#1577' '#1576#1608#1593#1604#1575#1605
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -14
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object pnlUserInfo: TPanel
      Left = 0
      Top = 0
      Width = 200
      Height = 36
      Align = alLeft
      BevelOuter = bvNone
      Color = 6567967
      TabOrder = 0
      object lblHeaderDate: TLabel
        Left = 158
        Top = -1
        Width = 48
        Height = 12
        Caption = '01/01/2026'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 14994616
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblHeaderUser: TLabel
        Left = 158
        Top = 17
        Width = 42
        Height = 13
        Caption = #1605#1587#1578#1582#1583#1605
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object btnLogout: TButton
        Left = 4
        Top = 6
        Width = 60
        Height = 24
        Caption = #1582#1585#1608#1580
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnClick = btnLogoutClick
      end
    end
  end
  object pnlStatusBar: TPanel
    Left = 0
    Top = 650
    Width = 1100
    Height = 22
    Align = alBottom
    BevelOuter = bvNone
    Color = 14215660
    TabOrder = 3
    object lblStatusUser: TLabel
      Left = 55
      Top = 4
      Width = 49
      Height = 11
      Caption = ' '#1605#1587#1578#1582#1583#1605': - '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblStatusDate: TLabel
      Left = 138
      Top = 4
      Width = 52
      Height = 11
      Caption = ' 01/01/2026 '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblStatusTime: TLabel
      Left = 214
      Top = 4
      Width = 42
      Height = 11
      Caption = ' 00:00:00 '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblStatusVer: TLabel
      Left = 800
      Top = 4
      Width = 158
      Height = 11
      Alignment = taRightJustify
      Caption = #1606#1592#1575#1605' '#1578#1587#1610#1610#1585' '#1575#1604#1576#1585#1602#1610#1575#1578' v2.1.4 | '#1583#1575#1574#1585#1577' '#1576#1608#1593#1604#1575#1605
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlBody: TPanel
    Left = 0
    Top = 60
    Width = 1100
    Height = 590
    Align = alClient
    BevelOuter = bvNone
    Color = 13160660
    TabOrder = 4
    object pnlSidebar: TPanel
      Left = 940
      Top = 0
      Width = 160
      Height = 590
      Align = alRight
      BevelOuter = bvNone
      Color = 6567967
      TabOrder = 0
      object pnlSideHeader: TPanel
        Left = 0
        Top = 0
        Width = 160
        Height = 28
        Align = alTop
        BevelOuter = bvNone
        Color = 5385494
        TabOrder = 0
        object lblSideTitle: TLabel
          Left = 0
          Top = 0
          Width = 62
          Height = 11
          Alignment = taCenter
          Caption = #1575#1604#1602#1575#1574#1605#1577' '#1575#1604#1585#1574#1610#1587#1610#1577
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 14994616
          Font.Height = -9
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          Layout = tlCenter
        end
      end
      object pnlSideStatus: TPanel
        Left = 0
        Top = 518
        Width = 160
        Height = 72
        Align = alBottom
        BevelOuter = bvNone
        Color = 6567967
        TabOrder = 1
        object lblDBStatus: TLabel
          Left = 74
          Top = 8
          Width = 80
          Height = 11
          Caption = #1602#1575#1593#1583#1577' '#1575#1604#1576#1610#1575#1606#1575#1578': '#1605#1578#1589#1604
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 14994616
          Font.Height = -9
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblNetStatus: TLabel
          Left = 101
          Top = 26
          Width = 53
          Height = 11
          Caption = #1575#1604#1588#1576#1603#1577': '#1606#1588#1591
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 14994616
          Font.Height = -9
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
      end
    end
    object pnlMainArea: TPanel
      Left = 0
      Top = 0
      Width = 940
      Height = 590
      Align = alClient
      BevelOuter = bvNone
      Color = 13160660
      TabOrder = 1
      object pnlBreadcrumb: TPanel
        Left = 0
        Top = 0
        Width = 940
        Height = 20
        Align = alTop
        BevelOuter = bvNone
        Color = 14215660
        TabOrder = 0
        object lblBreadcrumb: TLabel
          Left = 165
          Top = 3
          Width = 39
          Height = 11
          Caption = '  '#1575#1604#1585#1574#1610#1587#1610#1577
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5592405
          Font.Height = -9
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
      end
      object pnlContent: TPanel
        Left = 0
        Top = 20
        Width = 940
        Height = 570
        Align = alClient
        BevelOuter = bvNone
        Color = 15003120
        TabOrder = 1
      end
    end
  end
  object tmrClock: TTimer
    Enabled = False
    OnTimer = tmrClockTimer
    Left = 16
    Top = 592
  end
end
