unit uWared;

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
  CLR_BORDER = $00EBE7E5;   // hairline (#E5E7EB)
  CLR_BG     = $00FAF8F7;   // near-white page (#F7F8FA)

type
  TfrmWared = class(TForm)
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
  frmWared: TfrmWared;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  uDM, uFormBraquiya, uConsts, uTheme, uUtils;

procedure TfrmWared.FormCreate(Sender: TObject);
var
  AddBtn: TPanel;
  AddLbl: TLabel;
begin
  BiDiMode := bdRightToLeft;

  // Light theme surfaces — remove seClient so the colours actually render
  // under the active VCL style.
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

  // Toolbar button labels
  btnAdd.Caption     := #1573#1590#1575#1601#1577;
  btnEdit.Caption    := #1578#1593#1583#1610#1604;
  btnDelete.Caption  := #1581#1584#1601;
  btnRefresh.Caption := #1578#1581#1583#1610#1579;
  btnPrint.Caption   := #1591#1576#1575#1593#1577;
  btnExport.Caption  := #1578#1589#1583#1610#1585;

  // Search labels
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
    #1575#1604#1603#1604, #1608#1575#1585#1583#1577, #1605#1608#1580#1607#1577, #1605#1593#1575#1604#1580#1577, #1605#1572#1585#1588#1601#1577]);
  cmbEtat.ItemIndex := 0;

  dtFrom.Date := Date - 30;
  dtTo.Date   := Date;

  grdBraquiya.DataSource := DM.dsBraquiya;
  grdBraquiya.ReadOnly   := True;
  grdBraquiya.Options    := grdBraquiya.Options + [dgRowSelect];

  // Wire controls that had no handlers in the .dfm
  btnPrint.OnClick    := btnPrintClick;
  btnExport.OnClick   := btnExportClick;
  edtSearch.OnKeyPress := edtSearchKeyPress;
  grdBraquiya.OnDrawColumnCell := grdBraquiyaDrawColumnCell;

  uTheme.StyleForm(Self);

  // ── Primary blue "إضافة جديد" (custom panel-button) + red "حذف" ──
  btnDelete.StyleElements := btnDelete.StyleElements - [seFont];
  btnDelete.Font.Color    := $003C4CE7;   // red

  AddBtn := TPanel.Create(Self);
  AddBtn.Parent       := pnlToolbar;
  AddBtn.BoundsRect   := btnAdd.BoundsRect;
  AddBtn.BevelOuter   := bvNone;
  AddBtn.StyleElements    := AddBtn.StyleElements - [seClient];
  AddBtn.ParentBackground := False;
  AddBtn.Color        := uTheme.ACCENT_BLUE;
  AddBtn.Cursor       := crHandPoint;
  AddBtn.OnClick      := btnAddClick;

  AddLbl := TLabel.Create(Self);
  AddLbl.Parent       := AddBtn;
  AddLbl.Align        := alClient;
  AddLbl.Caption      := #1573#1590#1575#1601#1577' '#1580#1583#1610#1583;   // إضافة جديد
  AddLbl.Transparent  := True;
  AddLbl.StyleElements := AddLbl.StyleElements - [seFont];
  AddLbl.Font.Name    := uTheme.FONT_NAME;
  AddLbl.Font.Size    := 9;
  AddLbl.Font.Style   := [fsBold];
  AddLbl.Font.Color   := clWhite;
  AddLbl.Alignment    := taCenter;
  AddLbl.Layout       := tlCenter;
  AddLbl.Cursor       := crHandPoint;
  AddLbl.OnClick      := btnAddClick;
  btnAdd.Visible      := False;

  LoadData;
end;

procedure TfrmWared.LoadData;
begin
  DM.OpenBraquiyat(TYP_WARED, '', '', dtFrom.Date, dtTo.Date, Trim(edtSearch.Text));
  uTheme.SetupBraquiyaGrid(grdBraquiya);
  lblCount.Caption :=
    ' ' + #1575#1604#1605#1580#1605#1608#1593': ' +
    IntToStr(DM.qBraquiya.RecordCount) + ' ' + #1576#1585#1602#1610#1577 + ' ';
end;

procedure TfrmWared.btnSearchClick(Sender: TObject);
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
    1: E := ST_WAREDAH;
    2: E := ST_MAWJAHA;
    3: E := ST_MOALAJA;
    4: E := ST_MORSAFA;
  else
    E := '';
  end;
  DM.OpenBraquiyat(TYP_WARED, E, U, dtFrom.Date, dtTo.Date, Trim(edtSearch.Text));
  uTheme.SetupBraquiyaGrid(grdBraquiya);
  lblCount.Caption :=
    ' ' + #1575#1604#1605#1580#1605#1608#1593': ' +
    IntToStr(DM.qBraquiya.RecordCount) + ' ' + #1576#1585#1602#1610#1577 + ' ';
end;

procedure TfrmWared.edtSearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btnSearchClick(Sender);
  end;
end;

procedure TfrmWared.btnClearClick(Sender: TObject);
begin
  edtSearch.Clear;
  cmbUrgence.ItemIndex := 0;
  cmbEtat.ItemIndex    := 0;
  dtFrom.Date := Date - 30;
  dtTo.Date   := Date;
  LoadData;
end;

procedure TfrmWared.btnAddClick(Sender: TObject);
begin
  frmFormBraquiya := TfrmFormBraquiya.Create(Self);
  try
    frmFormBraquiya.SetMode('ADD', 'WARED');
    if frmFormBraquiya.ShowModal = mrOk then LoadData;
  finally
    FreeAndNil(frmFormBraquiya);
  end;
end;

procedure TfrmWared.btnEditClick(Sender: TObject);
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

procedure TfrmWared.btnDeleteClick(Sender: TObject);
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

procedure TfrmWared.btnRefreshClick(Sender: TObject);
begin
  LoadData;
end;

procedure TfrmWared.grdBraquiyaDblClick(Sender: TObject);
begin
  btnEditClick(Sender);
end;

procedure TfrmWared.grdBraquiyaDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  uTheme.DrawBadgeCell(TDBGrid(Sender), Rect, Column);
end;

procedure TfrmWared.btnPrintClick(Sender: TObject);
var
  F: string;
begin
  if DM.qBraquiya.IsEmpty then
  begin
    ShowMessage(#1604#1575' '#1578#1608#1580#1583' '#1576#1610#1575#1606#1575#1578' '#1604#1604#1591#1576#1575#1593#1577);
    Exit;
  end;
  F := TPath.Combine(TPath.GetTempPath, 'braquiyat_wared.html');
  if uUtils.ExportDataSetToHTML(DM.qBraquiya, F,
       #1575#1604#1576#1585#1602#1610#1575#1578' '#1575#1604#1608#1575#1585#1583#1577) then
    uUtils.OpenFileExternally(F);
end;

procedure TfrmWared.btnExportClick(Sender: TObject);
var
  Dlg: TSaveDialog;
begin
  if DM.qBraquiya.IsEmpty then Exit;
  Dlg := TSaveDialog.Create(Self);
  try
    Dlg.Filter     := 'CSV (*.csv)|*.csv';
    Dlg.DefaultExt := 'csv';
    Dlg.FileName   := 'braquiyat_wared.csv';
    if Dlg.Execute then
      if uUtils.ExportDataSetToCSV(DM.qBraquiya, Dlg.FileName) then
        ShowMessage(#1578#1605' '#1575#1604#1578#1589#1583#1610#1585' '#1576#1606#1580#1575#1581);
  finally
    Dlg.Free;
  end;
end;

end.
