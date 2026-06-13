object frmArchive: TfrmArchive
  Left = 0
  Top = 0
  BiDiMode = bdRightToLeft
  Caption = #216#167#217#8222#216#163#216#177#216#180#217#352#217#129
  ClientHeight = 550
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
    Height = 550
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object lblCount: TLabel
      Left = 12
      Top = 528
      Width = 173
      Height = 16
      Caption = #216#185#216#175#216#175' '#216#167#217#8222#216#179#216#172#217#8222#216#167#216#170': 0'
    end
    object pnlToolbar: TPanel
      Left = 0
      Top = 0
      Width = 740
      Height = 36
      Align = alTop
      BevelOuter = bvNone
      Color = 15526360
      TabOrder = 0
      object btnRefresh: TButton
        Left = 640
        Top = 4
        Width = 80
        Height = 28
        Caption = #216#170#216#173#216#175#217#352#216#171
        TabOrder = 0
        OnClick = btnRefreshClick
      end
      object btnRestore: TButton
        Left = 555
        Top = 4
        Width = 80
        Height = 28
        Caption = #216#167#216#179#216#170#216#185#216#167#216#175#216#169
        TabOrder = 1
        OnClick = btnRestoreClick
      end
    end
    object pnlSearch: TPanel
      Left = 0
      Top = 36
      Width = 740
      Height = 36
      Align = alTop
      BevelOuter = bvNone
      Color = 15526360
      TabOrder = 1
      object lblSearch: TLabel
        Left = 669
        Top = 10
        Width = 51
        Height = 16
        Caption = #216#168#216#173#216#171':'
      end
      object lblDateFrom: TLabel
        Left = 362
        Top = 10
        Width = 128
        Height = 16
        Caption = #217#8230#217#8224' '#216#170#216#167#216#177#217#352#216#174':'
      end
      object lblDateTo: TLabel
        Left = 151
        Top = 10
        Width = 149
        Height = 16
        Caption = #216#165#217#8222#217#8240' '#216#170#216#167#216#177#217#352#216#174':'
      end
      object edtSearch: TEdit
        Left = 530
        Top = 6
        Width = 120
        Height = 24
        TabOrder = 0
      end
      object dtFrom: TDateTimePicker
        Left = 300
        Top = 6
        Width = 110
        Height = 24
        Date = 46138.000000000000000000
        Time = 0.974825428238546000
        TabOrder = 1
      end
      object dtTo: TDateTimePicker
        Left = 110
        Top = 6
        Width = 110
        Height = 24
        Date = 46138.000000000000000000
        Time = 0.974825543984479700
        TabOrder = 2
      end
      object btnSearch: TButton
        Left = 20
        Top = 6
        Width = 80
        Height = 24
        Caption = #216#168#216#173#216#171
        TabOrder = 3
        OnClick = btnSearchClick
      end
    end
    object grdArchive: TDBGrid
      Left = 0
      Top = 72
      Width = 740
      Height = 478
      Align = alClient
      TabOrder = 2
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -13
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
  end
end
