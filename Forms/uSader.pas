unit uSader;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes,
  Vcl.Forms, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.DBCtrls,
  Vcl.Controls, Vcl.ComCtrls, Vcl.Graphics, Vcl.Dialogs,
  Data.DB;

const
  CLR_PANEL  = $00FFFFFF;   // white surfaces
  CLR_NAVY   = $00D84E1D;   // primary blue (#1D4ED8)
  CLR_BG     = $00FAF8F7;   // near-white page (#F7F8FA)

type
  TfrmSader = class(TForm)
    pnlMain:     TPanel;
    pnlToolbar:  TPanel;
    btnAdd:      TButton;
    btnEdit:     TButton;
    btnDelete:   TButton;
    btnRefresh:  TButton;
    btnPrint:    TButton;
    btnExport:   TButton;
    pnlSearch:   TPanel;
    lblSearch:   TLabel;
    edtSearch:   TEdit;
    lblFrom:     TLabel;
    dtFrom:      TDateTimePicker;
    lblTo:       TLabel;
    dtTo:        TDateTimePicker;
    lblUrgence:  TLabel;
    cmbUrgence:  TComboBox;
    lblEtat:     TLabel;
    cmbEtat:     TComboBox;
    btnSearch:   TButton;
    btnClear:    TButton;
    grdBraquiya: TDBGrid;
    pnlFooter:   TPanel;
    lblCount:    TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure grdBraquiyaDblClick(Sender: TObject);
    procedure grdBraquiyaDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure edtSearchKeyPress(Sender: TObject; var Key: Char);
  public
    procedure LoadData;
  end;

var
  frmSader: TfrmSader;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  uDM, uFormBraquiya, uConsts, uTheme, uUtils;

procedure TfrmSader.FormCreate(Sender: TObject);
begin
  BiDiMode := bdRightToLeft;

  // Light theme surfaces — remove seClient so the colours render under the style
  pnlMain.StyleElements    := pnlMain.StyleElements - [seClient];
  pnlMain.ParentBackground := False;
  pnlMain.Color      := CLR_BG;
  pnlMain.BevelOuter := bvNone;
  pnlToolbar.StyleElements    := pnlToolbar.StyleElements - [seClient];
  pnlToolbar.ParentBackground := False;
  pnlToolbar.Color      := CLR_PANEL;
  pnlToolbar.BevelOuter := bvNone;
  pnlToolbar.Height     := 32;
  pnlSearch.StyleElements    := pnlSearch.StyleElements - [seClient];
  pnlSearch.ParentBackground := False;
  pnlSearch.Color      := CLR_PANEL;
  pnlSearch.BevelOuter := bvNone;
  pnlSearch.Height     := 32;
  pnlFooter.StyleElements    := pnlFooter.StyleElements - [seClient];
  pnlFooter.ParentBackground := False;
  pnlFooter.Color      := CLR_PANEL;
  pnlFooter.BevelOuter := bvNone;
  pnlFooter.Height     := 22;

  grdBraquiya.Color      := clWhite;
  grdBraquiya.FixedColor := $00FAFAF9;   // light header band
  grdBraquiya.Font.Name  := uTheme.FONT_NAME;
  grdBraquiya.Font.Size  := 9;

  btnAdd.Caption     := #1573#1590#1575#1601#1577;
  btnEdit.Caption    := #1578#1593#1583#1610#1604;
  btnDelete.Caption  := #1581#1584#1601;
  btnRefresh.Caption := #1578#1581#1583#1610#1579;
  btnPrint.Caption   := #1591#1576#1575#1593#1577;
  btnExport.Caption  := #1578#1589#1583#1610#1585;

  lblSearch.Caption  := #1576#1581#1579':';
  lblFrom.Caption    := #1605#1606':';
  lblTo.Caption      := #1573#1604#1609':';
  lblUrgence.Caption := #1575#1604#1575#1587#1578#1593#1580#1575#1604':';
  lblEtat.Caption    := #1575#1604#1581#1575#1604#1577':';
  btnSearch.Caption  := #1576#1581#1579;
  btnClear.Caption   := #1605#1587#1581;

  cmbUrgence.Items.Clear;
  cmbUrgence.Items.AddStrings([
    #1575#1604#1603#1604, #1593#1575#1580#1604, #1593#1575#1583#1610, #1587#1585#1610,
    #1573#1583#1575#1585#1610]);
  cmbUrgence.ItemIndex := 0;

  cmbEtat.Items.Clear;
  cmbEtat.Items.AddStrings([
    #1575#1604#1603#1604, #1589#1575#1583#1585#1577, #1605#1608#1580#1607#1577, #1605#1593#1575#1604#1580#1577, #1605#1572#1585#1588#1601#1577]);
  cmbEtat.ItemIndex := 0;

  dtFrom.Date := Date - 30;
  dtTo.Date   := Date;

  grdBraquiya.DataSource := DM.dsBraquiya;
  grdBraquiya.ReadOnly   := True;
  grdBraquiya.Options    := grdBraquiya.Options + [dgRowSelect];

  btnPrint.OnClick     := btnPrintClick;
  btnExport.OnClick    := btnExportClick;
  edtSearch.OnKeyPress := edtSearchKeyPress;
  grdBraquiya.OnDrawColumnCell := grdBraquiyaDrawColumnCell;

  uTheme.StyleForm(Self);

  LoadData;
end;

procedure TfrmSader.LoadData;
begin
  DM.OpenBraquiyat(TYP_SADER, '', '', dtFrom.Date, dtTo.Date, Trim(edtSearch.Text));
  uTheme.SetupBraquiyaGrid(grdBraquiya);
  lblCount.Caption :=
    ' ' + #1575#1604#1605#1580#1605#1608#1593': ' +
    IntToStr(DM.qBraquiya.RecordCount) + ' ' + #1576#1585#1602#1610#1577 + ' ';
end;

procedure TfrmSader.btnSearchClick(Sender: TObject);
var
  U, E: string;
begin
  case cmbUrgence.ItemIndex of
    1: U := URG_AJIL;
    2: U := URG_ADI;
    3: U := URG_SIRRI;
    4: U := URG_IDARI;
  else
    U := '';
  end;
  case cmbEtat.ItemIndex of
    1: E := ST_SADERAH;
    2: E := ST_MAWJAHA;
    3: E := ST_MOALAJA;
    4: E := ST_MORSAFA;
  else
    E := '';
  end;
  DM.OpenBraquiyat(TYP_SADER, E, U, dtFrom.Date, dtTo.Date, Trim(edtSearch.Text));
  uTheme.SetupBraquiyaGrid(grdBraquiya);
  lblCount.Caption :=
    ' ' + #1575#1604#1605#1580#1605#1608#1593': ' +
    IntToStr(DM.qBraquiya.RecordCount) + ' ' + #1576#1585#1602#1610#1577 + ' ';
end;

procedure TfrmSader.edtSearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btnSearchClick(Sender);
  end;
end;

procedure TfrmSader.btnClearClick(Sender: TObject);
begin
  edtSearch.Clear;
  cmbUrgence.ItemIndex := 0;
  cmbEtat.ItemIndex    := 0;
  dtFrom.Date := Date - 30;
  dtTo.Date   := Date;
  LoadData;
end;

procedure TfrmSader.btnAddClick(Sender: TObject);
begin
  frmFormBraquiya := TfrmFormBraquiya.Create(Self);
  try
    frmFormBraquiya.SetMode('ADD', 'SADER');
    if frmFormBraquiya.ShowModal = mrOk then LoadData;
  finally
    FreeAndNil(frmFormBraquiya);
  end;
end;

procedure TfrmSader.btnEditClick(Sender: TObject);
begin
  if DM.qBraquiya.IsEmpty then Exit;
  frmFormBraquiya := TfrmFormBraquiya.Create(Self);
  try
    frmFormBraquiya.SetMode('EDIT',
      DM.qBraquiya.FieldByName('NUM_BRQ').AsInteger);
    if frmFormBraquiya.ShowModal = mrOk then LoadData;
  finally
    FreeAndNil(frmFormBraquiya);
  end;
end;

procedure TfrmSader.btnDeleteClick(Sender: TObject);
var N: Integer;
begin
  if DM.qBraquiya.IsEmpty then Exit;
  N := DM.qBraquiya.FieldByName('NUM_BRQ').AsInteger;
  if MessageDlg(
    #1607#1604' '#1578#1585#1610#1583' '#1581#1584#1601' '#1575#1604#1576#1585#1602#1610#1577' '#1585#1602#1605' ' + IntToStr(N) + '؟',
    mtWarning, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      DM.SoftDelete(N);
      LoadData;
    except
      on E: Exception do ShowMessage(E.Message);
    end;
  end;
end;

procedure TfrmSader.btnRefreshClick(Sender: TObject);
begin
  LoadData;
end;

procedure TfrmSader.grdBraquiyaDblClick(Sender: TObject);
begin
  btnEditClick(Sender);
end;

procedure TfrmSader.grdBraquiyaDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  uTheme.DrawBadgeCell(TDBGrid(Sender), Rect, Column);
end;

procedure TfrmSader.btnPrintClick(Sender: TObject);
var
  F: string;
begin
  if DM.qBraquiya.IsEmpty then
  begin
    ShowMessage(#1604#1575' '#1578#1608#1580#1583' '#1576#1610#1575#1606#1575#1578' '#1604#1604#1591#1576#1575#1593#1577);
    Exit;
  end;
  F := TPath.Combine(TPath.GetTempPath, 'braquiyat_sader.html');
  if uUtils.ExportDataSetToHTML(DM.qBraquiya, F,
       #1575#1604#1576#1585#1602#1610#1575#1578' '#1575#1604#1589#1575#1583#1585#1577) then
    uUtils.OpenFileExternally(F);
end;

procedure TfrmSader.btnExportClick(Sender: TObject);
var
  Dlg: TSaveDialog;
begin
  if DM.qBraquiya.IsEmpty then Exit;
  Dlg := TSaveDialog.Create(Self);
  try
    Dlg.Filter     := 'CSV (*.csv)|*.csv';
    Dlg.DefaultExt := 'csv';
    Dlg.FileName   := 'braquiyat_sader.csv';
    if Dlg.Execute then
      if uUtils.ExportDataSetToCSV(DM.qBraquiya, Dlg.FileName) then
        ShowMessage(#1578#1605' '#1575#1604#1578#1589#1583#1610#1585' '#1576#1606#1580#1575#1581);
  finally
    Dlg.Free;
  end;
end;

end.
