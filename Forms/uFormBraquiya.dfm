object frmFormBraquiya: TfrmFormBraquiya
  Left = 0
  Top = 0
  BiDiMode = bdRightToLeft
  BorderStyle = bsDialog
  ClientHeight = 580
  ClientWidth = 560
  Color = 13160660
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  ParentBiDiMode = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 560
    Height = 32
    Align = alTop
    BevelOuter = bvNone
    Color = 6567967
    TabOrder = 0
    object lblFormTitle: TLabel
      Left = 0
      Top = 0
      Width = 87
      Height = 17
      Align = alClient
      Alignment = taCenter
      Caption = #1606#1605#1608#1584#1580' '#1575#1604#1576#1585#1602#1610#1577
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -14
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 540
    Width = 560
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    Color = 14215660
    TabOrder = 1
    object btnSave: TButton
      Left = 460
      Top = 7
      Width = 80
      Height = 26
      Caption = #1581#1601#1592
      TabOrder = 0
      OnClick = btnSaveClick
    end
    object btnPrint: TButton
      Left = 374
      Top = 7
      Width = 80
      Height = 26
      Caption = #1591#1576#1575#1593#1577
      TabOrder = 1
    end
    object btnCancel: TButton
      Left = 290
      Top = 7
      Width = 80
      Height = 26
      Caption = #1573#1604#1594#1575#1569
      TabOrder = 2
      OnClick = btnCancelClick
    end
  end
  object pnlScroll: TPanel
    Left = 0
    Top = 32
    Width = 560
    Height = 508
    Align = alClient
    BevelOuter = bvNone
    Color = 13160660
    TabOrder = 2
    object pnlSec1: TPanel
      Left = 8
      Top = 8
      Width = 544
      Height = 168
      BevelOuter = bvLowered
      Color = 16119024
      TabOrder = 0
      object lblNum: TLabel
        Left = 517
        Top = 36
        Width = 19
        Height = 12
        Caption = #1585#1602#1605':'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblDate: TLabel
        Left = 302
        Top = 36
        Width = 62
        Height = 12
        Caption = #1578#1575#1585#1610#1582' '#1575#1604#1575#1587#1578#1604#1575#1605':'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblJiha: TLabel
        Left = 470
        Top = 66
        Width = 66
        Height = 12
        Caption = #1575#1604#1580#1607#1577' '#1575#1604#1605#1585#1587#1604#1577':'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblObjet: TLabel
        Left = 498
        Top = 96
        Width = 38
        Height = 12
        Caption = #1575#1604#1605#1608#1590#1608#1593':'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblUrgence: TLabel
        Left = 464
        Top = 130
        Width = 72
        Height = 12
        Caption = #1583#1585#1580#1577' '#1575#1604#1575#1587#1578#1593#1580#1575#1604':'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object pnlSec1Hdr: TPanel
        Left = 1
        Top = 1
        Width = 542
        Height = 22
        Align = alTop
        BevelOuter = bvNone
        Color = 6567967
        TabOrder = 0
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 544
        object lblSec1: TLabel
          Left = 446
          Top = 0
          Width = 98
          Height = 13
          Align = alClient
          Caption = '  '#1575#1604#1576#1610#1575#1606#1575#1578' '#1575#1604#1571#1587#1575#1587#1610#1577
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          Layout = tlCenter
        end
      end
      object edtNum: TEdit
        Left = 370
        Top = 32
        Width = 124
        Height = 22
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 1
        Text = '(#1578#1604#1602#1575#1574#1610)'
      end
      object dtDate: TDateTimePicker
        Left = 8
        Top = 32
        Width = 266
        Height = 20
        Date = 46138.000000000000000000
        Time = 0.972824212964042100
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
      end
      object cmbJiha: TComboBox
        Left = 8
        Top = 62
        Width = 448
        Height = 22
        Style = csDropDownList
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
      end
      object edtObjet: TEdit
        Left = 8
        Top = 92
        Width = 484
        Height = 22
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 4
      end
      object rbAjil: TRadioButton
        Left = 340
        Top = 128
        Width = 60
        Height = 18
        Caption = #1593#1575#1580#1604
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 5
      end
      object rbAdi: TRadioButton
        Left = 260
        Top = 128
        Width = 60
        Height = 18
        Caption = #1593#1575#1583#1610
        Checked = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 6
        TabStop = True
      end
      object rbSirri: TRadioButton
        Left = 180
        Top = 128
        Width = 60
        Height = 18
        Caption = #1587#1585#1610
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 7
      end
      object rbIdari: TRadioButton
        Left = 100
        Top = 128
        Width = 70
        Height = 18
        Caption = #1573#1583#1575#1585#1610
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 8
      end
    end
    object pnlSec2: TPanel
      Left = 8
      Top = 184
      Width = 544
      Height = 130
      BevelOuter = bvLowered
      Color = 16119024
      TabOrder = 1
      object lblContenu: TLabel
        Left = 487
        Top = 34
        Width = 49
        Height = 12
        Caption = #1606#1589' '#1575#1604#1576#1585#1602#1610#1577':'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object pnlSec2Hdr: TPanel
        Left = 0
        Top = 0
        Width = 544
        Height = 22
        Align = alTop
        BevelOuter = bvNone
        Color = 6567967
        TabOrder = 0
        object lblSec2: TLabel
          Left = 464
          Top = 0
          Width = 80
          Height = 13
          Align = alClient
          Caption = '  '#1605#1581#1578#1608#1609' '#1575#1604#1576#1585#1602#1610#1577
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          Layout = tlCenter
        end
      end
      object memContenu: TMemo
        Left = 8
        Top = 30
        Width = 482
        Height = 88
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
    object pnlSec3: TPanel
      Left = 8
      Top = 322
      Width = 544
      Height = 130
      BevelOuter = bvLowered
      Color = 16119024
      TabOrder = 2
      object lblService: TLabel
        Left = 462
        Top = 34
        Width = 74
        Height = 12
        Caption = #1575#1604#1605#1589#1604#1581#1577' '#1575#1604#1605#1593#1606#1610#1577':'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblRem: TLabel
        Left = 495
        Top = 66
        Width = 41
        Height = 12
        Caption = #1605#1604#1575#1581#1592#1575#1578':'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object pnlSec3Hdr: TPanel
        Left = 0
        Top = 0
        Width = 544
        Height = 22
        Align = alTop
        BevelOuter = bvNone
        Color = 6567967
        TabOrder = 0
        object lblSec3: TLabel
          Left = 448
          Top = 0
          Width = 96
          Height = 13
          Align = alClient
          Caption = '  '#1575#1604#1578#1608#1580#1610#1607' '#1608#1575#1604#1605#1593#1575#1604#1580#1577
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          Layout = tlCenter
        end
      end
      object cmbService: TComboBox
        Left = 8
        Top = 30
        Width = 450
        Height = 22
        Style = csDropDownList
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object memRem: TMemo
        Left = 8
        Top = 62
        Width = 482
        Height = 56
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 2
      end
    end
  end
end
