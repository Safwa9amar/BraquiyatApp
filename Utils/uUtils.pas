unit uUtils;

interface

uses
  System.SysUtils, System.Classes, System.StrUtils,
  Winapi.Windows, Winapi.ShellAPI,
  Data.DB,
  uConsts;

// Date utilities
function FormatArabicDate(const ADate: TDateTime): string;
function IsValidDate(const ADateStr: string): Boolean;

// String utilities
function TrimAll(const AStr: string): string;
function IsEmpty(const AStr: string): Boolean;
function ArabicToEnglishNumerals(const AStr: string): string;

// Number utilities
function FormatNumber(const AValue: Integer): string;
function PadZero(const AValue, AWidth: Integer): string;

// Validation utilities
function IsValidTelegramNumber(const ANumber: string): Boolean;

// UI utilities
procedure SetRTL(AHandle: HWND);

// Export / print utilities
function CellText(AField: TField): string;
function ExportDataSetToCSV(ADataSet: TDataSet; const AFile: string): Boolean;
function BuildDataSetHTML(ADataSet: TDataSet; const ATitle: string): string;
function ExportDataSetToHTML(ADataSet: TDataSet; const AFile, ATitle: string): Boolean;
procedure OpenFileExternally(const AFile: string);

// Attachment & Print utilities
function GetAttachmentFullPath(const AFileName: string): string;
function PreviewAttachment(const AFileName: string): Boolean;
function PrintFileBasedOnType(const AFile: string): Boolean;

implementation

uses
  Vcl.Printers, Vcl.Graphics, Vcl.Dialogs, Vcl.Forms,
  Vcl.Imaging.jpeg, Vcl.Imaging.pngimage, System.IOUtils;

function FormatArabicDate(const ADate: TDateTime): string;
begin
  Result := FormatDateTime('yyyy/mm/dd', ADate);
end;

function IsValidDate(const ADateStr: string): Boolean;
var
  D: TDateTime;
begin
  Result := TryStrToDate(ADateStr, D);
end;

function TrimAll(const AStr: string): string;
begin
  Result := Trim(AStr);
  while Pos('  ', Result) > 0 do
    Result := StringReplace(Result, '  ', ' ', [rfReplaceAll]);
end;

function IsEmpty(const AStr: string): Boolean;
begin
  Result := Trim(AStr) = '';
end;

function ArabicToEnglishNumerals(const AStr: string): string;
const
  ArabicNums: array[0..9] of Char = (#$0660, #$0661, #$0662, #$0663, #$0664,
                                      #$0665, #$0666, #$0667, #$0668, #$0669);
var
  I, J: Integer;
begin
  Result := AStr;
  for I := 0 to 9 do
    for J := 1 to Length(Result) do
      if Result[J] = ArabicNums[I] then
        Result[J] := Char(Ord('0') + I);
end;

function FormatNumber(const AValue: Integer): string;
begin
  Result := FormatFloat('#,##0', AValue);
end;

function PadZero(const AValue, AWidth: Integer): string;
begin
  Result := IntToStr(AValue);
  while Length(Result) < AWidth do
    Result := '0' + Result;
end;

function IsValidTelegramNumber(const ANumber: string): Boolean;
var
  I: Integer;
begin
  Result := (Length(ANumber) > 0) and (Length(ANumber) <= 20);
  if Result then
    for I := 1 to Length(ANumber) do
      if not CharInSet(ANumber[I], ['0'..'9', '/', '-', ' ']) then
      begin
        Result := False;
        Break;
      end;
end;

procedure SetRTL(AHandle: HWND);
var
  ExStyle: LONG;
begin
  ExStyle := GetWindowLong(AHandle, GWL_EXSTYLE);
  SetWindowLong(AHandle, GWL_EXSTYLE,
    ExStyle or WS_EX_RTLREADING or WS_EX_RIGHT or WS_EX_LEFTSCROLLBAR);
end;

function HtmlEsc(const S: string): string;
begin
  Result := StringReplace(S, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
end;

// Map a field's stored value to a human-readable (Arabic) cell value.
function CellText(AField: TField): string;
var
  Fn: string;
begin
  if AField = nil then Exit('');
  Fn := UpperCase(AField.FieldName);
  if Fn = 'URGENCE' then
    Result := UrgencyLabel(AField.AsString)
  else if Fn = 'ETAT' then
    Result := StateLabel(AField.AsString)
  else if Fn = 'TYPE_BRQ' then
    Result := TypeLabel(AField.AsString)
  else if (Fn = 'DATE_REC') and (not AField.IsNull) then
    Result := FormatDateTime('yyyy/mm/dd', AField.AsDateTime)
  else
    Result := AField.AsString;
end;

function ExportDataSetToCSV(ADataSet: TDataSet; const AFile: string): Boolean;
var
  W: TStreamWriter;
  I: Integer;
  Line: string;
  BM: TBookmark;
begin
  Result := False;
  if (ADataSet = nil) or (not ADataSet.Active) then Exit;
  W := TStreamWriter.Create(AFile, False, TEncoding.UTF8);  // UTF-8 BOM for Excel
  try
    Line := '';
    for I := 0 to ADataSet.FieldCount - 1 do
    begin
      if not ADataSet.Fields[I].Visible then Continue;
      if Line <> '' then Line := Line + ';';
      Line := Line + HeaderLabel(ADataSet.Fields[I].FieldName);
    end;
    W.WriteLine(Line);

    ADataSet.DisableControls;
    BM := ADataSet.GetBookmark;
    try
      ADataSet.First;
      while not ADataSet.Eof do
      begin
        Line := '';
        for I := 0 to ADataSet.FieldCount - 1 do
        begin
          if not ADataSet.Fields[I].Visible then Continue;
          if Line <> '' then Line := Line + ';';
          Line := Line + '"' +
            StringReplace(CellText(ADataSet.Fields[I]), '"', '""',
                          [rfReplaceAll]) + '"';
        end;
        W.WriteLine(Line);
        ADataSet.Next;
      end;
    finally
      if ADataSet.BookmarkValid(BM) then ADataSet.GotoBookmark(BM);
      ADataSet.FreeBookmark(BM);
      ADataSet.EnableControls;
    end;
    Result := True;
  finally
    W.Free;
  end;
end;

function BuildDataSetHTML(ADataSet: TDataSet; const ATitle: string): string;
var
  SB: TStringBuilder;
  I: Integer;
  BM: TBookmark;
begin
  SB := TStringBuilder.Create;
  try
    SB.Append('<!DOCTYPE html><html dir="rtl" lang="ar"><head><meta charset="utf-8">');
    SB.Append('<title>').Append(HtmlEsc(ATitle)).Append('</title><style>');
    SB.Append('body{font-family:"Segoe UI",Tahoma,sans-serif;margin:24px;color:#222;}');
    SB.Append('h2{text-align:center;color:#1f3864;}');
    SB.Append('table{width:100%;border-collapse:collapse;}');
    SB.Append('th,td{border:1px solid #aaa;padding:6px 8px;text-align:right;font-size:13px;}');
    SB.Append('th{background:#1f3864;color:#fff;}');
    SB.Append('tr:nth-child(even){background:#f2f4f8;}');
    SB.Append('.foot{margin-top:16px;font-size:12px;color:#666;text-align:center;}');
    SB.Append('</style></head><body>');
    SB.Append('<h2>').Append(HtmlEsc(ATitle)).Append('</h2>');
    SB.Append('<table><thead><tr>');
    for I := 0 to ADataSet.FieldCount - 1 do
      if ADataSet.Fields[I].Visible then
        SB.Append('<th>').Append(HtmlEsc(HeaderLabel(ADataSet.Fields[I].FieldName)))
        .Append('</th>');
    SB.Append('</tr></thead><tbody>');

    ADataSet.DisableControls;
    BM := ADataSet.GetBookmark;
    try
      ADataSet.First;
      while not ADataSet.Eof do
      begin
        SB.Append('<tr>');
        for I := 0 to ADataSet.FieldCount - 1 do
          if ADataSet.Fields[I].Visible then
            SB.Append('<td>').Append(HtmlEsc(CellText(ADataSet.Fields[I])))
            .Append('</td>');
        SB.Append('</tr>');
        ADataSet.Next;
      end;
    finally
      if ADataSet.BookmarkValid(BM) then ADataSet.GotoBookmark(BM);
      ADataSet.FreeBookmark(BM);
      ADataSet.EnableControls;
    end;

    SB.Append('</tbody></table>');
    SB.Append('<div class="foot">').Append(HtmlEsc(ATitle)).Append(' — ')
      .Append(FormatDateTime('yyyy/mm/dd hh:nn', Now)).Append('</div>');
    SB.Append('</body></html>');
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

function ExportDataSetToHTML(ADataSet: TDataSet; const AFile, ATitle: string): Boolean;
var
  W: TStreamWriter;
begin
  Result := False;
  if (ADataSet = nil) or (not ADataSet.Active) then Exit;
  W := TStreamWriter.Create(AFile, False, TEncoding.UTF8);
  try
    W.Write(BuildDataSetHTML(ADataSet, ATitle));
    Result := True;
  finally
    W.Free;
  end;
end;

procedure OpenFileExternally(const AFile: string);
begin
  ShellExecute(0, 'open', PChar(AFile), nil, nil, SW_SHOWNORMAL);
end;

function GetAttachmentFullPath(const AFileName: string): string;
var
  S, AttachDir: string;
begin
  Result := '';
  S := Trim(AFileName);
  if S = '' then Exit;
  if FileExists(S) then
    Exit(S);
  AttachDir := ExtractFilePath(ParamStr(0)) + 'Attachments' + PathDelim;
  if FileExists(AttachDir + S) then
    Exit(AttachDir + S);
  if FileExists(AttachDir + ExtractFileName(S)) then
    Exit(AttachDir + ExtractFileName(S));
  if FileExists(ExtractFilePath(ParamStr(0)) + S) then
    Exit(ExtractFilePath(ParamStr(0)) + S);
end;

function PreviewAttachment(const AFileName: string): Boolean;
var
  FullPath: string;
begin
  Result := False;
  if Trim(AFileName) = '' then
  begin
    ShowMessage(#1604#1575' '#1610#1608#1580#1583' '#1605#1604#1601' '#1605#1585#1601#1602' '#1604#1607#1584#1607' '#1575#1604#1576#1585#1602#1610#1577);  // لا يوجد ملف مرفق لهذه البرقية
    Exit;
  end;
  FullPath := GetAttachmentFullPath(AFileName);
  if (FullPath <> '') and FileExists(FullPath) then
  begin
    OpenFileExternally(FullPath);
    Result := True;
  end
  else
    ShowMessage(#1578#1593#1584#1585' '#1575#1604#1593#1570#1608#1585' '#1593#1604#1609' '#1575#1604#1605#1604#1601' '#1575#1604#1605#1585#1601#1602': ' + sLineBreak + AFileName);  // تعذر العثور على الملف المرفق
end;

function PrintImageFile(const AFile: string): Boolean;
var
  PrintDlg: TPrintDialog;
  Pic: TPicture;
  ScaleX, ScaleY, Scale: Double;
  DrawWidth, DrawHeight: Integer;
  OffsetX, OffsetY: Integer;
  PrintW, PrintH, Margin: Integer;
begin
  Result := False;
  Pic := TPicture.Create;
  try
    Pic.LoadFromFile(AFile);
    if (Pic.Width <= 0) or (Pic.Height <= 0) then Exit;

    PrintDlg := TPrintDialog.Create(nil);
    try
      if PrintDlg.Execute then
      begin
        Printer.BeginDoc;
        try
          Printer.Title := ExtractFileName(AFile);
          Margin := Round(Printer.PageWidth * 0.05); // 5% margins
          PrintW := Printer.PageWidth - (Margin * 2);
          PrintH := Printer.PageHeight - (Margin * 2);

          ScaleX := PrintW / Pic.Width;
          ScaleY := PrintH / Pic.Height;
          if ScaleX < ScaleY then
            Scale := ScaleX
          else
            Scale := ScaleY;

          DrawWidth  := Round(Pic.Width * Scale);
          DrawHeight := Round(Pic.Height * Scale);
          OffsetX := Margin + ((PrintW - DrawWidth) div 2);
          OffsetY := Margin + ((PrintH - DrawHeight) div 2);

          Printer.Canvas.StretchDraw(
            Rect(OffsetX, OffsetY, OffsetX + DrawWidth, OffsetY + DrawHeight),
            Pic.Graphic);
          Result := True;
        finally
          Printer.EndDoc;
        end;
      end;
    finally
      PrintDlg.Free;
    end;
  finally
    Pic.Free;
  end;
end;

function PrintFileBasedOnType(const AFile: string): Boolean;
var
  FullPath, Ext: string;
  Ret: HINST;
begin
  Result := False;
  FullPath := GetAttachmentFullPath(AFile);
  if (FullPath = '') or (not FileExists(FullPath)) then
  begin
    ShowMessage(#1578#1593#1584#1585' '#1575#1604#1593#1570#1608#1585' '#1593#1604#1609' '#1575#1604#1605#1604#1601' '#1575#1604#1605#1585#1575#1583' '#1591#1576#1575#1593#1578#1607': ' + sLineBreak + AFile); // تعذر العثور على الملف المراد طباعته
    Exit;
  end;

  Ext := LowerCase(ExtractFileExt(FullPath));

  // 1. Image formats: print directly to printer via canvas (avoids opening preview app)
  if (Ext = '.jpg') or (Ext = '.jpeg') or (Ext = '.png') or
     (Ext = '.bmp') or (Ext = '.ico') or (Ext = '.emf') or (Ext = '.wmf') then
  begin
    try
      Result := PrintImageFile(FullPath);
      Exit;
    except
      // If graphic parsing fails, fall through to shell print below
    end;
  end;

  // 2. Documents (PDF, Word, Text, HTML, etc.): invoke Windows Shell print verb
  Ret := ShellExecute(0, 'print', PChar(FullPath), nil, nil, SW_SHOWNORMAL);
  if Ret > 32 then
  begin
    Result := True;
    Exit;
  end;

  // 3. Fallback: if no direct print verb is registered, open in default app
  Ret := ShellExecute(0, 'open', PChar(FullPath), nil, nil, SW_SHOWNORMAL);
  if Ret > 32 then
  begin
    ShowMessage(#1578#1605' '#1601#1578#1581' '#1575#1604#1605#1604#1601' (' + ExtractFileName(FullPath) + ') '#1601#1610' '#1576#1585#1606#1575#1605#1580#1607' '#1575#1604#1575#1601#1578#1585#1575#1586#1610' '#1604#1604#1591#1576#1575#1593#1577'.'); // تم فتح الملف في برنامجه الافتراضي للطباعة
    Result := True;
  end
  else
    ShowMessage(#1578#1593#1584#1585' '#1601#1578#1581' '#1571#1608' '#1591#1576#1575#1593#1577' '#1575#1604#1605#1604#1601': ' + ExtractFileName(FullPath)); // تعذر فتح أو طباعة الملف
end;

end.
