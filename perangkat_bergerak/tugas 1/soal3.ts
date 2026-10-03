/**
 * Soal 3: Bilangan Prima dari NIM
 * Ambil 2 digit terakhir NIM dan tambahkan 10 sebagai batas akhir pencarian.
 * Tampilkan semua bilangan prima dari 1 sampai batas tersebut.
 */

export interface PrimeSearchResult {
  lastTwoDigits: number;
  upperLimit: number;
  primes: number[];
}

/**
 * Checks if a number is a prime number.
 *
 * @param value - Candidate number to evaluate
 * @returns boolean indicating whether value is prime
 */
export const isPrime = (value: number): boolean => {
  // Bilangan prima hanya berlaku untuk integer >= 2 (NaN dan Infinity ikut tertolak)
  if (!Number.isInteger(value) || value < 2) {
    return false;
  }

  // Cukup cek pembagi sampai akar kuadrat value
  for (let divisor = 2; divisor * divisor <= value; divisor++) {
    if (value % divisor === 0) {
      return false;
    }
  }

  return true;
};

/**
 * Finds all prime numbers from 1 up to (last 2 digits of NIM + 10).
 *
 * @param nim - Student Identification Number
 * @returns PrimeSearchResult containing boundary and list of primes
 */
export const findPrimesFromNim = (nim: string): PrimeSearchResult => {
  if (!nim || typeof nim !== 'string') {
    throw new Error('NIM must be a non-empty string.');
  }

  const cleanNim = nim.trim();
  if (!/^\d+$/.test(cleanNim)) {
    throw new Error('NIM must contain only numeric digits.');
  }

  if (cleanNim.length < 2) {
    throw new Error('NIM must contain at least 2 digits.');
  }

  const OFFSET = 10;
  const lastTwoDigits = Number.parseInt(cleanNim.slice(-2), 10);
  const upperLimit = lastTwoDigits + OFFSET;

  const primes: number[] = [];
  for (let candidate = 1; candidate <= upperLimit; candidate++) {
    if (isPrime(candidate)) {
      primes.push(candidate);
    }
  }

  return {
    lastTwoDigits,
    upperLimit,
    primes,
  };
};

/**
 * Executes and prints the output for Question 3.
 *
 * @param nim - Student Identification Number (default: '230411013')
 */
export const runSoal3 = (nim: string = '230411013'): void => {
  try {
    const result = findPrimesFromNim(nim);

    console.log('--- Soal 3: Bilangan Prima dari NIM ---');
    console.log(`NIM                                : ${nim}`);
    console.log(`2 Digit Terakhir                   : ${result.lastTwoDigits}`);
    console.log(`Batas Akhir (2 digit terakhir + 10): ${result.upperLimit}`);
    console.log(`Output: ${result.primes.join(', ')}`);
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    console.error(`[Soal 3 Error]: ${message}`);
  }
};
