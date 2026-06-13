unit uDashboard;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes,
  Vcl.Forms, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Controls, Vcl.Graphics, Vcl.Grids;

type
  TfrmDashboard = class(TForm)
    pnlMain:      TPanel;
    pnlCards:     TPanel;
    pnlRecent:    TPanel;
    pnlRecentHdr: TPanel;
    lblRecentHdr: TLabel;
    sgRecent:     TStringGrid;
    pnlBottom:    TPanel;
    pnlUrgStats:  TPanel;
    pnlUrgHdr:    TLabel;
    pnlStatStats: TPanel;
    pnlStatHdr:   TLabel;
    procedure FormCreate(Sender: TObject);
  private
    FCards: array[0..3] of TPanel;
    FUrgBody:  TLabel;
    FStatBody: TLabel;
    procedure CreateStatCards;
    procedure SetupRecentGrid;
    procedure SetupBottomStats;
  public
    procedure RefreshStats;
  end;

var
  frmDashboard: TfrmDashboard;

implementation

{$R *.dfm}

uses
  uDM, uConsts, uTheme, Data.DB;

const
  CLR_PANEL  = $00D8E9EC;
  CLR_NAVY   = $0064381F;
  CLR_BORDER = $00848284;
  CLR_BG     = $00C8D0D4;

procedure TfrmDashboard.FormCreate(Sender: TObject);
begin
  BiDiMode := bdRightToLeft;
  Color    := CLR_BG;
  uTheme.StyleForm(Self);

  pnlMain.Color      := CLR_BG;
  pnlMain.BevelOuter := bvNone;

  pnlCards.Color      := CLR_BG;
  pnlCards.BevelOuter := bvNone;
  pnlCards.Height     := 90;
  pnlCards.Align      := alTop;

  CreateStatCards;
  SetupRecentGrid;
  SetupBottomStats;
  RefreshStats;
end;

procedure TfrmDashboard.CreateStatCards;
  function MakeCard(AParent: TWinControl;
                    const ATitle: string;
                    AColor: TColor): TPanel;
  var
    pnl:   TPanel;
    lTitle: TLabel;
    lVal:  TLabel;
    lSub:  TLabel;
  begin
    pnl              := TPanel.Create(Self);
    pnl.Parent       := AParent;
    pnl.Align        := alLeft;
    pnl.BevelOuter   := bvNone;
    pnl.Color        := clWhite;
    pnl.Width        := 0; // will be set by parent width / 4

    // Classic border
    pnl.BevelInner   := bvNone;
    pnl.BorderStyle  := bsSingle;

    lTitle            := TLabel.Create(Self);
    lTitle.Parent     := pnl;
    lTitle.Caption    := ATitle;
    lTitle.Left       := 8;
    lTitle.Top        := 8;
    lTitle.Font.Size  := 8;
    lTitle.Font.Name  := 'Tahoma';
    lTitle.Font.Color := $00555555;

    lVal              := TLabel.Create(Self);
    lVal.Parent       := pnl;
    lVal.Caption      := '0';
    lVal.Left         := 8;
    lVal.Top          := 28;
    lVal.Font.Size    := 26;
    lVal.Font.Style   := [fsBold];
    lVal.Font.Name    := 'Tahoma';
    lVal.Font.Color   := AColor;
    lVal.Tag          := 1; // mark as value label

    lSub              := TLabel.Create(Self);
    lSub.Parent       := pnl;
    lSub.Caption      := FormatDateTime('dd/mm/yyyy', Date);
    lSub.Left         := 8;
    lSub.Top          := 66;
    lSub.Font.Size    := 8;
    lSub.Font.Name    := 'Tahoma';
    lSub.Font.Color   := $00888888;

    Result := pnl;
  end;
var
  Titles: array[0..3] of string;
  Colors: array[0..3] of TColor;
  I, CardW: Integer;
begin
  Titles[0] := #1575#1604#1576#1585#1602#1610#1575#1578' '#1575#1604#1608#1575#1585#1583#1577' '#1575#1604#1610#1608#1605;
  Titles[1] := #1575#1604#1576#1585#1602#1610#1575#1578' '#1575#1604#1589#1575#1583#1585#1577' '#1575#1604#1610#1608#1605;
  Titles[2] := #1602#1610#1583' '#1575#1604#1605#1593#1575#1604#1580#1577;
  Titles[3] := #1573#1580#1605#1575#1604#1610' '#1575#1604#1588#1607#1585;

  Colors[0] := CLR_NAVY;
  Colors[1] := $00205715;  // dark green
  Colors[2] := $00025685;  // dark amber
  Colors[3] := $00495057;  // dark gray

  for I := 0 to 3 do
    FCards[I] := MakeCard(pnlCards, Titles[I], Colors[I]);

  // Set equal widths after creation — handled by alLeft, resize at runtime
  CardW := pnlCards.ClientWidth div 4;
  for I := 0 to 3 do
    FCards[I].Width := CardW - 4;

  // The last card fills remaining space
  FCards[3].Align := alClient;
end;

procedure TfrmDashboard.SetupRecentGrid;
var
  I: Integer;
  ColWidths: array[0..5] of Integer;
  ColCaps:   array[0..5] of string;
begin
  pnlRecent.Color      := $00FFFFFF;
  pnlRecent.BevelOuter := bvNone;
  pnlRecent.Align      := alClient;

  pnlRecentHdr.Color      := CLR_NAVY;
  pnlRecentHdr.BevelOuter := bvNone;
  pnlRecentHdr.Height     := 24;
  pnlRecentHdr.Align      := alTop;

  lblRecentHdr.Caption    := '  ' + #1570#1582#1585' '#1575#1604#1576#1585#1602#1610#1575#1578' '#1575#1604#1608#1575#1585#1583#1577;
  lblRecentHdr.Font.Color := clWhite;
  lblRecentHdr.Font.Style := [fsBold];
  lblRecentHdr.Font.Name  := 'Tahoma';
  lblRecentHdr.Font.Size  := 9;
  lblRecentHdr.Align      := alClient;
  lblRecentHdr.Layout     := tlCenter;

  // Configure grid
  sgRecent.Parent       := pnlRecent;
  sgRecent.Align        := alClient;
  sgRecent.RowCount     := 8;
  sgRecent.ColCount     := 6;
  sgRecent.FixedRows    := 1;
  sgRecent.FixedCols    := 0;
  sgRecent.DefaultRowHeight := 20;
  sgRecent.Options      := [goFixedVertLine, goFixedHorzLine,
                             goVertLine, goHorzLine, goRowSizing,
                             goColSizing, goRowSelect];
  sgRecent.Color        := clWhite;
  sgRecent.FixedColor   := CLR_PANEL;
  sgRecent.Font.Name    := 'Tahoma';
  sgRecent.Font.Size    := 8;
  sgRecent.BiDiMode     := bdRightToLeft;

  ColCaps[0]  := #1585#1602#1605' '#1575#1604#1576#1585#1602#1610#1577;
  ColCaps[1]  := #1575#1604#1578#1575#1585#1610#1582;
  ColCaps[2]  := #1575#1604#1580#1607#1577' '#1575#1604#1605#1585#1587#1604#1577;
  ColCaps[3]  := #1575#1604#1605#1608#1590#1608#1593;
  ColCaps[4]  := #1575#1604#1575#1587#1578#1593#1580#1575#1604;
  ColCaps[5]  := #1575#1604#1581#1575#1604#1577;

  ColWidths[0] := 100;
  ColWidths[1] := 80;
  ColWidths[2] := 120;
  ColWidths[3] := 200;
  ColWidths[4] := 70;
  ColWidths[5] := 70;

  for I := 0 to 5 do
  begin
    sgRecent.ColWidths[I] := ColWidths[I];
    sgRecent.Cells[I, 0]  := ColCaps[I];
  end;
end;

procedure TfrmDashboard.SetupBottomStats;
begin
  pnlBottom.Color      := CLR_BG;
  pnlBottom.BevelOuter := bvNone;
  pnlBottom.Height     := 60;
  pnlBottom.Align      := alBottom;

  pnlUrgStats.Color      := clWhite;
  pnlUrgStats.BevelOuter := bvNone;
  pnlUrgStats.BorderStyle := bsSingle;
  pnlUrgStats.Align       := alRight;
  pnlUrgStats.Width       := pnlBottom.ClientWidth div 2 - 4;

  pnlUrgHdr.Caption    := '  ' + #1578#1608#1586#1610#1593' '#1575#1604#1576#1585#1602#1610#1575#1578' '#1581#1587#1576' '#1575#1604#1575#1587#1578#1593#1580#1575#1604#1610#1577;
  pnlUrgHdr.Color      := CLR_NAVY;
  pnlUrgHdr.Font.Color := clWhite;
  pnlUrgHdr.Font.Style := [fsBold];
  pnlUrgHdr.Align      := alTop;
  pnlUrgHdr.Height     := 20;

  pnlStatStats.Color      := clWhite;
  pnlStatStats.BevelOuter := bvNone;
  pnlStatStats.BorderStyle := bsSingle;
  pnlStatStats.Align       := alClient;

  pnlStatHdr.Caption    := '  ' + #1575#1604#1576#1585#1602#1610#1575#1578' '#1581#1587#1576' '#1575#1604#1581#1575#1604#1577;
  pnlStatHdr.Color      := CLR_NAVY;
  pnlStatHdr.Font.Color := clWhite;
  pnlStatHdr.Font.Style := [fsBold];
  pnlStatHdr.Align      := alTop;
  pnlStatHdr.Height     := 20;

  // Body labels that hold the live breakdown numbers (filled by RefreshStats)
  FUrgBody := TLabel.Create(Self);
  FUrgBody.Parent    := pnlUrgStats;
  FUrgBody.Align     := alClient;
  FUrgBody.Alignment := taCenter;
  FUrgBody.Layout    := tlCenter;
  FUrgBody.WordWrap  := True;
  FUrgBody.BiDiMode  := bdRightToLeft;
  FUrgBody.Font.Name := uTheme.FONT_NAME;
  FUrgBody.Font.Size := 10;

  FStatBody := TLabel.Create(Self);
  FStatBody.Parent    := pnlStatStats;
  FStatBody.Align     := alClient;
  FStatBody.Alignment := taCenter;
  FStatBody.Layout    := tlCenter;
  FStatBody.WordWrap  := True;
  FStatBody.BiDiMode  := bdRightToLeft;
  FStatBody.Font.Name := uTheme.FONT_NAME;
  FStatBody.Font.Size := 10;
end;

procedure TfrmDashboard.RefreshStats;
var
  Counts: array[0..3] of Integer;
  I, Row: Integer;
  ValLbl: TLabel;
  rq:     TDataSet;
begin
  Counts[0] := DM.GetCountToday(TYP_WARED);
  Counts[1] := DM.GetCountToday(TYP_SADER);
  Counts[2] := DM.GetCountPending;
  Counts[3] := DM.GetCountMonth('');

  for I := 0 to 3 do
    if FCards[I].ControlCount >= 2 then
    begin
      ValLbl := TLabel(FCards[I].Controls[1]);
      ValLbl.Caption := IntToStr(Counts[I]);
    end;

  // Recent telegrams grid (clear data rows, keep header row 0)
  for Row := 1 to sgRecent.RowCount - 1 do
    for I := 0 to sgRecent.ColCount - 1 do
      sgRecent.Cells[I, Row] := '';

  rq := DM.OpenRecent(sgRecent.RowCount - 1);
  Row := 1;
  while (not rq.Eof) and (Row < sgRecent.RowCount) do
  begin
    sgRecent.Cells[0, Row] := rq.FieldByName('NUM_BRQ').AsString;
    if not rq.FieldByName('DATE_REC').IsNull then
      sgRecent.Cells[1, Row] :=
        FormatDateTime('yyyy/mm/dd', rq.FieldByName('DATE_REC').AsDateTime);
    sgRecent.Cells[2, Row] := rq.FieldByName('NOM_JIHA').AsString;
    sgRecent.Cells[3, Row] := rq.FieldByName('OBJET').AsString;
    sgRecent.Cells[4, Row] := UrgencyLabel(rq.FieldByName('URGENCE').AsString);
    sgRecent.Cells[5, Row] := StateLabel(rq.FieldByName('ETAT').AsString);
    rq.Next;
    Inc(Row);
  end;

  // Breakdown panels
  if Assigned(FUrgBody) then
    FUrgBody.Caption :=
      UrgencyLabel(URG_AJIL)  + ': ' + IntToStr(DM.GetCountByUrgency(URG_AJIL))  + '     ' +
      UrgencyLabel(URG_ADI)   + ': ' + IntToStr(DM.GetCountByUrgency(URG_ADI))   + '     ' +
      UrgencyLabel(URG_SIRRI) + ': ' + IntToStr(DM.GetCountByUrgency(URG_SIRRI)) + '     ' +
      UrgencyLabel(URG_IDARI) + ': ' + IntToStr(DM.GetCountByUrgency(URG_IDARI));

  if Assigned(FStatBody) then
    FStatBody.Caption :=
      StateLabel(ST_WAREDAH) + ': ' + IntToStr(DM.GetCountByState(ST_WAREDAH)) + '     ' +
      StateLabel(ST_SADERAH) + ': ' + IntToStr(DM.GetCountByState(ST_SADERAH)) + '     ' +
      StateLabel(ST_MAWJAHA) + ': ' + IntToStr(DM.GetCountByState(ST_MAWJAHA)) + '     ' +
      StateLabel(ST_MOALAJA) + ': ' + IntToStr(DM.GetCountByState(ST_MOALAJA)) + '     ' +
      StateLabel(ST_MORSAFA) + ': ' + IntToStr(DM.GetCountByState(ST_MORSAFA));
end;

end.
