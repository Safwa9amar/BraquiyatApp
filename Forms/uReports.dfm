object frmReports: TfrmReports
  Left = 0
  Top = 0
  BiDiMode = bdRightToLeft
  Caption = #1575#1604#1578#1602#1575#1585#1610#1585
  ClientHeight = 500
  ClientWidth = 740
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  ParentBiDiMode = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 740
    Height = 500
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pnlHeader: TPanel
      Left = 0
      Top = 0
      Width = 740
      Height = 44
      Align = alTop
      BevelOuter = bvNone
      Color = clPurple
      TabOrder = 0
      object lblTitle: TLabel
        Left = 0
        Top = 0
        Width = 166
        Height = 18
        Alignment = taCenter
        Caption = #1575#1604#1578#1602#1575#1585#1610#1585
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
      end
    end
    object pnlOptions: TPanel
      Left = 0
      Top = 44
      Width = 740
      Height = 80
      Align = alTop
      BevelOuter = bvNone
      Color = 15526360
      TabOrder = 1
      object lblReportType: TLabel
        Left = 561
        Top = 12
        Width = 159
        Height = 16
        Caption = #1606#1608#1593' '#1575#1604#1578#1602#1585#1610#1585':'
      end
      object lblDateFrom: TLabel
        Left = 392
        Top = 52
        Width = 128
        Height = 16
        Caption = #1605#1606' '#1578#1575#1585#1610#1582':'
      end
      object lblDateTo: TLabel
        Left = 171
        Top = 52
        Width = 149
        Height = 16
        Caption = #1573#1604#1609' '#1578#1575#1585#1610#1582':'
      end
      object cmbReportType: TComboBox
        Left = 300
        Top = 8
        Width = 310
        Height = 24
        Style = csDropDownList
        TabOrder = 0
      end
      object dtFrom: TDateTimePicker
        Left = 300
        Top = 48
        Width = 130
        Height = 24
        Date = 46138.000000000000000000
        Time = 0.975396053239819600
        TabOrder = 1
      end
      object dtTo: TDateTimePicker
        Left = 110
        Top = 48
        Width = 130
        Height = 24
        Date = 46138.000000000000000000
        Time = 0.975396180554525900
        TabOrder = 2
      end
      object btnGenerate: TButton
        Left = 590
        Top = 46
        Width = 120
        Height = 28
        Caption = #1578#1608#1604#1610#1583' '#1575#1604#1578#1602#1585#1610#1585
        TabOrder = 3
        OnClick = btnGenerateClick
      end
      object btnPrint: TButton
        Left = 60
        Top = 46
        Width = 70
        Height = 28
        Caption = #1591#1576#1575#1593#1577
        TabOrder = 4
        OnClick = btnPrintClick
      end
      object btnExport: TButton
        Left = 135
        Top = 46
        Width = 70
        Height = 28
        Caption = #1578#1589#1583#1610#1585
        TabOrder = 5
        OnClick = btnExportClick
      end
    end
    object pnlPreview: TPanel
      Left = 0
      Top = 124
      Width = 740
      Height = 376
      Align = alClient
      BevelInner = bvLowered
      TabOrder = 2
      object lblPreview: TLabel
        Left = 0
        Top = 0
        Width = 435
        Height = 16
        Alignment = taCenter
        Caption = #1575#1590#1594#1591' "'#1578#1608#1604#1610#1583' '#1575#1604#1578#1602#1585#1610#1585'" '#1604#1593#1585#1590' '#1575#1604#1606#1578#1575#1574#1580
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
      end
    end
  end
end
