object frmLogin: TfrmLogin
  Left = 0
  Top = 0
  BiDiMode = bdRightToLeft
  BorderStyle = bsNone
  ClientHeight = 316
  ClientWidth = 340
  Color = 13160660
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  ParentBiDiMode = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlStatusBar: TPanel
    Left = 0
    Top = 294
    Width = 340
    Height = 22
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object lblVersion: TLabel
      Left = 217
      Top = 4
      Width = 115
      Height = 11
      Caption = #216#167#217#8222#216#165#216#181#216#175#216#167#216#177' 2.1.4'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblLoginDate: TLabel
      Left = 22
      Top = 4
      Width = 46
      Height = 11
      Caption = '01/01/2026'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlTitleBar: TPanel
    Left = 0
    Top = 0
    Width = 340
    Height = 24
    Align = alTop
    BevelOuter = bvNone
    Color = 6567967
    TabOrder = 1
    object lblTitleText: TLabel
      Left = 158
      Top = 5
      Width = 175
      Height = 13
      Caption = #1606#1592#1575#1605' '#1578#1587#1610#1610#1585' '#1575#1604#1576#1585#1602#1610#1575#1578' - '#1583#1575#1574#1585#1577' '#1576#1608#1593#1604#1575#1605
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object pnlWinBtns: TPanel
      Left = 0
      Top = 0
      Width = 58
      Height = 24
      Align = alLeft
      BevelOuter = bvNone
      Color = 6567967
      TabOrder = 0
      object lblBtnMin: TLabel
        Left = 4
        Top = 5
        Width = 7
        Height = 12
        Alignment = taCenter
        Caption = #9472
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblBtnMax: TLabel
        Left = 22
        Top = 5
        Width = 6
        Height = 12
        Alignment = taCenter
        Caption = #9633
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblBtnClose: TLabel
        Left = 40
        Top = 5
        Width = 8
        Height = 12
        Cursor = crHandPoint
        Alignment = taCenter
        Caption = #10005
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = lblBtnCloseClick
      end
    end
  end
  object pnlLoginBody: TPanel
    Left = 0
    Top = 24
    Width = 340
    Height = 270
    Align = alClient
    BevelOuter = bvNone
    Color = 14215660
    TabOrder = 2
    object lblAppTitle: TLabel
      Left = 0
      Top = 80
      Width = 129
      Height = 17
      Alignment = taCenter
      Caption = #1606#1592#1575#1605' '#1578#1587#1610#1610#1585' '#1575#1604#1576#1585#1602#1610#1575#1578
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -14
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblAppSub: TLabel
      Left = 0
      Top = 100
      Width = 110
      Height = 13
      Alignment = taCenter
      Caption = #1583#1575#1574#1585#1577' '#1576#1608#1593#1604#1575#1605' - '#1608#1604#1575#1610#1577' '#1576#1588#1575#1585
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 5592405
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblUser: TLabel
      Left = 260
      Top = 134
      Width = 70
      Height = 12
      Caption = #1575#1587#1605' '#1575#1604#1605#1587#1578#1582#1583#1605':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -10
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblPass: TLabel
      Left = 279
      Top = 164
      Width = 51
      Height = 12
      Caption = #1603#1604#1605#1577' '#1575#1604#1605#1585#1608#1585':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -10
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblError: TLabel
      Left = 0
      Top = 188
      Width = 3
      Height = 12
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -10
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblHint: TLabel
      Left = 0
      Top = 202
      Width = 106
      Height = 11
      Alignment = taCenter
      Caption = #1603#1604#1605#1577' '#1575#1604#1605#1585#1608#1585' '#1575#1604#1575#1601#1578#1585#1575#1590#1610#1577': 1234'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 8947848
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object pnlLogo: TPanel
      Left = 140
      Top = 12
      Width = 60
      Height = 60
      BevelOuter = bvNone
      Color = 6567967
      TabOrder = 0
      object lblLogoIcon: TLabel
        Left = 0
        Top = 0
        Width = 16
        Height = 32
        Alignment = taCenter
        Caption = #62667
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -24
        Font.Name = 'Segoe UI Emoji'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
      end
    end
    object pnlSep: TPanel
      Left = 20
      Top = 120
      Width = 300
      Height = 1
      BevelOuter = bvNone
      Color = 8684164
      TabOrder = 1
    end
    object edtUser: TEdit
      Left = 20
      Top = 130
      Width = 264
      Height = 21
      TabOrder = 2
    end
    object edtPass: TEdit
      Left = 20
      Top = 160
      Width = 264
      Height = 21
      PasswordChar = '*'
      TabOrder = 3
      OnKeyPress = edtPassKeyPress
    end
    object btnLogin: TButton
      Left = 160
      Top = 222
      Width = 90
      Height = 26
      Caption = #1583#1582#1608#1604
      TabOrder = 4
      OnClick = btnLoginClick
    end
    object btnCancel: TButton
      Left = 60
      Top = 222
      Width = 80
      Height = 26
      Caption = #1573#1604#1594#1575#1569
      TabOrder = 5
      OnClick = btnCancelClick
    end
  end
end
