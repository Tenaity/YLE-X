#!/usr/bin/env python3
"""
Update Firebase Dictionary with Audio URLs from Cambridge Dataset

This script updates the existing dictionaries collection with audio URLs
from the Cambridge_Vocabulary_2018_with_audio.csv file.

Coverage: 87.2% (1,233 out of 1,414 words have audio)

Usage:
    python3 update_audio_urls.py
"""

import csv
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime

# Configuration
CSV_FILE = 'Cambridge_Vocabulary_2018_with_audio.csv'
SERVICE_ACCOUNT_KEY = 'serviceAccountKey.json'
DRY_RUN = True  # Set to False to actually update Firebase

def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    try:
        cred = credentials.Certificate(SERVICE_ACCOUNT_KEY)
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("✅ Firebase initialized successfully")
        return db
    except Exception as e:
        print(f"❌ Error initializing Firebase: {e}")
        return None

def determine_accent(url):
    """
    Determine if audio URL is British or American accent
    Based on URL patterns from different sources
    """
    url_lower = url.lower()

    # British indicators
    if '/uk_pron/' in url_lower or '/uk/' in url_lower or 'british' in url_lower:
        return 'british'

    # American indicators
    if '/us_pron/' in url_lower or '/us/' in url_lower or 'american' in url_lower:
        return 'american'

    # Default based on source
    if 'cambridge.org' in url_lower:
        # Cambridge URLs with /uk_pron/ are British, /us_pron/ are American
        if '/uk_pron/' in url_lower:
            return 'british'
        elif '/us_pron/' in url_lower:
            return 'american'

    if 'oxforddictionaries.com' in url_lower:
        # Oxford URLs with /uk_pron/ are British
        if '/uk_pron/' in url_lower:
            return 'british'

    # Default to American for US-based sources
    if any(source in url_lower for source in ['vocabulary.com', 'yourdictionary.com']):
        return 'american'

    # OneLook and others - check path
    if 'british' in url_lower:
        return 'british'
    if 'american' in url_lower:
        return 'american'

    # Default to British (since Cambridge YLE is British English focused)
    return 'british'

def update_audio_urls(db):
    """Update Firestore with audio URLs from CSV"""
    print(f"\n🎤 Starting audio URL update...")
    print(f"   Source: {CSV_FILE}")
    print(f"   Mode: {'DRY RUN (no data uploaded)' if DRY_RUN else 'LIVE (updating Firebase)'}\\n")

    updated_count = 0
    skipped_count = 0
    not_found_count = 0
    errors = []

    # Statistics
    british_count = 0
    american_count = 0

    with open(CSV_FILE, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        total_rows = sum(1 for _ in reader)

    print(f"   Total words in CSV: {total_rows}\\n")

    with open(CSV_FILE, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)

        for idx, row in enumerate(reader, 1):
            try:
                word_british = row['british'].strip()
                audio_url = row['audioValue'].strip() if row['audioValue'] else ''

                # Skip if no audio URL
                if not audio_url:
                    skipped_count += 1
                    continue

                # Create word ID (same as migration script)
                word_id = word_british.lower().replace(' ', '_').replace("'", '')

                # Determine accent
                accent = determine_accent(audio_url)

                # Update data structure
                update_data = {}

                if accent == 'british':
                    update_data['pronunciation.british.audioUrl'] = audio_url
                    british_count += 1
                else:
                    update_data['pronunciation.american.audioUrl'] = audio_url
                    american_count += 1

                update_data['lastUpdated'] = datetime.now().isoformat()

                if DRY_RUN:
                    if idx % 100 == 0:
                        print(f"   [DRY RUN] Processed {idx}/{total_rows} words...")
                    if idx <= 5:
                        print(f"   [DRY RUN] {word_british:15} → {accent:8} → {audio_url[:60]}...")
                else:
                    # Check if document exists
                    doc_ref = db.collection('dictionaries').document(word_id)
                    doc = doc_ref.get()

                    if doc.exists:
                        doc_ref.update(update_data)
                        updated_count += 1

                        if idx % 100 == 0:
                            print(f"   Updated {updated_count}/{total_rows} words...")
                    else:
                        not_found_count += 1
                        if not_found_count <= 5:
                            print(f"   ⚠️  Word not found in Firebase: {word_british} (ID: {word_id})")

            except Exception as e:
                errors.append({
                    'word': row.get('british', 'unknown'),
                    'error': str(e)
                })
                print(f"   ❌ Error processing '{row.get('british', 'unknown')}': {e}")

    print(f"\n{'='*70}")
    print(f"📊 Audio Update Summary:")
    print(f"   ✅ Updated: {updated_count if not DRY_RUN else 'N/A (Dry Run)'}")
    print(f"   ⏭️  Skipped (no audio): {skipped_count}")
    print(f"   ❓ Not found in Firebase: {not_found_count if not DRY_RUN else 'N/A (Dry Run)'}")
    print(f"   📝 Total processed: {total_rows}")
    print(f"\n🎯 Audio Accent Distribution:")
    print(f"   🇬🇧 British: {british_count}")
    print(f"   🇺🇸 American: {american_count}")
    print(f"{'='*70}\\n")

    if errors:
        print("⚠️  Errors encountered:")
        for err in errors[:10]:
            print(f"   - {err['word']}: {err['error']}")
        if len(errors) > 10:
            print(f"   ... and {len(errors) - 10} more errors")

    return updated_count, skipped_count

def main():
    """Main update function"""
    print("="*70)
    print("🎤 Cambridge Audio URLs → Firebase Dictionary Update")
    print("="*70)

    if DRY_RUN:
        print("\\n⚠️  DRY RUN MODE - No data will be uploaded to Firebase")
        print("   Set DRY_RUN = False in script to update data\\n")
    else:
        print("\\n🚀 LIVE MODE - Audio URLs will be updated in Firebase")
        response = input("   Continue? (yes/no): ")
        if response.lower() != 'yes':
            print("   Update cancelled.")
            return

    # Initialize Firebase (or skip if DRY_RUN)
    db = None
    if not DRY_RUN:
        db = initialize_firebase()
        if not db:
            print("❌ Cannot proceed without Firebase connection")
            return

    # Update audio URLs
    updated, skipped = update_audio_urls(db)

    print("\\n✅ Update complete!")

    if DRY_RUN:
        print("\\n💡 Next steps:")
        print("   1. Review the output above")
        print("   2. Ensure serviceAccountKey.json is in the directory")
        print("   3. Set DRY_RUN = False in script")
        print("   4. Run script again to update Firebase")
        print("\\n📊 Expected results:")
        print("   - 1,233 words will get audio URLs (87.2% coverage)")
        print("   - 181 words will remain without audio (12.8%)")
        print("   - For words without audio, use AVSpeechSynthesizer as fallback")
    else:
        print("\\n💡 Next steps:")
        print("   1. Test audio playback in app")
        print("   2. For 181 words without audio, consider:")
        print("      - Using AVSpeechSynthesizer (free, instant)")
        print("      - Generating with Google TTS via N8N ($0.30)")
        print("      - Recording with voice actors (expensive)")

if __name__ == '__main__':
    main()
