unit uFormBraquiya;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.StrUtils,
  Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Controls, Vcl.ComCtrls, Vcl.Graphics, Vcl.Dialogs,
  Data.Win.ADODB,
  uDM;   // TBraquiyaExt is used in the class declaration

const
  CLR_PANEL  = $00D8E9EC;
  CLR_NAVY   = $0064381F;
  CLR_BORDER = $00848284;
  CLR_BG     = $00C8D0D4;
  CLR_FIELD  = $00F5F4F0;

type
  TfrmFormBraquiya = class(TForm)
    // Header
    pnlHeader:    TPanel;
    lblFormTitle: TLabel;
    // Scroll content
    pnlScroll:    TPanel;
    // Section 1 — Basic info
    pnlSec1:      TPanel;
    pnlSec1Hdr:   TPanel;
    lblSec1:      TLabel;
    lblNum:       TLabel;
    edtNum:       TEdit;
    lblDate:      TLabel;
    dtDate:       TDateTimePicker;
    lblJiha:      TLabel;
    cmbJiha:      TComboBox;
    lblObjet:     TLabel;
    edtObjet:     TEdit;
    lblUrgence:   TLabel;
    rbAjil:       TRadioButton;
    rbAdi:        TRadioButton;
    rbSirri:      TRadioButton;
    // Section 2 — Content
    pnlSec2:      TPanel;
    pnlSec2Hdr:   TPanel;
    lblSec2:      TLabel;
    lblContenu:   TLabel;
    memContenu:   TMemo;
    // Section 3 — Routing
    pnlSec3:      TPanel;
    pnlSec3Hdr:   TPanel;
    lblSec3:      TLabel;
    lblService:   TLabel;
    cmbService:   TComboBox;
    lblRem:       TLabel;
    memRem:       TMemo;
    // Footer buttons
    pnlFooter:    TPanel;
    btnSave:      TButton;
    btnPrint:     TButton;
    btnCancel:    TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FMode:    string;
    FTypeBRQ: string;
    FNumBRQ:  Integer;
    FAttachPath:    string;    // picked full path OR stored relative name
    FAttachChanged: Boolean;
    FBtnAttach:     TButton;
    FLblAttach:     TLabel;
    // Real-correspondence (extended) fields, created in code (BuildExtFields).
    edtMsgRef, edtRefNum, edtHeure, edtDest, edtCopie, edtNumArr,
    edtSign: TEdit;
    memRefPrec: TMemo;
    dtArrivee:  TDateTimePicker;
    pnlSecExt:  TPanel;
    FStoredTabligh: string;
    FRowMsgRef, FRowRefNum, FRowHeure, FRowDest, FRowCopie,
    FRowNumArr, FRowDateArr, FRowRefPrec: TPanel;
    procedure LoadJihat;
    procedure LoadServices;
    procedure LoadRecord(ANum: Integer);
    function  Validate: Boolean;
    procedure StyleSection(AHdr: TPanel; ABody: TPanel; const ATitle: string);
    procedure BuildAttachUI;
    procedure AttachClick(Sender: TObject);
    procedure OpenAttachClick(Sender: TObject);
    procedure SaveAttachment(ANum: Integer);
    function  AttachFolder: string;
    procedure BuildExtFields;
    procedure LayoutExtFields;
    procedure ApplyTypeUI;
    function  BuildExt: TBraquiyaExt;
    procedure ClearExtFields;
  public
    procedure SetMode(const AMode, AType: string); overload;
    procedure SetMode(const AMode: string; ANum: Integer); overload;
  end;

var
  frmFormBraquiya: TfrmFormBraquiya;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  uConsts, uTheme, uUtils;

procedure TfrmFormBraquiya.FormCreate(Sender: TObject);
begin
  BiDiMode    := bdRightToLeft;
  BorderStyle := bsDialog;
  Position    := poMainFormCenter;
  Width       := 600;
  Height      := 640;
  Color       := CLR_BG;

  // Header (accent band that survives the active VCL style)
  pnlHeader.Height := 32;
  pnlHeader.Align  := alTop;
  uTheme.StyleAccentPanel(pnlHeader, lblFormTitle);
  lblFormTitle.Font.Size := 11;

  // Scroll pnl
  pnlScroll.BevelOuter := bvNone;
  pnlScroll.Align      := alClient;

  // Section styles
  StyleSection(pnlSec1Hdr, pnlSec1,
    #1575#1604#1576#1610#1575#1606#1575#1578' '#1575#1604#1571#1587#1575#1587#1610#1577);
  StyleSection(pnlSec2Hdr, pnlSec2,
    #1605#1581#1578#1608#1609' '#1575#1604#1576#1585#1602#1610#1577);
  StyleSection(pnlSec3Hdr, pnlSec3,
    #1575#1604#1578#1608#1580#1610#1607' '#1608#1575#1604#1605#1593#1575#1604#1580#1577);

  // Field labels
  lblNum.Caption     := #1585#1602#1605' '#1575#1604#1576#1585#1602#1610#1577':';
  lblDate.Caption    := #1578#1575#1585#1610#1582' '#1575#1604#1575#1587#1578#1604#1575#1605':';
  lblJiha.Caption    := #1575#1604#1580#1607#1577' '#1575#1604#1605#1585#1587#1604#1577':';
  lblObjet.Caption   := #1575#1604#1605#1608#1590#1608#1593':';
  lblUrgence.Caption := #1583#1585#1580#1577' '#1575#1604#1575#1587#1578#1593#1580#1575#1604':';
  lblContenu.Caption := #1606#1589' '#1575#1604#1576#1585#1602#1610#1577':';
  lblService.Caption := #1575#1604#1605#1589#1604#1581#1577' '#1575#1604#1605#1593#1606#1610#1577':';
  lblRem.Caption     := #1605#1604#1575#1581#1592#1575#1578':';

  rbAjil.Caption  := #1593#1575#1580#1604;
  rbAdi.Caption   := #1593#1575#1583#1610;
  rbSirri.Caption := #1587#1585#1610;
  rbAdi.Checked   := True;

  edtNum.ReadOnly := True;
  edtNum.Color    := CLR_FIELD;
  dtDate.Date     := Date;

  // Footer
  pnlFooter.Color      := CLR_PANEL;
  pnlFooter.BevelOuter := bvNone;
  pnlFooter.Height     := 40;
  pnlFooter.Align      := alBottom;

  btnSave.Caption   := #1581#1601#1592;
  btnPrint.Caption  := #1591#1576#1575#1593#1577;
  btnCancel.Caption := #1573#1604#1594#1575#1569;
  // Keep the action buttons hugging the (now wider) right edge.
  if Tag = 0 then
  begin
    Tag := 1;
    btnSave.Left   := btnSave.Left   + 40;
    btnPrint.Left  := btnPrint.Left  + 40;
    btnCancel.Left := btnCancel.Left + 40;
  end;

  BuildExtFields;
  LoadServices;
  BuildAttachUI;
  ApplyTypeUI;

  btnPrint.OnClick := btnPrintClick;
  uTheme.StyleForm(Self);
end;

procedure TfrmFormBraquiya.BuildExtFields;
var
  sbox: TScrollBox;
  hdr:  TPanel;
  Y:    Integer;
  row:  TPanel;

  // One stacked row inside the section.
  function NewRow(AHeight: Integer): TPanel;
  begin
    Result := TPanel.Create(Self);
    Result.Parent     := pnlSecExt;
    Result.SetBounds(6, Y, 552, AHeight);
    Result.BevelOuter := bvNone;
    Result.StyleElements    := Result.StyleElements - [seClient];
    Result.ParentBackground := False;
    Result.Color      := 16119024;
    Inc(Y, AHeight + 5);
  end;

  // Right-pinned, fixed-width label (no AutoSize → no RTL re-anchoring).
  procedure RowLabel(ARow: TPanel; const ACap: string);
  var L: TLabel;
  begin
    L := TLabel.Create(Self);
    L.Parent     := ARow;
    L.Align      := alRight;
    L.AlignWithMargins := True;
    L.Margins.SetBounds(6, 0, 6, 0);
    L.AutoSize   := False;
    L.Width      := 138;
    L.Layout     := tlCenter;
    L.Transparent := True;
    L.Caption    := ACap;
    L.Font.Name  := 'Tahoma';
    L.Font.Size  := 10;
  end;

  // A labelled row whose input is a full-width TEdit.
  function RowEdit(const ACap: string): TEdit;
  var r: TPanel;
  begin
    r := NewRow(26);
    RowLabel(r, ACap);
    Result := TEdit.Create(Self);
    Result.Parent   := r;
    Result.Align    := alClient;
    Result.AlignWithMargins := True;
    Result.Margins.SetBounds(4, 1, 4, 1);
    Result.Font.Name := 'Tahoma';
    Result.Font.Size := 10;
    Result.BiDiMode  := bdRightToLeft;
  end;

begin
  if Assigned(pnlSecExt) then Exit;

  // Make the field area scrollable so the longer form fits any screen.
  sbox := TScrollBox.Create(Self);
  sbox.Parent      := pnlScroll;
  sbox.Align       := alClient;
  sbox.BorderStyle := bsNone;
  sbox.Color       := CLR_BG;
  sbox.ParentColor := False;
  sbox.BiDiMode    := bdRightToLeft;
  sbox.HorzScrollBar.Visible := False;
  pnlSec1.Parent := sbox;
  pnlSec2.Parent := sbox;
  pnlSec3.Parent := sbox;
  // Widen the existing panels so they stop clipping their own right-edge labels.
  pnlSec1.Width := 564;
  pnlSec2.Width := 564;
  pnlSec3.Width := 564;

  // The content section (محتوى البرقية) is no longer used — the telegram text
  // now lives in the attached file. Hide it and pull the routing / extended
  // correspondence sections up to close the gap it leaves behind.
  pnlSec2.Visible := False;
  pnlSec3.Top     := 184;   // was 322 (right below the removed content section)

  // New section: all the real-correspondence fields, stacked as Align-based rows.
  pnlSecExt := TPanel.Create(Self);
  pnlSecExt.Parent     := sbox;
  pnlSecExt.SetBounds(8, 320, 564, 400);
  pnlSecExt.BevelOuter := bvNone;
  pnlSecExt.StyleElements    := pnlSecExt.StyleElements - [seClient];
  pnlSecExt.ParentBackground := False;
  pnlSecExt.Color      := 16119024;

  hdr := TPanel.Create(Self);
  hdr.Parent := pnlSecExt;
  TLabel.Create(Self).Parent := hdr;   // StyleSection styles Controls[0]
  StyleSection(hdr, pnlSecExt,
    #1576#1610#1575#1606#1575#1578' '#1575#1604#1605#1585#1575#1587#1604#1577);  // بيانات المراسلة

  Y := 30;
  edtMsgRef  := RowEdit(#1585#1602#1605' '#1575#1604#1573#1585#1587#1575#1604':');           // رقم الإرسال
  FRowMsgRef := edtMsgRef.Parent as TPanel;

  edtRefNum  := RowEdit(#1585#1602#1605' '#1575#1604#1606#1589':');                           // رقم النص
  FRowRefNum := edtRefNum.Parent as TPanel;

  edtHeure   := RowEdit(#1608#1602#1578' '#1575#1604#1573#1585#1587#1575#1604':');          // وقت الإرسال
  FRowHeure  := edtHeure.Parent as TPanel;

  edtDest    := RowEdit(#1575#1604#1605#1585#1587#1604' '#1573#1604#1610#1607':');            // المرسل إليه
  FRowDest   := edtDest.Parent as TPanel;

  edtCopie   := RowEdit(#1606#1587#1582#1577' '#1573#1604#1609':');                           // نسخة إلى
  FRowCopie  := edtCopie.Parent as TPanel;

  // "الإمضاء / الصفة" removed from the form (now part of the attached file); kept
  // as a hidden field so editing an old record preserves its stored SIGNATAIRE.
  edtSign := TEdit.Create(Self);
  edtSign.Parent  := pnlSecExt;
  edtSign.Visible := False;

  edtNumArr  := RowEdit(#1585#1602#1605' '#1575#1604#1608#1575#1585#1583':');                 // رقم الوارد
  FRowNumArr := edtNumArr.Parent as TPanel;

  row := NewRow(26);
  RowLabel(row, #1578#1575#1585#1610#1582' '#1575#1604#1608#1585#1608#1583':');               // تاريخ الورود
  dtArrivee := TDateTimePicker.Create(Self);
  dtArrivee.Parent    := row;
  dtArrivee.Align     := alLeft;
  dtArrivee.AlignWithMargins := True;
  dtArrivee.Margins.SetBounds(4, 1, 4, 1);
  dtArrivee.Width     := 190;
  dtArrivee.Font.Name := 'Tahoma';
  dtArrivee.Font.Size := 10;
  dtArrivee.Date      := Date;
  FRowDateArr := row;

  row := NewRow(58);
  RowLabel(row, #1575#1604#1605#1585#1580#1593':');                                           // المرجع
  memRefPrec := TMemo.Create(Self);
  memRefPrec.Parent    := row;
  memRefPrec.Align     := alClient;
  memRefPrec.AlignWithMargins := True;
  memRefPrec.Margins.SetBounds(4, 2, 4, 2);
  memRefPrec.Font.Name := 'Tahoma';
  memRefPrec.Font.Size := 10;
  memRefPrec.ScrollBars := ssVertical;
  memRefPrec.BiDiMode   := bdRightToLeft;
  FRowRefPrec := row;

  LayoutExtFields;
end;

procedure TfrmFormBraquiya.LayoutExtFields;
var
  CurY: Integer;

  procedure PlaceRow(ARow: TPanel);
  begin
    if Assigned(ARow) and ARow.Visible then
    begin
      ARow.Top := CurY;
      Inc(CurY, ARow.Height + 5);
    end;
  end;

begin
  if not Assigned(pnlSecExt) then Exit;
  CurY := 30;
  PlaceRow(FRowMsgRef);
  PlaceRow(FRowRefNum);
  PlaceRow(FRowHeure);
  PlaceRow(FRowDest);
  PlaceRow(FRowCopie);
  PlaceRow(FRowNumArr);
  PlaceRow(FRowDateArr);
  PlaceRow(FRowRefPrec);
  pnlSecExt.Height := CurY + 8;
end;

procedure TfrmFormBraquiya.ApplyTypeUI;
var
  IsSader: Boolean;
begin
  IsSader := (FTypeBRQ = TYP_SADER);

  // 1. Date label caption
  if IsSader then
    lblDate.Caption := #1578#1575#1585#1610#1582' '#1575#1604#1573#1585#1587#1575#1604':'    // تاريخ الإرسال:
  else
    lblDate.Caption := #1578#1575#1585#1610#1582' '#1575#1604#1575#1587#1578#1604#1575#1605':';   // تاريخ الاستلام:

  // 2. Routing section (only for incoming / WARED)
  pnlSec3.Visible := not IsSader;
  if Assigned(pnlSecExt) then
  begin
    if pnlSec3.Visible then
      pnlSecExt.Top := 320
    else
      pnlSecExt.Top := 184;
  end;

  // 3. Outgoing fields: "المرسل إليه" and "نسخة إلى" are shown for SADER
  if Assigned(FRowDest) then
    FRowDest.Visible := IsSader;
  if Assigned(FRowCopie) then
    FRowCopie.Visible := IsSader;

  // 4. Incoming fields: "رقم الوارد" and "تاريخ الورود" are shown for WARED
  if Assigned(FRowNumArr) then
    FRowNumArr.Visible := not IsSader;
  if Assigned(FRowDateArr) then
    FRowDateArr.Visible := not IsSader;

  LayoutExtFields;

  // 5. Sender list (strictly 'دائرة بوعلام' for SADER)
  LoadJihat;
end;

function TfrmFormBraquiya.BuildExt: TBraquiyaExt;
begin
  Result.MsgRef       := Trim(edtMsgRef.Text);
  Result.RefNum       := Trim(edtRefNum.Text);
  Result.Heure        := Trim(edtHeure.Text);
  Result.Signataire   := Trim(edtSign.Text);
  Result.Tabligh      := FStoredTabligh;
  Result.RefPrec      := Trim(memRefPrec.Text);
  if FTypeBRQ = TYP_SADER then
  begin
    Result.Destinataire := Trim(edtDest.Text);
    Result.Copie        := Trim(edtCopie.Text);
    Result.NumArrivee   := '';
    Result.DateArrivee  := 0;
  end
  else
  begin
    Result.Destinataire := '';
    Result.Copie        := '';
    Result.NumArrivee   := Trim(edtNumArr.Text);
    Result.DateArrivee  := dtArrivee.Date;
  end;
end;

procedure TfrmFormBraquiya.ClearExtFields;
begin
  if Assigned(edtMsgRef)  then edtMsgRef.Text  := '';
  if Assigned(edtRefNum)  then edtRefNum.Text  := '';
  if Assigned(edtHeure)   then edtHeure.Text   := '';
  if Assigned(edtDest)    then edtDest.Text    := '';
  if Assigned(edtCopie)   then edtCopie.Text   := '';
  if Assigned(edtSign)    then edtSign.Text    := '';
  if Assigned(edtNumArr)  then edtNumArr.Text  := '';
  if Assigned(memRefPrec) then memRefPrec.Text := '';
  FStoredTabligh := '';
  if Assigned(dtArrivee)  then dtArrivee.Date  := Date;
end;

function TfrmFormBraquiya.AttachFolder: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'Attachments' + PathDelim;
end;

procedure TfrmFormBraquiya.BuildAttachUI;
begin
  if Assigned(FBtnAttach) then Exit;
  // Lives in the free (right) part of the footer band.
  FBtnAttach := TButton.Create(Self);
  FBtnAttach.Parent  := pnlFooter;
  FBtnAttach.SetBounds(8, 7, 104, 26);
  FBtnAttach.Caption := #1573#1585#1601#1575#1602' '#1605#1604#1601;   // إرفاق ملف
  FBtnAttach.OnClick := AttachClick;

  FLblAttach := TLabel.Create(Self);
  FLblAttach.Parent      := pnlFooter;
  FLblAttach.AutoSize    := False;
  FLblAttach.SetBounds(120, 13, 162, 16);
  FLblAttach.EllipsisPosition := epEndEllipsis;
  FLblAttach.Caption := '(' + #1604#1575' '#1610#1608#1580#1583' '#1605#1604#1601 + ')';  // (لا يوجد ملف)
  FLblAttach.Cursor    := crHandPoint;
  FLblAttach.OnClick   := OpenAttachClick;
  FLblAttach.Font.Color := clBlue;
end;

procedure TfrmFormBraquiya.AttachClick(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(Self);
  try
    Dlg.Filter :=
      #1603#1604' '#1575#1604#1605#1604#1601#1575#1578 + '|*.*|' +   // كل الملفات
      'PDF|*.pdf|' +
      #1589#1608#1585 + '|*.jpg;*.jpeg;*.png|' +                    // صور
      'Word|*.doc;*.docx';
    if Dlg.Execute then
    begin
      FAttachPath        := Dlg.FileName;
      FAttachChanged     := True;
      FLblAttach.Caption := ExtractFileName(FAttachPath);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmFormBraquiya.OpenAttachClick(Sender: TObject);
var
  P: string;
begin
  if FAttachPath = '' then Exit;
  P := FAttachPath;
  if not FileExists(P) then
    P := AttachFolder + FAttachPath;   // a stored relative name
  if FileExists(P) then
    uUtils.OpenFileExternally(P)
  else
    ShowMessage(#1604#1575' '#1610#1608#1580#1583' '#1605#1604#1601' '#1605#1585#1601#1602);  // لا يوجد ملف مرفق
end;

procedure TfrmFormBraquiya.SaveAttachment(ANum: Integer);
var
  Dest, NewName: string;
begin
  if (not FAttachChanged) or (FAttachPath = '') then Exit;
  if not FileExists(FAttachPath) then Exit;   // only copy a freshly-picked file
  Dest := AttachFolder;
  ForceDirectories(Dest);
  NewName := 'BRQ' + IntToStr(ANum) + '_' + ExtractFileName(FAttachPath);
  try
    TFile.Copy(FAttachPath, Dest + NewName, True);
    DM.SetAttachment(ANum, NewName);
    FAttachPath    := NewName;     // now a stored relative name
    FAttachChanged := False;
  except
    on E: Exception do
      ShowMessage(#1601#1588#1604' '#1606#1587#1582' '#1575#1604#1605#1604#1601 + ': ' + E.Message);  // فشل نسخ الملف
  end;
end;

procedure TfrmFormBraquiya.StyleSection(AHdr: TPanel; ABody: TPanel;
  const ATitle: string);
begin
  ABody.BevelOuter := bvNone;

  AHdr.Parent := ABody;
  AHdr.Align  := alTop;
  AHdr.Height := 24;

  // Find the label inside and style the band as a surviving accent.
  if AHdr.ControlCount > 0 then
  begin
    TLabel(AHdr.Controls[0]).Caption := '  ' + ATitle;
    uTheme.StyleAccentPanel(AHdr, TLabel(AHdr.Controls[0]));
    TLabel(AHdr.Controls[0]).Font.Size := 9;
    TLabel(AHdr.Controls[0]).Align     := alClient;
    TLabel(AHdr.Controls[0]).Layout    := tlCenter;
  end
  else
    uTheme.StyleAccentPanel(AHdr, nil);
end;

procedure TfrmFormBraquiya.LoadJihat;
var
  q: TADOQuery;
  DairaName: string;
  DairaId: Integer;
begin
  DairaName := #1583#1575#1574#1585#1577' '#1576#1608#1593#1604#1575#1605; // دائرة بوعلام
  cmbJiha.Clear;

  if FTypeBRQ = TYP_SADER then
  begin
    DairaId := -1;
    q := TADOQuery.Create(nil);
    try
      q.Connection := DM.Conn;
      q.SQL.Text   := 'SELECT ID_JIHA FROM JIHA WHERE NOM_JIHA = :n';
      q.Parameters.ParamByName('n').Value := DairaName;
      q.Open;
      if not q.IsEmpty then
        DairaId := q.FieldByName('ID_JIHA').AsInteger;
    finally
      q.Free;
    end;

    if DairaId <= 0 then
    begin
      try
        DM.EnsureJihaSeed;
        q := TADOQuery.Create(nil);
        try
          q.Connection := DM.Conn;
          q.SQL.Text   := 'SELECT ID_JIHA FROM JIHA WHERE NOM_JIHA = :n';
          q.Parameters.ParamByName('n').Value := DairaName;
          q.Open;
          if not q.IsEmpty then
            DairaId := q.FieldByName('ID_JIHA').AsInteger;
        finally
          q.Free;
        end;
      except
      end;
    end;

    if DairaId <= 0 then DairaId := 1;

    cmbJiha.Items.AddObject(DairaName, TObject(DairaId));
    cmbJiha.ItemIndex := 0;
  end
  else
  begin
    cmbJiha.Items.Add('-- ' + #1575#1582#1578#1585' '#1575#1604#1580#1607#1577' --');
    q := TADOQuery.Create(nil);
    try
      q.Connection := DM.Conn;
      q.SQL.Text   := 'SELECT ID_JIHA, NOM_JIHA FROM JIHA ORDER BY NOM_JIHA';
      q.Open;
      while not q.Eof do
      begin
        cmbJiha.Items.AddObject(
          q.FieldByName('NOM_JIHA').AsString,
          TObject(q.FieldByName('ID_JIHA').AsInteger));
        q.Next;
      end;
    finally
      q.Free;
    end;
    cmbJiha.ItemIndex := 0;
  end;
end;

procedure TfrmFormBraquiya.LoadServices;
begin
  DM.FillServices(cmbService.Items);   // offices from the DB (MASLAHA)
  cmbService.ItemIndex := 0;
end;

procedure TfrmFormBraquiya.SetMode(const AMode, AType: string);
begin
  FMode    := AMode;
  FTypeBRQ := AType;
  FNumBRQ  := -1;
  edtNum.Text := '('+#1578#1604#1602#1575#1574#1610+')';
  if AType = 'WARED' then
    lblFormTitle.Caption := #1573#1590#1575#1601#1577' '#1576#1585#1602#1610#1577' '#1608#1575#1585#1583#1577' '#1580#1583#1610#1583#1577
  else
    lblFormTitle.Caption := #1573#1590#1575#1601#1577' '#1576#1585#1602#1610#1577' '#1589#1575#1583#1585#1577' '#1580#1583#1610#1583#1577;

  BuildExtFields;
  ApplyTypeUI;

  ClearExtFields;
  FAttachPath    := '';
  FAttachChanged := False;
  FLblAttach.Caption := '(' + #1604#1575' '#1610#1608#1580#1583' '#1605#1604#1601 + ')';  // (لا يوجد ملف)
end;

procedure TfrmFormBraquiya.SetMode(const AMode: string; ANum: Integer);
begin
  FMode   := AMode;
  FNumBRQ := ANum;
  lblFormTitle.Caption :=
    #1578#1593#1583#1610#1604' '#1575#1604#1576#1585#1602#1610#1577' '#1585#1602#1605' ' + IntToStr(ANum);
  LoadRecord(ANum);
end;

procedure TfrmFormBraquiya.LoadRecord(ANum: Integer);
var
  q: TADOQuery;
  I, Idx: Integer;
begin
  q := TADOQuery.Create(nil);
  try
    q.Connection := DM.Conn;
    q.SQL.Text   := 'SELECT * FROM BRAQUIYA WHERE NUM_BRQ = :n';
    q.Parameters.ParamByName('n').Value := ANum;
    q.Open;
    if not q.IsEmpty then
    begin
      edtNum.Text     := IntToStr(ANum);
      dtDate.DateTime := q.FieldByName('DATE_REC').AsDateTime;
      edtObjet.Text   := q.FieldByName('OBJET').AsString;
      memContenu.Text := q.FieldByName('CONTENU').AsString;
      memRem.Text     := q.FieldByName('REMARQUES').AsString;
      FTypeBRQ        := q.FieldByName('TYPE_BRQ').AsString;

      BuildExtFields;
      ApplyTypeUI;

      case AnsiIndexStr(q.FieldByName('URGENCE').AsString,
                        [URG_AJIL, URG_ADI, URG_SIRRI]) of
        0: rbAjil.Checked  := True;
        1: rbAdi.Checked   := True;
        2: rbSirri.Checked := True;
      else
        rbAdi.Checked := True;
      end;

      // Restore the sender (Jiha) selection
      if FTypeBRQ = TYP_SADER then
      begin
        if cmbJiha.Items.Count > 0 then
          cmbJiha.ItemIndex := 0;
      end
      else
      begin
        for I := 1 to cmbJiha.Items.Count - 1 do
          if Integer(cmbJiha.Items.Objects[I]) =
             q.FieldByName('ID_JIHA').AsInteger then
          begin
            cmbJiha.ItemIndex := I;
            Break;
          end;
      end;

      // Restore the routed service if that column exists in the database.
      if Assigned(q.FindField('SERVICE')) and
         (q.FieldByName('SERVICE').AsString <> '') then
      begin
        Idx := cmbService.Items.IndexOf(q.FieldByName('SERVICE').AsString);
        if Idx >= 0 then cmbService.ItemIndex := Idx;
      end;

      // Extended (real-correspondence) fields — guarded so missing columns
      // never break loading.
      if Assigned(q.FindField('MSG_REF'))      then edtMsgRef.Text  := q.FieldByName('MSG_REF').AsString;
      if Assigned(q.FindField('REF_NUM'))      then edtRefNum.Text  := q.FieldByName('REF_NUM').AsString;
      if Assigned(q.FindField('HEURE'))        then edtHeure.Text   := q.FieldByName('HEURE').AsString;
      if Assigned(q.FindField('DESTINATAIRE')) and Assigned(edtDest)  then edtDest.Text    := q.FieldByName('DESTINATAIRE').AsString;
      if Assigned(q.FindField('SIGNATAIRE'))   then edtSign.Text    := q.FieldByName('SIGNATAIRE').AsString;
      if Assigned(q.FindField('TABLIGH'))      then FStoredTabligh  := q.FieldByName('TABLIGH').AsString;
      if Assigned(q.FindField('REF_PREC'))     then memRefPrec.Text := q.FieldByName('REF_PREC').AsString;
      if Assigned(q.FindField('COPIE')) and Assigned(edtCopie)        then edtCopie.Text   := q.FieldByName('COPIE').AsString;
      if Assigned(q.FindField('NUM_ARRIVEE'))  then edtNumArr.Text  := q.FieldByName('NUM_ARRIVEE').AsString;
      if Assigned(q.FindField('DATE_ARRIVEE')) and
         not q.FieldByName('DATE_ARRIVEE').IsNull then
        dtArrivee.DateTime := q.FieldByName('DATE_ARRIVEE').AsDateTime;

      if Assigned(q.FindField('ATTACHMENT')) and
         (q.FieldByName('ATTACHMENT').AsString <> '') then
      begin
        FAttachPath        := q.FieldByName('ATTACHMENT').AsString;
        FAttachChanged     := False;
        FLblAttach.Caption := FAttachPath;
      end;

      // Show the routing section only for incoming telegrams.
      pnlSec3.Visible := (FTypeBRQ = TYP_WARED);
      if pnlSec3.Visible then pnlSecExt.Top := 320 else pnlSecExt.Top := 184;
    end;
  finally
    q.Free;
  end;
end;

function TfrmFormBraquiya.Validate: Boolean;
begin
  Result := False;
  if Trim(edtObjet.Text) = '' then
  begin
    ShowMessage(#1575#1604#1585#1580#1575#1569' '#1573#1583#1582#1575#1604' '#1605#1608#1590#1608#1593' '#1575#1604#1576#1585#1602#1610#1577);
    edtObjet.SetFocus;
    Exit;
  end;
  if (cmbJiha.ItemIndex < 0) or (Integer(cmbJiha.Items.Objects[cmbJiha.ItemIndex]) <= 0) then
  begin
    ShowMessage(#1575#1604#1585#1580#1575#1569' '#1575#1582#1578#1610#1575#1585' '#1575#1604#1580#1607#1577);
    cmbJiha.SetFocus;
    Exit;
  end;
  Result := True;
end;

procedure TfrmFormBraquiya.btnSaveClick(Sender: TObject);
var
  Urg, Service: string;
  JihaID, NewNum: Integer;
begin
  if not Validate then Exit;

  if rbAjil.Checked       then Urg := URG_AJIL
  else if rbSirri.Checked then Urg := URG_SIRRI
  else                         Urg := URG_ADI;

  JihaID := Integer(cmbJiha.Items.Objects[cmbJiha.ItemIndex]);

  Service := '';
  if pnlSec3.Visible and (cmbService.ItemIndex > 0) then
    Service := cmbService.Text;

  try
    if FMode = 'ADD' then
    begin
      NewNum := DM.InsertBraquiya(
        edtObjet.Text, FTypeBRQ, Urg,
        memContenu.Text, memRem.Text,
        JihaID, dtDate.DateTime);
      if NewNum > 0 then
      begin
        if Service <> '' then
          DM.SetService(NewNum, Service);
        FNumBRQ := NewNum;
        DM.SaveBraquiyaExt(NewNum, BuildExt);
        SaveAttachment(NewNum);
        ShowMessage(#1578#1605' '#1581#1601#1592' '#1575#1604#1576#1585#1602#1610#1577' '#1585#1602#1605' ' +
                    IntToStr(NewNum) + ' ' + #1576#1606#1580#1575#1581);
        ModalResult := mrOk;
      end
      else
        ShowMessage(#1581#1583#1579' '#1582#1591#1571' '#1571#1579#1606#1575#1569' '#1575#1604#1581#1601#1592);
    end
    else
    begin
      DM.UpdateBraquiya(FNumBRQ, edtObjet.Text, Urg, memContenu.Text,
        memRem.Text, JihaID, dtDate.DateTime, Service);
      DM.SaveBraquiyaExt(FNumBRQ, BuildExt);
      SaveAttachment(FNumBRQ);
      ModalResult := mrOk;
    end;
  except
    on E: Exception do ShowMessage(E.Message);
  end;
end;

procedure TfrmFormBraquiya.btnPrintClick(Sender: TObject);
var
  SL: TStringList;
  F: string;

  procedure Row(const AField, AValue: string);
  begin
    if Trim(AValue) <> '' then
      SL.Add('<tr><td class="k">' + HeaderLabel(AField) + '</td><td>' +
             AValue + '</td></tr>');
  end;

begin
  SL := TStringList.Create;
  try
    SL.Add('<!DOCTYPE html><html dir="rtl" lang="ar"><head><meta charset="utf-8">');
    SL.Add('<style>body{font-family:"Segoe UI",Tahoma,sans-serif;margin:30px;}');
    SL.Add('h2{text-align:center;color:#1f3864;}');
    SL.Add('table{width:100%;border-collapse:collapse;}');
    SL.Add('td{border:1px solid #999;padding:8px;font-size:14px;text-align:right;}');
    SL.Add('td.k{background:#1f3864;color:#fff;width:160px;}</style></head><body>');
    SL.Add('<h2>' + lblFormTitle.Caption + '</h2><table>');
    SL.Add('<tr><td class="k">' + HeaderLabel('NUM_BRQ') + '</td><td>' +
           edtNum.Text + '</td></tr>');
    if FTypeBRQ = TYP_SADER then
      SL.Add('<tr><td class="k">' + #1578#1575#1585#1610#1582' '#1575#1604#1573#1585#1587#1575#1604 + '</td><td>' +
             FormatDateTime('yyyy/mm/dd', dtDate.Date) + '</td></tr>')
    else
      SL.Add('<tr><td class="k">' + #1578#1575#1585#1610#1582' '#1575#1604#1575#1587#1578#1604#1575#1605 + '</td><td>' +
             FormatDateTime('yyyy/mm/dd', dtDate.Date) + '</td></tr>');
    SL.Add('<tr><td class="k">' + HeaderLabel('NOM_JIHA') + '</td><td>' +
           cmbJiha.Text + '</td></tr>');
    SL.Add('<tr><td class="k">' + HeaderLabel('OBJET') + '</td><td>' +
           edtObjet.Text + '</td></tr>');
    SL.Add('<tr><td class="k">' + HeaderLabel('CONTENU') + '</td><td>' +
           memContenu.Text + '</td></tr>');
    SL.Add('<tr><td class="k">' + HeaderLabel('REMARQUES') + '</td><td>' +
           memRem.Text + '</td></tr>');
    Row('MSG_REF',      edtMsgRef.Text);
    Row('REF_NUM',      edtRefNum.Text);
    Row('HEURE',        edtHeure.Text);
    if FTypeBRQ = TYP_SADER then
    begin
      Row('DESTINATAIRE', edtDest.Text);
      Row('COPIE',        edtCopie.Text);
    end;
    Row('SIGNATAIRE',   edtSign.Text);
    Row('TABLIGH',      FStoredTabligh);
    Row('REF_PREC',     memRefPrec.Text);
    if FTypeBRQ <> TYP_SADER then
      Row('NUM_ARRIVEE',  edtNumArr.Text);
    Row('ATTACHMENT',   ExtractFileName(FAttachPath));
    SL.Add('</table></body></html>');
    F := TPath.Combine(TPath.GetTempPath, 'braquiya_print.html');
    SL.SaveToFile(F, TEncoding.UTF8);
    uUtils.OpenFileExternally(F);
  finally
    SL.Free;
  end;
end;

procedure TfrmFormBraquiya.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
