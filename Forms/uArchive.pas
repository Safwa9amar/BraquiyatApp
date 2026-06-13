unit uArchive;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.DateUtils, System.UITypes,
  Vcl.Forms, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.DBCtrls,
  Vcl.Controls, Vcl.ComCtrls, Vcl.Graphics, Vcl.Dialogs, Data.DB;

const
  CLR_PANEL = $00FFFFFF;   // white surfaces
  CLR_NAVY  = $00D84E1D;   // primary blue (#1D4ED8)
  CLR_BG    = $00FAF8F7;   // near-white page (#F7F8FA)

type
  TfrmArchive = class(TForm)
    pnlMain:     TPanel;
    pnlToolbar:  TPanel;
    btnRefresh:  TButton;
    btnRestore:  TButton;
    btnPrint:    TButton;
    btnExport:   TButton;
    pnlSearch:   TPanel;
    lblYear:     TLabel;
    cmbYear:     TComboBox;
    lblMonth:    TLabel;
    cmbMonth:    TComboBox;
    lblType:     TLabel;
    cmbType:     TComboBox;
    lblFrom:     TLabel;
    dtFrom:      TDateTimePicker;
    lblTo:       TLabel;
    dtTo:        TDateTimePicker;
    btnSearch:   TButton;
    grdArchive:  TDBGrid;
    pnlFooter:   TPanel;
    lblCount:    TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnRestoreClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure grdArchiveDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    procedure LoadData;
  end;

var
  frmArchive: TfrmArchive;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  uDM, uConsts, uTheme, uUtils;

procedure TfrmArchive.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  BiDiMode := bdRightToLeft;
  Color    := CLR_BG;

  // Light theme surfaces — remove seClient so the colours render under the style
  pnlMain.StyleElements    := pnlMain.StyleElements - [seClient];
  pnlMain.ParentBackground := False;
  pnlMain.Color      := CLR_BG;
  pnlMain.BevelOuter := bvNone;
  pnlToolbar.StyleElements    := pnlToolbar.StyleElements - [seClient];
  pnlToolbar.ParentBackground := False;
  pnlToolbar.Color   := CLR_PANEL;
  pnlToolbar.BevelOuter := bvNone;
  pnlSearch.StyleElements    := pnlSearch.StyleElements - [seClient];
  pnlSearch.ParentBackground := False;
  pnlSearch.Color    := CLR_PANEL;
  pnlSearch.BevelOuter := bvNone;
  pnlFooter.StyleElements    := pnlFooter.StyleElements - [seClient];
  pnlFooter.ParentBackground := False;
  pnlFooter.Color    := CLR_PANEL;
  pnlFooter.BevelOuter := bvNone;

  grdArchive.Color      := clWhite;
  grdArchive.FixedColor := $00FAFAF9;   // light header band
  grdArchive.Font.Name  := uTheme.FONT_NAME;
  grdArchive.Font.Size  := 9;

  btnRefresh.Caption := #1578#1581#1583#1610#1579;
  btnRestore.Caption := #1575#1587#1578#1593#1575#1583#1577;
  btnPrint.Caption   := #1591#1576#1575#1593#1577;
  btnExport.Caption  := #1578#1589#1583#1610#1585;

  lblYear.Caption  := #1575#1604#1587#1606#1577':';
  lblMonth.Caption := #1575#1604#1588#1607#1585':';
  lblType.Caption  := #1575#1604#1606#1608#1593':';
  lblFrom.Caption  := #1605#1606':';
  lblTo.Caption    := #1573#1604#1609':';
  btnSearch.Caption := #1576#1581#1579;

  // Year
  cmbYear.Items.Clear;
  for I := 2020 to YearOf(Date) + 1 do
    cmbYear.Items.Add(IntToStr(I));
  cmbYear.ItemIndex := cmbYear.Items.Count - 2;

  // Month
  cmbMonth.Items.Clear;
  cmbMonth.Items.AddStrings([
    #1575#1604#1603#1604,
    #1610#1606#1575#1610#1585, #1601#1576#1585#1575#1610#1585, #1605#1575#1585#1587, #1571#1576#1585#1610#1604, #1605#1575#1610#1608, #1610#1608#1606#1610#1608,
    #1610#1608#1604#1610#1608, #1571#1594#1587#1591#1587, #1587#1576#1578#1605#1576#1585, #1571#1603#1578#1608#1576#1585, #1606#1608#1601#1605#1576#1585, #1583#1610#1587#1605#1576#1585]);
  cmbMonth.ItemIndex := 0;

  // Type
  cmbType.Items.Clear;
  cmbType.Items.AddStrings([#1575#1604#1603#1604, #1608#1575#1585#1583, #1589#1575#1583#1585]);
  cmbType.ItemIndex := 0;

  dtFrom.Date := EncodeDate(YearOf(Date), 1, 1);
  dtTo.Date   := Date;

  grdArchive.DataSource := DM.dsBraquiya;
  grdArchive.ReadOnly   := True;
  grdArchive.Options    := grdArchive.Options + [dgRowSelect];

  // The archive filters by year/month/type; the free date pickers are redundant.
  lblFrom.Visible := False;
  lblTo.Visible   := False;
  dtFrom.Visible  := False;
  dtTo.Visible    := False;

  btnPrint.OnClick  := btnPrintClick;
  btnExport.OnClick := btnExportClick;
  grdArchive.OnDrawColumnCell := grdArchiveDrawColumnCell;

  uTheme.StyleForm(Self);

  LoadData;
end;

procedure TfrmArchive.LoadData;
var
  Typ: string;
  Y, M: Integer;
  D1, D2: TDate;
begin
  case cmbType.ItemIndex of
    1: Typ := TYP_WARED;
    2: Typ := TYP_SADER;
  else
    Typ := '';
  end;

  if cmbYear.ItemIndex >= 0 then
    Y := StrToIntDef(cmbYear.Items[cmbYear.ItemIndex], YearOf(Date))
  else
    Y := YearOf(Date);

  M := cmbMonth.ItemIndex;   // 0 = all months, 1..12 = specific month
  if M <= 0 then
  begin
    D1 := EncodeDate(Y, 1, 1);
    D2 := EncodeDate(Y, 12, 31);
  end
  else
  begin
    D1 := EncodeDate(Y, M, 1);
    D2 := EndOfTheMonth(D1);
  end;

  DM.OpenBraquiyat(Typ, ST_MORSAFA, '', D1, D2);
  uTheme.SetupBraquiyaGrid(grdArchive);
  lblCount.Caption :=
    ' ' + #1575#1604#1571#1585#1588#1610#1601': ' +
    IntToStr(DM.qBraquiya.RecordCount) + ' ' + #1576#1585#1602#1610#1577' '#1605#1572#1585#1588#1601#1577 + ' ';
end;

procedure TfrmArchive.btnRefreshClick(Sender: TObject);
begin
  LoadData;
end;

procedure TfrmArchive.btnRestoreClick(Sender: TObject);
var N: Integer;
begin
  if DM.qBraquiya.IsEmpty then Exit;
  N := DM.qBraquiya.FieldByName('NUM_BRQ').AsInteger;
  if MessageDlg(
    #1607#1604' '#1578#1585#1610#1583' '#1575#1587#1578#1593#1575#1583#1577' '#1575#1604#1576#1585#1602#1610#1577' '#1585#1602#1605' ' + IntToStr(N) + '؟',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      DM.RestoreBraquiya(N);
      LoadData;
    except
      on E: Exception do ShowMessage(E.Message);
    end;
  end;
end;

procedure TfrmArchive.btnSearchClick(Sender: TObject);
begin
  LoadData;
end;

procedure TfrmArchive.grdArchiveDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  uTheme.DrawBadgeCell(TDBGrid(Sender), Rect, Column);
end;

procedure TfrmArchive.btnPrintClick(Sender: TObject);
var
  F: string;
begin
  if DM.qBraquiya.IsEmpty then Exit;
  F := TPath.Combine(TPath.GetTempPath, 'archive.html');
  if uUtils.ExportDataSetToHTML(DM.qBraquiya, F, #1575#1604#1571#1585#1588#1610#1601) then
    uUtils.OpenFileExternally(F);
end;

procedure TfrmArchive.btnExportClick(Sender: TObject);
var
  Dlg: TSaveDialog;
begin
  if DM.qBraquiya.IsEmpty then Exit;
  Dlg := TSaveDialog.Create(Self);
  try
    Dlg.Filter     := 'CSV (*.csv)|*.csv';
    Dlg.DefaultExt := 'csv';
    Dlg.FileName   := 'archive.csv';
    if Dlg.Execute then
      if uUtils.ExportDataSetToCSV(DM.qBraquiya, Dlg.FileName) then
        ShowMessage(#1578#1605' '#1575#1604#1578#1589#1583#1610#1585' '#1576#1606#1580#1575#1581);
  finally
    Dlg.Free;
  end;
end;

end.
