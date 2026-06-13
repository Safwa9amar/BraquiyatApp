object frmArchive: TfrmArchive
  Left = 0
  Top = 0
  BiDiMode = bdRightToLeft
  Caption = #1575#1604#1571#1585#1588#1610#1601
  ClientHeight = 560
  ClientWidth = 900
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
    Width = 900
    Height = 560
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pnlToolbar: TPanel
      Left = 0
      Top = 0
      Width = 900
      Height = 36
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object btnRefresh: TButton
        Left = 816
        Top = 4
        Width = 80
        Height = 28
        TabOrder = 0
        OnClick = btnRefreshClick
      end
      object btnRestore: TButton
        Left = 730
        Top = 4
        Width = 80
        Height = 28
        TabOrder = 1
        OnClick = btnRestoreClick
      end
      object btnPrint: TButton
        Left = 644
        Top = 4
        Width = 80
        Height = 28
        TabOrder = 2
      end
      object btnExport: TButton
        Left = 558
        Top = 4
        Width = 80
        Height = 28
        TabOrder = 3
      end
    end
    object pnlSearch: TPanel
      Left = 0
      Top = 36
      Width = 900
      Height = 40
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object lblYear: TLabel
        Left = 852
        Top = 12
        Width = 40
        Height = 16
      end
      object lblMonth: TLabel
        Left = 712
        Top = 12
        Width = 48
        Height = 16
      end
      object lblType: TLabel
        Left = 544
        Top = 12
        Width = 40
        Height = 16
      end
      object lblFrom: TLabel
        Left = 300
        Top = 12
        Width = 40
        Height = 16
      end
      object lblTo: TLabel
        Left = 150
        Top = 12
        Width = 40
        Height = 16
      end
      object cmbYear: TComboBox
        Left = 772
        Top = 8
        Width = 72
        Height = 24
        Style = csDropDownList
        TabOrder = 0
      end
      object cmbMonth: TComboBox
        Left = 596
        Top = 8
        Width = 110
        Height = 24
        Style = csDropDownList
        TabOrder = 1
      end
      object cmbType: TComboBox
        Left = 448
        Top = 8
        Width = 90
        Height = 24
        Style = csDropDownList
        TabOrder = 2
      end
      object dtFrom: TDateTimePicker
        Left = 180
        Top = 8
        Width = 110
        Height = 24
        Date = 46138.000000000000000000
        Time = 0.000000000000000000
        TabOrder = 3
      end
      object dtTo: TDateTimePicker
        Left = 30
        Top = 8
        Width = 110
        Height = 24
        Date = 46138.000000000000000000
        Time = 0.000000000000000000
        TabOrder = 4
      end
      object btnSearch: TButton
        Left = 360
        Top = 8
        Width = 80
        Height = 26
        TabOrder = 5
        OnClick = btnSearchClick
      end
    end
    object grdArchive: TDBGrid
      Left = 0
      Top = 76
      Width = 900
      Height = 460
      Align = alClient
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect]
      TabOrder = 2
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -13
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
    object pnlFooter: TPanel
      Left = 0
      Top = 536
      Width = 900
      Height = 24
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 3
      object lblCount: TLabel
        Left = 820
        Top = 5
        Width = 72
        Height = 16
      end
    end
  end
end
