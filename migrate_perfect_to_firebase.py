#!/usr/bin/env python3
"""
Cambridge Vocabulary 2018 PERFECT → Firebase Firestore Migration

This is the FINAL, PRODUCTION-READY migration script.

CSV Structure (58 columns):
- Base data: word, levels, categories, part of speech
- Audio: cambridgeAudioGB, cambridgeAudioUS, old audioValue
- Content: translationVi, definitionEn, definitionVi
- Phonetics: ipaGB, ipaUS (separate for each accent)
- Examples: exampleStarters/Movers/Flyers (English)
- Examples Vi: exampleStartersVi/MoversVi/FlyersVi (Vietnamese)

Usage:
    python3 migrate_perfect_to_firebase.py
"""

import csv
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime

# Configuration
CSV_FILE = 'Cam_Voca_2018.csv'  # Updated to use your completed file
SERVICE_ACCOUNT_KEY = 'serviceAccountKey.json'
DRY_RUN = True  # Set to False to upload

# [Same constants as before]
POS_COLUMNS = [
    'adjective', 'adverb', 'conjunction', 'determiner', 'discourse_marker',
    'exclamation', 'interrogative', 'noun', 'possessive', 'preposition',
    'pronoun', 'title', 'verb'
]

LEVEL_COLUMNS = ['starters', 'movers', 'flyers']

CATEGORY_COLUMNS = [
    'animals', 'body_and_face', 'clothes', 'colours', 'family_and_friends',
    'food_and_drink', 'health', 'home', 'materials', 'names', 'numbers',
    'places_and_directions', 'school', 'sports_and_leisure', 'time',
    'toys', 'transport', 'weather', 'work', 'world_around_us'
]

CATEGORIES_DATA = {
    'animals': {'name': 'Animals', 'nameVi': 'Động Vật', 'icon': '🐾', 'color': '#4ECDC4', 'order': 1},
    'body_and_face': {'name': 'Body & Face', 'nameVi': 'Cơ Thể', 'icon': '👤', 'color': '#FFB6B9', 'order': 2},
    'clothes': {'name': 'Clothes', 'nameVi': 'Quần Áo', 'icon': '👕', 'color': '#FECA57', 'order': 3},
    'colours': {'name': 'Colours', 'nameVi': 'Màu Sắc', 'icon': '🎨', 'color': '#FF6B6B', 'order': 4},
    'family_and_friends': {'name': 'Family & Friends', 'nameVi': 'Gia Đình', 'icon': '👨‍👩‍👧‍👦', 'color': '#F9CA24', 'order': 5},
    'food_and_drink': {'name': 'Food & Drink', 'nameVi': 'Đồ Ăn', 'icon': '🍔', 'color': '#FF6B6B', 'order': 6},
    'health': {'name': 'Health', 'nameVi': 'Sức Khỏe', 'icon': '💊', 'color': '#EE5A6F', 'order': 7},
    'home': {'name': 'Home', 'nameVi': 'Nhà Cửa', 'icon': '🏠', 'color': '#F79F1F', 'order': 8},
    'materials': {'name': 'Materials', 'nameVi': 'Vật Liệu', 'icon': '🧱', 'color': '#A3CB38', 'order': 9},
    'names': {'name': 'Names', 'nameVi': 'Tên', 'icon': '👤', 'color': '#1289A7', 'order': 10},
    'numbers': {'name': 'Numbers', 'nameVi': 'Số', 'icon': '🔢', 'color': '#5758BB', 'order': 11},
    'places_and_directions': {'name': 'Places', 'nameVi': 'Địa Điểm', 'icon': '🗺️', 'color': '#12CBC4', 'order': 12},
    'school': {'name': 'School', 'nameVi': 'Trường Học', 'icon': '🎓', 'color': '#FDA7DF', 'order': 13},
    'sports_and_leisure': {'name': 'Sports', 'nameVi': 'Thể Thao', 'icon': '⚽', 'color': '#F79F1F', 'order': 14},
    'time': {'name': 'Time', 'nameVi': 'Thời Gian', 'icon': '⏰', 'color': '#ED4C67', 'order': 15},
    'toys': {'name': 'Toys', 'nameVi': 'Đồ Chơi', 'icon': '🧸', 'color': '#FFC312', 'order': 16},
    'transport': {'name': 'Transport', 'nameVi': 'Phương Tiện', 'icon': '🚗', 'color': '#C4E538', 'order': 17},
    'weather': {'name': 'Weather', 'nameVi': 'Thời Tiết', 'icon': '☀️', 'color': '#0652DD', 'order': 18},
    'work': {'name': 'Work', 'nameVi': 'Công Việc', 'icon': '💼', 'color': '#9980FA', 'order': 19},
    'world_around_us': {'name': 'World', 'nameVi': 'Thế Giới', 'icon': '🌍', 'color': '#009432', 'order': 20}
}


def initialize_firebase():
    """Initialize Firebase"""
    try:
        cred = credentials.Certificate(SERVICE_ACCOUNT_KEY)
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("✅ Firebase initialized")
        return db
    except Exception as e:
        print(f"❌ Firebase error: {e}")
        return None


def parse_csv_row(row):
    """Parse PERFECT CSV row to Firestore format"""
    word_british = row['british'].strip()
    word_american = row['american'].strip()
    word_id = word_british.lower().replace(' ', '_').replace("'", '').replace('-', '_')

    # Grammar
    pos_list = [pos for pos in POS_COLUMNS if row[pos] == 'True']
    primary_pos = pos_list[0] if pos_list else 'unknown'

    # Levels
    levels = [level for level in LEVEL_COLUMNS if row[level] == 'True']
    primary_level = levels[0] if levels else 'starters'

    # Categories
    categories = [cat for cat in CATEGORY_COLUMNS if row[cat] == 'True']

    difficulty = 1 if 'starters' in levels else (2 if 'movers' in levels else 3)

    # AUDIO with priority system
    cambridge_gb = row.get('cambridgeAudioGB', '').strip()
    cambridge_us = row.get('cambridgeAudioUS', '').strip()
    old_audio_url = row.get('audioValue', '').strip()
    old_audio_source = row.get('audioSource', '').strip()
    is_british = row.get('isBritishAccent') == 'True'
    is_american = row.get('isAmericanAccent') == 'True'

    # SEPARATE IPA for each accent
    ipa_gb = row.get('ipaGB', '').strip()
    ipa_us = row.get('ipaUS', '').strip()

    pronunciation = {
        'british': {
            'ipa': ipa_gb,
            'audioUrl': cambridge_gb if cambridge_gb else (old_audio_url if is_british else ''),
            'audioSource': 'Cambridge' if cambridge_gb else (old_audio_source if is_british else '')
        },
        'american': {
            'ipa': ipa_us,
            'audioUrl': cambridge_us if cambridge_us else (old_audio_url if is_american else ''),
            'audioSource': 'Cambridge' if cambridge_us else (old_audio_source if is_american else '')
        }
    }

    # EXAMPLES with Vietnamese translations
    examples = []

    # Starters
    ex_start_en = row.get('exampleStarters', '').strip()
    ex_start_vi = row.get('exampleStartersVi', '').strip()
    if ex_start_en:
        examples.append({
            'level': 'starters',
            'sentenceEn': ex_start_en,
            'sentenceVi': ex_start_vi
        })

    # Movers
    ex_mov_en = row.get('exampleMovers', '').strip()
    ex_mov_vi = row.get('exampleMoversVi', '').strip()
    if ex_mov_en:
        examples.append({
            'level': 'movers',
            'sentenceEn': ex_mov_en,
            'sentenceVi': ex_mov_vi
        })

    # Flyers
    ex_fly_en = row.get('exampleFlyers', '').strip()
    ex_fly_vi = row.get('exampleFlyersVi', '').strip()
    if ex_fly_en:
        examples.append({
            'level': 'flyers',
            'sentenceEn': ex_fly_en,
            'sentenceVi': ex_fly_vi
        })

    # Firestore document
    doc_data = {
        'wordId': word_id,
        'word': word_british,
        'british': word_british,
        'american': word_american,
        'irregular_plural': row['irregular_plural'] == 'True',

        'partOfSpeech': pos_list,
        'primaryPos': primary_pos,

        'levels': levels,
        'primaryLevel': primary_level,

        'categories': categories,

        'translationVi': row.get('translationVi', '').strip(),
        'definitionEn': row.get('definitionEn', '').strip(),
        'definitionVi': row.get('definitionVi', '').strip(),

        'pronunciation': pronunciation,

        'imageUrl': '',
        'emoji': '',

        'examples': examples,

        'difficulty': difficulty,
        'frequency': 'common',
        'xpValue': 5,
        'gemsValue': 1,
        'addedDate': datetime.now().isoformat(),
        'lastUpdated': datetime.now().isoformat(),

        'dataCompleteness': {
            'hasTranslation': bool(row.get('translationVi', '').strip()),
            'hasDefinitionEn': bool(row.get('definitionEn', '').strip()),
            'hasDefinitionVi': bool(row.get('definitionVi', '').strip()),
            'hasIPABritish': bool(ipa_gb),
            'hasIPAAmerican': bool(ipa_us),
            'hasAudioBritish': bool(pronunciation['british']['audioUrl']),
            'hasAudioAmerican': bool(pronunciation['american']['audioUrl']),
            'hasExamplesEn': any(ex['sentenceEn'] for ex in examples),
            'hasExamplesVi': any(ex['sentenceVi'] for ex in examples)
        }
    }

    return word_id, doc_data


def upload_categories(db):
    """Upload categories"""
    print("\n📁 Uploading categories...")

    for cat_id, cat_data in CATEGORIES_DATA.items():
        word_count = 0
        with open(CSV_FILE, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            word_count = sum(1 for row in reader if row[cat_id] == 'True')

        doc = {
            'categoryId': cat_id,
            'name': cat_data['name'],
            'nameVi': cat_data['nameVi'],
            'icon': cat_data['icon'],
            'color': cat_data['color'],
            'order': cat_data['order'],
            'wordCount': word_count,
            'description': f"Words related to {cat_data['name'].lower()}",
            'descriptionVi': f"Từ vựng về {cat_data['nameVi'].lower()}"
        }

        if DRY_RUN:
            print(f"   [DRY] {cat_data['name']}: {word_count} words")
        else:
            db.collection('categories').document(cat_id).set(doc)
            print(f"   ✅ {cat_data['name']}: {word_count} words")

    print(f"✅ Categories complete")


def migrate_vocabulary(db):
    """Migrate vocabulary"""
    print(f"\n📚 Migrating vocabulary...")
    print(f"   CSV: {CSV_FILE}")
    print(f"   Mode: {'DRY RUN' if DRY_RUN else 'LIVE'}\n")

    success = 0
    stats = {
        'translation': 0,
        'def_en': 0,
        'def_vi': 0,
        'ipa_gb': 0,
        'ipa_us': 0,
        'audio_gb': 0,
        'audio_us': 0,
        'examples_en': 0,
        'examples_vi': 0
    }

    with open(CSV_FILE, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        total = sum(1 for _ in reader)

    print(f"   Total: {total} words\n")

    with open(CSV_FILE, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)

        for idx, row in enumerate(reader, 1):
            try:
                word_id, doc = parse_csv_row(row)

                # Track stats
                if doc['dataCompleteness']['hasTranslation']:
                    stats['translation'] += 1
                if doc['dataCompleteness']['hasDefinitionEn']:
                    stats['def_en'] += 1
                if doc['dataCompleteness']['hasDefinitionVi']:
                    stats['def_vi'] += 1
                if doc['dataCompleteness']['hasIPABritish']:
                    stats['ipa_gb'] += 1
                if doc['dataCompleteness']['hasIPAAmerican']:
                    stats['ipa_us'] += 1
                if doc['dataCompleteness']['hasAudioBritish']:
                    stats['audio_gb'] += 1
                if doc['dataCompleteness']['hasAudioAmerican']:
                    stats['audio_us'] += 1
                if doc['dataCompleteness']['hasExamplesEn']:
                    stats['examples_en'] += 1
                if doc['dataCompleteness']['hasExamplesVi']:
                    stats['examples_vi'] += 1

                if DRY_RUN:
                    if idx % 100 == 0:
                        print(f"   Processed {idx}/{total}...")
                else:
                    db.collection('dictionaries').document(word_id).set(doc)
                    if idx % 100 == 0:
                        print(f"   Uploaded {idx}/{total}...")

                success += 1

            except Exception as e:
                print(f"   ❌ {row.get('british', '?')}: {e}")

    print(f"\n{'='*70}")
    print(f"📊 Migration Summary:")
    print(f"   ✅ Success: {success}/{total}")
    print(f"\n📈 Data Completeness:")
    print(f"   Translation Vi:    {stats['translation']:4d} ({stats['translation']/success*100:.1f}%)")
    print(f"   Definition En:     {stats['def_en']:4d} ({stats['def_en']/success*100:.1f}%)")
    print(f"   Definition Vi:     {stats['def_vi']:4d} ({stats['def_vi']/success*100:.1f}%)")
    print(f"   IPA British:       {stats['ipa_gb']:4d} ({stats['ipa_gb']/success*100:.1f}%)")
    print(f"   IPA American:      {stats['ipa_us']:4d} ({stats['ipa_us']/success*100:.1f}%)")
    print(f"   Audio British:     {stats['audio_gb']:4d} ({stats['audio_gb']/success*100:.1f}%)")
    print(f"   Audio American:    {stats['audio_us']:4d} ({stats['audio_us']/success*100:.1f}%)")
    print(f"   Examples (En):     {stats['examples_en']:4d} ({stats['examples_en']/success*100:.1f}%)")
    print(f"   Examples (Vi):     {stats['examples_vi']:4d} ({stats['examples_vi']/success*100:.1f}%)")
    print(f"{'='*70}\n")

    return success


def main():
    """Main function"""
    print("="*70)
    print("📖 PERFECT Migration: Cambridge Vocabulary 2018 → Firebase")
    print("="*70)

    if DRY_RUN:
        print("\n⚠️  DRY RUN MODE\n")
    else:
        print("\n🚀 LIVE MODE")
        response = input("   Continue? (yes/no): ")
        if response.lower() != 'yes':
            return

    db = None
    if not DRY_RUN:
        db = initialize_firebase()
        if not db:
            return
        upload_categories(db)
    else:
        print("\n📁 [DRY RUN] Categories")

    migrate_vocabulary(db)

    print("\n✅ Migration complete!\n")

    if DRY_RUN:
        print("💡 Next steps:")
        print("   1. Review output above")
        print("   2. Use N8N to fill empty fields (see N8N_PROMPTS_PERFECT.md)")
        print("   3. Set DRY_RUN = False")
        print("   4. Run script again\n")
    else:
        print("💡 Data completeness:")
        print("   - Use N8N to fill empty fields")
        print("   - See N8N_PROMPTS_PERFECT.md for AI prompts")
        print("   - Cost: ~$25, Time: ~12 hours\n")


if __name__ == '__main__':
    main()
