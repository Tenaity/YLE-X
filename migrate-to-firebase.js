#!/usr/bin/env node

/**
 * Cambridge Vocabulary 2018 → Firebase Firestore Migration (JavaScript)
 *
 * This script migrates Cam_Voca_2018.csv to Firebase Firestore.
 *
 * Prerequisites:
 *   npm install firebase-admin csv-parser
 *
 * Usage:
 *   node migrate-to-firebase.js
 */

const admin = require('firebase-admin');
const fs = require('fs');
const csv = require('csv-parser');
const path = require('path');

// ============================================================================
// CONFIGURATION
// ============================================================================

const CONFIG = {
  csvFile: 'Cam_Voca_2018.csv',
  serviceAccountKey: 'serviceAccountKey.json',
  dryRun: true, // Set to false to upload
  batchSize: 500, // Firestore batch limit
};

// ============================================================================
// CONSTANTS
// ============================================================================

const POS_COLUMNS = [
  'adjective', 'adverb', 'conjunction', 'determiner', 'discourse_marker',
  'exclamation', 'interrogative', 'noun', 'possessive', 'preposition',
  'pronoun', 'title', 'verb'
];

const LEVEL_COLUMNS = ['starters', 'movers', 'flyers'];

const CATEGORY_COLUMNS = [
  'animals', 'body_and_face', 'clothes', 'colours', 'family_and_friends',
  'food_and_drink', 'health', 'home', 'materials', 'names', 'numbers',
  'places_and_directions', 'school', 'sports_and_leisure', 'time',
  'toys', 'transport', 'weather', 'work', 'world_around_us'
];

const CATEGORIES_DATA = {
  animals: { name: 'Animals', nameVi: 'Động Vật', icon: '🐾', color: '#4ECDC4', order: 1 },
  body_and_face: { name: 'Body & Face', nameVi: 'Cơ Thể', icon: '👤', color: '#FFB6B9', order: 2 },
  clothes: { name: 'Clothes', nameVi: 'Quần Áo', icon: '👕', color: '#FECA57', order: 3 },
  colours: { name: 'Colours', nameVi: 'Màu Sắc', icon: '🎨', color: '#FF6B6B', order: 4 },
  family_and_friends: { name: 'Family & Friends', nameVi: 'Gia Đình', icon: '👨‍👩‍👧‍👦', color: '#F9CA24', order: 5 },
  food_and_drink: { name: 'Food & Drink', nameVi: 'Đồ Ăn', icon: '🍔', color: '#FF6B6B', order: 6 },
  health: { name: 'Health', nameVi: 'Sức Khỏe', icon: '💊', color: '#EE5A6F', order: 7 },
  home: { name: 'Home', nameVi: 'Nhà Cửa', icon: '🏠', color: '#F79F1F', order: 8 },
  materials: { name: 'Materials', nameVi: 'Vật Liệu', icon: '🧱', color: '#A3CB38', order: 9 },
  names: { name: 'Names', nameVi: 'Tên', icon: '👤', color: '#1289A7', order: 10 },
  numbers: { name: 'Numbers', nameVi: 'Số', icon: '🔢', color: '#5758BB', order: 11 },
  places_and_directions: { name: 'Places', nameVi: 'Địa Điểm', icon: '🗺️', color: '#12CBC4', order: 12 },
  school: { name: 'School', nameVi: 'Trường Học', icon: '🎓', color: '#FDA7DF', order: 13 },
  sports_and_leisure: { name: 'Sports', nameVi: 'Thể Thao', icon: '⚽', color: '#F79F1F', order: 14 },
  time: { name: 'Time', nameVi: 'Thời Gian', icon: '⏰', color: '#ED4C67', order: 15 },
  toys: { name: 'Toys', nameVi: 'Đồ Chơi', icon: '🧸', color: '#FFC312', order: 16 },
  transport: { name: 'Transport', nameVi: 'Phương Tiện', icon: '🚗', color: '#C4E538', order: 17 },
  weather: { name: 'Weather', nameVi: 'Thời Tiết', icon: '☀️', color: '#0652DD', order: 18 },
  work: { name: 'Work', nameVi: 'Công Việc', icon: '💼', color: '#9980FA', order: 19 },
  world_around_us: { name: 'World', nameVi: 'Thế Giới', icon: '🌍', color: '#009432', order: 20 }
};

// ============================================================================
// FIREBASE INITIALIZATION
// ============================================================================

let db;

function initializeFirebase() {
  try {
    const serviceAccount = require(`./${CONFIG.serviceAccountKey}`);

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });

    db = admin.firestore();
    console.log('✅ Firebase initialized');
    return true;
  } catch (error) {
    console.error('❌ Firebase initialization error:', error.message);
    return false;
  }
}

// ============================================================================
// CSV PARSING
// ============================================================================

function parseCSVRow(row) {
  const wordBritish = (row.british || '').trim();
  const wordAmerican = (row.american || '').trim();
  const wordId = wordBritish
    .toLowerCase()
    .replace(/\s+/g, '_')
    .replace(/'/g, '')
    .replace(/-/g, '_');

  // Grammar - Part of Speech
  const posList = POS_COLUMNS.filter(pos => row[pos] === 'TRUE');
  const primaryPos = posList.length > 0 ? posList[0] : 'unknown';

  // YLE Levels
  const levels = LEVEL_COLUMNS.filter(level => row[level] === 'TRUE');
  const primaryLevel = levels.length > 0 ? levels[0] : 'starters';

  // Categories
  const categories = CATEGORY_COLUMNS.filter(cat => row[cat] === 'TRUE');

  // Difficulty
  const difficulty = levels.includes('starters') ? 1 : (levels.includes('movers') ? 2 : 3);

  // Audio URLs
  const cambridgeGB = (row.cambridgeAudioGB || '').trim();
  const cambridgeUS = (row.cambridgeAudioUS || '').trim();
  const oldAudioUrl = (row.audioValue || '').trim();
  const oldAudioSource = (row.audioSource || '').trim();
  const isBritish = row.isBritishAccent === 'TRUE';
  const isAmerican = row.isAmericanAccent === 'TRUE';

  // IPA (separate for each accent)
  const ipaGB = (row.ipaGB || '').trim();
  const ipaUS = (row.ipaUS || '').trim();

  // Pronunciation object
  const pronunciation = {
    british: {
      ipa: ipaGB,
      audioUrl: cambridgeGB || (isBritish ? oldAudioUrl : ''),
      audioSource: cambridgeGB ? 'Cambridge' : (isBritish ? oldAudioSource : '')
    },
    american: {
      ipa: ipaUS,
      audioUrl: cambridgeUS || (isAmerican ? oldAudioUrl : ''),
      audioSource: cambridgeUS ? 'Cambridge' : (isAmerican ? oldAudioSource : '')
    }
  };

  // Examples with Vietnamese translations
  const examples = [];

  // Starters
  const exStartersEn = (row.exampleStarters || '').trim();
  const exStartersVi = (row.exampleStartersVi || '').trim();
  if (exStartersEn) {
    examples.push({
      level: 'starters',
      sentenceEn: exStartersEn,
      sentenceVi: exStartersVi
    });
  }

  // Movers
  const exMoversEn = (row.exampleMovers || '').trim();
  const exMoversVi = (row.exampleMoversVi || '').trim();
  if (exMoversEn) {
    examples.push({
      level: 'movers',
      sentenceEn: exMoversEn,
      sentenceVi: exMoversVi
    });
  }

  // Flyers
  const exFlyersEn = (row.exampleFlyers || '').trim();
  const exFlyersVi = (row.exampleFlyersVi || '').trim();
  if (exFlyersEn) {
    examples.push({
      level: 'flyers',
      sentenceEn: exFlyersEn,
      sentenceVi: exFlyersVi
    });
  }

  // Firestore document
  const docData = {
    wordId: wordId,
    word: wordBritish,
    british: wordBritish,
    american: wordAmerican,
    irregular_plural: row.irregular_plural === 'TRUE',

    partOfSpeech: posList,
    primaryPos: primaryPos,

    levels: levels,
    primaryLevel: primaryLevel,

    categories: categories,

    translationVi: (row.translationVi || '').trim(),
    definitionEn: (row.definitionEn || '').trim(),
    definitionVi: (row.definitionVi || '').trim(),

    pronunciation: pronunciation,

    imageUrl: '',
    emoji: '',

    examples: examples,

    difficulty: difficulty,
    frequency: 'common',
    xpValue: 5,
    gemsValue: 1,
    addedDate: admin.firestore.FieldValue.serverTimestamp(),
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),

    dataCompleteness: {
      hasTranslation: !!row.translationVi?.trim(),
      hasDefinitionEn: !!row.definitionEn?.trim(),
      hasDefinitionVi: !!row.definitionVi?.trim(),
      hasIPABritish: !!ipaGB,
      hasIPAAmerican: !!ipaUS,
      hasAudioBritish: !!pronunciation.british.audioUrl,
      hasAudioAmerican: !!pronunciation.american.audioUrl,
      hasExamplesEn: examples.some(ex => ex.sentenceEn),
      hasExamplesVi: examples.some(ex => ex.sentenceVi)
    }
  };

  return { wordId, docData };
}

// ============================================================================
// CATEGORY UPLOAD
// ============================================================================

async function uploadCategories() {
  console.log('\n📁 Uploading categories...');

  // Count words per category from CSV
  const categoryCounts = {};
  CATEGORY_COLUMNS.forEach(cat => {
    categoryCounts[cat] = 0;
  });

  await new Promise((resolve, reject) => {
    fs.createReadStream(CONFIG.csvFile)
      .pipe(csv())
      .on('data', (row) => {
        CATEGORY_COLUMNS.forEach(cat => {
          if (row[cat] === 'TRUE') {
            categoryCounts[cat]++;
          }
        });
      })
      .on('end', resolve)
      .on('error', reject);
  });

  // Upload categories
  for (const [catId, catData] of Object.entries(CATEGORIES_DATA)) {
    const doc = {
      categoryId: catId,
      name: catData.name,
      nameVi: catData.nameVi,
      icon: catData.icon,
      color: catData.color,
      order: catData.order,
      wordCount: categoryCounts[catId] || 0,
      description: `Words related to ${catData.name.toLowerCase()}`,
      descriptionVi: `Từ vựng về ${catData.nameVi.toLowerCase()}`
    };

    if (CONFIG.dryRun) {
      console.log(`   [DRY] ${catData.name}: ${doc.wordCount} words`);
    } else {
      await db.collection('categories').doc(catId).set(doc);
      console.log(`   ✅ ${catData.name}: ${doc.wordCount} words`);
    }
  }

  console.log('✅ Categories complete');
}

// ============================================================================
// VOCABULARY MIGRATION
// ============================================================================

async function migrateVocabulary() {
  console.log(`\n📚 Migrating vocabulary...`);
  console.log(`   CSV: ${CONFIG.csvFile}`);
  console.log(`   Mode: ${CONFIG.dryRun ? 'DRY RUN' : 'LIVE'}\n`);

  const words = [];
  const stats = {
    translation: 0,
    def_en: 0,
    def_vi: 0,
    ipa_gb: 0,
    ipa_us: 0,
    audio_gb: 0,
    audio_us: 0,
    examples_en: 0,
    examples_vi: 0
  };

  // Read CSV
  await new Promise((resolve, reject) => {
    fs.createReadStream(CONFIG.csvFile)
      .pipe(csv())
      .on('data', (row) => {
        try {
          const { wordId, docData } = parseCSVRow(row);
          words.push({ wordId, docData });

          // Track stats
          if (docData.dataCompleteness.hasTranslation) stats.translation++;
          if (docData.dataCompleteness.hasDefinitionEn) stats.def_en++;
          if (docData.dataCompleteness.hasDefinitionVi) stats.def_vi++;
          if (docData.dataCompleteness.hasIPABritish) stats.ipa_gb++;
          if (docData.dataCompleteness.hasIPAAmerican) stats.ipa_us++;
          if (docData.dataCompleteness.hasAudioBritish) stats.audio_gb++;
          if (docData.dataCompleteness.hasAudioAmerican) stats.audio_us++;
          if (docData.dataCompleteness.hasExamplesEn) stats.examples_en++;
          if (docData.dataCompleteness.hasExamplesVi) stats.examples_vi++;
        } catch (error) {
          console.error(`   ❌ Error parsing row: ${error.message}`);
        }
      })
      .on('end', resolve)
      .on('error', reject);
  });

  console.log(`   Total: ${words.length} words\n`);

  // Upload in batches
  if (!CONFIG.dryRun) {
    let uploaded = 0;
    for (let i = 0; i < words.length; i += CONFIG.batchSize) {
      const batch = db.batch();
      const chunk = words.slice(i, i + CONFIG.batchSize);

      chunk.forEach(({ wordId, docData }) => {
        const docRef = db.collection('dictionaries').doc(wordId);
        batch.set(docRef, docData);
      });

      await batch.commit();
      uploaded += chunk.length;
      console.log(`   Uploaded ${uploaded}/${words.length}...`);
    }
  } else {
    console.log(`   [DRY RUN] Would upload ${words.length} words`);
  }

  // Print summary
  console.log('\n' + '='.repeat(70));
  console.log('📊 Migration Summary:');
  console.log(`   ✅ Success: ${words.length}/${words.length}`);
  console.log('\n📈 Data Completeness:');
  console.log(`   Translation Vi:    ${stats.translation.toString().padStart(4)} (${(stats.translation/words.length*100).toFixed(1)}%)`);
  console.log(`   Definition En:     ${stats.def_en.toString().padStart(4)} (${(stats.def_en/words.length*100).toFixed(1)}%)`);
  console.log(`   Definition Vi:     ${stats.def_vi.toString().padStart(4)} (${(stats.def_vi/words.length*100).toFixed(1)}%)`);
  console.log(`   IPA British:       ${stats.ipa_gb.toString().padStart(4)} (${(stats.ipa_gb/words.length*100).toFixed(1)}%)`);
  console.log(`   IPA American:      ${stats.ipa_us.toString().padStart(4)} (${(stats.ipa_us/words.length*100).toFixed(1)}%)`);
  console.log(`   Audio British:     ${stats.audio_gb.toString().padStart(4)} (${(stats.audio_gb/words.length*100).toFixed(1)}%)`);
  console.log(`   Audio American:    ${stats.audio_us.toString().padStart(4)} (${(stats.audio_us/words.length*100).toFixed(1)}%)`);
  console.log(`   Examples (En):     ${stats.examples_en.toString().padStart(4)} (${(stats.examples_en/words.length*100).toFixed(1)}%)`);
  console.log(`   Examples (Vi):     ${stats.examples_vi.toString().padStart(4)} (${(stats.examples_vi/words.length*100).toFixed(1)}%)`);
  console.log('='.repeat(70) + '\n');

  return words.length;
}

// ============================================================================
// MAIN
// ============================================================================

async function main() {
  console.log('='.repeat(70));
  console.log('📖 Cambridge Vocabulary 2018 → Firebase Migration (JavaScript)');
  console.log('='.repeat(70));

  if (CONFIG.dryRun) {
    console.log('\n⚠️  DRY RUN MODE\n');
  } else {
    console.log('\n🚀 LIVE MODE\n');

    // Confirm with user
    const readline = require('readline').createInterface({
      input: process.stdin,
      output: process.stdout
    });

    const answer = await new Promise(resolve => {
      readline.question('   Continue? (yes/no): ', resolve);
    });
    readline.close();

    if (answer.toLowerCase() !== 'yes') {
      console.log('\n❌ Aborted\n');
      process.exit(0);
    }
  }

  // Initialize Firebase (skip in dry run)
  if (!CONFIG.dryRun) {
    if (!initializeFirebase()) {
      console.log('\n❌ Cannot proceed without Firebase\n');
      process.exit(1);
    }
  }

  // Upload categories
  if (!CONFIG.dryRun) {
    await uploadCategories();
  } else {
    console.log('\n📁 [DRY RUN] Categories (would upload 20 categories)');
  }

  // Migrate vocabulary
  await migrateVocabulary();

  console.log('\n✅ Migration complete!\n');

  if (CONFIG.dryRun) {
    console.log('💡 Next steps:');
    console.log('   1. Review output above');
    console.log('   2. Set CONFIG.dryRun = false in this file');
    console.log('   3. Run: node migrate-to-firebase.js\n');
  } else {
    console.log('💡 Next steps:');
    console.log('   1. Verify data in Firebase Console');
    console.log('   2. Create Firestore indexes (see docs)');
    console.log('   3. Start building Swift UI!\n');
  }

  process.exit(0);
}

// Run if called directly
if (require.main === module) {
  main().catch(error => {
    console.error('❌ Fatal error:', error);
    process.exit(1);
  });
}

module.exports = { parseCSVRow, CATEGORIES_DATA };
