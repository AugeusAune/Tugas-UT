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
 * Checks if an integer is a prime number.
 *
 * @param value - Candidate number to evaluate
 * @returns boolean indicating whether value is prime
 */
export const isPrime = (value: number): boolean => {
  if (!Number.isInteger(value) || value < 2) {
    return false;
  }
  if (value === 2) {
    return true;
  }
  if (value % 2 === 0) {
    return false;
  }

  for (let divisor = 3; divisor * divisor <= value; divisor += 2) {
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
  const cleanNim = nim?.trim();
  if (!cleanNim || !/^\d+$/.test(cleanNim)) {
    throw new Error('NIM must be a non-empty numeric string.');
  }

  if (cleanNim.length < 2) {
    throw new Error('NIM must contain at least 2 digits.');
  }

  const OFFSET = 10;
  const lastTwoDigits = Number.parseInt(cleanNim.slice(-2), 10);
  const upperLimit = lastTwoDigits + OFFSET;

  const primes = Array.from(
    { length: upperLimit },
    (_, index) => index + 1,
  ).filter(isPrime);

  return { lastTwoDigits, upperLimit, primes };
};

/**
 * Executes and prints the output for Question 3.
 *
 * @param nim - Student Identification Number (default: '230411013')
 */
export const runSoal3 = (nim = '230411013'): void => {
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
