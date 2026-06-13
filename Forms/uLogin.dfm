object frmLogin: TfrmLogin
  Left = 0
  Top = 0
  BiDiMode = bdRightToLeft
  BorderStyle = bsNone
  ClientHeight = 600
  ClientWidth = 440
  Color = 6567967
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  ParentBiDiMode = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object pnlTitleBar: TPanel
    Left = 0
    Top = 0
    Width = 440
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    Color = 4666390
    ParentBackground = False
    TabOrder = 0
    OnMouseDown = TitleBarMouseDown
    object lblTitleText: TLabel
      Left = 0
      Top = 12
      Width = 440
      Height = 16
      Alignment = taCenter
      Caption = #1606#1592#1575#1605' '#1578#1587#1610#1610#1585' '#1575#1604#1576#1585#1602#1610#1575#1578
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      OnMouseDown = TitleBarMouseDown
    end
    object lblBtnClose: TLabel
      Left = 12
      Top = 10
      Width = 22
      Height = 20
      Cursor = crHandPoint
      Alignment = taCenter
      Caption = #10005
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -14
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      OnClick = lblBtnCloseClick
    end
  end
  object pnlStatusBar: TPanel
    Left = 0
    Top = 572
    Width = 440
    Height = 28
    Align = alBottom
    BevelOuter = bvNone
    Color = 4666390
    ParentBackground = False
    TabOrder = 1
    object lblVersion: TLabel
      Left = 14
      Top = 7
      Width = 120
      Height = 14
      Caption = 'v2.1.4'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13027014
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblLoginDate: TLabel
      Left = 306
      Top = 7
      Width = 120
      Height = 14
      Alignment = taRightJustify
      Caption = '2026/06/13'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13027014
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlBody: TPanel
    Left = 0
    Top = 40
    Width = 440
    Height = 532
    Align = alClient
    BevelOuter = bvNone
    Color = 6567967
    ParentBackground = False
    TabOrder = 2
    object pbxBg: TPaintBox
      Left = 0
      Top = 0
      Width = 440
      Height = 532
      Align = alClient
      OnPaint = pbxBgPaint
      ExplicitLeft = 120
      ExplicitTop = 80
    end
    object pnlCard: TPanel
      Left = 40
      Top = 35
      Width = 360
      Height = 462
      BevelOuter = bvNone
      Color = 16777215
      ParentBackground = False
      TabOrder = 0
      object lblAppTitle: TLabel
        Left = 20
        Top = 104
        Width = 320
        Height = 28
        Alignment = taCenter
        Caption = #1606#1592#1575#1605' '#1578#1587#1610#1610#1585' '#1575#1604#1576#1585#1602#1610#1575#1578
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 2500134
        Font.Height = -21
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblAppSub: TLabel
        Left = 20
        Top = 138
        Width = 320
        Height = 18
        Alignment = taCenter
        Caption = #1583#1575#1574#1585#1577' '#1576#1608#1593#1604#1575#1605' '#1576#1606' '#1588#1585#1610
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 8947848
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblUser: TLabel
        Left = 30
        Top = 188
        Width = 300
        Height = 16
        Alignment = taLeftJustify
        Caption = #1575#1587#1605' '#1575#1604#1605#1587#1578#1582#1583#1605
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6710886
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblPass: TLabel
        Left = 30
        Top = 258
        Width = 300
        Height = 16
        Alignment = taLeftJustify
        Caption = #1603#1604#1605#1577' '#1575#1604#1605#1585#1608#1585
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6710886
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblError: TLabel
        Left = 20
        Top = 324
        Width = 320
        Height = 16
        Alignment = taCenter
        Caption = ''
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 3618793
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblExit: TLabel
        Left = 20
        Top = 410
        Width = 320
        Height = 18
        Cursor = crHandPoint
        Alignment = taCenter
        Caption = #1573#1604#1594#1575#1569' / '#1582#1585#1608#1580
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 8947848
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        OnClick = lblExitClick
      end
      object pnlLogo: TPanel
        Left = 147
        Top = 26
        Width = 66
        Height = 66
        BevelOuter = bvNone
        Color = 6567967
        ParentBackground = False
        TabOrder = 0
        object lblLogoIcon: TLabel
          Left = 0
          Top = 0
          Width = 66
          Height = 66
          Align = alClient
          Alignment = taCenter
          Caption = #9993
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -30
          Font.Name = 'Segoe UI Symbol'
          Font.Style = []
          ParentFont = False
          Layout = tlCenter
          ExplicitWidth = 66
          ExplicitHeight = 66
        end
      end
      object pnlDivider: TPanel
        Left = 40
        Top = 168
        Width = 280
        Height = 1
        BevelOuter = bvNone
        Color = 15066597
        ParentBackground = False
        TabOrder = 1
      end
      object pnlUserField: TPanel
        Left = 30
        Top = 208
        Width = 300
        Height = 42
        BevelOuter = bvNone
        Color = 16119285
        ParentBackground = False
        TabOrder = 2
        object pnlUserLine: TPanel
          Left = 0
          Top = 40
          Width = 300
          Height = 2
          Align = alBottom
          BevelOuter = bvNone
          Color = 14342874
          ParentBackground = False
          TabOrder = 0
          ExplicitTop = 38
        end
        object edtUser: TEdit
          AlignWithMargins = True
          Left = 12
          Top = 6
          Width = 276
          Height = 28
          Margins.Left = 12
          Margins.Top = 6
          Margins.Right = 12
          Margins.Bottom = 8
          Align = alClient
          AutoSize = False
          BorderStyle = bsNone
          Color = 16119285
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 2500134
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnEnter = FieldEnter
          OnExit = FieldExit
        end
      end
      object pnlPassField: TPanel
        Left = 30
        Top = 278
        Width = 300
        Height = 42
        BevelOuter = bvNone
        Color = 16119285
        ParentBackground = False
        TabOrder = 3
        object pnlPassLine: TPanel
          Left = 0
          Top = 40
          Width = 300
          Height = 2
          Align = alBottom
          BevelOuter = bvNone
          Color = 14342874
          ParentBackground = False
          TabOrder = 0
          ExplicitTop = 38
        end
        object lblEye: TLabel
          Left = 266
          Top = 0
          Width = 34
          Height = 40
          Cursor = crHandPoint
          Align = alRight
          Alignment = taCenter
          Caption = #128065
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 11119017
          Font.Height = -15
          Font.Name = 'Segoe UI Emoji'
          Font.Style = []
          ParentFont = False
          Layout = tlCenter
          OnClick = lblEyeClick
          ExplicitLeft = 0
          ExplicitHeight = 40
        end
        object edtPass: TEdit
          AlignWithMargins = True
          Left = 46
          Top = 6
          Width = 242
          Height = 28
          Margins.Left = 12
          Margins.Top = 6
          Margins.Right = 12
          Margins.Bottom = 8
          Align = alClient
          AutoSize = False
          BorderStyle = bsNone
          Color = 16119285
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 2500134
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          PasswordChar = #8226
          TabOrder = 1
          OnEnter = FieldEnter
          OnExit = FieldExit
          OnKeyPress = edtPassKeyPress
        end
      end
      object pnlLogin: TPanel
        Left = 30
        Top = 350
        Width = 300
        Height = 46
        BevelOuter = bvNone
        Color = 6567967
        ParentBackground = False
        Cursor = crHandPoint
        TabOrder = 4
        OnClick = LoginClick
        OnMouseEnter = LoginMouseEnter
        OnMouseLeave = LoginMouseLeave
        object lblLoginText: TLabel
          Left = 0
          Top = 0
          Width = 300
          Height = 46
          Cursor = crHandPoint
          Align = alClient
          Alignment = taCenter
          Caption = #1578#1587#1580#1610#1604' '#1575#1604#1583#1582#1608#1604
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          Layout = tlCenter
          OnClick = LoginClick
          ExplicitWidth = 300
          ExplicitHeight = 46
        end
      end
    end
  end
end
