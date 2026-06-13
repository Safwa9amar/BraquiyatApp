unit uFormBraquiya;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.StrUtils,
  Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Controls, Vcl.ComCtrls, Vcl.Graphics, Vcl.Dialogs,
  Data.Win.ADODB;

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
    rbIdari:      TRadioButton;
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
    procedure LoadJihat;
    procedure LoadServices;
    procedure LoadRecord(ANum: Integer);
    function  Validate: Boolean;
    procedure StyleSection(AHdr: TPanel; ABody: TPanel; const ATitle: string);
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
  uDM, uConsts, uTheme, uUtils;

procedure TfrmFormBraquiya.FormCreate(Sender: TObject);
begin
  BiDiMode    := bdRightToLeft;
  BorderStyle := bsDialog;
  Position    := poMainFormCenter;
  Width       := 560;
  Height      := 580;
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
  rbIdari.Caption := #1573#1583#1575#1585#1610;   // إداري
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

  LoadJihat;
  LoadServices;

  btnPrint.OnClick := btnPrintClick;
  uTheme.StyleForm(Self);
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
begin
  cmbJiha.Clear;
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

procedure TfrmFormBraquiya.LoadServices;
begin
  cmbService.Clear;
  cmbService.Items.Add('-- ' + #1575#1582#1578#1585' '#1575#1604#1605#1589#1604#1581#1577' --');
  cmbService.Items.Add(#1605#1603#1578#1576' '#1575#1604#1608#1575#1604#1610);
  cmbService.Items.Add(#1605#1589#1604#1581#1577' '#1575#1604#1573#1583#1575#1585#1577' '#1575#1604#1593#1575#1605#1577);
  cmbService.Items.Add(#1605#1589#1604#1581#1577' '#1575#1604#1578#1593#1604#1610#1605);
  cmbService.Items.Add(#1605#1589#1604#1581#1577' '#1575#1604#1589#1581#1577);
  cmbService.Items.Add(#1605#1589#1604#1581#1577' '#1575#1604#1601#1604#1575#1581#1577);
  cmbService.Items.Add(#1605#1589#1604#1581#1577' '#1575#1604#1605#1575#1604#1610#1577);
  cmbService.Items.Add(#1605#1589#1604#1581#1577' '#1575#1604#1575#1580#1578#1605#1575#1593#1610#1577);
  cmbService.Items.Add(#1605#1589#1604#1581#1577' '#1575#1604#1578#1593#1605#1610#1585);
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

  pnlSec3.Visible := (AType = 'WARED');
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

      case AnsiIndexStr(q.FieldByName('URGENCE').AsString,
                        [URG_AJIL, URG_ADI, URG_SIRRI, URG_IDARI]) of
        0: rbAjil.Checked  := True;
        1: rbAdi.Checked   := True;
        2: rbSirri.Checked := True;
        3: rbIdari.Checked := True;
      end;

      // Restore the sender (Jiha) selection — without this, editing fails
      // validation because no Jiha appears selected.
      for I := 1 to cmbJiha.Items.Count - 1 do
        if Integer(cmbJiha.Items.Objects[I]) =
           q.FieldByName('ID_JIHA').AsInteger then
        begin
          cmbJiha.ItemIndex := I;
          Break;
        end;

      // Restore the routed service if that column exists in the database.
      if Assigned(q.FindField('SERVICE')) and
         (q.FieldByName('SERVICE').AsString <> '') then
      begin
        Idx := cmbService.Items.IndexOf(q.FieldByName('SERVICE').AsString);
        if Idx >= 0 then cmbService.ItemIndex := Idx;
      end;

      // Show the routing section only for incoming telegrams.
      pnlSec3.Visible := (FTypeBRQ = TYP_WARED);
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
  if cmbJiha.ItemIndex <= 0 then
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
  else if rbIdari.Checked then Urg := URG_IDARI
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
    SL.Add('<tr><td class="k">' + HeaderLabel('DATE_REC') + '</td><td>' +
           FormatDateTime('yyyy/mm/dd', dtDate.Date) + '</td></tr>');
    SL.Add('<tr><td class="k">' + HeaderLabel('NOM_JIHA') + '</td><td>' +
           cmbJiha.Text + '</td></tr>');
    SL.Add('<tr><td class="k">' + HeaderLabel('OBJET') + '</td><td>' +
           edtObjet.Text + '</td></tr>');
    SL.Add('<tr><td class="k">' + HeaderLabel('CONTENU') + '</td><td>' +
           memContenu.Text + '</td></tr>');
    SL.Add('<tr><td class="k">' + HeaderLabel('REMARQUES') + '</td><td>' +
           memRem.Text + '</td></tr>');
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
