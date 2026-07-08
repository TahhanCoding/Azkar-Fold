#!/usr/bin/env python3
"""Restructure Prayer, Sleep, and Wakeup rows in azkar-db."""

from __future__ import annotations

import argparse
import csv
import re
import shutil
import sqlite3
from dataclasses import dataclass
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DB_MAINT = REPO_ROOT / "Azkar Fold" / "azkar-db-master" / "azkar-db"
DB_BUNDLE = REPO_ROOT / "Azkar Fold" / "Azkar Fold" / "azkar-db-master" / "azkar-db"

CATEGORY_PRAYER = "الأذكار بعد السلام من الصلاة"
CATEGORY_SLEEP = "أذكار النوم"
CATEGORY_WAKEUP = "أذكار الاستيقاظ من النوم"

TARGET_CATEGORIES = [CATEGORY_PRAYER, CATEGORY_SLEEP, CATEGORY_WAKEUP]

SURAH_IKHLAS = (
    "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\n"
    "قُلْ هُوَ ٱللَّهُ أَحَدٌ، ٱللَّهُ ٱلصَّمَدُ، لَمْ يَلِدْ وَلَمْ يُولَدْ، وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ."
)
SURAH_FALAQ = (
    "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\n"
    "قُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ، مِن شَرِّ مَا خَلَقَ، وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ، "
    "وَمِن شَرِّ ٱلنَّفَّاثَاتِ فِى ٱلْعُقَدِ، وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ."
)
SURAH_NAS = (
    "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\n"
    "قُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ، مَلِكِ ٱلنَّاسِ، إِلَٰهِ ٱلنَّاسِ، مِن شَرِّ ٱلْوَسْوَاسِ ٱلْخَنَّاسِ، "
    "ٱلَّذِى يُوَسْوِسُ فِى صُدُورِ ٱلنَّاسِ، مِنَ ٱلْجِنَّةِ وَٱلنَّاسِ."
)


@dataclass
class AzkarRow:
    category: str
    zekr: str
    description: str | None
    count: int
    reference: str | None
    search: str


def strip_wrappers(text: str) -> str:
    value = text.strip()
    value = re.sub(r"^\(\(", "", value)
    value = re.sub(r"\)\)\.?$", "", value)
    value = re.sub(r"^\(", "", value)
    value = re.sub(r"\)\.?$", "", value)
    return value.strip()


def split_trailing_note(text: str) -> tuple[str, str | None]:
    patterns = [
        r"(.+?)\s+(بَعْدَ كُلِّ صَلاَةٍ\.?)$",
        r"(.+?)\s+(عَقِبَ كلِّ صَلاَةٍ\.?)$",
        r"(.+?)\s+(عَشْرَ مَرّاتٍ بَعْدَ صَلاةِ الْمَغْرِبِ وَالصُّبْحِ\.?)$",
        r"(.+?)\s+(بَعْدَ السّلامِ مِنْ صَلاَةِ الفَجْرِ\.?)$",
    ]
    for pattern in patterns:
        match = re.match(pattern, text.strip(), flags=re.DOTALL)
        if match:
            return match.group(1).strip(), match.group(2).strip()
    return text.strip(), None


def merge_description(*parts: str | None) -> str | None:
    values = [part.strip() for part in parts if part and part.strip()]
    if not values:
        return None
    return "\n".join(values)


def row(
    category: str,
    zekr: str,
    count: int = 1,
    description: str | None = None,
    reference: str | None = None,
) -> AzkarRow:
    return AzkarRow(
        category=category,
        zekr=zekr.strip(),
        description=description,
        count=count,
        reference=reference,
        search=category,
    )


def parse_prayer(rows: list[tuple]) -> list[AzkarRow]:
  del rows
  return [
      row(CATEGORY_PRAYER, "أَسْتَغْفِرُ اللَّهَ", count=3),
      row(
          CATEGORY_PRAYER,
          "اللَّهُمَّ أَنْتَ السَّلاَمُ، وَمِنْكَ السَّلاَمُ، تَبَارَكْتَ يَا ذَا الْجَلاَلِ وَالْإِكْرَامِ",
      ),
      row(
          CATEGORY_PRAYER,
          "لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
          count=3,
      ),
      row(
          CATEGORY_PRAYER,
          "اللَّهُمَّ لاَ مَانِعَ لِمَا أَعْطَيْتَ، وَلاَ مُعْطِيَ لِمَا مَنَعْتَ، وَلاَ يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ",
      ),
      row(
          CATEGORY_PRAYER,
          "لَا إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ، وَلَهُ الْحَمدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ. "
          "لاَ حَوْلَ وَلاَ قُوَّةَ إِلاَّ بِاللَّهِ، لاَ إِلَهَ إِلاَّ اللَّهُ، وَلاَ نَعْبُدُ إِلاَّ إِيَّاهُ، لَهُ النِّعْمَةُ وَلَهُ الْفَضْلُ وَلَهُ الثَّنَاءُ الْحَسَنُ، "
          "لَا إِلَهَ إِلاَّ اللَّهُ مُخْلِصِينَ لَهُ الدِّينَ وَلَوْ كَرِهَ الكَافِرُونَ",
      ),
      row(CATEGORY_PRAYER, "سُبْحَانَ اللَّهِ", count=33),
      row(CATEGORY_PRAYER, "الْحَمْدُ لِلَّهِ", count=33),
      row(CATEGORY_PRAYER, "اللَّهُ أَكْبَرُ", count=33),
      row(
          CATEGORY_PRAYER,
          "لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
      ),
      row(CATEGORY_PRAYER, SURAH_IKHLAS, count=3, description="بَعْدَ كُلِّ صَلاَةٍ"),
      row(CATEGORY_PRAYER, SURAH_FALAQ, count=3, description="بَعْدَ كُلِّ صَلاَةٍ"),
      row(CATEGORY_PRAYER, SURAH_NAS, count=3, description="بَعْدَ كُلِّ صَلاَةٍ"),
      row(
          CATEGORY_PRAYER,
          "اللَّهُ لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَّهُ مَا فِي السَّمَوَاتِ وَمَا فِي الأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلاَّ بِإِذْنِهِ "
          "يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلاَ يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلاَّ بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَوَاتِ وَالأَرْضَ وَلاَ يَؤُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ",
          description="عَقِبَ كُلِّ صَلاَةٍ",
          reference="آية الكرسى - سورة البقرة 255",
      ),
      row(
          CATEGORY_PRAYER,
          "لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ يُحْيِي وَيُمِيتُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
          count=10,
          description="بَعْدَ صَلاةِ الْمَغْرِبِ وَالصُّبْحِ",
      ),
      row(
          CATEGORY_PRAYER,
          "اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْماً نافِعاً، وَرِزْقاً طَيِّباً، وَعَمَلاً مُتَقَبَّلاً",
          description="بَعْدَ السّلامِ مِنْ صَلاَةِ الفَجْرِ",
      ),
  ]


def parse_sleep(rows: list[tuple]) -> list[AzkarRow]:
    by_rowid = {item[0]: item for item in rows}
    result: list[AzkarRow] = []

    sleep_136_description = (
        "يَجْمَعُ كَفَّيْهِ ثُمَّ يَنْفُثُ فِيهِمَا فَيَقْرَأُ فِيهِمَا، ثُمَّ يَمْسَحُ بِهِمَا مَا اسْتَطَاعَ "
        "مِنْ جَسَدِهِ يَبْدَأُ بِهِمَا عَلَى رَأْسِهِ وَوَجْهِهِ وَمَا أَقْبَلَ مِنْ جَسَدِهِ. يُفْعَلُ ذَلِكَ ثَلَاثَ مَرَّاتٍ."
    )

    result.extend(
        [
            row(CATEGORY_SLEEP, SURAH_IKHLAS, count=1, description=sleep_136_description),
            row(CATEGORY_SLEEP, SURAH_FALAQ, count=1, description=sleep_136_description),
            row(CATEGORY_SLEEP, SURAH_NAS, count=1, description=sleep_136_description),
        ]
    )

    row137 = by_rowid[137]
    result.append(
        row(
            CATEGORY_SLEEP,
            strip_wrappers(row137[1]),
            count=1,
            reference=row137[4] or "آية الكرسى - سورة البقرة 255",
        )
    )

    row138 = by_rowid[138]
    result.append(
        row(
            CATEGORY_SLEEP,
            row138[1].strip(),
            count=1,
            description=row138[2] or "من قرأ آيتين من آخر سورة البقرة في ليلة كفتاه.",
            reference=row138[4] or "سورة البقرة 285 - 286",
        )
    )

    simple_sleep_rows = [139, 140, 141, 142, 145, 146, 148]
    for rowid in simple_sleep_rows:
        source = by_rowid[rowid]
        result.append(
            row(
                CATEGORY_SLEEP,
                strip_wrappers(source[1]),
                count=source[3] or 1,
                description=source[2] or None,
                reference=source[4] or None,
            )
        )

    result.extend(
        [
            row(CATEGORY_SLEEP, "سُبْحَانَ اللَّهِ", count=33),
            row(CATEGORY_SLEEP, "الْحَمْدُ لِلَّهِ", count=33),
            row(CATEGORY_SLEEP, "اللَّهُ أَكْبَرُ", count=34),
        ]
    )

    row144 = by_rowid[144]
    result.append(
        row(
            CATEGORY_SLEEP,
            strip_wrappers(row144[1]),
            count=1,
            description=row144[2] or None,
            reference=row144[4] or None,
        )
    )

    return result


def parse_wakeup(rows: list[tuple]) -> list[AzkarRow]:
    by_rowid = {item[0]: item for item in rows}
    result: list[AzkarRow] = []

    for rowid in [62, 63, 64]:
        source = by_rowid[rowid]
        result.append(
            row(
                CATEGORY_WAKEUP,
                strip_wrappers(source[1]),
                count=source[3] or 1,
                description=source[2] or None,
                reference=source[4] or None,
            )
        )

    row65 = by_rowid[65]
    result.append(
        row(
            CATEGORY_WAKEUP,
            row65[1].strip(),
            count=1,
            description="آيَاتٌ مِنْ سُورَةِ آلِ عِمْرَانَ",
            reference=row65[4] or "سورة آل عمران 190 - 200",
        )
    )

    return result


def load_source_rows(db_path: Path) -> dict[str, list[tuple]]:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    grouped: dict[str, list[tuple]] = {}
    for category in TARGET_CATEGORIES:
        cursor.execute(
            """
            SELECT rowid, zekr, description, count, reference
            FROM azkar
            WHERE category = ?
            ORDER BY rowid
            """,
            (category,),
        )
        grouped[category] = cursor.fetchall()
    conn.close()
    return grouped


def build_restructured_rows(source: dict[str, list[tuple]]) -> list[AzkarRow]:
    rows: list[AzkarRow] = []
    rows.extend(parse_prayer(source[CATEGORY_PRAYER]))
    rows.extend(parse_sleep(source[CATEGORY_SLEEP]))
    rows.extend(parse_wakeup(source[CATEGORY_WAKEUP]))
    return rows


def write_csv(rows: list[AzkarRow], output_path: Path) -> None:
    with output_path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(["category", "zekr", "count", "description", "reference", "search"])
        for item in rows:
            writer.writerow(
                [
                    item.category,
                    item.zekr,
                    item.count,
                    item.description or "",
                    item.reference or "",
                    item.search,
                ]
            )


def apply_migration(db_path: Path, rows: list[AzkarRow]) -> None:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    for category in TARGET_CATEGORIES:
        cursor.execute("DELETE FROM azkar WHERE category = ?", (category,))
    cursor.executemany(
        """
        INSERT INTO azkar (category, zekr, description, count, reference, search)
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        [
            (
                item.category,
                item.zekr,
                item.description,
                item.count,
                item.reference,
                item.search,
            )
            for item in rows
        ],
    )
    conn.commit()
    conn.close()


def print_summary(rows: list[AzkarRow]) -> None:
    counts: dict[str, int] = {}
    for item in rows:
        counts[item.category] = counts.get(item.category, 0) + 1
    print("Restructured row counts:")
    for category in TARGET_CATEGORIES:
        print(f"  {category}: {counts.get(category, 0)}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Restructure Sunnah azkar categories in azkar-db")
    parser.add_argument("--db", type=Path, default=DB_MAINT, help="Path to azkar-db SQLite file")
    parser.add_argument("--dry-run", action="store_true", help="Preview changes without writing")
    parser.add_argument("--apply", action="store_true", help="Apply changes to --db and sync bundle copy")
    parser.add_argument("--output", type=Path, default=REPO_ROOT / "Azkar Fold" / "scripts" / "restructure_review.csv")
    args = parser.parse_args()

    if not args.dry_run and not args.apply:
        parser.error("Use --dry-run or --apply")

    source = load_source_rows(args.db)
    rows = build_restructured_rows(source)
    print_summary(rows)
    write_csv(rows, args.output)
    print(f"Review CSV written to: {args.output}")

    if args.apply:
        apply_migration(args.db, rows)
        shutil.copy2(args.db, DB_BUNDLE)
        print(f"Applied migration to: {args.db}")
        print(f"Synced bundle copy to: {DB_BUNDLE}")


if __name__ == "__main__":
    main()
