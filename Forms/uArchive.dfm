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
      object cmbYear: TComboBox
        Left = 772
        Top = 8
        Width = 72
        Height = 24
        Style = csDropDownList
        TabOrder = 0
      end
      object lblMonth: TLabel
        Left = 712
        Top = 12
        Width = 48
        Height = 16
      end
      object cmbMonth: TComboBox
        Left = 600
        Top = 8
        Width = 106
        Height = 24
        Style = csDropDownList
        TabOrder = 1
      end
      object lblType: TLabel
        Left = 554
        Top = 12
        Width = 40
        Height = 16
      end
      object cmbType: TComboBox
        Left = 472
        Top = 8
        Width = 76
        Height = 24
        Style = csDropDownList
        TabOrder = 2
      end
      object lblSearch: TLabel
        Left = 422
        Top = 12
        Width = 44
        Height = 16
      end
      object edtSearch: TEdit
        Left = 190
        Top = 8
        Width = 226
        Height = 24
        TabOrder = 3
        OnKeyPress = edtSearchKeyPress
      end
      object btnSearch: TButton
        Left = 102
        Top = 8
        Width = 80
        Height = 26
        TabOrder = 4
        OnClick = btnSearchClick
      end
      object btnClear: TButton
        Left = 16
        Top = 8
        Width = 80
        Height = 26
        TabOrder = 5
        OnClick = btnClearClick
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
