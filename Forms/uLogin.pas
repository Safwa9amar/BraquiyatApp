unit uLogin;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes,
  Vcl.Forms, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Controls, Vcl.Graphics;
 
type
  TfrmLogin = class(TForm)
    pnlTitleBar:  TPanel;
    lblTitleText: TLabel;
    pnlWinBtns:   TPanel;
    lblBtnClose:  TLabel;
    lblBtnMax:    TLabel;
    lblBtnMin:    TLabel;
    pnlLoginBody: TPanel;
    pnlLogo:      TPanel;
    lblLogoIcon:  TLabel;
    lblAppTitle:  TLabel;
    lblAppSub:    TLabel;
    pnlSep:       TPanel;
    lblUser:      TLabel;
    edtUser:      TEdit;
    lblPass:      TLabel;
    edtPass:      TEdit;
    lblError:     TLabel;
    lblHint:      TLabel;
    btnLogin:     TButton;
    btnCancel:    TButton;
    lblUserIcon:  TLabel;
    lblPassIcon:  TLabel;
    pnlStatusBar: TPanel;
    lblVersion:   TLabel;
    lblLoginDate: TLabel;
    pnlInputCard: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure edtPassKeyPress(Sender: TObject; var Key: Char);
    procedure lblBtnCloseClick(Sender: TObject);
    procedure edtUserEnter(Sender: TObject);
    procedure edtUserExit(Sender: TObject);
    procedure edtPassEnter(Sender: TObject);
    procedure edtPassExit(Sender: TObject);
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.dfm}

uses 
  uDM, 
  uMain;

// Modern Color Scheme
const
  CLR_PRIMARY_DARK   = $003D5A80;  // Deep professional blue
  CLR_PRIMARY_LIGHT  = $00547BA0;  // Light professional blue
  CLR_ACCENT         = $0000A8FF;  // Vibrant accent blue
  CLR_ACCENT_LIGHT   = $0033CCFF;  // Light cyan accent
  CLR_BG_GRADIENT_1  = $00004A7C;  // Dark blue
  CLR_BG_GRADIENT_2  = $002A5F8D;  // Medium blue
  CLR_CARD           = $00FFFFFF;  // Pure white
  CLR_TEXT_DARK      = $00212121;  // Dark text
  CLR_TEXT_LIGHT     = $00757575;  // Light gray text
  CLR_BORDER         = $00E0E0E0;  // Light border
  CLR_ERROR          = $001A1AFF;  // Bright red
  CLR_SUCCESS        = $0000AA00;  // Green

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  // Form Setup - Modern Design
  Caption     := '';
  BorderStyle := bsNone;
  Position    := poScreenCenter;
  Width       := 420;
  Height      := 540;
  Color       := CLR_BG_GRADIENT_1;
  BiDiMode    := bdRightToLeft;
  KeyPreview  := True;

  // Title bar - Modern gradient effect
  pnlTitleBar.Color      := CLR_PRIMARY_DARK;
  pnlTitleBar.BevelOuter := bvNone;
  pnlTitleBar.Height     := 32;
  pnlTitleBar.Align      := alTop;
  lblTitleText.Font.Color  := clWhite;
  lblTitleText.Font.Style  := [fsBold];
  lblTitleText.Font.Size   := 11;
  lblTitleText.Font.Name   := 'Segoe UI';

  // Window buttons panel
  pnlWinBtns.Color      := CLR_PRIMARY_DARK;
  pnlWinBtns.BevelOuter := bvNone;
  pnlWinBtns.Align      := alLeft;
  pnlWinBtns.Width      := 70;
  lblBtnClose.Font.Color := clWhite;
  lblBtnMax.Font.Color   := clWhite;
  lblBtnMin.Font.Color   := clWhite;
  lblBtnClose.Cursor     := crHandPoint;

  // Login body with gradient background
  pnlLoginBody.Color      := CLR_BG_GRADIENT_1;
  pnlLoginBody.BevelOuter := bvNone;
  pnlLoginBody.Align      := alClient;

  // Logo area
  pnlLogo.Color      := CLR_BG_GRADIENT_1;
  pnlLogo.BevelOuter := bvNone;
  lblLogoIcon.Font.Color := clWhite;
  lblLogoIcon.Font.Size  := 32;

  // App Title - Modern Typography
  lblAppTitle.Font.Color  := clWhite;
  lblAppTitle.Font.Style  := [fsBold];
  lblAppTitle.Font.Size   := 18;
  lblAppTitle.Font.Name   := 'Segoe UI';

  // App Subtitle
  lblAppSub.Font.Color := $00B0D4FF;  // Light blue
  lblAppSub.Font.Size  := 11;
  lblAppSub.Font.Name  := 'Segoe UI';

  // Separator line - subtle
  pnlSep.Color      := CLR_ACCENT_LIGHT;
  pnlSep.BevelOuter := bvNone;

  // Input card panel (white card effect)
  if Assigned(pnlInputCard) then
  begin
    pnlInputCard.Color      := CLR_CARD;
    pnlInputCard.BevelOuter := bvNone;
  end;

  // Labels for inputs
  lblUser.Font.Color := CLR_TEXT_DARK;
  lblUser.Font.Size  := 10;
  lblUser.Font.Name  := 'Segoe UI';
  lblUser.Font.Style := [];

  lblPass.Font.Color := CLR_TEXT_DARK;
  lblPass.Font.Size  := 10;
  lblPass.Font.Name  := 'Segoe UI';
  lblPass.Font.Style := [];

  // Input fields - Modern styling
  edtUser.BorderStyle := bsNone;
  edtUser.Font.Name   := 'Segoe UI';
  edtUser.Font.Size   := 11;
  edtUser.Font.Color  := CLR_TEXT_DARK;
  edtUser.OnEnter     := edtUserEnter;
  edtUser.OnExit      := edtUserExit;

  edtPass.BorderStyle := bsNone;
  edtPass.PasswordChar := '●';
  edtPass.Font.Name   := 'Segoe UI';
  edtPass.Font.Size   := 11;
  edtPass.Font.Color  := CLR_TEXT_DARK;
  edtPass.OnEnter     := edtPassEnter;
  edtPass.OnExit      := edtPassExit;
  edtPass.OnKeyPress  := edtPassKeyPress;

  // Error label
  lblError.Font.Color := CLR_ERROR;
  lblError.Font.Size  := 10;
  lblError.Font.Name  := 'Segoe UI';
  lblError.Font.Style := [];
  lblError.Caption    := '';

  // Hint label
  lblHint.Font.Color := CLR_TEXT_LIGHT;
  lblHint.Font.Size  := 9;
  lblHint.Font.Name  := 'Segoe UI';
  lblHint.Font.Style := [fsItalic];

  // Login Button - Modern style
  btnLogin.Font.Color     := clWhite;
  btnLogin.Font.Size      := 11;
  btnLogin.Font.Name      := 'Segoe UI';
  btnLogin.Font.Style     := [fsBold];
  btnLogin.Height         := 40;
  btnLogin.Cursor         := crHandPoint;

  // Cancel Button - Secondary style
  btnCancel.Font.Color    := CLR_TEXT_DARK;
  btnCancel.Font.Size     := 10;
  btnCancel.Font.Name     := 'Segoe UI';
  btnCancel.Height        := 36;
  btnCancel.Cursor        := crHandPoint;

  // Status bar
  pnlStatusBar.Color      := CLR_PRIMARY_DARK;
  pnlStatusBar.BevelOuter := bvNone;
  pnlStatusBar.Height     := 26;
  pnlStatusBar.Align      := alBottom;

  lblVersion.Font.Color  := $00B0D4FF;
  lblVersion.Font.Size   := 8;
  lblVersion.Font.Name   := 'Segoe UI';
  lblLoginDate.Font.Color := $00B0D4FF;
  lblLoginDate.Font.Size  := 8;
  lblLoginDate.Font.Name  := 'Segoe UI';

  lblLoginDate.Caption := FormatDateTime('yyyy/mm/dd', Date);
end;

procedure TfrmLogin.btnLoginClick(Sender: TObject);
begin
  lblError.Caption := '';
  if Trim(edtUser.Text) = '' then
  begin
    lblError.Caption := '⚠ يرجى إدخال اسم المستخدم';
    edtUser.SetFocus;
    Exit;
  end;
  if Trim(edtPass.Text) = '' then
  begin
    lblError.Caption := '⚠ يرجى إدخال كلمة المرور';
    edtPass.SetFocus;
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
    lblError.Caption := '⚠ اسم المستخدم أو كلمة المرور غير صحيحة';
    lblHint.Caption  := '';
    edtPass.Clear;
    edtPass.SetFocus;
  end;
end;

procedure TfrmLogin.btnCancelClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmLogin.edtPassKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then btnLoginClick(Sender);
end;

procedure TfrmLogin.lblBtnCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

// Mouse hover effects for modern UI
procedure TfrmLogin.edtUserEnter(Sender: TObject);
begin
  // Edit received focus
  edtUser.Font.Style := [fsBold];
end;

procedure TfrmLogin.edtUserExit(Sender: TObject);
begin
  // Edit lost focus
  edtUser.Font.Style := [];
end;

procedure TfrmLogin.edtPassEnter(Sender: TObject);
begin
  // Password field received focus
  edtPass.Font.Style := [fsBold];
end;

procedure TfrmLogin.edtPassExit(Sender: TObject);
begin
  // Password field lost focus
  edtPass.Font.Style := [];
end;

end.