/**
 * Entry Point: Tugas 1 Pemrograman Perangkat Bergerak
 * Menjalankan seluruh jawaban soal 1, soal 2, dan soal 3.
 */

import { runSoal1 } from './soal1';
import { runSoal2 } from './soal2';
import { runSoal3 } from './soal3';

declare const process: {
  argv: string[];
};

const main = (): void => {
  // Use NIM passed via CLI argument or default to example NIM from task description
  const customNim =
    typeof process !== 'undefined' ? process.argv[2] : undefined;
  const DEFAULT_NIM = '054750333';
  const nimToUse = customNim ? customNim.trim() : DEFAULT_NIM;

  console.log('====================================================');
  console.log(`  TUGAS 1 - PEMROGRAMAN PERANGKAT BERGERAK`);
  console.log(`  NIM Mahasiswa: ${nimToUse}`);
  console.log('====================================================\n');

  // Run Question 1
  runSoal1(nimToUse);
  console.log('\n----------------------------------------------------\n');

  // Run Question 2
  runSoal2(nimToUse);
  console.log('\n----------------------------------------------------\n');

  // Run Question 3
  runSoal3(nimToUse);
  console.log('\n====================================================');
};;;

main();
