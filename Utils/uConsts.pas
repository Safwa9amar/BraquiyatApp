unit uConsts;

{
  Centralized domain codes, Arabic display labels, and the telegram state
  lifecycle for BraquiyatApp.

  Arabic labels are written with the #NNNN numeric-character encoding (the same
  convention used throughout the project's .pas/.dfm files) so this source stays
  codepage-safe regardless of the editor's encoding.

  These codes are the authoritative values stored in the Access database
  (columns TYPE_BRQ, ETAT, URGENCE). Every form/unit should reference these
  constants instead of repeating magic strings.
}

interface

uses
  System.SysUtils, System.Classes;

const
  // ── Direction (BRAQUIYA.TYPE_BRQ) ─────────────────────────────
  TYP_WARED = 'WARED';   // وارد  (incoming)
  TYP_SADER = 'SADER';   // صادر  (outgoing)

  // ── State (BRAQUIYA.ETAT) ─────────────────────────────────────
  ST_WAREDAH = 'WAREDAH';  // واردة        (incoming, initial)
  ST_SADERAH = 'SADERAH';  // صادرة        (outgoing, initial)
  ST_MAWJAHA = 'MAWJAHA';  // موجهة        (routed to a service)
  ST_MOALAJA = 'MOALAJA';  // معالجة       (processed)
  ST_MORSAFA = 'MORSAFA';  // مؤرشفة       (archived)
  ST_MAHDHUF = 'MAHDHUF';  // محذوفة       (soft-deleted)

  // ── Urgency (BRAQUIYA.URGENCE) ────────────────────────────────
  URG_AJIL  = 'AJIL';    // عاجل
  URG_ADI   = 'ADI';     // عادي
  URG_SIRRI = 'SIRRI';   // سري
  URG_IDARI = 'IDARI';   // إداري (administrative)

  // ── Business rule ─────────────────────────────────────────────
  NORMAL_PROCESS_HOURS = 48;  // a normal telegram must be handled within 48h

function StateLabel(const ACode: string): string;     // code -> Arabic label
function StateCode(const ALabel: string): string;      // Arabic label -> code
function UrgencyLabel(const ACode: string): string;
function UrgencyCode(const ALabel: string): string;
function TypeLabel(const ACode: string): string;

// Arabic column header for a BRAQUIYA field name (for exports/reports)
function HeaderLabel(const AField: string): string;

// WARED -> WAREDAH, SADER -> SADERAH
function InitialState(const ATypeBRQ: string): string;

// Is a record in this state still "active" (not archived/deleted)?
function IsActiveState(const AState: string): Boolean;

// Lifecycle guard: may a record move from AFrom to ATo?
function CanTransition(const AFrom, ATo: string): Boolean;

// Fill a combo/list with the internal services (المصالح). Item 0 is a prompt.
procedure FillServices(AItems: TStrings);

implementation

function StateLabel(const ACode: string): string;
begin
  if ACode = ST_WAREDAH then
    Result := #1608#1575#1585#1583#1577            // واردة
  else if ACode = ST_SADERAH then
    Result := #1589#1575#1583#1585#1577            // صادرة
  else if ACode = ST_MAWJAHA then
    Result := #1605#1608#1580#1607#1577            // موجهة
  else if ACode = ST_MOALAJA then
    Result := #1605#1593#1575#1604#1580#1577       // معالجة
  else if ACode = ST_MORSAFA then
    Result := #1605#1572#1585#1588#1601#1577       // مؤرشفة
  else if ACode = ST_MAHDHUF then
    Result := #1605#1581#1584#1608#1601#1577       // محذوفة
  else
    Result := ACode;
end;

function StateCode(const ALabel: string): string;
begin
  if ALabel = #1608#1575#1585#1583#1577 then
    Result := ST_WAREDAH
  else if ALabel = #1589#1575#1583#1585#1577 then
    Result := ST_SADERAH
  else if ALabel = #1605#1608#1580#1607#1577 then
    Result := ST_MAWJAHA
  else if ALabel = #1605#1593#1575#1604#1580#1577 then
    Result := ST_MOALAJA
  else if ALabel = #1605#1572#1585#1588#1601#1577 then
    Result := ST_MORSAFA
  else if ALabel = #1605#1581#1584#1608#1601#1577 then
    Result := ST_MAHDHUF
  else
    Result := '';
end;

function UrgencyLabel(const ACode: string): string;
begin
  if ACode = URG_AJIL then
    Result := #1593#1575#1580#1604                 // عاجل
  else if ACode = URG_ADI then
    Result := #1593#1575#1583#1610                 // عادي
  else if ACode = URG_SIRRI then
    Result := #1587#1585#1610                      // سري
  else if ACode = URG_IDARI then
    Result := #1573#1583#1575#1585#1610            // إداري
  else
    Result := ACode;
end;

function UrgencyCode(const ALabel: string): string;
begin
  if ALabel = #1593#1575#1580#1604 then
    Result := URG_AJIL
  else if ALabel = #1593#1575#1583#1610 then
    Result := URG_ADI
  else if ALabel = #1587#1585#1610 then
    Result := URG_SIRRI
  else if ALabel = #1573#1583#1575#1585#1610 then
    Result := URG_IDARI
  else
    Result := '';
end;

function TypeLabel(const ACode: string): string;
begin
  if ACode = TYP_WARED then
    Result := #1608#1575#1585#1583                 // وارد
  else if ACode = TYP_SADER then
    Result := #1589#1575#1583#1585                 // صادر
  else
    Result := ACode;
end;

function HeaderLabel(const AField: string): string;
var
  F: string;
begin
  F := UpperCase(AField);
  if F = 'NUM_BRQ' then
    Result := #1585#1602#1605' '#1575#1604#1576#1585#1602#1610#1577        // رقم البرقية
  else if F = 'DATE_REC' then
    Result := #1575#1604#1578#1575#1585#1610#1582                          // التاريخ
  else if F = 'OBJET' then
    Result := #1575#1604#1605#1608#1590#1608#1593                          // الموضوع
  else if F = 'CONTENU' then
    Result := #1606#1589' '#1575#1604#1576#1585#1602#1610#1577            // نص البرقية
  else if F = 'REMARQUES' then
    Result := #1605#1604#1575#1581#1592#1575#1578                          // ملاحظات
  else if F = 'URGENCE' then
    Result := #1575#1604#1575#1587#1578#1593#1580#1575#1604               // الاستعجال
  else if F = 'TYPE_BRQ' then
    Result := #1575#1604#1606#1608#1593                                    // النوع
  else if F = 'ETAT' then
    Result := #1575#1604#1581#1575#1604#1577                              // الحالة
  else if F = 'NOM_JIHA' then
    Result := #1575#1604#1580#1607#1577' '#1575#1604#1605#1585#1587#1604#1577 // الجهة المرسلة
  else if F = 'SERVICE' then
    Result := #1575#1604#1605#1589#1604#1581#1577                          // المصلحة
  else if F = 'MSG_REF' then
    Result := #1585#1602#1605' '#1575#1604#1573#1585#1587#1575#1604        // رقم الإرسال
  else if F = 'REF_NUM' then
    Result := #1585#1602#1605' '#1575#1604#1605#1585#1575#1587#1604#1577   // رقم المراسلة
  else if F = 'HEURE' then
    Result := #1575#1604#1608#1602#1578                                    // الوقت
  else if F = 'DESTINATAIRE' then
    Result := #1575#1604#1605#1585#1587#1604' '#1573#1604#1610#1607        // المرسل إليه
  else if F = 'SIGNATAIRE' then
    Result := #1575#1604#1605#1605#1590#1610                               // الممضي
  else if F = 'TABLIGH' then
    Result := #1580#1607#1577' '#1575#1604#1578#1576#1604#1610#1594        // جهة التبليغ
  else if F = 'REF_PREC' then
    Result := #1575#1604#1605#1585#1580#1593                               // المرجع
  else if F = 'COPIE' then
    Result := #1606#1587#1582#1577' '#1573#1604#1609                       // نسخة إلى
  else if F = 'NUM_ARRIVEE' then
    Result := #1585#1602#1605' '#1575#1604#1608#1575#1585#1583            // رقم الوارد
  else if F = 'DATE_ARRIVEE' then
    Result := #1578#1575#1585#1610#1582' '#1575#1604#1608#1585#1608#1583  // تاريخ الورود
  else if F = 'ATTACHMENT' then
    Result := #1575#1604#1605#1604#1601' '#1575#1604#1605#1585#1601#1602   // الملف المرفق
  else
    Result := AField;
end;

function InitialState(const ATypeBRQ: string): string;
begin
  if ATypeBRQ = TYP_SADER then
    Result := ST_SADERAH
  else
    Result := ST_WAREDAH;
end;

function IsActiveState(const AState: string): Boolean;
begin
  Result := (AState = ST_WAREDAH) or (AState = ST_SADERAH) or
            (AState = ST_MAWJAHA) or (AState = ST_MOALAJA);
end;

procedure FillServices(AItems: TStrings);
begin
  AItems.Clear;
  AItems.Add('-- ' + #1575#1582#1578#1585' '#1575#1604#1605#1589#1604#1581#1577 + ' --');   // اختر المصلحة
  AItems.Add(#1605#1603#1578#1576' '#1575#1604#1578#1606#1592#1610#1605' '#1608#1575#1604#1588#1572#1608#1606' '#1575#1604#1593#1575#1605#1577);                 // مكتب التنظيم والشؤون العامة
  AItems.Add(#1605#1603#1578#1576' '#1575#1604#1608#1589#1575#1610#1577);                                                                                     // مكتب الوصاية
  AItems.Add(#1605#1603#1578#1576' '#1575#1604#1578#1580#1607#1610#1586);                                                                                     // مكتب التجهيز
  AItems.Add(#1605#1603#1578#1576' '#1575#1604#1588#1572#1608#1606' '#1575#1604#1575#1580#1578#1605#1575#1593#1610#1577' '#1608#1581#1585#1603#1577' '#1575#1604#1580#1605#1593#1610#1575#1578); // مكتب الشؤون الاجتماعية وحركة الجمعيات
  AItems.Add(#1605#1603#1578#1576' '#1575#1604#1587#1603#1606);                                                                                               // مكتب السكن
  AItems.Add(#1605#1603#1578#1576' '#1575#1604#1575#1606#1578#1582#1575#1576#1575#1578);                                                                       // مكتب الانتخابات
  AItems.Add(#1605#1603#1578#1576' '#1575#1604#1601#1604#1575#1581#1577);                                                                                     // مكتب الفلاحة
  AItems.Add(#1605#1603#1578#1576' '#1575#1604#1605#1589#1604#1581#1577' '#1575#1604#1576#1610#1608#1605#1578#1585#1610#1577);                                 // مكتب المصلحة البيومترية
  AItems.Add(#1575#1604#1571#1605#1575#1606#1577' '#1575#1604#1593#1575#1605#1577);                                                                           // الأمانة العامة
  AItems.Add(#1605#1603#1578#1576' '#1605#1606#1583#1608#1576#1610#1577' '#1575#1604#1571#1605#1606);                                                         // مكتب مندوبية الأمن
end;

function CanTransition(const AFrom, ATo: string): Boolean;
begin
  Result := False;
  if AFrom = ATo then
    Exit;

  // Soft delete: any active record, or an archived one, can be deleted
  if ATo = ST_MAHDHUF then
    Exit(IsActiveState(AFrom) or (AFrom = ST_MORSAFA));

  // Restore: an archived or deleted record returns to an initial state
  if (ATo = ST_WAREDAH) or (ATo = ST_SADERAH) then
    Exit((AFrom = ST_MORSAFA) or (AFrom = ST_MAHDHUF));

  // Route: an incoming/outgoing item is directed to a service
  if ATo = ST_MAWJAHA then
    Exit((AFrom = ST_WAREDAH) or (AFrom = ST_SADERAH));

  // Process
  if ATo = ST_MOALAJA then
    Exit((AFrom = ST_WAREDAH) or (AFrom = ST_SADERAH) or (AFrom = ST_MAWJAHA));

  // Archive
  if ATo = ST_MORSAFA then
    Exit((AFrom = ST_MAWJAHA) or (AFrom = ST_MOALAJA));
end;

end.
