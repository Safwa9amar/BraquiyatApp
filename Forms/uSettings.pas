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
    FSecCards: array[0..2] of TPanel;   // section cards (for rounded corners)
    FSecCount: Integer;
    procedure btnChangePwdClick(Sender: TObject);
    procedure btnApplyStyleClick(Sender: TObject);
    procedure btnTestDBClick(Sender: TObject);
    procedure PnlMainResize(Sender: TObject);
    procedure BtnEnter(Sender: TObject);
    procedure BtnLeave(Sender: TObject);
  public
    pnlMain: TPanel;
  end;

var
  frmSettings: TfrmSettings;

implementation

{$R *.dfm}

uses
  uDM, uConsts, uTheme;

type
  TCtrlCrack = class(TControl);   // exposes the protected OnResize event

procedure TfrmSettings.FormCreate(Sender: TObject);
var
  Navy, FieldFill, CardBg, PageBg, Muted, TextMain: TColor;
  body, row: TPanel;
  I: Integer;

  procedure StyleField(E: TEdit);
  begin
    E.StyleElements := E.StyleElements - [seClient, seBorder];
    E.AutoSize    := False;
    E.BorderStyle := bsNone;
    E.Color       := FieldFill;
    E.Font.Name   := uTheme.FONT_NAME;
    E.Font.Size   := 10;
    E.Font.Color  := TextMain;
    E.BiDiMode    := bdRightToLeft;
  end;

  // A white card with a navy header band; returns the padded body panel.
  function MakeSection(const ATitle: string; AHeight: Integer): TPanel;
  var
    card, hdr, body: TPanel;
    lbl: TLabel;
  begin
    card := TPanel.Create(Self);
    card.Parent      := pnlMain;
    card.Align       := alTop;
    card.AlignWithMargins := True;
    card.Margins.SetBounds(0, 0, 0, 16);
    card.Height      := AHeight;
    card.BevelOuter  := bvNone;
    card.StyleElements    := card.StyleElements - [seClient];
    card.ParentBackground := False;
    card.Color       := CardBg;

    hdr := TPanel.Create(Self);
    hdr.Parent       := card;
    hdr.Align        := alTop;
    hdr.Height       := 36;
    hdr.BevelOuter   := bvNone;
    hdr.StyleElements    := hdr.StyleElements - [seClient];
    hdr.ParentBackground := False;
    hdr.Color        := Navy;

    lbl := TLabel.Create(Self);
    lbl.Parent       := hdr;
    lbl.Align        := alClient;
    lbl.AlignWithMargins := True;
    lbl.Margins.SetBounds(16, 0, 16, 0);
    lbl.Caption      := ATitle;
    lbl.Transparent  := True;
    lbl.StyleElements := lbl.StyleElements - [seFont];
    lbl.Font.Name    := uTheme.FONT_NAME;
    lbl.Font.Size    := 11;
    lbl.Font.Style   := [fsBold];
    lbl.Font.Color   := clWhite;
    lbl.Layout       := tlCenter;
    lbl.BiDiMode     := bdRightToLeft;
    lbl.Alignment    := taLeftJustify;   // RTL flip -> visual right

    body := TPanel.Create(Self);
    body.Parent      := card;
    body.Align       := alClient;
    body.BevelOuter  := bvNone;
    body.StyleElements    := body.StyleElements - [seClient];
    body.ParentBackground := False;
    body.Color       := CardBg;
    body.Padding.SetBounds(20, 16, 20, 16);

    if FSecCount <= High(FSecCards) then
      FSecCards[FSecCount] := card;
    Inc(FSecCount);
    Result := body;
  end;

  // A label-on-the-right / input-fills-the-rest row; returns the row panel.
  function AttachRow(ABody: TWinControl; const ALabel: string;
                     AInput: TControl): TPanel;
  var
    row: TPanel;
    lbl: TLabel;
  begin
    row := TPanel.Create(Self);
    row.Parent       := ABody;
    row.Align        := alTop;
    row.AlignWithMargins := True;
    row.Margins.SetBounds(0, 0, 0, 12);
    row.Height       := 32;
    row.BevelOuter   := bvNone;
    row.StyleElements    := row.StyleElements - [seClient];
    row.ParentBackground := False;
    row.Color        := CardBg;

    lbl := TLabel.Create(Self);
    lbl.Parent       := row;
    lbl.Align        := alRight;
    lbl.Width        := 170;
    lbl.Caption      := ALabel;
    lbl.Transparent  := True;
    lbl.StyleElements := lbl.StyleElements - [seFont];
    lbl.Font.Name    := uTheme.FONT_NAME;
    lbl.Font.Size    := 10;
    lbl.Font.Color   := Muted;
    lbl.Layout       := tlCenter;
    lbl.BiDiMode     := bdRightToLeft;
    lbl.Alignment    := taLeftJustify;

    AInput.Parent    := row;
    AInput.Align     := alClient;
    AInput.AlignWithMargins := True;
    AInput.Margins.SetBounds(10, 2, 6, 2);

    Result := row;
  end;

  // Custom navy CTA (panel + label) matching the login button.
  procedure MakePrimaryButton(AParent: TWinControl; const ACap: string;
                              AWidth: Integer; AAlign: TAlign; AClick: TNotifyEvent);
  var
    btn: TPanel;
    lbl: TLabel;
  begin
    btn := TPanel.Create(Self);
    btn.Parent       := AParent;
    btn.Align        := AAlign;
    btn.AlignWithMargins := True;
    btn.Margins.SetBounds(6, 4, 6, 4);
    btn.Width        := AWidth;
    btn.BevelOuter   := bvNone;
    btn.StyleElements    := btn.StyleElements - [seClient];
    btn.ParentBackground := False;
    btn.Color        := Navy;
    btn.Cursor       := crHandPoint;
    btn.OnClick      := AClick;
    btn.OnMouseEnter := BtnEnter;
    btn.OnMouseLeave := BtnLeave;

    lbl := TLabel.Create(Self);
    lbl.Parent       := btn;
    lbl.Align        := alClient;
    lbl.Caption      := ACap;
    lbl.Transparent  := True;
    lbl.StyleElements := lbl.StyleElements - [seFont];
    lbl.Font.Name    := uTheme.FONT_NAME;
    lbl.Font.Size    := 10;
    lbl.Font.Style   := [fsBold];
    lbl.Font.Color   := clWhite;
    lbl.Alignment    := taCenter;
    lbl.Layout       := tlCenter;
    lbl.Cursor       := crHandPoint;
    lbl.OnClick      := AClick;
    lbl.OnMouseEnter := BtnEnter;
    lbl.OnMouseLeave := BtnLeave;
  end;

  function ButtonRow(ABody: TWinControl): TPanel;
  begin
    Result := TPanel.Create(Self);
    Result.Parent    := ABody;
    Result.Align     := alTop;
    Result.AlignWithMargins := True;
    Result.Margins.SetBounds(0, 6, 0, 0);
    Result.Height    := 38;
    Result.BevelOuter := bvNone;
    Result.StyleElements    := Result.StyleElements - [seClient];
    Result.ParentBackground := False;
    Result.Color     := CardBg;
  end;

begin
  BiDiMode := bdRightToLeft;
  uTheme.StyleForm(Self);

  Navy   := uTheme.AccentHeader;
  CardBg := uTheme.CardSurface;
  Muted  := uTheme.MutedText;
  if uTheme.IsDarkStyle then
  begin
    FieldFill := $003A3633;
    TextMain  := $00ECECEC;
    PageBg    := $001E1B19;
  end
  else
  begin
    FieldFill := $00F5F5F5;
    TextMain  := $00262626;
    PageBg    := $00E6EAEC;
  end;

  FSecCount := 0;

  pnlMain := TPanel.Create(Self);
  pnlMain.Parent     := Self;
  pnlMain.Align      := alClient;
  pnlMain.BevelOuter := bvNone;
  pnlMain.StyleElements    := pnlMain.StyleElements - [seClient];
  pnlMain.ParentBackground := False;
  pnlMain.Color      := PageBg;
  pnlMain.Padding.SetBounds(40, 24, 40, 24);
  TCtrlCrack(pnlMain).OnResize := PnlMainResize;

  // Create the edits up front so they can be slotted into rows
  FEdtOld     := TEdit.Create(Self); FEdtOld.PasswordChar     := '*'; StyleField(FEdtOld);
  FEdtNew     := TEdit.Create(Self); FEdtNew.PasswordChar     := '*'; StyleField(FEdtNew);
  FEdtConfirm := TEdit.Create(Self); FEdtConfirm.PasswordChar := '*'; StyleField(FEdtConfirm);

  // ── Section 1: change password ──
  body := MakeSection('تغيير كلمة المرور', 250);
  AttachRow(body, 'كلمة المرور الحالية:', FEdtOld);
  AttachRow(body, 'كلمة المرور الجديدة:', FEdtNew);
  AttachRow(body, 'تأكيد كلمة المرور:',  FEdtConfirm);
  MakePrimaryButton(ButtonRow(body), 'تغيير كلمة المرور', 190, alRight, btnChangePwdClick);

  // ── Section 2: appearance ──
  // A TComboBox keeps its items in the native control, so it must have a
  // parent (window handle) BEFORE Items are added — parent it via AttachRow first.
  body := MakeSection('المظهر', 116);
  FCmbStyle := TComboBox.Create(Self);
  FCmbStyle.Style     := csDropDownList;
  FCmbStyle.Font.Name := uTheme.FONT_NAME;
  FCmbStyle.Font.Size := 10;
  row  := AttachRow(body, 'النمط:', FCmbStyle);
  MakePrimaryButton(row, 'تطبيق', 100, alLeft, btnApplyStyleClick);
  for I := 0 to High(TStyleManager.StyleNames) do
    FCmbStyle.Items.Add(TStyleManager.StyleNames[I]);
  FCmbStyle.ItemIndex := FCmbStyle.Items.IndexOf(TStyleManager.ActiveStyle.Name);

  // ── Section 3: database ──
  body := MakeSection('قاعدة البيانات', 146);
  FLblDB := TLabel.Create(Self);
  FLblDB.Parent      := body;
  FLblDB.Align       := alTop;
  FLblDB.AlignWithMargins := True;
  FLblDB.Margins.SetBounds(2, 0, 2, 8);
  FLblDB.AutoSize    := False;
  FLblDB.Height      := 22;
  FLblDB.Caption     := ExtractFilePath(ParamStr(0)) + 'Braquiyat.accdb';
  FLblDB.Transparent := True;
  FLblDB.StyleElements := FLblDB.StyleElements - [seFont];
  FLblDB.Font.Name   := uTheme.FONT_NAME;
  FLblDB.Font.Size   := 9;
  FLblDB.Font.Color  := Muted;
  FLblDB.Layout      := tlCenter;
  MakePrimaryButton(ButtonRow(body), 'فحص الاتصال', 150, alRight, btnTestDBClick);

  PnlMainResize(pnlMain);
end;

procedure TfrmSettings.PnlMainResize(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FSecCount - 1 do
    if Assigned(FSecCards[I]) then
      uTheme.RoundPanel(FSecCards[I], 14);
end;

procedure TfrmSettings.BtnEnter(Sender: TObject);
var
  P: TWinControl;
begin
  if Sender is TPanel then
    P := TPanel(Sender)
  else if (Sender is TLabel) and (TLabel(Sender).Parent is TPanel) then
    P := TLabel(Sender).Parent
  else
    Exit;
  TPanel(P).Color := uTheme.AccentHover;
end;

procedure TfrmSettings.BtnLeave(Sender: TObject);
var
  P: TWinControl;
begin
  if Sender is TPanel then
    P := TPanel(Sender)
  else if (Sender is TLabel) and (TLabel(Sender).Parent is TPanel) then
    P := TLabel(Sender).Parent
  else
    Exit;
  TPanel(P).Color := uTheme.AccentHeader;
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
