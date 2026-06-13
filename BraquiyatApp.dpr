program BraquiyatApp;

uses
  Vcl.Forms,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.Themes,
  Vcl.Styles,
  System.SysUtils,
  System.UITypes,
  uConsts       in 'Utils\uConsts.pas',
  uTheme        in 'Utils\uTheme.pas',
  uUtils        in 'Utils\uUtils.pas',
  uDM           in 'DataModule\uDM.pas'          {DM: TDataModule},
  uLogin        in 'Forms\uLogin.pas'            {frmLogin},
  uMain         in 'Forms\uMain.pas'             {frmMain},
  uDashboard    in 'Forms\uDashboard.pas'        {frmDashboard},
  uWared        in 'Forms\uWared.pas'            {frmWared},
  uSader        in 'Forms\uSader.pas'            {frmSader},
  uFormBraquiya in 'Forms\uFormBraquiya.pas'     {frmFormBraquiya},
  uArchive      in 'Forms\uArchive.pas'          {frmArchive},
  uReports      in 'Forms\uReports.pas'          {frmReports},
  uRouting      in 'Forms\uRouting.pas'          {frmRouting},
  uSettings     in 'Forms\uSettings.pas'         {frmSettings};

{$R *.res}

var
  Missing: string;
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title             := 'نظام تسيير البرقيات';

  // Activate the VCL style chosen in <exe>.ini (falls back gracefully).
  uTheme.ApplyStartupStyle;

  try
    Application.CreateForm(TDM, DM);

    // Defensive startup check: confirm required tables/columns exist.
    if DM.CheckSchema(Missing) then
    begin
      Application.CreateForm(TfrmLogin, frmLogin);
      Application.Run;
    end
    else
      MessageDlg('قاعدة البيانات ناقصة العناصر التالية:' + sLineBreak +
                 sLineBreak + Missing, mtError, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg('تعذر تشغيل النظام:' + sLineBreak + E.Message,
                 mtError, [mbOK], 0);
  end;
end.
