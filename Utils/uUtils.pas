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

implementation

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
      if I > 0 then Line := Line + ';';
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
          if I > 0 then Line := Line + ';';
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

end.
