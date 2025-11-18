#!/usr/bin/env python3
"""
Validation Script for Cambridge_Vocabulary_2018_PERFECT.csv

Run this AFTER N8N AI generation completes to verify data quality.

Usage:
    python3 validate_perfect_csv.py
"""

import csv
import re
from collections import defaultdict

# Configuration
CSV_FILE = 'Cambridge_Vocabulary_2018_PERFECT.csv'

# Fields that should be filled by N8N
AI_FIELDS = [
    'translationVi',
    'definitionEn',
    'definitionVi',
    'ipaGB',
    'ipaUS',
    'exampleStarters',
    'exampleMovers',
    'exampleFlyers',
    'exampleStartersVi',
    'exampleMoversVi',
    'exampleFlyersVi'
]


def validate_ipa(ipa_string):
    """Check if IPA notation is valid"""
    if not ipa_string:
        return False

    # IPA should be enclosed in slashes
    if not (ipa_string.startswith('/') and ipa_string.endswith('/')):
        return False

    # Should contain IPA symbols
    ipa_symbols = r'[æɑɔəɪʊɛʌaɜːiːuːɒeɔːɑːʃʒθðŋtʃdʒˈˌ]'
    if not re.search(ipa_symbols, ipa_string):
        return False

    return True


def validate_example_uses_word(example, word):
    """Check if example sentence uses the target word"""
    if not example or not word:
        return True  # Skip empty examples

    word_lower = word.lower()
    example_lower = example.lower()

    # Check if word appears in example
    # Handle plural/verb forms
    word_stem = word_lower.rstrip('s').rstrip('e').rstrip('ing').rstrip('ed')

    return (word_lower in example_lower or
            word_stem in example_lower or
            word_lower + 's' in example_lower or
            word_lower + 'es' in example_lower)


def validate_csv():
    """Main validation function"""

    print("=" * 80)
    print("📊 Validating Cambridge_Vocabulary_2018_PERFECT.csv")
    print("=" * 80)
    print()

    # Stats
    total = 0
    stats = {field: 0 for field in AI_FIELDS}
    issues = []

    # Issue tracking
    ipa_format_issues = []
    example_word_issues = []
    translation_issues = []
    definition_issues = []

    with open(CSV_FILE, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)

        for idx, row in enumerate(reader, 1):
            total += 1
            word = row['british'].strip()

            # Check completeness
            for field in AI_FIELDS:
                value = row.get(field, '').strip()
                if value:
                    stats[field] += 1
                else:
                    issues.append(f"Line {idx} ({word}): Missing {field}")

            # Validate IPA format
            ipa_gb = row.get('ipaGB', '').strip()
            ipa_us = row.get('ipaUS', '').strip()

            if ipa_gb and not validate_ipa(ipa_gb):
                ipa_format_issues.append(f"Line {idx} ({word}): ipaGB invalid format: {ipa_gb}")

            if ipa_us and not validate_ipa(ipa_us):
                ipa_format_issues.append(f"Line {idx} ({word}): ipaUS invalid format: {ipa_us}")

            # Validate examples use the word
            examples = [
                ('exampleStarters', row.get('exampleStarters', '').strip()),
                ('exampleMovers', row.get('exampleMovers', '').strip()),
                ('exampleFlyers', row.get('exampleFlyers', '').strip())
            ]

            for field_name, example in examples:
                if example and not validate_example_uses_word(example, word):
                    example_word_issues.append(
                        f"Line {idx} ({word}): {field_name} doesn't use word: '{example}'"
                    )

            # Check translation not empty or same as word
            translation = row.get('translationVi', '').strip()
            if translation and translation.lower() == word.lower():
                translation_issues.append(
                    f"Line {idx} ({word}): translationVi same as English word"
                )

            # Check definitions not too short
            def_en = row.get('definitionEn', '').strip()
            def_vi = row.get('definitionVi', '').strip()

            if def_en and len(def_en.split()) < 5:
                definition_issues.append(
                    f"Line {idx} ({word}): definitionEn too short ({len(def_en.split())} words)"
                )

            if def_vi and len(def_vi.split()) < 5:
                definition_issues.append(
                    f"Line {idx} ({word}): definitionVi too short ({len(def_vi.split())} words)"
                )

    # Print results
    print(f"📈 Data Completeness (Total: {total} words):\n")

    for field in AI_FIELDS:
        count = stats[field]
        percentage = (count / total * 100) if total > 0 else 0
        status = "✅" if percentage == 100 else ("⚠️" if percentage > 95 else "❌")
        print(f"  {status} {field:20s} {count:4d}/{total} ({percentage:5.1f}%)")

    print()
    print("=" * 80)

    # Overall status
    all_complete = all(stats[field] == total for field in AI_FIELDS)

    if all_complete:
        print("✅ ALL FIELDS 100% COMPLETE!")
    else:
        print("⚠️ SOME FIELDS INCOMPLETE")
        print(f"   Missing data: {len(issues)} issues")

    print()

    # Quality issues
    print("🔍 Quality Issues:\n")

    if ipa_format_issues:
        print(f"  ⚠️ IPA Format Issues: {len(ipa_format_issues)}")
        for issue in ipa_format_issues[:5]:
            print(f"     - {issue}")
        if len(ipa_format_issues) > 5:
            print(f"     ... and {len(ipa_format_issues) - 5} more")
    else:
        print("  ✅ IPA Format: All valid")

    print()

    if example_word_issues:
        print(f"  ⚠️ Examples Not Using Word: {len(example_word_issues)}")
        for issue in example_word_issues[:5]:
            print(f"     - {issue}")
        if len(example_word_issues) > 5:
            print(f"     ... and {len(example_word_issues) - 5} more")
    else:
        print("  ✅ Examples: All use target word")

    print()

    if translation_issues:
        print(f"  ⚠️ Translation Issues: {len(translation_issues)}")
        for issue in translation_issues[:5]:
            print(f"     - {issue}")
        if len(translation_issues) > 5:
            print(f"     ... and {len(translation_issues) - 5} more")
    else:
        print("  ✅ Translations: All valid")

    print()

    if definition_issues:
        print(f"  ⚠️ Definition Issues: {len(definition_issues)}")
        for issue in definition_issues[:5]:
            print(f"     - {issue}")
        if len(definition_issues) > 5:
            print(f"     ... and {len(definition_issues) - 5} more")
    else:
        print("  ✅ Definitions: All valid length")

    print()
    print("=" * 80)

    # Final summary
    total_issues = (len(issues) + len(ipa_format_issues) +
                   len(example_word_issues) + len(translation_issues) +
                   len(definition_issues))

    if total_issues == 0:
        print()
        print("🎉 VALIDATION PASSED! CSV is ready for Firebase upload.")
        print()
        print("Next steps:")
        print("  1. Review output above")
        print("  2. Spot-check 20 random words manually")
        print("  3. Run: python3 migrate_perfect_to_firebase.py")
        print()
    else:
        print()
        print(f"⚠️ FOUND {total_issues} ISSUES")
        print()
        print("Recommended actions:")
        print("  1. Review issues above")
        print("  2. Fix critical issues (missing data, IPA format)")
        print("  3. Optionally fix quality issues (examples, definitions)")
        print("  4. Re-run validation")
        print()

        # Export issues to file
        with open('validation_issues.txt', 'w', encoding='utf-8') as f:
            f.write("VALIDATION ISSUES\n")
            f.write("=" * 80 + "\n\n")

            if issues:
                f.write("Missing Data:\n")
                for issue in issues:
                    f.write(f"  {issue}\n")
                f.write("\n")

            if ipa_format_issues:
                f.write("IPA Format Issues:\n")
                for issue in ipa_format_issues:
                    f.write(f"  {issue}\n")
                f.write("\n")

            if example_word_issues:
                f.write("Example Word Issues:\n")
                for issue in example_word_issues:
                    f.write(f"  {issue}\n")
                f.write("\n")

            if translation_issues:
                f.write("Translation Issues:\n")
                for issue in translation_issues:
                    f.write(f"  {issue}\n")
                f.write("\n")

            if definition_issues:
                f.write("Definition Issues:\n")
                for issue in definition_issues:
                    f.write(f"  {issue}\n")

        print(f"  📄 Issues exported to: validation_issues.txt")
        print()

    print("=" * 80)

    return total_issues == 0


if __name__ == '__main__':
    validate_csv()
