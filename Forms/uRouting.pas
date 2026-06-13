unit uRouting;

{
  Workflow screen (التوجيه والمعالجة): lists active telegrams (received /
  routed / processing) and lets the user advance them through the lifecycle:
  route to a service -> mark processed -> archive. This is what finally drives
  the ETAT transitions and fills the Archive.

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
    FLblCount:   TLabel;
    FBtnRoute, FBtnProcess, FBtnArchive, FBtnRefresh: TButton;
    function  MakeBtn(AParent: TWinControl; const ACap: string;
                      ALeft: Integer; AClick: TNotifyEvent): TButton;
    function  SelectedNum: Integer;
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
  uConsts.FillServices(FCmbService.Items);
  FCmbService.ItemIndex := 0;

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
  FGrid.DataSource := DM.dsBraquiya;
  FGrid.ReadOnly   := True;
  FGrid.Options    := FGrid.Options + [dgRowSelect];
  FGrid.OnDrawColumnCell := GridDraw;

  LoadData;
end;

procedure TfrmRouting.LoadData;
begin
  DM.OpenNeedsRouting(Date - 365, Date);
  uTheme.SetupBraquiyaGrid(FGrid);
  FLblCount.Caption := ' قيد المعالجة: ' +
    IntToStr(DM.qBraquiya.RecordCount) + ' برقية ';
end;

function TfrmRouting.SelectedNum: Integer;
begin
  Result := -1;
  if not DM.qBraquiya.IsEmpty then
    Result := DM.qBraquiya.FieldByName('NUM_BRQ').AsInteger;
end;

procedure TfrmRouting.GridDraw(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
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
  if FCmbService.ItemIndex <= 0 then
  begin
    ShowMessage('يرجى اختيار المصلحة');
    Exit;
  end;
  try
    DM.RouteBraquiya(N, FCmbService.Text);
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
