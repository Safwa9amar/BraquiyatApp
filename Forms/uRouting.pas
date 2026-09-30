unit uRouting;

{
  Workflow screen (التوجيه والمعالجة): lists active telegrams (received /
  routed / processing) and lets the user advance them through the lifecycle:
  route to a service -> mark processed -> archive. This is what finally drives
  the ETAT transitions and fills the Archive.

  Incoming telegrams are routed to an internal service (المصلحة); outgoing
  ones to a دائرة / بلدية of ولاية البيض (saved as المرسل إليه). The toolbar
  shows the matching dropdown for the selected row.

  The UI is built in code; the .dfm is intentionally minimal. Like the other
  content forms, only pnlMain is embedded into the main shell's content area.
}

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.Graphics, Vcl.Dialogs,
  Data.DB;

type
  TfrmRouting = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    FToolbar:    TPanel;
    FFooter:     TPanel;
    FGrid:       TDBGrid;
    FCmbService: TComboBox;
    FLblService: TLabel;
    FCmbDest:    TComboBox;
    FLblDest:    TLabel;
    FDs:         TDataSource;
    FLblCount:   TLabel;
    FBtnRoute, FBtnProcess, FBtnArchive, FBtnRefresh: TButton;
    function  MakeBtn(AParent: TWinControl; const ACap: string;
                      ALeft: Integer; AClick: TNotifyEvent): TButton;
    function  SelectedNum: Integer;
    function  SelectedIsSader: Boolean;
    procedure DsDataChange(Sender: TObject; Field: TField);
    procedure btnRouteClick(Sender: TObject);
    procedure btnProcessClick(Sender: TObject);
    procedure btnArchiveClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure GridDraw(Sender: TObject; const Rect: TRect; DataCol: Integer;
                       Column: TColumn; State: TGridDrawState);
  public
    pnlMain: TPanel;
    procedure LoadData;
  end;

var
  frmRouting: TfrmRouting;

implementation

{$R *.dfm}

uses
  uDM, uConsts, uTheme;

function TfrmRouting.MakeBtn(AParent: TWinControl; const ACap: string;
  ALeft: Integer; AClick: TNotifyEvent): TButton;
begin
  Result := TButton.Create(Self);
  Result.Parent  := AParent;
  Result.Caption := ACap;
  Result.Left    := ALeft;
  Result.Top     := 6;
  Result.Width   := 84;
  Result.Height  := 28;
  Result.OnClick := AClick;
end;

procedure TfrmRouting.FormCreate(Sender: TObject);
begin
  BiDiMode := bdRightToLeft;
  uTheme.StyleForm(Self);

  pnlMain := TPanel.Create(Self);
  pnlMain.Parent     := Self;
  pnlMain.Align      := alClient;
  pnlMain.BevelOuter := bvNone;

  FToolbar := TPanel.Create(Self);
  FToolbar.Parent     := pnlMain;
  FToolbar.Align      := alTop;
  FToolbar.Height     := 40;
  FToolbar.BevelOuter := bvNone;

  FBtnRoute   := MakeBtn(FToolbar, 'توجيه',  8,   btnRouteClick);
  FBtnProcess := MakeBtn(FToolbar, 'معالجة', 96,  btnProcessClick);
  FBtnArchive := MakeBtn(FToolbar, 'أرشفة',  184, btnArchiveClick);
  FBtnRefresh := MakeBtn(FToolbar, 'تحديث',  272, btnRefreshClick);

  FLblService := TLabel.Create(Self);
  FLblService.Parent  := FToolbar;
  FLblService.Left    := 372;
  FLblService.Top     := 12;
  FLblService.Caption := 'المصلحة:';

  FCmbService := TComboBox.Create(Self);
  FCmbService.Parent    := FToolbar;
  FCmbService.Left      := 424;
  FCmbService.Top       := 8;
  FCmbService.Width     := 220;
  FCmbService.Style     := csDropDownList;
  DM.FillServices(FCmbService.Items);   // offices from the DB (MASLAHA)
  FCmbService.ItemIndex := 0;

  // Outgoing telegrams: دوائر / بلديات ولاية البيض, same spot as المصلحة.
  FLblDest := TLabel.Create(Self);
  FLblDest.Parent  := FToolbar;
  FLblDest.Left    := 372;
  FLblDest.Top     := 12;
  FLblDest.Caption := 'المرسل إليه:';
  FLblDest.Visible := False;

  FCmbDest := TComboBox.Create(Self);
  FCmbDest.Parent    := FToolbar;
  FCmbDest.Left      := 440;
  FCmbDest.Top       := 8;
  FCmbDest.Width     := 220;
  FCmbDest.Style     := csDropDownList;
  FCmbDest.DropDownCount := 20;
  uConsts.FillBayadhLocalities(FCmbDest.Items);
  FCmbDest.ItemIndex := 0;
  FCmbDest.Visible   := False;

  FFooter := TPanel.Create(Self);
  FFooter.Parent     := pnlMain;
  FFooter.Align      := alBottom;
  FFooter.Height     := 26;
  FFooter.BevelOuter := bvNone;

  FLblCount := TLabel.Create(Self);
  FLblCount.Parent  := FFooter;
  FLblCount.Left    := 8;
  FLblCount.Top     := 6;
  FLblCount.Caption := '';

  FGrid := TDBGrid.Create(Self);
  FGrid.Parent     := pnlMain;
  FGrid.Align      := alClient;
  // Own data source on the shared query, so row changes can switch the
  // dropdown without hooking DM.dsBraquiya (used by the other screens).
  FDs := TDataSource.Create(Self);
  FDs.DataSet      := DM.qBraquiya;
  FDs.OnDataChange := DsDataChange;
  FGrid.DataSource := FDs;
  FGrid.ReadOnly   := True;
  FGrid.Options    := FGrid.Options + [dgRowSelect];
  FGrid.OnDrawColumnCell := GridDraw;

  LoadData;
end;

procedure TfrmRouting.LoadData;
var
  I: Integer;
begin
  DM.OpenNeedsRouting(Date - 365, Date);
  uTheme.SetupBraquiyaGrid(FGrid);
  // Mixed incoming/outgoing list: show the type (hidden by default).
  for I := 0 to FGrid.Columns.Count - 1 do
    if SameText(FGrid.Columns[I].FieldName, 'TYPE_BRQ') then
    begin
      FGrid.Columns[I].Visible   := True;
      FGrid.Columns[I].Width     := 70;
      FGrid.Columns[I].Alignment := taCenter;
    end;
  DsDataChange(nil, nil);
  FLblCount.Caption := ' قيد المعالجة: ' +
    IntToStr(DM.qBraquiya.RecordCount) + ' برقية ';
end;

function TfrmRouting.SelectedNum: Integer;
begin
  Result := -1;
  if not DM.qBraquiya.IsEmpty then
    Result := DM.qBraquiya.FieldByName('NUM_BRQ').AsInteger;
end;

function TfrmRouting.SelectedIsSader: Boolean;
var
  F: TField;
begin
  Result := False;
  // FindField: the shared query may have been reopened by another screen.
  if not DM.qBraquiya.Active or DM.qBraquiya.IsEmpty then Exit;
  F := DM.qBraquiya.FindField('TYPE_BRQ');
  Result := Assigned(F) and (F.AsString = TYP_SADER);
end;

// Row changed: المصلحة for incoming, دائرة / بلدية for outgoing telegrams.
procedure TfrmRouting.DsDataChange(Sender: TObject; Field: TField);
var
  IsSader: Boolean;
  F: TField;
  Idx: Integer;
begin
  if (Field <> nil) or not Assigned(FCmbDest) then Exit;
  IsSader := SelectedIsSader;
  FLblService.Visible := not IsSader;
  FCmbService.Visible := not IsSader;
  FLblDest.Visible    := IsSader;
  FCmbDest.Visible    := IsSader;
  if IsSader then
  begin
    // Preselect the addressee already stored, if it is one of the list.
    Idx := 0;
    F := DM.qBraquiya.FindField('DESTINATAIRE');
    if Assigned(F) and (Trim(F.AsString) <> '') then
      Idx := FCmbDest.Items.IndexOf(Trim(F.AsString));
    if Idx < 0 then Idx := 0;
    FCmbDest.ItemIndex := Idx;
  end;
end;

procedure TfrmRouting.GridDraw(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  R: TRect;
begin
  if Assigned(Column.Field) and SameText(Column.FieldName, 'TYPE_BRQ') then
  begin
    FGrid.Canvas.FillRect(Rect);
    R := Rect;
    DrawText(FGrid.Canvas.Handle, PChar(TypeLabel(Column.Field.AsString)), -1, R,
      DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_RTLREADING);
    Exit;
  end;
  uTheme.DrawBadgeCell(TDBGrid(Sender), Rect, Column);
end;

procedure TfrmRouting.btnRouteClick(Sender: TObject);
var
  N: Integer;
begin
  N := SelectedNum;
  if N < 0 then
  begin
    ShowMessage('يرجى اختيار برقية');
    Exit;
  end;
  try
    if SelectedIsSader then
    begin
      if FCmbDest.ItemIndex <= 0 then
      begin
        ShowMessage('يرجى اختيار الدائرة أو البلدية');
        Exit;
      end;
      DM.RouteSader(N, FCmbDest.Text);
    end
    else
    begin
      if FCmbService.ItemIndex <= 0 then
      begin
        ShowMessage('يرجى اختيار المصلحة');
        Exit;
      end;
      DM.RouteBraquiya(N, FCmbService.Text);
    end;
    LoadData;
  except
    on E: Exception do ShowMessage(E.Message);
  end;
end;

procedure TfrmRouting.btnProcessClick(Sender: TObject);
var
  N: Integer;
begin
  N := SelectedNum;
  if N < 0 then
  begin
    ShowMessage('يرجى اختيار برقية');
    Exit;
  end;
  try
    DM.MarkProcessed(N);
    LoadData;
  except
    on E: Exception do ShowMessage(E.Message);
  end;
end;

procedure TfrmRouting.btnArchiveClick(Sender: TObject);
var
  N: Integer;
begin
  N := SelectedNum;
  if N < 0 then
  begin
    ShowMessage('يرجى اختيار برقية');
    Exit;
  end;
  try
    DM.ArchiveBraquiya(N);
    LoadData;
  except
    on E: Exception do ShowMessage(E.Message);
  end;
end;

procedure TfrmRouting.btnRefreshClick(Sender: TObject);
begin
  LoadData;
end;

end.
