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
  NAV: array[0..6] of TNavItem = (
    (Key: 'home';     Caption: #1575#1604#1585#1574#1610#1587#1610#1577;           Glyph: #$25A3' '),
    (Key: 'incoming'; Caption: #1575#1604#1576#1585#1602#1610#1575#1578' '#1575#1604#1608#1575#1585#1583#1577; Glyph: #$25BC' '),
    (Key: 'outgoing'; Caption: #1575#1604#1576#1585#1602#1610#1575#1578' '#1575#1604#1589#1575#1583#1585#1577; Glyph: #$25B2' '),
    (Key: 'routing';  Caption: #1575#1604#1578#1608#1580#1610#1607;              Glyph: #$21A9' '),
    (Key: 'archive';  Caption: #1575#1604#1571#1585#1588#1610#1601;              Glyph: #$25A6' '),
    (Key: 'reports';  Caption: #1575#1604#1578#1602#1575#1585#1610#1585;             Glyph: #$25A4' '),
    (Key: 'settings'; Caption: #1575#1604#1573#1593#1583#1575#1583#1575#1578;            Glyph: #$2699' ')
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
var
  I:    Integer;
  Item: TPanel;
  Lbl:  TLabel;
begin
  for I := 0 to 6 do
  begin
    Item              := TPanel.Create(Self);
    Item.Parent       := pnlSidebar;
    Item.Align        := alTop;
    Item.Height       := 36;
    Item.BevelOuter   := bvNone;
    Item.StyleElements    := Item.StyleElements - [seClient];
    Item.ParentBackground := False;
    Item.Color        := uTheme.AccentHeader;
    Item.Tag          := I;
    Item.Cursor       := crHandPoint;
    Item.OnClick      := SideItemClick;
    Item.OnMouseEnter := SideItemEnter;
    Item.OnMouseLeave := SideItemLeave;

    // Border bottom separator
    Item.BorderWidth := 0;

    Lbl              := TLabel.Create(Self);
    Lbl.Parent       := Item;
    Lbl.Caption      := NAV[I].Glyph + NAV[I].Caption;
    Lbl.StyleElements := Lbl.StyleElements - [seFont];
    Lbl.Transparent  := True;
    Lbl.Font.Color   := CLR_SIDE_TEXT;
    Lbl.Font.Name    := uTheme.FONT_NAME;
    Lbl.Font.Size    := 10;
    Lbl.Layout       := tlCenter;
    Lbl.Align        := alClient;
    Lbl.Alignment    := taRightJustify;
    Lbl.BiDiMode     := bdRightToLeft;
    Lbl.Tag          := I;
    Lbl.Cursor       := crHandPoint;
    Lbl.OnClick      := SideItemClick;
    Lbl.OnMouseEnter := SideItemEnter;
    Lbl.OnMouseLeave := SideItemLeave;

    // Draw bottom separator line (handled via Color only)

    FSideItems[I] := Item;
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
  Pnl: TPanel;
begin
  if Sender is TPanel then
    Pnl := TPanel(Sender)
  else if Sender is TLabel then
    Pnl := TPanel(TLabel(Sender).Parent)
  else Exit;

  if Pnl <> FActiveSideBtn then
  begin
    Pnl.Color := uTheme.AccentHover;
    TLabel(Pnl.Controls[0]).Font.Color := clWhite;
  end;
end;

procedure TfrmMain.SideItemLeave(Sender: TObject);
var
  Pnl: TPanel;
begin
  if Sender is TPanel then
    Pnl := TPanel(Sender)
  else if Sender is TLabel then
    Pnl := TPanel(TLabel(Sender).Parent)
  else Exit;

  if Pnl <> FActiveSideBtn then
  begin
    Pnl.Color := uTheme.AccentHeader;
    TLabel(Pnl.Controls[0]).Font.Color := CLR_SIDE_TEXT;
  end;
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
      FSideItems[I].Color := uTheme.AccentActive;
      TLabel(FSideItems[I].Controls[0]).Font.Color := clWhite;
      FActiveSideBtn := FSideItems[I];
      SetBreadcrumb(NAV[I].Caption);
    end
    else
    begin
      FSideItems[I].Color := uTheme.AccentHeader;
      TLabel(FSideItems[I].Controls[0]).Font.Color := CLR_SIDE_TEXT;
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
