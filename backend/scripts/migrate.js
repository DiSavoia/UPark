// scripts/migrate.js

/**
 * Migration runner
 * This script loads .env via dotenv (already in dependencies),
 * then runs psql using the DATABASE_URL defined in .env.
 */

require('dotenv').config();
const { execSync } = require('child_process');

const url = process.env.DATABASE_URL;
if (!url) {
  console.error('❌  DATABASE_URL is not set. Check your .env file.');
  process.exit(1);
}

const migrationFile = 'migrations/001_create_tables.sql';
console.log(`🔄  Running migration: ${migrationFile}`);

try {
  execSync(`psql "${url}" -f ${migrationFile}`, { stdio: 'inherit' });
  console.log('✅  Migration completed successfully.');
} catch (err) {
  console.error('❌  Migration failed.', err);
  process.exit(1);
}
