unit uTheme;

{
  Single source of truth for the application's look & feel.

  Strategy: a VCL Style governs the overall appearance. We only override colors
  where an accent is intentional (header bands, active sidebar item, status
  badges) using the StyleElements - [seClient] pattern. Everything else inherits
  the active style, so the per-form CLR_* constant blocks are no longer needed.

  To actually embed a style the developer must enable it once in
  Project > Options > Application > Appearance (this regenerates the .res). If no
  style is embedded, TrySetStyle simply fails gracefully and the app runs on the
  OS theme.
}

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes, System.IniFiles, System.Types,
  Data.DB,
  Vcl.Graphics, Vcl.Controls, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.Forms, Vcl.Themes, Vcl.Styles;

const
  DEFAULT_STYLE = 'Windows11 Modern Light';
  DARK_STYLE    = 'Windows11 Modern Dark';

  FONT_NAME   = 'Segoe UI';   // renders Arabic well and matches the Win11 style
  FONT_BASE   = 10;
  FONT_HEADER = 13;
  FONT_TITLE  = 18;

  PAD_S = 6;
  PAD_M = 12;
  PAD_L = 20;
  CARD_H = 96;

  // Brand accent family — blue (TColor = $00BBGGRR)
  ACCENT_BLUE       = $00D84E1D;  // primary    #1D4ED8  RGB(29,78,216)
  ACCENT_BLUE_DARK  = $008A3A1E;  // pressed     #1E3A8A  RGB(30,58,138)
  ACCENT_LIGHT      = $00FEEADB;  // light pill  #DBEAFE  RGB(219,234,254)

  ACCENT_NAVY       = ACCENT_BLUE;       // legacy name -> primary accent
  ACCENT_NAVY_LIGHT = $00EB7E40;         // lighter blue for dark mode
  ACCENT_HOVER      = $00AF401E;         // hover       #1E40AF  RGB(30,64,175)
  ACCENT_ACTIVE     = ACCENT_BLUE_DARK;  // active

  // Light sidebar shell + neutrals
  SIDEBAR_BG    = $00FFFFFF;  // white sidebar
  SIDEBAR_DARK  = $00F7F4F1;  // subtle header tint
  SIDEBAR_HOVER = $00F9F5F1;  // slate-100 hover  #F1F5F9
  SIDEBAR_TEXT  = $00554133;  // slate-700 text   #334155
  PAGE_BG       = $00FAF8F7;  // near-white #F7F8FA
  TEXT_MAIN     = $0037291F;  // slate-800  #1F2937
  HAIRLINE      = $00EBE7E5;  // border     #E5E7EB
  CLR_OK_GREEN  = $0081B910;  // online dot #10B981

  // Status (ETAT) badge colors
  CLR_ST_RECEIVED  = $00B98029;  // blue   RGB(41,128,185)
  CLR_ST_PROCESS   = $00129CF3;  // amber  RGB(243,156,18)
  CLR_ST_ROUTED    = $0085A016;  // teal   RGB(22,160,133)
  CLR_ST_ARCHIVED  = $008D8C7F;  // gray   RGB(127,140,141)
  CLR_ST_DELETED   = $002B39C0;  // red    RGB(192,57,43)

  // Urgency badge colors
  CLR_URG_AJIL  = $003C4CE7;  // red    RGB(231,76,60)
  CLR_URG_ADI   = $0060AE27;  // green  RGB(39,174,96)
  CLR_URG_SIRRI = $00AD448E;  // purple RGB(142,68,173)
  CLR_URG_IDARI = $005E4934;  // slate  RGB(52,73,94)

// ── Style management ────────────────────────────────────────────
procedure ApplyStartupStyle;            // read <exe>.ini and activate
procedure SetActiveStyle(const AName: string);  // switch live + persist
function  IsDarkStyle: Boolean;

// ── Style-aware accent resolvers ────────────────────────────────
function AccentHeader: TColor;
function AccentHover: TColor;
function AccentActive: TColor;
function MutedText: TColor;
function CardSurface: TColor;
function BorderColor: TColor;

// ── Badge maps (codes from uConsts) ─────────────────────────────
function EtatColor(const AEtat: string): TColor;
function UrgenceColor(const AUrgence: string): TColor;

// ── Reusable styling helpers ────────────────────────────────────
procedure StyleAccentPanel(APanel: TPanel; ALabel: TLabel);
procedure StyleAsCard(APanel: TPanel);
procedure StyleGrid(AGrid: TDBGrid);
procedure StyleForm(AForm: TForm);
procedure RoundPanel(AControl: TWinControl; ARadius: Integer);  // rounded-corner region

// Telegram-grid helpers: Arabic titles, hidden TYPE_BRQ, badge cell drawing.
procedure SetupBraquiyaGrid(AGrid: TDBGrid);              // call after dataset is open
procedure DrawBadgeCell(AGrid: TDBGrid; const ARect: TRect; AColumn: TColumn);

implementation

uses
  uConsts;

function IniPath: string;
begin
  Result := ChangeFileExt(ParamStr(0), '.ini');
end;

procedure ApplyStartupStyle;
var
  Ini: TIniFile;
  StyleName: string;
begin
  Ini := TIniFile.Create(IniPath);
  try
    StyleName := Ini.ReadString('UI', 'Style', DEFAULT_STYLE);
  finally
    Ini.Free;
  end;
  if not TStyleManager.TrySetStyle(StyleName, False) then
    TStyleManager.TrySetStyle(DEFAULT_STYLE, False);
end;

procedure SetActiveStyle(const AName: string);
var
  Ini: TIniFile;
begin
  if TStyleManager.TrySetStyle(AName, False) then
  begin
    Ini := TIniFile.Create(IniPath);
    try
      Ini.WriteString('UI', 'Style', AName);
    finally
      Ini.Free;
    end;
  end;
end;

function IsDarkStyle: Boolean;
begin
  Result := SameText(TStyleManager.ActiveStyle.Name, DARK_STYLE);
end;

function AccentHeader: TColor;
begin
  if IsDarkStyle then
    Result := ACCENT_NAVY_LIGHT
  else
    Result := ACCENT_NAVY;
end;

function AccentHover: TColor;
begin
  Result := ACCENT_HOVER;
end;

function AccentActive: TColor;
begin
  Result := ACCENT_ACTIVE;
end;

function MutedText: TColor;
begin
  if IsDarkStyle then
    Result := $00A0A0A0
  else
    Result := $00808080;
end;

function CardSurface: TColor;
begin
  if IsDarkStyle then
    Result := $002E2A28
  else
    Result := clWhite;
end;

function BorderColor: TColor;
begin
  Result := StyleServices.GetSystemColor(clBtnShadow);
end;

function EtatColor(const AEtat: string): TColor;
begin
  if AEtat = ST_WAREDAH then Result := CLR_ST_RECEIVED
  else if AEtat = ST_SADERAH then Result := CLR_ST_RECEIVED
  else if AEtat = ST_MAWJAHA then Result := CLR_ST_ROUTED
  else if AEtat = ST_MOALAJA then Result := CLR_ST_PROCESS
  else if AEtat = ST_MORSAFA then Result := CLR_ST_ARCHIVED
  else if AEtat = ST_MAHDHUF then Result := CLR_ST_DELETED
  else Result := MutedText;
end;

function UrgenceColor(const AUrgence: string): TColor;
begin
  if AUrgence = URG_AJIL then Result := CLR_URG_AJIL
  else if AUrgence = URG_ADI then Result := CLR_URG_ADI
  else if AUrgence = URG_SIRRI then Result := CLR_URG_SIRRI
  else if AUrgence = URG_IDARI then Result := CLR_URG_IDARI
  else Result := MutedText;
end;

procedure StyleAccentPanel(APanel: TPanel; ALabel: TLabel);
begin
  APanel.StyleElements := APanel.StyleElements - [seClient];
  APanel.ParentBackground := False;
  APanel.BevelOuter := bvNone;
  APanel.BevelInner := bvNone;
  APanel.Color := AccentHeader;
  if Assigned(ALabel) then
  begin
    ALabel.StyleElements := ALabel.StyleElements - [seFont];
    ALabel.Transparent := True;
    ALabel.Font.Name := FONT_NAME;
    ALabel.Font.Color := clWhite;
    ALabel.Font.Style := [fsBold];
  end;
end;

procedure StyleAsCard(APanel: TPanel);
begin
  APanel.StyleElements := APanel.StyleElements - [seClient];
  APanel.ParentBackground := False;
  APanel.BevelOuter := bvNone;
  APanel.BevelInner := bvNone;
  APanel.Color := CardSurface;
end;

procedure StyleGrid(AGrid: TDBGrid);
begin
  AGrid.DrawingStyle := gdsThemed;
  AGrid.Font.Name := FONT_NAME;
  AGrid.Font.Size := 9;
  AGrid.TitleFont.Name := FONT_NAME;
  AGrid.TitleFont.Size := 9;
  AGrid.TitleFont.Style := [fsBold];
end;

procedure StyleForm(AForm: TForm);
begin
  AForm.Font.Name := FONT_NAME;
  AForm.Font.Size := FONT_BASE;
end;

// Clip a control to a rounded rectangle. Must be re-applied whenever the
// control resizes (the region is fixed to the current Width/Height).
procedure RoundPanel(AControl: TWinControl; ARadius: Integer);
begin
  if AControl.HandleAllocated then
    SetWindowRgn(AControl.Handle,
      CreateRoundRectRgn(0, 0, AControl.Width + 1, AControl.Height + 1,
        ARadius, ARadius), True);
end;

procedure SetupBraquiyaGrid(AGrid: TDBGrid);
var
  I: Integer;
begin
  StyleGrid(AGrid);
  if Assigned(AGrid.DataSource) and Assigned(AGrid.DataSource.DataSet) and
     AGrid.DataSource.DataSet.Active then
  begin
    AGrid.Columns.RebuildColumns;
    for I := 0 to AGrid.Columns.Count - 1 do
      if Assigned(AGrid.Columns[I].Field) then
      begin
        AGrid.Columns[I].Title.Caption :=
          HeaderLabel(AGrid.Columns[I].Field.FieldName);
        if SameText(AGrid.Columns[I].FieldName, 'TYPE_BRQ') then
          AGrid.Columns[I].Visible := False
        else if SameText(AGrid.Columns[I].FieldName, 'OBJET') then
          AGrid.Columns[I].Width := 240;
      end;
  end;
end;

procedure DrawBadgeCell(AGrid: TDBGrid; const ARect: TRect; AColumn: TColumn);
var
  Fn, Txt: string;
  Clr:     TColor;
  Cv:      TCanvas;
  cx, cy:  Integer;
begin
  if not Assigned(AColumn.Field) then
    Exit;
  Fn := UpperCase(AColumn.Field.FieldName);

  if Fn = 'URGENCE' then
  begin
    Txt := UrgencyLabel(AColumn.Field.AsString);
    Clr := UrgenceColor(AColumn.Field.AsString);
  end
  else if Fn = 'ETAT' then
  begin
    Txt := StateLabel(AColumn.Field.AsString);
    Clr := EtatColor(AColumn.Field.AsString);
  end
  else
    Exit;  // not a badge column — leave default drawing untouched

  Cv := AGrid.Canvas;
  cx := (ARect.Left + ARect.Right) div 2;
  cy := (ARect.Top  + ARect.Bottom) div 2;

  // Text only — coloured label, no chip / no dot.
  Cv.Brush.Style := bsSolid;
  Cv.FillRect(ARect);                 // erase the default cell text, keep row bg
  Cv.Brush.Style := bsClear;
  Cv.Font.Name   := FONT_NAME;
  Cv.Font.Size   := 9;
  Cv.Font.Style  := [fsBold];
  Cv.Font.Color  := Clr;
  SetTextAlign(Cv.Handle, TA_CENTER or TA_TOP);
  Cv.TextOut(cx, cy - Cv.TextHeight(Txt) div 2, Txt);
  SetTextAlign(Cv.Handle, TA_LEFT or TA_TOP);
  Cv.Brush.Style := bsSolid;
end;

end.
