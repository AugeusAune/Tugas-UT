/**
 * Entry Point: Tugas 1 Pemrograman Perangkat Bergerak
 * Runs solutions for Question 1, Question 2, and Question 3.
 */

import { runSoal1 } from './soal1';
import { runSoal2 } from './soal2';
import { runSoal3 } from './soal3';

declare const process: { argv: string[] };

const DEFAULT_NIM = '054750333';

const main = (): void => {
  const nim = (typeof process !== 'undefined' && process.argv[2]?.trim()) || DEFAULT_NIM;

  console.log('====================================================');
  console.log('  TUGAS 1 - PEMROGRAMAN PERANGKAT BERGERAK');
  console.log(`  NIM Mahasiswa: ${nim}`);
  console.log('====================================================\n');

  runSoal1(nim);
  console.log('\n----------------------------------------------------\n');

  runSoal2(nim);
  console.log('\n----------------------------------------------------\n');

  runSoal3(nim);
  console.log('\n====================================================');
};

main();
