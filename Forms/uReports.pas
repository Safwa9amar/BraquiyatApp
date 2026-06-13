unit uReports;

interface

uses
  Vcl.Forms, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Controls, Vcl.ComCtrls, Vcl.Dialogs,
  System.SysUtils, System.DateUtils, System.Classes;

type
  TfrmReports = class(TForm)
    pnlMain:       TPanel;
    pnlHeader:     TPanel;
    lblTitle:      TLabel;
    pnlOptions:    TPanel;
    lblReportType: TLabel;
    cmbReportType: TComboBox;
    lblDateFrom:   TLabel;
    dtFrom:        TDateTimePicker;
    lblDateTo:     TLabel;
    dtTo:          TDateTimePicker;
    btnGenerate:   TButton;
    btnPrint:      TButton;
    btnExport:     TButton;
    pnlPreview:    TPanel;
    lblPreview:    TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnGenerateClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
  private
    procedure GenerateReport;
  end;

var
  frmReports: TfrmReports;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  uDM, uConsts, uTheme, uUtils;

procedure TfrmReports.FormCreate(Sender: TObject);
begin
  BiDiMode := bdRightToLeft;
  uTheme.StyleForm(Self);
  uTheme.StyleAccentPanel(pnlHeader, lblTitle);

  cmbReportType.Items.AddStrings([
    'تقرير البرقيات الواردة',
    'تقرير البرقيات الصادرة',
    'تقرير شامل',
    'تقرير إحصائي'
  ]);
  cmbReportType.ItemIndex := 0;

  dtFrom.Date := EncodeDate(YearOf(Date), 1, 1);
  dtTo.Date   := Date;
end;

procedure TfrmReports.GenerateReport;
begin
  case cmbReportType.ItemIndex of
    0: begin
         DM.OpenBraquiyat(TYP_WARED, '', '', dtFrom.Date, dtTo.Date);
         lblPreview.Caption :=
           'البرقيات الواردة: ' +
           IntToStr(DM.qBraquiya.RecordCount) + ' سجل';
       end;
    1: begin
         DM.OpenBraquiyat(TYP_SADER, '', '', dtFrom.Date, dtTo.Date);
         lblPreview.Caption :=
           'البرقيات الصادرة: ' +
           IntToStr(DM.qBraquiya.RecordCount) + ' سجل';
       end;
    2: begin
         DM.OpenBraquiyat('', '', '', dtFrom.Date, dtTo.Date);
         lblPreview.Caption :=
           'إجمالي البرقيات: ' +
           IntToStr(DM.qBraquiya.RecordCount) + ' سجل';
       end;
    3: begin
         lblPreview.Caption :=
           'الواردة اليوم: ' + IntToStr(DM.GetCountToday(TYP_WARED)) +
           '   |   الصادرة اليوم: ' + IntToStr(DM.GetCountToday(TYP_SADER)) +
           '   |   في الانتظار: ' + IntToStr(DM.GetCountPending);
       end;
  end;
end;

procedure TfrmReports.btnGenerateClick(Sender: TObject);
begin
  GenerateReport;
end;

procedure TfrmReports.btnPrintClick(Sender: TObject);
var
  F: string;
begin
  GenerateReport;
  if (cmbReportType.ItemIndex = 3) or (not DM.qBraquiya.Active) or
     DM.qBraquiya.IsEmpty then
  begin
    ShowMessage('لا توجد بيانات قابلة للطباعة في هذا التقرير');
    Exit;
  end;
  F := TPath.Combine(TPath.GetTempPath, 'report.html');
  if uUtils.ExportDataSetToHTML(DM.qBraquiya, F, cmbReportType.Text) then
    uUtils.OpenFileExternally(F);
end;

procedure TfrmReports.btnExportClick(Sender: TObject);
var
  Dlg: TSaveDialog;
begin
  GenerateReport;
  if (cmbReportType.ItemIndex = 3) or (not DM.qBraquiya.Active) or
     DM.qBraquiya.IsEmpty then
  begin
    ShowMessage('لا توجد بيانات قابلة للتصدير في هذا التقرير');
    Exit;
  end;
  Dlg := TSaveDialog.Create(Self);
  try
    Dlg.Filter     := 'CSV (*.csv)|*.csv';
    Dlg.DefaultExt := 'csv';
    Dlg.FileName   := 'report.csv';
    if Dlg.Execute then
      if uUtils.ExportDataSetToCSV(DM.qBraquiya, Dlg.FileName) then
        ShowMessage('تم التصدير بنجاح');
  finally
    Dlg.Free;
  end;
end;

end.
