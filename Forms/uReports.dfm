object frmReports: TfrmReports
  Left = 0
  Top = 0
  BiDiMode = bdRightToLeft
  Caption = #216#167#217#8222#216#170#217#8218#216#167#216#177#217#352#216#177
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
        Caption = #216#167#217#8222#216#170#217#8218#216#167#216#177#217#352#216#177
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
        Caption = #217#8224#217#710#216#185' '#216#167#217#8222#216#170#217#8218#216#177#217#352#216#177':'
      end
      object lblDateFrom: TLabel
        Left = 392
        Top = 52
        Width = 128
        Height = 16
        Caption = #217#8230#217#8224' '#216#170#216#167#216#177#217#352#216#174':'
      end
      object lblDateTo: TLabel
        Left = 171
        Top = 52
        Width = 149
        Height = 16
        Caption = #216#165#217#8222#217#8240' '#216#170#216#167#216#177#217#352#216#174':'
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
        Caption = #216#170#217#710#217#8222#217#352#216#175' '#216#167#217#8222#216#170#217#8218#216#177#217#352#216#177
        TabOrder = 3
        OnClick = btnGenerateClick
      end
      object btnPrint: TButton
        Left = 60
        Top = 46
        Width = 70
        Height = 28
        Caption = #216#183#216#168#216#167#216#185#216#169
        TabOrder = 4
        OnClick = btnPrintClick
      end
      object btnExport: TButton
        Left = 135
        Top = 46
        Width = 70
        Height = 28
        Caption = #216#170#216#181#216#175#217#352#216#177
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
        Caption = #216#167#216#182#216#186#216#183' "'#216#170#217#710#217#8222#217#352#216#175' '#216#167#217#8222#216#170#217#8218#216#177#217#352#216#177'" '#217#8222#216#185#216#177#216#182' '#216#167#217#8222#217#8224#216#170#216#167#216#166#216#172
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
