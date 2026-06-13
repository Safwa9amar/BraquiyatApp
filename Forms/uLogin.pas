unit uLogin;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes,
  Vcl.Forms, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Controls, Vcl.Graphics, Vcl.GraphUtil;

type
  TfrmLogin = class(TForm)
    pnlTitleBar:  TPanel;
    lblTitleText: TLabel;
    lblBtnClose:  TLabel;
    pnlStatusBar: TPanel;
    lblVersion:   TLabel;
    lblLoginDate: TLabel;
    pnlBody:      TPanel;
    pbxBg:        TPaintBox;
    pnlCard:      TPanel;
    pnlLogo:      TPanel;
    lblLogoIcon:  TLabel;
    lblAppTitle:  TLabel;
    lblAppSub:    TLabel;
    pnlDivider:   TPanel;
    lblUser:      TLabel;
    pnlUserField: TPanel;
    pnlUserLine:  TPanel;
    edtUser:      TEdit;
    lblPass:      TLabel;
    pnlPassField: TPanel;
    pnlPassLine:  TPanel;
    lblEye:       TLabel;
    edtPass:      TEdit;
    lblError:     TLabel;
    pnlLogin:     TPanel;
    lblLoginText: TLabel;
    lblExit:      TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure pbxBgPaint(Sender: TObject);
    procedure TitleBarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblBtnCloseClick(Sender: TObject);
    procedure lblExitClick(Sender: TObject);
    procedure LoginClick(Sender: TObject);
    procedure LoginMouseEnter(Sender: TObject);
    procedure LoginMouseLeave(Sender: TObject);
    procedure FieldEnter(Sender: TObject);
    procedure FieldExit(Sender: TObject);
    procedure lblEyeClick(Sender: TObject);
    procedure edtPassKeyPress(Sender: TObject; var Key: Char);
  private
    FShowPass:    Boolean;
    FRounded:     Boolean;
    FGradTop:     TColor;
    FGradBottom:  TColor;
    FLineIdle:    TColor;
    FLineActive:  TColor;
    procedure RoundControl(AControl: TWinControl; ARadius: Integer);
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.dfm}

uses
  uDM,
  uMain,
  uTheme;

procedure TfrmLogin.FormCreate(Sender: TObject);
var
  TextMain, FieldFill, Muted, Navy: TColor;
begin
  Caption     := '';
  BorderStyle := bsNone;
  Position    := poScreenCenter;
  ClientWidth  := 440;
  ClientHeight := 600;
  BiDiMode     := bdRightToLeft;
  KeyPreview  := True;

  FShowPass := False;

  // Pull the palette from the shared theme so the login screen matches the rest
  // of the app and follows the active VCL style (light / dark).
  Navy := uTheme.AccentHeader;
  if uTheme.IsDarkStyle then
  begin
    TextMain    := $00ECECEC;
    FieldFill   := $003A3633;
    FLineIdle   := $00555049;
    FGradTop    := uTheme.AccentHover;
    FGradBottom := uTheme.AccentActive;
  end
  else
  begin
    TextMain    := $00262626;
    FieldFill   := $00F5F5F5;
    FLineIdle   := $00DADADA;
    FGradTop    := uTheme.AccentHeader;
    FGradBottom := uTheme.AccentActive;
  end;
  Muted       := uTheme.MutedText;
  FLineActive := Navy;
  Color       := FGradBottom;

  // Title bar (accent band, survives the active style)
  pnlTitleBar.StyleElements    := pnlTitleBar.StyleElements - [seClient];
  pnlTitleBar.ParentBackground := False;
  pnlTitleBar.Color            := uTheme.AccentActive;
  lblTitleText.StyleElements   := lblTitleText.StyleElements - [seFont];
  lblTitleText.Transparent     := True;
  lblTitleText.Font.Color      := clWhite;
  lblBtnClose.StyleElements    := lblBtnClose.StyleElements - [seFont];
  lblBtnClose.Transparent      := True;
  lblBtnClose.Font.Color       := clWhite;

  // Body + gradient backdrop
  pnlBody.StyleElements    := pnlBody.StyleElements - [seClient];
  pnlBody.ParentBackground := False;
  pnlBody.Color            := FGradBottom;

  // Card surface
  pnlCard.StyleElements    := pnlCard.StyleElements - [seClient];
  pnlCard.ParentBackground := False;
  pnlCard.Color            := uTheme.CardSurface;

  // Logo badge
  pnlLogo.StyleElements    := pnlLogo.StyleElements - [seClient];
  pnlLogo.ParentBackground := False;
  pnlLogo.Color            := Navy;
  lblLogoIcon.StyleElements := lblLogoIcon.StyleElements - [seFont];
  lblLogoIcon.Transparent  := True;
  lblLogoIcon.Font.Color   := clWhite;

  // Titles
  lblAppTitle.StyleElements := lblAppTitle.StyleElements - [seFont];
  lblAppTitle.Transparent   := True;
  lblAppTitle.Font.Color    := TextMain;
  lblAppSub.StyleElements   := lblAppSub.StyleElements - [seFont];
  lblAppSub.Transparent     := True;
  lblAppSub.Font.Color      := Muted;

  // Divider
  pnlDivider.StyleElements    := pnlDivider.StyleElements - [seClient];
  pnlDivider.ParentBackground := False;
  pnlDivider.Color            := FLineIdle;

  // Field labels
  lblUser.StyleElements := lblUser.StyleElements - [seFont];
  lblUser.Transparent   := True;
  lblUser.Font.Color    := Muted;
  lblPass.StyleElements := lblPass.StyleElements - [seFont];
  lblPass.Transparent   := True;
  lblPass.Font.Color    := Muted;

  // Username field
  pnlUserField.StyleElements    := pnlUserField.StyleElements - [seClient];
  pnlUserField.ParentBackground := False;
  pnlUserField.Color            := FieldFill;
  pnlUserLine.StyleElements     := pnlUserLine.StyleElements - [seClient];
  pnlUserLine.ParentBackground  := False;
  pnlUserLine.Color             := FLineIdle;
  edtUser.StyleElements := edtUser.StyleElements - [seClient, seBorder];
  edtUser.Color         := FieldFill;
  edtUser.Font.Color    := TextMain;

  // Password field
  pnlPassField.StyleElements    := pnlPassField.StyleElements - [seClient];
  pnlPassField.ParentBackground := False;
  pnlPassField.Color            := FieldFill;
  pnlPassLine.StyleElements     := pnlPassLine.StyleElements - [seClient];
  pnlPassLine.ParentBackground  := False;
  pnlPassLine.Color             := FLineIdle;
  edtPass.StyleElements := edtPass.StyleElements - [seClient, seBorder];
  edtPass.Color         := FieldFill;
  edtPass.Font.Color    := TextMain;
  edtPass.PasswordChar  := #8226;
  lblEye.StyleElements  := lblEye.StyleElements - [seFont];
  lblEye.Transparent    := True;
  lblEye.Font.Color     := Muted;

  // Error
  lblError.StyleElements := lblError.StyleElements - [seFont];
  lblError.Transparent   := True;
  lblError.Font.Color    := $003618C9;   // red
  lblError.Caption       := '';

  // Primary button (custom navy CTA)
  pnlLogin.StyleElements    := pnlLogin.StyleElements - [seClient];
  pnlLogin.ParentBackground := False;
  pnlLogin.Color            := Navy;
  lblLoginText.StyleElements := lblLoginText.StyleElements - [seFont];
  lblLoginText.Transparent  := True;
  lblLoginText.Font.Color   := clWhite;

  // Exit link
  lblExit.StyleElements := lblExit.StyleElements - [seFont];
  lblExit.Transparent   := True;
  lblExit.Font.Color    := Muted;

  // Status bar
  pnlStatusBar.StyleElements    := pnlStatusBar.StyleElements - [seClient];
  pnlStatusBar.ParentBackground := False;
  pnlStatusBar.Color            := uTheme.AccentActive;
  lblVersion.StyleElements  := lblVersion.StyleElements - [seFont];
  lblVersion.Transparent    := True;
  lblVersion.Font.Color     := $00C8B8A8;
  lblLoginDate.StyleElements := lblLoginDate.StyleElements - [seFont];
  lblLoginDate.Transparent  := True;
  lblLoginDate.Font.Color   := $00C8B8A8;
  lblLoginDate.Caption      := FormatDateTime('yyyy/mm/dd', Date);
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  if not FRounded then
  begin
    RoundControl(Self,     16);
    RoundControl(pnlCard,  18);
    RoundControl(pnlLogo,  pnlLogo.Height);   // full radius -> circle
    RoundControl(pnlLogin, 12);
    FRounded := True;
  end;
  if edtUser.CanFocus then
    edtUser.SetFocus;
end;

procedure TfrmLogin.RoundControl(AControl: TWinControl; ARadius: Integer);
begin
  if AControl.HandleAllocated then
    SetWindowRgn(AControl.Handle,
      CreateRoundRectRgn(0, 0, AControl.Width + 1, AControl.Height + 1,
        ARadius, ARadius), True);
end;

procedure TfrmLogin.pbxBgPaint(Sender: TObject);
begin
  GradientFillCanvas(pbxBg.Canvas, FGradTop, FGradBottom,
    pbxBg.ClientRect, gdVertical);
end;

procedure TfrmLogin.TitleBarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  // Let the user drag the borderless window by its title bar.
  if Button = mbLeft then
  begin
    ReleaseCapture;
    SendMessage(Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0);
  end;
end;

procedure TfrmLogin.LoginClick(Sender: TObject);
begin
  lblError.Caption := '';

  if Trim(edtUser.Text) = '' then
  begin
    lblError.Caption := #9888' '#1610#1585#1580#1609' '#1573#1583#1582#1575#1604' '+
      #1575#1587#1605' '#1575#1604#1605#1587#1578#1582#1583#1605;          // يرجى إدخال اسم المستخدم
    if edtUser.CanFocus then edtUser.SetFocus;
    Exit;
  end;

  if Trim(edtPass.Text) = '' then
  begin
    lblError.Caption := #9888' '#1610#1585#1580#1609' '#1573#1583#1582#1575#1604' '+
      #1603#1604#1605#1577' '#1575#1604#1605#1585#1608#1585;               // يرجى إدخال كلمة المرور
    if edtPass.CanFocus then edtPass.SetFocus;
    Exit;
  end;

  if DM.Login(Trim(edtUser.Text), Trim(edtPass.Text)) then
  begin
    frmMain := TfrmMain.Create(Application);
    frmMain.Show;
    Self.Hide;
  end
  else
  begin
    lblError.Caption := #9888' '#1575#1587#1605' '#1575#1604#1605#1587#1578#1582#1583#1605' '+
      #1571#1608' '#1603#1604#1605#1577' '#1575#1604#1605#1585#1608#1585' '+
      #1594#1610#1585' '#1589#1581#1610#1581#1577;   // اسم المستخدم أو كلمة المرور غير صحيحة
    edtPass.Clear;
    if edtPass.CanFocus then edtPass.SetFocus;
  end;
end;

procedure TfrmLogin.LoginMouseEnter(Sender: TObject);
begin
  pnlLogin.Color := uTheme.AccentHover;
end;

procedure TfrmLogin.LoginMouseLeave(Sender: TObject);
begin
  pnlLogin.Color := uTheme.AccentHeader;
end;

procedure TfrmLogin.FieldEnter(Sender: TObject);
begin
  // Highlight the underline of the focused field with the accent color.
  if Sender = edtUser then
    pnlUserLine.Color := FLineActive
  else if Sender = edtPass then
    pnlPassLine.Color := FLineActive;
end;

procedure TfrmLogin.FieldExit(Sender: TObject);
begin
  if Sender = edtUser then
    pnlUserLine.Color := FLineIdle
  else if Sender = edtPass then
    pnlPassLine.Color := FLineIdle;
end;

procedure TfrmLogin.lblEyeClick(Sender: TObject);
begin
  FShowPass := not FShowPass;
  if FShowPass then
  begin
    edtPass.PasswordChar := #0;
    lblEye.Font.Color    := uTheme.AccentHeader;
  end
  else
  begin
    edtPass.PasswordChar := #8226;
    lblEye.Font.Color    := uTheme.MutedText;
  end;
  if edtPass.CanFocus then edtPass.SetFocus;
end;

procedure TfrmLogin.edtPassKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    LoginClick(Sender);
  end;
end;

procedure TfrmLogin.lblBtnCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmLogin.lblExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

end.
