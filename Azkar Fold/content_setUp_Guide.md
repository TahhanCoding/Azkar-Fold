# Sunnah Azkar Content Guide

## Source of truth

Sunnah azkar content is loaded at runtime from the bundled SQLite database:

- **Runtime:** `Azkar Fold/Azkar Fold/azkar-db-master/azkar-db`
- **Edit copy:** `Azkar Fold/azkar-db-master/azkar-db` (same file, kept in repo for maintenance)
- **Exports:** `azkar_obj.json` / `azkar.csv` in `azkar-db-master/` are optional exports only — the app does not read them

## App categories

| App category | DB `category` |
|---|---|
| Morning | أذكار الصباح |
| Evening | أذكار المساء |
| After Prayer | الأذكار بعد السلام من الصلاة |
| Before Sleeping | أذكار النوم |
| Waking Up | أذكار الاستيقاظ من النوم |

## Updating content

1. Edit `azkar-db` using [DB Browser for SQLite](https://sqlitebrowser.org/) or [SQLiteStudio](https://sqlitestudio.pl/).
2. Replace both copies in the repo:
   - `Azkar Fold/Azkar Fold/azkar-db-master/azkar-db` (bundled in app)
   - `Azkar Fold/azkar-db-master/azkar-db` (maintenance copy)
3. Optionally re-export JSON/CSV from the database for other tools.
4. Ship a new app build.

### Restructuring Sunnah categories

To re-parse and split Prayer / Sleep / Wakeup rows into one-dhikr-per-row format:

```bash
python3 "Azkar Fold/scripts/restructure_sunnah_azkar.py" --dry-run
python3 "Azkar Fold/scripts/restructure_sunnah_azkar.py" --apply
```

Review output: `Azkar Fold/scripts/restructure_review.csv`

## Field mapping

| SQLite column | App field |
|---|---|
| `zekr` | zekr text |
| `description` | bless |
| `count` | repeat count (defaults to 1 if null) |
| `reference` | source |

## Languages

azkar-db is Arabic-only. Secondary language settings are hidden until translations are added.

## Firebase

Firebase is used for Remote Config (app version checks), Analytics without Ad ID (anonymous usage), and Crashlytics (crash diagnostics)—not for azkar content.
