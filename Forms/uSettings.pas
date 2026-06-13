unit uSettings;

{
  Settings screen (الإعدادات): change password, switch the VCL style (theme),
  and verify the database connection. UI is built in code; only pnlMain is
  embedded into the main shell.
}

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Dialogs,
  Vcl.Graphics, Vcl.Themes;

type
  TfrmSettings = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    FEdtOld, FEdtNew, FEdtConfirm: TEdit;
    FCmbStyle: TComboBox;
    FLblDB:    TLabel;
    procedure btnChangePwdClick(Sender: TObject);
    procedure btnApplyStyleClick(Sender: TObject);
    procedure btnTestDBClick(Sender: TObject);
  public
    pnlMain: TPanel;
  end;

var
  frmSettings: TfrmSettings;

implementation

{$R *.dfm}

uses
  uDM, uConsts, uTheme;

procedure TfrmSettings.FormCreate(Sender: TObject);

  function MakeLabel(const ACap: string; ATop: Integer; ABold: Boolean): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent  := pnlMain;
    Result.Left    := 24;
    Result.Top     := ATop;
    Result.Caption := ACap;
    if ABold then
    begin
      Result.Font.Style := [fsBold];
      Result.Font.Size  := 11;
    end;
  end;

  function MakeEdit(ATop: Integer): TEdit;
  begin
    Result := TEdit.Create(Self);
    Result.Parent       := pnlMain;
    Result.Left         := 200;
    Result.Top          := ATop;
    Result.Width        := 220;
    Result.PasswordChar := '*';
  end;

  function MakeButton(const ACap: string; ALeft, ATop, AWidth: Integer;
                      AClick: TNotifyEvent): TButton;
  begin
    Result := TButton.Create(Self);
    Result.Parent  := pnlMain;
    Result.Caption := ACap;
    Result.Left    := ALeft;
    Result.Top     := ATop;
    Result.Width   := AWidth;
    Result.Height  := 30;
    Result.OnClick := AClick;
  end;

var
  I: Integer;
begin
  BiDiMode := bdRightToLeft;
  uTheme.StyleForm(Self);

  pnlMain := TPanel.Create(Self);
  pnlMain.Parent     := Self;
  pnlMain.Align      := alClient;
  pnlMain.BevelOuter := bvNone;

  // ── Change password ──
  MakeLabel('تغيير كلمة المرور', 20, True);
  MakeLabel('كلمة المرور الحالية:', 56, False);
  FEdtOld := MakeEdit(52);
  MakeLabel('كلمة المرور الجديدة:', 90, False);
  FEdtNew := MakeEdit(86);
  MakeLabel('تأكيد كلمة المرور:', 124, False);
  FEdtConfirm := MakeEdit(120);
  MakeButton('تغيير كلمة المرور', 200, 156, 180, btnChangePwdClick);

  // ── Appearance ──
  MakeLabel('المظهر', 210, True);
  MakeLabel('النمط:', 246, False);
  FCmbStyle := TComboBox.Create(Self);
  FCmbStyle.Parent := pnlMain;
  FCmbStyle.Left   := 200;
  FCmbStyle.Top    := 242;
  FCmbStyle.Width  := 240;
  FCmbStyle.Style  := csDropDownList;
  for I := 0 to High(TStyleManager.StyleNames) do
    FCmbStyle.Items.Add(TStyleManager.StyleNames[I]);
  FCmbStyle.ItemIndex := FCmbStyle.Items.IndexOf(TStyleManager.ActiveStyle.Name);
  MakeButton('تطبيق', 450, 240, 90, btnApplyStyleClick);

  // ── Database ──
  MakeLabel('قاعدة البيانات', 300, True);
  FLblDB := MakeLabel('', 336, False);
  FLblDB.Width   := 560;
  FLblDB.Caption := ExtractFilePath(ParamStr(0)) + 'Braquiyat.accdb';
  MakeButton('فحص الاتصال', 24, 366, 130, btnTestDBClick);
end;

procedure TfrmSettings.btnChangePwdClick(Sender: TObject);
begin
  if FEdtNew.Text = '' then
  begin
    ShowMessage('يرجى إدخال كلمة المرور الجديدة');
    Exit;
  end;
  if FEdtNew.Text <> FEdtConfirm.Text then
  begin
    ShowMessage('كلمتا المرور غير متطابقتين');
    Exit;
  end;
  try
    if DM.ChangePassword(DM.CurrentUser, FEdtOld.Text, FEdtNew.Text) then
    begin
      ShowMessage('تم تغيير كلمة المرور بنجاح');
      FEdtOld.Clear;
      FEdtNew.Clear;
      FEdtConfirm.Clear;
    end;
  except
    on E: Exception do ShowMessage(E.Message);
  end;
end;

procedure TfrmSettings.btnApplyStyleClick(Sender: TObject);
begin
  if FCmbStyle.ItemIndex >= 0 then
    uTheme.SetActiveStyle(FCmbStyle.Text);
end;

procedure TfrmSettings.btnTestDBClick(Sender: TObject);
var
  Missing: string;
begin
  if DM.CheckSchema(Missing) then
    ShowMessage('قاعدة البيانات سليمة والاتصال ناجح')
  else
    ShowMessage('عناصر ناقصة في قاعدة البيانات:' + sLineBreak + Missing);
end;

end.
