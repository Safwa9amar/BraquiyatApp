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
    FCards:    array[0..3] of TPanel;
    FChips:    array[0..3] of TPanel;   // colored icon chip per card
    FValLbls:  array[0..3] of TLabel;
    FUrgBody:  TLabel;
    FStatBody: TLabel;
    FTrack:    array[0..3] of TPanel;   // priority bar track
    FFill:     array[0..3] of TPanel;   // priority bar colored fill
    FPcts:     array[0..3] of TLabel;   // priority percentage label
    FPctVal:   array[0..3] of Integer;  // cached percentage (for resize)
    procedure CreateStatCards;
    procedure SetupRecentGrid;
    procedure SetupBottomStats;
    procedure CardsResize(Sender: TObject);
    procedure BarsResize(Sender: TObject);
    procedure GridResize(Sender: TObject);
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
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
  CLR_NAVY   = $00D84E1D;   // primary blue (#1D4ED8) — matches uTheme accent
  CLR_BORDER = $00848284;
  CLR_BG     = $00FAF8F7;   // near-white page background (#F7F8FA)

  // Urgency codes shown (in order) by the priority-distribution card
  PRIORITY_URG: array[0..3] of string = (URG_AJIL, URG_ADI, URG_SIRRI, URG_IDARI);

type
  TCtrlCrack = class(TControl);   // exposes the protected OnResize event

procedure TfrmDashboard.FormCreate(Sender: TObject);
begin
  BiDiMode := bdRightToLeft;
  Color    := CLR_BG;
  uTheme.StyleForm(Self);

  pnlMain.Color      := CLR_BG;
  pnlMain.BevelOuter := bvNone;

  pnlCards.Color      := CLR_BG;
  pnlCards.BevelOuter := bvNone;
  pnlCards.Height     := 150;
  pnlCards.Align      := alTop;
  TCtrlCrack(pnlCards).OnResize := CardsResize;

  CreateStatCards;
  SetupRecentGrid;
  SetupBottomStats;
  RefreshStats;
end;

procedure TfrmDashboard.CreateStatCards;
const
  ICON_FONT = 'Segoe MDL2 Assets';

  procedure MakeCard(AIndex: Integer; const ATitle, AGlyph: string;
                     AColor, ATint: TColor);
  var
    pnl, band, chip:          TPanel;
    lTitle, lVal, lSub, lIco: TLabel;
  begin
    pnl              := TPanel.Create(Self);
    pnl.Parent       := pnlCards;
    pnl.BevelOuter   := bvNone;
    pnl.StyleElements    := pnl.StyleElements - [seClient];
    pnl.ParentBackground := False;
    pnl.Color        := uTheme.CardSurface;

    // ── Top band: icon chip (right) + metric title (fills, right-aligned) ──
    band             := TPanel.Create(Self);
    band.Parent      := pnl;
    band.Align       := alTop;
    band.Height      := 56;
    band.BevelOuter  := bvNone;
    band.StyleElements    := band.StyleElements - [seClient];
    band.ParentBackground := False;
    band.Color       := uTheme.CardSurface;

    chip             := TPanel.Create(Self);
    chip.Parent      := band;
    chip.Align       := alRight;
    chip.AlignWithMargins := True;
    chip.Margins.SetBounds(14, 6, 14, 6);
    chip.Width       := 44;
    chip.BevelOuter  := bvNone;
    chip.StyleElements    := chip.StyleElements - [seClient];
    chip.ParentBackground := False;
    chip.Color       := ATint;

    lIco             := TLabel.Create(Self);
    lIco.Parent      := chip;
    lIco.Align       := alClient;
    lIco.Caption     := AGlyph;
    lIco.Transparent := True;
    lIco.StyleElements := lIco.StyleElements - [seFont];
    lIco.Font.Name   := ICON_FONT;
    lIco.Font.Size   := 16;
    lIco.Font.Color  := AColor;
    lIco.Alignment   := taCenter;
    lIco.Layout      := tlCenter;

    lTitle           := TLabel.Create(Self);
    lTitle.Parent    := band;
    lTitle.Align     := alClient;
    lTitle.AlignWithMargins := True;
    lTitle.Margins.SetBounds(8, 0, 14, 0);
    lTitle.Caption   := ATitle;
    lTitle.Transparent := True;
    lTitle.StyleElements := lTitle.StyleElements - [seFont];
    lTitle.Font.Name := uTheme.FONT_NAME;
    lTitle.Font.Size := 10;
    lTitle.Font.Color := uTheme.MutedText;
    lTitle.Layout    := tlCenter;
    lTitle.BiDiMode  := bdRightToLeft;
    lTitle.Alignment := taLeftJustify;   // RTL flip -> visual right

    // ── Date — bottom band, right-aligned ──
    lSub             := TLabel.Create(Self);
    lSub.Parent      := pnl;
    lSub.Align       := alBottom;
    lSub.AlignWithMargins := True;
    lSub.Margins.SetBounds(16, 0, 16, 10);
    lSub.Caption     := FormatDateTime('yyyy/mm/dd', Date);
    lSub.Transparent := True;
    lSub.StyleElements := lSub.StyleElements - [seFont];
    lSub.Font.Name   := uTheme.FONT_NAME;
    lSub.Font.Size   := 8;
    lSub.Font.Color  := uTheme.MutedText;
    lSub.Layout      := tlCenter;
    lSub.BiDiMode    := bdRightToLeft;
    lSub.Alignment   := taLeftJustify;

    // ── Big number — fills the middle, right-aligned (RTL) ──
    lVal             := TLabel.Create(Self);
    lVal.Parent      := pnl;
    lVal.Align       := alClient;
    lVal.AlignWithMargins := True;
    lVal.Margins.SetBounds(16, 0, 16, 0);
    lVal.Caption     := '0';
    lVal.Transparent := True;
    lVal.StyleElements := lVal.StyleElements - [seFont];
    lVal.Font.Name   := uTheme.FONT_NAME;
    lVal.Font.Size   := 28;
    lVal.Font.Style  := [fsBold];
    lVal.Font.Color  := uTheme.TEXT_MAIN;
    lVal.Layout      := tlCenter;
    lVal.BiDiMode    := bdRightToLeft;
    lVal.Alignment   := taLeftJustify;   // RTL flip -> visual right

    FCards[AIndex]   := pnl;
    FChips[AIndex]   := chip;
    FValLbls[AIndex] := lVal;
  end;

var
  Titles, Glyphs: array[0..3] of string;
  Colors, Tints:  array[0..3] of TColor;
  I: Integer;
begin
  Titles[0] := #1575#1604#1576#1585#1602#1610#1575#1578' '#1575#1604#1608#1575#1585#1583#1577' '#1575#1604#1610#1608#1605;
  Titles[1] := #1575#1604#1576#1585#1602#1610#1575#1578' '#1575#1604#1589#1575#1583#1585#1577' '#1575#1604#1610#1608#1605;
  Titles[2] := #1602#1610#1583' '#1575#1604#1605#1593#1575#1604#1580#1577;
  Titles[3] := #1573#1580#1605#1575#1604#1610' '#1575#1604#1588#1607#1585;

  Glyphs[0] := #$E896;  // download / incoming
  Glyphs[1] := #$E898;  // upload / outgoing
  Glyphs[2] := #$E724;  // routing / in-progress
  Glyphs[3] := #$E8A5;  // document / total

  Colors[0] := $004444EF;           Tints[0] := $00E2E2FE;  // red
  Colors[1] := uTheme.ACCENT_BLUE;  Tints[1] := uTheme.ACCENT_LIGHT;  // blue
  Colors[2] := $000B9EF5;           Tints[2] := $00C7F3FE;  // amber
  Colors[3] := $0081B910;           Tints[3] := $00E5FAD1;  // green

  for I := 0 to 3 do
    MakeCard(I, Titles[I], Glyphs[I], Colors[I], Tints[I]);

  CardsResize(pnlCards);
end;

procedure TfrmDashboard.SetupRecentGrid;
var
  I: Integer;
  ColCaps: array[0..5] of string;
begin
  pnlRecent.StyleElements    := pnlRecent.StyleElements - [seClient];
  pnlRecent.ParentBackground := False;
  pnlRecent.Color      := uTheme.CardSurface;
  pnlRecent.BevelOuter := bvNone;
  pnlRecent.Align      := alClient;
  pnlRecent.AlignWithMargins := True;
  pnlRecent.Margins.SetBounds(8, 8, 16, 12);   // gap from the priority card + edges

  pnlRecentHdr.StyleElements    := pnlRecentHdr.StyleElements - [seClient];
  pnlRecentHdr.ParentBackground := False;
  pnlRecentHdr.Color      := uTheme.CardSurface;   // white section header
  pnlRecentHdr.BevelOuter := bvNone;
  pnlRecentHdr.Height     := 40;
  pnlRecentHdr.Align      := alTop;

  lblRecentHdr.Caption    := '   ' + #1570#1582#1585' '#1575#1604#1576#1585#1602#1610#1575#1578' '#1575#1604#1608#1575#1585#1583#1577;
  lblRecentHdr.StyleElements := lblRecentHdr.StyleElements - [seFont];
  lblRecentHdr.Transparent := True;
  lblRecentHdr.Font.Color := uTheme.TEXT_MAIN;     // dark title
  lblRecentHdr.Font.Style := [fsBold];
  lblRecentHdr.Font.Name  := uTheme.FONT_NAME;
  lblRecentHdr.Font.Size  := 11;
  lblRecentHdr.Align      := alClient;
  lblRecentHdr.Layout     := tlCenter;
  lblRecentHdr.BiDiMode   := bdRightToLeft;
  lblRecentHdr.Alignment  := taLeftJustify;   // RTL flip -> visual right

  // Configure grid — fully owner-drawn (see GridDrawCell), auto-fit (GridResize)
  sgRecent.Parent       := pnlRecent;
  sgRecent.Align        := alClient;
  sgRecent.RowCount     := 9;
  sgRecent.ColCount     := 6;
  sgRecent.FixedRows    := 1;
  sgRecent.FixedCols    := 0;
  sgRecent.DefaultRowHeight := 30;
  sgRecent.DefaultDrawing := False;
  sgRecent.BorderStyle  := bsNone;
  sgRecent.Options      := [goFixedHorzLine, goHorzLine, goRowSelect];
  sgRecent.Color        := uTheme.CardSurface;
  sgRecent.FixedColor   := uTheme.AccentHeader;
  sgRecent.Font.Name    := uTheme.FONT_NAME;
  sgRecent.Font.Size    := 9;
  sgRecent.BiDiMode     := bdRightToLeft;
  sgRecent.OnDrawCell   := GridDrawCell;
  TCtrlCrack(sgRecent).OnResize := GridResize;

  ColCaps[0]  := #1585#1602#1605' '#1575#1604#1576#1585#1602#1610#1577;
  ColCaps[1]  := #1575#1604#1578#1575#1585#1610#1582;
  ColCaps[2]  := #1575#1604#1580#1607#1577' '#1575#1604#1605#1585#1587#1604#1577;
  ColCaps[3]  := #1575#1604#1605#1608#1590#1608#1593;
  ColCaps[4]  := #1575#1604#1575#1587#1578#1593#1580#1575#1604;
  ColCaps[5]  := #1575#1604#1581#1575#1604#1577;
  for I := 0 to 5 do
    sgRecent.Cells[I, 0] := ColCaps[I];

  GridResize(sgRecent);
end;

procedure TfrmDashboard.CardsResize(Sender: TObject);
const
  GAP = 12;
var
  Avail, CardW, I, X: Integer;
begin
  Avail := pnlCards.ClientWidth - GAP * 5;
  if Avail <= 0 then Exit;
  CardW := Avail div 4;
  // RTL: the first metric sits on the right, the rest flow leftward
  X := pnlCards.ClientWidth - GAP - CardW;
  for I := 0 to 3 do
  begin
    if Assigned(FCards[I]) then
    begin
      FCards[I].SetBounds(X, GAP, CardW, pnlCards.ClientHeight - GAP * 2);
      uTheme.RoundPanel(FCards[I], 14);
      if Assigned(FChips[I]) then
        uTheme.RoundPanel(FChips[I], 12);
    end;
    Dec(X, CardW + GAP);
  end;
end;

procedure TfrmDashboard.GridResize(Sender: TObject);
const
  W: array[0..5] of Double = (0.10, 0.13, 0.18, 0.31, 0.14, 0.14);
var
  G: TStringGrid;
  Avail, I, Used, ColW: Integer;
begin
  G := TStringGrid(Sender);
  Avail := G.ClientWidth - (G.ColCount + 1);
  if Avail <= 60 then Exit;
  Used := 0;
  // Every column except the subject (3) takes a fixed share; subject flexes.
  for I := 0 to 5 do
    if I <> 3 then
    begin
      ColW := Round(W[I] * Avail);
      G.ColWidths[I] := ColW;
      Inc(Used, ColW);
    end;
  ColW := Avail - Used;
  if ColW < 120 then ColW := 120;
  G.ColWidths[3] := ColW;
end;

procedure TfrmDashboard.GridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  G:      TStringGrid;
  Cv:     TCanvas;
  Txt:    string;
  Bg, Fg: TColor;
  Flags:  Cardinal;
  R:      TRect;
  Dark:   Boolean;
begin
  G    := TStringGrid(Sender);
  Cv   := G.Canvas;
  Txt  := G.Cells[ACol, ARow];
  Dark := uTheme.IsDarkStyle;

  if ARow = 0 then
  begin
    if Dark then Bg := $00373330 else Bg := $00FAFAF9;  // light header row
    Fg := uTheme.MutedText;                             // muted column titles
  end
  else if gdSelected in State then
  begin
    Bg := uTheme.ACCENT_LIGHT;       // light-blue selection
    Fg := uTheme.ACCENT_BLUE;
  end
  else
  begin
    if Dark then Fg := $00DDDDDD else Fg := uTheme.TEXT_MAIN;
    if Odd(ARow) then
      Bg := uTheme.CardSurface
    else if Dark then
      Bg := $00373330
    else
      Bg := $00FCFAF8;               // cool very-light alt row
  end;

  Cv.Brush.Style := bsSolid;
  Cv.Brush.Color := Bg;
  Cv.FillRect(Rect);

  if Trim(Txt) <> '' then
  begin
    Cv.Font.Name  := uTheme.FONT_NAME;
    Cv.Font.Size  := 9;
    Cv.Font.Color := Fg;
    if ARow = 0 then Cv.Font.Style := [fsBold] else Cv.Font.Style := [];
    Cv.Brush.Style := bsClear;

    R := Rect;
    InflateRect(R, -8, 0);
    Flags := DT_VCENTER or DT_SINGLELINE or DT_RTLREADING or DT_END_ELLIPSIS;
    if (ARow = 0) or (ACol = 0) or (ACol >= 4) then
      Flags := Flags or DT_CENTER
    else
      Flags := Flags or DT_RIGHT;
    Winapi.Windows.DrawText(Cv.Handle, PChar(Txt), Length(Txt), R, Flags);
    Cv.Brush.Style := bsSolid;
  end;
end;

procedure TfrmDashboard.SetupBottomStats;

  procedure MakeBarRow(AIndex: Integer);
  var
    row, head, track, fill: TPanel;
    lName, lPct: TLabel;
  begin
    row := TPanel.Create(Self);
    row.Parent       := pnlBottom;
    row.Align        := alTop;
    row.AlignWithMargins := True;
    row.Margins.SetBounds(0, 0, 0, 14);
    row.Height       := 34;
    row.BevelOuter   := bvNone;
    row.StyleElements    := row.StyleElements - [seClient];
    row.ParentBackground := False;
    row.Color        := uTheme.CardSurface;

    head := TPanel.Create(Self);
    head.Parent      := row;
    head.Align       := alTop;
    head.Height      := 18;
    head.BevelOuter  := bvNone;
    head.StyleElements    := head.StyleElements - [seClient];
    head.ParentBackground := False;
    head.Color       := uTheme.CardSurface;

    lPct := TLabel.Create(Self);
    lPct.Parent      := head;
    lPct.Align       := alRight;
    lPct.Width       := 50;
    lPct.Caption     := '0%';
    lPct.Transparent := True;
    lPct.StyleElements := lPct.StyleElements - [seFont];
    lPct.Font.Name   := uTheme.FONT_NAME;
    lPct.Font.Size   := 9;
    lPct.Font.Style  := [fsBold];
    lPct.Font.Color  := uTheme.TEXT_MAIN;
    lPct.Layout      := tlCenter;
    lPct.Alignment   := taLeftJustify;   // RTL flip -> percentage hugs the right

    lName := TLabel.Create(Self);
    lName.Parent     := head;
    lName.Align      := alClient;
    lName.Caption    := UrgencyLabel(PRIORITY_URG[AIndex]);
    lName.Transparent := True;
    lName.StyleElements := lName.StyleElements - [seFont];
    lName.Font.Name  := uTheme.FONT_NAME;
    lName.Font.Size  := 9;
    lName.Font.Color := uTheme.TEXT_MAIN;
    lName.Layout     := tlCenter;
    lName.BiDiMode   := bdRightToLeft;
    lName.Alignment  := taRightJustify;  // RTL flip -> name hugs the left

    track := TPanel.Create(Self);
    track.Parent     := row;
    track.Align      := alTop;
    track.AlignWithMargins := True;
    track.Margins.SetBounds(0, 6, 0, 0);
    track.Height     := 8;
    track.BevelOuter := bvNone;
    track.StyleElements    := track.StyleElements - [seClient];
    track.ParentBackground := False;
    track.Color      := $00EBE7E5;        // light gray track

    fill := TPanel.Create(Self);
    fill.Parent      := track;
    fill.Align       := alLeft;
    fill.Width       := 0;
    fill.BevelOuter  := bvNone;
    fill.StyleElements    := fill.StyleElements - [seClient];
    fill.ParentBackground := False;
    fill.Color       := uTheme.UrgenceColor(PRIORITY_URG[AIndex]);

    FTrack[AIndex] := track;
    FFill[AIndex]  := fill;
    FPcts[AIndex]  := lPct;
  end;

var
  lblHdr, lblFoot: TLabel;
  I: Integer;
begin
  // The old two-column breakdown is replaced by a priority-distribution card
  pnlUrgStats.Visible  := False;
  pnlStatStats.Visible := False;

  pnlBottom.Align      := alLeft;
  pnlBottom.AlignWithMargins := True;
  pnlBottom.Margins.SetBounds(16, 8, 8, 12);
  pnlBottom.Width      := 340;
  pnlBottom.BevelOuter := bvNone;
  pnlBottom.StyleElements    := pnlBottom.StyleElements - [seClient];
  pnlBottom.ParentBackground := False;
  pnlBottom.Color      := uTheme.CardSurface;
  pnlBottom.Padding.SetBounds(18, 14, 18, 14);
  TCtrlCrack(pnlBottom).OnResize := BarsResize;

  lblHdr := TLabel.Create(Self);
  lblHdr.Parent      := pnlBottom;
  lblHdr.Align       := alTop;
  lblHdr.AlignWithMargins := True;
  lblHdr.Margins.SetBounds(0, 0, 0, 14);
  lblHdr.Height      := 22;
  lblHdr.Caption     := #1578#1608#1586#1610#1593' '#1575#1604#1576#1585#1602#1610#1575#1578' '#1581#1587#1576' '#1575#1604#1571#1608#1604#1608#1610#1577;
  lblHdr.Transparent := True;
  lblHdr.StyleElements := lblHdr.StyleElements - [seFont];
  lblHdr.Font.Name   := uTheme.FONT_NAME;
  lblHdr.Font.Size   := 11;
  lblHdr.Font.Style  := [fsBold];
  lblHdr.Font.Color  := uTheme.TEXT_MAIN;
  lblHdr.Layout      := tlCenter;
  lblHdr.BiDiMode    := bdRightToLeft;
  lblHdr.Alignment   := taLeftJustify;

  lblFoot := TLabel.Create(Self);
  lblFoot.Parent     := pnlBottom;
  lblFoot.Align      := alBottom;
  lblFoot.Height     := 18;
  lblFoot.Caption    := #1578#1605' '#1578#1581#1583#1610#1579' '#1575#1604#1573#1581#1589#1575#1574#1610#1575#1578' '#1575#1604#1570#1606;
  lblFoot.Transparent := True;
  lblFoot.StyleElements := lblFoot.StyleElements - [seFont];
  lblFoot.Font.Name  := uTheme.FONT_NAME;
  lblFoot.Font.Size  := 8;
  lblFoot.Font.Color := uTheme.MutedText;
  lblFoot.Layout     := tlCenter;
  lblFoot.BiDiMode   := bdRightToLeft;
  lblFoot.Alignment  := taLeftJustify;

  for I := 0 to 3 do
    MakeBarRow(I);
end;

procedure TfrmDashboard.BarsResize(Sender: TObject);
var
  I, tw: Integer;
begin
  for I := 0 to 3 do
    if Assigned(FFill[I]) and Assigned(FTrack[I]) then
    begin
      tw := FTrack[I].ClientWidth;
      if tw > 0 then
        FFill[I].Width := Round(FPctVal[I] / 100 * tw);
    end;
end;

procedure TfrmDashboard.RefreshStats;
var
  Counts: array[0..3] of Integer;
  Cnt:    array[0..3] of Integer;
  I, Row, Total: Integer;
  rq:     TDataSet;
begin
  Counts[0] := DM.GetCountToday(TYP_WARED);
  Counts[1] := DM.GetCountToday(TYP_SADER);
  Counts[2] := DM.GetCountPending;
  Counts[3] := DM.GetCountMonth('');

  for I := 0 to 3 do
    if Assigned(FValLbls[I]) then
      FValLbls[I].Caption := IntToStr(Counts[I]);

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

  // Priority-distribution bars
  Total := 0;
  for I := 0 to 3 do
  begin
    Cnt[I] := DM.GetCountByUrgency(PRIORITY_URG[I]);
    Inc(Total, Cnt[I]);
  end;
  for I := 0 to 3 do
  begin
    if Total > 0 then
      FPctVal[I] := Round(Cnt[I] / Total * 100)
    else
      FPctVal[I] := 0;
    if Assigned(FPcts[I]) then
      FPcts[I].Caption := IntToStr(FPctVal[I]) + '%';
  end;
  BarsResize(pnlBottom);
end;

end.
