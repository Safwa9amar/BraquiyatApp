# نظام تسيير البرقيات — BraquiyatApp

نظام معلوماتي لتسيير البرقيات الإدارية (الواردة والصادرة) على مستوى **دائرة بوعلام – ولاية البيض**،
أُنجز في إطار مذكرة تخرج لنيل شهادة تقني سامي في الإعلام الآلي (تخصص قاعدة معطيات).

A desktop information system for managing administrative telegrams/dispatches (incoming **الوارد**
and outgoing **الصادر**) for the Daïra of Boualam, El‑Bayadh — Algeria. Built with **Delphi (Object
Pascal, VCL)** over a **Microsoft Access** database, following the **MERISE** analysis method.

---

## التقنيات / Tech stack

- **Delphi 12 (RAD Studio), VCL, Win32**
- **Microsoft Access (`Braquiyat.accdb`)** via ADO (`Microsoft.ACE.OLEDB.12.0`)
- Right‑to‑left (Arabic) UI, themed with **VCL Styles**

## بنية المشروع / Project structure

| Path | Role |
|------|------|
| `BraquiyatApp.dpr` | Program entry — applies the VCL style and runs a DB schema self‑check on startup |
| `DataModule/uDM.pas` | Data access: connection, login, telegram CRUD, **state lifecycle**, statistics, diagnostics |
| `Utils/uConsts.pas` | Domain codes (type/state/urgency), Arabic labels, lifecycle rules, services list |
| `Utils/uTheme.pas` | VCL style management, accent colors, status/urgency badges, grid helpers |
| `Utils/uUtils.pas` | CSV / HTML export and print helpers |
| `Forms/uLogin` | Login |
| `Forms/uMain` | Main shell (sidebar navigation, embedded content panels) |
| `Forms/uDashboard` | Stat cards, recent telegrams, urgency/state breakdowns |
| `Forms/uWared` / `uSader` | Incoming / outgoing telegram lists (search, badges, print/export) |
| `Forms/uFormBraquiya` | Add / edit a telegram |
| `Forms/uRouting` | **Workflow**: route → process → archive a telegram |
| `Forms/uArchive` | Archived telegrams (filter by year/month/type, restore) |
| `Forms/uReports` | Reports (preview + HTML/CSV export) |
| `Forms/uSettings` | Change password, switch theme, verify DB connection |

## دورة حياة البرقية / Telegram lifecycle

`واردة/صادرة → موجهة → معالجة → مؤرشفة` (received → routed → processed → archived), with
soft‑delete. Transitions are guarded centrally in `uConsts.CanTransition`.

---

## البناء / Building

1. Open `BraquiyatApp.dproj` in **Delphi 12** (Win32).
2. **Enable the VCL style** (one‑time): *Project ▸ Options ▸ Application ▸ Appearance* → tick
   **Windows11 Modern Light** (and *Dark* if desired) and set it as the Default Style. This embeds
   the style resource. If skipped, the app still runs on the OS theme.
3. Build & run. The app reads `Braquiyat.accdb` from the executable's folder.

### خطوات يدوية في قاعدة البيانات / Manual database steps

The startup self‑check reports any missing tables/columns in Arabic. For full functionality:

- **(Routing)** add a nullable text column `SERVICE` (Short Text, 100) to table `BRAQUIYA` — used to
  store the service a telegram is routed to. Without it, routing still advances the state but does
  not store the service name.
- Confirm `BRAQUIYA.NUM_BRQ` is an **AutoNumber** key.
- Ensure `ETAT` / `URGENCE` have no validation rules that would reject the lifecycle codes
  (`WAREDAH, SADERAH, MAWJAHA, MOALAJA, MORSAFA, MAHDHUF`) or the urgency code `IDARI`.

> Note: passwords are currently stored as plain text in the sample database (legacy behaviour).
> The Settings screen lets users change their password; hashing is a recommended future enhancement.

---

## رخصة / License

Academic graduation project. Provided as‑is for educational reference.
