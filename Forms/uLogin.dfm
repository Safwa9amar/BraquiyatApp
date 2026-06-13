object frmLogin: TfrmLogin
  Left = 0
  Top = 0
  BiDiMode = bdRightToLeft
  BorderStyle = bsNone
  ClientHeight = 540
  ClientWidth = 420
  Color = 3870080
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  ParentBiDiMode = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlStatusBar: TPanel
    Left = 0
    Top = 514
    Width = 420
    Height = 26
    Align = alBottom
    BevelOuter = bvNone
    Color = 4019840
    TabOrder = 0
    DesignSize = (
      420
      26)
    object lblVersion: TLabel
      Left = 280
      Top = 6
      Width = 130
      Height = 14
      Anchors = [akLeft, akBottom]
      Alignment = taCenter
      Caption = 'Version 2.1.4'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 11591423
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblLoginDate: TLabel
      Left = 10
      Top = 6
      Width = 95
      Height = 14
      Anchors = [akLeft, akBottom]
      Alignment = taCenter
      Caption = '2026/06/13'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 11591423
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlTitleBar: TPanel
    Left = 0
    Top = 0
    Width = 420
    Height = 32
    Align = alTop
    BevelOuter = bvNone
    Color = 4019840
    TabOrder = 1
    object lblTitleText: TLabel
      Left = 160
      Top = 7
      Width = 240
      Height = 18
      Alignment = taCenter
      Caption = 'Telegram Management System'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object pnlWinBtns: TPanel
      Left = 0
      Top = 0
      Width = 70
      Height = 32
      Align = alLeft
      BevelOuter = bvNone
      Color = 4019840
      TabOrder = 0
      object lblBtnMin: TLabel
        Left = 8
        Top = 8
        Width = 14
        Height = 16
        Alignment = taCenter
        Caption = #9472
        Cursor = crHandPoint
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblBtnMax: TLabel
        Left = 28
        Top = 8
        Width = 14
        Height = 16
        Alignment = taCenter
        Caption = #9633
        Cursor = crHandPoint
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblBtnClose: TLabel
        Left = 48
        Top = 8
        Width = 14
        Height = 16
        Cursor = crHandPoint
        Alignment = taCenter
        Caption = #10005
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        OnClick = lblBtnCloseClick
      end
    end
  end
  object pnlLoginBody: TPanel
    Left = 0
    Top = 32
    Width = 420
    Height = 482
    Align = alClient
    BevelOuter = bvNone
    Color = 3870080
    TabOrder = 2
    DesignSize = (
      420
      482)
    object lblAppTitle: TLabel
      Left = 0
      Top = 40
      Width = 420
      Height = 32
      Alignment = taCenter
      Caption = 'Telegram Management'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -24
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblAppSub: TLabel
      Left = 0
      Top = 75
      Width = 420
      Height = 16
      Alignment = taCenter
      Caption = 'Boualam - Benshary Department'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 11591423
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblUser: TLabel
      Left = 330
      Top = 160
      Width = 70
      Height = 13
      Alignment = taRightJustify
      Caption = 'Username:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 2236449
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblPass: TLabel
      Left = 360
      Top = 215
      Width = 40
      Height = 13
      Alignment = taRightJustify
      Caption = 'Password:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 2236449
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblError: TLabel
      Left = 20
      Top = 270
      Width = 380
      Height = 16
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 1710399
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblHint: TLabel
      Left = 20
      Top = 290
      Width = 380
      Height = 13
      Alignment = taCenter
      Caption = ''
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 7833591
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsItalic]
      ParentFont = False
    end
    object pnlLogo: TPanel
      Left = 180
      Top = 10
      Width = 60
      Height = 60
      BevelOuter = bvNone
      Color = 3870080
      TabOrder = 0
      object lblLogoIcon: TLabel
        Left = 0
        Top = 0
        Width = 60
        Height = 60
        Alignment = taCenter
        Caption = #62667
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -40
        Font.Name = 'Segoe UI Emoji'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
      end
    end
    object pnlInputCard: TPanel
      Left = 20
      Top = 110
      Width = 380
      Height = 250
      Anchors = [akLeft, akTop, akRight]
      BevelOuter = bvNone
      Color = 16777215
      TabOrder = 1
      object pnlSep: TPanel
        Left = 0
        Top = 75
        Width = 380
        Height = 2
        Align = alTop
        BevelOuter = bvNone
        Color = 51
        TabOrder = 5
      end
      object edtUser: TEdit
        Left = 20
        Top = 30
        Width = 340
        Height = 35
        BorderStyle = bsNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 2236449
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        Text = ''
      end
      object edtPass: TEdit
        Left = 20
        Top = 115
        Width = 340
        Height = 35
        BorderStyle = bsNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 2236449
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        PasswordChar = #8226
        TabOrder = 2
        Text = ''
      end
      object lblUserIcon: TLabel
        Left = 10
        Top = 30
        Width = 15
        Height = 35
        Alignment = taCenter
        Caption = #128100
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5520207
        Font.Height = -16
        Font.Name = 'Segoe UI Emoji'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
      end
      object lblPassIcon: TLabel
        Left = 10
        Top = 115
        Width = 15
        Height = 35
        Alignment = taCenter
        Caption = #128274
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5520207
        Font.Height = -16
        Font.Name = 'Segoe UI Emoji'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
      end
      object btnLogin: TButton
        Left = 190
        Top = 180
        Width = 170
        Height = 40
        Caption = 'Login'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 3
        OnClick = btnLoginClick
      end
      object btnCancel: TButton
        Left = 20
        Top = 180
        Width = 160
        Height = 40
        Caption = 'Cancel'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 2236449
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 4
        OnClick = btnCancelClick
      end
    end
  end
end
