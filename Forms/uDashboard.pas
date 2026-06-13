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
    FValLbls:  array[0..3] of TLabel;
    FUrgBody:  TLabel;
    FStatBody: TLabel;
    procedure CreateStatCards;
    procedure SetupRecentGrid;
    procedure SetupBottomStats;
    procedure CardsResize(Sender: TObject);
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
  CLR_NAVY   = $0064381F;
  CLR_BORDER = $00848284;
  CLR_BG     = $00C8D0D4;

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
  pnlCards.Height     := 110;
  pnlCards.Align      := alTop;
  TCtrlCrack(pnlCards).OnResize := CardsResize;

  CreateStatCards;
  SetupRecentGrid;
  SetupBottomStats;
  RefreshStats;
end;

procedure TfrmDashboard.CreateStatCards;
  procedure MakeCard(AIndex: Integer; const ATitle: string; AColor: TColor);
  var
    pnl, strip:         TPanel;
    lTitle, lVal, lSub: TLabel;
  begin
    pnl              := TPanel.Create(Self);
    pnl.Parent       := pnlCards;
    pnl.BevelOuter   := bvNone;
    pnl.StyleElements    := pnl.StyleElements - [seClient];
    pnl.ParentBackground := False;
    pnl.Color        := uTheme.CardSurface;

    // Colour-coded accent strip across the top
    strip            := TPanel.Create(Self);
    strip.Parent     := pnl;
    strip.Align      := alTop;
    strip.Height     := 4;
    strip.BevelOuter := bvNone;
    strip.StyleElements    := strip.StyleElements - [seClient];
    strip.ParentBackground := False;
    strip.Color      := AColor;

    // Metric title — top band, right-aligned (RTL)
    lTitle           := TLabel.Create(Self);
    lTitle.Parent    := pnl;
    lTitle.Align     := alTop;
    lTitle.AlignWithMargins := True;
    lTitle.Margins.SetBounds(12, 10, 12, 0);
    lTitle.Caption   := ATitle;
    lTitle.Transparent := True;
    lTitle.StyleElements := lTitle.StyleElements - [seFont];
    lTitle.Font.Name := uTheme.FONT_NAME;
    lTitle.Font.Size := 9;
    lTitle.Font.Color := uTheme.MutedText;
    lTitle.Layout    := tlCenter;
    lTitle.BiDiMode  := bdRightToLeft;
    lTitle.Alignment := taLeftJustify;   // RTL flip -> visual right

    // Date / subtitle — bottom band, right-aligned
    lSub             := TLabel.Create(Self);
    lSub.Parent      := pnl;
    lSub.Align       := alBottom;
    lSub.AlignWithMargins := True;
    lSub.Margins.SetBounds(12, 0, 12, 8);
    lSub.Caption     := FormatDateTime('yyyy/mm/dd', Date);
    lSub.Transparent := True;
    lSub.StyleElements := lSub.StyleElements - [seFont];
    lSub.Font.Name   := uTheme.FONT_NAME;
    lSub.Font.Size   := 8;
    lSub.Font.Color  := uTheme.MutedText;
    lSub.Layout      := tlCenter;
    lSub.BiDiMode    := bdRightToLeft;
    lSub.Alignment   := taLeftJustify;

    // The number — fills the middle, centred on both axes
    lVal             := TLabel.Create(Self);
    lVal.Parent      := pnl;
    lVal.Align       := alClient;
    lVal.Caption     := '0';
    lVal.Transparent := True;
    lVal.StyleElements := lVal.StyleElements - [seFont];
    lVal.Font.Name   := uTheme.FONT_NAME;
    lVal.Font.Size   := 30;
    lVal.Font.Style  := [fsBold];
    lVal.Font.Color  := AColor;
    lVal.Alignment   := taCenter;
    lVal.Layout      := tlCenter;

    FCards[AIndex]   := pnl;
    FValLbls[AIndex] := lVal;
  end;
var
  Titles: array[0..3] of string;
  Colors: array[0..3] of TColor;
  I: Integer;
begin
  Titles[0] := #1575#1604#1576#1585#1602#1610#1575#1578' '#1575#1604#1608#1575#1585#1583#1577' '#1575#1604#1610#1608#1605;
  Titles[1] := #1575#1604#1576#1585#1602#1610#1575#1578' '#1575#1604#1589#1575#1583#1585#1577' '#1575#1604#1610#1608#1605;
  Titles[2] := #1602#1610#1583' '#1575#1604#1605#1593#1575#1604#1580#1577;
  Titles[3] := #1573#1580#1605#1575#1604#1610' '#1575#1604#1588#1607#1585;

  Colors[0] := uTheme.AccentHeader;
  Colors[1] := $00205715;  // green
  Colors[2] := $00025685;  // amber
  Colors[3] := $00495057;  // slate

  for I := 0 to 3 do
    MakeCard(I, Titles[I], Colors[I]);

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

  pnlRecentHdr.StyleElements    := pnlRecentHdr.StyleElements - [seClient];
  pnlRecentHdr.ParentBackground := False;
  pnlRecentHdr.Color      := uTheme.AccentHeader;
  pnlRecentHdr.BevelOuter := bvNone;
  pnlRecentHdr.Height     := 30;
  pnlRecentHdr.Align      := alTop;

  lblRecentHdr.Caption    := '   ' + #1570#1582#1585' '#1575#1604#1576#1585#1602#1610#1575#1578' '#1575#1604#1608#1575#1585#1583#1577;
  lblRecentHdr.StyleElements := lblRecentHdr.StyleElements - [seFont];
  lblRecentHdr.Transparent := True;
  lblRecentHdr.Font.Color := clWhite;
  lblRecentHdr.Font.Style := [fsBold];
  lblRecentHdr.Font.Name  := uTheme.FONT_NAME;
  lblRecentHdr.Font.Size  := 10;
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
      uTheme.RoundPanel(FCards[I], 12);
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
    Bg := uTheme.AccentHeader;
    Fg := clWhite;
  end
  else if gdSelected in State then
  begin
    Bg := uTheme.AccentHover;
    Fg := clWhite;
  end
  else
  begin
    if Dark then Fg := $00DDDDDD else Fg := $00333333;
    if Odd(ARow) then
      Bg := uTheme.CardSurface
    else if Dark then
      Bg := $00373330
    else
      Bg := $00F6F2EE;
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
