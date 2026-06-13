unit uDM;

interface

uses
  System.SysUtils, System.Classes,
  Data.DB, Data.Win.ADODB,
  uConsts;

type
  // Raised by the data layer with a friendly Arabic message; forms catch it.
  EDataError = class(Exception);

  TDM = class(TDataModule)
    Conn:       TADOConnection;
    // ── Queries ──────────────────────────
    qBraquiya:  TADOQuery;
    qJiha:      TADOQuery;
    qEmploye:   TADOQuery;
    qOrient:    TADOQuery;
    // ── DataSources ──────────────────────
    dsBraquiya: TDataSource;
    dsJiha:     TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  private
    FCurrentUser:   Integer;
    FCurrentRole:   string;
    FCurrentName:   string;
    FHasServiceCol: Boolean;
    FqRecent:       TADOQuery;
    procedure RaiseDataError(E: Exception);
    function  ProbeColumn(const ATable, ACol: string): Boolean;
    function  CountQuery(const ASQL: string): Integer; overload;
    function  CountQuery(const ASQL, AParam: string;
                         const AValue: Variant): Integer; overload;
    procedure SetEtatChecked(ANum: Integer; const ATo: string);
  public
    property CurrentUser:      Integer read FCurrentUser write FCurrentUser;
    property CurrentRole:      string  read FCurrentRole write FCurrentRole;
    property CurrentName:      string  read FCurrentName;
    property HasServiceColumn: Boolean read FHasServiceCol;

    function  Login(AUser, APass: string): Boolean;

    procedure OpenBraquiyat(AType, AEtat, AUrgence: string;
                            ADateFrom, ADateTo: TDate;
                            const ASearch: string = '');
    procedure OpenNeedsRouting(ADateFrom, ADateTo: TDate);
    function  OpenRecent(ALimit: Integer): TADOQuery;

    function  InsertBraquiya(AObjet, AType, AUrgence,
                             AContenu, ARem: string;
                             AJiha: Integer;
                             ADateRec: TDateTime): Integer;
    procedure UpdateBraquiya(ANum: Integer;
                             AObjet, AUrgence, AContenu, ARem: string;
                             AJiha: Integer; ADateRec: TDateTime;
                             const AService: string);

    // ── State lifecycle ──────────────────
    function  GetState(ANum: Integer): string;
    procedure SetService(ANum: Integer; const AService: string);
    procedure RouteBraquiya(ANum: Integer; const AService: string);
    procedure MarkProcessed(ANum: Integer);
    procedure ArchiveBraquiya(ANum: Integer);
    procedure RestoreBraquiya(ANum: Integer);
    procedure SoftDelete(ANum: Integer);

    // ── Statistics ───────────────────────
    function  GetCountToday(AType: string): Integer;
    function  GetCountMonth(AType: string): Integer;
    function  GetCountPending: Integer;
    function  GetCountByUrgency(AUrgence: string): Integer;
    function  GetCountByState(AEtat: string): Integer;

    // ── Diagnostics / admin ──────────────
    function  CheckSchema(out AMissing: string): Boolean;
    function  ChangePassword(AUserId: Integer; const AOld, ANew: string): Boolean;
  end;

var
  DM: TDM;

implementation

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
var
  DBPath: string;
begin
  DBPath := ExtractFilePath(ParamStr(0)) + 'Braquiyat.accdb';
  Conn.ConnectionString :=
    'Provider=Microsoft.ACE.OLEDB.12.0;' +
    'Data Source=' + DBPath + ';' +
    'Persist Security Info=False;';
  Conn.LoginPrompt := False;
  // Client-side cursor → reliable RecordCount and random navigation.
  Conn.CursorLocation := clUseClient;
  try
    Conn.Connected := True;
  except
    on E: Exception do
      raise Exception.Create('خطأ في الاتصال بقاعدة البيانات: ' + E.Message);
  end;

  qBraquiya.CursorLocation := clUseClient;
  qBraquiya.CursorType     := ctStatic;

  FqRecent := TADOQuery.Create(Self);
  FqRecent.Connection     := Conn;
  FqRecent.CursorLocation := clUseClient;
  FqRecent.CursorType     := ctStatic;

  FHasServiceCol := False;
end;

procedure TDM.RaiseDataError(E: Exception);
begin
  raise EDataError.Create('تعذر تنفيذ العملية: ' + E.Message);
end;

function TDM.Login(AUser, APass: string): Boolean;
var
  q: TADOQuery;
begin
  Result := False;
  q := TADOQuery.Create(nil);
  try
    q.Connection := Conn;
    q.SQL.Text :=
      'SELECT ID_EMP, ROLE FROM EMPLOYE ' +
      'WHERE USERNAME=:u AND PASSWORD=:p AND ACTIF=True';
    q.Parameters.ParamByName('u').Value := AUser;
    q.Parameters.ParamByName('p').Value := APass;
    q.Open;
    if not q.IsEmpty then
    begin
      FCurrentUser := q.FieldByName('ID_EMP').AsInteger;
      FCurrentRole := q.FieldByName('ROLE').AsString;
      FCurrentName := AUser;
      Result := True;
    end;
  finally
    q.Free;
  end;
end;

procedure TDM.OpenBraquiyat(AType, AEtat, AUrgence: string;
                            ADateFrom, ADateTo: TDate;
                            const ASearch: string = '');
var
  SQL: string;
begin
  try
    SQL :=
      'SELECT B.NUM_BRQ, B.DATE_REC, B.OBJET, B.URGENCE, ' +
      '       B.ETAT, B.TYPE_BRQ, J.NOM_JIHA ' +
      'FROM BRAQUIYA B ' +
      'LEFT JOIN JIHA J ON B.ID_JIHA = J.ID_JIHA ' +
      'WHERE B.DATE_REC BETWEEN :d1 AND :d2 ' +
      'AND B.ETAT <> :del ';
    if AType    <> '' then SQL := SQL + 'AND B.TYPE_BRQ = :tp ';
    if AEtat    <> '' then SQL := SQL + 'AND B.ETAT = :et ';
    if AUrgence <> '' then SQL := SQL + 'AND B.URGENCE = :ur ';
    if ASearch  <> '' then
      SQL := SQL +
        'AND (B.OBJET LIKE :s OR B.CONTENU LIKE :s OR J.NOM_JIHA LIKE :s) ';
    SQL := SQL + 'ORDER BY B.DATE_REC DESC';

    qBraquiya.Close;
    qBraquiya.SQL.Text := SQL;
    qBraquiya.Parameters.ParamByName('d1').Value  := ADateFrom;
    qBraquiya.Parameters.ParamByName('d2').Value  := ADateTo;
    qBraquiya.Parameters.ParamByName('del').Value := ST_MAHDHUF;
    if AType    <> '' then qBraquiya.Parameters.ParamByName('tp').Value := AType;
    if AEtat    <> '' then qBraquiya.Parameters.ParamByName('et').Value := AEtat;
    if AUrgence <> '' then qBraquiya.Parameters.ParamByName('ur').Value := AUrgence;
    if ASearch  <> '' then
      qBraquiya.Parameters.ParamByName('s').Value := '%' + ASearch + '%';
    qBraquiya.Open;
  except
    on E: Exception do RaiseDataError(E);
  end;
end;

procedure TDM.OpenNeedsRouting(ADateFrom, ADateTo: TDate);
begin
  try
    qBraquiya.Close;
    qBraquiya.SQL.Text :=
      'SELECT B.NUM_BRQ, B.DATE_REC, B.OBJET, B.URGENCE, ' +
      '       B.ETAT, B.TYPE_BRQ, J.NOM_JIHA ' +
      'FROM BRAQUIYA B ' +
      'LEFT JOIN JIHA J ON B.ID_JIHA = J.ID_JIHA ' +
      'WHERE B.DATE_REC BETWEEN :d1 AND :d2 ' +
      'AND B.ETAT IN (' + QuotedStr(ST_WAREDAH) + ',' +
                          QuotedStr(ST_SADERAH) + ',' +
                          QuotedStr(ST_MAWJAHA) + ',' +
                          QuotedStr(ST_MOALAJA) + ') ' +
      'ORDER BY B.DATE_REC DESC';
    qBraquiya.Parameters.ParamByName('d1').Value := ADateFrom;
    qBraquiya.Parameters.ParamByName('d2').Value := ADateTo;
    qBraquiya.Open;
  except
    on E: Exception do RaiseDataError(E);
  end;
end;

function TDM.OpenRecent(ALimit: Integer): TADOQuery;
begin
  try
    FqRecent.Close;
    FqRecent.SQL.Text := Format(
      'SELECT TOP %d B.NUM_BRQ, B.DATE_REC, J.NOM_JIHA, ' +
      '       B.OBJET, B.URGENCE, B.ETAT ' +
      'FROM BRAQUIYA B ' +
      'LEFT JOIN JIHA J ON B.ID_JIHA = J.ID_JIHA ' +
      'WHERE B.ETAT <> %s ' +
      'ORDER BY B.NUM_BRQ DESC', [ALimit, QuotedStr(ST_MAHDHUF)]);
    FqRecent.Open;
    Result := FqRecent;
  except
    on E: Exception do
    begin
      Result := FqRecent;
      RaiseDataError(E);
    end;
  end;
end;

function TDM.InsertBraquiya(AObjet, AType, AUrgence,
                            AContenu, ARem: string;
                            AJiha: Integer;
                            ADateRec: TDateTime): Integer;
var
  q: TADOQuery;
begin
  Result := -1;
  q := TADOQuery.Create(nil);
  try
    try
      q.Connection := Conn;
      q.SQL.Text :=
        'INSERT INTO BRAQUIYA ' +
        '(DATE_REC, OBJET, TYPE_BRQ, URGENCE, CONTENU, REMARQUES, ' +
        ' ID_JIHA, ID_EMP_ENREG, ETAT) ' +
        'VALUES (:dr, :ob, :tp, :ur, :ct, :rm, :jh, :em, :et)';
      q.Parameters.ParamByName('dr').Value := ADateRec;
      q.Parameters.ParamByName('ob').Value := AObjet;
      q.Parameters.ParamByName('tp').Value := AType;
      q.Parameters.ParamByName('ur').Value := AUrgence;
      q.Parameters.ParamByName('ct').Value := AContenu;
      q.Parameters.ParamByName('rm').Value := ARem;
      q.Parameters.ParamByName('jh').Value := AJiha;
      q.Parameters.ParamByName('em').Value := FCurrentUser;
      q.Parameters.ParamByName('et').Value := InitialState(AType);
      q.ExecSQL;

      // Retrieve the new auto-number (same connection). Fall back to MAX().
      q.SQL.Text := 'SELECT @@IDENTITY AS NewID';
      q.Open;
      if (not q.IsEmpty) and (not q.Fields[0].IsNull) and
         (q.Fields[0].AsInteger > 0) then
        Result := q.Fields[0].AsInteger
      else
      begin
        q.Close;
        q.SQL.Text := 'SELECT MAX(NUM_BRQ) AS NewID FROM BRAQUIYA';
        q.Open;
        Result := q.FieldByName('NewID').AsInteger;
      end;
    except
      on E: Exception do RaiseDataError(E);
    end;
  finally
    q.Free;
  end;
end;

procedure TDM.UpdateBraquiya(ANum: Integer;
                             AObjet, AUrgence, AContenu, ARem: string;
                             AJiha: Integer; ADateRec: TDateTime;
                             const AService: string);
var
  q: TADOQuery;
  SQL: string;
begin
  q := TADOQuery.Create(nil);
  try
    try
      q.Connection := Conn;
      SQL :=
        'UPDATE BRAQUIYA SET OBJET=:ob, URGENCE=:ur, CONTENU=:ct, ' +
        'REMARQUES=:rm, ID_JIHA=:jh, DATE_REC=:dr ';
      if FHasServiceCol then
        SQL := SQL + ', SERVICE=:sv ';
      SQL := SQL + 'WHERE NUM_BRQ=:nm';
      q.SQL.Text := SQL;
      q.Parameters.ParamByName('ob').Value := AObjet;
      q.Parameters.ParamByName('ur').Value := AUrgence;
      q.Parameters.ParamByName('ct').Value := AContenu;
      q.Parameters.ParamByName('rm').Value := ARem;
      q.Parameters.ParamByName('jh').Value := AJiha;
      q.Parameters.ParamByName('dr').Value := ADateRec;
      if FHasServiceCol then
        q.Parameters.ParamByName('sv').Value := AService;
      q.Parameters.ParamByName('nm').Value := ANum;
      q.ExecSQL;
    except
      on E: Exception do RaiseDataError(E);
    end;
  finally
    q.Free;
  end;
end;

function TDM.GetState(ANum: Integer): string;
var
  q: TADOQuery;
begin
  Result := '';
  q := TADOQuery.Create(nil);
  try
    q.Connection := Conn;
    q.SQL.Text := 'SELECT ETAT, TYPE_BRQ FROM BRAQUIYA WHERE NUM_BRQ=:n';
    q.Parameters.ParamByName('n').Value := ANum;
    q.Open;
    if not q.IsEmpty then
      Result := q.FieldByName('ETAT').AsString;
  finally
    q.Free;
  end;
end;

procedure TDM.SetEtatChecked(ANum: Integer; const ATo: string);
var
  CurState: string;
  q: TADOQuery;
begin
  try
    CurState := GetState(ANum);
    if not CanTransition(CurState, ATo) then
      raise EDataError.Create('انتقال الحالة غير مسموح به: ' +
        StateLabel(CurState) + ' ◄ ' + StateLabel(ATo));
    q := TADOQuery.Create(nil);
    try
      q.Connection := Conn;
      q.SQL.Text := 'UPDATE BRAQUIYA SET ETAT=:et WHERE NUM_BRQ=:nm';
      q.Parameters.ParamByName('et').Value := ATo;
      q.Parameters.ParamByName('nm').Value := ANum;
      q.ExecSQL;
    finally
      q.Free;
    end;
  except
    on E: EDataError do raise;
    on E: Exception do RaiseDataError(E);
  end;
end;

procedure TDM.SetService(ANum: Integer; const AService: string);
var
  q: TADOQuery;
begin
  if not FHasServiceCol then Exit;  // column not present — nothing to persist
  try
    q := TADOQuery.Create(nil);
    try
      q.Connection := Conn;
      q.SQL.Text := 'UPDATE BRAQUIYA SET SERVICE=:sv WHERE NUM_BRQ=:n';
      q.Parameters.ParamByName('sv').Value := AService;
      q.Parameters.ParamByName('n').Value  := ANum;
      q.ExecSQL;
    finally
      q.Free;
    end;
  except
    on E: Exception do RaiseDataError(E);
  end;
end;

procedure TDM.RouteBraquiya(ANum: Integer; const AService: string);
var
  CurState: string;
  q: TADOQuery;
begin
  try
    CurState := GetState(ANum);
    if not CanTransition(CurState, ST_MAWJAHA) then
      raise EDataError.Create('لا يمكن توجيه برقية حالتها: ' +
        StateLabel(CurState));
    q := TADOQuery.Create(nil);
    try
      q.Connection := Conn;
      if FHasServiceCol then
      begin
        q.SQL.Text :=
          'UPDATE BRAQUIYA SET ETAT=:et, SERVICE=:sv WHERE NUM_BRQ=:nm';
        q.Parameters.ParamByName('sv').Value := AService;
      end
      else
        q.SQL.Text := 'UPDATE BRAQUIYA SET ETAT=:et WHERE NUM_BRQ=:nm';
      q.Parameters.ParamByName('et').Value := ST_MAWJAHA;
      q.Parameters.ParamByName('nm').Value := ANum;
      q.ExecSQL;
    finally
      q.Free;
    end;
  except
    on E: EDataError do raise;
    on E: Exception do RaiseDataError(E);
  end;
end;

procedure TDM.MarkProcessed(ANum: Integer);
begin
  SetEtatChecked(ANum, ST_MOALAJA);
end;

procedure TDM.ArchiveBraquiya(ANum: Integer);
begin
  SetEtatChecked(ANum, ST_MORSAFA);
end;

procedure TDM.RestoreBraquiya(ANum: Integer);
var
  q: TADOQuery;
  TypeBrq: string;
begin
  try
    q := TADOQuery.Create(nil);
    try
      q.Connection := Conn;
      q.SQL.Text := 'SELECT TYPE_BRQ FROM BRAQUIYA WHERE NUM_BRQ=:n';
      q.Parameters.ParamByName('n').Value := ANum;
      q.Open;
      if q.IsEmpty then Exit;
      TypeBrq := q.FieldByName('TYPE_BRQ').AsString;
    finally
      q.Free;
    end;
    SetEtatChecked(ANum, InitialState(TypeBrq));
  except
    on E: EDataError do raise;
    on E: Exception do RaiseDataError(E);
  end;
end;

procedure TDM.SoftDelete(ANum: Integer);
begin
  SetEtatChecked(ANum, ST_MAHDHUF);
end;

function TDM.CountQuery(const ASQL: string): Integer;
var
  q: TADOQuery;
begin
  q := TADOQuery.Create(nil);
  try
    q.Connection := Conn;
    q.SQL.Text := ASQL;
    q.Open;
    Result := q.Fields[0].AsInteger;
  finally
    q.Free;
  end;
end;

function TDM.CountQuery(const ASQL, AParam: string;
                        const AValue: Variant): Integer;
var
  q: TADOQuery;
begin
  q := TADOQuery.Create(nil);
  try
    q.Connection := Conn;
    q.SQL.Text := ASQL;
    q.Parameters.ParamByName(AParam).Value := AValue;
    q.Open;
    Result := q.Fields[0].AsInteger;
  finally
    q.Free;
  end;
end;

function TDM.GetCountToday(AType: string): Integer;
begin
  Result := CountQuery(
    'SELECT COUNT(*) FROM BRAQUIYA ' +
    'WHERE TYPE_BRQ=:tp AND DateValue(DATE_REC)=DateValue(Now()) ' +
    'AND ETAT <> ' + QuotedStr(ST_MAHDHUF), 'tp', AType);
end;

function TDM.GetCountMonth(AType: string): Integer;
var
  SQL: string;
begin
  SQL :=
    'SELECT COUNT(*) FROM BRAQUIYA ' +
    'WHERE Year(DATE_REC)=Year(Now()) AND Month(DATE_REC)=Month(Now()) ' +
    'AND ETAT <> ' + QuotedStr(ST_MAHDHUF);
  if AType <> '' then
  begin
    Result := CountQuery(SQL + ' AND TYPE_BRQ=:tp', 'tp', AType);
    Exit;
  end;
  Result := CountQuery(SQL);
end;

function TDM.GetCountPending: Integer;
begin
  Result := CountQuery(
    'SELECT COUNT(*) FROM BRAQUIYA WHERE ETAT IN (' +
    QuotedStr(ST_WAREDAH) + ',' + QuotedStr(ST_SADERAH) + ',' +
    QuotedStr(ST_MAWJAHA) + ',' + QuotedStr(ST_MOALAJA) + ')');
end;

function TDM.GetCountByUrgency(AUrgence: string): Integer;
begin
  Result := CountQuery(
    'SELECT COUNT(*) FROM BRAQUIYA WHERE URGENCE=:u ' +
    'AND ETAT <> ' + QuotedStr(ST_MAHDHUF), 'u', AUrgence);
end;

function TDM.GetCountByState(AEtat: string): Integer;
begin
  Result := CountQuery(
    'SELECT COUNT(*) FROM BRAQUIYA WHERE ETAT=:e', 'e', AEtat);
end;

function TDM.ProbeColumn(const ATable, ACol: string): Boolean;
var
  q: TADOQuery;
begin
  Result := True;
  q := TADOQuery.Create(nil);
  try
    q.Connection := Conn;
    q.SQL.Text := Format('SELECT TOP 1 [%s] FROM [%s]', [ACol, ATable]);
    try
      q.Open;
    except
      Result := False;
    end;
  finally
    q.Free;
  end;
end;

function TDM.CheckSchema(out AMissing: string): Boolean;

  procedure Need(const ATable, ACol: string);
  begin
    if not ProbeColumn(ATable, ACol) then
      AMissing := AMissing + '  • ' + ATable + '.' + ACol + sLineBreak;
  end;

begin
  AMissing := '';
  Need('BRAQUIYA', 'NUM_BRQ');
  Need('BRAQUIYA', 'DATE_REC');
  Need('BRAQUIYA', 'OBJET');
  Need('BRAQUIYA', 'CONTENU');
  Need('BRAQUIYA', 'REMARQUES');
  Need('BRAQUIYA', 'URGENCE');
  Need('BRAQUIYA', 'TYPE_BRQ');
  Need('BRAQUIYA', 'ETAT');
  Need('BRAQUIYA', 'ID_JIHA');
  Need('BRAQUIYA', 'ID_EMP_ENREG');
  Need('JIHA', 'ID_JIHA');
  Need('JIHA', 'NOM_JIHA');
  Need('EMPLOYE', 'ID_EMP');
  Need('EMPLOYE', 'USERNAME');
  Need('EMPLOYE', 'PASSWORD');
  Need('EMPLOYE', 'ROLE');
  Need('EMPLOYE', 'ACTIF');

  // Optional column used for routing — does not block startup.
  FHasServiceCol := ProbeColumn('BRAQUIYA', 'SERVICE');

  Result := AMissing = '';
end;

function TDM.ChangePassword(AUserId: Integer;
                            const AOld, ANew: string): Boolean;
var
  q: TADOQuery;
begin
  Result := False;
  try
    q := TADOQuery.Create(nil);
    try
      q.Connection := Conn;
      q.SQL.Text :=
        'SELECT COUNT(*) FROM EMPLOYE WHERE ID_EMP=:id AND PASSWORD=:p';
      q.Parameters.ParamByName('id').Value := AUserId;
      q.Parameters.ParamByName('p').Value  := AOld;
      q.Open;
      if q.Fields[0].AsInteger = 0 then
        raise EDataError.Create('كلمة المرور الحالية غير صحيحة');
      q.Close;
      q.SQL.Text := 'UPDATE EMPLOYE SET PASSWORD=:np WHERE ID_EMP=:id';
      q.Parameters.ParamByName('np').Value := ANew;
      q.Parameters.ParamByName('id').Value := AUserId;
      q.ExecSQL;
      Result := True;
    finally
      q.Free;
    end;
  except
    on E: EDataError do raise;
    on E: Exception do RaiseDataError(E);
  end;
end;

end.
