unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.UITypes,
  Vcl.Forms, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Controls, Vcl.Graphics, Vcl.Dialogs;

const
  CLR_BG          = $00C8D0D4;
  CLR_PANEL       = $00D8E9EC;
  CLR_NAVY        = $0064381F;
  CLR_DARK_NAVY   = $00522D16;
  CLR_SIDEBAR_HOV = $00824D2A;
  CLR_SIDEBAR_ACT = $00473416;
  CLR_BORDER      = $00848284;
  CLR_CONTENT     = $00E4EDF0;
  CLR_SIDE_TEXT   = $00E4CCB8;
  CLR_ACCENT      = $00D8A36F;

type
  TNavItem = record
    Key:     string;
    Caption: string;
    Glyph:   string;
  end;

  TfrmMain = class(TForm)
    // App header
    pnlAppHeader:  TPanel;
    lblAppTitle:   TLabel;
    pnlUserInfo:   TPanel;
    lblHeaderUser: TLabel;
    lblHeaderDate: TLabel;
    btnLogout:     TButton;
    // Status bar
    pnlStatusBar:  TPanel;
    lblStatusUser: TLabel;
    lblStatusDate: TLabel;
    lblStatusTime: TLabel;
    lblStatusVer:  TLabel;
    // Body
    pnlBody:       TPanel;
    pnlSidebar:    TPanel;
    pnlSideHeader: TPanel;
    lblSideTitle:  TLabel;
    pnlSideStatus: TPanel;
    lblDBStatus:   TLabel;
    lblNetStatus:  TLabel;
    pnlMainArea:   TPanel;
    pnlBreadcrumb: TPanel;
    lblBreadcrumb: TLabel;
    pnlContent:    TPanel;
    // Clock
    tmrClock:      TTimer;
    procedure FormCreate(Sender: TObject);
    procedure tmrClockTimer(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
  private
    FActiveKey:    string;
    FActiveSideBtn: TPanel;
    FSideItems:    array[0..6] of TPanel;
    FSideBar:      array[0..6] of TPanel;   // active-state accent strip per row
    FSideIcon:     array[0..6] of TLabel;   // icon-font glyph per row
    FSideText:     array[0..6] of TLabel;   // Arabic caption per row
    procedure SetupColors;
    procedure SetupSidebar;
    procedure NavigateTo(const AKey: string);
    procedure SideItemClick(Sender: TObject);
    procedure SideItemEnter(Sender: TObject);
    procedure SideItemLeave(Sender: TObject);
    procedure UpdateClock;
    procedure SetBreadcrumb(const ALabel: string);
  public
    procedure ShowSubPanel(APanel: TPanel);
    procedure SetStatus(const AMsg: string);
  end;

var
  frmMain: TfrmMain;

const
  // Glyphs are Segoe MDL2 Assets codepoints (rendered with that icon font in
  // SetupSidebar); see CLR_SIDE_TEXT / the icon column there.
  NAV: array[0..6] of TNavItem = (
    (Key: 'home';     Caption: #1575#1604#1585#1574#1610#1587#1610#1577;           Glyph: #$E80F),  // Home
    (Key: 'incoming'; Caption: #1575#1604#1576#1585#1602#1610#1575#1578' '#1575#1604#1608#1575#1585#1583#1577; Glyph: #$E896),  // Download / inbox
    (Key: 'outgoing'; Caption: #1575#1604#1576#1585#1602#1610#1575#1578' '#1575#1604#1589#1575#1583#1585#1577; Glyph: #$E898),  // Upload / outbox
    (Key: 'routing';  Caption: #1575#1604#1578#1608#1580#1610#1607;              Glyph: #$E724),  // Send
    (Key: 'archive';  Caption: #1575#1604#1571#1585#1588#1610#1601;              Glyph: #$E7B8),  // Archive
    (Key: 'reports';  Caption: #1575#1604#1578#1602#1575#1585#1610#1585;             Glyph: #$E8A5),  // Document
    (Key: 'settings'; Caption: #1575#1604#1573#1593#1583#1575#1583#1575#1578;            Glyph: #$E713)   // Settings
  );

implementation

{$R *.dfm}

uses
  uDM,
  uDashboard,
  uWared,
  uSader,
  uArchive,
  uReports,
  uRouting,
  uSettings,
  uConsts,
  uTheme,
  uLogin;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Caption     := #1606#1592#1575#1605' '#1578#1587#1610#1610#1585' '#1575#1604#1576#1585#1602#1610#1575#1578' - '#1583#1575#1574#1585#1577' '#1576#1608#1593#1604#1575#1605;
  WindowState := wsMaximized;
  BiDiMode    := bdRightToLeft;
  Color       := CLR_BG;
  uTheme.StyleForm(Self);

  SetupColors;
  SetupSidebar;

  // Update header with logged-in user (name, falling back to role)
  if DM.CurrentName <> '' then
    lblHeaderUser.Caption := #1605#1585#1581#1576#1575#1611': ' + DM.CurrentName
  else
    lblHeaderUser.Caption := #1605#1585#1581#1576#1575#1611': ' + DM.CurrentRole;
  lblHeaderDate.Caption := FormatDateTime('dd/mm/yyyy', Date);

  // Start clock
  tmrClock.Interval := 1000;
  tmrClock.Enabled  := True;
  UpdateClock;

  // Open dashboard
  NavigateTo('home');
end;

procedure TfrmMain.SetupColors;

  procedure Accent(P: TPanel; AColor: TColor);
  begin
    P.StyleElements    := P.StyleElements - [seClient];
    P.ParentBackground := False;
    P.BevelOuter       := bvNone;
    P.Color            := AColor;
  end;

  procedure TextLbl(L: TLabel; AColor: TColor; ASize: Integer);
  begin
    L.StyleElements := L.StyleElements - [seFont];
    L.Transparent   := True;
    L.Font.Color    := AColor;
    if ASize > 0 then L.Font.Size := ASize;
  end;

begin
  // App header — accent band (survives the active VCL style)
  Accent(pnlAppHeader, uTheme.AccentHeader);
  Accent(pnlUserInfo,  uTheme.AccentHeader);
  TextLbl(lblAppTitle,   clWhite, 13);
  lblAppTitle.Font.Style := [fsBold];
  TextLbl(lblHeaderUser, clWhite, 0);
  TextLbl(lblHeaderDate, CLR_SIDE_TEXT, 9);

  // Sidebar — accent column
  Accent(pnlSidebar,    uTheme.AccentHeader);
  Accent(pnlSideHeader, uTheme.AccentActive);
  Accent(pnlSideStatus, uTheme.AccentHeader);
  TextLbl(lblSideTitle, CLR_SIDE_TEXT, 9);
  TextLbl(lblDBStatus,  CLR_SIDE_TEXT, 0);
  TextLbl(lblNetStatus, CLR_SIDE_TEXT, 0);

  // Breadcrumb / content / status bar are left to the active style.
end;

procedure TfrmMain.SetupSidebar;
const
  ICON_FONT = 'Segoe MDL2 Assets';  // crisp monoline glyphs, ships with Win10+
  ROW_H     = 42;
  ICON_W    = 38;
  BAR_W     = 3;
var
  I:              Integer;
  Item, Bar:      TPanel;
  IcoLbl, TxtLbl: TLabel;
begin
  for I := 0 to 6 do
  begin
    // ── Row container ─────────────────────────────────────────────
    Item              := TPanel.Create(Self);
    Item.Parent       := pnlSidebar;
    Item.Align        := alTop;
    Item.AlignWithMargins := True;
    Item.Margins.SetBounds(6, 3, 6, 0);   // side insets + gap above each row
    Item.Height       := ROW_H;
    Item.BevelOuter   := bvNone;
    Item.StyleElements    := Item.StyleElements - [seClient];
    Item.ParentBackground := False;
    Item.Color        := uTheme.AccentHeader;
    Item.Tag          := I;
    Item.Cursor       := crHandPoint;
    Item.OnClick      := SideItemClick;
    Item.OnMouseEnter := SideItemEnter;
    Item.OnMouseLeave := SideItemLeave;

    // ── Active accent bar (RTL leading edge = right); blends in until active ─
    Bar               := TPanel.Create(Self);
    Bar.Parent        := Item;
    Bar.Align         := alRight;
    Bar.Width         := BAR_W;
    Bar.BevelOuter    := bvNone;
    Bar.StyleElements := Bar.StyleElements - [seClient];
    Bar.ParentBackground := False;
    Bar.Color         := uTheme.AccentHeader;
    Bar.Tag           := I;
    Bar.Cursor        := crHandPoint;
    Bar.OnClick       := SideItemClick;
    Bar.OnMouseEnter  := SideItemEnter;
    Bar.OnMouseLeave  := SideItemLeave;

    // ── Icon column ───────────────────────────────────────────────
    IcoLbl            := TLabel.Create(Self);
    IcoLbl.Parent     := Item;
    IcoLbl.Align      := alRight;
    IcoLbl.Width      := ICON_W;
    IcoLbl.Caption    := NAV[I].Glyph;
    IcoLbl.StyleElements := IcoLbl.StyleElements - [seFont];
    IcoLbl.Transparent := True;
    IcoLbl.Font.Name  := ICON_FONT;
    IcoLbl.Font.Size  := 13;
    IcoLbl.Font.Color := CLR_SIDE_TEXT;
    IcoLbl.Alignment  := taCenter;
    IcoLbl.Layout     := tlCenter;
    IcoLbl.Tag        := I;
    IcoLbl.Cursor     := crHandPoint;
    IcoLbl.OnClick    := SideItemClick;
    IcoLbl.OnMouseEnter := SideItemEnter;
    IcoLbl.OnMouseLeave := SideItemLeave;

    // ── Caption (fills the rest, right-justified with padding) ────
    TxtLbl            := TLabel.Create(Self);
    TxtLbl.Parent     := Item;
    TxtLbl.Align      := alClient;
    TxtLbl.AlignWithMargins := True;
    TxtLbl.Margins.SetBounds(10, 0, 10, 0);
    TxtLbl.Caption    := NAV[I].Caption;
    TxtLbl.StyleElements := TxtLbl.StyleElements - [seFont];
    TxtLbl.Transparent := True;
    TxtLbl.Font.Name  := uTheme.FONT_NAME;
    TxtLbl.Font.Size  := 11;
    TxtLbl.Font.Color := CLR_SIDE_TEXT;
    TxtLbl.Alignment  := taRightJustify;
    TxtLbl.Layout     := tlCenter;
    TxtLbl.BiDiMode   := bdRightToLeft;
    TxtLbl.Tag        := I;
    TxtLbl.Cursor     := crHandPoint;
    TxtLbl.OnClick    := SideItemClick;
    TxtLbl.OnMouseEnter := SideItemEnter;
    TxtLbl.OnMouseLeave := SideItemLeave;

    FSideItems[I] := Item;
    FSideBar[I]   := Bar;
    FSideIcon[I]  := IcoLbl;
    FSideText[I]  := TxtLbl;
  end;
end;

procedure TfrmMain.SideItemClick(Sender: TObject);
var
  Idx: Integer;
begin
  if Sender is TPanel then
    Idx := TPanel(Sender).Tag
  else if Sender is TLabel then
    Idx := TLabel(Sender).Tag
  else Exit;

  NavigateTo(NAV[Idx].Key);
end;

procedure TfrmMain.SideItemEnter(Sender: TObject);
var
  Idx: Integer;
begin
  if not (Sender is TControl) then Exit;
  Idx := TControl(Sender).Tag;
  if (Idx < 0) or (Idx > 6) or (FSideItems[Idx] = FActiveSideBtn) then Exit;

  FSideItems[Idx].Color     := uTheme.AccentHover;
  FSideBar[Idx].Color       := uTheme.AccentHover;
  FSideIcon[Idx].Font.Color := clWhite;
  FSideText[Idx].Font.Color := clWhite;
end;

procedure TfrmMain.SideItemLeave(Sender: TObject);
var
  Idx: Integer;
begin
  if not (Sender is TControl) then Exit;
  Idx := TControl(Sender).Tag;
  if (Idx < 0) or (Idx > 6) or (FSideItems[Idx] = FActiveSideBtn) then Exit;

  FSideItems[Idx].Color     := uTheme.AccentHeader;
  FSideBar[Idx].Color       := uTheme.AccentHeader;
  FSideIcon[Idx].Font.Color := CLR_SIDE_TEXT;
  FSideText[Idx].Font.Color := CLR_SIDE_TEXT;
end;

procedure TfrmMain.NavigateTo(const AKey: string);
var
  I: Integer;
begin
  FActiveKey := AKey;

  // Update sidebar active state
  for I := 0 to 6 do
  begin
    if NAV[I].Key = AKey then
    begin
      FSideItems[I].Color     := uTheme.AccentActive;
      FSideBar[I].Color       := CLR_ACCENT;        // gold accent strip
      FSideIcon[I].Font.Color := clWhite;
      FSideText[I].Font.Color := clWhite;
      FSideText[I].Font.Style := [fsBold];
      FActiveSideBtn := FSideItems[I];
      SetBreadcrumb(NAV[I].Caption);
    end
    else
    begin
      FSideItems[I].Color     := uTheme.AccentHeader;
      FSideBar[I].Color       := uTheme.AccentHeader;
      FSideIcon[I].Font.Color := CLR_SIDE_TEXT;
      FSideText[I].Font.Color := CLR_SIDE_TEXT;
      FSideText[I].Font.Style := [];
    end;
  end;

  // Show corresponding content
  if AKey = 'home' then
  begin
    if not Assigned(frmDashboard) then
      frmDashboard := TfrmDashboard.Create(Self);
    frmDashboard.RefreshStats;
    ShowSubPanel(frmDashboard.pnlMain);
  end
  else if AKey = 'incoming' then
  begin
    if not Assigned(frmWared) then
      frmWared := TfrmWared.Create(Self);
    frmWared.LoadData;
    ShowSubPanel(frmWared.pnlMain);
  end
  else if AKey = 'outgoing' then
  begin
    if not Assigned(frmSader) then
      frmSader := TfrmSader.Create(Self);
    frmSader.LoadData;
    ShowSubPanel(frmSader.pnlMain);
  end
  else if AKey = 'archive' then
  begin
    if not Assigned(frmArchive) then
      frmArchive := TfrmArchive.Create(Self);
    ShowSubPanel(frmArchive.pnlMain);
  end
  else if AKey = 'reports' then
  begin
    if not Assigned(frmReports) then
      frmReports := TfrmReports.Create(Self);
    ShowSubPanel(frmReports.pnlMain);
  end
  else if AKey = 'routing' then
  begin
    if not Assigned(frmRouting) then
      frmRouting := TfrmRouting.Create(Self);
    frmRouting.LoadData;
    ShowSubPanel(frmRouting.pnlMain);
  end
  else if AKey = 'settings' then
  begin
    if not Assigned(frmSettings) then
      frmSettings := TfrmSettings.Create(Self);
    ShowSubPanel(frmSettings.pnlMain);
  end;

  SetStatus(#1605#1587#1578#1582#1583#1605': ' + DM.CurrentRole +
            '   |   ' + FormatDateTime('dd/mm/yyyy hh:nn', Now));
end;

procedure TfrmMain.ShowSubPanel(APanel: TPanel);
var
  I: Integer;
begin
  // Hide all existing children of pnlContent
  for I := pnlContent.ControlCount - 1 downto 0 do
    pnlContent.Controls[I].Visible := False;

  // Embed and show the new panel
  APanel.Parent  := pnlContent;
  APanel.Align   := alClient;
  APanel.Visible := True;
  APanel.BringToFront;
end;

procedure TfrmMain.SetBreadcrumb(const ALabel: string);
begin
  lblBreadcrumb.Caption :=
    '  ' + #1575#1604#1585#1574#1610#1587#1610#1577 + '  ' + #$203A + '  ' + ALabel;
end;

procedure TfrmMain.SetStatus(const AMsg: string);
begin
  lblStatusUser.Caption := ' ' + #1605#1587#1578#1582#1583#1605': ' + DM.CurrentRole + ' ';
  lblStatusDate.Caption := ' ' + FormatDateTime('dd/mm/yyyy', Date) + ' ';
end;

procedure TfrmMain.UpdateClock;
var
  T: string;
begin
  T := FormatDateTime('hh:nn:ss', Now);
  lblStatusTime.Caption  := ' ' + T + ' ';
  lblHeaderDate.Caption  :=
    FormatDateTime('dddd dd/mm/yyyy', Date) + '   ';
end;

procedure TfrmMain.tmrClockTimer(Sender: TObject);
begin
  UpdateClock;
end;

procedure TfrmMain.btnLogoutClick(Sender: TObject);
begin
  if MessageDlg(#1607#1604' '#1578#1585#1610#1583' '#1578#1587#1580#1610#1604' '#1575#1604#1582#1585#1608#1580'؟',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    frmLogin.edtUser.Clear;
    frmLogin.edtPass.Clear;
    frmLogin.Show;

    // Clear content-form globals (they are owned by this form and freed with
    // it by Release) so the next login recreates them instead of touching
    // dangling pointers.
    frmDashboard := nil;
    frmWared     := nil;
    frmSader     := nil;
    frmArchive   := nil;
    frmReports   := nil;
    frmRouting   := nil;
    frmSettings  := nil;
    frmMain      := nil;
    Release;   // safe self-free after this event returns
  end;
end;

end.
